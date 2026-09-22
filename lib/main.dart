// Flutter වල Material Design widgets භාවිතා කරන්න.
import 'package:flutter/material.dart';

// අපි හදපු Bookly theme එක import කරනවා.
import 'theme/app_theme.dart';

// Splash Screen එක import කරනවා.
import 'screens/splash_screen.dart';


// Flutter app එකේ entry point එක.
void main() {
  // BooklyApp කියන main widget එක run කරනවා.
  runApp(const BooklyApp());
}


// BooklyApp කියන්නේ අපේ application එකේ main widget එක.
class BooklyApp extends StatelessWidget {
  const BooklyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // MaterialApp කියන්නේ app එකේ main configuration එක.
    return MaterialApp(

      // DEBUG banner එක hide කරනවා.
      debugShowCheckedModeBanner: false,

      // App එකේ නම.
      title: 'Bookly',

      // අපි app_theme.dart එකේ හදපු
      // Bookly light theme එක මෙතන connect කරනවා.
      theme: AppTheme.lightTheme,

      // App එක open වුණාම
      // මුලින්ම Splash Screen එක පෙන්වනවා.
      home: const SplashScreen(),
    );
  }
}