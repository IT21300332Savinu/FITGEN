import 'package:flutter/material.dart';

class BreakScreen extends StatelessWidget {
  final int? bpm;
  const BreakScreen({super.key, this.bpm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a Short Break'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.self_improvement, size: 72, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                bpm != null ? 'Current BPM: $bpm' : 'Let’s slow down for a bit',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Close your eyes and breathe in for 4 seconds, hold for 4 seconds, and breathe out for 6 seconds. Repeat for 2–3 minutes.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.done),
                    label: const Text('I’m OK'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


