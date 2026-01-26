import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';
import 'package:restaurant_management_fierbase/model/user_detail_model.dart';

import '../model/master_category_model.dart';

class RealtimeDbHelper {
  RealtimeDbHelper._();

  /// https://restaurant-management-6ae21-default-rtdb.firebaseio.com/ url of my db.
  static final RealtimeDbHelper instance = RealtimeDbHelper._();

  final FirebaseDatabase database = FirebaseDatabase.instance;

  /// Reference shortcut
  DatabaseReference ref(String path) {
    return database.ref(path);
  }

  /// Update data (updates only given fields)
  Future<void> updateData({required String path, required Map<String, dynamic> data}) async {
    try {
      await ref(path).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Push data (auto-generated ID)
  Future<String?> pushData({required String path, required Map<String, dynamic> data}) async {
    try {
      final newRef = ref(path).push();
      await newRef.set(data);
      return newRef.key;
    } catch (e) {
      rethrow;
    }
  }

  /// READ DATA (ONCE)
  Future<DataSnapshot> getDataOnce(String path) async {
    try {
      final snapshot = await ref(path).get();
      return snapshot;
    } catch (e) {
      debugPrint("ERROR::::::$e");
      rethrow;
    }
  }

  /// READ DATA (STREAM)
  Stream<DatabaseEvent> listenToData(String path) {
    return ref(path).onValue;
  }

  /// DELETE DATA
  Future<void> deleteData(String path) async {
    try {
      await ref(path).remove();
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE TABLE
  Future<void> deleteTable(RestaurantTableModel table)async {
    if (table.id.isEmpty) {
      throw Exception("Table ID is empty. Cannot delete.");
    }try {
      return ref('restaurant_tables/${table.id}').remove();
    }catch (e){
      debugPrint("DELETE TABLE ::::::$e");
      rethrow;
    }

  }

  /// Find user by email
  Future<UserDetail?> getUserByEmail(String email) async {
    try {
      final emailLower = email.trim().toLowerCase();

      // Perform the query
      final snapshot = await ref('users').orderByChild('email').equalTo(emailLower).get();
      if (!snapshot.exists || snapshot.value == null) return null;
      // Snapshot.value for a query is ALWAYS a Map of { "id": { data } }
      // We use Map.from to avoid type-cast errors with dynamic maps
      final rawData = snapshot.value;
      if (rawData is Map) {
        final dataMap = Map<dynamic, dynamic>.from(rawData);
        if (dataMap.isNotEmpty) {
          final entry = dataMap.entries.first;
          return UserDetail.fromMap(entry.key.toString(), Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
      return null;
    } catch (e) {
      // This catches the 'String is not subtype of Map' error if the index is missing
      debugPrint('Firebase Query Error: $e');
      if (e.toString().contains('String')) {
        debugPrint('CRITICAL: Check your Firebase Database Rules for .indexOn: ["email"]');
      }
      return null;
    }
  }

  /// Find User Detail By UserId
  Future<UserDetail?> getUserDetailByUserId(String userId) async {
    debugPrint("Entering the Function");
    final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');
    debugPrint("UserRef::::::::::$userRef");
    final DataSnapshot snapshot = await userRef.get();
    debugPrint("Snapshot :::::::::::::: $snapshot");
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;

    return UserDetail.fromMap(userId, data);
  }

  Future<List<MasterCategoryModel>> getMasterCategories() async {
    final snap = await ref('master_categories').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries.map((e) => MasterCategoryModel.fromMap(e.key, e.value)).toList();
  }

  Future<List<CategoryModel>> getCategoriesByMaster(String masterId) async {
    try {
      final snap = await ref('categories').get();
      if (!snap.exists) return [];

      final map = snap.value as Map<dynamic, dynamic>;

      final result = map.entries.where((e) {

        final data = e.value as Map<dynamic, dynamic>;
        // Check for both possible field names for compatibility
        final categoryMasterId = data['masterId'] ?? data['master_id'];
        debugPrint('Checking category ${data['name']}: masterId=$categoryMasterId, looking for=$masterId');
        return categoryMasterId == masterId;
      }).map((e) => CategoryModel.fromMap(e.key, e.value)).toList();

      debugPrint('Found ${result.length} categories for master $masterId');
      return result;
    } catch (e) {
      debugPrint('Error in getCategoriesByMaster: $e');
      return [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final snap = await ref('categories').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries.map((e) => CategoryModel.fromMap(e.key, e.value)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final snap = await ref('products').get();
      if (!snap.exists) return [];

      final map = snap.value as Map<dynamic, dynamic>;

      final result = map.entries
          .where((e) {
        final data = e.value as Map<dynamic, dynamic>;
        // Check for both possible field names for compatibility
        final productCategoryId = data['categoryId'] ?? data['category_id'];
        debugPrint('Checking product ${data['name']}: categoryId=$productCategoryId, looking for=$categoryId');
        return productCategoryId == categoryId;
      })
          .map((e) => ProductModel.fromMap(e.key, e.value))
          .toList();

      debugPrint('Found ${result.length} products for category $categoryId');
      return result;
    } catch (e) {
      debugPrint('Error in getProductsByCategory: $e');
      return [];
    }
  }

  Future<void> insertOrUpdateCartItem({required String tableId, required CartItemModel item}) async {
    final path = 'carts/$tableId/${item.productId}';
    await ref(path).set(item.toMap());
  }

  Future<List<CartItemModel>> getTableCartList(String tableId) async {
    final snap = await ref('carts/$tableId').get();
    if (!snap.exists) return [];

    final rawMap = snap.value as Map<dynamic, dynamic>;

    return rawMap.values.map((e) {
      final itemMap = Map<String, dynamic>.from(e as Map);
      return CartItemModel.fromMap(itemMap);
    }).toList();
  }

  Future<void> deleteCartItem(String tableId, String productId) {
    return ref('carts/$tableId/$productId').remove();
  }

  Future<bool> checkCart(String tableId) async {
    final snap = await ref('carts/$tableId').get();
    return snap.exists;
  }

  Future<String?> createOrder({required String orderTotal, required String customerName, required String customerMobile, required int isGst, required String orderJson, required customerEmail,}) {
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