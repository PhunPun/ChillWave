import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart'; // Thay đổi đường dẫn phù hợp với project của bạn

class ListenedMusicSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với màu chính
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Nhạc đã nghe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(MyColor.se4),
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 20),
        
        // Horizontal scrollable music list
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: 16),
                child: _buildMusicCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMusicCard(int index) {


    List<IconData> musicIcons = [
      Icons.music_note,
      Icons.audiotrack,
      Icons.album,
      Icons.queue_music,
      Icons.library_music,
      Icons.music_video,
      Icons.radio,
      Icons.headset,
    ];

    return GestureDetector(
      onTap: () {
        print('Tapped on music ${index + 1}');
      },
      child: Container(
        width: 90,
        height: 120,
        child: Column(
          children: [
            // Music card với gradient sử dụng MyColor
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Color(MyColor.pr4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(MyColor.pr1),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Hiệu ứng ánh sáng
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(MyColor.white).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Icon chính
                  Center(
                    child: Icon(
                      musicIcons[index % musicIcons.length],
                      color: Color(MyColor.white),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            
            // Tên bài hát với màu từ MyColor
            Container(
              width: 75,
              child: Text(
                'Song ${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(MyColor.se4),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}