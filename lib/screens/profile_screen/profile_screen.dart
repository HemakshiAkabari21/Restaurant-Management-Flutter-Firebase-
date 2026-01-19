import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/screens/authentication/login_screen/log_in_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_keys.dart';
import 'package:restaurant_management_fierbase/widgets/custom_app_bar.dart';
import 'package:restaurant_management_fierbase/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  final void Function(int index) onTabChange;
  const ProfileScreen({super.key, required this.onTabChange});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AppColors.black,
        isLeading: false,
        statusColor: AppColors.black,
        title: Text("Profile".toUpperCase(),style: StyleHelper.customStyle(color: AppColors.white,size: 16.sp,family: semiBold),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            CustomButton(
              onTap: (){
                getStorage.remove(IS_LOGIN);
                getStorage.remove(USER_ID);
                getStorage.remove(USER_DETAIL);
                getStorage.erase();
                Get.offAll(()=>LogInScreen());
              },
              topMargin: 50.h,
              borderColor: AppColors.black,
              height: 40.h,
              borderRadius: 12.r,
              text: 'LOGOUT',
              textStyle: StyleHelper.customStyle(color: AppColors.black,size: 16.sp,family: semiBold),
            )
          ],
        ).paddingSymmetric(horizontal: 16.w),
      ),
    );
  }

  Widget profileCard(){
    return Row(
      children: [



      ],
    );
  }
}
