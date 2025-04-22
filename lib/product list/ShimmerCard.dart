import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Container(color: Colors.grey, width: double.infinity),
            ),
            const SizedBox(height: 6),
            Container(height: 12, color: Colors.grey),
            const SizedBox(height: 6),
            Container(height: 12, width: 60, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
