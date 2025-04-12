import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AdminDashboardController extends GetxController {
  final GetStorage storage = GetStorage();

  String get userName => storage.read('name') ?? 'Admin User';
  String get organization => storage.read('organization') ?? 'Parking System';
  String get email => storage.read('username') ?? 'admin@example.com';

  @override
  void onInit() {
    super.onInit();
    // Redirect if no admin access
    if (!checkAdminAccess()) {
      Get.offAllNamed('/first_screen');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Check if the user has admin access
  bool checkAdminAccess() {
    return storage.read('adminAccess') == true;
  }

  // Sign out of admin dashboard
  void adminLogout() {
    storage.remove('adminAccess');
    Get.offAllNamed('/first_screen');
  }

  // Full logout
  void fullLogout() {
    storage.erase();
    Get.offAllNamed('/login_screen');
  }
}
