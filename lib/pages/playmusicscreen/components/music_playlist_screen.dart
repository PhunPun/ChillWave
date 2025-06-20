// music_playlist_screen.dart
import 'package:chillwave/controllers/artist_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chillwave/models/song_model.dart';
import '../../../themes/colors/colors.dart';

class MusicPlaylistScreen extends StatelessWidget {
  final SongModel song;
  final List<SongModel>? playlist;
  final List<String> artistNames;

  const MusicPlaylistScreen({
    Key? key,
    required this.song,
    this.playlist,
    required this.artistNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    Future<List<SongModel>> fetchSimilarSongs(SongModel currentSong) async {
      final firestore = FirebaseFirestore.instance;
      final allDocs = await firestore.collection('songs').get();

      final Set<String> currentArtistIds = currentSong.artistIds.toSet();
      final List<SongModel> similar = [];
      final List<SongModel> fallback = [];

      for (var doc in allDocs.docs) {
        final data = doc.data();
        final songId = doc.id;

        if (songId.trim() == currentSong.id.trim()) continue; // ✅ Fix không lặp bài hiện tại

        // ✅ Parse artistId linh hoạt
        List<String> songArtistIds = [];
        if (data['artist_id'] is List) {
          songArtistIds = List<String>.from(data['artist_id']);
        } else if (data['artist_id'] is String) {
          final raw = data['artist_id'] as String;
          songArtistIds = raw.replaceAll('[', '').replaceAll(']', '').split(',').map((s) => s.trim()).toList();
        }

        final song = SongModel.fromMap(songId, data);

        // ✅ Nếu có ít nhất 1 nghệ sĩ trùng → thêm
        if (currentArtistIds.any((id) => songArtistIds.contains(id))) {
          similar.add(song);
        } else {
          fallback.add(song);
        }
      }

      if (similar.isNotEmpty) {
        return similar;
      } else {
        fallback.shuffle();
        return fallback.take(4).toList();
      }
    }

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
                    song.imageUrl,
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
                        song.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(MyColor.pr4),
                        ),
                      ),
                      Text(
                        artistNames.isNotEmpty ? artistNames.join(', ') : 'Soobin',
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
                        '${song.year}',
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
                Text(formatNumberCompact(song.loveCount), style: TextStyle(color: Color(MyColor.grey))),
                Spacer(),
                Text(formatNumberCompact(song.playCount), style: TextStyle(color: Color(MyColor.grey))),
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
            child: playlist != null
              ? ListView.builder(
                  itemCount: playlist!.length,
                  itemBuilder: (context, index) {
                    final songItem = playlist![index];
                    return buildSongTile(songItem, index);
                  },
                )
              : FutureBuilder<List<SongModel>>(
                  future: fetchSimilarSongs(song),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
                        return buildSongTile(songItem, index);
                      },
                    );
                  },
                ),
          )
        ],
      ),
    );
  }
  Widget buildSongTile(SongModel songItem, int index) {
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
            child: Image.network(
              songItem.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Color(MyColor.se1),
                child: Icon(Icons.music_note, size: 20),
              ),
            ),
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
                  future: ArtistController.getArtistNamesByIds(songItem.artistIds),
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
            onPressed: () {
              // TODO: handle play this song
            },
          ),
        ],
      ),
    );
  }

}