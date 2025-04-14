import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';
import 'package:aditya_birla/Constant/loading.dart';
import 'package:aditya_birla/Constant/rounded_button.dart';
import 'package:aditya_birla/Screens/Admin_Reports/Controller/adminReportsController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminReportsView extends GetView<AdminReportsController> {
  const AdminReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: ConstColors.black,
            size: 25.sp,
          ),
        ),
        title: Text(
          "Parking Reports",
          style: getTextTheme().headlineLarge,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: ConstColors.white,
        surfaceTintColor: ConstColors.backgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              _showDateRangePicker(context);
            },
            icon: Icon(
              Icons.date_range,
              color: ConstColors.green,
              size: 25.sp,
            ),
            tooltip: "Select Date Range",
          ),
          IconButton(
            onPressed: () {
              controller.generatePdfReport();
            },
            icon: Icon(
              Icons.download,
              color: ConstColors.green,
              size: 25.sp,
            ),
            tooltip: "Download Report",
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: GetBuilder<AdminReportsController>(
        id: 'report_tabs',
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildDateRangeHeader(),
              _buildSearchBar(),
              _buildSummaryCard(),
              _buildTabBar(),
              Expanded(
                child: controller.selectedTabIndex.value == 0
                    ? _buildEntriesTab()
                    : _buildExitsTab(),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget to build search bar
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: "Search by vehicle number",
          prefixIcon: Icon(
            Icons.search,
            color: ConstColors.green,
          ),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: ConstColors.green,
                  ),
                  onPressed: () {
                    controller.clearSearch();
                  },
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          // This will trigger search via the listener in controller
        },
      ),
    );
  }

  // Method to show date range picker
  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ConstColors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ConstColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }

  // Widget to display the date range header
  Widget _buildDateRangeHeader() {
    final startFormatted =
        DateFormat('MMM dd, yyyy').format(controller.startDate.value);
    final endFormatted =
        DateFormat('MMM dd, yyyy').format(controller.endDate.value);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
      color: ConstColors.green.withOpacity(0.1),
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10.w,
        children: [
          Icon(
            Icons.calendar_today,
            color: ConstColors.green,
            size: 18.sp,
          ),
          Text(
            "Date Range: $startFormatted - $endFormatted",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: ConstColors.green,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget to display summary metrics
  Widget _buildSummaryCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildMetricItem(
              "Total Entries",
              controller.totalEntries.value.toString(),
              Icons.login,
            ),
          ),
          Expanded(
            child: _buildMetricItem(
              "Total Exits",
              controller.totalExits.value.toString(),
              Icons.logout,
            ),
          ),
          Expanded(
            child: _buildMetricItem(
              "Revenue",
              "Rs ${controller.totalRevenue.value.toStringAsFixed(0)}",
              Icons.attach_money,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display a single metric
  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: ConstColors.green,
          size: 25.sp,
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: ConstColors.black,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget to display the tab bar
  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: controller.selectedTabIndex.value == 0
                      ? ConstColors.green
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    "Entries",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: controller.selectedTabIndex.value == 0
                          ? Colors.white
                          : ConstColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: controller.selectedTabIndex.value == 1
                      ? ConstColors.green
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    "Exits",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: controller.selectedTabIndex.value == 1
                          ? Colors.white
                          : ConstColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display entries tab
  Widget _buildEntriesTab() {
    if (controller.filteredVehicleEntries.isEmpty) {
      return Center(
        child: Text(
          controller.searchQuery.value.isEmpty
              ? "No entries found for this date range"
              : "No entries found for '${controller.searchQuery.value}'",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: controller.filteredVehicleEntries.length,
        itemBuilder: (context, index) {
          final entry = controller.filteredVehicleEntries[index];
          final entryTime = DateTime.parse(entry['entryTime']);
          final formattedTime =
              DateFormat('MMM dd, yyyy hh:mm a').format(entryTime);

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: ConstColors.green.withOpacity(0.2),
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: ConstColors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  entry['vehicleNumber'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Entry: $formattedTime"),
                    Text("Type: ${entry['vehicleType'] ?? 'Unknown'}"),
                    Text("Location: ${entry['location'] ?? 'Unknown'}"),
                  ],
                ),
                isThreeLine: true,
              ),
              Divider(height: 1, color: Colors.grey[300]),
            ],
          );
        },
      ),
    );
  }

  // Widget to display exits tab
  Widget _buildExitsTab() {
    if (controller.filteredVehicleExits.isEmpty) {
      return Center(
        child: Text(
          controller.searchQuery.value.isEmpty
              ? "No exits found for this date range"
              : "No exits found for '${controller.searchQuery.value}'",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: controller.filteredVehicleExits.length,
        itemBuilder: (context, index) {
          final exit = controller.filteredVehicleExits[index];
          final exitTime = DateTime.parse(exit['exitTime']);
          final formattedTime =
              DateFormat('MMM dd, yyyy hh:mm a').format(exitTime);

          // Format duration
          final hours = exit['durationHours'] ?? 0;
          final minutes = exit['durationMinutes'] ?? 0;
          final duration = "${hours}h ${minutes}m";

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.2),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  exit['vehicleNumber'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Exit: $formattedTime"),
                    Text("Duration: $duration"),
                    Text(
                        "Charges: Rs ${exit['charges']?.toString() ?? '0.00'}"),
                    Text("Payment: ${exit['paymentType'] ?? 'Unknown'}"),
                  ],
                ),
                isThreeLine: true,
              ),
              Divider(height: 1, color: Colors.grey[300]),
            ],
          );
        },
      ),
    );
  }
}
