class Shift {
  final int id;
  final String name;
  final String? description;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final int? staffCount;

  Shift({
    required this.id,
    required this.name,
    this.description,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.staffCount,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] is int ? json['id'] : int.parse('${json['id']}'),
      name: json['name'] ?? '',
      description: json['description'],
      dayOfWeek: json['day_of_week'] ?? 'Monday',
      startTime: json['start_time'] ?? '09:00',
      endTime: json['end_time'] ?? '17:00',
      staffCount: json['staff_count'] is int ? json['staff_count'] : int.tryParse('${json['staff_count'] ?? 0}'),
    );
  }
}
