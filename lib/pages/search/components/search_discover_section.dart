import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../themes/colors/colors.dart';
import '../../../controllers/search_controller.dart' as mysearch;
import '../../../widgets/skeleton_search/search_skeleton.dart';
import '../../../widgets/search_components.dart';
import '../../../models/song_model.dart';
import '../../../controllers/music_controller.dart';
import '../../playmusicscreen/playmusic.dart';

class SearchDiscoverSection extends StatelessWidget {
  final mysearch.SearchController controller;

  const SearchDiscoverSection({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👋 Xin chào!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(MyColor.grey),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bạn muốn nghe gì hôm nay?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(MyColor.se4),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🔥 Trending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(MyColor.se4),
                  ),
                ),
                Tooltip(
                  message: 'Làm mới nhạc trending',
                  child: GestureDetector(
                    onTap:
                        controller.isTrendingLoading
                            ? null
                            : () async {
                              HapticFeedback.lightImpact();
                              await controller.refreshTrendingSongs();
                              _showRefreshSuccess(context);
                            },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            controller.isTrendingLoading
                                ? const Color(MyColor.grey).withOpacity(0.3)
                                : const Color(MyColor.pr5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              controller.isTrendingLoading
                                  ? const Color(MyColor.grey).withOpacity(0.3)
                                  : const Color(MyColor.pr5).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child:
                          controller.isTrendingLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(MyColor.pr5),
                                  ),
                                ),
                              )
                              : const Icon(
                                Icons.refresh,
                                size: 16,
                                color: Color(MyColor.pr5),
                              ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            controller.trendingSongs.isNotEmpty
                ? _buildTrendingGrid(context)
                : const TrendingSkeletonLoader(),
            const SizedBox(height: 24),
            _buildSearchTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: controller.trendingSongs.take(6).length,
      itemBuilder: (context, index) {
        final song = controller.trendingSongs[index];
        return _buildTrendingCard(context, song, index);
      },
    );
  }

  Widget _buildTrendingCard(
    BuildContext context,
    Map<String, dynamic> song,
    int index,
  ) {
    return AnimatedSearchCard(
      index: index,
      child: GestureDetector(
        onTap: () => _playSong(context, song),
        child: Container(
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
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: _buildSongImage(song),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(MyColor.pr5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(MyColor.pr5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          song['song_name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(MyColor.se4),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongImage(Map<String, dynamic> song) {
    String imageUrl = song['song_imageUrl'] ?? '';

    // Kiểm tra URL ảnh hợp lệ
    if (imageUrl.isEmpty || !_isValidImageUrl(imageUrl)) {
      return _buildPlaceholderImage();
    }

    // Convert Google Drive URL nếu cần
    if (imageUrl.contains('drive.google.com')) {
      imageUrl = _convertGoogleDriveImageUrl(imageUrl);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(MyColor.se1),
          child: Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              color: const Color(MyColor.pr5),
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('Lỗi tải ảnh: $imageUrl - $error');
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(MyColor.pr5).withOpacity(0.3),
            const Color(MyColor.pr5).withOpacity(0.1),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, size: 50, color: Color(MyColor.grey)),
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    // Kiểm tra URL hợp lệ
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }
    } catch (e) {
      return false;
    }

    // Kiểm tra phần mở rộng file ảnh
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('.webp') ||
        lowerUrl.contains('drive.google.com') ||
        lowerUrl.contains('firebasestorage') ||
        lowerUrl.contains('imgur') ||
        lowerUrl.contains('unsplash') ||
        lowerUrl.contains('pinimg');
  }

  String _convertGoogleDriveImageUrl(String originalUrl) {
    // Convert Google Drive sharing URL to direct image URL
    final regExp = RegExp(r'd\/(.*?)\/');
    final match = regExp.firstMatch(originalUrl);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    // Nếu không match được pattern, thử pattern khác
    final regExp2 = RegExp(r'id=([^&]+)');
    final match2 = regExp2.firstMatch(originalUrl);

    if (match2 != null) {
      final fileId = match2.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }

    return originalUrl;
  }

  Widget _buildSearchTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(MyColor.pr5).withOpacity(0.1),
            const Color(MyColor.pr5).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(MyColor.pr5).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(MyColor.pr5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mẹo tìm kiếm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(MyColor.se4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• Gõ tên bài hát hoặc nghệ sĩ\n• Sử dụng tìm kiếm bằng giọng nói 🎤\n• Thử nhận diện bài hát đang phát 🎵',
            style: TextStyle(
              fontSize: 14,
              color: Color(MyColor.grey),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _playSong(BuildContext context, Map<String, dynamic> song) {
    try {
      final musicController = MusicController();
      final rawAudioUrl = song['audio_url'] ?? '';
      final convertedAudioUrl = musicController.convertDriveLink(rawAudioUrl);

      String imageUrl = song['song_imageUrl'] ?? '';

      // Xử lý URL ảnh tương tự như trong _buildSongImage
      if (imageUrl.isNotEmpty && imageUrl.contains('drive.google.com')) {
        imageUrl = _convertGoogleDriveImageUrl(imageUrl);
      } else if (imageUrl.isEmpty || !_isValidImageUrl(imageUrl)) {
        imageUrl =
            'https://i.pinimg.com/736x/19/55/48/195548510f8764f0c5245cd14d2adb16.jpg';
      }

      final songModel = SongModel(
        id: song['id'] ?? '',
        name: song['song_name'] ?? '',
        imageUrl: imageUrl,
        linkMp3: convertedAudioUrl,
        artistIds: List<String>.from(song['artist_id'] ?? []),
        loveCount: song['love_count'] ?? 0,
        playCount: song['play_count'] ?? 0,
        year: song['year'] ?? 2024,
      );

      print('Đang phát: ${songModel.name}');
      _addToPlayHistory(songModel.id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MusicPlayerWithSwipeScreen(song: songModel),
        ),
      );
    } catch (e) {
      print('Lỗi khi phát nhạc: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể phát bài hát: $e'),
          backgroundColor: const Color(MyColor.red),
        ),
      );
    }
  }

  Future<void> _addToPlayHistory(String songId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('play_history')
            .add({
              'song_id': songId,
              'played_at': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Lỗi khi thêm vào lịch sử: $e');
    }
  }

  void _showRefreshSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Đã cập nhật nhạc trending mới nhất!'),
          ],
        ),
        backgroundColor: const Color(MyColor.pr5),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
