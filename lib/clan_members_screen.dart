import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';

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
    _searchController.addListener(_filterMembers);
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

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMembers =
          members
              .where(
                (member) =>
                    member.name.toLowerCase().contains(query) ||
                    (member.lastname?.toLowerCase().contains(query) ?? false),
              )
              .toList();
    });
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddFamilyMemberDialog(
          authService: widget.authService,
          onMemberAdded: () {
            _loadFamilyMembers();
          },
        );
      },
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
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _filterMembers();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Хайх',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Members List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        return Padding(
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
                                const CircleAvatar(
                                  backgroundColor: Colors.black,
                                  radius: 20,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddFamilyMemberDialog extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onMemberAdded;

  const AddFamilyMemberDialog({
    super.key,
    required this.authService,
    required this.onMemberAdded,
  });

  @override
  _AddFamilyMemberDialogState createState() => _AddFamilyMemberDialogState();
}

class _AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _biographyController = TextEditingController();
  String _selectedGender = 'Эр';
  DateTime _selectedBirthDate = DateTime.now();
  DateTime? _selectedDeathDate;
  String? _selectedPlaceId;
  String? _selectedUyeId;
  String? _selectedUrgiinOvogId;
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _uye = [];
  List<Map<String, dynamic>> _urgiinOvog = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final places = await widget.authService.getPlaces();
      final uye = await widget.authService.getUye();
      final urgiinOvog = await widget.authService.getUrgiinOvog();

      setState(() {
        _places = places;
        _uye = uye;
        _urgiinOvog = urgiinOvog;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isBirthDate
              ? _selectedBirthDate
              : (_selectedDeathDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _selectedBirthDate = picked;
        } else {
          _selectedDeathDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final member = FamilyMember(
          name: _nameController.text,
          lastname: _lastnameController.text,
          gender: _selectedGender,
          birthdate: _selectedBirthDate,
          diedate: _selectedDeathDate,
          biography: _biographyController.text,
          placeId: _selectedPlaceId,
          uyeId: _selectedUyeId,
          urgiinOvogId: _selectedUrgiinOvogId,
        );

        final success = await widget.authService.createFamilyMember(member);
        if (success && mounted) {
          Navigator.of(context).pop();
          widget.onMemberAdded();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating member: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Овгийн гишүүн нэмэх'),
      content:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Нэр',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нэр оруулна уу';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _lastnameController,
                        decoration: const InputDecoration(
                          labelText: 'Овог',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Хүйс',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Эр', child: Text('Эр')),
                          DropdownMenuItem(value: 'Эм', child: Text('Эм')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: const Text('Төрсөн огноо'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedBirthDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: const Text('Нас барсан огноо'),
                        subtitle: Text(
                          _selectedDeathDate != null
                              ? DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDeathDate!)
                              : 'Тодорхойгүй',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, false),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedPlaceId,
                        decoration: const InputDecoration(
                          labelText: 'Төрсөн газар',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _places.map((place) {
                              return DropdownMenuItem<String>(
                                value: place['element_id']?.toString(),
                                child: Text(
                                  place['name']?.toString() ?? 'Unknown',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPlaceId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedUyeId,
                        decoration: const InputDecoration(
                          labelText: 'Үе',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _uye.map((uye) {
                              return DropdownMenuItem<String>(
                                value: uye['element_id']?.toString(),
                                child: Text(
                                  uye['uyname']?.toString() ?? 'Unknown',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUyeId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedUrgiinOvogId,
                        decoration: const InputDecoration(
                          labelText: 'Ургийн овог',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _urgiinOvog.map((ovog) {
                              return DropdownMenuItem<String>(
                                value: ovog['element_id']?.toString(),
                                child: Text(
                                  ovog['urgiinovog']?.toString() ?? 'Unknown',
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUrgiinOvogId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _biographyController,
                        decoration: const InputDecoration(
                          labelText: 'Намтар',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Болих'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
          child: const Text('Нэмэх'),
        ),
      ],
    );
  }
}
