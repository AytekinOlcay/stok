import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShelvesListController extends GetxController {
  final _supabase = Supabase.instance.client;

  final shelves = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShelves();
  }

  Future<void> fetchShelves() async {
    isLoading.value = true;
    try {
      final data = await _supabase
          .from('shelves')
          .select('id, name, position')
          .order('position');
      shelves.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shelves: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
