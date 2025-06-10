class SongModel {
  final String id;
  final List<String> artistIds;
  final String name;
  final String linkMp3;
  final String imageUrl;
  final int loveCount;
  final int playCount;
  final int year;

  SongModel({
    required this.id,
    required this.artistIds,
    required this.name,
    required this.linkMp3,
    required this.imageUrl,
    required this.loveCount,
    required this.playCount,
    required this.year,
  });

  factory SongModel.fromMap(String id, Map<String, dynamic> map) {
    return SongModel(
      id: id,
      artistIds: List<String>.from(map['artist_id'] ?? []),
      name: map['song_name'] ?? '',
      linkMp3: map['audio_url'] ?? '',
      imageUrl: map['song_imageUrl'] == '' ? 'https://i.pinimg.com/736x/19/55/48/195548510f8764f0c5245cd14d2adb16.jpg' : map['song_imageUrl'],
      loveCount: map['love_count'] ?? 0,
      playCount: map['play_count'] ?? 0,
      year: map['year'] ?? 0,
    );
  }
}
