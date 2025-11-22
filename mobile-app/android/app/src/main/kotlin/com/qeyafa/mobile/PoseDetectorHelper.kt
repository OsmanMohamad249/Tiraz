package com.qeyafa.mobile

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import android.util.Log
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarkerResult
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

/**
 * Helper class for MediaPipe Pose Landmarker in LIVE_STREAM mode.
 * 
 * Handles initialization, processing camera frames, and delivering 3D pose landmarks
 * to Flutter via callbacks.
 */
class PoseDetectorHelper(
    private val context: Context,
    private val onResults: (List<Map<String, Double>>) -> Unit,
    private val onError: (String) -> Unit
) {
    companion object {
        private const val TAG = "PoseDetectorHelper"
        // Flutter asset path - models must be in assets/models/ folder
        private const val MODEL_NAME = "models/pose_landmarker_heavy.task"
        private const val DEFAULT_MIN_DETECTION_CONFIDENCE = 0.5f
        private const val DEFAULT_MIN_TRACKING_CONFIDENCE = 0.5f
        private const val DEFAULT_MIN_PRESENCE_CONFIDENCE = 0.5f
        private const val DEFAULT_NUM_POSES = 1
    }

    private var poseLandmarker: PoseLandmarker? = null
    private var executor: ScheduledExecutorService? = null
    private var lastProcessedTimestamp: Long = 0
    private var isProcessing = false

    /**
     * Initialize the MediaPipe Pose Landmarker with LIVE_STREAM mode.
     * 
     * @throws RuntimeException if initialization fails
     */
    fun initialize() {
        try {
            Log.d(TAG, "🚀 Initializing MediaPipe Pose Landmarker...")
            
            // Create executor for background processing
            executor = Executors.newSingleThreadScheduledExecutor()

            // Configure base options
            val baseOptions = BaseOptions.builder()
                .setDelegate(Delegate.GPU) // Use GPU for better performance
                .setModelAssetPath(MODEL_NAME)
                .build()

            // Configure PoseLandmarker options for LIVE_STREAM mode
            val options = PoseLandmarker.PoseLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.LIVE_STREAM)
                .setNumPoses(DEFAULT_NUM_POSES)
                .setMinPoseDetectionConfidence(DEFAULT_MIN_DETECTION_CONFIDENCE)
                .setMinPosePresenceConfidence(DEFAULT_MIN_PRESENCE_CONFIDENCE)
                .setMinTrackingConfidence(DEFAULT_MIN_TRACKING_CONFIDENCE)
                .setResultListener { result, input ->
                    // Use System.currentTimeMillis() instead of input.timestamp (which is private)
                    handlePoseResult(result, System.currentTimeMillis())
                }
                .setErrorListener { error ->
                    Log.e(TAG, "❌ MediaPipe error: ${error.message}")
                    onError("MediaPipe detection error: ${error.message}")
                }
                .build()

            // Create the landmarker
            poseLandmarker = PoseLandmarker.createFromOptions(context, options)
            
            Log.d(TAG, "✅ MediaPipe initialized successfully")
        } catch (e: Exception) {
            val errorMsg = "Failed to initialize MediaPipe: ${e.message}"
            Log.e(TAG, "❌ $errorMsg", e)
            onError(errorMsg)
            throw RuntimeException(errorMsg, e)
        }
    }

    /**
     * Process a camera frame for pose detection.
     * 
     * This method is designed to work with image data from Flutter's camera plugin.
     * It supports both encoded images (JPEG/PNG) and raw YUV data.
     * 
     * @param imageData Image bytes (JPEG/PNG encoded or YUV420 raw data)
     * @param width Image width (required for YUV format)
     * @param height Image height (required for YUV format)
     * @param rotation Image rotation in degrees (0, 90, 180, 270)
     */
    fun detectFromBytes(
        imageData: ByteArray,
        width: Int = 0,
        height: Int = 0,
        rotation: Int = 0
    ) {
        // Skip if already processing to avoid frame queue buildup
        if (isProcessing) {
            Log.d(TAG, "⏭️ Skipping frame - already processing")
            return
        }

        executor?.execute {
            try {
                isProcessing = true
                
                // Try to decode as encoded image first (JPEG/PNG)
                var bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
                
                // If decoding fails and we have width/height, assume YUV420 format
                if (bitmap == null && width > 0 && height > 0) {
                    Log.d(TAG, "🔄 Decoding YUV420 data (${width}x${height})")
                    bitmap = convertYuv420ToBitmap(imageData, width, height)
                }
                
                if (bitmap == null) {
                    Log.e(TAG, "❌ Failed to decode image data")
                    onError("Failed to decode image")
                    return@execute
                }

                // Apply rotation if needed
                val finalBitmap = if (rotation != 0) {
                    rotateBitmap(bitmap, rotation.toFloat())
                } else {
                    bitmap
                }

                // Convert to MPImage
                val mpImage = BitmapImageBuilder(finalBitmap).build()
                
                // Generate timestamp (must be monotonically increasing)
                val timestamp = System.currentTimeMillis()
                
                // Detect pose asynchronously
                poseLandmarker?.detectAsync(mpImage, timestamp)
                
                // Clean up bitmaps
                if (finalBitmap != bitmap) {
                    finalBitmap.recycle()
                }
                bitmap.recycle()
                
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error processing frame: ${e.message}", e)
                onError("Frame processing error: ${e.message}")
            } finally {
                isProcessing = false
            }
        }
    }

    /**
     * Convert YUV420 byte array to Bitmap.
     * 
     * YUV420 format from Flutter camera (Android):
     * - Total size ≈ width × height × 1.5
     * - Y plane: width × height bytes
     * - U plane: (width × height) / 4 bytes
     * - V plane: (width × height) / 4 bytes
     */
    private fun convertYuv420ToBitmap(yuvData: ByteArray, width: Int, height: Int): Bitmap? {
        return try {
            // Create YuvImage from raw data
            val yuvImage = YuvImage(yuvData, ImageFormat.NV21, width, height, null)
            
            // Convert to JPEG (intermediate format for BitmapFactory)
            val outputStream = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, width, height), 80, outputStream)
            val jpegData = outputStream.toByteArray()
            
            // Decode JPEG to Bitmap
            BitmapFactory.decodeByteArray(jpegData, 0, jpegData.size)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to convert YUV to Bitmap: ${e.message}", e)
            null
        }
    }

    /**
     * Rotate bitmap by specified degrees.
     */
    private fun rotateBitmap(source: Bitmap, degrees: Float): Bitmap {
        val matrix = android.graphics.Matrix()
        matrix.postRotate(degrees)
        return Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, true)
    }

    /**
     * Handle pose detection results from MediaPipe.
     * 
     * Converts the result to a list of landmark maps with x, y, z, visibility.
     */
    private fun handlePoseResult(result: PoseLandmarkerResult, timestamp: Long) {
        try {
            // Prevent processing outdated results
            if (timestamp <= lastProcessedTimestamp) {
                Log.d(TAG, "⏭️ Skipping outdated result")
                return
            }
            lastProcessedTimestamp = timestamp

            val landmarksList = mutableListOf<Map<String, Double>>()

            // Extract landmarks from the first detected pose
            if (result.landmarks().isNotEmpty()) {
                val landmarks = result.landmarks()[0] // 2D normalized coordinates
                val worldLandmarks = result.worldLandmarks()[0] // 3D real-world coordinates

                for (i in landmarks.indices) {
                    val landmark = landmarks[i]
                    val worldLandmark = worldLandmarks[i]

                    // Create landmark map matching PoseLandmark.fromMap() in Flutter
                    landmarksList.add(
                        mapOf(
                            "x" to landmark.x().toDouble(),
                            "y" to landmark.y().toDouble(),
                            "z" to worldLandmark.z().toDouble(), // Use 3D depth from world landmarks
                            "visibility" to (landmark.visibility().orElse(0f).toDouble())
                        )
                    )
                }

                Log.d(TAG, "📍 Detected ${landmarksList.size} landmarks")
            } else {
                Log.d(TAG, "👤 No pose detected in frame")
            }

            // Send results to Flutter (even if empty - Flutter expects the stream)
            onResults(landmarksList)

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error handling pose result: ${e.message}", e)
            onError("Result processing error: ${e.message}")
        }
    }

    /**
     * Clean up resources.
     * Must be called when done with detection to prevent memory leaks.
     */
    fun dispose() {
        try {
            Log.d(TAG, "🛑 Disposing PoseDetectorHelper...")
            
            // Shutdown executor
            executor?.shutdown()
            executor?.awaitTermination(1, TimeUnit.SECONDS)
            executor = null

            // Close landmarker
            poseLandmarker?.close()
            poseLandmarker = null
            
            Log.d(TAG, "✅ Disposed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "⚠️ Error during disposal: ${e.message}", e)
        }
    }

    /**
     * Check if the helper is initialized and ready.
     */
    fun isReady(): Boolean = poseLandmarker != null
}
