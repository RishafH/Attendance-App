import 'package:flutter/material.dart';
import 'package:pegas_attendance_app/services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_record.dart';
import '../models/monthly_summary.dart';

enum AttendanceStatus { idle, loading, success, error }



class AttendanceProvider with ChangeNotifier {
  
  final ApiService _apiService = ApiService();

  List<AttendanceRecord> _attendanceRecords = [];
  AttendanceStatus _status = AttendanceStatus.idle;
  String? _errorMessage;
  
  // Current form data
  DateTime _selectedDate = DateTime.now();
  bool _isPresent = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _billsCount = 0;
  String _remarks = '';

  // Getters
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceStatus get status => _status;
  String? get errorMessage => _errorMessage;
  
  DateTime get selectedDate => _selectedDate;
  bool get isPresent => _isPresent;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;
  int get billsCount => _billsCount;
  String get remarks => _remarks;

  // Calculated values
  double get basePayment {
    if (!_isPresent) return 0.0;
    return _billsCount < 10 ? 500.0 : 1000.0;
  }

  double get incentives {
    if (!_isPresent) return 0.0;
    if (_billsCount >= 25) return 1000.0;
    if (_billsCount >= 20) return 500.0;
    return 0.0;
  }

  double get totalDailySalary => basePayment + incentives;

  // Form setters
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setPresent(bool isPresent) {
    _isPresent = isPresent;
    if (!isPresent) {
      _startTime = null;
      _endTime = null;
      _billsCount = 0;
    }
    notifyListeners();
  }

  void setStartTime(TimeOfDay? time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay? time) {
    _endTime = time;
    notifyListeners();
  }

  void setBillsCount(int count) {
    _billsCount = count;
    notifyListeners();
  }

  void setRemarks(String remarks) {
    _remarks = remarks;
    notifyListeners();
  }

  // Reset form
  void resetForm() {
    _selectedDate = DateTime.now();
    _isPresent = true;
    _startTime = null;
    _endTime = null;
    _billsCount = 0;
    _remarks = '';
    notifyListeners();
  }

  // Load attendance records
  Future<void> loadAttendanceRecords(String employeeId) async {
    _status = AttendanceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _attendanceRecords = await _apiService.getAttendanceRecords(employeeId);
      _status = AttendanceStatus.success;
    } catch (e) {
      _status = AttendanceStatus.error;
      _errorMessage = e.toString();
      _attendanceRecords = [];
    }
    notifyListeners();
  }

  // Save attendance record
  Future<bool> saveAttendanceRecord(String employeeId) async {
    _status = AttendanceStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      DateTime? startDateTime;
      DateTime? endDateTime;
      
      if (_startTime != null) {
        startDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }
      
      if (_endTime != null) {
        endDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      final record = AttendanceRecord.calculatePayment(
        employeeId: employeeId,
        date: _selectedDate,
        isPresent: _isPresent,
        startTime: startDateTime,
        endTime: endDateTime,
        billsCount: _billsCount,
        remarks: _remarks.isNotEmpty ? _remarks : null,
      );

      // Save to local storage (Demo mode)
      final prefs = await SharedPreferences.getInstance();
      
      // Update local list
      final existingIndex = _attendanceRecords.indexWhere(
        (r) => r.date.day == _selectedDate.day &&
               r.date.month == _selectedDate.month &&
               r.date.year == _selectedDate.year
      );
      
      if (existingIndex != -1) {
        _attendanceRecords[existingIndex] = record;
      } else {
        _attendanceRecords.add(record);
      }
      
      _attendanceRecords.sort((a, b) => b.date.compareTo(a.date));
      
      // Save to SharedPreferences
      final recordsJson = json.encode(
        _attendanceRecords.map((record) => record.toJson()).toList()
      );
      await prefs.setString('attendance_records_$employeeId', recordsJson);
      
      _status = AttendanceStatus.success;
      resetForm();
      notifyListeners();
      return true;
    } catch (e) {
      _status = AttendanceStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get monthly summary
  MonthlySummary getMonthlySummary(int month, int year) {
    return MonthlySummary.fromAttendanceRecords(_attendanceRecords, month, year);
  }

  // Get records for a specific month
  List<AttendanceRecord> getRecordsForMonth(int month, int year) {
    return _attendanceRecords
        .where((record) => record.date.month == month && record.date.year == year)
        .toList();
  }

  // Check if attendance exists for date
  bool hasAttendanceForDate(DateTime date) {
    return _attendanceRecords.any((record) =>
        record.date.day == date.day &&
        record.date.month == date.month &&
        record.date.year == date.year);
  }

  // Get attendance for specific date
  AttendanceRecord? getAttendanceForDate(DateTime date) {
    try {
      return _attendanceRecords.firstWhere((record) =>
          record.date.day == date.day &&
          record.date.month == date.month &&
          record.date.year == date.year);
    } catch (e) {
      return null;
    }
  }
}