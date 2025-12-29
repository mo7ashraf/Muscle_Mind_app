class ExerciseModel {
  final int id;
  final int workoutId;
  final String name;
  final int? sets;
  final int? reps;
  final int? restTime; // seconds
  final String? notes;
  final String? videoUrl;

  const ExerciseModel({
    required this.id,
    required this.workoutId,
    required this.name,
    this.sets,
    this.reps,
    this.restTime,
    this.notes,
    this.videoUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    int? parseNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return ExerciseModel(
      id: parseInt(json['id']),
      workoutId: parseInt(json['workout_id']),
      name: (json['name'] ?? '').toString(),
      sets: parseNullableInt(json['sets']),
      reps: parseNullableInt(json['reps']),
      restTime: parseNullableInt(json['rest_time']),
      notes: json['notes']?.toString(),
      videoUrl: json['video_url']?.toString(),
    );
  }
}
