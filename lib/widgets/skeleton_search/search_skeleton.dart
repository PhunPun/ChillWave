import 'package:flutter/material.dart';
import '../../themes/colors/colors.dart';

class SearchSkeletonLoader extends StatefulWidget {
  const SearchSkeletonLoader({Key? key}) : super(key: key);

  @override
  State<SearchSkeletonLoader> createState() => _SearchSkeletonLoaderState();
}

class _SearchSkeletonLoaderState extends State<SearchSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search results header skeleton
              Row(
                children: [
                  _buildShimmerBox(width: 120, height: 20),
                  const Spacer(),
                  _buildShimmerBox(width: 80, height: 20),
                ],
              ),
              const SizedBox(height: 20),

              // Search result items skeleton
              Expanded(
                child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildSearchResultSkeleton(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultSkeleton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(MyColor.pr2),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _animation.value, 0.0),
          end: Alignment(1.0 + 2.0 * _animation.value, 0.0),
          colors: [
            const Color(MyColor.se1).withOpacity(0.3),
            const Color(MyColor.se1).withOpacity(0.6),
            const Color(MyColor.se1).withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class TrendingSkeletonLoader extends StatefulWidget {
  const TrendingSkeletonLoader({Key? key}) : super(key: key);

  @override
  State<TrendingSkeletonLoader> createState() => _TrendingSkeletonLoaderState();
}

class _TrendingSkeletonLoaderState extends State<TrendingSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GridView.builder(
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
        );
      },
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShimmerBox(width: double.infinity, height: 12),
                  const SizedBox(height: 4),
                  _buildShimmerBox(width: 100, height: 10),
                ],
              ),
            ),
          ),
        ],
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
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _animation.value, 0.0),
          end: Alignment(1.0 + 2.0 * _animation.value, 0.0),
          colors: [
            const Color(MyColor.se1).withOpacity(0.3),
            const Color(MyColor.se1).withOpacity(0.6),
            const Color(MyColor.se1).withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
