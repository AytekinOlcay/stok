import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/join_org_controller.dart';

class JoinOrgView extends GetView<JoinOrgController> {
  const JoinOrgView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Davete Katıl')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🔑',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'Davet Kodunu Gir',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organizasyon sahibinin paylaştığı 6 karakterli kodu gir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: controller.tokenCtrl,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Davet Kodu',
                      hintText: 'ABCDEF',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    onChanged: (v) {
                      // Force uppercase as user types
                      final upper = v.toUpperCase();
                      if (v != upper) {
                        controller.tokenCtrl.value = TextEditingValue(
                          text: upper,
                          selection: TextSelection.collapsed(offset: upper.length),
                        );
                      }
                    },
                    onSubmitted: (_) => controller.joinOrg(),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => FilledButton(
                        onPressed:
                            controller.isLoading.value ? null : controller.joinOrg,
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Katıl'),
                      )),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: Get.back,
                    child: const Text('İptal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
