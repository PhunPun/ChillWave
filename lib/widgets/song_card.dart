import 'package:chillwave/controllers/artist_controller.dart';
import 'package:chillwave/controllers/playlist_controller.dart';
import 'package:chillwave/models/artist_model.dart';
import 'package:chillwave/models/song_model.dart';
import 'package:chillwave/pages/playmusicscreen/playmusic.dart';
import 'package:chillwave/themes/colors/colors.dart';
import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  final SongModel song;

  const SongCard({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final artistId = song.artistIds;
    return InkWell(
      onTap: (){
        print('aaaaaaaaaaaaaaaaaaaa ${song.linkMp3}');
        print('== ON TAP ĐÃ ĐƯỢC GỌI ==');
        print('== song: ${song.name}');
        print('== linkMp3: ${song.linkMp3}');
        Navigator.push(context, 
          MaterialPageRoute(
            builder: (context) => MusicPlayerWithSwipeScreen(song: song,),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 290,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                song.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://i.pinimg.com/736x/19/55/48/195548510f8764f0c5245cd14d2adb16.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(MyColor.se5),
                    ),
                  ),
                  StreamBuilder<List<ArtistModel>>(
                    stream: ArtistController.getArtistsByIds(artistId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("Đang tải...");
                      final artists = snapshot.data!;
                      return Text(
                        artists.map((a) => a.artistName).join(", "),
                      );
                    },
                  )
                ],
              ),
            ),
            PopupMenuButton<String>(
              padding: const EdgeInsets.all(0),
              icon: const Icon(Icons.more_vert),
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Color(MyColor.pr5), width: 1.0),
              ),
              onSelected: (value) async {
                if (value == 'favorite') {
                  try {
                    await ArtistController.saveFavoriteSongs({song.id});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm vào yêu thích!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Có lỗi xảy ra: $e'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else if (value == 'playlist') {
                  _showPlaylistDialog(context, song.id);
                } else if (value == 'like_artist') {
                  try {
                    await ArtistController.saveFavoriteArtists({...song.artistIds});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm vào yêu thích!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Có lỗi xảy ra: $e'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'favorite',
                  height: 38, // Giảm chiều cao
                  padding: const EdgeInsets.symmetric(horizontal: 2,),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(MyColor.se2), // Màu nền riêng
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: const Text(
                      '❤️ Yêu thích',
                      style: TextStyle(color: Color(MyColor.pr1)),
                    ),
                  ),
                ), 
                PopupMenuItem<String>(
                  value: 'playlist',
                  height: 38, // Giảm chiều cao
                  padding: const EdgeInsets.symmetric(horizontal: 2,),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(MyColor.se3), // Màu nền riêng
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: const Text(
                      '➕ Thêm vào danh sách',
                      style: TextStyle(color: Color(MyColor.pr1)),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'like_artist',
                  height: 38, // Giảm chiều cao
                  padding: const EdgeInsets.symmetric(horizontal: 2,),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(MyColor.se4), // Màu nền riêng
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: const Text(
                      '🎤 Thích nghệ sĩ',
                      style: TextStyle(color: Color(MyColor.pr1)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showPlaylistDialog(BuildContext context, String songId) async {
    final playlists = await PlaylistController.getUserPlaylists();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(MyColor.pr1),
          title: const Text(
            'Chọn playlist', 
            style: TextStyle(
              color: Color(MyColor.se2), 
              fontWeight: FontWeight.bold
            ),),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (playlists.isNotEmpty)
                    ...playlists.map((playlist) => ListTile(
                          tileColor: Color(MyColor.pr2), // Thêm màu nền cho ListTile
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(
                              color: Color(MyColor.pr6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () async {
                            await ArtistController.saveSongToPlaylist(
                              playlistId: playlist.id,
                              songId: songId,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã thêm vào playlist!')),
                            );
                          },
                        )),
                  const SizedBox(height: 8),
                  Text(
                    'Hoặc',
                    style: TextStyle(
                      color: Color(MyColor.se5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên playlist mới',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final newPlaylistName = nameController.text.trim();
                      if (newPlaylistName.isNotEmpty) {
                        await ArtistController.saveSongToPlaylist(
                          playlistId: null,
                          songId: songId,
                          playlistName: newPlaylistName,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã tạo playlist và thêm bài hát!')),
                        );
                      }
                    },
                    child: const Text(
                      'Tạo mới & Thêm',
                      style: TextStyle(color: Color(MyColor.pr5))
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
