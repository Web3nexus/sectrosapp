import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/staff_message.dart';

class StaffMessagesState {
  final List<StaffMessage> messages;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  StaffMessagesState({
    this.messages = const [], this.isLoading = false, this.error,
    this.unreadCount = 0,
  });

  StaffMessagesState copyWith({
    List<StaffMessage>? messages, bool? isLoading, String? error, int? unreadCount,
  }) {
    return StaffMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class StaffMessagesNotifier extends StateNotifier<StaffMessagesState> {
  final ApiService _api;
  StaffMessagesNotifier(this._api) : super(StaffMessagesState()) { fetch(); }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.client.get('/staff/messages');
      if (response.statusCode == 200) {
        final List<dynamic> data = ApiService.extractList(response.data, 'messages');
        final messages = data.map((j) => StaffMessage.fromJson(j)).toList();
        final unread = messages.where((m) => !m.read).length;
        state = state.copyWith(isLoading: false, messages: messages, unreadCount: unread);
      } else {
        state = state.copyWith(isLoading: false, error: 'Unexpected response');
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
      await _api.client.patch('/staff/messages/$id/read');
      await fetch();
    } on DioException catch (e) {
      final err = ApiError.fromDio(e);
      state = state.copyWith(error: err.message);
    } catch (_) {
      state = state.copyWith(error: 'Failed to mark message as read');
    }
  }
}

final staffMessagesProvider = StateNotifierProvider<StaffMessagesNotifier, StaffMessagesState>((ref) {
  return StaffMessagesNotifier(ref.watch(apiServiceProvider));
});
