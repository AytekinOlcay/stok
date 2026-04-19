import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/shelves_list_controller.dart';

class ShelvesListView extends GetView<ShelvesListController> {
  const ShelvesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shelves'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchShelves,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final shelves = controller.shelves;
        if (shelves.isEmpty) {
          return const Center(child: Text('No shelves found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: shelves.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final s = shelves[i];
            final name = s['name'] as String? ?? 'Shelf ${s['position']}';
            final position = s['position'] as int;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('$position'),
                ),
                title: Text(name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed('/shelf/${s['id']}'),
              ),
            );
          },
        );
      }),
    );
  }
}
