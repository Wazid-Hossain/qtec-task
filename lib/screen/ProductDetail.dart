import 'package:flutter/material.dart';
import 'package:qtec_task/api%20services/model.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final disc = product.discountPercentage ?? 0;
    final price = product.price ?? 0;
    final original = disc > 0 ? price * 100 / (100 - disc) : price;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? 'Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.thumbnail ?? '',
                height: 200,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.title ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '\$${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (disc > 0) ...[
                  Text(
                    '\$${original.toStringAsFixed(0)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${disc.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              product.description ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text('Category: ${product.category ?? '-'}'),
            Text('Stock: ${product.stock ?? 0}'),
            Text('Rating: ${product.rating?.toStringAsFixed(1) ?? '0.0'}'),
          ],
        ),
      ),
    );
  }
}
