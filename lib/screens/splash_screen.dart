import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Splash screen එක තත්පර 3ක් පෙන්වනවා.
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      // Splash screen එක remove කරලා
      // Home screen එකට යනවා.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Screen width එක අනුව splash image එක තෝරනවා.
          final bool isMobile = constraints.maxWidth < 600;

          final String splashImage = isMobile
              ? 'assets/images/splash_mobile.png'
              : 'assets/images/splash_web.png';

          return SizedBox.expand(
            child: Image.asset(
              splashImage,

              // මුළු screen එක cover කරනවා.
              fit: BoxFit.cover,

              // Image එක center කරලා තියාගන්නවා.
              alignment: Alignment.center,
            ),
          );
        },
      ),
    );
  }
}
