import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    
    primaryColor: Colors.purple,

    colorScheme: ColorScheme.dark(
      primary: Colors.purple,
      secondary: Colors.cyan,
    ), 

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
