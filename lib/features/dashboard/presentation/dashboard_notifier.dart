import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';

class DashboardState {
  final Map<String, dynamic> metrics;
  final List<dynamic> recentOrders;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.metrics = const {
      'total_revenue': 0.0,
      'aov': 0.0,
      'active_reservations': 0,
      'total_expenses': 0.0,
      'net_profit': 0.0,
    },
    this.recentOrders = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    Map<String, dynamic>? metrics,
    List<dynamic>? recentOrders,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      metrics: metrics ?? this.metrics,
      recentOrders: recentOrders ?? this.recentOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiService _apiService;

  DashboardNotifier(this._apiService) : super(DashboardState()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.client.get('/dashboard/stats');
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          metrics: response.data['metrics'] ?? {},
          recentOrders: response.data['recent_orders'] ?? [],
        );
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      if (apiError.isAuthError) await _apiService.clearAuth();
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DashboardNotifier(apiService);
});
