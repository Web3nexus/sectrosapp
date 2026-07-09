class AiInteraction {
  final int id;
  final String type;
  final String sender;
  final String platform;
  final String? platformAccountId;
  final String? platformAccountName;
  final String content;
  final String? reply;
  final String status;
  final String? sentiment;
  final String time;
  final String timestamp;

  AiInteraction({
    required this.id,
    this.type = 'inquiry',
    required this.sender,
    required this.platform,
    this.platformAccountId,
    this.platformAccountName,
    required this.content,
    this.reply,
    this.status = 'pending',
    this.sentiment,
    required this.time,
    required this.timestamp,
  });

  factory AiInteraction.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null) {
      throw ArgumentError('Missing required field: id');
    }
    return AiInteraction(
      id: id is int ? id : int.parse(id.toString()),
      type: json['type']?.toString() ?? 'inquiry',
      sender: json['sender']?.toString() ?? 'Unknown',
      platform: json['platform']?.toString() ?? 'Web',
      platformAccountId: json['platform_account_id']?.toString(),
      platformAccountName: json['platform_account_name']?.toString(),
      content: json['content']?.toString() ?? '',
      reply: json['reply']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      sentiment: json['sentiment']?.toString(),
      time: json['time']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  bool get isOutOfCredits => status == 'limit_reached';
  bool get isFailedToSend => status == 'failed_to_send';
  bool get isManualReply => status == 'manual_reply';
  bool get isAiReply => status == 'replied' || status == 'actioned';
  bool get hasReply => reply != null && reply!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiInteraction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          sender == other.sender &&
          platform == other.platform &&
          platformAccountId == other.platformAccountId &&
          platformAccountName == other.platformAccountName &&
          content == other.content &&
          reply == other.reply &&
          status == other.status &&
          sentiment == other.sentiment &&
          time == other.time &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      sender.hashCode ^
      platform.hashCode ^
      platformAccountId.hashCode ^
      platformAccountName.hashCode ^
      content.hashCode ^
      reply.hashCode ^
      status.hashCode ^
      sentiment.hashCode ^
      time.hashCode ^
      timestamp.hashCode;
}

class Conversation {
  final String key;
  final String sender;
  final String platform;
  final String? platformAccountId;
  final String? platformAccountName;
  final String lastMessage;
  final String timestamp;
  final String time;
  final bool unread;
  final List<AiInteraction> messages;

  Conversation({
    required this.key,
    required this.sender,
    required this.platform,
    this.platformAccountId,
    this.platformAccountName,
    required this.lastMessage,
    required this.timestamp,
    required this.time,
    this.unread = false,
    required this.messages,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Conversation &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          sender == other.sender &&
          platform == other.platform &&
          platformAccountId == other.platformAccountId &&
          platformAccountName == other.platformAccountName &&
          lastMessage == other.lastMessage &&
          timestamp == other.timestamp &&
          time == other.time &&
          unread == other.unread &&
          messages == other.messages;

  @override
  int get hashCode =>
      key.hashCode ^
      sender.hashCode ^
      platform.hashCode ^
      platformAccountId.hashCode ^
      platformAccountName.hashCode ^
      lastMessage.hashCode ^
      timestamp.hashCode ^
      time.hashCode ^
      unread.hashCode ^
      messages.hashCode;
}
