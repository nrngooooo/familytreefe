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
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 201) {
      print('Бүртгэл амжилттай!');
    } else if (response.statusCode == 400) {
      var errorData = jsonDecode(response.body);
      print(errorData['error'] ?? 'Бүртгэл амжилтгүй. Давтан оролдоно уу');
      return false;
    } else {
      print('Бүртгэлийн үйл явцад алдаа гарлаа. Дахин оролдоно уу');
      return false;
    }
    return false; // Ensure all code paths return a value
  }

  // Login method
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      body: jsonEncode({"username": username, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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

    // Optionally, you can redirect the user to the login screen here
    // For example, using Navigator:
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
