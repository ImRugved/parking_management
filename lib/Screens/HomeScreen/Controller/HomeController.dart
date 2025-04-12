import 'dart:async';
import 'dart:developer';
import 'dart:convert';

import 'package:aditya_birla/Constant/global.dart';
import 'package:aditya_birla/Screens/HomeScreen/model/getOfficeName.dart';
import 'package:aditya_birla/Screens/HomeScreen/model/getVehicleRateModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:convert/convert.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    getVehicleRate();
    updateDateTime();
    getLocationList();
    locationType = null;
    selectedLocation = 'Aditya Birla Office'.obs;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateDateTime();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    vehicleNo.clear();
    customLocationController.dispose();
    selectedVehicle.value = 0;
    locationType = null;
    super.dispose();
  }

  final GetStorage storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxString currentDateWithDay = ''.obs;
  RxString currentDay = ''.obs;
  RxString currentTime = ''.obs;
  RxString qrcodeNumber = ''.obs;
  RxBool isPdfLoading = false.obs;
  RxBool isLoading = false.obs;
  RxBool isOfficeLoading = false.obs;
  RxInt selectedVehicle = 0.obs;
  RxString selectedLocation = 'Aditya Birla Office'.obs;
  TextEditingController vehicleNo = TextEditingController();
  TextEditingController customLocationController = TextEditingController();
  String? locationType;
  RxBool isOtherLocationSelected = false.obs;
  RxList<GetOfficeModel> locationTypeList = <GetOfficeModel>[].obs;
  RxList<GetVehicleRate> vehicleRates = <GetVehicleRate>[].obs;
  Timer? timer;

  void updateDateTime() {
    final now = DateTime.now();
    currentDateWithDay.value = DateFormat('d MMM yyyy EEEE').format(now);
    currentDay.value = DateFormat('EEEE').format(now);
    currentTime.value = DateFormat('h:mm a').format(now);
    update(["homeScreen"]);
  }

  // Method to handle location selection
  void onLocationSelected(String? value) {
    locationType = value;
    if (value == 'Other') {
      isOtherLocationSelected.value = true;
    } else {
      isOtherLocationSelected.value = false;
      customLocationController.clear();
    }
    update(["homeScreen"]);
  }

  Future<void> getVehicleRate() async {
    try {
      isLoading.value = true;

      // Check if vehicle rates exist
      final ratesCollection =
          await _firestore.collection('vehicle_rates').get();

      if (ratesCollection.docs.isEmpty) {
        // Create default rates if none exist
        await _createDefaultRates();
      }

      final rates = await _firestore.collection('vehicle_rates').get();
      vehicleRates.value =
          rates.docs.map((doc) => GetVehicleRate.fromMap(doc.data())).toList();

      // Debug logging
      for (var rate in vehicleRates) {
        log('Vehicle Type: ${rate.vehicleTypeId}, Hours Rate: ${rate.hoursRate}, Hourly: ${rate.everyHoursRate}, 24Hr Rate: ${rate.hours24Rate}');
      }

      update(["rate"]);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch vehicle rates: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createDefaultRates() async {
    // Create two-wheeler rates
    await _firestore.collection('vehicle_rates').add({
      'vehicleTypeId': '2 Wheeler',
      'hoursRate': '20',
      'everyHoursRate': '10',
      'hours24Rate': '200',
      'amountFor2': '20',
      'amountAfter2': '10',
    });

    // Create four-wheeler rates
    await _firestore.collection('vehicle_rates').add({
      'vehicleTypeId': '4 Wheeler',
      'hoursRate': '40',
      'everyHoursRate': '20',
      'hours24Rate': '400',
      'amountFor2': '40',
      'amountAfter2': '20',
    });
  }

  Future<void> getLocationList() async {
    try {
      isOfficeLoading.value = true;

      // Check if locations exist
      final locationsCollection =
          await _firestore.collection('locations').get();

      if (locationsCollection.docs.isEmpty) {
        // Create default locations if none exist
        await _firestore.collection('locations').add({
          'name': 'Location 1',
          'address': 'Aditya Birla Campus Main Gate',
          'id': '1',
        });

        await _firestore.collection('locations').add({
          'name': 'Location 2',
          'address': 'Aditya Birla Campus East Wing',
          'id': '2',
        });

        await _firestore.collection('locations').add({
          'name': 'Location 3',
          'address': 'Aditya Birla Campus West Wing',
          'id': '3',
        });
      }

      // Fetch locations from Firestore
      final locations = await _firestore.collection('locations').get();
      List<GetOfficeModel> locationList = locations.docs
          .map((doc) => GetOfficeModel.fromMap(doc.data()))
          .toList();

      // Add "Other" option to the list
      locationList.add(GetOfficeModel(
        name: 'Other',
        address: 'Custom location',
        id: 'other',
      ));

      locationTypeList.value = locationList;
      update(["locations", "homeScreen"]);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch locations: $e");
    } finally {
      isOfficeLoading.value = false;
    }
  }

  void selectVehicle(String vehicleType) {
    selectedVehicle.value = vehicleType == 'bike' ? 2 : 4;
    log('selected vehicle value is ${selectedVehicle.value}');
    update(["typeOfVehicle"]);
    update(["homeScreen"]);
  }

  Future<void> insertVehicleEntry() async {
    try {
      isPdfLoading.value = true;
      update(["homeScreen"]);
      log("Vehicle No: ${vehicleNo.text.toUpperCase()}");

      // Check if vehicle is already parked
      final formattedVehicleNumber = vehicleNo.text.trim().toUpperCase();
      final existingEntries = await _firestore
          .collection('vehicle_entries')
          .where('vehicleNumber', isEqualTo: formattedVehicleNumber)
          .where('status', isEqualTo: 'active')
          .get();

      if (existingEntries.docs.isNotEmpty) {
        // Vehicle is already parked
        final existingEntry =
            existingEntries.docs.first.data() as Map<String, dynamic>;
        final entryTime = DateTime.parse(existingEntry['entryTime']).toLocal();
        final formattedTime =
            DateFormat('MMM dd, yyyy hh:mm a').format(entryTime);
        final location = existingEntry['location'] ?? 'Unknown location';
        final vehicleType = existingEntry['vehicleType'] ?? '';

        Get.snackbar(
          "VEHICLE ALREADY PARKED",
          "$formattedVehicleNumber ($vehicleType) was parked at $location on $formattedTime",
          colorText: const Color(0xFFFFFFFF),
          backgroundColor: Colors.red,
          margin: EdgeInsets.all(10.w),
          borderRadius: 10,
          duration: Duration(seconds: 8),
          snackPosition: SnackPosition.TOP,
          animationDuration: Duration(milliseconds: 500),
          forwardAnimationCurve: Curves.easeOutBack,
        );

        isPdfLoading.value = false;
        update(['homeScreen']);
        return;
      }

      final entryTime = DateTime.now();
      final tokenNo = UniqueKey().hashCode.toString().substring(0, 4);
      String locationToStore = selectedLocation.value.isNotEmpty
          ? selectedLocation.value
          : 'Aditya Birla Office';

      // Generate QR code data as a string
      final qrData = "${vehicleNo.text.toUpperCase()}_$tokenNo";

      // Get the current admin ID
      final adminId = storage.read('userMasterID') ?? '';
      final organization = storage.read('organization') ?? '';

      // Set the rates from Firestore
      final vehicleTypeId =
          selectedVehicle.value == 2 ? '2 Wheeler' : '4 Wheeler';
      final vehicleRate = vehicleRates.firstWhere(
          (rate) => rate.vehicleTypeId == vehicleTypeId,
          orElse: () => vehicleRates.first);

      // Create vehicle entry
      final entryData = {
        'vehicleNumber': vehicleNo.text.toUpperCase(),
        'vehicleType': selectedVehicle.value == 2 ? '2 Wheeler' : '4 Wheeler',
        'location': locationToStore,
        'entryTime': entryTime.toIso8601String(),
        'tokenNo': tokenNo,
        'status': 'active',
        'qrCode': qrData,
        'adminId': adminId,
        'organization': organization,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Add to Firestore
      await _firestore.collection('vehicle_entries').add(entryData);

      // Generate PDF
      await generatePdf(
          vehicleNo.text.toUpperCase(),
          selectedVehicle.value == 2 ? '2 Wheeler' : '4 Wheeler',
          'Aditya Birla',
          qrData, // Using the qrData string directly
          vehicleRate.hoursRate ?? '20',
          vehicleRate.everyHoursRate ?? '10',
          vehicleRate.hours24Rate ??
              (selectedVehicle.value == 2 ? '200' : '400'),
          DateFormat('yyyy-MM-dd').format(entryTime),
          DateFormat('hh:mm a').format(entryTime),
          tokenNo,
          vehicleRate.amountFor2 ?? '20',
          vehicleRate.amountAfter2 ?? '10',
          selectedVehicle.value == 4
              ? 'assets/images/carpdf.png'
              : 'assets/images/bikepdf.png',
          locationToStore);

      // Reset fields
      vehicleNo.clear();
      selectedVehicle.value = 2;
      selectedLocation.value = 'Aditya Birla Office';
      isPdfLoading.value = true;

      isPdfLoading.value = false;
      update(["homeScreen"]);
    } catch (e) {
      Get.snackbar("Error", "Failed to add vehicle entry: $e");
      isPdfLoading.value = false;
      update(['homeScreen']);
    }
  }

  Future<void> generatePdf(
      String vehicleNumber,
      String vehicleTy,
      String companyName,
      String qrCodeNumber,
      String hoursRate,
      String everyHoursRate,
      String hours24Rate,
      String date,
      String time,
      String tokenNo,
      String amountFor2,
      String amountAfter2,
      var bikeIcon,
      String location) async {
    final pdf = pw.Document();

    log("VehicleType $vehicleNumber");

    // Load image asset
    final ByteData imageData = await rootBundle.load(bikeIcon);
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final img = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text("* $companyName *",
                    style: pw.TextStyle(
                      fontSize: 40.sp,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    )),
              ),
              pw.Center(
                child: pw.Text("Parking Receipt",
                    style: pw.TextStyle(
                      fontSize: 25.sp,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    )),
              ),
              pw.Center(
                child: pw.Text('Token No. $tokenNo',
                    style:
                        pw.TextStyle(fontSize: 25.sp, color: PdfColors.black)),
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.BarcodeWidget(
                      color: PdfColors.black,
                      barcode: pw.Barcode.qrCode(),
                      data: qrCodeNumber,
                      height: 200,
                      width: 200,
                    ),
                    pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Vehicle No. : $vehicleNumber',
                              style: pw.TextStyle(
                                  fontSize: 25.sp, color: PdfColors.black)),
                          pw.Text('Vehicle Type : $vehicleTy',
                              style: pw.TextStyle(
                                  fontSize: 25.sp, color: PdfColors.black)),
                          pw.Text('Entry Date : $date',
                              style: pw.TextStyle(
                                  fontSize: 25.sp, color: PdfColors.black)),
                          pw.Text('Entry Time : $time',
                              style: pw.TextStyle(
                                  fontSize: 25.sp, color: PdfColors.black)),
                        ])
                  ]),
              pw.Divider(),
              pw.Text('Rates',
                  style: pw.TextStyle(fontSize: 25.sp, color: PdfColors.black)),
              pw.Text('First 2 Hours : Rs $hoursRate',
                  style: pw.TextStyle(fontSize: 25.sp, color: PdfColors.black)),
              pw.Text('After 2 Hours (hourly) : Rs $everyHoursRate',
                  style: pw.TextStyle(fontSize: 25.sp, color: PdfColors.black)),
              pw.Text('24 Hours : Rs $hours24Rate',
                  style: pw.TextStyle(fontSize: 25.sp, color: PdfColors.black)),
              pw.Divider(),
              pw.Center(
                child: pw.Image(
                  img,
                  width: 300.w,
                  height: 150.h,
                ),
              ),
              pw.Center(
                child: pw.Text("Thank you for using our parking service.",
                    style: pw.TextStyle(
                        fontSize: 25.sp,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
