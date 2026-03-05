import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Colors.indigo;
  static const Color _background = Color(0xFFF5F7FB);

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _primary),
      scaffoldBackgroundColor: _background,
      useMaterial3: true,
    );
  }
}
