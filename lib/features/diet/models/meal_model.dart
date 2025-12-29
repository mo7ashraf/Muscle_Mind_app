class MealModel {
  final int id;
  final int dietPlanId;
  final String name;
  final String? time;
  final int? calories;
  final double? proteins;
  final double? carbs;
  final double? fats;
  final String? description;

  const MealModel({
    required this.id,
    required this.dietPlanId,
    required this.name,
    this.time,
    this.calories,
    this.proteins,
    this.carbs,
    this.fats,
    this.description,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return MealModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      dietPlanId: (json['diet_plan_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '') as String,
      time: json['time'] as String?,
      calories: parseInt(json['calories']),
      proteins: parseDouble(json['proteins']),
      carbs: parseDouble(json['carbs']),
      fats: parseDouble(json['fats']),
      description: json['description'] as String?,
    );
  }
}
