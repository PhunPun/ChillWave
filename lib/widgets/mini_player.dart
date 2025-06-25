import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/controllers/music_state_provider.dart';
import 'package:chillwave/controllers/playlist_controller.dart';
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
import 'package:chillwave/pages/playmusicscreen/playmusic.dart';

class MiniPlayer extends StatefulWidget {
  final SongModel song;
  final List<SongModel>? playlist;
  final void Function(SongModel)? onSongChanged;

  const MiniPlayer({
    Key? key, 
    required this.song,
    this.playlist,
    this.onSongChanged,
  }) : super(key: key);

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer>
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );

    _rotationController.addListener(() {
      if (isPlaying) {
        setState(() {
          _currentAngle = _rotationController.value * 2 * 3.1416;
        });
      }
    });

    _rotationController.repeat();
    
    // Sử dụng PlayerController để phát nhạc
    _playSafe(widget.song);
    // Tăng play_count khi bắt đầu phát nhạc
    MusicController().incrementPlayCount(widget.song.id);

    _initPlayedSongIds();

    _playerController.audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() => _duration = d);
      }
    });

    _playerController.audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });
    _updateInitialPlayerState();
      _playerController.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    }); 
    _loadArtistNames();
    _checkIfFavorite();
    _addToPlayHistory(widget.song.id); // chỉ update Firestore
    final controller = PlayerController();
    controller.onSongComplete = () {
      _handleNext(); // Gọi logic chuyển bài tiếp theo
    };
  }

  @override
    void didUpdateWidget(covariant MiniPlayer oldWidget) {
      super.didUpdateWidget(oldWidget);

      if (oldWidget.song.id != widget.song.id) {
        _handleSongChange();
      }
    }
  Future<void> _handleSongChange() async {
    _checkIfFavorite();
    _loadArtistNames();
    _updateInitialPlayerState();
    await _addToPlayHistory(widget.song.id); // cũng nên gọi lại để log đúng bài mới
    await _initPlayedSongIds();              // cập nhật lịch sử nếu cần
    await _playSafe(widget.song);            // để tự động phát bài mới khi cập nhật
    MusicController().incrementPlayCount(widget.song.id); // update play count
  }
  void _updateInitialPlayerState() {
    final state = _playerController.audioPlayer.state;

    setState(() {
      isPlaying = state == PlayerState.playing;
    });
  }

  Future<void> _loadPlayedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    playedSongIds = prefs.getStringList('playedSongIds') ?? [];
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


  @override
  Widget build(BuildContext context) {
    if(widget.song.name.isNotEmpty) {print('ssssssssssssss'+widget.song.name);}
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerWithSwipeScreen(
              song: widget.song,
              playlist: widget.playlist,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal:8, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6A85B6), Color(0xFFBC6EC7)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar bài hát
            ClipOval(
              child: Image.network(
                widget.song.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                  child: const Icon(Icons.music_note, size: 32, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Thông tin bài hát
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.song.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artistNames.isNotEmpty ? artistNames.join(", ") : "",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Các nút điều khiển
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Yêu thích
                  InkWell(
                    onTap: () async {
                      final controller = MusicController();
                      await controller.toggleFavoriteSong(widget.song);
                      _checkIfFavorite();
                    },
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  // Bài trước
                  InkWell(
                    onTap: _handlePrev,
                    child: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  // Phát / Tạm dừng
                  InkWell(
                    onTap: _togglePlayPause,
                    child: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // Bài tiếp
                  InkWell(
                    onTap: _handleNext,
                    child: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        final musicStateProvider = context.read<MusicStateProvider>();
        musicStateProvider.setCurrentSong(nextSong);
        musicStateProvider.setCurrentPlaylist(playlist);
        await _playSafe(nextSong);
        if (widget.onSongChanged != null) widget.onSongChanged!(nextSong);
        setState(() {});
        return;
      }
    }

    // Fallback dùng playedSongIds nếu không có playlist
    await _loadPlayedSongIds();
    final currentIdx = playedSongIds.lastIndexOf(widget.song.id);
    if (currentIdx < playedSongIds.length - 1) {
      final nextSongId = playedSongIds[currentIdx + 1];
      final songDoc = await FirebaseFirestore.instance.collection('songs').doc(nextSongId).get();
      if (songDoc.exists) {
        final musicController = MusicController();
        final data = songDoc.data() as Map<String, dynamic>;
        data['audio_url'] = musicController.convertDriveLink(data['audio_url'] ?? '');
        final nextSong = SongModel.fromMap(songDoc.id, data);
        final musicStateProvider = context.read<MusicStateProvider>();
        musicStateProvider.setCurrentSong(nextSong);
        musicStateProvider.setCurrentPlaylist(widget.playlist);
        await _playSafe(nextSong);
        if (widget.onSongChanged != null) widget.onSongChanged!(nextSong);
        setState(() {});
        return;
      }
    }

    // Nếu cuối danh sách: random bài khác
    final snapshot = await FirebaseFirestore.instance.collection('songs').get();
    final musicController = MusicController();
    final allSongs = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['audio_url'] = musicController.convertDriveLink(data['audio_url'] ?? '');
      return SongModel.fromMap(doc.id, data);
    }).toList();

    allSongs.removeWhere((s) => s.id == widget.song.id);
    if (allSongs.isNotEmpty) {
      allSongs.shuffle();
      final nextSong = allSongs.first;
      final musicStateProvider = context.read<MusicStateProvider>();
      musicStateProvider.setCurrentSong(nextSong);
      musicStateProvider.setCurrentPlaylist(widget.playlist);
      await _playSafe(nextSong);
      if (widget.onSongChanged != null) widget.onSongChanged!(nextSong);
      setState(() {});
    }
  }


  void _handlePrev() async {
    _playerController.stop();

    final playlist = widget.playlist;
    if (playlist != null && playlist.isNotEmpty) {
      final currentIndex = playlist.indexWhere((s) => s.id == widget.song.id);
      if (currentIndex > 0) {
        final prevSong = playlist[currentIndex - 1];
        final musicStateProvider = context.read<MusicStateProvider>();
        musicStateProvider.setCurrentSong(prevSong);
        musicStateProvider.setCurrentPlaylist(playlist);
        await _playSafe(prevSong);
        if (widget.onSongChanged != null) widget.onSongChanged!(prevSong);
        setState(() {});
        return;
      }
    }

    // Fallback nếu không có playlist
    await _loadPlayedSongIds();
    final currentIdx = playedSongIds.lastIndexOf(widget.song.id);
    if (currentIdx > 0) {
      final prevSongId = playedSongIds[currentIdx - 1];
      final songDoc = await FirebaseFirestore.instance.collection('songs').doc(prevSongId).get();
      if (songDoc.exists) {
        final musicController = MusicController();
        final data = songDoc.data() as Map<String, dynamic>;
        data['audio_url'] = musicController.convertDriveLink(data['audio_url'] ?? '');
        final prevSong = SongModel.fromMap(songDoc.id, data);
        final musicStateProvider = context.read<MusicStateProvider>();
        musicStateProvider.setCurrentSong(prevSong);
        musicStateProvider.setCurrentPlaylist(widget.playlist);
        await _playSafe(prevSong);
        if (widget.onSongChanged != null) widget.onSongChanged!(prevSong);
        setState(() {});
      }
    }
  }


  Future<void> _playSafe(SongModel song) async {
    // Nếu đã phát bài này rồi, không phát lại
    if (_playerController.currentUrl == song.linkMp3) {
      print("✅ Đang phát bài này rồi, không phát lại.");
      setState(() {
        isPlaying = true;
      });
      return;
    }

    final ok = await _playerController.play(
      url: song.linkMp3,
      songName: song.name,
      artistName: song.artistIds.join(", "),
      imageUrl: song.imageUrl,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Không thể phát nhạc: Link nhạc lỗi hoặc không tồn tại!')),
      );

      setState(() {
        isPlaying = false;
        _rotationController.stop();
        _duration = Duration.zero;
        _position = Duration.zero;
      });

      return; // ⛔ Dừng tại đây nếu play thất bại
    }

    // Nếu phát thành công
    setState(() {
      isPlaying = true;
      _rotationController.repeat();
    });

    print("▶️ Đang phát bài mới: ${song.name}");
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