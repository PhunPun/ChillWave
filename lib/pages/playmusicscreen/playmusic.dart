// music_player_with_swipe_screen.dart
import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/controllers/music_state_provider.dart';
import 'package:chillwave/controllers/playlist_controller.dart';
import 'package:chillwave/pages/home/home_center.dart';
import 'package:chillwave/pages/playmusicscreen/components/music_player_screen.dart';
import 'package:chillwave/pages/playmusicscreen/components/music_playlist_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:provider/provider.dart';
import '../../themes/colors/colors.dart';
import '../../controllers/player_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicPlayerWithSwipeScreen extends StatefulWidget {
  final SongModel song;
  final List<SongModel>? playlist;

  const MusicPlayerWithSwipeScreen({
    Key? key, 
    required this.song,
    this.playlist,
  }) : super(key: key);

  @override
  _MusicPlayerWithSwipeScreenState createState() => _MusicPlayerWithSwipeScreenState();
}

class _MusicPlayerWithSwipeScreenState extends State<MusicPlayerWithSwipeScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late PageController _pageController;
  final PlayerController _playerController = PlayerController();
  
  double _currentAngle = 0.0;
  bool isPlaying = true;
  bool isFavorite = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<String> artistNames = [];
  int _currentPageIndex = 0;
  List<String> playedSongIds = [];
  Future<List<SongModel>>? _similarSongsFuture;
  


  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _rotationController.addListener(() {
      if (isPlaying) {
        setState(() {
          _currentAngle = _rotationController.value * 2 * 3.1416;
        });
      }
    });

    // ✅ Đồng bộ trạng thái phát
    final audioPlayer = _playerController.audioPlayer;
    final state = audioPlayer.state;

    setState(() {
      isPlaying = (state == PlayerState.playing);
      if (isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    // ✅ Đồng bộ thời gian nếu đang pause
    audioPlayer.getCurrentPosition().then((p) {
      if (mounted && p != null) {
        setState(() {
          _position = p;
        });
      }
    });

    audioPlayer.getDuration().then((d) {
      if (mounted && d != null) {
        setState(() {
          _duration = d;
        });
      }
    });

    _playSafe(); // chỉ gọi nếu khác bài
    MusicController().incrementPlayCount(widget.song.id);
    _initPlayedSongIds();

    // Tiếp tục lắng nghe stream
    audioPlayer.onDurationChanged.listen((d) {
      if (mounted && d.inMilliseconds > 0) {
        setState(() => _duration = d);
      }
    });

    audioPlayer.onPositionChanged.listen((p) {
      if (mounted && _duration.inSeconds > 0) {
        setState(() => _position = p);
      }
    });

    _loadArtistNames();
    _checkIfFavorite();
    _addToPlayHistory(widget.song.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stateProvider = context.read<MusicStateProvider>();
      stateProvider.setCurrentSong(widget.song);
      stateProvider.setCurrentPlaylist(widget.playlist);
    });
    _similarSongsFuture = fetchSimilarSongs(widget.song);
    final controller = PlayerController();
    controller.onSongComplete = () {
      _handleNext(); // Gọi logic chuyển bài tiếp theo
    };
  }




  Future<void> _loadPlayedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    playedSongIds = prefs.getStringList('playedSongIds') ?? [];
    print('====== $playedSongIds');
  }

  Future<void> _savePlayedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('playedSongIds', playedSongIds);
  }

  Future<void> _initPlayedSongIds() async {
    await _loadPlayedSongIds();
    if (playedSongIds.isEmpty) {
      setState(() {
        playedSongIds = [widget.song.id];
      });
      await _savePlayedSongIds();
    } else {
      if (!playedSongIds.contains(widget.song.id)) {
        setState(() {
          playedSongIds.add(widget.song.id);
        });
        await _savePlayedSongIds();
      }
      // Nếu đã có thì giữ nguyên thứ tự, không xóa/thêm lại
    }
  }

  void _addToPlayedSongIds(String songId) async {
    if (!playedSongIds.contains(songId)) {
      setState(() {
        playedSongIds.add(songId);
      });
      await _savePlayedSongIds();
    }
    // Nếu đã có thì không làm gì
  }

  void _checkIfFavorite() async {
    final controller = MusicController();
    final result = await controller.isFavoriteSong(widget.song.id);
    if (mounted) {
      setState(() {
        isFavorite = result;
      });
    }
  }

  void _loadArtistNames() {
    if (widget.song.artistIds.isNotEmpty) {
      List<String> flattenedIds = [];

      for (var id in widget.song.artistIds) {
        if (id is String) {
          final trimmed = id.trim();
          if (trimmed.isNotEmpty && !trimmed.startsWith('[') && !trimmed.endsWith(']')) {
            flattenedIds.add(trimmed);
          } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
            final cleaned = trimmed.substring(1, trimmed.length - 1);
            final parts = cleaned.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
            flattenedIds.addAll(parts);
          }
        }
      }

      if (flattenedIds.isNotEmpty) {
        Future.wait(
          flattenedIds.map((id) => FirebaseFirestore.instance.collection('artists').doc(id).get()),
        ).then((docs) {
          final names = <String>[];
          for (var doc in docs) {
            if (doc.exists) {
              final data = doc.data();
              final artistName = data?['artist_name']?.toString().trim() ?? '';
              if (artistName.isNotEmpty) {
                names.add(artistName);
              }
            }
          }

          setState(() {
            artistNames = names.isNotEmpty ? names : ['Không tìm được nghệ sĩ'];
          });
        }).catchError((e) {
          setState(() {
            artistNames = ['Không tìm được nghệ sĩ'];
          });
        });
      } else {
        setState(() {
          artistNames = ['Không tìm được nghệ sĩ'];
        });
      }
    } else {
      setState(() {
        artistNames = ['Không tìm được nghệ sĩ'];
      });
    }
  }

  Future<void> _addToPlayHistory(String songId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final playHistoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('play_history');
      // Tìm document có song_id == songId
      final query = await playHistoryRef.where('song_id', isEqualTo: songId).limit(1).get();
      if (query.docs.isNotEmpty) {
        // Đã có, chỉ update played_at
        await playHistoryRef.doc(query.docs.first.id).update({
          'played_at': FieldValue.serverTimestamp(),
        });
      } else {
        // Chưa có, thêm mới
        await playHistoryRef.add({
          'song_id': songId,
          'played_at': FieldValue.serverTimestamp(),
        });
      }
      // Sau khi thêm/cập nhật, load lại playedSongIds
      await _initPlayedSongIds();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _togglePlayPause() {
    if (_duration.inSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể phát: Link nhạc không hợp lệ')),
      );
      return;
    }

    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _playerController.resume();
        _rotationController.repeat();
      } else {
        _playerController.pause();
        _rotationController.stop(canceled: false);
      }
    });
  }

  Future<List<SongModel>> fetchSimilarSongs(SongModel currentSong) async {
      final firestore = FirebaseFirestore.instance;
      final allDocs = await firestore.collection('songs').get();

      final Set<String> currentArtistIds = currentSong.artistIds.toSet();
      final List<SongModel> similar = [];
      final List<SongModel> fallback = [];

      for (var doc in allDocs.docs) {
        final data = doc.data();
        final songId = doc.id;

        if (songId.trim() == currentSong.id.trim()) continue; // ✅ Fix không lặp bài hiện tại

        // ✅ Parse artistId linh hoạt
        List<String> songArtistIds = [];
        if (data['artist_id'] is List) {
          songArtistIds = List<String>.from(data['artist_id']);
        } else if (data['artist_id'] is String) {
          final raw = data['artist_id'] as String;
          songArtistIds = raw.replaceAll('[', '').replaceAll(']', '').split(',').map((s) => s.trim()).toList();
        }

        final song = SongModel.fromMap(songId, data);

        // ✅ Nếu có ít nhất 1 nghệ sĩ trùng → thêm
        if (currentArtistIds.any((id) => songArtistIds.contains(id))) {
          similar.add(song);
        } else {
          fallback.add(song);
        }
      }

      if (similar.isNotEmpty) {
        return similar;
      } else {
        fallback.shuffle();
        return fallback.take(4).toList();
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(MyColor.white),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, color: Color(MyColor.black)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.song.name.toUpperCase(),
          style: TextStyle(
            color: Color(MyColor.pr4),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            padding: const EdgeInsets.all(0),
            icon: const Icon(Icons.more_vert),
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Color(MyColor.pr5), width: 1.0),
            ),
            onSelected: (value) async {
              if (value == 'favorite') {
                try {
                  await ArtistController.saveFavoriteSongs({widget.song.id});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm vào yêu thích!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Có lỗi xảy ra: $e'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } else if (value == 'playlist') {
                _showPlaylistDialog(context, widget.song.id);
              } else if (value == 'like_artist') {
                try {
                  await ArtistController.saveFavoriteArtists({...widget.song.artistIds});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm vào yêu thích!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Có lỗi xảy ra: $e'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'playlist',
                height: 38, // Giảm chiều cao
                padding: const EdgeInsets.symmetric(horizontal: 2,),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(MyColor.pr4), // Màu nền riêng
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: const Text(
                    '➕ Thêm vào danh sách',
                    style: TextStyle(color: Color(MyColor.se5)),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'like_artist',
                height: 38, // Giảm chiều cao
                padding: const EdgeInsets.symmetric(horizontal: 2,),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(MyColor.pr5), // Màu nền riêng
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: const Text(
                    '🎤 Thích nghệ sĩ',
                    style: TextStyle(color: Color(MyColor.se5)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        children: [
          MusicPlayerScreen(
            song: widget.song,
            currentAngle: _currentAngle,
            isPlaying: isPlaying,
            isFavorite: isFavorite,
            duration: _duration,
            position: _position,
            artistNames: artistNames,
            formatDuration: _formatDuration,
            togglePlayPause: _togglePlayPause,
            toggleFavorite: () async {
              final controller = MusicController();
              await controller.toggleFavoriteSong(widget.song);
              final result = await controller.isFavoriteSong(widget.song.id);
              if (mounted) {
                setState(() {
                  isFavorite = result;
                });
              }
            },
            onSeek: (value) async {
              if (_duration.inSeconds > 0) {
                final newPos = Duration(seconds: value.toInt());
                await _playerController.audioPlayer.seek(newPos);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không thể tua: chưa tải được độ dài bài hát')),
                );
              }
            },
            onNext: _handleNext,
            onPrev: _handlePrev,
          ),
          MusicPlaylistScreen(
            song: widget.song,
            playlist: widget.playlist,
            artistNames: artistNames,
            similarSongsFuture: _similarSongsFuture,
          ),
        ],
      ),
    );
  }

  void _handleNext() async {
    _playerController.stop();

    final playlist = widget.playlist;

    if (playlist != null && playlist.isNotEmpty) {
      final currentIndex = playlist.indexWhere((s) => s.id == widget.song.id);
      if (currentIndex >= 0 && currentIndex < playlist.length - 1) {
        final nextSong = playlist[currentIndex + 1];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerWithSwipeScreen(
              song: nextSong,
              playlist: playlist,
            ),
          ),
        );
        return;
      }
    }

    // Nếu không có playlist hoặc đã ở cuối, fallback dùng playedSongIds
    await _loadPlayedSongIds();
    int currentIdx = playedSongIds.lastIndexOf(widget.song.id);
    if (currentIdx < playedSongIds.length - 1) {
      final nextSongId = playedSongIds[currentIdx + 1];
      final songDoc = await FirebaseFirestore.instance.collection('songs').doc(nextSongId).get();
      if (songDoc.exists) {
        final musicController = MusicController();
        final data = songDoc.data() as Map<String, dynamic>;
        data['audio_url'] = musicController.convertDriveLink(data['audio_url'] ?? '');
        final nextSong = SongModel.fromMap(songDoc.id, data);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerWithSwipeScreen(song: nextSong),
          ),
        );
      }
    } else {
      // Random bài mới
      final snapshot = await FirebaseFirestore.instance.collection('songs').get();
      final musicController = MusicController();
      final allSongs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['audio_url'] = musicController.convertDriveLink(data['audio_url'] ?? '');
        return SongModel.fromMap(doc.id, data);
      }).toList();
      allSongs.removeWhere((s) => s.id == widget.song.id);
      if (!mounted) return;
      if (allSongs.isNotEmpty) {
        allSongs.shuffle();
        final nextSong = allSongs.first;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerWithSwipeScreen(song: nextSong),
          ),
        );
      }
    }
  }


  void _handlePrev() async {
    _playerController.stop();

    final playlist = widget.playlist;

    if (playlist != null && playlist.isNotEmpty) {
      final currentIndex = playlist.indexWhere((s) => s.id == widget.song.id);
      if (currentIndex > 0) {
        final prevSong = playlist[currentIndex - 1];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerWithSwipeScreen(
              song: prevSong,
              playlist: playlist,
            ),
          ),
        );
        return;
      }
    }

    // Nếu không có playlist hoặc đã ở đầu, fallback dùng playedSongIds
    await _loadPlayedSongIds();
    int currentIdx = playedSongIds.lastIndexOf(widget.song.id);
    if (currentIdx > 0) {
      final prevSongId = playedSongIds[currentIdx - 1];
      final songDoc = await FirebaseFirestore.instance.collection('songs').doc(prevSongId).get();
      if (songDoc.exists) {
        final musicController = MusicController();
        final data = songDoc.data() as Map<String, dynamic>;
        data['audio_url'] = musicController.convertDriveLink(data['audio_url'] ?? '');
        final prevSong = SongModel.fromMap(songDoc.id, data);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerWithSwipeScreen(song: prevSong),
          ),
        );
      }
    }
  }


  Future<void> _playSafe() async {
    // ✅ Nếu bài hát hiện tại đã được load → kiểm tra trạng thái thực tế
    if (_playerController.currentUrl == widget.song.linkMp3) {
      print("✅ Bài hát đã được phát, kiểm tra trạng thái thực tế");

      final state = _playerController.audioPlayer.state;
      setState(() {
        isPlaying = (state == PlayerState.playing);
        if (isPlaying) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      });

      return;
    }

    // ✅ Nếu chưa phát → phát mới
    final ok = await _playerController.play(
      url: widget.song.linkMp3,
      songName: widget.song.name,
      artistName: widget.song.artistIds.join(", "),
      imageUrl: widget.song.imageUrl,
      songModel: widget.song,
    );

    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Không thể phát nhạc: Link lỗi hoặc không tồn tại')),
        );
      }
      setState(() {
        isPlaying = false;
        _rotationController.stop();
        _duration = Duration.zero;
        _position = Duration.zero;
      });
      return;
    }

    if (!mounted) return; // ✅ Thêm dòng này trước setState
      setState(() {
        isPlaying = true;
        _rotationController.repeat();
      });
    }

  void _showPlaylistDialog(BuildContext context, String songId) async {
    final playlists = await PlaylistController.getUserPlaylists();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(MyColor.pr1),
          title: const Text(
            'Chọn playlist', 
            style: TextStyle(
              color: Color(MyColor.se2), 
              fontWeight: FontWeight.bold
            ),),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (playlists.isNotEmpty)
                    ...playlists.map((playlist) => ListTile(
                          tileColor: Color(MyColor.pr2), // Thêm màu nền cho ListTile
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(
                              color: Color(MyColor.pr6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () async {
                            await ArtistController.saveSongToPlaylist(
                              playlistId: playlist.id,
                              songId: songId,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã thêm vào playlist!')),
                            );
                          },
                        )),
                  const SizedBox(height: 8),
                  Text(
                    'Hoặc',
                    style: TextStyle(
                      color: Color(MyColor.se5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên playlist mới',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final newPlaylistName = nameController.text.trim();
                      if (newPlaylistName.isNotEmpty) {
                        await ArtistController.saveSongToPlaylist(
                          playlistId: null,
                          songId: songId,
                          playlistName: newPlaylistName,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã tạo playlist và thêm bài hát!')),
                        );
                      }
                    },
                    child: const Text(
                      'Tạo mới & Thêm',
                      style: TextStyle(color: Color(MyColor.pr5))
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}