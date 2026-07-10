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
      final results = await Future.wait([
        _api.client.get('/finance/overview', queryParameters: {'period': period}),
        _api.client.get('/finance/transactions', queryParameters: {'page': page}),
        _api.client.get('/finance/settlements'),
      ]);

      final overviewRes = results[0];
      final txRes = results[1];
      final settleRes = results[2];

      state = state.copyWith(
        isLoading: false,
        overview: overviewRes.statusCode == 200
            ? FinancialSummary.fromJson(overviewRes.data)
            : state.overview,
        transactions: txRes.statusCode == 200
            ? (txRes.data['data'] as List?)?.map((e) => TransactionEntry.fromJson(e)).toList() ?? []
            : state.transactions,
        transactionsMeta: txRes.statusCode == 200 ? txRes.data['meta'] : state.transactionsMeta,
        settlements: settleRes.statusCode == 200
            ? (settleRes.data as List?)?.map((e) => SettlementRecord.fromJson(e)).toList() ?? []
            : state.settlements,
      );
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }
}

final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier(ref.watch(apiServiceProvider));
});
