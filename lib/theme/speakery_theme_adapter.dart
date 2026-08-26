import 'package:flutter/material.dart';

import '../widgets/voxa_fox_motifs.dart';
import 'speakery_theme_tokens.dart';

class SpeakeryThemeAdapter extends StatelessWidget {
  final Widget child;

  const SpeakeryThemeAdapter({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (context.dependOnInheritedWidgetOfExactType<_SpeakeryThemeScope>() !=
        null) {
      return child;
    }

    final tokens = SpeakeryThemeTokens.of(context);
    final isVoxa = tokens.isVoxaTheme;
    final wallpaperAsset = tokens.isVoxaDark
        ? 'assets/images/voxa_dark_wallpaper_v1.jpg'
        : 'assets/images/voxa_light_wallpaper_v1.jpg';

    if (!tokens.isLight && !isVoxa) {
      return child;
    }

    return _SpeakeryThemeScope(
      child: ColoredBox(
        color: tokens.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
                decoration: BoxDecoration(gradient: tokens.pageGradient)),
            if (isVoxa) ...[
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: tokens.isVoxaDark ? .88 : .94,
                    child: Image.asset(
                      wallpaperAsset,
                      key: const ValueKey<String>('voxa-wallpaper-base'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      filterQuality: FilterQuality.medium,
                      cacheWidth: 1080,
                      cacheHeight: 1920,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -90,
                right: -65,
                child: _VoxaHaze(
                  size: 250,
                  color: tokens.foxAccent.withAlpha(52),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -90,
                child: _VoxaHaze(
                  size: 270,
                  color: tokens.secondaryAccent.withAlpha(34),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: VoxaAmbientIllustration(
                    primary: tokens.primaryAccent,
                    secondary: tokens.secondaryAccent,
                  ),
                ),
              ),
            ],
            child,
            if (isVoxa)
              IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: tokens.isVoxaDark ? .085 : .13,
                      child: Image.asset(
                        wallpaperAsset,
                        key: const ValueKey<String>('voxa-wallpaper-overlay'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.low,
                        cacheWidth: 1080,
                        cacheHeight: 1920,
                        gaplessPlayback: true,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tokens.foxAccent
                                .withAlpha(tokens.isVoxaDark ? 14 : 18),
                            Colors.transparent,
                            tokens.accent
                                .withAlpha(tokens.isVoxaDark ? 12 : 18),
                            tokens.secondaryAccent
                                .withAlpha(tokens.isVoxaDark ? 10 : 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeakeryThemeScope extends InheritedWidget {
  const _SpeakeryThemeScope({required super.child});

  @override
  bool updateShouldNotify(_SpeakeryThemeScope oldWidget) => false;
}

class _VoxaHaze extends StatelessWidget {
  final double size;
  final Color color;

  const _VoxaHaze({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 90,
              spreadRadius: 38,
            ),
          ],
        ),
      ),
    );
  }
}
