import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_management_fierbase/firebase/realtime_db_helper.dart';
import 'package:restaurant_management_fierbase/model/category_model.dart';
import 'package:restaurant_management_fierbase/model/product_model.dart';
import 'package:restaurant_management_fierbase/repository/cloudinary_service.dart';

enum MenuSettingType { category, product }

class MenuSettingController extends GetxController {
  final db = RealtimeDbHelper.instance;

  // Observables
  final selectedType = MenuSettingType.category.obs;
  final selectedCategory = Rxn<CategoryModel>();
  final selectedProduct = Rxn<ProductModel>();
  final uploadedImageUrl = RxnString();
  final selectedCategoryForProduct = Rxn<CategoryModel>();

  // Reactive lists for real-time updates
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;

  // Text Controllers
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // Loading states
  final isLoading = false.obs;
  final isSaving = false.obs;
  final isLoadingData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadProducts();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }

  // Load categories with real-time listener
  void loadCategories() async {
    isLoadingData.value = true;
    try {
      db.ref('categories').onValue.listen((event) {
        if (event.snapshot.exists) {
          final map = event.snapshot.value as Map<dynamic, dynamic>;
          categories.value = map.entries
              .map((e) => CategoryModel.fromMap(e.key, e.value))
              .toList();
        } else {
          categories.value = [];
        }
        isLoadingData.value = false;
      });
    } catch (e) {
      isLoadingData.value = false;
      Get.snackbar('Error', 'Failed to load categories: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Load products with real-time listener
  void loadProducts() async {
    try {
      db.ref('products').onValue.listen((event) {
        if (event.snapshot.exists) {
          final map = event.snapshot.value as Map<dynamic, dynamic>;
          products.value = map.entries
              .map((e) => ProductModel.fromMap(e.key, e.value))
              .toList();
        } else {
          products.value = [];
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
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
    selectedCategory.value = null;
    selectedProduct.value = null;
    selectedCategoryForProduct.value = null;
  }

  // Image picker and upload
  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );
      if (pickedFile == null) return;

      isLoading.value = true;
      File image = File(pickedFile.path);
      String? imageUrl = await CloudinaryService.uploadImage(image);
      uploadedImageUrl.value = imageUrl ??
          "https://t4.ftcdn.net/jpg/06/57/37/01/360_F_657370150_pdNeG5pjI976ZasVbKN9VqH1rfoykdYU.jpg";
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Select Category
  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
    nameCtrl.text = category.name;
    uploadedImageUrl.value = category.image.isNotEmpty ? category.image : null;
  }

  // Select Product
  void selectProduct(ProductModel product) {
    final category = categories.firstWhereOrNull((c) => c.id == product.categoryId);

    selectedProduct.value = product;
    nameCtrl.text = product.name;
    priceCtrl.text = product.price;
    uploadedImageUrl.value = product.image.isNotEmpty ? product.image : null;
    selectedCategoryForProduct.value = category;
  }

  // Save or Update Category
  Future<void> saveCategory() async {
    if (nameCtrl.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a category name',
        snackPosition: SnackPosition.BOTTOM,
      );
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
          },
        );
        Get.snackbar(
          'Success',
          'Category updated!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Create new category
        await db.pushData(
          path: 'categories',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
          },
        );
        Get.snackbar(
          'Success',
          'Category saved!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      resetForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Save or Update Product
  Future<void> saveProduct() async {
    if (nameCtrl.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a product name',
        snackPosition: SnackPosition.BOTTOM,
      );
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
            'categoryId': selectedCategoryForProduct.value?.id ?? "",
          },
        );
        Get.snackbar(
          'Success',
          'Product updated!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Create new product
        await db.pushData(
          path: 'products',
          data: {
            'name': nameCtrl.text,
            'image': uploadedImageUrl.value ?? "",
            'price': priceCtrl.text,
            'categoryId': selectedCategoryForProduct.value?.id ?? "",
          },
        );
        Get.snackbar(
          'Success',
          'Product saved!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      resetForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Delete Category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await db.deleteData('categories/$categoryId');
      Get.snackbar(
        'Success',
        'Category deleted!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    try {
      await db.deleteData('products/$productId');
      Get.snackbar(
        'Success',
        'Product deleted!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get products by category (filtered from reactive list)
  List<ProductModel> getProductsByCategory(String categoryId) {
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  // Get uncategorized products (filtered from reactive list)
  List<ProductModel> getUncategorizedProducts() {
    return products
        .where((p) => p.categoryId == null || p.categoryId!.isEmpty)
        .toList();
  }
}