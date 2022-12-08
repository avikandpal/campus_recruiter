import 'spacer/paddings.dart';
import 'package:flutter/material.dart';
import 'constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String _appFontFamily = 'PT_Sans';
  static const TextStyle appLabelTextStyle = TextStyle(
      fontFamily: _appFontFamily, fontSize: 18, color: AppColors.kDarkGrey);
  static const TextStyle appButtonTextStyle = TextStyle(
    fontFamily: _appFontFamily,
    fontSize: 16,
  );

  static const TextStyle appAccentTextStyle = TextStyle(
    fontFamily: _appFontFamily,
    fontSize: 16,
    color: Colors.black,
  );

  static const TextStyle appAlertLabelTextStyle = TextStyle(
    fontFamily: _appFontFamily,
    fontSize: 16.5,
    color: AppColors.kPrimaryColor,
    fontWeight: FontWeight.w600,
  );

  static const BorderRadius appBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );

  // App theme data
  static ThemeData data = ThemeData(
    // Font Family
    fontFamily: _appFontFamily,

    // Color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.kPrimaryColor,
    ),

    primarySwatch: Colors.blue,
    canvasColor: Colors.transparent,

    scaffoldBackgroundColor: Colors.white,

    // App bar theme
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black,
        size: 32,
      ),
      centerTitle: false,
      titleSpacing: 0,
      titleTextStyle: TextStyle(
        fontFamily: _appFontFamily,
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // TextField Input decoration theme
    inputDecorationTheme: const InputDecorationTheme(
      alignLabelWithHint: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: appBorderRadius,
        borderSide: BorderSide(
          color: AppColors.kMediumGrey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: appBorderRadius,
        borderSide: BorderSide(
          color: AppColors.kPrimaryColor,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 18,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: appButtonTextStyle,
        disabledForegroundColor:
            AppColors.kDisabledButtonColor.withOpacity(0.38),
        disabledBackgroundColor:
            AppColors.kDisabledButtonColor.withOpacity(0.12),
        // elevation: 0,
        padding: Paddings.all14px,
        // minimumSize: const Size(double.infinity, 36),
        shape: const RoundedRectangleBorder(
          borderRadius: appBorderRadius,
        ),
      ),
    ),

    // Outline Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: appBorderRadius,
        ),
        side: const BorderSide(
          color: AppColors.kPrimaryColor,
        ),
        textStyle: appButtonTextStyle,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 16,
        ),
        minimumSize: const Size(double.infinity, 0),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: Paddings.all2px,
        minimumSize: const Size(0, 0),
        textStyle: appButtonTextStyle,
      ),
    ),
  );
}
