import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../features/invite/bindings/invite_binding.dart';
import '../../../features/invite/views/invite_sheet.dart';
import '../controllers/account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  void _openInviteSheet(BuildContext context) {
    // Register InviteController fresh each time the sheet opens
    InviteBinding().dependencies();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const InviteSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hesabım')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            // ── Kullanıcı Bilgisi ───────────────────────────────
            _SectionHeader('Hesap Bilgileri'),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('E-posta'),
              subtitle: Text(controller.userEmail.value),
            ),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Organizasyon'),
              subtitle: Text(session.orgName.value ?? '—'),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Rol'),
              subtitle: Text(
                session.role.value == 'owner' ? 'Sahip' : 'Üye',
              ),
            ),

            const Divider(),

            // ── Üyeler (yalnızca sahip) ────────────────────────
            if (session.role.value == 'owner') ...[
              _SectionHeader('Üyeler'),
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('Üye Davet Et'),
                subtitle: const Text('Kod veya QR ile davet oluştur'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openInviteSheet(context),
              ),
              const Divider(),
            ],

            // ── Güvenlik ───────────────────────────────────────
            _SectionHeader('Güvenlik'),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Şifre Değiştir'),
              trailing: const Icon(Icons.chevron_right),
              onTap: controller.showChangePasswordDialog,
            ),

            const Divider(),

            // ── Oturum ─────────────────────────────────────────
            _SectionHeader('Oturum'),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Çıkış Yap'),
              textColor: Colors.orange,
              onTap: () => Get.dialog(
                AlertDialog(
                  title: const Text('Çıkış Yap'),
                  content: const Text('Oturumunuzu kapatmak istiyor musunuz?'),
                  actions: [
                    TextButton(
                      onPressed: Get.back,
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.signOut();
                      },
                      child: const Text('Çıkış Yap'),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),

            // ── Tehlikeli Alan ──────────────────────────────────
            _SectionHeader('Tehlikeli Alan', color: Colors.red),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Hesabı Sil'),
              subtitle: const Text('Bu işlem geri alınamaz.'),
              textColor: Colors.red,
              onTap: controller.showDeleteAccountDialog,
            ),

            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionHeader(this.title, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color ?? Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
