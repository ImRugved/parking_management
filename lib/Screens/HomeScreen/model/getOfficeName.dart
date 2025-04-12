import 'dart:convert';

class GetOfficeModel {
  final String? name;
  final String? address;
  final String? id;

  GetOfficeModel({
    this.name,
    this.address,
    this.id,
  });

  factory GetOfficeModel.fromMap(Map<String, dynamic> map) {
    return GetOfficeModel(
      name: map['name'],
      address: map['address'],
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'id': id,
    };
  }
}
