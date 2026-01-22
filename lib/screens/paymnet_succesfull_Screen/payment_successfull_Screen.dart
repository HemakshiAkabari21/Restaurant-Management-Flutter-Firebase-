import 'package:firebase_database/firebase_database.dart';
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

  /// CUSTOMER
  final customerNameCtrl = TextEditingController();
  final customerMobileCtrl = TextEditingController();

  /// BILL CONFIG
  double serviceCharge = 0;

  /// GST
  bool isGstEnabled = true;
  final double gstPercent = 5;
  double get cgstPercent => gstPercent / 2;
  double get sgstPercent => gstPercent / 2;

  /// SERVICE CHARGE (TABLE BASED)
  bool isServiceChargeEnabled = true;
  double serviceChargePercent = 10;

  /// DISCOUNT
  bool isDiscount = false;
  double discount = 0;
  double discountPercentage = 5;

  /// ================= TOTALS =================
  double get subTotal => widget.cartItems.fold(
    0,
        (sum, e) => sum + (double.parse(e.productPrice) * e.qty),
  );

  double get gstAmount =>
      isGstEnabled ? (subTotal * gstPercent / 100) : 0;

  double get cgstAmount =>
      isGstEnabled ? (subTotal * cgstPercent / 100) : 0;

  double get sgstAmount =>
      isGstEnabled ? (subTotal * sgstPercent / 100) : 0;

  double get serviceChargeAmount =>
      isServiceChargeEnabled
          ? (subTotal * serviceChargePercent / 100)
          : 0;

  double get totalWithoutServiceCharge =>
      subTotal + gstAmount - discountTotal ;

  double get grandTotal =>
      subTotal + gstAmount + serviceChargeAmount - discountTotal ;

  double get discountTotal => isDiscount ? (subTotal * discountPercentage / 100) : 0;


  @override
  void initState() {
    super.initState();
    loadTableServiceCharge();
  }

  /// ================= LOAD TABLE CONFIG =================
  Future<void> loadTableServiceCharge() async {
    try {
      final DataSnapshot snap = await RealtimeDbHelper.instance
          .getDataOnce('restaurant_tables/${widget.tableId}');

      if (snap.exists && snap.value != null) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        if (map['service_charge_percent'] != null) {
          serviceChargePercent =
              double.tryParse(map['service_charge_percent'].toString()) ?? 10;
        }
      }
      setState(() {});
    } catch (e) {
      debugPrint("Service charge load failed: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor:Color(0xFF1a2847),
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Column(
                children: [
                  /// CUSTOMER DETAILS
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customerNameCtrl,
                            decoration:
                            inputDecoration("Customer Name"),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextFormField(
                            controller: customerMobileCtrl,
                            maxLength: 10,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText:"Mobile Number",
                              counter: SizedBox(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r)
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// BILL + PAYMENT
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

          /// CONFIRM BUTTON
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6.r),],),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: method != null ? confirmPayment : null,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= BILL PANEL =================
  Widget buildBillPanel() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BILL",
              style: StyleHelper.customStyle(
                size: 7.sp,
                family: semiBold,
              )),
          Divider(thickness: 1.5,color: AppColors.lightGray),

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
          ...widget.cartItems.map((item) {
            final amount =
                double.parse(item.productPrice) * item.qty;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(item.productName)),
                  Expanded(
                    child: Text(item.qty.toString(),
                        textAlign: TextAlign.center),
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

          Divider(thickness: 1.5,color: AppColors.lightGray),
          billRow("Sub Total", subTotal),

          /// GST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             Text("GST ($gstPercent%)"),
              Switch(
                value: isGstEnabled,
                activeColor: AppColors.white,
                inactiveTrackColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                activeTrackColor:Color(0xFF1a2847) ,
                onChanged: (v) => setState(() => isGstEnabled = v),
              ),
            ],
          ),

          if (isGstEnabled) ...[
            billRow("CGST ($cgstPercent%)", cgstAmount),
            billRow("SGST ($sgstPercent%)", sgstAmount),
          ],

          /// SERVICE CHARGE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Service Charge ($serviceChargePercent%)"),
              Switch(
                value: isServiceChargeEnabled,
                activeColor: AppColors.white,
                inactiveTrackColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                activeTrackColor:Color(0xFF1a2847) ,
                onChanged: (v) => setState(() => isServiceChargeEnabled = v),
              ),
            ],
          ),

          if (isServiceChargeEnabled)
            billRow("Service Charge Amount", serviceChargeAmount),
          Divider(thickness: 1.5,color: AppColors.lightGray),


          /// DISCOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Discount ($discountPercentage%)"),
              Switch(
                value: isDiscount,
                activeColor: AppColors.white,
                inactiveTrackColor: AppColors.white,
                inactiveThumbColor: AppColors.black,
                activeTrackColor:Color(0xFF1a2847) ,
                onChanged: (v) => setState(() => isDiscount = v),
              ),
            ],
          ),

          if(isDiscount)
            billRow("Discount", discountTotal),
          Divider(thickness: 1.5,color: AppColors.lightGray,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GRAND TOTAL", style: StyleHelper.customStyle(size: 5.sp, family: semiBold)),
              Text("₹${grandTotal.toStringAsFixed(2)}",style: StyleHelper.customStyle(size: 5.sp, family: semiBold)),
            ],
          ),

        ],
      ),
    );
  }

  /// ================= PAYMENT PANEL =================
  Widget buildPaymentPanel() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PAYMENT METHOD",
              style: StyleHelper.customStyle(
                size: 7.sp,
                family: semiBold,
              )),
          SizedBox(height: 12.h),

          ...PaymentMethod.values.map((pm) {
            final selected = method == pm;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                leading: Icon(getPaymentIcon(pm)),
                title: Text(pm.name.toUpperCase()),
                trailing: selected
                    ?  Icon(Icons.check_circle,color: Color(0xFF1a2847),)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(
                      color: selected
                          ? AppColors.black
                          : Colors.grey.shade300),
                ),
                onTap: () => setState(() => method = pm),
              ),
            );
          }),

          Divider(color: AppColors.lightGray),

          SwitchListTile(
            title: const Text("Payment Received"),
            activeColor: AppColors.white,
            inactiveTrackColor: AppColors.white,
            inactiveThumbColor: AppColors.black,
            activeTrackColor:Color(0xFF1a2847) ,
            value: isPaid,
            onChanged: (v) => setState(() => isPaid = v),
          ),
        ],
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

  Widget billEditableRow(
      String title,
      double value,
      Function(double) onChanged,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          SizedBox(
            width: 16.w,
            child: TextFormField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                prefixText: "₹ ",
                hintText:"₹ ",
                isDense: true,
               // border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  onChanged(double.tryParse(v) ?? 0),
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

  /// ================= CONFIRM PAYMENT =================
  Future<void> confirmPayment() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await RealtimeDbHelper.instance.createOrder(
        orderTotal: grandTotal.toStringAsFixed(2),
        customerName: customerNameCtrl.text.trim(),
        customerMobile: customerMobileCtrl.text.trim(),
        isGst: isGstEnabled ? 1 : 0,
        orderJson: {
          "items": widget.cartItems.map((e) => e.toMap()).toList(),
          "sub_total": subTotal,
          "gst_percent": gstPercent,
          "gst_amount": gstAmount,
          "service_charge": serviceCharge,
          "discount": discount,
          "grand_total": grandTotal,
        }.toString(),
      );

      await RealtimeDbHelper.instance
          .deleteData('carts/${widget.tableId}');

      await RealtimeDbHelper.instance.updateData(
        path: 'restaurant_tables/${widget.tableId}',
        data: {'status': 'available'},
      );

      Get.back();
      Get.offAll(() => MainLayoutScreen());

      Get.snackbar(
        "Success",
        "Payment completed successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Payment failed: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
