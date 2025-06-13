import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFEF476F); // Pastry pink color
  static const Color secondaryColor = Color(0xFFF4F4F4);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF0A0A0A);
  static const Color mutedTextColor = Color(0xFF737373);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFE5E5E5);
  
  // Dark mode colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFE0E0E0); // Lebih terang untuk kontras yang lebih baik
  static const Color darkMutedTextColor = Color(0xFFB0B0B0); // Lebih terang untuk kontras yang lebih baik
  static const Color darkBorderColor = Color(0xFF2C2C2C);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: const CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: borderColor),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textColor),
      titleSmall: TextStyle(color: mutedTextColor),
      bodyLarge: TextStyle(color: textColor),
      bodyMedium: TextStyle(color: textColor),
      bodySmall: TextStyle(color: mutedTextColor),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: mutedTextColor,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: mutedTextColor),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondaryColor,
      labelStyle: const TextStyle(color: textColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      onPrimary: Colors.white,
      onSecondary: textColor,
      onSurface: textColor,
      onError: Colors.white,
      error: Colors.red,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    cardTheme: const CardTheme(
      color: darkCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: darkBorderColor),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextColor),
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: darkTextColor),
      titleSmall: TextStyle(color: darkMutedTextColor),
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: darkTextColor),
      bodySmall: TextStyle(color: darkMutedTextColor),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: darkMutedTextColor,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextColor,
        side: const BorderSide(color: darkBorderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: darkMutedTextColor),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCardColor,
      labelStyle: const TextStyle(color: darkTextColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      selectedColor: primaryColor.withAlpha(77),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: darkMutedTextColor,
      textColor: darkTextColor,
    ),
    iconTheme: const IconThemeData(
      color: darkMutedTextColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkMutedTextColor,
    ),
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkCardColor,
      onPrimary: Colors.white,
      onSecondary: darkTextColor,
      onSurface: darkTextColor,
      onError: Colors.white,
      error: Colors.red,
    ),
  );
  
  // Cupertino theme data - Light
  static CupertinoThemeData getCupertinoLightTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      barBackgroundColor: backgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryColor,
        textStyle: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        navTitleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: textColor,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
        navActionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          color: mutedTextColor,
          fontSize: 10,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        pickerTextStyle: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
    );
  }
  
  // Cupertino theme data - Dark
  static CupertinoThemeData getCupertinoDarkTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      barBackgroundColor: darkBackgroundColor,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryColor,
        textStyle: TextStyle(
          color: darkTextColor,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        navTitleTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
        navActionTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          color: darkMutedTextColor,
          fontSize: 10,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 16,
        ),
        pickerTextStyle: TextStyle(
          color: darkTextColor,
          fontSize: 16,
        ),
      ),
    );
  }
}

