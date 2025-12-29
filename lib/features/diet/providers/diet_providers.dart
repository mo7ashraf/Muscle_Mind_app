import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../models/diet_plan_model.dart';
import 'diet_service.dart';

final dietStatusFilterProvider = StateProvider<String?>((ref) => null);

final dietPlansProvider = FutureProvider.autoDispose<List<DietPlanModel>>((ref) async {
  final status = ref.watch(dietStatusFilterProvider);
  return DietService.fetchDietPlans(status: status);
});

final dietPlanProvider = FutureProvider.autoDispose.family<DietPlanModel, int>((ref, id) async {
  return DietService.fetchDietPlan(id);
});

final trainerTraineesListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final res = await ApiService.dio.get('/trainer/trainees');
  final data = res.data as Map<String, dynamic>;
  final list = (data['data'] as List<dynamic>? ?? const []);
  return list
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

final dietActionsProvider = StateNotifierProvider.autoDispose<DietActions, AsyncValue<void>>((ref) {
  return DietActions(ref);
});

class DietActions extends StateNotifier<AsyncValue<void>> {
  DietActions(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<bool> createPlan({
    required int traineeId,
    required String title,
    String? description,
    int? caloriesTarget,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();
    try {
      await DietService.createDietPlan(
        traineeId: traineeId,
        title: title,
        description: description,
        caloriesTarget: caloriesTarget,
        startDate: startDate,
        endDate: endDate,
      );
      ref.invalidate(dietPlansProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> addMeal({
    required int dietPlanId,
    required String name,
    String? time,
    int? calories,
    double? proteins,
    double? carbs,
    double? fats,
    String? description,
  }) async {
    state = const AsyncLoading();
    try {
      await DietService.addMeal(
        dietPlanId: dietPlanId,
        name: name,
        time: time,
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        description: description,
      );
      ref.invalidate(dietPlanProvider(dietPlanId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deletePlan(int id) async {
    state = const AsyncLoading();
    try {
      await DietService.deleteDietPlan(id);
      ref.invalidate(dietPlansProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
