import 'package:chillwave/pages/top_bxh_list100/Top_bxh_list100.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:chillwave/widgets/collection_list.dart';
import 'package:chillwave/widgets/new_song_list.dart';
import 'package:chillwave/widgets/song_list.dart';
import 'package:chillwave/widgets/top_bxh_list.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCountry = 'Tất cả';
  final ValueNotifier<String> countryNotifier = ValueNotifier<String>('all');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Tuyển tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.pr6)
                ),
              ),
            ),
            CollectionList(),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Gợi ý cho bạn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.pr6)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                height: 220,
                child: SongList(),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //height: 295,
              decoration: BoxDecoration(
                color: Color(MyColor.pr2),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top BXH',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(MyColor.se3)
                    ),
                  ),
                  TopBxhList(topNumber: 5,),
                  Container(
                    height: 1,
                    color: Color(MyColor.pr6),
                  ),
                  const SizedBox(height: 5,),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) =>TopBxhList100())
                      );
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Xem tất cả >>',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(MyColor.se5),
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                'Mới phát hành',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(MyColor.pr6)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  selectCountry('Tất cả'),
                  const SizedBox(width: 8,),
                  selectCountry('Việt Nam'),
                  const SizedBox(width: 8,),
                  selectCountry('Quốc tế'),
                ],
              ),
            ),
            ValueListenableBuilder<String>(
              valueListenable: countryNotifier,
              builder: (context, country, _) {
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SizedBox(
                    height: 220,
                    child: NewSongList(country: country),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget selectCountry(String title) {
    final bool isSelected = selectedCountry == title;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCountry = title;
        });
        if (title == 'Việt Nam') {
          countryNotifier.value = 'Viet Nam';
        } else if (title == 'Quốc tế') {
          countryNotifier.value = 'international';
        } else {
          countryNotifier.value = 'all';
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 0,
        backgroundColor: isSelected ? Color(MyColor.pr2) : Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isSelected
              ? BorderSide.none
              : BorderSide(
                  color: Color(MyColor.se3),
                  width: 1.5,
                ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Color(MyColor.pr6),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}