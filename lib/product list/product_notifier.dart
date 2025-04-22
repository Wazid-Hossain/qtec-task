import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/model.dart';
import 'package:qtec_task/api_servies.dart';

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  ProductNotifier() : super([]) {
    fetchMore();
  }

  bool isLoading = false;
  int _skip = 0;
  final int _limit = 10;

  Future<void> fetchMore() async {
    if (isLoading) return;
    isLoading = true;

    final products = await ApiService.fetchProducts(limit: _limit, skip: _skip);
    state = [...state, ...products];
    _skip += _limit;
    isLoading = false;
  }

  void reset() {
    state = [];
    _skip = 0;
    fetchMore();
  }
}

final paginatedProductProvider =
    StateNotifierProvider<ProductNotifier, List<ProductModel>>((ref) {
      return ProductNotifier();
    });
