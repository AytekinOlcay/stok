import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipesController extends GetxController {
  final _supabase = Supabase.instance.client;

  final isLoading = true.obs;
  final recipes = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    isLoading.value = true;
    try {
      final data = await _supabase
          .from('recipes')
          .select('id, title, description, prep_time_min, video_source, video_thumbnail, recipe_products(count)')
          .order('created_at', ascending: false);
      recipes.value = List<Map<String, dynamic>>.from(data as List);
    } catch (e) {
      Get.snackbar('Hata', 'Tarifler yüklenemedi: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
