import 'package:firebase_database/firebase_database.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/model/user_detail_model.dart';

import '../model/master_category_model.dart';

class RealtimeDbHelper {
  RealtimeDbHelper._();

  /// https://restaurant-management-6ae21-default-rtdb.firebaseio.com/ url of my db.
  static final RealtimeDbHelper instance = RealtimeDbHelper._();

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Reference shortcut
  DatabaseReference ref(String path) {
    return _database.ref(path);
  }

  /// -----------------------------
  /// CREATE / UPDATE DATA
  /// -----------------------------

  /// Set data (overwrites existing data)
  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await ref(path).set(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update data (updates only given fields)
  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await ref(path).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Push data (auto-generated ID)
  Future<String?> pushData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      final newRef = ref(path).push();
      await newRef.set(data);
      return newRef.key;
    } catch (e) {
      rethrow;
    }
  }

  /// -----------------------------
  /// READ DATA (ONCE)
  /// -----------------------------

  Future<DataSnapshot> getDataOnce(String path) async {
    try {
      final snapshot = await ref(path).get();
      return snapshot;
    } catch (e) {
      rethrow;
    }
  }

  /// -----------------------------
  /// READ DATA (STREAM)
  /// -----------------------------

  Stream<DatabaseEvent> listenToData(String path) {
    return ref(path).onValue;
  }

  /// -----------------------------
  /// DELETE DATA
  /// -----------------------------

  Future<void> deleteData(String path) async {
    try {
      await ref(path).remove();
    } catch (e) {
      rethrow;
    }
  }

  /// -----------------------------
  /// CHECK IF NODE EXISTS
  /// -----------------------------

  Future<bool> isNodeExists(String path) async {
    final snapshot = await ref(path).get();
    return snapshot.exists;
  }

  /// -----------------------------
  /// Find user by email
  /// -----------------------------

  Future<UserDetail?> getUserByEmail(String email) async {
    final snapshot = await ref('users').get();

    if (!snapshot.exists) return null;

    final value = snapshot.value;

    if (value is! Map<dynamic, dynamic>) return null;

    final emailLower = email.trim().toLowerCase();

    for (final entry in value.entries) {
      final userValue = entry.value;

      if (userValue is Map<dynamic, dynamic>) {
        final userEmail = (userValue['email'] ?? '').toString().trim().toLowerCase();

        if (userEmail == emailLower) {
          return UserDetail.fromMap(entry.key.toString(), userValue);
        }
      }
    }

    return null;
  }

  Future<List<MasterCategoryModel>> getMasterCategories() async {
    final snap = await ref('master_categories').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries
        .map((e) => MasterCategoryModel.fromMap(e.key, e.value))
        .toList();
  }

  Future<List<CategoryModel>> getCategoriesByMaster(String masterId) async {
    final snap = await ref('categories').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;

    return map.entries
        .where((e) => e.value['master_id'] == masterId)
        .map((e) => CategoryModel.fromMap(e.key, e.value))
        .toList();
  }

  Future<String?> insertCategory(CategoryModel model) {
    return pushData(path: 'categories', data: model.toMap());
  }

  Future<List<CategoryModel>> getCategories() async {
    final snap = await ref('categories').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries
        .map((e) => CategoryModel.fromMap(e.key, e.value))
        .toList();
  }

  Future<void> insertBunchCategory(List<Map<String, dynamic>> categories) async {
    for (final cat in categories) {
      await pushData(
        path: 'categories',
        data: {
          'category_name': cat['cat_name'],
          'category_status': 1,
        },
      );
    }
  }

  Future<String?> insertProduct(ProductModel model) {
    return pushData(path: 'products', data: model.toMap());
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final snap = await ref('products').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;

    return map.entries
        .where((e) => e.value['category_id'] == categoryId)
        .map((e) => ProductModel.fromMap(e.key, e.value))
        .toList();
  }


  Future<void> insertOrUpdateCartItem({
    required String tableId,
    required CartItemModel item,
  }) async {
    final path = 'carts/$tableId/${item.productId}';
    await ref(path).set(item.toMap());
  }

  Future<List<CartItemModel>> getTableCartList(String tableId) async {
    final snap = await ref('carts/$tableId').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.values.map((e) => CartItemModel.fromMap(e)).toList();
  }

  Future<int> getCartQty(String tableId, String productId) async {
    final snap = await ref('carts/$tableId/$productId').get();

    if (!snap.exists || snap.value == null) return 0;

    final data = snap.value as Map<dynamic, dynamic>;

    return (data['product_qty'] as int?) ?? 0;
  }


  Future<void> deleteCartItem(String tableId, String productId) {
    return ref('carts/$tableId/$productId').remove();
  }

  Future<bool> checkCart(String tableId) async {
    final snap = await ref('carts/$tableId').get();
    return snap.exists;
  }

  Future<String?> createOrder({
    required String orderTotal,
    required String customerName,
    required String customerMobile,
    required int isGst,
    required String orderJson,
  }) {
    return pushData(
      path: 'orders',
      data: {
        'order_total': orderTotal,
        'customer_name': customerName,
        'customer_mobile': customerMobile,
        'is_gst': isGst,
        'order_date': DateTime.now().toIso8601String(),
        'order_json': orderJson,
      },
    );
  }




}

/*final userId = await RealtimeDbHelper.instance.pushData(
  path: 'users',
  data: {
    'name': 'Hemaxi',
    'email': 'hemaxi@gmail.com',
    'createdAt': DateTime.now().millisecondsSinceEpoch,
  },
);

print("User ID: $userId");

*/

/*final tableId = await RealtimeDbHelper.instance.pushData(
  path: 'restaurant_table',
  data: {
    'tableNo': 1,
    'capacity': 4,
    'status': 'available',
  },
);

print("Table ID: $tableId");
*/
/*final category = CategoryModel(
  id: '',
  masterId: masterId,
  name: 'Juice',
  status: 1,
);

await RealtimeDbHelper.instance.pushData(
  path: 'categories',
  data: category.toMap(),
);
*/
/*final product = ProductModel(
  id: '',
  categoryId: categoryId,
  name: 'Apple Juice',
  price: '80',
  status: 1,
);

await RealtimeDbHelper.instance.pushData(
  path: 'products',
  data: product.toMap(),
);
*/