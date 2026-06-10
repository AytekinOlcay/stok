import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dondurucu Takip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Hesabım',
            onPressed: () => Get.toNamed('/account'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MenuButton(
              icon: Icons.qr_code_scanner,
              label: 'QR Tara',
              onTap: () => Get.toNamed('/qr-scanner'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.kitchen,
              label: 'Raflar',
              onTap: () => Get.toNamed('/shelves'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.search,
              label: 'Ara',
              onTap: () => Get.toNamed('/search'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.inventory_2_outlined,
              label: 'Ürünler',
              onTap: () => Get.toNamed('/products'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.bar_chart,
              label: 'İstatistikler',
              onTap: () => Get.toNamed('/statistics'),
            ),
            const SizedBox(height: 16),
            _MenuButton(
              icon: Icons.restaurant_menu,
              label: 'Tarifler',
              onTap: () => Get.toNamed('/recipes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
      ),
    );
  }
}
