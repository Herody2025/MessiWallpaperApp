import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:wallpaper_app/pages/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String? imageUrl;
  late AnimationController _imgController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

    _imgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fetchRandomImage();

    // ✅ After 4 sec, move to home
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  Future<void> fetchRandomImage() async {
    try {
      final response = await http.get(
        Uri.parse("https://herody.in/api/wallpapers"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> wallpapers = decoded["data"];

        if (wallpapers.isNotEmpty) {
          wallpapers.shuffle();
          setState(() {
            imageUrl = wallpapers.first["url"].toString();
          });

          _imgController.forward();
          Future.delayed(const Duration(milliseconds: 800), () {
            _textController.forward();
          });
        }
      } else {
        setState(() => imageUrl = null);
      }
    } catch (e) {
      debugPrint("⚠️ Splash fetch error: $e");
      setState(() => imageUrl = null);
    }
  }

  @override
  void dispose() {
    _imgController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _imgController,
            builder: (context, child) {
              return Opacity(
                opacity: _imgController.value,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.amberAccent));
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/Messi wallpaper 4k.jpg',
                                fit: BoxFit.cover),
                      )
                    : Image.asset('assets/Messi wallpaper 4k.jpg',
                        fit: BoxFit.cover),
              );
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: FadeTransition(
              opacity: _textController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Messi Wallpapers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.amberAccent.withOpacity(0.7),
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '"Greatest Of All Time"\nUnleash the GOAT on your screen!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black54,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 48,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
