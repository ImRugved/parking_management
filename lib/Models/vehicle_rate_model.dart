class GetVehicleRate {
  final String id;
  final String vehicleTypeId;
  final String organizationId;
  final String hoursRate;
  final String everyHoursRate;
  final String hours24Rate;
  final String amountFor2;
  final String amountAfter2;

  GetVehicleRate({
    required this.id,
    required this.vehicleTypeId,
    required this.organizationId,
    required this.hoursRate,
    required this.everyHoursRate,
    required this.hours24Rate,
    required this.amountFor2,
    required this.amountAfter2,
  });

  factory GetVehicleRate.fromMap(Map<String, dynamic> map) {
    return GetVehicleRate(
      id: map['id'] ?? '',
      vehicleTypeId: map['vehicleTypeId'] ?? '',
      organizationId: map['organizationId'] ?? '',
      hoursRate: map['hoursRate'] ?? '',
      everyHoursRate: map['everyHoursRate'] ?? '',
      hours24Rate: map['hours24Rate'] ?? '',
      amountFor2: map['amountFor2'] ?? '',
      amountAfter2: map['amountAfter2'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleTypeId': vehicleTypeId,
      'organizationId': organizationId,
      'hoursRate': hoursRate,
      'everyHoursRate': everyHoursRate,
      'hours24Rate': hours24Rate,
      'amountFor2': amountFor2,
      'amountAfter2': amountAfter2,
    };
  }
}
