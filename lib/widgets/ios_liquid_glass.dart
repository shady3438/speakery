import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/speakery_theme_tokens.dart';
import 'liquid_glass_refraction.dart';
import 'voxa_fox_motifs.dart';

class IosLiquidMotion {
  const IosLiquidMotion._();

  static const entrance = Duration(milliseconds: 640);
  static const quick = Duration(milliseconds: 220);
  static const settle = Duration(milliseconds: 420);
  static const expressive = Duration(milliseconds: 760);
  static const ambient = Duration(seconds: 11);

  /// Pointer enter/leave easing for the glass lift.
  static const hover = Duration(milliseconds: 420);
  static const hoverOut = Duration(milliseconds: 560);

  /// One full trip of the blue/violet rim light around a card.
  static const orbit = Duration(seconds: 9);

  static const Curve press = Curves.easeOutCubic;
  static const Curve release = Curves.easeOutBack;
  static const Curve settleCurve = Curves.easeOutCubic;
  static const Curve selectedCurve = Curves.easeInOutCubicEmphasized;

  /// Long, soft deceleration used by glass surfaces.
  static const Curve glass = Curves.easeOutQuart;

  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

/// Saturation (and a whisper of lift) applied to whatever sits behind a glass
/// pane, mirroring the vibrancy pass iOS runs under its material.
ColorFilter _vibrancy(bool isLight) {
  const double s = 1.42;
  const double lr = 0.213, lg = 0.715, lb = 0.072;
  final double b = isLight ? 6 : 2; // tiny brightness lift
  return ColorFilter.matrix(<double>[
    lr + s * (1 - lr), lg - s * lg, lb - s * lb, 0, b,
    lr - s * lr, lg + s * (1 - lg), lb - s * lb, 0, b,
    lr - s * lr, lg - s * lg, lb + s * (1 - lb), 0, b,
    0, 0, 0, 1, 0,
  ]);
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

  /// Pointer-reactive lift, cursor-tracked specular and a brighter rim light.
  /// Turn it off for tiny decorative chips that should stay perfectly still.
  final bool interactive;

  /// The thin blue/violet light that travels around the edge.
  final bool rimLight;

  /// Sample and blur what is behind the pane with a real [BackdropFilter].
  ///
  /// This is by far the most expensive thing a glass surface can do: each one
  /// forces its own backdrop snapshot, and a screen carrying a dozen cards pays
  /// for a dozen of them every frame. Over the app's smooth page gradient a
  /// blurred backdrop is nearly indistinguishable from a translucent fill, so
  /// panes stay unblurred by default and only surfaces that genuinely sit over
  /// moving content — sheets, bars, overlays — should ask for it.
  final bool blurBackdrop;

  const IosLiquidGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin = EdgeInsets.zero,
    this.radius = 28,
    this.accent,
    this.gradient,
    this.borderColor,
    this.blur = 28,
    this.strong = false,
    this.interactive = true,
    this.rimLight = true,
    this.blurBackdrop = false,
  });

  @override
  State<IosLiquidGlassSurface> createState() => _IosLiquidGlassSurfaceState();
}

class _IosLiquidGlassSurfaceState extends State<IosLiquidGlassSurface>
    with TickerProviderStateMixin {
  /// Drives the rim light orbit and the slow specular drift.
  late final AnimationController _orbit;

  /// 0 = resting, 1 = pointer is over the surface.
  late final AnimationController _lift;

  /// Cursor position in local coordinates; null when the pointer is away.
  final ValueNotifier<Offset?> _pointer = ValueNotifier<Offset?>(null);

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: IosLiquidMotion.orbit,
    );
    _lift = AnimationController(
      vsync: this,
      duration: IosLiquidMotion.hover,
      reverseDuration: IosLiquidMotion.hoverOut,
    )..addListener(_syncOrbit);
  }

  /// The rim light only travels while a pane is engaged. At rest it is a still,
  /// even wash, which leaves an idle screen with no repainting surfaces at all —
  /// a list of sixty cards each ticking its own orbit is pure wasted frames.
  void _syncOrbit() {
    final engaged = _lift.value > .001;
    if (engaged && !_orbit.isAnimating && !_reduceMotion) {
      _orbit.repeat();
    } else if (!engaged && _orbit.isAnimating) {
      _orbit.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = IosLiquidMotion.reduce(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _orbit.stop();
      _orbit.value = .18;
    } else {
      _syncOrbit();
    }
  }

  @override
  void dispose() {
    _orbit.dispose();
    _lift.dispose();
    _pointer.dispose();
    _refractShader?.dispose();
    super.dispose();
  }

  // ── True edge refraction (Impeller only) ──────────────────────────────────
  FragmentShader? _refractShader;
  ImageFilter? _refractFilter;
  double? _refractRadius;
  Size? _refractSeed;
  double? _refractRatio;

  /// Rebuilds the refraction filter only when its configuration changes, so a
  /// scrolling list is not allocating shaders every frame.
  ///
  /// The filter runs over the backdrop *texture*, so every length handed to it
  /// has to be in physical pixels — logical units would make the corner radius
  /// and the bend roughly three times too small on a 3x screen.
  ImageFilter? _refractionFilter(
    double radius,
    Size screen,
    double ratio,
    bool strong,
  ) {
    if (!LiquidGlassRefraction.isReady) return null;
    if (_refractFilter != null &&
        _refractRadius == radius &&
        _refractSeed == screen &&
        _refractRatio == ratio) {
      return _refractFilter;
    }
    _refractShader?.dispose();
    _refractShader = LiquidGlassRefraction.shaderFor(
      size: screen * ratio,
      radius: radius * ratio,
      refraction: (strong ? 10 : 7.5) * ratio,
      dispersion: (strong ? 3.2 : 2.4) * ratio,
      band: math.max(radius * 1.7, 20) * ratio,
    );
    final shader = _refractShader;
    _refractFilter =
        shader == null ? null : LiquidGlassRefraction.filterFor(shader);
    _refractRadius = radius;
    _refractSeed = screen;
    _refractRatio = ratio;
    return _refractFilter;
  }

  void _enter(PointerEnterEvent event) {
    if (!widget.interactive) return;
    _pointer.value = event.localPosition;
    _lift.forward();
  }

  void _move(PointerHoverEvent event) {
    if (!widget.interactive) return;
    _pointer.value = event.localPosition;
  }

  void _exit(PointerExitEvent event) {
    if (!widget.interactive) return;
    _pointer.value = null;
    _lift.reverse();
  }

  // Touch equivalent of hover. A Listener only observes pointers, so it never
  // competes with the taps and scrolls the card already handles.
  void _touchDown(PointerDownEvent event) {
    if (!widget.interactive || event.kind == PointerDeviceKind.mouse) return;
    _pointer.value = event.localPosition;
    _lift.forward();
  }

  void _touchMove(PointerMoveEvent event) {
    if (!widget.interactive || event.kind == PointerDeviceKind.mouse) return;
    _pointer.value = event.localPosition;
  }

  void _touchRelease(PointerEvent event) {
    if (!widget.interactive || event.kind == PointerDeviceKind.mouse) return;
    _pointer.value = null;
    _lift.reverse();
  }

  /// Wraps [child] in a real backdrop blur only when this pane asked for one.
  ///
  /// The blur, the edge refraction and the vibrancy pass all ride on the same
  /// backdrop snapshot, so they are built together and skipped together.
  Widget _withBackdrop({
    required SpeakeryThemeTokens tokens,
    required double blur,
    required double radius,
    required bool strong,
    required Widget child,
  }) {
    if (!widget.blurBackdrop) return child;

    // Blur → bend the rim (device only) → lift saturation, the way real glass
    // behaves. Where the shader is unavailable the chain simply loses its
    // middle link and the painted bevel carries the effect on its own.
    ImageFilter backdrop = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    final refraction = _refractionFilter(
      radius,
      MediaQuery.sizeOf(context),
      MediaQuery.devicePixelRatioOf(context),
      strong,
    );
    if (refraction != null) {
      backdrop = ImageFilter.compose(outer: refraction, inner: backdrop);
    }
    backdrop = ImageFilter.compose(
      outer: _vibrancy(tokens.isLight),
      inner: backdrop,
    );
    return BackdropFilter(filter: backdrop, child: child);
  }

  LinearGradient _fill(SpeakeryThemeTokens tokens, Color tint, bool strong) {
    if (tokens.isVoxaDark) {
      return LinearGradient(
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
      );
    }
    if (tokens.isVoxaTheme) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withAlpha(strong ? 240 : 218),
          const Color(0xFFFFFAF4).withAlpha(strong ? 228 : 198),
          const Color(0xFFFFE9D6).withAlpha(strong ? 172 : 126),
        ],
        stops: const [0, .62, 1],
      );
    }
    // Default brand glass. The tint is deliberately faint: Liquid Glass reads
    // as a lens, so what is behind the pane must stay visible. The sense of
    // "glass" comes from the bevel and edge dispersion, not from white paint.
    // With no blur pass behind it the pane needs a little more body of its own
    // to still read as a surface rather than a bare outline.
    final int body = widget.blurBackdrop ? 0 : (tokens.isLight ? 16 : 8);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: tokens.isLight
          ? [
              Colors.white.withAlpha((strong ? 66 : 44) + body),
              Color.alphaBlend(
                tint.withAlpha(strong ? 20 : 14),
                Colors.white.withAlpha((strong ? 48 : 30) + body),
              ),
              const Color(0xFFDCE8FF).withAlpha((strong ? 44 : 30) + body),
            ]
          : [
              Colors.white.withAlpha((strong ? 26 : 15) + body),
              tint.withAlpha(strong ? 20 : 11),
              Colors.white.withAlpha((strong ? 10 : 5) + body),
            ],
      stops: const [0, .54, 1],
    );
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
    final isVoxa = tokens.isVoxaTheme;
    final surfaceGradient = widget.gradient ?? _fill(tokens, tint, strong);

    // The travelling edge light: brand blue into brand violet, or the warm
    // Voxa pair when that skin is active.
    final rimStart = isVoxa ? tokens.secondaryAccent : const Color(0xFF4C8DFF);
    final rimEnd = isVoxa ? tokens.warmAccent : const Color(0xFF9B6BFF);

    final lights = Listenable.merge([_orbit, _lift, _pointer]);


    final glass = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: _withBackdrop(
        tokens: tokens,
        blur: blur,
        radius: radius,
        strong: strong,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: surfaceGradient,
                ),
              ),
            ),
            // Specular sheen, cursor bloom and glass thickness. Painted, so a
            // moving pointer never rebuilds the card's content.
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _GlassInnerLights(
                      repaint: lights,
                      orbit: _orbit,
                      lift: _lift,
                      pointer: _pointer,
                      radius: radius,
                      tint: tint,
                      isLight: tokens.isLight,
                      strong: strong,
                      reduceMotion: reduceMotion,
                    ),
                  ),
                ),
              ),
            ),
            if (isVoxa)
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
            if (isVoxa)
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
        ),
      ),
    );

    // The rim sits above the clip so its halo can spill outside the card.
    final framed = Stack(
      children: [
        glass,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _GlassRimLight(
                  repaint: lights,
                  orbit: _orbit,
                  lift: _lift,
                  radius: radius,
                  rimStart: rimStart,
                  rimEnd: rimEnd,
                  hairline: widget.borderColor,
                  isLight: tokens.isLight,
                  strong: strong,
                  enabled: widget.rimLight,
                  reduceMotion: reduceMotion,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final hoverable = widget.interactive
        ? Listener(
            onPointerDown: _touchDown,
            onPointerMove: _touchMove,
            onPointerUp: _touchRelease,
            onPointerCancel: _touchRelease,
            child: MouseRegion(
              onEnter: _enter,
              onHover: _move,
              onExit: _exit,
              child: framed,
            ),
          )
        : framed;

    final surface = AnimatedBuilder(
      animation: _lift,
      child: hoverable,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_lift.value.clamp(0.0, 1.0));
        final baseShadow = isVoxa
            ? (tokens.isVoxaDark
                ? tokens.warmAccent.withAlpha(strong ? 34 : 22)
                : tokens.secondaryAccent.withAlpha(strong ? 25 : 16))
            : tokens.isLight
                ? const Color(0xFF1D2C4A).withAlpha(strong ? 24 : 16)
                : Colors.black.withAlpha(strong ? 92 : 70);

        return Transform.translate(
          offset: Offset(0, -4 * t),
          child: Transform.scale(
            scale: 1 + .016 * t,
            child: Container(
              width: double.infinity,
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: baseShadow.withAlpha(
                      (baseShadow.a * 255 * (1 + .55 * t)).round().clamp(0, 255),
                    ),
                    blurRadius: (strong ? 30 : 22) + 16 * t,
                    spreadRadius: -3,
                    offset: Offset(0, 14 + 6 * t),
                  ),
                  BoxShadow(
                    color: tint.withAlpha(
                      ((tokens.isLight ? 16 : 25) + 18 * t).round(),
                    ),
                    blurRadius: (strong ? 30 : 22) + 14 * t,
                    spreadRadius: -5,
                    offset: Offset(0, 8 + 4 * t),
                  ),
                  if (t > .01)
                    BoxShadow(
                      color: rimEnd.withAlpha((26 * t).round()),
                      blurRadius: 30 + 14 * t,
                      spreadRadius: -6,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );

    if (reduceMotion) return surface;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: strong ? IosLiquidMotion.expressive : IosLiquidMotion.entrance,
      curve: IosLiquidMotion.glass,
      child: surface,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: Transform.scale(
              scale: .988 + .012 * value,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Everything that lives *inside* the glass: the drifting specular band, the
/// soft crown bloom, the cursor highlight and the bottom thickness shade.
///
/// Every gradient fades to `sameColor.withAlpha(0)` rather than
/// [Colors.transparent] — fading to transparent *black* is what produced the
/// grey smear across the top of light-mode cards.
class _GlassInnerLights extends CustomPainter {
  final Animation<double> orbit;
  final Animation<double> lift;
  final ValueNotifier<Offset?> pointer;
  final double radius;
  final Color tint;
  final bool isLight;
  final bool strong;
  final bool reduceMotion;

  _GlassInnerLights({
    required Listenable repaint,
    required this.orbit,
    required this.lift,
    required this.pointer,
    required this.radius,
    required this.tint,
    required this.isLight,
    required this.strong,
    required this.reduceMotion,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.save();
    canvas.clipRRect(rrect);

    final phase = (reduceMotion ? .18 : orbit.value) * math.pi * 2;
    final drift = math.sin(phase * .5);
    final t = Curves.easeOutCubic.transform(lift.value.clamp(0.0, 1.0));

    // 0. Frost — the whole pane brightens while the pointer rests on it, so the
    // card being pointed at is unmistakable.
    if (t > .01) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.white.withAlpha(((isLight ? 30 : 20) * t).round()),
      );
    }

    // 1. Slow specular band sliding across the pane.
    final bandAlpha = (isLight ? (strong ? 40 : 28) : (strong ? 26 : 16)) +
        (16 * t).round();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(-1.15 + drift * .22, -1),
          end: Alignment(.95 + drift * .18, 1),
          colors: [
            Colors.white.withAlpha(bandAlpha),
            Colors.white.withAlpha(0),
            tint.withAlpha((isLight ? 13 : 18) + (10 * t).round()),
            tint.withAlpha(0),
          ],
          stops: const [0, .34, .6, 1],
        ).createShader(rect),
    );

    // 2. Crown bloom — kept faint. Liquid Glass gets its read from the bevel,
    // not from a milky wash across the top.
    final bloomAlpha =
        (isLight ? (strong ? 16 : 11) : (strong ? 15 : 10)) + (12 * t).round();
    final bloomCenter = Offset(
      size.width * (.34 + drift * .1),
      -radius * .25,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha(bloomAlpha),
            Colors.white.withAlpha(0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: bloomCenter,
            radius: math.max(size.width, size.height) * .62,
          ),
        ),
    );

    // 3. Cursor-tracked specular — the "liquid" part of liquid glass.
    final cursor = pointer.value;
    if (cursor != null && t > .01) {
      final reach = math.max(size.shortestSide * .95, 130.0);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withAlpha(((isLight ? 96 : 62) * t).round()),
              Colors.white.withAlpha(0),
            ],
            stops: const [0, 1],
          ).createShader(Rect.fromCircle(center: cursor, radius: reach)),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              tint.withAlpha(((isLight ? 42 : 48) * t).round()),
              tint.withAlpha(0),
            ],
          ).createShader(
            Rect.fromCircle(center: cursor, radius: reach * .58),
          ),
      );
    }

    // 4. Bottom shade — gives the pane a sense of thickness.
    final shadeHeight = math.min(size.height * .3, 16.0);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - shadeHeight, size.width, shadeHeight),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isLight
              ? [
                  const Color(0xFF7C8EB4).withAlpha(0),
                  const Color(0xFF7C8EB4).withAlpha(strong ? 10 : 7),
                ]
              : [
                  const Color(0xFF05070F).withAlpha(0),
                  const Color(0xFF05070F).withAlpha(strong ? 22 : 15),
                ],
        ).createShader(
          Rect.fromLTWH(0, size.height - shadeHeight, size.width, shadeHeight),
        ),
    );

    // 5. The bevel — the lit inner wall of the pane. This is what sells the
    // "slab of glass" read: a bright lip where light enters at the top-left, a
    // weaker return highlight at the bottom-right, and a thin shaded wall just
    // inside both so the pane has measurable thickness.
    // A hairline, not a lip. A wide bevel reads as a second, thicker pane
    // stacked on the first one instead of a single thin sheet of glass.
    final bevelWidth = math.min(radius * .12, 1.6).clamp(.9, 1.6);
    final bevel = RRect.fromRectAndRadius(
      rect.deflate(bevelWidth / 2),
      Radius.circular(math.max(0, radius - bevelWidth / 2)),
    );

    canvas.drawRRect(
      bevel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bevelWidth
        ..shader = LinearGradient(
          begin: Alignment(-1 + drift * .2, -1),
          end: const Alignment(1, 1),
          colors: [
            Colors.white.withAlpha(
              ((isLight ? 208 : 126) + 34 * t).round().clamp(0, 255),
            ),
            Colors.white.withAlpha((isLight ? 54 : 34) + (12 * t).round()),
            Colors.white.withAlpha(0),
          ],
          stops: const [0, .38, .72],
        ).createShader(rect),
    );

    // Return highlight on the far edge.
    canvas.drawRRect(
      bevel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bevelWidth * .8
        ..shader = LinearGradient(
          begin: const Alignment(1, 1),
          end: const Alignment(-.2, -.2),
          colors: [
            Colors.white.withAlpha(
              ((isLight ? 132 : 82) + 26 * t).round().clamp(0, 255),
            ),
            Colors.white.withAlpha(0),
          ],
          stops: const [0, .55],
        ).createShader(rect),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GlassInnerLights old) {
    return old.radius != radius ||
        old.tint != tint ||
        old.isLight != isLight ||
        old.strong != strong ||
        old.reduceMotion != reduceMotion;
  }
}

/// The hairline frame plus the thin blue→violet light that orbits the card.
class _GlassRimLight extends CustomPainter {
  final Animation<double> orbit;
  final Animation<double> lift;
  final double radius;
  final Color rimStart;
  final Color rimEnd;
  final Color? hairline;
  final bool isLight;
  final bool strong;
  final bool enabled;
  final bool reduceMotion;

  _GlassRimLight({
    required Listenable repaint,
    required this.orbit,
    required this.lift,
    required this.radius,
    required this.rimStart,
    required this.rimEnd,
    required this.hairline,
    required this.isLight,
    required this.strong,
    required this.enabled,
    required this.reduceMotion,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    const inset = .6;
    final rect = Offset.zero & size;
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        math.max(0, size.width - inset * 2),
        math.max(0, size.height - inset * 2),
      ),
      Radius.circular(math.max(0, radius - inset)),
    );

    // Static hairline: bright along the top, cooling toward the bottom.
    final hairPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    if (hairline != null) {
      hairPaint.color = hairline!;
    } else {
      hairPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isLight
            ? [
                Colors.white.withAlpha(strong ? 236 : 208),
                const Color(0xFFAEBFE2).withAlpha(strong ? 132 : 104),
              ]
            : [
                Colors.white.withAlpha(strong ? 62 : 44),
                Colors.white.withAlpha(strong ? 20 : 12),
              ],
      ).createShader(rect);
    }
    canvas.drawRRect(frame, hairPaint);

    // Chromatic dispersion. Real glass splits light at a steep edge, so the rim
    // carries a magenta fringe on one side and a cyan one on the other. Offset
    // by well under a pixel — it should be felt, not counted.
    const disp = .7;
    final fringeAlpha = isLight ? 54 : 66;
    void fringe(Color color, Offset shift, Alignment from) {
      canvas.save();
      canvas.translate(shift.dx, shift.dy);
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..shader = LinearGradient(
            begin: from,
            end: Alignment(-from.x, -from.y),
            colors: [
              color.withAlpha(fringeAlpha),
              color.withAlpha((fringeAlpha * .35).round()),
              color.withAlpha(0),
            ],
            stops: const [0, .45, .85],
          ).createShader(rect),
      );
      canvas.restore();
    }

    fringe(const Color(0xFFFF5FC8), const Offset(-disp, -disp),
        Alignment.topLeft);
    fringe(const Color(0xFF48D5FF), const Offset(disp, disp),
        Alignment.bottomRight);

    if (!enabled) return;

    final t = Curves.easeOutCubic.transform(lift.value.clamp(0.0, 1.0));
    final angle = (reduceMotion ? .12 : orbit.value) * math.pi * 2;

    // At rest the edge carries an even, very thin blue→violet wash. Pointing at
    // the card is what turns that wash into a bright comet racing around it,
    // so a resting card never looks "selected".
    final peak = ((isLight ? 62 : 78) + 150 * t).round().clamp(0, 255);
    final base = .66 + (.14 - .66) * t;

    Shader arc(double scale) {
      int a(double factor) => (peak * factor * scale).round().clamp(0, 255);
      return SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          rimStart.withAlpha(a(base)),
          rimStart.withAlpha(a(base + (1 - base) * .55)),
          rimStart.withAlpha(a(1)),
          rimEnd.withAlpha(a(1)),
          rimEnd.withAlpha(a(base + (1 - base) * .55)),
          rimEnd.withAlpha(a(base)),
          rimStart.withAlpha(a(base)),
        ],
        stops: const [0, .05, .12, .22, .3, .38, 1],
        transform: GradientRotation(angle),
      ).createShader(rect);
    }

    // Soft halo first, then the crisp filament on top.
    if (t > .01) {
      canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4
          ..shader = arc(.5 * t)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 4 * t),
      );
    }
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1 + .8 * t
        ..shader = arc(1),
    );
  }

  @override
  bool shouldRepaint(covariant _GlassRimLight old) {
    return old.radius != radius ||
        old.rimStart != rimStart ||
        old.rimEnd != rimEnd ||
        old.hairline != hairline ||
        old.isLight != isLight ||
        old.strong != strong ||
        old.enabled != enabled ||
        old.reduceMotion != reduceMotion;
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
    );
    // Parked, not repeating. These are three full-screen radial gradients: any
    // motion here repaints the entire screen every frame, forever, even on an
    // idle page. The drift it buys is barely perceptible behind the content, so
    // the ambience is composed once and left alone. Call `_controller.repeat()`
    // here to bring the movement back.
    _controller.value = .18;
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
        RepaintBoundary(
          child: AnimatedBuilder(
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
                        size: 360,
                        alpha: tokens.isLight ? 66 : 46,
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
                        size: 380,
                        alpha: tokens.isLight ? 58 : 40,
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
                      size: 380,
                      alpha: tokens.isLight ? 42 : 28,
                    ),
                  ),
                ],
              ),
            );
            },
          ),
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
          // Fading to the same hue keeps the halo clean; fading to
          // Colors.transparent would blend through grey.
          colors: [color.withAlpha(alpha), color.withAlpha(0)],
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
