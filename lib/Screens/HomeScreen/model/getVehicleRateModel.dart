// To parse this JSON data, do
//
//     final getVehicleRate = getVehicleRateFromJson(jsonString);

import 'dart:convert';

List<GetVehicleRate> getVehicleRateFromJson(String str) =>
    List<GetVehicleRate>.from(
        json.decode(str).map((x) => GetVehicleRate.fromJson(x)));

String getVehicleRateToJson(List<GetVehicleRate> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetVehicleRate {
  final String? vehicleTypeId;
  final String? hoursRate;
  final String? everyHoursRate;
  final String? hours24Rate;
  final String? amountFor2;
  final String? amountAfter2;

  GetVehicleRate({
    this.vehicleTypeId,
    this.hoursRate,
    this.everyHoursRate,
    this.hours24Rate,
    this.amountFor2,
    this.amountAfter2,
  });

  factory GetVehicleRate.fromJson(Map<String, dynamic> json) => GetVehicleRate(
        vehicleTypeId: json["vehicleTypeID"],
        hoursRate: json["hoursRate"],
        everyHoursRate: json["everyHoursRate"],
        hours24Rate: json["hours24Rate"],
        amountFor2: json["amountFor2"],
        amountAfter2: json["amountAfter2"],
      );

  Map<String, dynamic> toJson() => {
        "vehicleTypeID": vehicleTypeId,
        "hoursRate": hoursRate,
        "everyHoursRate": everyHoursRate,
        "hours24Rate": hours24Rate,
        "amountFor2": amountFor2,
        "amountAfter2": amountAfter2,
      };

  factory GetVehicleRate.fromMap(Map<String, dynamic> map) {
    return GetVehicleRate(
      vehicleTypeId: map['vehicleTypeId'],
      hoursRate: map['hoursRate'],
      everyHoursRate: map['everyHoursRate'],
      hours24Rate: map['hours24Rate'],
      amountFor2: map['amountFor2'],
      amountAfter2: map['amountAfter2'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleTypeId': vehicleTypeId,
      'hoursRate': hoursRate,
      'everyHoursRate': everyHoursRate,
      'hours24Rate': hours24Rate,
      'amountFor2': amountFor2,
      'amountAfter2': amountAfter2,
    };
  }
}
