import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../themes/colors/colors.dart';
import '../../controllers/acrcloud_controller.dart';

class SearchMusicPage extends StatefulWidget {
  const SearchMusicPage({Key? key}) : super(key: key);

  @override
  State<SearchMusicPage> createState() => _SearchMusicPageState();
}

class _SearchMusicPageState extends State<SearchMusicPage>
    with TickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ACRCloudController _acrController = ACRCloudController();

  bool _isRecording = false;
  bool _isRecognizing = false;
  bool _hasPermission = false;
  String? _recordedFilePath;
  String _recognizedSong = "";
  String _confidence = "";
  int _score = 0;
  String _artist = "";
  String _album = "";

  AnimationController? _pulseController;
  AnimationController? _waveController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _waveAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initRecorder();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController!, curve: Curves.easeInOut),
    );
  }

  Future<void> _initRecorder() async {
    try {
      // Request permissions
      final micPermission = await Permission.microphone.request();
      final storagePermission = await Permission.storage.request();

      if (micPermission.isGranted && storagePermission.isGranted) {
        await _recorder.openRecorder();
        setState(() {
          _hasPermission = true;
        });
      } else {
        setState(() {
          _hasPermission = false;
        });
        _showErrorSnackBar(
          'Cần cấp quyền microphone và storage để sử dụng chức năng này',
        );
      }
    } catch (e) {
      print('Error initializing recorder: $e');
      _showErrorSnackBar('Lỗi khởi tạo microphone');
    }
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      await _initRecorder();
      if (!_hasPermission) return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/recorded_music_${DateTime.now().millisecondsSinceEpoch}.aac';
      _recordedFilePath = filePath;

      // Sử dụng cài đặt tương tự như test.dart
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS, // Format tốt cho ACRCloud
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 1,
      );

      setState(() {
        _isRecording = true;
        _recognizedSong = "";
        _confidence = "";
        _score = 0;
        _artist = "";
        _album = "";
      });

      if (mounted) {
        _pulseController?.repeat(reverse: true);
        _waveController?.repeat();
      }

      // Auto stop after 15 seconds
      Future.delayed(const Duration(seconds: 15), () {
        if (_isRecording && mounted) {
          _stopRecording();
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
      _showErrorSnackBar('Không thể bắt đầu ghi âm: ${e.toString()}');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _isRecognizing = true;
      });

      if (mounted) {
        _pulseController?.stop();
        _waveController?.stop();
      }

      if (_recordedFilePath != null) {
        final result = await _acrController.recognizeSong(
          File(_recordedFilePath!),
        );

        setState(() {
          _isRecognizing = false;
        });

        if (result != null) {
          // Parse result similar to test.dart approach
          final songInfo = _parseRecognitionResult(result);
          setState(() {
            _recognizedSong =
                (songInfo['title'] ?? 'Không nhận diện được').trim();
            _artist = (songInfo['artist'] ?? '').trim();
            _album = (songInfo['album'] ?? '').trim();
            _confidence = songInfo['confidence'] ?? '';
            _score = songInfo['score'] ?? 0;
          });

          print('Recognized song: "$_recognizedSong"');
          print('Artist: "$_artist"');

          if (_score < 50) {
            _showErrorSnackBar(
              'Độ tin cậy thấp ($_confidence). Hãy thử lại với âm thanh rõ hơn.',
            );
          }
        } else {
          _showErrorSnackBar(
            'Không nhận diện được bài hát. Hãy thử lại với đoạn nhạc rõ hơn.',
          );
        }
      } else {
        setState(() {
          _isRecognizing = false;
        });
        _showErrorSnackBar('Lỗi: Không tìm thấy file ghi âm');
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isRecognizing = false;
      });
      print('Error stopping recording: $e');
      _showErrorSnackBar('Lỗi khi dừng ghi âm: ${e.toString()}');
    }
  }

  Map<String, dynamic> _parseRecognitionResult(Map<String, dynamic> result) {
    // Parse result similar to how test.dart would handle it
    String title = result['display'] ?? result['title'] ?? 'Không xác định';

    // Loại bỏ tên nghệ sĩ khỏi tên bài hát nếu có
    if (title.contains(' - ')) {
      // Lấy phần trước dấu " - " (thường là tên bài hát)
      title = title.split(' - ')[0].trim();
    }

    String confidence = result['confidence']?.toString() ?? '';
    int score =
        (result['score'] is int)
            ? result['score']
            : (result['score'] is String)
            ? int.tryParse(result['score']) ?? 0
            : 0;

    return {
      'title': title,
      'artist': '', // Không lưu tên nghệ sĩ
      'album': '', // Không lưu tên album
      'confidence': confidence,
      'score': score,
    };
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(MyColor.red),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showCancelRecognitionDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy nhận diện?'),
          content: const Text(
            'Bạn có muốn hủy quá trình nhận diện bài hát không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                setState(() {
                  _isRecognizing = false;
                });
                Navigator.pop(context); // Go back to search page
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _resetSearch() {
    setState(() {
      _recognizedSong = "";
      _artist = "";
      _album = "";
      _confidence = "";
      _score = 0;
    });
  }

  @override
  void dispose() {
    try {
      _pulseController?.dispose();
      _waveController?.dispose();
    } catch (e) {
      print('Error disposing animation controllers: $e');
    }
    try {
      _recorder.closeRecorder();
    } catch (e) {
      print('Error closing recorder: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isRecording && !_isRecognizing,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // Handle back button when recording or recognizing
        if (_isRecording) {
          _stopRecording();
        } else if (_isRecognizing) {
          // Show dialog asking if user wants to cancel recognition
          _showCancelRecognitionDialog();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(MyColor.pr2),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(MyColor.se4)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Nhận diện bài hát',
            style: TextStyle(
              color: Color(MyColor.se4),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_recognizedSong.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(MyColor.se4)),
                onPressed: _resetSearch,
                tooltip: 'Thử lại',
              ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(MyColor.pr2),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Music Animation with enhanced visual feedback
                          AnimatedBuilder(
                            animation:
                                _pulseAnimation ??
                                const AlwaysStoppedAnimation(1.0),
                            builder: (context, child) {
                              return Transform.scale(
                                scale:
                                    _isRecording
                                        ? (_pulseAnimation?.value ?? 1.0)
                                        : 1.0,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        _isRecording
                                            ? const Color(
                                              MyColor.red,
                                            ).withOpacity(0.3)
                                            : _isRecognizing
                                            ? const Color(
                                              MyColor.pr5,
                                            ).withOpacity(0.3)
                                            : const Color(
                                              MyColor.pr5,
                                            ).withOpacity(0.1),
                                    border: Border.all(
                                      color:
                                          _isRecording
                                              ? const Color(MyColor.red)
                                              : const Color(MyColor.pr5),
                                      width: 3,
                                    ),
                                  ),
                                  child:
                                      _isRecognizing
                                          ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(MyColor.pr5),
                                              strokeWidth: 3,
                                            ),
                                          )
                                          : Icon(
                                            _recognizedSong.isNotEmpty
                                                ? Icons.music_note
                                                : _isRecording
                                                ? Icons.mic
                                                : Icons.music_note,
                                            size: 70,
                                            color:
                                                _isRecording
                                                    ? const Color(MyColor.red)
                                                    : const Color(MyColor.pr5),
                                          ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // Enhanced Status Text
                          Text(
                            _isRecording
                                ? 'Đang nghe nhạc...'
                                : _isRecognizing
                                ? 'Đang nhận diện...'
                                : _recognizedSong.isNotEmpty
                                ? 'Đã nhận diện!'
                                : 'Phát nhạc để nhận diện',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isRecording
                                      ? const Color(MyColor.red)
                                      : _recognizedSong.isNotEmpty
                                      ? const Color(MyColor.pr5)
                                      : const Color(MyColor.se4),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            _isRecording
                                ? 'Đang thu âm... (Tự động dừng sau 15s)\nGiữ máy gần nguồn phát nhạc'
                                : _isRecognizing
                                ? 'Đang phân tích với ACRCloud...\nVui lòng chờ một chút'
                                : _recognizedSong.isNotEmpty
                                ? 'Nhấn "Tìm kiếm" để tìm bài hát này\nhoặc thử nhận diện bài khác'
                                : 'Nhấn nút và phát nhạc với âm lượng vừa phải\nTốt nhất là đoạn điệp khúc của bài hát',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(MyColor.grey),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Enhanced Recognition Result
                          if (_recognizedSong.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    size: 32,
                                    color: const Color(MyColor.pr5),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Bài hát được nhận diện:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(MyColor.grey),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _recognizedSong,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(MyColor.se4),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Enhanced Bottom Controls
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!_hasPermission) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(MyColor.red).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Color(MyColor.red),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Cần cấp quyền microphone để sử dụng chức năng này',
                                  style: TextStyle(color: Color(MyColor.red)),
                                ),
                              ),
                              TextButton(
                                onPressed: _initRecorder,
                                child: const Text('Cấp quyền'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Record Button
                      GestureDetector(
                        onTap:
                            _hasPermission
                                ? (_isRecognizing
                                    ? null
                                    : (_isRecording
                                        ? _stopRecording
                                        : _startRecording))
                                : _initRecorder,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                !_hasPermission
                                    ? Colors.grey
                                    : _isRecording
                                    ? const Color(MyColor.red)
                                    : _isRecognizing
                                    ? Colors.grey
                                    : const Color(MyColor.pr5),
                            boxShadow: [
                              BoxShadow(
                                color: (!_hasPermission
                                        ? Colors.grey
                                        : _isRecording
                                        ? const Color(MyColor.red)
                                        : const Color(MyColor.pr5))
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            !_hasPermission
                                ? Icons.mic_off
                                : _isRecording
                                ? Icons.stop
                                : _isRecognizing
                                ? Icons.hourglass_empty
                                : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        !_hasPermission
                            ? 'Nhấn để cấp quyền'
                            : _isRecording
                            ? 'Nhấn để dừng ghi âm'
                            : _isRecognizing
                            ? 'Đang xử lý...'
                            : 'Nhấn để bắt đầu',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(MyColor.grey),
                        ),
                      ),

                      if (_recognizedSong.isNotEmpty &&
                          !_isRecording &&
                          !_isRecognizing) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Return only the song name to search (without artist)
                                  // Clean up the song name before returning
                                  String cleanSongName = _recognizedSong.trim();
                                  print(
                                    'Returning song name to search: "$cleanSongName"',
                                  );
                                  Navigator.pop(context, cleanSongName);
                                },
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Tìm kiếm bài hát',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(MyColor.pr5),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _resetSearch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Color(MyColor.se4),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
