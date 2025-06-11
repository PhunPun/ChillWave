import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SongCardSkeleton extends StatelessWidget {
  const SongCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 30),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 8,
                        width: 70,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
