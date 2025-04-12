import 'package:aditya_birla/Screens/Admin_Dashboard/Controller/adminDashboardController.dart';
import 'package:get/get.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AdminDashboardController>(AdminDashboardController());
  }
}
