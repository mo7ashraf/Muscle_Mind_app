import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/services/api_service.dart';
import '../models/measurement_model.dart';
import '../models/paged_response.dart';
import '../models/progress_photo_model.dart';

class ProgressService {
  ProgressService._();

  static Future<PagedResponse<ProgressPhotoModel>> fetchProgressPhotos({int page = 1}) async {
    final res = await ApiService.dio.get('/trainee/progress', queryParameters: {'page': page});
    final body = res.data as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? const []);
    final items = list
        .whereType<Map>()
        .map((e) => ProgressPhotoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PagedResponse(
      data: items,
      currentPage: (body['current_page'] as num?)?.toInt() ?? page,
      lastPage: (body['last_page'] as num?)?.toInt(),
      total: (body['total'] as num?)?.toInt(),
    );
  }

  static Future<PagedResponse<MeasurementModel>> fetchMeasurementHistory({int page = 1}) async {
    final res = await ApiService.dio.get('/trainee/measurements/history', queryParameters: {'page': page});
    final body = res.data as Map<String, dynamic>;
    final list = (body['data'] as List<dynamic>? ?? const []);
    final items = list
        .whereType<Map>()
        .map((e) => MeasurementModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PagedResponse(
      data: items,
      currentPage: (body['current_page'] as num?)?.toInt() ?? page,
      lastPage: (body['last_page'] as num?)?.toInt(),
      total: (body['total'] as num?)?.toInt(),
    );
  }

  static Future<void> uploadProgress({
    String? frontPath,
    String? backPath,
    String? sidePath,
    double? weight,
    String? notes,
    DateTime? takenAt,
  }) async {
    final form = FormData();

    if (frontPath != null && frontPath.isNotEmpty) {
      form.files.add(MapEntry(
        'front_image',
        await MultipartFile.fromFile(frontPath, filename: File(frontPath).uri.pathSegments.last),
      ));
    }
    if (backPath != null && backPath.isNotEmpty) {
      form.files.add(MapEntry(
        'back_image',
        await MultipartFile.fromFile(backPath, filename: File(backPath).uri.pathSegments.last),
      ));
    }
    if (sidePath != null && sidePath.isNotEmpty) {
      form.files.add(MapEntry(
        'side_image',
        await MultipartFile.fromFile(sidePath, filename: File(sidePath).uri.pathSegments.last),
      ));
    }

    if (weight != null) form.fields.add(MapEntry('weight', weight.toString()));
    if (notes != null && notes.trim().isNotEmpty) form.fields.add(MapEntry('notes', notes.trim()));
    if (takenAt != null) form.fields.add(MapEntry('taken_at', takenAt.toIso8601String()));

    await ApiService.dio.post('/trainee/progress/photos', data: form);
  }

  static Future<void> addMeasurement({
    double? weight,
    double? chest,
    double? waist,
    double? hips,
    double? arms,
    double? thighs,
    DateTime? measuredAt,
  }) async {
    final payload = <String, dynamic>{
      if (weight != null) 'weight': weight,
      if (chest != null) 'chest': chest,
      if (waist != null) 'waist': waist,
      if (hips != null) 'hips': hips,
      if (arms != null) 'arms': arms,
      if (thighs != null) 'thighs': thighs,
      if (measuredAt != null) 'measured_at': measuredAt.toIso8601String(),
    };

    await ApiService.dio.post('/trainee/measurements', data: payload);
  }
}
