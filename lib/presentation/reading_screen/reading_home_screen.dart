import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../data/reading/reading_models.dart';
import '../../data/reading/reading_repository.dart';
import '../../data/reading/reading_progress_store.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import 'reading_detail_screen.dart';

class ReadingHomeScreen extends StatefulWidget {
  final String initialLevel;
  final bool isEnglish;

  const ReadingHomeScreen({
    super.key,
    this.initialLevel = 'A1',
    required this.isEnglish,
  });

  @override
  State<ReadingHomeScreen> createState() => _ReadingHomeScreenState();
}

class _ReadingHomeScreenState extends State<ReadingHomeScreen>
    with TickerProviderStateMixin {
  static const ReadingRepository _repository = ReadingRepository();

  late ReadingLevel selectedLevel;
  late AnimationController _contentFadeCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  bool get isEnglish => widget.isEnglish;
  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    selectedLevel = _levelFromCode(widget.initialLevel);
    AppProgress.instance.loadProgress();

    _contentFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _contentFade = CurvedAnimation(
      parent: _contentFadeCtrl,
      curve: Curves.easeOutCubic,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentFadeCtrl,
      curve: Curves.easeOutCubic,
    ));
    _contentFadeCtrl.forward();
  }

  @override
  void dispose() {
    _contentFadeCtrl.dispose();
    super.dispose();
  }

  void _switchLevel(ReadingLevel level) {
    if (level == selectedLevel) return;
    _contentFadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => selectedLevel = level);
      _contentFadeCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForLevel(selectedLevel);
    final tokens = SpeakeryThemeTokens.of(context);
    final clusters = _repository.clustersByLevel(selectedLevel);
    final lessons = _repository.lessonsByLevel(selectedLevel);
    final completed = lessons
        .where((l) => AppProgress.instance.isLessonCompleted(l.id))
        .length;

    return Scaffold(
      backgroundColor: tokens.background,
      body: _SceneBackground(
        palette: palette,
        child: SafeArea(
          child: Column(
            children: [
              // ── Fixed header zone (never scrolls) ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  children: [
                    _TopHeader(
                      palette: palette,
                      lessonCount: lessons.length,
                      completed: completed,
                      selectedLevel: selectedLevel,
                      isEnglish: isEnglish,
                      onBack: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),
                    _LevelToggle(
                      selectedLevel: selectedLevel,
                      onChanged: _switchLevel,
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                        count: lessons.length,
                        palette: palette,
                        isEnglish: isEnglish),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // ── Animated scrollable content ─────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: AnimatedBuilder(
                      animation: AppProgress.instance,
                      builder: (context, _) {
                        if (clusters.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _EmptyLevelCard(
                                level: selectedLevel,
                                isEnglish: isEnglish,
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          physics: const BouncingScrollPhysics(),
                          itemCount: clusters.length,
                          itemBuilder: (ctx, i) {
                            final cluster = clusters[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ReadingClusterCard(
                                cluster: cluster,
                                palette: _paletteForLevel(cluster.level),
                                isEnglish: isEnglish,
                                onLessonTap: _openLesson,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(ReadingLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: ReadingDetailScreen(
            passageId: lesson.id,
            isEnglish: isEnglish,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCENE BACKGROUND  — single blur layer, not per-card
// ─────────────────────────────────────────────────────────────────────────────

class _SceneBackground extends StatelessWidget {
  final _LevelPalette palette;
  final Widget child;

  const _SceneBackground({required this.palette, required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.32, -0.92),
          radius: 1.18,
          colors: [
            palette.start.withAlpha(42),
            palette.end.withAlpha(16),
            tokens.backgroundEnd,
            tokens.background,
          ],
          stops: const [0.0, 0.34, 0.68, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 80,
            right: -92,
            child: _BackgroundOrb(
              color: palette.end.withAlpha(38),
              size: 190,
            ),
          ),
          Positioned(
            bottom: -72,
            left: -82,
            child: _BackgroundOrb(
              color: palette.start.withAlpha(28),
              size: 210,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _BackgroundOrb({
    required this.color,
    required this.size,
  });

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
              blurRadius: 92,
              spreadRadius: 34,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _TopHeader extends StatelessWidget {
  final _LevelPalette palette;
  final int lessonCount;
  final int completed;
  final ReadingLevel selectedLevel;
  final bool isEnglish;
  final VoidCallback onBack;

  const _TopHeader({
    required this.palette,
    required this.lessonCount,
    required this.completed,
    required this.selectedLevel,
    required this.isEnglish,
    required this.onBack,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final progress = lessonCount == 0 ? 0.0 : completed / lessonCount;

    return _GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      accentColor: palette.start,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          _TapScale(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withAlpha(10),
                border: Border.all(color: Colors.white.withAlpha(18)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Reading',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        height: 1,
                      ),
                    ),
                    const Spacer(),
                    _LevelBadge(palette: palette, level: selectedLevel),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t(
                    'Read, collect words, and check comprehension.',
                    'Oku, kelime topla ve anladığını kontrol et.',
                  ),
                  style: TextStyle(
                    color: Colors.white.withAlpha(165),
                    fontSize: 12.2,
                    height: 1.38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Progress bar row
                Row(
                  children: [
                    _MiniStat(
                      icon: Icons.auto_stories_rounded,
                      label: t('$lessonCount texts', '$lessonCount metin'),
                    ),
                    const SizedBox(width: 7),
                    _MiniStat(
                      icon: Icons.check_circle_outline_rounded,
                      label: t('$completed done', '$completed bitti'),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        color: palette.start,
                        fontSize: 10.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress track
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      // Track
                      Container(
                        height: 5,
                        width: double.infinity,
                        color: Colors.white.withAlpha(10),
                      ),
                      // Fill
                      AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [palette.start, palette.end],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: palette.start.withAlpha(80),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL BADGE (animated color)
// ─────────────────────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  final _LevelPalette palette;
  final ReadingLevel level;

  const _LevelBadge({required this.palette, required this.level});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.start, palette.end],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.start.withAlpha(48),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        level.code,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final int count;
  final _LevelPalette palette;
  final bool isEnglish;

  const _SectionHeader({
    required this.count,
    required this.palette,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            isEnglish ? 'Texts' : 'Metinler',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: palette.start.withAlpha(20),
            border: Border.all(color: palette.start.withAlpha(50)),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL TOGGLE  — liquid pill, single blur, smooth slide
// ─────────────────────────────────────────────────────────────────────────────

class _LevelToggle extends StatelessWidget {
  final ReadingLevel selectedLevel;
  final ValueChanged<ReadingLevel> onChanged;

  const _LevelToggle({
    required this.selectedLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const levels = ReadingLevel.values;
    final selectedIndex =
        levels.indexOf(selectedLevel).clamp(0, levels.length - 1);
    final selectedPalette = _paletteForLevel(selectedLevel);

    return IosLiquidPillSelector(
      items: levels
          .map((level) => IosPillItem(level.code))
          .toList(growable: false),
      selectedIndex: selectedIndex,
      startColor: selectedPalette.start,
      endColor: selectedPalette.end,
      onChanged: (index) => onChanged(levels[index]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLUSTER CARD  — no BackdropFilter per card (performance fix)
// ─────────────────────────────────────────────────────────────────────────────

class _ReadingClusterCard extends StatelessWidget {
  final ReadingCluster cluster;
  final _LevelPalette palette;
  final bool isEnglish;
  final ValueChanged<ReadingLesson> onLessonTap;

  const _ReadingClusterCard({
    required this.cluster,
    required this.palette,
    required this.isEnglish,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      accentColor: palette.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cluster header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ClusterIcon(icon: cluster.icon, palette: palette),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cluster.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cluster.subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(155),
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: palette.start.withAlpha(20),
                  border: Border.all(color: palette.start.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.library_books_rounded,
                        size: 12, color: palette.start),
                    const SizedBox(width: 4),
                    Text(
                      '${cluster.lessons.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Lesson cards
          ...List.generate(cluster.lessons.length, (i) {
            final lesson = cluster.lessons[i];
            final completed = AppProgress.instance.isLessonCompleted(lesson.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReadingLessonCard(
                lesson: lesson,
                palette: palette,
                isEnglish: isEnglish,
                index: i,
                completed: completed,
                onTap: () => onLessonTap(lesson),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LESSON CARD  — solid glass, no per-card BackdropFilter
// ─────────────────────────────────────────────────────────────────────────────

class _ReadingLessonCard extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;
  final bool completed;
  final int index;
  final VoidCallback onTap;

  const _ReadingLessonCard({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
    required this.completed,
    required this.index,
    required this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final locked = lesson.isPremium;

    return _TapScale(
      onTap: locked ? () => _showLockedSnack(context) : onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          // Solid semi-transparent — no blur here
          color:
              locked ? Colors.white.withAlpha(6) : palette.start.withAlpha(14),
          border: Border.all(
            color: locked
                ? Colors.white.withAlpha(13)
                : palette.start.withAlpha(48),
            width: 1,
          ),
          boxShadow: locked
              ? null
              : [
                  BoxShadow(
                    color: palette.start.withAlpha(18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookBadge(
              lesson: lesson,
              palette: palette,
              index: index,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha(locked ? 170 : 245),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        lessonId: lesson.id,
                        completed: completed,
                        locked: locked,
                        isEnglish: isEnglish,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lesson.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(155),
                      fontSize: 12,
                      height: 1.32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Meta chips row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Chip(
                        icon: Icons.schedule_rounded,
                        label: locked
                            ? '--'
                            : '${lesson.estimatedMinutes} ${t('min', 'dk')}',
                        faint: locked,
                      ),
                      _Chip(
                        icon: Icons.text_snippet_outlined,
                        label: locked
                            ? '--'
                            : '${lesson.wordCount} ${t('words', 'kelime')}',
                        faint: locked,
                      ),
                      _Chip(
                        icon: Icons.bar_chart_rounded,
                        label: lesson.level.code,
                        faint: locked,
                        accentColor: locked ? null : palette.start,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Progress micro-bar
                  _LessonProgressBar(
                    completed: completed,
                    locked: locked,
                    palette: palette,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFF111827),
        content: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Colors.white60, size: 16),
            const SizedBox(width: 8),
            Text(
              isEnglish
                  ? '${lesson.level.code} Reading is premium.'
                  : '${lesson.level.code} okuma paketi premium.',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LESSON PROGRESS BAR
// ─────────────────────────────────────────────────────────────────────────────

class _LessonProgressBar extends StatelessWidget {
  final bool completed;
  final bool locked;
  final _LevelPalette palette;

  const _LessonProgressBar({
    required this.completed,
    required this.locked,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            color: Colors.white.withAlpha(9),
          ),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            widthFactor: completed ? 1.0 : 0.0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: locked
                      ? [Colors.white.withAlpha(30), Colors.white.withAlpha(20)]
                      : [palette.start, palette.end],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: locked
                    ? null
                    : [
                        BoxShadow(
                          color: palette.start.withAlpha(70),
                          blurRadius: 4,
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOK BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _BookBadge extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final int index;

  const _BookBadge({
    required this.lesson,
    required this.palette,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final locked = lesson.isPremium;
    return Container(
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: locked
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.start, palette.end],
              ),
        color: locked ? Colors.white.withAlpha(8) : null,
        border: Border.all(
          color: locked ? Colors.white.withAlpha(14) : Colors.transparent,
        ),
        boxShadow: locked
            ? null
            : [
                BoxShadow(
                  color: palette.start.withAlpha(45),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: locked
          ? Icon(Icons.lock_rounded,
              color: Colors.white.withAlpha(150), size: 20)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(lesson.icon, color: Colors.white, size: 20),
                const SizedBox(height: 3),
                Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyLevelCard extends StatelessWidget {
  final ReadingLevel level;
  final bool isEnglish;

  const _EmptyLevelCard({required this.level, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForLevel(level);
    return _GlassCard(
      radius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      accentColor: palette.start,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.start.withAlpha(22),
              border: Border.all(color: palette.start.withAlpha(48)),
            ),
            child: Icon(level.icon, color: palette.start, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            t('${level.code} Reading', '${level.code} Okuma'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              'No texts found for this filter. Choose another level above or return later after content sync.',
              'Bu filtre için metin bulunamadı. Üstten başka seviye seç veya içerik senkronundan sonra tekrar bak.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(155),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: palette.start.withAlpha(18),
              border: Border.all(color: palette.start.withAlpha(45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 14, color: palette.start),
                const SizedBox(width: 6),
                Text(
                  t('Use level picker', 'Seviye seciciyi kullan'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String lessonId;
  final bool completed;
  final bool locked;
  final bool isEnglish;

  const _StatusBadge({
    required this.lessonId,
    required this.completed,
    required this.locked,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return FutureBuilder<ReadingProgress?>(
        future: ReadingProgressStore.instance.progressFor(lessonId),
        builder: (context, snapshot) {
          final progress = snapshot.data;
          final hasScore = progress != null && progress.totalQuestions > 0;
          final label = hasScore
              ? '${progress.latestScore}/${progress.totalQuestions}'
              : t('Done', 'Bitti');

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF22C55E).withAlpha(24),
              border: Border.all(color: const Color(0xFF22C55E).withAlpha(55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: 10,
                  color: Color(0xFF22C55E),
                ),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 9.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (locked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withAlpha(7),
          border: Border.all(color: Colors.white.withAlpha(14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 10,
              color: Colors.white.withAlpha(130),
            ),
            const SizedBox(width: 3),
            Text(
              'PRO',
              style: TextStyle(
                color: Colors.white.withAlpha(140),
                fontSize: 9.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHIP  — lightweight meta pill
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool faint;
  final Color? accentColor;

  const _Chip({
    required this.icon,
    required this.label,
    this.faint = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color:
            c != null ? c.withAlpha(16) : Colors.white.withAlpha(faint ? 5 : 8),
        border: Border.all(
          color: c != null
              ? c.withAlpha(40)
              : Colors.white.withAlpha(faint ? 10 : 14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11.5,
            color: c ?? Colors.white.withAlpha(faint ? 80 : 130),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: c != null
                  ? Colors.white
                  : Colors.white.withAlpha(faint ? 90 : 140),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MINI STAT  — header stat pill
// ─────────────────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withAlpha(8),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: Colors.white.withAlpha(140)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLUSTER ICON
// ─────────────────────────────────────────────────────────────────────────────

class _ClusterIcon extends StatelessWidget {
  final IconData icon;
  final _LevelPalette palette;

  const _ClusterIcon({required this.icon, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.start.withAlpha(22),
        border: Border.all(color: palette.start.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: palette.start.withAlpha(28),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(icon, color: palette.start, size: 21),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLASS CARD  — no BackdropFilter (perf), solid semi-transparent container
// ─────────────────────────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color accentColor;

  const _GlassCard({
    required this.child,
    required this.radius,
    required this.padding,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // Solid glass — matches liquid glass aesthetic without blur overhead
        color: tokens.isLight
            ? tokens.elevatedSurface
            : Colors.white.withAlpha(10),
        border: Border.all(
          color: tokens.isLight ? tokens.border : accentColor.withAlpha(38),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withAlpha(tokens.isLight ? 30 : 40),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accentColor.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAP SCALE
// ─────────────────────────────────────────────────────────────────────────────

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScale({required this.child, required this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.978 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

ReadingLevel _levelFromCode(String code) {
  final clean = code.toUpperCase().trim();
  for (final level in ReadingLevel.values) {
    if (level.code == clean) return level;
  }
  return ReadingLevel.a1;
}

_LevelPalette _paletteForLevel(ReadingLevel level) {
  // App-wide CEFR palette matched to the existing Learn/Grammar screens.
  // A1 cyan, A2 green, B1 amber, B2 pink, C1 purple, C2 coral.
  switch (level) {
    case ReadingLevel.a1:
      return const _LevelPalette(
        Color(0xFF06B6D4), // cyan
        Color(0xFF0284C7), // deep cyan-blue
      );
    case ReadingLevel.a2:
      return const _LevelPalette(
        Color(0xFF22C55E), // green
        Color(0xFF16A34A), // deep green
      );
    case ReadingLevel.b1:
      return const _LevelPalette(
        Color(0xFFF59E0B), // amber
        Color(0xFFD97706), // deep amber
      );
    case ReadingLevel.b2:
      return const _LevelPalette(
        Color(0xFFEC4899), // pink
        Color(0xFFBE185D), // deep pink
      );
    case ReadingLevel.c1:
      return const _LevelPalette(
        Color(0xFF8B5CF6), // violet
        Color(0xFF6D28D9), // deep violet
      );
    case ReadingLevel.c2:
      return const _LevelPalette(
        Color(0xFFFF6B57), // coral
        Color(0xFFEC4899), // pink edge
      );
  }
}

class _LevelPalette {
  final Color start;
  final Color end;
  const _LevelPalette(this.start, this.end);
}
