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
      imageUrl: map['song_imageUrl'] == ''
          ? 'https://i.pinimg.com/736x/19/55/48/195548510f8764f0c5245cd14d2adb16.jpg'
          : map['song_imageUrl'],
      loveCount: map['love_count'] ?? 0,
      playCount: map['play_count'] ?? 0,
      year: map['year'] ?? 0,
    );
  }

  /// ✅ Hàm `copyWith` để tạo một bản sao với thuộc tính thay đổi
  SongModel copyWith({
    String? id,
    List<String>? artistIds,
    String? name,
    String? linkMp3,
    String? imageUrl,
    int? loveCount,
    int? playCount,
    int? year,
  }) {
    return SongModel(
      id: id ?? this.id,
      artistIds: artistIds ?? this.artistIds,
      name: name ?? this.name,
      linkMp3: linkMp3 ?? this.linkMp3,
      imageUrl: imageUrl ?? this.imageUrl,
      loveCount: loveCount ?? this.loveCount,
      playCount: playCount ?? this.playCount,
      year: year ?? this.year,
    );
  }
}
