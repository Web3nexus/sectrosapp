import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/notification.dart';

class NotificationsState {
  final List<AppNotification> list;
  final int? serverUnreadCount;
  final bool isLoading;
  final String? error;

  NotificationsState({
    this.list = const [],
    this.serverUnreadCount,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? list,
    int? serverUnreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationsState(
      list: list ?? this.list,
      serverUnreadCount: serverUnreadCount ?? this.serverUnreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get unreadCount => serverUnreadCount ?? list.where((n) => n.isUnread).length;
}

class NotificationNotifier extends StateNotifier<NotificationsState> {
  final ApiService _api;

  NotificationNotifier(this._api) : super(NotificationsState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = ApiService.extractList(response.data, 'notifications');
        final list = data.map((j) => AppNotification.fromJson(j as Map<String, dynamic>)).toList();
        int? serverUnread;
        if (response.data is Map && response.data['unread_count'] != null) {
          serverUnread = int.tryParse('${response.data['unread_count']}');
        }
        state = state.copyWith(
          isLoading: false,
          list: list,
          serverUnreadCount: serverUnread,
        );
      }
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: err.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<void> markRead(int id) async {
    try {
      await _api.client.patch('/notifications/$id/read');
      await fetch();
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _api.client.post('/notifications/read-all');
      await fetch();
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _api.client.post('/notifications/settings', data: settings);
    } on DioException catch (e) {
      state = state.copyWith(error: ApiError.fromDio(e).message);
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationNotifier, NotificationsState>((ref) {
  return NotificationNotifier(ref.watch(apiServiceProvider));
});
