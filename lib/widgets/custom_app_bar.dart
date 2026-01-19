import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';


import 'custom_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? toolBarHeight;
  final Widget? title;
  final double? titleSpacing;
  final double? leadingWidth;
  final List<Widget>? actions;
  final bool? isLeading;
  final Widget? leading;
  final bool? centerTitle;
  final Widget? flexibleChild;
  final Color? backgroundColor;
  final Color? statusColor;
  final Color? iconColor;
  final Function()? onTap;
  final double? height;

  const CustomAppBar({super.key,
    this.titleSpacing,
    this.onTap,
    this.toolBarHeight,
    this.leadingWidth,
    this.title,
    this.flexibleChild,
    this.backgroundColor,
    this.actions,
    this.leading,
    this.height,
    this.iconColor,
    this.statusColor,
    this.isLeading = false,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 150.h,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ]),
      child: AppBar(
        backgroundColor: backgroundColor ?? AppColors.white,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: statusColor ?? AppColors.white,
          systemNavigationBarColor: AppColors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        // backgroundColor: Colors.white,
        toolbarHeight: toolBarHeight ?? 55.h,
        // titleSpacing: titleSpacing ?? 15.w,
        shadowColor: Colors.white,
        centerTitle: centerTitle,
        automaticallyImplyLeading: false,
        leadingWidth: leadingWidth ?? 45.w,
        leading: isLeading != null && isLeading! ? CustomSquareButton(leftMargin: 15.w, icon: AppImages.arrowLeft, onTap: () => Get.back(),iconColor: iconColor ?? AppColors.black ,) : leading,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight ?? 55.h);
}