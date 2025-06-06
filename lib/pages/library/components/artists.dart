import 'package:chillwave/pages/library/components/lisentedmusic.dart';
import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class ArtistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nghệ sĩ section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nghệ sĩ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          
          SizedBox(height: 8),
          
          // Artists grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildArtistGrid(),
              ],
            ),
          ),
          
          SizedBox(height: 32),
          
          // Nhạc đã nghe section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: ListenedMusicSection(),
          ),
          
          // Bottom padding
          SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildAddCircle() {
    return GestureDetector(
      onTap: () {
        print('Add artist tapped');
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.add,
          color: Colors.grey[500],
          size: 28,
        ),
      ),
    );
  }
  
  Widget _buildArtistGrid() {
    List<ArtistData> artists = _getArtistData();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        return _buildArtistCard(artists[index]);
      },
    );
  }
  
  Widget _buildArtistCard(ArtistData artist) {
    return GestureDetector(
      onTap: () {
        print('Tapped on ${artist.name}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(MyColor.white),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Artist image (circular)
            Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(MyColor.pr2),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: _buildArtistImage(artist.imageUrl),
              ),
            ),
            
            // Artist info
            Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        artist.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(MyColor.se4),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${artist.songCount} bài hát',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(MyColor.pr4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildArtistImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Color(MyColor.pr1),
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
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
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
            Color(MyColor.pr2),
            Color(MyColor.pr1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Color(MyColor.pr4).withOpacity(0.7),
          size: 28,
        ),
      ),
    );
  }
  
  // Sample artist data
  List<ArtistData> _getArtistData() {
    return [
      ArtistData(
        name: 'Ariana Grande',
        songCount: 45,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/dd/Ariana_Grande_Grammys_Red_Carpet_2020.png',
      ),
      ArtistData(
        name: 'The Weeknd',
        songCount: 38,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/31/The_Weeknd_in_2018.jpg',
      ),
      ArtistData(
        name: 'Dua Lipa',
        songCount: 29,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Dua_Lipa_2018_2.jpg',
      ),
      ArtistData(
        name: 'Taylor Swift',
        songCount: 67,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/b/b5/191125_Taylor_Swift_at_the_2019_American_Music_Awards_%28cropped%29.png',
      ),
      ArtistData(
        name: 'Lady Gaga',
        songCount: 52,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/39/Lady_Gaga_at_Joe_Biden%27s_inauguration_%28cropped_2%29.jpg',
      ),
      ArtistData(
        name: 'Harry Styles',
        songCount: 31,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/e/e7/Harry_Styles_December_2019.jpg',
      ),
    ];
  }
}

// Model class for artist data
class ArtistData {
  final String name;
  final int songCount;
  final String imageUrl;
  final String? id;

  ArtistData({
    required this.name,
    required this.songCount,
    required this.imageUrl,
    this.id,
  });
}