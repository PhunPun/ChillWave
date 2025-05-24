import 'package:flutter/material.dart';

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
        ? 110.0 
        : screenHeight < 700 
            ? 130.0 
            : 140.0;
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
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$profileCompletionCount of 3 COMPLETE',
            style: TextStyle(
              fontSize: subtitleFontSize, 
              color: Colors.grey[700]
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
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing - Hình vuông và to hơn
    final itemSize = screenWidth < 320 
        ? 100.0 
        : screenWidth < 360 
            ? 110.0 
            : screenWidth < 400 
                ? 120.0 
                : 130.0;
    
    final itemWidth = itemSize;
    final itemHeight = itemSize;
    
    final iconSize = screenWidth < 320 
        ? 22.0 
        : screenWidth < 360 
            ? 26.0 
            : screenWidth < 400 
                ? 30.0 
                : 32.0;
    
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
    
    final padding = screenWidth < 360 ? 8.0 : 12.0;
    final spacing = screenWidth < 360 ? 6.0 : 8.0;
    final borderRadius = screenWidth < 360 ? 6.0 : 8.0;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: itemWidth,
        height: itemHeight,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.grey[300]!,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isCompleted ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Icon(
                icon, 
                size: iconSize,
                color: isCompleted ? Colors.green : Colors.grey[600],
              ),
            ),
            SizedBox(height: spacing),
            Flexible(
              flex: 2,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize, 
                  fontWeight: FontWeight.w500
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: spacing * 0.5),
            Flexible(
              child: Text(
                isCompleted ? 'Hoàn thành' : 'Thêm',
                style: TextStyle(
                  fontSize: statusFontSize, 
                  color: isCompleted ? Colors.green : Colors.blue,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}