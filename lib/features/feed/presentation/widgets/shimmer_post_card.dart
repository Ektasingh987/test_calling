import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';

class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceCard,
      highlightColor: AppTheme.surface,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const _ShimmerBox(width: 44, height: 44, radius: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _ShimmerBox(width: 120, height: 13),
                    SizedBox(height: 6),
                    _ShimmerBox(width: 80, height: 11),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Caption lines
            const _ShimmerBox(width: double.infinity, height: 13),
            const SizedBox(height: 6),
            const _ShimmerBox(width: 200, height: 13),
            const SizedBox(height: 14),
            // Image placeholder
            const _ShimmerBox(
              width: double.infinity,
              height: 200,
              radius: 12,
            ),
            const SizedBox(height: 14),
            // Action row
            Row(
              children: const [
                _ShimmerBox(width: 60, height: 14),
                SizedBox(width: 20),
                _ShimmerBox(width: 60, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

