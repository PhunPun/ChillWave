
import 'package:chillwave/pages/library/components/listendmusic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../themes/colors/colors.dart';

// Model class cho Song
class Song {
  final String id;
  final String albumId;
  final String artistId;
  final String audioUrl;
  final int duration;
  final int loveCount;
  final int playCount;
  final String songImageUrl;
  final String songName;
  final int year;

  Song({
    required this.id,
    required this.albumId,
    required this.artistId,
    required this.audioUrl,
    required this.duration,
    required this.loveCount,
    required this.playCount,
    required this.songImageUrl,
    required this.songName,
    required this.year,
  });

  factory Song.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Song(
      id: doc.id,
      albumId: data['album_id'] ?? '',
      artistId: data['artist_id'] ?? '',
      audioUrl: data['audio_url'] ?? '',
      duration: data['duration'] ?? 0,
      loveCount: data['love_count'] ?? 0,
      playCount: data['play_count'] ?? 0,
      songImageUrl: data['song_imageUrl'] ?? '',
      songName: data['song_name'] ?? '',
      year: data['year'] ?? 0,
    );
  }
}

class PlaylistsTab extends StatefulWidget {
  @override
  _PlaylistsTabState createState() => _PlaylistsTabState();
}

class _PlaylistsTabState extends State<PlaylistsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _songs = [];
  bool _isLoading = true;
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Hàm chuyển đổi Google Drive URL thành direct download URL
  String _convertGoogleDriveUrl(String originalUrl) {
    if (originalUrl.contains('drive.google.com')) {
      RegExp regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
      Match? match = regExp.firstMatch(originalUrl);
      
      if (match != null) {
        String fileId = match.group(1)!;
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }
    return originalUrl;
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });
  }

  Future<void> _loadSongs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('songs').get();
      setState(() {
        _songs = querySnapshot.docs.map((doc) => Song.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading songs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic songs from Firebase
          _buildSongsSection(),
          SizedBox(height: 24),

          // Mini Player nếu đang phát nhạc
          if (_currentSong != null) _buildMiniPlayer(),
          SizedBox(height: 24),

          // Nhạc đã nghe section
          ListenedMusicSection(),
        ],
      ),
    );
  }

  Widget _buildSongsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Bài hát mới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 12),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(MyColor.pr4)),
                ),
              )
            : _songs.isEmpty
                ? Center(
                    child: Text(
                      'Không có bài hát nào',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  )
                : Column(
                    children: _songs.map((song) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: _buildSongItem(song),
                    )).toList(),
                  ),
      ],
    );
  }

  Widget _buildSongItem(Song song) {
    return Container(
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
        padding: EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Color(MyColor.white),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
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
              ),
              child: Center(
                child: Text(
                  song.songName.isNotEmpty 
                      ? song.songName.substring(0, song.songName.length > 3 ? 3 : song.songName.length).toUpperCase()
                      : 'N/A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.songName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${song.year} • ${_formatDuration(song.duration)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  if (song.playCount > 0)
                    Text(
                      '${song.playCount} lượt phát',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                if (song.loveCount > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${song.loveCount}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _togglePlayPause(song),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
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
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(MyColor.pr4).withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      (_currentSong?.id == song.id && _isPlaying)
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    if (_currentSong == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(MyColor.pr4).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    _currentSong!.songName.isNotEmpty 
                        ? _currentSong!.songName.substring(0, _currentSong!.songName.length > 3 ? 3 : _currentSong!.songName.length).toUpperCase()
                        : 'N/A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSong!.songName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_formatPosition(_currentPosition)} / ${_formatPosition(_totalDuration)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousSong,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(17.5),
                      ),
                      child: Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _togglePlayPause(_currentSong!),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Color(MyColor.pr4),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _nextSong,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(17.5),
                      ),
                      child: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          // Progress Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
            ),
            child: Slider(
              value: _totalDuration.inSeconds > 0
                  ? _currentPosition.inSeconds / _totalDuration.inSeconds
                  : 0.0,
              onChanged: (value) {
                final position = Duration(
                  seconds: (value * _totalDuration.inSeconds).round(),
                );
                _audioPlayer.seek(position);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatPosition(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _togglePlayPause(Song song) async {
    try {
      if (_currentSong?.id == song.id) {
        // Same song - toggle play/pause
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      } else {
        // New song - play it với URL đã được chuyển đổi
        setState(() {
          _currentSong = song;
        });
        
        // Chuyển đổi URL trước khi phát
        String playableUrl = _convertGoogleDriveUrl(song.audioUrl);
        await _audioPlayer.play(UrlSource(playableUrl));
        
        // Update play count in Firebase
        await _updatePlayCount(song.id);
      }
    } catch (e) {
      print('Error playing song: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể phát bài hát: ${song.songName}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updatePlayCount(String songId) async {
    try {
      DocumentReference songRef = _firestore.collection('songs').doc(songId);
      await songRef.update({
        'play_count': FieldValue.increment(1),
      });
      
      // Update local data
      setState(() {
        int index = _songs.indexWhere((s) => s.id == songId);
        if (index != -1) {
          _songs[index] = Song(
            id: _songs[index].id,
            albumId: _songs[index].albumId,
            artistId: _songs[index].artistId,
            audioUrl: _songs[index].audioUrl,
            duration: _songs[index].duration,
            loveCount: _songs[index].loveCount,
            playCount: _songs[index].playCount + 1,
            songImageUrl: _songs[index].songImageUrl,
            songName: _songs[index].songName,
            year: _songs[index].year,
          );
        }
      });
    } catch (e) {
      print('Error updating play count: $e');
    }
  }

  void _previousSong() {
    if (_currentSong == null || _songs.isEmpty) return;
    
    int currentIndex = _songs.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex > 0) {
      _togglePlayPause(_songs[currentIndex - 1]);
    } else {
      _togglePlayPause(_songs.last); // Loop to last song
    }
  }

  void _nextSong() {
    if (_currentSong == null || _songs.isEmpty) return;
    
    int currentIndex = _songs.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex < _songs.length - 1) {
      _togglePlayPause(_songs[currentIndex + 1]);
    } else {
      _togglePlayPause(_songs.first); // Loop to first song
    }
  }
}