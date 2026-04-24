import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/session_service.dart';

class StatisticsController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = true.obs;
  // List of {product_name, total_quantity, unit}
  final consumption = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final orgId = Get.find<SessionService>().currentOrgId;
      final data = await _supabase
          .from('inventory_logs')
          .select('quantity, products(name, default_unit)')
          .eq('org_id', orgId)
          .eq('action_type', 'package_removed');

      // Aggregate in Dart: sum quantity per product
      final Map<String, Map<String, dynamic>> agg = {};
      for (final row in data as List) {
        final product = row['products'] as Map<String, dynamic>?;
        if (product == null) continue;
        final name = product['name'] as String;
        final unit = product['default_unit'] as String;
        final qty = ((row['quantity'] as num?) ?? 0).toDouble().abs();
        if (agg.containsKey(name)) {
          agg[name]!['total'] = (agg[name]!['total'] as double) + qty;
        } else {
          agg[name] = {'product_name': name, 'unit': unit, 'total': qty};
        }
      }

      final sorted = agg.values.toList()
        ..sort((a, b) =>
            (b['total'] as double).compareTo(a['total'] as double));
      consumption.value = sorted;
    } catch (e) {
      Get.snackbar('Hata', 'İstatistikler yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
