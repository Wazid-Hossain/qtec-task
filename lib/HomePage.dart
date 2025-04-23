import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtec_task/api services/model.dart';
import 'package:qtec_task/riverpod/Riverpod Providers.dart';
import 'package:qtec_task/ProductNotifier/product_notifier.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedProductProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(paginatedProductProvider);
    final notifier = ref.read(paginatedProductProvider.notifier);
    final isLoading = ref.watch(isLoadingProvider);
    final hasMore = ref.watch(hasMoreProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final sortType = ref.watch(sortTypeProvider);

    // Filter & sort client-side
    var displayed =
        products.where((p) {
          final title = p.title?.toLowerCase() ?? '';
          return title.contains(searchQuery.toLowerCase());
        }).toList();

    if (sortType == SortType.highToLow) {
      displayed.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    } else if (sortType == SortType.lowToHigh) {
      displayed.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else if (sortType == SortType.rating) {
      displayed.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          'AL-Hamra',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (searchQuery.isNotEmpty)
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!isLoading &&
                    hasMore &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                  notifier.fetchMore();
                }
                return false;
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: hasMore ? displayed.length + 5 : displayed.length,
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
                itemBuilder: (context, index) {
                  if (index >= displayed.length) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }

                  final p = displayed[index];
                  bool isFavorite = false;

                  // Safely encode URL
                  final rawUrl = p.thumbnail ?? p.images?.first ?? '';
                  final imageUrl =
                      rawUrl.isNotEmpty ? Uri.encodeFull(rawUrl) : '';

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to detail page
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child:
                                    imageUrl.isEmpty
                                        ? const Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey,
                                        )
                                        : Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stack,
                                          ) {
                                            return const Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.title ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${p.price?.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  Text(
                                    '${p.rating?.toStringAsFixed(1) ?? '0.0'}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if ((p.stock ?? 0) <= 0)
                                const Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged:
                  (q) => ref.read(searchQueryProvider.notifier).state = q,
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.black54),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showSortOptions(),
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

  void _showSortOptions() {
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
                title: const Text('Price - High to Low'),
                onTap: () {
                  ref.read(sortTypeProvider.notifier).state =
                      SortType.highToLow;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Price - Low to High'),
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
            ],
          ),
    );
  }
}
