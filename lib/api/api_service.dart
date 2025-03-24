import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // To store JWT token securely

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/api"; // Your backend API URL

  // Register method
  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      return true; // Registration successful
    } else {
      return false; // Registration failed
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username_or_email": email,
        "password": password,
      }), // Changed 'email' to 'username_or_email'
    );

    if (response.statusCode == 200) {
      // If login is successful, save the JWT token
      final data = json.decode(response.body);
      String token =
          data['access']; // JWT token (ensure your backend returns this)
      await _saveToken(token); // Save token using SharedPreferences
      return true; // Login successful
    } else {
      return false; // Login failed
    }
  }

  // Method to save the JWT token securely in SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', token);
  }

  // Method to get the saved token (to check if user is logged in)
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); // Get saved token
  }

  // Method to logout (remove the token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token'); // Remove saved token
  }
}
