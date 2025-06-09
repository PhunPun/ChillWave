import 'package:chillwave/models/artist_model.dart';
import 'package:chillwave/pages/collection/collection_page.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final ArtistModel favoriteArtist;
  const CollectionCard({
    super.key,
    required this.favoriteArtist
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => CollectionPage(artistId: favoriteArtist.id)
          )
        );
      },
      child: Container(
        width: 127,
        height: 147,
        margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(favoriteArtist.artistImages),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 10,
                height: 10,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Tuyển tập của\n${favoriteArtist.artistName}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.white),
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1), // Dịch bóng theo trục X, Y
                      blurRadius: 3.0,          // Độ mờ
                      color: Color(MyColor.grey),    // Màu bóng
                    ),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}