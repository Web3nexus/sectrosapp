import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_service.dart';
import '../../../models/user.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final UserNotifier _userNotifier;

  AuthNotifier(this._apiService, this._userNotifier) : super(AuthState());

  Future<bool> tryAutoLogin() async {
    final token = await _apiService.getToken();
    if (token == null || token.isEmpty) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.client.get('/user');
      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        _userNotifier.setUser(user);
        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      }
    } on DioException catch (e) {
      // Only clear auth on 401 Unauthorized — 403, timeout, or network issues
      // should NOT invalidate a valid token.
      if (e.response?.statusCode == 401) {
        await _apiService.clearAuth();
      }
    } on Exception {
      // Non-Dio exceptions — do not clear token, user may just be offline.
    }
    state = state.copyWith(isLoading: false, isAuthenticated: false);
    return false;
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.client.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        final tenantDomain = data['tenant_domain'];
        final userData = data['user'];

        await _apiService.saveToken(token);
        if (tenantDomain != null) {
          await _apiService.saveTenant(tenantDomain);
        }

        final user = User.fromJson(userData);
        _userNotifier.setUser(user);

        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Login failed',
        );
        return false;
      }
    } on DioException catch (e) {
      final msg = _dioErrorMessage(e);
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error during login.');
      return false;
    }
  }

  /// Converts a DioException into a human-readable message.
  static String _dioErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach the server. Please check your internet connection.';
    }
    final status = e.response?.statusCode;
    if (status == 403) {
      return 'Access denied by server (403). Please contact support.';
    }
    if (status == 422) {
      final errors = e.response?.data?['errors'];
      if (errors is Map) {
        return errors.values.expand((v) => v is List ? v : [v]).join('\n');
      }
      return e.response?.data?['message'] ?? 'Validation error.';
    }
    if (status != null) {
      return e.response?.data?['message'] ?? 'Server error ($status).';
    }
    return 'Connection error. Please check your internet.';
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.client.post('/auth/register', data: {
        ...data,
        'turnstile_token': 'mobile_bypass',
      });

      if (response.statusCode == 201) {
        final responseData = response.data;
        final token = responseData['token'];
        final tenantDomain = responseData['domain'];
        final userData = responseData['user'];

        await _apiService.saveToken(token);
        if (tenantDomain != null) {
          await _apiService.saveTenant(tenantDomain);
        }

        final user = User.fromJson(userData);
        _userNotifier.setUser(user);

        state = state.copyWith(isLoading: false, isAuthenticated: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Registration failed',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _dioErrorMessage(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error during registration.');
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.client.post('/forgot-password', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Failed to send reset link',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _dioErrorMessage(e));
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error.');
      return false;
    }
  }

  void resetError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final userNotifier = ref.watch(userProvider.notifier);
  return AuthNotifier(apiService, userNotifier);
});

final autoLoginProvider = FutureProvider<bool>((ref) async {
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.tryAutoLogin();
});
