import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
import '../apptheme/app_colors.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? width;
  final double? height;
  final bool? isDisMissile;

  const CustomLoadingIndicator({
    super.key,
    this.width,
    this.height,
    this.isDisMissile = false,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isDisMissile!,
      child: Center(
        child: SizedBox(
          width: width??30.h,
          height: height??30.h,
          child: const CircularProgressIndicator(color: AppColors.black),
        ),
      ),
    );
  }
}

class ImageErrorWidget extends StatelessWidget {
  const ImageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: AppColors.white),
      child: Image.asset(AppImages.appLogo, fit: BoxFit.contain)
    );
  }
}

// class NoDataFoundWidget extends StatelessWidget {
//   final String? svgImage;
//   final String? title;
//   final String? subTitle;
//
//   const NoDataFoundWidget({
//     super.key,
//     this.svgImage,
//     this.title,
//     this.subTitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SvgPicture.asset(svgImage??AppImages.noData,height: 130.h),
//           Text(title!=null ? title!.tr : 'no_data_found'.tr,
//               textAlign: TextAlign.center,
//               style: StyleHelper.customStyle(color: AppColors.blackText,size: 15.sp,family: medium)
//           ),
//           if(subTitle!=null)
//           Text(subTitle!.tr,
//               textAlign: TextAlign.center,
//               style: StyleHelper.customStyle(color: AppColors.black,family: medium)
//           )
//         ],
//       ),
//     );
//   }
// }