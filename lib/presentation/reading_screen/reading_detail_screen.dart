import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../data/reading/reading_models.dart';
import '../../data/reading/reading_repository.dart';
import '../../data/reading/reading_progress_store.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/premium_feedback.dart';
import '../premium_screen/premium_screen.dart';
import 'reading_result_screen.dart';

class ReadingDetailScreen extends StatefulWidget {
  final String passageId;
  final bool isEnglish;

  const ReadingDetailScreen({
    super.key,
    required this.passageId,
    required this.isEnglish,
  });

  @override
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen>
    with TickerProviderStateMixin {
  static const ReadingRepository _repository = ReadingRepository();

  late TabController _tabController;
  late AnimationController _tabFadeCtrl;
  late Animation<double> _tabFade;
  final Map<String, String> _checkAnswers = <String, String>{};

  String get passageId => widget.passageId;
  bool get isEnglish => widget.isEnglish;
  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1.0,
    );
    _tabFade = CurvedAnimation(
      parent: _tabFadeCtrl,
      curve: Curves.easeOutCubic,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _tabFadeCtrl.reverse().then((_) {
          if (mounted) _tabFadeCtrl.forward();
        });
      }
    });

    ReadingProgressStore.instance.markOpened(passageId);
  }

  void _recordCheckAnswer(String questionId, String answer) {
    setState(() => _checkAnswers[questionId] = answer);
    final lesson = _repository.lessonById(passageId);
    if (lesson == null) return;
    final question = lesson.questions.where((item) => item.id == questionId);
    if (question.isEmpty) return;
    final correct = question.first.answer == answer;
    PremiumFeedback.show(
      context,
      message: correct
          ? (widget.isEnglish
              ? 'Correct. Voxa spotted the detail with you.'
              : 'Doğru. Voxa detayı seninle birlikte yakaladı.')
          : (widget.isEnglish
              ? 'Look at the passage once more. Voxa is thinking too.'
              : 'Metne bir kez daha bak. Voxa da düşünüyor.'),
      tone: correct ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );
  }

  int _scoreForLesson(ReadingLesson lesson) {
    var score = 0;
    for (final question in lesson.questions) {
      if (_checkAnswers[question.id] == question.answer) {
        score += 1;
      }
    }
    return score;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabFadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _repository.lessonById(passageId);
    final tokens = SpeakeryThemeTokens.of(context);

    if (lesson == null) {
      return Scaffold(
        backgroundColor: tokens.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded,
                    color: tokens.mutedText.withAlpha(150), size: 44),
                const SizedBox(height: 12),
                Text(
                  t('Reading not found.', 'Okuma metni bulunamadı.'),
                  style: TextStyle(
                    color: tokens.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final palette = _paletteForLevel(lesson.level);

    return Scaffold(
      backgroundColor: tokens.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.85),
            radius: 1.2,
            colors: [
              palette.start.withAlpha(tokens.isLight ? 24 : 44),
              tokens.backgroundEnd,
              tokens.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────
              _TopBar(
                lesson: lesson,
                palette: palette,
                isEnglish: isEnglish,
              ),
              const SizedBox(height: 10),

              // ── Tab bar (single blur, stays fixed) ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SegmentedTabBar(
                  controller: _tabController,
                  palette: palette,
                  isEnglish: isEnglish,
                ),
              ),
              const SizedBox(height: 12),

              // ── Tab content with fade ────────────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _tabFade,
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _ReadTab(
                        lesson: lesson,
                        palette: palette,
                        isEnglish: isEnglish,
                      ),
                      _WordsTab(
                        lesson: lesson,
                        palette: palette,
                        isEnglish: isEnglish,
                      ),
                      _CheckTab(
                        lesson: lesson,
                        palette: palette,
                        isEnglish: isEnglish,
                        chosenAnswers: _checkAnswers,
                        onAnswerChanged: _recordCheckAnswer,
                        onAllAnswered: () {
                          // Auto-advance to task tab after a brief delay
                          Future.delayed(
                            const Duration(milliseconds: 600),
                            () {
                              if (mounted && _tabController.index == 2) {
                                _tabController.animateTo(3);
                              }
                            },
                          );
                        },
                      ),
                      _AfterReadingTab(
                        lesson: lesson,
                        palette: palette,
                        isEnglish: isEnglish,
                        score: _scoreForLesson(lesson),
                        totalQuestions: lesson.questions.length,
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// SEGMENTED TAB BAR  — single BackdropFilter for the whole bar
// ─────────────────────────────────────────────────────────────────────────────

class _SegmentedTabBar extends StatelessWidget {
  final TabController controller;
  final _LevelPalette palette;
  final bool isEnglish;

  const _SegmentedTabBar({
    required this.controller,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withAlpha(9),
            border: Border.all(
              color: palette.start.withAlpha(36),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: TabBar(
            controller: controller,
            dividerColor: Colors.transparent,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.start, palette.end],
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.start.withAlpha(55),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withAlpha(130),
            labelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.05,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            tabs: [
              Tab(text: t('Read', 'Oku')),
              Tab(text: t('Words', 'Kelime')),
              Tab(text: t('Check', 'Kontrol')),
              Tab(text: t('Task', 'Görev')),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;

  const _TopBar({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: _SolidCard(
        radius: 26,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        accentColor: palette.start,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back
            _TapScale(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withAlpha(10),
                  border: Border.all(color: Colors.white.withAlpha(18)),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 19),
              ),
            ),
            const SizedBox(width: 12),

            // Title block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon badge
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: lesson.isPremium
                              ? null
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [palette.start, palette.end],
                                ),
                          color: lesson.isPremium
                              ? Colors.white.withAlpha(8)
                              : null,
                          border: Border.all(color: Colors.white.withAlpha(14)),
                          boxShadow: lesson.isPremium
                              ? null
                              : [
                                  BoxShadow(
                                    color: palette.start.withAlpha(50),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Icon(
                          lesson.isPremium ? Icons.lock_rounded : lesson.icon,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lesson.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status pill
                      AnimatedBuilder(
                        animation: AppProgress.instance,
                        builder: (ctx, _) {
                          final done = !lesson.isPremium &&
                              AppProgress.instance.isLessonCompleted(lesson.id);
                          return _StatusPill(done: done, isEnglish: isEnglish);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    lesson.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(160),
                      fontSize: 12.2,
                      height: 1.32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _LevelBadge(palette: palette, code: lesson.level.code),
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: lesson.isPremium
                            ? '--'
                            : '${lesson.estimatedMinutes} ${t('min', 'dk')}',
                      ),
                      _MetaChip(
                        icon: Icons.text_snippet_outlined,
                        label: lesson.isPremium
                            ? '--'
                            : '${lesson.wordCount} ${t('words', 'kelime')}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// READ TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ReadTab extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;

  const _ReadTab({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    if (lesson.isPremium) {
      return _EmptyLocked(level: lesson.level, isEnglish: isEnglish);
    }

    final showTurkishSupport = !isEnglish ||
        lesson.level == ReadingLevel.a1 ||
        lesson.level == ReadingLevel.a2;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _ReadHeroCard(
          lesson: lesson,
          palette: palette,
          isEnglish: isEnglish,
        ),
        const SizedBox(height: 12),
        if (showTurkishSupport &&
            (lesson.orientationTurkish != null ||
                lesson.readingTipTurkish != null)) ...[
          _WarmUpCard(lesson: lesson, palette: palette, isEnglish: isEnglish),
          const SizedBox(height: 12),
        ],
        _PaperSheet(
          tint: palette.start,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReadingPaperHeader(
                lesson: lesson,
                palette: palette,
                isEnglish: isEnglish,
              ),
              const SizedBox(height: 12),
              SelectionArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < lesson.paragraphs.length; i++) ...[
                      _ParagraphBlock(
                        paragraph: lesson.paragraphs[i],
                        palette: palette,
                      ),
                      if (i < lesson.paragraphs.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadHeroCard extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;

  const _ReadHeroCard({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _SolidCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      accentColor: palette.start,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [palette.start, palette.end]),
              boxShadow: [
                BoxShadow(
                  color: palette.start.withAlpha(45),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Read with focus', 'Odaklanarak oku'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t(
                    'First catch the main idea, then check details.',
                    'Önce ana fikri yakala, sonra detayları kontrol et.',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12.1,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${lesson.estimatedMinutes} ${t('min read', 'dk okuma')} • ${lesson.wordCount} ${t('words', 'kelime')}',
                  style: TextStyle(
                    color: palette.start.withAlpha(210),
                    fontSize: 11.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.05,
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

class _ReadingPaperHeader extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;

  const _ReadingPaperHeader({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: palette.start.withAlpha(18),
            border: Border.all(color: palette.start.withAlpha(44)),
          ),
          child: Icon(lesson.icon, color: palette.start, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                t('Read slowly. Understand the story.',
                    'Yavaş oku. Metnin anlamını yakala.'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(135),
                  fontSize: 11.7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParagraphBlock extends StatelessWidget {
  final ReadingParagraph paragraph;
  final _LevelPalette palette;

  const _ParagraphBlock({
    required this.paragraph,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withAlpha(6),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 23,
            height: 23,
            margin: const EdgeInsets.only(top: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.start.withAlpha(22),
              border: Border.all(color: palette.start.withAlpha(50)),
            ),
            child: Text(
              '${paragraph.number}',
              style: TextStyle(
                color: palette.start,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              paragraph.text,
              style: const TextStyle(
                color: Color(0xFFF2EFFF),
                fontSize: 15.4,
                height: 1.66,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WARM-UP CARD — solid, no blur
// ─────────────────────────────────────────────────────────────────────────────

class _WarmUpCard extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;

  const _WarmUpCard({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final showTurkish = !isEnglish ||
        lesson.level == ReadingLevel.a1 ||
        lesson.level == ReadingLevel.a2;

    return _SolidCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      accentColor: palette.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: palette.start, size: 17),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lesson.orientationEnglish,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (showTurkish && lesson.orientationTurkish != null) ...[
            const SizedBox(height: 8),
            Text(
              lesson.orientationTurkish!,
              style: TextStyle(
                color: Colors.white.withAlpha(148),
                fontSize: 12,
                height: 1.38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (showTurkish && lesson.readingTipTurkish != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: palette.start.withAlpha(16),
                border: Border.all(color: palette.start.withAlpha(38)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded, color: palette.start, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lesson.readingTipTurkish!,
                      style: TextStyle(
                        color: Colors.white.withAlpha(155),
                        fontSize: 11.8,
                        height: 1.38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WORDS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _WordsTab extends StatelessWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;

  const _WordsTab({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    if (lesson.isPremium) {
      return _EmptyLocked(level: lesson.level, isEnglish: isEnglish);
    }

    final glosses = lesson.glosses;
    final review = lesson.vocabularyReview;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _TabTitle(
          title: t('Key words', 'Anahtar kelimeler'),
          subtitle: t(
            'Each word shown in its original context.',
            'Her kelime kendi bağlamında gösterilmiştir.',
          ),
        ),
        const SizedBox(height: 12),
        if (glosses.isEmpty && review.isEmpty) ...[
          _SmallEmpty(
            icon: Icons.check_circle_outline_rounded,
            title: t('All clear', 'Sorun yok'),
            subtitle: t(
              'This lesson uses simple vocabulary.',
              'Bu ders temel kelime kadrosuyla hazırlandı.',
            ),
            palette: palette,
          ),
        ],
        for (var i = 0; i < glosses.length; i++) ...[
          _GlossCard(
            gloss: glosses[i],
            palette: palette,
            number: i + 1,
            isEnglish: isEnglish,
          ),
          if (i < glosses.length - 1) const SizedBox(height: 9),
        ],
        if (review.isNotEmpty) ...[
          const SizedBox(height: 20),
          _TabTitle(
            title: t('Review', 'Tekrar'),
            subtitle: t(
              'The same word in a new sentence.',
              'Aynı kelime, yeni bir cümlede.',
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < review.length; i++) ...[
            _ReviewWordCard(
              item: review[i],
              palette: palette,
              number: i + 1,
              isEnglish: isEnglish,
            ),
            if (i < review.length - 1) const SizedBox(height: 9),
          ],
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK TAB
// ─────────────────────────────────────────────────────────────────────────────

class _CheckTab extends StatefulWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;
  final Map<String, String> chosenAnswers;
  final void Function(String questionId, String answer) onAnswerChanged;
  final VoidCallback? onAllAnswered;

  const _CheckTab({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
    required this.chosenAnswers,
    required this.onAnswerChanged,
    this.onAllAnswered,
  });

  @override
  State<_CheckTab> createState() => _CheckTabState();
}

class _CheckTabState extends State<_CheckTab> {
  final Set<String> _revealed = {};

  bool get isEnglish => widget.isEnglish;
  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final palette = widget.palette;

    if (lesson.isPremium) {
      return _EmptyLocked(level: lesson.level, isEnglish: isEnglish);
    }

    final total = lesson.questions.length;
    final answered = widget.chosenAnswers.length;
    final progress = total == 0 ? 0.0 : answered / total;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _TabTitle(
          title: t('Check comprehension', 'Anladığını kontrol et'),
          subtitle: t(
            '$answered of $total answered',
            '$total sorudan $answered\'ı cevaplandı',
          ),
        ),
        const SizedBox(height: 10),

        // Progress bar
        _ProgressBar(value: progress, palette: palette),
        const SizedBox(height: 14),

        for (var i = 0; i < lesson.questions.length; i++) ...[
          _QuestionCard(
            question: lesson.questions[i],
            questionNumber: i + 1,
            palette: palette,
            isEnglish: isEnglish,
            chosenAnswer: widget.chosenAnswers[lesson.questions[i].id],
            revealed: _revealed.contains(lesson.questions[i].id),
            onChoose: (answer) {
              final wasNew =
                  !widget.chosenAnswers.containsKey(lesson.questions[i].id);
              widget.onAnswerChanged(lesson.questions[i].id, answer);
              final nextAnswered =
                  widget.chosenAnswers.length + (wasNew ? 1 : 0);
              if (nextAnswered == total) {
                widget.onAllAnswered?.call();
              }
            },
            onToggleReveal: () => setState(() {
              final id = lesson.questions[i].id;
              if (_revealed.contains(id)) {
                _revealed.remove(id);
              } else {
                _revealed.add(id);
              }
            }),
          ),
          if (i < lesson.questions.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AFTER READING TAB
// ─────────────────────────────────────────────────────────────────────────────

class _AfterReadingTab extends StatefulWidget {
  final ReadingLesson lesson;
  final _LevelPalette palette;
  final bool isEnglish;
  final int score;
  final int totalQuestions;

  const _AfterReadingTab({
    required this.lesson,
    required this.palette,
    required this.isEnglish,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<_AfterReadingTab> createState() => _AfterReadingTabState();
}

class _AfterReadingTabState extends State<_AfterReadingTab> {
  final TextEditingController _ctrl = TextEditingController();

  bool get isEnglish => widget.isEnglish;
  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final palette = widget.palette;

    if (lesson.isPremium) {
      return _EmptyLocked(level: lesson.level, isEnglish: isEnglish);
    }

    final prompt = isEnglish
        ? (lesson.reflectionPrompt ??
            'Write 2–3 sentences about this text. What did you understand?')
        : (lesson.reflectionPromptTurkish ??
            'Bu metin hakkında 2–3 cümle yaz. Ne anladın?');

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        _TaskHeader(
          palette: palette,
          isEnglish: isEnglish,
        ),
        const SizedBox(height: 12),
        _TaskPromptCard(
          prompt: prompt,
          palette: palette,
          isEnglish: isEnglish,
        ),
        const SizedBox(height: 12),
        _WritingBox(
          controller: _ctrl,
          palette: palette,
          isEnglish: isEnglish,
        ),
        const SizedBox(height: 14),
        AnimatedBuilder(
          animation: AppProgress.instance,
          builder: (ctx, _) {
            final done = AppProgress.instance.isLessonCompleted(lesson.id);
            return _CompleteButton(
              done: done,
              palette: palette,
              isEnglish: isEnglish,
              onTap: () {
                final wasAlreadyCompleted =
                    AppProgress.instance.isLessonCompleted(lesson.id);
                if (!wasAlreadyCompleted) {
                  AppProgress.instance.completeLesson(
                    lesson.id,
                    rewardXP: 25,
                  );
                }

                ReadingProgressStore.instance.recordAttempt(
                  lessonId: lesson.id,
                  score: widget.score,
                  totalQuestions: widget.totalQuestions,
                  completed: true,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeakeryThemeAdapter(
                      child: ReadingResultScreen(
                        lesson: lesson,
                        score: widget.score,
                        totalQuestions: widget.totalQuestions,
                        earnedXP: wasAlreadyCompleted ? 0 : 25,
                        alreadyCompleted: wasAlreadyCompleted,
                        isEnglish: isEnglish,
                        nextLessonBuilder: (nextLessonId) =>
                            SpeakeryThemeAdapter(
                          child: ReadingDetailScreen(
                            passageId: nextLessonId,
                            isEnglish: isEnglish,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _TaskHeader extends StatelessWidget {
  final _LevelPalette palette;
  final bool isEnglish;

  const _TaskHeader({
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _SolidCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      accentColor: palette.start,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [palette.start, palette.end]),
              boxShadow: [
                BoxShadow(
                  color: palette.start.withAlpha(42),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t('Your task', 'Görevin'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskPromptCard extends StatelessWidget {
  final String prompt;
  final _LevelPalette palette;
  final bool isEnglish;

  const _TaskPromptCard({
    required this.prompt,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _SolidCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      accentColor: palette.start,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.edit_note_rounded,
            color: palette.start,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              prompt,
              style: TextStyle(
                color: Colors.white.withAlpha(185),
                fontSize: 13.2,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WritingBox extends StatelessWidget {
  final TextEditingController controller;
  final _LevelPalette palette;
  final bool isEnglish;

  const _WritingBox({
    required this.controller,
    required this.palette,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final words = _wordCount(controller.text);
        final hasText = controller.text.trim().isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.start.withAlpha(hasText ? 105 : 58),
                Colors.white.withAlpha(18),
                palette.end.withAlpha(hasText ? 82 : 34),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: hasText
                    ? palette.start.withAlpha(30)
                    : Colors.black.withAlpha(34),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF111827).withAlpha(228),
                  const Color(0xFF0B1020).withAlpha(238),
                  palette.start.withAlpha(hasText ? 18 : 10),
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 13, 15, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.start.withAlpha(18),
                          border: Border.all(
                            color: palette.start.withAlpha(42),
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: palette.start,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        t('Your response', 'Cevabın'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: palette.start.withAlpha(hasText ? 20 : 9),
                          border: Border.all(
                            color: palette.start.withAlpha(hasText ? 46 : 20),
                          ),
                        ),
                        child: Text(
                          t('$words words', '$words kelime'),
                          style: TextStyle(
                            color: hasText
                                ? palette.start.withAlpha(235)
                                : Colors.white.withAlpha(120),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF070B16).withAlpha(135),
                    border: Border.all(
                      color: Colors.white.withAlpha(10),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 7,
                    minLines: 6,
                    textInputAction: TextInputAction.newline,
                    cursorColor: palette.start,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.55,
                    ),
                    decoration: InputDecoration(
                      hintText: t(
                        'Write your short answer here...',
                        'Kısa cevabını buraya yaz...',
                      ),
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha(82),
                        fontWeight: FontWeight.w600,
                        fontSize: 13.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(14, 13, 14, 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _wordCount(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 0;
    return clean
        .split(RegExp(r'\\s+'))
        .where((w) => w.trim().isNotEmpty)
        .length;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPLETE BUTTON  — animated state
// ─────────────────────────────────────────────────────────────────────────────

class _CompleteButton extends StatelessWidget {
  final bool done;
  final _LevelPalette palette;
  final bool isEnglish;
  final VoidCallback? onTap;

  const _CompleteButton({
    required this.done,
    required this.palette,
    required this.isEnglish,
    this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap ?? () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: done
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.start, palette.end],
                ),
          color: done ? Colors.white.withAlpha(10) : null,
          border: Border.all(
            color: done
                ? const Color(0xFF22C55E).withAlpha(55)
                : Colors.transparent,
          ),
          boxShadow: done
              ? null
              : [
                  BoxShadow(
                    color: palette.start.withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.flag_rounded,
              color: done ? const Color(0xFF22C55E) : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              done
                  ? t('Completed', 'Tamamlandı')
                  : t('Finish Reading', 'Okumayı Bitir'),
              style: TextStyle(
                color: done ? const Color(0xFF22C55E) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUESTION CARD  — solid, no per-card blur
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final ReadingQuestion question;
  final int questionNumber;
  final _LevelPalette palette;
  final bool isEnglish;
  final String? chosenAnswer;
  final bool revealed;
  final ValueChanged<String> onChoose;
  final VoidCallback onToggleReveal;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.palette,
    required this.isEnglish,
    required this.chosenAnswer,
    required this.revealed,
    required this.onChoose,
    required this.onToggleReveal,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  static const _optionLabels = ['A', 'B', 'C', 'D', 'E'];

  String _typeLabel(ReadingQuestionType type) {
    switch (type) {
      case ReadingQuestionType.multipleChoice:
        return t('Multiple choice', 'Çoktan seçmeli');
      case ReadingQuestionType.trueFalse:
        return t('True / False', 'Doğru / Yanlış');
      case ReadingQuestionType.trueFalseNotGiven:
        return t('T / F / NG', 'D / Y / Belirsiz');
      case ReadingQuestionType.mainIdea:
        return t('Main idea', 'Ana fikir');
      case ReadingQuestionType.detail:
        return t('Detail', 'Detay');
      case ReadingQuestionType.inference:
        return t('Inference', 'Çıkarım');
      case ReadingQuestionType.vocabularyInContext:
        return t('Vocabulary', 'Kelime');
      case ReadingQuestionType.matchingHeadings:
        return t('Headings', 'Başlık eşleştirme');
      case ReadingQuestionType.sequence:
        return t('Sequence', 'Sıralama');
      case ReadingQuestionType.gapFill:
        return t('Gap fill', 'Boşluk doldurma');
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = question.options;
    final hasOptions = options.isNotEmpty;
    final isAnswered = chosenAnswer != null;
    final explanation = isEnglish
        ? question.explanationEnglish
        : (question.explanationTurkish ?? question.explanationEnglish);

    return _SolidCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      accentColor: palette.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _QuestionNumber(number: questionNumber, palette: palette),
              const SizedBox(width: 8),
              _TypeChip(label: _typeLabel(question.type), palette: palette),
              const Spacer(),
              if (!hasOptions)
                _TapScale(
                  onTap: onToggleReveal,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withAlpha(7),
                      border: Border.all(color: Colors.white.withAlpha(14)),
                    ),
                    child: Text(
                      revealed ? t('Hide', 'Gizle') : t('Answer', 'Cevap'),
                      style: TextStyle(
                        color: Colors.white.withAlpha(160),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 11),

          // Question text
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.38,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),

          // Options
          if (hasOptions) ...[
            const SizedBox(height: 11),
            ...List.generate(options.length, (i) {
              return _OptionRow(
                label: options[i],
                displayLetter:
                    i < _optionLabels.length ? _optionLabels[i] : '${i + 1}',
                isAnswered: isAnswered,
                correctAnswer: question.answer,
                chosenAnswer: chosenAnswer,
                onTap: isAnswered ? null : () => onChoose(options[i]),
              );
            }),
          ],

          // Explanation block (shown after answer or reveal)
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: (!hasOptions && revealed) || (hasOptions && isAnswered)
                ? _ExplanationBlock(
                    explanation: explanation,
                    evidenceText: question.evidenceText,
                    palette: palette,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPLANATION BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class _ExplanationBlock extends StatelessWidget {
  final String explanation;
  final String? evidenceText;
  final _LevelPalette palette;

  const _ExplanationBlock({
    required this.explanation,
    required this.evidenceText,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withAlpha(6),
          border: Border.all(color: Colors.white.withAlpha(14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              explanation,
              style: TextStyle(
                color: Colors.white.withAlpha(172),
                fontSize: 12.2,
                height: 1.42,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (evidenceText != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: palette.start.withAlpha(14),
                  border: Border.all(color: palette.start.withAlpha(35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded,
                        color: palette.start, size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        evidenceText!,
                        style: TextStyle(
                          color: palette.start.withAlpha(230),
                          fontSize: 12,
                          height: 1.38,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTION ROW  — fixed A/B/C/D letters
// ─────────────────────────────────────────────────────────────────────────────

class _OptionRow extends StatelessWidget {
  final String label;
  final String displayLetter;
  final bool isAnswered;
  final String correctAnswer;
  final String? chosenAnswer;
  final VoidCallback? onTap;

  const _OptionRow({
    required this.label,
    required this.displayLetter,
    required this.isAnswered,
    required this.correctAnswer,
    required this.chosenAnswer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = isAnswered && label == correctAnswer;
    final isWrongChosen =
        isAnswered && label == chosenAnswer && chosenAnswer != correctAnswer;

    return _TapScale(
      onTap: onTap ?? () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _bg(isCorrect, isWrongChosen),
          border: Border.all(
            color: _border(isCorrect, isWrongChosen),
            width: isCorrect || isWrongChosen ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Fixed letter badge
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _letterBg(isCorrect, isWrongChosen),
                border: Border.all(
                    color: _border(isCorrect, isWrongChosen).withAlpha(80)),
              ),
              child: Text(
                displayLetter,
                style: TextStyle(
                  color: _letterColor(isCorrect, isWrongChosen),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withAlpha(
                      isAnswered && !isCorrect && !isWrongChosen ? 170 : 235),
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF22C55E), size: 17)
            else if (isWrongChosen)
              const Icon(Icons.cancel_rounded,
                  color: Color(0xFFFF5B8A), size: 17),
          ],
        ),
      ),
    );
  }

  Color _bg(bool correct, bool wrong) {
    if (correct) return const Color(0xFF22C55E).withAlpha(15);
    if (wrong) return const Color(0xFFFF5B8A).withAlpha(12);
    return Colors.white.withAlpha(6);
  }

  Color _border(bool correct, bool wrong) {
    if (correct) return const Color(0xFF22C55E).withAlpha(60);
    if (wrong) return const Color(0xFFFF5B8A).withAlpha(55);
    return Colors.white.withAlpha(13);
  }

  Color _letterBg(bool correct, bool wrong) {
    if (correct) return const Color(0xFF22C55E).withAlpha(25);
    if (wrong) return const Color(0xFFFF5B8A).withAlpha(20);
    return Colors.white.withAlpha(8);
  }

  Color _letterColor(bool correct, bool wrong) {
    if (correct) return const Color(0xFF22C55E);
    if (wrong) return const Color(0xFFFF5B8A);
    return Colors.white.withAlpha(160);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLOSS CARD  — solid, no blur
// ─────────────────────────────────────────────────────────────────────────────

class _GlossCard extends StatelessWidget {
  final ReadingGloss gloss;
  final _LevelPalette palette;
  final int number;
  final bool isEnglish;

  const _GlossCard({
    required this.gloss,
    required this.palette,
    required this.number,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final meaning = isEnglish
        ? gloss.meaningEnglish
        : (gloss.meaningTurkish ?? gloss.meaningEnglish);

    return _SolidCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      accentColor: palette.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _QuestionNumber(number: number, palette: palette),
              const SizedBox(width: 9),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: palette.start.withAlpha(22),
                  border: Border.all(color: palette.start.withAlpha(55)),
                ),
                child: Text(
                  gloss.word,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(185),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withAlpha(5),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Text(
              gloss.example,
              style: TextStyle(
                color: Colors.white.withAlpha(162),
                fontSize: 12,
                height: 1.42,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEW WORD CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewWordCard extends StatelessWidget {
  final ReadingVocabularyReviewItem item;
  final _LevelPalette palette;
  final int number;
  final bool isEnglish;

  const _ReviewWordCard({
    required this.item,
    required this.palette,
    required this.number,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final meaning = isEnglish
        ? item.meaningEnglish
        : (item.meaningTurkish ?? item.meaningEnglish);

    return _SolidCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      accentColor: palette.start,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _QuestionNumber(number: number, palette: palette),
              const SizedBox(width: 9),
              Text(
                item.word,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(185),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.originalSentence,
            style: TextStyle(
              color: Colors.white.withAlpha(175),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            item.newExampleSentence,
            style: TextStyle(
              color: Colors.white.withAlpha(138),
              fontSize: 12,
              height: 1.42,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final _LevelPalette palette;

  const _ProgressBar({required this.value, required this.palette});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
              height: 5,
              width: double.infinity,
              color: Colors.white.withAlpha(10)),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [palette.start, palette.end]),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: palette.start.withAlpha(70),
                    blurRadius: 5,
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

class _TabTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TabTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withAlpha(155),
            fontSize: 12.2,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuestionNumber extends StatelessWidget {
  final int number;
  final _LevelPalette palette;

  const _QuestionNumber({required this.number, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [palette.start, palette.end]),
        boxShadow: [
          BoxShadow(
            color: palette.start.withAlpha(35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        number.toString().padLeft(2, '0'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final _LevelPalette palette;

  const _TypeChip({required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: palette.start.withAlpha(18),
        border: Border.all(color: palette.start.withAlpha(48)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final _LevelPalette palette;
  final String code;

  const _LevelBadge({required this.palette, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.start, palette.end],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.start.withAlpha(45),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withAlpha(7),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withAlpha(135)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(148),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool done;
  final bool isEnglish;

  const _StatusPill({required this.done, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: done
            ? const Color(0xFF22C55E).withAlpha(22)
            : Colors.white.withAlpha(7),
        border: Border.all(
          color: done
              ? const Color(0xFF22C55E).withAlpha(55)
              : Colors.white.withAlpha(13),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
            size: 11,
            color: done ? const Color(0xFF22C55E) : Colors.white.withAlpha(130),
          ),
          const SizedBox(width: 4),
          Text(
            done ? t('Done', 'Bitti') : t('Active', 'Aktif'),
            style: TextStyle(
              color:
                  done ? const Color(0xFF22C55E) : Colors.white.withAlpha(140),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final _LevelPalette palette;

  const _SmallEmpty({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return _SolidCard(
      radius: 22,
      padding: const EdgeInsets.all(18),
      accentColor: palette.start,
      child: Column(
        children: [
          Icon(icon, color: palette.start, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(148),
              fontSize: 12,
              height: 1.38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLocked extends StatelessWidget {
  final ReadingLevel level;
  final bool isEnglish;

  const _EmptyLocked({required this.level, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForLevel(level);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _SolidCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          accentColor: palette.start,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      LinearGradient(colors: [palette.start, palette.end]),
                  boxShadow: [
                    BoxShadow(
                      color: palette.start.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                t('Premium content', 'Premium içerik'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t(
                  'Upgrade to Premium to open this reading pack.',
                  'Bu okuma paketini açmak için Premium gerekir.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(158),
                  fontSize: 12.5,
                  height: 1.38,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: palette.start,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SpeakeryThemeAdapter(
                          child: PremiumScreen(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                  label: Text(
                    t('Open Premium', 'Premium’u Aç'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
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

// ─────────────────────────────────────────────────────────────────────────────
// PAPER SHEET  — the reading text background
// ─────────────────────────────────────────────────────────────────────────────

class _PaperSheet extends StatelessWidget {
  final Color tint;
  final Widget child;

  const _PaperSheet({required this.tint, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withAlpha(26),
            Colors.white.withAlpha(7),
            tint.withAlpha(10),
          ],
        ),
        border: Border.all(color: tint.withAlpha(55), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(44),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: tint.withAlpha(16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOLID CARD  — replaces _Glass everywhere in lists
// No BackdropFilter = no GPU blur per item = smooth scroll
// ─────────────────────────────────────────────────────────────────────────────

class _SolidCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color accentColor;

  const _SolidCard({
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
        color: tokens.isLight
            ? tokens.elevatedSurface
            : Colors.white.withAlpha(10),
        border: Border.all(
          color: tokens.isLight ? tokens.border : accentColor.withAlpha(36),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withAlpha(tokens.isLight ? 28 : 38),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
          BoxShadow(
            color: accentColor.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 5),
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
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

_LevelPalette _paletteForLevel(ReadingLevel level) {
  // App-wide CEFR palette matched to the existing Learn / Grammar screens.
  // A1 cyan, A2 green, B1 amber, B2 pink, C1 purple, C2 coral.
  switch (level) {
    case ReadingLevel.a1:
      return const _LevelPalette(
        Color(0xFF06B6D4),
        Color(0xFF0284C7),
      );
    case ReadingLevel.a2:
      return const _LevelPalette(
        Color(0xFF22C55E),
        Color(0xFF16A34A),
      );
    case ReadingLevel.b1:
      return const _LevelPalette(
        Color(0xFFF59E0B),
        Color(0xFFD97706),
      );
    case ReadingLevel.b2:
      return const _LevelPalette(
        Color(0xFFEC4899),
        Color(0xFFBE185D),
      );
    case ReadingLevel.c1:
      return const _LevelPalette(
        Color(0xFF8B5CF6),
        Color(0xFF6D28D9),
      );
    case ReadingLevel.c2:
      return const _LevelPalette(
        Color(0xFFFF6B57),
        Color(0xFFEC4899),
      );
  }
}

class _LevelPalette {
  final Color start;
  final Color end;
  const _LevelPalette(this.start, this.end);
}
