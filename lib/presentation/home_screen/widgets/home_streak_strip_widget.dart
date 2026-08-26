import '../../../core/app_export.dart';

class HomeStreakStripWidget extends StatelessWidget {
  final int streak;
  final int xp;
  final int xpToNext;
  final String level;
  final int wordsLearned;

  const HomeStreakStripWidget({
    super.key,
    required this.streak,
    required this.xp,
    required this.xpToNext,
    required this.level,
    required this.wordsLearned,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        icon: Icons.local_fire_department_rounded,
        value: '$streak',
        label: 'Streak',
        color: const Color(0xFFFF8A65),
      ),
      _MetricData(
        icon: Icons.bolt_rounded,
        value: _formatXp(xp),
        label: 'XP',
        color: const Color(0xFFFFC107),
      ),
      _MetricData(
        icon: Icons.military_tech_rounded,
        value: level,
        label: 'Level',
        color: AppTheme.cefrLevelColor(level),
      ),
      _MetricData(
        icon: Icons.menu_book_rounded,
        value: '$wordsLearned',
        label: 'Words',
        color: const Color(0xFF34D399),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _xpBar(),
          const SizedBox(height: 14),
          SizedBox(
            height: 95,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: metrics.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _MetricCard(data: metrics[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _xpBar() {
    final safe = xpToNext <= 0 ? 1 : xpToNext;
    final progress = (xp / safe).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              '$xp / $xpToNext XP',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    color: Colors.white.withAlpha(20),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: 6,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return '$xp';
  }
}

class _MetricData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  _MetricData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: data.color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              size: 16,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
