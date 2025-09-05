import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  static final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Process medical report using real OCR with enhanced detection
  static Future<Map<String, dynamic>> processReport(File imageFile) async {
    try {
      print('🔍 Starting enhanced OCR processing for: ${imageFile.path}');

      // Validate file existence
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

      // Validate OCR results
      if (ocrText.trim().isEmpty) {
        return {
          'success': false,
          'error':
              'No text detected in the image. Please ensure the image is clear and contains readable text.',
          'suggestion': 'Try taking a clearer photo with better lighting',
        };
      }

      if (ocrText.trim().length < 50) {
        return {
          'success': false,
          'error':
              'Very little text detected. This may not be a medical report.',
          'extractedText': ocrText,
          'suggestion': 'Please upload a clear medical report image',
        };
      }

      // Calculate medical confidence
      double confidence = _calculateMedicalConfidence(ocrText);
      print('🏥 Medical confidence: ${(confidence * 100).toStringAsFixed(1)}%');

      // Validate as medical report
      if (confidence < 0.1) {
        return {
          'success': false,
          'error': 'This image does not appear to contain medical report data.',
          'extractedText': ocrText.length > 200
              ? ocrText.substring(0, 200) + '...'
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
        'lineCount': ocrText.split('\n').length,
      };

      // Extract health values with enhanced algorithms
      Map<String, dynamic> extractedValues = _extractHealthValues(ocrText);

      print('💊 Extracted ${extractedValues.length} health parameters');

      return {
        'success': true,
        'ocrResults': ocrResults,
        'extractedValues': extractedValues,
        'rawText': ocrText,
        'medicalTermsFound': _findMedicalTerms(ocrText),
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

    // Comprehensive medical terms
    final medicalTerms = [
      'hba1c',
      'hemoglobin a1c',
      'glycated hemoglobin',
      'glucose',
      'blood sugar',
      'fasting glucose',
      'egfr',
      'creatinine',
      'kidney function',
      'renal function',
      'alt',
      'ast',
      'sgpt',
      'sgot',
      'liver function',
      'hepatic',
      'cholesterol',
      'hdl',
      'ldl',
      'triglycerides',
      'blood pressure',
      'systolic',
      'diastolic',
      'hypertension',
      'albumin',
      'protein',
      'total protein',
      'bilirubin',
      'laboratory',
      'lab results',
      'pathology',
      'clinical',
      'mg/dl',
      'mmol/l',
      'mg/l',
      'μmol/l',
      'umol/l',
      'iu/l',
      'u/l',
      'normal range',
      'reference range',
      'reference value',
      'patient',
      'test results',
      'specimen',
      'serum',
      'plasma',
      'report',
      'analysis',
      'examination',
      'investigation',
    ];

    int foundTerms = 0;
    int totalPossibleScore = medicalTerms.length;

    for (String term in medicalTerms) {
      if (lowerText.contains(term)) {
        foundTerms++;
      }
    }

    // Additional scoring for numerical patterns typical in medical reports
    RegExp numberPattern = RegExp(
      r'\d+\.?\d*\s*(?:mg/dl|mmol/l|iu/l|u/l|%|g/dl)',
    );
    int medicalNumbers = numberPattern.allMatches(lowerText).length;

    // Bonus points for medical number patterns (max 10 bonus points)
    int bonusScore = (medicalNumbers * 2).clamp(0, 10);

    return ((foundTerms + bonusScore) / (totalPossibleScore + 10)).clamp(
      0.0,
      1.0,
    );
  }

  /// Find and return list of medical terms found in text
  static List<String> _findMedicalTerms(String text) {
    final lowerText = text.toLowerCase();
    final medicalTerms = [
      'hba1c',
      'glucose',
      'egfr',
      'creatinine',
      'alt',
      'ast',
      'sgpt',
      'sgot',
      'cholesterol',
      'hdl',
      'ldl',
      'albumin',
      'protein',
      'bilirubin',
      'blood pressure',
      'laboratory',
      'pathology',
    ];

    List<String> foundTerms = [];
    for (String term in medicalTerms) {
      if (lowerText.contains(term)) {
        foundTerms.add(term.toUpperCase());
      }
    }
    return foundTerms;
  }

  /// Enhanced health values extraction with comprehensive detection
  static Map<String, dynamic> _extractHealthValues(String ocrText) {
    Map<String, dynamic> values = {};

    // Clean and normalize text
    String cleanText = ocrText
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    List<String> lines = ocrText.split('\n');

    print('🔬 Analyzing text for health parameters...');

    // ==================== HbA1c Detection ====================
    _extractHbA1c(cleanText, values);

    // ==================== eGFR Detection ====================
    _extractEgfr(cleanText, lines, values);

    // ==================== Liver Function Tests ====================
    _extractLiverFunction(cleanText, lines, values);

    // ==================== Protein Analysis ====================
    _extractProteins(cleanText, lines, values);

    // ==================== Kidney Function Markers ====================
    _extractKidneyMarkers(cleanText, values);

    // ==================== Glucose Detection ====================
    _extractGlucose(cleanText, values);

    // ==================== Blood Pressure ====================
    _extractBloodPressure(cleanText, values);

    // ==================== Lipid Profile ====================
    _extractLipidProfile(cleanText, values);

    // ==================== Additional Markers ====================
    _extractAdditionalMarkers(cleanText, lines, values);

    print('📊 Total extracted parameters: ${values.length}');
    return values;
  }

  /// Extract HbA1c values with multiple patterns
  static void _extractHbA1c(String text, Map<String, dynamic> values) {
    List<RegExp> hba1cPatterns = [
      RegExp(r'HbA1[cC]?\s*[:\-=]?\s*(\d+\.?\d*)\s*%?', caseSensitive: false),
      RegExp(
        r'hemoglobin\s*a1c\s*[:\-=]?\s*(\d+\.?\d*)\s*%?',
        caseSensitive: false,
      ),
      RegExp(
        r'glycated\s*hemoglobin\s*[:\-=]?\s*(\d+\.?\d*)\s*%?',
        caseSensitive: false,
      ),
      RegExp(r'HBA1C\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
    ];

    for (RegExp pattern in hba1cPatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null) {
        double? hba1c = double.tryParse(match.group(1) ?? '');
        if (hba1c != null && hba1c >= 4.0 && hba1c <= 15.0) {
          values['hba1c'] = hba1c;
          values['hba1c_unit'] = '%';

          // Clinical classification
          String category;
          String recommendation;
          if (hba1c < 5.7) {
            category = "Normal";
            recommendation = "Continue healthy lifestyle";
          } else if (hba1c >= 5.7 && hba1c <= 6.4) {
            category = "Prediabetes";
            recommendation = "Lifestyle modification recommended";
          } else if (hba1c >= 6.5 && hba1c <= 7.0) {
            category = "Diabetes (Good Control)";
            recommendation = "Maintain current management";
          } else if (hba1c > 7.0 && hba1c <= 8.0) {
            category = "Diabetes (Fair Control)";
            recommendation = "Consider treatment adjustment";
          } else {
            category = "Diabetes (Poor Control)";
            recommendation = "Urgent treatment optimization needed";
          }

          values['diabetes_stage'] = category;
          values['diabetes_recommendation'] = recommendation;
          values['diabetes_risk'] = hba1c >= 6.5
              ? 'High'
              : hba1c >= 5.7
              ? 'Medium'
              : 'Low';

          print('✅ Found HbA1c: $hba1c% → $category');
          break;
        }
      }
    }
  }

  /// Extract eGFR with enhanced detection
  static void _extractEgfr(
    String text,
    List<String> lines,
    Map<String, dynamic> values,
  ) {
    List<RegExp> egfrPatterns = [
      RegExp(
        r'eGFR\s*[:\-=]?\s*(\d+\.?\d*)\s*(?:mL/min/1\.73m[²2]?)?',
        caseSensitive: false,
      ),
      RegExp(r'EGFR\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'EGR[a-z]*\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'(?:eGFR|EGFR)\s*.*?(\d+\.?\d*)', caseSensitive: false),
    ];

    double? detectedEgfr;

    // Try patterns first
    for (RegExp pattern in egfrPatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null) {
        double? egfr = double.tryParse(match.group(1) ?? '');
        if (egfr != null && egfr >= 5 && egfr <= 200) {
          detectedEgfr = egfr;
          break;
        }
      }
    }

    // Line-by-line analysis if not found
    if (detectedEgfr == null) {
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].toLowerCase();
        if (line.contains('egfr') || line.contains('egr')) {
          for (int j = i; j < i + 3 && j < lines.length; j++) {
            RegExp numberPattern = RegExp(r'(\d+\.?\d*)');
            Iterable<Match> matches = numberPattern.allMatches(lines[j]);
            for (Match match in matches) {
              double? egfr = double.tryParse(match.group(1) ?? '');
              if (egfr != null && egfr >= 5 && egfr <= 200) {
                detectedEgfr = egfr;
                break;
              }
            }
            if (detectedEgfr != null) break;
          }
          if (detectedEgfr != null) break;
        }
      }
    }

    if (detectedEgfr != null) {
      values['egfr'] = detectedEgfr;
      values['egfr_unit'] = 'mL/min/1.73m²';

      // CKD Classification
      String kidneyFunction;
      String ckdStage;
      String recommendation;

      if (detectedEgfr >= 90) {
        kidneyFunction = 'Normal';
        ckdStage = 'Stage 1 (Normal or High)';
        recommendation = 'Maintain healthy lifestyle';
      } else if (detectedEgfr >= 60) {
        kidneyFunction = 'Mild Decline';
        ckdStage = 'Stage 2 (Mild CKD)';
        recommendation =
            'Monitor annually, control blood pressure and diabetes';
      } else if (detectedEgfr >= 45) {
        kidneyFunction = 'Moderate Decline';
        ckdStage = 'Stage 3a (Mild to Moderate CKD)';
        recommendation = 'Monitor every 6 months, nephrology referral';
      } else if (detectedEgfr >= 30) {
        kidneyFunction = 'Moderate Decline';
        ckdStage = 'Stage 3b (Moderate to Severe CKD)';
        recommendation = 'Nephrology care, monitor every 3 months';
      } else if (detectedEgfr >= 15) {
        kidneyFunction = 'Severe Decline';
        ckdStage = 'Stage 4 (Severe CKD)';
        recommendation = 'Prepare for renal replacement therapy';
      } else {
        kidneyFunction = 'Kidney Failure';
        ckdStage = 'Stage 5 (Kidney Failure)';
        recommendation = 'Dialysis or transplant needed';
      }

      values['kidney_function'] = kidneyFunction;
      values['ckd_stage'] = ckdStage;
      values['kidney_recommendation'] = recommendation;
      values['kidney_risk'] = detectedEgfr < 90 ? 'High' : 'Normal';

      print(
        '✅ eGFR Analysis: $detectedEgfr mL/min/1.73m² - $kidneyFunction ($ckdStage)',
      );
    }
  }

  /// Extract liver function tests with enhanced detection
  static void _extractLiverFunction(
    String text,
    List<String> lines,
    Map<String, dynamic> values,
  ) {
    double? altValue;
    double? astValue;

    // ALT/SGPT Detection
    List<RegExp> altPatterns = [
      RegExp(r'ALT\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'SGPT\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'(?:ALT|SGPT)\s*.*?(\d+\.?\d*)', caseSensitive: false),
    ];

    // Try patterns
    for (RegExp pattern in altPatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null) {
        double? alt = double.tryParse(match.group(1) ?? '');
        if (alt != null && alt >= 1 && alt <= 500) {
          altValue = alt;
          break;
        }
      }
    }

    // Line analysis for ALT/SGPT
    if (altValue == null) {
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].toLowerCase();
        if (line.contains('sgpt') || line.contains('alt')) {
          for (int j = i; j < i + 2 && j < lines.length; j++) {
            RegExp numberPattern = RegExp(r'(\d+\.?\d*)');
            Iterable<Match> matches = numberPattern.allMatches(lines[j]);
            for (Match match in matches) {
              double? value = double.tryParse(match.group(1) ?? '');
              if (value != null && value >= 1 && value <= 500) {
                altValue = value;
                break;
              }
            }
            if (altValue != null) break;
          }
          if (altValue != null) break;
        }
      }
    }

    // AST/SGOT Detection
    List<RegExp> astPatterns = [
      RegExp(r'AST\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'SGOT\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'(?:AST|SGOT)\s*.*?(\d+\.?\d*)', caseSensitive: false),
    ];

    // Try patterns
    for (RegExp pattern in astPatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null) {
        double? ast = double.tryParse(match.group(1) ?? '');
        if (ast != null && ast >= 1 && ast <= 500) {
          astValue = ast;
          break;
        }
      }
    }

    // Line analysis for AST/SGOT
    if (astValue == null) {
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].toLowerCase();
        if (line.contains('sgot') || line.contains('ast')) {
          for (int j = i; j < i + 2 && j < lines.length; j++) {
            RegExp numberPattern = RegExp(r'(\d+\.?\d*)');
            Iterable<Match> matches = numberPattern.allMatches(lines[j]);
            for (Match match in matches) {
              double? value = double.tryParse(match.group(1) ?? '');
              if (value != null &&
                  value >= 1 &&
                  value <= 500 &&
                  value != altValue) {
                astValue = value;
                break;
              }
            }
            if (astValue != null) break;
          }
          if (astValue != null) break;
        }
      }
    }

    // Store liver function values
    if (altValue != null) {
      values['alt'] = altValue;
      values['sgpt'] = altValue;
      values['alt_unit'] = 'IU/L';
      print('✅ Found ALT/SGPT: $altValue IU/L');
    }

    if (astValue != null) {
      values['ast'] = astValue;
      values['sgot'] = astValue;
      values['ast_unit'] = 'IU/L';
      print('✅ Found AST/SGOT: $astValue IU/L');
    }

    // Calculate ratios and assess liver function
    if (altValue != null && astValue != null) {
      double astAltRatio = astValue / altValue;
      double altAstRatio = altValue / astValue;

      values['ast_alt_ratio'] = astAltRatio;
      values['alt_ast_ratio'] = altAstRatio;
      values['sgot_sgpt_ratio'] = astAltRatio;

      // Liver function assessment
      String liverStatus;
      String liverLevel;
      String recommendation;

      bool altElevated = altValue > 45; // Normal range typically 7-45 IU/L
      bool astElevated = astValue > 40; // Normal range typically 8-40 IU/L

      if (altElevated || astElevated) {
        if (astAltRatio > 2.0) {
          liverStatus = 'Possible alcoholic liver disease pattern';
          liverLevel = 'High';
          recommendation = 'Alcohol history assessment, hepatology referral';
        } else if (astAltRatio > 1.0) {
          liverStatus = 'Possible viral hepatitis or drug-induced pattern';
          liverLevel = 'High';
          recommendation = 'Viral hepatitis screening, medication review';
        } else {
          liverStatus = 'Elevated liver enzymes';
          liverLevel = 'High';
          recommendation = 'Further liver function assessment needed';
        }
      } else {
        liverStatus = 'Normal liver enzyme levels';
        liverLevel = 'Normal';
        recommendation = 'Continue healthy lifestyle';
      }

      values['liver_function'] = liverStatus;
      values['liver_level'] = liverLevel;
      values['liver_recommendation'] = recommendation;
      values['liver_risk'] = (altElevated || astElevated) ? 'High' : 'Normal';

      print(
        '✅ Liver Function Analysis: $liverStatus (AST/ALT: ${astAltRatio.toStringAsFixed(2)})',
      );
    }

    // Direct ratio detection
    RegExp ratioPattern = RegExp(
      r'(?:AST/ALT|SGOT/SGPT)\s*(?:RATIO)?\s*[:\-=]?\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    Match? ratioMatch = ratioPattern.firstMatch(text);
    if (ratioMatch != null && values['ast_alt_ratio'] == null) {
      double? ratio = double.tryParse(ratioMatch.group(1) ?? '');
      if (ratio != null && ratio >= 0.1 && ratio <= 10.0) {
        values['ast_alt_ratio'] = ratio;
        values['sgot_sgpt_ratio'] = ratio;
        print('✅ Found direct AST/ALT Ratio: $ratio');
      }
    }
  }

  /// Extract protein markers
  static void _extractProteins(
    String text,
    List<String> lines,
    Map<String, dynamic> values,
  ) {
    // Total Protein Detection
    double? proteinValue;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].toLowerCase();
      if (line.contains('total') && line.contains('protein')) {
        for (int j = i; j < i + 2 && j < lines.length; j++) {
          RegExp numberPattern = RegExp(r'(\d+\.?\d*)');
          Iterable<Match> matches = numberPattern.allMatches(lines[j]);
          for (Match match in matches) {
            double? protein = double.tryParse(match.group(1) ?? '');
            if (protein != null && protein >= 3.0 && protein <= 12.0) {
              proteinValue = protein;
              break;
            }
          }
          if (proteinValue != null) break;
        }
        if (proteinValue != null) break;
      }
    }

    if (proteinValue != null) {
      values['total_protein'] = proteinValue;
      values['total_protein_unit'] = 'g/dL';

      String proteinLevel;
      String proteinStatus;
      String recommendation;

      if (proteinValue < 6.0) {
        proteinLevel = 'Low';
        proteinStatus = 'Hypoproteinemia detected';
        recommendation = 'Assess for malnutrition, kidney or liver disease';
      } else if (proteinValue <= 8.3) {
        proteinLevel = 'Normal';
        proteinStatus = 'Normal protein levels';
        recommendation = 'Continue balanced nutrition';
      } else {
        proteinLevel = 'High';
        proteinStatus = 'Hyperproteinemia detected';
        recommendation = 'Assess for dehydration, chronic inflammation';
      }

      values['protein_level'] = proteinLevel;
      values['protein_status'] = proteinStatus;
      values['protein_recommendation'] = recommendation;
      values['protein_risk'] = proteinLevel == 'Normal' ? 'Normal' : 'High';

      print('✅ Total Protein Analysis: $proteinValue g/dL - $proteinLevel');
    }

    // Albumin Detection
    RegExp albuminPattern = RegExp(
      r'albumin\s*[:\-=]?\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    Match? albuminMatch = albuminPattern.firstMatch(text);
    if (albuminMatch != null) {
      double? albumin = double.tryParse(albuminMatch.group(1) ?? '');
      if (albumin != null && albumin >= 1.0 && albumin <= 6.0) {
        values['albumin'] = albumin;
        values['albumin_unit'] = 'g/dL';

        String albuminStatus = albumin < 3.5
            ? 'Low (Hypoalbuminemia)'
            : albumin <= 5.0
            ? 'Normal'
            : 'High';
        values['albumin_status'] = albuminStatus;

        print('✅ Found Albumin: $albumin g/dL - $albuminStatus');
      }
    }
  }

  /// Extract kidney function markers
  static void _extractKidneyMarkers(String text, Map<String, dynamic> values) {
    // Creatinine Detection
    RegExp creatininePattern = RegExp(
      r'creatinine\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|μmol/l|umol/l)?',
      caseSensitive: false,
    );
    Match? creatinineMatch = creatininePattern.firstMatch(text);
    if (creatinineMatch != null) {
      double? creatinine = double.tryParse(creatinineMatch.group(1) ?? '');
      String unit = creatinineMatch.group(2)?.toLowerCase() ?? 'mg/dl';

      if (creatinine != null) {
        bool validRange = false;
        if (unit.contains('mg/dl') && creatinine >= 0.5 && creatinine <= 5.0) {
          validRange = true;
        } else if ((unit.contains('μmol/l') || unit.contains('umol/l')) &&
            creatinine >= 44 &&
            creatinine <= 442) {
          validRange = true;
        }

        if (validRange) {
          values['creatinine'] = creatinine;
          values['creatinine_unit'] = unit;

          String creatinineStatus;
          if (unit.contains('mg/dl')) {
            creatinineStatus = creatinine <= 1.2 ? 'Normal' : 'Elevated';
          } else {
            creatinineStatus = creatinine <= 106 ? 'Normal' : 'Elevated';
          }
          values['creatinine_status'] = creatinineStatus;

          print('✅ Found Creatinine: $creatinine $unit - $creatinineStatus');
        }
      }
    }

    // Blood Urea Nitrogen (BUN)
    RegExp bunPattern = RegExp(
      r'(?:BUN|urea)\s*[:\-=]?\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    Match? bunMatch = bunPattern.firstMatch(text);
    if (bunMatch != null) {
      double? bun = double.tryParse(bunMatch.group(1) ?? '');
      if (bun != null && bun >= 5 && bun <= 100) {
        values['bun'] = bun;
        values['bun_unit'] = 'mg/dL';
        values['bun_status'] = bun <= 25 ? 'Normal' : 'Elevated';
        print('✅ Found BUN: $bun mg/dL');
      }
    }
  }

  /// Extract glucose values
  static void _extractGlucose(String text, Map<String, dynamic> values) {
    List<RegExp> glucosePatterns = [
      RegExp(
        r'glucose\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
        caseSensitive: false,
      ),
      RegExp(r'blood\s+sugar\s*[:\-=]?\s*(\d+\.?\d*)', caseSensitive: false),
      RegExp(
        r'fasting\s+glucose\s*[:\-=]?\s*(\d+\.?\d*)',
        caseSensitive: false,
      ),
    ];

    for (RegExp pattern in glucosePatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null) {
        double? glucose = double.tryParse(match.group(1) ?? '');
        String unit = match.group(2)?.toLowerCase() ?? 'mg/dl';

        if (glucose != null) {
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

            String glucoseStatus;
            String recommendation;
            if (unit.contains('mg/dl')) {
              if (glucose < 100) {
                glucoseStatus = 'Normal';
                recommendation = 'Continue healthy lifestyle';
              } else if (glucose < 126) {
                glucoseStatus = 'Prediabetes range';
                recommendation = 'Lifestyle modification recommended';
              } else {
                glucoseStatus = 'Diabetes range';
                recommendation = 'Medical evaluation required';
              }
            } else {
              // mmol/L conversion
              if (glucose < 5.6) {
                glucoseStatus = 'Normal';
                recommendation = 'Continue healthy lifestyle';
              } else if (glucose < 7.0) {
                glucoseStatus = 'Prediabetes range';
                recommendation = 'Lifestyle modification recommended';
              } else {
                glucoseStatus = 'Diabetes range';
                recommendation = 'Medical evaluation required';
              }
            }

            values['glucose_status'] = glucoseStatus;
            values['glucose_recommendation'] = recommendation;
            values['glucose_risk'] = glucoseStatus == 'Normal'
                ? 'Normal'
                : 'High';

            print('✅ Found Glucose: $glucose $unit - $glucoseStatus');
            break;
          }
        }
      }
    }
  }

  /// Extract blood pressure values
  static void _extractBloodPressure(String text, Map<String, dynamic> values) {
    List<RegExp> bpPatterns = [
      RegExp(r'(\d{2,3})\s*/\s*(\d{2,3})\s*mmHg?', caseSensitive: false),
      RegExp(
        r'blood\s+pressure\s*[:\-=]?\s*(\d{2,3})\s*/\s*(\d{2,3})',
        caseSensitive: false,
      ),
      RegExp(r'BP\s*[:\-=]?\s*(\d{2,3})\s*/\s*(\d{2,3})', caseSensitive: false),
    ];

    for (RegExp pattern in bpPatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null) {
        int? systolic = int.tryParse(match.group(1) ?? '');
        int? diastolic = int.tryParse(match.group(2) ?? '');

        if (systolic != null &&
            diastolic != null &&
            systolic >= 80 &&
            systolic <= 250 &&
            diastolic >= 40 &&
            diastolic <= 150) {
          values['systolic_bp'] = systolic;
          values['diastolic_bp'] = diastolic;
          values['bp_unit'] = 'mmHg';

          // AHA/ACC Blood Pressure Classification
          String bpCategory;
          String recommendation;
          String riskLevel;

          if (systolic < 120 && diastolic < 80) {
            bpCategory = 'Normal';
            recommendation = 'Maintain healthy lifestyle';
            riskLevel = 'Normal';
          } else if (systolic < 130 && diastolic < 80) {
            bpCategory = 'Elevated';
            recommendation = 'Lifestyle modifications recommended';
            riskLevel = 'Medium';
          } else if ((systolic >= 130 && systolic <= 139) ||
              (diastolic >= 80 && diastolic <= 89)) {
            bpCategory = 'Stage 1 Hypertension';
            recommendation = 'Lifestyle changes and possible medication';
            riskLevel = 'High';
          } else if ((systolic >= 140 && systolic <= 179) ||
              (diastolic >= 90 && diastolic <= 119)) {
            bpCategory = 'Stage 2 Hypertension';
            recommendation = 'Lifestyle changes and medication required';
            riskLevel = 'High';
          } else if (systolic >= 180 || diastolic >= 120) {
            bpCategory = 'Hypertensive Crisis';
            recommendation = 'Immediate medical attention required';
            riskLevel = 'Critical';
          } else {
            bpCategory = 'Unclassified';
            recommendation = 'Medical evaluation recommended';
            riskLevel = 'Medium';
          }

          values['bp_category'] = bpCategory;
          values['bp_recommendation'] = recommendation;
          values['hypertension_risk'] = riskLevel;

          print(
            '✅ Found Blood Pressure: $systolic/$diastolic mmHg - $bpCategory',
          );
          break;
        }
      }
    }
  }

  /// Extract lipid profile values
  static void _extractLipidProfile(String text, Map<String, dynamic> values) {
    // Total Cholesterol
    RegExp cholesterolPattern = RegExp(
      r'(?:total\s+)?cholesterol\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? cholesterolMatch = cholesterolPattern.firstMatch(text);
    if (cholesterolMatch != null) {
      double? cholesterol = double.tryParse(cholesterolMatch.group(1) ?? '');
      String unit = cholesterolMatch.group(2)?.toLowerCase() ?? 'mg/dl';

      if (cholesterol != null && cholesterol >= 100 && cholesterol <= 400) {
        values['cholesterol'] = cholesterol;
        values['cholesterol_unit'] = unit;

        String cholesterolStatus;
        if (cholesterol < 200) {
          cholesterolStatus = 'Desirable';
        } else if (cholesterol <= 239) {
          cholesterolStatus = 'Borderline High';
        } else {
          cholesterolStatus = 'High';
        }
        values['cholesterol_status'] = cholesterolStatus;

        print(
          '✅ Found Total Cholesterol: $cholesterol $unit - $cholesterolStatus',
        );
      }
    }

    // HDL Cholesterol
    RegExp hdlPattern = RegExp(
      r'HDL\s*(?:cholesterol)?\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? hdlMatch = hdlPattern.firstMatch(text);
    if (hdlMatch != null) {
      double? hdl = double.tryParse(hdlMatch.group(1) ?? '');
      String unit = hdlMatch.group(2)?.toLowerCase() ?? 'mg/dl';

      if (hdl != null && hdl >= 20 && hdl <= 100) {
        values['hdl'] = hdl;
        values['hdl_unit'] = unit;

        String hdlStatus = hdl >= 40
            ? (hdl >= 60 ? 'High (Protective)' : 'Normal')
            : 'Low';
        values['hdl_status'] = hdlStatus;

        print('✅ Found HDL: $hdl $unit - $hdlStatus');
      }
    }

    // LDL Cholesterol
    RegExp ldlPattern = RegExp(
      r'LDL\s*(?:cholesterol)?\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? ldlMatch = ldlPattern.firstMatch(text);
    if (ldlMatch != null) {
      double? ldl = double.tryParse(ldlMatch.group(1) ?? '');
      String unit = ldlMatch.group(2)?.toLowerCase() ?? 'mg/dl';

      if (ldl != null && ldl >= 50 && ldl <= 300) {
        values['ldl'] = ldl;
        values['ldl_unit'] = unit;

        String ldlStatus;
        if (ldl < 100) {
          ldlStatus = 'Optimal';
        } else if (ldl <= 129) {
          ldlStatus = 'Near Optimal';
        } else if (ldl <= 159) {
          ldlStatus = 'Borderline High';
        } else if (ldl <= 189) {
          ldlStatus = 'High';
        } else {
          ldlStatus = 'Very High';
        }
        values['ldl_status'] = ldlStatus;

        print('✅ Found LDL: $ldl $unit - $ldlStatus');
      }
    }

    // Triglycerides
    RegExp triglyceridesPattern = RegExp(
      r'triglycerides?\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl|mmol/l)?',
      caseSensitive: false,
    );
    Match? triglyceridesMatch = triglyceridesPattern.firstMatch(text);
    if (triglyceridesMatch != null) {
      double? triglycerides = double.tryParse(
        triglyceridesMatch.group(1) ?? '',
      );
      String unit = triglyceridesMatch.group(2)?.toLowerCase() ?? 'mg/dl';

      if (triglycerides != null &&
          triglycerides >= 50 &&
          triglycerides <= 1000) {
        values['triglycerides'] = triglycerides;
        values['triglycerides_unit'] = unit;

        String triglyceridesStatus;
        if (triglycerides < 150) {
          triglyceridesStatus = 'Normal';
        } else if (triglycerides <= 199) {
          triglyceridesStatus = 'Borderline High';
        } else if (triglycerides <= 499) {
          triglyceridesStatus = 'High';
        } else {
          triglyceridesStatus = 'Very High';
        }
        values['triglycerides_status'] = triglyceridesStatus;

        print(
          '✅ Found Triglycerides: $triglycerides $unit - $triglyceridesStatus',
        );
      }
    }
  }

  /// Extract additional markers
  static void _extractAdditionalMarkers(
    String text,
    List<String> lines,
    Map<String, dynamic> values,
  ) {
    // Bilirubin (Total)
    RegExp bilirubinPattern = RegExp(
      r'(?:total\s+)?bilirubin\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl)?',
      caseSensitive: false,
    );
    Match? bilirubinMatch = bilirubinPattern.firstMatch(text);
    if (bilirubinMatch != null) {
      double? bilirubin = double.tryParse(bilirubinMatch.group(1) ?? '');
      if (bilirubin != null && bilirubin >= 0.0 && bilirubin <= 10.0) {
        values['bilirubin_total'] = bilirubin;
        values['bilirubin_unit'] = 'mg/dL';
        values['bilirubin_status'] = bilirubin <= 1.2 ? 'Normal' : 'Elevated';
        print('✅ Found Total Bilirubin: $bilirubin mg/dL');
      }
    }

    // Alkaline Phosphatase (ALP)
    RegExp alpPattern = RegExp(
      r'(?:alkaline\s+phosphatase|ALP)\s*[:\-=]?\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    Match? alpMatch = alpPattern.firstMatch(text);
    if (alpMatch != null) {
      double? alp = double.tryParse(alpMatch.group(1) ?? '');
      if (alp != null && alp >= 20 && alp <= 500) {
        values['alp'] = alp;
        values['alp_unit'] = 'IU/L';
        values['alp_status'] = alp <= 147 ? 'Normal' : 'Elevated';
        print('✅ Found ALP: $alp IU/L');
      }
    }

    // Uric Acid
    RegExp uricAcidPattern = RegExp(
      r'uric\s+acid\s*[:\-=]?\s*(\d+\.?\d*)\s*(mg/dl)?',
      caseSensitive: false,
    );
    Match? uricAcidMatch = uricAcidPattern.firstMatch(text);
    if (uricAcidMatch != null) {
      double? uricAcid = double.tryParse(uricAcidMatch.group(1) ?? '');
      if (uricAcid != null && uricAcid >= 1.0 && uricAcid <= 15.0) {
        values['uric_acid'] = uricAcid;
        values['uric_acid_unit'] = 'mg/dL';
        values['uric_acid_status'] = uricAcid <= 7.0 ? 'Normal' : 'Elevated';
        print('✅ Found Uric Acid: $uricAcid mg/dL');
      }
    }

    // Hemoglobin
    RegExp hbPattern = RegExp(
      r'(?:hemoglobin|Hb)\s*[:\-=]?\s*(\d+\.?\d*)\s*(g/dl)?',
      caseSensitive: false,
    );
    Match? hbMatch = hbPattern.firstMatch(text);
    if (hbMatch != null) {
      double? hb = double.tryParse(hbMatch.group(1) ?? '');
      if (hb != null && hb >= 5.0 && hb <= 20.0) {
        values['hemoglobin'] = hb;
        values['hemoglobin_unit'] = 'g/dL';
        String hbStatus;
        if (hb < 12.0) {
          hbStatus = 'Low (Anemia)';
        } else if (hb <= 17.5) {
          hbStatus = 'Normal';
        } else {
          hbStatus = 'High (Polycythemia)';
        }
        values['hemoglobin_status'] = hbStatus;
        print('✅ Found Hemoglobin: $hb g/dL - $hbStatus');
      }
    }

    // White Blood Cell Count
    RegExp wbcPattern = RegExp(
      r'(?:WBC|white\s+blood\s+cell)\s*[:\-=]?\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    Match? wbcMatch = wbcPattern.firstMatch(text);
    if (wbcMatch != null) {
      double? wbc = double.tryParse(wbcMatch.group(1) ?? '');
      if (wbc != null && wbc >= 1.0 && wbc <= 50.0) {
        values['wbc'] = wbc;
        values['wbc_unit'] = '×10³/μL';
        String wbcStatus;
        if (wbc < 4.0) {
          wbcStatus = 'Low (Leukopenia)';
        } else if (wbc <= 11.0) {
          wbcStatus = 'Normal';
        } else {
          wbcStatus = 'High (Leukocytosis)';
        }
        values['wbc_status'] = wbcStatus;
        print('✅ Found WBC: $wbc ×10³/μL - $wbcStatus');
      }
    }

    // Platelet Count
    RegExp plateletPattern = RegExp(
      r'(?:platelet|PLT)\s*[:\-=]?\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    Match? plateletMatch = plateletPattern.firstMatch(text);
    if (plateletMatch != null) {
      double? platelets = double.tryParse(plateletMatch.group(1) ?? '');
      if (platelets != null && platelets >= 50 && platelets <= 1000) {
        values['platelets'] = platelets;
        values['platelets_unit'] = '×10³/μL';
        String plateletStatus;
        if (platelets < 150) {
          plateletStatus = 'Low (Thrombocytopenia)';
        } else if (platelets <= 450) {
          plateletStatus = 'Normal';
        } else {
          plateletStatus = 'High (Thrombocytosis)';
        }
        values['platelets_status'] = plateletStatus;
        print('✅ Found Platelets: $platelets ×10³/μL - $plateletStatus');
      }
    }
  }

  /// Generate comprehensive health insights from extracted values
  static String getHealthInsight(
    Map<String, dynamic> values,
    bool hasDiabetes,
    bool hasHypertension,
    bool hasCKD,
    bool hasLiverDisease,
  ) {
    List<String> insights = [];

    // HbA1c Analysis
    if (values['hba1c'] != null) {
      double hba1c = values['hba1c'];
      String stage = values['diabetes_stage'] ?? '';
      String recommendation = values['diabetes_recommendation'] ?? '';

      if (hba1c < 5.7) {
        insights.add(
          "✅ **Diabetes Control**: HbA1c is $hba1c% ($stage). $recommendation",
        );
      } else if (hba1c < 6.5) {
        insights.add(
          "⚠️ **Prediabetes Alert**: HbA1c is $hba1c% ($stage). $recommendation",
        );
      } else {
        insights.add(
          "🚨 **Diabetes Management**: HbA1c is $hba1c% ($stage). $recommendation",
        );
      }
    }

    // Kidney Function Analysis
    if (values['egfr'] != null) {
      double egfr = values['egfr'];
      String stage = values['ckd_stage'] ?? '';
      String recommendation = values['kidney_recommendation'] ?? '';

      if (egfr >= 90) {
        insights.add(
          "✅ **Kidney Health**: eGFR ${egfr.toStringAsFixed(0)} mL/min/1.73m² ($stage). $recommendation",
        );
      } else if (egfr >= 60) {
        insights.add(
          "⚠️ **Kidney Function**: eGFR ${egfr.toStringAsFixed(0)} mL/min/1.73m² ($stage). $recommendation",
        );
      } else {
        insights.add(
          "🚨 **Kidney Concern**: eGFR ${egfr.toStringAsFixed(0)} mL/min/1.73m² ($stage). $recommendation",
        );
      }
    }

    // Liver Function Analysis
    if (values['alt'] != null || values['ast'] != null) {
      String liverStatus = values['liver_function'] ?? 'Liver enzymes detected';
      String recommendation =
          values['liver_recommendation'] ?? 'Monitor liver function';

      if (values['liver_level'] == 'Normal') {
        insights.add("✅ **Liver Health**: $liverStatus. $recommendation");
      } else {
        insights.add("⚠️ **Liver Function**: $liverStatus. $recommendation");

        if (values['ast_alt_ratio'] != null) {
          double ratio = values['ast_alt_ratio'];
          insights.add("   📊 AST/ALT ratio: ${ratio.toStringAsFixed(2)}");
        }
      }
    }

    // Blood Pressure Analysis
    if (values['systolic_bp'] != null && values['diastolic_bp'] != null) {
      int systolic = values['systolic_bp'];
      int diastolic = values['diastolic_bp'];
      String category = values['bp_category'] ?? '';
      String recommendation = values['bp_recommendation'] ?? '';

      if (category == 'Normal') {
        insights.add(
          "✅ **Blood Pressure**: $systolic/$diastolic mmHg ($category). $recommendation",
        );
      } else if (category == 'Elevated') {
        insights.add(
          "⚠️ **Blood Pressure**: $systolic/$diastolic mmHg ($category). $recommendation",
        );
      } else {
        insights.add(
          "🚨 **Hypertension**: $systolic/$diastolic mmHg ($category). $recommendation",
        );
      }
    }

    // Glucose Analysis
    if (values['glucose'] != null) {
      double glucose = values['glucose'];
      String unit = values['glucose_unit'] ?? 'mg/dL';
      String status = values['glucose_status'] ?? '';
      String recommendation = values['glucose_recommendation'] ?? '';

      if (status.contains('Normal')) {
        insights.add(
          "✅ **Blood Glucose**: $glucose $unit ($status). $recommendation",
        );
      } else {
        insights.add(
          "⚠️ **Blood Glucose**: $glucose $unit ($status). $recommendation",
        );
      }
    }

    // Lipid Profile Analysis
    if (values['cholesterol'] != null) {
      double cholesterol = values['cholesterol'];
      String status = values['cholesterol_status'] ?? '';
      String unit = values['cholesterol_unit'] ?? 'mg/dL';

      if (status == 'Desirable') {
        insights.add("✅ **Cholesterol**: Total $cholesterol $unit ($status)");
      } else {
        insights.add("⚠️ **Cholesterol**: Total $cholesterol $unit ($status)");
      }
    }

    // Protein Analysis
    if (values['total_protein'] != null) {
      double protein = values['total_protein'];
      String status = values['protein_status'] ?? '';
      String recommendation = values['protein_recommendation'] ?? '';

      if (values['protein_level'] == 'Normal') {
        insights.add(
          "✅ **Protein Levels**: $protein g/dL ($status). $recommendation",
        );
      } else {
        insights.add(
          "⚠️ **Protein Levels**: $protein g/dL ($status). $recommendation",
        );
      }
    }

    // Risk Assessment for Existing Conditions
    if (hasDiabetes && values['hba1c'] != null && values['hba1c'] > 7.0) {
      insights.add(
        "🔄 **Diabetes Management**: Current HbA1c suggests treatment optimization may be needed. Consult your healthcare provider.",
      );
    }

    if (hasHypertension &&
        values['systolic_bp'] != null &&
        values['systolic_bp'] > 140) {
      insights.add(
        "🔄 **Hypertension Management**: Blood pressure control may need adjustment. Monitor regularly.",
      );
    }

    if (hasCKD && values['egfr'] != null && values['egfr'] < 60) {
      insights.add(
        "🔄 **CKD Management**: Kidney function monitoring is crucial. Regular nephrology follow-up recommended.",
      );
    }

    if (hasLiverDisease && values['liver_level'] == 'High') {
      insights.add(
        "🔄 **Liver Disease Management**: Elevated enzymes require close monitoring and specialist care.",
      );
    }

    // Additional Health Insights
    if (values['hemoglobin'] != null) {
      String hbStatus = values['hemoglobin_status'] ?? '';
      if (hbStatus.contains('Anemia')) {
        insights.add(
          "⚠️ **Blood Health**: ${values['hemoglobin']} g/dL indicates anemia. Iron studies and further evaluation recommended.",
        );
      }
    }

    if (values['uric_acid'] != null &&
        values['uric_acid_status'] == 'Elevated') {
      insights.add(
        "⚠️ **Uric Acid**: Elevated at ${values['uric_acid']} mg/dL. Monitor for gout risk and kidney function.",
      );
    }

    // General Recommendations
    insights.add("\n📋 **General Recommendations**:");
    insights.add("• Regular follow-up with your healthcare provider");
    insights.add("• Maintain a balanced diet and regular exercise");
    insights.add("• Monitor your vital signs and symptoms");
    insights.add("• Take medications as prescribed");
    insights.add("• Stay hydrated and get adequate sleep");

    if (insights.isEmpty) {
      insights.add(
        "ℹ️ **Analysis Complete**: No specific health parameters requiring immediate attention were detected in this report.",
      );
      insights.add(
        "Continue regular health monitoring and consult your healthcare provider for routine check-ups.",
      );
    }

    return insights.join('\n\n');
  }

  /// Assess condition risks from OCR data with comprehensive analysis
  static Map<String, bool> assessConditionRisks(Map<String, dynamic> values) {
    Map<String, bool> risks = {
      'diabetesRisk': false,
      'hypertensionRisk': false,
      'ckdRisk': false,
      'liverDiseaseRisk': false,
      'anemiaRisk': false,
      'hyperlipidemia Risk': false,
    };

    // Diabetes Risk Assessment
    if (values['hba1c'] != null && values['hba1c'] > 6.5) {
      risks['diabetesRisk'] = true;
    }
    if (values['glucose'] != null) {
      double glucose = values['glucose'];
      String unit = values['glucose_unit'] ?? 'mg/dl';
      if (unit.contains('mg/dl') && glucose > 126) {
        risks['diabetesRisk'] = true;
      } else if (unit.contains('mmol/l') && glucose > 7.0) {
        risks['diabetesRisk'] = true;
      }
    }

    // Hypertension Risk Assessment
    if (values['systolic_bp'] != null && values['diastolic_bp'] != null) {
      if (values['systolic_bp'] > 130 || values['diastolic_bp'] > 80) {
        risks['hypertensionRisk'] = true;
      }
    }

    // CKD Risk Assessment
    if (values['egfr'] != null && values['egfr'] < 90) {
      risks['ckdRisk'] = true;
    }
    if (values['creatinine'] != null &&
        values['creatinine_status'] == 'Elevated') {
      risks['ckdRisk'] = true;
    }

    // Liver Disease Risk Assessment
    if (values['liver_level'] == 'High') {
      risks['liverDiseaseRisk'] = true;
    }
    if (values['ast_alt_ratio'] != null && values['ast_alt_ratio'] > 2.0) {
      risks['liverDiseaseRisk'] = true;
    }

    // Anemia Risk Assessment
    if (values['hemoglobin'] != null && values['hemoglobin'] < 12.0) {
      risks['anemiaRisk'] = true;
    }

    // Hyperlipidemia Risk Assessment
    if (values['cholesterol'] != null && values['cholesterol'] > 240) {
      risks['hyperlipidemiaRisk'] = true;
    }
    if (values['ldl'] != null && values['ldl'] > 160) {
      risks['hyperlipidemiaRisk'] = true;
    }

    return risks;
  }

  /// Get detailed parameter summary
  static Map<String, dynamic> getParameterSummary(Map<String, dynamic> values) {
    Map<String, dynamic> summary = {
      'totalParameters': values.length,
      'normalParameters': 0,
      'abnormalParameters': 0,
      'criticalParameters': 0,
      'parametersByCategory': {
        'diabetes': [],
        'kidney': [],
        'liver': [],
        'cardiovascular': [],
        'lipids': [],
        'blood': [],
        'other': [],
      },
    };

    // Categorize parameters
    values.forEach((key, value) {
      if (key.contains('hba1c') ||
          key.contains('glucose') ||
          key.contains('diabetes')) {
        summary['parametersByCategory']['diabetes'].add(key);
      } else if (key.contains('egfr') ||
          key.contains('creatinine') ||
          key.contains('kidney') ||
          key.contains('bun')) {
        summary['parametersByCategory']['kidney'].add(key);
      } else if (key.contains('alt') ||
          key.contains('ast') ||
          key.contains('sgpt') ||
          key.contains('sgot') ||
          key.contains('liver') ||
          key.contains('bilirubin') ||
          key.contains('alp')) {
        summary['parametersByCategory']['liver'].add(key);
      } else if (key.contains('bp') ||
          key.contains('pressure') ||
          key.contains('systolic') ||
          key.contains('diastolic')) {
        summary['parametersByCategory']['cardiovascular'].add(key);
      } else if (key.contains('cholesterol') ||
          key.contains('hdl') ||
          key.contains('ldl') ||
          key.contains('triglycerides')) {
        summary['parametersByCategory']['lipids'].add(key);
      } else if (key.contains('hemoglobin') ||
          key.contains('wbc') ||
          key.contains('platelet')) {
        summary['parametersByCategory']['blood'].add(key);
      } else if (!key.contains('_unit') &&
          !key.contains('_status') &&
          !key.contains('_recommendation') &&
          !key.contains('_category') &&
          !key.contains('_level') &&
          !key.contains('_risk') &&
          !key.contains('_stage')) {
        summary['parametersByCategory']['other'].add(key);
      }
    });

    return summary;
  }

  /// Clean up resources
  static void dispose() {
    _textRecognizer.close();
  }
}
