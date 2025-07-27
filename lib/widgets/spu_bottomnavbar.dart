import 'package:flutter/material.dart';

class spu_bottomnavbar extends StatelessWidget {
  const spu_bottomnavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.lightBlue,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Home", style: TextStyle(color: Colors.white)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("AI Coach", style: TextStyle(color: Colors.white)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Safeguard", style: TextStyle(color: Colors.white)),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Meetup", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
