import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ACRCloudController {
  final String host = 'identify-ap-southeast-1.acrcloud.com';
  final String accessKey = '11564149661260ac99cbdf4c2c211c92';
  final String accessSecret = 'cJtHfZWbiAne6La5legUweAebIfATKILiLFEsuAy';

  // Cải thiện: Nhận diện với multiple attempts và better result processing
  Future<Map<String, dynamic>?> recognizeSong(
    File audioFile, {
    int maxAttempts = 2,
  }) async {
    Map<String, dynamic>? bestResult;
    int highestScore = 0;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print('ACRCloud attempt $attempt/$maxAttempts');

        // Preprocessing audio nếu cần thiết
        Uint8List audioBytes = await _preprocessAudio(audioFile);

        final result = await _performRecognition(audioBytes);

        if (result != null) {
          final score = result['score'] ?? 0;

          // Lưu kết quả tốt nhất
          if (score > highestScore) {
            highestScore = score;
            bestResult = result;
          }

          // Nếu đã có kết quả tốt (>= 90), không cần thử nữa
          if (score >= 90) {
            print('High confidence result found: $score%');
            break;
          }
        }

        // Delay giữa các lần thử
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        print('ACRCloud attempt $attempt failed: $e');
      }
    }

    return bestResult;
  }

  // Preprocessing audio để cải thiện chất lượng nhận diện
  Future<Uint8List> _preprocessAudio(File audioFile) async {
    final bytes = await audioFile.readAsBytes();

    // TODO: Có thể thêm noise reduction, normalization ở đây
    // Hiện tại trả về bytes gốc

    return bytes;
  }

  // Thực hiện nhận diện với ACRCloud API
  Future<Map<String, dynamic>?> _performRecognition(
    Uint8List audioBytes,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final stringToSign = 'POST\n/v1/identify\n$accessKey\naudio\n1\n$timestamp';

    final hmacSha1 = Hmac(sha1, utf8.encode(accessSecret));
    final signature = base64.encode(
      hmacSha1.convert(utf8.encode(stringToSign)).bytes,
    );

    final request =
        http.MultipartRequest('POST', Uri.https(host, '/v1/identify'))
          ..fields['access_key'] = accessKey
          ..fields['sample_bytes'] = audioBytes.length.toString()
          ..fields['timestamp'] = timestamp.toString()
          ..fields['signature'] = signature
          ..fields['data_type'] = 'audio'
          ..fields['signature_version'] = '1'
          ..files.add(http.MultipartFile.fromBytes('sample', audioBytes));

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final result = json.decode(utf8.decode(responseData));

    print('ACRCloud response: $result');

    return _processRecognitionResult(result);
  }

  // Cải thiện: Xử lý kết quả tốt hơn với multiple candidates
  Map<String, dynamic>? _processRecognitionResult(Map<String, dynamic> result) {
    try {
      if (result['status']['code'] == 0) {
        final musicList = result['metadata']['music'] as List;

        if (musicList.isEmpty) {
          return null;
        }

        print('Found ${musicList.length} potential matches:');
        for (int i = 0; i < musicList.length; i++) {
          final music = musicList[i];
          final title = music['title'] ?? 'Unknown';
          final artist = music['artists']?[0]?['name'] ?? 'Unknown';
          final score = music['score'] ?? 0;
          final releaseDate = music['album']?['release_date'] ?? '';
          final isNumbered = _isNumberedTitle(title);
          final artistPriority = _getArtistPriorityScore(music);

          print(
            '  $i: $title - $artist (Score: $score, Release: $releaseDate, IsNumbered: $isNumbered, Priority: $artistPriority)',
          );
        }

        // Tìm kết quả tốt nhất từ multiple candidates với logic thông minh hơn
        Map<String, dynamic>? bestMatch = _selectBestMatch(musicList);

        if (bestMatch != null) {
          final title = bestMatch['title'] ?? 'Unknown';
          final artists = bestMatch['artists'] as List? ?? [];
          final artist =
              artists.isNotEmpty
                  ? artists[0]['name'] ?? 'Unknown Artist'
                  : 'Unknown Artist';
          final album = bestMatch['album']?['name'] ?? '';
          final score = bestMatch['score'] ?? 0;

          print('Selected best match: $title - $artist (Score: $score)');

          // Trả về kết quả với threshold linh hoạt hơn
          if (score >= 60) {
            return {
              'title': title,
              'artist': artist,
              'album': album,
              'score': score,
              'display': '$title - $artist',
              'confidence': '${score}%',
              'isHighConfidence': score >= 80,
            };
          } else {
            return {
              'title': 'Không chắc chắn',
              'artist': '',
              'album': '',
              'score': score,
              'display': 'Không nhận diện được (độ tin cậy thấp)',
              'confidence': '${score}%',
              'isHighConfidence': false,
            };
          }
        }
      } else {
        print('ACRCloud error: ${result['status']['msg']}');
      }
    } catch (e) {
      print('Parse error: $e');
    }

    return null;
  }

  // Logic thông minh để chọn bài hát đúng nhất từ nhiều candidates
  Map<String, dynamic>? _selectBestMatch(List musicList) {
    if (musicList.isEmpty) return null;
    if (musicList.length == 1) return musicList[0];

    // Sắp xếp theo nhiều tiêu chí
    final sortedList = List<Map<String, dynamic>>.from(musicList);

    sortedList.sort((a, b) {
      final scoreA = a['score'] ?? 0;
      final scoreB = b['score'] ?? 0;
      final titleA = a['title'] ?? '';
      final titleB = b['title'] ?? '';

      print('Comparing: "$titleA" vs "$titleB"');

      // 1. Ưu tiên score cao hơn (chỉ khi khác biệt đáng kể)
      if ((scoreA - scoreB).abs() > 5) {
        print('  -> Score difference significant: $scoreA vs $scoreB');
        return scoreB.compareTo(scoreA);
      }

      // 2. QUAN TRỌNG: Ưu tiên bài KHÔNG PHẢI dạng "Bài Hát Số X"
      final isNumberedA = _isNumberedTitle(titleA);
      final isNumberedB = _isNumberedTitle(titleB);

      if (isNumberedA != isNumberedB) {
        print('  -> Numbered title preference: A=$isNumberedA, B=$isNumberedB');
        return isNumberedA ? 1 : -1; // Ưu tiên bài không có số
      }

      // 3. Ưu tiên nghệ sĩ nổi tiếng
      final priorityScoreA = _getArtistPriorityScore(a);
      final priorityScoreB = _getArtistPriorityScore(b);

      if (priorityScoreA != priorityScoreB) {
        print('  -> Artist priority: A=$priorityScoreA, B=$priorityScoreB');
        return priorityScoreB.compareTo(priorityScoreA);
      }

      // 4. Ưu tiên bài có thời gian phát hành gần đây hơn
      final releaseDateA = a['album']?['release_date'] ?? '';
      final releaseDateB = b['album']?['release_date'] ?? '';

      if (releaseDateA.isNotEmpty && releaseDateB.isNotEmpty) {
        print('  -> Release date: A=$releaseDateA, B=$releaseDateB');
        return releaseDateB.compareTo(releaseDateA);
      }

      // 5. Ưu tiên bài có duration dài hơn (thường là bài chính thức)
      final durationA = a['duration_ms'] ?? 0;
      final durationB = b['duration_ms'] ?? 0;

      if (durationA != durationB) {
        print('  -> Duration: A=$durationA, B=$durationB');
        return durationB.compareTo(durationA);
      }

      // 6. Ưu tiên bài có tên album không trùng với tên bài hát (tránh single)
      final albumA = a['album']?['name'] ?? '';
      final albumB = b['album']?['name'] ?? '';

      final isAlbumTitleMatchA = titleA.toLowerCase() == albumA.toLowerCase();
      final isAlbumTitleMatchB = titleB.toLowerCase() == albumB.toLowerCase();

      if (isAlbumTitleMatchA != isAlbumTitleMatchB) {
        print(
          '  -> Album title match: A=$isAlbumTitleMatchA, B=$isAlbumTitleMatchB',
        );
        return isAlbumTitleMatchA ? 1 : -1;
      }

      // 7. Cuối cùng so sánh score chính xác
      print('  -> Final score comparison: A=$scoreA, B=$scoreB');
      return scoreB.compareTo(scoreA);
    });

    print('\nAfter sorting:');
    for (int i = 0; i < sortedList.length; i++) {
      final music = sortedList[i];
      final title = music['title'] ?? 'Unknown';
      final artist = music['artists']?[0]?['name'] ?? 'Unknown';
      final score = music['score'] ?? 0;
      print('  $i: $title - $artist (Score: $score)');
    }

    final selected = sortedList.first;
    print(
      '\nFINAL SELECTION: ${selected['title']} - ${selected['artists']?[0]?['name']}',
    );

    return selected;
  }

  // Tính điểm ưu tiên cho nghệ sĩ dựa trên độ nổi tiếng
  int _getArtistPriorityScore(Map<String, dynamic> music) {
    final artists = music['artists'] as List? ?? [];
    if (artists.isEmpty) return 0;

    final artistName = artists[0]['name']?.toString().toLowerCase() ?? '';

    // Danh sách nghệ sĩ nổi tiếng Việt Nam (có thể mở rộng)
    final popularArtists = [
      'sơn tùng m-tp',
      'erik',
      'hồ ngọc hà',
      'đen vâu',
      'jack',
      'k-icm',
      'amee',
      'bích phương',
      'mỹ tâm',
      'noo phước thịnh',
      'touliver',
      'binz',
      'karik',
      'rhymastic',
      'hieuthuhai',
    ];

    for (int i = 0; i < popularArtists.length; i++) {
      if (artistName.contains(popularArtists[i])) {
        return popularArtists.length - i; // Điểm càng cao càng ưu tiên
      }
    }

    return 0;
  }

  // Kiểm tra xem tiêu đề có phải là dạng "Bài Hát Số X" không
  bool _isNumberedTitle(String title) {
    final lowerTitle = title.toLowerCase().trim();

    // Các pattern cần tránh
    final patterns = ['bài hát số', 'bài số', 'track', 'song number'];

    for (final pattern in patterns) {
      if (lowerTitle.contains(pattern)) {
        print(
          '  -> Title "$title" matches pattern "$pattern" - marking as numbered',
        );
        return true;
      }
    }

    // Kiểm tra pattern kết thúc bằng số (như "Song 2", "Track 1")
    if (RegExp(r'.*\s+\d+$').hasMatch(lowerTitle)) {
      print('  -> Title "$title" ends with number - marking as numbered');
      return true;
    }

    print('  -> Title "$title" is NOT numbered');
    return false;
  }

  // Thêm method để nhận diện với custom settings
  Future<Map<String, dynamic>?> recognizeSongAdvanced(
    File audioFile, {
    int maxAttempts = 3,
    int minScore = 60,
    bool enablePreprocessing = true,
  }) async {
    Map<String, dynamic>? bestResult;
    int highestScore = 0;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        print('ACRCloud advanced attempt $attempt/$maxAttempts');

        Uint8List audioBytes;
        if (enablePreprocessing) {
          audioBytes = await _preprocessAudio(audioFile);
        } else {
          audioBytes = await audioFile.readAsBytes();
        }

        final result = await _performRecognition(audioBytes);

        if (result != null) {
          final score = result['score'] ?? 0;

          if (score > highestScore && score >= minScore) {
            highestScore = score;
            bestResult = result;
          }

          // Early exit cho high confidence
          if (score >= 95) {
            print('Very high confidence result: $score%');
            break;
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(Duration(milliseconds: 300 * attempt));
        }
      } catch (e) {
        print('ACRCloud advanced attempt $attempt failed: $e');
      }
    }

    return bestResult;
  }
}
