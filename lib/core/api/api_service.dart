import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = AppConfig.apiUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // Use a real mobile browser UA so Cloudflare Bot Fight Mode
      // doesn't block Dart's default 'Dart/x.x (dart:io)' agent.
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
        // Pass 401s through — do NOT clear auth here.
        // Individual screens show "session expired" and only a
        // manual logout (or tryAutoLogin failure) clears credentials.
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

  Future<void> clearAuth() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'tenant_domain');
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    await clearAuth();
  }
}
