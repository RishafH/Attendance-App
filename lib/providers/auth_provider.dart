import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthStatus _status = AuthStatus.idle;
  Employee? _currentEmployee;
  String? _errorMessage;
  String? _token;

  // Getters
  AuthStatus get status => _status;
  Employee? get currentEmployee => _currentEmployee;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentEmployee != null;
  String? get token => _token;

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedEmployeeData = prefs.getString('employee_data');

      if (savedToken != null && savedEmployeeData != null) {
        _token = savedToken;
        // You could validate token with backend here
        // For now, we'll trust the stored data
        _currentEmployee = Employee.fromJson({
          'id': prefs.getString('employee_id') ?? '',
          'username': prefs.getString('employee_username') ?? '',
          'name': prefs.getString('employee_name') ?? '',
          'email': prefs.getString('employee_email'),
          'phone': prefs.getString('employee_phone'),
          'createdAt': DateTime.now().toIso8601String(),
        });
        
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Failed to check authentication status';
    }
    
    notifyListeners();
  }

  // Login (Demo mode - no backend required)
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Demo login - accept 'demo'/'demo' or any credentials
      if ((username == 'demo' && password == 'demo') || 
          (username.isNotEmpty && password.isNotEmpty)) {
        
        // Create demo employee data
        _currentEmployee = Employee.fromJson({
          'id': 'demo_001',
          'username': username,
          'name': username == 'demo' ? 'Demo User' : username.toUpperCase(),
          'email': '${username}@pegas.com',
          'phone': '+1234567890',
          'createdAt': DateTime.now().toIso8601String(),
        });
        
        _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('employee_id', _currentEmployee!.id);
        await prefs.setString('employee_username', _currentEmployee!.username);
        await prefs.setString('employee_name', _currentEmployee!.name);
        if (_currentEmployee!.email != null) {
          await prefs.setString('employee_email', _currentEmployee!.email!);
        }
        if (_currentEmployee!.phone != null) {
          await prefs.setString('employee_phone', _currentEmployee!.phone!);
        }
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid credentials. Try: demo/demo';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset state
      _token = null;
      _currentEmployee = null;
      _errorMessage = null;
      _status = AuthStatus.unauthenticated;
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed';
      notifyListeners();
    }
  }

  // Register (if needed in future)
  Future<bool> register({
    required String username,
    required String password,
    required String name,
    String? email,
    String? phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(
        username: username,
        password: password,
        name: name,
        email: email,
        phone: phone,
      );
      
      if (result['success'] == true) {
        // Automatically login after successful registration
        return await login(username, password);
      } else {
        _status = AuthStatus.error;
        _errorMessage = result['message'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update profile (if needed)
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (_currentEmployee == null) return false;

    try {
      final updatedEmployee = _currentEmployee!.copyWith(
        name: name ?? _currentEmployee!.name,
        email: email ?? _currentEmployee!.email,
        phone: phone ?? _currentEmployee!.phone,
      );

      // Update local state
      _currentEmployee = updatedEmployee;
      
      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('employee_name', updatedEmployee.name);
      if (updatedEmployee.email != null) {
        await prefs.setString('employee_email', updatedEmployee.email!);
      }
      if (updatedEmployee.phone != null) {
        await prefs.setString('employee_phone', updatedEmployee.phone!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }
}