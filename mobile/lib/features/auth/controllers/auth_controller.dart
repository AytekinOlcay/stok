import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/session_service.dart';

class AuthController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final isLoginMode = true.obs;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }

  Future<void> signIn() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Hata', 'E-posta ve şifre zorunludur.');
      return;
    }
    isLoading.value = true;
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      final session = Get.find<SessionService>();
      final hasOrg = await session.loadSession();
      if (hasOrg) {
        Get.offAllNamed('/');
      } else {
        Get.offAllNamed('/onboarding');
      }
    } on AuthException catch (e) {
      Get.snackbar('Hata', e.message);
    } catch (e) {
      Get.snackbar('Hata', 'Giriş yapılamadı.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Hata', 'E-posta ve şifre zorunludur.');
      return;
    }
    if (password != confirmPasswordCtrl.text) {
      Get.snackbar('Hata', 'Şifreler eşleşmiyor.');
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Hata', 'Şifre en az 6 karakter olmalıdır.');
      return;
    }
    isLoading.value = true;
    try {
      await _supabase.auth.signUp(email: email, password: password);
      Get.snackbar('Başarılı', 'Hesap oluşturuldu. Lütfen giriş yapın.');
      isLoginMode.value = true;
      passwordCtrl.clear();
      confirmPasswordCtrl.clear();
    } on AuthException catch (e) {
      Get.snackbar('Hata', e.message);
    } catch (e) {
      Get.snackbar('Hata', 'Kayıt olunamadı.');
    } finally {
      isLoading.value = false;
    }
  }
}
