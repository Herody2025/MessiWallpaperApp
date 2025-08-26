import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallpaper_app/helper/wallpaper_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FullScreenWallpaper extends StatefulWidget {
  final String imageUrl;
  const FullScreenWallpaper({super.key, required this.imageUrl});

  @override
  State<FullScreenWallpaper> createState() => _FullScreenWallpaperState();
}

class _FullScreenWallpaperState extends State<FullScreenWallpaper> {
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  /// ✅ Load Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test Rewarded Ad
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint("Rewarded Ad loaded ✅");
        },
        onAdFailedToLoad: (error) {
          debugPrint("Rewarded failed: $error");
          _rewardedAd = null;
        },
      ),
    );
  }

  /// ✅ Show Rewarded Ad before executing action
  void _showRewardedAd(VoidCallback onRewardEarned) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint("🎁 User watched ad: ${reward.amount} ${reward.type}");
          onRewardEarned(); // Run the action after ad
        },
      );
      _rewardedAd = null;
      _loadRewardedAd(); // Preload next
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Ad not ready, please try again")),
      );
    }
  }

  /// ✅ Download image to temporary dir
  Future<String> _downloadImageTemp() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp_wallpaper.jpg');
    await Dio().download(widget.imageUrl, file.path);
    return file.path;
  }

  /// ✅ Ask permission
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) return true;
      if (Platform.version.compareTo("13") >= 0) {
        var status = await Permission.photos.request();
        return status.isGranted;
      }
      var status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  /// ✅ Save image to gallery (only after ad watched)
  void _saveImage(BuildContext context) {
    _showRewardedAd(() async {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Permission denied")),
        );
        return;
      }

      try {
        final response = await http.get(Uri.parse(widget.imageUrl));
        final Uint8List bytes = response.bodyBytes;

        await ImageGallerySaverPlus.saveImage(
          bytes,
          quality: 90,
          name: "wallpaper_${DateTime.now().millisecondsSinceEpoch}",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Image saved to gallery")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: $e")),
        );
      }
    });
  }

  /// ✅ Set wallpaper (only after ad watched)
  void _setWallpaper(BuildContext context, int option) {
    _showRewardedAd(() async {
      try {
        final path = await _downloadImageTemp();
        await WallpaperHelper.setWallpaper(path, option);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Wallpaper set successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: $e")),
        );
      }
    });
  }

  void _showSetWallpaperOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Set as Wallpaper",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    )),
                const SizedBox(height: 10),
                Text("Choose where you want to set the wallpaper",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 20),
                _buildOptionButton(
                  context,
                  icon: Icons.home,
                  text: "Home Screen",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(ctx);
                    _setWallpaper(context, 1);
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  context,
                  icon: Icons.lock,
                  text: "Lock Screen",
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(ctx);
                    _setWallpaper(context, 2);
                  },
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  context,
                  icon: Icons.phone_android,
                  text: "Both",
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.pop(ctx);
                    _setWallpaper(context, 3);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onPressed: onTap,
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      onPressed: onPressed,
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: widget.imageUrl,
              child: PhotoView(
                imageProvider: NetworkImage(widget.imageUrl),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  text: "Set as Wallpaper",
                  onPressed: () => _showSetWallpaperOptions(context),
                ),
                const SizedBox(height: 12),
                _buildButton(
                  text: "Download",
                  onPressed: () => _saveImage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
