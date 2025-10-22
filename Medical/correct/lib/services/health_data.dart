class HealthData {
  final String id;
  final double heartRate;
  final DateTime timestamp;
  final String source; // 'esp32' or 'manual'

  HealthData({
    required this.id,
    required this.heartRate,
    required this.timestamp,
    required this.source,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
    };
  }

  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      id: map['id'] ?? '',
      heartRate: (map['heartRate'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      source: map['source'] ?? 'manual',
    );
  }
}

class ReportData {
  final String id;
  final String fileName;
  final String fileUrl;
  final Map<String, dynamic> ocrResults;
  final DateTime uploadDate;
  final Map<String, dynamic> extractedValues;
  final String? rawText;
  final Map<String, dynamic> conditionRisks;
  final String? healthInsight;
  final double? confidence;

  // Legacy fields for backward compatibility
  final double? hba1c;
  final double? glucose;
  final double? cholesterol;

  ReportData({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.ocrResults,
    required this.uploadDate,
    required this.extractedValues,
    this.rawText,
    required this.conditionRisks,
    this.healthInsight,
    this.confidence,
    // Legacy fields
    this.hba1c,
    this.glucose,
    this.cholesterol,
  });

  // Convenience getters for specific health parameters
  double? get hba1cValue => extractedValues['hba1c']?.toDouble() ?? hba1c;
  double? get glucoseValue => extractedValues['glucose']?.toDouble() ?? glucose;
  double? get cholesterolValue =>
      extractedValues['cholesterol']?.toDouble() ?? cholesterol;
  double? get egfrValue => extractedValues['egfr']?.toDouble();
  double? get altAstRatio => extractedValues['alt_ast_ratio']?.toDouble();
  int? get systolicBp => extractedValues['systolic_bp']?.toInt();
  int? get diastolicBp => extractedValues['diastolic_bp']?.toInt();
  double? get creatinine => extractedValues['creatinine']?.toDouble();
  double? get hdl => extractedValues['hdl']?.toDouble();
  double? get ldl => extractedValues['ldl']?.toDouble();

  // Risk assessment getters
  bool get hasDiabetesRisk => conditionRisks['diabetesRisk'] == true;
  bool get hasHypertensionRisk => conditionRisks['hypertensionRisk'] == true;
  bool get hasCkdRisk => conditionRisks['ckdRisk'] == true;
  bool get hasLiverDiseaseRisk => conditionRisks['liverDiseaseRisk'] == true;

  // Get detected parameters count
  int get detectedParametersCount {
    return extractedValues.entries
        .where(
          (entry) =>
              !entry.key.endsWith('_unit') &&
              !entry.key.endsWith('_risk') &&
              entry.value != null,
        )
        .length;
  }

  // Get parameter summary
  List<String> get detectedParametersList {
    return extractedValues.entries
        .where(
          (entry) =>
              !entry.key.endsWith('_unit') &&
              !entry.key.endsWith('_risk') &&
              entry.value != null,
        )
        .map((entry) => entry.key.toUpperCase())
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'ocrResults': ocrResults,
      'uploadDate': uploadDate.toIso8601String(),
      'extractedValues': extractedValues,
      'rawText': rawText,
      'conditionRisks': conditionRisks,
      'healthInsight': healthInsight,
      'confidence': confidence,
      // Legacy fields for backward compatibility
      'hba1c': hba1c,
      'glucose': glucose,
      'cholesterol': cholesterol,
    };
  }

  factory ReportData.fromMap(Map<String, dynamic> map) {
    return ReportData(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      ocrResults: Map<String, dynamic>.from(map['ocrResults'] ?? {}),
      uploadDate: DateTime.parse(
        map['uploadDate'] ?? DateTime.now().toIso8601String(),
      ),
      extractedValues: Map<String, dynamic>.from(map['extractedValues'] ?? {}),
      rawText: map['rawText'],
      conditionRisks: Map<String, dynamic>.from(map['conditionRisks'] ?? {}),
      healthInsight: map['healthInsight'],
      confidence: map['confidence']?.toDouble(),
      // Legacy fields
      hba1c: map['hba1c']?.toDouble(),
      glucose: map['glucose']?.toDouble(),
      cholesterol: map['cholesterol']?.toDouble(),
    );
  }
}

// New model for health parameter tracking
class HealthParameter {
  final String id;
  final String reportId;
  final String parameterId;
  final String parameterName;
  final dynamic value;
  final String? unit;
  final String? riskLevel;
  final DateTime recordDate;
  final DateTime createdAt;

  HealthParameter({
    required this.id,
    required this.reportId,
    required this.parameterId,
    required this.parameterName,
    required this.value,
    this.unit,
    this.riskLevel,
    required this.recordDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportId': reportId,
      'parameterId': parameterId,
      'parameterName': parameterName,
      'value': value,
      'unit': unit,
      'riskLevel': riskLevel,
      'recordDate': recordDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HealthParameter.fromMap(Map<String, dynamic> map) {
    return HealthParameter(
      id: map['id'] ?? '',
      reportId: map['reportId'] ?? '',
      parameterId: map['parameterId'] ?? '',
      parameterName: map['parameterName'] ?? '',
      value: map['value'],
      unit: map['unit'],
      riskLevel: map['riskLevel'],
      recordDate: DateTime.parse(
        map['recordDate'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
