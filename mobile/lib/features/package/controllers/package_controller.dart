import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackageController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final package = Rxn<Map<String, dynamic>>();
  final totalStock = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id'];
    if (id != null) fetchPackage(id);
  }

  Future<void> fetchPackage(String id) async {
    isLoading.value = true;
    try {
      final data = await _supabase
          .from('packages')
          .select('*, products(*), shelves(*)')
          .eq('id', id)
          .single();
      package.value = data;

      final productId = data['product_id'] as String;
      final stockRows = await _supabase
          .rpc('get_product_total_stock', params: {'p_product_id': productId});
      if (stockRows is List && stockRows.isNotEmpty) {
        totalStock.value =
            ((stockRows.first as Map)['total_quantity'] as num?)?.toDouble() ??
                0.0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load package: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
