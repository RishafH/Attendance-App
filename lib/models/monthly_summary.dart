import 'attendance_record.dart';

class MonthlySummary {
  final int month;
  final int year;
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int totalBills;
  final double totalIncentives;
  final double totalSalary;
  final double averageBillsPerDay;

  MonthlySummary({
    required this.month,
    required this.year,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.absentDays,
    required this.totalBills,
    required this.totalIncentives,
    required this.totalSalary,
    required this.averageBillsPerDay,
  });

  // Create summary from attendance records
  factory MonthlySummary.fromAttendanceRecords(
    List<AttendanceRecord> records,
    int month,
    int year,
  ) {
    final filteredRecords = records.where((record) =>
        record.date.month == month && record.date.year == year).toList();

    int totalWorkingDays = filteredRecords.length;
    int presentDays = filteredRecords.where((record) => record.isPresent).length;
    int absentDays = totalWorkingDays - presentDays;
    
    int totalBills = filteredRecords.fold(0, (sum, record) => sum + record.billsCount);
    double totalIncentives = filteredRecords.fold(0.0, (sum, record) => sum + record.incentives);
    double totalSalary = filteredRecords.fold(0.0, (sum, record) => sum + record.totalSalary);
    
    double averageBillsPerDay = presentDays > 0 ? totalBills / presentDays : 0.0;

    return MonthlySummary(
      month: month,
      year: year,
      totalWorkingDays: totalWorkingDays,
      presentDays: presentDays,
      absentDays: absentDays,
      totalBills: totalBills,
      totalIncentives: totalIncentives,
      totalSalary: totalSalary,
      averageBillsPerDay: averageBillsPerDay,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'totalWorkingDays': totalWorkingDays,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'totalBills': totalBills,
      'totalIncentives': totalIncentives,
      'totalSalary': totalSalary,
      'averageBillsPerDay': averageBillsPerDay,
    };
  }

  // Get month name
  String get monthName {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Get attendance percentage
  double get attendancePercentage {
    return totalWorkingDays > 0 ? (presentDays / totalWorkingDays) * 100 : 0.0;
  }
}