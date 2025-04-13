import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MasterController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final organizationController = TextEditingController();

  // Observable variables
  RxBool isLoading = false.obs;
  RxBool isVisible = false.obs;
  RxBool noDataForDateRange = false.obs;
  RxBool isLoadingVehicleEntries = false.obs;

  // Flag to track if firestore index error occurred
  RxString vehicleQueryErrorMessage = ''.obs;

  // Selected organization for viewing data
  RxString selectedOrganizationId = ''.obs;
  RxString selectedOrganizationName = ''.obs;

  // View states
  RxString currentView =
      'manage_users'.obs; // 'create_admin', 'manage_users', 'vehicle_data'
  RxBool showVehicleEntries =
      true.obs; // Toggle between entries and rates when viewing vehicle data

  // Date range for filtering entries
  Rx<DateTime> fromDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  Rx<DateTime> toDate = DateTime.now().obs;
  RxBool useCustomDateRange = false.obs;

  // Stream subscriptions to manage
  StreamSubscription? _vehicleEntriesSubscription;

  @override
  void onInit() {
    super.onInit();
    clearFormFields();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    organizationController.dispose();
    // Cancel any active stream subscriptions
    _vehicleEntriesSubscription?.cancel();
    super.onClose();
  }

  void clearFormFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    organizationController.clear();
    isVisible.value = false;
  }

  void changeView(String view) {
    currentView.value = view;
    update(['master_dashboard']);
  }

  void viewOrganizationData(String orgId, String orgName) {
    selectedOrganizationId.value = orgId;
    selectedOrganizationName.value = orgName;
    currentView.value = 'vehicle_data';
    update(['master_dashboard']);
  }

  void togglePasswordVisibility() {
    isVisible.value = !isVisible.value;
    update(['create_admin_form']);
  }

  // Set date range
  void setDateRange(DateTime from, DateTime to) {
    fromDate.value = from;
    toDate.value = to;
    useCustomDateRange.value = true;
    update(['vehicle_data']);
  }

  // Reset date filter
  void resetDateFilter() {
    useCustomDateRange.value = false;
    fromDate.value = DateTime.now().subtract(const Duration(days: 7));
    toDate.value = DateTime.now();
    update(['vehicle_data']);
  }

  // Get all organizations where role is admin
  Stream<QuerySnapshot> getAllOrganizations() {
    return _firestore
        .collection('organizations')
        .where('role', isEqualTo: 'admin')
        .snapshots();
  }

  // Toggle user status (active/inactive)
  Future<void> toggleUserStatus(String userId, bool makeActive) async {
    try {
      isLoading.value = true;
      update(['manage_users']);

      String newStatus = makeActive ? 'active' : 'inactive';

      // Update user status in Firestore
      await _firestore.collection('users').doc(userId).update({
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Also update in organizations collection if exists
      final orgDoc =
          await _firestore.collection('organizations').doc(userId).get();
      if (orgDoc.exists) {
        await _firestore.collection('organizations').doc(userId).update({
          'status': newStatus,
        });
      }

      Get.snackbar(
        "Success",
        "User status updated to $newStatus",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to update user status: $e");
    } finally {
      isLoading.value = false;
      update(['manage_users']);
    }
  }

  // Create admin user
  Future<void> createAdminUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        organizationController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      update(['create_admin_form']);

      // Check if email already exists
      final emailCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: emailController.text.trim())
          .get();

      if (emailCheck.docs.isNotEmpty) {
        Get.snackbar(
          "Error",
          "Email already in use",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        update(['create_admin_form']);
        return;
      }

      // Create user with Firebase Auth directly from the login controller
      // Here we will use Firestore to store admin data
      final adminId = DateTime.now().millisecondsSinceEpoch.toString();
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'username': emailController.text.trim(),
          'password': passwordController.text
              .trim(), // In real app, this should be handled securely
          'organization': organizationController.text.trim(),
          'userMasterID': user.uid,
          'role': 'admin',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Create organization document
        await _firestore.collection('organizations').doc(user.uid).set({
          'name': organizationController.text.trim(),
          'adminId': user.uid,
          'email': emailController.text.trim(),
          'role': 'admin',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        });

        Get.snackbar(
          "Success",
          "Admin account created successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        clearFormFields();
      }
      // Create user document
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create admin account: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      update(['create_admin_form']);
    }
  }

  // Get vehicle entries for selected organization
  Stream<QuerySnapshot> getVehicleEntries() {
    if (selectedOrganizationId.value.isEmpty) {
      // Return an empty stream if no organization is selected
      return Stream.empty();
    }

    // Reset states
    noDataForDateRange.value = false;
    isLoadingVehicleEntries.value = true;
    vehicleQueryErrorMessage.value = '';

    // Base query
    var query = _firestore
        .collection('vehicle_entries')
        .where('adminId', isEqualTo: selectedOrganizationId.value);

    // Apply date filter if enabled
    if (useCustomDateRange.value) {
      try {
        // Adjust to end of day for the toDate to include the entire day
        final endOfDay = DateTime(
          toDate.value.year,
          toDate.value.month,
          toDate.value.day,
          23,
          59,
          59,
        );

        // Convert dates to ISO string format for Firestore query
        final fromDateStr = fromDate.value.toIso8601String();
        final toDateStr = endOfDay.toIso8601String();

        // Apply date filters
        query = query
            .where('entryTime', isGreaterThanOrEqualTo: fromDateStr)
            .where('entryTime', isLessThanOrEqualTo: toDateStr);
      } catch (e) {
        // Handle any errors when creating the query
        print("Error setting up date query: $e");
        noDataForDateRange.value = true;
        isLoadingVehicleEntries.value = false;
        return Stream.empty();
      }
    }

    // Cancel previous subscription if it exists
    _vehicleEntriesSubscription?.cancel();

    // Set up a listener outside of the build method
    Future.delayed(Duration.zero, () {
      _vehicleEntriesSubscription = query.snapshots().listen(
        (snapshot) {
          // Data received, update loading state
          isLoadingVehicleEntries.value = false;
        },
        onError: (error) {
          print("Error in vehicle entries query: $error");

          // Check if it's a missing index error
          if (error.toString().contains('requires an index') ||
              error.toString().contains('failed-precondition')) {
            noDataForDateRange.value = true;
            vehicleQueryErrorMessage.value =
                'No data available for the selected date range';
          } else {
            vehicleQueryErrorMessage.value =
                'Error loading data: ${error.toString()}';
          }

          isLoadingVehicleEntries.value = false;
        },
      );
    });

    // Return the query as stream
    return query.snapshots();
  }

  // No longer needed as we handle state in the stream listeners
  void handleVehicleQueryError(dynamic error) {
    print("Error in vehicle entries query: $error");

    // Check if it's a missing index error
    if (error.toString().contains('requires an index') ||
        error.toString().contains('failed-precondition')) {
      noDataForDateRange.value = true;
      vehicleQueryErrorMessage.value =
          'No data available for the selected date range';
    } else {
      vehicleQueryErrorMessage.value =
          'Error loading data: ${error.toString()}';
    }

    isLoadingVehicleEntries.value = false;
    // No need to call update() here as we use .obs variables
  }

  // No longer needed as we handle state in the stream listeners
  void resetVehicleQueryState() {
    isLoadingVehicleEntries.value = false;
    // No need to call update() here as we use .obs variables
  }

  // Get all vehicle entries for the selected organization
  // Used when filtering by custom date and field name is unknown
  Future<List<QueryDocumentSnapshot>> getAllVehicleEntries() async {
    if (selectedOrganizationId.value.isEmpty) {
      return [];
    }

    final snapshot = await _firestore
        .collection('vehicle_entries')
        .where('adminId', isEqualTo: selectedOrganizationId.value)
        .get();

    if (useCustomDateRange.value) {
      // Filter entries by date client-side to handle different date field formats
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Try to get date from different possible fields
        DateTime? entryDate;

        if (data['entryTime'] != null) {
          try {
            entryDate = DateTime.parse(data['entryTime'].toString());
          } catch (_) {}
        }

        if (entryDate == null && data['createdAt'] != null) {
          try {
            entryDate = DateTime.parse(data['createdAt'].toString());
          } catch (_) {}
        }

        // If no valid date found, exclude the entry
        if (entryDate == null) return false;

        // Check if the date is within the range
        return isDateInRange(entryDate);
      }).toList();
    }

    return snapshot.docs;
  }

  // Get vehicle rates for selected organization
  Stream<QuerySnapshot> getVehicleRates() {
    if (selectedOrganizationId.value.isEmpty) {
      // Return an empty stream if no organization is selected
      return Stream.empty();
    }

    return _firestore
        .collection('vehicle_rates')
        .where('adminId', isEqualTo: selectedOrganizationId.value)
        .snapshots();
  }

  // Toggle between vehicle entries and rates view
  void toggleVehicleDataView(bool showEntries) {
    showVehicleEntries.value = showEntries;
    update(['vehicle_data']);
  }

  // Format date time
  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Format date for display (day-month-year)
  String formatDateOnly(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  // Helper method to check if a date falls within the selected date range
  bool isDateInRange(DateTime date) {
    // Create start of day for fromDate
    final startOfDay = DateTime(
      fromDate.value.year,
      fromDate.value.month,
      fromDate.value.day,
    );

    // Create end of day for toDate
    final endOfDay = DateTime(
      toDate.value.year,
      toDate.value.month,
      toDate.value.day,
      23,
      59,
      59,
    );

    // Check if the date is within range
    return date.isAfter(startOfDay.subtract(Duration(milliseconds: 1))) &&
        date.isBefore(endOfDay.add(Duration(milliseconds: 1)));
  }

  // Sign out
  void signOut() {
    // Cancel any active stream subscriptions before signing out
    _vehicleEntriesSubscription?.cancel();
    _vehicleEntriesSubscription = null;

    _storage.erase();
    Get.offAllNamed('/login_screen');
  }
}
