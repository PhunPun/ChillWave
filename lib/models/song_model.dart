class SongModel {
  final String name;
  final String linkMp3;

  SongModel({required this.name, required this.linkMp3});

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      name: map['name'],
      linkMp3: map['linkMp3'],
    );
  }
}
