import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_service.dart';
import '../../../models/customer.dart';
import '../../reservations/presentation/reservation_notifier.dart';

class CustomersState {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;

  CustomersState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
  });

  CustomersState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CustomersNotifier extends StateNotifier<CustomersState> {
  final ApiService _apiService;
  final Ref _ref;

  CustomersNotifier(this._apiService, this._ref) : super(CustomersState()) {
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.client.get('/customers');
      if (response.statusCode == 200) {
        final rawList = ApiService.extractList(response.data);
        if (rawList.isNotEmpty) {
          final list = rawList.map((j) => Customer.fromJson(j as Map<String, dynamic>)).toList();
          state = state.copyWith(isLoading: false, customers: list);
          return;
        }
      }
    } catch (_) {
      // Fallback: derive customers from reservations list
    }

    // Fallback: derive unique customers from reservations
    final reservations = _ref.read(reservationsProvider).reservations;
    final Map<String, Customer> map = {};
    int idCounter = 1;

    for (final res in reservations) {
      final key = res.phone != null && res.phone!.isNotEmpty
          ? res.phone!
          : (res.email != null && res.email!.isNotEmpty ? res.email! : res.customerName);

      if (key.trim().isEmpty) continue;

      if (map.containsKey(key)) {
        final existing = map[key]!;
        map[key] = Customer(
          id: existing.id,
          name: existing.name,
          email: existing.email.isNotEmpty ? existing.email : (res.email ?? ''),
          phone: existing.phone.isNotEmpty ? existing.phone : (res.phone ?? ''),
          totalBookings: existing.totalBookings + 1,
          lastVisit: res.date,
          status: existing.totalBookings + 1 >= 3 ? 'vip' : 'regular',
          notes: existing.notes ?? res.notes,
          totalSpend: existing.totalSpend + 50.0,
        );
      } else {
        map[key] = Customer(
          id: idCounter++,
          name: res.customerName,
          email: res.email ?? '',
          phone: res.phone ?? '',
          totalBookings: 1,
          lastVisit: res.date,
          status: 'new',
          notes: res.notes,
          totalSpend: 50.0,
        );
      }
    }

    state = state.copyWith(
      isLoading: false,
      customers: map.values.toList(),
    );
  }
}

final customersProvider = StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return CustomersNotifier(api, ref);
});

