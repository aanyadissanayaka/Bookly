import 'package:flutter/material.dart';
import '../utils/app_colors.dart';


// Bookly app එකේ main theme settings මෙතන තියාගන්නවා.
class AppTheme {

  // --------------------------------------------------
  // LIGHT THEME
  // --------------------------------------------------

  static ThemeData lightTheme = ThemeData(

    // Material 3 design system එක භාවිතා කරනවා.
    useMaterial3: true,


    // ------------------------------------------------
    // MAIN BACKGROUND
    // ------------------------------------------------

    // App එකේ screens වල default background color එක.
    scaffoldBackgroundColor: AppColors.warmCream,


    // ------------------------------------------------
    // COLOR SCHEME
    // ------------------------------------------------

    colorScheme: ColorScheme.fromSeed(

      // Bookly app එකේ main Olive Green color එක.
      seedColor: AppColors.primary,

      // Light theme එකක් බව Flutter එකට කියනවා.
      brightness: Brightness.light,

      // Main screen background.
      surface: AppColors.warmCream,
    ),


    // ------------------------------------------------
    // TEXT COLOR
    // ------------------------------------------------

    // App එකේ default text color එක Dark Charcoal කරනවා.
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.darkText,
      ),

      bodyMedium: TextStyle(
        color: AppColors.darkText,
      ),

      bodySmall: TextStyle(
        color: AppColors.darkText,
      ),
    ),


    // ------------------------------------------------
    // APP BAR
    // ------------------------------------------------

    appBarTheme: const AppBarTheme(

      // Background එක Warm Cream.
      backgroundColor: AppColors.warmCream,

      // AppBar text / icons වල color.
      foregroundColor: AppColors.darkText,

      // Shadow එක remove කරනවා.
      elevation: 0,

      // Title එක center කරනවා.
      centerTitle: true,
    ),


    // ------------------------------------------------
    // NAVIGATION BAR
    // ------------------------------------------------

    navigationBarTheme: NavigationBarThemeData(

      // Bottom navigation background.
      backgroundColor: AppColors.offWhite,

      // Navigation bar height.
      height: 70,

      // Select කරපු icon එක වටේ තියෙන indicator.
      indicatorColor: AppColors.sage.withValues(
        alpha: 0.45,
      ),

      // Navigation icons වල color.
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
        (states) {

          // Selected tab එක.
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
            );
          }

          // Unselected tabs.
          return const IconThemeData(
            color: AppColors.darkText,
          );
        },
      ),
    ),
  );
}