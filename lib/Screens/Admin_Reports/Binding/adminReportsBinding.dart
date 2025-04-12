import 'package:aditya_birla/Screens/Admin_Reports/Controller/adminReportsController.dart';
import 'package:get/get.dart';

class AdminReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AdminReportsController>(AdminReportsController());
  }
}
