import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/ProductNotifier/product_notifier.dart';
import 'package:qtec_task/api services/model.dart';
import 'package:qtec_task/riverpod/ShimmerCard.dart';

enum SortType { highToLow, lowToHigh, rating }

final searchQueryProvider = StateProvider<String>((_) => '');
final sortTypeProvider = StateProvider<SortType?>((_) => null);

class Homepage extends ConsumerStatefulWidget {
  const Homepage({Key? key}) : super(key: key);
  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController()..addListener(() {
          ref.read(searchQueryProvider.notifier).state = _searchController.text;
        });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedProductProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(paginatedProductProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final hasMore = ref.watch(hasMoreProvider);

    // client‐side filter & sort
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final sort = ref.watch(sortTypeProvider);

    var displayed =
        items.where((p) {
          return p.title?.toLowerCase().contains(query) ?? false;
        }).toList();

    if (sort == SortType.highToLow) {
      displayed.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    } else if (sort == SortType.lowToHigh) {
      displayed.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else if (sort == SortType.rating) {
      displayed.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    // one shimmer at the end while loading
    final totalCount = displayed.length + (hasMore ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AL-Hamra'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          _buildSearchAndSortBar(),
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Showing ${displayed.length} result'
                '${displayed.length == 1 ? '' : 's'}',
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
              itemCount: totalCount,
              itemBuilder: (ctx, i) {
                if (hasMore && i == displayed.length) {
                  // trigger load of next page
                  ref.read(paginatedProductProvider.notifier).fetchMore();
                  return const ShimmerCard();
                }
                final p = displayed[i];
                return _ProductCard(product: p);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search anything…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showSortSheet,
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

  void _showSortSheet() {
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

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // decode and re-encode thumbnail
    final raw = product.thumbnail ?? '';
    final decoded = raw.isNotEmpty ? Uri.decodeFull(raw) : '';
    final url = decoded.isNotEmpty ? Uri.encodeFull(decoded) : '';

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
                  (c, _, __) => const Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey,
                  ),
            );

    final price = product.price ?? 0;
    final disc = product.discountPercentage ?? 0;
    final orig = disc > 0 ? price * 100 / (100 - disc) : price;

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
                product.title ?? '',
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
                      '\$${orig.toStringAsFixed(0)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$disc% OFF',
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
                    '${(product.rating ?? 0).toStringAsFixed(1)} (${product.stock ?? 0})',
                  ),
                ],
              ),
              if ((product.stock ?? 0) <= 0) ...[
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

        // favorite icon (toggle locally)
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () {},
            child: const Icon(Icons.favorite_border, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
