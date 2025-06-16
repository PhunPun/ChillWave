import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/widgets/skeleton/top_bxh_skeleton.dart';
import 'package:chillwave/widgets/top_bxh_card.dart';
import 'package:flutter/material.dart';

class TopBxhList extends StatefulWidget {
  final int topNumber;
  final bool? full;
  const TopBxhList({
    super.key,
    required this.topNumber,
    this.full
  });

  @override
  State<TopBxhList> createState() => _TopBxhListState();
}

class _TopBxhListState extends State<TopBxhList> {
  late final Stream<List<SongModel>> topSongsStream;

  @override
  void initState() {
    super.initState();
    topSongsStream = MusicController().getTopPlayedSongs();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: topSongsStream, 
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
          itemBuilder: (context, index) => (widget.full ?? false) 
            ? TopBxhCard(song: songs[index], topIndex: index+1, full: widget.full,) 
            : TopBxhCard(song: songs[index], topIndex: index+1), 
          separatorBuilder: (_,_) => const SizedBox(), 
          itemCount: songs!.length < widget.topNumber ? songs.length : widget.topNumber
        );
      }
    );
  }
}