import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/song_model.dart';

class MusicController {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  Stream<List<SongModel>> getAllSongs() {
    return FirebaseFirestore.instance
      .collection('songs')
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          final rawLink = data['audio_url'] ?? '';
          final convertedLink = convertDriveLink(rawLink);
          final updatedData = {
            ...data,
            'audio_url': convertedLink,
          };

          return SongModel.fromMap(doc.id, updatedData);
        }).toList();
      }
    );
  }

  Stream<List<SongModel>> getFavoriteArtistSongs() async* {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      yield [];
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .where('categories', isEqualTo: 'artists');

    await for (final favSnapshot in favRef.snapshots()) {
      final Set<String> favoriteArtistIds = {};

      for (var doc in favSnapshot.docs) {
        final data = doc.data();
        if (data['artist_id'] is List) {
          favoriteArtistIds.addAll(List<String>.from(data['artist_id']));
        }
      }

      if (favoriteArtistIds.isEmpty) {
        yield [];
        continue;
      }

      final List<SongModel> filteredSongs = [];

      // Chia theo nhóm ≤ 10 phần tử vì Firestore whereIn chỉ hỗ trợ tối đa 10 phần tử mỗi lần
      final List<List<String>> chunkedArtistIds = _chunkList(favoriteArtistIds.toList(), 10);

      for (var chunk in chunkedArtistIds) {
        final songQuery = await FirebaseFirestore.instance
            .collection('songs')
            .where('artist_id', arrayContainsAny: chunk)
            .get();

        for (var doc in songQuery.docs) {
          final data = doc.data();

          // Đảm bảo bài này thực sự có nghệ sĩ trong danh sách yêu thích
          final List<String> songArtistIds = List<String>.from(data['artist_id'] ?? []);
          final isMatch = songArtistIds.any(favoriteArtistIds.contains);
          if (isMatch) {
            final rawLink = data['audio_url'] ?? '';
            final updatedData = {
              ...data,
              'audio_url': convertDriveLink(rawLink),
            };

            filteredSongs.add(SongModel.fromMap(doc.id, updatedData));
          }
        }
      }
      yield filteredSongs;
    }
  }


  String convertDriveLink(String originalLink) {
    final regExp = RegExp(r'd\/(.*?)\/');
    final match = regExp.firstMatch(originalLink);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return originalLink;
  }
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
  Stream<List<SongModel>> getTopPlayedSongs() {
    return FirebaseFirestore.instance
      .collection('songs')
      .orderBy('play_count', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final rawLink = data['audio_url'] ?? '';
          final updatedData = {
            ...data,
            'audio_url': convertDriveLink(rawLink),
          };
          return SongModel.fromMap(doc.id, updatedData);
        }).toList();
      }
    );
  }
  Stream<List<SongModel>> getSongsByYear(String country) {
    final songsCollection = FirebaseFirestore.instance.collection('songs');
    Query query = songsCollection;

    if (country != 'all') {
      query = query.where('country', isEqualTo: country);
    }

    return query
        .orderBy('year', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // ✅ ép kiểu
            final rawLink = data['audio_url'] ?? '';
            final Map<String, dynamic> updatedData = {
              ...data,
              'audio_url': convertDriveLink(rawLink), // ✅ dùng đúng tên hàm
            };
            return SongModel.fromMap(doc.id, updatedData);
          }).toList();
        });
  }

  Stream<List<SongModel>> getSongsByArtistId(String artistId) {
    return FirebaseFirestore.instance
        .collection('songs')
        .where('artist_id', arrayContains: artistId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final Map<String, dynamic> data = doc.data();
            final rawLink = data['audio_url'] ?? '';
            final updatedData = {
              ...data,
              'audio_url': convertDriveLink(rawLink),
            };
            return SongModel.fromMap(doc.id, updatedData);
          }).toList();
        });
  }
  Future<bool> isFavoriteSong(String songId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .where('categories', isEqualTo: 'songs')
        .get();

    for (var doc in querySnapshot.docs) {
      final songIds = List<String>.from(doc.data()['song_id'] ?? []);
      if (songIds.contains(songId)) return true;
    }

    return false;
  }



  // Thêm hoặc gỡ yêu thích bài hát
  Future<void> toggleFavoriteSong(SongModel song) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final favCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');

    final querySnapshot = await favCollection
        .where('categories', isEqualTo: 'songs')
        .get();

    DocumentReference? targetDoc;
    List<String> currentList = [];

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      targetDoc = doc.reference;
      currentList = List<String>.from(doc['song_id'] ?? []);
    } else {
      targetDoc = favCollection.doc(); // tạo mới nếu chưa có
    }

    final alreadyFavorite = currentList.contains(song.id);

    if (alreadyFavorite) {
      currentList.remove(song.id);
      // Giảm love_count
      await FirebaseFirestore.instance.collection('songs').doc(song.id).update({
        'love_count': FieldValue.increment(-1),
      });
    } else {
      currentList.add(song.id);
      // Tăng love_count
      await FirebaseFirestore.instance.collection('songs').doc(song.id).update({
        'love_count': FieldValue.increment(1),
      });
    }

    await targetDoc.set({
      'song_id': currentList,
      'categories': 'songs',
      'updated_at': FieldValue.serverTimestamp(),
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> incrementPlayCount(String songId) async {
    await FirebaseFirestore.instance.collection('songs').doc(songId).update({
      'play_count': FieldValue.increment(1),
    });
  }
  Future<SongModel?> getSongById(String songId) async {
    final doc = await FirebaseFirestore.instance
        .collection('songs')
        .doc(songId)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    final rawLink = data['audio_url'] ?? '';
    final updatedData = {
      ...data,
      'audio_url': convertDriveLink(rawLink),
    };

    return SongModel.fromMap(doc.id, updatedData);
  }

}
