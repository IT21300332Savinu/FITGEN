// lib/features/ai_trainer/painters/form_feedback_painter.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import '../ai_trainer/exercise/exercise_detector.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class FormFeedbackPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final int rotation;
  final CameraLensDirection lensDirection;
  final ExerciseMetrics? exerciseMetrics;
  final bool showAngleIndicator;
  final bool showFormHighlight;
  final bool showAllKeypoints;

  FormFeedbackPainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
    this.exerciseMetrics,
    this.showAngleIndicator = true,
    this.showFormHighlight = true,
    this.showAllKeypoints = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final pose = poses.first;
    final colors = exerciseMetrics != null 
        ? _getColorsForForm(exerciseMetrics!.formQuality)
        : _getDefaultColors();

    // Draw all 33 keypoints if enabled
    if (showAllKeypoints) {
      _drawAllKeypoints(canvas, pose, size, colors);
      _drawPoseSkeleton(canvas, pose, size, colors);
    }

    // Draw form-specific overlays
    if (showFormHighlight && exerciseMetrics != null) {
      _drawFormHighlights(canvas, pose, size, colors);
    }
    
    if (showAngleIndicator && exerciseMetrics != null) {
      _drawAngleIndicators(canvas, pose, size, colors);
    }
    
    // Draw exercise metrics
    if (exerciseMetrics != null) {
      _drawExerciseMetrics(canvas, size, colors);
      _drawFormQualityIndicator(canvas, size, colors);
    }
  }

  void _drawAllKeypoints(Canvas canvas, Pose pose, Size size, FormColors colors) {
    // Get all 33 pose landmarks
    final landmarks = pose.landmarks;
    
    // Define keypoint colors based on body parts
    final Map<PoseLandmarkType, Color> keypointColors = {
      // Face landmarks (0-10)
      PoseLandmarkType.nose: Colors.yellow,
      PoseLandmarkType.leftEyeInner: Colors.cyan,
      PoseLandmarkType.leftEye: Colors.cyan,
      PoseLandmarkType.leftEyeOuter: Colors.cyan,
      PoseLandmarkType.rightEyeInner: Colors.cyan,
      PoseLandmarkType.rightEye: Colors.cyan,
      PoseLandmarkType.rightEyeOuter: Colors.cyan,
      PoseLandmarkType.leftEar: Colors.purple,
      PoseLandmarkType.rightEar: Colors.purple,
      PoseLandmarkType.leftMouth: Colors.pink,
      PoseLandmarkType.rightMouth: Colors.pink,
      
      // Upper body landmarks (11-16)
      PoseLandmarkType.leftShoulder: Colors.orange,
      PoseLandmarkType.rightShoulder: Colors.orange,
      PoseLandmarkType.leftElbow: Colors.red,
      PoseLandmarkType.rightElbow: Colors.red,
      PoseLandmarkType.leftWrist: Colors.blue,
      PoseLandmarkType.rightWrist: Colors.blue,
      
      // Hand landmarks (17-22)
      PoseLandmarkType.leftPinky: Colors.lightBlue,
      PoseLandmarkType.rightPinky: Colors.lightBlue,
      PoseLandmarkType.leftIndex: Colors.lightGreen,
      PoseLandmarkType.rightIndex: Colors.lightGreen,
      PoseLandmarkType.leftThumb: Colors.amber,
      PoseLandmarkType.rightThumb: Colors.amber,
      
      // Lower body landmarks (23-32)
      PoseLandmarkType.leftHip: Colors.deepOrange,
      PoseLandmarkType.rightHip: Colors.deepOrange,
      PoseLandmarkType.leftKnee: Colors.green,
      PoseLandmarkType.rightKnee: Colors.green,
      PoseLandmarkType.leftAnkle: Colors.indigo,
      PoseLandmarkType.rightAnkle: Colors.indigo,
      PoseLandmarkType.leftHeel: Colors.brown,
      PoseLandmarkType.rightHeel: Colors.brown,
      PoseLandmarkType.leftFootIndex: Colors.teal,
      PoseLandmarkType.rightFootIndex: Colors.teal,
    };

    // Draw each keypoint
    landmarks.forEach((type, landmark) {
      if (landmark.likelihood > 0.3) { // Only draw if confidence is reasonable
        final point = _translatePoint(landmark, size);
        final color = keypointColors[type] ?? Colors.white;
        
        // Draw keypoint circle
        final keypointPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(point, 4.0, keypointPaint);
        
        // Draw white border for visibility
        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        
        canvas.drawCircle(point, 4.0, borderPaint);
        
        // Draw keypoint number for debugging (optional)
        if (landmark.likelihood > 0.7) {
          _drawKeypointLabel(canvas, point, type.index.toString(), Colors.white);
        }
      }
    });
  }

  void _drawPoseSkeleton(Canvas canvas, Pose pose, Size size, FormColors colors) {
    final landmarks = pose.landmarks;
    
    // Define skeleton connections (all 33 keypoints)
    final List<List<PoseLandmarkType>> connections = [
      // Face connections
      [PoseLandmarkType.leftEye, PoseLandmarkType.nose],
      [PoseLandmarkType.rightEye, PoseLandmarkType.nose],
      [PoseLandmarkType.leftEar, PoseLandmarkType.leftEye],
      [PoseLandmarkType.rightEar, PoseLandmarkType.rightEye],
      [PoseLandmarkType.leftMouth, PoseLandmarkType.nose],
      [PoseLandmarkType.rightMouth, PoseLandmarkType.nose],
      
      // Upper body connections
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      
      // Hand connections (reduced thickness for less boldness)
      [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb],
      [PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex],
      [PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky],
      [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb],
      [PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex],
      [PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky],
      
      // Torso connections
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      
      // Lower body connections
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
      
      // Foot connections
      [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
      [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
      [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftFootIndex],
      [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightFootIndex],
      [PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex],
      [PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex],
    ];

    // Hand connections (for thinner lines)
    final List<PoseLandmarkType> handConnections = [
      PoseLandmarkType.leftThumb,
      PoseLandmarkType.leftIndex,
      PoseLandmarkType.leftPinky,
      PoseLandmarkType.rightThumb,
      PoseLandmarkType.rightIndex,
      PoseLandmarkType.rightPinky,
    ];

    // Draw all connections with appropriate thickness
    for (final connection in connections) {
      final startLandmark = landmarks[connection[0]];
      final endLandmark = landmarks[connection[1]];
      
      if (startLandmark != null && endLandmark != null && 
          startLandmark.likelihood > 0.3 && endLandmark.likelihood > 0.3) {
        final startPoint = _translatePoint(startLandmark, size);
        final endPoint = _translatePoint(endLandmark, size);
        
        // Use thinner lines for hand connections
        bool isHandConnection = handConnections.contains(connection[0]) || 
                               handConnections.contains(connection[1]);
        
        final connectionPaint = Paint()
          ..color = colors.exerciseArm.withOpacity(0.6)
          ..strokeWidth = isHandConnection ? 1.0 : 2.0 // Thinner for hands
          ..strokeCap = StrokeCap.round;
        
        canvas.drawLine(startPoint, endPoint, connectionPaint);
      }
    }
  }

  void _drawKeypointLabel(Canvas canvas, Offset point, String label, Color textColor) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final textOffset = Offset(
      point.dx - textPainter.width / 2,
      point.dy - textPainter.height - 8,
    );
    
    // Draw background for text
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          textOffset.dx - 2,
          textOffset.dy - 1,
          textPainter.width + 4,
          textPainter.height + 2,
        ),
        const Radius.circular(2),
      ),
      bgPaint,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  void _drawFormHighlights(Canvas canvas, Pose pose, Size size, FormColors colors) {
    // Highlight the working arm with colored overlay
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    // Draw both arms with form-based colors
    _drawArmHighlight(canvas, size, leftShoulder, leftElbow, leftWrist, colors.exerciseArm);
    _drawArmHighlight(canvas, size, rightShoulder, rightElbow, rightWrist, colors.exerciseArm);
    
    // Draw joint highlights
    _drawJointHighlight(canvas, size, leftElbow, colors.joint, 8);
    _drawJointHighlight(canvas, size, rightElbow, colors.joint, 8);
    _drawJointHighlight(canvas, size, leftShoulder, colors.joint, 6);
    _drawJointHighlight(canvas, size, rightShoulder, colors.joint, 6);
    _drawJointHighlight(canvas, size, leftWrist, colors.joint, 6);
    _drawJointHighlight(canvas, size, rightWrist, colors.joint, 6);
  }

  void _drawArmHighlight(Canvas canvas, Size size, PoseLandmark? shoulder, 
                        PoseLandmark? elbow, PoseLandmark? wrist, Color color) {
    if (shoulder == null || elbow == null || wrist == null) return;

    final shoulderPoint = _translatePoint(shoulder, size);
    final elbowPoint = _translatePoint(elbow, size);
    final wristPoint = _translatePoint(wrist, size);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw arm segments
    canvas.drawLine(shoulderPoint, elbowPoint, paint);
    canvas.drawLine(elbowPoint, wristPoint, paint);
  }

  void _drawJointHighlight(Canvas canvas, Size size, PoseLandmark? landmark, 
                          Color color, double radius) {
    if (landmark == null) return;

    final point = _translatePoint(landmark, size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(point, radius, paint);
    
    // Add white border for contrast
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(point, radius, borderPaint);
  }

  void _drawAngleIndicators(Canvas canvas, Pose pose, Size size, FormColors colors) {
    // Draw angle indicators for both elbows
    _drawElbowAngleIndicator(canvas, pose, size, PoseLandmarkType.leftElbow, colors);
    _drawElbowAngleIndicator(canvas, pose, size, PoseLandmarkType.rightElbow, colors);
  }

  void _drawElbowAngleIndicator(Canvas canvas, Pose pose, Size size, 
                               PoseLandmarkType elbowType, FormColors colors) {
    final elbow = pose.landmarks[elbowType];
    if (elbow == null) return;

    final isLeft = elbowType == PoseLandmarkType.leftElbow;
    final shoulder = pose.landmarks[isLeft ? PoseLandmarkType.leftShoulder : PoseLandmarkType.rightShoulder];
    final wrist = pose.landmarks[isLeft ? PoseLandmarkType.leftWrist : PoseLandmarkType.rightWrist];

    if (shoulder == null || wrist == null) return;

    final elbowPoint = _translatePoint(elbow, size);
    
    // Calculate the actual angle for this specific arm
    double angle = _calculateElbowAngle(shoulder, elbow, wrist);
    
    // Draw angle arc
    final arcPaint = Paint()
      ..color = colors.angleIndicator.withOpacity(0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Calculate arc parameters based on arm vectors
    final shoulderPoint = _translatePoint(shoulder, size);
    final wristPoint = _translatePoint(wrist, size);
    
    // Get angles for arc positioning
    double shoulderAngle = math.atan2(shoulderPoint.dy - elbowPoint.dy, shoulderPoint.dx - elbowPoint.dx);
    double wristAngle = math.atan2(wristPoint.dy - elbowPoint.dy, wristPoint.dx - elbowPoint.dx);
    
    // Ensure we draw the smaller arc
    double startAngle = math.min(shoulderAngle, wristAngle);
    double sweepAngle = (wristAngle - shoulderAngle).abs();
    if (sweepAngle > math.pi) {
      sweepAngle = 2 * math.pi - sweepAngle;
      startAngle = math.max(shoulderAngle, wristAngle);
    }

    canvas.drawArc(
      Rect.fromCircle(center: elbowPoint, radius: 30),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw angle text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${angle.toInt()}°',
        style: TextStyle(
          color: colors.angleText,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              color: Colors.black.withOpacity(0.8),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Position text above the elbow
    final textOffset = Offset(
      elbowPoint.dx - textPainter.width / 2, 
      elbowPoint.dy - 50
    );
    
    // Draw text background for better readability
    final textBgPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          textOffset.dx - 4, 
          textOffset.dy - 2, 
          textPainter.width + 8, 
          textPainter.height + 4
        ),
        const Radius.circular(4),
      ),
      textBgPaint,
    );
    
    textPainter.paint(canvas, textOffset);
  }

  void _drawExerciseMetrics(Canvas canvas, Size size, FormColors colors) {
    // Top-left corner metrics
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'REPS: ${exerciseMetrics!.repCount}\n',
            style: TextStyle(
              color: colors.metricsText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'FORM: ${exerciseMetrics!.formScore.toInt()}%\n',
            style: TextStyle(
              color: colors.metricsText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: 'STATE: ${_getStateText(exerciseMetrics!.state)}',
            style: TextStyle(
              color: colors.metricsText,
              fontSize: 14,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Draw background
    final bgRect = Rect.fromLTWH(
      10, 10, 
      textPainter.width + 20, 
      textPainter.height + 20
    );
    
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(8)),
      backgroundPaint,
    );
    
    textPainter.paint(canvas, const Offset(20, 20));
  }

  void _drawFormQualityIndicator(Canvas canvas, Size size, FormColors colors) {
    // Top-right corner form indicator
    final center = Offset(size.width - 50, 50);
    final radius = 30.0;
    
    // Main circle
    final paint = Paint()
      ..color = colors.formIndicator
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
    
    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, borderPaint);
    
    // Quality icon/text
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getFormQualityEmoji(exerciseMetrics!.formQuality),
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(
        center.dx - textPainter.width / 2, 
        center.dy - textPainter.height / 2
      )
    );
    
    // Quality text below
    final qualityTextPainter = TextPainter(
      text: TextSpan(
        text: _getFormQualityText(exerciseMetrics!.formQuality),
        style: TextStyle(
          color: colors.formIndicator,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    qualityTextPainter.layout();
    qualityTextPainter.paint(
      canvas, 
      Offset(
        center.dx - qualityTextPainter.width / 2, 
        center.dy + radius + 5
      )
    );
  }

  double _calculateElbowAngle(PoseLandmark shoulder, PoseLandmark elbow, PoseLandmark wrist) {
    // Vector from elbow to shoulder
    double shoulderX = shoulder.x - elbow.x;
    double shoulderY = shoulder.y - elbow.y;
    
    // Vector from elbow to wrist
    double wristX = wrist.x - elbow.x;
    double wristY = wrist.y - elbow.y;
    
    // Calculate angle using dot product
    double dotProduct = shoulderX * wristX + shoulderY * wristY;
    double shoulderLength = math.sqrt(shoulderX * shoulderX + shoulderY * shoulderY);
    double wristLength = math.sqrt(wristX * wristX + wristY * wristY);
    
    if (shoulderLength == 0 || wristLength == 0) return 0;
    
    double cosAngle = dotProduct / (shoulderLength * wristLength);
    cosAngle = cosAngle.clamp(-1.0, 1.0);
    
    double angleRadians = math.acos(cosAngle);
    return angleRadians * 180 / math.pi;
  }

  Offset _translatePoint(PoseLandmark landmark, Size size) {
    return translatePoint(
      landmark.x,
      landmark.y,
      rotation,
      size,
      imageSize,
      lensDirection,
    );
  }

  Offset translatePoint(
    double x,
    double y,
    int rotation,
    Size canvasSize,
    Size imageSize,
    CameraLensDirection cameraLensDirection,
  ) {
    double translatedX = x;
    double translatedY = y;
    
    if (rotation == 90) {
      const double VERTICAL_STRETCH_FACTOR = 1.0;
      
      double normalizedX = x / imageSize.height;
      double normalizedY = y / imageSize.width;
      
      normalizedY = normalizedY * VERTICAL_STRETCH_FACTOR;
      
      translatedX = normalizedX * canvasSize.width;
      translatedY = normalizedY * canvasSize.height;
      
      double verticalOffset = (canvasSize.height - (canvasSize.height / VERTICAL_STRETCH_FACTOR)) / 2;
      translatedY = translatedY - verticalOffset;
      
    } else if (rotation == 270) {
      double normalizedX = (imageSize.height - y) / imageSize.height;
      double normalizedY = x / imageSize.width;
      
      translatedX = normalizedX * canvasSize.width;
      translatedY = normalizedY * canvasSize.height;
      
    } else {
      double normalizedX = x / imageSize.width;
      double normalizedY = y / imageSize.height;
      
      if (rotation == 180) {
        normalizedX = 1.0 - normalizedX;
        normalizedY = 1.0 - normalizedY;
      }
      
      translatedX = normalizedX * canvasSize.width;
      translatedY = normalizedY * canvasSize.height;
    }
    
    if (cameraLensDirection == CameraLensDirection.front) {
      translatedX = canvasSize.width - translatedX;
    }
    
    return Offset(translatedX, translatedY);
  }

  FormColors _getColorsForForm(FormQuality formQuality) {
    switch (formQuality) {
      case FormQuality.excellent:
        return FormColors(
          exerciseArm: Colors.green[600]!,
          joint: Colors.green[500]!,
          angleIndicator: Colors.green[400]!,
          angleText: Colors.green[700]!,
          metricsText: Colors.green[600]!,
          formIndicator: Colors.green[500]!,
        );
      case FormQuality.good:
        return FormColors(
          exerciseArm: Colors.lightGreen[600]!,
          joint: Colors.lightGreen[500]!,
          angleIndicator: Colors.lightGreen[400]!,
          angleText: Colors.lightGreen[700]!,
          metricsText: Colors.lightGreen[600]!,
          formIndicator: Colors.lightGreen[500]!,
        );
      case FormQuality.warning:
        return FormColors(
          exerciseArm: Colors.orange[600]!,
          joint: Colors.orange[500]!,
          angleIndicator: Colors.orange[400]!,
          angleText: Colors.orange[700]!,
          metricsText: Colors.orange[600]!,
          formIndicator: Colors.orange[500]!,
        );
      case FormQuality.poor:
        return FormColors(
          exerciseArm: Colors.red[600]!,
          joint: Colors.red[500]!,
          angleIndicator: Colors.red[400]!,
          angleText: Colors.red[700]!,
          metricsText: Colors.red[600]!,
          formIndicator: Colors.red[500]!,
        );
    }
  }

  FormColors _getDefaultColors() {
    return FormColors(
      exerciseArm: Colors.blue[600]!,
      joint: Colors.blue[500]!,
      angleIndicator: Colors.blue[400]!,
      angleText: Colors.blue[700]!,
      metricsText: Colors.blue[600]!,
      formIndicator: Colors.blue[500]!,
    );
  }

  String _getStateText(ExerciseState state) {
    switch (state) {
      case ExerciseState.ready:
        return 'READY';
      case ExerciseState.descending:
        return 'DOWN';
      case ExerciseState.hold:
        return 'HOLD';
      case ExerciseState.ascending:
        return 'UP';
    }
  }
  
  String _getFormQualityText(FormQuality quality) {
    switch (quality) {
      case FormQuality.excellent:
        return 'PERFECT';
      case FormQuality.good:
        return 'GOOD';
      case FormQuality.warning:
        return 'WATCH';
      case FormQuality.poor:
        return 'POOR';
    }
  }

  String _getFormQualityEmoji(FormQuality quality) {
    switch (quality) {
      case FormQuality.excellent:
        return '⭐';
      case FormQuality.good:
        return '👍';
      case FormQuality.warning:
        return '⚠️';
      case FormQuality.poor:
        return '👎';
    }
  }

  @override
  bool shouldRepaint(covariant FormFeedbackPainter oldDelegate) => true;
}

class FormColors {
  final Color exerciseArm;
  final Color joint;
  final Color angleIndicator;
  final Color angleText;
  final Color metricsText;
  final Color formIndicator;

  FormColors({
    required this.exerciseArm,
    required this.joint,
    required this.angleIndicator,
    required this.angleText,
    required this.metricsText,
    required this.formIndicator,
  });
}