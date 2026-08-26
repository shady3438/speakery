import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/reading/reading_models.dart';
import '../../data/reading/reading_repository.dart';

/// Standalone Speakery Reading module preview screen.
///
/// Put this file here:
/// lib/presentation/reading_screen/reading_module_screen.dart
///
/// This is compatible with the current Reading data structure:
/// - reading_models.dart
/// - reading_repository.dart
/// - reading_a1.dart
/// - reading_a2.dart
///
/// It does not depend on reading_seed_data.dart anymore.
class ReadingModuleScreen extends StatefulWidget {
  final bool isEnglish;

  const ReadingModuleScreen({
    super.key,
    this.isEnglish = true,
  });

  @override
  State<ReadingModuleScreen> createState() => _ReadingModuleScreenState();
}

class _ReadingModuleScreenState extends State<ReadingModuleScreen> {
  static const ReadingRepository _repository = ReadingRepository();

  ReadingLevel _selectedLevel = ReadingLevel.a1;
  ReadingLesson? _activeLesson;

  List<ReadingCluster> get _clusters {
    return _repository.clustersByLevel(_selectedLevel);
  }

  bool get isEnglish => widget.isEnglish;
  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final lesson = _activeLesson;

    return Scaffold(
      backgroundColor: const Color(0xFF080A14),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: lesson == null
            ? _ReadingHub(
                key: const ValueKey('reading_hub'),
                selectedLevel: _selectedLevel,
                clusters: _clusters,
                isEnglish: isEnglish,
                onLevelChanged: (level) {
                  setState(() => _selectedLevel = level);
                },
                onLessonTap: (lesson) {
                  setState(() => _activeLesson = lesson);
                },
              )
            : _ReadingLessonFlow(
                key: ValueKey('lesson_${lesson.id}'),
                lesson: lesson,
                isEnglish: isEnglish,
                onClose: () {
                  setState(() => _activeLesson = null);
                },
              ),
      ),
    );
  }
}

class _ReadingHub extends StatelessWidget {
  final ReadingLevel selectedLevel;
  final List<ReadingCluster> clusters;
  final bool isEnglish;
  final ValueChanged<ReadingLevel> onLevelChanged;
  final ValueChanged<ReadingLesson> onLessonTap;

  const _ReadingHub({
    super.key,
    required this.selectedLevel,
    required this.clusters,
    required this.isEnglish,
    required this.onLevelChanged,
    required this.onLessonTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final accent = selectedLevel.accent;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _HeroHeader(accent: accent, isEnglish: isEnglish),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 118,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: ReadingLevel.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final level = ReadingLevel.values[index];
                  return _LevelCard(
                    level: level,
                    selected: level == selectedLevel,
                    isEnglish: isEnglish,
                    onTap: () => onLevelChanged(level),
                  );
                },
              ),
            ),
          ),
          if (clusters.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              sliver: SliverToBoxAdapter(
                child: _EmptyLevelCard(
                  level: selectedLevel,
                  isEnglish: isEnglish,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              sliver: SliverList.separated(
                itemCount: clusters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final cluster = clusters[index];
                  return _ClusterCard(
                    cluster: cluster,
                    isEnglish: isEnglish,
                    onLessonTap: onLessonTap,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final Color accent;
  final bool isEnglish;

  const _HeroHeader({
    required this.accent,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      borderRadius: 32,
      padding: const EdgeInsets.all(22),
      gradientColors: [
        accent.withAlpha(61),
        const Color(0xFF22244A).withAlpha(148),
        const Color(0xFF121421).withAlpha(219),
      ],
      child: Row(
        children: [
          _IconOrb(
            icon: Icons.auto_stories_rounded,
            accent: accent,
            size: 58,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reading',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t(
                    'Read naturally, check understanding, and build real comprehension.',
                    'Doğal metinler oku, anladığını kontrol et ve gerçek okuma becerisi geliştir.',
                  ),
                  style: const TextStyle(
                    color: Color(0xFFC9CBE8),
                    fontSize: 14.5,
                    height: 1.35,
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

class _LevelCard extends StatelessWidget {
  final ReadingLevel level;
  final bool selected;
  final bool isEnglish;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.selected,
    required this.isEnglish,
    required this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final accent = level.accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: selected ? 126 : 104,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: selected ? accent.withAlpha(56) : Colors.white.withAlpha(14),
          border: Border.all(
            color:
                selected ? accent.withAlpha(184) : Colors.white.withAlpha(26),
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: accent.withAlpha(56),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(level.icon, color: accent, size: 24),
            const Spacer(),
            Text(
              level.code,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFFE0E1F4),
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
            ),
            Text(
              selected ? t('Selected', 'Seçili') : level.title.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFAEB1D1),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClusterCard extends StatelessWidget {
  final ReadingCluster cluster;
  final bool isEnglish;
  final ValueChanged<ReadingLesson> onLessonTap;

  const _ClusterCard({
    required this.cluster,
    required this.isEnglish,
    required this.onLessonTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final accent = cluster.level.accent;

    return _GlassPanel(
      borderRadius: 30,
      padding: const EdgeInsets.all(18),
      gradientColors: [
        Colors.white.withAlpha(23),
        Colors.white.withAlpha(11),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconOrb(icon: cluster.icon, accent: accent, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cluster.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cluster.subtitle,
                      style: const TextStyle(
                        color: Color(0xFFB7BAD7),
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniCountPill(
                accent: accent,
                label: t(
                  '${cluster.lessons.length} texts',
                  '${cluster.lessons.length} metin',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cluster.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LessonTile(
                lesson: lesson,
                isEnglish: isEnglish,
                onTap: () => onLessonTap(lesson),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final ReadingLesson lesson;
  final bool isEnglish;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.isEnglish,
    required this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final accent = lesson.level.accent;

    return GestureDetector(
      onTap: lesson.isPremium ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: lesson.isPremium
              ? Colors.white.withAlpha(8)
              : Colors.white.withAlpha(14),
          border: Border.all(
            color: lesson.isPremium
                ? Colors.white.withAlpha(14)
                : Colors.white.withAlpha(20),
          ),
        ),
        child: Row(
          children: [
            _IconOrb(
              icon: lesson.isPremium ? Icons.lock_rounded : lesson.icon,
              accent: accent,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: lesson.isPremium
                          ? Colors.white.withAlpha(140)
                          : Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.isPremium
                        ? t('Premium reading lesson', 'Premium okuma dersi')
                        : '${lesson.textType} • ${lesson.wordCount} ${t('words', 'kelime')} • ${lesson.estimatedMinutes} ${t('min', 'dk')}',
                    style: const TextStyle(
                      color: Color(0xFFAEB1D1),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              lesson.isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: accent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLevelCard extends StatelessWidget {
  final ReadingLevel level;
  final bool isEnglish;

  const _EmptyLevelCard({
    required this.level,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      borderRadius: 30,
      padding: const EdgeInsets.all(22),
      gradientColors: [
        level.accent.withAlpha(31),
        Colors.white.withAlpha(11),
      ],
      child: Column(
        children: [
          _IconOrb(
            icon: level.icon,
            accent: level.accent,
            size: 58,
          ),
          const SizedBox(height: 14),
          Text(
            t(
              'No texts found for ${level.code}.',
              '${level.code} için metin bulunamadı.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            t(
              'Use the level selector to jump to an available reading pack.',
              'Hazır okuma paketine geçmek için seviye seçiciyi kullan.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFB7BAD7),
              height: 1.35,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingLessonFlow extends StatefulWidget {
  final ReadingLesson lesson;
  final bool isEnglish;
  final VoidCallback onClose;

  const _ReadingLessonFlow({
    super.key,
    required this.lesson,
    required this.isEnglish,
    required this.onClose,
  });

  @override
  State<_ReadingLessonFlow> createState() => _ReadingLessonFlowState();
}

class _ReadingLessonFlowState extends State<_ReadingLessonFlow> {
  int _step = 0;
  int _questionIndex = 0;
  final Map<String, String> _answers = {};

  ReadingLesson get lesson => widget.lesson;
  bool get isEnglish => widget.isEnglish;
  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final accent = lesson.level.accent;

    return SafeArea(
      child: Column(
        children: [
          _LessonTopBar(
            accent: accent,
            title: lesson.title,
            step: _step,
            isEnglish: isEnglish,
            onBack: _step == 0
                ? widget.onClose
                : () => setState(() => _step = (_step - 1).clamp(0, 2)),
            onClose: widget.onClose,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              child: _buildStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    if (_step == 0) {
      return _BeforeReadView(
        key: const ValueKey('before'),
        lesson: lesson,
        isEnglish: isEnglish,
        onStart: () => setState(() => _step = 1),
      );
    }

    if (_step == 1) {
      return _ReaderView(
        key: const ValueKey('reader'),
        lesson: lesson,
        isEnglish: isEnglish,
        onFinished: () => setState(() => _step = 2),
      );
    }

    final question = lesson.questions[_questionIndex];

    return _QuestionView(
      key: const ValueKey('questions'),
      lesson: lesson,
      index: _questionIndex,
      isEnglish: isEnglish,
      selectedAnswer: _answers[question.id],
      onSelected: (value) => setState(() => _answers[question.id] = value),
      onNext: () {
        if (_questionIndex < lesson.questions.length - 1) {
          setState(() => _questionIndex++);
        } else {
          _showCompletionSheet(context);
        }
      },
    );
  }

  void _showCompletionSheet(BuildContext context) {
    final score =
        lesson.questions.where((q) => _answers[q.id] == q.answer).length;
    final total = lesson.questions.length;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _GlassPanel(
          margin: const EdgeInsets.all(16),
          borderRadius: 32,
          padding: const EdgeInsets.all(22),
          gradientColors: [
            lesson.level.accent.withAlpha(51),
            const Color(0xFF111320).withAlpha(240),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconOrb(
                icon: Icons.emoji_events_rounded,
                accent: lesson.level.accent,
                size: 64,
              ),
              const SizedBox(height: 14),
              Text(
                t('Reading complete', 'Okuma tamamlandı'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('Score: $score / $total', 'Puan: $score / $total'),
                style: const TextStyle(
                  color: Color(0xFFD9DBF5),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onClose();
                },
                child: Text(t('Back to Reading', 'Reading’e dön')),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LessonTopBar extends StatelessWidget {
  final Color accent;
  final String title;
  final int step;
  final bool isEnglish;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const _LessonTopBar({
    required this.accent,
    required this.title,
    required this.step,
    required this.isEnglish,
    required this.onBack,
    required this.onClose,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (step + 1) / 3,
                    minHeight: 5,
                    backgroundColor: Colors.white.withAlpha(26),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: t('Close', 'Kapat'),
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _BeforeReadView extends StatelessWidget {
  final ReadingLesson lesson;
  final bool isEnglish;
  final VoidCallback onStart;

  const _BeforeReadView({
    super.key,
    required this.lesson,
    required this.isEnglish,
    required this.onStart,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final accent = lesson.level.accent;
    final showTurkish = !isEnglish ||
        lesson.level == ReadingLevel.a1 ||
        lesson.level == ReadingLevel.a2;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        _GlassPanel(
          borderRadius: 34,
          padding: const EdgeInsets.all(24),
          gradientColors: [
            accent.withAlpha(56),
            Colors.white.withAlpha(14),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconOrb(icon: lesson.icon, accent: accent, size: 62),
              const SizedBox(height: 18),
              Text(
                lesson.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.orientationEnglish,
                style: const TextStyle(
                  color: Color(0xFFE2E4FA),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
              if (showTurkish && lesson.orientationTurkish != null) ...[
                const SizedBox(height: 14),
                Text(
                  lesson.orientationTurkish!,
                  style: const TextStyle(
                    color: Color(0xFFBFC2DF),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              if (showTurkish && lesson.readingTipTurkish != null) ...[
                const SizedBox(height: 18),
                _TipCard(text: lesson.readingTipTurkish!, accent: accent),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(t('Start Reading', 'Okumaya başla')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReaderView extends StatelessWidget {
  final ReadingLesson lesson;
  final bool isEnglish;
  final VoidCallback onFinished;

  const _ReaderView({
    super.key,
    required this.lesson,
    required this.isEnglish,
    required this.onFinished,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final accent = lesson.level.accent;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        ...lesson.paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _GlassPanel(
              borderRadius: 26,
              padding: const EdgeInsets.all(20),
              gradientColors: [
                Colors.white.withAlpha(17),
                Colors.white.withAlpha(8),
              ],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${paragraph.number}',
                    style: TextStyle(
                      color: accent.withAlpha(204),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      paragraph.text,
                      style: const TextStyle(
                        color: Color(0xFFF4F5FF),
                        fontSize: 17,
                        height: 1.75,
                        letterSpacing: .1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onFinished,
          icon: const Icon(Icons.check_circle_rounded),
          label: Text(t('Finished Reading', 'Okumayı bitirdim')),
        ),
      ],
    );
  }
}

class _QuestionView extends StatelessWidget {
  final ReadingLesson lesson;
  final int index;
  final bool isEnglish;
  final String? selectedAnswer;
  final ValueChanged<String> onSelected;
  final VoidCallback onNext;

  const _QuestionView({
    super.key,
    required this.lesson,
    required this.index,
    required this.isEnglish,
    required this.selectedAnswer,
    required this.onSelected,
    required this.onNext,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final question = lesson.questions[index];
    final accent = lesson.level.accent;
    final hasAnswer = selectedAnswer != null;
    final isCorrect = selectedAnswer == question.answer;
    final explanation = isEnglish
        ? question.explanationEnglish
        : (question.explanationTurkish ?? question.explanationEnglish);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        _GlassPanel(
          borderRadius: 30,
          padding: const EdgeInsets.all(20),
          gradientColors: [
            Colors.white.withAlpha(19),
            Colors.white.withAlpha(9),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(
                  'Question ${index + 1} of ${lesson.questions.length}',
                  'Soru ${index + 1} / ${lesson.questions.length}',
                ),
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                question.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 18),
              ...question.options.map((option) {
                final selected = option == selectedAnswer;
                final correct = option == question.answer;
                final showState = hasAnswer && (selected || correct);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: hasAnswer ? null : () => onSelected(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: showState
                            ? (correct
                                ? Colors.greenAccent.withAlpha(43)
                                : Colors.redAccent.withAlpha(38))
                            : selected
                                ? accent.withAlpha(46)
                                : Colors.white.withAlpha(14),
                        border: Border.all(
                          color: showState
                              ? (correct
                                  ? Colors.greenAccent
                                  : Colors.redAccent)
                              : selected
                                  ? accent
                                  : Colors.white.withAlpha(23),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            showState
                                ? (correct
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded)
                                : Icons.circle_outlined,
                            color: showState
                                ? (correct
                                    ? Colors.greenAccent
                                    : Colors.redAccent)
                                : selected
                                    ? accent
                                    : const Color(0xFFAEB1D1),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (hasAnswer) ...[
                const SizedBox(height: 12),
                _FeedbackCard(
                  correct: isCorrect,
                  explanation: explanation,
                  evidence: question.evidenceText,
                  accent: accent,
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: hasAnswer ? onNext : null,
                  child: Text(
                    index == lesson.questions.length - 1
                        ? t('Complete', 'Tamamla')
                        : t('Next Question', 'Sonraki soru'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool correct;
  final String explanation;
  final String? evidence;
  final Color accent;

  const _FeedbackCard({
    required this.correct,
    required this.explanation,
    required this.accent,
    this.evidence,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? Colors.greenAccent : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(107)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? 'Correct' : 'Check the text',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            explanation,
            style: const TextStyle(
              color: Color(0xFFE6E7F8),
              height: 1.35,
            ),
          ),
          if (evidence != null) ...[
            const SizedBox(height: 8),
            Text(
              '“$evidence”',
              style: TextStyle(
                color: accent.withAlpha(224),
                height: 1.35,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String text;
  final Color accent;

  const _TipCard({
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withAlpha(26),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withAlpha(89)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE4E6FA),
                height: 1.35,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCountPill extends StatelessWidget {
  final Color accent;
  final String label;

  const _MiniCountPill({
    required this.accent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withAlpha(31),
        border: Border.all(color: accent.withAlpha(77)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _IconOrb extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final double size;

  const _IconOrb({
    required this.icon,
    required this.accent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withAlpha(41),
        border: Border.all(color: accent.withAlpha(115)),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(46),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: accent, size: size * .46),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final List<Color> gradientColors;

  const _GlassPanel({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.borderRadius = 28,
    this.gradientColors = const [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
