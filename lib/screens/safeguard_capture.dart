import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'safeguard_confirm.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safeguard'),
        backgroundColor: Colors.lightBlue,
        actions: [
          CircleAvatar(backgroundImage: AssetImage('assets/images/user.png')),
        ],
      ),
      drawer: const Drawer(),
      body: const Center(child: Text("Captures a video/image\nshould be max 10s")),
      bottomNavigationBar: const bottom_navbar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: IconButton(
        iconSize: 70,
        icon: const Icon(Icons.circle_outlined),
        onPressed: () {
          // Simulate capture and go to confirmation
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfirmScreen()));
        },
      ),
    );
  }
}
