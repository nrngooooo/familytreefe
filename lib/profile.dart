import 'package:familytreefe/api/api_service.dart';
import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class ProfileScreen extends StatefulWidget {
  final AuthService authService;
  final String uid;

  const ProfileScreen({
    super.key,
    required this.authService,
    required this.uid,
  });

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

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade700, Colors.green.shade500],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await widget.authService.logout();
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 47,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile!['username'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                profile!['email'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Хувь хүний мэдээлэл',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditProfilePage(
                              authService: widget.authService,
                              profile: profile!,
                            ),
                      ),
                    );
                    if (result == true) {
                      await _loadProfile();
                    }
                  },
                  icon: Icon(
                    profile!['person'] == null ? Icons.add : Icons.edit,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (profile!['person'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Нэр', profile!['person']['name']),
                  if (profile!['person']['lastname'] != null)
                    _buildInfoRow('Овог', profile!['person']['lastname']),
                  _buildInfoRow(
                    'Төрсөн огноо',
                    profile!['person']['birthdate'] ?? 'Тодорхойгүй',
                  ),
                  _buildInfoRow(
                    'Хүйс',
                    profile!['person']['gender'] ?? 'Тодорхойгүй',
                  ),
                  if (profile!['person']['biography'] != null)
                    _buildInfoRow('Намтар', profile!['person']['biography']),
                ],
              )
            else
              const Center(
                child: Text(
                  "Хувь хүний мэдээлэл бүртгэгдээгүй.",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : profile == null
              ? const Center(child: Text("Профайл ачааллахад алдаа гарлаа"))
              : Column(
                children: [
                  _buildProfileHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildProfileInfo(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Бүртгэл устгах'),
                              content: const Text(
                                'Та өөрийн бүртгэлийг устгахдаа итгэлтэй байна уу? Энэ үйлдлийг буцаах боломжгүй.',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Болих'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    'Устгах',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    final success = await widget.authService
                                        .deleteUser(widget.uid);
                                    if (success && mounted) {
                                      Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/login');
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Бүртгэл устгахад алдаа гарлаа',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Бүртгэл устгах',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
