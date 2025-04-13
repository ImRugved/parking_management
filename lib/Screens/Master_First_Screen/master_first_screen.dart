import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../Screens/Login_Screen/Controller/loginController.dart';
import '../../Constant/const_colors.dart';
import 'Controller/masterController.dart';

class MasterFirstScreen extends StatelessWidget {
  const MasterFirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MasterController>(
      init: MasterController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Master Dashboard',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
            ),
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  controller.signOut();
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 25.sp,
                ),
              ),
            ],
          ),
          body: GetBuilder<MasterController>(
            id: 'master_dashboard',
            builder: (_) {
              return Column(
                children: [
                  _buildNavigation(controller),
                  Expanded(
                    child: _buildCurrentView(controller),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNavigation(MasterController controller) {
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _navButton(
              'Manage Users',
              Icons.people,
              controller.currentView.value == 'manage_users',
              () => controller.changeView('manage_users'),
            ),
            SizedBox(width: 8.w),
            _navButton(
              'Create Admin',
              Icons.person_add,
              controller.currentView.value == 'create_admin',
              () => controller.changeView('create_admin'),
            ),
            if (controller.currentView.value == 'vehicle_data') ...[
              SizedBox(width: 8.w),
              _navButton(
                'Back',
                Icons.arrow_back,
                false,
                () => controller.changeView('manage_users'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _navButton(
      String title, IconData icon, bool isActive, Function() onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? ConstColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? ConstColors.green : Colors.grey[400]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[700],
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView(MasterController controller) {
    switch (controller.currentView.value) {
      case 'create_admin':
        return _buildCreateAdminForm(controller);
      case 'vehicle_data':
        return _buildVehicleDataView(controller);
      case 'manage_users':
      default:
        return _buildManageUsersView(controller);
    }
  }

  Widget _buildCreateAdminForm(MasterController controller) {
    return GetBuilder<MasterController>(
      id: 'create_admin_form',
      builder: (_) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Admin Account',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                controller: controller.nameController,
                label: 'Full Name',
                icon: Icons.person,
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: controller.emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              _buildPasswordField(controller),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: controller.organizationController,
                label: 'Organization Name',
                icon: Icons.business,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstColors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.createAdminUser();
                        },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Create Admin Account',
                          style: GoogleFonts.poppins(fontSize: 16.sp),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildPasswordField(MasterController controller) {
    return TextField(
      controller: controller.passwordController,
      obscureText: !controller.isVisible.value,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isVisible.value
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            controller.togglePasswordVisibility();
          },
        ),
      ),
    );
  }

  Widget _buildManageUsersView(MasterController controller) {
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getAllOrganizations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No organizations found',
              style: GoogleFonts.poppins(fontSize: 16.sp),
            ),
          );
        }

        final organizations = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16.sp),
          itemCount: organizations.length,
          itemBuilder: (context, index) {
            final organization =
                organizations[index].data() as Map<String, dynamic>;
            final orgId = organizations[index].id;
            final orgName = organization['name'] ?? 'Unknown';
            final orgStatus = organization['status'] ?? 'inactive';
            final orgEmail = organization['email'] ?? 'No email';

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16.h),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: orgStatus == 'active'
                        ? ConstColors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ExpansionTile(
                  tilePadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  title: Text(
                    orgName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.h),
                      Text(
                        orgEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: orgStatus == 'active'
                                  ? ConstColors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                            ),
                            child: Text(
                              orgStatus == 'active' ? 'Active' : 'Inactive',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: orgStatus == 'active'
                                    ? ConstColors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundColor: orgStatus == 'active'
                        ? ConstColors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    child: Icon(
                      Icons.business,
                      color: orgStatus == 'active'
                          ? ConstColors.green
                          : Colors.red,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status:',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              GetBuilder<MasterController>(
                                id: 'manage_users',
                                builder: (_) {
                                  return Switch(
                                    value: orgStatus == 'active',
                                    activeColor: ConstColors.green,
                                    onChanged: controller.isLoading.value
                                        ? null
                                        : (value) {
                                            controller.toggleUserStatus(
                                                orgId, value);
                                          },
                                  );
                                },
                              ),
                            ],
                          ),
                          Divider(height: 20.h),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ConstColors.green,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 16.w,
                              ),
                            ),
                            onPressed: () {
                              controller.viewOrganizationData(orgId, orgName);
                            },
                            icon: const Icon(Icons.visibility),
                            label: Text(
                              'View Vehicle Data',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVehicleDataView(MasterController controller) {
    return GetBuilder<MasterController>(
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
                  Row(
                    children: [
                      Icon(Icons.business, color: ConstColors.green),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '${controller.selectedOrganizationName.value}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
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
                          onTap: () => controller.toggleVehicleDataView(true),
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
                          onTap: () => controller.toggleVehicleDataView(false),
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
                                  color: !controller.showVehicleEntries.value
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
    return StreamBuilder<QuerySnapshot>(
      stream: controller.getVehicleEntries(),
      builder: (context, snapshot) {
        // Don't call controller methods during build

        // Use Obx for reactive UI components
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

          // Show message when no data is available
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
        });
      },
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
              elevation: 3,
              margin: EdgeInsets.only(bottom: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: ConstColors.green.withOpacity(0.1),
                          radius: 24.r,
                          child: Icon(
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
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          vehicleType,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24.h),
                    _buildRateRow('First 2 Hours', '₹$firstHourRate'),
                    SizedBox(height: 12.h),
                    _buildRateRow(
                        'Every Additional Hour', '₹$additionalHourRate'),
                    SizedBox(height: 12.h),
                    _buildRateRow('24-Hour Rate', '₹$dayRate'),
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
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.grey[700],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: ConstColors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ConstColors.green.withOpacity(0.3),
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ConstColors.green,
            ),
          ),
        ),
      ],
    );
  }
}
