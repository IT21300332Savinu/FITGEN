import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class SafeguardResultScreen extends StatefulWidget {
  const SafeguardResultScreen({super.key});

  @override
  State<SafeguardResultScreen> createState() => _SafeguardResultScreenState();
}

class _SafeguardResultScreenState extends State<SafeguardResultScreen> {
  String? videoUrl;
  String aiFeedback = "Upload a video to get feedback.";

  bool isLoading = false;

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;

    setState(() {
      isLoading = true;
      aiFeedback = "Uploading video...";
    });

    final file = File(result.files.single.path!);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child("uploads/$fileName.mp4");

    try {
      await ref.putFile(file);
      final downloadURL = await ref.getDownloadURL();

      setState(() {
        videoUrl = downloadURL;
        aiFeedback = "Video uploaded. Getting AI feedback...";
      });

      // Call AI analysis after successful upload
      await analyzeVideo(downloadURL);
    } catch (e) {
      setState(() {
        aiFeedback = "Error uploading video: $e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> analyzeVideo(String videoUrl) async {
    try {
      final response = await http.post(
        Uri.parse("https://have to include my link here"),
        body: {"video_url": videoUrl},
      );

      if (response.statusCode == 200) {
        setState(() {
          aiFeedback = "AI Feedback:\n${response.body}";
        });
      } else {
        setState(() {
          aiFeedback = "AI analysis failed: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        aiFeedback = "Error fetching AI feedback: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safeguard Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isLoading ? null : uploadFile,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Video"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Text(
                    aiFeedback,
                    style: const TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}
