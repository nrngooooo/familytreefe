import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'api/api_service.dart'; // Import the AuthService
import 'register.dart'; // Import the RegisterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // Function to handle login
  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Clear any previous error messages
    });

    final authService = AuthService();

    bool success = await authService.login(
      emailController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      setState(() {
        errorMessage = 'Нэвтрэхэд алдаа гарлаа. Шалгана уу.';
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

              // Email Input
              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
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
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    hintText: 'Нууц үг',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                    width: 200,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'нэвтрэх',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),

              // Error Message (if any)
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),

              const SizedBox(height: 20),

              // Register Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Бүртгэлгүй бол?', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () {
                      // Navigate to Register Screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Энд дарна уу',
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
