import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api_services/model.dart';
import 'package:qtec_task/riverpod/Riverpod%20Providers.dart';
import 'package:qtec_task/riverpod/ShimmerCard.dart';
import 'package:qtec_task/screen/ProductDetail.dart';

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
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final sort = ref.watch(sortTypeProvider);

    var displayed =
        items
            .where((p) => p.title?.toLowerCase().contains(query) ?? false)
            .toList();

    if (sort == SortType.highToLow) {
      displayed.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    } else if (sort == SortType.lowToHigh) {
      displayed.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else if (sort == SortType.rating) {
      displayed.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    final totalCount = displayed.length + (hasMore ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qtec Task'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchAndSortBar(),
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Showing ${displayed.length} result${displayed.length == 1 ? '' : 's'}',
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
                crossAxisCount: (MediaQuery.of(context).size.width / 180)
                    .floor()
                    .clamp(2, 4),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: totalCount,
              itemBuilder: (ctx, i) {
                if (hasMore && i == displayed.length) {
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
    final raw = p.thumbnail ?? '';
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

    final price = p.price ?? 0;
    final disc = p.discountPercentage ?? 0;
    final orig = disc > 0 ? price * 100 / (100 - disc) : price;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
        );
      },
      child: Stack(
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
                    Flexible(
                      child: Text(
                        '\$${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (disc > 0) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '\$${orig.toStringAsFixed(0)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '$disc% OFF',
                          style: const TextStyle(color: Colors.orange),
                          overflow: TextOverflow.ellipsis,
                        ),
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
              ],
            ),
          ),

          // Favorite button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFav = !isFav;
                });
              },
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.grey,
              ),
            ),
          ),

          // Out of Stock label below favorite icon
          if ((p.stock ?? 0) <= 0)
            Positioned(
              top: 36,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Out of Stock',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
