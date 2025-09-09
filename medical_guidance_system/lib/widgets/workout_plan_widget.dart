import 'package:flutter/material.dart';
import '../models/workout_plan.dart';

class WorkoutPlanWidget extends StatefulWidget {
  final WorkoutPlan workoutPlan;

  const WorkoutPlanWidget({super.key, required this.workoutPlan});

  @override
  State<WorkoutPlanWidget> createState() => _WorkoutPlanWidgetState();
}

class _WorkoutPlanWidgetState extends State<WorkoutPlanWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final exercisesByDay = <String, List<WorkoutExercise>>{};
    for (final exercise in widget.workoutPlan.exercises) {
      exercisesByDay.putIfAbsent(exercise.day, () => []).add(exercise);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fitness_center, color: Colors.orange[700]),
            ),
            title: Text(
              widget.workoutPlan.fitnessType
                  .split(' ')
                  .map((word) => word[0].toUpperCase() + word.substring(1))
                  .join(' '),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${widget.workoutPlan.level} Level'),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: exercisesByDay.entries.map((entry) {
                  return _buildDaySection(entry.key, entry.value);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySection(String day, List<WorkoutExercise> exercises) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...exercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.exercise,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
