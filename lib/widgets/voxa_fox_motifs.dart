import 'dart:math' as math;

import 'package:flutter/material.dart';

enum VoxaMascotMood { neutral, lonely, hungry, happy }

class VoxaMascot extends StatelessWidget {
  final double size;
  final VoxaMascotMood mood;
  final bool circular;
  final double radius;

  const VoxaMascot({
    super.key,
    required this.size,
    this.mood = VoxaMascotMood.neutral,
    this.circular = true,
    this.radius = 24,
  });

  String get _asset {
    return switch (mood) {
      VoxaMascotMood.neutral => 'assets/images/voxa_mascot_v2.png',
      VoxaMascotMood.lonely => 'assets/images/voxa_lonely_v2.png',
      VoxaMascotMood.hungry => 'assets/images/voxa_hungry_v2.png',
      VoxaMascotMood.happy => 'assets/images/voxa_happy_v2.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      cacheWidth: (size * 2).round(),
      cacheHeight: (size * 2).round(),
      errorBuilder: (_, __, ___) => ColoredBox(
        color: const Color(0xFFFFF1E1),
        child: Icon(
          Icons.pets_rounded,
          size: size * .42,
          color: const Color(0xFFFF7A12),
        ),
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: circular
          ? ClipOval(child: image)
          : ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: image,
            ),
    );
  }
}

class VoxaAmbientIllustration extends StatelessWidget {
  final Color primary;
  final Color secondary;

  const VoxaAmbientIllustration({
    super.key,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VoxaAmbientPainter(
        primary: primary,
        secondary: secondary,
      ),
    );
  }
}

class VoxaFoxPatternLayer extends StatelessWidget {
  final Color color;
  final double opacity;
  final double spacing;
  final bool includeTails;

  const VoxaFoxPatternLayer({
    super.key,
    required this.color,
    this.opacity = .08,
    this.spacing = 78,
    this.includeTails = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: VoxaFoxPatternPainter(
          color: color.withValues(alpha: opacity),
          spacing: spacing,
          includeTails: includeTails,
        ),
      ),
    );
  }
}

class VoxaFoxGlyph extends StatelessWidget {
  final double size;
  final Color color;
  final Color? fillColor;
  final bool showTail;

  const VoxaFoxGlyph({
    super.key,
    this.size = 32,
    required this.color,
    this.fillColor,
    this.showTail = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: VoxaFoxGlyphPainter(
          lineColor: color,
          fillColor: fillColor ?? color.withValues(alpha: .09),
          showTail: showTail,
        ),
      ),
    );
  }
}

class _VoxaAmbientPainter extends CustomPainter {
  final Color primary;
  final Color secondary;

  const _VoxaAmbientPainter({
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final warmFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primary.withValues(alpha: .045);
    final sandFill = Paint()
      ..style = PaintingStyle.fill
      ..color = secondary.withValues(alpha: .028);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..color = primary.withValues(alpha: .11);

    final bottomWave = Path()
      ..moveTo(0, size.height * .88)
      ..cubicTo(
        size.width * .23,
        size.height * .78,
        size.width * .46,
        size.height * .97,
        size.width * .68,
        size.height * .88,
      )
      ..cubicTo(
        size.width * .82,
        size.height * .82,
        size.width * .92,
        size.height * .84,
        size.width,
        size.height * .76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bottomWave, warmFill);

    final secondWave = Path()
      ..moveTo(0, size.height * .94)
      ..cubicTo(
        size.width * .25,
        size.height * .82,
        size.width * .55,
        size.height * 1.03,
        size.width,
        size.height * .87,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(secondWave, sandFill);

    final tail = Path()
      ..moveTo(size.width * .72, size.height * .08)
      ..cubicTo(
        size.width * .94,
        size.height * .02,
        size.width * 1.02,
        size.height * .14,
        size.width * .9,
        size.height * .22,
      )
      ..cubicTo(
        size.width * .84,
        size.height * .26,
        size.width * .78,
        size.height * .19,
        size.width * .85,
        size.height * .14,
      );
    canvas.drawPath(tail, line);

    _drawSpark(canvas, Offset(size.width * .1, size.height * .18), 7, line);
    _drawSpark(canvas, Offset(size.width * .89, size.height * .42), 5, line);
    _drawLeaf(
      canvas,
      Offset(size.width * .12, size.height * .82),
      8,
      warmFill,
      -.45,
    );
    _drawLeaf(
      canvas,
      Offset(size.width * .92, size.height * .72),
      7,
      warmFill,
      .55,
    );
  }

  static void _drawSpark(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    canvas.drawLine(
      center.translate(-radius, 0),
      center.translate(radius, 0),
      paint,
    );
    canvas.drawLine(
      center.translate(0, -radius),
      center.translate(0, radius),
      paint,
    );
  }

  static void _drawLeaf(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final leaf = Path()
      ..moveTo(-radius, 0)
      ..quadraticBezierTo(0, -radius * .7, radius, 0)
      ..quadraticBezierTo(0, radius * .7, -radius, 0)
      ..close();
    canvas.drawPath(leaf, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VoxaAmbientPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.secondary != secondary;
  }
}

class VoxaFoxPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final bool includeTails;

  const VoxaFoxPatternPainter({
    required this.color,
    required this.spacing,
    required this.includeTails,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final rows = (size.height / spacing).ceil() + 1;
    final columns = (size.width / spacing).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final seed = row * 17 + column * 11;
        final center = Offset(
          column * spacing + (row.isOdd ? spacing * .43 : 8),
          row * spacing + 16,
        );
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate((seed.isEven ? -1 : 1) * .07);
        if (includeTails && seed % 4 == 0) {
          _drawTail(canvas, paint, 12);
        } else if (seed % 3 == 0) {
          _drawEars(canvas, paint, 12);
        } else {
          _drawFace(canvas, paint, 12);
        }
        canvas.restore();
      }
    }
  }

  static void _drawFace(Canvas canvas, Paint paint, double radius) {
    final path = Path()
      ..moveTo(-radius, -radius * .12)
      ..lineTo(-radius * .78, -radius)
      ..lineTo(-radius * .22, -radius * .58)
      ..quadraticBezierTo(0, -radius * .72, radius * .22, -radius * .58)
      ..lineTo(radius * .78, -radius)
      ..lineTo(radius, -radius * .12)
      ..quadraticBezierTo(
        radius * .86,
        radius * .72,
        0,
        radius,
      )
      ..quadraticBezierTo(
        -radius * .86,
        radius * .72,
        -radius,
        -radius * .12,
      );
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(-radius * .34, radius * .08), 1, paint);
    canvas.drawCircle(Offset(radius * .34, radius * .08), 1, paint);
    canvas.drawCircle(Offset.zero.translate(0, radius * .43), 1.15, paint);
  }

  static void _drawEars(Canvas canvas, Paint paint, double radius) {
    final path = Path()
      ..moveTo(-radius, radius * .7)
      ..lineTo(-radius * .72, -radius)
      ..lineTo(-radius * .04, radius * .1)
      ..lineTo(radius * .72, -radius)
      ..lineTo(radius, radius * .7);
    canvas.drawPath(path, paint);
  }

  static void _drawTail(Canvas canvas, Paint paint, double radius) {
    final path = Path()
      ..moveTo(-radius * .8, radius * .7)
      ..cubicTo(
        -radius * 1.15,
        -radius * .8,
        radius,
        -radius * 1.1,
        radius * .85,
        radius * .1,
      )
      ..cubicTo(
        radius * .75,
        radius * .92,
        radius * .05,
        radius,
        -radius * .35,
        radius * .54,
      );
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(radius * .48, -radius * .46),
      Offset(radius * .86, radius * .08),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant VoxaFoxPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.includeTails != includeTails;
  }
}

class VoxaFoxGlyphPainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;
  final bool showTail;

  const VoxaFoxGlyphPainter({
    required this.lineColor,
    required this.fillColor,
    required this.showTail,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) * .34;
    final center = Offset(size.width / 2, size.height / 2);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, size.width * .045)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawCircle(Offset.zero, radius * 1.28, fill);
    if (showTail) {
      VoxaFoxPatternPainter._drawTail(canvas, line, radius);
    } else {
      VoxaFoxPatternPainter._drawFace(canvas, line, radius);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VoxaFoxGlyphPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.showTail != showTail;
  }
}
