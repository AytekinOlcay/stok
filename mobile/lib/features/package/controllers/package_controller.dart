import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackageController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final isConsuming = false.obs;
  final package = Rxn<Map<String, dynamic>>();
  final totalStock = 0.0.obs;
  final relatedRecipes = <Map<String, dynamic>>[].obs;

  String? get _packageId => package.value?['id'] as String?;

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
      await _refreshStock(data['product_id'] as String);
      await _fetchRelatedRecipes(data['product_id'] as String);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        Get.back();
        return;
      }
      Get.snackbar('Hata', 'Paket yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshStock(String productId) async {    final stockRows = await _supabase
        .rpc('get_product_total_stock', params: {'p_product_id': productId});
    if (stockRows is List && stockRows.isNotEmpty) {
      totalStock.value =
          ((stockRows.first as Map)['total_quantity'] as num?)?.toDouble() ??
              0.0;
    } else {
      totalStock.value = 0.0;
    }
  }

  Future<void> _fetchRelatedRecipes(String productId) async {
    try {
      final data = await _supabase
          .from('recipe_products')
          .select('recipes(id, title, prep_time_min, video_thumbnail, video_source)')
          .eq('product_id', productId)
          .limit(3);
      if (data is List) {
        relatedRecipes.value = data
            .map((e) => (e as Map)['recipes'] as Map<String, dynamic>?)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    } catch (_) {
      // Recipes section is optional — silently ignore failures
    }
  }

  /// Returns true if the package was fully consumed (deleted).
  Future<bool> consume(double amount) async {
    final id = _packageId;
    if (id == null) return false;
    isConsuming.value = true;
    try {
      final result = await _supabase.rpc(
        'consume_package',
        params: {'p_package_id': id, 'p_amount': amount},
      );

      final action = (result as Map<String, dynamic>)['action'] as String;

      if (action == 'removed') {
        Get.back(); // close detail screen
        Get.snackbar('Done', 'Package fully consumed and removed.');
        return true;
      } else {
        final remaining = (result['remaining'] as num).toDouble();
        // Update local state without a full reload
        final updated = Map<String, dynamic>.from(package.value!);
        updated['quantity'] = remaining;
        package.value = updated;
        await _refreshStock(updated['product_id'] as String);
        Get.snackbar('Done', '${amount.toStringAsFixed(0)} consumed. '
            '${remaining.toStringAsFixed(0)} remaining.');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isConsuming.value = false;
    }
  }
}
