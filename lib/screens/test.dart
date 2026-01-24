/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/repository/cloudinary_service.dart';
import 'package:restaurant_management_fierbase/widgets/expandable_Selection.dart';

enum MenuSettingType { master, category, product }

class MenuSettingScreen extends StatefulWidget {
  final void Function(int index) onTabChange;
  const MenuSettingScreen({super.key, required this.onTabChange});

  @override
  State<MenuSettingScreen> createState() => _MenuSettingScreenState();
}

class _MenuSettingScreenState extends State<MenuSettingScreen> {
  MenuSettingType selectedType = MenuSettingType.master;

  MasterCategoryModel? selectedMaster;
  CategoryModel? selectedCategory;
  ProductModel? selectedProduct;
  String? uploadedImageUrl;

  // Controllers for editing
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  MasterCategoryModel? selectedMasterForCategory;
  CategoryModel? selectedCategoryForProduct;

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File image = File(pickedFile.path);
    String? imageUrl = await CloudinaryService.uploadImage(image);
    setState(() {
      uploadedImageUrl = imageUrl ??
          "https://t4.ftcdn.net/jpg/06/57/37/01/360_F_657370150_pdNeG5pjI976ZasVbKN9VqH1rfoykdYU.jpg";
    });
  }

  void resetForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    uploadedImageUrl = null;
    selectedMaster = null;
    selectedCategory = null;
    selectedProduct = null;
    selectedMasterForCategory = null;
    selectedCategoryForProduct = null;
  }

  Future<List<ProductModel>> getAllProducts() async {
    final snap = await RealtimeDbHelper.instance.ref('products').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries
        .map((e) => ProductModel.fromMap(e.key, e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          buildLeftOptions(),
          buildCenterGrid(),
          buildRightForm(),
        ],
      ),
    );
  }

  Widget buildLeftOptions() {
    return Expanded(
      flex: 2,
      child: SizedBox(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
          ),
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
                    Text('MENU SETTINGS', style: StyleHelper.customStyle(color: AppColors.white,size: 6.sp, family: semiBold,),),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
              ...MenuSettingType.values.map((type) {
                final isSelected = selectedType == type;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF1a2847): Colors.transparent,
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
                        color: isSelected?AppColors.white : AppColors.black,
                        size: 4.sp,
                        family: isSelected ? semiBold : regular,
                      ),
                    ),
                    onTap: () => setState(() {
                      selectedType = type;
                      resetForm();
                    }),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCenterGrid() {
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
                Text('MENU ITEMS', style: StyleHelper.customStyle(color: AppColors.white,size: 6.sp, family: semiBold,),textAlign: TextAlign.start,),
                SizedBox(height: 30.h),
              ],
            ),
          ),
          Expanded(
            child: buildGridContent().paddingSymmetric(horizontal: 2.w),
          ),
        ],
      ),
    );
  }

  Widget buildRightForm() {
    return Expanded(
      flex: 3,
      child: SizedBox(
        //  width: 340,
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
          child: buildForm(),
        ),
      ),
    );
  }

  Widget buildGridContent() {
    switch (selectedType) {
      case MenuSettingType.master:
        return masterGrid();
      case MenuSettingType.category:
        return categoryGrid();
      case MenuSettingType.product:
        return productGrid();
    }
  }

  Widget masterGrid() {
    return FutureBuilder<List<MasterCategoryModel>>(
      future: RealtimeDbHelper.instance.getMasterCategories(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.data!.isEmpty) {
          return const Center(child: Text("No master categories yet"));
        }
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
                  onTap: () => setState(() {
                    selectedMaster = m;
                    nameCtrl.text = m.name;
                    uploadedImageUrl = m.image.isNotEmpty ? m.image : null;
                  }),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),),
                          child: m.image.isNotEmpty
                              ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),
                            child: Image.network(m.image, fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey,),),)
                              : const Icon(Icons.image, size: 50, color: Colors.grey,),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(m.name,   textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style:  StyleHelper.customStyle(size: 6.sp, color: AppColors.white,family: medium),
                          ),
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

  Widget categoryGrid() {
    return FutureBuilder<List<CategoryModel>>(
      future: RealtimeDbHelper.instance.getCategories(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.data!.isEmpty) {
          return const Center(child: Text("No categories yet"));
        }
        return GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: snap.data!.map((c) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                  onTap: () async {
                    // Get the master category for this category
                    final masters = await RealtimeDbHelper.instance.getMasterCategories();
                    final master = masters.firstWhereOrNull((m) => m.id == c.masterId);

                    setState(() {
                      selectedCategory = c;
                      nameCtrl.text = c.name;
                      uploadedImageUrl = c.image.isNotEmpty ? c.image : null;
                      selectedMasterForCategory = master;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),),
                          child: c.image.isNotEmpty
                              ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),
                            child: Image.network(c.image, fit: BoxFit.cover, width: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey,),),)
                              : const Icon(Icons.image, size: 50, color: Colors.grey,),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(c.name,textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style:  StyleHelper.customStyle(size: 6.sp, color: AppColors.white,family: medium),
                          ),
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

  Widget productGrid() {
    return FutureBuilder<List<ProductModel>>(
      future: selectedCategory != null
          ? RealtimeDbHelper.instance.getProductsByCategory(selectedCategory!.id)
          : getAllProducts(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(selectedCategory != null
                    ? "No products in this category"
                    : "No products yet"),
                const SizedBox(height: 8),
                const Text(
                  "Select a category from the Category tab first",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return GridView.count(
          crossAxisCount: 4,
          childAspectRatio:0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: snap.data!.map((p) {
            return buildProductCard(p);
            */
/*Card(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    // Get the category for this product
                    final categories = await RealtimeDbHelper.instance.getCategories();
                    final category = categories.firstWhereOrNull((c) => c.id == p.categoryId);

                    setState(() {
                      selectedProduct = p;
                      nameCtrl.text = p.name;
                      priceCtrl.text = p.price;
                      uploadedImageUrl = p.image.isNotEmpty ? p.image : null;
                      selectedCategoryForProduct = category;
                    });
                  },
                  child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("₹${p.price}", style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold,), textAlign: TextAlign.center,).paddingOnly(bottom: 4.h),
                    Text(p.name, maxLines: 2, softWrap: true, textAlign: TextAlign.center, overflow: TextOverflow.visible, style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold,),),
                  ],
                ),

                )
              ),
            );*//*

          }).toList(),
        );
      },
    );
  }

  Widget buildProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async{
          // Get the category for this product
          final categories = await RealtimeDbHelper.instance.getCategories();
          final category = categories.firstWhereOrNull((c) => c.id == product.categoryId);

          setState(() {
            selectedProduct = product;
            nameCtrl.text = product.name;
            priceCtrl.text = product.price;
            uploadedImageUrl = product.image.isNotEmpty ? product.image : null;
            selectedCategoryForProduct = category;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: */
/*isAvailable*//*

                */
/*?*//*
 [Color(0xFF2d4875), Color(0xFF1a2847)]
              // : [Color(0xFFff6b6b), Color(0xFFee5a6f)],
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: product.image != null && product.image!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.fastfood,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.fastfood,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style:  StyleHelper.customStyle(size: 4.sp, family: medium,color: AppColors.white), maxLines: 2, overflow: TextOverflow.ellipsis,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("₹${product.price}", style: TextStyle(fontSize: 4.sp, fontWeight: FontWeight.bold, color: Colors.white,),),
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

  Widget buildForm() {
    switch (selectedType) {
      case MenuSettingType.master:
        return buildMasterForm();
      case MenuSettingType.category:
        return buildCategoryForm();
      case MenuSettingType.product:
        return buildProductForm();
    }
  }

  Widget buildMasterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)]
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 30.h),
                    Text(selectedMaster != null ? "EDIT M. CATEGORY" : "ADD M. CATEGORY",
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold,),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
              if(selectedMaster != null)
                GestureDetector(onTap: () {resetForm();}, child: Icon(Icons.close, size: 6.sp,color: AppColors.white,),),
            ],
          ).paddingSymmetric(horizontal: 6.w,vertical: 5.h),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r),),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ).paddingOnly(bottom: 16.h),
                if (uploadedImageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(uploadedImageUrl!, height: 120.h, width: double.infinity, fit: BoxFit.cover),
                  ).paddingOnly(bottom: 12.h),
                ],
                OutlinedButton.icon(
                  onPressed: pickAndUploadImage,
                  icon: Icon(Icons.image),
                  label: Text("Pick Image"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 6.w,vertical: 6.h),
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: () async {
            if (nameCtrl.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a name")),
              );
              return;
            }

            if (selectedMaster != null) {
              await RealtimeDbHelper.instance.updateData(
                path: 'master_categories/${selectedMaster!.id}',
                data: {
                  'name': nameCtrl.text,
                  'image': uploadedImageUrl ?? "",
                },
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Master category updated!")),
              );
            } else {
              String? masterId = await RealtimeDbHelper.instance.pushData(
                path: 'master_categories',
                data: {
                  'name': nameCtrl.text,
                  'image': uploadedImageUrl ?? "",
                  'categoryIds': [],
                },
              );

              if (masterId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Master category saved!")),
                );
              }
            }
            resetForm();
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2d4875),
            minimumSize: Size(double.infinity, 52.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            selectedMaster != null ? "Update M. Category" : "Save M. Category",
            style: StyleHelper.customStyle(
              color: AppColors.white,
              size: 6.sp,
              family: semiBold,
            ),
          ),
        ).paddingSymmetric(horizontal: 6.w,vertical: 6.h),
      ],
    );
  }

  Widget buildCategoryForm() {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847), Color(0xFF1a2847)]
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text( selectedCategory != null ? "EDIT CATEGORY" : "ADD CATEGORY",
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold,),
                      ).paddingOnly(top: 30.h,bottom: 20.h),
                    ),
                    if(selectedMaster != null)
                      GestureDetector(onTap: () {resetForm();}, child: Icon(Icons.close, size: 6.sp,color: AppColors.white),),
                  ],
                ).paddingSymmetric(horizontal: 6.w,vertical: 5.h)
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<List<MasterCategoryModel>>(
                      future: RealtimeDbHelper.instance.getMasterCategories(),
                      builder: (_, snap) {
                        if (!snap.hasData) return const SizedBox();
                        return ExpandableSelection<MasterCategoryModel>(
                          items: snap.data!,
                          selectedItem: selectedMasterForCategory,
                          isMultiple: false,
                          displayString: (m) => m.name,
                          onSelectedSingle: (m) {
                            setStateLocal(() => selectedMasterForCategory = m);
                          },
                          hintText: "Select Master Category",
                          labelText: "Master Category",
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: "Category Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (uploadedImageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(uploadedImageUrl!, height: 120.h, width: double.infinity, fit: BoxFit.cover),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    OutlinedButton.icon(
                      onPressed: () async {
                        await pickAndUploadImage();
                        setStateLocal(() {});
                      },
                      icon: Icon(Icons.image),
                      label: Text("Pick Image"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 6.w,vertical: 6.h),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || selectedMasterForCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all required fields")),
                  );
                  return;
                }

                if (selectedCategory != null) {
                  await RealtimeDbHelper.instance.updateData(
                    path: 'categories/${selectedCategory!.id}',
                    data: {
                      'name': nameCtrl.text,
                      'image': uploadedImageUrl ?? "",
                      'masterId': selectedMasterForCategory!.id,
                    },
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Category updated!")),
                  );
                } else {
                  String? categoryId = await RealtimeDbHelper.instance.pushData(
                    path: 'categories',
                    data: {
                      'name': nameCtrl.text,
                      'image': uploadedImageUrl ?? "",
                      'masterId': selectedMasterForCategory!.id,
                      'productIds': [],
                    },
                  );

                  List<dynamic> masterCategoryIds = selectedMasterForCategory!.categoryIds ?? [];
                  masterCategoryIds.add(categoryId);
                  await RealtimeDbHelper.instance.updateData(
                    path: 'master_categories/${selectedMasterForCategory!.id}',
                    data: {'categoryIds': masterCategoryIds},
                  );

                  if (categoryId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Category saved!")),
                    );
                  }
                }
                resetForm();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2d4875),
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                selectedCategory != null ? "Update Category" : "Save Category",
                style: StyleHelper.customStyle(
                  color: AppColors.white,
                  size: 6.sp,
                  family: semiBold,
                ),
              ),
            ).paddingSymmetric(horizontal: 6.w,vertical: 8.h),
          ],
        );
      },
    );
  }

  Widget buildProductForm() {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2d4875), Color(0xFF1a2847), Color(0xFF1a2847)]
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 30.h),
                        Text( selectedProduct != null ? "EDIT PRODUCT" : "ADD PRODUCT",
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: StyleHelper.customStyle(color: AppColors.white, size: 6.sp, family: semiBold,),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                  if(selectedMaster != null)
                    GestureDetector(onTap: () {resetForm();}, child: Icon(Icons.close, size: 6.sp,color: AppColors.white),),
                ],
              ).paddingSymmetric(horizontal: 6.w,vertical: 5.h),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<List<CategoryModel>>(
                      future: RealtimeDbHelper.instance.getCategories(),
                      builder: (_, snap) {
                        if (!snap.hasData) return const SizedBox();
                        return ExpandableSelection<CategoryModel>(
                          items: snap.data!,
                          selectedItem: selectedCategoryForProduct,
                          isMultiple: false,
                          displayString: (c) => c.name,
                          onSelectedSingle: (c) {
                            setStateLocal(() => selectedCategoryForProduct = c);
                          },
                          hintText: "Select Category",
                          labelText: "Category",
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: "Product Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: priceCtrl,
                      decoration: InputDecoration(
                        labelText: "Price",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.h),
                    if (uploadedImageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(uploadedImageUrl!, height: 120.h, width: double.infinity, fit: BoxFit.cover),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    OutlinedButton.icon(
                      onPressed: () async {
                        await pickAndUploadImage();
                        setStateLocal(() {});
                      },
                      icon: Icon(Icons.image),
                      label: Text("Pick Image"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 6.w,vertical: 6.h),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || selectedCategoryForProduct == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all required fields")),
                  );
                  return;
                }

                if (selectedProduct != null) {
                  await RealtimeDbHelper.instance.updateData(
                    path: 'products/${selectedProduct!.id}',
                    data: {
                      'name': nameCtrl.text,
                      'image': uploadedImageUrl ?? "",
                      'price': priceCtrl.text,
                      'categoryId': selectedCategoryForProduct!.id,
                    },
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Product updated!")),
                  );
                } else {
                  String? productId = await RealtimeDbHelper.instance.pushData(
                    path: 'products',
                    data: {
                      'name': nameCtrl.text,
                      'image': uploadedImageUrl ?? "",
                      'price': priceCtrl.text,
                      'categoryId': selectedCategoryForProduct!.id,
                    },
                  );

                  List<dynamic> productIds = selectedCategoryForProduct!.productIds ?? [];
                  productIds.add(productId);
                  await RealtimeDbHelper.instance.updateData(
                    path: 'categories/${selectedCategoryForProduct!.id}',
                    data: {'productIds': productIds},
                  );

                  if (productId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Product saved!")),
                    );
                  }
                }
                resetForm();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2d4875),
                minimumSize: Size(double.infinity, 52.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                selectedProduct != null ? "Update Product" : "Save Product",
                style: StyleHelper.customStyle(
                  color: AppColors.white,
                  size: 6.sp,
                  family: semiBold,
                ),
              ),
            ).paddingSymmetric(horizontal: 6.w,vertical: 6.h),
          ],
        );
      },
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_management_fierbase/apptheme/app_colors.dart';
import 'package:restaurant_management_fierbase/apptheme/stylehelper.dart';
import 'package:restaurant_management_fierbase/model/cart_item_model.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/screens/menu_screen/menu_controller.dart';
import 'package:restaurant_management_fierbase/screens/paymnet_succesfull_Screen/payment_successfull_Screen.dart';

enum MenuLevel { master, category, product }

class MenuScreen extends StatefulWidget {
  final String? tableId;
  const MenuScreen({super.key, this.tableId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  MenuLevel currentLevel = MenuLevel.master;
  MasterCategoryModel? selectedMaster;
  CategoryModel? selectedCategory;
  List<CartItemModel> cartItems = [];
  String? expandedMasterId;
  List<MasterCategoryModel> leftMasters = [];

  AnimationController? _animationController;
  Animation<double>? _searchAnimation;

  MenuScreenController controller = Get.put(MenuScreenController());

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _searchAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );

    loadLeftMasters();
    loadCart();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> loadLeftMasters() async {
    leftMasters = await controller.getMasters();
    if (mounted) setState(() {});
  }

  Future<void> loadCart() async {
    cartItems = await controller.getCart(widget.tableId ?? '');
    debugPrint("TABLE ${widget.tableId} CART COUNT: ${cartItems.length}");
    if (mounted) setState(() {});
  }

  void toggleSearch() {
    if (controller.isSearch.value) {
      _animationController?.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        controller.clearSearch();
      });
    } else {
      controller.isSearch.value = true;
      _animationController?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            buildLeftPanel(),
            buildCenterPanel(),
            buildCartPanel(),
          ],
        ),
      ),
    );
  }

  /// LEFT PANEL
  Widget buildLeftPanel() {
    return Expanded(
      flex: 2,
      child: Container(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: Get.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                ),
              ),
              child: const Text(
                "Categories",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: leftMasters.length,
                itemBuilder: (_, i) {
                  final master = leftMasters[i];
                  final isExpanded = expandedMasterId == master.id;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          master.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onTap: () async {
                          setState(() {
                            expandedMasterId = isExpanded ? null : master.id;
                            selectedMaster = master;
                            selectedCategory = null;
                            currentLevel = MenuLevel.product;
                          });

                          if (!isExpanded) {
                            final categories = await controller.getCategories(master.id);
                            if (categories.isNotEmpty && mounted) {
                              setState(() {
                                selectedCategory = categories.first;
                              });
                            }
                          }
                        },
                      ),
                      if (isExpanded)
                        FutureBuilder<List<CategoryModel>>(
                          future: controller.getCategories(master.id),
                          builder: (_, snap) {
                            if (!snap.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Column(
                              children: snap.data!
                                  .map(
                                    (cat) => SizedBox(
                                  height: 150,
                                  child: buildGridCard(
                                    title: cat.name,
                                    imageUrl: cat.image,
                                    onTap: () {
                                      setState(() {
                                        selectedCategory = cat;
                                        currentLevel = MenuLevel.product;
                                      });
                                    },
                                  ),
                                ),
                              )
                                  .toList(),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CENTER PANEL
  Widget buildCenterPanel() {
    return Expanded(
      flex: 5,
      child: Container(
        color: AppColors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title section
                  Obx(() {
                    if (controller.isSearch.value) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      children: [
                        Icon(
                          currentLevel == MenuLevel.master
                              ? Icons.restaurant_menu
                              : currentLevel == MenuLevel.category
                              ? Icons.category
                              : Icons.fastfood,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          currentLevel == MenuLevel.master
                              ? "Select Master Category"
                              : currentLevel == MenuLevel.category
                              ? "Select Category"
                              : "Select Products",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                  const Spacer(),
                  // Animated Search Bar
                  Obx(() {
                    if (!controller.isSearch.value) {
                      return const SizedBox.shrink();
                    }
                    return SizeTransition(
                      sizeFactor: _searchAnimation ?? AlwaysStoppedAnimation(1),
                      axis: Axis.horizontal,
                      axisAlignment: -1,
                      child: Container(
                        width: 300,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gray),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.search,
                                size: 20,
                                color: AppColors.black,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: controller.searchController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search Product",
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (query) async {
                                  await controller.searchProducts(query);
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: AppColors.black,
                              ),
                              onPressed: toggleSearch,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Search Icon Button
                  Obx(() {
                    if (controller.isSearch.value) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      onPressed: toggleSearch,
                      icon: Icon(
                        Icons.search,
                        size: 24,
                        color: AppColors.white,
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  if (controller.isSearch.value) {
                    return buildSearchProductGrid();
                  }
                  return buildGridContent();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridContent() {
    if (selectedCategory != null) {
      return buildProductGrid();
    }
    return buildMasterGrid();
  }

  Widget buildMasterGrid() {
    return FutureBuilder<List<MasterCategoryModel>>(
      future: controller.getMasters(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (_, index) {
            final master = snap.data![index];
            return buildGridCard(
              title: master.name,
              imageUrl: master.image,
              onTap: () async {
                setState(() {
                  selectedMaster = master;
                  expandedMasterId = master.id;
                  selectedCategory = null;
                  currentLevel = MenuLevel.product;
                });

                final categories = await controller.getCategories(master.id);
                if (categories.isNotEmpty && mounted) {
                  setState(() {
                    selectedCategory = categories.first;
                  });
                }
              },
            );
          },
        );
      },
    );
  }

  Widget buildProductGrid() {
    if (selectedCategory == null) {
      return const Center(child: Text("No category selected"));
    }

    return FutureBuilder<List<ProductModel>>(
      future: controller.getProducts(selectedCategory!.id),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.data!.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: snap.data!.length,
          itemBuilder: (_, index) {
            return buildProductCard(snap.data![index]);
          },
        );
      },
    );
  }

  Widget buildSearchProductGrid() {
    if (controller.searchController.text.trim().isEmpty) {
      return const Center(
        child: Text(
          "Type to search products",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return const Center(
          child: Text(
            "No products found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: controller.searchResults.length,
        itemBuilder: (_, index) {
          return buildProductCard(controller.searchResults[index]);
        },
      );
    });
  }

  /// Product card with price
  Widget buildProductCard(ProductModel product) {
    int productQty = cartItems
        .firstWhere(
          (e) => e.productId == product.id,
      orElse: () => CartItemModel(
        productQty: 0,
        productId: '',
        productName: '',
        productPrice: 0.0,
        isHalf: 0,
        productNote: '',
      ),
    )
        .productQty;
    CartItemModel item = CartItemModel(
      productId: product.id,
      productName: product.name,
      productPrice: double.tryParse(product.price ?? '') ?? 0,
      productQty: productQty,
      isHalf: 0,
      productNote: '',
    );
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (productQty == 0) {
            addToCart(product);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: product.image.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.fastfood,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.fastfood,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (productQty == 0) ...[
                          Text(
                            "₹${product.price}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade700,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ] else ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => updateQty(item, -1),
                                color: Colors.red,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  item.productQty.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => updateQty(item, 1),
                                color: Colors.green,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// grid card widget
  Widget buildGridCard({
    required String title,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CART
  Widget buildCartPanel() {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2d4875),
                    Color(0xFF1a2847),
                    Color(0xFF1a2847),
                    Color(0xFF1a2847)
                  ],
                ),
              ),
              width: Get.width,
              child: const Column(
                children: [
                  Text(
                    "Selected Items",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: buildCartList()),
            buildCartActions(),
          ],
        ),
      ),
    );
  }

  Widget buildCartActions() {
    final total = cartItems.fold<double>(
      0,
          (sum, item) => sum + (item.productPrice ?? 0) * item.productQty,
    );
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: cartItems.isEmpty ? null : placeOrder,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              backgroundColor: const Color(0xFF1a2847),
            ),
            child: const Text(
              "Place Order",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a2847),
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: cartItems.isEmpty ? null : generateBill,
            child: const Text(
              "Generate Bill",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartList() {
    if (cartItems.isEmpty) {
      return const Center(child: Text("No items added"));
    }

    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (_, index) {
        final item = cartItems[index];
        final itemTotal = item.productPrice * item.productQty;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2d4875), Color(0xFF1a2847)],
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      "₹${item.productPrice}",
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => updateQty(item, -1),
                          color: Colors.red,
                        ),
                        Text(
                          item.productQty.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => updateQty(item, 1),
                          color: Colors.green,
                        ),
                      ],
                    ),
                    Text(
                      "₹${(itemTotal).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                TextField(
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    hintText: "Special note",
                    isDense: true,
                    hintStyle: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.white),
                    ),
                  ),
                  onChanged: (val) => updateNote(item, val),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void addToCart(ProductModel p) {
    controller.addToCart(
      cartItems: cartItems,
      product: p,
    );
    setState(() {});
  }

  void updateQty(CartItemModel item, int change) {
    controller.updateQty(
      cartItems: cartItems,
      item: item,
      change: change,
    );
    setState(() {});
  }

  void updateNote(CartItemModel item, String note) {
    controller.updateNote(
      cartItems: cartItems,
      item: item,
      note: note,
    );
    setState(() {});
  }

  void generateBill() {
    Get.to(
          () => PaymentScreen(
        tableId: widget.tableId ?? '',
        cartItems: cartItems,
      ),
    );
  }

  Future<void> placeOrder() async {
    await controller.placeOrder(
      tableId: widget.tableId ?? '',
      cartItems: cartItems,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order placed successfully"),
      ),
    );
  }
}