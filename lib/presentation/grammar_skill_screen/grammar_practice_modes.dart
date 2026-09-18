import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../data/grammar/grammar_models.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';

/// How a learner wants to work a grammar topic.
///
/// Grammar used to have exactly one path — open a topic, walk the five lesson
/// steps, done. Vocabulary and Arena both let you pick how to study the same
/// material, and that is the shape this brings to grammar.
enum GrammarPracticeMode {
  /// The full five-step lesson: Learn, Structure, Examples, Usage, Control.
  lesson,

  /// Flip through the rule, its formula rows and the classic trap.
  cards,

  /// Only this topic's questions, no explanation pages first.
  drill,

  /// Questions drawn from every topic in the level, shuffled.
  review,
}

/// One side-by-side reference card in the deck.
class GrammarRuleCard {
  final String tag;
  final String front;
  final String back;
  final IconData icon;

  const GrammarRuleCard({
    required this.tag,
    required this.front,
    required this.back,
    required this.icon,
  });
}

/// Builds a topic's deck out of the lesson content that already exists — the
/// rule, each formula row, the trap, and the worked examples.
List<GrammarRuleCard> grammarCardsFor(
  GrammarTopic topic,
  GrammarLesson lesson, {
  required bool isEnglish,
}) {
  String t(String en, String tr) => isEnglish ? en : tr;

  final cards = <GrammarRuleCard>[
    GrammarRuleCard(
      tag: t('Rule', 'Kural'),
      front: lesson.bigTitle.isEmpty ? topic.title : lesson.bigTitle,
      back: lesson.teacherIntro.isEmpty ? topic.rule : lesson.teacherIntro,
      icon: Icons.auto_stories_rounded,
    ),
  ];

  for (final row in lesson.formulaRows) {
    cards.add(
      GrammarRuleCard(
        tag: row.label.isEmpty ? t('Form', 'Yapı') : row.label,
        front: row.pattern,
        back: row.sample,
        icon: Icons.architecture_rounded,
      ),
    );
  }

  if (lesson.wrong.trim().isNotEmpty && lesson.right.trim().isNotEmpty) {
    cards.add(
      GrammarRuleCard(
        tag: t('Trap', 'Tuzak'),
        front: lesson.wrong,
        back: lesson.reason.trim().isEmpty
            ? lesson.right
            : '${lesson.right}\n\n${lesson.reason}',
        icon: Icons.report_problem_rounded,
      ),
    );
  }

  for (final example in lesson.examples.take(4)) {
    if (example.trim().isEmpty) continue;
    cards.add(
      GrammarRuleCard(
        tag: t('Example', 'Örnek'),
        front: example,
        back: lesson.oneLineGoal.trim().isEmpty
            ? topic.subtitle
            : lesson.oneLineGoal,
        icon: Icons.chat_bubble_rounded,
      ),
    );
  }

  return cards;
}

// ─────────────────────────────────────────────────────────────────────────────
// RULE CARDS
// ─────────────────────────────────────────────────────────────────────────────

class GrammarCardsScreen extends StatefulWidget {
  final String title;
  final List<GrammarRuleCard> cards;
  final Color start;
  final Color end;
  final bool isEnglish;

  const GrammarCardsScreen({
    super.key,
    required this.title,
    required this.cards,
    required this.start,
    required this.end,
    required this.isEnglish,
  });

  @override
  State<GrammarCardsScreen> createState() => _GrammarCardsScreenState();
}

class _GrammarCardsScreenState extends State<GrammarCardsScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  final Set<int> _flipped = <int>{};

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _move(int delta) {
    final next = (_index + delta).clamp(0, widget.cards.length - 1);
    if (next == _index) return;
    _controller.animateToPage(
      next,
      duration: IosLiquidMotion.settle,
      curve: IosLiquidMotion.settleCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final total = widget.cards.length;

    return Scaffold(
      backgroundColor: tokens.background,
      body: Container(
        decoration: BoxDecoration(gradient: tokens.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _ModeTopBar(
                title: widget.title,
                subtitle: t('Card ${_index + 1} of $total',
                    'Kart ${_index + 1} / $total'),
                accent: widget.start,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final card = widget.cards[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                      child: _FlipCard(
                        card: card,
                        flipped: _flipped.contains(index),
                        start: widget.start,
                        end: widget.end,
                        hint: t('Tap to flip', 'Çevirmek için dokun'),
                        onTap: () => setState(() {
                          if (!_flipped.add(index)) _flipped.remove(index);
                        }),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        label: t('Back', 'Geri'),
                        icon: Icons.arrow_back_rounded,
                        filled: false,
                        accent: widget.start,
                        onTap: _index == 0 ? null : () => _move(-1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeButton(
                        label: _index == total - 1
                            ? t('Finish', 'Bitir')
                            : t('Next', 'İleri'),
                        icon: Icons.arrow_forward_rounded,
                        filled: true,
                        accent: widget.start,
                        accentEnd: widget.end,
                        onTap: () => _index == total - 1
                            ? Navigator.pop(context)
                            : _move(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final GrammarRuleCard card;
  final bool flipped;
  final Color start;
  final Color end;
  final String hint;
  final VoidCallback onTap;

  const _FlipCard({
    required this.card,
    required this.flipped,
    required this.start,
    required this.end,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final ink = tokens.readableAccent(start);

    return GestureDetector(
      onTap: onTap,
      child: IosLiquidGlassSurface(
        radius: 28,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        accent: start,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: start.withAlpha(tokens.isLight ? 30 : 38),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(card.icon, size: 13, color: ink),
                      const SizedBox(width: 5),
                      Text(
                        card.tag,
                        style: TextStyle(
                          color: ink,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  flipped ? Icons.flip_to_front_rounded : Icons.flip_rounded,
                  size: 17,
                  color: tokens.textMuted,
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: IosLiquidMotion.quick,
                    child: Text(
                      flipped ? card.back : card.front,
                      key: ValueKey<bool>(flipped),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: flipped ? 15.5 : 18,
                        height: 1.45,
                        fontWeight:
                            flipped ? FontWeight.w600 : FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                hint,
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRILL / MIXED REVIEW
// ─────────────────────────────────────────────────────────────────────────────

class GrammarDrillScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<GrammarQuizQuestion> questions;
  final Color start;
  final Color end;
  final bool isEnglish;

  const GrammarDrillScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.questions,
    required this.start,
    required this.end,
    required this.isEnglish,
  });

  @override
  State<GrammarDrillScreen> createState() => _GrammarDrillScreenState();
}

class _GrammarDrillScreenState extends State<GrammarDrillScreen> {
  int _index = 0;
  int _correct = 0;
  String? _chosen;
  bool _awarded = false;

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  GrammarQuizQuestion get _question => widget.questions[_index];
  bool get _isLast => _index == widget.questions.length - 1;
  bool get _answered => _chosen != null;

  void _choose(String option) {
    if (_answered) return;
    setState(() {
      _chosen = option;
      if (option == _question.answer) _correct++;
    });
  }

  void _next() {
    if (!_isLast) {
      setState(() {
        _index++;
        _chosen = null;
      });
      return;
    }

    // A drill is extra practice on top of the lesson, so it pays a small bonus
    // rather than marking the lesson complete — that stays the lesson's job.
    if (!_awarded && _correct > 0) {
      _awarded = true;
      AppProgress.instance.addXP(math.max(1, _correct));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    if (widget.questions.isEmpty) {
      return _EmptyDrill(
        title: widget.title,
        accent: widget.start,
        message: t(
          'This topic has no practice questions yet.',
          'Bu konu için henüz alıştırma sorusu yok.',
        ),
      );
    }

    final finished = _isLast && _answered && _awarded;

    return Scaffold(
      backgroundColor: tokens.background,
      body: Container(
        decoration: BoxDecoration(gradient: tokens.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _ModeTopBar(
                title: widget.title,
                subtitle: finished
                    ? widget.subtitle
                    : t(
                        'Question ${_index + 1} of ${widget.questions.length}',
                        'Soru ${_index + 1} / ${widget.questions.length}',
                      ),
                accent: widget.start,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(height: 6, color: tokens.border),
                      FractionallySizedBox(
                        widthFactor:
                            (_index + (_answered ? 1 : 0)) /
                                widget.questions.length,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [widget.start, widget.end],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: finished
                    ? _DrillSummary(
                        correct: _correct,
                        total: widget.questions.length,
                        start: widget.start,
                        end: widget.end,
                        isEnglish: widget.isEnglish,
                        onClose: () => Navigator.pop(context),
                      )
                    : _questionBody(tokens),
              ),
              if (!finished)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                  child: _ModeButton(
                    label: _isLast
                        ? t('See result', 'Sonucu gör')
                        : t('Next question', 'Sonraki soru'),
                    icon: Icons.arrow_forward_rounded,
                    filled: true,
                    accent: widget.start,
                    accentEnd: widget.end,
                    onTap: _answered ? _next : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionBody(SpeakeryThemeTokens tokens) {
    final question = _question;
    final sentence = question.sentence;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      children: [
        IosLiquidGlassSurface(
          radius: 24,
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
          accent: widget.start,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.prompt,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (sentence != null && sentence.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  sentence,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 17,
                    height: 1.45,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final option in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _OptionRow(
              label: option,
              state: !_answered
                  ? _OptionState.idle
                  : option == question.answer
                      ? _OptionState.correct
                      : option == _chosen
                          ? _OptionState.wrong
                          : _OptionState.dimmed,
              accent: widget.start,
              onTap: () => _choose(option),
            ),
          ),
        if (_answered && question.explanation.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          IosLiquidGlassSurface(
            radius: 20,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
            accent: widget.end,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  size: 16,
                  color: tokens.readableAccent(widget.end),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    question.explanation,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 12.5,
                      height: 1.42,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionRow extends StatelessWidget {
  final String label;
  final _OptionState state;
  final Color accent;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.state,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final highlight = switch (state) {
      _OptionState.correct => tokens.success,
      _OptionState.wrong => tokens.error,
      _ => accent,
    };

    return GestureDetector(
      onTap: state == _OptionState.idle ? onTap : null,
      child: Opacity(
        opacity: state == _OptionState.dimmed ? .55 : 1,
        child: IosLiquidGlassSurface(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          accent: highlight,
          borderColor: state == _OptionState.idle
              ? null
              : highlight.withAlpha(tokens.isLight ? 120 : 130),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (state == _OptionState.correct)
                Icon(Icons.check_circle_rounded,
                    size: 18, color: tokens.success)
              else if (state == _OptionState.wrong)
                Icon(Icons.cancel_rounded, size: 18, color: tokens.error),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrillSummary extends StatelessWidget {
  final int correct;
  final int total;
  final Color start;
  final Color end;
  final bool isEnglish;
  final VoidCallback onClose;

  const _DrillSummary({
    required this.correct,
    required this.total,
    required this.start,
    required this.end,
    required this.isEnglish,
    required this.onClose,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final percent = total == 0 ? 0 : (correct * 100 / total).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        children: [
          IosLiquidGlassSurface(
            radius: 28,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            accent: start,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [start, end]),
                  ),
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  t('$correct of $total correct', '$total sorudan $correct doğru'),
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  correct == total
                      ? t('Clean run. Move to the next topic.',
                          'Tertemiz. Sıradaki konuya geçebilirsin.')
                      : t('Review the explanations and run it again.',
                          'Açıklamalara bak ve tekrar dene.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _ModeButton(
            label: t('Done', 'Bitti'),
            icon: Icons.check_rounded,
            filled: true,
            accent: start,
            accentEnd: end,
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

class _EmptyDrill extends StatelessWidget {
  final String title;
  final String message;
  final Color accent;

  const _EmptyDrill({
    required this.title,
    required this.message,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: Container(
        decoration: BoxDecoration(gradient: tokens.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _ModeTopBar(title: title, subtitle: '', accent: accent),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: IosLiquidGlassSurface(
                      radius: 26,
                      padding: const EdgeInsets.all(22),
                      accent: accent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz_outlined,
                              size: 30,
                              color: tokens.readableAccent(accent)),
                          const SizedBox(height: 12),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED CHROME
// ─────────────────────────────────────────────────────────────────────────────

class _ModeTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;

  const _ModeTopBar({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 42,
              height: 42,
              child: IosLiquidGlassSurface(
                radius: 21,
                padding: const EdgeInsets.all(9),
                accent: accent,
                child: Icon(Icons.arrow_back_rounded,
                    size: 19, color: tokens.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.3,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11.5,
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

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final Color? accentEnd;
  final VoidCallback? onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.accent,
    this.accentEnd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : .45,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: filled
                ? LinearGradient(colors: [accent, accentEnd ?? accent])
                : null,
            color: filled ? null : tokens.inputSurface,
            border: Border.all(
              color: filled ? Colors.transparent : tokens.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: filled ? Colors.white : tokens.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : tokens.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
