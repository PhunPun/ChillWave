import 'package:chillwave/controllers/album_controller.dart';
import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/widgets/skeleton/song_card_skeleton.dart';
import 'package:chillwave/widgets/song_card.dart';
import 'package:flutter/material.dart';
import 'package:chillwave/models/artist_model.dart';
import '../../../themes/colors/colors.dart';

class ArtistDetailPage extends StatefulWidget {
  final ArtistModel artist;
  
  const ArtistDetailPage({Key? key, required this.artist}) : super(key: key);
  
  @override
  _ArtistDetailPageState createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  bool _isFavorite = false;
  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final result = await ArtistController.isFavorite(widget.artist.id);
    setState(() {
      _isFavorite = result;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColor.white),
      body: CustomScrollView(
        slivers: [
          // App Bar với ảnh nghệ sĩ
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Color(MyColor.pr4),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.redAccent : Colors.white,
                ),
                onPressed: () async {
                  setState(() => _isFavorite = !_isFavorite);

                  if (_isFavorite) {
                    await ArtistController.saveFavoriteArtists({widget.artist.id});
                  } else {
                    await ArtistController.removeFavoriteArtist(widget.artist.id);
                  }
                },
              ),
              // IconButton(
              //   icon: Icon(Icons.more_vert, color: Colors.white),
              //   onPressed: () {
              //     // TODO: Show more options
              //   },
              // ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  _buildArtistImage(),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  
                  // Artist name
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.artist.artistName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${widget.artist.albums.length} album${widget.artist.albums.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action buttons
                //_buildActionButtons(),
                
                // Artist info
                const SizedBox(height: 10,),
                _buildArtistInfo(),
                
                // Albums section
                //_buildAlbumsSection(),
                
                // Popular songs section
                _buildPopularSongsSection(),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArtistImage() {
    String imageUrl = widget.artist.artistImages;
    
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
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
            Color(MyColor.pr4),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white.withOpacity(0.7),
          size: 80,
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          // Play button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Play all songs
              },
              icon: Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                'Phát tất cả',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(MyColor.pr4),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          
          SizedBox(width: 16),
          
          // Shuffle button
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(MyColor.pr4)),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: Shuffle play
              },
              icon: Icon(
                Icons.shuffle,
                color: Color(MyColor.pr4),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArtistInfo() {
    return FutureBuilder<int>(
      future: AlbumController.countAlbumsByArtist(widget.artist.id),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin nghệ sĩ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.se4),
                ),
              ),
              SizedBox(height: 12),

              if (widget.artist.bio.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiểu sử',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(MyColor.se4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.artist.bio,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(MyColor.grey),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),

              if (snapshot.connectionState == ConnectionState.waiting)
                _buildInfoRow('Số album', 'Đang tải...')
              else
                _buildInfoRow('Số album', '$count album'),

              _buildInfoRow('ID', widget.artist.id),

              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Color(MyColor.grey),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Color(MyColor.se4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAlbumsSection() {
    if (widget.artist.albums.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Albums',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.se4),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all albums page
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(MyColor.pr4),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 20),
            itemCount: widget.artist.albums.length,
            itemBuilder: (context, index) {
              String albumId = widget.artist.albums[index];
              return _buildAlbumCard(albumId, index);
            },
          ),
        ),
        
        SizedBox(height: 20),
      ],
    );
  }
  
  Widget _buildAlbumCard(String albumId, int index) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album cover
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildAlbumPlaceholder(),
            ),
          ),
          
          SizedBox(height: 8),
          
          // Album info
          Text(
            'Album ${index + 1}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(MyColor.se4),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          Text(
            'ID: ${albumId.length > 10 ? albumId.substring(0, 10) + '...' : albumId}',
            style: TextStyle(
              fontSize: 12,
              color: Color(MyColor.grey),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAlbumImage(dynamic album) {
    return _buildAlbumPlaceholder();
  }
  
  Widget _buildAlbumPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(MyColor.pr1),
            Color(MyColor.pr2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.album,
          color: Color(MyColor.pr4).withOpacity(0.7),
          size: 40,
        ),
      ),
    );
  }
  
  Widget _buildPopularSongsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Bài hát nổi bật',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(MyColor.se4),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // StreamBuilder để hiển thị danh sách bài hát
        StreamBuilder<List<SongModel>>(
          stream: MusicController().getSongsByArtistId(widget.artist.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: SongCardSkeleton(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Không có bài hát nào.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(MyColor.grey),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            final songs = snapshot.data!;
            print('====== $songs');
            return Container(
              margin: EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: songs.take(5).map((SongModel song) => SongCard(song: song)).toList(),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  
}