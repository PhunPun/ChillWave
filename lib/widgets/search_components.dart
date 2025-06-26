import 'package:flutter/material.dart';
import '../themes/colors/colors.dart';
import '../controllers/search_controller.dart' as mysearch;
import 'package:chillwave/controllers/artist_controller.dart';

// Re-export enums from controller
typedef SearchFilter = mysearch.SearchFilter;
typedef SortOption = mysearch.SortOption;

class SearchFilterChips extends StatelessWidget {
  final mysearch.SearchController controller;

  const SearchFilterChips({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('Tất cả', SearchFilter.all),
          const SizedBox(width: 8),
          _buildFilterChip('Bài hát', SearchFilter.songs),
          const SizedBox(width: 8),
          _buildFilterChip('Nghệ sĩ', SearchFilter.artists),
          const SizedBox(width: 8),
          _buildFilterChip('Album', SearchFilter.albums),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SearchFilter filter) {
    final isSelected = controller.currentFilter == filter;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(MyColor.se4),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(filter),
        backgroundColor: const Color(MyColor.pr2),
        selectedColor: const Color(MyColor.pr5),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color:
              isSelected ? const Color(MyColor.pr5) : const Color(MyColor.se1),
        ),
      ),
    );
  }
}

class SearchSortMenu extends StatelessWidget {
  final mysearch.SearchController controller;

  const SearchSortMenu({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(MyColor.pr2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(MyColor.se1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.sort, size: 18, color: Color(MyColor.se4)),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Color(MyColor.se4)),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            _buildSortMenuItem(
              'Liên quan',
              SortOption.relevance,
              Icons.trending_up,
            ),
            _buildSortMenuItem('Tên A-Z', SortOption.name, Icons.sort_by_alpha),
            _buildSortMenuItem(
              'Phổ biến',
              SortOption.playCount,
              Icons.play_circle_filled,
            ),
            _buildSortMenuItem(
              'Mới nhất',
              SortOption.recent,
              Icons.access_time,
            ),
          ],
      onSelected: controller.setSort,
    );
  }

  PopupMenuItem<SortOption> _buildSortMenuItem(
    String label,
    SortOption option,
    IconData icon,
  ) {
    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(MyColor.se4)),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

class SearchSuggestionsList extends StatelessWidget {
  final mysearch.SearchController controller;

  const SearchSuggestionsList({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!controller.showSuggestions || controller.searchSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.searchSuggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = controller.searchSuggestions[index];
          return ListTile(
            leading: const Icon(Icons.search, color: Color(MyColor.se4)),
            title: Text(suggestion, style: const TextStyle(fontSize: 15)),
            trailing: const Icon(
              Icons.north_west,
              size: 16,
              color: Color(MyColor.grey),
            ),
            onTap: () => controller.selectSuggestion(suggestion),
          );
        },
      ),
    );
  }
}

class SearchResultsHeader extends StatelessWidget {
  final mysearch.SearchController controller;

  const SearchResultsHeader({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!controller.hasResults) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Kết quả tìm kiếm',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(MyColor.se4),
            ),
          ),
          const Spacer(),
          Text(
            '${controller.totalResults} kết quả',
            style: const TextStyle(color: Color(MyColor.grey), fontSize: 14),
          ),
          const SizedBox(width: 8),
          SearchSortMenu(controller: controller),
        ],
      ),
    );
  }
}

class SearchHistoryItem extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SearchHistoryItem({
    Key? key,
    required this.query,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(MyColor.pr2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.history, size: 20, color: Color(MyColor.se4)),
        title: Text(query, style: const TextStyle(fontSize: 15)),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18, color: Color(MyColor.grey)),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class SearchLoadingIndicator extends StatelessWidget {
  const SearchLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple loading animation
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(MyColor.pr5),
                  ),
                  strokeWidth: 3,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(MyColor.pr5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 18),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Đang tìm kiếm...',
            style: TextStyle(
              color: Color(MyColor.se4),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Đang tìm kiếm trong cơ sở dữ liệu âm nhạc',
            style: TextStyle(color: Color(MyColor.grey), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  final String query;
  final String? filter;
  final String? errorMessage;
  final bool hasError;
  final VoidCallback? onRetry;

  const SearchEmptyState({
    Key? key,
    required this.query,
    this.filter,
    this.errorMessage,
    this.hasError = false,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String message =
        hasError && errorMessage != null ? errorMessage! : _getEmptyMessage();

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasError ? Icons.error_outline : Icons.search_off,
            size: 64,
            color:
                hasError
                    ? const Color(MyColor.red).withOpacity(0.7)
                    : const Color(MyColor.grey).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  hasError
                      ? const Color(MyColor.red)
                      : const Color(MyColor.se4),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasError
                ? 'Kiểm tra kết nối và thử lại'
                : 'Hãy thử tìm kiếm với từ khóa khác',
            style: const TextStyle(color: Color(MyColor.grey), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (hasError && onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Thử lại',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(MyColor.pr5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    if (filter == null) return 'Không tìm thấy kết quả nào';

    switch (filter) {
      case 'songs':
        return 'Không tìm thấy bài hát nào\ncho "$query"';
      case 'artists':
        return 'Không tìm thấy nghệ sĩ, bài hát\nhoặc album nào cho "$query"';
      case 'albums':
        return 'Không tìm thấy album nào\ncho "$query"';
      default:
        return 'Không tìm thấy kết quả nào\ncho "$query"';
    }
  }
}

class AnimatedSearchCard extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedSearchCard({Key? key, required this.child, required this.index})
    : super(key: key);

  @override
  State<AnimatedSearchCard> createState() => _AnimatedSearchCardState();
}

class _AnimatedSearchCardState extends State<AnimatedSearchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(opacity: _fadeAnimation.value, child: widget.child),
        );
      },
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String type; // 'song', 'artist', 'album'
  final VoidCallback onTap;

  const SearchResultCard({
    Key? key,
    required this.item,
    required this.type,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildLeadingWidget(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(MyColor.se4),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    type == 'album'
                        ? FutureBuilder<String>(
                          future: ArtistController.getArtistNameById(
                            item['artist_id'] ?? '',
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const Text(
                                "Đang tải nghệ sĩ...",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(MyColor.grey),
                                ),
                              );
                            return Text(
                              snapshot.data ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(MyColor.grey),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        )
                        : Text(
                          _getSubtitle(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(MyColor.grey),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ],
                ),
              ),
              _buildTrailingWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    final imageUrl = _getImageUrl();
    return ClipRRect(
      borderRadius: BorderRadius.circular(type == 'artist' ? 30 : 12),
      child: Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(MyColor.se1),
              borderRadius: BorderRadius.circular(type == 'artist' ? 30 : 12),
            ),
            child: Icon(
              type == 'artist' ? Icons.person : Icons.music_note,
              color: const Color(MyColor.grey),
              size: 24,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailingWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(MyColor.pr5),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        type == 'song' ? Icons.play_arrow : Icons.arrow_forward_ios,
        color: Colors.white,
        size: type == 'song' ? 20 : 16,
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case 'song':
        return item['song_name'] ?? 'Unknown Song';
      case 'artist':
        return item['artist_name'] ?? 'Unknown Artist';
      case 'album':
        return item['album_name'] ?? 'Unknown Album';
      default:
        return 'Unknown';
    }
  }

  String _getSubtitle() {
    switch (type) {
      case 'song':
        final name = item['artist_name'];
        return (name != null && name.toString().trim().isNotEmpty) ? name : '';
      case 'artist':
        final followerCount = item['follower_count'] ?? 0;
        return '$followerCount người theo dõi';
      case 'album':
        final name = item['artist_name'];
        return (name != null && name.toString().trim().isNotEmpty) ? name : '';
      default:
        return '';
    }
  }

  String _getImageUrl() {
    switch (type) {
      case 'song':
        return item['song_imageUrl'] ?? '';
      case 'artist':
        final imageUrl = item['artist_images'] ?? '';
        print('Artist image URL: $imageUrl for ${item['artist_name']}');
        return imageUrl;
      case 'album':
        return item['album_imageUrl'] ?? '';
      default:
        return '';
    }
  }
}
