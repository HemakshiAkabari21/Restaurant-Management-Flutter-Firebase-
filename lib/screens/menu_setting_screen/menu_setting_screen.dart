import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/widgets/expandable_Selection.dart';
import 'menu_setting_controller.dart';

class MenuSettingScreen extends StatelessWidget {
  final void Function(int index) onTabChange;
  const MenuSettingScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MenuSettingController());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Important: allows proper keyboard handling
      body: Row(
        children: [
          _buildLeftOptions(controller),
          _buildCenterGrid(controller),
          _buildRightForm(controller),
        ],
      ),
    );
  }

  Widget _buildLeftOptions(MenuSettingController controller) {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.shade50),
        child: Column(
          children: [
            Container(
              width: Get.width,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  Text('MENU SETTINGS', style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold)),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
            Expanded( // Wrap the menu items in Expanded
              child: ListView( // Use ListView instead of Column for scrollability
                children: MenuSettingType.values.map((type) {
                  return Obx(() {
                    final isSelected = controller.selectedType.value == type;
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFF1a2847) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.black.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          type.name.toUpperCase(),
                          style: StyleHelper.customStyle(
                            color: isSelected ? AppColors.white : AppColors.black,
                            size: 4.sp,
                            family: isSelected ? semiBold : regular,
                          ),
                        ),
                        onTap: () => controller.changeMenuType(type),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterGrid(MenuSettingController controller) {
    return Expanded(
      flex: 7,
      child: Column(
        children: [
          Container(
            width: Get.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Text('MENU ITEMS', style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold), textAlign: TextAlign.start),
                SizedBox(height: 30.h),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              switch (controller.selectedType.value) {
                case MenuSettingType.master:
                  return _buildMasterGrid(controller);
                case MenuSettingType.category:
                  return buildCategoryGrid(controller);
                case MenuSettingType.product:
                  return buildProductGrid(controller);
              }
            }).paddingSymmetric(horizontal: 2.w),
          ),
        ],
      ),
    );
  }

  Widget _buildRightForm(MenuSettingController controller) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Obx(() {
          switch (controller.selectedType.value) {
            case MenuSettingType.master:
              return buildMasterForm(controller);
            case MenuSettingType.category:
              return buildCategoryForm(controller);
            case MenuSettingType.product:
              return buildProductForm(controller);
          }
        }),
      ),
    );
  }

  // MASTER GRID
  Widget _buildMasterGrid(MenuSettingController controller) {
    return FutureBuilder<List<MasterCategoryModel>>(
      future: RealtimeDbHelper.instance.getMasterCategories(),
      builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        if (snap.data!.isEmpty) return const Center(child: Text("No master categories yet"));

        return GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: snap.data!.map((m) {
            return Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                  ),
                ),
                child: InkWell(
                  onTap: () => controller.selectMasterCategory(m),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                          child: m.image.isNotEmpty
                              ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(m.image, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))
                              : const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(m.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: StyleHelper.customStyle(size: 6.sp, color: AppColors.white, family: medium)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // CATEGORY GRID
  Widget buildCategoryGrid(MenuSettingController controller) {
    return FutureBuilder<List<CategoryModel>>(
      future: RealtimeDbHelper.instance.getCategories(),
      builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        if (snap.data!.isEmpty) return const Center(child: Text("No categories yet"));

        return GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: snap.data!.map((c) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                  ),
                ),
                child: InkWell(
                  onTap: () => controller.selectCategory(c),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
                          child: c.image.isNotEmpty
                              ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(c.image, fit: BoxFit.cover, width: double.infinity,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)))
                              : const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(c.name,textAlign: TextAlign.center,   maxLines: null,   overflow: TextOverflow.ellipsis, style: StyleHelper.customStyle(size: 4.sp, color: AppColors.white, family: medium),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // PRODUCT GRID
  Widget buildProductGrid(MenuSettingController controller) {
    return Obx(() {
      return FutureBuilder<List<ProductModel>>(
        future: controller.selectedCategory.value != null
            ? RealtimeDbHelper.instance.getProductsByCategory(controller.selectedCategory.value!.id)
            : controller.getAllProducts(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (snap.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.selectedCategory.value != null ? "No products in this category" : "No products yet"),
                  const SizedBox(height: 8),
                  const Text("Select a category from the Category tab first", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          }

          return GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: snap.data!.map((p) => buildProductCard(p, controller)).toList(),
          );
        },
      );
    });
  }

  Widget buildProductCard(ProductModel product, MenuSettingController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.selectProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
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
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: product.image != null && product.image!.isNotEmpty
                      ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(product.image, fit: BoxFit.cover, width: double.infinity,
                          errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 50, color: Colors.grey)))
                      : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: StyleHelper.customStyle(size: 4.sp, family: medium, color: AppColors.white),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₹${product.price}", style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ).paddingOnly(top: 4.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MASTER FORM
  Widget buildMasterForm(MenuSettingController controller) {
    return Obx(() => Column(
      children: [
        // Header - Fixed
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.selectedMaster.value != null ? "EDIT M. CATEGORY" : "ADD M. CATEGORY",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold),
                ).paddingSymmetric(vertical: 25.h),
              ),
              if (controller.selectedMaster.value != null)
                GestureDetector(
                  onTap: () => controller.resetForm(),
                  child: Icon(Icons.close, size: 6.sp, color: AppColors.white).paddingOnly(right: 6.w),
                ),
            ],
          ).paddingSymmetric(horizontal: 6.w),
        ),

        // Scrollable Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller.nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                if (controller.uploadedImageUrl.value != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(controller.uploadedImageUrl.value!,
                        height: 120.h, width: double.infinity, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 12.h),
                ],
                OutlinedButton.icon(
                  onPressed: controller.pickAndUploadImage,
                  icon: Icon(Icons.image),
                  label: Text("Pick Image"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Button - Fixed at bottom
        SafeArea(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveMasterCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2d4875),
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: controller.isSaving.value
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text(controller.selectedMaster.value != null ? "Update M. Category" : "Save M. Category",
                style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold)),
          ).paddingSymmetric(horizontal: 6.w, vertical: 6.h)),
        ),
      ],
    ));
  }

  // CATEGORY FORM
  Widget buildCategoryForm(MenuSettingController controller) {
    return Obx(() => Column(
      children: [
        // Header - Fixed
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.selectedCategory.value != null ? "EDIT CATEGORY" : "ADD CATEGORY",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold),
                ).paddingSymmetric(vertical: 25.h),
              ),
              if (controller.selectedCategory.value != null)
                GestureDetector(
                  onTap: () => controller.resetForm(),
                  child: Icon(Icons.close, size: 6.sp, color: AppColors.white).paddingOnly(right: 6.w),
                ),
            ],
          ).paddingSymmetric(horizontal: 6.w),
        ),

        // Scrollable Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<MasterCategoryModel>>(
                  future: RealtimeDbHelper.instance.getMasterCategories(),
                  builder: (_, snap) {
                    if (!snap.hasData) return const SizedBox();
                    return Obx(() => ExpandableSelection<MasterCategoryModel>(
                      items: snap.data!,
                      selectedItem: controller.selectedMasterForCategory.value,
                      isMultiple: false,
                      displayString: (m) => m.name,
                      onSelectedSingle: (m) => controller.selectedMasterForCategory.value = m,
                      hintText: "Select Master Category",
                      labelText: "Master Category",
                    ));
                  },
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: controller.nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                if (controller.uploadedImageUrl.value != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(controller.uploadedImageUrl.value!,
                        height: 120.h, width: double.infinity, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 12.h),
                ],
                OutlinedButton.icon(
                  onPressed: controller.pickAndUploadImage,
                  icon: Icon(Icons.image),
                  label: Text("Pick Image"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Button - Fixed at bottom
        SafeArea(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveCategory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2d4875),
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: controller.isSaving.value
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text(controller.selectedCategory.value != null ? "Update Category" : "Save Category",
                style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold)),
          ).paddingSymmetric(horizontal: 6.w, vertical: 6.h)),
        ),
      ],
    ));
  }

  // PRODUCT FORM
  Widget buildProductForm(MenuSettingController controller) {
    return Obx(() => Column(
      children: [
        // Header - Fixed
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847)],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.selectedProduct.value != null ? "EDIT PRODUCT" : "ADD PRODUCT",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold),
                ).paddingSymmetric(vertical: 25.h),
              ),
              if (controller.selectedProduct.value != null)
                GestureDetector(
                  onTap: () => controller.resetForm(),
                  child: Icon(Icons.close, size: 6.sp, color: AppColors.white).paddingOnly(right: 6.w),
                ),
            ],
          ).paddingSymmetric(horizontal: 6.w),
        ),

        // Scrollable Form Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<CategoryModel>>(
                  future: RealtimeDbHelper.instance.getCategories(),
                  builder: (_, snap) {
                    if (!snap.hasData) return const SizedBox();
                    return Obx(() => ExpandableSelection<CategoryModel>(
                      items: snap.data!,
                      selectedItem: controller.selectedCategoryForProduct.value,
                      isMultiple: false,
                      displayString: (c) => c.name,
                      onSelectedSingle: (c) => controller.selectedCategoryForProduct.value = c,
                      hintText: "Select Category",
                      labelText: "Category",
                    ));
                  },
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: controller.nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: controller.priceCtrl,
                  decoration: InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
                if (controller.uploadedImageUrl.value != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(controller.uploadedImageUrl.value!,
                        height: 120.h, width: double.infinity, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 12.h),
                ],
                OutlinedButton.icon(
                  onPressed: controller.pickAndUploadImage,
                  icon: Icon(Icons.image),
                  label: Text("Pick Image"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Button - Fixed at bottom
        SafeArea(
          child: Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value ? null : controller.saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2d4875),
              minimumSize: Size(double.infinity, 52.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: controller.isSaving.value
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Text(controller.selectedProduct.value != null ? "Update Product" : "Save Product",
                style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold)),
          ).paddingSymmetric(horizontal: 6.w, vertical: 6.h)),
        ),
      ],
    ));
  }
}