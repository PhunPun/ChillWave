import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ACRCloudController {
  final String host = 'identify-ap-southeast-1.acrcloud.com';
  final String accessKey = '11564149661260ac99cbdf4c2c211c92';
  final String accessSecret = 'cJtHfZWbiAne6La5legUweAebIfATKILiLFEsuAy';

  Future<String?> recognizeSong(File audioFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final stringToSign =
        'POST\n/v1/identify\n$accessKey\naudio\n1\n$timestamp';

    final hmacSha1 = Hmac(sha1, utf8.encode(accessSecret));
    final signature = base64.encode(hmacSha1.convert(utf8.encode(stringToSign)).bytes);

    final bytes = await audioFile.readAsBytes();

    final request = http.MultipartRequest(
      'POST',
      Uri.https(host, '/v1/identify'),
    )
      ..fields['access_key'] = accessKey
      ..fields['sample_bytes'] = bytes.length.toString()
      ..fields['timestamp'] = timestamp.toString()
      ..fields['signature'] = signature
      ..fields['data_type'] = 'audio'
      ..fields['signature_version'] = '1'
      ..files.add(http.MultipartFile.fromBytes('sample', bytes));

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final result = json.decode(utf8.decode(responseData));

    try {
      final title = result['metadata']['music'][0]['title'];
      final artist = result['metadata']['music'][0]['artists'][0]['name'];
      return '$title - $artist';
    } catch (e) {
      return 'Không nhận diện được';
    }
  }
}
