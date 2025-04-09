import 'package:intl/intl.dart';

class FamilyMember {
  final String fromPersonId;
  final String relationshipType;
  final String name;
  final String? lastname;
  final String gender;
  final DateTime birthdate;
  final DateTime? diedate;
  final String? biography;
  final String? uyeId;
  final String? placeId;
  final String? urgiinOvogId;

  FamilyMember({
    required this.fromPersonId,
    required this.relationshipType,
    required this.name,
    this.lastname,
    required this.gender,
    required this.birthdate,
    this.diedate,
    this.biography,
    this.uyeId,
    this.placeId,
    this.urgiinOvogId,
  });

  Map<String, dynamic> toJson() {
    return {
      'from_person_id': fromPersonId,
      'relationship_type': relationshipType,
      'name': name,
      'lastname': lastname,
      'gender': gender,
      'birthdate': DateFormat('yyyy-MM-dd').format(birthdate),
      'diedate':
          diedate != null ? DateFormat('yyyy-MM-dd').format(diedate!) : null,
      'biography': biography,
      'uye_id': uyeId,
      'place_id': placeId,
      'urgiin_ovog_id': urgiinOvogId,
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      fromPersonId: json['from_person_id'] ?? '',
      relationshipType: json['relationship_type'] ?? '',
      name: json['name'] ?? '',
      lastname: json['lastname'],
      gender: json['gender'] ?? 'Эр',
      birthdate: DateTime.parse(json['birthdate']),
      diedate: json['diedate'] != null ? DateTime.parse(json['diedate']) : null,
      biography: json['biography'],
      uyeId: json['uye_id'],
      placeId: json['place_id'],
      urgiinOvogId: json['urgiin_ovog_id'],
    );
  }
}
