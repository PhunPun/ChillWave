import 'package:chillwave/pages/library/components/lisentedmusic.dart';
import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class AlbumsTab extends StatefulWidget {
  @override
  _AlbumsTabState createState() => _AlbumsTabState();
}

class _AlbumsTabState extends State<AlbumsTab> {
  PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Listen to page changes
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
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 450, // Fixed height to prevent overflow
            child: PageView.builder(
              controller: _pageController,
              physics: BouncingScrollPhysics(),
              itemCount: _getAlbumData().length,
              itemBuilder: (context, index) {
                final album = _getAlbumData()[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: _buildAlbumCard(album),
                );
              },
            ),
          ),
          
          // Page indicators (dots)
          SizedBox(height: 16),
          _buildPageIndicators(),
          
          SizedBox(height: 32),
          
          // Nhạc đã nghe section - Now properly scrollable
          Container(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: ListenedMusicSection(),
          ),
          
          // Add some bottom padding to ensure last item is fully visible
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _getAlbumData().length,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
              ? Color(MyColor.pr4) // Active dot color - bright pink
              : Color(MyColor.pr2), // Inactive dot color - light pink
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

Widget _buildAlbumCard(AlbumData album) {
  return GestureDetector(
    onTap: () {
      print('Tapped on ${album.title}');
    },
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          decoration: BoxDecoration(
            color: Color(MyColor.white),
            borderRadius: BorderRadius.circular(20),
            // Đã loại bỏ boxShadow
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album cover image - Fixed height
              Container(
                height: constraints.maxHeight * 0.7, // 75% for image
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  child: _buildAlbumImage(album.imageUrl),
                ),
              ),
              
              // Album info - Fixed height
              Container(
                height: constraints.maxHeight * 0.25, // 25% for text
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        album.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(MyColor.se4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        album.artist,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(MyColor.se4).withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildAlbumImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      // Ảnh từ URL
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Color(MyColor.pr1), // Changed to use your light pink color
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
                color: Color(MyColor.pr4),
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else if (imageUrl.startsWith('assets/')) {
      // Ảnh từ assets
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      // Placeholder
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(MyColor.pr2), // Light pink
            Color(MyColor.pr1), // Very light pink
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.album,
          color: Color(MyColor.pr4).withOpacity(0.7),
          size: 32,
        ),
      ),
    );
  }

  // Sample album data
  List<AlbumData> _getAlbumData() {
    return [
      AlbumData(
        title: 'Positions',
        artist: 'Ariana Grande',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/a/a0/Ariana_Grande_-_Positions.png',
      ),
      AlbumData(
        title: 'After Hours',
        artist: 'The Weeknd',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/c/c1/The_Weeknd_-_After_Hours.png',
      ),
      AlbumData(
        title: 'Future Nostalgia',
        artist: 'Dua Lipa',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/f/f5/Dua_Lipa_-_Future_Nostalgia_%28Official_Album_Cover%29.png',
      ),
      AlbumData(
        title: 'Folklore',
        artist: 'Taylor Swift',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/f/f8/Taylor_Swift_-_Folklore.png',
      ),
      AlbumData(
        title: 'Chromatica',
        artist: 'Lady Gaga',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/0/02/Lady_Gaga_-_Chromatica_%28Official_Album_Cover%29.png',
      ),
      AlbumData(
        title: 'Fine Line',
        artist: 'Harry Styles',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/en/a/ae/Harry_Styles_-_Fine_Line.png',
      ),
    ];
  }
}

// Model class cho album data
class AlbumData {
  final String title;
  final String artist;
  final String imageUrl;
  final String? releaseYear;
  final String? id;

  AlbumData({
    required this.title,
    required this.artist,
    required this.imageUrl,
    this.releaseYear,
    this.id,
  });
}