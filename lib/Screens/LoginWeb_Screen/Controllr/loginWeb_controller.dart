import 'dart:developer';

import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/global.dart';
import 'package:aditya_birla/Utils/Api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginWebController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    userId.clear();
    password.clear();
    isVisible = false.obs;
    isLoading = false.obs;
  }

  @override
  void onClose() {
    userId.clear();
    password.clear();
    isVisible = false.obs;
    isLoading = false.obs;
    super.onClose();
  }

  final GetStorage storage = GetStorage();
  API api = API();

  TextEditingController userId = TextEditingController();
  TextEditingController password = TextEditingController();
  String? errorLogin;
  RxBool isVisible = false.obs;
  RxBool isLoading = false.obs;

  Future<void> loginApiCall() async {
    isLoading.value = true;
    Map<String, String> body = {
      "User_Name": userId.text,
      "Password": password.text,
    };
    try {
      log("api call");
      log("query Param $body");
      final response = await api.sendRequest.post(
        Global.hostUrl + Global.logInApi,
        queryParameters: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      log('login number msg : ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data > 0) {
          Map<String, String> param = {
            "UserName": userId.text,
            "Password": password.text,
          };
          final response1 = await api.sendRequest.post(
            Global.hostUrl + Global.jswTokenApi,
            queryParameters: param,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
              },
            ),
          );
          if (response1.statusCode == 200 || response1.statusCode == 201) {
            log("jsw is ${response1.data["token"]}");
            await storage.write("authToken", response1.data["token"]);
            await storage.write("username", response1.data["username"]);
            await storage.write("name", response1.data["name"]);
            await storage.write("userMasterID", response1.data["userMasterID"]);
            await storage.write("permission", response1.data["permission"]);
            Get.offAllNamed("/exit_web_screen",
                arguments: {"permission": response1.data["permission"]});
          }
        } else {
          Get.snackbar("Invalid User", "User is not valid",
              backgroundColor: ConstColors.white,
              colorText: ConstColors.primary);
        }
      }
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError) {
        Get.snackbar("NetWork Error", "Please check network connectivity",
            backgroundColor: ConstColors.white, colorText: ConstColors.primary);
      } else if (error.type == DioExceptionType.connectionTimeout) {
        Get.snackbar(
            "Connection timeout", "Connection timeout, please try again",
            backgroundColor: ConstColors.white, colorText: ConstColors.primary);
      } else if (error.response!.statusCode! >= 400 &&
          error.response!.statusCode! <= 500) {
        log(" main login status code is ${error.response?.statusCode}");
        Get.snackbar("Error Login", "Invalid login ,please login again",
            backgroundColor: ConstColors.white, colorText: ConstColors.primary);
      } else {
        Get.snackbar("Unexpected error occurred", " please try again",
            backgroundColor: ConstColors.white, colorText: ConstColors.primary);
      }
    } catch (error) {
      log('Register number ERROR : $error');
      Get.snackbar("Error", "$error",
          backgroundColor: ConstColors.white, colorText: ConstColors.primary);
    } finally {
      isLoading.value = false;
    }
  }
}
