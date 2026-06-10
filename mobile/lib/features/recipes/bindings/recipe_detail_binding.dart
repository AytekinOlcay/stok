import 'package:get/get.dart';
import '../controllers/recipe_detail_controller.dart';

class RecipeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecipeDetailController>(() => RecipeDetailController());
  }
}
