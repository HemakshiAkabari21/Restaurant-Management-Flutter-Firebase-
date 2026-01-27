import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';
import 'package:restaurant_management_fierbase/screens/manager_screen/manager_controller.dart';
import 'package:restaurant_management_fierbase/screens/paymnet_succesfull_Screen/payment_successfull_Screen.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  List<CartItemModel> cartItems = [];

  ManagerController controller = Get.put(ManagerController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  SizedBox(
                    height: 60.h,
                    child: StreamBuilder<DatabaseEvent>(
                      stream: RealtimeDbHelper.instance.listenToData('restaurant_tables'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                          return Center(
                            child: Text(
                              'No tables created yet',
                              style: StyleHelper.customStyle(
                                color: AppColors.black,
                                size: 10.sp,
                              ),
                            ),
                          );
                        }
                        final raw = snapshot.data!.snapshot.value;
                        if (raw is! Map) {
                          return Center(
                            child: Text(
                              'Invalid table data',
                              style: StyleHelper.customStyle(
                                color: AppColors.black,
                                size: 10.sp,
                              ),
                            ),
                          );
                        }
                        final map = Map<String, dynamic>.from(raw);
                        final tables = map.entries
                            .where((e) => e.value is Map)
                            .map((e) => RestaurantTableModel.fromMap(
                                  e.key,
                                  Map<String, dynamic>.from(e.value as Map),
                                ))
                            .toList()
                          ..sort((a, b) => a.tableNo.compareTo(b.tableNo));

                        return ListView.builder(
                          itemCount: tables.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final table = tables[index];
                            return buildTableCard(table: table);
                          },
                        ).paddingSymmetric(horizontal: 2.w);
                      },
                    ),
                  ),
                  Divider(color: AppColors.darkGray,thickness: 0.5,)
                ],
              ),
            ),
            Expanded(flex: 4, child: buildCartPanel())
          ],
        ),
      ),
    );
  }

  Widget buildTableCard({required RestaurantTableModel table}) {
    final isAvailable = table.status == "available";
    return Container(
      height: 50.h,
      width: 20.w,
      margin: EdgeInsets.all(2.sp),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isAvailable ? [Color(0xFF2d4875), Color(0xFF1a2847)] : [Color(0xFFff6b6b), Color(0xFFee5a6f)],
          )),
      child: Center(
          child: Text(
        "${table.tableNo}",
        style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: medium),
      )),
    );
  }

  /// CART
  Widget buildCartPanel() {
    return Expanded(
      flex: 3,
      child: Container(
        //width: 340,
        color: Colors.grey.shade200,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)]),
              ),
              width: Get.width,
              child: Column(
                children: [
                  Text(
                    "Selected Items",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                ],
              ),
            ),
            Expanded(child: buildCartList()),
            buildCartActions(),
          ],
        ),
      ),
    );
  }

  // In menu_screen.dart - Replace the buildCartList method

  Widget buildCartList() {
    if (cartItems.isEmpty) {
      return const Center(child: Text("No items added"));
    }

    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (_, index) {
        final item = cartItems[index];
        // Use the actual item's isHalf value from the cart
        final isHalf = item.isHalf == 1;

        // Calculate price based on half portion
        final effectiveQty = isHalf ? (item.productQty - 0.5) : item.productQty.toDouble();
        final itemTotal = item.productPrice * effectiveQty;

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: StyleHelper.customStyle(
                          family: bold,
                          color: AppColors.white,
                          size: 4.sp,
                        ),
                      ),
                    ),
                    Text(
                      "₹${item.productPrice}",
                      style: StyleHelper.customStyle(
                        color: AppColors.white,
                        size: 4.sp,
                        family: semiBold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => updateQty(item, -1),
                          color: Colors.red,
                        ),
                        Text(
                          // Show quantity with .5 if half is selected
                          isHalf ? "${item.productQty - 0.5}" : item.productQty.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => updateQty(item, 1),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    Text(
                      "₹${itemTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Special note",
                          isDense: true,
                          hintStyle: StyleHelper.customStyle(
                            color: AppColors.white,
                            size: 4.sp,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.white),
                          ),
                        ),
                        onChanged: (val) => updateNote(item, val),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.scale(
                          scale: 0.5,
                          child: Switch(
                            value: isHalf,
                            activeTrackColor: Color(0xFF1a2847),
                            activeColor: AppColors.white,
                            inactiveThumbColor: AppColors.black,
                            inactiveTrackColor: AppColors.white,
                            onChanged: (v) {
                              // Update the cart item's isHalf value
                              updateIsHalf(item, v ? 1 : 0);
                            },
                          ),
                        ),
                        Text(
                          "Is Half",
                          style: StyleHelper.customStyle(
                            color: AppColors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

// Also update the buildCartActions method to calculate total correctly
  Widget buildCartActions() {
    // Calculate total considering half portions
    final total = cartItems.fold<double>(0, (sum, item) {
      final effectiveQty = item.isHalf == 1 ? (item.productQty - 0.5) : item.productQty.toDouble();
      return sum + (item.productPrice ?? 0) * effectiveQty;
    });

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => cartItems.isEmpty ? null : placeOrder(tableId: controller.tableId.value ?? ''),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              backgroundColor: Color(0xFF1a2847),
            ),
            child: Text(
              "Place Order",
              style: StyleHelper.customStyle(
                color: AppColors.white,
                size: 4.sp,
                family: bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1a2847),
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () => cartItems.isEmpty ? null : generateBill(tableId: controller.tableId.value ?? ''),
            child: Text(
              "Generate Bill",
              style: StyleHelper.customStyle(
                color: AppColors.white,
                size: 4.sp,
                family: bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addToCart(ProductModel p) {
    controller.addToCart(
      cartItems: cartItems,
      product: p,
    );
    setState(() {});
  }

  void updateQty(CartItemModel item, int change) {
    controller.updateQty(
      cartItems: cartItems,
      item: item,
      change: change,
    );
    setState(() {});
  }

  void updateNote(CartItemModel item, String note) {
    controller.updateNote(
      cartItems: cartItems,
      item: item,
      note: note,
    );
    setState(() {});
  }

  void updateIsHalf(CartItemModel item, int isHalf) {
    controller.updateIsHalf(cartItems: cartItems, item: item, isHalf: isHalf);
    setState(() {});
  }

  void generateBill({required String tableId}) {
    Get.to(
      () => PaymentScreen(
        tableId: tableId ?? '',
        cartItems: cartItems,
      ),
    );
  }

  Future<void> placeOrder({required String tableId}) async {
    await controller.placeOrder(
      tableId: tableId ?? '',
      cartItems: cartItems,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order placed successfully"),
      ),
    );
  }
}
