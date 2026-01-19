import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';

class HomeController extends GetxController {

  Future<void> createRestaurantTables(int count) async {
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
    final snapshot = await RealtimeDbHelper.instance
        .getDataOnce('restaurant_tables');

    if (!snapshot.exists || snapshot.value is! Map) return 0;

    final data = snapshot.value as Map<dynamic, dynamic>;

    int maxTableNo = 0;

    for (final value in data.values) {
      if (value is Map<dynamic, dynamic>) {
        final no = int.tryParse(value['table_no'].toString()) ?? 0;
        if (no > maxTableNo) maxTableNo = no;
      }
    }

    return maxTableNo;
  }

  Future<List<RestaurantTableModel>> getTablesOnce() async {
    final snapshot = await RealtimeDbHelper.instance
        .getDataOnce('restaurant_tables');

    if (!snapshot.exists || snapshot.value is! Map) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;

    return data.entries
        .map((e) => RestaurantTableModel.fromMap(
      e.key.toString(),
      e.value as Map<dynamic, dynamic>,
    ))
        .toList()
      ..sort((a, b) => int.parse(a.tableNo).compareTo(int.parse(b.tableNo)));
  }


  Future<void> updateTable(RestaurantTableModel table) async {
    await RealtimeDbHelper.instance.updateData(
      path: 'restaurant_tables/${table.id}',
      data: table.toMap(),
    );
  }



}