import 'package:get/get.dart';

import '../controllers/shelves_list_controller.dart';

class ShelvesListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShelvesListController>(() => ShelvesListController());
  }
}
