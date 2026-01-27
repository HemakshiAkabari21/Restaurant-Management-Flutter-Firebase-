import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';

class ManagerController extends GetxController{

  final db = RealtimeDbHelper.instance;

  // Search observables
  final isSearch = false.obs;
  final searchController = TextEditingController();
  final searchResults = <ProductModel>[].obs;
  RxString tableId = ''.obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ================= FETCH DATA =================

  Future<List<MasterCategoryModel>> getMasters() {return db.getMasterCategories();}

  Future<List<CategoryModel>> getCategories(String masterId) {return db.getCategoriesByMaster(masterId);}

  Future<List<ProductModel>> getProducts(String categoryId) {return db.getProductsByCategory(categoryId);}

  Future<List<CartItemModel>> getCart(String tableId) {return db.getTableCartList(tableId);}

  // ================= SELECTION LOGIC =================

  Future<CategoryModel?> selectMasterAndGetFirstCategory(MasterCategoryModel master) async {
    final categories = await getCategories(master.id);
    return categories.isNotEmpty ? categories.first : null;
  }

  // ================= CART OPERATIONS =================

  void addToCart({required List<CartItemModel> cartItems, required ProductModel product}) {
    final index = cartItems.indexWhere((e) => e.productId == product.id);

    if (index == -1) {
      cartItems.add(
        CartItemModel(productId: product.id, productName: product.name, productPrice: double.tryParse(product.price ?? '') ?? 0,
          productQty: 1, isHalf: 0, productNote: '',),);
    } else {
      cartItems[index] = cartItems[index].copyWith(
        qty: cartItems[index].productQty + 1,
      );
    }
  }

  void updateQty({required List<CartItemModel> cartItems, required CartItemModel item, required int change}) {
    final index = cartItems.indexWhere((e) => e.productId == item.productId);
    if (index == -1) return;

    final newQty = cartItems[index].productQty + change;

    if (newQty <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems[index] = cartItems[index].copyWith(qty: newQty);
    }
  }

  void updateNote({required List<CartItemModel> cartItems, required CartItemModel item, required String note,}) {
    final index = cartItems.indexWhere((e) => e.productId == item.productId);
    if (index == -1) return;
    cartItems[index] = cartItems[index].copyWith(note: note, qty: null);
  }

  void updateIsHalf({required List<CartItemModel> cartItems,required CartItemModel item, required int isHalf}){
    final index = cartItems.indexWhere((e)=>e.productId == item.productId);
    if(index == -1) return;
    cartItems[index] = cartItems[index].copyWith(isHalf: isHalf);
  }

  double calculateTotal(List<CartItemModel> cartItems) {
    return cartItems.fold(0, (sum, item) => sum + (item.productPrice ?? 0) * item.productQty,);
  }

  // ================= ORDER OPERATIONS =================

  Future<void> placeOrder({required String tableId, required List<CartItemModel> cartItems,}) async {
    for (final item in cartItems) {
      await db.insertOrUpdateCartItem(
        tableId: tableId,
        item: item,
      );
    }
  }

  Future<void> clearCart(String tableId) async {
    await db.deleteData('carts/$tableId');
  }

  Future<void> removeCartItem({required String tableId, required String productId,}) async {
    await db.deleteCartItem(tableId, productId);
  }

  Future<bool> hasCartItems(String tableId) async {
    return await db.checkCart(tableId);
  }

  // ================= SEARCH =================


  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      searchResults.value = [];
      return;
    }

    final snap = await db.ref('products').get();
    if (!snap.exists) {
      searchResults.value = [];
      return;
    }

    final map = snap.value as Map<dynamic, dynamic>;
    final allProducts = map.entries.map((e) => ProductModel.fromMap(e.key, e.value)).toList();

    final searchLower = query.toLowerCase();
    searchResults.value = allProducts.where((product) {
      return product.name.toLowerCase().contains(searchLower);
    }).toList();
  }

  void clearSearch() {
    searchController.clear();
    searchResults.value = [];
    isSearch.value = false;
  }

}