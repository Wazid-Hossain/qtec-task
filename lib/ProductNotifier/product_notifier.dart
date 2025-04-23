import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api_services/api_servies.dart';
import 'package:qtec_task/api_services/model.dart';

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  ProductNotifier() : super([]) {
    fetchMore();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _skip = 0;
  static const _limit = 10;

  Future<void> fetchMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    try {
      final newItems = await ApiService.fetchProducts(
        limit: _limit,
        skip: _skip,
      );
      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        state = [...state, ...newItems];
        _skip += _limit;
      }
    } finally {
      _isLoading = false;
    }
  }

  void reset() {
    state = [];
    _skip = 0;
    _hasMore = true;
    fetchMore();
  }
}

final paginatedProductProvider =
    StateNotifierProvider<ProductNotifier, List<ProductModel>>(
      (_) => ProductNotifier(),
    );

final isLoadingProvider = Provider<bool>(
  (ref) => ref.watch(paginatedProductProvider.notifier).isLoading,
);
final hasMoreProvider = Provider<bool>(
  (ref) => ref.watch(paginatedProductProvider.notifier).hasMore,
);
