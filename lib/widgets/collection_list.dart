import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/widgets/collection_card.dart';
import 'package:chillwave/widgets/skeleton/collection_skeleton.dart';
import 'package:flutter/material.dart';

class CollectionList extends StatelessWidget {
  const CollectionList({super.key});

  @override
  Widget build(BuildContext context) {
     final favoriteArtist = ArtistController.getFavoriteArtists();
    return StreamBuilder(
      stream: favoriteArtist, 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CollectionSkeleton();
        }

        if (snapshot.data!.isEmpty || snapshot.hasError) {
          return Center(child: Text('Chưa có dữ liệu'));
        }
        final favoriteArtistList = snapshot.data;
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favoriteArtistList!.length,
            itemBuilder:(context, index) =>  CollectionCard(favoriteArtist: favoriteArtistList[index],)
          ),
        );
      }
    );
  }
}