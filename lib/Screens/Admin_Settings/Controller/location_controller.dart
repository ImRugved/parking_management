import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:aditya_birla/Models/location_model.dart';
import 'dart:developer';

class LocationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final RxList<ParkingLocation> locations = <ParkingLocation>[].obs;
  final RxString selectedLocation = ''.obs;
  final TextEditingController locationNameController = TextEditingController();

  // Flag to notify other screens when locations are updated
  final RxBool locationsUpdated = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Safely register the locations_updated event
    try {
      // Check if it's already registered
      Get.find<RxBool>(tag: 'locations_updated');
      log("locations_updated event already registered");
    } catch (e) {
      // Register it if not found
      log("Registering locations_updated event");
      Get.put(locationsUpdated, tag: 'locations_updated');
    }

    fetchLocations();
  }

  @override
  void onClose() {
    locationNameController.dispose();
    super.onClose();
  }

  Future<void> fetchLocations() async {
    try {
      final String adminId = _storage.read('userMasterID') ?? '';

      if (adminId.isEmpty) {
        Get.snackbar("Error", "User ID not found. Please login again.");
        return;
      }

      log("Fetching locations for admin: $adminId");

      final QuerySnapshot snapshot = await _firestore
          .collection('locations')
          .where('adminId', isEqualTo: adminId)
          .get();

      log("Location query returned ${snapshot.docs.length} results");

      locations.value = snapshot.docs
          .map((doc) =>
              ParkingLocation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      log("Loaded ${locations.length} locations");
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch locations: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addLocation(String name) async {
    try {
      final String adminId = _storage.read('userMasterID') ?? '';
      final String organization = _storage.read('organization') ?? '';

      if (adminId.isEmpty) {
        Get.snackbar("Error", "User ID not found. Please login again.");
        return;
      }

      final String id = _firestore.collection('locations').doc().id;

      log("Adding location: $name for admin: $adminId");

      final ParkingLocation location = ParkingLocation(
        id: id,
        name: name,
        organizationId: organization,
        adminId: adminId,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('locations').doc(id).set(location.toMap());

      locations.add(location);
      locationNameController.clear();

      // Signal that locations were updated
      locationsUpdated.toggle();

      Get.snackbar(
        "Success",
        "Location added successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add location: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      await _firestore.collection('locations').doc(id).delete();
      locations.removeWhere((location) => location.id == id);

      // Signal that locations were updated
      locationsUpdated.toggle();

      Get.snackbar(
        "Success",
        "Location deleted successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete location: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
