class Company {
  final String id;
  final String name;
  final String organizationId;

  Company({
    required this.id,
    required this.name,
    required this.organizationId,
  });

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      organizationId: map['organizationId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organizationId': organizationId,
    };
  }
}
