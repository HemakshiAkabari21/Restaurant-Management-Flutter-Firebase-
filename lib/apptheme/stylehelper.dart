import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';


const String bold = 'PoppinsBold';
const String extraBold = 'PoppinsExtraBold';
const String extraExtraBold = 'PoppinsBlack';
const String regular = 'PoppinsRegular';
const String medium = 'PoppinsMedium';
const String semiBold = 'PoppinsSemiBold';

class StyleHelper {
  static TextStyle customStyle({
    Color? color,
    double? size,
    String? family,
    TextDecoration? decoration,
    Color? decorationColor,
  }){
    return TextStyle(
      fontFamily: family??regular,
      color: color ?? AppColors.black,
      fontSize: size??14.sp,
      decoration: decoration ?? TextDecoration.none,
      decorationColor: decorationColor ?? AppColors.black
    );
  }
}

