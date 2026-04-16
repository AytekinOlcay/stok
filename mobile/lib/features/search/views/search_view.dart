import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Product name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => controller.query.value = value,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.query.value.isNotEmpty &&
                    controller.results.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }
                return ListView.separated(
                  itemCount: controller.results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final pkg = controller.results[i];
                    final product =
                        pkg['products'] as Map<String, dynamic>?;
                    final shelf = pkg['shelves'] as Map<String, dynamic>?;
                    final name = product?['name'] ?? 'Unknown';
                    final qty = pkg['quantity'] ?? 0;
                    final unit = pkg['unit'] ?? '';
                    final shelfLabel = shelf?['name'] as String? ??
                        'Shelf ${shelf?['position'] ?? '-'}';
                    final consumeBefore =
                        _formatDate(pkg['recommended_consume_before']);

                    return Card(
                      child: ListTile(
                        title: Text('$name — $qty $unit'),
                        subtitle: Text(
                            '$shelfLabel${consumeBefore.isNotEmpty ? ' · TETT: $consumeBefore' : ''}'),
                        onTap: () => Get.toNamed('/package/${pkg['id']}'),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
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
