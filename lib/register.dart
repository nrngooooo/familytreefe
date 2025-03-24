import 'package:familytreefe/login.dart';
import 'package:flutter/material.dart';
import 'package:familytreefe/api/api_service.dart'; // Import the AuthService

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService(); // Initialize AuthService

  Future<void> _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Түгээмэл талбаруудыг бөглөнө үү';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool success = await _authService.register(username, email, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to home screen after successful registration
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      setState(() {
        _errorMessage = 'Бүртгэл амжилтгүй. Давтан оролдоно уу';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF008000), Color(0xFFE6F7E6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Image
              CircleAvatar(radius: 60, backgroundImage: AssetImage('logo.jpg')),
              const SizedBox(height: 40),

              // Username Input
              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                    hintText: 'Хэрэглэгчийн нэр',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Email Input
              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.black),
                    hintText: 'Имэйл',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password Input
              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    hintText: 'Нууц үг',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Register Button
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : const Text(
                            'Бүртгүүлэх',
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ),
              const SizedBox(height: 20),

              // Error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),

              const SizedBox(height: 20),

              // Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Бүртгэлтэй юу?', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Go back to login
                    },
                    child: const Text(
                      'Нэвтрэх',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
