import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.deepCharcoal,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.actionAccent,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.slateGray,
          outline: AppColors.divider,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.deepCharcoal,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.apply(
                bodyColor: AppColors.textPrimary,
                displayColor: AppColors.textPrimary,
              ),
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.actionAccent,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.slateGray,
          selectedItemColor: AppColors.actionAccent,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.actionAccent;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: AppColors.textSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.slateGray,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.actionAccent, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.actionAccent,
          onPrimary: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceContainerHighest: AppColors.lightSlateGray,
          outline: AppColors.lightDivider,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme.apply(
                bodyColor: AppColors.lightTextPrimary,
                displayColor: AppColors.lightTextPrimary,
              ),
        ),
        cardTheme: CardTheme(
          color: AppColors.lightCardBackground,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.actionAccent,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightCardBackground,
          selectedItemColor: AppColors.actionAccent,
          unselectedItemColor: AppColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.actionAccent;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: AppColors.lightTextSecondary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSlateGray,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.lightDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.actionAccent, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
          hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
        ),
      );

  /// Tabular figures for timer so numbers don't jump when they change.
  static TextStyle timerTextStyle({required bool isDark}) => GoogleFonts.robotoMono(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
