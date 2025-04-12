import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aditya_birla/Constant/global.dart';
import 'package:aditya_birla/Screens/HomeScreen/model/getOfficeName.dart';
import 'package:aditya_birla/Screens/HomeScreen/model/getVehicleRateModel.dart'
    as old_model;
import 'package:aditya_birla/Models/vehicle_rate_model.dart';
import 'package:aditya_birla/Models/location_model.dart';
import 'package:aditya_birla/Models/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:convert/convert.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final vehicleNo = TextEditingController();
  final selectedVehicle = 1.obs;
  final selectedLocation = ''.obs;
  final selectedCompany = ''.obs;
  final isLoading = false.obs;
  final locations = <ParkingLocation>[].obs;
  final companies = <Company>[].obs;
  final vehicleRates = <GetVehicleRate>[].obs;

  @override
  void onInit() {
    super.onInit();

    // First, fetch locations from Firebase
    fetchLocations();

    // Then set up other data and UI elements
    getVehicleRate();
    updateDateTime();
    getLocationList();
    locationType = null;

    // Only set a default location if no locations were loaded
    if (locations.isEmpty) {
      selectedLocation.value = '';
    } else if (locations.isNotEmpty) {
      // Set the first available location as default
      selectedLocation.value = locations.first.id;
    }

    // Set up the timer for updating date/time
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateDateTime();
    });

    // Fetch companies data
    fetchCompanies();
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
  RxBool isOfficeLoading = false.obs;
  TextEditingController customLocationController = TextEditingController();
  String? locationType;
  RxBool isOtherLocationSelected = false.obs;
  RxList<GetOfficeModel> locationTypeList = <GetOfficeModel>[].obs;
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
    // Get the organization ID
    final storage = GetStorage();
    final organizationId = storage.read('organization') ?? '';

    // Create two-wheeler rates
    await _firestore.collection('vehicle_rates').add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'vehicleTypeId': '2 Wheeler',
      'organizationId': organizationId,
      'hoursRate': '20',
      'everyHoursRate': '10',
      'hours24Rate': '200',
      'amountFor2': '20',
      'amountAfter2': '10',
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Create four-wheeler rates
    await _firestore.collection('vehicle_rates').add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'vehicleTypeId': '4 Wheeler',
      'organizationId': organizationId,
      'hoursRate': '40',
      'everyHoursRate': '20',
      'hours24Rate': '400',
      'amountFor2': '40',
      'amountAfter2': '20',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> getLocationList() async {
    try {
      isOfficeLoading.value = true;

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
      String locationToStore = selectedLocation.value;

      // Generate QR code data as a string
      final qrData = "${vehicleNo.text.toUpperCase()}_$tokenNo";

      // Get the current admin ID
      final adminId = storage.read('userMasterID') ?? '';
      final organization = storage.read('organization') ?? '';

      // Set the rates from Firestore
      final vehicleTypeId =
          selectedVehicle.value == 2 ? '2 Wheeler' : '4 Wheeler';

      // Safely retrieve the vehicle rate
      GetVehicleRate? vehicleRate;
      try {
        vehicleRate = vehicleRates.firstWhere(
            (rate) => rate.vehicleTypeId == vehicleTypeId,
            orElse: () => vehicleRates.isNotEmpty
                ? vehicleRates.first
                : GetVehicleRate(
                    id: '',
                    vehicleTypeId: vehicleTypeId,
                    organizationId: '',
                    hoursRate: selectedVehicle.value == 2 ? '20' : '40',
                    everyHoursRate: selectedVehicle.value == 2 ? '10' : '20',
                    hours24Rate: selectedVehicle.value == 2 ? '200' : '400',
                    amountFor2: selectedVehicle.value == 2 ? '20' : '40',
                    amountAfter2: selectedVehicle.value == 2 ? '10' : '20',
                  ));
      } catch (e) {
        log('Error finding vehicle rate: $e');
        // Create default rate if none is found
        vehicleRate = GetVehicleRate(
          id: '',
          vehicleTypeId: vehicleTypeId,
          organizationId: '',
          hoursRate: selectedVehicle.value == 2 ? '20' : '40',
          everyHoursRate: selectedVehicle.value == 2 ? '10' : '20',
          hours24Rate: selectedVehicle.value == 2 ? '200' : '400',
          amountFor2: selectedVehicle.value == 2 ? '20' : '40',
          amountAfter2: selectedVehicle.value == 2 ? '10' : '20',
        );
      }

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
          vehicleRate.hoursRate,
          vehicleRate.everyHoursRate,
          vehicleRate.hours24Rate,
          DateFormat('yyyy-MM-dd').format(entryTime),
          DateFormat('hh:mm a').format(entryTime),
          tokenNo,
          vehicleRate.amountFor2,
          vehicleRate.amountAfter2,
          selectedVehicle.value == 4
              ? 'assets/images/carpdf.png'
              : 'assets/images/bikepdf.png',
          locationToStore);

      // Reset fields
      vehicleNo.clear();
      selectedVehicle.value = 2;
      // Keep the current location selected rather than resetting to default
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
                          pw.Text('Location : $location',
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

  Future<void> fetchLocations() async {
    try {
      isLoading.value = true;
      final storage = GetStorage();
      final organizationId = storage.read('organization') ?? '';

      final querySnapshot = await FirebaseFirestore.instance
          .collection('parking_locations')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      locations.value = querySnapshot.docs
          .map((doc) => ParkingLocation.fromMap(doc.data()))
          .toList();

      // Only show the snackbar if locations is empty and we're not already showing
      // a different loading operation
      if (locations.isEmpty && !isOfficeLoading.value) {
        // Get the location from the current selection before showing the message
        final currentLocation = selectedLocation.value;

        // Only show the message if there's no selected location either
        if (currentLocation.isEmpty ||
            currentLocation == 'Aditya Birla Office') {
          Get.snackbar(
            'Info',
            'No locations available. Please add locations from the admin dashboard.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch locations',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompanies() async {
    try {
      isLoading.value = true;
      final storage = GetStorage();
      final organizationId = storage.read('organization') ?? '';

      final querySnapshot = await FirebaseFirestore.instance
          .collection('companies')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      companies.value =
          querySnapshot.docs.map((doc) => Company.fromMap(doc.data())).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch companies',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
