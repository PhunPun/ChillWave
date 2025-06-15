import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chillwave/models/song_model.dart';
import '../../themes/colors/colors.dart';

class MusicPlayerWithSwipeScreen extends StatefulWidget {
  final SongModel song;
  final List<SongModel>? playlist; // Danh sách bài hát tương tự

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
  late AudioPlayer _audioPlayer;
  late AnimationController _rotationController;
  late PageController _pageController;
  
  double _currentAngle = 0.0;
  bool isPlaying = true;
  bool isFavorite = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<String> artistNames = [];
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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
    _audioPlayer.play(UrlSource(widget.song.linkMp3));

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _loadArtistNames();
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

  @override
  void dispose() {
    _rotationController.dispose();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _audioPlayer.resume();
        _rotationController.repeat();
      } else {
        _audioPlayer.pause();
        _rotationController.stop(canceled: false);
      }
    });
  }

  // Màn hình player chính
  Widget _buildPlayerScreen() {
    return Container(
      color: Color(MyColor.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          children: [
            SizedBox(height: 60),
            // Album Art
            Transform.rotate(
              angle: _currentAngle,
              child: Container(
                width: 280,
                height: 280,
                child: ClipOval(
                  child: Image.network(
                    widget.song.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.music_note, size: 80),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
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
                              widget.song.name.toUpperCase(),
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
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Color(MyColor.pr4) : Color(MyColor.grey),
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Progress Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Color(MyColor.pr4),
                      inactiveTrackColor: Color(MyColor.se1),
                      thumbColor: Color(MyColor.pr4),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                      onChanged: (value) async {
                        final newPos = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(newPos);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(MyColor.grey),
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(MyColor.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.shuffle, color: Color(MyColor.grey), size: 24),
                      Icon(Icons.skip_previous, color: Color(MyColor.black), size: 32),
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
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      Icon(Icons.skip_next, color: Color(MyColor.black), size: 32),
                      Icon(Icons.repeat, color: Color(MyColor.grey), size: 24),
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  // Màn hình danh sách bài hát tương tự
  Widget _buildPlaylistScreen() {
    return Container(
      color: Color(MyColor.white),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Header với thông tin bài hát hiện tại
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(MyColor.pr4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.song.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          width: 60,
                          height: 60,
                          color: Color(MyColor.se1),
                          child: Icon(Icons.music_note),
                        ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(MyColor.pr4),
                        ),
                      ),
                      Text(
                        artistNames.isNotEmpty ? artistNames.join(', ') : 'Soobin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(MyColor.grey),
                        ),
                      ),
                      Text(
                        'Đã phát nổi bật',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(MyColor.grey),
                        ),
                      ),
                      Text(
                        '2024',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(MyColor.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stats row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Color(MyColor.grey)),
                SizedBox(width: 4),
                Text('214.2K', style: TextStyle(color: Color(MyColor.grey))),
                Spacer(),
                Text('6M', style: TextStyle(color: Color(MyColor.grey))),
                SizedBox(width: 4),
                Icon(Icons.headphones, size: 20, color: Color(MyColor.grey)),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Bài hát tương tự header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Bài hát tương tự',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(MyColor.black),
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right, color: Color(MyColor.grey)),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Danh sách bài hát
          Expanded(
            child: ListView.builder(
              itemCount: widget.playlist?.length ?? 3, // Default 3 items if no playlist
              itemBuilder: (context, index) {
                // Dữ liệu mẫu nếu không có playlist
                final songs = widget.playlist ?? [
                  widget.song, // Current song
                  widget.song, // Duplicate for demo
                  widget.song, // Duplicate for demo
                ];
                
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(MyColor.pr4).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          songs[index].imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 50,
                                height: 50,
                                color: Color(MyColor.se1),
                                child: Icon(Icons.music_note, size: 20),
                              ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              songs[index].name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(MyColor.black),
                              ),
                            ),
                            Text(
                              'Nghệ sĩ ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(MyColor.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.play_arrow, color: Color(MyColor.pr4)),
                        onPressed: () {
                          // Handle play different song
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
            icon: Icon(Icons.more_horiz, color: Color(MyColor.black)),
            onPressed: () {},
          ),
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
          _buildPlayerScreen(),
          _buildPlaylistScreen(),
        ],
      ),
      // Bottom player - chỉ hiện ở playlist screen (page index 1)
      bottomNavigationBar: _currentPageIndex == 1 ? Container(
        height: 120,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(MyColor.white),
        ),
        child: Column(
          children: [
            // Thanh progress với slider có thể tương tác
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Color(MyColor.pr4),
                inactiveTrackColor: Color(MyColor.se1),
                thumbColor: Color(MyColor.pr4),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                trackHeight: 2,
                overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
              ),
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.clamp(0, _duration.inSeconds).toDouble(),
                onChanged: (value) async {
                  final newPos = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(newPos);
                },
              ),
            ),
            // Hiển thị thời gian thực
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(MyColor.grey),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(MyColor.grey),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Control buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Thông tin bài hát
                Expanded(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          widget.song.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 40,
                                height: 40,
                                color: Color(MyColor.se1),
                                child: Icon(Icons.music_note, size: 16),
                              ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.song.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(MyColor.black),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              artistNames.isNotEmpty ? artistNames.join(', ') : 'Loading...',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(MyColor.grey),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Control buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle, color: Color(MyColor.grey), size: 20),
                      onPressed: () {},
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Color(MyColor.black), size: 24),
                      onPressed: () {},
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    // Play/Pause button
                    Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Color(MyColor.pr4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Color(MyColor.white),
                          size: 20,
                        ),
                        onPressed: _togglePlayPause,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Color(MyColor.black), size: 24),
                      onPressed: () {},
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      icon: Icon(Icons.repeat, color: Color(MyColor.grey), size: 20),
                      onPressed: () {},
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ) : null,
    );
  }
}