import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/staff_profile.dart';

class StaffState {
  final List<StaffProfile> staff;
  final bool isLoading;
  final String? error;

  StaffState({
    this.staff = const [],
    this.isLoading = false,
    this.error,
  });

  StaffState copyWith({
    List<StaffProfile>? staff,
    bool? isLoading,
    String? error,
  }) {
    return StaffState(
      staff: staff ?? this.staff,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StaffNotifier extends StateNotifier<StaffState> {
  final ApiService _api;

  StaffNotifier(this._api) : super(StaffState()) {
    fetchStaff();
  }

  Future<void> fetchStaff() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/staff');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final staff = data.map((j) => StaffProfile.fromJson(j)).toList();
        state = state.copyWith(isLoading: false, staff: staff);
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<bool> createStaff(StaffProfile staff) async {
    try {
      await _api.client.post('/staff', data: staff.toJson());
      await fetchStaff();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> updateStaff(int id, StaffProfile staff) async {
    try {
      await _api.client.put('/staff/$id', data: staff.toJson());
      await fetchStaff();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> deleteStaff(int id) async {
    try {
      await _api.client.delete('/staff/$id');
      await fetchStaff();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }
}

final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>((ref) {
  return StaffNotifier(ref.watch(apiServiceProvider));
});
