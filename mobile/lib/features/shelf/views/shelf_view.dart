import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/shelf_controller.dart';

class ShelfView extends GetView<ShelfController> {
  const ShelfView({super.key});

  @override
  Widget build(BuildContext context) {
    final shelfId = Get.parameters['id'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Shelf Details')),
      body: Center(
        child: Text('Shelf ID: $shelfId'),
      ),
    );
  }
}
