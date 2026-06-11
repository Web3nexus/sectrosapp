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
    return AppNotification(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'],
      status: json['status'] ?? 'unread',
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isUnread => status == 'unread';
}
