import 'package:chillwave/pages/library/components/listendmusic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../themes/colors/colors.dart';

// Model cho Song
class Song {
  final String id;
  final String artistId;
  final String audioUrl;
  final String country;
  final int? duration;
  final String songImageUrl;
  final String songName;
  final int year;

  Song({
    required this.id,
    required this.artistId,
    required this.audioUrl,
    required this.country,
    this.duration,
    required this.songImageUrl,
    required this.songName,
    required this.year,
  });

  factory Song.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      return Song(
        id: doc.id,
        artistId: data['artist_id']?.toString() ?? '',
        audioUrl: data['audio_url']?.toString() ?? '',
        country: data['country']?.toString() ?? '',
        duration: data['duration'] is int ? data['duration'] : null,
        songImageUrl: data['song_imageUrl']?.toString() ?? '',
        songName: data['song_name']?.toString() ?? 'Không có tên',
        year: data['year'] is int ? data['year'] : 0,
      );
    } catch (e) {
      return Song(
        id: doc.id,
        artistId: '',
        audioUrl: '',
        country: '',
        duration: null,
        songImageUrl: '',
        songName: 'Lỗi tải dữ liệu',
        year: 0,
      );
    }
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
  Song? _currentPlayingSong;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPlayingSong = null;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _loadSongs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('songs').get();
      
      setState(() {
        _songs = snapshot.docs.map((doc) => Song.fromFirestore(doc)).toList();
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Lỗi kết nối'),
            content: Text('Không thể tải dữ liệu từ Firebase: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadSongs();
                },
                child: Text('Thử lại'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _playSong(Song song) async {
    try {
      if (song.audioUrl.isEmpty) {
        _showErrorDialog('Không có URL âm thanh cho bài hát này');
        return;
      }
      
      if (_currentPlayingSong?.id != song.id) {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(song.audioUrl));
        setState(() {
          _currentPlayingSong = song;
        });
      } else {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang phát: ${song.songName}'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(MyColor.pr4),
          ),
        );
      }
      
    } catch (e) {
      _showErrorDialog('Không thể phát bài hát: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini player nếu đang phát nhạc
          if (_currentPlayingSong != null) _buildMiniPlayer(),

          // Songs from Firebase section
          _buildSongsFromFirebase(),
          SizedBox(height: 24),

          // Nhạc đã nghe section
          ListenedMusicSection(),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: EdgeInsets.all(12),
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
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đang phát: ${_currentPlayingSong?.songName ?? ""}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _playSong(_currentPlayingSong!),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  await _audioPlayer.stop();
                  setState(() {
                    _currentPlayingSong = null;
                    _isPlaying = false;
                  });
                },
                child: Icon(Icons.stop, color: Colors.white, size: 20),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: _duration.inMilliseconds > 0 
                ? _position.inMilliseconds / _duration.inMilliseconds 
                : 0.0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsFromFirebase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(MyColor.pr4)),
            ),
          )
        else if (_songs.isEmpty)
          Center(
            child: Text(
              'Không có bài hát nào',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _songs.length,
            itemBuilder: (context, index) {
              return _buildSongItem(_songs[index]);
            },
          ),
      ],
    );
  }

  Widget _buildSongItem(Song song) {
    bool isCurrentSong = _currentPlayingSong?.id == song.id;
    bool isPlaying = isCurrentSong && _isPlaying;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
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
          color: isCurrentSong ? Color(MyColor.pr4).withOpacity(0.1) : Color(MyColor.white),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Song image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.songImageUrl.isNotEmpty
                    ? Image.network(
                        song.songImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultMusicIcon();
                        },
                      )
                    : _buildDefaultMusicIcon(),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isCurrentSong && _isPlaying)
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.volume_up,
                            size: 16,
                            color: Color(MyColor.pr4),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          song.songName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCurrentSong ? Color(MyColor.pr4) : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${song.country} • ${song.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isCurrentSong 
                          ? Color(MyColor.pr4).withOpacity(0.8)
                          : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _playSong(song),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(MyColor.pr4),
                      Color(MyColor.se2),
                      Color(MyColor.pr6),
                    ],
                  ),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultMusicIcon() {
    return Container(
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
        ),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.white,
        size: 24,
      ),
    );
  }


}