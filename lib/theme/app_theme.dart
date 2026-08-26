import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum SpeakeryThemeMode {
  dark('dark', 'Dark'),
  white('white', 'White'),
  voxaLight('voxa_light', 'Voxa Light'),
  voxaDark('voxa_dark', 'Voxa Dark');

  final String storageKey;
  final String label;

  const SpeakeryThemeMode(this.storageKey, this.label);

  static SpeakeryThemeMode fromStorageKey(String? value) {
    if (value == 'voxa') return SpeakeryThemeMode.voxaLight;
    for (final mode in values) {
      if (mode.storageKey == value) return mode;
    }
    return SpeakeryThemeMode.dark;
  }
}

class AppTheme {
  AppTheme._();

  static final Map<SpeakeryThemeMode, ThemeData> _themeCache =
      <SpeakeryThemeMode, ThemeData>{
    SpeakeryThemeMode.dark: darkTheme,
    SpeakeryThemeMode.white: whiteTheme,
    SpeakeryThemeMode.voxaLight: voxaLightTheme,
    SpeakeryThemeMode.voxaDark: voxaDarkTheme,
  };

  // Brand Colors
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryCyan = Color(0xFF22D3EE);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF4C1D95);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF60A5FA);

  // Gamification
  static const Color streak = Color(0xFFFF6B35);
  static const Color xpGold = Color(0xFFFBBF24);
  static const Color levelBadge = Color(0xFF8B5CF6);

  // Dark Surfaces
  static const Color background = Color(0xFF070711);
  static const Color backgroundSoft = Color(0xFF0F0E17);
  static const Color surface = Color(0xFF161627);
  static const Color surfaceVariant = Color(0xFF1D1B33);
  static const Color surfaceElevated = Color(0xFF24223A);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC9C7E8);
  static const Color textMuted = Color(0xFF7A7898);

  // Glass
  static const Color glassWhite = Color(0x18FFFFFF);
  static const Color glassStrong = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassActive = Color(0x447C3AED);

  // CEFR Colors
  static const Color levelA1 = Color(0xFF10B981);
  static const Color levelA2 = Color(0xFF34D399);
  static const Color levelB1 = Color(0xFF3B82F6);
  static const Color levelB2 = Color(0xFF6366F1);
  static const Color levelC1 = Color(0xFF8B5CF6);
  static const Color levelC2 = Color(0xFFEC4899);

  static ThemeData themeFor(SpeakeryThemeMode mode) {
    return _themeCache[mode]!;
  }

  static void _prepareFonts() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  static TextTheme _baseTextTheme(Brightness brightness) {
    final typography =
        Typography.material2021(platform: TargetPlatform.android);
    return brightness == Brightness.dark ? typography.white : typography.black;
  }

  static bool isLightMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  static ThemeData get darkTheme {
    _prepareFonts();
    final baseTextTheme = _baseTextTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        primaryContainer: Color(0xFF2E1065),
        secondary: primaryBlue,
        secondaryContainer: Color(0xFF172554),
        tertiary: primaryCyan,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        outline: glassBorder,
        outlineVariant: Color(0xFF2D2B45),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: _text(34, FontWeight.w800, textPrimary, -0.8),
        displayMedium: _text(30, FontWeight.w800, textPrimary, -0.6),
        displaySmall: _text(26, FontWeight.w700, textPrimary, -0.4),
        headlineLarge: _text(24, FontWeight.w700, textPrimary, -0.3),
        headlineMedium: _text(21, FontWeight.w700, textPrimary, -0.2),
        headlineSmall: _text(18, FontWeight.w700, textPrimary, 0),
        titleLarge: _text(17, FontWeight.w700, textPrimary, 0),
        titleMedium: _text(15, FontWeight.w600, textPrimary, 0),
        titleSmall: _text(13, FontWeight.w600, textSecondary, 0.1),
        bodyLarge: _text(15, FontWeight.w500, textPrimary, 0),
        bodyMedium: _text(13, FontWeight.w400, textSecondary, 0),
        bodySmall: _text(12, FontWeight.w400, textMuted, 0),
        labelLarge: _text(13, FontWeight.w700, textPrimary, 0.3),
        labelMedium: _text(11, FontWeight.w700, textSecondary, 0.4),
        labelSmall: _text(10, FontWeight.w700, textMuted, 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: _font(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return _font(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? Colors.white : textMuted,
            size: selected ? 25 : 23,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassWhite,
        hintStyle: _font(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: _font(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: _inputBorder(glassBorder),
        enabledBorder: _inputBorder(glassBorder),
        focusedBorder: _inputBorder(primaryLight, width: 1.6),
        errorBorder: _inputBorder(error),
        focusedErrorBorder: _inputBorder(error, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primary.withAlpha(89),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: _font(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: glassBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: _font(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: _font(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: glassWhite,
        elevation: 0,
        shadowColor: Colors.black.withAlpha(64),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: glassWhite,
        selectedColor: glassActive,
        disabledColor: surfaceVariant,
        labelStyle: _font(
          color: textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: _font(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: glassBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D2B45),
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: _font(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return whiteTheme;
  }

  static ThemeData get whiteTheme {
    _prepareFonts();
    final baseTextTheme = _baseTextTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F8FF),
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: Color(0xFFEDE9FE),
        secondary: primaryBlue,
        secondaryContainer: Color(0xFFEAF2FF),
        tertiary: primaryCyan,
        surface: Color(0xFFFFFFFF),
        error: error,
        onPrimary: Colors.white,
        onSurface: Color(0xFF171427),
        outline: Color(0xFFDCD6EE),
        outlineVariant: Color(0xFFECE8F7),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: _text(34, FontWeight.w800, const Color(0xFF171427), 0),
        displayMedium: _text(30, FontWeight.w800, const Color(0xFF171427), 0),
        displaySmall: _text(26, FontWeight.w700, const Color(0xFF171427), 0),
        headlineLarge: _text(24, FontWeight.w800, const Color(0xFF171427), 0),
        headlineMedium: _text(21, FontWeight.w800, const Color(0xFF171427), 0),
        headlineSmall: _text(18, FontWeight.w800, const Color(0xFF171427), 0),
        titleLarge: _text(17, FontWeight.w800, const Color(0xFF171427), 0),
        titleMedium: _text(15, FontWeight.w700, const Color(0xFF171427), 0),
        titleSmall: _text(13, FontWeight.w700, const Color(0xFF625A78), 0),
        bodyLarge: _text(15, FontWeight.w600, const Color(0xFF221D35), 0),
        bodyMedium: _text(13, FontWeight.w500, const Color(0xFF58516D), 0),
        bodySmall: _text(12, FontWeight.w500, const Color(0xFF77708D), 0),
        labelLarge: _text(13, FontWeight.w800, const Color(0xFF171427), 0),
        labelMedium: _text(11, FontWeight.w800, const Color(0xFF625A78), 0),
        labelSmall: _text(10, FontWeight.w800, const Color(0xFF77708D), 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _font(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF171427),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF171427)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withAlpha(150),
        elevation: 0,
        shadowColor: Colors.black.withAlpha(24),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE4E0F5), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return _font(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? const Color(0xFF171427) : const Color(0xFF77708D),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? const Color(0xFF171427) : const Color(0xFF77708D),
            size: selected ? 25 : 23,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(158),
        hintStyle: _font(
          color: const Color(0xFF77708D),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: _font(
          color: const Color(0xFF625A78),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: _inputBorder(const Color(0xFFDCD6EE)),
        enabledBorder: _inputBorder(const Color(0xFFDCD6EE)),
        focusedBorder: _inputBorder(primary, width: 1.6),
        errorBorder: _inputBorder(error),
        focusedErrorBorder: _inputBorder(error, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primary.withAlpha(42),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: _font(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF171427),
          side: const BorderSide(color: Color(0xFFDCD6EE), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: _font(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: _font(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withAlpha(150),
        selectedColor: const Color(0xB8EDE9FE),
        disabledColor: const Color(0xFFECE8F7),
        labelStyle: _font(
          color: const Color(0xFF171427),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        secondaryLabelStyle: _font(
          color: const Color(0xFF171427),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        side: const BorderSide(color: Color(0xFFDCD6EE), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE4E0F5),
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _font(
          color: const Color(0xFF171427),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: _font(
          color: const Color(0xFF625A78),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFFDCD6EE), width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF171427),
        contentTextStyle: _font(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  static ThemeData get voxaLightTheme {
    _prepareFonts();
    final baseTextTheme = _baseTextTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF7A12),
        primaryContainer: Color(0xFFFFE9D6),
        secondary: Color(0xFF8A4A20),
        secondaryContainer: Color(0xFFFFD4B3),
        tertiary: Color(0xFFFF9A3D),
        surface: Color(0xFFFFFCF8),
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF3B2116),
        outline: Color(0xFFB9876B),
        outlineVariant: Color(0xFFEAD5C5),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: _text(34, FontWeight.w800, const Color(0xFF3B2116), -0.8),
        displayMedium:
            _text(30, FontWeight.w800, const Color(0xFF3B2116), -0.6),
        displaySmall: _text(26, FontWeight.w700, const Color(0xFF3B2116), -0.4),
        titleLarge: _text(17, FontWeight.w800, const Color(0xFF3B2116), 0),
        titleMedium: _text(15, FontWeight.w700, const Color(0xFF3B2116), 0),
        bodyLarge: _text(15, FontWeight.w600, const Color(0xFF3B2116), 0),
        bodyMedium: _text(13, FontWeight.w500, const Color(0xFF76513E), 0),
        bodySmall: _text(12, FontWeight.w500, const Color(0xFF936F5B), 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: _font(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3B2116),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3B2116)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(205),
        hintStyle: _font(
          color: const Color(0xFF936F5B),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: _inputBorder(const Color(0xFFD9BDAA)),
        enabledBorder: _inputBorder(const Color(0xFFD9BDAA)),
        focusedBorder: _inputBorder(const Color(0xFFFF7A12), width: 1.6),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withAlpha(210),
        elevation: 0,
        shadowColor: const Color(0xFFFF7043).withAlpha(34),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFD9BDAA), width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withAlpha(190),
        selectedColor: const Color(0xFFFF7A12).withAlpha(38),
        disabledColor: const Color(0xFFF1E3D8),
        labelStyle: _font(
          color: const Color(0xFF3B2116),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: Color(0xFFD9BDAA), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF6F351F),
        contentTextStyle: _font(
          color: const Color(0xFFFFF6EC),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  static ThemeData get voxaDarkTheme {
    _prepareFonts();
    final baseTextTheme = _baseTextTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF9B6CFF),
        primaryContainer: Color(0xFF261B55),
        secondary: Color(0xFF2BB7D6),
        secondaryContainer: Color(0xFF102C46),
        tertiary: Color(0xFFC34CE8),
        surface: Color(0xFF0B0A24),
        error: Color(0xFFFF7B8E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFFFF8F1),
        outline: Color(0xFF66579A),
        outlineVariant: Color(0xFF29234E),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: _text(34, FontWeight.w800, Colors.white, -0.8),
        displayMedium: _text(30, FontWeight.w800, Colors.white, -0.6),
        displaySmall: _text(26, FontWeight.w700, Colors.white, -0.4),
        titleLarge: _text(17, FontWeight.w800, Colors.white, 0),
        titleMedium: _text(15, FontWeight.w700, Colors.white, 0),
        bodyLarge: _text(15, FontWeight.w600, const Color(0xFFFFF8F1), 0),
        bodyMedium: _text(13, FontWeight.w500, const Color(0xFFD9D0F4), 0),
        bodySmall: _text(12, FontWeight.w500, const Color(0xFFA99DCB), 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: _font(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(15),
        hintStyle: _font(
          color: const Color(0xFFA99DCB),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: _inputBorder(const Color(0xFF39305F)),
        enabledBorder: _inputBorder(const Color(0xFF39305F)),
        focusedBorder: _inputBorder(const Color(0xFF9B6CFF), width: 1.6),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xCC0B0A24),
        elevation: 0,
        shadowColor: const Color(0xFF9B6CFF).withAlpha(34),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x553E2A8A), width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withAlpha(13),
        selectedColor: const Color(0xFF9B6CFF).withAlpha(48),
        disabledColor: const Color(0xFF12102D),
        labelStyle: _font(
          color: const Color(0xFFFFF8F1),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: Color(0x553E2A8A), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF211746),
        contentTextStyle: _font(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF3B82F6),
      Color(0xFF22D3EE),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF070711),
      Color(0xFF111126),
      Color(0xFF171133),
      Color(0xFF070711),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x24FFFFFF),
      Color(0x0FFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFFD60A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color cefrLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return levelA1;
      case 'A2':
        return levelA2;
      case 'B1':
        return levelB1;
      case 'B2':
        return levelB2;
      case 'C1':
        return levelC1;
      case 'C2':
        return levelC2;
      default:
        return levelB1;
    }
  }

  static String cefrLevelName(String level) {
    switch (level.toUpperCase()) {
      case 'A1':
        return 'Beginner';
      case 'A2':
        return 'Elementary';
      case 'B1':
        return 'Intermediate';
      case 'B2':
        return 'Upper Intermediate';
      case 'C1':
        return 'Advanced';
      case 'C2':
        return 'Proficient';
      default:
        return 'Intermediate';
    }
  }

  static TextStyle _text(
    double size,
    FontWeight weight,
    Color color,
    double letterSpacing,
  ) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _font({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static OutlineInputBorder _inputBorder(
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
