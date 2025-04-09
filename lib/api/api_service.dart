import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_member.dart';

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
            'uid': data['uid'],
            'email': data['email'] ?? '',
          };

          if (kDebugMode) {
            print("Saving user info: $userInfo");
          }

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
          print(
            "Response body: ${json.decode(utf8.decode(response.bodyBytes))}",
          );
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
    if (_token != null) {
      try {
        final response = await http.post(
          Uri.parse("$baseUrl/logout/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Token $_token",
          },
        );

        if (response.statusCode == 200) {
          await clearUserData();
        } else {
          if (kDebugMode) {
            print("Logout failed with status: ${response.statusCode}");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Logout error: $e");
        }
      }
    }
    await clearUserData();
  }

  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    if (uid.isEmpty) {
      if (kDebugMode) {
        print('Error: Empty UID provided to fetchProfile');
      }
      return null;
    }

    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return null;
    }
    if (kDebugMode) {
      print('Fetching profile from URL: $baseUrl/profile/$uid/');
    }
    final url = Uri.parse("$baseUrl/profile/$uid/");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token", // Ensure token is correct here
        },
      );

      if (response.statusCode == 200) {
        final profileData = json.decode(utf8.decode(response.bodyBytes));
        return profileData;
      } else {
        if (kDebugMode) {
          print("Failed to fetch profile: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return null; // Handle failure
      }
    } catch (e) {
      if (kDebugMode) {
        print("Profile fetch error: $e");
      }
      return null;
    }
  }

  Future<bool> createOrUpdatePerson(Map<String, dynamic> personData) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    if (_userInfo == null || _userInfo!['uid'] == null) {
      if (kDebugMode) {
        print('Error: No user info available');
      }
      return false;
    }

    final url = Uri.parse("$baseUrl/profile/${_userInfo!['uid']}/");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
        body: jsonEncode(personData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to create/update person: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Create/update person error: $e");
      }
      return false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/profile/$uid/delete/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        await clearUserData();
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to delete user: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Delete user error: $e");
      }
      return false;
    }
  }

  Future<List<FamilyMember>> getFamilyMembers() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    if (_userInfo == null || _userInfo!['uid'] == null) {
      if (kDebugMode) {
        print('Error: No user info available');
      }
      return [];
    }

    try {
      // First get the user's profile to get their person
      final profile = await fetchProfile(_userInfo!['uid']);
      if (profile == null) {
        return [];
      }

      // Get family members using the user's UID directly
      final response = await http.get(
        Uri.parse("$baseUrl/family/${_userInfo!['uid']}/list/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List<FamilyMember> members = [];

        // Add the user's own information first
        if (profile['person'] != null) {
          members.add(
            FamilyMember(
              fromPersonId: _userInfo!['uid'],
              relationshipType: 'ӨӨРӨӨ',
              name: profile['person']['name'],
              lastname: profile['person']['lastname'],
              gender: profile['person']['gender'],
              birthdate: DateTime.parse(profile['person']['birthdate']),
              diedate:
                  profile['person']['diedate'] != null
                      ? DateTime.parse(profile['person']['diedate'])
                      : null,
              biography: profile['person']['biography'],
              uyeId: profile['person']['generation']?['uid'],
              placeId: profile['person']['birthplace']?['uid'],
              urgiinOvogId: profile['person']['urgiinovog']?['uid'],
            ),
          );
        }

        // Convert all family members to a flat list
        data.forEach((relationship, people) {
          for (var person in people) {
            members.add(
              FamilyMember(
                fromPersonId: _userInfo!['uid'],
                relationshipType: relationship,
                name: person['name'],
                lastname: person['lastname'],
                gender: person['gender'],
                birthdate: DateTime.parse(person['birthdate']),
                diedate:
                    person['diedate'] != null
                        ? DateTime.parse(person['diedate'])
                        : null,
                biography: person['biography'],
                uyeId: person['generation']?['uid'],
                placeId: person['birthplace']?['uid'],
                urgiinOvogId: person['urgiinovog']?['uid'],
              ),
            );
          }
        });

        return members;
      } else {
        if (kDebugMode) {
          print("Failed to load family members: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching family members: $e");
      }
      return [];
    }
  }

  Future<bool> createFamilyMember(FamilyMember member) async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/family/add/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
        body: json.encode(member.toJson()),
      );

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print('Error response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating family member: $e');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPlaces() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/places/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map(
              (item) => {
                'uid': item['uid'],
                'name': item['name'],
                'country': item['country'],
              },
            )
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load places: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching places: $e");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUye() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/uye/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map(
              (item) => {
                'uid': item['uid'],
                'uyname': item['uyname'],
                'level': item['level'],
              },
            )
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load uye: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching uye: $e");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUrgiinOvog() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/urgiinovog/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map(
              (item) => {'uid': item['uid'], 'urgiinovog': item['urgiinovog']},
            )
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load urgiin ovog: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching urgiin ovog: $e");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRelationshipTypes() async {
    if (_token == null || _token!.isEmpty) {
      if (kDebugMode) {
        print('Error: No authentication token available');
      }
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/relationship-types/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $_token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .map((item) => {'type': item['type'], 'label': item['label']})
            .toList();
      } else {
        if (kDebugMode) {
          print("Failed to load relationship types: ${response.statusCode}");
          print("Response body: ${utf8.decode(response.bodyBytes)}");
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching relationship types: $e");
      }
      return [];
    }
  }
}
