import '../../../core/services/api_service.dart';
import '../models/paged_response.dart';
import '../models/workout_model.dart';

class WorkoutService {
  WorkoutService._();

  static Future<PagedResponse<WorkoutModel>> fetchWorkouts({int page = 1}) async {
    final res = await ApiService.dio.get('/workouts', queryParameters: {'page': page});
    final body = res.data as Map<String, dynamic>;

    final list = (body['data'] as List<dynamic>? ?? const []);
    final items = list
        .whereType<Map>()
        .map((e) => WorkoutModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PagedResponse(
      data: items,
      currentPage: (body['current_page'] as num?)?.toInt() ?? page,
      lastPage: (body['last_page'] as num?)?.toInt(),
      total: (body['total'] as num?)?.toInt(),
    );
  }

  static Future<WorkoutModel> fetchWorkout(int id) async {
    final res = await ApiService.dio.get('/workouts/$id');
    final body = res.data as Map<String, dynamic>;
    final workoutJson = (body['workout'] as Map<String, dynamic>? ?? const <String, dynamic>{});
    return WorkoutModel.fromJson(workoutJson);
  }

  static Future<WorkoutModel> createWorkout({
    required int traineeId,
    required String title,
    String? description,
    DateTime? scheduledDate,
  }) async {
    final payload = <String, dynamic>{
      'trainee_id': traineeId,
      'title': title,
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      if (scheduledDate != null) 'scheduled_date': scheduledDate.toIso8601String(),
    };

    final res = await ApiService.dio.post('/workouts', data: payload);
    final body = res.data as Map<String, dynamic>;
    final workoutJson = (body['workout'] as Map<String, dynamic>? ?? const <String, dynamic>{});
    return WorkoutModel.fromJson(workoutJson);
  }

  static Future<void> markCompleted(int workoutId) async {
    await ApiService.dio.put('/workouts/$workoutId/complete');
  }

  static Future<void> addExercise({
    required int workoutId,
    required String name,
    int? sets,
    int? reps,
    int? restTime,
    String? notes,
    String? videoUrl,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      if (sets != null) 'sets': sets,
      if (reps != null) 'reps': reps,
      if (restTime != null) 'rest_time': restTime,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (videoUrl != null && videoUrl.trim().isNotEmpty) 'video_url': videoUrl.trim(),
    };

    await ApiService.dio.post('/workouts/$workoutId/exercises', data: payload);
  }
}
