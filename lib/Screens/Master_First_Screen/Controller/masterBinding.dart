import 'package:get/get.dart';
import 'masterController.dart';

class MasterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MasterController());
  }
}
