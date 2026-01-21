import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';

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
        backgroundColor: Color(0xFF2d4875),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Payment & Billing",
          style: StyleHelper.customStyle(
            color: AppColors.white,
            size: 18.sp,
            family: semiBold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section with Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
            child: Column(
              children: [
                Text(
                  "Table ${widget.tableId}",
                  style: StyleHelper.customStyle(
                    color: Colors.white70,
                    size: 14.sp,
                    family: regular,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: StyleHelper.customStyle(
                    color: AppColors.white,
                    size: 42.sp,
                    family: semiBold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Total Amount",
                  style: StyleHelper.customStyle(
                    color: Colors.white70,
                    size: 13.sp,
                    family: regular,
                  ),
                ),
              ],
            ),
          ),

          // Order Summary
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Items
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
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Summary",
                          style: StyleHelper.customStyle(
                            color: Color(0xFF1a2847),
                            size: 16.sp,
                            family: semiBold,
                          ),
                        ),
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
                                        color: Color(0xFF2d4875).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        "${item.qty}x",
                                        style: StyleHelper.customStyle(
                                          color: Color(0xFF2d4875),
                                          size: 12.sp,
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
                                          size: 14.sp,
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
                                  color: Color(0xFF1a2847),
                                  size: 14.sp,
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
                                color: Color(0xFF1a2847),
                                size: 16.sp,
                                family: semiBold,
                              ),
                            ),
                            Text(
                              "₹${total.toStringAsFixed(2)}",
                              style: StyleHelper.customStyle(
                                color: Color(0xFF2d4875),
                                size: 18.sp,
                                family: semiBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Payment Method
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
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Method",
                          style: StyleHelper.customStyle(
                            color: Color(0xFF1a2847),
                            size: 16.sp,
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
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF2d4875).withOpacity(0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF2d4875)
                                      : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getPaymentIcon(pm),
                                    color: isSelected
                                        ? Color(0xFF2d4875)
                                        : Colors.grey.shade600,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      pm.name.toUpperCase(),
                                      style: StyleHelper.customStyle(
                                        color: isSelected
                                            ? Color(0xFF2d4875)
                                            : Colors.grey.shade800,
                                        size: 14.sp,
                                        family: isSelected ? semiBold : regular,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2d4875),
                                      size: 22.sp,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

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
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Payment Received",
                        style: StyleHelper.customStyle(
                          color: Color(0xFF1a2847),
                          size: 15.sp,
                          family: semiBold,
                        ),
                      ),
                      subtitle: Text(
                        isPaid ? "Payment confirmed" : "Payment pending",
                        style: StyleHelper.customStyle(
                          color: Colors.grey.shade600,
                          size: 12.sp,
                          family: regular,
                        ),
                      ),
                      value: isPaid,
                      activeColor: Color(0xFF2d4875),
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
            padding: EdgeInsets.all(20.w),
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
                onPressed: method != null ? _confirmPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2d4875),
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
                    size: 16.sp,
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

  IconData _getPaymentIcon(PaymentMethod method) {
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

  Future<void> _confirmPayment() async {
    if (method == null) {
      Get.snackbar(
        "Error",
        "Please select a payment method",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show loading
    Get.dialog(
      Center(child: CircularProgressIndicator()),
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

      // Update table status to available
      await RealtimeDbHelper.instance.updateData(
        path: 'tables/${widget.tableId}',
        data: {'status': 'available'},
      );

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        "Success",
        "Payment completed and table is now available",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back
      Get.back(result: true);
      Get.back(); // back to menu
    } catch (e) {
      // Close loading dialog
      Get.back();

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