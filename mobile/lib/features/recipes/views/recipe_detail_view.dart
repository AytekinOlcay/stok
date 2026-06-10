import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../controllers/recipe_detail_controller.dart';

class RecipeDetailView extends GetView<RecipeDetailController> {
  const RecipeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarif')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final recipe = controller.recipe.value;
        if (recipe == null) {
          return const Center(child: Text('Tarif bulunamadı.'));
        }

        final title = recipe['title'] as String? ?? '';
        final description = recipe['description'] as String?;
        final prepTime = recipe['prep_time_min'] as int?;
        final videoSource = recipe['video_source'] as String?;
        final videoUrl = recipe['video_url'] as String?;
        final videoEmbedUrl = recipe['video_embed_url'] as String?;

        // Sort ingredients
        final rawProducts = recipe['recipe_products'];
        List<Map<String, dynamic>> ingredients;
        if (rawProducts is List) {
          ingredients = List<Map<String, dynamic>>.from(rawProducts);
          ingredients.sort((a, b) =>
              ((a['sort_order'] as int?) ?? 0)
                  .compareTo((b['sort_order'] as int?) ?? 0));
        } else {
          ingredients = <Map<String, dynamic>>[];
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Video section ────────────────────────────────────────────
            if (videoSource == 'youtube' && videoEmbedUrl != null)
              _YouTubeEmbed(embedUrl: videoEmbedUrl)
            else if (videoSource == 'vimeo' && videoEmbedUrl != null)
              _VimeoEmbed(embedUrl: videoEmbedUrl)
            else if (videoUrl != null && videoUrl.isNotEmpty)
              _ExternalVideoButton(url: videoUrl, source: videoSource),

            if (videoSource != null) const SizedBox(height: 16),

            // ── Title & meta ─────────────────────────────────────────────
            Text(title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            if (prepTime != null)
              Row(children: [
                const Icon(Icons.timer_outlined, size: 16),
                const SizedBox(width: 4),
                Text('$prepTime dakika',
                    style: Theme.of(context).textTheme.bodySmall),
              ]),

            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              MarkdownBody(
                data: description,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: Theme.of(context).textTheme.bodyMedium,
                ),
                onTapLink: (text, href, title) async {
                  if (href != null) {
                    final uri = Uri.parse(href);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
              ),
            ],

            // ── Ingredients ──────────────────────────────────────────────
            if (ingredients.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('🥦 Malzemeler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...ingredients.map((rp) => _IngredientTile(rp: rp)),
            ],
          ],
        );
      }),
    );
  }
}

// ── YouTube embed using youtube_player_flutter ───────────────────────────────
class _YouTubeEmbed extends StatefulWidget {
  final String embedUrl;
  const _YouTubeEmbed({required this.embedUrl});

  @override
  State<_YouTubeEmbed> createState() => _YouTubeEmbedState();
}

class _YouTubeEmbedState extends State<_YouTubeEmbed> {
  late YoutubePlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    // Extract video ID from embed URL: .../embed/{id}?...
    final id = YoutubePlayer.convertUrlToId(widget.embedUrl) ??
        Uri.parse(widget.embedUrl).pathSegments.last.split('?').first;
    _ctrl = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _ctrl,
      showVideoProgressIndicator: true,
    );
  }
}

// ── Vimeo embed via WebView ───────────────────────────────────────────────────
class _VimeoEmbed extends StatefulWidget {
  final String embedUrl;
  const _VimeoEmbed({required this.embedUrl});

  @override
  State<_VimeoEmbed> createState() => _VimeoEmbedState();
}

class _VimeoEmbedState extends State<_VimeoEmbed> {
  late WebViewController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: WebViewWidget(controller: _ctrl),
      ),
    );
  }
}

// ── External link button (Instagram / TikTok / other) ────────────────────────
class _ExternalVideoButton extends StatelessWidget {
  final String url;
  final String? source;
  const _ExternalVideoButton({required this.url, this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Video mevcut',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Bu platform embed desteklemiyor.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(source?.toUpperCase() ?? 'AÇ'),
          ),
        ],
      ),
    );
  }
}

// ── Ingredient tile ───────────────────────────────────────────────────────────
class _IngredientTile extends StatelessWidget {
  final Map<String, dynamic> rp;
  const _IngredientTile({required this.rp});

  @override
  Widget build(BuildContext context) {
    final product = rp['products'] as Map<String, dynamic>?;
    final name = product?['name'] as String? ?? '?';
    final defaultUnit = product?['default_unit'] as String? ?? '';
    final qty = rp['quantity'];
    final unit = rp['unit'] as String? ?? defaultUnit;

    String qtyText = '';
    if (qty != null) {
      final numQty = (qty as num).toDouble();
      qtyText = '${numQty % 1 == 0 ? numQty.toInt() : numQty} $unit';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(name)),
          if (qtyText.isNotEmpty)
            Text(qtyText,
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
