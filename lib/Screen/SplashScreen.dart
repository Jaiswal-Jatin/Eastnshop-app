import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:eastnshop/Routes/App_Pages.dart';
import 'package:eastnshop/Utils/SharedPrefUtils.dart';
import 'package:eastnshop/Utils/TokenManager.dart';
import 'package:eastnshop/Constants/GlobalVariables.dart';
import 'package:eastnshop/Utils/ApiService.dart';
import 'package:eastnshop/Utils/ImageCacheHelper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _fadeTextAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0,
      end: 22,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeTextAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _navigateAfterDelay();
  }

  /// ---------------- NAVIGATION & PRE-CACHE LOGIC ----------------
  Future<void> _navigateAfterDelay() async {
    // Run pre-caching and delay in parallel
    // We don't await the preload fully because we want splash screen to exit after 4s regardless
    // But starting it here downloads images to disk while splash is spinning
    _preloadImages();
    await Future.delayed(const Duration(seconds: 4));

    await SharedPrefUtils.init();
    final bool isAuthenticated = await TokenManager.isAuthenticated();

    if (isAuthenticated) {
      await initializeGlobalState();
      Get.offAllNamed(AppRoutes.home);
    } else {
      resetGlobalState();
      Get.offAllNamed(AppRoutes.appStart);
    }
  }

  Future<void> _preloadImages() async {
    try {
      print('🕒 Splash: Starting background pre-cache...');
      
      final results = await Future.wait([
        ApiService.getCarouselImages(),
        ApiService.getImage1(),
        ApiService.getImage2(),
      ]);

      final carousel = results[0] as List<dynamic>;
      final midBanner = results[1] as Map<String, dynamic>?;
      final botBanner = results[2] as Map<String, dynamic>?;

      final urls = <String>[];
      for (var img in carousel) {
        if (img['url'] != null && img['url'].toString().isNotEmpty) {
          urls.add(img['url']);
        }
      }
      if (midBanner != null && midBanner['url'] != null) {
        urls.add(midBanner['url']);
      }
      if (botBanner != null && botBanner['url'] != null) {
        urls.add(botBanner['url']);
      }

      if (urls.isNotEmpty) {
        // Will download to local disk
        await ImageCacheService().preCacheUrls(urls);
      }
    } catch (e) {
      print('⚠️ Splash Pre-cache error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandRed = Color(0xFFFF9900);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ---------------- LOGO ANIMATION ----------------
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: brandRed,
                      boxShadow: [
                        BoxShadow(
                          color: brandRed.withOpacity(0.5),
                          blurRadius: _glowAnimation.value * 2,
                          spreadRadius: _glowAnimation.value,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      height: 175,
                      width: 175,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Image.asset(
                        'assets/ENS_Logo_1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _fallbackIcon(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ---------------- TEXT + LOADER ----------------
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height / 2 + 130,
            child: FadeTransition(
              opacity: _fadeTextAnimation,
              child: Column(
                children: const [
                  Text(
                    "EASTNSHOP",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9900),
                      letterSpacing: 1.3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Online Convenience. Local Trust.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 36),
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFF9900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- FALLBACK ICON ----------------
  Widget _fallbackIcon() {
    return const Icon(Icons.storefront, size: 60, color: Color(0xFFFF9900));
  }
}
