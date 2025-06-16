import 'package:chillwave/pages/home/home_page.dart';
import 'package:chillwave/pages/library/page_library.dart';
import 'package:chillwave/pages/profile/user_profile_page.dart';
import 'package:chillwave/pages/search/search_page.dart';
import 'package:flutter/material.dart';

class HomeCenter extends StatefulWidget {
  const HomeCenter({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
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