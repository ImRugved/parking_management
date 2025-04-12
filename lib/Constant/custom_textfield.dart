import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aditya_birla/Constant/const_colors.dart';
import 'package:aditya_birla/Constant/custom_textstyle.dart';

class CustomTextFormField extends StatelessWidget {
  // final double width;
  // final double height;
  final String customText;
  final bool isBool;
  final void Function(String?)? onSaved;
  final String? label;
  final TextEditingController controller;
  final TextInputType? keyoardType;
  final String? Function(String?)? validator;
  final Function(String) onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool obsercureText;
  final int minline;
  final int maxline;
  final Widget iconss;
  const CustomTextFormField({
    super.key,

    // required this.width,
    this.onSaved,
    this.isBool = false,
    required this.customText,
    required this.controller,
    required this.validator,
    required this.inputFormatters,
    this.readOnly = false,
    this.obsercureText = false,
    this.minline = 1,
    this.label,
    this.maxline = 1,
    this.iconss = const SizedBox(),
    required this.onChanged,
    this.keyoardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obsercureText,
      inputFormatters: inputFormatters,
      keyboardType: keyoardType ?? TextInputType.emailAddress,
      readOnly: readOnly,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      style:
          isBool ? getTextTheme().headlineSmall : getTextTheme().headlineMedium,
      cursorColor: ConstColors.green,
      maxLines: maxline,
      cursorHeight: 30.h,
      minLines: minline,
      decoration: InputDecoration(
        label: Text(
          label ?? "",
          style: isBool
              ? getTextTheme().headlineSmall
              : getTextTheme().headlineMedium,
        ),
        //hintText: customText,
        suffixIcon: iconss,
        hintStyle:
            isBool ? getTextTheme().labelSmall : getTextTheme().labelMedium,
        errorStyle: TextStyle(
          height: 0.sp,
          color: ConstColors.red,
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
        ),
        //filled: true,
        //fillColor: ConstColors.backgroundColor,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 0),
        focusedBorder: UnderlineInputBorder(
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.sp, color: ConstColors.green),
        ),
        disabledBorder: UnderlineInputBorder(
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.sp, color: ConstColors.modelSheet),
        ),
        enabledBorder: UnderlineInputBorder(
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.sp, color: ConstColors.modelSheet),
        ),
        border: UnderlineInputBorder(
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.sp, color: ConstColors.modelSheet),
        ),
        errorBorder: UnderlineInputBorder(
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.sp, color: ConstColors.red),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          //borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(width: 2.sp, color: ConstColors.red),
        ),
      ),
      onChanged: onChanged,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
