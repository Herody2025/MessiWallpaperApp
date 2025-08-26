import 'dart:io';
import 'package:flutter/services.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class WallpaperHelper {
  /// Set wallpaper for Home, Lock, or Both
  static Future<void> setWallpaper(String imagePath, int option) async {
    try {
      // option => 1 = Home, 2 = Lock, 3 = Both
      int location = WallpaperManagerFlutter.homeScreen;

      if (option == 1) {
        location = WallpaperManagerFlutter.homeScreen;
      } else if (option == 2) {
        location = WallpaperManagerFlutter.lockScreen;
      } else if (option == 3) {
        location = WallpaperManagerFlutter.bothScreens;
      }

      final file = File(imagePath);

      await WallpaperManagerFlutter().setWallpaper(file, location);
      print("✅ Wallpaper set successfully!");
    } on PlatformException catch (e) {
      print("⚠️ Failed to set wallpaper: $e");
    }
  }
}
