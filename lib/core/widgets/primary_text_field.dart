
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warshity/core/styling/app_colors.dart';
import 'package:warshity/core/styling/app_fonts.dart';

class PrimaryTextField extends StatelessWidget {
  final String? hintText;
  final double? width;
  final bool? isPassword;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  const PrimaryTextField({
    super.key,
    this.hintText,
    this.isPassword,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.width,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 350.w,

      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        cursorColor: AppColors.primaryColor,
        obscureText: isPassword ?? false,
        decoration: InputDecoration(
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          hintText: hintText ?? "",
          hintStyle: TextStyle(
            fontFamily: AppFonts.appFonts,
            color: Color(0xff999999),
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Color(0xffE6E6E6), width: 1.sp),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 1.sp),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
