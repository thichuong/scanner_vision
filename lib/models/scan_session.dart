import 'cccd_model.dart';

class ScanSession {
  final String id;
  final DateTime date;
  final List<String> imagePaths;
  final String type; // 'document' or 'cccd'
  final CCCDModel? cccdData;

  ScanSession({
    required this.id,
    required this.date,
    required this.imagePaths,
    required this.type,
    this.cccdData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'imagePaths': imagePaths,
      'type': type,
      'cccdData': cccdData?.toJson(),
    };
  }

  factory ScanSession.fromJson(Map<String, dynamic> json) {
    return ScanSession(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      imagePaths: (json['imagePaths'] as List<dynamic>?)?.cast<String>() ?? [],
      type: json['type'] as String? ?? 'document',
      cccdData: json['cccdData'] != null ? CCCDModel.fromJson(json['cccdData']) : null,
    );
  }
}
