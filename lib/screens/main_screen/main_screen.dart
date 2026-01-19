import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/screens/home_screen/home_screen.dart';
import 'package:restaurant_management_fierbase/screens/profile_screen/profile_screen.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
import 'package:restaurant_management_fierbase/widgets/custom_button.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainScreenController mainController = Get.put(MainScreenController());
  RxBool isExit = false.obs;

  @override
  void initState() {
    super.initState();
  }

  void changeTab(int index) {
    mainController.currentIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onTabChange: changeTab,),
      ProfileScreen(onTabChange: changeTab)
    ];
    return WillPopScope(
      onWillPop: ()async{
        if(mainController.currentIndex.value != 0){
          mainController.currentIndex.value = 0;
        }
        else{
          exitAppDialog();
        }
        return isExit.value;
      },
      child: Scaffold(
          body: Obx(()=> screens[mainController.currentIndex.value]),
          bottomNavigationBar: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.black,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildItem(AppImages.homeIcon, 'home'.tr, 0),
                buildItem(AppImages.profileIcon, 'profile'.tr, 1),
              ],
            ).paddingSymmetric(vertical: 8.h,horizontal: 20.w),
          )
      ),
    );
  }

  exitAppDialog(){
    return Get.dialog(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r)
              ),
              child: Column(
                children: [
                  Text('Do you want to exit from this app ?',style: StyleHelper.customStyle(color: AppColors.black,size: 18.sp,family: medium),textAlign: TextAlign.center,maxLines: 2,).paddingOnly(bottom: 16.h,right: 16.w,left: 16.w),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          height: 30.h,
                          color: AppColors.black,
                          borderRadius: 12.r,
                          text: 'Yes',
                          textStyle: StyleHelper.customStyle(color: AppColors.white,size: 14.sp,family: medium),
                          onTap: (){isExit.value  = true;SystemNavigator.pop();},
                        ),
                      ),
                      SizedBox(width: 16.w,),
                      Expanded(
                        child: CustomButton(
                          height: 30.h,
                          color: AppColors.lightGray,
                          borderRadius: 12.r,
                          text: 'No',
                          textStyle: StyleHelper.customStyle(color: AppColors.white,size: 14.sp,family: medium),
                          onTap: (){Get.back();},
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 20.w)
    );
  }

  Widget buildItem(String icon,String name,int index){
    return GestureDetector(
      onTap: (){
        mainController.currentIndex.value = index;
      },
      child: Obx(()=> Column(
        children: [
          Image.asset(icon,height: 16.h,width: 16.w,color: mainController.currentIndex.value == index ? AppColors.white : AppColors.lightGray,fit: BoxFit.contain),
          Text(name,style: StyleHelper.customStyle(color: mainController.currentIndex.value == index ? AppColors.white : AppColors.lightGray,size: 4.sp,family: medium)),
        ],
      ),
      ),
    );
  }

}

class MainScreenController extends GetxController {
  RxInt currentIndex = 0.obs;

}
