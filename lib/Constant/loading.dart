import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:aditya_birla/Constant/const_colors.dart';

extension Extension on Widget {
  Widget toProgress(RxBool isLoading, {double? h, double? w}) {
    return Obx(() => Center(
          child: isLoading.value == true
              ? Center(
                  child: SizedBox(
                      height: h ?? 25,
                      width: w ?? 25,
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballRotateChase,

                        /// Required, The loading type of the widget
                        colors: [ConstColors.green],

                        /// Optional, The color collections
                        strokeWidth: 2,
                      )),
                )
              : this,
        ));
  }
}
