import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/session_service.dart';

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
      final orgId = Get.find<SessionService>().currentOrgId;
      final data = await _supabase
          .from('shelves')
          .select('id, name, position')
          .eq('org_id', orgId)
          .order('position');
      shelves.value = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      Get.snackbar('Hata', 'Raflar yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
