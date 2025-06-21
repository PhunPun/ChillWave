import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/album_model.dart';

class AlbumController {
  static final _albumRef = FirebaseFirestore.instance.collection('albums');

  /// Lấy toàn bộ album
  Stream<List<AlbumModel>> getAllAlbums() {
    return _albumRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AlbumModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Lấy 1 album theo ID
  static Future<AlbumModel?> getAlbumById(String id) async {
    try {
      final doc = await _albumRef.doc(id).get();
      if (!doc.exists) return null;
      return AlbumModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Lỗi khi lấy album theo ID: $e');
      return null;
    }
  }
  Future<List<AlbumModel>> getAllAlbumsOnce() async {
    final snapshot = await FirebaseFirestore.instance.collection('albums').get();
    return snapshot.docs.map((doc) => AlbumModel.fromMap(doc.data(), doc.id)).toList();
  }
  static Future<int> countAlbumsByArtist(String artistId) async {
    try {
      final querySnapshot = await _albumRef
          .where('artist_id', isEqualTo: artistId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Lỗi khi đếm album của nghệ sĩ: $e');
      return 0;
    }
  }

}
