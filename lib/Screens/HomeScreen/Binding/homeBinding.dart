import 'package:get/get.dart';
import 'package:aditya_birla/Screens/HomeScreen/Controller/HomeController.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
