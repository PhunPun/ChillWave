import 'package:flutter/material.dart';
import '../models/song_model.dart';

class MusicStateProvider extends ChangeNotifier {
  SongModel? _currentSong;
  List<SongModel>? _currentPlaylist;

  SongModel? get currentSong => _currentSong;
  List<SongModel>? get currentPlaylist => _currentPlaylist;

  void setCurrentSong(SongModel song) {
    _currentSong = song;
    notifyListeners(); // 👈 thông báo UI cập nhật
  }

  void setCurrentPlaylist(List<SongModel>? playlist) {
    _currentPlaylist = playlist;
    notifyListeners(); // 👈 thông báo UI cập nhật
  }

  void clear() {
    _currentSong = null;
    _currentPlaylist = null;
    notifyListeners(); // 👈 thông báo UI cập nhật
  }
}
