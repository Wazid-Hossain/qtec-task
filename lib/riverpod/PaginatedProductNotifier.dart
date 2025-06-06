import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api_services/model.dart';
import 'package:qtec_task/ProductNotifier/product_repository.dart';
import 'package:qtec_task/riverpod/Riverpod Providers.dart';

class PaginatedProductNotifier extends StateNotifier<List<ProductModel>> {
  final Ref ref;
  final ProductRepository repository;

  int _page = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];

  PaginatedProductNotifier(this.ref, this.repository) : super([]) {
    fetchProducts();
    ref.listen<String>(
      searchQueryProvider,
      (_, __) => _onSearchOrSortChanged(),
    );
    ref.listen<SortType?>(
      sortTypeProvider,
      (_, __) => _onSearchOrSortChanged(),
    );
  }

  Future<void> fetchProducts() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final response = await repository.fetchProducts(
        limit: _limit,
        skip: _page * _limit,
      );
      _allProducts = [..._allProducts, ...response];
      _filteredProducts = _applyFilterAndSort();
      _hasMore = response.length == _limit;
      state = _filteredProducts.take((_page + 1) * _limit).toList();
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
    }
  }

  void fetchMore() {
    if (_isLoading || !_hasMore) return;
    _page++;
    fetchProducts();
  }

  void _onSearchOrSortChanged() {
    _filteredProducts = _applyFilterAndSort();
    _page = 0;
    _hasMore = _filteredProducts.length > _limit;
    state = _filteredProducts.take(_limit).toList();
  }

  List<ProductModel> _applyFilterAndSort() {
    final query = ref.read(searchQueryProvider).toLowerCase();
    final sort = ref.read(sortTypeProvider);
    List<ProductModel> filtered = [..._allProducts];

    if (query.isNotEmpty) {
      filtered =
          filtered
              .where((p) => (p.title ?? '').toLowerCase().contains(query))
              .toList();
    }

    switch (sort) {
      case SortType.highToLow:
        filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case SortType.lowToHigh:
        filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case SortType.rating:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      default:
        break;
    }

    return filtered;
  }

  void reset() {
    _page = 0;
    _hasMore = true;
    _allProducts = [];
    _filteredProducts = [];
    state = [];
    fetchProducts();
  }

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
}
