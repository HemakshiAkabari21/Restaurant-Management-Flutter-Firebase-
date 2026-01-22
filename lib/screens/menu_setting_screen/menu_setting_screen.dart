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
      ).paddingSymmetric(vertical: 16.h),
    );
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

  Widget buildLeftOptions() {
    return Expanded(
      flex: 2,
      child: SizedBox(
        // width: 200,
        child: Container(
          decoration: BoxDecoration(
           color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text('MENU SETTINGS', style: StyleHelper.customStyle(color: AppColors.black,size: 6.sp, family: semiBold,),),
              SizedBox(height: 30.h),
              ...MenuSettingType.values.map((type) {
                final isSelected = selectedType == type;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black.withOpacity(0.2) : Colors.transparent,
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
                        color: AppColors.black,
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
          ).paddingSymmetric(vertical: 16.h),
        ),
      ),
    );
  }

  Widget buildCenterGrid() {
    return Expanded(
      flex: 7,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: buildGridContent(),
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
          crossAxisCount: 3,
          childAspectRatio: 2,
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
                  child: Center(
                    child: Text(
                      m.name,
                      style: StyleHelper.customStyle(
                        color: AppColors.white,
                        size: 6.sp,
                        family: semiBold,
                      ),
                    ),
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
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          children: snap.data!.map((c) {
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
                      Text(
                        c.name,
                        style: StyleHelper.customStyle(
                          color: AppColors.white,
                          size: 6.sp,
                          family: semiBold,
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
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          children: snap.data!.map((p) {
            return Card(
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

                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<ProductModel>> getAllProducts() async {
    final snap = await RealtimeDbHelper.instance.ref('products').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries
        .map((e) => ProductModel.fromMap(e.key, e.value))
        .toList();
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
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: Text(selectedMaster != null ? "Edit Master Category" : "Add Master Category",
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: StyleHelper.customStyle(color: const Color(0xFF1a2847), size: 8.sp, family: semiBold,),
              ),
            ),
            if(selectedMaster != null)
            GestureDetector(
              onTap: () {
                selectedMaster = null;
                nameCtrl.clear();
                uploadedImageUrl= null;
              },
              child: Icon(Icons.close, size: 6.sp),
            ),
          ],
        ),
        SizedBox(height: 24.h),
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
            ),
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
            selectedMaster != null ? "Update Master Category" : "Save Master Category",
            style: StyleHelper.customStyle(
              color: AppColors.white,
              size: 6.sp,
              family: semiBold,
            ),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 6.w,vertical: 6.h);
  }

  Widget buildCategoryForm() {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Row(
              children: [
                Text(
                  selectedCategory != null ? "Edit Category" : "Add Category",
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: StyleHelper.customStyle(color: Color(0xFF1a2847), size: 8.sp, family: semiBold,),
                ),
              ],
            ),
            SizedBox(height: 24.h),
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
                ),
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
            ),
          ],
        ).paddingSymmetric(horizontal: 6.w,vertical: 8.h);
      },
    );
  }

  Widget buildProductForm() {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            Text(
              selectedProduct != null ? "Edit Product" : "Add Product",
              style: StyleHelper.customStyle(
                color: Color(0xFF1a2847),
                size: 8.sp,
                family: semiBold,
              ),
            ),
            SizedBox(height: 24.h),
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
                ),
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
            ),
          ],
        ).paddingSymmetric(horizontal: 6.w,vertical: 8.h);
      },
    );
  }
}