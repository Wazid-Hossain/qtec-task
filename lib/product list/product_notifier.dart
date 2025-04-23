import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api_servies.dart';
import 'package:qtec_task/model.dart';

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  ProductNotifier() : super([]) {
    fetchMore();
  }

  bool _isLoading = false;
  int _skip = 0;
  final int _limit = 10;
  bool _hasMore = true;

  Future<void> fetchMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

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

    _isLoading = false;
  }

  void reset() {
    state = [];
    _skip = 0;
    _hasMore = true;
    fetchMore();
  }
}

final paginatedProductProvider =
    StateNotifierProvider<ProductNotifier, List<ProductModel>>((ref) {
      return ProductNotifier();
    });
