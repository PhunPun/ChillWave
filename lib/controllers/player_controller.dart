import 'package:audioplayers/audioplayers.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:flutter/material.dart';

class PlayerController {
  static final PlayerController _instance = PlayerController._internal();
  factory PlayerController() => _instance;
  PlayerController._internal() {
    _audioPlayer.onPlayerComplete.listen((event) {
      if (isLooping) {
        // Đã xử lý bằng setReleaseMode.loop nên không cần làm gì ở đây
      } else {
        // ✅ Gọi callback để chuyển bài
        if (onSongComplete != null) {
          onSongComplete!();
        }
      }
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentSongName;
  String? currentArtistName;
  String? currentImageUrl;
  String? currentUrl;
  bool isLooping = false;

  ValueNotifier<SongModel?> currentSongNotifier = ValueNotifier(null);

  VoidCallback? onSongComplete; // 🎯 callback được UI gán

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<bool> play({
    required String url,
    required String songName,
    required String artistName,
    required String imageUrl,
    SongModel? songModel,
  }) async {
    if (url.isEmpty) return false;

    try {
      currentUrl = url;
      currentSongName = songName;
      currentArtistName = artistName;
      currentImageUrl = imageUrl;

      // Cập nhật bài hiện tại
      currentSongNotifier.value = songModel;

      await _audioPlayer.setSource(UrlSource(url));
      await _audioPlayer.resume();
      return true;
    } catch (e) {
      print('❌ Lỗi phát nhạc: $e');
      return false;
    }
  }

  void pause() => _audioPlayer.pause();
  void resume() => _audioPlayer.resume();
  void stop() => _audioPlayer.stop();

  void toggleLoop() {
    isLooping = !isLooping;
    _audioPlayer.setReleaseMode(isLooping ? ReleaseMode.loop : ReleaseMode.release);
  }

  Stream<PlayerState> get playerState => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get position => _audioPlayer.onPositionChanged;
  Stream<Duration> get duration => _audioPlayer.onDurationChanged;
}
