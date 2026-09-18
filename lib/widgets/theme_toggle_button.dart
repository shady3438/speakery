import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_progress.dart';
import '../theme/app_theme.dart';
import '../theme/speakery_theme_tokens.dart';
import 'ios_liquid_glass.dart';

/// Vertical space every top-level tab screen must reserve at the top of its
/// scroll content so the floating [ThemeToggleButton] (pinned by AppShell)
/// never overlaps the screen's own header.
const double kThemeToggleReserve = 60;

/// Global light/dark switch. A single tap flips the app between the light and
/// dark halves of whichever skin is selected — the brand palette or Voxa.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  void _toggle() {
    HapticFeedback.lightImpact();
    final current = AppProgress.instance.themeMode;

    // Stay inside the chosen skin. Flipping a Voxa mode straight to the brand
    // palette threw away the skin the learner picked in Settings, which is not
    // what a light/dark button is asking about.
    final next = switch (current) {
      SpeakeryThemeMode.dark => SpeakeryThemeMode.white,
      SpeakeryThemeMode.white => SpeakeryThemeMode.dark,
      SpeakeryThemeMode.voxaDark => SpeakeryThemeMode.voxaLight,
      SpeakeryThemeMode.voxaLight => SpeakeryThemeMode.voxaDark,
    };

    AppProgress.instance.setThemeMode(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final isLight = tokens.isLight;

    return GestureDetector(
      onTap: _toggle,
      child: SizedBox(
        width: 42,
        height: 42,
        child: IosLiquidGlassSurface(
          radius: 21,
          blur: 22,
          strong: true,
          accent: tokens.primaryAccent,
          padding: const EdgeInsets.all(9),
          child: SizedBox(
            width: 24,
            height: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween<double>(begin: 0.72, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isLight ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey<bool>(isLight),
                color:
                    isLight ? const Color(0xFF3B2E63) : const Color(0xFFFFC64D),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
