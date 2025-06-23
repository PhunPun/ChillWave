import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../themes/colors/colors.dart';
import '../../controllers/acrcloud_controller.dart';

// Enum để quản lý trạng thái của màn hình một cách rõ ràng
enum RecognitionState {
  noPermission,
  requestingPermission,
  idle,
  listening,
  recognizing,
  resultFound,
}

class SearchMusicPage extends StatefulWidget {
  const SearchMusicPage({Key? key}) : super(key: key);

  @override
  State<SearchMusicPage> createState() => _SearchMusicPageState();
}

class _SearchMusicPageState extends State<SearchMusicPage>
    with TickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ACRCloudController _acrController = ACRCloudController();

  // Biến trạng thái duy nhất quản lý toàn bộ màn hình
  RecognitionState _state = RecognitionState.idle;

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
    // Chỉ kiểm tra quyền khi khởi động, không yêu cầu
    _checkInitialPermission();
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
  }

  // Kiểm tra trạng thái quyền hiện tại một cách lặng lẽ
  Future<void> _checkInitialPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      await _recorder.openRecorder();
      setState(() => _state = RecognitionState.idle);
    } else {
      setState(() => _state = RecognitionState.noPermission);
    }
  }

  // Yêu cầu quyền chỉ khi người dùng nhấn nút
  Future<void> _requestPermission() async {
    if (_state == RecognitionState.requestingPermission) return;
    setState(() => _state = RecognitionState.requestingPermission);

    final status = await Permission.microphone.request();

    if (!mounted) return;

    if (status.isGranted) {
      await _recorder.openRecorder();
      setState(() => _state = RecognitionState.idle);
      _showFeedbackSnackBar(
        'Đã cấp quyền! Sẵn sàng nhận diện.',
        isError: false,
      );
    } else {
      setState(() => _state = RecognitionState.noPermission);
      if (status.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog();
      } else {
        _showFeedbackSnackBar(
          'Cần cấp quyền microphone để sử dụng chức năng này.',
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (_state != RecognitionState.idle &&
        _state != RecognitionState.resultFound)
      return;

    try {
      final dir = await getTemporaryDirectory();
      _recordedFilePath =
          '${dir.path}/recorded_music_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(
        toFile: _recordedFilePath,
        codec: Codec.aacADTS,
        sampleRate: 44100,
        bitRate: 128000,
        numChannels: 1,
      );

      setState(() {
        _state = RecognitionState.listening;
        _resetResult();
      });

      _pulseController?.repeat(reverse: true);
      _waveController?.repeat();

      Future.delayed(const Duration(seconds: 15), () {
        if (_state == RecognitionState.listening && mounted) {
          _stopRecordingAndRecognize();
        }
      });
    } catch (e) {
      print('Lỗi bắt đầu ghi âm: $e');
      _showFeedbackSnackBar('Không thể bắt đầu ghi âm: ${e.toString()}');
      setState(() => _state = RecognitionState.idle);
    }
  }

  Future<void> _stopRecordingAndRecognize() async {
    if (_state != RecognitionState.listening) return;

    try {
      await _recorder.stopRecorder();
      setState(() => _state = RecognitionState.recognizing);

      _pulseController?.stop();
      _waveController?.stop();

      if (_recordedFilePath != null) {
        final result = await _acrController.recognizeSong(
          File(_recordedFilePath!),
        );

        if (result != null) {
          final songInfo = _parseRecognitionResult(result);
          setState(() {
            _recognizedSong =
                (songInfo['title'] ?? 'Không nhận diện được').trim();
            _artist = (songInfo['artist'] ?? '').trim();
            _album = (songInfo['album'] ?? '').trim();
            _confidence = songInfo['confidence'] ?? '';
            _score = songInfo['score'] ?? 0;
            _state = RecognitionState.resultFound;
          });

          if (_score < 50) {
            _showFeedbackSnackBar(
              'Độ tin cậy thấp. Hãy thử lại với âm thanh rõ hơn.',
            );
          }
        } else {
          _showFeedbackSnackBar('Không nhận diện được bài hát. Hãy thử lại.');
          setState(() => _state = RecognitionState.idle);
        }
      } else {
        _showFeedbackSnackBar('Lỗi: Không tìm thấy file ghi âm.');
        setState(() => _state = RecognitionState.idle);
      }
    } catch (e) {
      print('Lỗi dừng ghi âm: $e');
      _showFeedbackSnackBar('Lỗi khi dừng ghi âm: ${e.toString()}');
      setState(() => _state = RecognitionState.idle);
    }
  }

  Map<String, dynamic> _parseRecognitionResult(Map<String, dynamic> result) {
    String title = result['display'] ?? result['title'] ?? 'Không xác định';
    if (title.contains(' - ')) {
      title = title.split(' - ')[0].trim();
    }
    return {
      'title': title,
      'artist': '',
      'album': '',
      'confidence': '',
      'score':
          (result['score'] is int)
              ? result['score']
              : (int.tryParse(result['score']?.toString() ?? '0') ?? 0),
    };
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quyền bị từ chối'),
            content: const Text(
              'Bạn đã từ chối vĩnh viễn quyền truy cập microphone. Vui lòng vào Cài đặt ứng dụng để cấp quyền thủ công.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Mở Cài đặt'),
              ),
            ],
          ),
    );
  }

  void _showFeedbackSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(MyColor.red) : const Color(MyColor.pr5),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetSearch() => setState(() => _state = RecognitionState.idle);
  void _resetResult() => setState(() {
    _recognizedSong = "";
    _artist = "";
    _album = "";
    _confidence = "";
    _score = 0;
  });

  @override
  void dispose() {
    _pulseController?.dispose();
    _waveController?.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          _state != RecognitionState.listening &&
          _state != RecognitionState.recognizing,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_state == RecognitionState.listening) _stopRecordingAndRecognize();
      },
      child: Scaffold(
        backgroundColor: const Color(MyColor.pr2),
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
        if (_state == RecognitionState.resultFound)
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(MyColor.se4)),
            onPressed: _resetSearch,
            tooltip: 'Thử lại',
          ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildVisualizer(),
                    const SizedBox(height: 30),
                    _buildStatusText(),
                    const SizedBox(height: 12),
                    _buildInstructionText(),
                    const SizedBox(height: 20),
                    if (_state == RecognitionState.resultFound)
                      _buildResultCard(),
                  ],
                ),
              ),
              _buildBottomControls(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    bool isAnimating = _state == RecognitionState.listening;
    Color color =
        isAnimating ? const Color(MyColor.red) : const Color(MyColor.pr5);

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Transform.scale(
          scale: isAnimating ? _pulseAnimation!.value : 1.0,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color, width: 3),
            ),
            child: _buildVisualizerIcon(color),
          ),
        );
      },
    );
  }

  Widget _buildVisualizerIcon(Color color) {
    switch (_state) {
      case RecognitionState.recognizing:
        return const Center(
          child: CircularProgressIndicator(
            color: Color(MyColor.pr5),
            strokeWidth: 3,
          ),
        );
      case RecognitionState.listening:
        return Icon(Icons.mic, size: 70, color: color);
      default:
        return Icon(Icons.music_note, size: 70, color: color);
    }
  }

  Widget _buildStatusText() {
    String text;
    Color color = const Color(MyColor.se4);

    switch (_state) {
      case RecognitionState.listening:
        text = 'Đang nghe...';
        color = const Color(MyColor.red);
        break;
      case RecognitionState.recognizing:
        text = 'Đang nhận diện...';
        break;
      case RecognitionState.resultFound:
        text = 'Đã nhận diện!';
        color = const Color(MyColor.pr5);
        break;
      case RecognitionState.noPermission:
      case RecognitionState.requestingPermission:
      case RecognitionState.idle:
        text = 'Phát nhạc để nhận diện';
        break;
    }
    return Text(
      text,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInstructionText() {
    String text;
    switch (_state) {
      case RecognitionState.listening:
        text = 'Đang thu âm... (Tự động dừng sau 15s)';
        break;
      case RecognitionState.recognizing:
        text = 'Đang phân tích với ACRCloud...';
        break;
      case RecognitionState.resultFound:
        text = 'Nhấn "Tìm kiếm" để tìm bài hát này.';
        break;
      default:
        text =
            'Nhấn nút và phát nhạc với âm lượng vừa phải.\nTốt nhất là đoạn điệp khúc của bài hát.';
        break;
    }
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Color(MyColor.grey)),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildResultCard() {
    return Container(
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
        children: [
          const Text(
            'Bài hát được nhận diện:',
            style: TextStyle(fontSize: 12, color: Color(MyColor.grey)),
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
    );
  }

  Widget _buildBottomControls() {
    if (_state == RecognitionState.noPermission) {
      return _buildPermissionRequestUI();
    }
    if (_state == RecognitionState.resultFound) {
      return _buildResultActions();
    }
    return _buildRecordButton();
  }

  Widget _buildPermissionRequestUI() {
    bool isRequesting = _state == RecognitionState.requestingPermission;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(MyColor.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Color(MyColor.red)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Cần cấp quyền microphone để sử dụng chức năng này',
              style: TextStyle(color: Color(MyColor.red)),
            ),
          ),
          TextButton(
            onPressed: isRequesting ? null : _requestPermission,
            child:
                isRequesting
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Cấp quyền'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    VoidCallback? onTap;
    IconData icon;
    String text;
    Color color = Colors.grey;

    switch (_state) {
      case RecognitionState.idle:
        onTap = _startRecording;
        icon = Icons.mic;
        text = 'Nhấn để bắt đầu';
        color = const Color(MyColor.pr5);
        break;
      case RecognitionState.listening:
        onTap = _stopRecordingAndRecognize;
        icon = Icons.stop;
        text = 'Nhấn để dừng';
        color = const Color(MyColor.red);
        break;
      case RecognitionState.requestingPermission:
      case RecognitionState.recognizing:
        onTap = null;
        icon = Icons.hourglass_empty;
        text = 'Đang xử lý...';
        break;
      default:
        onTap = null;
        icon = Icons.mic_off;
        text = 'Không thể ghi âm';
    }

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(MyColor.grey)),
        ),
      ],
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, _recognizedSong.trim()),
            icon: const Icon(Icons.search, color: Colors.white),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Icon(Icons.refresh, color: Color(MyColor.se4), size: 24),
        ),
      ],
    );
  }
}
