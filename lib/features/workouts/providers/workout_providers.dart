import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paged_response.dart';
import '../models/workout_model.dart';
import 'workout_service.dart';

final workoutsProvider = FutureProvider.autoDispose<PagedResponse<WorkoutModel>>((ref) async {
  return WorkoutService.fetchWorkouts();
});

final workoutDetailsProvider = FutureProvider.family.autoDispose<WorkoutModel, int>((ref, id) async {
  return WorkoutService.fetchWorkout(id);
});

final workoutActionsProvider = StateNotifierProvider.autoDispose<WorkoutActions, AsyncValue<void>>((ref) {
  return WorkoutActions(ref);
});

class WorkoutActions extends StateNotifier<AsyncValue<void>> {
  WorkoutActions(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<bool> createWorkout({
    required int traineeId,
    required String title,
    String? description,
    DateTime? scheduledDate,
  }) async {
    state = const AsyncLoading();
    try {
      await WorkoutService.createWorkout(
        traineeId: traineeId,
        title: title,
        description: description,
        scheduledDate: scheduledDate,
      );
      ref.invalidate(workoutsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> addExercise({
    required int workoutId,
    required String name,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
    String? videoUrl,
  }) async {
    state = const AsyncLoading();
    try {
      await WorkoutService.addExercise(
        workoutId: workoutId,
        name: name,
        sets: sets,
        reps: reps,
        restTime: restTime,
        notes: notes,
        videoUrl: videoUrl,
      );
      ref.invalidate(workoutDetailsProvider(workoutId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> markCompleted(int workoutId) async {
    state = const AsyncLoading();
    try {
      await WorkoutService.markCompleted(workoutId);
      ref.invalidate(workoutsProvider);
      ref.invalidate(workoutDetailsProvider(workoutId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
