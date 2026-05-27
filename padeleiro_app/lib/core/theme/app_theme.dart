import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de cores da aplicação Padeleiro.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0055FF);
  static const success = Color(0xFF00C853);
  static const dark = Color(0xFF121212);
  static const light = Color(0xFFF8F9FA);
  static const error = Color(0xFFB00020);
  static const onPrimary = Color(0xFFFFFFFF);
}

/// Configuração de temas Material Design 3 para a aplicação Padeleiro.
class AppTheme {
  AppTheme._();

  /// Tema claro.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: AppColors.light,
    );
  }

  /// Tema escuro.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: AppColors.dark,
    );
  }
}
