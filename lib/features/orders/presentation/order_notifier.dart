import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/order.dart';

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrdersState> {
  final ApiService _apiService;

  OrderNotifier(this._apiService) : super(OrdersState()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.client.get('/orders');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final orders = data.map((json) => Order.fromJson(json)).toList();
        state = state.copyWith(isLoading: false, orders: orders);
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      if (apiError.isAuthError) await _apiService.clearAuth();
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<void> updateKitchenStatus(int orderId, String status) async {
    try {
      final response = await _apiService.client.patch('/orders/$orderId', data: {
        'kitchen_status': status,
      });
      if (response.statusCode == 200) {
        await fetchOrders();
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(error: apiError.message);
    } catch (_) {}
  }
}

final ordersProvider = StateNotifierProvider<OrderNotifier, OrdersState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderNotifier(apiService);
});
