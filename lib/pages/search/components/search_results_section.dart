import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../themes/colors/colors.dart';
import '../../../controllers/search_controller.dart' as mysearch;
import '../../../widgets/search_components.dart';
import '../../../models/song_model.dart';
import '../../../controllers/music_controller.dart';
import '../../playmusicscreen/playmusic.dart';

class SearchResultsSection extends StatelessWidget {
  final mysearch.SearchController controller;

  const SearchResultsSection({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchResultsHeader(controller: controller),
        Expanded(child: _buildFilteredResults(context)),
      ],
    );
  }

  Widget _buildFilteredResults(BuildContext context) {
    bool hasResults = false;

    switch (controller.currentFilter) {
      case mysearch.SearchFilter.all:
        hasResults =
            controller.searchResults.isNotEmpty ||
            controller.artistResults.isNotEmpty ||
            controller.albumResults.isNotEmpty;
        break;
      case mysearch.SearchFilter.songs:
        hasResults = controller.searchResults.isNotEmpty;
        break;
      case mysearch.SearchFilter.artists:
        hasResults = controller.artistResults.isNotEmpty;
        break;
      case mysearch.SearchFilter.albums:
        hasResults = controller.albumResults.isNotEmpty;
        break;
    }

    if (!hasResults) {
      return SearchEmptyState(
        query: controller.currentQuery,
        filter: controller.currentFilter.name,
        errorMessage: controller.errorMessage,
        hasError: controller.hasError,
        onRetry: controller.retrySearch,
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if ((controller.currentFilter == mysearch.SearchFilter.all ||
                controller.currentFilter == mysearch.SearchFilter.artists) &&
            controller.artistResults.isNotEmpty) ...[
          _buildSectionHeader('Nghệ sĩ', controller.artistResults.length),
          const SizedBox(height: 8),
          ...controller.artistResults.asMap().entries.map((entry) {
            final index = entry.key;
            final artist = entry.value;
            return AnimatedSearchCard(
              index: index,
              child: SearchResultCard(
                item: artist,
                type: 'artist',
                onTap: () => _viewArtist(artist),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],

        if ((controller.currentFilter == mysearch.SearchFilter.all ||
                controller.currentFilter == mysearch.SearchFilter.songs) &&
            controller.searchResults.isNotEmpty) ...[
          _buildSectionHeader('Bài hát', controller.searchResults.length),
          const SizedBox(height: 8),
          ...controller.searchResults.asMap().entries.map((entry) {
            final index = entry.key;
            final song = entry.value;
            return AnimatedSearchCard(
              index: index,
              child: SearchResultCard(
                item: song,
                type: 'song',
                onTap: () => _playSong(context, song),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],

        if ((controller.currentFilter == mysearch.SearchFilter.all ||
                controller.currentFilter == mysearch.SearchFilter.albums) &&
            controller.albumResults.isNotEmpty) ...[
          _buildSectionHeader('Album', controller.albumResults.length),
          const SizedBox(height: 8),
          ...controller.albumResults.asMap().entries.map((entry) {
            final index = entry.key;
            final album = entry.value;
            return AnimatedSearchCard(
              index: index,
              child: SearchResultCard(
                item: album,
                type: 'album',
                onTap: () => _viewAlbum(album),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(MyColor.se4),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(MyColor.pr5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _playSong(BuildContext context, Map<String, dynamic> song) {
    try {
      final musicController = MusicController();
      final rawAudioUrl = song['audio_url'] ?? '';
      final convertedAudioUrl = musicController.convertDriveLink(rawAudioUrl);

      final songModel = SongModel(
        id: song['id'] ?? '',
        name: song['song_name'] ?? '',
        imageUrl: song['song_imageUrl'] ?? '',
        linkMp3: convertedAudioUrl,
        artistIds: List<String>.from(song['artist_id'] ?? []),
        loveCount: song['love_count'] ?? 0,
        playCount: song['play_count'] ?? 0,
        year: song['year'] ?? 2024,
      );

      print('Đang phát: ${songModel.name}');
      _addToPlayHistory(songModel.id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MusicPlayerWithSwipeScreen(song: songModel),
        ),
      );
    } catch (e) {
      print('Lỗi khi phát nhạc: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể phát bài hát: $e'),
          backgroundColor: const Color(MyColor.red),
        ),
      );
    }
  }

  void _viewArtist(Map<String, dynamic> artist) {
    print('Xem nghệ sĩ: ${artist['artist_name']}');
  }

  void _viewAlbum(Map<String, dynamic> album) {
    print('Xem album: ${album['album_name']}');
  }

  Future<void> _addToPlayHistory(String songId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('play_history')
            .add({
              'song_id': songId,
              'played_at': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Lỗi khi thêm vào lịch sử: $e');
    }
  }
}
