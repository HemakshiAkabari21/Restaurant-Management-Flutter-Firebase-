import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';
import 'package:restaurant_management_fierbase/screens/home_screen/home_controller.dart';
import 'package:restaurant_management_fierbase/utils/const_images_key.dart';
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
      backgroundColor: AppColors.black,
      appBar: CustomAppBar(
        isLeading: false,
        backgroundColor: AppColors.black,
        statusColor: AppColors.black,
        title: Text('Dashboard', style: StyleHelper.customStyle(color: AppColors.white, size: 10.sp, family: semiBold)),
        actions: [GestureDetector(onTap: () {showTableCreateDialog(context);}, child: Icon(Icons.add, size: 14.sp, color: AppColors.white).paddingSymmetric(horizontal: 16.w))],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                buildItem(icon: AppImages.homeIcon, name: 'home'.tr,),
                buildItem(icon: AppImages.profileIcon, name: 'profile'.tr,),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              color: AppColors.white,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<DatabaseEvent>(
                      stream: RealtimeDbHelper.instance.listenToData('restaurant_tables'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                          return Center(child: Text('No tables created yet'));
                        }

                        final raw = snapshot.data!.snapshot.value;

                        if (raw is! Map) {
                          return Center(child: Text('Invalid table data'));
                        }

                        final map = Map<String, dynamic>.from(raw);

                        final tables = map.entries
                            .where((e) => e.value is Map) // <-- filter out anything that is not a Map
                            .map((e) => RestaurantTableModel.fromMap(
                          e.key,
                          Map<String, dynamic>.from(e.value as Map),
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
            ),
          ),
        ],
      ),
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
              child: Text('Cancel', style: StyleHelper.customStyle(color: AppColors.black, size: 8.sp, family: medium)),
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
                child: Text('Create', style: StyleHelper.customStyle(color: AppColors.white, size: 8.sp, family: medium)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildItem({required String icon,required String name,}){
    return GestureDetector(
      onTap: (){
        homeController.selectedTab.value = name;
      },
      child: Obx(()=> Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: homeController.selectedTab.value == name?AppColors.white:AppColors.black
        ),
        child: Column(
          children: [
            Image.asset(icon,height: 16.h,width: 16.w,color:  homeController.selectedTab.value == name ? AppColors.black : AppColors.lightGray,fit: BoxFit.contain),
            Text(name,style: StyleHelper.customStyle(color:  homeController.selectedTab.value == name ? AppColors.black : AppColors.lightGray,size: 4.sp,family: medium)),
          ],
        ),
      ),
      ),
    );
  }
}
