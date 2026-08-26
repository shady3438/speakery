

import '../../../core/app_export.dart';

class LearnCefrSelectorWidget extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final Function(String) onLevelSelected;

  const LearnCefrSelectorWidget({
    super.key,
    required this.levels,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  static const Map<String, String> _levelDescriptions = {
    'A1': 'Beginner',
    'A2': 'Elementary',
    'B1': 'Intermediate',
    'B2': 'Upper-Inter.',
    'C1': 'Advanced',
    'C2': 'Mastery',
  };

  static const Map<String, int> _lessonCounts = {
    'A1': 48,
    'A2': 54,
    'B1': 72,
    'B2': 68,
    'C1': 60,
    'C2': 44,
  };

  static const Map<String, double> _progressValues = {
    'A1': 1.0,
    'A2': 0.85,
    'B1': 0.62,
    'B2': 0.0,
    'C1': 0.0,
    'C2': 0.0,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CEFR Levels',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'A1 → C2',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 20),
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final level = levels[index];
                final isSelected = level == selectedLevel;
                final progress = _progressValues[level] ?? 0.0;
                final isLocked =
                    progress == 0.0 &&
                    levels.indexOf(level) > levels.indexOf(selectedLevel) + 1;

                return _CefrLevelCard(
                  level: level,
                  description: _levelDescriptions[level] ?? '',
                  lessonCount: _lessonCounts[level] ?? 0,
                  progress: progress,
                  isSelected: isSelected,
                  isLocked: isLocked,
                  onTap: () => onLevelSelected(level),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CefrLevelCard extends StatelessWidget {
  final String level;
  final String description;
  final int lessonCount;
  final double progress;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _CefrLevelCard({
    required this.level,
    required this.description,
    required this.lessonCount,
    required this.progress,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.cefrLevelColor(level);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [levelColor.withAlpha(77), levelColor.withAlpha(31)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? levelColor.withAlpha(128)
                : AppTheme.glassBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: levelColor.withAlpha(51),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  level,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isLocked ? AppTheme.textMuted : levelColor,
                  ),
                ),
                if (isLocked)
                  const Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  )
                else if (progress == 1.0)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.success.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: AppTheme.success,
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    color: isLocked
                        ? AppTheme.textMuted
                        : AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                if (!isLocked) ...[
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.glassWhite,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: levelColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    progress == 0.0
                        ? '$lessonCount lessons'
                        : '${(progress * lessonCount).toInt()}/$lessonCount',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 9,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ] else
                  Text(
                    'Complete $level first',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 9,
                      color: AppTheme.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
