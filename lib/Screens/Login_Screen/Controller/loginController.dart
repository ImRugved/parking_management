import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController extends GetxController {
  final GetStorage storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin code constant
  final String adminCode = "myparkingadmin";

  @override
  void onInit() {
    super.onInit();
    userId.clear();
    password.clear();
    isVisible = false.obs;
    isLoading = false.obs;
  }

  @override
  void onClose() {
    userId.dispose();
    password.dispose();
    nameController.dispose();
    organizationController.dispose();
    adminCodeController.dispose();
    isVisible = false.obs;
    isLoading = false.obs;
    super.onClose();
  }

  TextEditingController userId = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController adminCodeController = TextEditingController();
  String? errorLogin;
  RxBool isVisible = false.obs;
  RxBool isLoading = false.obs;

  Future<void> loginApiCall() async {
    isLoading.value = true;
    try {
      // Sign in with email and password
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: userId.text.trim(),
        password: password.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Get user details from Firestore
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          // Get user role and organization
          String role = userData['role'] ?? 'user';
          String organization = userData['organization'] ?? '';

          // Store user data in GetStorage
          await storage.write('authToken', user.uid);
          await storage.write('username', userData['username']);
          await storage.write('name', userData['name']);
          await storage.write('userMasterID', userData['userMasterID']);
          await storage.write('role', role);
          await storage.write('organization', organization);

          // Navigate to first screen
          Get.offAllNamed("/first_screen");
        } else {
          Get.snackbar("Error", "User not found in database");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar("Error", "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        Get.snackbar("Error", "Wrong password provided for that user.");
      } else {
        Get.snackbar("Error", "${e.message}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Admin code verification dialog
  Future<bool> _verifyAdminCode() async {
    final TextEditingController codeController = TextEditingController();
    bool isVerified = false;

    await Get.dialog(
      AlertDialog(
        title: Text("Admin Verification"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please enter admin code to access admin features:"),
            SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Admin Code",
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text == adminCode) {
                isVerified = true;
                Get.back(result: true);
              } else {
                Get.snackbar("Error", "Incorrect admin code");
                Get.back(result: false);
              }
            },
            child: Text("Verify"),
          ),
        ],
      ),
      barrierDismissible: false,
    ).then((value) {
      if (value != null) {
        isVerified = value;
      }
    });

    return isVerified;
  }

  // Signup method
  Future<void> signUp() async {
    isLoading.value = true;
    try {
      // Determine user role
      String role = 'user';
      if (adminCodeController.text.trim() == adminCode) {
        role = 'admin';
      }

      // Organization name is required
      if (organizationController.text.trim().isEmpty) {
        Get.snackbar("Error", "Organization name is required");
        isLoading.value = false;
        return;
      }

      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userId.text.trim(),
        password: password.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': userId.text.trim(),
          'name': nameController.text.trim(),
          'organization': organizationController.text.trim(),
          'userMasterID': user.uid,
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // If user is admin, create an organization document
        if (role == 'admin') {
          await _firestore.collection('organizations').doc(user.uid).set({
            'name': organizationController.text.trim(),
            'adminId': user.uid,
            'email': userId.text.trim(),
            'createdAt': DateTime.now().toIso8601String(),
          });
        }

        // Navigate to login screen with success message
        Get.offAllNamed("/login_screen");
        Get.snackbar(
          "Success",
          "Account created successfully. Please login." +
              (role == 'admin' ? " Admin account activated." : ""),
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar("Error", "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar("Error", "The account already exists for that email.");
      } else {
        Get.snackbar("Error", "${e.message}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await storage.erase();
      Get.offAllNamed("/login_screen");
    } catch (e) {
      Get.snackbar("Error", "Failed to sign out");
    }
  }
}
