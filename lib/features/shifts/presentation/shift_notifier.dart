import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/shift.dart';

class ShiftState {
  final List<Shift> list;
  final bool isLoading;
  final String? error;

  ShiftState({this.list = const [], this.isLoading = false, this.error});

  ShiftState copyWith({List<Shift>? list, bool? isLoading, String? error}) {
    return ShiftState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ShiftNotifier extends StateNotifier<ShiftState> {
  final ApiService _api;
  ShiftNotifier(this._api) : super(ShiftState()) { fetch(); }

  final List<String> dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  List<Shift> get sorted => List.from(state.list)
    ..sort((a, b) => dayOrder.indexOf(a.dayOfWeek).compareTo(dayOrder.indexOf(b.dayOfWeek)));

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/shifts');
      if (response.statusCode == 200) {
        final List<dynamic> data = ApiService.extractList(response.data);
        final shifts = data
            .whereType<Map>()
            .map((j) => Shift.fromJson(Map<String, dynamic>.from(j)))
            .toList();
        state = state.copyWith(isLoading: false, list: shifts);
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<bool> save(Map<String, dynamic> data, {int? id}) async {
    try {
      if (id != null) {
        await _api.client.put('/shifts/$id', data: data);
      } else {
        await _api.client.post('/shifts', data: data);
      }
      await fetch();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _api.client.delete('/shifts/$id');
      await fetch();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }
}

final shiftProvider = StateNotifierProvider<ShiftNotifier, ShiftState>((ref) {
  return ShiftNotifier(ref.watch(apiServiceProvider));
});
