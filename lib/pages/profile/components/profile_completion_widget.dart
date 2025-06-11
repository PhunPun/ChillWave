import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';

class ProfileCompletionWidget extends StatelessWidget {
  final int profileCompletionCount;
  final Map<String, dynamic>? userData;
  final VoidCallback onUpdatePhoto;
  final VoidCallback onUpdateBio;
  final VoidCallback onUpdateInterests;

  const ProfileCompletionWidget({
    Key? key,
    required this.profileCompletionCount,
    required this.userData,
    required this.onUpdatePhoto,
    required this.onUpdateBio,
    required this.onUpdateInterests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive values based on screen size
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
    final titleFontSize = screenWidth < 360 ? 13.0 : screenWidth < 400 ? 14.0 : 15.0;
    final subtitleFontSize = screenWidth < 360 ? 11.0 : 12.0;
    final containerHeight = screenHeight < 600 
        ? 130.0  // Tăng chiều cao để chứa đủ nội dung
        : screenHeight < 700 
            ? 150.0 
            : 160.0;
    final verticalSpacing = screenWidth < 360 ? 8.0 : 10.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoàn thiện hồ sơ của bạn',
            style: TextStyle(
              fontSize: titleFontSize, 
              fontWeight: FontWeight.bold,
              color: Color(MyColor.se4), // Màu chữ đậm
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$profileCompletionCount of 3 COMPLETE',
            style: TextStyle(
              fontSize: subtitleFontSize, 
              color: Color(MyColor.pr5), // Màu phụ cho subtitle
            ),
          ),
          SizedBox(height: verticalSpacing),
          SizedBox(
            height: containerHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  _buildProfileCompletionItem(
                    context,
                    'Thêm ảnh của bạn',
                    Icons.camera_alt,
                    userData?['photoUrl'] != null,
                    onUpdatePhoto,
                  ),
                  SizedBox(width: screenWidth < 360 ? 8 : 12),
                  _buildProfileCompletionItem(
                    context,
                    'Thêm tiểu sử của bạn',
                    Icons.description,
                    userData?['bio'] != null && userData!['bio'].toString().isNotEmpty,
                    onUpdateBio,
                  ),
                  SizedBox(width: screenWidth < 360 ? 8 : 12),
                  _buildProfileCompletionItem(
                    context,
                    'Thêm sở thích',
                    Icons.favorite,
                    userData?['interests'] != null,
                    onUpdateInterests,
                  ),
                  // Extra space at the end for better scrolling experience
                  SizedBox(width: horizontalPadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionItem(
    BuildContext context,
    String title, 
    IconData icon, 
    bool isCompleted,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing - Tăng kích thước để hiển thị đầy đủ nội dung
    final itemSize = screenWidth < 320 
        ? 110.0  // Tăng từ 100 lên 110
        : screenWidth < 360 
            ? 120.0  // Tăng từ 110 lên 120
            : screenWidth < 400 
                ? 130.0  // Tăng từ 120 lên 130
                : 140.0; // Tăng từ 130 lên 140
    
    final itemWidth = itemSize;
    final itemHeight = itemSize;
    
    final iconSize = screenWidth < 320 
        ? 24.0  // Tăng icon size
        : screenWidth < 360 
            ? 28.0 
            : screenWidth < 400 
                ? 32.0 
                : 36.0;
    
    final titleFontSize = screenWidth < 320 
        ? 10.0 
        : screenWidth < 360 
            ? 11.0 
            : 12.0;
    
    final statusFontSize = screenWidth < 320 
        ? 9.0 
        : screenWidth < 360 
            ? 10.0 
            : 11.0;
    
    final padding = screenWidth < 360 ? 10.0 : 14.0; // Tăng padding
    final borderRadius = screenWidth < 360 ? 8.0 : 10.0;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(MyColor.pr4), // Hồng
              Color(MyColor.se2), // Xanh
              Color(MyColor.pr6), // Đỏ đậm
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
          margin: EdgeInsets.all(2), // Tạo viền gradient
          decoration: BoxDecoration(
            color: Color(MyColor.white),
            borderRadius: BorderRadius.circular(borderRadius - 2),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon section - Sử dụng Container thay vì Flexible
                Container(
                  height: iconSize + 4, // Đảm bảo có đủ không gian cho icon
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(MyColor.pr4), // Hồng
                        Color(MyColor.se2), // Xanh  
                        Color(MyColor.pr6), // Đỏ đậm
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Icon(
                      icon, 
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8), // Khoảng cách cố định
                
                // Title section - Sử dụng Expanded để tận dụng không gian còn lại
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize, 
                          fontWeight: FontWeight.w500,
                          color: Color(MyColor.se4),
                          height: 1.2, // Điều chỉnh line height
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      
                      // Status section
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(MyColor.pr4), // Hồng
                            Color(MyColor.se2), // Xanh
                            Color(MyColor.pr6), // Đỏ đậm
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          isCompleted ? 'Hoàn thành' : 'Thêm',
                          style: TextStyle(
                            fontSize: statusFontSize, 
                            color: Colors.white,
                            fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}