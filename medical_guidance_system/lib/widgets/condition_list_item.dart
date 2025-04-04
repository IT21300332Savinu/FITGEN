import 'package:flutter/material.dart';
import '../models/medical_condition.dart';

class ConditionListItem extends StatelessWidget {
  final MedicalCondition condition;

  const ConditionListItem({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.medical_services, color: Colors.blue),
      title: Text(
        condition.name, // Display the name of the condition
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle:
          condition.description != null && condition.description!.isNotEmpty
              ? Text(
                condition.description!,
              ) // Display the description if available
              : null, // No subtitle if description is null or empty
    );
  }
}
