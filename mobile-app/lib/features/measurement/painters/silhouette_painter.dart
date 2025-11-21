import 'package:flutter/material.dart';
import '../../../core/models/pose_landmark.dart';

/// Custom painter that draws AR silhouette guide overlay.
///
/// Visual Guide:
/// - GREEN outline: Phone is vertical AND pose matches (correct)
/// - YELLOW outline: Phone is vertical BUT pose doesn't match (partial)
/// - RED outline: Phone is tilted (incorrect orientation)
/// - Semi-transparent white: Default guide shape
class SilhouettePainter extends CustomPainter {
  final bool isPhoneVertical;
  final List<PoseLandmark> landmarks;

  SilhouettePainter({
    required this.isPhoneVertical,
    required this.landmarks,
  });

  /// Check if the detected pose matches the silhouette guide
  bool get _poseMatchesGuide {
    if (landmarks.length != 33) return false;
    
    // Check if most landmarks are visible with good confidence
    final visibleLandmarks = landmarks.where((l) => l.visibility > 0.7).length;
    return visibleLandmarks >= 25; // At least 25 out of 33 landmarks visible
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Determine color based on orientation and pose match
    final Color outlineColor;
    if (!isPhoneVertical) {
      outlineColor = Colors.red.withValues(alpha: 0.6);
    } else if (_poseMatchesGuide) {
      outlineColor = Colors.green.withValues(alpha: 0.8); // Brighter green when matched
    } else {
      outlineColor = Colors.yellow.withValues(alpha: 0.6); // Yellow when vertical but not matched
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _poseMatchesGuide ? 4.0 : 3.0 // Thicker when matched
      ..color = outlineColor;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _poseMatchesGuide 
          ? Colors.green.withValues(alpha: 0.15) // Green fill when matched
          : Colors.white.withValues(alpha: 0.1);

    // Center position for silhouette
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw silhouette guide
    final path = _createSilhouettePath(centerX, centerY, size);
    
    // Draw filled shape first, then outline
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Draw landmark points if available
    if (landmarks.isNotEmpty) {
      _drawLandmarks(canvas, size, landmarks);
    }
  }

  /// Creates human silhouette path
  Path _createSilhouettePath(double centerX, double centerY, Size size) {
    final path = Path();
    
    // Head (circle)
    final headRadius = size.width * 0.08;
    final headY = centerY - size.height * 0.25;
    
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, headY),
      radius: headRadius,
    ));

    // Neck
    final neckTop = headY + headRadius;
    final neckBottom = neckTop + size.height * 0.05;
    final neckWidth = size.width * 0.05;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, (neckTop + neckBottom) / 2),
        width: neckWidth,
        height: neckBottom - neckTop,
      ),
      const Radius.circular(10),
    ));

    // Torso (rounded rectangle)
    final torsoTop = neckBottom;
    final torsoHeight = size.height * 0.35;
    final torsoWidth = size.width * 0.35;
    
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, torsoTop + torsoHeight / 2),
        width: torsoWidth,
        height: torsoHeight,
      ),
      const Radius.circular(20),
    ));

    // Shoulders (left and right)
    final shoulderY = torsoTop + size.height * 0.05;
    final shoulderWidth = size.width * 0.12;
    final shoulderHeight = size.height * 0.08;
    
    // Left shoulder
    path.addOval(Rect.fromCenter(
      center: Offset(centerX - torsoWidth / 2 - shoulderWidth / 2, shoulderY),
      width: shoulderWidth,
      height: shoulderHeight,
    ));
    
    // Right shoulder
    path.addOval(Rect.fromCenter(
      center: Offset(centerX + torsoWidth / 2 + shoulderWidth / 2, shoulderY),
      width: shoulderWidth,
      height: shoulderHeight,
    ));

    // Arms (simplified as lines with rounded caps)
    final armLength = size.height * 0.25;
    final leftArmStart = Offset(centerX - torsoWidth / 2, shoulderY);
    final leftArmEnd = Offset(leftArmStart.dx, leftArmStart.dy + armLength);
    
    final rightArmStart = Offset(centerX + torsoWidth / 2, shoulderY);
    final rightArmEnd = Offset(rightArmStart.dx, rightArmStart.dy + armLength);
    
    // Add arm lines to path
    path.moveTo(leftArmStart.dx, leftArmStart.dy);
    path.lineTo(leftArmEnd.dx, leftArmEnd.dy);
    
    path.moveTo(rightArmStart.dx, rightArmStart.dy);
    path.lineTo(rightArmEnd.dx, rightArmEnd.dy);

    return path;
  }

  /// Draw actual landmark points from MediaPipe
  void _drawLandmarks(Canvas canvas, Size size, List<PoseLandmark> landmarks) {
    final landmarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.cyan.withValues(alpha: 0.8);

    for (final landmark in landmarks) {
      // Skip landmarks with low visibility
      if (landmark.visibility < 0.5) continue;

      // Convert normalized coordinates to screen coordinates
      final x = landmark.x * size.width;
      final y = landmark.y * size.height;

      // Draw landmark point
      canvas.drawCircle(
        Offset(x, y),
        4.0,
        landmarkPaint,
      );

      // Draw Z-depth indicator (size varies with depth)
      final depthRadius = 8.0 + (landmark.z.abs() * 10).clamp(0, 20);
      canvas.drawCircle(
        Offset(x, y),
        depthRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.cyan.withValues(alpha: 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(SilhouettePainter oldDelegate) {
    return oldDelegate.isPhoneVertical != isPhoneVertical ||
        oldDelegate.landmarks.length != landmarks.length;
  }
}
