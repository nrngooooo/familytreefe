import 'package:familytreefe/api/api_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final AuthService authService;
  final String uid; // Add uid here

  const ProfileScreen({
    super.key,
    required this.authService,
    required this.uid,
  }); // Pass uid

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.authService.isLoggedIn()) {
      try {
        final data = await widget.authService.fetchProfile(widget.uid);
        setState(() {
          profile = data;
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching profile: $e");
        setState(() {
          isLoading = false;
          profile = null;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профайл")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : profile == null
              ? const Center(child: Text("Профайл ачааллахад алдаа гарлаа"))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Нэвтэрсэн хэрэглэгч:",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text("Нэр: ${profile!['username']}"),
                    Text("Имэйл: ${profile!['email']}"),
                    const Divider(height: 32),
                    Text(
                      "Хувь хүний мэдээлэл:",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (profile!['person'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Нэр: ${profile!['person']['name']}"),
                          Text(
                            "Төрсөн огноо: ${profile!['person']['birthdate'] ?? 'Тодорхойгүй'}",
                          ),
                          Text(
                            "Хүйс: ${profile!['person']['gender'] ?? 'Тодорхойгүй'}",
                          ),
                        ],
                      )
                    else
                      const Text("Хувь хүний мэдээлэл бүртгэгдээгүй."),
                  ],
                ),
              ),
    );
  }
}
