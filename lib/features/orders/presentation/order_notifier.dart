import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/order.dart';

class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
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
        final List<dynamic> data = ApiService.extractList(response.data);
        final orders = data
            .whereType<Map>()
            .map((json) => Order.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        state = state.copyWith(isLoading: false, orders: orders);
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load orders');
    }
  }

  Future<bool> createInHouseOrder({
    required String tableCode,
    required List<Map<String, dynamic>> items,
    String? customerName,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final response = await _apiService.client.post('/orders', data: {
        'table_code': tableCode,
        'customer_name': customerName,
        'dining_mode': 'dine_in',
        'items': items,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(isSubmitting: false);
        await fetchOrders();
        return true;
      }
      return false;
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(isSubmitting: false, error: apiError.message);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: 'Could not submit in-house order');
      return false;
    }
  }

  Future<bool> updateKitchenStatus(int orderId, String status) async {
    try {
      final response = await _apiService.client.patch('/orders/$orderId', data: {
        'kitchen_status': status,
      });
      if (response.statusCode == 200) {
        await fetchOrders();
        return true;
      }
      return false;
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(error: apiError.message);
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> collectCashPayment(int orderId, {double tipAmount = 0.0}) async {
    try {
      final response = await _apiService.client.patch('/orders/$orderId', data: {
        'payment_status': 'paid',
        'payment_method': 'cash',
        'tip_amount': tipAmount,
      });
      if (response.statusCode == 200) {
        await fetchOrders();
        return true;
      }
      return false;
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(error: apiError.message);
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> remitCash(int orderId) async {
    try {
      final response = await _apiService.client.post('/orders/$orderId/remit-cash');
      if (response.statusCode == 200) {
        await fetchOrders();
        return true;
      }
      return false;
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(error: apiError.message);
      return false;
    } catch (_) {
      return false;
    }
  }
}

final ordersProvider = StateNotifierProvider<OrderNotifier, OrdersState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderNotifier(apiService);
});
