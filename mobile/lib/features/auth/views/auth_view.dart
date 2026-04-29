import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Obx(() {
                final isLogin = controller.isLoginMode.value;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('❄️', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 8),
                    Text(
                      'Dondurucu Takip',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 32),

                    // Tab row
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _TabButton(
                            label: 'Giriş Yap',
                            selected: isLogin,
                            onTap: () => controller.isLoginMode.value = true,
                          ),
                          _TabButton(
                            label: 'Kayıt Ol',
                            selected: !isLogin,
                            onTap: () => controller.isLoginMode.value = false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    TextField(
                      controller: controller.emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextField(
                      controller: controller.passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    // Confirm password + invite code (register only)
                    if (!isLogin) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.confirmPasswordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Şifre Tekrar',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.inviteCodeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Davet Kodu (isteğe bağlı)',
                          hintText: 'örn. D9DF9B',
                          prefixIcon: Icon(Icons.key_outlined),
                          border: OutlineInputBorder(),
                          counterText: '',
                          helperText:
                              'Organizasyona davet edildiysen kodu gir.',
                        ),
                        onChanged: (v) {
                          final upper = v.toUpperCase();
                          if (v != upper) {
                            controller.inviteCodeCtrl.value = TextEditingValue(
                              text: upper,
                              selection: TextSelection.collapsed(
                                  offset: upper.length),
                            );
                          }
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : (isLogin ? controller.signIn : controller.signUp),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(isLogin ? 'Giriş Yap' : 'Hesap Oluştur'),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
