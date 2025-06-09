class ArtistModel {
  final String id;
  final String artistName;
  final String artistImages;
  final String bio;
  final List<String> albums;

  ArtistModel({
    required this.id,
    required this.artistName,
    required this.artistImages,
    required this.bio,
    required this.albums,
  });

  factory ArtistModel.fromMap(Map<String, dynamic> map, String id) {
    return ArtistModel(
      id: id,
      artistName: map['artist_name'] ?? '',
      artistImages: (map['artist_images'] == null || map['artist_images'].toString().trim().isEmpty)
        ? 'https://cdn-icons-png.freepik.com/512/3607/3607444.png'
        : map['artist_images'],
      bio: map['bio'] ?? '',
      albums: List<String>.from(map['albums'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artist_name': artistName,
      'artist_images': artistImages,
      'bio': bio,
      'albums': albums,
    };
  }
}