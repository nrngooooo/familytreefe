import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/api"; // Your backend API URL
  String? _token; // Store token here

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
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${json.decode(utf8.decode(response.bodyBytes))}');
      // Check if the response is successful
      if (response.statusCode == 201) {
        print('Бүртгэл амжилттай!');
        return true; // Registration successful
      } else if (response.statusCode == 400) {
        var errorData = jsonDecode(response.body);
        print(errorData['error'] ?? 'Бүртгэл амжилтгүй. Давтан оролдоно уу');
        return false;
      }
    } catch (e) {
      print("Бүртгэлийн үйл явцад алдаа гарлаа: $e");
      return false; // Handle any connection or other issues
    }
    return false; // Ensure a return value in all cases
  }

  // Login method
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      body: jsonEncode({"username": username, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print('Response Status: ${response.statusCode}');
      print("Logged in! Element ID: ${data['element_id']}");
      _token = data['token']; // Store the token after successful login
      return true; // Login successful
    } else {
      print("Login failed!");
      return false; // Login failed
    }
  }

  // Logout method
  void logout() {
    _token = null; // Clear the stored token
  }
}
