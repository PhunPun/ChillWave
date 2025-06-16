import 'dart:async';

import 'package:chillwave/pages/library/components/listendmusic.dart';
import 'package:chillwave/pages/playmusicscreen/playmusic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../themes/colors/colors.dart';
import '../../../controllers/music_controller.dart';
import '../../../models/song_model.dart';

class PlaylistsTab extends StatefulWidget {
  @override
  _PlaylistsTabState createState() => _PlaylistsTabState();
}

class _PlaylistsTabState extends State<PlaylistsTab> {
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _playerCompleteSub;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final MusicController _controller = MusicController();
  
  List<SongModel> _songs = [];
  bool _isLoading = true;
  SongModel? _currentPlayingSong;
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
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerCompleteSub?.cancel();

    _audioPlayer.dispose();
    super.dispose();
  }


  void _initializeAudioPlayer() {
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _durationSub = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPlayingSong = null;
          _position = Duration.zero;
        });
      }
    });
  }


  Future<void> _loadSongs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('songs').get();
      
      setState(() {
        _songs = snapshot.docs.map((doc) {
          final song = SongModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          // Convert drive link if needed
          return SongModel(
            id: song.id,
            artistIds: song.artistIds,
            name: song.name,
            linkMp3: _controller.convertDriveLink(song.linkMp3),
            imageUrl: song.imageUrl,
            loveCount: song.loveCount,
            playCount: song.playCount,
            year: song.year,
          );
        }).toList();
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        _showErrorDialog('Không thể tải dữ liệu từ Firebase: ${e.toString()}', () => _loadSongs());
      }
    }
  }

  Future<void> _playSong(SongModel song) async {
    try {
      if (song.linkMp3.isEmpty) {
        _showErrorDialog('Không có URL âm thanh cho bài hát này');
        return;
      }
      if (_currentPlayingSong?.id != song.id) {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(song.linkMp3));
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
            content: Text('Đang phát: ${song.name}'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(MyColor.pr4),
          ),
        );
      }
      
    } catch (e) {
      _showErrorDialog('Không thể phát bài hát: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message, [VoidCallback? onRetry]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: Text('Thử lại'),
            ),
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
          if (_currentPlayingSong != null) _buildMiniPlayer(),
          _buildSongsFromFirebase(),
          SizedBox(height: 24),
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
                  'Đang phát: ${_currentPlayingSong?.name ?? ""}',
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
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(MyColor.pr4)),
        ),
      );
    }
    
    if (_songs.isEmpty) {
      return Center(
        child: Text(
          'Không có bài hát nào',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _songs.length,
      itemBuilder: (context, index) => _buildSongItem(_songs[index]),
    );
  }

  Widget _buildSongItem(SongModel song) {
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
            _buildSongImage(song),
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
                          song.name,
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
                    '${song.year}',
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicPlayerWithSwipeScreen(song: song),
                  ),
                );
              },
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

  Widget _buildSongImage(SongModel song) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.imageUrl.isNotEmpty
            ? Image.network(
                song.imageUrl,
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
                errorBuilder: (context, error, stackTrace) => _buildDefaultMusicIcon(),
              )
            : _buildDefaultMusicIcon(),
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