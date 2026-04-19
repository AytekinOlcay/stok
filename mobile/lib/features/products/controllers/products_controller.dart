import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductsController extends GetxController {
  final _supabase = Supabase.instance.client;

  final products = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final data = await _supabase
          .from('products')
          .select('*')
          .order('name');
      products.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addProduct({
    required String name,
    String? category,
    required String defaultUnit,
    required int storageDays,
  }) async {
    isSubmitting.value = true;
    try {
      await _supabase.from('products').insert({
        'name': name,
        if (category != null && category.isNotEmpty) 'category': category,
        'default_unit': defaultUnit,
        'recommended_freezer_storage_days': storageDays,
      });
      await fetchProducts();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
