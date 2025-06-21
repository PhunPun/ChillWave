import 'package:chillwave/pages/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // ⬅️ thêm provider
import 'package:chillwave/controllers/music_state_provider.dart'; // ⬅️ đường dẫn tới provider mới

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('playedSongIds');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicStateProvider()), // ✅ Khởi tạo provider
      ],
      child: const MyApp(),
    ),
  );
}
