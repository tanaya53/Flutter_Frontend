import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _authService.getSavedUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerSchool({
    required String schoolName,
    required String schoolId,
    required String district,
    required String state,
    required String principalName,
    required String principalEmail,
    required String principalPhone,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.registerSchool(
        schoolName: schoolName,
        schoolId: schoolId,
        district: district,
        state: state,
        principalName: principalName,
        principalEmail: principalEmail,
        principalPhone: principalPhone,
        username: username,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> registerUser({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
    required String schoolId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.registerUser(
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        role: role,
        schoolId: schoolId,
      );
      _isLoading = false;
      notifyListeners();
      return res['message'];
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  /// Quick Demo Login Helper for Testing Different Roles & Schools
  Future<bool> quickDemoLogin(String role, {String school = 'ASH001'}) async {
    final r = role.toLowerCase().trim();
    final s = school.toLowerCase().trim();
    final username = '${r}_$s';
    return login(username, 'password123');
  }
}
