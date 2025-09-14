import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseVisualization extends StatelessWidget {
  final List<Pose> poses;
  final Size imageSize;

  const PoseVisualization({
    Key? key,
    required this.poses,
    required this.imageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PosePainter(
        poses: poses,
        imageSize: imageSize,
      ),
      child: Container(),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  
  // Cache paint objects for better performance
  static final Paint _jointPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 4.0;
    
  static final Paint _connectionPaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 2.0;

  PosePainter({
    required this.poses,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    for (final pose in poses) {
      _drawOptimizedSkeleton(canvas, pose, size);
    }
  }

  void _drawOptimizedSkeleton(Canvas canvas, Pose pose, Size size) {
    final landmarks = pose.landmarks;
    
    // Essential joints for bicep curl detection - reduced from 33 to 6 landmarks
    final essentialJoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
    ];

    // Draw essential connections only - reduced from full skeleton
    final connections = [
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    ];

    // Draw connections
    for (final connection in connections) {
      final startLandmark = landmarks[connection[0]];
      final endLandmark = landmarks[connection[1]];

      if (startLandmark != null && endLandmark != null) {
        final startPoint = _translatePoint(startLandmark.x, startLandmark.y, size);
        final endPoint = _translatePoint(endLandmark.x, endLandmark.y, size);
        canvas.drawLine(startPoint, endPoint, _connectionPaint);
      }
    }

    // Draw essential joints
    for (final jointType in essentialJoints) {
      final landmark = landmarks[jointType];
      if (landmark != null) {
        final point = _translatePoint(landmark.x, landmark.y, size);
        canvas.drawCircle(point, 6.0, _jointPaint);
      }
    }
  }

  Offset _translatePoint(double x, double y, Size size) {
    return Offset(
      x * size.width / imageSize.width,
      y * size.height / imageSize.height,
    );
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
           oldDelegate.imageSize != imageSize;
  }
}