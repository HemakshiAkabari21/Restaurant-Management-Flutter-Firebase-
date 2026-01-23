import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/screens/home_screen/home_controller.dart';
import 'package:restaurant_management_fierbase/screens/home_screen/home_screen.dart';
import 'package:restaurant_management_fierbase/screens/menu_screen/menu_screen.dart';
import 'package:restaurant_management_fierbase/screens/menu_setting_screen/menu_setting_screen.dart';
import 'package:restaurant_management_fierbase/screens/profile_screen/profile_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  HomeController homeController = Get.put(HomeController());
  RxInt currentIndex = 0.obs;

  // Callback function to change screen
  void onTabChange(int index) {
    setState(() {
      currentIndex.value = index;
    });

  }

  // Define your screens with callback
  List<Widget> get screens => [
    HomeScreen(onTabChange: onTabChange), // index 0
    MenuSettingScreen(onTabChange: onTabChange), // index 1
    ProfileScreen(onTabChange: onTabChange), // index 2
    // Add more screens as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true;
      backgroundColor: Color(0xFF2d4875),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fixed Sidebar
          Container(
            width: 40.w,
           // color: AppColors.black,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847)]
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildSidebarItem(
                  icon: AppImages.homeIcon,
                  name: 'home'.tr,
                  index: 0,
                  onTap: () {
                    onTabChange(0);
                  },
                ),
                buildSidebarItem(
                  icon: AppImages.icMenu,
                  name: 'Menu Setting'.tr,
                  index: 1,
                  onTap: () {
                    onTabChange(1);
                  },
                ).paddingSymmetric(vertical:  20.h),

                buildSidebarItem(
                  icon: AppImages.profileIcon,
                  name: 'profile'.tr,
                  index: 2,
                  onTap: () {
                    onTabChange(2);
                  },
                ),
              ],
            ),
          ),

          // Dynamic Content Area
          Expanded(
            child: IndexedStack(
              index: currentIndex.value,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebarItem({
    required String icon,
    required String name,
    required GestureTapCallback onTap,
    required int index,
  }) {
    return Obx(
          () => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: index == currentIndex.value
                ? Color(0xFFffb3b3)
                : Color(0xFF1a2847),
            border: Border.all(
              color:  index == currentIndex.value
                  ? AppColors.black
                  : Colors.white,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                height: 24.h,
                width: 24.w,
                color: index == currentIndex.value
                    ? AppColors.black
                    : AppColors.white,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 4.h),
              /*Text(
                name,
                style: StyleHelper.customStyle(
                  color: homeController.selectedTab.value == name
                      ? AppColors.black
                      : AppColors.white,
                  size: 6.sp,
                  family: medium,
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}