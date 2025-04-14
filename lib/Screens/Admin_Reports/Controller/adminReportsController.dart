import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminReportsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage storage = GetStorage();

  RxBool isLoading = false.obs;
  RxBool isDownloading = false.obs;

  // Tab selection
  RxInt selectedTabIndex = 0.obs;

  // Date range selection
  Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 7)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  // Data lists
  RxList<Map<String, dynamic>> vehicleEntries = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> vehicleExits = <Map<String, dynamic>>[].obs;

  // Filtered data lists for search
  RxList<Map<String, dynamic>> filteredVehicleEntries =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredVehicleExits =
      <Map<String, dynamic>>[].obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  // Summary metrics
  RxInt totalEntries = 0.obs;
  RxInt totalExits = 0.obs;
  RxDouble totalRevenue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();

    // Add listener to search controller
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterData();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Filter data based on search query
  void filterData() {
    if (searchQuery.value.isEmpty) {
      // If search query is empty, show all data
      filteredVehicleEntries.value = vehicleEntries;
      filteredVehicleExits.value = vehicleExits;
    } else {
      // Filter entries by vehicle number
      filteredVehicleEntries.value = vehicleEntries.where((entry) {
        final vehicleNumber =
            entry['vehicleNumber']?.toString().toLowerCase() ?? '';
        return vehicleNumber.contains(searchQuery.value.toLowerCase());
      }).toList();

      // Filter exits by vehicle number
      filteredVehicleExits.value = vehicleExits.where((exit) {
        final vehicleNumber =
            exit['vehicleNumber']?.toString().toLowerCase() ?? '';
        return vehicleNumber.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    update(['report_tabs']);
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterData();
  }

  // Change selected tab
  void changeTab(int index) {
    selectedTabIndex.value = index;
    update(['report_tabs']);
  }

  // Set date range
  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    fetchData();
    update(['report_tabs']);
  }

  // Fetch data based on date range
  Future<void> fetchData() async {
    try {
      isLoading.value = true;

      // Get admin ID
      final String adminId = storage.read('userMasterID') ?? '';

      // Calculate date range (end date should be end of day)
      final DateTime endOfDay = DateTime(
        endDate.value.year,
        endDate.value.month,
        endDate.value.day,
        23,
        59,
        59,
      );

      // Fetch all entries for this admin (simpler query)
      final entriesQuery = await _firestore
          .collection('vehicle_entries')
          .where('adminId', isEqualTo: adminId)
          .get();

      // Filter entries by date range in memory
      vehicleEntries.value = entriesQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((entry) {
        // Filter by entry time within date range
        final entryTime = DateTime.parse(entry['entryTime']);
        return entryTime.isAfter(startDate.value) &&
            entryTime.isBefore(endOfDay);
      }).toList();

      // Sort entries by entry time (descending)
      vehicleEntries.sort((a, b) {
        final aTime = DateTime.parse(a['entryTime']);
        final bTime = DateTime.parse(b['entryTime']);
        return bTime.compareTo(aTime); // descending order
      });

      // Fetch all exits (completed entries) for this admin
      final exitsQuery = await _firestore
          .collection('vehicle_entries')
          .where('adminId', isEqualTo: adminId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Filter exits by date range in memory
      vehicleExits.value = exitsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((exit) {
        // Only include if exitTime exists and is within range
        if (!exit.containsKey('exitTime')) return false;
        final exitTime = DateTime.parse(exit['exitTime']);
        return exitTime.isAfter(startDate.value) && exitTime.isBefore(endOfDay);
      }).toList();

      // Sort exits by exit time (descending)
      vehicleExits.sort((a, b) {
        final aTime = DateTime.parse(a['exitTime']);
        final bTime = DateTime.parse(b['exitTime']);
        return bTime.compareTo(aTime); // descending order
      });

      // Initialize filtered lists
      filteredVehicleEntries.value = vehicleEntries;
      filteredVehicleExits.value = vehicleExits;

      // Calculate metrics
      totalEntries.value = vehicleEntries.length;
      totalExits.value = vehicleExits.length;

      // Calculate total revenue
      totalRevenue.value = vehicleExits.fold(
        0.0,
        (sum, item) => sum + (item['charges'] ?? 0.0),
      );

      update(['report_tabs']);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch data: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Format datetime for display
  String formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  // Generate PDF report
  Future<void> generatePdfReport() async {
    try {
      isDownloading.value = true;

      final pdf = pw.Document();
      final orgName = storage.read('organization') ?? 'Parking Management';

      // Format dates for title
      final startDateFormatted =
          DateFormat('MMM dd, yyyy').format(startDate.value);
      final endDateFormatted = DateFormat('MMM dd, yyyy').format(endDate.value);

      // Add title page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    orgName,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    "Parking Activity Report",
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    "$startDateFormatted to $endDateFormatted",
                    style: pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(10)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Summary",
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      _buildSummaryRow(
                          "Total Entries", totalEntries.value.toString()),
                      pw.SizedBox(height: 10),
                      _buildSummaryRow(
                          "Total Exits", totalExits.value.toString()),
                      pw.SizedBox(height: 10),
                      _buildSummaryRow("Total Revenue",
                          "Rs ${totalRevenue.value.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  "Report generated on: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}",
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Add entries data page
      if (vehicleEntries.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Vehicle Entries",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  _buildEntriesTable(),
                ],
              );
            },
          ),
        );
      }

      // Add exits data page
      if (vehicleExits.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Vehicle Exits",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  _buildExitsTable(),
                ],
              );
            },
          ),
        );
      }

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: "Parking Report $startDateFormatted to $endDateFormatted.pdf",
      );

      Get.snackbar(
        "Success",
        "Report generated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to generate report: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  // Helper method to build summary row
  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 14,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper method to build entries table
  pw.Widget _buildEntriesTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(100),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FlexColumnWidth(),
        4: const pw.FixedColumnWidth(80),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            _buildTableCell("Sr.", isHeader: true),
            _buildTableCell("Date & Time", isHeader: true),
            _buildTableCell("Vehicle No.", isHeader: true),
            _buildTableCell("Location", isHeader: true),
            _buildTableCell("Type", isHeader: true),
          ],
        ),
        // Data rows
        ...vehicleEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final entryTime = DateTime.parse(data['entryTime']);
          final formattedTime =
              DateFormat('MM/dd/yy\nhh:mm a').format(entryTime);

          return pw.TableRow(
            children: [
              _buildTableCell((index + 1).toString()),
              _buildTableCell(formattedTime),
              _buildTableCell(data['vehicleNumber'] ?? '-'),
              _buildTableCell(data['location'] ?? '-'),
              _buildTableCell(data['vehicleType'] ?? '-'),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Helper method to build exits table
  pw.Widget _buildExitsTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(100),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FixedColumnWidth(70),
        4: const pw.FixedColumnWidth(60),
        5: const pw.FlexColumnWidth(),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            _buildTableCell("Sr.", isHeader: true),
            _buildTableCell("Exit Time", isHeader: true),
            _buildTableCell("Vehicle No.", isHeader: true),
            _buildTableCell("Duration", isHeader: true),
            _buildTableCell("Charges", isHeader: true),
            _buildTableCell("Payment", isHeader: true),
          ],
        ),
        // Data rows
        ...vehicleExits.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final exitTime = DateTime.parse(data['exitTime']);
          final formattedTime =
              DateFormat('MM/dd/yy\nhh:mm a').format(exitTime);

          // Format duration
          final hours = data['durationHours'] ?? 0;
          final minutes = data['durationMinutes'] ?? 0;
          final duration = "${hours}h ${minutes}m";

          return pw.TableRow(
            children: [
              _buildTableCell((index + 1).toString()),
              _buildTableCell(formattedTime),
              _buildTableCell(data['vehicleNumber'] ?? '-'),
              _buildTableCell(duration),
              _buildTableCell("Rs ${data['charges']?.toString() ?? '-'}"),
              _buildTableCell(data['paymentType'] ?? '-'),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Helper method to build table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }
}
