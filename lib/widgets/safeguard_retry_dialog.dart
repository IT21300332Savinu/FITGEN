import 'package:flutter/material.dart';

class RetryDialog extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onKeep;

  const RetryDialog({super.key, required this.onDelete, required this.onKeep});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text("Are you sure you want to delete this?"),
      actions: [
        OutlinedButton(onPressed: onDelete, child: const Text("Delete")),
        OutlinedButton(onPressed: onKeep, child: const Text("Keep")),
      ],
    );
  }
}
