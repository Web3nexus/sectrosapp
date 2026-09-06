import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/financial_summary.dart';
import '../../../models/transaction_entry.dart';
import '../../../models/settlement_record.dart';

class FinanceState {
  final FinancialSummary? overview;
  final List<TransactionEntry> transactions;
  final Map<String, dynamic>? transactionsMeta;
  final List<SettlementRecord> settlements;
  final bool isLoading;
  final String? error;

  FinanceState({
    this.overview,
    this.transactions = const [],
    this.transactionsMeta,
    this.settlements = const [],
    this.isLoading = false,
    this.error,
  });

  FinanceState copyWith({
    FinancialSummary? overview,
    List<TransactionEntry>? transactions,
    Map<String, dynamic>? transactionsMeta,
    List<SettlementRecord>? settlements,
    bool? isLoading,
    String? error,
  }) {
    return FinanceState(
      overview: overview ?? this.overview,
      transactions: transactions ?? this.transactions,
      transactionsMeta: transactionsMeta ?? this.transactionsMeta,
      settlements: settlements ?? this.settlements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  final ApiService _api;

  FinanceNotifier(this._api) : super(FinanceState()) {
    fetchAll();
  }

  Future<void> fetchAll({String period = 'all', int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      FinancialSummary? overview = state.overview;
      List<TransactionEntry> transactions = state.transactions;
      Map<String, dynamic>? transactionsMeta = state.transactionsMeta;
      List<SettlementRecord> settlements = state.settlements;
      String? firstError;

      // 1. Overview
      try {
        final res = await _api.client.get('/finance/overview', queryParameters: {'period': period});
        if (res.statusCode == 200 && res.data is Map) {
          overview = FinancialSummary.fromJson(Map<String, dynamic>.from(res.data));
        }
      } on DioException catch (e) {
        firstError ??= ApiError.fromDio(e).message;
      } catch (_) {}

      // 2. Transactions
      try {
        final res = await _api.client.get('/finance/transactions', queryParameters: {'page': page});
        if (res.statusCode == 200) {
          final data = ApiService.extractList(res.data);
          transactions = data
              .whereType<Map>()
              .map((e) => TransactionEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          if (res.data is Map && res.data['meta'] is Map) {
            transactionsMeta = Map<String, dynamic>.from(res.data['meta']);
          }
        }
      } on DioException catch (e) {
        firstError ??= ApiError.fromDio(e).message;
      } catch (_) {}

      // 3. Settlements
      try {
        final res = await _api.client.get('/finance/settlements');
        if (res.statusCode == 200) {
          final data = ApiService.extractList(res.data);
          settlements = data
              .whereType<Map>()
              .map((e) => SettlementRecord.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } on DioException catch (e) {
        firstError ??= ApiError.fromDio(e).message;
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        overview: overview,
        transactions: transactions,
        transactionsMeta: transactionsMeta,
        settlements: settlements,
        error: (overview == null && transactions.isEmpty && settlements.isEmpty) ? firstError : null,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier(ref.watch(apiServiceProvider));
});
