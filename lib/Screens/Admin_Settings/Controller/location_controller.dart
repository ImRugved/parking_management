import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:aditya_birla/Models/location_model.dart';

class LocationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final RxList<ParkingLocation> locations = <ParkingLocation>[].obs;
  final RxString selectedLocation = ''.obs;
  final TextEditingController locationNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  @override
  void onClose() {
    locationNameController.dispose();
    super.onClose();
  }

  Future<void> fetchLocations() async {
    try {
      final String organizationId = _storage.read('userMasterID') ?? '';

      final QuerySnapshot snapshot = await _firestore
          .collection('locations')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      locations.value = snapshot.docs
          .map((doc) =>
              ParkingLocation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
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
      final String organizationId = _storage.read('userMasterID') ?? '';
      final String id = _firestore.collection('locations').doc().id;

      final ParkingLocation location = ParkingLocation(
        id: id,
        name: name,
        organizationId: organizationId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('locations').doc(id).set(location.toMap());

      locations.add(location);
      locationNameController.clear();

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
