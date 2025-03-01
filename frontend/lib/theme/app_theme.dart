import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class AppTheme {
  // Brand Colors - using existing colors from AppColors
  static const primaryColor =
      AppColors.mainGreenDark; // Using your existing green
  static const accentColor = AppColors.mainRed; // Using your existing red
  static const backgroundColor = AppColors.mainCreme; // Using your cream color

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mainWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textBlack),
        titleTextStyle: TextStyle(
          color: AppColors.textBlack,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.mainWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: AppColors.mainBlackFaded,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.mainWhite,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.mainGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.mainGray,
        ),
      ),
    );
  }
}
