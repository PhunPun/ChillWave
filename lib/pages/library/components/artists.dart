import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chillwave/models/artist_model.dart';
import 'package:chillwave/pages/library/components/artist_detail.dart';
import '../../../themes/colors/colors.dart';

class ArtistsTab extends StatefulWidget {
  @override
  _ArtistsTabState createState() => _ArtistsTabState();
}

class _ArtistsTabState extends State<ArtistsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: _buildFirebaseArtistGrid(),
      ),
    );
  }
  
  // Firebase StreamBuilder để lấy dữ liệu nghệ sĩ
  Widget _buildFirebaseArtistGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('artists').snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(
                color: Color(MyColor.pr4),
              ),
            ),
          );
        }
        
        // Error state
        if (snapshot.hasError) {
          return Container(
            height: 200,
            child: Center(
              child: Text(
                'Lỗi khi tải dữ liệu nghệ sĩ',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        
        // Empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            height: 200,
            child: Center(
              child: Text(
                'Chưa có nghệ sĩ nào',
                style: TextStyle(
                  color: Color(MyColor.grey),
                  fontSize: 16,
                ),
              ),
            ),
          );
        }
        
        // Success state - chỉ hiển thị ảnh nghệ sĩ
        List<ArtistModel> artists = snapshot.data!.docs.map((doc) {
          return ArtistModel.fromMap(
            doc.data() as Map<String, dynamic>, 
            doc.id
          );
        }).toList();
        
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0, // Hình vuông
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            return _buildArtistImageOnly(artists[index]);
          },
        );
      },
    );
  }
  
  // Widget chỉ hiển thị ảnh nghệ sĩ
  Widget _buildArtistImageOnly(ArtistModel artist) {
    return GestureDetector(
      onTap: () {
        print('Tapped on ${artist.artistName}');
        // Navigate to artist detail page
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => ArtistDetailPage(artist: artist)
          )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(MyColor.pr2),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: _buildArtistImage(artist.artistImages),
        ),
      ),
    );
  }
  
  Widget _buildArtistImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Color(MyColor.pr1),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
                color: Color(MyColor.pr4),
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }
  
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(MyColor.pr2),
            Color(MyColor.pr1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Color(MyColor.pr4).withOpacity(0.7),
          size: 40,
        ),
      ),
    );
  }
}