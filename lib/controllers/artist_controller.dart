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

}
