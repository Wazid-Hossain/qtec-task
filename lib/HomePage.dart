import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/ProductNotifier/product_notifier.dart';
import 'model.dart';

enum SortType { highToLow, lowToHigh, rating }

final searchQueryProvider = StateProvider<String>((_) => '');
final sortProvider = StateProvider<SortType?>((_) => null);

class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productProvider);
    final search = ref.watch(searchQueryProvider).toLowerCase();
    final sort = ref.watch(sortProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AL-Hamra')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          // 1) filter
          var list =
              all.where((p) {
                return p.title?.toLowerCase().contains(search) ?? false;
              }).toList();

          // 2) sort
          if (sort == SortType.highToLow) {
            list.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          } else if (sort == SortType.lowToHigh) {
            list.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          } else if (sort == SortType.rating) {
            list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
          }

          return Column(
            children: [
              _buildSearchAndSortBar(ref),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        (MediaQuery.of(context).size.width / 180)
                            .floor()
                            .clamp(2, 4)
                            .toInt(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) => _ProductCard(product: list[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndSortBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged:
                  (q) => ref.read(searchQueryProvider.notifier).state = q,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            onSelected: (s) => ref.read(sortProvider.notifier).state = s,
            itemBuilder:
                (_) => [
                  const PopupMenuItem(
                    value: SortType.highToLow,
                    child: Text('Price ↓'),
                  ),
                  const PopupMenuItem(
                    value: SortType.lowToHigh,
                    child: Text('Price ↑'),
                  ),
                  const PopupMenuItem(
                    value: SortType.rating,
                    child: Text('Rating'),
                  ),
                ],
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // Build and encode URL
    final raw = product.thumbnail ?? '';
    final url = raw.isNotEmpty ? Uri.encodeFull(raw) : '';

    Widget imageWidget;
    if (url.isEmpty) {
      imageWidget = const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey,
      );
    } else {
      imageWidget = Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder:
            (c, child, prog) =>
                prog == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
        errorBuilder:
            (c, e, st) =>
                const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: imageWidget,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text('\$${(product.price ?? 0).toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${(product.rating ?? 0).toStringAsFixed(1)} '
                '(${product.stock ?? 0})',
              ),
            ],
          ),
          if ((product.stock ?? 0) <= 0)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Out of Stock', style: TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
