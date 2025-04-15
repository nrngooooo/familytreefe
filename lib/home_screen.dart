import 'package:familytreefe/profile.dart';
import 'package:flutter/material.dart';
import 'family_tree_screen.dart';
import 'api/api_service.dart';
import 'clan_members_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({super.key, required this.authService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _selectedIndex == 1
              ? FamilyTreeScreen(authService: widget.authService)
              : (_selectedIndex == 2
                  ? ProfileScreen(
                    authService: widget.authService,
                    uid: widget.authService.userInfo?['uid'] ?? '',
                  )
                  : ClanMembersScreen(authService: widget.authService)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey[300],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Овгийн гишүүд',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: 'Ургийн мод',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профайл'),
        ],
      ),
    );
  }
}
