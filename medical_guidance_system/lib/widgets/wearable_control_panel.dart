// lib/widgets/wearable_control_panel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/mock_wearable_provider.dart';

class WearableControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mockWearableProvider = Provider.of<MockWearableProvider>(context);

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.watch, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  "Mock Wearable Controls",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Simulate different health conditions:",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed:
                      () => mockWearableProvider.simulateHealthCondition(
                        'normal',
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Normal'),
                ),
                ElevatedButton(
                  onPressed:
                      () => mockWearableProvider.simulateHealthCondition(
                        'hypertension',
                      ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Hypertension'),
                ),
                ElevatedButton(
                  onPressed:
                      () => mockWearableProvider.simulateHealthCondition(
                        'diabetes',
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Diabetes'),
                ),
                ElevatedButton(
                  onPressed:
                      () => mockWearableProvider.simulateHealthCondition(
                        'fatigue',
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: Text('Fatigue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
