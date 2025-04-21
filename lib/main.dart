import 'package:chillwave/pages/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Trong suốt
    statusBarIconBrightness: Brightness.dark, // Đổi màu icon (light = icon trắng, dark = icon đen)
    systemNavigationBarColor: Colors.transparent, // Làm trong suốt hoặc đổi thành màu nền
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  runApp(const MyApp());
}