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
  final double? hba1c;
  final double? glucose;
  final double? cholesterol;
  final Map<String, dynamic> extractedValues;

  ReportData({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.ocrResults,
    required this.uploadDate,
    this.hba1c,
    this.glucose,
    this.cholesterol,
    required this.extractedValues,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'ocrResults': ocrResults,
      'uploadDate': uploadDate.toIso8601String(),
      'hba1c': hba1c,
      'glucose': glucose,
      'cholesterol': cholesterol,
      'extractedValues': extractedValues,
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
      hba1c: map['hba1c']?.toDouble(),
      glucose: map['glucose']?.toDouble(),
      cholesterol: map['cholesterol']?.toDouble(),
      extractedValues: Map<String, dynamic>.from(map['extractedValues'] ?? {}),
    );
  }
}
