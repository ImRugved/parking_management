class ParkingLocation {
  final String id;
  final String name;
  final String organizationId;
  final String adminId;
  final String createdAt;
  final String updatedAt;

  ParkingLocation({
    required this.id,
    required this.name,
    required this.organizationId,
    this.adminId = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory ParkingLocation.fromMap(Map<String, dynamic> map) {
    return ParkingLocation(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      organizationId: map['organizationId'] ?? '',
      adminId: map['adminId'] ?? '',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organizationId': organizationId,
      'adminId': adminId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
