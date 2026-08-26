import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../widgets/premium_feedback.dart';

class LearnCategoryGridWidget extends StatelessWidget {
  final String selectedLevel;
  final bool isTablet;

  const LearnCategoryGridWidget({
    super.key,
    required this.selectedLevel,
    required this.isTablet,
  });

  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'grammar',
      'title': 'Grammar',
      'subtitle': 'Rules & structures',
      'icon': Icons.auto_fix_high_rounded,
      'gradient': [Color(0xFF6366F1), Color(0xFF4F46E5)],
      'lessonCount': 24,
      'completedCount': 15,
      'isNew': false,
    },
    {
      'id': 'vocabulary',
      'title': 'Vocabulary',
      'subtitle': 'Words & phrases',
      'icon': Icons.style_rounded,
      'gradient': [Color(0xFF10B981), Color(0xFF059669)],
      'lessonCount': 32,
      'completedCount': 18,
      'isNew': false,
    },
    {
      'id': 'reading',
      'title': 'Reading',
      'subtitle': 'Passages & comprehension',
      'icon': Icons.menu_book_rounded,
      'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB)],
      'lessonCount': 20,
      'completedCount': 8,
      'isNew': false,
    },
    {
      'id': 'writing',
      'title': 'Writing',
      'subtitle': 'Essays & tasks',
      'icon': Icons.edit_note_rounded,
      'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
      'lessonCount': 16,
      'completedCount': 5,
      'isNew': false,
    },
    {
      'id': 'speaking',
      'title': 'Speaking',
      'subtitle': 'Pronunciation & fluency',
      'icon': Icons.mic_rounded,
      'gradient': [Color(0xFFFF6B35), Color(0xFFEA580C)],
      'lessonCount': 18,
      'completedCount': 9,
      'isNew': false,
    },
    {
      'id': 'exercises',
      'title': 'Exercises',
      'subtitle': 'Practice & quizzes',
      'icon': Icons.psychology_rounded,
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      'lessonCount': 40,
      'completedCount': 22,
      'isNew': false,
    },
    {
      'id': 'exam_prep',
      'title': 'Exam Prep',
      'subtitle': 'IELTS · TOEFL · YDT',
      'icon': Icons.workspace_premium_rounded,
      'gradient': [Color(0xFFEC4899), Color(0xFFDB2777)],
      'lessonCount': 28,
      'completedCount': 3,
      'isNew': true,
    },
    {
      'id': 'revision',
      'title': 'Revision',
      'subtitle': 'Review & reinforce',
      'icon': Icons.refresh_rounded,
      'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
      'lessonCount': 12,
      'completedCount': 0,
      'isNew': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = isTablet ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Skill Categories',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.glassBorder, width: 1),
                ),
                child: Text(
                  selectedLevel,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cefrLevelColor(selectedLevel),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: isTablet ? 1.1 : 1.0,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _CategoryCard(data: _categories[index], index: index);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;

  const _CategoryCard({required this.data, required this.index});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final gradientColors = (data['gradient'] as List).cast<Color>();
    final progress =
        (data['completedCount'] as int) / (data['lessonCount'] as int);

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: () => PremiumFeedback.show(
        context,
        message: 'Open ${data['title']} from the main Learn overview.',
        icon: data['icon'] as IconData,
      ),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.glassBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColors.first.withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          data['icon'] as IconData,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      if (data['isNew'] as bool)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] as String,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['subtitle'] as String,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['completedCount']}/${data['lessonCount']} lessons',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          color: AppTheme.textMuted,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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
