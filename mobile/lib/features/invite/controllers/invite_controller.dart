import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InviteController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final token = Rxn<String>();
  final expiresAt = Rxn<DateTime>();
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _createInvitation();
  }

  Future<void> _createInvitation() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _supabase
          .rpc('create_invitation')
          .timeout(const Duration(seconds: 15));
      debugPrint('create_invitation result: $result');
      token.value = result['token'] as String;
      expiresAt.value = DateTime.parse(result['expires_at'] as String).toLocal();
    } on PostgrestException catch (e) {
      debugPrint('create_invitation PostgrestException: ${e.code} | ${e.message} | ${e.details}');
      errorMessage.value = e.message;
    } catch (e, st) {
      debugPrint('create_invitation error: $e\n$st');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// QR payload content — the QR scanner will detect this format.
  String get qrPayload {
    if (token.value == null) return '';
    return jsonEncode({'type': 'invitation', 'token': token.value});
  }

  Future<void> refreshToken() => _createInvitation();

  void copyToClipboard() {
    if (token.value == null) return;
    Clipboard.setData(ClipboardData(text: token.value!));
    Get.snackbar(
      'Kopyalandı',
      'Davet kodu panoya kopyalandı.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
