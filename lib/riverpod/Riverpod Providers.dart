import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/ProductNotifier/product_notifier.dart';
import 'package:qtec_task/ProductNotifier/product_repository.dart';
import 'package:qtec_task/api_services/model.dart';
import 'package:qtec_task/riverpod/PaginatedProductNotifier.dart';

enum SortType { highToLow, lowToHigh, rating }

final searchQueryProvider = StateProvider<String>((_) => '');
final sortTypeProvider = StateProvider<SortType?>((_) => null);

final productRepositoryProvider = Provider((_) => ProductRepository());

final productListProvider =
    StateNotifierProvider<ProductNotifier, List<ProductModel>>(
      (ref) => ProductNotifier(ref.read(productRepositoryProvider)),
    );

final paginatedProductProvider = StateNotifierProvider<
  PaginatedProductNotifier,
  List<ProductModel>
>((ref) => PaginatedProductNotifier(ref, ref.read(productRepositoryProvider)));

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(paginatedProductProvider.notifier).isLoading;
});

final hasMoreProvider = Provider<bool>((ref) {
  return ref.watch(paginatedProductProvider.notifier).hasMore;
});
