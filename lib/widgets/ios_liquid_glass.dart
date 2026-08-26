import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/speakery_theme_tokens.dart';
import 'voxa_fox_motifs.dart';

class IosLiquidMotion {
  const IosLiquidMotion._();

  static const entrance = Duration(milliseconds: 560);
  static const quick = Duration(milliseconds: 220);
  static const settle = Duration(milliseconds: 420);
  static const expressive = Duration(milliseconds: 680);
  static const ambient = Duration(seconds: 11);

  static const Curve press = Curves.easeOutCubic;
  static const Curve release = Curves.easeOutBack;
  static const Curve settleCurve = Curves.easeOutCubic;
  static const Curve selectedCurve = Curves.easeInOutCubicEmphasized;

  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

class IosLiquidGlassSurface extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color? accent;
  final Gradient? gradient;
  final Color? borderColor;
  final double blur;
  final bool strong;

  const IosLiquidGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
    this.radius = 28,
    this.accent,
    this.gradient,
    this.borderColor,
    this.blur = 24,
    this.strong = false,
  });

  @override
  State<IosLiquidGlassSurface> createState() => _IosLiquidGlassSurfaceState();
}

class _IosLiquidGlassSurfaceState extends State<IosLiquidGlassSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheenController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: IosLiquidMotion.ambient,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = IosLiquidMotion.reduce(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _sheenController.stop();
      _sheenController.value = .18;
    } else if (!_sheenController.isAnimating) {
      _sheenController.repeat();
    }
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final reduceMotion = IosLiquidMotion.reduce(context);
    final radius = math
        .min(widget.radius, screenWidth < 360 ? 24.0 : widget.radius)
        .toDouble();
    final blur =
        (screenWidth < 360 ? math.max(16.0, widget.blur - 4) : widget.blur)
            .toDouble();
    final tint = tokens.adaptAccent(widget.accent ?? tokens.primaryAccent);
    final strong = widget.strong;
    final surfaceGradient = widget.gradient ??
        (tokens.isVoxaDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF21194A).withAlpha(strong ? 205 : 155),
                  const Color(0xFF100D2E).withAlpha(strong ? 222 : 178),
                  Color.alphaBlend(
                    tint.withAlpha(strong ? 30 : 18),
                    const Color(0xFF07091D).withAlpha(strong ? 232 : 188),
                  ),
                ],
                stops: const [0, .56, 1],
              )
            : tokens.isVoxaTheme
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withAlpha(strong ? 246 : 226),
                      const Color(0xFFFFFAF4).withAlpha(strong ? 236 : 208),
                      const Color(0xFFFFE9D6).withAlpha(strong ? 182 : 136),
                    ],
                    stops: const [0, .62, 1],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: tokens.isLight
                        ? [
                            Colors.white.withAlpha(strong ? 168 : 116),
                            Color.alphaBlend(
                              tint.withAlpha(strong ? 20 : 12),
                              Colors.white.withAlpha(strong ? 132 : 86),
                            ),
                            const Color(0xFFE9EEFF)
                                .withAlpha(strong ? 116 : 68),
                          ]
                        : [
                            Colors.white.withAlpha(strong ? 30 : 18),
                            tint.withAlpha(strong ? 21 : 12),
                            Colors.white.withAlpha(strong ? 12 : 6),
                          ],
                    stops: const [0, .54, 1],
                  ));

    final surface = Container(
      width: double.infinity,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: tokens.isVoxaTheme
                ? (tokens.isVoxaDark
                    ? tokens.warmAccent.withAlpha(strong ? 34 : 22)
                    : tokens.secondaryAccent.withAlpha(strong ? 25 : 16))
                : tokens.isLight
                    ? const Color(0xFF20304A).withAlpha(strong ? 26 : 18)
                    : Colors.black.withAlpha(strong ? 92 : 70),
            blurRadius: strong ? 30 : 22,
            spreadRadius: -3,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: tint.withAlpha(tokens.isLight ? 16 : 25),
            blurRadius: strong ? 30 : 22,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: AnimatedBuilder(
            animation: _sheenController,
            builder: (context, _) {
              final phase = reduceMotion ? .18 : _sheenController.value;
              final drift = math.sin(phase * math.pi * 2);
              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        gradient: surfaceGradient,
                        border: Border.all(
                          color: widget.borderColor ??
                              (tokens.isVoxaTheme
                                  ? (tokens.isVoxaDark
                                      ? Color.alphaBlend(
                                          tokens.secondaryAccent
                                              .withAlpha(strong ? 66 : 42),
                                          tokens.primaryAccent
                                              .withAlpha(strong ? 48 : 30),
                                        )
                                      : tokens.secondaryAccent
                                          .withAlpha(strong ? 42 : 29))
                                  : tokens.isLight
                                      ? Colors.white
                                          .withAlpha(strong ? 190 : 145)
                                      : Colors.white
                                          .withAlpha(strong ? 55 : 37)),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          gradient: LinearGradient(
                            begin: Alignment(-1.1 + drift * .18, -1),
                            end: Alignment(.92 + drift * .14, .95),
                            colors: [
                              Colors.white.withAlpha(tokens.isLight
                                  ? (strong ? 72 : 46)
                                  : (strong ? 28 : 16)),
                              Colors.transparent,
                              tint.withAlpha(tokens.isLight
                                  ? (strong ? 16 : 10)
                                  : (strong ? 20 : 12)),
                              Colors.transparent,
                            ],
                            stops: const [0, .27, .62, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: radius * .55,
                    right: radius * .55,
                    top: 0,
                    child: Transform.translate(
                      offset: Offset(drift * 10, 0),
                      child: Container(
                        height: 1.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white
                                  .withAlpha(tokens.isLight ? 250 : 118),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -radius * 1.3,
                    left: -radius * .7 + drift * 7,
                    child: IgnorePointer(
                      child: Container(
                        width: radius * 4.2,
                        height: radius * 2.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withAlpha(tokens.isLight ? 158 : 34),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (tokens.isVoxaTheme)
                    Positioned.fill(
                      child: VoxaFoxPatternLayer(
                        color: tokens.isVoxaDark
                            ? tokens.warmAccent
                            : tokens.secondaryAccent,
                        opacity: tokens.isVoxaDark
                            ? (strong ? .05 : .028)
                            : (strong ? .025 : .016),
                        spacing: strong ? 154 : 176,
                      ),
                    ),
                  if (tokens.isVoxaTheme)
                    Positioned(
                      right: 9,
                      bottom: 7,
                      child: VoxaFoxGlyph(
                        size: strong ? 34 : 25,
                        color: (tokens.isVoxaDark
                                ? tokens.warmAccent
                                : tokens.primaryAccent)
                            .withAlpha(strong ? 48 : 30),
                        fillColor: Colors.transparent,
                        showTail: true,
                      ),
                    ),
                  Padding(padding: widget.padding, child: widget.child),
                ],
              );
            },
          ),
        ),
      ),
    );
    if (reduceMotion) return surface;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: .972, end: 1),
      duration: strong ? IosLiquidMotion.expressive : IosLiquidMotion.entrance,
      curve: IosLiquidMotion.settleCurve,
      child: surface,
      builder: (context, value, child) {
        final easedOpacity = ((value - .972) / .028).clamp(.0, 1.0).toDouble();
        return Opacity(
          opacity: easedOpacity,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: Transform.scale(
              scale: value,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class IosPillItem {
  final String label;
  final IconData? icon;

  const IosPillItem(this.label, {this.icon});
}

class IosLiquidPillSelector extends StatelessWidget {
  final List<IosPillItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color startColor;
  final Color endColor;
  final List<Color>? itemColors;
  final double height;
  final EdgeInsetsGeometry margin;

  const IosLiquidPillSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    required this.startColor,
    required this.endColor,
    this.itemColors,
    this.height = 38,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final tokens = SpeakeryThemeTokens.of(context);
    final safeIndex = selectedIndex.clamp(0, items.length - 1);
    final hasItemColors =
        itemColors != null && itemColors!.length == items.length;
    final effectiveStartColor = tokens.adaptAccent(startColor);
    final effectiveEndColor = tokens.adaptAccent(endColor, slot: 1);
    final effectiveItemColors = hasItemColors
        ? List<Color>.generate(
            items.length,
            (index) => tokens.adaptAccent(itemColors![index], slot: index),
          )
        : null;
    final selectedColor =
        hasItemColors ? effectiveItemColors![safeIndex] : effectiveStartColor;
    final selectedEndColor = hasItemColors
        ? Color.lerp(selectedColor, Colors.white, tokens.isLight ? .15 : .08)!
        : effectiveEndColor;

    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: height,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tokens.isLight
                    ? [
                        Colors.white.withAlpha(158),
                        (tokens.isVoxaTheme
                                ? const Color(0xFFFFF0DF)
                                : const Color(0xFFEFF3FF))
                            .withAlpha(92),
                      ]
                    : [
                        Colors.white.withAlpha(19),
                        Colors.white.withAlpha(6),
                      ],
              ),
              border: Border.all(
                color: tokens.isLight
                    ? Color.alphaBlend(
                        effectiveStartColor.withAlpha(24),
                        tokens.border,
                      )
                    : Colors.white.withAlpha(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadow.withAlpha(tokens.isLight ? 24 : 62),
                  blurRadius: 18,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedAlign(
                  duration: IosLiquidMotion.settle,
                  curve: IosLiquidMotion.selectedCurve,
                  alignment: Alignment(
                    items.length == 1
                        ? 0
                        : -1 + (safeIndex * 2 / (items.length - 1)),
                    0,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1 / items.length,
                    heightFactor: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: AnimatedContainer(
                        duration: IosLiquidMotion.settle,
                        curve: IosLiquidMotion.selectedCurve,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.alphaBlend(
                                selectedColor
                                    .withAlpha(tokens.isLight ? 172 : 154),
                                Colors.white.withAlpha(tokens.isLight ? 42 : 8),
                              ),
                              selectedEndColor
                                  .withAlpha(tokens.isLight ? 158 : 142),
                            ],
                          ),
                          border:
                              Border.all(color: Colors.white.withAlpha(132)),
                          boxShadow: [
                            BoxShadow(
                              color: selectedColor.withAlpha(54),
                              blurRadius: 16,
                              spreadRadius: -2,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.white.withAlpha(54),
                              blurRadius: 7,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final selected = index == safeIndex;
                    return Expanded(
                      child: _PillTapTarget(
                        onTap: () => onChanged(index),
                        child: AnimatedScale(
                          scale: selected ? 1.035 : .98,
                          duration: IosLiquidMotion.quick,
                          curve: IosLiquidMotion.release,
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: IosLiquidMotion.quick,
                              curve: IosLiquidMotion.settleCurve,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : hasItemColors
                                        ? effectiveItemColors![index].withAlpha(
                                            tokens.isLight ? 215 : 190,
                                          )
                                        : tokens.textSecondary,
                                fontSize: 10.7,
                                height: 1,
                                fontWeight: selected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                letterSpacing: selected ? .02 : -.05,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.icon != null) ...[
                                    Icon(
                                      item.icon,
                                      color: selected
                                          ? Colors.white
                                          : hasItemColors
                                              ? effectiveItemColors![index]
                                                  .withAlpha(
                                                  tokens.isLight ? 215 : 190,
                                                )
                                              : tokens.iconSecondary,
                                      size: selected ? 13.5 : 13,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Flexible(
                                    child: Text(
                                      item.label,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IosLiquidSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const IosLiquidSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF34C759),
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final effectiveActiveColor = tokens.adaptAccent(activeColor);
    return _PillTapTarget(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: IosLiquidMotion.settle,
        curve: IosLiquidMotion.selectedCurve,
        width: 54,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: value
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveActiveColor,
                    Color.lerp(effectiveActiveColor, Colors.white, .24)!,
                  ],
                )
              : LinearGradient(
                  colors: [
                    tokens.inputSurface,
                    tokens.glassSurface,
                  ],
                ),
          border: Border.all(
            color: value
                ? Colors.white.withAlpha(92)
                : tokens.border.withAlpha(220),
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: effectiveActiveColor.withAlpha(72),
                    blurRadius: 18,
                    spreadRadius: -2,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: IosLiquidMotion.expressive,
          curve: IosLiquidMotion.release,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedScale(
            duration: IosLiquidMotion.quick,
            curve: IosLiquidMotion.release,
            scale: value ? 1.03 : .98,
            child: AnimatedContainer(
              duration: IosLiquidMotion.settle,
              curve: IosLiquidMotion.selectedCurve,
              width: value ? 27 : 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFE7ECF7)],
                ),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(42),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  if (value)
                    BoxShadow(
                      color: Colors.white.withAlpha(80),
                      blurRadius: 7,
                      offset: const Offset(0, -1),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IosDynamicGlassBackdrop extends StatefulWidget {
  final Widget child;
  final Color primary;
  final Color secondary;

  const IosDynamicGlassBackdrop({
    super.key,
    required this.child,
    required this.primary,
    required this.secondary,
  });

  @override
  State<IosDynamicGlassBackdrop> createState() =>
      _IosDynamicGlassBackdropState();
}

class _IosDynamicGlassBackdropState extends State<IosDynamicGlassBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller.stop();
      _controller.value = .18;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: tokens.pageGradient)),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final phase = _controller.value * math.pi * 2;
            final slowPhase = phase * .72;
            final breathe = .92 + math.sin(slowPhase) * .035;
            return IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    left: -112 + math.sin(phase) * 54,
                    top: -92 + math.cos(slowPhase) * 38,
                    child: Transform.scale(
                      scale: breathe,
                      child: _AnimatedHaze(
                        color: widget.primary,
                        size: 330,
                        alpha: tokens.isLight ? 35 : 46,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -142 + math.cos(slowPhase) * 58,
                    top: 172 + math.sin(phase) * 52,
                    child: Transform.scale(
                      scale: 1.04 - math.sin(phase) * .035,
                      child: _AnimatedHaze(
                        color: widget.secondary,
                        size: 360,
                        alpha: tokens.isLight ? 29 : 40,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 80 + math.cos(phase + 1.7) * 36,
                    bottom: -170 + math.sin(slowPhase + .4) * 42,
                    child: _AnimatedHaze(
                      color: Color.lerp(
                        widget.primary,
                        widget.secondary,
                        .5 + math.sin(phase) * .18,
                      )!,
                      size: 360,
                      alpha: tokens.isLight ? 18 : 28,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _AnimatedHaze extends StatelessWidget {
  final Color color;
  final double size;
  final int alpha;

  const _AnimatedHaze({
    required this.color,
    required this.size,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withAlpha(alpha), Colors.transparent],
        ),
      ),
    );
  }
}

class _PillTapTarget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PillTapTarget({required this.child, required this.onTap});

  @override
  State<_PillTapTarget> createState() => _PillTapTargetState();
}

class _PillTapTargetState extends State<_PillTapTarget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .94 : 1,
        duration: IosLiquidMotion.quick,
        curve: _pressed ? IosLiquidMotion.press : IosLiquidMotion.release,
        child: widget.child,
      ),
    );
  }
}
