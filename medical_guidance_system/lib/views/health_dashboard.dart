import 'package:flutter/material.dart';

class HealthDashboard extends StatelessWidget {
  const HealthDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Health Metrics",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Card(
              child: ListTile(
                title: const Text("Halth Status"),
                subtitle: const Text("Normal"),
                trailing: Icon(
                  Icons.favorite,
                  color: const Color.fromARGB(255, 6, 179, 130),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text("Blood Glucose Level"),
                subtitle: const Text("5.8 mmol/L"),
                trailing: Icon(Icons.bloodtype, color: Colors.red[400]),
              ),
            ),

            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text("Heart Rate"),
                subtitle: const Text("72 BPM"),
                trailing: Icon(Icons.favorite, color: Colors.pink[300]),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text("BP"),
                subtitle: const Text("72 BPM"),
                trailing: Icon(Icons.favorite, color: Colors.pink[300]),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text("oxygen Level"),
                subtitle: const Text("72 BPM"),
                trailing: Icon(Icons.favorite, color: Colors.pink[300]),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                title: const Text("Recomndation Workout"),
                subtitle: const Text("dsffaaaaaaaaaaaas"),
                trailing: Icon(
                  Icons.favorite,
                  color: const Color.fromARGB(255, 98, 193, 240),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Example action
              },
              child: const Text("View Detailed Report"),
            ),
          ],
        ),
      ),
    );
  }
}
