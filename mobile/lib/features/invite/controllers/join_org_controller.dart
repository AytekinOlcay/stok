import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/session_service.dart';

class JoinOrgController extends GetxController {
  final _supabase = Supabase.instance.client;

  final tokenCtrl = TextEditingController();
  final isLoading = false.obs;

  /// Pre-fill token if arriving from QR scan (/join-org?token=ABCDEF)
  @override
  void onInit() {
    super.onInit();
    final params = Get.parameters;
    if (params['token'] != null && params['token']!.isNotEmpty) {
      tokenCtrl.text = params['token']!.toUpperCase();
    }
  }

  @override
  void onClose() {
    tokenCtrl.dispose();
    super.onClose();
  }

  Future<void> joinOrg() async {
    final code = tokenCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      Get.snackbar('Hata', 'Davet kodu boş olamaz.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final result = await _supabase
          .rpc('join_org_by_token', params: {'p_token': code})
          .timeout(const Duration(seconds: 15));

      // Update session service with the newly joined org
      final session = Get.find<SessionService>();
      await session.loadSession();

      Get.offAllNamed('/');
      Get.snackbar(
        'Hoş Geldiniz!',
        '"${result['org_name']}" organizasyonuna katıldınız.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } on PostgrestException catch (e) {
      Get.snackbar('Hata', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hata', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
