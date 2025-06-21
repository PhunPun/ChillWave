import 'package:chillwave/controllers/music_state_provider.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/pages/home/home_page.dart';
import 'package:chillwave/pages/library/page_library.dart';
import 'package:chillwave/pages/profile/user_profile_page.dart';
import 'package:chillwave/pages/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:chillwave/widgets/mini_player.dart';
import 'package:provider/provider.dart';

class HomeCenter extends StatefulWidget {
  const HomeCenter({super.key,});

  @override
  State<HomeCenter> createState() => _HomeCenterState();
}

class _HomeCenterState extends State<HomeCenter> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    HomePage(),
    ChillWaveScreen(),
    SearchPage(),
    UserProfilePage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void refreshMiniPlayer() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final song = context.watch<MusicStateProvider>().currentSong;
    final playlist = context.watch<MusicStateProvider>().currentPlaylist;
    if (song != null) {
      print("cjbdhvb MiniPlayer đang chơi: ${song.name}");
    }else{
      print('aaaaaaaaaaabnhbdc');
    }
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          if (song != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0, // Để MiniPlayer nằm trên BottomNavigationBar
              child: MiniPlayer(song: song, playlist: playlist),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false, // chỉ tránh phía dưới
        child: Stack(
          children: [
            // Nền gradient tràn toàn bộ
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // BottomNavigationBar phía trên nền
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _selectedIndex == 0
                      ? Image.asset('assets/images/active_home.png', width: 30, height: 30)
                      : Image.asset('assets/images/inactive_home.png', width: 30, height: 30),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 1
                      ? Image.asset('assets/images/active_library.png', width: 30, height: 30)
                      : Image.asset('assets/images/inactive_library.png', width: 30, height: 30),
                  label: 'Thư viện',
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 2
                      ? Image.asset('assets/images/active_search.png', width: 30, height: 30)
                      : Image.asset('assets/images/inactive_search.png', width: 30, height: 30),
                  label: 'Tìm kiếm',
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 3
                      ? Image.asset('assets/images/active_profile.png', width: 30, height: 30)
                      : Image.asset('assets/images/inactive_profile.png', width: 30, height: 30),
                  label: 'Cá nhân',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}