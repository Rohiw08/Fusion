import 'package:flutter/material.dart';

final ThemeData darkNightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3B3A4A), // Dark gray from palette
    onPrimary:
        Color(0xFFF5F9F8), // Off-white from palette for text/icons on primary
    secondary: Color(0xFF595168), // Purple-gray from palette
    onSecondary: Color(0xFFF5F9F8), // Off-white for text on secondary
    background: Color(0xFF252330), // Darkest gray/almost black for background
    onBackground: Color(0xFFF5F9F8), // Off-white for text on background
    surface: Color(0xFF3B3A4A), // Dark gray for surface elements
    onSurface: Color(0xFFF5F9F8), // Off-white for text on surface
    error: Colors.redAccent, // Keeping a reddish error color
    onError: Color(0xFFF5F9F8), // Off-white for text on error
  ),
  scaffoldBackgroundColor:
      const Color(0xFF252330), // Darkest color for scaffold
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF252330), // Darkest color
    foregroundColor: Color(0xFFF5F9F8), // Off-white text
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF595168), // Purple-gray accent
    foregroundColor: Color(0xFFF5F9F8), // Off-white for icon
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3B3A4A), // Dark gray
      foregroundColor: const Color(0xFFF5F9F8), // Off-white text
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFF5F9F8)), // Off-white
    bodyMedium: TextStyle(color: Color(0xFFA1A2AB)), // Light gray
  ),
  cardTheme: const CardTheme(
    color: Color(0xFF3B3A4A), // Dark gray
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFA1A2AB), // Light gray
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF575669), // Medium gray
  ),
);
