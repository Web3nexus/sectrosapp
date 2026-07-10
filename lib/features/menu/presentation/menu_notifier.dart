import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/menu.dart';

class MenuState {
  final List<MenuCategory> categories;
  final bool isLoading;
  final String? error;

  MenuState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  MenuState copyWith({
    List<MenuCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return MenuState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  final ApiService _api;

  MenuNotifier(this._api) : super(MenuState()) {
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/menu');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        final categories = data.map((j) => MenuCategory.fromJson(j)).toList();
        state = state.copyWith(isLoading: false, categories: categories);
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<bool> createCategory(String name, {String? description}) async {
    try {
      await _api.client.post('/menu/categories', data: {
        'name': name,
        'description': description,
      });
      await fetchMenu();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name, {String? description}) async {
    try {
      await _api.client.put('/menu/categories/$id', data: {
        'name': name,
        'description': description,
      });
      await fetchMenu();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _api.client.delete('/menu/categories/$id');
      await fetchMenu();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> createItem(MenuItem item) async {
    try {
      await _api.client.post('/menu/items', data: item.toJson());
      await fetchMenu();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> updateItem(int id, MenuItem item) async {
    try {
      await _api.client.put('/menu/items/$id', data: item.toJson());
      await fetchMenu();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await _api.client.delete('/menu/items/$id');
      await fetchMenu();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    }
  }
}

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref.watch(apiServiceProvider));
});
