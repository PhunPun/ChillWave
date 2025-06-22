import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';
import '../../../controllers/search_controller.dart' as mysearch;
import '../../../widgets/search_components.dart';

class SearchHistorySection extends StatelessWidget {
  final mysearch.SearchController controller;

  const SearchHistorySection({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHistoryHeader(),
          const SizedBox(height: 16),
          Expanded(
            child:
                controller.history.isEmpty
                    ? _buildEmptyHistory()
                    : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Lịch sử tìm kiếm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(MyColor.se4),
          ),
        ),
        if (controller.history.isNotEmpty)
          TextButton.icon(
            onPressed: () => controller.clearSearch(fromUser: true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Xóa tất cả'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(MyColor.pr5),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Color(MyColor.grey)),
          SizedBox(height: 16),
          Text(
            'Chưa có lịch sử tìm kiếm',
            style: TextStyle(color: Color(MyColor.grey), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: controller.history.length,
      itemBuilder: (context, index) {
        final query = controller.history[index];
        return AnimatedSearchCard(
          index: index,
          child: SearchHistoryItem(
            query: query,
            onTap: () => controller.selectHistoryItem(query),
            onDelete: () => controller.removeFromHistory(query),
          ),
        );
      },
    );
  }
}
