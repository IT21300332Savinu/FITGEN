// lib/widgets/medical_alert_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/mock_wearable_provider.dart';

class MedicalAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mockWearableProvider = Provider.of<MockWearableProvider>(context);

    // Check for conditions that would trigger alerts
    bool showHeartRateAlert = mockWearableProvider.heartRate > 120;
    bool showBloodPressureAlert = false;

    final bp = mockWearableProvider.bloodPressure;
    final parts = bp.split('/');
    if (parts.length == 2) {
      final systolic = int.tryParse(parts[0]) ?? 0;
      final diastolic = int.tryParse(parts[1]) ?? 0;

      showBloodPressureAlert = systolic > 160 || diastolic > 100;
    }

    // If no alerts, don't show the widget
    if (!showHeartRateAlert && !showBloodPressureAlert) {
      return SizedBox.shrink();
    }

    return Card(
      color: Colors.red[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  "Medical Alert",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (showHeartRateAlert)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "• Your heart rate is critically high (${mockWearableProvider.heartRate} BPM). Stop exercising immediately and seek medical attention if symptoms persist.",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
              ),
            if (showBloodPressureAlert)
              Text(
                "• Your blood pressure is critically high (${mockWearableProvider.bloodPressure}). Stop exercising, rest, and consult your healthcare provider immediately.",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // In a real app, this would call emergency contacts
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Emergency contact notified (Demo)'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                  child: Text("Contact Emergency"),
                ),
                TextButton(
                  onPressed: () {
                    // Reset the simulation to normal
                    mockWearableProvider.simulateHealthCondition('normal');
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Text("Dismiss (Demo Only)"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
