import 'package:get/get.dart';

class QrScannerController extends GetxController {
  final scannedCode = ''.obs;

  void onCodeScanned(String code) {
    scannedCode.value = code;
  }
}
