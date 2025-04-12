class ParkingLocation {
  final String id;
  final String name;
  final String organizationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingLocation({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organizationId': organizationId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ParkingLocation.fromMap(Map<String, dynamic> map) {
    return ParkingLocation(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      organizationId: map['organizationId'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
