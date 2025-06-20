// music_playlist_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/pages/playmusicscreen/playmusic.dart';
import 'package:chillwave/widgets/skeleton/song_card_skeleton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chillwave/models/song_model.dart';
import '../../../themes/colors/colors.dart';

class MusicPlaylistScreen extends StatefulWidget {
  final SongModel song;
  final List<SongModel>? playlist;
  final List<String> artistNames;
  final Future<List<SongModel>>? similarSongsFuture;

  const MusicPlaylistScreen({
    Key? key,
    required this.song,
    this.playlist,
    required this.artistNames,
    this.similarSongsFuture
  }) : super(key: key);

  @override
  State<MusicPlaylistScreen> createState() => _MusicPlaylistScreenState();
}

class _MusicPlaylistScreenState extends State<MusicPlaylistScreen> {
  Map<String, Future<List<String>>> artistFutureCache = {};
  Future<List<String>> getArtistNames(List<String> artistIds) {
    final key = artistIds.join(',');
    if (!artistFutureCache.containsKey(key)) {
      artistFutureCache[key] = ArtistController.getArtistNamesByIds(artistIds);
    }
    return artistFutureCache[key]!; // luôn trả về cùng 1 future
  }
  @override
  Widget build(BuildContext context) {
    
    String formatNumberCompact(int number) {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else {
        return '$number';
      }
    }

    return Container(
      color: Color(MyColor.white),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Header với thông tin bài hát hiện tại
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(MyColor.pr4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.song.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          width: 60,
                          height: 60,
                          color: Color(MyColor.se1),
                          child: Icon(Icons.music_note),
                        ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(MyColor.pr4),
                        ),
                      ),
                      Text(
                        widget.artistNames.isNotEmpty ? widget.artistNames.join(', ') : 'Soobin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(MyColor.grey),
                        ),
                      ),
                      Text(
                        'Bài hát nổi bật',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(MyColor.grey),
                        ),
                      ),
                      Text(
                        '${widget.song.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(MyColor.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stats row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Color(MyColor.grey)),
                SizedBox(width: 4),
                Text(formatNumberCompact(widget.song.loveCount), style: TextStyle(color: Color(MyColor.grey))),
                Spacer(),
                Text(formatNumberCompact(widget.song.playCount), style: TextStyle(color: Color(MyColor.grey))),
                SizedBox(width: 4),
                Icon(Icons.headphones, size: 20, color: Color(MyColor.grey)),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Bài hát tương tự header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Bài hát tương tự',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(MyColor.black),
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right, color: Color(MyColor.grey)),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Danh sách bài hát
          Expanded(
            child: widget.playlist != null
              ? ListView.builder(
                  itemCount: widget.playlist!.length,
                  itemBuilder: (context, index) {
                    final songItem = widget.playlist![index];
                    return buildSongTile(context, songItem, index);
                  },
                )
              : FutureBuilder<List<SongModel>>(
                  future: widget.similarSongsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: SongCardSkeleton());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi khi tải bài hát tương tự'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Không tìm thấy bài hát tương tự'));
                    }

                    final similarSongs = snapshot.data!;
                    return ListView.builder(
                      itemCount: similarSongs.length,
                      itemBuilder: (context, index) {
                        final songItem = similarSongs[index];
                        return buildSongTile(context, songItem, index);
                      },
                    );
                  },
                ),
          )
        ],
      ),
    );
  }

  Widget buildSongTile(BuildContext context, SongModel songItem, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(MyColor.pr4).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: songItem.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 50,
                height: 50,
                color: Color(MyColor.se1),
                child: Center(child: Icon(Icons.music_note, size: 20)),
              ),
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 50,
                color: Color(MyColor.se1),
                child: Icon(Icons.music_note, size: 20),
              ),
            )
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  songItem.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(MyColor.black),
                  ),
                ),
                FutureBuilder<List<String>>(
                  future: getArtistNames(songItem.artistIds),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        'Đang tải tên nghệ sĩ...',
                        style: TextStyle(fontSize: 12, color: Color(MyColor.grey)),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Text(
                        'Không tìm được tên nghệ sĩ',
                        style: TextStyle(fontSize: 12, color: Color(MyColor.grey)),
                      );
                    }

                    final names = snapshot.data!;
                    return Text(
                      names.join(', '),
                      style: TextStyle(fontSize: 12, color: Color(MyColor.grey)),
                    );
                  },
                ),

              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.play_arrow, color: Color(MyColor.pr4)),
            onPressed: () async {
              final musicController = MusicController();
              final convertedUrl = musicController.convertDriveLink(songItem.linkMp3);
              final fixedSong = songItem.copyWith(linkMp3: convertedUrl); // cần hàm copyWith trong SongModel

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayerWithSwipeScreen(song: fixedSong),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}