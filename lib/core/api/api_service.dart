import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../../models/user.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final api = ApiService(
    onUnauthorized: () {
      ref.read(userProvider.notifier).logout();
    },
  );
  return api;
});

class ApiService {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();
  final void Function()? onUnauthorized;

  ApiService({this.onUnauthorized}) : _dio = Dio() {
    _dio.options.baseUrl = AppConfig.apiUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 '
          'SectrosApp/1.0',
    };
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        final tenantDomain = await _storage.read(key: 'tenant_domain');
        if (tenantDomain != null) {
          options.headers['X-Tenant-Domain'] = tenantDomain;
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // 401 is handled per-call (e.g. in tryAutoLogin).
        // We intentionally do NOT logout globally here —
        // a 401 on /reservations or any other resource should
        // just surface as an error on that screen, not wipe auth.
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;

  Future<String?> getToken() => _storage.read(key: 'auth_token');

  Future<String?> getTenantDomain() => _storage.read(key: 'tenant_domain');

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> saveTenant(String domain) async {
    await _storage.write(key: 'tenant_domain', value: domain);
  }

  Future<void> saveCachedUser(Map<String, dynamic> userData) async {
    await _storage.write(key: 'cached_user', value: jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getCachedUser() async {
    final raw = await _storage.read(key: 'cached_user');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'tenant_domain');
    await _storage.delete(key: 'cached_user');
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    await clearAuth();
  }

  /// Safely extracts a List from API responses, supporting plain lists,
  /// paginated Laravel responses ({ "data": [...] }), and custom keys.
  static List<dynamic> extractList(dynamic responseData, [String? preferredKey]) {
    if (responseData == null) return [];
    if (responseData is List) return responseData;

    if (responseData is Map) {
      if (preferredKey != null && responseData[preferredKey] is List) {
        return responseData[preferredKey] as List;
      }
      if (responseData['data'] is List) {
        return responseData['data'] as List;
      }
      if (responseData['notifications'] is List) {
        return responseData['notifications'] as List;
      }
      if (responseData['items'] is List) {
        return responseData['items'] as List;
      }
      if (responseData['plans'] is List) {
        return responseData['plans'] as List;
      }
      if (responseData['lists'] is List) {
        return responseData['lists'] as List;
      }
    }
    return [];
  }
}

