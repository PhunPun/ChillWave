import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model.dart';

class MusicController {
  Future<SongModel?> getSong(String docId) async {
    final doc = await FirebaseFirestore.instance.collection('songs').doc('GcA5kafc4VrxXPxl80Cj').get();

    if (doc.exists) {
      final rawLink = doc['linkMp3'];
      final convertedLink = _convertDriveLink(rawLink);

      return SongModel(
        name: doc['name'],
        linkMp3: convertedLink,
      );
    }
    return null;
  }

  String _convertDriveLink(String originalLink) {
    final regExp = RegExp(r'd\/(.*?)\/');
    final match = regExp.firstMatch(originalLink);

    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return originalLink;
  }
}
