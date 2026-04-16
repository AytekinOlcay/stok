import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/statistics_controller.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchStats,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = controller.consumption;
        if (items.isEmpty) {
          return const Center(
              child: Text('No consumption data yet.\nStart removing packages to track usage.',
                  textAlign: TextAlign.center));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Total Consumption',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.map((item) => _ConsumptionTile(
                  name: item['product_name'] as String,
                  total: item['total'] as double,
                  unit: item['unit'] as String,
                )),
          ],
        );
      }),
    );
  }
}

class _ConsumptionTile extends StatelessWidget {
  final String name;
  final double total;
  final String unit;
  const _ConsumptionTile(
      {required this.name, required this.total, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(name),
        trailing: Text(
          '${total.toStringAsFixed(0)} $unit',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
