class AppNotification {
  final int id;
  final String title;
  final String message;
  final String? type;
  final String status;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    required this.status,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (int.tryParse('$rawId') ?? 0);
    return AppNotification(
      id: id,
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? '').toString(),
      type: json['type']?.toString(),
      status: (json['status'] ?? 'unread').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  bool get isUnread => status == 'unread';
}
