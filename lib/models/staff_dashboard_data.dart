class StaffDashboardData {
  final StaffProfileInfo profile;
  final NextShift? nextShift;
  final StaffSummary summary;
  final List<ShiftItem> upcomingShifts;
  final List<AttendanceItem> recentAttendance;
  final List<PayrollItem> payroll;

  StaffDashboardData({
    required this.profile,
    this.nextShift,
    required this.summary,
    this.upcomingShifts = const [],
    this.recentAttendance = const [],
    this.payroll = const [],
  });

  factory StaffDashboardData.fromJson(Map<String, dynamic> json) {
    return StaffDashboardData(
      profile: StaffProfileInfo.fromJson(json['profile'] ?? {}),
      nextShift: json['next_shift'] != null ? NextShift.fromJson(json['next_shift']) : null,
      summary: StaffSummary.fromJson(json['summary'] ?? {}),
      upcomingShifts: (json['upcoming_shifts'] as List?)?.map((j) => ShiftItem.fromJson(j)).toList() ?? [],
      recentAttendance: (json['recent_attendance'] as List?)?.map((j) => AttendanceItem.fromJson(j)).toList() ?? [],
      payroll: (json['payroll'] as List?)?.map((j) => PayrollItem.fromJson(j)).toList() ?? [],
    );
  }
}

class StaffProfileInfo {
  final String name;
  final String role;
  final double? hourlyRate;
  final String? avatarUrl;

  StaffProfileInfo({required this.name, required this.role, this.hourlyRate, this.avatarUrl});

  factory StaffProfileInfo.fromJson(Map<String, dynamic> json) {
    return StaffProfileInfo(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      avatarUrl: json['avatar_url'],
    );
  }
}

class NextShift {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  NextShift({required this.id, required this.date, required this.startTime, required this.endTime, required this.status});

  factory NextShift.fromJson(Map<String, dynamic> json) {
    return NextShift(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}') ?? 0,
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? 'scheduled',
    );
  }
}

class StaffSummary {
  final double weeklyHours;
  final double monthlyHours;
  final double monthlyPayout;

  StaffSummary({required this.weeklyHours, required this.monthlyHours, required this.monthlyPayout});

  factory StaffSummary.fromJson(Map<String, dynamic> json) {
    return StaffSummary(
      weeklyHours: (json['weekly_hours'] as num?)?.toDouble() ?? 0,
      monthlyHours: (json['monthly_hours'] as num?)?.toDouble() ?? 0,
      monthlyPayout: (json['monthly_payout'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ShiftItem {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  ShiftItem({required this.id, required this.date, required this.startTime, required this.endTime, required this.status});

  factory ShiftItem.fromJson(Map<String, dynamic> json) {
    return ShiftItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}') ?? 0,
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? 'scheduled',
    );
  }
}

class AttendanceItem {
  final int id;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final double totalHours;

  AttendanceItem({required this.id, required this.date, this.checkIn, this.checkOut, required this.totalHours});

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}') ?? 0,
      date: json['date'] ?? '',
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PayrollItem {
  final int id;
  final String period;
  final double baseSalary;
  final double overtimePay;
  final double tipsShare;
  final double totalPayout;
  final String status;

  PayrollItem({
    required this.id, required this.period,
    required this.baseSalary, required this.overtimePay,
    required this.tipsShare, required this.totalPayout,
    required this.status,
  });

  factory PayrollItem.fromJson(Map<String, dynamic> json) {
    return PayrollItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? ''}') ?? 0,
      period: json['period'] ?? '',
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0,
      overtimePay: (json['overtime_pay'] as num?)?.toDouble() ?? 0,
      tipsShare: (json['tips_share'] as num?)?.toDouble() ?? 0,
      totalPayout: (json['total_payout'] as num?)?.toDouble() ?? 0,
      status: json['status'] ?? 'pending',
    );
  }
}
