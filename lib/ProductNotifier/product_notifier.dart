import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api%20services/api_servies.dart';
import 'package:qtec_task/api%20services/model.dart';

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  ProductNotifier() : super([]) {
    fetchMore();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _skip = 0;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> fetchMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    try {
      final newProducts = await ApiService.fetchProducts(
        limit: _limit,
        skip: _skip,
      );
      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        state = [...state, ...newProducts];
        _skip += _limit;
      }
    } catch (e) {
      print('Error fetching products: $e');
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
      (ref) => ProductNotifier(),
    );

final isLoadingProvider = Provider<bool>(
  (ref) => ref.watch(paginatedProductProvider.notifier).isLoading,
);

final hasMoreProvider = Provider<bool>(
  (ref) => ref.watch(paginatedProductProvider.notifier).hasMore,
);
