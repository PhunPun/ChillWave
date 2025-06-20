import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/models/artist_model.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:chillwave/widgets/gradient_wrapper.dart';
import 'package:chillwave/widgets/skeleton_search/song_card_skeleton.dart';
import 'package:chillwave/widgets/song_card.dart';
import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  final String artistId;

  const CollectionPage({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ArtistModel?>(
      stream: ArtistController.getArtistById(artistId),
      builder: (context, artistSnapshot) {
        if (!artistSnapshot.hasData) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            appBar: AppBar(),
            body: GradientWrapper(
              child: SongCardSkeleton(),
            ),
          );
        }

        final artist = artistSnapshot.data!;
        return StreamBuilder<List<SongModel>>(
          stream: MusicController().getSongsByArtistId(artistId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(),
                body: GradientWrapper(
                  child: SongCardSkeleton(),
                ),
              );
            }
            final appBar = AppBar(
              centerTitle: true,
              title: Text(
                'Nhạc của ${artist.artistName}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.se5),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            );

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Scaffold(
                extendBodyBehindAppBar: true,
                appBar: appBar,
                body: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(MyColor.pr3), Color(MyColor.se1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Không có dữ liệu',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              );
            }

            final songs = snapshot.data!;
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: appBar,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(MyColor.pr3), Color(MyColor.se1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: kToolbarHeight + 24, left: 12, right: 12, bottom: 12),
                  itemCount: songs.length,
                  itemBuilder: (context, index) => SongCard(song: songs[index]),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                ),
              ),
            );
          },
        );
      },
    );
  }
}