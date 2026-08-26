import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/reading/reading_models.dart';
import '../../data/reading/reading_repository.dart';
import '../../theme/speakery_theme_tokens.dart';

class ReadingResultScreen extends StatelessWidget {
  final ReadingLesson lesson;
  final int score;
  final int totalQuestions;
  final int earnedXP;
  final bool alreadyCompleted;
  final bool isEnglish;
  final Widget Function(String nextLessonId)? nextLessonBuilder;

  const ReadingResultScreen({
    super.key,
    required this.lesson,
    required this.score,
    required this.totalQuestions,
    required this.earnedXP,
    required this.alreadyCompleted,
    required this.isEnglish,
    this.nextLessonBuilder,
  });

  static const ReadingRepository _repository = ReadingRepository();

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForLevel(lesson.level);
    final tokens = SpeakeryThemeTokens.of(context);
    final accuracy =
        totalQuestions == 0 ? 0.0 : (score / totalQuestions).clamp(0.0, 1.0);
    final percent = (accuracy * 100).round();

    return Scaffold(
      backgroundColor: tokens.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.25, -0.85),
            radius: 1.2,
            colors: [
              palette.start.withAlpha(48),
              tokens.backgroundEnd,
              tokens.background,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              _topBar(context, palette),
              const SizedBox(height: 16),
              _resultHero(palette, percent),
              const SizedBox(height: 12),
              _scoreGrid(palette, percent),
              const SizedBox(height: 12),
              _lessonSummary(palette),
              const SizedBox(height: 16),
              _actions(context, palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, _LevelPalette palette) {
    return Row(
      children: [
        _TapScale(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withAlpha(10),
              border: Border.all(color: Colors.white.withAlpha(16)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GlassCard(
            radius: 26,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            accentColor: palette.start,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [palette.start, palette.end],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.start.withAlpha(55),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t('Reading Result', 'Okuma Sonucu'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultHero(_LevelPalette palette, int percent) {
    final strong = percent >= 80;
    final good = percent >= 60;

    return _GlassCard(
      radius: 34,
      padding: const EdgeInsets.all(18),
      accentColor: palette.start,
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.start, palette.end],
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.start.withAlpha(80),
                  blurRadius: 34,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(
              strong
                  ? Icons.workspace_premium_rounded
                  : good
                      ? Icons.check_circle_rounded
                      : Icons.refresh_rounded,
              color: Colors.white,
              size: 46,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strong
                ? t('Excellent reading!', 'Harika okuma!')
                : good
                    ? t('Nice work!', 'Güzel iş!')
                    : t('Good start — try again.',
                        'İyi başlangıç — tekrar dene.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            lesson.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(155),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: palette.start.withAlpha(14),
              border: Border.all(color: palette.start.withAlpha(36)),
            ),
            child: Text(
              earnedXP > 0
                  ? t('Progress saved · +$earnedXP XP',
                      'İlerleme kaydedildi · +$earnedXP XP')
                  : t('Already completed · XP saved before',
                      'Zaten tamamlandı · XP daha önce verildi'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(205),
                fontSize: 11.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProgressBar(value: percent / 100, palette: palette, height: 9),
        ],
      ),
    );
  }

  Widget _scoreGrid(_LevelPalette palette, int percent) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.quiz_rounded,
            value: '$score/$totalQuestions',
            label: t('Score', 'Skor'),
            color: palette.start,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.track_changes_rounded,
            value: '$percent%',
            label: t('Accuracy', 'Doğruluk'),
            color: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon: Icons.bolt_rounded,
            value: earnedXP > 0 ? '+$earnedXP' : '0',
            label: 'XP',
            color: const Color(0xFFFF8A00),
          ),
        ),
      ],
    );
  }

  Widget _lessonSummary(_LevelPalette palette) {
    return _GlassCard(
      radius: 28,
      padding: const EdgeInsets.all(16),
      accentColor: palette.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.menu_book_rounded,
            title: t('Lesson summary', 'Ders özeti'),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: lesson.icon,
            title: lesson.title,
            subtitle:
                '${lesson.level.code} · ${lesson.wordCount} ${t('words', 'kelime')} · ${lesson.estimatedMinutes} ${t('min', 'dk')}',
            color: palette.start,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: alreadyCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.stars_rounded,
            title: earnedXP > 0
                ? t('Progress saved', 'İlerleme kaydedildi')
                : t('Already completed', 'Zaten tamamlandı'),
            subtitle: earnedXP > 0
                ? t('This lesson was added to your progress.',
                    'Bu ders ilerlemene eklendi.')
                : t('XP is only awarded once per reading.',
                    'XP her okuma için sadece bir kez verilir.'),
            color: earnedXP > 0 ? const Color(0xFF22C55E) : Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, _LevelPalette palette) {
    final nextLesson = _nextLesson();

    return Column(
      children: [
        _ActionButton(
          icon: Icons.replay_rounded,
          label: t('Review this reading', 'Bu okumayı tekrar incele'),
          palette: palette,
          filled: false,
          onTap: () => Navigator.pop(context),
        ),
        if (nextLesson != null && nextLessonBuilder != null) ...[
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.arrow_forward_rounded,
            label: t('Next reading', 'Sonraki okuma'),
            palette: palette,
            filled: true,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => nextLessonBuilder!(nextLesson.id),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.list_rounded,
          label: t('Back to Reading list', 'Reading listesine dön'),
          palette: palette,
          filled: nextLesson == null || nextLessonBuilder == null,
          onTap: () {
            final navigator = Navigator.of(context);
            navigator.pop(); // close result screen
            if (navigator.canPop()) {
              navigator.pop(); // close reading detail, return to reading list
            }
          },
        ),
      ],
    );
  }

  ReadingLesson? _nextLesson() {
    final lessons = _repository.lessonsByLevel(lesson.level);
    final index = lessons.indexWhere((item) => item.id == lesson.id);
    if (index == -1 || index + 1 >= lessons.length) return null;
    return lessons[index + 1];
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withAlpha(14),
        border: Border.all(color: color.withAlpha(38)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(135),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final finalColor = color == Colors.white ? Colors.white70 : color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: finalColor.withAlpha(color == Colors.white ? 8 : 12),
        border: Border.all(
          color: finalColor.withAlpha(color == Colors.white ? 18 : 34),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: finalColor, size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(135),
                    fontSize: 11.2,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final _LevelPalette palette;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.palette,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: filled
              ? LinearGradient(colors: [palette.start, palette.end])
              : null,
          color: filled ? null : Colors.white.withAlpha(9),
          border: Border.all(
            color: filled ? Colors.transparent : palette.start.withAlpha(34),
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: palette.start.withAlpha(48),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 19),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final _LevelPalette palette;
  final double height;

  const _ProgressBar({
    required this.value,
    required this.palette,
    this.height = 7,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: Colors.white.withAlpha(18),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            widthFactor: safeValue,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [palette.start, palette.end]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color accentColor;

  const _GlassCard({
    required this.child,
    required this.padding,
    required this.radius,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(12),
                accentColor.withAlpha(9),
                Colors.white.withAlpha(7),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: accentColor.withAlpha(30)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TapScale({
    required this.child,
    required this.onTap,
  });

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
        scale: _pressed ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _LevelPalette {
  final Color start;
  final Color end;

  const _LevelPalette(this.start, this.end);
}

_LevelPalette _paletteForLevel(ReadingLevel level) {
  switch (level) {
    case ReadingLevel.a1:
      return const _LevelPalette(Color(0xFF06B6D4), Color(0xFF38BDF8));
    case ReadingLevel.a2:
      return const _LevelPalette(Color(0xFF22C55E), Color(0xFF06B6D4));
    case ReadingLevel.b1:
      return const _LevelPalette(Color(0xFFF59E0B), Color(0xFFFF8A00));
    case ReadingLevel.b2:
      return const _LevelPalette(Color(0xFFEC4899), Color(0xFF8B5CF6));
    case ReadingLevel.c1:
      return const _LevelPalette(Color(0xFF8B5CF6), Color(0xFF6366F1));
    case ReadingLevel.c2:
      return const _LevelPalette(Color(0xFFFF6B57), Color(0xFFEC4899));
  }
}
