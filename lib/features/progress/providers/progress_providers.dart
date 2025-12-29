import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/measurement_model.dart';
import '../models/paged_response.dart';
import '../models/progress_photo_model.dart';
import 'progress_service.dart';

final progressPhotosProvider = FutureProvider.autoDispose<PagedResponse<ProgressPhotoModel>>((ref) async {
  return ProgressService.fetchProgressPhotos();
});

final measurementHistoryProvider = FutureProvider.autoDispose<PagedResponse<MeasurementModel>>((ref) async {
  return ProgressService.fetchMeasurementHistory();
});

final progressActionsProvider = StateNotifierProvider.autoDispose<ProgressActions, AsyncValue<void>>((ref) {
  return ProgressActions(ref);
});

class ProgressActions extends StateNotifier<AsyncValue<void>> {
  ProgressActions(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<bool> uploadProgress({
    String? frontPath,
    String? backPath,
    String? sidePath,
    double? weight,
    String? notes,
    DateTime? takenAt,
  }) async {
    state = const AsyncLoading();
    try {
      await ProgressService.uploadProgress(
        frontPath: frontPath,
        backPath: backPath,
        sidePath: sidePath,
        weight: weight,
        notes: notes,
        takenAt: takenAt,
      );
      ref.invalidate(progressPhotosProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> addMeasurement({
    double? weight,
    double? chest,
    double? waist,
    double? hips,
    double? arms,
    double? thighs,
    DateTime? measuredAt,
  }) async {
    state = const AsyncLoading();
    try {
      await ProgressService.addMeasurement(
        weight: weight,
        chest: chest,
        waist: waist,
        hips: hips,
        arms: arms,
        thighs: thighs,
        measuredAt: measuredAt,
      );
      ref.invalidate(measurementHistoryProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
