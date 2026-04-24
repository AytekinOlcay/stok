import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/session_service.dart';

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
      final orgId = Get.find<SessionService>().currentOrgId;
      final data = await _supabase
          .from('products')
          .select('*')
          .eq('org_id', orgId)
          .order('name');
      products.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar('Hata', 'Ürünler yüklenemedi: $e');
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
      final orgId = Get.find<SessionService>().currentOrgId;
      await _supabase.from('products').insert({
        'org_id': orgId,
        'name': name,
        if (category != null && category.isNotEmpty) 'category': category,
        'default_unit': defaultUnit,
        'recommended_freezer_storage_days': storageDays,
      });
      await fetchProducts();
      return true;
    } catch (e) {
      Get.snackbar('Hata', 'Ürün eklenemedi: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
