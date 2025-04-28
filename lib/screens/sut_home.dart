import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/sut_home_workout_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FITGEN'),
        backgroundColor: Colors.blue,
        actions: [CircleAvatar(backgroundImage: AssetImage('assets/images/user.png'))],
      ),
      drawer: Drawer(child: ListView(children: [ListTile(title: Text('Profile'))])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(15)),
              child: Text("Calendar\nWorkout days are highlighted"),
            ),
            Text("Welcome User!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            sut_home_workout_card(sport: "Cricket", progress: 50, completed: 5),
            sut_home_workout_card(sport: "Badminton", progress: 50, completed: 5),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text("Workout History", style: TextStyle(fontWeight: FontWeight.bold)),
                  DataTable(columns: [
                    DataColumn(label: Text("Sport")),
                    DataColumn(label: Text("Workouts")),
                    DataColumn(label: Text("Date")),
                  ], rows: [
                    DataRow(cells: [DataCell(Text("Cricket")), DataCell(Text("3")), DataCell(Text("04/01/2025"))]),
                    DataRow(cells: [DataCell(Text("Badminton")), DataCell(Text("1")), DataCell(Text("03/01/2025"))]),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottom_navbar(),
    );
  }
}
