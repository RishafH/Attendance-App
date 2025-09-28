import 'package:intl/intl.dart';

class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime date;
  final bool isPresent;
  final DateTime? startTime;
  final DateTime? endTime;
  final int billsCount;
  final String? remarks;
  final double basePayment;
  final double incentives;
  final double totalSalary;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.isPresent,
    this.startTime,
    this.endTime,
    required this.billsCount,
    this.remarks,
    required this.basePayment,
    required this.incentives,
    required this.totalSalary,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate payment based on business logic
  static AttendanceRecord calculatePayment({
    String? id,
    required String employeeId,
    required DateTime date,
    required bool isPresent,
    DateTime? startTime,
    DateTime? endTime,
    required int billsCount,
    String? remarks,
  }) {
    double basePayment = 0.0;
    double incentives = 0.0;

    if (isPresent) {
      // Base payment is 1000 if present
      basePayment = 1000.0;
      
      // If bills < 10, give half payment
      if (billsCount < 10) {
        basePayment = 500.0;
      }
      
      // Calculate incentives
      if (billsCount >= 25) {
        incentives = 1000.0;
      } else if (billsCount >= 20) {
        incentives = 500.0;
      }
    }

    double totalSalary = basePayment + incentives;
    DateTime now = DateTime.now();

    return AttendanceRecord(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employeeId,
      date: date,
      isPresent: isPresent,
      startTime: startTime,
      endTime: endTime,
      billsCount: billsCount,
      remarks: remarks,
      basePayment: basePayment,
      incentives: incentives,
      totalSalary: totalSalary,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'isPresent': isPresent,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'billsCount': billsCount,
      'remarks': remarks,
      'basePayment': basePayment,
      'incentives': incentives,
      'totalSalary': totalSalary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON response
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] ?? json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: DateTime.parse(json['date']),
      isPresent: json['isPresent'] ?? false,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      billsCount: json['billsCount'] ?? 0,
      remarks: json['remarks'],
      basePayment: (json['basePayment'] ?? 0).toDouble(),
      incentives: (json['incentives'] ?? 0).toDouble(),
      totalSalary: (json['totalSalary'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a copy with updated fields
  AttendanceRecord copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    bool? isPresent,
    DateTime? startTime,
    DateTime? endTime,
    int? billsCount,
    String? remarks,
    double? basePayment,
    double? incentives,
    double? totalSalary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      isPresent: isPresent ?? this.isPresent,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      billsCount: billsCount ?? this.billsCount,
      remarks: remarks ?? this.remarks,
      basePayment: basePayment ?? this.basePayment,
      incentives: incentives ?? this.incentives,
      totalSalary: totalSalary ?? this.totalSalary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted date string
  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  
  // Get formatted start time
  String get formattedStartTime => 
      startTime != null ? DateFormat('HH:mm').format(startTime!) : '--';
  
  // Get formatted end time
  String get formattedEndTime => 
      endTime != null ? DateFormat('HH:mm').format(endTime!) : '--';
  
  // Get status string
  String get statusString => isPresent ? 'Present' : 'Absent';
}