/*
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/order_model.dart';
import 'package:restaurant_management_fierbase/screens/main_layout_screen/main_layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_management_fierbase/widgets/common_widget.dart';

enum PaymentMethod { cash, card, upi, online, cheque }

class PaymentSuccessfullyController extends GetxController {
  final String tableId;
  final List<CartItemModel> cartItems;

  PaymentSuccessfullyController({
    required this.tableId,
    required this.cartItems,
  });

  /// ================= CUSTOMER =================
  final customerNameCtrl = TextEditingController();
  final customerMobileCtrl = TextEditingController();
  final customerEmailCtrl = TextEditingController();

  /// ================= PAYMENT =================
  var method = Rxn<PaymentMethod>();
  var isPaid = true.obs;

  /// ================= GST =================
  var isGstEnabled = true.obs;
  final double gstPercent = 5;
  double get cgstPercent => gstPercent / 2;
  double get sgstPercent => gstPercent / 2;

  /// ================= SERVICE CHARGE =================
  var isServiceChargeEnabled = true.obs;
  var serviceChargePercent = 10.0.obs;

  /// ================= DISCOUNT =================
  var isDiscount = false.obs;
  double discountPercentage = 5;

  /// ================= CALCULATIONS =================
  double get subTotal => cartItems.fold(0, (sum, e) => sum + (e.productPrice * e.productQty));

  double get gstAmount => isGstEnabled.value ? (subTotal * gstPercent / 100) : 0;

  double get cgstAmount => isGstEnabled.value ? (subTotal * cgstPercent / 100) : 0;

  double get sgstAmount => isGstEnabled.value ? (subTotal * sgstPercent / 100) : 0;

  double get serviceChargeAmount => isServiceChargeEnabled.value
          ? (subTotal * serviceChargePercent.value / 100)
          : 0;

  double get discountTotal => isDiscount.value ? (subTotal * discountPercentage / 100) : 0;

  double get totalWithoutServiceCharge => subTotal + gstAmount - discountTotal;

  double get grandTotal => subTotal + gstAmount + serviceChargeAmount - discountTotal;

  @override
  void onInit() {
    super.onInit();
    loadTableServiceCharge();
  }

  /// ================= LOAD TABLE CONFIG =================
  Future<void> loadTableServiceCharge() async {
    try {
      final snap = await RealtimeDbHelper.instance.getDataOnce('restaurant_tables/$tableId');

      if (snap.exists && snap.value != null) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        if (map['service_charge_percent'] != null) {
          serviceChargePercent.value = double.tryParse(map['service_charge_percent'].toString()) ?? 10;
        }
      }
    } catch (e) {
      debugPrint("Service charge load failed: $e");
    }
  }

  /// ================= VALIDATION =================
  bool isValid() {
    if (customerNameCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Customer Name", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (customerMobileCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Customer Mobile Number", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (customerMobileCtrl.text.trim().length != 10) {
      Get.snackbar("Error", "Please enter valid Customer Number", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (customerEmailCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Customer E-mail", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (method.value == null) {
      Get.snackbar("Error", "Please select payment method", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    return true;
  }

  /// ================= CONFIRM PAYMENT =================
  Future<void> confirmPayment() async {
    if (!isValid()) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      //  Create order in DB
      final orderId = await RealtimeDbHelper.instance.createOrder(
        orderTotal: grandTotal.toStringAsFixed(2),
        customerName: customerNameCtrl.text.trim(),
        customerMobile: customerMobileCtrl.text.trim(),
        customerEmail: customerEmailCtrl.text.trim(),
        isGst: isGstEnabled.value ? 1 : 0,
        orderJson: {
          "items": cartItems.map((e) => e.toMap()).toList(),
          "sub_total": subTotal,
          "gst_percent": gstPercent,
          "gst_amount": gstAmount,
          "service_charge": serviceChargeAmount,
          "discount": discountTotal,
          "grand_total": grandTotal,
        }.toString(),
      );

      //  Build OrderModel (FOR PDF)
      final orderModel = buildOrderModel(orderId: orderId);

      //  Generate PDF
      final pdfFile = await InvoicePdf.generate(orderModel);

      //  Send email silently
      await sendInvoiceEmail(
        toEmail: orderModel.customerEmail,
        pdfFile: pdfFile,
      );

      // Cleanup
      await RealtimeDbHelper.instance.deleteData('carts/$tableId');
      await RealtimeDbHelper.instance.updateData(
        path: 'restaurant_tables/$tableId',
        data: {'status': 'available'},
      );

      Get.back(); // loader
      Get.offAll(() => MainLayoutScreen());

      Get.snackbar("Success", "Payment completed & invoice emailed", backgroundColor: Colors.green, colorText: Colors.white,);
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Payment or invoice failed", backgroundColor: Colors.red, colorText: Colors.white,);
    }
  }

  /// ================= ORDER MODEL =================
  OrderModel buildOrderModel({String? orderId}) {
    return OrderModel(
      orderId: orderId ?? '',
      customerName: customerNameCtrl.text.trim(),
      customerEmail: customerEmailCtrl.text.trim(),
      customerMobile: customerMobileCtrl.text.trim(),
      isGst: isGstEnabled.value ? 1 : 0,
      orderDate: DateTime.now(),
      orderTotal: grandTotal,
      orderJson: OrderJson(
        items: cartItems,
        subTotal: subTotal,
        gstPercent: gstPercent,
        gstAmount: gstAmount,
        serviceCharge: serviceChargeAmount,
        discount: discountTotal,
        grandTotal: grandTotal,
      ),
    );
  }
}
*/
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/order_model.dart';
import 'package:restaurant_management_fierbase/screens/main_layout_screen/main_layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_management_fierbase/widgets/common_widget.dart';

enum PaymentMethod { cash, card, upi, online, cheque }

class PaymentSuccessfullyController extends GetxController {
  final String tableId;
  final List<CartItemModel> cartItems;
  final String tableNo;

  PaymentSuccessfullyController({
    required this.tableId,
    required this.cartItems,
    required this.tableNo
  });

  /// ================= CUSTOMER =================
  final customerNameCtrl = TextEditingController();
  final customerMobileCtrl = TextEditingController();
  final customerEmailCtrl = TextEditingController();

  /// ================= PAYMENT =================
  var method = Rxn<PaymentMethod>();
  var isPaid = true.obs;

  /// ================= GST =================
  var isGstEnabled = true.obs;
  final double gstPercent = 5;
  double get cgstPercent => gstPercent / 2;
  double get sgstPercent => gstPercent / 2;

  /// ================= SERVICE CHARGE =================
  var isServiceChargeEnabled = true.obs;
  var serviceChargePercent = 10.0.obs;

  /// ================= DISCOUNT =================
  var isDiscount = false.obs;
  double discountPercentage = 5;

  /// ================= CALCULATIONS - Updated to handle half portions =================

  // Calculate subtotal considering half portions
  double get subTotal => cartItems.fold(0.0, (sum, item) {
    // Calculate effective quantity (reduce by 0.5 if half)
    final effectiveQty = item.isHalf == 1
        ? (item.productQty - 0.5)
        : item.productQty.toDouble();

    return sum + (item.productPrice * effectiveQty);
  });

  double get gstAmount => isGstEnabled.value ? (subTotal * gstPercent / 100) : 0;

  double get cgstAmount => isGstEnabled.value ? (subTotal * cgstPercent / 100) : 0;

  double get sgstAmount => isGstEnabled.value ? (subTotal * sgstPercent / 100) : 0;

  double get serviceChargeAmount => isServiceChargeEnabled.value
      ? (subTotal * serviceChargePercent.value / 100)
      : 0;

  double get discountTotal => isDiscount.value ? (subTotal * discountPercentage / 100) : 0;

  double get totalWithoutServiceCharge => subTotal + gstAmount - discountTotal;

  double get grandTotal => subTotal + gstAmount + serviceChargeAmount - discountTotal;

  @override
  void onInit() {
    super.onInit();
    loadTableServiceCharge();
  }

  /// ================= LOAD TABLE CONFIG =================
  Future<void> loadTableServiceCharge() async {
    try {
      final snap = await RealtimeDbHelper.instance.getDataOnce('restaurant_tables/$tableId');

      if (snap.exists && snap.value != null) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        if (map['service_charge_percent'] != null) {
          serviceChargePercent.value = double.tryParse(map['service_charge_percent'].toString()) ?? 10;
        }
      }
    } catch (e) {
      debugPrint("Service charge load failed: $e");
    }
  }

  /// ================= VALIDATION =================
  bool isValid() {
    if (customerNameCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Customer Name", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (customerMobileCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Customer Mobile Number", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (customerMobileCtrl.text.trim().length != 10) {
      Get.snackbar("Error", "Please enter valid Customer Number", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (customerEmailCtrl.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter Customer E-mail", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    if (method.value == null) {
      Get.snackbar("Error", "Please select payment method", backgroundColor: Colors.red, colorText: Colors.white,);
      return false;
    }
    return true;
  }

  /// ================= CONFIRM PAYMENT =================
  Future<void> confirmPayment() async {
    if (!isValid()) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      //  Create order in DB
      final orderId = await RealtimeDbHelper.instance.createOrder(
        orderTotal: grandTotal.toStringAsFixed(2),
        customerName: customerNameCtrl.text.trim(),
        customerMobile: customerMobileCtrl.text.trim(),
        customerEmail: customerEmailCtrl.text.trim(),
        isGst: isGstEnabled.value ? 1 : 0,
        orderJson: {
          "items": cartItems.map((e) => e.toMap()).toList(),
          "sub_total": subTotal,
          "gst_percent": gstPercent,
          "gst_amount": gstAmount,
          "service_charge": serviceChargeAmount,
          "discount": discountTotal,
          "grand_total": grandTotal,
        }.toString(),
      );

      //  Build OrderModel (FOR PDF)
      final orderModel = buildOrderModel(orderId: orderId);

      //  Generate PDF
      final pdfFile = await InvoicePdf.generate(orderModel);

      //  Send email silently
      await sendInvoiceEmail(
        toEmail: orderModel.customerEmail,
        pdfFile: pdfFile,
      );

      // Cleanup
      await RealtimeDbHelper.instance.deleteData('carts/$tableId');
      await RealtimeDbHelper.instance.updateData(
        path: 'restaurant_tables/$tableId',
        data: {'status': 'available'},
      );

      Get.back(); // loader
      Get.offAll(() => MainLayoutScreen());

      Get.snackbar("Success", "Payment completed & invoice emailed", backgroundColor: Colors.green, colorText: Colors.white,);
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Payment or invoice failed", backgroundColor: Colors.red, colorText: Colors.white,);
    }
  }

  /// ================= ORDER MODEL =================
  OrderModel buildOrderModel({String? orderId}) {
    return OrderModel(
      orderId: orderId ?? '',
      customerName: customerNameCtrl.text.trim(),
      customerEmail: customerEmailCtrl.text.trim(),
      customerMobile: customerMobileCtrl.text.trim(),
      isGst: isGstEnabled.value ? 1 : 0,
      orderDate: DateTime.now(),
      orderTotal: grandTotal,
      orderJson: OrderJson(
        items: cartItems,
        subTotal: subTotal,
        gstPercent: gstPercent,
        gstAmount: gstAmount,
        serviceCharge: serviceChargeAmount,
        discount: discountTotal,
        grandTotal: grandTotal,
      ),
    );
  }
}