import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../controllers/player_controller.dart';

class MiniPlayer extends StatelessWidget {
  final controller = PlayerController();

  MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.currentUrl == null) return const SizedBox();

    return StreamBuilder<PlayerState>(
      stream: controller.playerState,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data == PlayerState.playing;

        return Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  controller.currentImageUrl ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentSongName ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      controller.currentArtistName ?? '',
                      style: TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  isPlaying ? controller.pause() : controller.resume();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
