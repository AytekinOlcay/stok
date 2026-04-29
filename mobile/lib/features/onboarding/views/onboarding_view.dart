import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

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
                return controller.step.value == 0
                    ? _StepOrg(controller: controller)
                    : _StepFreezer(controller: controller);
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Step 1: Organizasyon adı
// ──────────────────────────────────────────
class _StepOrg extends StatelessWidget {
  final OnboardingController controller;
  const _StepOrg({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('❄️', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(
          'Hoş Geldiniz!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Başlamadan önce birkaç şeyi ayarlayalım.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 32),
        Text('1 / 2', textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 8),
        Text(
          'Bu dondurucu kimin?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Bir isim verin (ör. "Ev", "Ahmet Market", "Depo")',
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.orgNameCtrl,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Organizasyon Adı *',
            hintText: 'örn. Ev',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: controller.nextStep,
          child: const Text('Devam Et'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.key_outlined),
          label: const Text('Davete Katıl'),
          onPressed: () => Get.toNamed('/join-org'),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// Step 2: Dondurucu bilgileri
// ──────────────────────────────────────────
class _StepFreezer extends StatelessWidget {
  final OnboardingController controller;
  const _StepFreezer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('🧊', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Dondurucunu Tanıt',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Text('2 / 2', textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.freezerNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Dondurucu Adı *',
                hintText: 'örn. Derin Dondurucu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kaç raf var?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.outlined(
                  icon: const Icon(Icons.remove),
                  onPressed: controller.shelfCount.value > 1
                      ? () => controller.shelfCount.value--
                      : null,
                ),
                const SizedBox(width: 16),
                Text(
                  '${controller.shelfCount.value} Raf',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                IconButton.outlined(
                  icon: const Icon(Icons.add),
                  onPressed: () => controller.shelfCount.value++,
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: controller.isLoading.value ? null : controller.create,
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kurulumu Tamamla'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => controller.step.value = 0,
              child: const Text('← Geri'),
            ),
          ],
        ));
  }
}
