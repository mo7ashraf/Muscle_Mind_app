import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../models/diet_plan_model.dart';

class DietService {
  DietService._();

  static Future<List<DietPlanModel>> fetchDietPlans({String? status}) async {
    final res = await ApiService.dio.get('/diet-plans', queryParameters: {
      if (status != null && status.isNotEmpty) 'status': status,
    });
    final body = res.data as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? const []);

    return list
        .whereType<Map>()
        .map((e) => DietPlanModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<DietPlanModel> fetchDietPlan(int id) async {
    final res = await ApiService.dio.get('/diet-plans/$id');
    final body = res.data as Map<String, dynamic>;
    final planJson = (body['diet_plan'] as Map<String, dynamic>? ?? const <String, dynamic>{});
    return DietPlanModel.fromJson(planJson);
  }

  static Future<void> createDietPlan({
    required int traineeId,
    required String title,
    String? description,
    int? caloriesTarget,
    DateTime? startDate,
    DateTime? endDate,
    String status = 'active',
  }) async {
    final payload = {
      'trainee_id': traineeId,
      'title': title,
      if (description != null) 'description': description,
      if (caloriesTarget != null) 'calories_target': caloriesTarget,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      'status': status,
    };

    await ApiService.dio.post('/diet-plans', data: payload);
  }

  static Future<void> addMeal({
    required int dietPlanId,
    required String name,
    String? time,
    int? calories,
    double? proteins,
    double? carbs,
    double? fats,
    String? description,
  }) async {
    final payload = {
      'name': name,
      if (time != null) 'time': time,
      if (calories != null) 'calories': calories,
      if (proteins != null) 'proteins': proteins,
      if (carbs != null) 'carbs': carbs,
      if (fats != null) 'fats': fats,
      if (description != null) 'description': description,
    };

    await ApiService.dio.post('/diet-plans/$dietPlanId/meals', data: payload);
  }

  static Future<void> updateDietPlan({
    required int id,
    String? title,
    String? description,
    int? caloriesTarget,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final payload = {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (caloriesTarget != null) 'calories_target': caloriesTarget,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (status != null) 'status': status,
    };

    await ApiService.dio.put('/diet-plans/$id', data: payload);
  }

  static Future<void> deleteDietPlan(int id) async {
    await ApiService.dio.delete('/diet-plans/$id');
  }
}
