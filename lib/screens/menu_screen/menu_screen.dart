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

  @override
  void initState() {
    super.initState();
    masterFuture = RealtimeDbHelper.instance.getMasterCategories();
    loadLeftMasters();
    loadCart();
  }

  Future<void> loadLeftMasters() async {
    leftMasters = await RealtimeDbHelper.instance.getMasterCategories();
    setState(() {});
  }

  Future<void> loadCart() async {
    cartItems = await RealtimeDbHelper.instance.getTableCartList(widget.tableId ?? '');
    debugPrint("TABLE ${widget.tableId} CART COUNT: ${cartItems.length}",);
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

  /// LEFT PANEL - Shows navigation breadcrumb/back button
  Widget buildLeftPanel() {
    return Container(
      width: 220,
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
            child: const Text(
              "Categories",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                      title: Text(master.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                      onTap: () async {
                        setState(() {
                          expandedMasterId = isExpanded ? null : master.id;
                          selectedMaster = master;
                          selectedCategory = null; // reset category initially
                          currentLevel = MenuLevel.product; // show products in center
                        });

                        if (!isExpanded) {
                          // Fetch categories for this master
                          final categories = await RealtimeDbHelper.instance.getCategoriesByMaster(master.id);
                          if (categories.isNotEmpty) {
                            // Automatically select the first category
                            setState(() {
                              selectedCategory = categories.first;
                            });
                          }
                        }
                      },
                    ),
                    if (isExpanded)
                      FutureBuilder<List<CategoryModel>>(
                        future: RealtimeDbHelper.instance.getCategoriesByMaster(master.id),
                        builder: (_, snap) {
                          if (!snap.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Column(
                            children: snap.data!.map((cat) {
                              return SizedBox(
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
                              );
                            }).toList(),
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
    );
  }

  /* Widget buildLeftPanel() {
    return Container(
      width: 220,
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            width: Get.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)]
              ),
            ),
            child: const Text(
              "Menu Navigation",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Breadcrumb/Navigation
          if (currentLevel != MenuLevel.master) ...[
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text("Back"),
              tileColor: Colors.grey.shade300,
              onTap: () {
                setState(() {
                  if (currentLevel == MenuLevel.product) {
                    currentLevel = MenuLevel.category;
                  } else if (currentLevel == MenuLevel.category) {
                    currentLevel = MenuLevel.master;
                    selectedMaster = null;
                  }
                });
              },
            ),
            const Divider(height: 1),
          ],

          // Current selection info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedMaster != null) ...[
                  const Text(
                    "Master Category:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedMaster!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (selectedCategory != null) ...[
                  const Text(
                    "Category:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedCategory!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }*/

  /// CENTER PANEL - Shows grid of current level items
  Widget buildCenterPanel() {
    return Expanded(
      flex: 2,
      child: Container(
        color: AppColors.white,
        child: Column(
          children: [
            // Header showing current level
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)]
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
                    style:  TextStyle(
                      fontSize: 20,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Grid content
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

/*  Widget buildGridContent() {
    switch (currentLevel) {
      case MenuLevel.master:
        return buildMasterGrid();
      case MenuLevel.category:
        return buildCategoryGrid();
      case MenuLevel.product:
        return buildProductGrid();
    }
  }*/

  Widget buildGridContent() {
    if (selectedCategory != null) {
      return buildProductGrid();
    }
    return buildMasterGrid();
  }

  // Grid for Master Categories
  Widget buildMasterGrid() {
    return FutureBuilder<List<MasterCategoryModel>>(
      future: RealtimeDbHelper.instance.getMasterCategories(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.isEmpty) {
          return const Center(child: Text("No master categories available"));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (context, index) {
            final master = snap.data![index];
            return buildGridCard(
              title: master.name,
              imageUrl: master.image,
              onTap: () async {
                // Update selected master
                setState(() {
                  selectedMaster = master;
                  expandedMasterId = master.id; // expand in left panel
                  currentLevel = MenuLevel.product; // show products
                  selectedCategory = null; // reset category initially
                });

                // Load categories for this master
                final categories =
                await RealtimeDbHelper.instance.getCategoriesByMaster(master.id);

                if (categories.isNotEmpty) {
                  // Automatically select first category
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

  /* Widget buildMasterGrid() {
    return FutureBuilder<List<MasterCategoryModel>>(
      future: RealtimeDbHelper.instance.getMasterCategories(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.isEmpty) {
          return const Center(child: Text("No master categories available"));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (context, index) {
            final master = snap.data![index];
            return buildGridCard(
              title: master.name,
              imageUrl: master.image,
              onTap: () {
                setState(() {
                  selectedMaster = master;
                  selectedCategory = null;
                  currentLevel = MenuLevel.category;
                });
              },
            );
          },
        );
      },
    );
  }*/

  // Grid for Categories
  Widget buildCategoryGrid() {
    if (selectedMaster == null) {
      return const Center(child: Text("No master category selected"));
    }

    return FutureBuilder<List<CategoryModel>>(
      future: RealtimeDbHelper.instance.getCategoriesByMaster(selectedMaster!.id),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.isEmpty) {
          return const Center(
            child: Text("No categories available for this master category"),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (context, index) {
            final category = snap.data![index];
            return buildGridCard(
              title: category.name,
              imageUrl: category.image,
              onTap: () {
                setState(() {
                  selectedCategory = category;
                  currentLevel = MenuLevel.product;
                });
              },
            );
          },
        );
      },
    );
  }

  // Grid for Products
  Widget buildProductGrid() {
    if (selectedCategory == null) {
      return const Center(child: Text("No category selected"));
    }

    return FutureBuilder<List<ProductModel>>(
      future: RealtimeDbHelper.instance.getProductsByCategory(selectedCategory!.id),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.isEmpty) {
          return const Center(
            child: Text("No products available for this category"),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (context, index) {
            final product = snap.data![index];
            return buildProductCard(product);
          },
        );
      },
    );
  }

  // grid card widget
  Widget buildGridCard({required String title, String? imageUrl, required VoidCallback onTap,}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: /*isAvailable*/
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
                      ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),
                          child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,
                           errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey,),),)
                      : const Icon(Icons.image, size: 50, color: Colors.grey,),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    title,
                    style:  StyleHelper.customStyle(size: 6.sp, color: AppColors.white,family: medium),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Product card with price
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
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: /*isAvailable*/
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
                  child: product.image != null && product.image!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
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
                      : const Icon(
                    Icons.fastfood,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style:  StyleHelper.customStyle(size: 4.sp, family: medium,color: AppColors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${product.price}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
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

  /// RIGHT PANEL - Cart
  Widget buildCartPanel() {
    return Container(
      width: 340,
      color: Colors.grey.shade200,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)]
              ),
            ),
            width: Get.width,
            padding:  EdgeInsets.all(4.sp),
            child: Column(
              children: [
                 Text(
                  "Selected Items",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: AppColors.white),
                ),
               SizedBox(height: 3.h,)
               /* if (widget.tableId != null && widget.tableId!.isNotEmpty)
                  Text(
                    "Table: ${widget.tableId}",
                    style:  TextStyle(fontSize: 14, color: Colors.grey.shade50),
                  ),*/
              ],
            ),
          ),
          Expanded(child: buildCartList()),
          buildCartActions(),
        ],
      ),
    );
  }

  Widget buildCartActions() {
    final total = cartItems.fold<double>(
      0,
          (sum, item) => sum + (item.productPrice ?? 0) * item.productQty,
    );

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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: cartItems.isEmpty ? null : placeOrder,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              backgroundColor: Color(0xFF1a2847)
            ),
            child: Text("Place Order",style: StyleHelper.customStyle(color: AppColors.white,size: 4.sp,family: bold),),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1a2847),
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: cartItems.isEmpty ? null : generateBill,
            child: Text("Generate Bill",style: StyleHelper.customStyle(color: AppColors.white,size: 4.sp,family: bold),),
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
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: /*isAvailable*/
                  /*?*/ [Color(0xFF2d4875), Color(0xFF1a2847)]
                // : [Color(0xFFff6b6b), Color(0xFFee5a6f)],
              ),
            ),
            padding:  EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style:  StyleHelper.customStyle(family: bold,color: AppColors.white,size: 4.sp),
                      ),
                    ),
                    Text("₹${item.productPrice}",style: StyleHelper.customStyle(color: AppColors.white,size: 4.sp,family: semiBold),),
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: AppColors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => updateQty(item, 1),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    Text(
                      "₹${(itemTotal).toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold,color: AppColors.white),
                    ),
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
    final index = cartItems.indexWhere((e) => e.productId == p.id);

    setState(() {
      if (index == -1) {
        cartItems.add(
          CartItemModel(
            productId: p.id,
            productName: p.name,
            productPrice: double.tryParse(p.price ?? '') ?? 0.0,
            productQty: 1,
            isHalf: 0,
            productNote: '',
          ),
        );
      } else {
        cartItems[index] = cartItems[index].copyWith(qty: cartItems[index].productQty + 1);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${p.name} added to cart"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void updateQty(CartItemModel item, int change) {
    final index = cartItems.indexWhere((e) => e.productId == item.productId);

    setState(() {
      final newQty = cartItems[index].productQty + change;
      if (newQty <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems[index] = cartItems[index].copyWith(qty: newQty);
      }
    });
  }

  void updateNote(CartItemModel item, String note) {
    final index = cartItems.indexWhere((e) => e.productId == item.productId);

    setState(() {
      cartItems[index] = cartItems[index].copyWith(note: note, qty: null);
    });
  }

  void generateBill() {
    Get.to(
          () => PaymentScreen(
        tableId: widget.tableId ?? '',
        cartItems: cartItems,
      ),
    );
  }

  Future<void> placeOrder() async {
    for (final item in cartItems) {
      await RealtimeDbHelper.instance.insertOrUpdateCartItem(
        tableId: widget.tableId ?? '',
        item: item,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully")),
    );
  }
}