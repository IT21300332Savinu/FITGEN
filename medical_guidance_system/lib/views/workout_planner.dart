import 'package:flutter/material.dart';

class WorkoutPlanner extends StatelessWidget {
  const WorkoutPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Planner')),
      body: Center(child: Text('Workout Plans will be displayed here')),
    );
  }
}
