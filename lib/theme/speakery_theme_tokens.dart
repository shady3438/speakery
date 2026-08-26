import 'package:flutter/material.dart';

class SpeakeryThemeTokens {
  final bool isLight;
  final Color background;
  final Color backgroundEnd;
  final Color glass;
  final Color glassStrong;
  final Color elevated;
  final Color border;
  final Color shadow;
  final Color text;
  final Color mutedText;
  final Color accent;
  final Color secondaryAccent;
  final Color warmAccent;
  final Color success;
  final Color error;
  final Color warning;
  final Color warmGlow;
  final LinearGradient brandGradient;

  const SpeakeryThemeTokens({
    required this.isLight,
    required this.background,
    required this.backgroundEnd,
    required this.glass,
    required this.glassStrong,
    required this.elevated,
    required this.border,
    required this.shadow,
    required this.text,
    required this.mutedText,
    required this.accent,
    required this.secondaryAccent,
    required this.warmAccent,
    required this.success,
    required this.error,
    required this.warning,
    required this.warmGlow,
    required this.brandGradient,
  });

  LinearGradient get pageGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [background, backgroundEnd],
      );

  LinearGradient get backgroundGradient => pageGradient;
  Color get surface => elevated;
  Color get glassSurface => glass;
  Color get elevatedSurface => elevated;
  Color get cardSurface => elevated;
  Color get textPrimary => text;
  Color get textSecondary => mutedText;
  Color get textMuted => mutedText.withAlpha(isLight ? 205 : 170);
  Color get iconPrimary => textPrimary;
  Color get iconSecondary => textSecondary;
  Color get primaryAccent => accent;
  Color get secondaryAccentColor => secondaryAccent;
  Color get chipSurface => isLight ? Colors.white.withAlpha(150) : glass;
  Color get chipSelected =>
      isLight ? accent.withAlpha(24) : accent.withAlpha(46);
  Color get inputSurface =>
      isLight ? Colors.white.withAlpha(154) : Colors.white.withAlpha(16);
  Color get navGlass =>
      isLight ? Colors.white.withAlpha(112) : Colors.white.withAlpha(28);
  Color get navActive =>
      isLight ? accent.withAlpha(24) : Colors.white.withAlpha(58);
  Color get foxAccent => warmAccent;
  Color get iconOnAccent => Colors.white;
  bool get isVoxaTheme =>
      accent == const Color(0xFF9B6CFF) ||
      accent == const Color(0xFFFF7A12) ||
      accent == const Color(0xFFF97316) ||
      accent == const Color(0xFFFF7043) ||
      accent == const Color(0xFFFF8A3D);
  bool get isVoxaDark => isVoxaTheme && !isLight;

  LinearGradient get glassGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [glassStrong, glass, elevated.withAlpha(isLight ? 120 : 24)],
      );

  Color surfaceForAccent(Color accent) {
    return isLight ? Colors.white.withAlpha(142) : accent.withAlpha(18);
  }

  Color adaptAccent(Color requested, {int slot = 0}) {
    if (!isVoxaTheme) return requested;

    final hue = HSLColor.fromColor(requested).hue;
    if (isVoxaDark) {
      if (hue >= 300 || hue < 20) return warmAccent;
      if (hue >= 160 && hue <= 245) return secondaryAccent;
      return slot.isEven ? accent : warmAccent;
    }
    if (hue >= 18 && hue <= 62) {
      return hue < 34 ? accent : warmAccent;
    }
    if (hue >= 330 || hue < 18) return secondaryAccent;
    return slot.isEven ? accent : secondaryAccent;
  }

  static SpeakeryThemeTokens of(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final isVoxa = colors.primary == const Color(0xFFFF7A12) ||
        colors.primary == const Color(0xFF9B6CFF) ||
        colors.primary == const Color(0xFFF97316) ||
        colors.primary == const Color(0xFFFF5C7A) ||
        colors.primary == const Color(0xFFFF8A3D) ||
        colors.primary == const Color(0xFFFF7043);

    if (isLight && !isVoxa) {
      return const SpeakeryThemeTokens(
        isLight: true,
        background: Color(0xFFF6F8FF),
        backgroundEnd: Color(0xFFECEFFD),
        glass: Color(0x9EFFFFFF),
        glassStrong: Color(0xC4FFFFFF),
        elevated: Color(0xD9FFFFFF),
        border: Color(0xB8FFFFFF),
        shadow: Color(0x220B1020),
        text: Color(0xFF171427),
        mutedText: Color(0xFF554F68),
        accent: Color(0xFF7C3AED),
        secondaryAccent: Color(0xFF3B82F6),
        warmAccent: Color(0xFFFF8A3D),
        success: Color(0xFF059669),
        error: Color(0xFFDC2626),
        warning: Color(0xFFD97706),
        warmGlow: Color(0x29FF8A3D),
        brandGradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
      );
    }

    if (isVoxa && isLight) {
      return const SpeakeryThemeTokens(
        isLight: true,
        background: Color(0xFFFFF9F2),
        backgroundEnd: Color(0xFFFFE9D6),
        glass: Color(0xD9FFFFFF),
        glassStrong: Color(0xF2FFFFFF),
        elevated: Color(0xFAFFFCF8),
        border: Color(0x3D8A4A20),
        shadow: Color(0x245C321D),
        text: Color(0xFF3B2116),
        mutedText: Color(0xFF76503A),
        accent: Color(0xFFFF7A12),
        secondaryAccent: Color(0xFF8A4A20),
        warmAccent: Color(0xFFFF9A3D),
        success: Color(0xFFB85C24),
        error: Color(0xFFB42318),
        warning: Color(0xFFD96A10),
        warmGlow: Color(0x30FF9A3D),
        brandGradient: LinearGradient(
          colors: [
            Color(0xFFB85A20),
            Color(0xFFFF7A12),
            Color(0xFFFFA14D),
          ],
        ),
      );
    }

    if (isVoxa) {
      return const SpeakeryThemeTokens(
        isLight: false,
        background: Color(0xFF030617),
        backgroundEnd: Color(0xFF0B0825),
        glass: Color(0x241B1640),
        glassStrong: Color(0x3D251C55),
        elevated: Color(0xD90B0A24),
        border: Color(0x604D3D91),
        shadow: Color(0xA8000000),
        text: Color(0xFFFFF8F1),
        mutedText: Color(0xFFD9D0F4),
        accent: Color(0xFF9B6CFF),
        secondaryAccent: Color(0xFF2BB7D6),
        warmAccent: Color(0xFFC34CE8),
        success: Color(0xFF64D9A2),
        error: Color(0xFFFF7B8E),
        warning: Color(0xFFFFA04D),
        warmGlow: Color(0x309B6CFF),
        brandGradient: LinearGradient(
          colors: [
            Color(0xFF2B63C7),
            Color(0xFF7141D8),
            Color(0xFFC23DD0),
          ],
        ),
      );
    }

    return const SpeakeryThemeTokens(
      isLight: false,
      background: Color(0xFF050710),
      backgroundEnd: Color(0xFF090D1C),
      glass: Color(0x18FFFFFF),
      glassStrong: Color(0x26FFFFFF),
      elevated: Color(0xFF0B1020),
      border: Color(0x33FFFFFF),
      shadow: Color(0x77000000),
      text: Colors.white,
      mutedText: Color(0xFFC9C7E8),
      accent: Color(0xFF8B5CF6),
      secondaryAccent: Color(0xFF3B82F6),
      warmAccent: Color(0xFFFF4FD8),
      success: Color(0xFF22C55E),
      error: Color(0xFFF87171),
      warning: Color(0xFFFFB020),
      warmGlow: Color(0x18FF4FD8),
      brandGradient: LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
      ),
    );
  }
}
