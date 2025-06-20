import 'package:chillwave/widgets/skeleton_search/song_card_skeleton.dart';
import 'package:flutter/material.dart';
import 'song_card.dart';
import '../models/song_model.dart';
import '../controllers/music_controller.dart';

class NewSongList extends StatefulWidget {
  final String country;
  const NewSongList({
    super.key,
    required this.country
    });

  @override
  State<NewSongList> createState() => _NewSongListState();
}

class _NewSongListState extends State<NewSongList> {
  late final MusicController musicController;

  @override
  void initState() {
    super.initState();
    musicController = MusicController(); // ✅ chỉ tạo 1 lần duy nhất
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: StreamBuilder<List<SongModel>>(
        stream: musicController.getSongsByYear(widget.country),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SongCardSkeleton(); // hiển thị loading khi đang chờ dữ liệu
          }
          
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không có dữ liệu'));
          }
          final songs = snapshot.data!;
          // Chia thành cột 3 bài mỗi cột
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                (songs.length / 3).ceil(),
                (columnIndex) {
                  final start = columnIndex * 3;
                  final end = (start + 3 > songs.length) ? songs.length : start + 3;
                  final chunk = songs.sublist(start, end);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: chunk.map((song) => SongCard(song: song)).toList(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
