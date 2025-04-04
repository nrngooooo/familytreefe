import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/api";
  String? _token;
  Map<String, dynamic>? _userInfo;
  static const String _tokenKey = 'auth_token';
  static const String _userInfoKey = 'user_info';

  // Initialize shared preferences and load token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userInfoString = prefs.getString(_userInfoKey);
    if (userInfoString != null) {
      _userInfo = json.decode(userInfoString);
    }
  }

  // Save token and user info to shared preferences
  Future<void> _saveUserData(
    String token,
    Map<String, dynamic> userInfo,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userInfoKey, json.encode(userInfo));
    _token = token;
    _userInfo = userInfo;
  }

  // Clear user data from shared preferences
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userInfoKey);
    _token = null;
    _userInfo = null;
  }

  // Get current user info
  Map<String, dynamic>? get userInfo => _userInfo;

  // Check if user is logged in
  bool isLoggedIn() {
    return _token != null;
  }

  // Register method
  Future<bool> register(
    String username,
    String email,
    String password,
    String repassword,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": _token != null ? "Bearer $_token" : "",
      },
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "repassword": repassword,
      }),
    );
    try {
      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response Body: ${json.decode(utf8.decode(response.bodyBytes))}');
      }
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Бүртгэл амжилттай!');
        }
        return true; // Registration successful
      } else if (response.statusCode == 400) {
        var errorData = jsonDecode(response.body);
        if (kDebugMode) {
          print(errorData['error'] ?? 'Бүртгэл амжилтгүй. Давтан оролдоно уу');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Бүртгэлийн үйл явцад алдаа гарлаа: $e");
      }
      return false; // Handle any connection or other issues
    }
    return false; // Ensure a return value in all cases
  }

  // Login method
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login/"),
        body: jsonEncode({"username": username, "password": password}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('Response Status: ${response.statusCode}');
          print("Logged in! Response data: $data");
        }

        // Check if token exists in response
        if (data['token'] != null) {
          // Create user info object
          final userInfo = {
            'username': username,
            'element_id': data['element_id'],
            'email': data['email'] ?? '',
          };

          await _saveUserData(data['token'], userInfo);
          return true;
        } else {
          if (kDebugMode) {
            print("No token received in response");
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print("Login failed with status: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login error: $e");
      }
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    await clearUserData();
  }
}
