import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/family_member.dart';

class ClanMemberDetailScreen extends StatelessWidget {
  final FamilyMember member;

  const ClanMemberDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${member.lastname ?? ''} ${member.name}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${member.lastname ?? ''} ${member.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    member.relationshipType,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information
            const Text(
              'Хувийн мэдээлэл',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Хүйс', member.gender, Icons.person),
            _buildInfoCard(
              'Төрсөн огноо',
              DateFormat('yyyy-MM-dd').format(member.birthdate),
              Icons.cake,
            ),
            if (member.diedate != null)
              _buildInfoCard(
                'Нас барсан огноо',
                DateFormat('yyyy-MM-dd').format(member.diedate!),
                Icons.person_off,
              ),

            // Additional Information
            const SizedBox(height: 32),
            const Text(
              'Нэмэлт мэдээлэл',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (member.birthplace != null)
              _buildInfoCard(
                'Төрсөн газар',
                '${member.birthplace!['name']} (${member.birthplace!['country']})',
                Icons.location_on,
              ),
            if (member.generation != null)
              _buildInfoCard(
                'Үе',
                '${member.generation!['uyname']} (${member.generation!['level']})',
                Icons.generating_tokens,
              ),
            if (member.urgiinovog != null)
              _buildInfoCard(
                'Ургийн овог',
                member.urgiinovog!['urgiinovog'],
                Icons.family_restroom,
              ),

            // Biography
            if (member.biography != null && member.biography!.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Намтар',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member.biography!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
