import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeDetailController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final recipe = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    final id = Get.parameters['id'];
    if (id != null) fetchRecipe(id);
  }

  Future<void> fetchRecipe(String id) async {
    isLoading.value = true;
    try {
      final data = await _supabase
          .from('recipes')
          .select('''
            *,
            recipe_products (
              id,
              quantity,
              unit,
              sort_order,
              products ( id, name, default_unit )
            )
          ''')
          .eq('id', id)
          .single();
      recipe.value = Map<String, dynamic>.from(data as Map);
    } catch (e) {
      Get.snackbar('Hata', 'Tarif yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
