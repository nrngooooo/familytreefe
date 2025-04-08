class FamilyMember {
  final String name;
  final String? lastname;
  final String gender;
  final DateTime birthdate;
  final DateTime? diedate;
  final String? imageUrl;
  final String? biography;
  final String? placeId;
  final String? uyeId;
  final String? urgiinOvogId;

  FamilyMember({
    required this.name,
    this.lastname,
    required this.gender,
    required this.birthdate,
    this.diedate,
    this.imageUrl,
    this.biography,
    this.placeId,
    this.uyeId,
    this.urgiinOvogId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastname': lastname,
      'gender': gender,
      'birthdate': birthdate.toIso8601String(),
      'diedate': diedate?.toIso8601String(),
      'image_url': imageUrl,
      'biography': biography,
      'place_id': placeId,
      'uye_id': uyeId,
      'urgiin_ovog_id': urgiinOvogId,
    };
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      name: json['name'],
      lastname: json['lastname'],
      gender: json['gender'],
      birthdate: DateTime.parse(json['birthdate']),
      diedate: json['diedate'] != null ? DateTime.parse(json['diedate']) : null,
      imageUrl: json['image_url'],
      biography: json['biography'],
      placeId: json['place_id'],
      uyeId: json['uye_id'],
      urgiinOvogId: json['urgiin_ovog_id'],
    );
  }
}
