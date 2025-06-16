import 'package:flutter/material.dart';
import '../../themes/colors/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  bool _showHistory = false;
  List<String> _history = ['Giờ thi', '3107-2', 'Bức tranh màu nước mắt'];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() {
        _showHistory = _searchFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading:
            _showHistory
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(MyColor.se4)),
                  onPressed: () {
                    _searchFocus.unfocus();
                    setState(() {
                      _showHistory = false;
                    });
                  },
                )
                : Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(MyColor.se1),
                    child: Icon(
                      Icons.person,
                      color: Color(MyColor.grey),
                      size: 24,
                    ),
                  ),
                ),
        title: const Text(
          'Tìm kiếm',
          style: TextStyle(
            color: Color(MyColor.se4),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(MyColor.pr2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (_showHistory) const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocus,
                          controller: _searchController,
                          style: const TextStyle(fontSize: 15),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            isDense: true,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Bạn muốn nghe gì?',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color(MyColor.se4),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      if (_showHistory) ...[
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/icons/music.png',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.mic,
                          color: Color(MyColor.se4),
                          size: 24,
                        ),
                      ] else ...[
                        const Icon(
                          Icons.mic,
                          color: Color(MyColor.se4),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!_showHistory) ...[
                  const Text(
                    'Trending',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(MyColor.se4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(MyColor.pr2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      height: 180,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double spacing = 16;
                          final double cardWidth =
                              (constraints.maxWidth - spacing) / 2;
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            children: [
                              _TrendingCard(
                                image: 'assets/images/tinhyeu.png',
                                size: cardWidth,
                              ),
                              const SizedBox(width: 16),
                              _TrendingCard(
                                image: 'assets/images/chimsau.png',
                                size: cardWidth,
                              ),
                              const SizedBox(width: 16),
                              _TrendingCard(
                                image: 'assets/images/tinhyeu.png',
                                size: cardWidth,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (_showHistory) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lịch sử tìm kiếm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(MyColor.se4),
                        ),
                      ),
                      if (_history.isNotEmpty)
                        TextButton(
                          onPressed: _clearHistory,
                          child: const Text(
                            'Xóa tất cả',
                            style: TextStyle(color: Color(MyColor.se4)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Text(
                      'Không có lịch sử tìm kiếm',
                      style: TextStyle(color: Color(MyColor.grey)),
                    ),
                  ..._history.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Color(MyColor.se4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Gần đây',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(MyColor.se4),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _RecentCard(
                        image: 'assets/images/tinhyeu.png',
                        title: 'Mehabooba',
                        subtitle: 'Kgf Chapter 2  •  Ananya Bhat',
                        current: '2:50',
                        total: '3:50',
                      ),
                      const SizedBox(height: 12),
                      _RecentCard(
                        image: 'assets/images/chimsau.png',
                        title: 'Mehabooba',
                        subtitle: 'Kgf Chapter 2  •  Ananya Bhat',
                        current: '2:50',
                        total: '3:50',
                      ),
                      const SizedBox(height: 12),
                      _RecentCard(
                        image: 'assets/images/tinhyeu.png',
                        title: 'Mehabooba',
                        subtitle: 'Kgf Chapter 2  •  Ananya Bhat',
                        current: '2:50',
                        total: '3:50',
                      ),
                      const SizedBox(height: 12),
                      _RecentCard(
                        image: 'assets/images/chimsau.png',
                        title: 'Mehabooba',
                        subtitle: 'Kgf Chapter 2  •  Ananya Bhat',
                        current: '2:50',
                        total: '3:50',
                      ),
                      const SizedBox(height: 12),
                      _RecentCard(
                        image: 'assets/images/tinhyeu.png',
                        title: 'Mehabooba',
                        subtitle: 'Kgf Chapter 2  •  Ananya Bhat',
                        current: '2:50',
                        total: '3:50',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final String image;
  final double size;
  const _TrendingCard({required this.image, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(MyColor.pr2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(image, fit: BoxFit.cover, width: size, height: size),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String current;
  final String total;
  const _RecentCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(MyColor.pr2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(MyColor.se4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(MyColor.grey),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      current,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(MyColor.pr5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(MyColor.grey),
                      ),
                    ),
                    Text(
                      total,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(MyColor.se4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Container(
              decoration: const BoxDecoration(
                color: Color(MyColor.pr5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
