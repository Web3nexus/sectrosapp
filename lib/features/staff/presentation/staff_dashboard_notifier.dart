import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/staff_dashboard_data.dart';

class StaffDashboardState {
  final StaffDashboardData? data;
  final bool isLoading;
  final String? error;

  StaffDashboardState({this.data, this.isLoading = false, this.error});

  StaffDashboardState copyWith({StaffDashboardData? data, bool? isLoading, String? error}) {
    return StaffDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StaffDashboardNotifier extends StateNotifier<StaffDashboardState> {
  final ApiService _api;
  StaffDashboardNotifier(this._api) : super(StaffDashboardState()) { fetch(); }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/staff/me/dashboard');
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          data: StaffDashboardData.fromJson(response.data),
        );
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      if (err.isAuthError) await _api.clearAuth();
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }
}

final staffDashboardProvider = StateNotifierProvider<StaffDashboardNotifier, StaffDashboardState>((ref) {
  return StaffDashboardNotifier(ref.watch(apiServiceProvider));
});
