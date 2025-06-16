import 'package:flutter/material.dart';
import 'package:chillwave/models/song_model.dart';
import '../../../themes/colors/colors.dart';

class MusicPlayerScreen extends StatelessWidget {
  final SongModel song;
  final double currentAngle;
  final bool isPlaying;
  final bool isFavorite;
  final Duration duration;
  final Duration position;
  final List<String> artistNames;
  final String Function(Duration) formatDuration;
  final VoidCallback togglePlayPause;
  final VoidCallback toggleFavorite;
  final Function(double) onSeek;

  const MusicPlayerScreen({
    Key? key,
    required this.song,
    required this.currentAngle,
    required this.isPlaying,
    required this.isFavorite,
    required this.duration,
    required this.position,
    required this.artistNames,
    required this.formatDuration,
    required this.togglePlayPause,
    required this.toggleFavorite,
    required this.onSeek,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold( // đảm bảo điều chỉnh theo bàn phím
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(MyColor.white),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Album Art
                Transform.rotate(
                  angle: currentAngle,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(MyColor.pr3),
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        song.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.music_note, size: 80),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),

                // Song Info, Slider, và Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Song Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(MyColor.pr4),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  artistNames.isNotEmpty
                                      ? artistNames.join(', ')
                                      : 'Đang tải nghệ sĩ...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(MyColor.grey),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Color(MyColor.pr4)
                                  : Color(MyColor.grey),
                              size: 28,
                            ),
                            onPressed: toggleFavorite,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Progress Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Color(MyColor.pr4),
                          inactiveTrackColor: Color(MyColor.se1),
                          thumbColor: Color(MyColor.pr4),
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 6),
                          trackHeight: 2,
                        ),
                        child: Slider(
                          min: 0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds
                              .clamp(0, duration.inSeconds)
                              .toDouble(),
                          onChanged: onSeek,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(MyColor.grey),
                            ),
                          ),
                          Text(
                            formatDuration(duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(MyColor.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.shuffle,
                              color: Color(MyColor.grey), size: 24),
                          Icon(Icons.skip_previous,
                              color: Color(MyColor.black), size: 32),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Color(MyColor.pr4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Color(MyColor.white),
                                size: 28,
                              ),
                              onPressed: togglePlayPause,
                            ),
                          ),
                          Icon(Icons.skip_next,
                              color: Color(MyColor.black), size: 32),
                          Icon(Icons.repeat,
                              color: Color(MyColor.grey), size: 24),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
