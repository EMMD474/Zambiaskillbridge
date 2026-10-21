import 'package:flutter/material.dart';

/// Design tokens for Zambia SkillBridge.
/// Light, flat and quiet: white screens, soft grey fills, one blue accent.
class SB {
  SB._();
  static const navy = Color(0xFF24364B);
  static const blueGrey = Color(0xFF64788C);
  static const bg = Color(0xFFFFFFFF);
  static const card = Colors.white;
  static const text = Color(0xFF172333);
  static const text2 = Color(0xFF6B7788);
  static const border = Color(0xFFEBEEF2);
  static const success = Color(0xFF1F9D6B);
  static const warning = Color(0xFFB87414);
  static const error = Color(0xFFD64545);
  static const accent = Color(0xFF2870D3);
  static const soft = Color(0xFFF3F5F8);

  // Older warm names now point at the same calm palette so nothing clashes.
  static const terracotta = accent;
  static const ochre = Color(0xFFE9A93B);
  static const sage = Color(0xFF3E9B74);
  static const navyLight = Color(0xFF3A5775);

  // Headings: Plus Jakarta Sans, bundled with the app so it works offline.
  static const _f = 'Jakarta';
  static const h0 = TextStyle(fontFamily: _f, fontSize: 40, fontWeight: FontWeight.w800, color: text, letterSpacing: -0.8);
  static const h0Navy = TextStyle(fontFamily: _f, fontSize: 44, fontWeight: FontWeight.w800, color: navy, letterSpacing: -0.8);
  static const h1 = TextStyle(fontFamily: _f, fontSize: 28, fontWeight: FontWeight.w800, color: text, height: 1.2, letterSpacing: -0.5);
  static const h1Navy = TextStyle(fontFamily: _f, fontSize: 30, fontWeight: FontWeight.w800, color: navy, height: 1.2, letterSpacing: -0.5);
  static const h2 = TextStyle(fontFamily: _f, fontSize: 22, fontWeight: FontWeight.w800, color: text, height: 1.25, letterSpacing: -0.3);
  static const h3 = TextStyle(fontFamily: _f, fontSize: 19, fontWeight: FontWeight.w700, color: text);
  static const h4 = TextStyle(fontFamily: _f, fontSize: 17, fontWeight: FontWeight.w700, color: text);

  static const double radius = 16;
  static const double radiusSm = 12;
  static const double pad = 16;
  static const double gap = 12;
}

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light, fontFamily: 'Jakarta');
  final scheme = ColorScheme.fromSeed(
    seedColor: SB.accent,
    brightness: Brightness.light,
  ).copyWith(
    primary: SB.accent,
    onPrimary: Colors.white,
    secondary: SB.navy,
    surface: Colors.white,
    surfaceTint: Colors.transparent,
    error: SB.error,
    outline: SB.border,
  );
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: SB.bg,
    textTheme: base.textTheme.apply(bodyColor: SB.text, displayColor: SB.text, fontFamily: 'Jakarta'),
    appBarTheme: const AppBarTheme(
      backgroundColor: SB.bg,
      foregroundColor: SB.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: SB.h4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SB.soft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(SB.accent, 1.4),
      errorBorder: border(SB.error),
      focusedErrorBorder: border(SB.error, 1.4),
      labelStyle: const TextStyle(color: SB.text2),
      hintStyle: const TextStyle(color: SB.text2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: SB.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Jakarta', fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SB.navy,
        minimumSize: const Size(64, 52),
        side: const BorderSide(color: Color(0xFFDDE2E9), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Jakarta', fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SB.accent,
        minimumSize: const Size(48, 44),
        textStyle: const TextStyle(fontFamily: 'Jakarta', fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: SB.soft,
      selectedColor: SB.accent,
      side: BorderSide.none,
      labelStyle: const TextStyle(fontFamily: 'Jakarta', fontSize: 13, fontWeight: FontWeight.w500, color: SB.text),
      secondaryLabelStyle: const TextStyle(fontFamily: 'Jakarta', fontSize: 13, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: SB.accent.withValues(alpha: .12),
      height: 66,
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontFamily: 'Jakarta',
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? SB.accent : SB.text2,
          )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(color: states.contains(WidgetState.selected) ? SB.accent : SB.text2)),
    ),
    dialogTheme: DialogThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    dividerTheme: const DividerThemeData(color: SB.border, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: SB.navy,
      contentTextStyle: const TextStyle(fontFamily: 'Jakarta', color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
