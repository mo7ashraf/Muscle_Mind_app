import 'meal_model.dart';

class DietPlanModel {
  final int id;
  final int traineeId;
  final int trainerId;
  final String title;
  final String? description;
  final int? caloriesTarget;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  final String? traineeName;
  final String? trainerName;
  final List<MealModel> meals;

  const DietPlanModel({
    required this.id,
    required this.traineeId,
    required this.trainerId,
    required this.title,
    required this.description,
    required this.caloriesTarget,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.traineeName,
    required this.trainerName,
    required this.meals,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? getNestedName(Map<String, dynamic>? parent) {
      if (parent == null) return null;
      final user = parent['user'];
      if (user is Map<String, dynamic>) {
        return user['name'] as String?;
      }
      return null;
    }

    final mealsJson = (json['meals'] as List<dynamic>? ?? const []);

    return DietPlanModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      traineeId: (json['trainee_id'] as num?)?.toInt() ?? 0,
      trainerId: (json['trainer_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      caloriesTarget: parseInt(json['calories_target']),
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      status: (json['status'] ?? 'active') as String,
      traineeName: getNestedName(json['trainee'] as Map<String, dynamic>?),
      trainerName: getNestedName(json['trainer'] as Map<String, dynamic>?),
      meals: mealsJson
          .whereType<Map>()
          .map((e) => MealModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
