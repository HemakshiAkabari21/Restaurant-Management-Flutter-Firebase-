import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';
import 'package:restaurant_management_fierbase/screens/home_screen/home_controller.dart';
import 'package:restaurant_management_fierbase/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index) onTabChange;
  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        isLeading: false,
        backgroundColor: AppColors.black,
        statusColor: AppColors.black,
        title: Text('Dashboard', style: StyleHelper.customStyle(color: AppColors.white, size: 16.sp, family: semiBold)),
        actions: [GestureDetector(onTap: () {showTableCreateDialog(context);}, child: Icon(Icons.add, size: 24.sp, color: AppColors.white).paddingSymmetric(horizontal: 16.w))],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: RealtimeDbHelper.instance.listenToData('restaurant_tables'),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(child: Text('No tables created yet'));
                }

                final map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                final tables = map.entries
                    .map((e) => RestaurantTableModel.fromMap(
                  e.key,
                  e.value as Map<dynamic, dynamic>,
                ))
                    .toList()
                  ..sort((a, b) => int.parse(a.tableNo).compareTo(int.parse(b.tableNo)));

                return GridView.builder(
                  itemCount: tables.length,
                  gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing:8.w,
                    crossAxisSpacing: 8.h,
                  ),
                  itemBuilder: (context, index) {
                    final table = tables[index];

                    return GestureDetector(
                      onTap: () => editTableDialog(context, table),
                      child: Container(
                        decoration: BoxDecoration(
                          color: table.status == 'booked'
                              ? AppColors.errorColor
                              : AppColors.white,
                          border: Border.all(color: table.status == 'booked'?AppColors.errorColor :AppColors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Table ${table.tableNo}',style: StyleHelper.customStyle(color: table.status == 'booked' ? AppColors.white : AppColors.black,
                                family:  table.status == 'booked' ? semiBold : medium),),
                            Text('Capacity: ${table.capacityPeople}',style: StyleHelper.customStyle(color: table.status == 'booked' ? AppColors.white : AppColors.black,
                                family:  table.status == 'booked' ? semiBold : medium)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
     ).paddingSymmetric(horizontal: 16.w,vertical: 16.h),
    );
  }

  void editTableDialog(BuildContext context, RestaurantTableModel table) {
    final capacityController =
    TextEditingController(text: table.capacityPeople.toString());
    String status = table.status;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Table ${table.tableNo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: capacityController,
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: status,
              items: ['available', 'booked']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => status = v!,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final updated = table.copyWith(
                capacityPeople:
                int.tryParse(capacityController.text) ?? table.capacityPeople,
                status: status,
              );

              await homeController.updateTable(updated);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  void showTableCreateDialog(BuildContext context) {
    final TextEditingController tableCountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text('Create Restaurant Tables',textAlign: TextAlign.center,),
          content: TextField(
            controller: tableCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Number of tables', hintText: 'Enter number of tables'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: StyleHelper.customStyle(color: AppColors.black, size: 14.sp, family: medium)),
            ),
            TextButton(
              onPressed: () {
                final count = int.tryParse(tableCountController.text);
                if (count != null && count > 0) {
                  homeController.createRestaurantTables(count);
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12.r)),
                child: Text('Create', style: StyleHelper.customStyle(color: AppColors.white, size: 14.sp, family: medium)),
              ),
            ),
          ],
        );
      },
    );
  }
}
