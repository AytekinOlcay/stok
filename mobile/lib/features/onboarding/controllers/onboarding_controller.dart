import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/session_service.dart';

class OnboardingController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final step = 0.obs; // 0 = org info, 1 = freezer info

  final orgNameCtrl = TextEditingController();
  final freezerNameCtrl = TextEditingController(text: 'Derin Dondurucu');
  final shelfCount = 7.obs;

  @override
  void onClose() {
    orgNameCtrl.dispose();
    freezerNameCtrl.dispose();
    super.onClose();
  }

  void nextStep() {
    if (orgNameCtrl.text.trim().isEmpty) {
      Get.snackbar('Hata', 'Organizasyon adı zorunludur.');
      return;
    }
    step.value = 1;
  }

  Future<void> create() async {
    if (freezerNameCtrl.text.trim().isEmpty) {
      Get.snackbar('Hata', 'Dondurucu adı zorunludur.');
      return;
    }
    isLoading.value = true;
    try {
      final result = await _supabase.rpc(
        'create_organization_with_freezer',
        params: {
          'p_org_name': orgNameCtrl.text.trim(),
          'p_freezer_name': freezerNameCtrl.text.trim(),
          'p_shelf_count': shelfCount.value,
        },
      );
      final session = Get.find<SessionService>();
      session.orgId.value = result['org_id'] as String?;
      session.orgName.value = orgNameCtrl.text.trim();
      session.role.value = 'owner';
      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar('Hata', 'Kurulum tamamlanamadı: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
