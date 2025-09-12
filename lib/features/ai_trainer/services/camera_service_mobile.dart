// This file handles mobile implementation

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'platform_service.dart';
import 'pose_analyzer_service.dart';

/// Mobile implementation of PlatformService
class MobilePlatformService implements PlatformService {
  final String exerciseName;
  
  CameraController? _cameraController;
  late PoseAnalyzerService _poseAnalyzer;
  bool _isInitialized = false;
  
  // Analysis data
  int _repCount = 0;
  double _formQuality = 0.75;
  List<String> _formIssues = ['Getting ready...'];
  List<PoseLandmark>? _landmarks;
  
  MobilePlatformService(this.exerciseName);
  
  @override
  Future<void> initialize() async {
    try {
      // Initialize pose analyzer
      _poseAnalyzer = PoseAnalyzerService();
      await _poseAnalyzer.initialize(exerciseName);
      
      // Initialize camera
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing mobile platform service: $e');
      rethrow;
    }
  }
  
  @override
  Widget buildCameraPreview() {
    if (!_isInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildPlaceholderPreview();
    }
    
    return AspectRatio(
      aspectRatio: _cameraController!.value.aspectRatio,
      child: CameraPreview(_cameraController!),
    );
  }
  
  Widget _buildPlaceholderPreview() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              exerciseName.toLowerCase() == 'squat'
                  ? Icons.accessibility_new
                  : Icons.fitness_center,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera initializing...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Future<void> startProcessing() async {
    if (!_isInitialized || _cameraController == null) return;
    
    await _cameraController!.startImageStream(_processImage);
  }
  
  @override
  Future<void> stopProcessing() async {
    if (!_isInitialized || _cameraController == null) return;
    
    await _cameraController!.stopImageStream();
  }
  
  void _processImage(CameraImage image) async {
    try {
      final result = await _poseAnalyzer.processFrame(
        image, 
        _cameraController!.description
      );
      
      if (result != null) {
        _repCount = result.repCount;
        _formQuality = result.formQuality;
        _formIssues = result.formIssues;
        _landmarks = result.landmarks;
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    }
  }
  
  @override
  Map<String, dynamic> getAnalysisData() {
    return {
      'repCount': _repCount,
      'formQuality': _formQuality,
      'formIssues': _formIssues,
      'landmarks': _landmarks,
    };
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    _poseAnalyzer.dispose();
  }
}
