import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/billing_plan.dart';

class BillingState {
  final List<BillingPlan> plans;
  final BillingPlan? currentPlan;
  final Map<String, dynamic>? usage;
  final bool isLoading;
  final String? error;

  BillingState({
    this.plans = const [],
    this.currentPlan,
    this.usage,
    this.isLoading = false,
    this.error,
  });

  BillingState copyWith({
    List<BillingPlan>? plans,
    BillingPlan? currentPlan,
    Map<String, dynamic>? usage,
    bool? isLoading,
    String? error,
  }) {
    return BillingState(
      plans: plans ?? this.plans,
      currentPlan: currentPlan ?? this.currentPlan,
      usage: usage ?? this.usage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BillingNotifier extends StateNotifier<BillingState> {
  final ApiService _api;

  BillingNotifier(this._api) : super(BillingState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/billing/plans');
      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final List<dynamic> plansRaw = data['plans'] is List ? data['plans'] : [];
        final plans = plansRaw.map((j) => BillingPlan.fromJson(j)).toList();
        final current = plans.cast<BillingPlan?>().firstWhere(
          (p) => p!.isCurrent, orElse: () => null,
        );
        state = BillingState(
          plans: plans,
          currentPlan: current,
          usage: data['usage'] as Map<String, dynamic>?,
          isLoading: false,
        );
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<String?> upgrade(int planId) async {
    try {
      final response = await _api.client.post('/billing/upgrade', data: {'plan_id': planId});
      await fetch();
      return response.data['checkout_url'];
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return null;
    }
  }
}

final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier(ref.watch(apiServiceProvider));
});
