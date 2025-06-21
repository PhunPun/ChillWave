import 'package:chillwave/models/artist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ArtistController {
  static final CollectionReference _artistRef =
      FirebaseFirestore.instance.collection('artists');
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static Stream<List<ArtistModel>> getAllArtists() {
    return _artistRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ArtistModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
  static Stream<List<ArtistModel>> getFavoriteArtists() async* {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("Chưa đăng nhập");
    final userFavoritesRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .where('categories', isEqualTo: 'artists');
    final snapshot = await userFavoritesRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      yield [];
      return;
    }
    final artistIds = List<String>.from(snapshot.docs.first['artist_id']);
    yield* _artistRef.snapshots().map((snapshot) {
      return snapshot.docs
        .where((doc) => artistIds.contains(doc.id))
        .map((doc) => ArtistModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    });
  }

  static Future<void> saveFavoriteArtists(Set<String> artistIds) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null){
        throw Exception('Chưa đăng nhập');
      }

      final userId = currentUser.uid;
      final favoritesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites');
      final querySnapshot = await favoritesRef
          .where('categories', isEqualTo: 'artists')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('👀 Đang lưu ${artistIds.length} nghệ sĩ: $artistIds');

        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'artist_id': FieldValue.arrayUnion(artistIds.toList()),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        final newDocRef = favoritesRef.doc();
        await newDocRef.set({
          'artist_id': artistIds,
          'categories': 'artists',
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      // Tăng love_count cho từng artist
      for (final artistId in artistIds) {
        final artistDoc = _artistRef.doc(artistId);
        await artistDoc.update({
          'love_count': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }
  static Future<void> saveFavoriteSongs(Set<String> songIds) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }

      final userId = currentUser.uid;
      final favoritesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites');
      final querySnapshot = await favoritesRef
          .where('categories', isEqualTo: 'songs')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('👀 Đang lưu ${songIds.length} bài hát: $songIds');

        final doc = querySnapshot.docs.first;
        await doc.reference.update({
          'song_id': FieldValue.arrayUnion(songIds.toList()),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        final newDocRef = favoritesRef.doc();
        await newDocRef.set({
          'song_id': songIds,
          'categories': 'songs',
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      for (final songId in songIds) {
        final songDoc = _firestore.collection('songs').doc(songId);
        await songDoc.update({
          'love_count': FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }
  static void printAllArtists() {
    getAllArtists().listen((artistList) {
      for (var artist in artistList) {
        print('🎵 ID: ${artist.id}, Name: ${artist.artistName}');
      }
    });
  }
  static Stream<List<ArtistModel>> getArtistsByIds(List<String> ids) {
    return _artistRef.snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => ids.contains(doc.id))
          .map((doc) => ArtistModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
  static Stream<ArtistModel?> getArtistById(String id) {
    return _artistRef.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ArtistModel.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }
  static Future<void> saveSongToPlaylist({
    String? playlistId,
    required String songId,
    String? playlistName,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Chưa đăng nhập');
      }

      final userId = currentUser.uid;
      final playlistsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('playlists');

      if (playlistId == null || playlistId.isEmpty) {
        // Tạo mới playlist
        await playlistsRef.add({
          'song_ids': [songId],
          'name': playlistName ?? 'Playlist mới',
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        final playlistRef = playlistsRef.doc(playlistId);
        final playlistDoc = await playlistRef.get();
        if (playlistDoc.exists) {
          // Nếu chưa có trường name thì thêm vào
          if (!(playlistDoc.data()?.containsKey('name') ?? false)) {
            await playlistRef.update({
              'name': playlistName ?? 'Playlist mới',
            });
          }
          await playlistRef.update({
            'song_ids': FieldValue.arrayUnion([songId]),
            'updated_at': FieldValue.serverTimestamp(),
          });
        } else {
          await playlistRef.set({
            'song_ids': [songId],
            'name': playlistName ?? 'Playlist mới',
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }
  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getUserPlaylists() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Chưa đăng nhập');
    }
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('playlists')
        .get();
    return snapshot.docs;
  }
  static Future<String> getArtistNameById(String id) async {
    try {
      final doc = await _artistRef.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['artist_name']?.toString().trim() ?? 'Không rõ tên';
      } else {
        return 'Không tìm thấy nghệ sĩ';
      }
    } catch (e) {
      return 'Lỗi: $e';
    }
  }
  static Future<List<String>> getArtistNamesByIds(List<String> ids) async {
    try {
      final snapshots = await Future.wait(
        ids.map((id) => _artistRef.doc(id).get()),
      );

      return snapshots.map((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return data['artist_name']?.toString().trim() ?? 'Không rõ tên';
        }
        return 'Không tìm thấy nghệ sĩ';
      }).toList();
    } catch (e) {
      return ['Lỗi: $e'];
    }
  }
  static Future<bool> isFavorite(String artistId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .where('categories', isEqualTo: 'artists')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return false;

    final artistIds = List<String>.from(snapshot.docs.first['artist_id']);
    return artistIds.contains(artistId);
  }
  static Future<void> removeFavoriteArtist(String artistId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final favoritesRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites');

    final snapshot = await favoritesRef
        .where('categories', isEqualTo: 'artists')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      await doc.reference.update({
        'artist_id': FieldValue.arrayRemove([artistId]),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Giảm love_count cho artist đó
      final artistDoc = _artistRef.doc(artistId);
      await artistDoc.update({
        'love_count': FieldValue.increment(-1),
      });
    }
  }



}
