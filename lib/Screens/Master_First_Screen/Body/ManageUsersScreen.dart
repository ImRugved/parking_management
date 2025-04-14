import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/const_colors.dart';
import '../Controller/masterController.dart';
import 'VehicleDataScreen.dart';

class ManageUsersScreen extends StatelessWidget {
  final MasterController controller;

  const ManageUsersScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                              // Navigate to the vehicle data screen
                              Get.to(
                                () => VehicleDataScreen(
                                  controller: controller,
                                  organizationId: orgId,
                                  organizationName: orgName,
                                ),
                                transition: Transition.rightToLeft,
                              );
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
}
