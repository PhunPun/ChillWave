class PlaylistModel {
  final String id;
  final String name;
  final List<String> songIds;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map, String docId) {
    return PlaylistModel(
      id: docId,
      name: map['name'] ?? 'Playlist mới',
      songIds: List<String>.from(map['song_ids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'song_ids': songIds,
    };
  }
}