import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/ProductNotifier/product_notifier.dart';
import 'model.dart';

enum SortType { highToLow, lowToHigh, rating }

final searchQueryProvider = StateProvider<String>((_) => '');
final sortTypeProvider = StateProvider<SortType?>((_) => null);

class Homepage extends ConsumerWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productProvider);
    final search = ref.watch(searchQueryProvider).toLowerCase();
    final sort = ref.watch(sortTypeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AL-Hamra')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (all) {
          // 1) filter by search
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
              _buildSearchAndSortBar(context, ref),
              if (search.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Showing ${list.length} result${list.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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

  Widget _buildSearchAndSortBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged:
                  (q) => ref.read(searchQueryProvider.notifier).state = q,
              decoration: InputDecoration(
                hintText: 'Search anything...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showSortSheet(context, ref),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sort, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Price: High → Low'),
                onTap: () {
                  ref.read(sortTypeProvider.notifier).state =
                      SortType.highToLow;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Price: Low → High'),
                onTap: () {
                  ref.read(sortTypeProvider.notifier).state =
                      SortType.lowToHigh;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Rating'),
                onTap: () {
                  ref.read(sortTypeProvider.notifier).state = SortType.rating;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool isFav = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final disc = p.discountPercentage ?? 0;
    final price = p.price ?? 0;
    final original = disc > 0 ? price * 100 / (100 - disc) : price;

    // 1) grab the raw thumbnail URL
    final raw = p.thumbnail ?? '';

    // 2) decode any existing % escapes, then encode once:
    String url = '';
    if (raw.isNotEmpty) {
      final decoded = Uri.decodeFull(raw);
      url = Uri.encodeFull(decoded);
    }

    // 3) build the image widget with loading and error fallback
    final image =
        url.isEmpty
            ? const Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            )
            : Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder:
                  (c, child, prog) =>
                      prog == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
              errorBuilder:
                  (c, e, st) => const Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey,
                  ),
            );

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(child: image),
              const SizedBox(height: 6),
              Text(
                p.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (disc > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '\$${original.toStringAsFixed(0)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${disc.toStringAsFixed(0)}% OFF',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${(p.rating ?? 0).toStringAsFixed(1)} (${p.stock ?? 0})',
                  ),
                ],
              ),
              if ((p.stock ?? 0) <= 0) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Out of Stock',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),

        // favorite icon
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => setState(() => isFav = !isFav),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
