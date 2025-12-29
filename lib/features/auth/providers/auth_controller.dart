import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController()..init();
});

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? token;
  final String? error;

  const AuthState({
    required this.isLoading,
    this.user,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? token,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
    );
  }

  bool get isAuthed => token != null && token!.isNotEmpty && user != null;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState(isLoading: true));

  Future<void> init() async {
    ApiService.init();

    final token = await StorageService.readToken();
    final userJson = await StorageService.readUserJson();
    final cachedUser = UserModel.fromJsonString(userJson);

    state = AuthState(
      isLoading: false,
      token: token,
      user: cachedUser,
      error: null,
    );

    // If token exists, refresh /user in background
    if (token != null && token.isNotEmpty) {
      try {
        final me = await AuthService.me();
        await StorageService.saveUserJson(me.toJsonString());
        state = state.copyWith(user: me, error: null);
      } catch (_) {
        // token might be invalid; keep cached but allow app to continue
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthService.login(email: email, password: password);
      await StorageService.saveToken(result.$1);
      await StorageService.saveUserJson(result.$2.toJsonString());

      state = AuthState(isLoading: false, token: result.$1, user: result.$2);
      return true;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        token: null,
        user: null,
        error: ApiService.messageFromError(e),
      );
      return false;
    }
  }

  Future<bool> register({
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        phone: phone,
        specialization: specialization,
        experienceYears: experienceYears,
        certification: certification,
        bio: bio,
        trainerId: trainerId,
        currentWeight: currentWeight,
        targetWeight: targetWeight,
        height: height,
        age: age,
        gender: gender,
        goal: goal,
        startingDate: startingDate,
      );

      await StorageService.saveToken(result.$1);
      await StorageService.saveUserJson(result.$2.toJsonString());

      state = AuthState(isLoading: false, token: result.$1, user: result.$2);
      return true;
    } catch (e) {
      state = AuthState(
        isLoading: false,
        token: null,
        user: null,
        error: ApiService.messageFromError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.logout();
    } catch (_) {}
    await StorageService.clearAuth();
    state = const AuthState(isLoading: false);
  }

  Future<void> refreshMe() async {
    try {
      final me = await AuthService.me();
      await StorageService.saveUserJson(me.toJsonString());
      state = state.copyWith(user: me, error: null);
    } catch (e) {
      state = state.copyWith(error: ApiService.messageFromError(e));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final me = await AuthService.updateProfile(payload);
      await StorageService.saveUserJson(me.toJsonString());
      state = state.copyWith(isLoading: false, user: me, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiService.messageFromError(e));
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.uploadAvatar(filePath);
      await refreshMe();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ApiService.messageFromError(e));
    }
  }
}
