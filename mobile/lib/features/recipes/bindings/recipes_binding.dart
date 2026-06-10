import 'package:get/get.dart';
import '../controllers/recipes_controller.dart';

class RecipesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecipesController>(() => RecipesController());
  }
}
