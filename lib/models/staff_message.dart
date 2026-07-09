class StaffMessage {
  final int id;
  final String subject;
  final String body;
  final String from;
  final bool read;
  final String? readAt;
  final String createdAt;

  StaffMessage({
    required this.id, required this.subject, required this.body,
    required this.from, required this.read, this.readAt, required this.createdAt,
  });

  factory StaffMessage.fromJson(Map<String, dynamic> json) {
    return StaffMessage(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}') ?? 0,
      subject: json['subject'] ?? '',
      body: json['body'] ?? '',
      from: json['from'] ?? '',
      read: json['read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
