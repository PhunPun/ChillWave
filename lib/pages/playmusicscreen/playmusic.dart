import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chillwave/models/song_model.dart';

class MusicPlayerScreen extends StatefulWidget {
  final SongModel song;
  const MusicPlayerScreen({Key? key, required this.song}) : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _rotationController;
  double _currentAngle = 0.0;
  bool isPlaying = true;
  bool isFavorite = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<String> artistNames = [];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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
      print("🔊 Tổng thời lượng bài hát: \${d.inSeconds} giây");
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
      print("🎵 Đang ở vị trí: \${p.inSeconds} giây");
    });

    // 👉 Lấy danh sách nghệ sĩ
    // Thay thế phần xử lý nghệ sĩ trong initState() của MusicPlayerScreen

// 👉 Lấy danh sách nghệ sĩ
// Thay thế phần xử lý nghệ sĩ trong initState() của MusicPlayerScreen

// 👉 Lấy danh sách nghệ sĩ
if (widget.song.artistIds.isNotEmpty) {
  print("📋 Danh sách artistIds nhận được: ${widget.song.artistIds}");
  
  // Xử lý trường hợp artistIds có thể chứa nested data
  List<String> flattenedIds = [];
  
  for (var id in widget.song.artistIds) {
    // Nếu id là string bình thường
    if (id is String) {
      final trimmed = id.trim();
      if (trimmed.isNotEmpty && !trimmed.startsWith('[') && !trimmed.endsWith(']')) {
        flattenedIds.add(trimmed);
      } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        // Nếu id là string representation của array "[id1, id2]"
        final cleaned = trimmed.substring(1, trimmed.length - 1);
        final parts = cleaned.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
        flattenedIds.addAll(parts);
      }
    }
  }
  
  print("🔧 Danh sách IDs sau khi xử lý: $flattenedIds");
  
  if (flattenedIds.isNotEmpty) {
    Future.wait(
      flattenedIds.map((id) => FirebaseFirestore.instance.collection('artists').doc(id).get()),
    ).then((docs) {
      print("📄 Số documents nhận được: ${docs.length}");
      
      final names = <String>[];
      for (var doc in docs) {
        print("📄 Doc ID: ${doc.id}, exists: ${doc.exists}");
        if (doc.exists) {
          final data = doc.data();
          print("📄 Doc data: $data");
          final artistName = data?['artist_name']?.toString().trim() ?? '';
          if (artistName.isNotEmpty) {
            names.add(artistName);
            print("✅ Thêm nghệ sĩ: $artistName");
          }
        }
      }

      setState(() {
        artistNames = names.isNotEmpty ? names : ['Không tìm được nghệ sĩ'];
      });
      print("🎤 Danh sách nghệ sĩ cuối cùng: $artistNames");
    }).catchError((e) {
      print("❌ Lỗi khi lấy danh sách nghệ sĩ: $e");
      setState(() {
        artistNames = ['Không tìm được nghệ sĩ'];
      });
    });
  } else {
    print("⚠️ Không có ID nghệ sĩ hợp lệ sau khi flatten");
    setState(() {
      artistNames = ['Không tìm được nghệ sĩ'];
    });
  }
} else {
  print("⚠️ artistIds rỗng");
  setState(() {
    artistNames = ['Không tìm được nghệ sĩ'];
  });
}
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.song.name.toUpperCase(),
          style: TextStyle(color: Colors.pink, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 20),
            Transform.rotate(
              angle: _currentAngle,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.song.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.music_note, size: 80),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        artistNames.isNotEmpty ? artistNames.join(', ') : 'Đang tải nghệ sĩ...',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.pink : Colors.grey[400],
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
            SizedBox(height: 24),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.pink,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.pink,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text(_formatDuration(_duration), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.shuffle, color: Colors.grey, size: 24),
                Icon(Icons.skip_previous, color: Colors.black, size: 32),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
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
                    },
                  ),
                ),
                Icon(Icons.skip_next, color: Colors.black, size: 32),
                Icon(Icons.repeat, color: Colors.grey, size: 24),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
