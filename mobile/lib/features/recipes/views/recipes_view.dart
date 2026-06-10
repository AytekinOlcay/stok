import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/recipes_controller.dart';

class RecipesView extends GetView<RecipesController> {
  const RecipesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchRecipes,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final recipes = controller.recipes;

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🍳', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 12),
                Text(
                  'Henüz tarif eklenmemiş.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tarifler web admin panelinden eklenebilir.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchRecipes,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final r = recipes[i];
              return _RecipeCard(recipe: r);
            },
          ),
        );
      }),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] as String? ?? '';
    final description = recipe['description'] as String?;
    final prepTime = recipe['prep_time_min'] as int?;
    final videoSource = recipe['video_source'] as String?;
    final thumbnail = recipe['video_thumbnail'] as String?;

    // recipe_products: [{count: N}]
    final rpList = recipe['recipe_products'];
    int ingredientCount = 0;
    if (rpList is List && rpList.isNotEmpty) {
      ingredientCount = ((rpList.first as Map)['count'] as int?) ?? 0;
    }

    return GestureDetector(
      onTap: () => Get.toNamed('/recipe/${recipe['id']}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (thumbnail != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(thumbnail, fit: BoxFit.cover),
                    if (videoSource != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(153),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            videoSource.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(
                height: 80,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Text('🍳', style: TextStyle(fontSize: 36)),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (prepTime != null) ...[
                        const Icon(Icons.timer_outlined, size: 14),
                        const SizedBox(width: 3),
                        Text('$prepTime dk', style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                      ],
                      if (ingredientCount > 0) ...[
                        const Text('🥦', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 3),
                        Text('$ingredientCount malzeme', style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
