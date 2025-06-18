import 'package:audioplayers/audioplayers.dart';

class PlayerController {
  static final PlayerController _instance = PlayerController._internal();
  factory PlayerController() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentSongName;
  String? currentArtistName;
  String? currentImageUrl;
  String? currentUrl;
  bool isLooping = false;

  PlayerController._internal();

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<bool> play({
    required String url,
    required String songName,
    required String artistName,
    required String imageUrl,
  }) async {
    if (url.isEmpty) {
      print('Lỗi: Link nhạc rỗng!');
      return false;
    }
    try {
      if (currentUrl != url) {
        currentUrl = url;
        currentSongName = songName;
        currentArtistName = artistName;
        currentImageUrl = imageUrl;
        await _audioPlayer.setSource(UrlSource(url));
      }
      await _audioPlayer.resume();
      return true;
    } catch (e) {
      print('Lỗi phát nhạc: $e');
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
