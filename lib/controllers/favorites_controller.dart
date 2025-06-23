import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/controllers/music_controller.dart';
import 'package:chillwave/pages/playmusicscreen/playmusic.dart';

class FavoritesController extends ChangeNotifier {
  final String userId;
  final BuildContext context;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingSongId;
  bool _isPlaying = false;

  FavoritesController({
    required this.userId,
    required this.context,
  });

  // Getters
  String? get currentPlayingSongId => _currentPlayingSongId;
  bool get isPlaying => _isPlaying;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Helper method để extract song ID từ dynamic data
  List<String> extractSongIds(dynamic songIdData) {
    if (songIdData == null) return [];
    
    if (songIdData is String) {
      return [songIdData];
    } else if (songIdData is List) {
      return songIdData.map((id) => id.toString()).toList();
    }
    
    return [];
  }

  // Phát nhạc
  Future<void> playMusic(String audioUrl, String songId) async {
    try {
      if (_currentPlayingSongId == songId && _isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        await _audioPlayer.play(UrlSource(audioUrl));
        _currentPlayingSongId = songId;
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error playing music: $e');
      _showSnackBar('Không thể phát nhạc: $e');
    }
  }

  // Navigate to MusicPlayerWithSwipeScreen
  void navigateToMusicPlayer(Map<String, dynamic> songData) {
    final musicController = MusicController();
    final convertedAudioUrl = musicController.convertDriveLink(songData['audioUrl'] ?? '');
    
    final songModel = SongModel(
      id: songData['songId'],
      name: songData['songName'],
      linkMp3: convertedAudioUrl,
      imageUrl: songData['songImageUrl'],
      artistIds: List<String>.from(songData['artistIds'] ?? []),
      playCount: songData['playCount'] ?? 0,
      loveCount: songData['loveCount'] ?? 0,
      year: songData['year'] ?? 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerWithSwipeScreen(
          song: songModel,
          playlist: null,
        ),
      ),
    );
  }

  // Xóa khỏi favorites
  Future<void> removeFromFavorites(String favoriteDocId, String songIdToRemove) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(favoriteDocId);
      
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final currentSongIds = extractSongIds(data['song_id']);
        
        // If only one song in this favorite document, delete the entire document
        if (currentSongIds.length <= 1) {
          await docRef.delete();
        } else {
          // Remove only the specific song from the list
          currentSongIds.remove(songIdToRemove);
          
          // Update the document with the remaining songs
          await docRef.update({
            'song_id': currentSongIds,
            'updated_at': FieldValue.serverTimestamp(),
          });
        }
      }
      
      _showSnackBar('Đã xóa bài hát khỏi danh sách yêu thích');
    } catch (e) {
      print('Error removing from favorites: $e');
      _showSnackBar('Lỗi khi xóa khỏi yêu thích: $e');
    }
  }

  // Method để lấy tất cả songs (xử lý trường hợp > 10 song IDs)
  Stream<List<QueryDocumentSnapshot>> getAllSongs(List<String> songIds) {
    const int batchSize = 10;
    
    if (songIds.length <= batchSize) {
      return FirebaseFirestore.instance
          .collection('songs')
          .where(FieldPath.documentId, whereIn: songIds)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }
    
    final List<Stream<QuerySnapshot>> streams = [];
    
    for (int i = 0; i < songIds.length; i += batchSize) {
      final batch = songIds.skip(i).take(batchSize).toList();
      streams.add(
        FirebaseFirestore.instance
            .collection('songs')
            .where(FieldPath.documentId, whereIn: batch)
            .snapshots()
      );
    }
    
    return _combineStreams(streams);
  }
  
  // Helper method để combine multiple streams using RxDart
  Stream<List<QueryDocumentSnapshot>> _combineStreams(List<Stream<QuerySnapshot>> streams) {
    return Rx.combineLatest(streams, (List<QuerySnapshot> snapshots) {
      final allDocs = <QueryDocumentSnapshot>[];
      for (final snapshot in snapshots) {
        allDocs.addAll(snapshot.docs);
      }
      return allDocs;
    });
  }

  // Lấy tên các artist
  Future<String> getArtistNames(List<dynamic> artistIds) async {
    if (artistIds.isEmpty) return 'Unknown Artist';
    
    try {
      final artistDocs = await FirebaseFirestore.instance
          .collection('artists')
          .where(FieldPath.documentId, whereIn: artistIds.cast<String>())
          .get();
      
      final artistNames = artistDocs.docs
          .map((doc) => (doc.data()['artist_name'] ?? 'Unknown') as String)
          .toList();
      
      return artistNames.join(', ');
    } catch (e) {
      print('Error getting artist names: $e');
      return 'Unknown Artist';
    }
  }

  // Format số để hiển thị đẹp hơn
  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Get favorites stream
  Stream<QuerySnapshot> getFavoritesStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .where('categories', isEqualTo: 'songs')
        .snapshots();
  }

  // Process combined data from favorites and songs
  List<Map<String, dynamic>> processCombinedData(
    List<QueryDocumentSnapshot> favoritesDocs,
    List<QueryDocumentSnapshot> songsDocs,
  ) {
    // Tạo Map để lookup song theo ID
    final songsMap = <String, Map<String, dynamic>>{};
    for (var songDoc in songsDocs) {
      songsMap[songDoc.id] = songDoc.data() as Map<String, dynamic>;
    }
    
    // Kết hợp dữ liệu favorites và songs
    final combinedData = <Map<String, dynamic>>[];
    
    for (var favoriteDoc in favoritesDocs) {
      final favoriteData = favoriteDoc.data() as Map<String, dynamic>;
      final songIds = extractSongIds(favoriteData['song_id']);
      
      for (var songId in songIds) {
        if (songsMap.containsKey(songId)) {
          final songData = songsMap[songId]!;
          
          combinedData.add({
            'favoriteDocId': favoriteDoc.id,
            'songId': songId,
            'songName': songData['song_name'] ?? 'Unknown Song',
            'artistIds': songData['artist_id'] ?? [],
            'audioUrl': songData['audio_url'] ?? '',
            'songImageUrl': songData['song_imageUrl'] ?? '',
            'playCount': songData['play_count'] ?? 0,
            'loveCount': songData['love_count'] ?? 0,
            'year': songData['year'] ?? 0,
            'country': songData['country'] ?? '',
            'createdAt': favoriteData['created_at'],
          });
        }
      }
    }
    
    return combinedData;
  }

  // Show snackbar helper
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Handle menu actions
  void handleMenuAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'play':
        navigateToMusicPlayer(item);
        break;
      case 'quick_play':
        if (item['audioUrl'].isNotEmpty) {
          playMusic(item['audioUrl'], item['songId']);
        }
        break;
      case 'remove':
        removeFromFavorites(item['favoriteDocId'], item['songId']);
        break;
      case 'details':
        // This will be handled in the UI
        break;
    }
  }
}