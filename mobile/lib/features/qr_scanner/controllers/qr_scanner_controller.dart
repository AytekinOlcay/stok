import 'dart:convert';

import 'package:get/get.dart';

class QrScannerController extends GetxController {
  final scannedCode = ''.obs;
  final isProcessing = false.obs;

  void onCodeScanned(String raw) {
    if (isProcessing.value) return;
    isProcessing.value = true;
    scannedCode.value = raw;

    try {
      final Map<String, dynamic> payload = jsonDecode(raw);
      final String type = payload['type'] as String;

      if (type == 'shelf') {
        final String id = payload['id'] as String;
        Get.offNamed('/shelf/$id');
      } else if (type == 'package') {
        final String id = payload['id'] as String;
        Get.offNamed('/package/$id');
      } else if (type == 'invitation') {
        final String token = payload['token'] as String;
        // Go back to scanner first, then navigate to join screen
        Get.offNamed('/join-org', parameters: {'token': token});
      } else {
        Get.snackbar('Uyarı', 'Bu bir freezer QR kodu değil.',
            duration: const Duration(seconds: 3));
        isProcessing.value = false;
      }
    } catch (_) {
      Get.snackbar('Uyarı', 'Bu bir freezer QR kodu değil.',
          duration: const Duration(seconds: 3));
      isProcessing.value = false;
    }
  }
}
