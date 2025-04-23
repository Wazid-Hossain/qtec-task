import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api%20services/api_servies.dart';
import 'package:qtec_task/model.dart';

/// Holds all products (100) and loading / error state.
class ProductNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  ProductNotifier() : super(const AsyncValue.loading()) {
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    try {
      final items = await ApiService.fetchAll();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Pull-to-refresh or manual refresh
  Future<void> refresh() => _fetchAll();
}

final productProvider =
    StateNotifierProvider<ProductNotifier, AsyncValue<List<ProductModel>>>(
      (_) => ProductNotifier(),
    );
