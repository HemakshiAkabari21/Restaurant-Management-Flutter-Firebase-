import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/screens/main_layout_screen/main_layout_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String tableId;
  final List<CartItemModel> cartItems;

  const PaymentScreen({
    super.key,
    required this.tableId,
    required this.cartItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

enum PaymentMethod { cash, card, upi, online, cheque }

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? method;
  bool isPaid = true;

  double get total => widget.cartItems.fold(
    0,
        (sum, e) => sum + (double.parse(e.productPrice) * e.qty),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Payment & Billing",
          style: StyleHelper.customStyle(
            color: AppColors.white,
            size: 8.sp,
            family: semiBold,
          ),
        ),
      ),
      body: Column(
        children: [
          /// Order Summary
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Items
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2),),],
                    ),
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order Summary", style: StyleHelper.customStyle(color: AppColors.black, size: 6.sp, family: semiBold,),),
                        SizedBox(height: 16.h),
                        ...widget.cartItems.map((item) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        "${item.qty}x",
                                        style: StyleHelper.customStyle(
                                          color:AppColors.black,
                                          size: 4.sp,
                                          family: semiBold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        style: StyleHelper.customStyle(
                                          color: Colors.grey.shade800,
                                          size: 4.sp,
                                          family: regular,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "₹${(double.parse(item.productPrice) * item.qty).toStringAsFixed(2)}",
                                style: StyleHelper.customStyle(
                                  color: AppColors.black,
                                  size: 4.sp,
                                  family: semiBold,
                                ),
                              ),
                            ],
                          ),
                        )),
                        Divider(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: StyleHelper.customStyle(
                                color: AppColors.black,
                                size: 6.sp,
                                family: semiBold,
                              ),
                            ),
                            Text(
                              "₹${total.toStringAsFixed(2)}",
                              style: StyleHelper.customStyle(
                                color: AppColors.black,
                                size: 6.sp,
                                family: semiBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// Payment Method
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2),),],
                    ),
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Method",
                          style: StyleHelper.customStyle(
                            color:AppColors.black,
                            size: 6.sp,
                            family: semiBold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ...PaymentMethod.values.map((pm) {
                          final isSelected = method == pm;
                          return GestureDetector(
                            onTap: () => setState(() => method = pm),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.black.withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.black
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    getPaymentIcon(pm),
                                    color: isSelected
                                        ? AppColors.black
                                        : Colors.grey.shade600,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      pm.name.toUpperCase(),
                                      style: StyleHelper.customStyle(
                                        color: isSelected
                                            ? AppColors.black
                                            : Colors.grey.shade800,
                                        size: 6.sp,
                                        family: isSelected ? semiBold : regular,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.black,
                                      size: 10.sp,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ).paddingOnly(bottom: 10.h),

                  // Payment Status
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Payment Received",
                        style: StyleHelper.customStyle(
                          color: AppColors.black,
                          size: 5.sp,
                          family: semiBold,
                        ),
                      ),
                      subtitle: Text(
                        isPaid ? "Payment confirmed" : "Payment pending",
                        style: StyleHelper.customStyle(
                          color: Colors.grey.shade600,
                          size: 4.sp,
                          family: regular,
                        ),
                      ),
                      value: isPaid,
                      activeColor:AppColors.black,
                      onChanged: (val) => setState(() => isPaid = val),
                    ),
                  ),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: EdgeInsets.all(6.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: method != null ? confirmPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Confirm Payment & Close Table",
                  style: StyleHelper.customStyle(
                    color: AppColors.white,
                    size: 6.sp,
                    family: semiBold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.online:
        return Icons.phone_android;
      case PaymentMethod.cheque:
        return Icons.receipt_long;
    }
  }

  Future<void> confirmPayment() async {
    if (method == null) {
      Get.snackbar(
        "Error",
        "Please select a payment method",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Create order
      await RealtimeDbHelper.instance.createOrder(
        orderTotal: total.toString(),
        customerName: '',
        customerMobile: '',
        isGst: 0,
        orderJson: widget.cartItems.map((e) => e.toMap()).toList().toString(),
      );

      // Clear cart
      await RealtimeDbHelper.instance.deleteData(
        'carts/${widget.tableId}',
      );

      // Update table status
      await RealtimeDbHelper.instance.updateData(
        path: 'restaurant_tables/${widget.tableId}',
        data: {'status': 'available'},
      );

      // Close loading dialog safely
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Close any open snackbar safely
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      // Show success
      Get.snackbar(
        "Success",
        "Payment completed and table is now available",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back only once with result
      Get.offAll(()=>MainLayoutScreen());

    } catch (e) {
      // Close loading dialog safely
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Close any open snackbar safely
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      // Show error
      Get.snackbar(
        "Error",
        "Failed to process payment: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}