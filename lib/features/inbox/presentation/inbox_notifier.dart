import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_service.dart';
import '../../../core/utils/api_error.dart';
import '../../../models/ai_interaction.dart';

class _Sentinel {
  const _Sentinel();
}

class InboxState {
  final List<AiInteraction> interactions;
  final bool isLoading;
  final String? error;

  InboxState({
    this.interactions = const [],
    this.isLoading = false,
    this.error,
  });

  InboxState copyWith({
    List<AiInteraction>? interactions,
    bool? isLoading,
    Object? error = const _Sentinel(),
  }) {
    return InboxState(
      interactions: interactions ?? this.interactions,
      isLoading: isLoading ?? this.isLoading,
      error: error == const _Sentinel() ? this.error : error as String?,
    );
  }

  List<Conversation> get conversations {
    final map = <String, List<AiInteraction>>{};
    for (final msg in interactions) {
      final key = '${msg.sender}|${msg.platformAccountId ?? msg.platform}';
      map.putIfAbsent(key, () => []);
      map[key]!.add(msg);
    }
    // Sort messages within each group by timestamp descending (newest first)
    for (final key in map.keys) {
      map[key]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    final sortedKeys = map.keys.toList()..sort((a, b) {
      final aTime = map[a]!.first.timestamp;
      final bTime = map[b]!.first.timestamp;
      return bTime.compareTo(aTime);
    });
    return sortedKeys.map((key) {
      final msgs = map[key]!;
      final first = msgs.first;
      return Conversation(
        key: key,
        sender: first.sender,
        platform: first.platform,
        platformAccountId: first.platformAccountId,
        platformAccountName: first.platformAccountName,
        lastMessage: first.content,
        timestamp: first.timestamp,
        time: first.time,
        unread: first.status == 'Thinking...',
        messages: msgs,
      );
    }).toList();
  }
}

class InboxNotifier extends StateNotifier<InboxState> {
  final ApiService _apiService;

  InboxNotifier(this._apiService) : super(InboxState()) {
    fetchInteractions();
  }

  Future<void> fetchInteractions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.client.get('/automation/activity');
      if (response.statusCode == 200) {
        final rawList = ApiService.extractList(response.data, 'activity');
        final interactions = rawList
            .whereType<Map>()
            .map((json) => AiInteraction.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        state = state.copyWith(isLoading: false, interactions: interactions);
      }
    } on DioException catch (e) {
      final apiError = ApiError.fromDio(e);
      state = state.copyWith(isLoading: false, error: apiError.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong');
    }
  }

  Future<bool> sendReply(int interactionId, String reply) async {
    state = state.copyWith(error: null);
    try {
      final response = await _apiService.client.post(
        '/automation/interactions/$interactionId/reply',
        data: {'reply': reply},
      );
      if (response.statusCode == 200) {
        await fetchInteractions();
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

final inboxProvider = StateNotifierProvider<InboxNotifier, InboxState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return InboxNotifier(apiService);
});
