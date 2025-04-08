import 'package:familytreefe/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatefulWidget {
  final AuthService authService;
  final Map<String, dynamic> profile;

  const EditProfilePage({
    super.key,
    required this.authService,
    required this.profile,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lastnameController;
  late DateTime? _birthdate;
  late String _selectedGender;
  late final TextEditingController _biographyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile['person']?['name'] ?? '',
    );
    _lastnameController = TextEditingController(
      text: widget.profile['person']?['lastname'] ?? '',
    );
    _selectedGender = widget.profile['person']?['gender'] ?? 'Эр';
    if (widget.profile['person']?['birthdate'] != null) {
      _birthdate = DateTime.parse(widget.profile['person']?['birthdate']);
    }
    _biographyController = TextEditingController(
      text: widget.profile['person']?['biography'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _biographyController.dispose();
    super.dispose();
  }

  Future<void> _savePerson() async {
    if (_formKey.currentState!.validate()) {
      try {
        final personData = {
          'name': _nameController.text,
          'lastname': _lastnameController.text,
          'gender': _selectedGender,
          'birthdate':
              _birthdate != null
                  ? DateFormat('yyyy-MM-dd').format(_birthdate!)
                  : null,
          'biography': _biographyController.text,
        };

        final success = await widget.authService.createOrUpdatePerson(
          personData,
        );
        if (success && mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Мэдээлэл хадгалахад алдаа гарлаа'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Алдаа гарлаа: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хувь хүний мэдээлэл засах'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _savePerson),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Нэр *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Нэр оруулна уу';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastnameController,
                        decoration: InputDecoration(
                          labelText: 'Овог',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Хүйс',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
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
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _birthdate == null
                              ? 'Төрсөн огноо сонгох'
                              : 'Төрсөн огноо: ${DateFormat('yyyy-MM-dd').format(_birthdate!)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        leading: const Icon(Icons.calendar_today),
                        trailing: const Icon(Icons.arrow_drop_down),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _birthdate ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _birthdate = date;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _biographyController,
                        decoration: InputDecoration(
                          labelText: 'Намтар',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
