import 'package:flutter/material.dart';
import '../../themes/colors/colors.dart';

class MusicRecognitionSkeleton extends StatefulWidget {
  final bool isRecording;
  final bool isRecognizing;

  const MusicRecognitionSkeleton({
    Key? key,
    this.isRecording = false,
    this.isRecognizing = false,
  }) : super(key: key);

  @override
  State<MusicRecognitionSkeleton> createState() =>
      _MusicRecognitionSkeletonState();
}

class _MusicRecognitionSkeletonState extends State<MusicRecognitionSkeleton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }

    _shimmerController.repeat();
  }

  @override
  void didUpdateWidget(MusicRecognitionSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _shimmerAnimation]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing circle for recording/recognizing
              Transform.scale(
                scale: widget.isRecording ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        widget.isRecording
                            ? const Color(MyColor.red).withOpacity(0.3)
                            : widget.isRecognizing
                            ? const Color(MyColor.pr5).withOpacity(0.3)
                            : const Color(MyColor.pr5).withOpacity(0.1),
                    border: Border.all(
                      color:
                          widget.isRecording
                              ? const Color(MyColor.red)
                              : const Color(MyColor.pr5),
                      width: 3,
                    ),
                  ),
                  child:
                      widget.isRecognizing
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(MyColor.pr5),
                              strokeWidth: 3,
                            ),
                          )
                          : Icon(
                            widget.isRecording ? Icons.mic : Icons.music_note,
                            size: 70,
                            color:
                                widget.isRecording
                                    ? const Color(MyColor.red)
                                    : const Color(MyColor.pr5),
                          ),
                ),
              ),

              const SizedBox(height: 30),

              // Status shimmer text
              _buildShimmerText(
                widget.isRecording
                    ? 'Đang nghe nhạc...'
                    : widget.isRecognizing
                    ? 'Đang nhận diện...'
                    : 'Phát nhạc để nhận diện',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),

              const SizedBox(height: 12),

              // Description shimmer text
              _buildShimmerText(
                widget.isRecording
                    ? 'Đang thu âm...'
                    : widget.isRecognizing
                    ? 'Đang phân tích...'
                    : 'Nhấn nút để bắt đầu',
                fontSize: 14,
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // Result skeleton
              if (widget.isRecognizing) _buildResultSkeleton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerText(
    String text, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    int maxLines = 1,
  }) {
    return Container(
      width: double.infinity,
      height: fontSize * 1.5 * maxLines,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * _shimmerAnimation.value, 0.0),
          end: Alignment(1.0 + 2.0 * _shimmerAnimation.value, 0.0),
          colors: [
            const Color(MyColor.se1).withOpacity(0.1),
            const Color(MyColor.se1).withOpacity(0.3),
            const Color(MyColor.se1).withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildResultSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                end: Alignment(1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                colors: [
                  const Color(MyColor.se1).withOpacity(0.1),
                  const Color(MyColor.se1).withOpacity(0.3),
                  const Color(MyColor.se1).withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                end: Alignment(1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                colors: [
                  const Color(MyColor.se1).withOpacity(0.1),
                  const Color(MyColor.se1).withOpacity(0.3),
                  const Color(MyColor.se1).withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                end: Alignment(1.0 + 2.0 * _shimmerAnimation.value, 0.0),
                colors: [
                  const Color(MyColor.se1).withOpacity(0.1),
                  const Color(MyColor.se1).withOpacity(0.3),
                  const Color(MyColor.se1).withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
