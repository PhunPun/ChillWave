import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/widgets/skeleton/top_bxh_skeleton.dart';
import 'package:chillwave/widgets/top_bxh_card.dart';
import 'package:flutter/material.dart';

class TopBxhList extends StatelessWidget {
  final int topNumber;
  final bool? full;
  const TopBxhList({
    super.key,
    required this.topNumber,
    this.full
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MusicController().getTopPlayedSongs(), 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TopBxhSkeleton();
        }
        if(!snapshot.hasData || snapshot.data == null){
          return const Center(child: Text('Không có bài hát nào'));
        }
        final songs = snapshot.data;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => (full ?? false) 
            ? TopBxhCard(song: songs![index], topIndex: index+1, full: full,) 
            : TopBxhCard(song: songs![index], topIndex: index+1), 
          separatorBuilder: (_,_) => const SizedBox(), 
          itemCount: songs!.length < topNumber ? songs.length : topNumber
        );
      }
    );
  }
}