import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'inbox_notifier.dart';
import '../../../models/ai_interaction.dart';
import '../../../widgets/common/skeleton_loader.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/error_view.dart';
import '../../../widgets/common/animations.dart';
import '../../../core/theme/app_colors.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxState = ref.watch(inboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Inbox',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (!inboxState.isLoading && inboxState.conversations.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${inboxState.conversations.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref.read(inboxProvider.notifier).fetchInteractions(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, ref, inboxState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, InboxState state) {
    if (state.isLoading && state.interactions.isEmpty) {
      return const SkeletonLoader(type: SkeletonType.listTile, itemCount: 7);
    }
    if (state.error != null && state.interactions.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(inboxProvider.notifier).fetchInteractions(),
      );
    }
    if (state.interactions.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.messageSquare,
        title: 'No conversations yet',
        subtitle: 'Messages from WhatsApp, Facebook, Instagram, and Web will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 120),
      itemCount: state.conversations.length,
      itemBuilder: (context, index) {
        final conv = state.conversations[index];
        return AnimatedListItem(
          index: index,
          child: _ConversationTile(conversation: conv),
        );
      },
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'Instagram':
        return LucideIcons.instagram;
      case 'Facebook':
        return LucideIcons.facebook;
      case 'WhatsApp':
        return LucideIcons.messageCircle;
      default:
        return LucideIcons.messageSquare;
    }
  }

  Color _platformColor(String platform) {
    switch (platform) {
      case 'Instagram':
        return const Color(0xFFE1306C);
      case 'Facebook':
        return const Color(0xFF1877F2);
      case 'WhatsApp':
        return const Color(0xFF25D366);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final platformColor = _platformColor(conversation.platform);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _ChatScreen(conversationKey: conversation.key),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: conversation.unread
                    ? platformColor.withValues(alpha: 0.15)
                    : isDark ? AppColors.darkBorder : AppColors.border,
                width: conversation.unread ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: platformColor.withValues(alpha: 0.12),
                      child: Text(
                        conversation.sender.isNotEmpty
                            ? conversation.sender.substring(0, conversation.sender.length > 1 ? 2 : 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: platformColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkCard : AppColors.card,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _platformIcon(conversation.platform),
                          size: 12,
                          color: platformColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              conversation.sender,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            conversation.time,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (conversation.platformAccountName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'via ${conversation.platformAccountName}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedForeground.withValues(alpha: 0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatScreen extends ConsumerStatefulWidget {
  final String conversationKey;
  const _ChatScreen({required this.conversationKey});

  @override
  ConsumerState<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<_ChatScreen> {
  final _replyController = TextEditingController();
  bool _isSending = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSending) return;

    final conv = _getConversation();
    if (conv == null || conv.messages.isEmpty) return;

    setState(() => _isSending = true);
    final lastMsg = conv.messages.first;
    final success = await ref.read(inboxProvider.notifier).sendReply(lastMsg.id, text);
    setState(() => _isSending = false);

    if (success) {
      _replyController.clear();
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reply')),
        );
      }
    }
  }

  Conversation? _getConversation() {
    final inboxState = ref.read(inboxProvider);
    try {
      return inboxState.conversations.firstWhere(
        (c) => c.key == widget.conversationKey,
      );
    } catch (_) {
      return null;
    }
  }

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'Instagram':
        return LucideIcons.instagram;
      case 'Facebook':
        return LucideIcons.facebook;
      case 'WhatsApp':
        return LucideIcons.messageCircle;
      default:
        return LucideIcons.messageSquare;
    }
  }

  Color _platformColor(String platform) {
    switch (platform) {
      case 'Instagram':
        return const Color(0xFFE1306C);
      case 'Facebook':
        return const Color(0xFF1877F2);
      case 'WhatsApp':
        return const Color(0xFF25D366);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inboxState = ref.watch(inboxProvider);
    Conversation? conv;
    try {
      conv = inboxState.conversations.firstWhere(
        (c) => c.key == widget.conversationKey,
      );
    } catch (_) {
      conv = null;
    }
    if (conv == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Conversation')),
        body: const Center(child: Text('Conversation not found')),
      );
    }
    final platformColor = _platformColor(conv.platform);
    final messages = conv.messages.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: platformColor.withValues(alpha: 0.15),
              child: Text(
                conv.sender.isNotEmpty ? conv.sender.substring(0, conv.sender.length > 1 ? 2 : 1).toUpperCase() : '?',
                style: TextStyle(
                  color: platformColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv.sender,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Icon(_platformIcon(conv.platform), size: 10, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text(
                      '${conv.platform}${conv.platformAccountName != null ? ' via ${conv.platformAccountName}' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages',
                      style: TextStyle(color: AppColors.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final showReply = msg.hasReply;
                      final isManual = msg.isManualReply;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User message bubble
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCard : AppColors.muted,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  msg.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Reply bubble (if exists)
                            if (showReply)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isManual
                                        ? AppColors.secondary.withValues(alpha: 0.85)
                                        : AppColors.primary.withValues(alpha: 0.85),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        msg.reply!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isManual ? LucideIcons.user : LucideIcons.bot,
                                            size: 10,
                                            color: Colors.white70,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isManual ? 'Manual' : 'AI',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Reply input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.card,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      decoration: InputDecoration(
                        hintText: 'Type a reply...',
                        hintStyle: TextStyle(color: AppColors.mutedForeground),
                        filled: true,
                        fillColor: isDark ? AppColors.darkMuted : AppColors.muted,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendReply(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _isSending ? null : _sendReply,
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(LucideIcons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
