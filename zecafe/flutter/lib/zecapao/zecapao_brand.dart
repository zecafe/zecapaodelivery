import 'package:flutter/material.dart';

abstract final class ZecapaoBrand {
  static const String appName = 'Zecapão Delivery';
  static const String destinationName = 'Vale do Capão';
  static const String tagline = 'Tudo que Vale, entregue até você!';

  static const Color red = Color(0xFFE72E27);
  static const Color yellow = Color(0xFFFEC90F);
  static const Color graphite = Color(0xFF242330);
  static const Color white = Color(0xFFFFFFFF);
  static const Color indigo = Color(0xFF303154);
  static const Color coral = Color(0xFFF46C48);
  static const Color green = Color(0xFF3EC877);
  static const Color sand = Color(0xFFF4E8D3);
  static const Color lightSurface = Color(0xFFF7F7F8);
  static const Color muted = Color(0xFF9CA3AF);

  static ThemeData lightTheme() => ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: white,
        primaryColor: red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          brightness: Brightness.light,
          primary: red,
          secondary: yellow,
          surface: white,
          error: const Color(0xFFEF4444),
        ),
        cardTheme: CardThemeData(
          color: white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
