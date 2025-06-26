import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:diacritic/diacritic.dart';

enum SearchFilter { all, songs, artists, albums }

enum SortOption { relevance, name, playCount, recent }

class SearchController extends ChangeNotifier {
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  List<String> history = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> artistResults = [];
  List<Map<String, dynamic>> albumResults = [];
  List<Map<String, dynamic>> trendingSongs = [];
  List<Map<String, dynamic>> recentSongs = [];
  List<String> searchSuggestions = [];

  bool showHistory = false;
  bool isLoading = false;
  bool isTrendingLoading = false;
  bool showSuggestions = false;
  SearchFilter currentFilter = SearchFilter.all;
  SortOption currentSort = SortOption.relevance;
  String currentQuery = '';
  String? userId;
  Timer? _debounce;
  Timer? _suggestionTimer;

  // Cache cho performance
  final Map<String, List<Map<String, dynamic>>> _searchCache = {};
  final Map<String, List<String>> _suggestionCache = {};

  List<Map<String, dynamic>> _allArtistsCache = [];
  bool _isAllArtistsLoaded = false;

  List<Map<String, dynamic>> _allSongsCache = [];
  bool _isAllSongsLoaded = false;

  List<Map<String, dynamic>> _allAlbumsCache = [];
  bool _isAllAlbumsLoaded = false;

  SearchController() {
    _init();
  }

  // Error handling state
  String? errorMessage;
  bool hasError = false;

  void _init() async {
    searchFocus.addListener(() {
      if (searchFocus.hasFocus) {
        showHistory = true;
        if (searchController.text.isNotEmpty) {
          showSuggestions = true;
        }
      } else {
        showHistory = false;
        showSuggestions = false;
      }
      notifyListeners();
    });

    // Fetch initial data
    print('Initializing search controller...');
    await Future.wait([
      fetchTrendingSongs(),
      fetchRecentSongs(),
      _setUserIdAndFetchHistory(),
    ]);
    print(
      'Search controller initialized with ${trendingSongs.length} trending and ${recentSongs.length} recent songs',
    );
  }

  Future<void> _setUserIdAndFetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      await fetchHistory();
    }
  }

  void onSearchChanged(String value) {
    currentQuery = value;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (_suggestionTimer?.isActive ?? false) _suggestionTimer!.cancel();

    if (value.isEmpty) {
      clearSearch(fromUser: false);
      return;
    }

    // Show suggestions faster
    _suggestionTimer = Timer(const Duration(milliseconds: 150), () {
      _fetchSuggestions(value);
    });

    // Search với debounce
    _debounce = Timer(const Duration(milliseconds: 50), () {
      // Clear cache for new search to avoid duplicates
      _searchCache.clear();
      searchAll(value);
    });
  }

  void onSearchSubmitted(String value) async {
    if (value.isEmpty) return;
    showSuggestions = false;
    await addToHistory(value);
    await searchAll(value);
  }

  void selectSuggestion(String suggestion) {
    searchController.text = suggestion;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    showSuggestions = false;

    // Hạ bàn phím xuống khi chọn gợi ý
    searchFocus.unfocus();

    // Delay nhỏ để đảm bảo UI cập nhật mượt mà
    Future.delayed(const Duration(milliseconds: 100), () {
      onSearchSubmitted(suggestion);
    });
  }

  void selectHistoryItem(String query) {
    searchController.text = query;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    showHistory = false;

    // Hạ bàn phím xuống khi chọn lịch sử
    searchFocus.unfocus();

    // Delay nhỏ để đảm bảo UI cập nhật mượt mà
    Future.delayed(const Duration(milliseconds: 100), () {
      onSearchSubmitted(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 2) return;

    // Check cache
    if (_suggestionCache.containsKey(query)) {
      searchSuggestions = _suggestionCache[query]!;
      showSuggestions = true;
      notifyListeners();
      return;
    }

    try {
      final suggestions = <String>{};
      final searchKeyword = _formatSearchKeyword(query);

      // Get song suggestions
      final songQuery =
          await FirebaseFirestore.instance
              .collection('songs')
              .where('song_name', isGreaterThanOrEqualTo: searchKeyword)
              .where('song_name', isLessThanOrEqualTo: searchKeyword + '\uf8ff')
              .limit(6)
              .get();

      suggestions.addAll(
        songQuery.docs
            .map((doc) => doc['song_name'] as String? ?? '')
            .where((name) => name.isNotEmpty),
      );

      // Get artist suggestions
      final artistQuery =
          await FirebaseFirestore.instance
              .collection('artists')
              .where('artist_name', isGreaterThanOrEqualTo: searchKeyword)
              .where(
                'artist_name',
                isLessThanOrEqualTo: searchKeyword + '\uf8ff',
              )
              .limit(4)
              .get();

      suggestions.addAll(
        artistQuery.docs
            .map((doc) => doc['artist_name'] as String? ?? '')
            .where((name) => name.isNotEmpty),
      );

      searchSuggestions = suggestions.take(8).toList();
      _suggestionCache[query] = searchSuggestions;
      showSuggestions = true;
      notifyListeners();
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  // Hàm chuẩn hóa: capitalize từng từ
  String _capitalizeEachWord(String input) {
    return input
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // Lấy toàn bộ nghệ sĩ từ Firestore (cache lại)
  Future<void> _loadAllArtists() async {
    if (_isAllArtistsLoaded && _allArtistsCache.isNotEmpty) return;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('artists').get();
      _allArtistsCache =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
      _isAllArtistsLoaded = true;
    } catch (e) {
      print('Error loading all artists: $e');
      _allArtistsCache = [];
      _isAllArtistsLoaded = false;
    }
  }

  // Lọc nghệ sĩ client-side
  List<Map<String, dynamic>> _filterArtistsClient(String keyword) {
    String normalize(String s) =>
        removeDiacritics(s).toLowerCase().replaceAll(' ', '');
    final normKeyword = normalize(keyword);

    // 1. Khớp chính xác
    final exact = _allArtistsCache.where((artist) {
      final name = artist['artist_name'] ?? '';
      return normalize(name) == normKeyword;
    });

    // 2. Bắt đầu bằng keyword (nhưng không phải exact)
    final startsWith = _allArtistsCache.where((artist) {
      final name = artist['artist_name'] ?? '';
      final normName = normalize(name);
      return normName.startsWith(normKeyword) && normName != normKeyword;
    });

    // 3. Chỉ chứa keyword (nhưng không phải exact hay startsWith)
    final contains = _allArtistsCache.where((artist) {
      final name = artist['artist_name'] ?? '';
      final normName = normalize(name);
      return normName.contains(normKeyword) &&
          !normName.startsWith(normKeyword) &&
          normName != normKeyword;
    });

    // Gộp lại, ưu tiên exact > startsWith > contains
    return [...exact, ...startsWith, ...contains].toList();
  }

  // Lấy toàn bộ bài hát từ Firestore (cache lại)
  Future<void> _loadAllSongs() async {
    if (_isAllSongsLoaded && _allSongsCache.isNotEmpty) return;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('songs').get();
      _allSongsCache =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
      _isAllSongsLoaded = true;
    } catch (e) {
      print('Error loading all songs: $e');
      _allSongsCache = [];
      _isAllSongsLoaded = false;
    }
  }

  // Lọc bài hát client-side
  List<Map<String, dynamic>> _filterSongsClient(String keyword) {
    String normalize(String s) =>
        removeDiacritics(s).toLowerCase().replaceAll(' ', '');
    final normKeyword = normalize(keyword);

    // 1. Khớp chính xác
    final exact = _allSongsCache.where((song) {
      final name = song['song_name'] ?? '';
      return normalize(name) == normKeyword;
    });

    // 2. Bắt đầu bằng keyword (nhưng không phải exact)
    final startsWith = _allSongsCache.where((song) {
      final name = song['song_name'] ?? '';
      final normName = normalize(name);
      return normName.startsWith(normKeyword) && normName != normKeyword;
    });

    // 3. Chỉ chứa keyword (nhưng không phải exact hay startsWith)
    final contains = _allSongsCache.where((song) {
      final name = song['song_name'] ?? '';
      final normName = normalize(name);
      return normName.contains(normKeyword) &&
          !normName.startsWith(normKeyword) &&
          normName != normKeyword;
    });

    // Gộp lại, ưu tiên exact > startsWith > contains
    return [...exact, ...startsWith, ...contains].toList();
  }

  // Lấy toàn bộ album từ Firestore (cache lại)
  Future<void> _loadAllAlbums() async {
    if (_isAllAlbumsLoaded && _allAlbumsCache.isNotEmpty) return;
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('albums').get();
      _allAlbumsCache =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
      _isAllAlbumsLoaded = true;
    } catch (e) {
      print('Error loading all albums: $e');
      _allAlbumsCache = [];
      _isAllAlbumsLoaded = false;
    }
  }

  // Sửa _searchArtists để tìm nghệ sĩ qua bài hát nếu không tìm thấy theo tên
  Future<void> _searchArtists(String keyword) async {
    await _loadAllArtists();
    await _loadAllSongs();
    // Ưu tiên tìm kiếm client-side
    artistResults = _filterArtistsClient(keyword);
    print('Client-side artist search found: \\${artistResults.length}');
    // Nếu không tìm thấy, thử thêm các biến thể keyword
    if (artistResults.isEmpty) {
      // Capitalize từng từ
      final capKeyword = _capitalizeEachWord(keyword);
      if (capKeyword != keyword) {
        artistResults = _filterArtistsClient(capKeyword);
      }
    }
    if (artistResults.isEmpty) {
      // Loại bỏ khoảng trắng
      final noSpaceKeyword = keyword.replaceAll(' ', '');
      if (noSpaceKeyword != keyword) {
        artistResults = _filterArtistsClient(noSpaceKeyword);
      }
    }
    // Nếu vẫn không có, tìm nghệ sĩ qua bài hát
    if (artistResults.isEmpty) {
      final matchedSongs = _filterSongsClient(keyword);
      final Set<String> artistIds = {};
      for (var song in matchedSongs) {
        if (song['artist_id'] is List) {
          artistIds.addAll(List<String>.from(song['artist_id']));
        } else if (song['artist_id'] is String) {
          artistIds.add(song['artist_id']);
        }
      }
      artistResults =
          _allArtistsCache
              .where((artist) => artistIds.contains(artist['id']))
              .toList();
      print('Artist search via song found: \\${artistResults.length}');
    }
    // Nếu vẫn không có, fallback về Firestore query cũ (ít khi cần)
    if (artistResults.isEmpty) {
      await _searchArtistsFirestore(keyword);
    }
  }

  // Hàm Firestore query cũ, đổi tên lại
  Future<void> _searchArtistsFirestore(String keyword) async {
    final searchKeyword = _formatSearchKeyword(keyword);
    try {
      final Set<String> addedArtistIds = <String>{};
      artistResults = <Map<String, dynamic>>[];
      final directQuery =
          await FirebaseFirestore.instance
              .collection('artists')
              .where('artist_name', isGreaterThanOrEqualTo: searchKeyword)
              .where(
                'artist_name',
                isLessThanOrEqualTo: searchKeyword + '\\uf8ff',
              )
              .limit(10)
              .get();
      for (var doc in directQuery.docs) {
        final artistId = doc.id;
        if (!addedArtistIds.contains(artistId)) {
          final data = doc.data();
          data['id'] = artistId;
          artistResults.add(data);
          addedArtistIds.add(artistId);
        }
      }
      // ... giữ nguyên phần còn lại nếu cần ...
    } catch (e) {
      print('Error searching artists (firestore fallback): $e');
      artistResults = [];
    }
  }

  // Sửa _searchAlbums để tìm album qua bài hát nếu không tìm thấy theo tên
  Future<void> _searchAlbums(String keyword) async {
    await _loadAllAlbums();
    await _loadAllSongs();
    // Ưu tiên tìm kiếm client-side
    albumResults = _filterAlbumsClient(keyword);
    print('Client-side album search found: \\${albumResults.length}');
    // Nếu không tìm thấy, thử thêm các biến thể keyword
    if (albumResults.isEmpty) {
      // Capitalize từng từ
      final capKeyword = _capitalizeEachWord(keyword);
      if (capKeyword != keyword) {
        albumResults = _filterAlbumsClient(capKeyword);
      }
    }
    if (albumResults.isEmpty) {
      // Loại bỏ khoảng trắng
      final noSpaceKeyword = keyword.replaceAll(' ', '');
      if (noSpaceKeyword != keyword) {
        albumResults = _filterAlbumsClient(noSpaceKeyword);
      }
    }
    // Nếu vẫn không có, tìm album qua bài hát
    if (albumResults.isEmpty) {
      final matchedSongs = _filterSongsClient(keyword);
      final Set<String> songIds =
          matchedSongs.map((s) => s['id'] as String).toSet();
      // Duyệt album, kiểm tra songs_id có chứa id bài hát không
      albumResults =
          _allAlbumsCache.where((album) {
            final songsId = album['songs_id'];
            if (songsId is List) {
              return songsId.any((id) => songIds.contains(id));
            }
            return false;
          }).toList();
      print('Album search via song found: \\${albumResults.length}');
    }
    // Nếu vẫn không có, fallback về Firestore query cũ (ít khi cần)
    if (albumResults.isEmpty) {
      await _searchAlbumsFirestore(keyword);
    }
  }

  // Lọc album client-side
  List<Map<String, dynamic>> _filterAlbumsClient(String keyword) {
    String normalize(String s) =>
        removeDiacritics(s).toLowerCase().replaceAll(' ', '');
    final normKeyword = normalize(keyword);
    // 1. Khớp chính xác
    final exact = _allAlbumsCache.where((album) {
      final name = album['album_name'] ?? '';
      return normalize(name) == normKeyword;
    });
    // 2. Bắt đầu bằng keyword (nhưng không phải exact)
    final startsWith = _allAlbumsCache.where((album) {
      final name = album['album_name'] ?? '';
      final normName = normalize(name);
      return normName.startsWith(normKeyword) && normName != normKeyword;
    });
    // 3. Chỉ chứa keyword (nhưng không phải exact hay startsWith)
    final contains = _allAlbumsCache.where((album) {
      final name = album['album_name'] ?? '';
      final normName = normalize(name);
      return normName.contains(normKeyword) &&
          !normName.startsWith(normKeyword) &&
          normName != normKeyword;
    });
    return [...exact, ...startsWith, ...contains].toList();
  }

  // Hàm tìm kiếm với 1 keyword (logic cũ của searchAll)
  Future<void> _searchAllWithKeyword(String keyword) async {
    // Gán keyword cho currentQuery để đảm bảo nó được giữ lại
    currentQuery = keyword;
    isLoading = true;
    notifyListeners();

    // Check cache
    final cacheKey = '$keyword-${currentFilter.name}-${currentSort.name}';
    if (_searchCache.containsKey(cacheKey)) {
      _applyCachedResults(cacheKey);
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Clear previous errors
      hasError = false;
      errorMessage = null;

      await Future.wait([
        if (currentFilter == SearchFilter.all ||
            currentFilter == SearchFilter.songs)
          _searchSongs(keyword),
        if (currentFilter == SearchFilter.all ||
            currentFilter == SearchFilter.artists)
          _searchArtists(keyword),
        if (currentFilter == SearchFilter.all ||
            currentFilter == SearchFilter.albums)
          _searchAlbums(keyword),
      ]);

      // Load artist names for songs after all searches are done
      if ((currentFilter == SearchFilter.all ||
              currentFilter == SearchFilter.songs) &&
          searchResults.isNotEmpty) {
        await _loadArtistNamesForSongs();
      }

      // Final deduplication for all results
      _deduplicateResults();

      _sortResults();
      _cacheResults(cacheKey);
    } catch (e) {
      print('Error searching: $e');
      hasError = true;
      errorMessage = _getErrorMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Sửa searchAll để thử nhiều dạng keyword
  Future<void> searchAll(String keyword) async {
    if (keyword.isEmpty) {
      clearSearch();
      return;
    }

    // Reset kết quả trước khi thử
    searchResults = [];
    artistResults = [];
    albumResults = [];
    hasError = false;
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    // Lần 1: Giữ nguyên keyword
    await _searchAllWithKeyword(keyword);
    if (hasResults) return;

    // Lần 2: Capitalize từng từ
    final capKeyword = _capitalizeEachWord(keyword);
    if (capKeyword != keyword) {
      await _searchAllWithKeyword(capKeyword);
      if (hasResults) return;
    }

    // Lần 3: Loại bỏ khoảng trắng
    final noSpaceKeyword = keyword.replaceAll(' ', '');
    if (noSpaceKeyword != keyword) {
      await _searchAllWithKeyword(noSpaceKeyword);
      if (hasResults) return;
    }

    // Nếu vẫn không có kết quả, giữ nguyên trạng thái (hasResults = false)
    notifyListeners();
  }

  Future<void> _searchAlbumsByArtistName(
    String keyword,
    Set<String> addedAlbumIds,
  ) async {
    try {
      final searchKeyword = _formatSearchKeyword(keyword);

      // First find artists matching the keyword
      final artistQuery =
          await FirebaseFirestore.instance
              .collection('artists')
              .where('artist_name', isGreaterThanOrEqualTo: searchKeyword)
              .where(
                'artist_name',
                isLessThanOrEqualTo: searchKeyword + '\uf8ff',
              )
              .limit(5)
              .get();

      final artistIds = artistQuery.docs.map((doc) => doc.id).toList();

      if (artistIds.isNotEmpty) {
        // Then find albums by these artists
        for (String artistId in artistIds) {
          final albumQuery =
              await FirebaseFirestore.instance
                  .collection('albums')
                  .where('artist_id', arrayContains: artistId)
                  .limit(8)
                  .get();

          // Add to album results if not already present
          for (var doc in albumQuery.docs) {
            if (!addedAlbumIds.contains(doc.id)) {
              final data = doc.data();
              data['id'] = doc.id;
              albumResults.add(data);
              addedAlbumIds.add(doc.id);
            }
          }
        }
      }
    } catch (e) {
      print('Error searching albums by artist name: $e');
    }
  }

  Future<void> _loadArtistNamesForSongs() async {
    await _loadArtistNamesForList(searchResults);
  }

  Future<void> _loadArtistNamesForList(
    List<Map<String, dynamic>> songList,
  ) async {
    try {
      print('Loading artist names for \\${songList.length} songs');

      for (int i = 0; i < songList.length; i++) {
        final song = songList[i];
        final artistIds = song['artist_id'];

        print('Song \\${i}: \\${song['song_name']}, artist_id: \\${artistIds}');

        List<String> ids = [];
        if (artistIds != null) {
          if (artistIds is List) {
            ids = artistIds.map((e) => e.toString().trim()).toList();
          } else if (artistIds is String) {
            ids = [artistIds.trim()];
          }
        }
        if (ids.isNotEmpty) {
          final artistId = ids.first;
          final artistDoc =
              await FirebaseFirestore.instance
                  .collection('artists')
                  .doc(artistId)
                  .get();
          if (artistDoc.exists) {
            final artistData = artistDoc.data();
            final artistName =
                artistData?['artist_name']?.toString().trim() ?? '';
            songList[i]['artist_name'] = artistName;
            print(
              'Found artist: \\${artistName} for song: \\${song['song_name']}',
            );
          } else {
            songList[i]['artist_name'] = '';
            print('Artist document not found for ID: \\${artistId}');
          }
        } else {
          songList[i]['artist_name'] = '';
          print('No artist_id found for song: \\${song['song_name']}');
        }
      }

      print('Finished loading artist names');
    } catch (e) {
      print('Error loading artist names: \\${e}');
    }
  }

  Future<void> _loadArtistNamesForAlbums() async {
    try {
      for (int i = 0; i < albumResults.length; i++) {
        final album = albumResults[i];
        final artistIds = album['artist_id'];
        String? artistId;
        if (artistIds != null) {
          if (artistIds is List && artistIds.isNotEmpty) {
            artistId = artistIds.first.toString().trim();
          } else if (artistIds is String) {
            artistId = artistIds.trim();
          }
        }
        if (artistId != null && artistId.isNotEmpty) {
          print('Album ${album['album_name']} - artistId: $artistId');
          final artistDoc =
              await FirebaseFirestore.instance
                  .collection('artists')
                  .doc(artistId)
                  .get();
          if (artistDoc.exists) {
            final artistData = artistDoc.data();
            albumResults[i]['artist_name'] =
                artistData?['artist_name']?.toString().trim() ?? '';
            print(
              'Found artist for album: ${album['album_name']} - ${albumResults[i]['artist_name']}',
            );
          } else {
            albumResults[i]['artist_name'] = '';
            print(
              'Artist document not found for album: ${album['album_name']} - id: $artistId',
            );
          }
        } else {
          albumResults[i]['artist_name'] = '';
          print('No valid artist_id for album: ${album['album_name']}');
        }
      }
    } catch (e) {
      print('Error loading artist names for albums: $e');
    }
  }

  String _formatSearchKeyword(String keyword) {
    return keyword
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  void _deduplicateResults() {
    // Deduplicate songs
    if (searchResults.isNotEmpty) {
      final uniqueSongs = <String, Map<String, dynamic>>{};
      for (final song in searchResults) {
        final id = song['id'] as String? ?? '';
        if (id.isNotEmpty) {
          uniqueSongs[id] = song;
        }
      }
      searchResults = uniqueSongs.values.toList();
      print('Deduplicated songs: ${searchResults.length}');
    }

    // Deduplicate artists
    if (artistResults.isNotEmpty) {
      final uniqueArtists = <String, Map<String, dynamic>>{};
      for (final artist in artistResults) {
        final id = artist['id'] as String? ?? '';
        if (id.isNotEmpty) {
          uniqueArtists[id] = artist;
        }
      }
      artistResults = uniqueArtists.values.toList();
      print('Deduplicated artists: ${artistResults.length}');
    }

    // Deduplicate albums
    if (albumResults.isNotEmpty) {
      final uniqueAlbums = <String, Map<String, dynamic>>{};
      for (final album in albumResults) {
        final id = album['id'] as String? ?? '';
        if (id.isNotEmpty) {
          uniqueAlbums[id] = album;
        }
      }
      albumResults = uniqueAlbums.values.toList();
      print('Deduplicated albums: ${albumResults.length}');
    }
  }

  void _sortResults() {
    switch (currentSort) {
      case SortOption.name:
        searchResults.sort(
          (a, b) => (a['song_name'] ?? '').compareTo(b['song_name'] ?? ''),
        );
        artistResults.sort(
          (a, b) => (a['artist_name'] ?? '').compareTo(b['artist_name'] ?? ''),
        );
        albumResults.sort(
          (a, b) => (a['album_name'] ?? '').compareTo(b['album_name'] ?? ''),
        );
        break;
      case SortOption.playCount:
        searchResults.sort(
          (a, b) => (b['play_count'] ?? 0).compareTo(a['play_count'] ?? 0),
        );
        break;
      case SortOption.recent:
        searchResults.sort((a, b) {
          final aTime = a['created_at'] as Timestamp?;
          final bTime = b['created_at'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        break;
      case SortOption.relevance:
      default:
        // Sort by relevance - prioritize exact matches
        _sortByRelevance();
        break;
    }
  }

  void _sortByRelevance() {
    final query = currentQuery.toLowerCase();

    // Sort songs by relevance
    searchResults.sort((a, b) {
      final aName = (a['song_name'] ?? '').toLowerCase();
      final bName = (b['song_name'] ?? '').toLowerCase();

      // Exact match gets highest priority
      if (aName == query && bName != query) return -1;
      if (bName == query && aName != query) return 1;

      // Starts with query gets second priority
      if (aName.startsWith(query) && !bName.startsWith(query)) return -1;
      if (bName.startsWith(query) && !aName.startsWith(query)) return 1;

      // Contains query gets third priority
      if (aName.contains(query) && !bName.contains(query)) return -1;
      if (bName.contains(query) && !aName.contains(query)) return 1;

      // Finally sort by play count
      return (b['play_count'] ?? 0).compareTo(a['play_count'] ?? 0);
    });

    // Sort artists by relevance
    artistResults.sort((a, b) {
      final aName = (a['artist_name'] ?? '').toLowerCase();
      final bName = (b['artist_name'] ?? '').toLowerCase();

      if (aName == query && bName != query) return -1;
      if (bName == query && aName != query) return 1;
      if (aName.startsWith(query) && !bName.startsWith(query)) return -1;
      if (bName.startsWith(query) && !aName.startsWith(query)) return 1;
      if (aName.contains(query) && !bName.contains(query)) return -1;
      if (bName.contains(query) && !aName.contains(query)) return 1;

      return (b['follower_count'] ?? 0).compareTo(a['follower_count'] ?? 0);
    });

    // Sort albums by relevance
    albumResults.sort((a, b) {
      final aName = (a['album_name'] ?? '').toLowerCase();
      final bName = (b['album_name'] ?? '').toLowerCase();

      if (aName == query && bName != query) return -1;
      if (bName == query && aName != query) return 1;
      if (aName.startsWith(query) && !bName.startsWith(query)) return -1;
      if (bName.startsWith(query) && !aName.startsWith(query)) return 1;
      if (aName.contains(query) && !bName.contains(query)) return -1;
      if (bName.contains(query) && !aName.contains(query)) return 1;

      return aName.compareTo(bName);
    });
  }

  void _cacheResults(String cacheKey) {
    _searchCache[cacheKey] = [
      ...searchResults,
      ...artistResults,
      ...albumResults,
    ];
  }

  void _applyCachedResults(String cacheKey) {
    final cached = _searchCache[cacheKey]!;

    // Use Sets to track unique IDs and avoid duplicates
    final Set<String> addedSongIds = {};
    final Set<String> addedArtistIds = {};
    final Set<String> addedAlbumIds = {};

    searchResults = [];
    artistResults = [];
    albumResults = [];

    for (var item in cached) {
      final id = item['id'] as String?;
      if (id == null) continue;

      // Determine item type more precisely
      if (item.containsKey('song_name') &&
          item['song_name'] != null &&
          !addedSongIds.contains(id)) {
        searchResults.add(item);
        addedSongIds.add(id);
      } else if (item.containsKey('artist_name') &&
          item['artist_name'] != null &&
          !item.containsKey('song_name') &&
          !item.containsKey('album_name') &&
          !addedArtistIds.contains(id)) {
        artistResults.add(item);
        addedArtistIds.add(id);
      } else if (item.containsKey('album_name') &&
          item['album_name'] != null &&
          !addedAlbumIds.contains(id)) {
        albumResults.add(item);
        addedAlbumIds.add(id);
      }
    }

    print(
      'Applied cached results - Songs: ${searchResults.length}, Artists: ${artistResults.length}, Albums: ${albumResults.length}',
    );
  }

  void setFilter(SearchFilter filter) {
    if (currentFilter != filter) {
      currentFilter = filter;
      if (currentQuery.isNotEmpty) {
        searchAll(currentQuery);
      } else {
        notifyListeners();
      }
    }
  }

  void setSort(SortOption sort) {
    if (currentSort != sort) {
      currentSort = sort;
      if (currentQuery.isNotEmpty) {
        _sortResults();
        notifyListeners();
      }
    }
  }

  void clearSearch({bool fromUser = true}) {
    if (fromUser) {
      searchController.clear();
      searchFocus.requestFocus();
    }
    searchResults = [];
    artistResults = [];
    albumResults = [];
    searchSuggestions = [];
    showSuggestions = false;
    hasError = false;
    errorMessage = null;

    // Chỉ reset currentQuery khi người dùng xóa hết text
    if (searchController.text.isEmpty) {
      currentQuery = '';
    }

    notifyListeners();
  }

  Future<void> fetchTrendingSongs({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isTrendingLoading = true;
        notifyListeners();
      }

      final query =
          await FirebaseFirestore.instance
              .collection('songs')
              .orderBy('play_count', descending: true)
              .limit(12)
              .get();

      trendingSongs =
          query.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      if (isRefresh) {
        isTrendingLoading = false;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching trending songs: $e');
      trendingSongs = [];
      if (isRefresh) {
        isTrendingLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> refreshTrendingSongs() async {
    await fetchTrendingSongs(isRefresh: true);
  }

  Future<void> fetchRecentSongs() async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('songs')
              .orderBy('created_at', descending: true)
              .limit(15)
              .get();

      recentSongs =
          query.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      // Load artist names for recent songs
      await _loadArtistNamesForList(recentSongs);
      notifyListeners();
    } catch (e) {
      print('Error fetching recent songs: $e');
      recentSongs = [];
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    if (userId == null) return;
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('search_history')
              .orderBy('timestamp', descending: true)
              .limit(15)
              .get();

      history =
          query.docs
              .map((doc) => doc['document'] as String? ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching search history: $e');
      history = [];
      notifyListeners();
    }
  }

  Future<void> addToHistory(String keyword) async {
    if (userId == null || keyword.isEmpty) return;
    try {
      // Remove if exists to avoid duplicates
      final existingQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('search_history')
              .where('document', isEqualTo: keyword)
              .get();

      for (var doc in existingQuery.docs) {
        await doc.reference.delete();
      }

      // Add new entry
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('search_history')
          .add({
            'document': keyword,
            'timestamp': FieldValue.serverTimestamp(),
          });

      await fetchHistory();
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  Future<void> removeFromHistory(String keyword) async {
    if (userId == null) return;
    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('search_history')
              .where('document', isEqualTo: keyword)
              .get();

      for (var doc in query.docs) {
        await doc.reference.delete();
      }

      await fetchHistory();
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }

  void hideHistory() {
    showHistory = false;
    showSuggestions = false;
    searchFocus.unfocus();
    notifyListeners();
  }

  void hideSuggestions() {
    showSuggestions = false;
    searchFocus.unfocus();
    notifyListeners();
  }

  int get totalResults =>
      searchResults.length + artistResults.length + albumResults.length;

  bool get hasResults => totalResults > 0;

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
    } else if (error.toString().contains('timeout')) {
      return 'Tìm kiếm quá lâu. Vui lòng thử lại.';
    } else if (error.toString().contains('firebase')) {
      return 'Lỗi server. Vui lòng thử lại sau.';
    } else {
      return 'Có lỗi xảy ra khi tìm kiếm. Vui lòng thử lại.';
    }
  }

  void retrySearch() {
    if (currentQuery.isNotEmpty) {
      searchAll(currentQuery);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _suggestionTimer?.cancel();
    searchController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  // Hàm Firestore query cũ cho album (fallback)
  Future<void> _searchAlbumsFirestore(String keyword) async {
    final searchKeyword = _formatSearchKeyword(keyword);
    try {
      final albumQuery =
          await FirebaseFirestore.instance
              .collection('albums')
              .where('album_name', isGreaterThanOrEqualTo: searchKeyword)
              .where(
                'album_name',
                isLessThanOrEqualTo: searchKeyword + '\\uf8ff',
              )
              .limit(10)
              .get();
      final Set<String> addedAlbumIds = {};
      albumResults = [];
      for (var doc in albumQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (!addedAlbumIds.contains(doc.id)) {
          albumResults.add(data);
          addedAlbumIds.add(doc.id);
        }
      }
    } catch (e) {
      print('Error searching albums (firestore fallback): $e');
      albumResults = [];
    }
  }

  Future<void> _searchSongs(String keyword) async {
    await _loadAllSongs();
    // Ưu tiên tìm kiếm client-side
    searchResults = _filterSongsClient(keyword);
    print('Client-side song search found: \\${searchResults.length}');
    // Nếu không tìm thấy, thử thêm các biến thể keyword
    if (searchResults.isEmpty) {
      // Capitalize từng từ
      final capKeyword = _capitalizeEachWord(keyword);
      if (capKeyword != keyword) {
        searchResults = _filterSongsClient(capKeyword);
      }
    }
    if (searchResults.isEmpty) {
      // Loại bỏ khoảng trắng
      final noSpaceKeyword = keyword.replaceAll(' ', '');
      if (noSpaceKeyword != keyword) {
        searchResults = _filterSongsClient(noSpaceKeyword);
      }
    }
    print('Final client-side song search: \\${searchResults.length}');
    // Nếu vẫn không có, fallback về Firestore query cũ (ít khi cần)
    if (searchResults.isEmpty) {
      await _searchSongsFirestore(keyword);
    }
  }

  // Hàm Firestore query cũ cho song (fallback)
  Future<void> _searchSongsFirestore(String keyword) async {
    final searchKeyword = _formatSearchKeyword(keyword);
    try {
      final songQuery =
          await FirebaseFirestore.instance
              .collection('songs')
              .where('song_name', isGreaterThanOrEqualTo: searchKeyword)
              .where(
                'song_name',
                isLessThanOrEqualTo: searchKeyword + '\\uf8ff',
              )
              .limit(10)
              .get();
      final Set<String> addedSongIds = {};
      searchResults = [];
      for (var doc in songQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (!addedSongIds.contains(doc.id)) {
          searchResults.add(data);
          addedSongIds.add(doc.id);
        }
      }
    } catch (e) {
      print('Error searching songs (firestore fallback): $e');
      searchResults = [];
    }
  }
}
