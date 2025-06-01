import 'package:chillwave/pages/library/components/lisentedmusic.dart';
import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24), // Cho thêm padding dưới
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Playlist items
          _buildPlaylistItem('Chill Mix', 'Tự tạo', Color(MyColor.pr4)),
          SizedBox(height: 12),
          _buildPlaylistItem('Study Beats', 'Tự tạo', Color(MyColor.pr3)),
          SizedBox(height: 12),
          _buildPlaylistItem('Night Vibes', 'Tự tạo', Color(MyColor.se2)),
          SizedBox(height: 24), // Thay Spacer bằng SizedBox để tránh lỗi layout

          // Nhạc đã nghe section
          ListenedMusicSection(),
        ],
      ),
    );
  }

  Widget _buildPlaylistItem(String title, String subtitle, Color color) {
    return Container(
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
          color: Color(MyColor.white),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(MyColor.pr4),
                    Color(MyColor.se2),
                    Color(MyColor.pr6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(MyColor.pr4),
                  Color(MyColor.se2),
                  Color(MyColor.pr6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
