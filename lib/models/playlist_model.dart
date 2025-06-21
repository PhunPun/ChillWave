import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    this.updatedAt,
  });

  factory PlaylistModel.fromMap(String id, Map<String, dynamic> map) {
    return PlaylistModel(
      id: id,
      name: map['name'] ?? '',
      songIds: List<String>.from(map['song_ids'] ?? []),
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: map['updated_at'] != null
          ? (map['updated_at'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'song_ids': songIds,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
