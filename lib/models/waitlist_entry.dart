class WaitlistEntry {
  final int id;
  final int? tableId;
  final String? tableName;
  final String guestName;
  final String? phone;
  final int partySize;
  final String status;
  final String? notes;
  final String? estimatedWait;
  final String createdAt;

  WaitlistEntry({
    required this.id,
    this.tableId,
    this.tableName,
    required this.guestName,
    this.phone,
    required this.partySize,
    required this.status,
    this.notes,
    this.estimatedWait,
    required this.createdAt,
  });

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) {
    return WaitlistEntry(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      tableId: json['table_id'] is int ? json['table_id'] : int.tryParse('${json['table_id'] ?? ''}'),
      tableName: json['table_name'] ?? json['table']['name'] ?? '',
      guestName: json['customer_name'] ?? '',
      phone: json['customer_phone'],
      partySize: json['party_size'] ?? 1,
      status: json['status'] ?? 'waiting',
      notes: json['notes'],
      estimatedWait: json['estimated_wait'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
