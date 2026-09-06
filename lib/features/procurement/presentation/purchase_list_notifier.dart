import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/shopping_item.dart';

class PurchaseListState {
  final List<ShoppingItem> items;
  final bool isLoading;
  final String? error;

  PurchaseListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  PurchaseListState copyWith({
    List<ShoppingItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return PurchaseListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<ShoppingItem> get pending => items.where((i) => !i.isPurchased).toList();
  List<ShoppingItem> get purchased => items.where((i) => i.isPurchased).toList();
}

class PurchaseListNotifier extends StateNotifier<PurchaseListState> {
  final ApiService _api;

  PurchaseListNotifier(this._api) : super(PurchaseListState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/procurement/shopping-items');
      if (response.statusCode == 200) {
        final data = ApiService.extractList(response.data);
        final items = data
            .whereType<Map>()
            .map((j) => ShoppingItem.fromJson(Map<String, dynamic>.from(j)))
            .toList();
        state = state.copyWith(isLoading: false, items: items);
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Unable to load shopping list');
    }
  }

  Future<bool> addItem(String name, {String? notes, String? unit, double? quantity}) async {
    try {
      await _api.client.post('/procurement/shopping-items', data: {
        'name': name,
        'item_name': name,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (unit != null && unit.isNotEmpty) 'unit': unit,
        'quantity': quantity ?? 1.0,
      });
      await fetch();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
      return false;
    } catch (_) {
      state = state.copyWith(error: 'Failed to add item');
      return false;
    }
  }

  Future<void> toggle(int id) async {
    // Optimistic update
    final updated = state.items.map((item) {
      return item.id == id ? item.copyWith(isPurchased: !item.isPurchased) : item;
    }).toList();
    state = state.copyWith(items: updated);

    try {
      await _api.client.patch('/procurement/shopping-items/$id/toggle');
    } on DioException catch (_) {
      await fetch(); // revert on error
    }
  }

  Future<void> deleteItem(int id) async {
    state = state.copyWith(items: state.items.where((i) => i.id != id).toList());
    try {
      await _api.client.delete('/procurement/shopping-items/$id');
    } on DioException catch (_) {
      await fetch();
    }
  }
}

final purchaseListProvider =
    StateNotifierProvider<PurchaseListNotifier, PurchaseListState>((ref) {
  return PurchaseListNotifier(ref.watch(apiServiceProvider));
});
