import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class HomeXpChartWidget extends StatefulWidget {
  final int currentXp;

  const HomeXpChartWidget({
    super.key,
    required this.currentXp,
  });

  @override
  State<HomeXpChartWidget> createState() => _HomeXpChartWidgetState();
}

class _HomeXpChartWidgetState extends State<HomeXpChartWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  int _selectedDayIndex = 6;

  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'Mon', 'xp': 180},
    {'day': 'Tue', 'xp': 240},
    {'day': 'Wed', 'xp': 95},
    {'day': 'Thu', 'xp': 310},
    {'day': 'Fri', 'xp': 275},
    {'day': 'Sat', 'xp': 60},
    {'day': 'Sun', 'xp': 195},
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalXpThisWeek = _weeklyData.fold<int>(
      0,
      (sum, item) => sum + (item['xp'] as int),
    );

    final avgXp = totalXpThisWeek ~/ _weeklyData.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.glassWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.glassBorder,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(totalXpThisWeek, avgXp),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(double.infinity, 140),
                      painter: _XpChartPainter(
                        data: _weeklyData,
                        progress: _animationController.value,
                        selectedIndex: _selectedDayIndex,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _dayLabels(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(int totalXpThisWeek, int avgXp) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly XP Progress',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Apr 14 – Apr 20, 2026',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$totalXpThisWeek XP',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'avg $avgXp/day',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dayLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_weeklyData.length, (index) {
        final isSelected = index == _selectedDayIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDayIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withAlpha(51)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  _weeklyData[index]['day'] as String,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isSelected ? AppTheme.primaryLight : AppTheme.textMuted,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${_weeklyData[index]['xp']}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _XpChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double progress;
  final int selectedIndex;

  _XpChartPainter({
    required this.data,
    required this.progress,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const maxXp = 350.0;
    final width = size.width;
    final height = size.height;

    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        gridPaint,
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final xp = (data[i]['xp'] as int).toDouble() * progress;
      final x = data.length == 1 ? width / 2 : width * i / (data.length - 1);
      final y = height - ((xp / maxXp) * height);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final midX = (previous.dx + current.dx) / 2;

      path.cubicTo(
        midX,
        previous.dy,
        midX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, height)
      ..lineTo(points.first.dx, height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.primary.withAlpha(65),
          AppTheme.primaryBlue.withAlpha(10),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppTheme.primaryLight
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      final isSelected = i == selectedIndex;

      final dotPaint = Paint()
        ..color = isSelected ? AppTheme.primaryLight : AppTheme.primary;

      canvas.drawCircle(
        points[i],
        isSelected ? 6 : 4,
        dotPaint,
      );

      if (isSelected) {
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(points[i], 6, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _XpChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.data != data;
  }
}
