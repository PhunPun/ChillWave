import 'package:audioplayers/audioplayers.dart';

class PlayerController {
  static final PlayerController _instance = PlayerController._internal();
  factory PlayerController() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? currentSongName;
  String? currentArtistName;
  String? currentImageUrl;
  String? currentUrl;

  PlayerController._internal();

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> play({
    required String url,
    required String songName,
    required String artistName,
    required String imageUrl,
  }) async {
    if (currentUrl != url) {
      currentUrl = url;
      currentSongName = songName;
      currentArtistName = artistName;
      currentImageUrl = imageUrl;
      await _audioPlayer.setSource(UrlSource(url));
    }
    await _audioPlayer.resume();
  }

  void pause() => _audioPlayer.pause();
  void resume() => _audioPlayer.resume();
  void stop() => _audioPlayer.stop();
  Stream<PlayerState> get playerState => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get position => _audioPlayer.onPositionChanged;
  Stream<Duration> get duration => _audioPlayer.onDurationChanged;
}
