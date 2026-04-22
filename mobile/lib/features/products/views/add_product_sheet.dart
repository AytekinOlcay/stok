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

  bool get _isDirty =>
      _nameCtrl.text.isNotEmpty ||
      _categoryCtrl.text.isNotEmpty ||
      _daysCtrl.text.trim() != '90';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  void _tryClose() {
    if (!_isDirty) {
      Navigator.of(context).pop();
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Değişiklikleri iptal et?'),
        content: const Text('Girilen bilgiler kaybolacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Geri Dön'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _tryClose();
      },
      child: Padding(
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
                  Text('Ürün Ekle',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _tryClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Ad *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'örn. Et, Balık, Sebze',
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
                        labelText: 'Saklama süresi (gün) *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Birim',
                        border: OutlineInputBorder(),
                      ),
                      items: const ['g', 'kg', 'ml', 'l', 'piece']
                          .map((u) =>
                              DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _unit = val ?? _unit),
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
                    : const Text('Ürün Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final days = int.tryParse(_daysCtrl.text.trim());
    if (name.isEmpty) {
      Get.snackbar('Hata', 'Ürün adı zorunludur.');
      return;
    }
    if (days == null || days <= 0) {
      Get.snackbar('Hata', 'Saklama süresi pozitif bir sayı olmalıdır.');
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
      if (mounted) Navigator.of(context).pop();
      Get.snackbar('Eklendi', 'winget ürünlere eklendi.');
    }
  }
}
