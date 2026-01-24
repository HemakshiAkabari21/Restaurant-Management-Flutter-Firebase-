/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/screens/paymnet_succesfull_Screen/payment_successfull_controller.dart';

class PaymentScreen extends StatelessWidget {
  final PaymentSuccessfullyController controller;

  PaymentScreen({super.key, required String tableId, required List<CartItemModel> cartItems})
      : controller = Get.put(PaymentSuccessfullyController(tableId: tableId, cartItems: cartItems));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Color(0xFF1a2847),
        title: Text(
          "Billing & Payment",
          style: StyleHelper.customStyle(
            color: Colors.white,
            size: 8.sp,
            family: semiBold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              if (!controller.isValid()) return;
              final orderModel = controller.buildOrderModel();
              final pdfFile = await InvoicePdf.generate(orderModel);
              await Share.shareXFiles([XFile(pdfFile.path)], subject: 'Invoice Preview', text: 'Invoice preview',);
            },
            child: Icon(Icons.inventory_outlined, size: 16.sp, color: AppColors.white,),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Column(
                children: [
                  buildCustomerDetails(),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: buildBillPanel()),
                      SizedBox(width: 16.w),
                      Expanded(flex: 1, child: buildPaymentPanel()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          buildConfirmButton(),
        ],
      ),
    );
  }

  /// ================= CUSTOMER DETAILS =================
  Widget buildCustomerDetails() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: boxDecoration(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.customerNameCtrl,
              decoration: inputDecoration("Customer Name"),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextFormField(
              controller: controller.customerMobileCtrl,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Mobile Number",
                counter: SizedBox(),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextFormField(
              controller: controller.customerEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "E-mail",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= BILL PANEL =================
  Widget buildBillPanel() {
    return Obx(() => Container(
      padding: EdgeInsets.all(12.w),
      decoration: boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BILL",
              style: StyleHelper.customStyle(size: 7.sp, family: semiBold)),
          Divider(thickness: 1.5, color: AppColors.lightGray),

          /// ITEMS HEADER
          Row(
            children: const [
              Expanded(flex: 4, child: Text("Item")),
              Expanded(child: Text("Qty", textAlign: TextAlign.center)),
              Expanded(child: Text("Amount", textAlign: TextAlign.right)),
            ],
          ),
          Divider(color: AppColors.lightGray),

          /// ITEMS
          ...controller.cartItems.map((item) {
            final amount = item.productPrice * item.productQty;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(item.productName)),
                  Expanded(
                      child: Text(
                        item.productQty.toString(),
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                    child: Text(
                      "₹${amount.toStringAsFixed(2)}",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          Divider(thickness: 1.5, color: AppColors.lightGray),

          billRow("Sub Total", controller.subTotal),

          /// GST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GST (${controller.gstPercent}%)"),
              Switch(
                value: controller.isGstEnabled.value,
                activeTrackColor: Color(0xFF1a2847),
                activeColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                inactiveTrackColor: AppColors.white,
                onChanged: (v) => controller.isGstEnabled.value = v,
              ),
            ],
          ),
          if (controller.isGstEnabled.value) ...[
            billRow("CGST (${controller.cgstPercent}%)", controller.cgstAmount),
            billRow("SGST (${controller.sgstPercent}%)", controller.sgstAmount),
          ],

          /// SERVICE CHARGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Service Charge (${controller.serviceChargePercent.value}%)"),
              Switch(
                value: controller.isServiceChargeEnabled.value,
                activeTrackColor: Color(0xFF1a2847),
                activeColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                inactiveTrackColor: AppColors.white,
                onChanged: (v) => controller.isServiceChargeEnabled.value = v,
              ),
            ],
          ),
          if (controller.isServiceChargeEnabled.value)
            billRow("Service Charge Amount", controller.serviceChargeAmount),

          /// DISCOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Discount (${controller.discountPercentage}%)"),
              Switch(
                value: controller.isDiscount.value,
                activeTrackColor: Color(0xFF1a2847),
                activeColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                inactiveTrackColor: AppColors.white,
                onChanged: (v) => controller.isDiscount.value = v,
              ),
            ],
          ),
          if (controller.isDiscount.value)
            billRow("Discount", controller.discountTotal),

          Divider(thickness: 1.5, color: AppColors.lightGray),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GRAND TOTAL",
                  style: StyleHelper.customStyle(size: 5.sp, family: semiBold)),
              Text("₹${controller.grandTotal.toStringAsFixed(2)}",
                  style: StyleHelper.customStyle(size: 5.sp, family: semiBold)),
            ],
          ),
        ],
      ),
    ));
  }

  /// ================= PAYMENT PANEL =================
  Widget buildPaymentPanel() {
    return Obx(() => Container(
      padding: EdgeInsets.all(12.w),
      decoration: boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PAYMENT METHOD",
              style: StyleHelper.customStyle(size: 7.sp, family: semiBold)),
          SizedBox(height: 12.h),

          ...PaymentMethod.values.map((pm) {
            final selected = controller.method.value == pm;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                leading: Icon(getPaymentIcon(pm)),
                title: Text(pm.name.toUpperCase()),
                trailing: selected
                    ? Icon(
                  Icons.check_circle,
                  color: Color(0xFF1a2847),
                )
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(
                      color: selected
                          ? AppColors.black
                          : Colors.grey.shade300),
                ),
                onTap: () => controller.method.value = pm,
              ),
            );
          }),

          Divider(color: AppColors.lightGray),
          SwitchListTile(
            title: const Text("Payment Received"),
            value: controller.isPaid.value,
            activeTrackColor: Color(0xFF1a2847),
            activeColor: AppColors.white,
            inactiveThumbColor: AppColors.black,
            inactiveTrackColor: AppColors.white,
            onChanged: (v) => controller.isPaid.value = v,
          ),
        ],
      ),
    ));
  }

  /// ================= CONFIRM BUTTON =================
  Widget buildConfirmButton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6.r)],
      ),
      child: SafeArea(
        child: Obx(() => ElevatedButton(
          onPressed: controller.method.value != null
              ? controller.confirmPayment
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1a2847),
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            "Confirm Payment & Close Table",
            style: StyleHelper.customStyle(
              color: Colors.white,
              size: 6.sp,
              family: semiBold,
            ),
          ),
        )),
      ),
    );
  }

  /// ================= HELPERS =================
  Widget billRow(String title, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text("₹${amount.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        )
      ],
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
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
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/screens/paymnet_succesfull_Screen/payment_successfull_controller.dart';
import 'package:restaurant_management_fierbase/widgets/common_widget.dart';
import 'package:share_plus/share_plus.dart';

class PaymentScreen extends StatelessWidget {
  final PaymentSuccessfullyController controller;

  PaymentScreen({super.key, required String tableId, required List<CartItemModel> cartItems})
      : controller = Get.put(PaymentSuccessfullyController(tableId: tableId, cartItems: cartItems));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Color(0xFF1a2847),
        title: Text(
          "Billing & Payment",
          style: StyleHelper.customStyle(
            color: Colors.white,
            size: 8.sp,
            family: semiBold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Column(
                children: [
                  buildCustomerDetails(),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: buildBillPanel()),
                      SizedBox(width: 16.w),
                      Expanded(flex: 1, child: buildPaymentPanel()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          buildConfirmButton(),
        ],
      ),
    );
  }

  /// ================= CUSTOMER DETAILS =================
  Widget buildCustomerDetails() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: boxDecoration(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.customerNameCtrl,
              decoration: inputDecoration("Customer Name"),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextFormField(
              controller: controller.customerMobileCtrl,
              maxLength: 10,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Mobile Number",
                counter: SizedBox(),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextFormField(
              controller: controller.customerEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "E-mail",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= BILL PANEL =================
  Widget buildBillPanel() {
    return Obx(() => Container(
      padding: EdgeInsets.all(12.w),
      decoration: boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BILL",
              style: StyleHelper.customStyle(size: 7.sp, family: semiBold)),
          Divider(thickness: 1.5, color: AppColors.lightGray),

          /// ITEMS HEADER
          Row(
            children: const [
              Expanded(flex: 4, child: Text("Item")),
              Expanded(child: Text("Qty", textAlign: TextAlign.center)),
              Expanded(child: Text("Amount", textAlign: TextAlign.right)),
            ],
          ),
          Divider(color: AppColors.lightGray),

          /// ITEMS - Updated to handle half portions
          ...controller.cartItems.map((item) {
            // Calculate effective quantity (reduce by 0.5 if half)
            final effectiveQty = item.isHalf == 1
                ? (item.productQty - 0.5)
                : item.productQty.toDouble();

            // Calculate amount with effective quantity
            final amount = item.productPrice * effectiveQty;

            // Display quantity with .5 if half
            final displayQty = item.isHalf == 1
                ? "${item.productQty - 0.5}"
                : item.productQty.toString();

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Expanded(child: Text(item.productName)),
                        if (item.isHalf == 1)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Text(
                              "Half",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      displayQty,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "₹${amount.toStringAsFixed(2)}",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

          Divider(thickness: 1.5, color: AppColors.lightGray),

          billRow("Sub Total", controller.subTotal),

          /// GST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GST (${controller.gstPercent}%)"),
              Switch(
                value: controller.isGstEnabled.value,
                activeTrackColor: Color(0xFF1a2847),
                activeColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                inactiveTrackColor: AppColors.white,
                onChanged: (v) => controller.isGstEnabled.value = v,
              ),
            ],
          ),
          if (controller.isGstEnabled.value) ...[
            billRow("CGST (${controller.cgstPercent}%)", controller.cgstAmount),
            billRow("SGST (${controller.sgstPercent}%)", controller.sgstAmount),
          ],

          /// SERVICE CHARGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Service Charge (${controller.serviceChargePercent.value}%)"),
              Switch(
                value: controller.isServiceChargeEnabled.value,
                activeTrackColor: Color(0xFF1a2847),
                activeColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                inactiveTrackColor: AppColors.white,
                onChanged: (v) => controller.isServiceChargeEnabled.value = v,
              ),
            ],
          ),
          if (controller.isServiceChargeEnabled.value)
            billRow("Service Charge Amount", controller.serviceChargeAmount),

          /// DISCOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Discount (${controller.discountPercentage}%)"),
              Switch(
                value: controller.isDiscount.value,
                activeTrackColor: Color(0xFF1a2847),
                activeColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                inactiveTrackColor: AppColors.white,
                onChanged: (v) => controller.isDiscount.value = v,
              ),
            ],
          ),
          if (controller.isDiscount.value)
            billRow("Discount", controller.discountTotal),

          Divider(thickness: 1.5, color: AppColors.lightGray),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GRAND TOTAL",
                  style: StyleHelper.customStyle(size: 5.sp, family: semiBold)),
              Text("₹${controller.grandTotal.toStringAsFixed(2)}",
                  style: StyleHelper.customStyle(size: 5.sp, family: semiBold)),
            ],
          ),
        ],
      ),
    ));
  }

  /// ================= PAYMENT PANEL =================
  Widget buildPaymentPanel() {
    return Obx(() => Container(
      padding: EdgeInsets.all(12.w),
      decoration: boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PAYMENT METHOD",
              style: StyleHelper.customStyle(size: 7.sp, family: semiBold)),
          SizedBox(height: 12.h),

          ...PaymentMethod.values.map((pm) {
            final selected = controller.method.value == pm;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                leading: Icon(getPaymentIcon(pm)),
                title: Text(pm.name.toUpperCase()),
                trailing: selected
                    ? Icon(
                  Icons.check_circle,
                  color: Color(0xFF1a2847),
                )
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(
                      color: selected
                          ? AppColors.black
                          : Colors.grey.shade300),
                ),
                onTap: () => controller.method.value = pm,
              ),
            );
          }),

          Divider(color: AppColors.lightGray),
          SwitchListTile(
            title: const Text("Payment Received"),
            value: controller.isPaid.value,
            activeTrackColor: Color(0xFF1a2847),
            activeColor: AppColors.white,
            inactiveThumbColor: AppColors.black,
            inactiveTrackColor: AppColors.white,
            onChanged: (v) => controller.isPaid.value = v,
          ),
        ],
      ),
    ));
  }

  /// ================= CONFIRM BUTTON =================
  Widget buildConfirmButton() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6.r)],
      ),
      child: SafeArea(
        child: Obx(() => ElevatedButton(
          onPressed: controller.method.value != null
              ? controller.confirmPayment
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1a2847),
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            "Confirm Payment & Close Table",
            style: StyleHelper.customStyle(
              color: Colors.white,
              size: 6.sp,
              family: semiBold,
            ),
          ),
        )),
      ),
    );
  }

  /// ================= HELPERS =================
  Widget billRow(String title, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text("₹${amount.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        )
      ],
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
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
}