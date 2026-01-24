/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/repository/cloudinary_service.dart';

enum MenuSettingType { master, category, product }

class MenuSettingController extends GetxController {
  // Observables
  final selectedType = MenuSettingType.master.obs;
  final selectedMaster = Rxn<MasterCategoryModel>();
  final selectedCategory = Rxn<CategoryModel>();
  final selectedProduct = Rxn<ProductModel>();
  final uploadedImageUrl = RxnString();
  final selectedMasterForCategory = Rxn<MasterCategoryModel>();
  final selectedCategoryForProduct = Rxn<CategoryModel>();

  // Text Controllers
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }

  // Change selected menu type
  void changeMenuType(MenuSettingType type) {
    selectedType.value = type;
    resetForm();
  }

  // Reset form
  void resetForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    uploadedImageUrl.value = null;
    selectedMaster.value = null;
    selectedCategory.value = null;
    selectedProduct.value = null;
    selectedMasterForCategory.value = null;
    selectedCategoryForProduct.value = null;
  }

  // Image picker and upload
  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      isLoading.value = true;
      File image = File(pickedFile.path);
      String? imageUrl = await CloudinaryService.uploadImage(image);
      uploadedImageUrl.value = imageUrl ?? "https://t4.ftcdn.net/jpg/06/57/37/01/360_F_657370150_pdNeG5pjI976ZasVbKN9VqH1rfoykdYU.jpg";
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final snap = await RealtimeDbHelper.instance.ref('products').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries.map((e) => ProductModel.fromMap(e.key, e.value)).toList();
  }

  // Select Master Category
  void selectMasterCategory(MasterCategoryModel master) {
    selectedMaster.value = master;
    nameCtrl.text = master.name;
    uploadedImageUrl.value = master.image.isNotEmpty ? master.image : null;
  }

  // Select Category
  Future<void> selectCategory(CategoryModel category) async {
    final masters = await RealtimeDbHelper.instance.getMasterCategories();
    final master = masters.firstWhereOrNull((m) => m.id == category.masterId);

    selectedCategory.value = category;
    nameCtrl.text = category.name;
    uploadedImageUrl.value = category.image.isNotEmpty ? category.image : null;
    selectedMasterForCategory.value = master;
  }

  // Select Product
  Future<void> selectProduct(ProductModel product) async {
    final categories = await RealtimeDbHelper.instance.getCategories();
    final category = categories.firstWhereOrNull((c) => c.id == product.categoryId);

    selectedProduct.value = product;
    nameCtrl.text = product.name;
    priceCtrl.text = product.price;
    uploadedImageUrl.value = product.image.isNotEmpty ? product.image : null;
    selectedCategoryForProduct.value = category;
  }

  // Save or Update Master Category
  Future<void> saveMasterCategory() async {
    if (nameCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a name', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSaving.value = true;

      if (selectedMaster.value != null) {
        await RealtimeDbHelper.instance.updateData(
          path: 'master_categories/${selectedMaster.value!.id}',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
          },
        );
        Get.snackbar('Success', 'Master category updated!', snackPosition: SnackPosition.BOTTOM);
      } else {
        String? masterId = await RealtimeDbHelper.instance.pushData(
          path: 'master_categories',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'categoryIds': [],
          },
        );

        if (masterId != null) {
          Get.snackbar('Success', 'Master category saved!', snackPosition: SnackPosition.BOTTOM);
        }
      }
      resetForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // Save or Update Category
  Future<void> saveCategory() async {
    if (nameCtrl.text.isEmpty || selectedMasterForCategory.value == null) {
      Get.snackbar('Error', 'Please fill all required fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSaving.value = true;

      if (selectedCategory.value != null) {
        await RealtimeDbHelper.instance.updateData(
          path: 'categories/${selectedCategory.value!.id}',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'masterId': selectedMasterForCategory.value!.id,
          },
        );
        Get.snackbar('Success', 'Category updated!', snackPosition: SnackPosition.BOTTOM);
      } else {
        String? categoryId = await RealtimeDbHelper.instance.pushData(
          path: 'categories',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'masterId': selectedMasterForCategory.value!.id,
            'productIds': [],
          },
        );

        List<dynamic> masterCategoryIds = selectedMasterForCategory.value!.categoryIds ?? [];
        masterCategoryIds.add(categoryId);
        await RealtimeDbHelper.instance.updateData(
          path: 'master_categories/${selectedMasterForCategory.value!.id}',
          data: {'categoryIds': masterCategoryIds},
        );

        if (categoryId != null) {
          Get.snackbar('Success', 'Category saved!', snackPosition: SnackPosition.BOTTOM);
        }
      }
      resetForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // Save or Update Product
  Future<void> saveProduct() async {
    if (nameCtrl.text.isEmpty || selectedCategoryForProduct.value == null) {
      Get.snackbar('Error', 'Please fill all required fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSaving.value = true;

      if (selectedProduct.value != null) {
        await RealtimeDbHelper.instance.updateData(
          path: 'products/${selectedProduct.value!.id}',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'price': priceCtrl.text,
            'categoryId': selectedCategoryForProduct.value!.id,
          },
        );
        Get.snackbar('Success', 'Product updated!', snackPosition: SnackPosition.BOTTOM);
      } else {
        String? productId = await RealtimeDbHelper.instance.pushData(
          path: 'products',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'price': priceCtrl.text,
            'categoryId': selectedCategoryForProduct.value!.id,
          },
        );

        List<dynamic> productIds = selectedCategoryForProduct.value!.productIds ?? [];
        productIds.add(productId);
        await RealtimeDbHelper.instance.updateData(
          path: 'categories/${selectedCategoryForProduct.value!.id}',
          data: {'productIds': productIds},
        );

        if (productId != null) {
          Get.snackbar('Success', 'Product saved!', snackPosition: SnackPosition.BOTTOM);
        }
      }
      resetForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/master_category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/repository/cloudinary_service.dart';

enum MenuSettingType { master, category, product }

class MenuSettingController extends GetxController {
  final db = RealtimeDbHelper.instance;

  // Observables
  final selectedType = MenuSettingType.master.obs;
  final selectedMaster = Rxn<MasterCategoryModel>();
  final selectedCategory = Rxn<CategoryModel>();
  final selectedProduct = Rxn<ProductModel>();
  final uploadedImageUrl = RxnString();
  final selectedMasterForCategory = Rxn<MasterCategoryModel>();
  final selectedCategoryForProduct = Rxn<CategoryModel>();

  // Text Controllers
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }

  // Change selected menu type
  void changeMenuType(MenuSettingType type) {
    selectedType.value = type;
    resetForm();
  }

  // Reset form
  void resetForm() {
    nameCtrl.clear();
    priceCtrl.clear();
    uploadedImageUrl.value = null;
    selectedMaster.value = null;
    selectedCategory.value = null;
    selectedProduct.value = null;
    selectedMasterForCategory.value = null;
    selectedCategoryForProduct.value = null;
  }

  // Image picker and upload
  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      isLoading.value = true;
      File image = File(pickedFile.path);
      String? imageUrl = await CloudinaryService.uploadImage(image);
      uploadedImageUrl.value = imageUrl ?? "https://t4.ftcdn.net/jpg/06/57/37/01/360_F_657370150_pdNeG5pjI976ZasVbKN9VqH1rfoykdYU.jpg";
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Select Master Category
  void selectMasterCategory(MasterCategoryModel master) {
    selectedMaster.value = master;
    nameCtrl.text = master.name;
    uploadedImageUrl.value = master.image.isNotEmpty ? master.image : null;
  }

  // Select Category
  Future<void> selectCategory(CategoryModel category) async {
    final masters = await db.getMasterCategories();
    final master = masters.firstWhereOrNull((m) => m.id == category.masterId);

    selectedCategory.value = category;
    nameCtrl.text = category.name;
    uploadedImageUrl.value = category.image.isNotEmpty ? category.image : null;
    selectedMasterForCategory.value = master;
  }

  // Select Product
  Future<void> selectProduct(ProductModel product) async {
    final categories = await db.getCategories();
    final category = categories.firstWhereOrNull((c) => c.id == product.categoryId);

    selectedProduct.value = product;
    nameCtrl.text = product.name;
    priceCtrl.text = product.price;
    uploadedImageUrl.value = product.image.isNotEmpty ? product.image : null;
    selectedCategoryForProduct.value = category;
  }

  // Save or Update Master Category
  Future<void> saveMasterCategory() async {
    if (nameCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a name', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSaving.value = true;

      if (selectedMaster.value != null) {
        // Update existing master
        await db.updateData(
          path: 'master_categories/${selectedMaster.value!.id}',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
          },
        );
        Get.snackbar('Success', 'Master category updated!', snackPosition: SnackPosition.BOTTOM);
      } else {
        // Create new master using pushData
        await db.pushData(
          path: 'master_categories',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
          },
        );
        Get.snackbar('Success', 'Master category saved!', snackPosition: SnackPosition.BOTTOM);
      }
      resetForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // Save or Update Category
  Future<void> saveCategory() async {
    if (nameCtrl.text.isEmpty || selectedMasterForCategory.value == null) {
      Get.snackbar('Error', 'Please fill all required fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSaving.value = true;

      if (selectedCategory.value != null) {
        // Update existing category
        await db.updateData(
          path: 'categories/${selectedCategory.value!.id}',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'masterId': selectedMasterForCategory.value!.id,
          },
        );
        Get.snackbar('Success', 'Category updated!', snackPosition: SnackPosition.BOTTOM);
      } else {
        // Create new category using pushData
        await db.pushData(
          path: 'categories',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'masterId': selectedMasterForCategory.value!.id,
          },
        );
        Get.snackbar('Success', 'Category saved!', snackPosition: SnackPosition.BOTTOM);
      }
      resetForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // Save or Update Product
  Future<void> saveProduct() async {
    if (nameCtrl.text.isEmpty || selectedCategoryForProduct.value == null) {
      Get.snackbar('Error', 'Please fill all required fields', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isSaving.value = true;

      if (selectedProduct.value != null) {
        // Update existing product
        await db.updateData(
          path: 'products/${selectedProduct.value!.id}',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'price': priceCtrl.text,
            'categoryId': selectedCategoryForProduct.value!.id,
          },
        );
        Get.snackbar('Success', 'Product updated!', snackPosition: SnackPosition.BOTTOM);
      } else {
        // Create new product using pushData
        await db.pushData(
          path: 'products',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'price': priceCtrl.text,
            'categoryId': selectedCategoryForProduct.value!.id,
          },
        );
        Get.snackbar('Success', 'Product saved!', snackPosition: SnackPosition.BOTTOM);
      }
      resetForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // Delete Master Category
  Future<void> deleteMasterCategory(String masterId) async {
    try {
      await db.deleteData('master_categories/$masterId');
      Get.snackbar('Success', 'Master category deleted!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Delete Category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await db.deleteData('categories/$categoryId');
      Get.snackbar('Success', 'Category deleted!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final snap = await RealtimeDbHelper.instance.ref('products').get();
    if (!snap.exists) return [];

    final map = snap.value as Map<dynamic, dynamic>;
    return map.entries.map((e) => ProductModel.fromMap(e.key, e.value)).toList();
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    try {
      await db.deleteData('products/$productId');
      Get.snackbar('Success', 'Product deleted!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}