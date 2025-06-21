import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../themes/colors/colors.dart';

class SearchMicroPage extends StatefulWidget {
  const SearchMicroPage({Key? key}) : super(key: key);

  @override
  State<SearchMicroPage> createState() => _SearchMicroPageState();
}

class _SearchMicroPageState extends State<SearchMicroPage>
    with TickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    initSpeech();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'vi_VN',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {
      _isListening = true;
      _confidenceLevel = 0;
    });

    _pulseController.repeat(reverse: true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();

    // Nếu có kết quả, trả về trang search với query
    if (_wordsSpoken.isNotEmpty) {
      Navigator.pop(context, _wordsSpoken);
    }
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isListening,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // Handle back button when listening
        if (_isListening) {
          _showCancelListeningDialog();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(MyColor.pr2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(MyColor.se4)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Tìm kiếm bằng giọng nói',
            style: TextStyle(
              color: Color(MyColor.se4),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Voice Animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isListening ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _isListening
                                      ? const Color(
                                        MyColor.red,
                                      ).withOpacity(0.3)
                                      : const Color(
                                        MyColor.pr5,
                                      ).withOpacity(0.1),
                              border: Border.all(
                                color:
                                    _isListening
                                        ? const Color(MyColor.red)
                                        : const Color(MyColor.pr5),
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.mic,
                              size: 80,
                              color:
                                  _isListening
                                      ? const Color(MyColor.red)
                                      : const Color(MyColor.pr5),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Status Text
                    Text(
                      _isListening
                          ? 'Đang nghe...'
                          : _speechEnabled
                          ? 'Nhấn micro để bắt đầu'
                          : 'Tính năng không khả dụng',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            _isListening
                                ? const Color(MyColor.red)
                                : const Color(MyColor.se4),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Recognized Text
                    if (_wordsSpoken.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _wordsSpoken,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(MyColor.se4),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_confidenceLevel > 0) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Độ tin cậy: ${(_confidenceLevel * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Controls
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Record Button
                  GestureDetector(
                    onTap:
                        _speechEnabled
                            ? (_isListening ? _stopListening : _startListening)
                            : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _isListening
                                ? const Color(MyColor.red)
                                : const Color(MyColor.pr5),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? const Color(MyColor.red)
                                    : const Color(MyColor.pr5))
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _isListening ? 'Nhấn để dừng' : 'Nhấn để ghi âm',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(MyColor.grey),
                    ),
                  ),

                  if (_wordsSpoken.isNotEmpty && !_isListening) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, _wordsSpoken);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(MyColor.pr5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Tìm kiếm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelListeningDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy ghi âm?'),
          content: const Text(
            'Bạn có muốn hủy quá trình ghi âm giọng nói không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _stopListening();
                Navigator.pop(context); // Go back to search page
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}
