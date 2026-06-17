import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      try {
        final data = await ApiService.getProfile();
        final user = UserModel.fromJson(data);
        state = AuthState(user: user, isAuthenticated: true);
      } catch (_) {
        await prefs.remove('access_token');
        state = AuthState();
      }
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiService.register(data);
      final auth = AuthResponse.fromJson(response);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', auth.accessToken);
      await prefs.setString('refresh_token', auth.refreshToken);
      state = AuthState(user: auth.user, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> login(String emailOrUsername, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ApiService.login(emailOrUsername, password);
      final auth = AuthResponse.fromJson(response);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', auth.accessToken);
      await prefs.setString('refresh_token', auth.refreshToken);
      state = AuthState(user: auth.user, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    state = AuthState();
  }
}
