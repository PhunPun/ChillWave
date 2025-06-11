import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/models/artist_model.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class TopBxhCard extends StatelessWidget {
  final SongModel song;
  final int topIndex;
  final bool? full;

  const TopBxhCard({
    super.key, 
    required this.song,
    required this.topIndex,
    this.full,
  });

  @override
  Widget build(BuildContext context) {
    final artistId = song.artistIds;
    return Container(
      margin: EdgeInsets.symmetric(vertical: (full?? false)? 8 : 5),
      width: 290,
      child: Row(
        children: [
          Container(
            width: (full?? false)? 50 : 35,
            height: (full?? false)? 50 : 35,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(MyColor.pr5),
                width:(full?? false)? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: NetworkImage(song.imageUrl))
            ),
          ),
          SizedBox(
            width: 25,
            child: Column(
              children: [
                Text(
                  topIndex.toString(),
                  style: TextStyle(
                    fontSize: (full?? false)? 14 : 13,
                    color: Color(MyColor.pr6),
                    fontWeight: FontWeight.bold
                  ),
                ),
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Color(MyColor.se3),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (full?? false) ? 14 : 13,
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
                      style: TextStyle(
                        fontSize: (full?? false) ? 13 : 12
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          const Icon(
            Icons.more_vert,
            color: Color(MyColor.se3),
            size: 18,
          ),
        ],
      ),
    );
  }
}
