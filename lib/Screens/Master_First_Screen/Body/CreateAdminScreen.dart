import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/const_colors.dart';
import '../Controller/masterController.dart';

class CreateAdminScreen extends StatelessWidget {
  final MasterController controller;

  const CreateAdminScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
