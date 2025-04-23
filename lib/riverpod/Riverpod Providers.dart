// lib/providers/product_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/ProductNotifier/ProductRepository.dart';
import 'package:qtec_task/api%20services/model.dart';

enum SortType { highToLow, lowToHigh, rating }

final productRepositoryProvider = Provider((ref) => ProductRepository());

final sortTypeProvider = StateProvider<SortType?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final productListProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  final sortType = ref.watch(sortTypeProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final products = await repository.fetchProducts();

  final filtered =
      products.where((product) {
        final title = product.title?.toLowerCase() ?? '';
        return title.contains(searchQuery);
      }).toList();

  if (sortType == SortType.highToLow) {
    filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
  } else if (sortType == SortType.lowToHigh) {
    filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
  } else if (sortType == SortType.rating) {
    filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  }

  return filtered;
});
