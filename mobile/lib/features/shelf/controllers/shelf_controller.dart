import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShelfController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final shelf = Rxn<Map<String, dynamic>>();
  final packages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id'];
    if (id != null) fetchShelf(id);
  }

  Future<void> fetchShelf(String id) async {
    isLoading.value = true;
    try {
      final shelfData =
          await _supabase.from('shelves').select().eq('id', id).single();
      shelf.value = shelfData;

      final pkgs = await _supabase
          .from('packages')
          .select('*, products(*)')
          .eq('shelf_id', id)
          .order('added_at', ascending: false);
      packages.value = List<Map<String, dynamic>>.from(pkgs);
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        Get.back();
        return;
      }
      Get.snackbar('Hata', 'Raf yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removePackage(String packageId) async {
    try {
      await _supabase.from('packages').delete().eq('id', packageId);
      packages.removeWhere((p) => p['id'] == packageId);
      Get.snackbar('Done', 'Package removed from shelf.');
    } catch (e) {
      Get.snackbar('Hata', 'Paket kaldırılamadı: $e');
    }
  }
}
