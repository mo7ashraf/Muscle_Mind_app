class MeasurementModel {
  final int id;
  final int traineeId;
  final double? weight;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? arms;
  final double? thighs;
  final DateTime measuredAt;

  const MeasurementModel({
    required this.id,
    required this.traineeId,
    required this.weight,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.arms,
    required this.thighs,
    required this.measuredAt,
  });

  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
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

    return MeasurementModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      traineeId: (json['trainee_id'] as num?)?.toInt() ?? 0,
      weight: parseDouble(json['weight']),
      chest: parseDouble(json['chest']),
      waist: parseDouble(json['waist']),
      hips: parseDouble(json['hips']),
      arms: parseDouble(json['arms']),
      thighs: parseDouble(json['thighs']),
      measuredAt: parseDate(json['measured_at']),
    );
  }
}
