import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // POST /register
  static Future<(String token, UserModel user)> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,

    // trainer
    String? specialization,
    int? experienceYears,
    String? certification,
    String? bio,

    // trainee
    int? trainerId,
    double? currentWeight,
    double? targetWeight,
    double? height,
    int? age,
    String? gender,
    String? goal,
    String? startingDate,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
      if (phone != null) 'phone': phone,
      if (role == 'trainer') ...{
        if (specialization != null) 'specialization': specialization,
        if (experienceYears != null) 'experience_years': experienceYears,
        if (certification != null) 'certification': certification,
        if (bio != null) 'bio': bio,
      },
      if (role == 'trainee') ...{
        if (trainerId != null) 'trainer_id': trainerId,
        if (currentWeight != null) 'current_weight': currentWeight,
        if (targetWeight != null) 'target_weight': targetWeight,
        if (height != null) 'height': height,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (goal != null) 'goal': goal,
        if (startingDate != null) 'starting_date': startingDate,
      },
    };

    final res = await ApiService.dio.post('/register', data: payload);
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (token, user);
  }

  // POST /login
  static Future<(String token, UserModel user)> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiService.dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (token, user);
  }

  // POST /logout
  static Future<void> logout() async {
    await ApiService.dio.post('/logout');
  }

  // GET /user
  static Future<UserModel> me() async {
    final res = await ApiService.dio.get('/user');
    final data = res.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  // PUT /user/profile
  static Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    final res = await ApiService.dio.put('/user/profile', data: payload);
    final data = res.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  // POST /user/avatar
  static Future<String> uploadAvatar(String filePath) async {
    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final res = await ApiService.dio.post('/user/avatar', data: form);
    final data = res.data as Map<String, dynamic>;
    return (data['profile_image_url'] ?? '') as String;
  }
}
