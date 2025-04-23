import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';
import 'add_clan_member_screen.dart';
import 'clan_member_detail_screen.dart';
import 'add_relationship_screen.dart';
import 'edit_clan_member_screen.dart';

class ClanMembersScreen extends StatefulWidget {
  final AuthService authService;

  const ClanMembersScreen({super.key, required this.authService});

  @override
  _ClanMembersScreenState createState() => _ClanMembersScreenState();
}

class _ClanMembersScreenState extends State<ClanMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FamilyMember> members = [];
  List<FamilyMember> filteredMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    _searchController.addListener(_debounceFilterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final loadedMembers = await widget.authService.getFamilyMembers();
      setState(() {
        members = loadedMembers;
        filteredMembers = loadedMembers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading members: $e')));
      }
    }
  }

  void _debounceFilterMembers() {
    // Apply debouncing logic to avoid firing immediately on every character typed
    Future.delayed(const Duration(milliseconds: 300), () {
      _filterMembers();
    });
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMembers =
          members.where((member) {
            return member.name.toLowerCase().contains(query) ||
                (member.lastname?.toLowerCase().contains(query) ?? false);
          }).toList();
    });
  }

  void _showAddMemberScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddClanMemberScreen(
              authService: widget.authService,
              onMemberAdded: () {
                _loadFamilyMembers();
              },
              fromPersonId: widget.authService.userInfo?['uid'] ?? '',
              relationshipType: 'ХҮҮХЭД', // Default relationship type
            ),
      ),
    );
  }

  void _showAddRelationshipScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddRelationshipScreen(
              authService: widget.authService,
              members: members,
              onRelationshipAdded: () {
                _loadFamilyMembers();
              },
            ),
      ),
    );
  }

  void _showEditMemberScreen(FamilyMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditClanMemberScreen(
              authService: widget.authService,
              onMemberUpdated: () {
                _loadFamilyMembers();
              },
              member: member,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Овгийн гишүүд',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.link, color: Colors.black),
            onPressed: _showAddRelationshipScreen,
            tooltip: 'Харилцаа нэмэх',
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.black,
                                ),
                                hintText: 'Хайх утгаа оруулна уу!',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _showAddMemberScreen,
                            tooltip: 'Овгийн гишүүн нэмэх',
                            iconSize: 20,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Members List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ClanMemberDetailScreen(member: member),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        member.gender == 'Эр'
                                            ? Colors.blue
                                            : Colors.pink,
                                    radius: 20,
                                    child: Icon(
                                      member.gender == 'Эр'
                                          ? Icons.male
                                          : Icons.female,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${member.lastname ?? ''} ${member.name}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Төрсөн: ${DateFormat('yyyy-MM-dd').format(member.birthdate)}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    ),
                                    onPressed:
                                        () => _showEditMemberScreen(member),
                                    tooltip: 'Засах',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
