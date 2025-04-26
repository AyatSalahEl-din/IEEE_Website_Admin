class TeamMember {
  final String id; // Firestore doc ID
  final String pic;
  final String name;
  final String position;
  final int number;

  TeamMember({
    required this.id,
    required this.pic,
    required this.name,
    required this.position,
    required this.number,
  });

  factory TeamMember.fromFirestore(String id, Map<String, dynamic> data) {
    return TeamMember(
      id: id,
      pic: data['pic'] ?? '',
      name: data['name'] ?? 'Unknown',
      position: data['position'] ?? 'Member',
      number: (data['number'] ?? 9999).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'pic': pic, 'name': name, 'position': position, 'number': number};
  }
}
