import 'package:chillwave/models/playlist_model.dart';
import 'package:chillwave/pages/playlist/playlist_page.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class PlaylistsTap extends StatelessWidget {
  final Future<List<PlaylistModel>>? playlist;

  const PlaylistsTap({
    Key? key,
    this.playlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (playlist == null) {
      return const Center(child: Text("Không có dữ liệu playlist."));
    }

    return FutureBuilder<List<PlaylistModel>>(
      future: playlist,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Bạn chưa có playlist nào."));
        }

        final playlists = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: playlists.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final pl = playlists[index];
            return buildPlaylistTile(context, pl);
          },
        );
      },
    );
  }

  Widget buildPlaylistTile(BuildContext context,PlaylistModel playlist) {
    return InkWell(
       onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (_) => PlaylistPage(playlist: playlist)
          )
        );
      },
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(MyColor.pr4),
              Color(MyColor.se2),
              Color(MyColor.pr6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(MyColor.pr4).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
      
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                  margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(MyColor.se3),
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://i.pinimg.com/736x/19/55/48/195548510f8764f0c5245cd14d2adb16.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        color: Color(MyColor.se3),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${playlist.songIds.length} bài hát',
                      style: const TextStyle(
                        color: Color(MyColor.black),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(MyColor.pr6)),
            ],
          ),

        ),
      ),
    );
  }
}
