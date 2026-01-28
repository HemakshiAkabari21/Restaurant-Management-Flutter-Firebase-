/*
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';
import 'package:restaurant_management_fierbase/screens/manager_screen/manager_controller.dart';
import 'package:restaurant_management_fierbase/screens/paymnet_succesfull_Screen/payment_successfull_Screen.dart';

enum MenuLevel { master, category, product }

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> with SingleTickerProviderStateMixin {
  List<CartItemModel> cartItems = [];
  List<MasterCategoryModel> leftMasters = [];
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<ProductModel> products = <ProductModel>[].obs;
  late Future<List<MasterCategoryModel>> masterFuture;
  AnimationController? animationController;
  Animation<double>? searchAnimation;

  ManagerController controller = Get.put(ManagerController());

  @override
  void initState() {
    // TODO: implement initState
    // Initialize animation controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    searchAnimation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );

    masterFuture = controller.getMasters();
    loadLeftMasters();
    loadCart();
    super.initState();
  }

  Future<void> loadLeftMasters() async {
    leftMasters = await controller.getMasters();
    setState(() {});
  }

  Future<void> loadCategory() async {
    categoryList.value = await controller.getCategories(controller.selectedMasterId.value);
    setState(() {});
  }

  Future<void> loadProduct() async {
    products.value = await controller.getProducts(controller.selectedProductId.value);
  }

  void toggleSearch() {
    if (controller.isSearch.value) {
      animationController?.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        controller.clearSearch();
      });
    } else {
      controller.isSearch.value = true;
      animationController?.forward();
    }
  }

  Future<void> loadCart() async {
    cartItems = await controller.getCart(controller.selectedTableId.value ?? '');
    debugPrint("TABLE ${controller.selectedTableId.value ?? ''} CART COUNT: ${cartItems.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
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
                  Divider(color: AppColors.darkGray,thickness: 0.5,),
                  SizedBox(
                    height: 40.h,
                    child: FutureBuilder<List<MasterCategoryModel>>(
                      future: controller.getMasters(),
                      builder: (_, snap) {
                        if (!snap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ListView.builder(
                         scrollDirection: Axis.horizontal,
                          itemCount: snap.data!.length,
                          itemBuilder: (_, index) {
                            final master = snap.data![index];
                            return buildMainCategory(masterCategory: master);
                          },
                        );
                      },
                    ),
                  ).paddingSymmetric(horizontal: 2.w),
                  Divider(color: AppColors.darkGray,thickness: 0.5,),
                  SizedBox(
                    height: 40.h,
                    child: FutureBuilder<List<CategoryModel>>(
                      future: controller.getCategories(controller.selectedMasterId.value),
                      builder: (_, snap) {
                        if (!snap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snap.data!.length,
                          itemBuilder: (_, index) {
                            final category = snap.data![index];
                            return buildCategory(category: category);
                          },
                        );
                      },
                    ),
                  ).paddingSymmetric(horizontal: 2.w),
                  Divider(color: AppColors.darkGray,thickness: 0.5,),
                  Expanded(child: buildProductGrid().paddingSymmetric(horizontal: 2.w))
                ],
              ),
            ),
            Expanded(flex: 4, child: buildCartPanel())
          ],
        ),
      ),
    );
  }

  /// Table
  Widget buildTableCard({required RestaurantTableModel table}) {
    final isAvailable = table.status == "available";
    return GestureDetector(
      onTap: ()async {
        if (isAvailable) {
          editTableDialog(context, table);
        }else{
          controller.selectedTableId.value = table.id;
          controller.getCart(table.id);
          cartItems = await controller.getCart(controller.selectedTableId.value ?? '');
          controller.selectedMasterId.value = leftMasters.first.id;
          loadCategory();
          controller.selectedCategoryId.value = categoryList.first.id;
          loadProduct();

        }
      },
      child: Container(
        height: 50.h,
        width: 20.w,
        margin: EdgeInsets.all(2.sp),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAvailable ? [AppColors.primaryColor, AppColors.secondaryPrimaryColor] : [AppColors.errorPrimaryColor, AppColors.errorSecondaryPrimaryColor],
            )),
        child: Center(
            child: Text(
          "${table.tableNo}",
          style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: medium),
        )),
      ),
    );
  }

  ///Master Category
  Widget buildMainCategory({required MasterCategoryModel masterCategory}){
    RxBool isSelected = (controller.selectedMasterId.value == masterCategory.id).obs;
    return Obx(()=> GestureDetector(
        onTap: (){
          controller.selectedMasterId.value = masterCategory.id;
         // controller.selectedCategoryId.value = controller.getCategories(masterCategory.id).first.id;
          isSelected.value = controller.selectedMasterId.value == masterCategory.id;
          setState(() {});
        },
        child: Container(
          height: 30.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: isSelected.value ? AppColors.secondaryPrimaryColor : AppColors.white,
              border: Border.all(color: AppColors.secondaryPrimaryColor,width: 0.5)
            ),
            child: Text(masterCategory.name,style: StyleHelper.customStyle(color: isSelected.value ? AppColors.white : AppColors.black,size: 4.sp,family: medium),),
          ),
      ),
    );
}

  ///Category
  Widget buildCategory({required CategoryModel category}){
    RxBool isSelected = (controller.selectedCategoryId.value == category.id).obs;
    return Obx(
      ()=> GestureDetector(
        onTap: (){
          controller.selectedCategoryId .value = category.id;
          isSelected.value = controller.selectedCategoryId.value == category.id;
          setState(() {});
        },
        child: Container(
          height: 30.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal:  8.w),
          decoration: BoxDecoration(
              color: isSelected.value ? AppColors.secondaryPrimaryColor : AppColors.white,
              border: Border.all(color: AppColors.secondaryPrimaryColor,width: 0.5)
          ),
          child: Text(category.name,style: StyleHelper.customStyle(color: isSelected.value ? AppColors.white : AppColors.black,size: 4.sp,family: medium),),
        ),
      ),
    );
}

  /// Product card with price
  Widget buildProductGrid() {
    if (controller.selectedCategoryId.isEmpty) {
      return const Center(child: Text("No category selected"));
    }

    return FutureBuilder<List<ProductModel>>(
      future: controller.getProducts(controller.selectedCategoryId.value),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.h,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (_, index) {
            return buildProductCard(snap.data![index]);
          },
        );
      },
    );
  }

  Widget buildProductCard(ProductModel product) {
    int productQty = cartItems.firstWhere((e) => e.productId == product.id, orElse: () => CartItemModel(productQty: 0, productId: '', productName: '', productPrice: 0.0, isHalf: 0, productNote: ''),).productQty;
    CartItemModel item = CartItemModel(productId: product.id, productName: product.name, productPrice:double.tryParse(product.price ?? '') ??0, productQty: productQty, isHalf: 0, productNote: '');
    return GestureDetector(
      onTap: (){
        if(productQty == 0){
          addToCart(product);
        }else{
          updateQty(item, 1);
        }
        },
      child: Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w,vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.darkGray),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, -4), blurRadius: 20, spreadRadius: 0,)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(product.name ?? '',maxLines: null,style: StyleHelper.customStyle(color: AppColors.black,size: 5.sp,family: semiBold),),
            Text(product.price,style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: regular),)
          ],
        ),
      ),
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
            onPressed: () => cartItems.isEmpty ? null : placeOrder(tableId: controller.selectedTableId.value ?? ''),
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
            onPressed: () => cartItems.isEmpty ? null : generateBill(tableId: controller.selectedTableId.value ?? ''),
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
    controller.addToCart(cartItems: cartItems, product: p,);
    setState(() {});
  }

  void updateQty(CartItemModel item, int change) {
    controller.updateQty(cartItems: cartItems, item: item, change: change,);
    setState(() {});
  }

  void updateNote(CartItemModel item, String note) {
    controller.updateNote(cartItems: cartItems, item: item, note: note,);
    setState(() {});
  }

  void updateIsHalf(CartItemModel item, int isHalf) {
    controller.updateIsHalf(cartItems: cartItems, item: item, isHalf: isHalf);
    setState(() {});
  }

  void generateBill({required String tableId}) {
    Get.to(() => PaymentScreen(tableId: tableId ?? '', cartItems: cartItems,),);
  }

  Future<void> placeOrder({required String tableId}) async {
    await controller.placeOrder(tableId: tableId ?? '', cartItems: cartItems,);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order placed successfully"),),);
  }

  void editTableDialog(BuildContext context, RestaurantTableModel table) {
    final capacityController = TextEditingController(text: table.capacityPeople.toString());
    String status = table.status;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('Edit Table ${table.tableNo}', style: StyleHelper.customStyle(color: AppColors.black, size: 8.sp, family: semiBold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ).paddingOnly(bottom: 16.h),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                items: ['available', 'booked'].map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.capitalizeFirst!),
                )).toList(),
                onChanged: (v) {
                  setState(() {status = v!;});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: StyleHelper.customStyle(color: Colors.grey, size: 6.sp,),),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = table.copyWith(capacityPeople: int.tryParse(capacityController.text) ?? table.capacityPeople, status: status);
                await controller.updateTable(updated);
                controller.selectedMasterId.value = leftMasters.first.id;
                loadCategory();
                controller.selectedCategoryId.value = categoryList.first.id;
                loadProduct();
                controller.getCart(table.id);
                cartItems = await controller.getCart(controller.selectedTableId.value ?? '');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2d4875), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
              child: Text('Save', style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/