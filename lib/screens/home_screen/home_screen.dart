import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/restaurent_table.dart';
import 'package:restaurant_management_fierbase/screens/home_screen/home_controller.dart';
import 'package:restaurant_management_fierbase/screens/menu_screen/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index) onTabChange;
  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.white),
        child: Column(
          children: [
            /// Header
            buildHeader(),
      
            /// Table Grid
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: RealtimeDbHelper.instance.listenToData('restaurant_tables'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return Center(child: Text('No tables created yet', style: StyleHelper.customStyle(color: AppColors.black, size: 10.sp,),),);
                  }
                  final raw = snapshot.data!.snapshot.value;
                  if (raw is! Map) {
                    return Center(child: Text('Invalid table data', style: StyleHelper.customStyle(color: AppColors.black, size: 10.sp,),),);
                  }
                  final map = Map<String, dynamic>.from(raw);
                  final tables = map.entries.where((e) => e.value is Map).map((e) => RestaurantTableModel.fromMap(
                    e.key, Map<String, dynamic>.from(e.value as Map),))
                    .toList()
                    ..sort((a, b) => a.tableNo
                     .compareTo(b.tableNo));
      
                  return GridView.builder(
                    itemCount: tables.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 5.w,
                      childAspectRatio: 0.80,
                    ),
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return buildTableCard(table);
                    },
                  ).paddingSymmetric(horizontal: 8.w);
                },
              ),
            ),
            SizedBox(height: 10.h,)
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
          onTap: (){showTableCreateDialog(context);},
        child: Container(
          height: 50.h,
          width: 50.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [  BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, -4), blurRadius: 20, spreadRadius: 0,),],
            gradient:LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFff6b6b), Color(0xFFee5a6f)],
            )
          ),
          child: Icon(Icons.add,size: 14.sp,color: AppColors.white,),
        ) ,
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: EdgeInsets.only(left: 10.w, top: 20.h,bottom: 5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2d4875), Color(0xFF1a2847)]
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restaurant',
                style: StyleHelper.customStyle(
                  color: AppColors.white,
                  size: 10.sp,
                  family: semiBold,
                ),
              ).paddingOnly(bottom: 4.h),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Monday, 20 March, 2023',
                  style: StyleHelper.customStyle(
                    color: AppColors.white.withOpacity(0.8),
                    size: 7.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTableCard(RestaurantTableModel table) {
    final bool isAvailable = table.status == 'available';

    return GestureDetector(
      onTap: () {
        if (isAvailable) {
          editTableDialog(context, table);
        } else {
         Get.to(()=>MenuScreen(tableId: table.id));
        }
      },
      onLongPress: (){
        showTableDeleteDialog(context,table);
      },
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Main Card Container
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 30.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isAvailable
                      ? [Color(0xFF2d4875), Color(0xFF1a2847)]
                      : [Color(0xFFff6b6b), Color(0xFFee5a6f)],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isAvailable
                      ? Color(0xFF4a6fa5).withOpacity(0.5)
                      : Colors.red.shade300.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isAvailable ? Colors.blue : Colors.red)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isAvailable ? 'Free Table' : 'Occupied',
                    textAlign: TextAlign.center,
                    style: StyleHelper.customStyle(
                      color: AppColors.white,
                      size: 6.sp,
                      family: semiBold,
                    ),
                  ).paddingOnly(bottom: 4.h, top: 20.h),
                  Text(
                    isAvailable ? 'Waiting for God!' : 'In Use',
                    textAlign: TextAlign.center,
                    style: StyleHelper.customStyle(
                      color: AppColors.white.withOpacity(0.9),
                      size: 5.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Table Number Circle
            Positioned(
              top: 15.h,
              child: Container(
                width: 60.w,
                height: 60.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFffb3b3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 2),),],
                ),
                child: Text(
                  '${table.tableNo}',
                  style: StyleHelper.customStyle(
                    color: AppColors.black,
                    size: 10.sp,
                    family: semiBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void editTableDialog(BuildContext context, RestaurantTableModel table) {
    final capacityController = TextEditingController(text: table.capacityPeople.toString());

    String status = table.status;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('Edit Table ${table.tableNo}', style: StyleHelper.customStyle(color: AppColors.black, size: 8.sp, family: semiBold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ).paddingOnly(bottom: 16.h),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                items: ['available', 'booked'].map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.capitalizeFirst!),
                )).toList(),
                onChanged: (v) {
                  setState(() {status = v!;});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: StyleHelper.customStyle(color: Colors.grey, size: 6.sp,),),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = table.copyWith(capacityPeople: int.tryParse(capacityController.text) ?? table.capacityPeople, status: status);
                await homeController.updateTable(updated);
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2d4875), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
              child: Text('Save', style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp,),
              ),
            ),
          ],
        ),
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
              onPressed: () => Get.back(),
              child: Text('Cancel', style: StyleHelper.customStyle(color: Colors.grey, size: 6.sp),),
            ),
            ElevatedButton(
              onPressed: () {
                final count = int.tryParse(tableCountController.text);
                if (count != null && count > 0) {
                  homeController.createRestaurantTables(count);
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2d4875),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r),),
              ),
              child: Text('Create', style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp,),),
            ),
          ],
        );
      },
    );
  }

  void showTableDeleteDialog(BuildContext context,RestaurantTableModel table) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text('Delete Restaurant Table no:${table.tableNo}',textAlign: TextAlign.center,),
          content:Text('Are you sure you want to delete the table.',textAlign: TextAlign.center,),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel', style: StyleHelper.customStyle(color: Colors.grey, size: 6.sp,),),
            ),
            ElevatedButton(
              onPressed: () {
                RealtimeDbHelper.instance.deleteTable(table);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2d4875),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r),),
              ),
              child: Text('Delete', style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp,),),
            ),
          ],
        );
      },
    );
  }
}
