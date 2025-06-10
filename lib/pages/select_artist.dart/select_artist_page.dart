import 'package:chillwave/apps/router/router_name.dart';
import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/pages/select_artist.dart/widget/artist_circle_pick.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SelectArtistPage extends StatefulWidget {
  const SelectArtistPage({super.key});

  @override
  State<SelectArtistPage> createState() => _SelectArtistPageState();
}

class _SelectArtistPageState extends State<SelectArtistPage> {
  Set<String> selectedArtistIds = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
              width: double.infinity,
              color: Color(MyColor.pr1),
            ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 40,),
                  Text(
                    "Chọn 3 nghệ sĩ bạn thích trở lên.",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(MyColor.pr6),
                    ),
                  ),
                  const SizedBox(height: 40,),
                  ArtistCirclePick(
                    selectedArtistIds: selectedArtistIds,
                    onSelectionChanged: (updatedSet) {
                      setState(() {
                        selectedArtistIds = updatedSet;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
          if(selectedArtistIds.length >= 3)
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    context.goNamed(RouterName.home);
                    await ArtistController.saveFavoriteArtists(selectedArtistIds);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(MyColor.pr5),
                    minimumSize: Size(158, 58)
                  ),
                  child: Text(
                    'Xong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(MyColor.pr1)
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}