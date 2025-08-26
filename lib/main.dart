import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallpaper_app/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MessiWallpaperApp());
}

class MessiWallpaperApp extends StatelessWidget {
  const MessiWallpaperApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Messi Wallpaper",
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
