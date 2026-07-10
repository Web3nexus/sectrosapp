import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/table.dart';

class TablesState {
  final List<TableModel> tables;
  final bool isLoading;
  final String? error;

  TablesState({
    this.tables = const [],
    this.isLoading = false,
    this.error,
  });

  TablesState copyWith({
    List<TableModel>? tables,
    bool? isLoading,
    String? error,
  }) {
    return TablesState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TableNotifier extends StateNotifier<TablesState> {
  final ApiService _apiService;

  TableNotifier(this._apiService) : super(TablesState()) {
    fetchTables();
  }

  Future<void> fetchTables() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.client.get('/tables');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final tables = data.map((json) => TableModel.fromJson(json)).toList();
        state = state.copyWith(isLoading: false, tables: tables);
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }
}

final tablesProvider = StateNotifierProvider<TableNotifier, TablesState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TableNotifier(apiService);
});
