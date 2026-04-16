import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/package_controller.dart';

class PackageView extends GetView<PackageController> {
  const PackageView({super.key});

  @override
  Widget build(BuildContext context) {
    final packageId = Get.parameters['id'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('Package Details')),
      body: Center(
        child: Text('Package ID: $packageId'),
      ),
    );
  }
}
