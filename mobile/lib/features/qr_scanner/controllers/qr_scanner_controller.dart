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
      final String id = payload['id'] as String;

      if (type == 'shelf') {
        Get.offNamed('/shelf/$id');
      } else if (type == 'package') {
        Get.offNamed('/package/$id');
      } else {
        Get.snackbar('Unknown QR', 'This QR code is not recognized.');
        isProcessing.value = false;
      }
    } catch (_) {
      Get.snackbar('Invalid QR', 'Could not parse QR code content.');
      isProcessing.value = false;
    }
  }
}
