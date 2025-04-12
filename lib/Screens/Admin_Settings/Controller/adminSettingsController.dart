import 'dart:developer';

import 'package:aditya_birla/Screens/HomeScreen/model/getVehicleRateModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AdminSettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage();

  RxBool isLoading = false.obs;

  // Text controllers for editing rates
  TextEditingController twoWheelerFirstHoursRate = TextEditingController();
  TextEditingController twoWheelerEveryHoursRate = TextEditingController();
  TextEditingController twoWheeler24HoursRate = TextEditingController();

  TextEditingController fourWheelerFirstHoursRate = TextEditingController();
  TextEditingController fourWheelerEveryHoursRate = TextEditingController();
  TextEditingController fourWheeler24HoursRate = TextEditingController();

  // Number of hours for first rate bracket (default is 2)
  RxInt firstHoursBracket = 2.obs;

  // Current vehicle rates
  RxList<GetVehicleRate> vehicleRates = <GetVehicleRate>[].obs;

  @override
  void onInit() {
    super.onInit();
    getVehicleRates();
  }

  @override
  void onClose() {
    twoWheelerFirstHoursRate.dispose();
    twoWheelerEveryHoursRate.dispose();
    twoWheeler24HoursRate.dispose();
    fourWheelerFirstHoursRate.dispose();
    fourWheelerEveryHoursRate.dispose();
    fourWheeler24HoursRate.dispose();
    super.onClose();
  }

  // Get the current vehicle rates
  Future<void> getVehicleRates() async {
    try {
      isLoading.value = true;

      // Get the organization ID from storage
      final String adminId = storage.read('userMasterID') ?? '';

      // Check if rates exist
      final ratesCollection = await _firestore
          .collection('vehicle_rates')
          .where('adminId', isEqualTo: adminId)
          .get();

      if (ratesCollection.docs.isEmpty) {
        // Create default rates if none exist
        await _createDefaultRates();
      }

      // Get the rates
      final rates = await _firestore
          .collection('vehicle_rates')
          .where('adminId', isEqualTo: adminId)
          .get();

      vehicleRates.value =
          rates.docs.map((doc) => GetVehicleRate.fromMap(doc.data())).toList();

      // Populate text controllers with current values
      if (vehicleRates.isNotEmpty) {
        // Get 2 Wheeler rate
        final twoWheelerRate = vehicleRates.firstWhere(
          (rate) => rate.vehicleTypeId == '2 Wheeler',
          orElse: () => vehicleRates.first,
        );

        twoWheelerFirstHoursRate.text = twoWheelerRate.hoursRate ?? '20';
        twoWheelerEveryHoursRate.text = twoWheelerRate.everyHoursRate ?? '10';
        twoWheeler24HoursRate.text = twoWheelerRate.hours24Rate ?? '200';

        // Get 4 Wheeler rate
        final fourWheelerRate = vehicleRates.firstWhere(
          (rate) => rate.vehicleTypeId == '4 Wheeler',
          orElse: () => vehicleRates.first,
        );

        fourWheelerFirstHoursRate.text = fourWheelerRate.hoursRate ?? '40';
        fourWheelerEveryHoursRate.text = fourWheelerRate.everyHoursRate ?? '20';
        fourWheeler24HoursRate.text = fourWheelerRate.hours24Rate ?? '400';
      }

      update(["rates"]);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch vehicle rates: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Create default rates for the organization
  Future<void> _createDefaultRates() async {
    final String adminId = storage.read('userMasterID') ?? '';
    final String organization = storage.read('organization') ?? '';

    // Create two-wheeler rates
    await _firestore.collection('vehicle_rates').add({
      'vehicleTypeId': '2 Wheeler',
      'hoursRate': '20',
      'everyHoursRate': '10',
      'hours24Rate': '200',
      'amountFor2': '20',
      'amountAfter2': '10',
      'firstHoursBracket': 2,
      'adminId': adminId,
      'organization': organization,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Create four-wheeler rates
    await _firestore.collection('vehicle_rates').add({
      'vehicleTypeId': '4 Wheeler',
      'hoursRate': '40',
      'everyHoursRate': '20',
      'hours24Rate': '400',
      'amountFor2': '40',
      'amountAfter2': '20',
      'firstHoursBracket': 2,
      'adminId': adminId,
      'organization': organization,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Update the vehicle rates
  Future<void> updateVehicleRates() async {
    try {
      isLoading.value = true;

      // Validate inputs are numbers
      if (!_validateInputs()) {
        return;
      }

      final String adminId = storage.read('userMasterID') ?? '';

      // Update two-wheeler rates
      final twoWheelerSnapshot = await _firestore
          .collection('vehicle_rates')
          .where('adminId', isEqualTo: adminId)
          .where('vehicleTypeId', isEqualTo: '2 Wheeler')
          .get();

      if (twoWheelerSnapshot.docs.isNotEmpty) {
        await _firestore
            .collection('vehicle_rates')
            .doc(twoWheelerSnapshot.docs.first.id)
            .update({
          'hoursRate': twoWheelerFirstHoursRate.text,
          'everyHoursRate': twoWheelerEveryHoursRate.text,
          'hours24Rate': twoWheeler24HoursRate.text,
          'amountFor2': twoWheelerFirstHoursRate.text,
          'amountAfter2': twoWheelerEveryHoursRate.text,
          'firstHoursBracket': firstHoursBracket.value,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      // Update four-wheeler rates
      final fourWheelerSnapshot = await _firestore
          .collection('vehicle_rates')
          .where('adminId', isEqualTo: adminId)
          .where('vehicleTypeId', isEqualTo: '4 Wheeler')
          .get();

      if (fourWheelerSnapshot.docs.isNotEmpty) {
        await _firestore
            .collection('vehicle_rates')
            .doc(fourWheelerSnapshot.docs.first.id)
            .update({
          'hoursRate': fourWheelerFirstHoursRate.text,
          'everyHoursRate': fourWheelerEveryHoursRate.text,
          'hours24Rate': fourWheeler24HoursRate.text,
          'amountFor2': fourWheelerFirstHoursRate.text,
          'amountAfter2': fourWheelerEveryHoursRate.text,
          'firstHoursBracket': firstHoursBracket.value,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      // Reload rates
      await getVehicleRates();

      Get.snackbar(
        "Success",
        "Vehicle rates updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to update vehicle rates: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Update the first hours bracket
  void updateFirstHoursBracket(int value) {
    firstHoursBracket.value = value;
    update(["rates"]);
  }

  // Validate that all inputs are valid numbers
  bool _validateInputs() {
    try {
      // Check that all inputs are valid numbers
      int.parse(twoWheelerFirstHoursRate.text);
      int.parse(twoWheelerEveryHoursRate.text);
      int.parse(twoWheeler24HoursRate.text);
      int.parse(fourWheelerFirstHoursRate.text);
      int.parse(fourWheelerEveryHoursRate.text);
      int.parse(fourWheeler24HoursRate.text);
      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Please enter valid numbers for all rates",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
