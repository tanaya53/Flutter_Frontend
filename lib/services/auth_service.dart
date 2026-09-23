import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<UserModel> login(String username, String password) async {
    final response = await _api.post(ApiConstants.login, {
      'username': username.trim(),
      'password': password,
    });

    final accessToken = response['tokens']['access'];
    await _api.setToken(accessToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_json', jsonEncode(response['user']));

    return UserModel.fromJson(response['user']);
  }

  Future<UserModel> registerSchool({
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
    final response = await _api.post(ApiConstants.registerSchool, {
      'school_name': schoolName.trim(),
      'school_id': schoolId.trim().toUpperCase(),
      'district': district.trim(),
      'state': state.trim(),
      'principal_name': principalName.trim(),
      'principal_email': principalEmail.trim(),
      'principal_phone': principalPhone.trim(),
      'username': username.trim(),
      'password': password,
    });

    final accessToken = response['tokens']['access'];
    await _api.setToken(accessToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user_json', jsonEncode(response['user']));

    return UserModel.fromJson(response['user']);
  }

  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
    required String schoolId,
  }) async {
    final response = await _api.post(ApiConstants.registerUser, {
      'full_name': fullName.trim(),
      'username': username.trim(),
      'email': email.trim(),
      'phone_number': phoneNumber.trim(),
      'password': password,
      'role': role,
      'school_id': schoolId.trim().toUpperCase(),
    });

    return response;
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cached_user_json');
    if (jsonStr != null) {
      try {
        return UserModel.fromJson(jsonDecode(jsonStr));
      } catch (_) {}
    }
    return null;
  }

  Future<void> logout() async {
    await _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user_json');
  }
}
