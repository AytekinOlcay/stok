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
      Get.snackbar('Error', 'Failed to load products: $e');
    }
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
                    Text('Add Package',
                        style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product selector
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Product *',
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

                // Quantity + Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _quantityCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
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

                // Expiration date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _expirationDate == null
                        ? 'Expiration date (optional)'
                        : 'Expires: ${DateFormat('dd.MM.yyyy').format(_expirationDate!)}',
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

                // Notes
                TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
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
                      : const Text('Add to Shelf'),
                ),
              ],
            ),
    );
  }

  Future<void> _submit() async {
    if (_selectedProductId == null) {
      Get.snackbar('Validation', 'Please select a product.');
      return;
    }
    final qty = double.tryParse(_quantityCtrl.text.trim());
    if (qty == null || qty <= 0) {
      Get.snackbar('Validation', 'Please enter a valid quantity.');
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
      if (mounted) Get.back();
      widget.onAdded();
      Get.snackbar('Added', 'Package added to shelf.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add package: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
