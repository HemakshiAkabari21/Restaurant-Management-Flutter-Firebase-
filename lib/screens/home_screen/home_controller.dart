import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';

class HomeController extends GetxController {

  RxString selectedTab = "home".obs;

  Future<void> createRestaurantTables(int count) async {
    debugPrint("Last Table NO:::::::::${getLastTableNumber()}");
    final lastTableNo = await getLastTableNumber();

    for (int i = 1; i <= count; i++) {
      final newTableNo = lastTableNo + i;

      final model = RestaurantTableModel(
        id: '',
        tableNo: (lastTableNo + i).toString(),
        capacityPeople: 4,
        status: 'available',
      );

      await RealtimeDbHelper.instance.pushData(
        path: 'restaurant_tables',
        data: model.toMap(),
      );
    }
  }

  Future<int> getLastTableNumber() async {
    final snapshot = await RealtimeDbHelper.instance.ref('restaurant_tables').orderByChild('table_no').limitToLast(1).get();

    if (!snapshot.exists || snapshot.value == null) return 0;

    final map = snapshot.value as Map<dynamic, dynamic>;
    final last = map.values.first;

    if (last is! Map) return 0;

    return int.tryParse(last['table_no'].toString()) ?? 0;
  }

  Future<List<RestaurantTableModel>> getTablesOnce() async {
    final snapshot = await RealtimeDbHelper.instance.ref('restaurant_tables').orderByChild('table_no').get();
    debugPrint("Snapshot:::::::::: $snapshot");
    if (!snapshot.exists || snapshot.value == null) return [];

    final map = snapshot.value as Map<dynamic, dynamic>;

    return map.entries
        .where((e) => e.value is Map)
        .map((e) => RestaurantTableModel.fromMap(
      e.key.toString(),
      Map<String, dynamic>.from(e.value),
    ))
        .toList();
  }

  Future<void> updateTable(RestaurantTableModel table) async {
    await RealtimeDbHelper.instance.updateData(
      path: 'restaurant_tables/${table.id}',
      data: table.toMap(),
    );
  }



}