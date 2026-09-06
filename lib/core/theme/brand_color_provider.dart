import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_service.dart';
import 'app_colors.dart';

class BrandColorNotifier extends StateNotifier<Color> {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  BrandColorNotifier(this._apiService) : super(AppColors.primary) {
    _initFromStorage();
    fetchBranding();
  }

  Future<void> _initFromStorage() async {
    try {
      final cached = await _storage.read(key: 'ui_color');
      if (cached != null) {
        AppColors.setBrandColor(cached);
        state = AppColors.primary;
      }
    } catch (_) {}
  }

  Future<void> fetchBranding() async {
    try {
      final res = await _apiService.client.get('/public/branding');
      if (res.statusCode == 200 && res.data is Map) {
        final uiColor = res.data['ui_color'] as String?;
        if (uiColor != null && uiColor.isNotEmpty) {
          await _storage.write(key: 'ui_color', value: uiColor);
          AppColors.setBrandColor(uiColor);
          state = AppColors.primary;
        }
      }
    } catch (_) {
      // Offline fallback: keep cached or default color
    }
  }

  Future<void> setColor(String colorName) async {
    AppColors.setBrandColor(colorName);
    await _storage.write(key: 'ui_color', value: colorName);
    state = AppColors.primary;
  }
}

final brandColorProvider = StateNotifierProvider<BrandColorNotifier, Color>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BrandColorNotifier(apiService);
});
