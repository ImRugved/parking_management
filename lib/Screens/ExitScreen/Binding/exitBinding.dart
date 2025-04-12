import 'package:get/get.dart';
import 'package:aditya_birla/Screens/ExitScreen/Controller/exitController.dart';

class ExitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExitController>(
      () => ExitController(),
    );
  }
}
