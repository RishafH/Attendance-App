import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/attendance_record.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:3000/api'; // Change this to your backend URL

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add request interceptor for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authentication token if available
        // This will be implemented when we have token management
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        debugPrint('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Authentication endpoints
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Login failed',
        };
      } else {
        return {
          'success': false,
          'message': 'Network error. Please check your connection.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
        'name': name,
        'email': email,
        'phone': phone,
      });

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Registration failed',
        };
      } else {
        return {
          'success': false,
          'message': 'Network error. Please check your connection.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  // Attendance endpoints
  Future<List<AttendanceRecord>> getAttendanceRecords(String employeeId) async {
    try {
      final response = await _dio.get('/attendance/$employeeId');
      
      if (response.data['success'] == true) {
        final List<dynamic> recordsJson = response.data['data'] ?? [];
        return recordsJson.map((json) => AttendanceRecord.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch attendance records');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch attendance records');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<AttendanceRecord> saveAttendanceRecord(AttendanceRecord record) async {
    try {
      final response = await _dio.post('/attendance', data: record.toJson());
      
      if (response.data['success'] == true) {
        return AttendanceRecord.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to save attendance record');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to save attendance record');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<AttendanceRecord> updateAttendanceRecord(AttendanceRecord record) async {
    try {
      final response = await _dio.put('/attendance/${record.id}', data: record.toJson());
      
      if (response.data['success'] == true) {
        return AttendanceRecord.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update attendance record');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update attendance record');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> deleteAttendanceRecord(String recordId) async {
    try {
      final response = await _dio.delete('/attendance/$recordId');
      
      return response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete attendance record');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Get attendance records for a specific month
  Future<List<AttendanceRecord>> getMonthlyAttendanceRecords(
    String employeeId,
    int month,
    int year,
  ) async {
    try {
      final response = await _dio.get(
        '/attendance/$employeeId/monthly',
        queryParameters: {
          'month': month,
          'year': year,
        },
      );
      
      if (response.data['success'] == true) {
        final List<dynamic> recordsJson = response.data['data'] ?? [];
        return recordsJson.map((json) => AttendanceRecord.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch monthly attendance records');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch monthly attendance records');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Set authentication token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}