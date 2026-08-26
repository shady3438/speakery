import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/speakery_theme_tokens.dart';

enum PremiumFeedbackTone { info, success, error }

class PremiumFeedback {
  const PremiumFeedback._();

  static void show(
    BuildContext context, {
    required String message,
    PremiumFeedbackTone tone = PremiumFeedbackTone.info,
    IconData? icon,
  }) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = switch (tone) {
      PremiumFeedbackTone.success => const Color(0xFF22C55E),
      PremiumFeedbackTone.error => const Color(0xFFEF4444),
      PremiumFeedbackTone.info => tokens.primaryAccent,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
          padding: EdgeInsets.zero,
          duration: const Duration(milliseconds: 2400),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: tokens.isLight
                      ? Colors.white.withAlpha(238)
                      : tokens.elevatedSurface.withAlpha(238),
                  border: Border.all(color: tokens.border),
                  boxShadow: [
                    BoxShadow(
                      color: tokens.shadow.withAlpha(tokens.isLight ? 36 : 92),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withAlpha(22),
                        border: Border.all(color: accent.withAlpha(52)),
                      ),
                      child: Icon(
                        icon ?? _iconFor(tone),
                        color: accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 12.8,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    PremiumFeedbackTone tone = PremiumFeedbackTone.info,
  }) async {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = tone == PremiumFeedbackTone.error
        ? const Color(0xFFEF4444)
        : tokens.primaryAccent;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: tokens.elevatedSurface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(color: tokens.border),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: tokens.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(cancelLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                confirmLabel,
                style: TextStyle(color: accent, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  static IconData _iconFor(PremiumFeedbackTone tone) {
    return switch (tone) {
      PremiumFeedbackTone.success => Icons.check_circle_rounded,
      PremiumFeedbackTone.error => Icons.error_rounded,
      PremiumFeedbackTone.info => Icons.auto_awesome_rounded,
    };
  }
}
