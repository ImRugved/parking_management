import 'dart:developer';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aditya_birla/Constant/global.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class ExitController extends GetxController {
  final GetStorage storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  String? paymentType;
  String currentDate = DateFormat('d MMM yyyy').format(DateTime.now());
  String currentDay = DateFormat('EEEE').format(DateTime.now());
  String currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());

  List<String> paymentsTypeList = ["Cash", "UPI", "Cards"];
  TextEditingController outputController = TextEditingController();
  TextEditingController paymentAmount = TextEditingController();
  Map<String, dynamic> currentVehicleData = {};
  String currentVehicleDocId = '';

  Future<void> getVehicleEntryData(bool isCheckOut) async {
    try {
      isLoading.value = true;
      paymentAmount.clear();

      // First check if vehicle exists at all (active or completed)
      final allEntriesSnapshot = await _firestore
          .collection('vehicle_entries')
          .where('vehicleNumber',
              isEqualTo: outputController.text.toUpperCase())
          .get();

      if (allEntriesSnapshot.docs.isEmpty) {
        Get.snackbar("Error",
            "Vehicle entry is not available for ${outputController.text.toUpperCase()}");
        paymentAmount.clear();
        update(["ExitScreen"]);
        return;
      }

      // Now check for active entries
      final activeEntriesSnapshot = await _firestore
          .collection('vehicle_entries')
          .where('vehicleNumber',
              isEqualTo: outputController.text.toUpperCase())
          .where('status', isEqualTo: 'active')
          .get();

      if (activeEntriesSnapshot.docs.isEmpty) {
        // Vehicle exists but has already exited
        // First just check if completed entries exist without ordering
        final completedEntriesSnapshot = await _firestore
            .collection('vehicle_entries')
            .where('vehicleNumber',
                isEqualTo: outputController.text.toUpperCase())
            .where('status', isEqualTo: 'completed')
            .get();

        if (completedEntriesSnapshot.docs.isNotEmpty) {
          // Now we know completed entries exist, we can manually find the latest one
          DateTime latestExitTime = DateTime(1970);
          Map<String, dynamic> latestExitData = {};

          for (var doc in completedEntriesSnapshot.docs) {
            final data = doc.data();
            final exitTime = DateTime.parse(data['exitTime']);

            if (exitTime.isAfter(latestExitTime)) {
              latestExitTime = exitTime;
              latestExitData = data;
            }
          }

          final formattedExitTime =
              DateFormat('dd MMM yyyy, hh:mm a').format(latestExitTime);
          Get.snackbar("Already Exited",
              "${outputController.text.toUpperCase()} already exited at $formattedExitTime");
        } else {
          Get.snackbar("Error", "Vehicle data is inconsistent");
        }
        paymentAmount.clear();
        update(["ExitScreen"]);
        return;
      }

      final entryData = activeEntriesSnapshot.docs.first.data();
      currentVehicleData = entryData;
      currentVehicleDocId = activeEntriesSnapshot.docs.first.id;

      if (isCheckOut) {
        await recordVehicleExit(currentVehicleDocId);
      } else {
        // Calculate charges for display
        final entryTime = DateTime.parse(entryData['entryTime']);
        final exitTime = DateTime.now();
        final duration = exitTime.difference(entryTime);

        // Calculate total minutes for more precise rate calculation
        final totalMinutes = duration.inMinutes;
        final hours = totalMinutes ~/ 60; // Integer division
        final minutes = totalMinutes % 60;

        // Calculate charges based on duration and vehicle type with 30-minute grace periods
        double charges = 0;
        final vehicleType = entryData['vehicleType'];

        if (vehicleType == '2 Wheeler') {
          if (totalMinutes <= 150) {
            // 2 hours + 30 min grace period (2.5 hours = 150 minutes)
            charges = 20;
          } else if (totalMinutes >= 1440 && totalMinutes <= 1470) {
            // 24 hours + 30 min grace period
            charges = 190; // 24-hour rate
          } else if (totalMinutes > 1470) {
            // More than 24 hours + 30 min
            // Calculate full days (24 hours) and remaining hours
            final double fullDays = (totalMinutes ~/ 1440).toDouble();
            final remainingMinutes = totalMinutes % 1440;

            if (remainingMinutes <= 150) {
              // If remaining time is within 2.5 hours
              charges = fullDays * 190 + 20;
            } else {
              final additionalHours = (remainingMinutes - 120) / 60;
              final additionalCharges = (additionalHours.ceil() * 10);
              charges = fullDays * 190 + 20 + additionalCharges;
            }
          } else {
            // Between 2.5 hours and 24 hours
            final additionalHours = (totalMinutes - 120) / 60;
            charges = 20 + (additionalHours.ceil() * 10);
          }
        } else {
          // 4 Wheeler
          if (totalMinutes <= 150) {
            // 2 hours + 30 min grace period (2.5 hours = 150 minutes)
            charges = 40;
          } else if (totalMinutes >= 1440 && totalMinutes <= 1470) {
            // 24 hours + 30 min grace period
            charges = 400; // 24-hour rate
          } else if (totalMinutes > 1470) {
            // More than 24 hours + 30 min
            // Calculate full days (24 hours) and remaining hours
            final double fullDays = (totalMinutes ~/ 1440).toDouble();
            final remainingMinutes = totalMinutes % 1440;

            if (remainingMinutes <= 150) {
              // If remaining time is within 2.5 hours
              charges = fullDays * 400 + 40;
            } else {
              final additionalHours = (remainingMinutes - 120) / 60;
              final additionalCharges = (additionalHours.ceil() * 20);
              charges = fullDays * 400 + 40 + additionalCharges;
            }
          } else {
            // Between 2.5 hours and 24 hours
            final additionalHours = (totalMinutes - 120) / 60;
            charges = 40 + (additionalHours.ceil() * 20);
          }
        }

        // Show vehicle details
        paymentAmount.text = "Rs ${charges.toStringAsFixed(2)}";
        paymentType = paymentsTypeList.first;

        Get.snackbar("Vehicle Found",
            "Vehicle: ${entryData['vehicleNumber']}, Type: ${entryData['vehicleType']}",
            duration: Duration(seconds: 3));
      }

      update(["ExitScreen"]);
    } catch (e) {
      Get.snackbar("Error", "Failed to retrieve vehicle data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> scan() async {
    await Permission.camera.request();
    outputController.clear();
    paymentAmount.clear();

    try {
      final barcode = await BarcodeScanner.scan();
      String scannedCode = barcode.rawContent;

      if (scannedCode.isEmpty) {
        Get.snackbar("Error", "Empty QR code scanned");
        return;
      }

      // Extract vehicle number from QR code (format: ABPMS-tokenNo-vehicleNumber)
      if (scannedCode.startsWith('ABPMS-')) {
        final parts = scannedCode.split('-');
        if (parts.length >= 3) {
          outputController.text = parts.sublist(2).join('-').toUpperCase();
        } else {
          outputController.text = scannedCode;
          Get.snackbar("Warning", "QR code format not recognized");
        }
      } else {
        outputController.text = scannedCode;
        Get.snackbar("Warning", "QR code may not be from our system");
      }

      if (outputController.text.isNotEmpty) {
        await getVehicleEntryData(false);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to scan QR code: $e");
    }
  }

  Future<void> generateExitReceipt(
      String vehicleNumber,
      String companyName,
      String amount,
      String paymentType,
      String vehicleType,
      String entryTimeStr,
      String exitTimeStr,
      String location,
      Duration totalDuration,
      String tokenNo) async {
    final pdf = pw.Document();
    final entryTime = DateTime.parse(entryTimeStr);
    final exitTime = DateTime.parse(exitTimeStr);

    // Format dates for display
    final entryDateFormatted = DateFormat('MMM dd, yyyy').format(entryTime);
    final entryTimeFormatted = DateFormat('hh:mm a').format(entryTime);
    final exitDateFormatted = DateFormat('MMM dd, yyyy').format(exitTime);
    final exitTimeFormatted = DateFormat('hh:mm a').format(exitTime);

    // Format duration
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    final durationText = '${hours}h ${minutes}m';

    // Load image asset
    final ByteData imageData = await rootBundle.load(vehicleType == '4 Wheeler'
        ? 'assets/images/carpdf.png'
        : 'assets/images/bikepdf.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final img = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text("$companyName",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    )),
                pw.SizedBox(height: 10),
                pw.Text("Payment Receipt",
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Token No:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(tokenNo),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Vehicle Number:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(vehicleNumber),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Vehicle Type:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(vehicleType),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Location:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(location),
                    ]),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Entry Date:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(entryDateFormatted),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Entry Time:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(entryTimeFormatted),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Exit Date:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(exitDateFormatted),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Exit Time:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(exitTimeFormatted),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Total Duration:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(durationText),
                    ]),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Amount Paid:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text("Rs $amount"),
                    ]),
                pw.SizedBox(height: 10),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("Payment Method:",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(paymentType),
                    ]),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Image(
                    img,
                    width: 150,
                    height: 100,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text("Thank you for using our parking service.",
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
                pw.Text("Drive Safely",
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // Process vehicle exit
  Future<void> recordVehicleExit(String vehicleId) async {
    try {
      isLoading.value = true;

      // Get admin ID
      final adminId = storage.read('userMasterID') ?? '';
      final organizationName = storage.read('organization') ?? '';

      // Calculate parking charges
      final entryData = currentVehicleData;
      final entryTime = DateTime.parse(entryData['entryTime']);
      final exitTime = DateTime.now();
      final duration = exitTime.difference(entryTime);

      // Calculate total minutes for more precise rate calculation
      final totalMinutes = duration.inMinutes;
      final hours = totalMinutes ~/ 60; // Integer division
      final minutes = totalMinutes % 60;

      // Calculate charges based on duration and vehicle type with 30-minute grace periods
      double charges = 0;
      final vehicleType = entryData['vehicleType'];

      if (vehicleType == '2 Wheeler') {
        if (totalMinutes <= 150) {
          // 2 hours + 30 min grace period (2.5 hours = 150 minutes)
          charges = 20;
        } else if (totalMinutes >= 1440 && totalMinutes <= 1470) {
          // 24 hours + 30 min grace period
          charges = 190; // 24-hour rate
        } else if (totalMinutes > 1470) {
          // More than 24 hours + 30 min
          // Calculate full days (24 hours) and remaining hours
          final double fullDays = (totalMinutes ~/ 1440).toDouble();
          final remainingMinutes = totalMinutes % 1440;

          if (remainingMinutes <= 150) {
            // If remaining time is within 2.5 hours
            charges = fullDays * 190 + 20;
          } else {
            final additionalHours = (remainingMinutes - 120) / 60;
            final additionalCharges = (additionalHours.ceil() * 10);
            charges = fullDays * 190 + 20 + additionalCharges;
          }
        } else {
          // Between 2.5 hours and 24 hours
          final additionalHours = (totalMinutes - 120) / 60;
          charges = 20 + (additionalHours.ceil() * 10);
        }
      } else {
        // 4 Wheeler
        if (totalMinutes <= 150) {
          // 2 hours + 30 min grace period (2.5 hours = 150 minutes)
          charges = 40;
        } else if (totalMinutes >= 1440 && totalMinutes <= 1470) {
          // 24 hours + 30 min grace period
          charges = 400; // 24-hour rate
        } else if (totalMinutes > 1470) {
          // More than 24 hours + 30 min
          // Calculate full days (24 hours) and remaining hours
          final double fullDays = (totalMinutes ~/ 1440).toDouble();
          final remainingMinutes = totalMinutes % 1440;

          if (remainingMinutes <= 150) {
            // If remaining time is within 2.5 hours
            charges = fullDays * 400 + 40;
          } else {
            final additionalHours = (remainingMinutes - 120) / 60;
            final additionalCharges = (additionalHours.ceil() * 20);
            charges = fullDays * 400 + 40 + additionalCharges;
          }
        } else {
          // Between 2.5 hours and 24 hours
          final additionalHours = (totalMinutes - 120) / 60;
          charges = 40 + (additionalHours.ceil() * 20);
        }
      }

      // Update vehicle entry with exit details
      await _firestore.collection('vehicle_entries').doc(vehicleId).update({
        'exitTime': exitTime.toIso8601String(),
        'durationHours': hours,
        'durationMinutes': minutes,
        'charges': charges,
        'paymentType': paymentType ?? 'Cash',
        'status': 'completed',
        'exitRecordedBy': adminId,
        'organizationName': organizationName,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Generate receipt
      await generateExitReceipt(
          entryData['vehicleNumber'],
          'Aditya Birla',
          charges.toString(),
          paymentType ?? 'Cash',
          vehicleType,
          entryTime.toIso8601String(),
          exitTime.toIso8601String(),
          entryData['location'] ?? 'Unknown Location',
          duration,
          entryData['tokenNo']);

      // Clear the form
      outputController.clear();
      paymentAmount.clear();
      paymentType = null;
      currentVehicleData = {};
      currentVehicleDocId = '';

      Get.snackbar(
        "Success",
        "Vehicle exit recorded successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to record vehicle exit: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    outputController.clear();
    paymentAmount.clear();
    paymentType = null;
    currentVehicleData = {};
  }
}
