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

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> with SingleTickerProviderStateMixin {
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  List<MasterCategoryModel> leftMasters = [];
  RxList<CategoryModel> categoryList = <CategoryModel>[].obs;
  RxList<ProductModel> products = <ProductModel>[].obs;
  late Future<List<MasterCategoryModel>> masterFuture;
  AnimationController? animationController;
  Animation<double>? searchAnimation;
  RxBool isLoading = false.obs;
  RxBool isCategoryLoading = false.obs;
  RxBool isProductLoading = false.obs;

  ManagerController controller = Get.put(ManagerController());

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    searchAnimation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.easeInOut,
    );
    loadCategory();
  }

  Future<void> loadCategory() async {
    categoryList.value = await controller.getCategories();
  }

  Future<void> loadProduct() async {
    // isProductLoading.value = true;
    products.value = await controller.getProducts(controller.selectedCategoryId.value);
    isProductLoading.value = false;
  }

  Future<void> loadCart() async {
    isLoading.value = true;
    final items = await controller.getCart(controller.selectedTableId.value);
    cartItems.value = items;
    debugPrint("TABLE ${controller.selectedTableId.value} CART COUNT: ${cartItems.length}");
    isLoading.value = false;
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
                    height: 50.h,
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
                  Divider(color: AppColors.darkGray, thickness: 0.5),
                  FutureBuilder<List<CategoryModel>>(
                    future: controller.getCategories(),
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return Center(child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()));
                      }
                      return Obx(
                        () => isCategoryLoading.value
                            ? SizedBox(height: 10.h, width: 10.w, child: CircularProgressIndicator())
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 1, childAspectRatio: 4.50),
                                itemCount: snap.data!.length,
                                itemBuilder: (_, index) {
                                  final category = snap.data![index];
                                  return buildCategory(category: category);
                                },
                              ),
                      );
                    },
                  ).paddingSymmetric(horizontal: 2.w),
                  Divider(color: AppColors.darkGray, thickness: 0.5),
                  Expanded(child: buildProductGrid().paddingSymmetric(horizontal: 2.w))
                ],
              ),
            ),
            Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      height: Get.height,
                      color: AppColors.darkGray,
                      width: (0.1).w,
                    ),
                    buildCartPanel(),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  /// Table
  Widget buildTableCard({required RestaurantTableModel table}) {
    return Obx(() {
      final isAvailable = table.status == "available";
      final isSelected = controller.selectedTableId.value == table.id;

      return GestureDetector(
        onTap: () async {
          if (isAvailable) {
            editTableDialog(context, table);
          } else {
            // Set selected table
            controller.selectedTableId.value = table.id;
            controller.selectedTable.value = '${table.tableNo}';

            // Load cart items immediately
            await loadCart();

            // Load master categories if not already loaded
            if (leftMasters.isEmpty) {
              await loadCategory();
            }
            // Select first category
            if (categoryList.isNotEmpty) {
              controller.selectedCategoryId.value = categoryList.first.id;
              await loadProduct();
            }
          }
        },
        child: Container(
          height: 40.h,
          width: 20.w,
          margin: EdgeInsets.all(2.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [Color(0xFF4CAF50), Color(0xFF45a049)] // Selected - Green gradient
                  : isAvailable
                      ? [AppColors.primaryColor, AppColors.secondaryPrimaryColor] // Available
                      : [AppColors.errorPrimaryColor, AppColors.errorSecondaryPrimaryColor], // Booked
            ),
            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Center(
            child: Text(
              "${table.tableNo}",
              style: StyleHelper.customStyle(
                color: AppColors.white,
                size: 6.sp,
                family: medium,
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Category
  Widget buildCategory({required CategoryModel category}) {
    return Obx(
      () {
        bool isSelected = controller.selectedCategoryId.value == category.id;
        return GestureDetector(
          onTap: () async {
            controller.selectedCategoryId.value = category.id;
            await loadProduct();
          },
          child: Container(
            height: 30.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondaryPrimaryColor : AppColors.white,
              border: Border.all(color: AppColors.secondaryPrimaryColor, width: 0.5),
            ),
            child: Text(
              category.name,
              style: StyleHelper.customStyle(
                color: isSelected ? AppColors.white : AppColors.black,
                size: 4.sp,
                family: medium,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Product card with price
  Widget buildProductGrid() {
    return Obx(() {
      if (controller.selectedCategoryId.isEmpty) {
        return const Center(child: Text("No category selected"));
      }

      return FutureBuilder<List<ProductModel>>(
        future: controller.getProducts(controller.selectedCategoryId.value),
        builder: (_, snap) {
          if (!snap.hasData) {
            return Center(child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()));
          }
          return Obx(
            () => isProductLoading.value
                ? Center(child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, crossAxisSpacing: 2.w, mainAxisSpacing: 2.h, childAspectRatio: 1),
                    itemCount: snap.data!.length,
                    itemBuilder: (_, index) {
                      return buildProductCard(snap.data![index]);
                    },
                  ),
          );
        },
      );
    });
  }

  Widget buildProductCard(ProductModel product) {
    int productQty = 0;

    // Find product in cart safely
    try {
      final cartItem = cartItems.firstWhere(
        (e) => e.productId == product.id,
        orElse: () => CartItemModel(productQty: 0, productId: '', productName: '', productPrice: 0.0, isHalf: 0, productNote: ''),
      );

      // Only use quantity if we found a valid cart item
      if (cartItem.productId.isNotEmpty) {
        productQty = cartItem.productQty;
      }
    } catch (e) {
      productQty = 0;
    }

    CartItemModel item = CartItemModel(
        productId: product.id,
        productName: product.name,
        productPrice: double.tryParse(product.price ?? '') ?? 0,
        productQty: productQty,
        isHalf: 0,
        productNote: '');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (controller.selectedTableId.isEmpty) {
            Get.snackbar(
              'No Table Selected',
              'Please select a table first',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          if (productQty == 0) {
            controller.addToCart(
              cartItems: cartItems,
              product: product,
            );
            cartItems.refresh();
          } else {
            updateQty(item, 1);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: product.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: StyleHelper.customStyle(
                        size: 4.sp,
                        family: medium,
                        color: AppColors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${product.price}",
                          style: TextStyle(
                            fontSize: 4.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ).paddingOnly(top: 4.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProductCard1(ProductModel product) {
    return Obx(() {
      int productQty = 0;

      // Find product in cart safely
      try {
        final cartItem = cartItems.firstWhere(
          (e) => e.productId == product.id,
          orElse: () => CartItemModel(productQty: 0, productId: '', productName: '', productPrice: 0.0, isHalf: 0, productNote: ''),
        );

        // Only use quantity if we found a valid cart item
        if (cartItem.productId.isNotEmpty) {
          productQty = cartItem.productQty;
        }
      } catch (e) {
        productQty = 0;
      }

      CartItemModel item = CartItemModel(
          productId: product.id,
          productName: product.name,
          productPrice: double.tryParse(product.price ?? '') ?? 0,
          productQty: productQty,
          isHalf: 0,
          productNote: '');

      return GestureDetector(
        onTap: () {
          if (controller.selectedTableId.isEmpty) {
            Get.snackbar(
              'No Table Selected',
              'Please select a table first',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          if (productQty == 0) {
            controller.addToCart(
              cartItems: cartItems,
              product: product,
            );
            cartItems.refresh();
          } else {
            updateQty(item, 1);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.darkGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -4),
                blurRadius: 20,
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name ?? '',
                maxLines: null,
                textAlign: TextAlign.center,
                style: StyleHelper.customStyle(
                  color: AppColors.black,
                  size: 5.sp,
                  family: semiBold,
                ),
              ),
              Text(
                "₹${product.price}",
                style: StyleHelper.customStyle(
                  color: AppColors.black,
                  size: 4.sp,
                  family: medium,
                ),
              ),
              if (productQty > 0)
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryPrimaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Qty: $productQty',
                    style: StyleHelper.customStyle(
                      color: AppColors.white,
                      size: 3.sp,
                      family: semiBold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  /// CART
  Widget buildCartPanel() {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)],
                ),
              ),
              width: Get.width,
              child: Column(
                children: [
                  Text("Selected Items", style: StyleHelper.customStyle(size: 5.sp, family: bold, color: AppColors.white,),),
                  Obx(() {
                    if (controller.selectedTableId.isNotEmpty) {
                      return Text("Table: ${controller.selectedTable.value}", style: TextStyle(fontSize: 12, color: AppColors.white.withOpacity(0.8),));
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(flex: 4, child: Text("Item Name",textAlign: TextAlign.start,style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: semiBold),)),
                Expanded(flex: 2, child: Text("Item qty",textAlign: TextAlign.center,style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: semiBold),)),
                Expanded(flex: 2, child: Text("is half",textAlign: TextAlign.center,style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: semiBold),)),
                Expanded(flex: 2, child: Text("Item price",textAlign: TextAlign.end,style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: semiBold),)),
              ],
            ).paddingSymmetric(horizontal: 10,vertical: 6.h),
            Expanded(child: buildCartList()),
            buildCartActions(),
          ],
        ),
      ),
    );
  }

  Widget buildCartList() {
    return Obx(() {
      // Filter out any invalid cart items
      final validCartItems = cartItems.where((item) => item.productId.isNotEmpty && item.productName.isNotEmpty && item.productQty > 0).toList();

      if (validCartItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey).paddingOnly(bottom: 16.h),
              Text(
                "No items added",
                style: StyleHelper.customStyle(
                  size: 18,
                  color: Colors.grey,
                  family: medium,
                ),
              ),
            ],
          ),
        );
      }

      return Obx(() => isLoading.value
          ? Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator()))
          : ListView.builder(
              itemCount: validCartItems.length,
              itemBuilder: (_, index) {
                final item = validCartItems[index];
                final isHalf = item.isHalf == 1;
                final effectiveQty = isHalf ? (item.productQty - 0.5) : item.productQty.toDouble();
                final itemTotal = item.productPrice * effectiveQty;

                return buildCart(item: item,itemTotal: itemTotal.toStringAsFixed(2),isHalf:isHalf,index:index);
                  /*Card(
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
                            Expanded(child: Text(item.productName, style: StyleHelper.customStyle(family: bold, color: AppColors.white, size: 4.sp,))),
                            Text("₹${item.productPrice.toStringAsFixed(2)}", style: StyleHelper.customStyle(color: AppColors.white, size: 4.sp, family: semiBold)),
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
                            Text("₹${itemTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Special note",
                                    isDense: true,
                                    hintStyle: StyleHelper.customStyle(color: AppColors.white, size: 4.sp),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.white)),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.white)),
                                  ),
                                  onChanged: (val) {
                                    controller.updateNote(cartItems: cartItems, item: item, note: val);
                                    cartItems.refresh();
                                  },
                                ),
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
                                      controller.updateIsHalf(cartItems: cartItems, item: item, isHalf: v ? 1 : 0);
                                      cartItems.refresh();
                                    },
                                  ),
                                ),
                                Text("Is Half", style: StyleHelper.customStyle(color: AppColors.white, size: 12)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );*/
              },
            ));
    });
  }

  Widget buildCart({required CartItemModel item,required String itemTotal, required bool isHalf, required int index}){
    return SizedBox(
      width: Get.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 4,
                  child: Text(item.productName,maxLines: null,style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: medium))),
              Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){updateQty(item, -1);},
                        child: Container(
                          padding: EdgeInsets.all(2.sp),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: AppColors.black),
                          ),
                          child: Center(child: Icon(Icons.remove,color: AppColors.black,size: 8,)),
                        ),
                      ),
                      Text( item.isHalf == 1
                          ? '${item.productQty - 0.5}'
                          : '${item.productQty}',style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: medium),),
                      GestureDetector(
                        onTap: (){updateQty(item, 1);},
                        child: Container(
                          padding: EdgeInsets.all(2.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: AppColors.black),
                          ),
                          child: Icon(Icons.add,color: AppColors.black,size: 8,),
                        ),
                      )
                    ],
                  )),
              Expanded(
                flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      controller.updateIsHalf(cartItems: cartItems, item: item, isHalf: item.isHalf == 1 ? 0 : 1);
                      cartItems.refresh();
                    },
                    child: Icon(
                      item.isHalf == 1
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 8.sp,
                    ),
                  ).paddingSymmetric(horizontal: 4.w)),

              Expanded(
                  flex: 2,
                  child: Text('₹$itemTotal',textAlign: TextAlign.end,style: StyleHelper.customStyle(color: AppColors.black,size: 4.sp,family: medium),)),
            ],
          ),
          if(index != -1)
            Divider(color: AppColors.gray,thickness: 0.5,)
        ],
      ),
    ).paddingSymmetric(horizontal: 10);
  }

  Widget buildCartActions() {
    return Obx(() {
      // Filter valid cart items
      final validCartItems = cartItems.where((item) => item.productId.isNotEmpty && item.productQty > 0).toList();

      final total = validCartItems.fold<double>(0, (sum, item) {
        final effectiveQty = item.isHalf == 1 ? (item.productQty - 0.5) : item.productQty.toDouble();
        return sum + (item.productPrice ?? 0) * effectiveQty;
      });

      return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding:  EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("₹${total.toStringAsFixed(2)}", style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ).paddingOnly(bottom: 8.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: validCartItems.isEmpty || controller.selectedTableId.isEmpty
                          ? null
                          : () => placeOrder(tableId: controller.selectedTableId.value),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        backgroundColor: Color(0xFF1a2847),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Text("Place Order", style: StyleHelper.customStyle(color: AppColors.white, size: 4.sp, family: bold))
                  ),
                ),
                SizedBox(
                  width: 2.w,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1a2847),
                      minimumSize: const Size(double.infinity, 45),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    onPressed: validCartItems.isEmpty || controller.selectedTableId.isEmpty
                        ? null
                        : () => generateBill(tableId: controller.selectedTableId.value),
                    child: Text("Generate Bill", style: StyleHelper.customStyle(color: AppColors.white, size: 4.sp, family: bold)),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    });
  }

  void updateQty(CartItemModel item, int change) {
    controller.updateQty(cartItems: cartItems, item: item, change: change);
    cartItems.refresh();
  }

  void generateBill({required String tableId}) {
    // Filter valid cart items before generating bill
    final validCartItems = cartItems.where((item) => item.productId.isNotEmpty && item.productQty > 0).toList();

    Get.to(() => PaymentScreen(tableId: tableId, cartItems: validCartItems, tableNo: controller.selectedTable.value));
  }

  Future<void> placeOrder({required String tableId}) async {
    // Filter valid cart items before placing order
    final validCartItems = cartItems.where((item) => item.productId.isNotEmpty && item.productQty > 0).toList();
    await controller.placeOrder(tableId: tableId, cartItems: validCartItems);
    Get.snackbar('Success', 'Order placed successfully', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
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
                items: ['available', 'booked'].map((e) => DropdownMenuItem(value: e, child: Text(e.capitalizeFirst!),)).toList(),
                onChanged: (v) {
                  setState(() {status = v!;});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: StyleHelper.customStyle(color: Colors.grey, size: 6.sp)),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = table.copyWith(
                  capacityPeople: int.tryParse(capacityController.text) ?? table.capacityPeople,
                  status: status,
                );
                await controller.updateTable(updated);

                if (status == 'booked') {
                  controller.selectedTableId.value = table.id;
                  controller.selectedTable.value = '${table.tableNo}';
                  await loadCart();

                  if (leftMasters.isNotEmpty) {
                    controller.selectedMasterId.value = leftMasters.first.id;
                    await loadCategory();

                    if (categoryList.isNotEmpty) {
                      controller.selectedCategoryId.value = categoryList.first.id;
                      await loadProduct();
                    }
                  }
                }

                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2d4875),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: Text('Save', style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp))
            ),
          ],
        ),
      ),
    );
  }
}
