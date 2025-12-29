import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role; // trainer | trainee
  final String? profileImage;

  final TrainerProfile? trainerProfile;
  final TraineeProfile? traineeProfile;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.trainerProfile,
    this.traineeProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: json['phone'] as String?,
      role: (json['role'] ?? '') as String,
      profileImage: json['profile_image'] as String?,
      trainerProfile: json['trainer_profile'] != null
          ? TrainerProfile.fromJson(json['trainer_profile'] as Map<String, dynamic>)
          : null,
      traineeProfile: json['trainee_profile'] != null
          ? TraineeProfile.fromJson(json['trainee_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'profile_image': profileImage,
        'trainer_profile': trainerProfile?.toJson(),
        'trainee_profile': traineeProfile?.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());

  static UserModel? fromJsonString(String? value) {
    if (value == null || value.isEmpty) return null;
    final map = jsonDecode(value) as Map<String, dynamic>;
    return UserModel.fromJson(map);
  }
}

class TrainerProfile {
  final int id;
  final int userId;
  final String? specialization;
  final int experienceYears;
  final String? certification;
  final String? bio;
  final double rating;

  const TrainerProfile({
    required this.id,
    required this.userId,
    this.specialization,
    required this.experienceYears,
    this.certification,
    this.bio,
    required this.rating,
  });

  factory TrainerProfile.fromJson(Map<String, dynamic> json) {
    return TrainerProfile(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      specialization: json['specialization'] as String?,
      experienceYears: (json['experience_years'] ?? 0 as num).toInt(),
      certification: json['certification'] as String?,
      bio: json['bio'] as String?,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'specialization': specialization,
        'experience_years': experienceYears,
        'certification': certification,
        'bio': bio,
        'rating': rating,
      };
}

class TraineeProfile {
  final int id;
  final int userId;
  final int? trainerId;
  final double? currentWeight;
  final double? targetWeight;
  final double? height;
  final int? age;
  final String? gender;
  final String goal;
  final String? startingDate;

  const TraineeProfile({
    required this.id,
    required this.userId,
    this.trainerId,
    this.currentWeight,
    this.targetWeight,
    this.height,
    this.age,
    this.gender,
    required this.goal,
    this.startingDate,
  });

  factory TraineeProfile.fromJson(Map<String, dynamic> json) {
    return TraineeProfile(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      trainerId: (json['trainer_id'] as num?)?.toInt(),
      currentWeight: (json['current_weight'] as num?)?.toDouble(),
      targetWeight: (json['target_weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      goal: (json['goal'] ?? 'maintenance') as String,
      startingDate: json['starting_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'trainer_id': trainerId,
        'current_weight': currentWeight,
        'target_weight': targetWeight,
        'height': height,
        'age': age,
        'gender': gender,
        'goal': goal,
        'starting_date': startingDate,
      };
}
