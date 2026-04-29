import 'package:get/get.dart';

import '../controllers/join_org_controller.dart';

class JoinOrgBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinOrgController>(() => JoinOrgController());
  }
}
