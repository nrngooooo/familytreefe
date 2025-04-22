import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart';

class AddRelationshipScreen extends StatefulWidget {
  final AuthService authService;
  final List<FamilyMember> members;
  final VoidCallback onRelationshipAdded;

  const AddRelationshipScreen({
    super.key,
    required this.authService,
    required this.members,
    required this.onRelationshipAdded,
  });

  @override
  _AddRelationshipScreenState createState() => _AddRelationshipScreenState();
}

class _AddRelationshipScreenState extends State<AddRelationshipScreen> {
  FamilyMember? _selectedFromMember;
  FamilyMember? _selectedToMember;
  String _selectedRelationshipType = 'ХҮҮХЭД';
  List<Map<String, dynamic>> _relationshipTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRelationshipTypes();
  }

  Future<void> _loadRelationshipTypes() async {
    try {
      final types = await widget.authService.getRelationshipTypes();
      setState(() {
        _relationshipTypes = types;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading relationship types: $e')),
        );
      }
    }
  }

  Future<void> _addRelationship() async {
    if (_selectedFromMember == null || _selectedToMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both family members')),
      );
      return;
    }

    // Validate that both members have valid UIDs
    if (_selectedFromMember!.uid.isEmpty || _selectedToMember!.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid member selection. Please try again.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) {
        print('Adding relationship with:');
        print('fromPersonId: ${_selectedFromMember!.uid}');
        print('toPersonId: ${_selectedToMember!.uid}');
        print('relationshipType: $_selectedRelationshipType');
      }

      final success = await widget.authService.addRelationship(
        fromPersonId: _selectedFromMember!.uid,
        toPersonId: _selectedToMember!.uid,
        relationshipType: _selectedRelationshipType,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Relationship added successfully')),
          );
          widget.onRelationshipAdded();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add relationship')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding relationship: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Харилцаа нэмэх',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // From Member Selection
            Card(
              child: ListTile(
                title: const Text('Эхлэх гишүүн'),
                subtitle: Text(_selectedFromMember?.name ?? 'Сонгох'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Эхлэх гишүүн сонгох'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.members.length,
                              itemBuilder: (context, index) {
                                final member = widget.members[index];
                                return ListTile(
                                  title: Text(
                                    '${member.lastname ?? ''} ${member.name}',
                                  ),
                                  subtitle: Text(member.relationshipType),
                                  onTap: () {
                                    if (kDebugMode) {
                                      print(
                                        'Selected from member: ${member.name} with uid: ${member.uid}',
                                      );
                                    }
                                    setState(() {
                                      _selectedFromMember = member;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // To Member Selection
            Card(
              child: ListTile(
                title: const Text('Харилцаатай гишүүн'),
                subtitle: Text(_selectedToMember?.name ?? 'Сонгох'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Харилцаатай гишүүн сонгох'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.members.length,
                              itemBuilder: (context, index) {
                                final member = widget.members[index];
                                return ListTile(
                                  title: Text(
                                    '${member.lastname ?? ''} ${member.name}',
                                  ),
                                  subtitle: Text(member.relationshipType),
                                  onTap: () {
                                    if (kDebugMode) {
                                      print(
                                        'Selected to member: ${member.name} with uid: ${member.uid}',
                                      );
                                    }
                                    setState(() {
                                      _selectedToMember = member;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Relationship Type Selection
            Card(
              child: ListTile(
                title: const Text('Харилцааны төрөл'),
                subtitle: Text(_selectedRelationshipType),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Харилцааны төрөл сонгох'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _relationshipTypes.length,
                              itemBuilder: (context, index) {
                                final type = _relationshipTypes[index];
                                return ListTile(
                                  title: Text(type['label']),
                                  onTap: () {
                                    setState(() {
                                      _selectedRelationshipType = type['type'];
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                  );
                },
              ),
            ),
            const Spacer(),
            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _addRelationship,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Харилцаа нэмэх',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
