import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/models/artist_model.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArtistCirclePick extends StatefulWidget {
  final Set<String> selectedArtistIds;
  final void Function(Set<String>) onSelectionChanged;
  const ArtistCirclePick({
    super.key,
    required this.selectedArtistIds,
    required this.onSelectionChanged,
  });

  @override
  State<ArtistCirclePick> createState() => _ArtistCirclePickState();
}

class _ArtistCirclePickState extends State<ArtistCirclePick> {
  final artists = ArtistController.getAllArtists();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: artists,
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // TODO:
        }

        if (snapshot.data!.isEmpty || snapshot.hasError) {
          return Center(child: Text('Chưa có nghệ sĩ nào để chọn'));
        }
        final artistList = snapshot.data;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: artistList!.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 🧱 3 cột mỗi hàng
            mainAxisSpacing: 0,
            crossAxisSpacing: 20,
            childAspectRatio: 0.65, // Tỉ lệ ngang/dọc, chỉnh cho vừa hình + tên
          ),
          itemBuilder: (context, index) {
            final artist = artistList[index];
            final isSelected = widget.selectedArtistIds.contains(artist.id);

            return circlePick(
              artist,
              isSelected,
              () {
                setState(() {
                  final updatedSet = Set<String>.from(widget.selectedArtistIds);
                  if (isSelected) {
                    updatedSet.remove(artist.id);
                  } else {
                    updatedSet.add(artist.id);
                  }
                  widget.onSelectionChanged(updatedSet);
                });
              },
            );
          },
        );
      }
    );
  }
  Widget circlePick(ArtistModel artist, bool isSelected, VoidCallback ontap){
    return GestureDetector(
      onTap: ontap,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(MyColor.pr6)
                  ),
                  image: DecorationImage(image: NetworkImage(artist.artistImages), fit: BoxFit.cover)
                ),
              ),
              Text(
                textAlign: TextAlign.center,
                artist.artistName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.pr6)
                ),
              ),
            ],
          ),
          if (isSelected)
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/icons/check_circle.svg',
                width: 24,
                height: 24,
              ),
            ),
        ],
      ),
    );
  }
}