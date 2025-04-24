import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api_services/model.dart';
import 'package:qtec_task/ProductNotifier/product_repository.dart';

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super([]) {
    fetchMore();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _skip = 0;
  static const int _limit = 10;

  Future<void> fetchMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;

    try {
      final newItems = await _repository.fetchProducts(
        limit: _limit,
        skip: _skip,
      );

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        state = [...state, ...newItems];
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
