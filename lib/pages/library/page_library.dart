import 'package:chillwave/pages/library/components/albums.dart';
import 'package:chillwave/pages/library/components/arttists.dart';
import 'package:chillwave/pages/library/components/playlists.dart';
import 'package:flutter/material.dart';
import '../../themes/colors/colors.dart';

class ChillWaveScreen extends StatefulWidget {
  @override
  _ChillWaveScreenState createState() => _ChillWaveScreenState();
}

class _ChillWaveScreenState extends State<ChillWaveScreen> {
  int _selectedTab = 0;
  int _selectedBottomTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(MyColor.white),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Top row with icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.search, color: Color(MyColor.se2), size: 35),
                      Icon(Icons.menu, color: Color(MyColor.se2), size: 35),
                    ],
                  ),
                  SizedBox(height: 8),
                  // ChillWave title moved down with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(MyColor.pr4),
                        Color(MyColor.se2),
                        Color(MyColor.pr6),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'ChillWave',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    
                    // Thư viện
                    Text(
                      'Thư viện',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(MyColor.se4),
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Tabs
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(MyColor.pr3),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color(MyColor.pr4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildTab('Playlists', 0)),
                          Expanded(child: _buildTab('Albums', 1)),
                          Expanded(child: _buildTab('Artists', 2)),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Content based on selected tab
                    Expanded(
                      child: _buildTabContent(),
                    ),
                    
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected ? Color(MyColor.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Color(MyColor.black).withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ] : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Color(MyColor.pr6) : Color(MyColor.pr5),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // Playlists
        return PlaylistsTab();
      case 1: // Albums
        return AlbumsTab();
      case 2: // Artists
        return ArtistsTab();
      default:
        return Container();
    }
  }
  
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedBottomTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBottomTab = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(MyColor.pr6) : Color(MyColor.grey),
            size: 26,
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(MyColor.pr6) : Color(MyColor.grey),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Main App
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChillWave Library',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'SF Pro Display',
      ),
      home: ChillWaveScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}