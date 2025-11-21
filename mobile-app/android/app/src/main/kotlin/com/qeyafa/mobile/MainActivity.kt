package com.qeyafa.mobile

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Main Activity for Qeyafa Android app.
 * 
 * Integrates MediaPipe Pose Detection with Flutter via Platform Channels:
 * - MethodChannel: 'com.qeyafa.app/vision' for init/dispose commands
 * - EventChannel: 'com.qeyafa.app/vision_stream' for streaming pose landmarks
 */
class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val METHOD_CHANNEL = "com.qeyafa.app/vision"
        private const val EVENT_CHANNEL = "com.qeyafa.app/vision_stream"
    }

    private var poseDetectorHelper: PoseDetectorHelper? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "🔧 Configuring Flutter engine...")

        // Setup MethodChannel for commands (init, dispose)
        setupMethodChannel(flutterEngine)
        
        // Setup EventChannel for streaming pose landmarks
        setupEventChannel(flutterEngine)
        
        Log.d(TAG, "✅ Flutter engine configured")
    }

    /**
     * Setup MethodChannel to handle 'init' and 'dispose' commands from Flutter.
     */
    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "init" -> {
                        Log.d(TAG, "📞 Received 'init' command")
                        initializePoseDetector(result)
                    }
                    
                    "processFrame" -> {
                        Log.d(TAG, "📞 Received 'processFrame' command")
                        processFrame(call, result)
                    }
                    
                    "dispose" -> {
                        Log.d(TAG, "📞 Received 'dispose' command")
                        disposePoseDetector(result)
                    }
                    
                    else -> {
                        Log.w(TAG, "⚠️ Unknown method: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
    }

    /**
     * Setup EventChannel to stream pose detection results to Flutter.
     */
    private fun setupEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d(TAG, "🎧 Flutter started listening to pose stream")
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "🔇 Flutter stopped listening to pose stream")
                    eventSink = null
                }
            })
    }

    /**
     * Initialize the PoseDetectorHelper.
     */
    private fun initializePoseDetector(result: MethodChannel.Result) {
        try {
            // Dispose existing instance if any
            poseDetectorHelper?.dispose()

            // Create new helper with callbacks
            poseDetectorHelper = PoseDetectorHelper(
                context = applicationContext,
                onResults = { landmarks ->
                    sendLandmarksToFlutter(landmarks)
                },
                onError = { error ->
                    sendErrorToFlutter(error)
                }
            )

            // Initialize MediaPipe
            poseDetectorHelper?.initialize()

            Log.d(TAG, "✅ PoseDetectorHelper initialized")
            result.success(true)

        } catch (e: Exception) {
            val errorMsg = "Failed to initialize: ${e.message}"
            Log.e(TAG, "❌ $errorMsg", e)
            result.error("INIT_ERROR", errorMsg, e.stackTraceToString())
        }
    }

    /**
     * Dispose the PoseDetectorHelper and clean up resources.
     */
    private fun disposePoseDetector(result: MethodChannel.Result) {
        try {
            poseDetectorHelper?.dispose()
            poseDetectorHelper = null
            eventSink = null
            
            Log.d(TAG, "✅ PoseDetectorHelper disposed")
            result.success(true)

        } catch (e: Exception) {
            val errorMsg = "Failed to dispose: ${e.message}"
            Log.e(TAG, "⚠️ $errorMsg", e)
            result.error("DISPOSE_ERROR", errorMsg, e.stackTraceToString())
        }
    }

    /**
     * Process a camera frame for pose detection.
     * 
     * Expected call arguments:
     * - imageData: ByteArray (JPEG/PNG encoded image)
     * - width: Int (optional)
     * - height: Int (optional)
     * - rotation: Int (optional, degrees: 0, 90, 180, 270)
     */
    private fun processFrame(call: MethodChannel.MethodCall, result: MethodChannel.Result) {
        try {
            // Extract frame data from method call
            val imageData = call.argument<ByteArray>("imageData")
            val width = call.argument<Int>("width") ?: 0
            val height = call.argument<Int>("height") ?: 0
            val rotation = call.argument<Int>("rotation") ?: 0

            if (imageData == null) {
                result.error("INVALID_ARGUMENT", "imageData is required", null)
                return
            }

            if (poseDetectorHelper == null || !poseDetectorHelper!!.isReady()) {
                result.error("NOT_INITIALIZED", "PoseDetectorHelper not initialized", null)
                return
            }

            // Process frame asynchronously
            poseDetectorHelper?.detectFromBytes(imageData, width, height, rotation)
            
            // Return immediately (results come via EventChannel)
            result.success(true)

        } catch (e: Exception) {
            val errorMsg = "Failed to process frame: ${e.message}"
            Log.e(TAG, "❌ $errorMsg", e)
            result.error("PROCESS_ERROR", errorMsg, e.stackTraceToString())
        }
    }

    /**
     * Send pose landmarks to Flutter via EventChannel.
     * 
     * @param landmarks List of landmark maps with x, y, z, visibility
     */
    private fun sendLandmarksToFlutter(landmarks: List<Map<String, Double>>) {
        // EventChannel events must be sent on the main thread
        mainHandler.post {
            try {
                eventSink?.success(landmarks)
                Log.d(TAG, "📤 Sent ${landmarks.size} landmarks to Flutter")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error sending landmarks: ${e.message}", e)
            }
        }
    }

    /**
     * Send error to Flutter via EventChannel.
     * 
     * @param errorMessage Error description
     */
    private fun sendErrorToFlutter(errorMessage: String) {
        mainHandler.post {
            try {
                eventSink?.error("DETECTION_ERROR", errorMessage, null)
                Log.e(TAG, "📤 Sent error to Flutter: $errorMessage")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error sending error message: ${e.message}", e)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "🛑 Activity destroying - cleaning up resources")
        poseDetectorHelper?.dispose()
        poseDetectorHelper = null
        eventSink = null
    }
}
