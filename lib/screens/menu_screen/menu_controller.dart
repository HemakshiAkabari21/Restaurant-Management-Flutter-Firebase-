import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';

class MenuScreenController extends GetxController {
  // ================= FETCH =================

  Future<List<MasterCategoryModel>> getMasters() {
    return RealtimeDbHelper.instance.getMasterCategories();
  }

  Future<List<CategoryModel>> getCategories(String masterId) {
    return RealtimeDbHelper.instance.getCategoriesByMaster(masterId);
  }

  Future<List<ProductModel>> getProducts(String categoryId) {
    return RealtimeDbHelper.instance.getProductsByCategory(categoryId);
  }

  Future<List<CartItemModel>> getCart(String tableId) {
    return RealtimeDbHelper.instance.getTableCartList(tableId);
  }

  // ================= SELECTION LOGIC =================

  Future<CategoryModel?> selectMasterAndGetFirstCategory(
      MasterCategoryModel master,
      ) async {
    final categories = await getCategories(master.id);
    if (categories.isNotEmpty) {
      return categories.first;
    }
    return null;
  }

  // ================= CART LOGIC =================

  void addToCart({
    required List<CartItemModel> cartItems,
    required ProductModel product,
  }) {
    final index =
    cartItems.indexWhere((e) => e.productId == product.id);

    if (index == -1) {
      cartItems.add(
        CartItemModel(
          productId: product.id,
          productName: product.name,
          productPrice:
          double.tryParse(product.price ?? '') ?? 0,
          productQty: 1,
          isHalf: 0,
          productNote: '',
        ),
      );
    } else {
      cartItems[index] = cartItems[index].copyWith(
        qty: cartItems[index].productQty + 1,
      );
    }
  }

  void updateQty({
    required List<CartItemModel> cartItems,
    required CartItemModel item,
    required int change,
  }) {
    final index =
    cartItems.indexWhere((e) => e.productId == item.productId);

    final newQty = cartItems[index].productQty + change;

    if (newQty <= 0) {
      cartItems.removeAt(index);
    } else {
      cartItems[index] =
          cartItems[index].copyWith(qty: newQty);
    }
  }

  void updateNote({
    required List<CartItemModel> cartItems,
    required CartItemModel item,
    required String note,
  }) {
    final index =
    cartItems.indexWhere((e) => e.productId == item.productId);

    cartItems[index] =
        cartItems[index].copyWith(note: note, qty: null);
  }

  double calculateTotal(List<CartItemModel> cartItems) {
    return cartItems.fold(
      0,
          (sum, item) =>
      sum + (item.productPrice ?? 0) * item.productQty,
    );
  }

  // ================= ORDER =================

  Future<void> placeOrder({
    required String tableId,
    required List<CartItemModel> cartItems,
  }) async {
    for (final item in cartItems) {
      await RealtimeDbHelper.instance.insertOrUpdateCartItem(
        tableId: tableId,
        item: item,
      );
    }
  }
}
