import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    userEmail.value = _supabase.auth.currentUser?.email ?? '';
  }

  // ── Şifre Değiştir ────────────────────────────────────────────
  Future<void> changePassword(String newPassword) async {
    isLoading.value = true;
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      Get.back();
      Get.snackbar('Başarılı', 'Şifreniz güncellendi.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hata', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Çıkış Yap ────────────────────────────────────────────────
  Future<void> signOut() async {
    isLoading.value = true;
    try {
      await _supabase.auth.signOut();
      // SessionService.onInit() auth listener handles clearing + redirect
    } catch (e) {
      debugPrint('signOut error: $e');
      isLoading.value = false;
    }
  }

  // ── Hesabı Sil ───────────────────────────────────────────────
  // Calls a SECURITY DEFINER RPC so the user can delete themselves
  // without needing service-role access on the client.
  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      await _supabase.rpc('delete_own_account');
      // After deletion Supabase signs the session out automatically.
      // SessionService listener will redirect to /login.
    } catch (e) {
      Get.snackbar('Hata', e.toString(), snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
    }
  }

  // ── Şifre Değiştir Dialog ─────────────────────────────────────
  void showChangePasswordDialog() {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final obscureNew = true.obs;
    final obscureConfirm = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => TextField(
                  controller: newPassCtrl,
                  obscureText: obscureNew.value,
                  decoration: InputDecoration(
                    labelText: 'Yeni Şifre',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => obscureNew.toggle(),
                    ),
                  ),
                )),
            const SizedBox(height: 12),
            Obx(() => TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm.value,
                  decoration: InputDecoration(
                    labelText: 'Şifreyi Onayla',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm.value
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => obscureConfirm.toggle(),
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('İptal'),
          ),
          Obx(() => TextButton(
                onPressed: isLoading.value
                    ? null
                    : () {
                        if (newPassCtrl.text.length < 6) {
                          Get.snackbar('Hata', 'Şifre en az 6 karakter olmalı.',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        if (newPassCtrl.text != confirmCtrl.text) {
                          Get.snackbar('Hata', 'Şifreler eşleşmiyor.',
                              snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        changePassword(newPassCtrl.text);
                      },
                child: const Text('Kaydet'),
              )),
        ],
      ),
    );
  }

  // ── Hesap Sil Onay Dialog ────────────────────────────────────
  void showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınız kalıcı olarak silinecek.\n\n'
          'Eğer organizasyonunuzun tek sahibiyseniz, tüm veriler de silinir.\n\n'
          'Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
