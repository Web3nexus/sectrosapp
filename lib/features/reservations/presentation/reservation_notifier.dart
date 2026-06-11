import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/reservation.dart';

class ReservationsState {
  final List<Reservation> reservations;
  final bool isLoading;
  final String? error;

  ReservationsState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
  });

  ReservationsState copyWith({
    List<Reservation>? reservations,
    bool? isLoading,
    String? error,
  }) {
    return ReservationsState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ReservationNotifier extends StateNotifier<ReservationsState> {
  final ApiService _apiService;

  ReservationNotifier(this._apiService) : super(ReservationsState()) {
    fetchReservations();
  }

  Future<void> fetchReservations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.client.get('/reservations');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final reservations = data.map((json) => Reservation.fromJson(json)).toList();
        state = state.copyWith(isLoading: false, reservations: reservations);
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

final reservationsProvider = StateNotifierProvider<ReservationNotifier, ReservationsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReservationNotifier(apiService);
});
