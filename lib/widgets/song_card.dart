import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/models/artist_model.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  final SongModel song;

  const SongCard({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final artistId = song.artistIds;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 290,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(MyColor.pr5),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(song.imageUrl))
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(MyColor.se5),
                  ),
                ),
                StreamBuilder<List<ArtistModel>>(
                  stream: ArtistController.getArtistsByIds(artistId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text("Đang tải...");
                    final artists = snapshot.data!;
                    return Text(
                      artists.map((a) => a.artistName).join(", "),
                    );
                  },
                )
              ],
            ),
          ),
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}
