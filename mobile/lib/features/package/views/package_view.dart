import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/package_controller.dart';

class PackageView extends GetView<PackageController> {
  const PackageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package Details')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final pkg = controller.package.value;
        if (pkg == null) {
          return const Center(child: Text('Package not found.'));
        }

        final product = pkg['products'] as Map<String, dynamic>?;
        final shelf = pkg['shelves'] as Map<String, dynamic>?;
        final productName = product?['name'] ?? 'Unknown';
        final shelfName = shelf?['name'] ?? 'Shelf ${shelf?['position'] ?? '-'}';
        final quantity = pkg['quantity'] ?? 0;
        final unit = pkg['unit'] ?? '';
        final addedAt = _formatDate(pkg['added_at']);
        final consumeBefore = _formatDate(pkg['recommended_consume_before']);
        final expirationDate = _formatDate(pkg['expiration_date']);
        final notes = pkg['notes'] as String?;
        final total = controller.totalStock.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(children: [
              _DetailRow(label: 'Product', value: productName),
              _DetailRow(label: 'Quantity', value: '$quantity $unit'),
              _DetailRow(label: 'Shelf', value: shelfName),
            ]),
            const SizedBox(height: 12),
            _SectionCard(children: [
              _DetailRow(label: 'Added', value: addedAt),
              _DetailRow(
                  label: 'Consume Before',
                  value: consumeBefore,
                  highlight: true),
              if (expirationDate.isNotEmpty)
                _DetailRow(label: 'Expiration', value: expirationDate),
            ]),
            const SizedBox(height: 12),
            _SectionCard(children: [
              _DetailRow(
                  label: 'Total Stock ($productName)',
                  value: '${total.toStringAsFixed(0)} $unit'),
            ]),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionCard(children: [
                _DetailRow(label: 'Notes', value: notes),
              ]),
            ],
          ],
        );
      }),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    try {
      final dt = DateTime.parse(value.toString());
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return value.toString();
    }
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(children: children),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _DetailRow(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight:
                    highlight ? FontWeight.bold : FontWeight.normal,
                color: highlight
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
