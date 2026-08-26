import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../widgets/premium_feedback.dart';

class LearnAppBarWidget extends StatelessWidget {
  final AnimationController entranceController;

  const LearnAppBarWidget({super.key, required this.entranceController});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.primaryGradient.createShader(bounds),
                          child: const Text(
                            'Learn',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cefrLevelColor('B1').withAlpha(46),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.cefrLevelColor(
                                'B1',
                              ).withAlpha(102),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Current: B1',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cefrLevelColor('B1'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '62 lessons completed · 347 words learned',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Search button
              GestureDetector(
                onTap: () => PremiumFeedback.show(
                  context,
                  message: 'Use the search control in the main Learn screen.',
                  icon: Icons.search_rounded,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.glassWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.glassBorder, width: 1),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter
              GestureDetector(
                onTap: () => PremiumFeedback.show(
                  context,
                  message: 'Use the skill filters in the main Learn screen.',
                  icon: Icons.tune_rounded,
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.glassWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.glassBorder, width: 1),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
