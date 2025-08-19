import 'dart:io';
import 'dart:math';

class OCRService {
  // This is an improved OCR service with better mock data for development
  // Replace this with your actual OCR implementation when ready

  static Future<Map<String, dynamic>> processReport(File imageFile) async {
    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 2));

      // Generate realistic mock OCR results based on common medical report formats
      Map<String, dynamic> ocrResults = _generateMockOCRResults();

      // Extract health values from OCR text
      Map<String, dynamic> extractedValues = _extractHealthValues(
        ocrResults['text'],
      );

      return {
        'success': true,
        'ocrResults': ocrResults,
        'extractedValues': extractedValues,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Map<String, dynamic> _generateMockOCRResults() {
    final random = Random();

    // Generate realistic medical report text with various health parameters
    List<String> mockReportTexts = [
      """
      COMPREHENSIVE METABOLIC PANEL
      Patient: John Doe
      Date: ${DateTime.now().subtract(Duration(days: random.nextInt(30))).toString().split(' ')[0]}
      
      GLUCOSE: ${70 + random.nextInt(80)} mg/dL
      HbA1c: ${4.5 + random.nextDouble() * 3}.${random.nextInt(10)}%
      CHOLESTEROL: ${150 + random.nextInt(100)} mg/dL
      HDL CHOLESTEROL: ${35 + random.nextInt(30)} mg/dL
      LDL CHOLESTEROL: ${80 + random.nextInt(70)} mg/dL
      TRIGLYCERIDES: ${80 + random.nextInt(120)} mg/dL
      CREATININE: ${0.6 + random.nextDouble() * 1.5} mg/dL
      BUN: ${8 + random.nextInt(17)} mg/dL
      SODIUM: ${135 + random.nextInt(10)} mEq/L
      POTASSIUM: ${3.5 + random.nextDouble() * 1.5} mEq/L
      """,

      """
      LIPID PROFILE REPORT
      Patient ID: ${random.nextInt(10000)}
      Test Date: ${DateTime.now().subtract(Duration(days: random.nextInt(60))).toString().split(' ')[0]}
      
      Total Cholesterol: ${170 + random.nextInt(80)} mg/dL
      HDL-C: ${40 + random.nextInt(20)} mg/dL  
      LDL-C: ${90 + random.nextInt(60)} mg/dL
      VLDL-C: ${15 + random.nextInt(20)} mg/dL
      Triglycerides: ${100 + random.nextInt(150)} mg/dL
      Non-HDL Cholesterol: ${120 + random.nextInt(70)} mg/dL
      TC/HDL Ratio: ${3.0 + random.nextDouble() * 2}
      LDL/HDL Ratio: ${2.0 + random.nextDouble() * 2}
      """,

      """
      DIABETES MONITORING REPORT
      HbA1c: ${5.0 + random.nextDouble() * 4}.${random.nextInt(10)}%
      Fasting Glucose: ${80 + random.nextInt(70)} mg/dL
      Random Glucose: ${90 + random.nextInt(100)} mg/dL
      Blood Pressure: ${110 + random.nextInt(40)}/${70 + random.nextInt(25)} mmHg
      Microalbumin: ${5 + random.nextInt(40)} mg/g creatinine
      eGFR: ${60 + random.nextInt(40)} mL/min/1.73m²
      """,

      """
      COMPREHENSIVE HEALTH CHECKUP
      Blood Pressure: ${115 + random.nextInt(35)}/${75 + random.nextInt(20)} mmHg
      Heart Rate: ${60 + random.nextInt(40)} BPM
      BMI: ${18.5 + random.nextDouble() * 15} kg/m²
      
      LABORATORY RESULTS:
      Hemoglobin: ${12.0 + random.nextDouble() * 4} g/dL
      Hematocrit: ${36 + random.nextInt(15)}%
      WBC Count: ${4000 + random.nextInt(7000)} /μL
      Platelet Count: ${150000 + random.nextInt(300000)} /μL
      ESR: ${5 + random.nextInt(25)} mm/hr
      
      LIVER FUNCTION:
      ALT: ${10 + random.nextInt(40)} U/L
      AST: ${15 + random.nextInt(35)} U/L
      Bilirubin Total: ${0.3 + random.nextDouble() * 1.5} mg/dL
      """,
    ];

    String selectedText =
        mockReportTexts[random.nextInt(mockReportTexts.length)];

    return {
      'text': selectedText,
      'confidence': 0.85 + random.nextDouble() * 0.14, // 85-99% confidence
      'processedDate': DateTime.now().toIso8601String(),
      'language': 'en',
      'pages': 1,
    };
  }

  static Map<String, dynamic> _extractHealthValues(String ocrText) {
    Map<String, dynamic> values = {};

    // Extract HbA1c values
    RegExp hba1cPattern = RegExp(
      r'HbA1[cC]?\s*:?\s*(\d+\.?\d*)\s*%?',
      caseSensitive: false,
    );
    Match? hba1cMatch = hba1cPattern.firstMatch(ocrText);
    if (hba1cMatch != null) {
      values['hba1c'] = double.tryParse(hba1cMatch.group(1) ?? '');
    }

    // Extract glucose values (fasting, random, etc.)
    RegExp glucosePattern = RegExp(
      r'(?:fasting\s+|random\s+)?glucose\s*:?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? glucoseMatch = glucosePattern.firstMatch(ocrText);
    if (glucoseMatch != null) {
      values['glucose'] = double.tryParse(glucoseMatch.group(1) ?? '');
      values['glucoseUnit'] = glucoseMatch.group(2) ?? 'mg/dl';
    }

    // Extract total cholesterol
    RegExp cholesterolPattern = RegExp(
      r'(?:total\s+)?cholesterol\s*:?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? cholesterolMatch = cholesterolPattern.firstMatch(ocrText);
    if (cholesterolMatch != null) {
      values['cholesterol'] = double.tryParse(cholesterolMatch.group(1) ?? '');
      values['cholesterolUnit'] = cholesterolMatch.group(2) ?? 'mg/dl';
    }

    // Extract HDL cholesterol
    RegExp hdlPattern = RegExp(
      r'HDL[-\s]*(?:cholesterol|c)\s*:?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? hdlMatch = hdlPattern.firstMatch(ocrText);
    if (hdlMatch != null) {
      values['hdl'] = double.tryParse(hdlMatch.group(1) ?? '');
      values['hdlUnit'] = hdlMatch.group(2) ?? 'mg/dl';
    }

    // Extract LDL cholesterol
    RegExp ldlPattern = RegExp(
      r'LDL[-\s]*(?:cholesterol|c)\s*:?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? ldlMatch = ldlPattern.firstMatch(ocrText);
    if (ldlMatch != null) {
      values['ldl'] = double.tryParse(ldlMatch.group(1) ?? '');
      values['ldlUnit'] = ldlMatch.group(2) ?? 'mg/dl';
    }

    // Extract triglycerides
    RegExp triglyceridesPattern = RegExp(
      r'triglycerides?\s*:?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? triglyceridesMatch = triglyceridesPattern.firstMatch(ocrText);
    if (triglyceridesMatch != null) {
      values['triglycerides'] = double.tryParse(
        triglyceridesMatch.group(1) ?? '',
      );
      values['triglyceridesUnit'] = triglyceridesMatch.group(2) ?? 'mg/dl';
    }

    // Extract blood pressure
    RegExp bpPattern = RegExp(
      r'(?:blood\s+pressure\s*:?\s*)?(\d{2,3})/(\d{2,3})\s*mmHg',
      caseSensitive: false,
    );
    Match? bpMatch = bpPattern.firstMatch(ocrText);
    if (bpMatch != null) {
      values['systolicBP'] = int.tryParse(bpMatch.group(1) ?? '');
      values['diastolicBP'] = int.tryParse(bpMatch.group(2) ?? '');
    }

    // Extract creatinine
    RegExp creatininePattern = RegExp(
      r'creatinine\s*:?\s*(\d+\.?\d*)\s*(mg/dl|μmol/l|umol/l)?',
      caseSensitive: false,
    );
    Match? creatinineMatch = creatininePattern.firstMatch(ocrText);
    if (creatinineMatch != null) {
      values['creatinine'] = double.tryParse(creatinineMatch.group(1) ?? '');
      values['creatinineUnit'] = creatinineMatch.group(2) ?? 'mg/dl';
    }

    // Extract BUN (Blood Urea Nitrogen)
    RegExp bunPattern = RegExp(
      r'BUN\s*:?\s*(\d+\.?\d*)\s*(mg/dl)?',
      caseSensitive: false,
    );
    Match? bunMatch = bunPattern.firstMatch(ocrText);
    if (bunMatch != null) {
      values['bun'] = double.tryParse(bunMatch.group(1) ?? '');
      values['bunUnit'] = bunMatch.group(2) ?? 'mg/dl';
    }

    // Extract eGFR (estimated Glomerular Filtration Rate)
    RegExp egfrPattern = RegExp(
      r'eGFR\s*:?\s*(\d+\.?\d*)\s*(ml/min/1\.73m²|mL/min/1.73m²)?',
      caseSensitive: false,
    );
    Match? egfrMatch = egfrPattern.firstMatch(ocrText);
    if (egfrMatch != null) {
      values['egfr'] = double.tryParse(egfrMatch.group(1) ?? '');
      values['egfrUnit'] = egfrMatch.group(2) ?? 'mL/min/1.73m²';
    }

    return values;
  }

  static String getHealthInsight(
    Map<String, dynamic> values,
    bool hasDiabetes,
    bool hasHypertension,
  ) {
    List<String> insights = [];

    // HbA1c insights
    if (values['hba1c'] != null) {
      double hba1c = values['hba1c'];
      if (hba1c < 5.7) {
        insights.add("✅ HbA1c is normal (${hba1c.toStringAsFixed(1)}%)");
      } else if (hba1c < 6.5) {
        insights.add(
          "⚠️ HbA1c indicates prediabetes (${hba1c.toStringAsFixed(1)}%)",
        );
        insights.add("💡 Consider lifestyle changes to prevent diabetes");
      } else {
        insights.add(
          "🔴 HbA1c indicates diabetes (${hba1c.toStringAsFixed(1)}%)",
        );
        if (hasDiabetes) {
          insights.add("📊 Continue monitoring and follow your treatment plan");
        } else {
          insights.add("⚠️ Please consult your doctor about this result");
        }
      }
    }

    // Glucose insights
    if (values['glucose'] != null) {
      double glucose = values['glucose'];
      if (glucose < 100) {
        insights.add(
          "✅ Glucose level is normal (${glucose.toStringAsFixed(0)} mg/dL)",
        );
      } else if (glucose < 126) {
        insights.add(
          "⚠️ Glucose level is elevated (${glucose.toStringAsFixed(0)} mg/dL)",
        );
      } else {
        insights.add(
          "🔴 Glucose level indicates diabetes (${glucose.toStringAsFixed(0)} mg/dL)",
        );
      }
    }

    // Blood pressure insights
    if (values['systolicBP'] != null && values['diastolicBP'] != null) {
      int systolic = values['systolicBP'];
      int diastolic = values['diastolicBP'];
      if (systolic < 120 && diastolic < 80) {
        insights.add("✅ Blood pressure is normal ($systolic/$diastolic mmHg)");
      } else if (systolic < 140 || diastolic < 90) {
        insights.add(
          "⚠️ Blood pressure is elevated ($systolic/$diastolic mmHg)",
        );
        insights.add("💡 Consider lifestyle modifications");
      } else {
        insights.add(
          "🔴 Blood pressure indicates hypertension ($systolic/$diastolic mmHg)",
        );
        if (!hasHypertension) {
          insights.add("⚠️ Please consult your doctor about this result");
        }
      }
    }

    // Cholesterol insights
    if (values['cholesterol'] != null) {
      double cholesterol = values['cholesterol'];
      if (cholesterol < 200) {
        insights.add(
          "✅ Total cholesterol is optimal (${cholesterol.toStringAsFixed(0)} mg/dL)",
        );
      } else if (cholesterol < 240) {
        insights.add(
          "⚠️ Total cholesterol is borderline high (${cholesterol.toStringAsFixed(0)} mg/dL)",
        );
      } else {
        insights.add(
          "🔴 Total cholesterol is high (${cholesterol.toStringAsFixed(0)} mg/dL)",
        );
      }
    }

    // HDL insights
    if (values['hdl'] != null) {
      double hdl = values['hdl'];
      if (hdl >= 40) {
        insights.add(
          "✅ HDL (good cholesterol) is adequate (${hdl.toStringAsFixed(0)} mg/dL)",
        );
      } else {
        insights.add(
          "⚠️ HDL (good cholesterol) is low (${hdl.toStringAsFixed(0)} mg/dL)",
        );
        insights.add("💡 Regular exercise can help raise HDL levels");
      }
    }

    // Kidney function insights
    if (values['creatinine'] != null) {
      double creatinine = values['creatinine'];
      if (creatinine <= 1.3) {
        insights.add("✅ Kidney function appears normal");
      } else if (creatinine <= 2.0) {
        insights.add(
          "⚠️ Creatinine is slightly elevated - monitor kidney function",
        );
      } else {
        insights.add(
          "🔴 Creatinine is significantly elevated - consult your doctor",
        );
      }
    }

    if (insights.isEmpty) {
      insights.add(
        "📊 Report processed successfully. Some values were extracted but need medical interpretation.",
      );
    }

    insights.add(
      "\n💡 Remember: Always consult with your healthcare provider for proper medical interpretation of these results.",
    );

    return insights.join('\n');
  }

  // Helper method to get health recommendations based on extracted values
  static List<String> getHealthRecommendations(Map<String, dynamic> values) {
    List<String> recommendations = [];

    // HbA1c recommendations
    if (values['hba1c'] != null) {
      double hba1c = values['hba1c'];
      if (hba1c >= 6.5) {
        recommendations.addAll([
          "Follow a low-carb, high-fiber diet",
          "Monitor blood sugar regularly",
          "Engage in regular physical activity",
          "Take medications as prescribed",
        ]);
      } else if (hba1c >= 5.7) {
        recommendations.addAll([
          "Adopt a balanced diet with controlled portions",
          "Increase physical activity to 150 minutes per week",
          "Maintain a healthy weight",
        ]);
      }
    }

    // Blood pressure recommendations
    if (values['systolicBP'] != null && values['diastolicBP'] != null) {
      int systolic = values['systolicBP'];
      if (systolic >= 140) {
        recommendations.addAll([
          "Reduce sodium intake to less than 2,300mg daily",
          "Include potassium-rich foods in your diet",
          "Limit alcohol consumption",
          "Practice stress management techniques",
        ]);
      }
    }

    // Cholesterol recommendations
    if (values['cholesterol'] != null) {
      double cholesterol = values['cholesterol'];
      if (cholesterol >= 200) {
        recommendations.addAll([
          "Choose lean proteins and healthy fats",
          "Increase soluble fiber intake",
          "Include omega-3 rich foods",
          "Consider plant sterols and stanols",
        ]);
      }
    }

    return recommendations;
  }
}
