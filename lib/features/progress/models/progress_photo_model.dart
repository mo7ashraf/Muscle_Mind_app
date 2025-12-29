import '../../../core/constants/app_constants.dart';

class ProgressPhotoModel {
  final int id;
  final int traineeId;
  final String? frontImage;
  final String? backImage;
  final String? sideImage;
  final double? weight;
  final String? notes;
  final DateTime takenAt;

  const ProgressPhotoModel({
    required this.id,
    required this.traineeId,
    required this.frontImage,
    required this.backImage,
    required this.sideImage,
    required this.weight,
    required this.notes,
    required this.takenAt,
  });

  String? toPublicUrl(String? storagePath) {
    if (storagePath == null || storagePath.isEmpty) return null;
    return '${AppConstants.storageBaseUrl}/$storagePath';
  }

  String? get frontUrl => toPublicUrl(frontImage);
  String? get backUrl => toPublicUrl(backImage);
  String? get sideUrl => toPublicUrl(sideImage);

  factory ProgressPhotoModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return ProgressPhotoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      traineeId: (json['trainee_id'] as num?)?.toInt() ?? 0,
      frontImage: json['front_image'] as String?,
      backImage: json['back_image'] as String?,
      sideImage: json['side_image'] as String?,
      weight: parseDouble(json['weight']),
      notes: json['notes'] as String?,
      takenAt: parseDate(json['taken_at']),
    );
  }
}
