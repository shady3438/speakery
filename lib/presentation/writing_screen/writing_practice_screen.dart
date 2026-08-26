import 'package:flutter/material.dart';

import '../../services/ai_service.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';
import 'writing_analyzer.dart';

class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({super.key});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _entryController;
  bool _submitted = false;
  bool _aiLoading = false;
  int _promptIndex = 0;
  String? _aiCoachNote;

  static const _prompts = <WritingPracticePrompt>[
    WritingPracticePrompt(
      title: 'Daily Routine',
      instruction: 'Write about your daily routine.',
      target: 'Use 5-7 Present Simple sentences.',
      tab: 'Routine',
      icon: Icons.wb_sunny_rounded,
      level: 'A1',
      focus: 'Present Simple',
      minWords: 35,
      targetSentences: 5,
      checklist: [
        'Use I + verb',
        'Add time words',
        'Use First / Then / In the evening',
        'Finish every sentence with punctuation',
      ],
      usefulPhrases: [
        'I wake up at...',
        'First, I...',
        'Then, I...',
        'In the evening, I...',
      ],
      requiredSignals: ['I', 'at', 'first', 'then'],
    ),
    WritingPracticePrompt(
      title: 'Friendly Message',
      instruction: 'Invite a friend to do something this weekend.',
      target: 'Include a time, place and one question.',
      tab: 'Message',
      icon: Icons.mark_chat_unread_rounded,
      level: 'A2',
      focus: 'Invitations',
      minWords: 45,
      targetSentences: 4,
      checklist: [
        'Greet your friend',
        'Say the activity',
        'Add time and place',
        'Ask one question',
      ],
      usefulPhrases: [
        'Hi...',
        'Would you like to...',
        'Let’s meet at...',
        'Can you come?',
      ],
      requiredSignals: ['hi', 'would', 'at', '?'],
    ),
    WritingPracticePrompt(
      title: 'Mini Story',
      instruction: 'Describe a surprising moment from yesterday.',
      target: 'Use Past Simple and at least two sequence words.',
      tab: 'Story',
      icon: Icons.auto_stories_rounded,
      level: 'B1',
      focus: 'Past Simple',
      minWords: 60,
      targetSentences: 6,
      checklist: [
        'Start with yesterday / last...',
        'Use Past Simple verbs',
        'Use two sequence words',
        'End with your feeling',
      ],
      usefulPhrases: [
        'Yesterday, I...',
        'At first, ...',
        'After that, ...',
        'I felt...',
      ],
      requiredSignals: ['yesterday', 'first', 'after', 'felt'],
    ),
  ];

  WritingPracticePrompt get _prompt => _prompts[_promptIndex];
  WritingAnalysis get _analysis =>
      WritingAnalyzer.analyze(_controller.text, _prompt);

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: IosLiquidMotion.entrance,
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final analysis = _analysis;
    if (!analysis.isReady) {
      PremiumFeedback.show(
        context,
        message: analysis.words == 0
            ? 'Start writing here before submitting.'
            : 'Add at least one clear sentence and a few more words.',
        tone: PremiumFeedbackTone.error,
      );
      return;
    }
    setState(() => _submitted = true);
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _submitted = false;
      _aiCoachNote = null;
      _aiLoading = false;
    });
  }

  Future<void> _askAiCoach() async {
    final analysis = _analysis;
    if (!analysis.isReady) {
      PremiumFeedback.show(
        context,
        message: 'Write a little more before asking for AI polish.',
        tone: PremiumFeedbackTone.info,
      );
      return;
    }

    setState(() => _aiLoading = true);
    try {
      if (AIService.isConfigured) {
        final result = await AIService.feedback(
          task: AIFeedbackTask.writing,
          text: analysis.text,
          context: {
            'prompt': _prompt.title,
            'words': analysis.words,
          },
        );
        if (!mounted) return;
        setState(() => _aiCoachNote = result['result']);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        setState(() {
          _aiCoachNote =
              'Voxa coach: ${analysis.localCoachNote} Suggested polish: ${analysis.suggestedRewrite}';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _aiCoachNote =
            'Voxa coach: ${analysis.localCoachNote} Suggested polish: ${analysis.suggestedRewrite}';
      });
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final analysis = _analysis;
    final entry = CurvedAnimation(
      parent: _entryController,
      curve: IosLiquidMotion.settleCurve,
    );

    return Scaffold(
      backgroundColor: tokens.background,
      body: IosDynamicGlassBackdrop(
        primary: tokens.primaryAccent,
        secondary: tokens.warmAccent,
        child: SafeArea(
          child: FadeTransition(
            opacity: entry,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(entry),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                children: [
                  _Header(tokens: tokens),
                  const SizedBox(height: 13),
                  IosLiquidPillSelector(
                    items: _prompts
                        .map((prompt) =>
                            IosPillItem(prompt.tab, icon: prompt.icon))
                        .toList(growable: false),
                    selectedIndex: _promptIndex,
                    onChanged: (value) => setState(() {
                      _promptIndex = value;
                      _submitted = false;
                      _aiCoachNote = null;
                    }),
                    startColor: tokens.primaryAccent,
                    endColor: tokens.warmAccent,
                  ),
                  const SizedBox(height: 16),
                  _PromptCard(
                    tokens: tokens,
                    prompt: _prompts[_promptIndex],
                  ),
                  const SizedBox(height: 10),
                  _CoachStrip(
                    tokens: tokens,
                    prompt: _prompt,
                    analysis: analysis,
                  ),
                  const SizedBox(height: 14),
                  _EditorCard(
                    tokens: tokens,
                    controller: _controller,
                    prompt: _prompt,
                    analysis: analysis,
                    onChanged: () => setState(() {
                      _submitted = false;
                      _aiCoachNote = null;
                    }),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          tokens: tokens,
                          icon: Icons.refresh_rounded,
                          label: _submitted ? 'Retry' : 'Clear',
                          onTap: _clear,
                          soft: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          tokens: tokens,
                          icon: Icons.fact_check_rounded,
                          label: 'Check',
                          onTap: _submit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _AiCoachPanel(
                    tokens: tokens,
                    isLoading: _aiLoading,
                    note: _aiCoachNote,
                    enabled: analysis.isReady,
                    onTap: _askAiCoach,
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: IosLiquidMotion.settle,
                    switchInCurve: IosLiquidMotion.selectedCurve,
                    switchOutCurve: IosLiquidMotion.settleCurve,
                    child: _submitted
                        ? _EnhancedFeedbackCard(
                            key: const ValueKey('feedback'),
                            tokens: tokens,
                            prompt: _prompt,
                            analysis: analysis,
                            onRetry: _clear,
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('empty-feedback'),
                          ),
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

class _PromptCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final WritingPracticePrompt prompt;

  const _PromptCard({required this.tokens, required this.prompt});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(tokens: tokens, label: prompt.level),
              _Tag(tokens: tokens, label: 'Writing'),
              _Tag(tokens: tokens, label: prompt.focus),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prompt.title,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prompt.instruction,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            prompt.target,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: prompt.usefulPhrases
                .map((phrase) => _PhraseChip(tokens: tokens, label: phrase))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _CoachStrip extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final WritingPracticePrompt prompt;
  final WritingAnalysis analysis;

  const _CoachStrip({
    required this.tokens,
    required this.prompt,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (analysis.score / 100).clamp(0.0, 1.0);
    return IosLiquidGlassSurface(
      radius: 23,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      accent: tokens.foxAccent,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.foxAccent.withAlpha(22),
              border: Border.all(color: tokens.foxAccent.withAlpha(58)),
            ),
            child: Icon(
              Icons.pets_rounded,
              color: tokens.foxAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Writing coach',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 12.4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${analysis.words}/${prompt.minWords} words',
                      style: TextStyle(
                        color: tokens.foxAccent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  analysis.localCoachNote,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11.3,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: progress,
                    backgroundColor: tokens.border,
                    color: _scoreColor(tokens, analysis.score),
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

class _EditorCard extends StatefulWidget {
  final SpeakeryThemeTokens tokens;
  final TextEditingController controller;
  final WritingPracticePrompt prompt;
  final WritingAnalysis analysis;
  final VoidCallback onChanged;

  const _EditorCard({
    required this.tokens,
    required this.controller,
    required this.prompt,
    required this.analysis,
    required this.onChanged,
  });

  @override
  State<_EditorCard> createState() => _EditorCardState();
}

class _EditorCardState extends State<_EditorCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return _GlassPanel(
      tokens: tokens,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Focus(
            onFocusChange: (value) => setState(() => _focused = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (_focused)
                    BoxShadow(
                      color: tokens.primaryAccent
                          .withAlpha(tokens.isLight ? 24 : 34),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                minLines: 9,
                maxLines: 14,
                textInputAction: TextInputAction.newline,
                onChanged: (_) => widget.onChanged(),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Start writing here...',
                  hintStyle: TextStyle(
                    color: tokens.textMuted.withAlpha(165),
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: tokens.inputSurface,
                  border: _inputBorder(tokens.border),
                  enabledBorder: _inputBorder(tokens.border),
                  focusedBorder: _inputBorder(tokens.primaryAccent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Counter(
                tokens: tokens,
                label: 'Words',
                value: '${widget.analysis.words}',
              ),
              const SizedBox(width: 8),
              _Counter(
                tokens: tokens,
                label: 'Sentences',
                value: '${widget.analysis.sentences}',
              ),
              const SizedBox(width: 8),
              _Counter(
                tokens: tokens,
                label: 'Score',
                value: '${widget.analysis.score}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Checklist(
            tokens: tokens,
            prompt: widget.prompt,
            analysis: widget.analysis,
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _EnhancedFeedbackCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final WritingPracticePrompt prompt;
  final WritingAnalysis analysis;
  final VoidCallback onRetry;

  const _EnhancedFeedbackCard({
    super.key,
    required this.tokens,
    required this.prompt,
    required this.analysis,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: tokens.warmAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Writing Feedback · ${analysis.score}/100',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _FeedbackPill(tokens: tokens, label: analysis.cefrEstimate),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.metrics
                .map(
                  (metric) => _FeedbackMetric(
                    tokens: tokens,
                    label: metric.label,
                    value: metric.value,
                    score: metric.score,
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _FeedbackNote(
            tokens: tokens,
            icon: Icons.flag_rounded,
            title: 'Task target',
            text: prompt.target,
          ),
          const SizedBox(height: 10),
          _FeedbackNote(
            tokens: tokens,
            icon: Icons.verified_rounded,
            title: 'Strengths',
            text: analysis.strengths.join(' '),
          ),
          const SizedBox(height: 10),
          if (analysis.issues.isNotEmpty) ...[
            ...analysis.issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IssueNote(tokens: tokens, issue: issue),
              ),
            ),
          ],
          _FeedbackNote(
            tokens: tokens,
            icon: Icons.tips_and_updates_rounded,
            title: 'Suggested polish',
            text: analysis.suggestedRewrite,
          ),
          const SizedBox(height: 10),
          _FeedbackNote(
            tokens: tokens,
            icon: Icons.school_rounded,
            title: 'Next step',
            text: analysis.nextSteps.join(' '),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InlineAction(tokens: tokens, label: 'Try again', onTap: onRetry),
              const SizedBox(width: 8),
              _InlineAction(
                tokens: tokens,
                label: 'Back to Learn',
                onTap: () => Navigator.maybePop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackMetric extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final String value;
  final int score;

  const _FeedbackMetric({
    required this.tokens,
    required this.label,
    required this.value,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: (score / 100).clamp(0.0, 1.0),
              backgroundColor: tokens.border,
              color: _scoreColor(tokens, score),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueNote extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final WritingIssue issue;

  const _IssueNote({
    required this.tokens,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (issue.severity) {
      WritingIssueSeverity.fix => tokens.error,
      WritingIssueSeverity.warning => tokens.warning,
      WritingIssueSeverity.info => tokens.primaryAccent,
    };
    final icon = switch (issue.severity) {
      WritingIssueSeverity.fix => Icons.build_circle_rounded,
      WritingIssueSeverity.warning => Icons.warning_amber_rounded,
      WritingIssueSeverity.info => Icons.lightbulb_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withAlpha(tokens.isLight ? 14 : 22),
        border: Border.all(color: color.withAlpha(52)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  issue.example == null
                      ? issue.message
                      : '${issue.message} Example: ${issue.example}',
                  style: TextStyle(
                    color: tokens.textSecondary,
                    height: 1.35,
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

class _AiCoachPanel extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isLoading;
  final bool enabled;
  final String? note;
  final VoidCallback onTap;

  const _AiCoachPanel({
    required this.tokens,
    required this.isLoading,
    required this.enabled,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isLoading;
    return IosLiquidGlassSurface(
      radius: 22,
      padding: const EdgeInsets.all(13),
      accent: tokens.primaryAccent,
      borderColor: tokens.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.primaryAccent.withAlpha(20),
                  border: Border.all(color: tokens.primaryAccent.withAlpha(52)),
                ),
                child: Icon(
                  Icons.auto_fix_high_rounded,
                  color: tokens.primaryAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Optional AI polish',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Local checks run first. AI only helps when you ask.',
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 11.3,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: canTap ? onTap : null,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: canTap ? 1 : 0.55,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [tokens.primaryAccent, tokens.warmAccent],
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Polish',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(height: 11),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: tokens.inputSurface,
                border: Border.all(color: tokens.border),
              ),
              child: Text(
                note!,
                style: TextStyle(
                  color: tokens.textPrimary,
                  height: 1.38,
                  fontSize: 12.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedbackNote extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String title;
  final String text;

  const _FeedbackNote({
    required this.tokens,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: tokens.primaryAccent.withAlpha(tokens.isLight ? 14 : 18),
        border: Border.all(color: tokens.primaryAccent.withAlpha(42)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tokens.primaryAccent, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    height: 1.35,
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

class _FeedbackPill extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;

  const _FeedbackPill({
    required this.tokens,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.warmAccent.withAlpha(20),
        border: Border.all(color: tokens.warmAccent.withAlpha(50)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tokens.warmAccent,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final VoidCallback onTap;

  const _InlineAction({
    required this.tokens,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: tokens.chipSurface,
          border: Border.all(color: tokens.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SpeakeryThemeTokens tokens;

  const _Header({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tokens: tokens,
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: tokens.text),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Writing Practice',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.text,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Local feedback first. AI polish is optional.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.mutedText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_note_rounded, color: tokens.accent, size: 26),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassPanel({
    required this.tokens,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 26,
      padding: padding,
      accent: tokens.primaryAccent,
      borderColor: tokens.border,
      child: child,
    );
  }
}

class _PhraseChip extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;

  const _PhraseChip({
    required this.tokens,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tokens.textSecondary,
          fontSize: 11.3,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Checklist extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final WritingPracticePrompt prompt;
  final WritingAnalysis analysis;

  const _Checklist({
    required this.tokens,
    required this.prompt,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Writing checklist',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          ...List.generate(prompt.checklist.length, (index) {
            final item = prompt.checklist[index];
            final done = _isChecklistItemDone(item, index);
            final color = done ? tokens.success : tokens.textMuted;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == prompt.checklist.length - 1 ? 0 : 7,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: color,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: done ? tokens.textPrimary : tokens.textSecondary,
                        height: 1.25,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isChecklistItemDone(String item, int index) {
    final text = analysis.text.toLowerCase();
    final lowerItem = item.toLowerCase();
    if (text.isEmpty) return false;
    if (lowerItem.contains('punctuation')) {
      return RegExp(r'[.!?]$').hasMatch(analysis.text.trim());
    }
    if (lowerItem.contains('question')) return text.contains('?');
    if (lowerItem.contains('past simple')) {
      return RegExp(
        r'\b(was|were|went|had|saw|played|visited|started|finished|watched|did)\b',
      ).hasMatch(text);
    }
    if (lowerItem.contains('sentence')) {
      return analysis.sentences >= prompt.targetSentences;
    }
    if (lowerItem.contains('time')) {
      return RegExp(
        r'\b(at|on|in|morning|evening|weekend|yesterday|today|tomorrow)\b',
      ).hasMatch(text);
    }
    if (lowerItem.contains('sequence')) {
      return RegExp(r'\b(first|then|after|after that|finally)\b')
          .hasMatch(text);
    }
    if (index < prompt.requiredSignals.length) {
      return text.contains(prompt.requiredSignals[index].toLowerCase());
    }
    return analysis.words >= prompt.minWords;
  }
}

Color _scoreColor(SpeakeryThemeTokens tokens, int score) {
  if (score >= 85) return tokens.success;
  if (score >= 65) return tokens.warning;
  return tokens.error;
}

class _Tag extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;

  const _Tag({required this.tokens, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.accent.withAlpha(22),
        border: Border.all(color: tokens.accent.withAlpha(55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tokens.accent,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final String value;

  const _Counter({
    required this.tokens,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: tokens.glass,
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: tokens.mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: tokens.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool soft;

  const _ActionButton({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.onTap,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: soft ? tokens.glass : null,
          gradient: soft
              ? null
              : LinearGradient(colors: [tokens.accent, tokens.warmAccent]),
          border: Border.all(color: soft ? tokens.border : Colors.transparent),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: soft ? tokens.text : Colors.white, size: 18),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: soft ? tokens.text : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
