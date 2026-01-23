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
import 'package:restaurant_management_fierbase/screens/menu_screen/menu_controller.dart';
import 'package:restaurant_management_fierbase/screens/paymnet_succesfull_Screen/payment_successfull_Screen.dart';

enum MenuLevel { master, category, product }

class MenuScreen extends StatefulWidget {
  final String? tableId;
  const MenuScreen({super.key, this.tableId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  MenuLevel currentLevel = MenuLevel.master;
  MasterCategoryModel? selectedMaster;
  CategoryModel? selectedCategory;
  List<CartItemModel> cartItems = [];
  String? expandedMasterId;
  List<MasterCategoryModel> leftMasters = [];

  late Future<List<MasterCategoryModel>> masterFuture;

  MenuScreenController controller = Get.put(MenuScreenController());

  @override
  void initState() {
    super.initState();
    masterFuture = controller.getMasters();
    loadLeftMasters();
    loadCart();
  }

  Future<void> loadLeftMasters() async {
    leftMasters = await controller.getMasters();
    setState(() {});
  }

  Future<void> loadCart() async {
    cartItems = await controller.getCart(widget.tableId ?? '');
    debugPrint("TABLE ${widget.tableId} CART COUNT: ${cartItems.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            buildLeftPanel(),
            buildCenterPanel(),
            buildCartPanel(),
          ],
        ),
      ),
    );
  }

  /// LEFT PANEL
  Widget buildLeftPanel() {
    return Expanded(
      flex: 2,
      child: Container(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: Get.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                ),
              ),
              child: const Text("Categories", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,),),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: leftMasters.length,
                itemBuilder: (_, i) {
                  final master = leftMasters[i];
                  final isExpanded = expandedMasterId == master.id;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          master.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onTap: () async {
                          setState(() {
                            expandedMasterId = isExpanded ? null : master.id;
                            selectedMaster = master;
                            selectedCategory = null;
                            currentLevel = MenuLevel.product;
                          });

                          if (!isExpanded) {
                            final categories = await controller.getCategories(master.id);
                            if (categories.isNotEmpty) {
                              setState(() {
                                selectedCategory = categories.first;
                              });
                            }
                          }
                        },
                      ),
                      if (isExpanded)
                        FutureBuilder<List<CategoryModel>>(
                          future: controller.getCategories(master.id),
                          builder: (_, snap) {
                            if (!snap.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Column(
                              children: snap.data!
                                  .map(
                                    (cat) => SizedBox(
                                      height: 150,
                                      child: buildGridCard(
                                        title: cat.name,
                                        imageUrl: cat.image,
                                        onTap: () {
                                          setState(() {
                                            selectedCategory = cat;
                                            currentLevel = MenuLevel.product;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CENTER PANEL
  Widget buildCenterPanel() {
    return Expanded(
      flex: 5,
      child: Container(
        color: AppColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    currentLevel == MenuLevel.master
                        ? Icons.restaurant_menu
                        : currentLevel == MenuLevel.category
                            ? Icons.category
                            : Icons.fastfood,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currentLevel == MenuLevel.master
                        ? "Select Master Category"
                        : currentLevel == MenuLevel.category
                            ? "Select Category"
                            : "Select Products",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildGridContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridContent() {
    if (selectedCategory != null) {
      return buildProductGrid();
    }
    return buildMasterGrid();
  }

  Widget buildMasterGrid() {
    return FutureBuilder<List<MasterCategoryModel>>(
      future: controller.getMasters(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (_, index) {
            final master = snap.data![index];
            return buildGridCard(
              title: master.name,
              imageUrl: master.image,
              onTap: () async {
                setState(() {
                  selectedMaster = master;
                  expandedMasterId = master.id;
                  selectedCategory = null;
                  currentLevel = MenuLevel.product;
                });

                final categories = await controller.getCategories(master.id);
                if (categories.isNotEmpty) {
                  setState(() {
                    selectedCategory = categories.first;
                  });
                }
              },
            );
          },
        );
      },
    );
  }

  Widget buildProductGrid() {
    if (selectedCategory == null) {
      return const Center(child: Text("No category selected"));
    }

    return FutureBuilder<List<ProductModel>>(
      future: controller.getProducts(selectedCategory!.id),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (_, index) {
            return buildProductCard(snap.data![index]);
          },
        );
      },
    );
  }

  /// Product card with price
  Widget buildProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => addToCart(product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: /*isAvailable*/
                    /*?*/ [Color(0xFF2d4875), Color(0xFF1a2847)]
                // : [Color(0xFFff6b6b), Color(0xFFee5a6f)],
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: product.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),
                          child: Image.network(
                            product.image, fit: BoxFit.cover, width: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 50, color: Colors.grey,),
                          ),
                        )
                      : const Icon(Icons.fastfood, size: 50, color: Colors.grey,),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 2,overflow: TextOverflow.ellipsis, style: StyleHelper.customStyle(size: 4.sp, family: medium, color: AppColors.white),).paddingOnly(bottom: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₹${product.price}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green,),),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h,),
                          decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(6),),
                          child: const Icon(Icons.add, color: Colors.white, size: 18,),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// grid card widget
  Widget buildGridCard({required String title, String? imageUrl, required VoidCallback onTap,}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: /*isAvailable*/
                    /*?*/ [Color(0xFF2d4875), Color(0xFF1a2847)]
                // : [Color(0xFFff6b6b), Color(0xFFee5a6f)],
                ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),
                          child: Image.network(
                            imageUrl, fit: BoxFit.cover, width: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey,),
                          ),
                        )
                      : const Icon(Icons.image, size: 50, color: Colors.grey,),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(title,textAlign: TextAlign.center,   maxLines: 2,   overflow: TextOverflow.ellipsis,
                    style: StyleHelper.customStyle(size: 6.sp, color: AppColors.white, family: medium),
                  ),
                ),
              ),
            ],
          ),
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
              padding:  EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)]),
              ),
              width: Get.width,
              child: Column(
                children: [
                  Text("Selected Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),),
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

  Widget buildCartActions() {
    final total = cartItems.fold<double>(0, (sum, item) => sum + (item.productPrice ?? 0) * item.productQty,);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: cartItems.isEmpty ? null : placeOrder,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45), backgroundColor: Color(0xFF1a2847)),
            child: Text("Place Order", style: StyleHelper.customStyle(color: AppColors.white, size: 4.sp, family: bold),),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1a2847),
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: cartItems.isEmpty ? null : generateBill,
            child: Text("Generate Bill", style: StyleHelper.customStyle(color: AppColors.white, size: 4.sp, family: bold),),
          ),
        ],
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
        final itemTotal = item.productPrice * item.productQty;

        return Card(
          margin: EdgeInsets.all(4.sp),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: /*isAvailable*/
                      /*?*/ [Color(0xFF2d4875), Color(0xFF1a2847)]
                  // : [Color(0xFFff6b6b), Color(0xFFee5a6f)],
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
                        style: StyleHelper.customStyle(family: bold, color: AppColors.white, size: 4.sp),
                      ),
                    ),
                    Text(
                      "₹${item.productPrice}",
                      style: StyleHelper.customStyle(color: AppColors.white, size: 4.sp, family: semiBold),
                    ),
                  ],
                ).paddingOnly(bottom: 8.h),
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
                          item.productQty.toString(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => updateQty(item, 1),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    Text("₹${(itemTotal).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),),
                  ],
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Special note",
                    isDense: true,
                    hintStyle: StyleHelper.customStyle(color: AppColors.white, size: 4.sp,),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.white),),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.white),),
                  ),
                  onChanged: (val) => updateNote(item, val),
                )
              ],
            ),
          ),
        );
      },
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

  void generateBill() {
    Get.to(() => PaymentScreen(tableId: widget.tableId ?? '', cartItems: cartItems,),);
  }

  Future<void> placeOrder() async {
    await controller.placeOrder(tableId: widget.tableId ?? '', cartItems: cartItems,);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order placed successfully"),),);
  }

}
