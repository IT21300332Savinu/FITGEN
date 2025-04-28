import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/safeguard_retry_dialog.dart';
import 'safeguard_result.dart';
import 'safeguard_capture.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  void _showRetryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RetryDialog(
        onDelete: () {
          Navigator.pop(context); // Close dialog
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const CaptureScreen()));
        },
        onKeep: () {
          Navigator.pop(context); // Close dialog only
        },
      ),
    );
  }

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
      body: const Center(child: Text("Captured video replays till confirmed")),
      bottomNavigationBar: const bottom_navbar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(onPressed: () => _showRetryDialog(context), child: const Text("Retry")),
          IconButton(
            iconSize: 70,
            icon: const Icon(Icons.circle),
            onPressed: () {},
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SafeguardResultScreen()),
                );
              },
              child: const Text("Next")),
        ],
      ),
    );
  }
}
