import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../features/add_package/views/add_package_sheet.dart';
import '../../../widgets/qr_display_dialog.dart';
import '../controllers/shelf_controller.dart';

class ShelfView extends GetView<ShelfController> {
  const ShelfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final s = controller.shelf.value;
          final title = s != null
              ? (s['name'] as String? ?? 'Shelf ${s['position']}')
              : 'Shelf';
          return Text(title);
        }),
        actions: [
          Obx(() {
            final s = controller.shelf.value;
            if (s == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: 'Show QR',
              onPressed: () => showQrDialog(
                context,
                type: 'shelf',
                id: s['id'] as String,
                label: s['name'] as String? ?? 'Shelf ${s['position']}',
              ),
            );
          }),
        ],
      ),
      floatingActionButton: Obx(() {
        final s = controller.shelf.value;
        if (s == null) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => AddPackageSheet(
              shelfId: s['id'] as String,
              onAdded: () => controller.fetchShelf(s['id'] as String),
            ),
          ),
          child: const Icon(Icons.add),
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final packages = controller.packages;
        if (packages.isEmpty) {
          return const Center(child: Text('No packages on this shelf.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final pkg = packages[i];
            final product = pkg['products'] as Map<String, dynamic>?;
            final name = product?['name'] ?? 'Unknown';
            final qty = pkg['quantity'] ?? 0;
            final unit = pkg['unit'] ?? '';
            final consumeBefore = _formatDate(pkg['recommended_consume_before']);

            return Card(
              child: ListTile(
                title: Text('$name — $qty $unit'),
                subtitle: consumeBefore.isNotEmpty
                    ? Text('TETT: $consumeBefore')
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmRemove(context, pkg),
                ),
                onTap: () => Get.toNamed('/package/${pkg['id']}'),
              ),
            );
          },
        );
      }),
    );
  }

  void _confirmRemove(BuildContext context, Map<String, dynamic> pkg) {
    final product = pkg['products'] as Map<String, dynamic>?;
    final name = product?['name'] ?? 'this package';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Package'),
        content: Text('Remove "$name" from this shelf?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removePackage(pkg['id'] as String);
            },
            child:
                const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(value.toString()));
    } catch (_) {
      return value.toString();
    }
  }
}

