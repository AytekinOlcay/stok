import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by product name…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (v) => controller.query.value = v,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.query.value.isEmpty
                            ? 'No packages in freezer'
                            : 'No results found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: controller.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: controller.results.length +
                    (controller.hasMore.value ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i == controller.results.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _PackageCard(pkg: controller.results[i]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.pkg});

  final Map<String, dynamic> pkg;

  @override
  Widget build(BuildContext context) {
    final product = pkg['products'] as Map<String, dynamic>?;
    final shelf = pkg['shelves'] as Map<String, dynamic>?;

    final name = product?['name'] as String? ?? 'Unknown';
    final category = product?['category'] as String?;
    final qty = pkg['quantity'];
    final unit = pkg['unit'] as String? ?? '';
    final shelfLabel = shelf?['name'] as String? ??
        'Shelf ${shelf?['position'] ?? '-'}';
    final addedAt = _fmt(pkg['added_at']);
    final consumeBefore = _fmt(pkg['recommended_consume_before']);
    final expirationDate = _fmt(pkg['expiration_date']);
    final notes = pkg['notes'] as String?;

    final tettColor = _tettColor(context, pkg['recommended_consume_before']);
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.toNamed('/package/${pkg['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: name + quantity badge ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$qty $unit',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Category chip ──
              if (category != null && category.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.label_outline,
                        size: 13, color: cs.secondary),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: TextStyle(
                          fontSize: 12, color: cs.secondary),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),
              Divider(height: 1, color: cs.outlineVariant),
              const SizedBox(height: 8),

              // ── Detail rows ──
              _InfoRow(
                icon: Icons.layers_outlined,
                label: shelfLabel,
              ),
              if (addedAt.isNotEmpty)
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Added: $addedAt',
                ),
              if (consumeBefore.isNotEmpty)
                _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'TETT: $consumeBefore',
                  color: tettColor,
                ),
              if (expirationDate.isNotEmpty)
                _InfoRow(
                  icon: Icons.warning_amber_outlined,
                  label: 'Exp: $expirationDate',
                  color: cs.error,
                ),
              if (notes != null && notes.isNotEmpty)
                _InfoRow(
                  icon: Icons.notes_outlined,
                  label: notes,
                  color: Theme.of(context).hintColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _tettColor(BuildContext context, dynamic raw) {
    if (raw == null) return null;
    try {
      final days =
          DateTime.parse(raw.toString()).difference(DateTime.now()).inDays;
      if (days < 14) return Theme.of(context).colorScheme.error;
      if (days < 30) return Colors.orange;
    } catch (_) {}
    return null;
  }

  static String _fmt(dynamic value) {
    if (value == null) return '';
    try {
      return DateFormat('dd.MM.yyyy')
          .format(DateTime.parse(value.toString()));
    } catch (_) {
      return value.toString();
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: c),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: c),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

