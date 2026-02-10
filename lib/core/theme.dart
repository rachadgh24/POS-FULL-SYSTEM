import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E0E11),

    colorScheme: const ColorScheme.dark(
      primary: Colors.cyanAccent,
      secondary: Color(0xFF1E1E24),
      surface: Color(0xFF16161A),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0E0E11),
      elevation: 0,
      centerTitle: true,
      toolbarTextStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 20),
      titleTextStyle: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 20),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF16161A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.black54,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
    ),
  );

  static LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF16161A), Color(0xFF1E1E24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient appBarGradient = LinearGradient(
    colors: [Color(0xFF0E0E11), Color(0xFF1E1E24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient lowStockGradientYellow = LinearGradient(
    colors: [Colors.yellow.shade700, Colors.yellow.shade500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient lowStockGradientOrange = LinearGradient(
    colors: [Colors.orange.shade700, Colors.orange.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient lowStockGradientRed = LinearGradient(
    colors: [Colors.red.shade800, Colors.red.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
