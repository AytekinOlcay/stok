import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPackageSheet extends StatefulWidget {
  final String shelfId;
  final VoidCallback onAdded;

  const AddPackageSheet({
    super.key,
    required this.shelfId,
    required this.onAdded,
  });

  @override
  State<AddPackageSheet> createState() => _AddPackageSheetState();
}

class _AddPackageSheetState extends State<AddPackageSheet> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _products = [];
  bool _loadingProducts = true;
  bool _submitting = false;

  String? _selectedProductId;
  String _unit = 'g';
  DateTime? _expirationDate;

  final _quantityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool get _isDirty =>
      _selectedProductId != null ||
      _quantityCtrl.text.isNotEmpty ||
      _notesCtrl.text.isNotEmpty ||
      _expirationDate != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select('id, name, default_unit')
          .order('name');
      setState(() {
        _products = List<Map<String, dynamic>>.from(data);
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() => _loadingProducts = false);
      Get.snackbar('Hata', 'Ürünler yüklenemedi: $e');
    }
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
              Navigator.of(context).pop(); // dialog kapat
              Navigator.of(context).pop(); // sheet kapat
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
        child: _loadingProducts
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('Paket Ekle',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _tryClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ürün seçici
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Ürün *',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedProductId,
                    items: _products
                        .map((p) => DropdownMenuItem<String>(
                              value: p['id'] as String,
                              child: Text(p['name'] as String),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      final product =
                          _products.firstWhere((p) => p['id'] == val);
                      setState(() {
                        _selectedProductId = val;
                        _unit = product['default_unit'] as String? ?? 'g';
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Miktar + Birim
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Miktar *',
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
                  const SizedBox(height: 4),

                  // Son kullanma tarihi
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _expirationDate == null
                          ? 'Son kullanma tarihi (opsiyonel)'
                          : 'SKT: ${DateFormat('dd.MM.yyyy').format(_expirationDate!)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: _expirationDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _expirationDate = null),
                          )
                        : null,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setState(() => _expirationDate = picked);
                      }
                    },
                  ),

                  // Notlar
                  TextField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notlar (opsiyonel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Rafa Ekle'),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedProductId == null) {
      Get.snackbar('Hata', 'Lütfen bir ürün seçin.');
      return;
    }
    final qty = double.tryParse(_quantityCtrl.text.trim());
    if (qty == null || qty <= 0) {
      Get.snackbar('Hata', 'Geçerli bir miktar girin.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _supabase.from('packages').insert({
        'product_id': _selectedProductId,
        'shelf_id': widget.shelfId,
        'quantity': qty,
        'unit': _unit,
        if (_expirationDate != null)
          'expiration_date':
              _expirationDate!.toIso8601String().substring(0, 10),
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      });
      if (mounted) Navigator.of(context).pop();
      widget.onAdded();
      Get.snackbar('Eklendi', 'Paket rafa eklendi.');
    } catch (e) {
      Get.snackbar('Hata', 'Paket eklenemedi: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
