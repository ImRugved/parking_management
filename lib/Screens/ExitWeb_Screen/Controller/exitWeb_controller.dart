import 'dart:developer';

//import 'dart:html' as html;

import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/global.dart';
import 'package:aditya_birla/Utils/Api.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class ExitWebController extends GetxController {
  final GetStorage storage = GetStorage();
  API api = API();

  RxBool isLoading = false.obs;
  String? paymentType;
  String currentDate = DateFormat('d MMM yyyy').format(DateTime.now());
  String currentDay = DateFormat('EEEE').format(DateTime.now());
  String currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());

  List<String> paymentsTypeList = ["Cash", "UPI", "Cards"];
  TextEditingController outputController = TextEditingController();
  TextEditingController paymentAmount = TextEditingController();

  Future<void> getVehicleEntryData(bool? isCheckOut) async {
    String userID = storage.read('userMasterID');
    isLoading.value = true;
    log("outputController ${outputController.text}");
    Map<String, dynamic> body = {
      "UserID": userID,
      "QrCode": outputController.text,
      "PaymentType": isCheckOut != false ? paymentType : "NULL",
    };
    try {
      final response = await api.sendRequest.get(
        Global.hostUrl + Global.scanQr,
        queryParameters: body,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      log('API response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isCheckOut == false) {
          paymentAmount.text = "${response.data[0]["paidAmount"]} Rs";
          paymentType = paymentsTypeList.first;
        } else {
          final bikeIcon = pw.MemoryImage(
            (await rootBundle.load(response.data[0]["vehicleTypeID"] == "4"
                    ? 'assets/images/carpdf.png'
                    : 'assets/images/bikepdf.png'))
                .buffer
                .asUint8List(),
          );
          // final bikeIcon = await imageFromAssetBundle(
          //     response.data[0]["vehicleTypeID"] == "4"
          //         ? 'assets/images/carpdf.png'
          //         : 'assets/images/bikepdf.png');
          String time =
              "Out Time: ${DateFormat('hh:MM a').format(DateTime.now())}";
          String date =
              "Exit : ${response.data[0]["outDate"]}, ${response.data[0]["outTime"]}";
          String totalTime = "${response.data[0]["inTime"]}";
          generatePdf(
              response.data[0]["paidAmount"],
              response.data[0]["vehicleNo"],
              response.data[0]["companyName"],
              response.data[0]["payType"],
              response.data[0]["vehicleTypeID"],
              response.data[0]["date"],
              response.data[0]["time"],
              bikeIcon,
              date,
              totalTime);
          paymentType = "NULL";
          outputController.clear();
          paymentAmount.clear();
          Get.snackbar("Check Out", "Checkout successfully",
              backgroundColor: ConstColors.white,
              colorText: ConstColors.primary);
        }
      } else {
        paymentType = "NULL";
        outputController.clear();
        paymentAmount.clear();
        Get.snackbar("Error", "Invalid QR code",
            backgroundColor: ConstColors.white, colorText: ConstColors.primary);
      }
    } on DioException catch (error) {
      String errorMessage = error.type == DioExceptionType.connectionError
          ? "Network Error"
          : error.type == DioExceptionType.connectionTimeout
              ? "Time Out"
              : "Something went wrong: $error";
      Get.snackbar("Error", errorMessage,
          backgroundColor: ConstColors.white, colorText: ConstColors.primary);
    } catch (error) {
      log('Vehicle rate ERROR: $error');
      Get.snackbar("Error", "$error",
          backgroundColor: ConstColors.white, colorText: ConstColors.primary);
    } finally {
      isLoading.value = false;
      update(["ExitWebScreen"]);
    }
  }

  Future scan() async {
    await Permission.camera.request();
    outputController.clear();
    String userID = storage.read('userMasterID');
    var barcode = await BarcodeScanner.scan();
    log('Qr code $barcode');
    log('userID $userID');
    outputController.text = barcode.rawContent;
    getVehicleEntryData(false);
  }

  Future<bool> generatePdf(
    String amount,
    String vehicleNumber,
    String companyName,
    String paymentType,
    String vehicleType,
    String date,
    String time,
    pw.MemoryImage bikeIcon,
    String dateOut,
    String totalTime,
  ) async {
    final pdf = pw.Document();

    // Use built-in fonts
    final font = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "---------------------------------------",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "---------------------------------------",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 20,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Payment Receipt",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 22,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Vehicle No.: $vehicleNumber',
                      style: pw.TextStyle(font: font, fontSize: 18),
                    ),
                    pw.Text(
                      'Amount Paid: $amount',
                      style: pw.TextStyle(font: font, fontSize: 18),
                    ),
                    pw.Text(
                      'Payment Type: $paymentType',
                      style: pw.TextStyle(font: font, fontSize: 18),
                    ),
                    pw.Text(
                      'Entry: $date, $time',
                      style: pw.TextStyle(font: font, fontSize: 18),
                    ),
                    pw.Text(
                      'Exit: $dateOut',
                      style: pw.TextStyle(font: font, fontSize: 18),
                    ),
                    pw.Text(
                      'Total Time: $totalTime',
                      style: pw.TextStyle(font: font, fontSize: 18),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Image(bikeIcon, width: 150, height: 100),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Drive Safely.",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  "Thank you for Visiting",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  "Come Again!",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 18,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (kIsWeb) {
      final bytes = await pdf.save();
      // final blob = html.Blob([bytes], 'application/pdf');
      // final url = html.Url.createObjectUrlFromBlob(blob);
      // html.window.open(url, '_blank'); // Open in a new tab
      // html.Url.revokeObjectUrl(url);
      return true;
    } else {
      return await Printing.layoutPdf(
        name: '$vehicleNumber-qrScan',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  }

  pw.Widget buildHeader(String companyName) {
    return pw.Column(
      children: [
        pw.Text(
          "---------------------------------------",
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          companyName,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          "---------------------------------------",
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget buildFooter() {
    return pw.Column(
      children: [
        pw.Text("Drive Safely.",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text("Thank you for Visiting",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text("Come Again!",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}
