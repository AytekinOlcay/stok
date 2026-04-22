import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/products_controller.dart';
import 'add_product_sheet.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = controller.products;
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Henüz ürün yok'),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => _showAddSheet(context),
                  child: const Text('İlk ürünü ekle'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = products[i];
              final name = p['name'] as String;
              final category = p['category'] as String?;
              final unit = p['default_unit'] as String;
              final days = p['recommended_freezer_storage_days'] as int;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(name),
                  subtitle: Text(
                    '${category ?? 'Kategori yok'} · $unit · $days gün',
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddProductSheet(),
    );
  }
}
