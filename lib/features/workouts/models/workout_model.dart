import 'exercise_model.dart';

class WorkoutModel {
  final int id;
  final int traineeId;
  final int trainerId;
  final String title;
  final String? description;
  final DateTime? scheduledDate;
  final bool completed;

  final String? traineeName;
  final String? trainerName;
  final List<ExerciseModel> exercises;

  const WorkoutModel({
    required this.id,
    required this.traineeId,
    required this.trainerId,
    required this.title,
    this.description,
    this.scheduledDate,
    required this.completed,
    this.traineeName,
    this.trainerName,
    this.exercises = const [],
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) return v == '1' || v.toLowerCase() == 'true';
      return false;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    String? nestedName(dynamic parent) {
      if (parent is Map) {
        final m = Map<String, dynamic>.from(parent);
        if (m['name'] != null) return m['name'].toString();
      }
      return null;
    }

    final exercisesJson = (json['exercises'] as List?)?.whereType<Map>().map((e) {
          return ExerciseModel.fromJson(Map<String, dynamic>.from(e));
        }).toList() ??
        const <ExerciseModel>[];

    return WorkoutModel(
      id: parseInt(json['id']),
      traineeId: parseInt(json['trainee_id']),
      trainerId: parseInt(json['trainer_id']),
      title: (json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      scheduledDate: parseDate(json['scheduled_date']),
      completed: parseBool(json['completed']),
      traineeName: nestedName(json['trainee']),
      trainerName: nestedName(json['trainer']),
      exercises: exercisesJson,
    );
  }
}
