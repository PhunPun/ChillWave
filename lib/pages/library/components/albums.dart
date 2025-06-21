import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/pages/album/album_page.dart';
import 'package:flutter/material.dart';
import 'package:chillwave/controllers/album_controller.dart';
import 'package:chillwave/models/album_model.dart';
import 'package:chillwave/pages/library/components/listendmusic.dart';
import '../../../themes/colors/colors.dart';

class AlbumsTab extends StatefulWidget {
  @override
  _AlbumsTabState createState() => _AlbumsTabState();
}

class _AlbumsTabState extends State<AlbumsTab> {
  late final Future<List<AlbumModel>> _albumsFuture;
  PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  final Map<String, String> _artistNameCache = {};
  Future<String> getArtistNameCached(String id) async {
    if(id == null || id == ""){
      return '';
    }
    if (_artistNameCache.containsKey(id)) return _artistNameCache[id]!;

    try {
      final names = await ArtistController.getArtistNamesByIds([id]);
      final name = names.isNotEmpty ? names.first : 'Không rõ tên';
      _artistNameCache[id] = name;
      return name;
    } catch (e) {
      return 'Lỗi: $e';
    }
  }
  @override
  void initState() {
    super.initState();
    _albumsFuture = AlbumController().getAllAlbumsOnce(); // ⬅️ Lưu future tại đây
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlbumModel>>(
      future: _albumsFuture, // ⬅️ Dùng lại future đã lưu
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có album nào."));
        }

        final albums = snapshot.data!;
        return Column(
          children: [
            SizedBox(
              height: 450,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: _buildAlbumCard(albums[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildPageIndicators(albums.length),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ListenedMusicSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Color(MyColor.pr4) : Color(MyColor.pr2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumCard(AlbumModel album) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (_) => AlbumPage(album: album)
              )
            );
          },
          child: Container(
            height: constraints.maxHeight,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            decoration: BoxDecoration(
              color: Color(MyColor.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: constraints.maxHeight * 0.7,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: _buildAlbumImage(album.albumImageUrl),
                  ),
                ),
                Container(
                  height: constraints.maxHeight * 0.25,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        album.albumName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(MyColor.se4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      FutureBuilder<String>(
                        future: getArtistNameCached(album.artistId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              "Đang tải nghệ sĩ...",
                              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                            );
                          }
          
                          return Text(
                            snapshot.data ?? "Không rõ nghệ sĩ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(MyColor.se4).withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
          
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                  : null,
              color: Color(MyColor.pr4),
              strokeWidth: 2,
            ),
          );
        },
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(MyColor.pr2), Color(MyColor.pr1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.album, color: Color(MyColor.pr4).withOpacity(0.7), size: 32),
      ),
    );
  }
}
