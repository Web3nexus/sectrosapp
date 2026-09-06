import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/waitlist_entry.dart';

class WaitlistState {
  final List<WaitlistEntry> list;
  final bool isLoading;
  final String? error;

  WaitlistState({this.list = const [], this.isLoading = false, this.error});

  WaitlistState copyWith({List<WaitlistEntry>? list, bool? isLoading, String? error}) {
    return WaitlistState(
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WaitlistNotifier extends StateNotifier<WaitlistState> {
  final ApiService _api;
  WaitlistNotifier(this._api) : super(WaitlistState()) { fetch(); }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/waitlist');
      if (response.statusCode == 200) {
        final List<dynamic> data = ApiService.extractList(response.data);
        final entries = data
            .whereType<Map>()
            .map((j) => WaitlistEntry.fromJson(Map<String, dynamic>.from(j)))
            .toList();
        state = state.copyWith(isLoading: false, list: entries);
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<bool> add(Map<String, dynamic> data) async {
    try {
      await _api.client.post('/waitlist', data: data);
      await fetch();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> seat(int id, int tableId) async {
    try {
      await _api.client.post('/waitlist/$id/seat', data: {'table_id': tableId});
      await fetch();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> cancel(int id) async {
    try {
      await _api.client.post('/waitlist/$id/cancel');
      await fetch();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> notify(int id) async {
    try {
      await _api.client.post('/waitlist/$id/notify');
      await fetch();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }
}

final waitlistProvider = StateNotifierProvider<WaitlistNotifier, WaitlistState>((ref) {
  return WaitlistNotifier(ref.watch(apiServiceProvider));
});
