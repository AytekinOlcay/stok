import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/products_controller.dart';

class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key});

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _controller = Get.find<ProductsController>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: '90');
  String _unit = 'g';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Add Product',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Meat, Fish, Vegetable',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _daysCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Storage days *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: const ['g', 'kg', 'ml', 'l', 'piece']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (val) => setState(() => _unit = val ?? _unit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _controller.isSubmitting.value ? null : _submit,
              child: _controller.isSubmitting.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final days = int.tryParse(_daysCtrl.text.trim());
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Product name is required.');
      return;
    }
    if (days == null || days <= 0) {
      Get.snackbar('Validation', 'Storage days must be a positive number.');
      return;
    }

    final success = await _controller.addProduct(
      name: name,
      category: _categoryCtrl.text.trim().isEmpty
          ? null
          : _categoryCtrl.text.trim(),
      defaultUnit: _unit,
      storageDays: days,
    );

    if (success) {
      Get.back();
      Get.snackbar('Added', '$name added to products.');
    }
  }
}
