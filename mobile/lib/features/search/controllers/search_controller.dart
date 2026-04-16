import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchController extends GetxController {
  final _supabase = Supabase.instance.client;

  final query = ''.obs;
  final results = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(query, (_) => search(), time: const Duration(milliseconds: 400));
  }

  Future<void> search() async {
    final q = query.value.trim();
    if (q.isEmpty) {
      results.clear();
      return;
    }

    isLoading.value = true;
    try {
      final data = await _supabase
          .from('packages')
          .select('*, products!inner(*), shelves(*)')
          .ilike('products.name', '%$q%')
          .order('added_at', ascending: false);
      results.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
