class AlbumModel {
  final String id;
  final String albumName;
  final String albumImageUrl;
  final String artistId;
  final List<String> songIds;

  AlbumModel({
    required this.id,
    required this.albumName,
    required this.albumImageUrl,
    required this.artistId,
    required this.songIds,
  });

  factory AlbumModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AlbumModel(
      id: documentId,
      albumName: map['album_name'] ?? '',
      albumImageUrl: map['album_imageUrl'] ?? 'https://i.pinimg.com/736x/19/55/48/195548510f8764f0c5245cd14d2adb16.jpg',
      artistId: map['artist_id'] ?? '',
      songIds: List<String>.from(map['songs_id'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'album_name': albumName,
      'album_imageUrl': albumImageUrl,
      'artist_id': artistId,
      'songs_id': songIds,
    };
  }
}
