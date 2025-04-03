import 'package:flutter/material.dart';
import 'package:familytreefe/api/api_service.dart';
import 'package:familytreefe/login.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;

  const RegisterScreen({super.key, required this.authService});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String repassword = _rePasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        repassword.isEmpty) {
      setState(() {
        _errorMessage = 'Бүх талбаруудыг бөглөнө үү';
      });
      return;
    }

    if (password != repassword) {
      setState(() {
        _errorMessage = 'Нууц үг таарахгүй байна';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success = await widget.authService.register(
        username,
        email,
        password,
        repassword,
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => LoginScreen(authService: widget.authService),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Бүртгэл амжилтгүй. Давтан оролдоно уу';
        });
      }
    } catch (e) {
      print("Server Response: $e"); // Debug the error
      setState(() {
        _errorMessage = 'Серверийн алдаа: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
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
              const SizedBox(height: 15),

              // Re-enter Password Input
              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _rePasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    hintText: 'Нууц үг давтах',
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
