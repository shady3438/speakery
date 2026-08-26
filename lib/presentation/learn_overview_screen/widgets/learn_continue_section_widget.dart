import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../widgets/premium_feedback.dart';

class LearnContinueSectionWidget extends StatelessWidget {
  final String selectedLevel;

  const LearnContinueSectionWidget({super.key, required this.selectedLevel});

  static const List<Map<String, dynamic>> _recentLessons = [
    {
      'title': 'Present Perfect vs. Past Simple',
      'category': 'Grammar',
      'level': 'B1',
      'duration': '18 min',
      'progress': 0.62,
      'icon': Icons.auto_fix_high_rounded,
      'gradientColors': [Color(0xFF6366F1), Color(0xFF4F46E5)],
      'status': 'in_progress',
    },
    {
      'title': 'Business Email Vocabulary',
      'category': 'Vocabulary',
      'level': 'B1',
      'duration': '12 min',
      'progress': 0.0,
      'icon': Icons.style_rounded,
      'gradientColors': [Color(0xFF10B981), Color(0xFF059669)],
      'status': 'available',
    },
    {
      'title': 'The Future of Renewable Energy',
      'category': 'Reading',
      'level': 'B2',
      'duration': '25 min',
      'progress': 0.0,
      'icon': Icons.menu_book_rounded,
      'gradientColors': [Color(0xFF3B82F6), Color(0xFF2563EB)],
      'status': 'locked',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Continue Where You Left Off',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => PremiumFeedback.show(
                  context,
                  message: 'Your recent lessons are shown below.',
                  icon: Icons.history_rounded,
                ),
                child: const Text(
                  'All',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recentLessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LessonListItem(lesson: lesson),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonListItem extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const _LessonListItem({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson['status'] == 'locked';
    final isInProgress = lesson['status'] == 'in_progress';
    final progress = lesson['progress'] as double;
    final gradientColors = (lesson['gradientColors'] as List).cast<Color>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isLocked
                ? AppTheme.glassWhite.withAlpha(128)
                : AppTheme.glassWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isInProgress
                  ? AppTheme.primary.withAlpha(77)
                  : AppTheme.glassBorder,
              width: isInProgress ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: isLocked
                      ? null
                      : LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: isLocked ? AppTheme.surfaceVariant : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLocked ? Icons.lock_rounded : lesson['icon'] as IconData,
                  size: 20,
                  color: isLocked ? AppTheme.textMuted : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson['title'] as String,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isLocked
                                  ? AppTheme.textMuted
                                  : AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cefrLevelColor(
                              lesson['level'] as String,
                            ).withAlpha(31),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            lesson['level'] as String,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.cefrLevelColor(
                                lesson['level'] as String,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lesson['category'] as String,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '·',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          lesson['duration'] as String,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (isInProgress) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
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
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Action button
              if (!isLocked)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isInProgress ? AppTheme.primaryGradient : null,
                    color: isInProgress ? null : AppTheme.glassWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: isInProgress
                        ? null
                        : Border.all(color: AppTheme.glassBorder, width: 1),
                  ),
                  child: Icon(
                    isInProgress
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                    size: 16,
                    color: isInProgress ? Colors.white : AppTheme.textSecondary,
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
