// music_playlist_screen.dart
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
                        'Đã phát nổi bật',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(MyColor.grey),
                        ),
                      ),
                      Text(
                        '2024',
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
                Text('214.2K', style: TextStyle(color: Color(MyColor.grey))),
                Spacer(),
                Text('6M', style: TextStyle(color: Color(MyColor.grey))),
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
            child: ListView.builder(
              itemCount: playlist?.length ?? 3, // Default 3 items if no playlist
              itemBuilder: (context, index) {
                // Dữ liệu mẫu nếu không có playlist
                final songs = playlist ?? [
                  song, // Current song
                  song, // Duplicate for demo
                  song, // Duplicate for demo
                ];
                
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
                          songs[index].imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                              songs[index].name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(MyColor.black),
                              ),
                            ),
                            Text(
                              'Nghệ sĩ ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(MyColor.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.play_arrow, color: Color(MyColor.pr4)),
                        onPressed: () {
                          // Handle play different song
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}