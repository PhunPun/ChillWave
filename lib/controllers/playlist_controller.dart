import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chillwave/models/playlist_model.dart';

class PlaylistController {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<List<PlaylistModel>> getUserPlaylists() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('playlists')
        .get();

    return snapshot.docs.map((doc) {
      return PlaylistModel.fromMap(doc.id, doc.data());
    }).toList();
  }
}
