import 'package:flutter/material.dart';

class sut_home_workout_card extends StatelessWidget {
  final String sport;
  final int progress;
  final int completed;

  const sut_home_workout_card({super.key, required this.sport, required this.progress, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sport, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Progress: $progress%"),
                Text("Completed: $completed"),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text("Next Workout")),
          ],
        ),
      ),
    );
  }
}
