import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchController extends GetxController {
  final _supabase = Supabase.instance.client;

  static const _pageSize = 20;

  final query = ''.obs;
  final results = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  final scrollController = ScrollController();
  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    debounce(query, (_) => _resetAndLoad(), time: const Duration(milliseconds: 400));
    scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 250) {
      _loadMore();
    }
  }

  void _resetAndLoad() {
    _offset = 0;
    results.clear();
    hasMore.value = true;
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (isLoadingMore.value || (!hasMore.value)) return;

    if (_offset == 0) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final q = query.value.trim();
      final List<dynamic> response;

      if (q.isEmpty) {
        response = await _supabase
            .from('packages')
            .select('*, products(*), shelves(*)')
            .order('added_at', ascending: false)
            .range(_offset, _offset + _pageSize - 1);
      } else {
        response = await _supabase
            .from('packages')
            .select('*, products!inner(*), shelves(*)')
            .ilike('products.name', '%$q%')
            .order('added_at', ascending: false)
            .range(_offset, _offset + _pageSize - 1);
      }

      final data = List<Map<String, dynamic>>.from(response);
      if (data.length < _pageSize) hasMore.value = false;
      results.addAll(data);
      _offset += data.length;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
}
