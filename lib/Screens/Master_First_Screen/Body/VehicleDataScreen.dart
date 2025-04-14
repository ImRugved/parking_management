import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aditya_birla/Constant/const_colors.dart';
import '../Controller/masterController.dart';

class VehicleDataScreen extends StatelessWidget {
  final MasterController controller;
  final String organizationId;
  final String organizationName;

  const VehicleDataScreen({
    Key? key,
    required this.controller,
    required this.organizationId,
    required this.organizationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller with organization data
    controller.selectedOrganizationId.value = organizationId;
    controller.selectedOrganizationName.value = organizationName;

    return WillPopScope(
      onWillPop: () async {
        // Return to the manage users screen instead of exiting the app
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Vehicle Data - $organizationName',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: GetBuilder<MasterController>(
          id: 'vehicle_data',
          builder: (_) {
            return Column(
              children: [
                // Organization info header
                Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Filter
                      if (controller.showVehicleEntries.value) ...[
                        _buildDateFilter(controller),
                        SizedBox(height: 16.h),
                      ],
                      // Tab selection
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  controller.toggleVehicleDataView(true),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: controller.showVehicleEntries.value
                                      ? ConstColors.green
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: controller.showVehicleEntries.value
                                        ? ConstColors.green
                                        : Colors.grey[400]!,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Vehicle Entries',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: controller.showVehicleEntries.value
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  controller.toggleVehicleDataView(false),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: !controller.showVehicleEntries.value
                                      ? ConstColors.green
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: !controller.showVehicleEntries.value
                                        ? ConstColors.green
                                        : Colors.grey[400]!,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Parking Rates',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          !controller.showVehicleEntries.value
                                              ? Colors.white
                                              : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content area
                Expanded(
                  child: controller.showVehicleEntries.value
                      ? _buildVehicleEntriesTab(controller)
                      : _buildVehicleRatesTab(controller),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Date filter widget
  Widget _buildDateFilter(MasterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.date_range, color: ConstColors.green, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'Filter by Date Range',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: Get.context!,
                    initialDate: controller.fromDate.value,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: ConstColors.green,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (selectedDate != null) {
                    controller.setDateRange(
                      selectedDate,
                      controller.toDate.value,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          'From: ${controller.formatDateOnly(controller.fromDate.value)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: Get.context!,
                    initialDate: controller.toDate.value,
                    firstDate: controller.fromDate.value,
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: ConstColors.green,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (selectedDate != null) {
                    controller.setDateRange(
                      controller.fromDate.value,
                      selectedDate,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          'To: ${controller.formatDateOnly(controller.toDate.value)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {
                controller.resetDateFilter();
              },
              icon: Icon(
                Icons.refresh,
                size: 16.sp,
                color: controller.useCustomDateRange.value
                    ? ConstColors.green
                    : Colors.grey[400],
              ),
              label: Text(
                'Reset Filter',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: controller.useCustomDateRange.value
                      ? ConstColors.green
                      : Colors.grey[400],
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleEntriesTab(MasterController controller) {
    return Obx(() {
      // Show loading indicator
      if (controller.isLoadingVehicleEntries.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Show custom message for no data in date range
      if (controller.noDataForDateRange.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 72.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                'No data available for the selected date range',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              TextButton.icon(
                onPressed: () {
                  controller.resetDateFilter();
                },
                icon: Icon(
                  Icons.refresh,
                  size: 16.sp,
                  color: ConstColors.green,
                ),
                label: Text(
                  'Reset Date Filter',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: ConstColors.green,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Show error message if one is set
      if (controller.vehicleQueryErrorMessage.value.isNotEmpty) {
        return Center(
          child: Text(
            controller.vehicleQueryErrorMessage.value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      return StreamBuilder<QuerySnapshot>(
        stream: controller.getVehicleEntries(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_crash_outlined,
                    size: 72.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No vehicle entries found for this organization',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final entries = snapshot.data!.docs;
          entries.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            // Get entry time with fallback options for different field formats
            final aEntryTime = _getDateTimeFromEntry(aData);
            final bEntryTime = _getDateTimeFromEntry(bData);

            return bEntryTime.compareTo(aEntryTime); // Newer entries first
          });

          return ListView.builder(
            padding: EdgeInsets.all(16.sp),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index].data() as Map<String, dynamic>;

              // Get vehicle number with fallbacks
              final vehicleNo =
                  entry['vehicleNo'] ?? entry['vehicleNumber'] ?? 'Unknown';

              // Get vehicle type with fallbacks
              final vehicleType =
                  entry['vehicleType'] ?? entry['vehicleTypeId'] ?? 'Unknown';

              // Get entry time
              final entryTime = _getDateTimeFromEntry(entry);

              // Get exit time if available
              final exitTime = entry['exitTime'] != null
                  ? DateTime.parse(entry['exitTime'].toString())
                  : (entry['status'] == 'completed' ? DateTime.now() : null);

              // Get amount paid
              final amount = entry['amount'] ?? entry['charges'] ?? '0';

              // Get location with fallbacks
              final location =
                  entry['locationName'] ?? entry['location'] ?? 'Unknown';

              // Determine status
              final status = entry['status'] == 'completed' || exitTime != null
                  ? 'Exited'
                  : 'Parked';

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: status == 'Exited'
                        ? Colors.grey[300]!
                        : ConstColors.green.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                vehicleType.toString().contains('2') ||
                                        vehicleType
                                            .toString()
                                            .toLowerCase()
                                            .contains('bike')
                                    ? Icons.two_wheeler
                                    : Icons.directions_car,
                                color: ConstColors.green,
                                size: 24.sp,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                vehicleNo,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Exited'
                                  ? Colors.grey[200]
                                  : ConstColors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: status == 'Exited'
                                    ? Colors.grey[700]
                                    : ConstColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24.h),
                      _infoRow('Vehicle Type', vehicleType),
                      SizedBox(height: 6.h),
                      _infoRow('Location', location),
                      SizedBox(height: 6.h),
                      _infoRow(
                          'Entry Time', controller.formatDateTime(entryTime)),
                      if (exitTime != null) ...[
                        SizedBox(height: 6.h),
                        _infoRow(
                            'Exit Time', controller.formatDateTime(exitTime)),
                        SizedBox(height: 6.h),
                        _infoRow('Amount Paid', '₹$amount'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _buildVehicleRatesTab(MasterController controller) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getVehicleRates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.money_off,
                  size: 72.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No vehicle rates defined for this organization',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final rates = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16.sp),
          itemCount: rates.length,
          itemBuilder: (context, index) {
            final rate = rates[index].data() as Map<String, dynamic>;

            // Get vehicle type with fallbacks
            final vehicleType = rate['vehicleTypeId'] ?? 'Unknown';

            // Get rate values with fallbacks
            final firstHourRate = rate['hoursRate'] ??
                rate['amountFor2'] ??
                rate['firstHoursRate'] ??
                '0';
            final additionalHourRate = rate['everyHoursRate'] ??
                rate['amountAfter2'] ??
                rate['additionalHourRate'] ??
                '0';
            final dayRate = rate['hours24Rate'] ?? rate['dayRate'] ?? '0';

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: ConstColors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          vehicleType.contains('2') ||
                                  vehicleType.toLowerCase().contains('bike')
                              ? Icons.two_wheeler
                              : Icons.directions_car,
                          color: ConstColors.green,
                          size: 24.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          vehicleType,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24.h),
                    _rateRow('First 2 Hours', '₹$firstHourRate'),
                    SizedBox(height: 6.h),
                    _rateRow('Every Additional Hour', '₹$additionalHourRate'),
                    SizedBox(height: 6.h),
                    _rateRow('Full Day (24 Hours)', '₹$dayRate'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[900],
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _rateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: ConstColors.green,
          ),
        ),
      ],
    );
  }

  // Helper method to extract date time from entry with fallbacks
  DateTime _getDateTimeFromEntry(Map<String, dynamic> entry) {
    if (entry['entryTime'] != null) {
      try {
        return DateTime.parse(entry['entryTime'].toString());
      } catch (e) {
        // Continue to fallbacks
      }
    }

    if (entry['createdAt'] != null) {
      try {
        return DateTime.parse(entry['createdAt'].toString());
      } catch (e) {
        // Continue to fallbacks
      }
    }

    return DateTime.now(); // Default fallback
  }
}
