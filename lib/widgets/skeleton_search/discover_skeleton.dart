import 'package:flutter/material.dart';
import '../../themes/colors/colors.dart';

class DiscoverSkeleton extends StatelessWidget {
  const DiscoverSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending Section Header
            _buildShimmerBox(width: 120, height: 24),
            const SizedBox(height: 16),

            // Trending Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildTrendingCardSkeleton();
              },
            ),

            const SizedBox(height: 32),

            // Recent Section Header
            _buildShimmerBox(width: 150, height: 24),
            const SizedBox(height: 16),

            // Recent Songs List
            ...List.generate(
              6,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildSongCardSkeleton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(MyColor.se1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildTrendingCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: _buildShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(width: double.infinity, height: 14),
                  const SizedBox(height: 6),
                  _buildShimmerBox(width: 100, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(MyColor.pr2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildShimmerBox(width: 60, height: 60, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                _buildShimmerBox(width: 150, height: 14),
              ],
            ),
          ),
          _buildShimmerBox(width: 36, height: 36, borderRadius: 18),
        ],
      ),
    );
  }
}
