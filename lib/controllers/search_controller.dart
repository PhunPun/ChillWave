import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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

  Future<void> searchAll(String keyword) async {
    if (keyword.isEmpty) {
      clearSearch();
      return;
    }

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

      // If no results found after successful search
      if (!hasResults && !hasError) {
        // Không cần làm gì ở đây, chỉ cần giữ state
      }
    } catch (e) {
      print('Error searching: $e');
      hasError = true;
      errorMessage = _getErrorMessage(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _searchSongs(String keyword) async {
    final searchKeyword = _formatSearchKeyword(keyword);
    print(
      'Searching songs for keyword: "$keyword" -> formatted: "$searchKeyword"',
    );

    try {
      // Search by song name first (exact match priority)
      final songQuery =
          await FirebaseFirestore.instance
              .collection('songs')
              .where('song_name', isGreaterThanOrEqualTo: searchKeyword)
              .where('song_name', isLessThanOrEqualTo: searchKeyword + '\uf8ff')
              .limit(20)
              .get();

      print('Firebase query returned ${songQuery.docs.length} songs');

      // Use Set to track unique song IDs
      final Set<String> addedSongIds = {};
      searchResults = [];

      // Add direct song matches first
      for (var doc in songQuery.docs) {
        final data = doc.data();
        final songName = data['song_name'] as String? ?? '';

        // Filter to only include songs that actually contain the search keyword
        if (songName.toLowerCase().contains(keyword.toLowerCase())) {
          data['id'] = doc.id;
          if (!addedSongIds.contains(doc.id)) {
            searchResults.add(data);
            addedSongIds.add(doc.id);
            print('Found song: ${data['song_name']} by direct search');
          }
        }
      }

      // Only search by artist name if:
      // Current filter is 'artists' (user wants artist-related songs)
      if (currentFilter == SearchFilter.artists) {
        await _searchSongsByArtistName(keyword, addedSongIds);
      }
    } catch (e) {
      print('Error searching songs: $e');
      searchResults = [];
    }
  }

  Future<void> _searchSongsByArtistName(
    String keyword,
    Set<String> addedSongIds,
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
        // Then find songs by these artists
        for (String artistId in artistIds) {
          final songQuery =
              await FirebaseFirestore.instance
                  .collection('songs')
                  .where('artist_id', arrayContains: artistId)
                  .limit(10)
                  .get();

          // Add to search results if not already present
          for (var doc in songQuery.docs) {
            if (!addedSongIds.contains(doc.id)) {
              final data = doc.data();
              data['id'] = doc.id;
              searchResults.add(data);
              addedSongIds.add(doc.id);
            }
          }
        }
      }
    } catch (e) {
      print('Error searching songs by artist name: $e');
    }
  }

  Future<void> _loadArtistNamesForSongs() async {
    await _loadArtistNamesForList(searchResults);
  }

  Future<void> _loadArtistNamesForList(
    List<Map<String, dynamic>> songList,
  ) async {
    try {
      print('Loading artist names for ${songList.length} songs');

      for (int i = 0; i < songList.length; i++) {
        final song = songList[i];
        final artistIds = song['artist_id'];

        print('Song ${i}: ${song['song_name']}, artist_id: $artistIds');

        if (artistIds != null && artistIds is List && artistIds.isNotEmpty) {
          final artistId = artistIds.first.toString();
          print('Fetching artist with ID: $artistId');

          final artistDoc =
              await FirebaseFirestore.instance
                  .collection('artists')
                  .doc(artistId)
                  .get();

          if (artistDoc.exists) {
            final artistData = artistDoc.data();
            final artistName = artistData?['artist_name'] ?? 'Unknown Artist';
            songList[i]['artist_name'] = artistName;
            print('Found artist: $artistName for song: ${song['song_name']}');
          } else {
            songList[i]['artist_name'] = 'Unknown Artist';
            print('Artist document not found for ID: $artistId');
          }
        } else {
          songList[i]['artist_name'] = 'Unknown Artist';
          print('No artist_id found for song: ${song['song_name']}');
        }
      }

      print('Finished loading artist names');
    } catch (e) {
      print('Error loading artist names: $e');
    }
  }

  Future<void> _searchArtists(String keyword) async {
    final searchKeyword = _formatSearchKeyword(keyword);

    try {
      // Use Set to track unique artist IDs to avoid duplicates
      final Set<String> addedArtistIds = <String>{};
      artistResults = <Map<String, dynamic>>[];

      // 1. Search by artist name directly
      final directQuery =
          await FirebaseFirestore.instance
              .collection('artists')
              .where('artist_name', isGreaterThanOrEqualTo: searchKeyword)
              .where(
                'artist_name',
                isLessThanOrEqualTo: searchKeyword + '\uf8ff',
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
          print(
            'Added artist from direct search: ${data['artist_name']} (${artistId})',
          );
        }
      }

      // 2. Only search artists through songs if we don't have enough results
      if (artistResults.length < 5) {
        final songQuery =
            await FirebaseFirestore.instance
                .collection('songs')
                .where('song_name', isGreaterThanOrEqualTo: searchKeyword)
                .where(
                  'song_name',
                  isLessThanOrEqualTo: searchKeyword + '\uf8ff',
                )
                .limit(10)
                .get();

        for (var songDoc in songQuery.docs) {
          final songData = songDoc.data();
          final artistIds = songData['artist_id'];
          print(
            'Processing song: ${songData['song_name']}, artist_ids: $artistIds',
          );

          if (artistIds != null && artistIds is List) {
            for (String artistId in artistIds) {
              print(
                'Checking artist ID: $artistId, already added: ${addedArtistIds.contains(artistId)}',
              );
              // Double check to prevent duplicates
              if (!addedArtistIds.contains(artistId)) {
                try {
                  final artistDoc =
                      await FirebaseFirestore.instance
                          .collection('artists')
                          .doc(artistId)
                          .get();

                  if (artistDoc.exists) {
                    final artistData = artistDoc.data()!;
                    artistData['id'] = artistId;
                    artistResults.add(artistData);
                    addedArtistIds.add(artistId);
                    print(
                      'Added artist from song search: ${artistData['artist_name']} (${artistId})',
                    );
                    print('Total added IDs now: ${addedArtistIds.toList()}');
                  }
                } catch (e) {
                  print('Error fetching artist $artistId: $e');
                }
              } else {
                print('Skipping duplicate artist ID: $artistId');
              }
            }
          }
        }
      }

      print('Total artists found: ${artistResults.length}');
      print('Unique artist IDs: ${addedArtistIds.length}');

      // Final verification - remove any duplicates that might have slipped through
      final uniqueResults = <String, Map<String, dynamic>>{};
      for (final artist in artistResults) {
        final id = artist['id'] as String;
        uniqueResults[id] = artist;
      }
      artistResults = uniqueResults.values.toList();

      print(
        'Final unique artists after deduplication: ${artistResults.length}',
      );
    } catch (e) {
      print('Error searching artists: $e');
      artistResults = [];
    }
  }

  Future<void> _searchAlbums(String keyword) async {
    final searchKeyword = _formatSearchKeyword(keyword);

    try {
      // Search by album name first (exact match priority)
      final albumQuery =
          await FirebaseFirestore.instance
              .collection('albums')
              .where('album_name', isGreaterThanOrEqualTo: searchKeyword)
              .where(
                'album_name',
                isLessThanOrEqualTo: searchKeyword + '\uf8ff',
              )
              .limit(10)
              .get();

      // Use Set to track unique album IDs
      final Set<String> addedAlbumIds = {};
      albumResults = [];

      // Add direct album matches first
      for (var doc in albumQuery.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        if (!addedAlbumIds.contains(doc.id)) {
          albumResults.add(data);
          addedAlbumIds.add(doc.id);
        }
      }

      // Only search by artist name if:
      // 1. Current filter is 'artists' or 'all'
      // 2. We have few direct album results (less than 2)
      if (currentFilter == SearchFilter.all ||
          currentFilter == SearchFilter.artists ||
          albumResults.length < 2) {
        await _searchAlbumsByArtistName(keyword, addedAlbumIds);
      }

      // Load artist names for albums
      await _loadArtistNamesForAlbums();
    } catch (e) {
      print('Error searching albums: $e');
      albumResults = [];
    }
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

  Future<void> _loadArtistNamesForAlbums() async {
    try {
      for (int i = 0; i < albumResults.length; i++) {
        final album = albumResults[i];
        final artistIds = album['artist_id'];

        if (artistIds != null && artistIds is List && artistIds.isNotEmpty) {
          final artistId = artistIds.first.toString();

          final artistDoc =
              await FirebaseFirestore.instance
                  .collection('artists')
                  .doc(artistId)
                  .get();

          if (artistDoc.exists) {
            final artistData = artistDoc.data();
            albumResults[i]['artist_name'] =
                artistData?['artist_name'] ?? 'Unknown Artist';
          } else {
            albumResults[i]['artist_name'] = 'Unknown Artist';
          }
        } else {
          albumResults[i]['artist_name'] = 'Unknown Artist';
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
}
