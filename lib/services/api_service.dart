import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('jwt_access_token', token);
    } else {
      await prefs.remove('jwt_access_token');
    }
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_access_token');
    return _token;
  }

  Map<String, String> _headers(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String url, {bool useCacheIfOffline = true}) async {
    final token = await getToken();
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers(token))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        // Cache successful response for offline usage
        if (useCacheIfOffline) {
          await prefs.setString('cache_$url', response.body);
        }
        return decoded;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response.body),
        );
      }
    } catch (e) {
      // Offline fallback: check if cached response exists
      if (useCacheIfOffline && prefs.containsKey('cache_$url')) {
        final cachedData = prefs.getString('cache_$url');
        if (cachedData != null) {
          return jsonDecode(cachedData);
        }
      }
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network connection error. Operating in offline cached mode if available.',
      );
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final token = await getToken();
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response.body),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Could not connect to server. Please verify network.',
      );
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('detail')) return data['detail'].toString();
        return data.values.first.toString();
      }
    } catch (_) {}
    return 'An unexpected server error occurred ($body)';
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
