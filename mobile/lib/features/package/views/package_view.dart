import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../widgets/qr_display_dialog.dart';
import '../controllers/package_controller.dart';

class PackageView extends GetView<PackageController> {
  const PackageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Details'),
        actions: [
          Obx(() {
            final pkg = controller.package.value;
            if (pkg == null) return const SizedBox.shrink();
            final product = pkg['products'] as Map<String, dynamic>?;
            final label = product?['name'] as String? ?? 'Package';
            return IconButton(
              icon: const Icon(Icons.qr_code),
              tooltip: 'Show QR',
              onPressed: () => showQrDialog(
                context,
                type: 'package',
                id: pkg['id'] as String,
                label: label,
                productName: label,
                addedAt: _formatDate(pkg['added_at']),
                consumeBefore: _formatDate(pkg['recommended_consume_before']),
              ),
            );
          }),
        ],
      ),
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
        final shelfName =
            shelf?['name'] ?? 'Shelf ${shelf?['position'] ?? '-'}';
        final quantity = (pkg['quantity'] as num?)?.toDouble() ?? 0.0;
        final unit = pkg['unit'] as String? ?? '';
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
              _DetailRow(
                  label: 'Quantity',
                  value:
                      '${quantity % 1 == 0 ? quantity.toInt() : quantity} $unit'),
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
                  value:
                      '${total % 1 == 0 ? total.toInt() : total} $unit'),
            ]),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionCard(children: [
                _DetailRow(label: 'Notes', value: notes),
              ]),
            ],
            const SizedBox(height: 20),
            // ── Consume section ────────────────────────────────────────
            _ConsumeSection(
              maxQty: quantity,
              unit: unit,
              isLoading: controller.isConsuming,
              onConsume: controller.consume,
            ),
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

// ── Consume widget ────────────────────────────────────────────────────────────

class _ConsumeSection extends StatefulWidget {
  final double maxQty;
  final String unit;
  final RxBool isLoading;
  final Future<bool> Function(double) onConsume;

  const _ConsumeSection({
    required this.maxQty,
    required this.unit,
    required this.isLoading,
    required this.onConsume,
  });

  @override
  State<_ConsumeSection> createState() => _ConsumeSectionState();
}

class _ConsumeSectionState extends State<_ConsumeSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = widget.isLoading.value;
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Use from package',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount (${widget.unit})',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: loading ? null : _submitPartial,
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Use'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: loading ? null : _submitAll,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.error),
                  ),
                  child: Text(
                    'Use All '
                    '(${widget.maxQty % 1 == 0 ? widget.maxQty.toInt() : widget.maxQty} ${widget.unit})',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _submitPartial() {
    final amount = double.tryParse(_ctrl.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar('Validation', 'Enter a valid amount.');
      return;
    }
    if (amount > widget.maxQty) {
      Get.snackbar('Validation',
          'Amount exceeds available quantity (${widget.maxQty} ${widget.unit}).');
      return;
    }
    _ctrl.clear();
    widget.onConsume(amount);
  }

  void _submitAll() {
    widget.onConsume(widget.maxQty);
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

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
