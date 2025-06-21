import 'dart:io';
import 'package:chillwave/controllers/acrcloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final ACRCloudController acrController = ACRCloudController();
  String result = 'Nhấn Ghi âm → Dừng → Tìm nhạc';
  String? recordedFilePath;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  Future<void> initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await recorder.openRecorder();
  }

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/recorded.aac';
    recordedFilePath = filePath;

    await recorder.startRecorder(toFile: filePath);
    setState(() {
      result = 'Đang ghi âm...';
    });
  }

  Future<void> stopRecording() async {
    await recorder.stopRecorder();
    setState(() {
      result = 'Đang nhận diện...';
    });

    if (recordedFilePath != null) {
      final songName = await acrController.recognizeSong(File(recordedFilePath!));
      setState(() {
        result = (songName != null) ? songName.toString() : 'Không nhận diện được';
      });
    } else {
      setState(() {
        result = 'Lỗi: Không tìm thấy file ghi âm';
      });
    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ACRCloud Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(result, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: startRecording, child: const Text('Ghi âm')),
            ElevatedButton(onPressed: stopRecording, child: const Text('Dừng & Tìm nhạc')),
          ],
        ),
      ),
    );
  }
}
