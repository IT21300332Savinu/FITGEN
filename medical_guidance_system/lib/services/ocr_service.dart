import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  /// Process medical report using real OCR
  static Future<Map<String, dynamic>> processReport(File imageFile) async {
    try {
      print('🔍 Starting OCR processing for: ${imageFile.path}');

      // Check if file exists
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist');
      }

      // Create InputImage from file
      final inputImage = InputImage.fromFile(imageFile);

      // Perform OCR
      print('📖 Performing text recognition...');
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // Get extracted text
      String ocrText = recognizedText.text;
      print('✅ OCR completed. Text length: ${ocrText.length} characters');

      // Check if OCR found meaningful text
      if (ocrText.trim().isEmpty) {
        return {
          'success': false,
          'error':
              'No text detected in the image. Please ensure the image is clear and contains readable text.',
          'suggestion': 'Try taking a clearer photo with better lighting',
        };
      }

      // Check if text is too short (likely not a medical report)
      if (ocrText.trim().length < 50) {
        return {
          'success': false,
          'error':
              'Very little text detected. This may not be a medical report.',
          'extractedText': ocrText,
          'suggestion': 'Please upload a clear medical report image',
        };
      }

      // Calculate confidence based on medical terms found
      double confidence = _calculateMedicalConfidence(ocrText);

      print('🏥 Medical confidence: ${(confidence * 100).toStringAsFixed(1)}%');

      // If confidence is too low, it might not be a medical report
      if (confidence < 0.1) {
        return {
          'success': false,
          'error': 'This image does not appear to contain medical report data.',
          'extractedText': ocrText.length > 200
              ? '${ocrText.substring(0, 200)}...'
              : ocrText,
          'confidence': confidence,
          'suggestion':
              'Please upload a medical report containing laboratory results',
        };
      }

      // Create OCR results
      Map<String, dynamic> ocrResults = {
        'text': ocrText,
        'confidence': confidence,
        'processedDate': DateTime.now().toIso8601String(),
        'wordCount': ocrText.split(' ').length,
        'blocks': recognizedText.blocks.length,
      };

      // Extract health values from OCR text
      Map<String, dynamic> extractedValues = _extractHealthValues(ocrText);

      print('💊 Extracted ${extractedValues.length} health parameters');

      return {
        'success': true,
        'ocrResults': ocrResults,
        'extractedValues': extractedValues,
        'rawText': ocrText, // Include raw text for debugging
      };
    } catch (e) {
      print('❌ OCR Error: $e');
      return {
        'success': false,
        'error': 'OCR processing failed: ${e.toString()}',
        'suggestion': 'Please try again with a clearer image',
      };
    }
  }

  /// Calculate confidence based on medical terms presence
  static double _calculateMedicalConfidence(String text) {
    final lowerText = text.toLowerCase();

    // Medical terms that indicate this is a medical report
    final medicalTerms = [
      'hba1c',
      'hemoglobin a1c',
      'glycated hemoglobin',
      'glucose',
      'blood sugar',
      'egfr',
      'creatinine',
      'kidney function',
      'alt',
      'ast',
      'liver function',
      'hepatic',
      'cholesterol',
      'hdl',
      'ldl',
      'triglycerides',
      'blood pressure',
      'systolic',
      'diastolic',
      'laboratory',
      'lab results',
      'pathology',
      'mg/dl',
      'mmol/l',
      'mg/l',
      'μmol/l',
      'normal range',
      'reference range',
      'patient',
      'test results',
    ];

    int foundTerms = 0;
    for (String term in medicalTerms) {
      if (lowerText.contains(term)) {
        foundTerms++;
      }
    }

    return (foundTerms / medicalTerms.length).clamp(0.0, 1.0);
  }

  /// Extract health values from OCR text with improved accuracy
  static Map<String, dynamic> _extractHealthValues(String ocrText) {
    Map<String, dynamic> values = {};
    String cleanText = ocrText
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    print('🔬 Analyzing text for health parameters...');

    // Extract HbA1c values (diabetes indicator)
    RegExp hba1cPattern = RegExp(
      r'(?:HbA1[cC]?|hemoglobin\s+a1c|glycated\s+hemoglobin)\s*[:\-=]?\s*(\d+\.?\d*)\s*%?',
      caseSensitive: false,
    );
    Match? hba1cMatch = hba1cPattern.firstMatch(cleanText);
    if (hba1cMatch != null) {
      double? hba1c = double.tryParse(hba1cMatch.group(1) ?? '');
      if (hba1c != null && hba1c >= 4.0 && hba1c <= 15.0) {
        // Realistic range
        values['hba1c'] = hba1c;
        values['hba1c_unit'] = '%';
        values['diabetes_risk'] = hba1c > 6.5
            ? 'High'
            : hba1c > 5.7
            ? 'Prediabetes'
            : 'Normal';
        print('✅ Found HbA1c: $hba1c%');
      }
    }

    // Extract eGFR values (kidney function)
    RegExp egfrPattern = RegExp(
      r'eGFR\s*[:\-=]?\s*(\d+\.?\d*)\s*(?:mL/min/1\.73m[²2]?|ml/min/1\.73m[²2]?)?',
      caseSensitive: false,
    );
    Match? egfrMatch = egfrPattern.firstMatch(cleanText);
    if (egfrMatch != null) {
      double? egfr = double.tryParse(egfrMatch.group(1) ?? '');
      if (egfr != null && egfr >= 10 && egfr <= 150) {
        // Realistic range
        values['egfr'] = egfr;
        values['egfr_unit'] = 'mL/min/1.73m²';
        values['kidney_function'] = egfr < 60
            ? 'Impaired'
            : egfr < 90
            ? 'Mild Decline'
            : 'Normal';
        print('✅ Found eGFR: $egfr mL/min/1.73m²');
      }
    }

    // Extract Creatinine values (additional kidney marker)
    RegExp creatininePattern = RegExp(
      r'creatinine\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|μmol/l|umol/l)?',
      caseSensitive: false,
    );
    Match? creatinineMatch = creatininePattern.firstMatch(cleanText);
    if (creatinineMatch != null) {
      double? creatinine = double.tryParse(creatinineMatch.group(1) ?? '');
      String unit = creatinineMatch.group(2)?.toLowerCase() ?? 'mg/dl';
      if (creatinine != null) {
        // Validate based on unit
        bool validRange = false;
        if (unit.contains('mg/dl') && creatinine >= 0.5 && creatinine <= 5.0) {
          validRange = true;
        } else if (unit.contains('μmol/l') || unit.contains('umol/l')) {
          if (creatinine >= 44 && creatinine <= 442) validRange = true;
        }

        if (validRange) {
          values['creatinine'] = creatinine;
          values['creatinine_unit'] = unit;
          print('✅ Found Creatinine: $creatinine $unit');
        }
      }
    }

    // Extract ALT values
    RegExp altPattern = RegExp(
      r'ALT\s*[:\-=]?\s*(\d+\.?\d*)\s*(?:U/L|IU/L)?',
      caseSensitive: false,
    );
    Match? altMatch = altPattern.firstMatch(cleanText);
    if (altMatch != null) {
      double? alt = double.tryParse(altMatch.group(1) ?? '');
      if (alt != null && alt >= 5 && alt <= 200) {
        // Realistic range
        values['alt'] = alt;
        values['alt_unit'] = 'U/L';
        print('✅ Found ALT: $alt U/L');
      }
    }

    // Extract AST values
    RegExp astPattern = RegExp(
      r'AST\s*[:\-=]?\s*(\d+\.?\d*)\s*(?:U/L|IU/L)?',
      caseSensitive: false,
    );
    Match? astMatch = astPattern.firstMatch(cleanText);
    if (astMatch != null) {
      double? ast = double.tryParse(astMatch.group(1) ?? '');
      if (ast != null && ast >= 5 && ast <= 200) {
        // Realistic range
        values['ast'] = ast;
        values['ast_unit'] = 'U/L';
        print('✅ Found AST: $ast U/L');
      }
    }

    // Calculate ALT/AST ratio if both are available
    if (values['alt'] != null && values['ast'] != null) {
      double ratio = values['alt'] / values['ast'];
      values['alt_ast_ratio'] = ratio;
      values['liver_function'] = ratio > 2.0 ? 'Abnormal' : 'Normal';
      print('✅ Calculated ALT/AST ratio: ${ratio.toStringAsFixed(2)}');
    }

    // Extract glucose values
    RegExp glucosePattern = RegExp(
      r'(?:glucose|blood\s+sugar)\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? glucoseMatch = glucosePattern.firstMatch(cleanText);
    if (glucoseMatch != null) {
      double? glucose = double.tryParse(glucoseMatch.group(1) ?? '');
      String unit = glucoseMatch.group(2)?.toLowerCase() ?? 'mg/dl';
      if (glucose != null) {
        // Validate based on unit
        bool validRange = false;
        if (unit.contains('mg/dl') && glucose >= 50 && glucose <= 500) {
          validRange = true;
        } else if (unit.contains('mmol/l') &&
            glucose >= 2.8 &&
            glucose <= 27.8) {
          validRange = true;
        }

        if (validRange) {
          values['glucose'] = glucose;
          values['glucose_unit'] = unit;
          print('✅ Found Glucose: $glucose $unit');
        }
      }
    }

    // Extract blood pressure
    RegExp bpPattern = RegExp(
      r'(?:blood\s+pressure|bp)\s*[:\-=]?\s*(\d{2,3})/(\d{2,3})\s*mmHg?',
      caseSensitive: false,
    );
    Match? bpMatch = bpPattern.firstMatch(cleanText);
    if (bpMatch != null) {
      int? systolic = int.tryParse(bpMatch.group(1) ?? '');
      int? diastolic = int.tryParse(bpMatch.group(2) ?? '');
      if (systolic != null &&
          diastolic != null &&
          systolic >= 80 &&
          systolic <= 250 &&
          diastolic >= 40 &&
          diastolic <= 150) {
        values['systolic_bp'] = systolic;
        values['diastolic_bp'] = diastolic;
        values['bp_unit'] = 'mmHg';
        values['hypertension_risk'] = (systolic > 130 || diastolic > 80)
            ? 'High'
            : 'Normal';
        print('✅ Found Blood Pressure: $systolic/$diastolic mmHg');
      }
    }

    // Extract cholesterol values
    RegExp cholesterolPattern = RegExp(
      r'(?:total\s+)?cholesterol\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? cholesterolMatch = cholesterolPattern.firstMatch(cleanText);
    if (cholesterolMatch != null) {
      double? cholesterol = double.tryParse(cholesterolMatch.group(1) ?? '');
      String unit = cholesterolMatch.group(2)?.toLowerCase() ?? 'mg/dl';
      if (cholesterol != null) {
        // Validate based on unit
        bool validRange = false;
        if (unit.contains('mg/dl') &&
            cholesterol >= 100 &&
            cholesterol <= 400) {
          validRange = true;
        } else if (unit.contains('mmol/l') &&
            cholesterol >= 2.6 &&
            cholesterol <= 10.4) {
          validRange = true;
        }

        if (validRange) {
          values['cholesterol'] = cholesterol;
          values['cholesterol_unit'] = unit;
          print('✅ Found Cholesterol: $cholesterol $unit');
        }
      }
    }

    // Extract HDL cholesterol
    RegExp hdlPattern = RegExp(
      r'HDL\s*(?:cholesterol)?\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? hdlMatch = hdlPattern.firstMatch(cleanText);
    if (hdlMatch != null) {
      double? hdl = double.tryParse(hdlMatch.group(1) ?? '');
      String unit = hdlMatch.group(2)?.toLowerCase() ?? 'mg/dl';
      if (hdl != null && hdl >= 20 && hdl <= 100) {
        // Realistic range for mg/dl
        values['hdl'] = hdl;
        values['hdl_unit'] = unit;
        print('✅ Found HDL: $hdl $unit');
      }
    }

    // Extract LDL cholesterol
    RegExp ldlPattern = RegExp(
      r'LDL\s*(?:cholesterol)?\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? ldlMatch = ldlPattern.firstMatch(cleanText);
    if (ldlMatch != null) {
      double? ldl = double.tryParse(ldlMatch.group(1) ?? '');
      String unit = ldlMatch.group(2)?.toLowerCase() ?? 'mg/dl';
      if (ldl != null && ldl >= 50 && ldl <= 300) {
        // Realistic range for mg/dl
        values['ldl'] = ldl;
        values['ldl_unit'] = unit;
        print('✅ Found LDL: $ldl $unit');
      }
    }

    print('📊 Total extracted parameters: ${values.length}');
    return values;
  }

  /// Generate health insights from extracted values
  static String getHealthInsight(
    Map<String, dynamic> values,
    bool hasDiabetes,
    bool hasHypertension,
    bool hasCKD,
    bool hasLiverDisease,
  ) {
    List<String> insights = [];

    // HbA1c insights
    if (values['hba1c'] != null) {
      double hba1c = values['hba1c'];
      if (hba1c < 5.7) {
        insights.add("✅ HbA1c is normal ($hba1c%) - Good diabetes control");
      } else if (hba1c < 6.5) {
        insights.add(
          "⚠️ HbA1c indicates prediabetes ($hba1c%) - Lifestyle changes recommended",
        );
      } else {
        insights.add(
          "⚠️ HbA1c indicates diabetes ($hba1c%) - Medical management needed",
        );
      }
    }

    // eGFR insights
    if (values['egfr'] != null) {
      double egfr = values['egfr'];
      if (egfr >= 90) {
        insights.add(
          "✅ Kidney function is normal (eGFR: ${egfr.toStringAsFixed(0)})",
        );
      } else if (egfr >= 60) {
        insights.add(
          "⚠️ Mild kidney function decline (eGFR: ${egfr.toStringAsFixed(0)}) - Monitor regularly",
        );
      } else {
        insights.add(
          "⚠️ Significant kidney function impairment (eGFR: ${egfr.toStringAsFixed(0)}) - Specialist consultation needed",
        );
      }
    }

    // ALT/AST ratio insights
    if (values['alt_ast_ratio'] != null) {
      double ratio = values['alt_ast_ratio'];
      if (ratio <= 2.0) {
        insights.add(
          "✅ Liver function markers are normal (ALT/AST ratio: ${ratio.toStringAsFixed(1)})",
        );
      } else {
        insights.add(
          "⚠️ Elevated liver enzymes (ALT/AST ratio: ${ratio.toStringAsFixed(1)}) - Further evaluation recommended",
        );
      }
    }

    // Blood pressure insights
    if (values['systolic_bp'] != null && values['diastolic_bp'] != null) {
      int systolic = values['systolic_bp'];
      int diastolic = values['diastolic_bp'];
      if (systolic < 120 && diastolic < 80) {
        insights.add("✅ Blood pressure is optimal");
      } else if (systolic <= 130 && diastolic <= 80) {
        insights.add(
          "⚠️ Blood pressure is elevated - Lifestyle modifications recommended",
        );
      } else {
        insights.add(
          "⚠️ Blood pressure indicates hypertension - Medical evaluation needed",
        );
      }
    }

    // Glucose insights
    if (values['glucose'] != null) {
      double glucose = values['glucose'];
      String unit = values['glucose_unit'] ?? 'mg/dl';
      if (unit.contains('mg/dl')) {
        if (glucose < 100) {
          insights.add("✅ Fasting glucose is normal");
        } else if (glucose < 126) {
          insights.add(
            "⚠️ Glucose level is elevated - Diabetes screening recommended",
          );
        } else {
          insights.add(
            "⚠️ Glucose level indicates diabetes - Medical management required",
          );
        }
      }
    }

    if (insights.isEmpty) {
      insights.add("ℹ️ No specific health parameters detected in the report.");
    }

    return insights.join('\n\n');
  }

  /// Assess condition risks from OCR data
  static Map<String, bool> assessConditionRisks(Map<String, dynamic> values) {
    Map<String, bool> risks = {
      'diabetesRisk': false,
      'hypertensionRisk': false,
      'ckdRisk': false,
      'liverDiseaseRisk': false,
    };

    // Diabetes risk assessment - HbA1c >6.5%
    if (values['hba1c'] != null && values['hba1c'] > 6.5) {
      risks['diabetesRisk'] = true;
    }
    if (values['glucose'] != null) {
      double glucose = values['glucose'];
      String unit = values['glucose_unit'] ?? 'mg/dl';
      if (unit.contains('mg/dl') && glucose > 126) {
        risks['diabetesRisk'] = true;
      }
    }

    // Hypertension risk assessment - BP >130/80 mmHg
    if (values['systolic_bp'] != null && values['diastolic_bp'] != null) {
      if (values['systolic_bp'] > 130 || values['diastolic_bp'] > 80) {
        risks['hypertensionRisk'] = true;
      }
    }

    // CKD risk assessment - eGFR <90 mL/min/1.73m²
    if (values['egfr'] != null && values['egfr'] < 90) {
      risks['ckdRisk'] = true;
    }

    // Liver disease risk assessment - ALT/AST ratio >2.0
    if (values['alt_ast_ratio'] != null && values['alt_ast_ratio'] > 2.0) {
      risks['liverDiseaseRisk'] = true;
    }

    return risks;
  }

  /// Clean up resources
  static void dispose() {
    _textRecognizer.close();
  }
}
