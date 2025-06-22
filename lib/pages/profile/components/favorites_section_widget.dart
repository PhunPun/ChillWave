import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controllers/favorites_controller.dart';

class FavoritesSectionWidget extends StatefulWidget {
  final String userId;

  const FavoritesSectionWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _FavoritesSectionWidgetState createState() => _FavoritesSectionWidgetState();
}

class _FavoritesSectionWidgetState extends State<FavoritesSectionWidget> {
  late FavoritesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FavoritesController(
      userId: widget.userId,
      context: context,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildFavoritesList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Yêu thích',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'TRACK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.getFavoritesStream(),
      builder: (context, favoritesSnapshot) {
        if (favoritesSnapshot.hasError) {
          return _buildErrorWidget('Có lỗi xảy ra: ${favoritesSnapshot.error}');
        }

        if (favoritesSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (!favoritesSnapshot.hasData || favoritesSnapshot.data!.docs.isEmpty) {
          return _buildEmptyWidget();
        }

        final favoritesDocs = favoritesSnapshot.data!.docs;
        
        // Lấy TẤT CẢ song_id từ favorites
        final allSongIds = <String>[];
        for (var doc in favoritesDocs) {
          final rawSongId = (doc.data() as Map<String, dynamic>)['song_id'];
          final songIds = _controller.extractSongIds(rawSongId);
          allSongIds.addAll(songIds);
        }

        final uniqueSongIds = allSongIds.toSet().toList();

        if (uniqueSongIds.isEmpty) {
          return _buildErrorWidget('Không có bài hát hợp lệ');
        }

        return StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: _controller.getAllSongs(uniqueSongIds),
          builder: (context, songsSnapshot) {
            if (songsSnapshot.hasError) {
              return _buildErrorWidget('Có lỗi khi tải bài hát: ${songsSnapshot.error}');
            }

            if (songsSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            }

            if (!songsSnapshot.hasData || songsSnapshot.data!.isEmpty) {
              return _buildErrorWidget('Không tìm thấy bài hát');
            }

            final songsDocs = songsSnapshot.data!;
            final combinedData = _controller.processCombinedData(favoritesDocs, songsDocs);

            if (combinedData.isEmpty) {
              return _buildErrorWidget('Không thể kết hợp dữ liệu');
            }

            return _buildSongsList(combinedData);
          },
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.favorite_border,
              size: 50,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài hát yêu thích',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildSongsList(List<Map<String, dynamic>> combinedData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: combinedData.length,
      itemBuilder: (context, index) {
        final item = combinedData[index];
        return _buildSongItem(item);
      },
    );
  }

  Widget _buildSongItem(Map<String, dynamic> item) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final isCurrentlyPlaying = _controller.currentPlayingSongId == item['songId'] && _controller.isPlaying;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _controller.navigateToMusicPlayer(item),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.shade50,
                      Colors.orange.shade50,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildAlbumArt(item, isCurrentlyPlaying),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSongInfo(item)),
                    _buildMenuButton(item),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(Map<String, dynamic> item, bool isCurrentlyPlaying) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              item['songImageUrl'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade200,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                );
              },
            ),
            if (isCurrentlyPlaying)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pause,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongInfo(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['songName'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FutureBuilder<String>(
          future: _controller.getArtistNames(item['artistIds']),
          builder: (context, artistSnapshot) {
            return Text(
              artistSnapshot.data ?? 'Loading...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildMenuButton(Map<String, dynamic> item) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.pink.shade400,
        size: 24,
      ),
      onSelected: (value) {
        if (value == 'play') {
          _controller.navigateToMusicPlayer(item);
        } else if (value == 'remove') {
          _controller.removeFromFavorites(item['favoriteDocId'], item['songId']);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'play',
          child: Row(
            children: [
              Icon(Icons.play_circle_fill, color: Colors.green),
              SizedBox(width: 8),
              Text('Mở trình phát'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.favorite_border, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa yêu thích'),
            ],
          ),
        ),
      ],
    );
  }
}