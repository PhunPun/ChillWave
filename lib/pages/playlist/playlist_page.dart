import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/models/playlist_model.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/widgets/skeleton/song_card_skeleton.dart';
import 'package:chillwave/widgets/song_card.dart';
import 'package:flutter/material.dart';

class PlaylistPage extends StatelessWidget {
  final PlaylistModel playlist;

  const PlaylistPage({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    List<SongModel> _playlist = [];
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name, style: TextStyle(fontWeight: FontWeight.w600,),),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 224, 223, 255),
              Color.fromARGB(255, 249, 189, 231),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 24,
            left: 12,
            right: 12,
            bottom: 12,
          ),
          itemCount: playlist.songIds.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final songId = playlist.songIds[index];

            return FutureBuilder<SongModel?>(
              future: MusicController().getSongById(songId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SongCardSkeleton();
                }

                if (snapshot.hasError) {
                  return const Text('Lỗi khi tải bài hát', style: TextStyle(color: Colors.white));
                }

                final song = snapshot.data;
                if (song == null) {
                  return const Text('Không tìm thấy bài hát', style: TextStyle(color: Colors.white));
                }
                _playlist.add(song);

                return SongCard(song: song, playlist: _playlist,);
              },
            );
          },
        ),
      ),
    );
  }
}
