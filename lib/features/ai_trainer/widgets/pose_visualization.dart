import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseVisualization extends StatelessWidget {
  final List<PoseLandmark>? landmarks;
  final Size screenSize;
  final Size cameraSize;
  final bool isFrontFacing;
  
  const PoseVisualization({
    Key? key,
    required this.landmarks,
    required this.screenSize,
    required this.cameraSize,
    this.isFrontFacing = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (landmarks == null || landmarks!.isEmpty) {
      return Container();
    }
    
    return CustomPaint(
      size: screenSize,
      painter: PosePainter(
        landmarks: landmarks!,
        screenSize: screenSize,
        cameraSize: cameraSize,
        isFrontFacing: isFrontFacing,
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<PoseLandmark> landmarks;
  final Size screenSize;
  final Size cameraSize;
  final bool isFrontFacing;
  
  PosePainter({
    required this.landmarks,
    required this.screenSize,
    required this.cameraSize,
    this.isFrontFacing = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Define paint styles
    final jointPaint = Paint()
      ..color = Colors.green.withAlpha(200)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final dotPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round;
    
    // Define connections for skeleton visualization
    final List<List<PoseLandmarkType>> connections = [
      // Torso
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
      
      // Left arm
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      
      // Right arm
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
      
      // Left leg
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      
      // Right leg
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];
    
    // Create map of landmarks for easier lookup
    final Map<PoseLandmarkType, PoseLandmark> landmarkMap = {};
    for (final landmark in landmarks) {
      landmarkMap[landmark.type] = landmark;
    }
    
    // Draw connections
    for (final connection in connections) {
      final startLandmark = landmarkMap[connection[0]];
      final endLandmark = landmarkMap[connection[1]];
      
      if (startLandmark != null && endLandmark != null) {
        // Transform coordinates to screen space
        final startX = transformX(startLandmark.x, size.width);
        final startY = transformY(startLandmark.y, size.height);
        final endX = transformX(endLandmark.x, size.width);
        final endY = transformY(endLandmark.y, size.height);
        
        // Draw line between joints
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          jointPaint,
        );
      }
    }
    
    // Draw joint points
    for (final landmark in landmarks) {
      // Only draw if the landmark has reasonable confidence
      if (landmark.likelihood > 0.5) {
        final x = transformX(landmark.x, size.width);
        final y = transformY(landmark.y, size.height);
        
        canvas.drawCircle(
          Offset(x, y),
          6.0, // Joint circle size
          dotPaint,
        );
      }
    }
  }
  
  // Helper methods to transform coordinates correctly
  double transformX(double x, double width) {
    // Handle mirroring for front-facing camera
    return isFrontFacing ? width - (x * width) : x * width;
  }
  
  double transformY(double y, double height) {
    return y * height;
  }
  
  @override
  bool shouldRepaint(PosePainter oldDelegate) => true;
}