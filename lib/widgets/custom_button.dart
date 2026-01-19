import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../apptheme/app_colors.dart';
import '../apptheme/stylehelper.dart';
import 'common_widget.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? horizontalPadding;
  final double? leftMargin;
  final double? rightMargin;
  final double? topMargin;
  final double? bottomMargin;
  final double? topPadding;
  final double? bottomPadding;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final String? text;
  final Function()? onTap;
  final TextStyle? textStyle;
  final Widget? childWidget;
  final List<BoxShadow>? boxShadow;

  const CustomButton(
      {super.key,
        this.height,
        this.width,
        this.color,
        this.borderColor,
        this.textStyle,
        this.leftMargin,
        this.rightMargin,
        this.horizontalPadding,
        this.topMargin,
        this.bottomMargin,
        this.topPadding,
        this.bottomPadding,
        this.borderRadius,
        this.childWidget,
        this.text,
        this.boxShadow,
        this.onTap
      });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height??42.h,
        width: width,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        margin: EdgeInsets.only(
            left: leftMargin??0,
            right: rightMargin??0,
            top: topMargin??0,
            bottom: bottomMargin??0
        ),
        padding: EdgeInsets.only(
            left: horizontalPadding??0,
            right: horizontalPadding??0,
            top: topPadding??0,
            bottom: bottomPadding??0
        ),
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius??9.r),
          border: borderColor != null ? Border.all(color: borderColor??Colors.transparent, width: 1.w) : null,
          boxShadow: boxShadow
        ),
        child: childWidget??Text(text!.tr, style: textStyle ?? StyleHelper.customStyle(family: semiBold,color: AppColors.white)),
      ),
    );
  }
}


class CustomSquareButton extends StatelessWidget {
  const CustomSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.leftMargin,
    this.rightMargin,
    this.topMargin,
    this.bottomMargin,
    this.backgroundColor,
    this.border,
    this.iconColor,
  });
  final String icon;
  final Function() onTap;
  final double? leftMargin;
  final double? rightMargin;
  final double? topMargin;
  final double? bottomMargin;
  final Color? backgroundColor;
  final Color? iconColor;
  final BoxBorder? border;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            alignment: Alignment.centerLeft,
            height: 38.w,
            width: 38.w,
            margin: EdgeInsets.only(left: leftMargin??0, right: rightMargin??0, top: topMargin??0, bottom: bottomMargin??0),
            color: backgroundColor ?? Colors.transparent,
            child: Center(
              child: SvgPicture.asset(icon, height: 24.sp, width: 24.sp,
                colorFilter: setSvgColor(iconColor ?? Colors.transparent)
              ),
            )
        ),
      ),
    );
  }
}