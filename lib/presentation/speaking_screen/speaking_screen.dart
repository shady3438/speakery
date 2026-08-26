import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/ai_service.dart';
import '../../services/native_speech_service.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';

enum SpeakingPracticeState { idle, recording, recorded, playing }

class SpeakingPrompt {
  final String title;
  final String level;
  final String tab;
  final IconData icon;
  final String prompt;
  final String target;
  final int targetSeconds;
  final List<String> usefulPhrases;
  final List<String> checklist;
  final List<String> requiredSignals;

  const SpeakingPrompt({
    required this.title,
    required this.level,
    required this.tab,
    required this.icon,
    required this.prompt,
    required this.target,
    required this.targetSeconds,
    required this.usefulPhrases,
    required this.checklist,
    required this.requiredSignals,
  });
}

class SpeakingAnalysis {
  final String text;
  final int words;
  final int seconds;
  final int score;
  final String cefrEstimate;
  final String pace;
  final String localCoachNote;
  final List<SpeakingMetric> metrics;
  final List<String> strengths;
  final List<String> nextSteps;

  const SpeakingAnalysis({
    required this.text,
    required this.words,
    required this.seconds,
    required this.score,
    required this.cefrEstimate,
    required this.pace,
    required this.localCoachNote,
    required this.metrics,
    required this.strengths,
    required this.nextSteps,
  });

  bool get hasTranscript => text.trim().isNotEmpty;
  bool get isReady => seconds >= 3 || words >= 6;
}

class SpeakingMetric {
  final String label;
  final String value;
  final int score;

  const SpeakingMetric(this.label, this.value, this.score);
}

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _transcriptController = TextEditingController();
  late final AnimationController _entryController;
  late final AnimationController _waveController;
  Timer? _timer;

  SpeakingPracticeState _state = SpeakingPracticeState.idle;
  int _secondsElapsed = 0;
  int _recordedSeconds = 0;
  int _promptIndex = 0;
  bool _feedbackVisible = false;
  bool _aiLoading = false;
  String? _aiCoachNote;

  static const _prompts = <SpeakingPrompt>[
    SpeakingPrompt(
      title: 'Weekend Chat',
      level: 'A2',
      tab: 'Daily',
      icon: Icons.wb_sunny_rounded,
      prompt: 'Describe your perfect weekend.',
      target: 'Speak for 30-45 seconds. Use because, then and after that.',
      targetSeconds: 35,
      usefulPhrases: [
        'On Saturday...',
        'After that...',
        'I like it because...',
        'At the end...',
      ],
      checklist: [
        'Give one clear activity',
        'Add one reason with because',
        'Use a sequence word',
        'Finish with a feeling',
      ],
      requiredSignals: [
        'because',
        'then|after|first|finally',
        'feel|happy|relaxed|tired'
      ],
    ),
    SpeakingPrompt(
      title: 'Introduce Yourself',
      level: 'A1',
      tab: 'Intro',
      icon: Icons.badge_rounded,
      prompt: 'Introduce yourself to a new classmate.',
      target: 'Say your name, city, one hobby and one simple question.',
      targetSeconds: 25,
      usefulPhrases: [
        'My name is...',
        'I am from...',
        'I like...',
        'What about you?',
      ],
      checklist: [
        'Say your name',
        'Say where you are from',
        'Mention one hobby',
        'Ask one question',
      ],
      requiredSignals: [
        'name|i am|i\'m',
        'from|live',
        'like|love|enjoy',
        r'\?'
      ],
    ),
    SpeakingPrompt(
      title: 'Opinion Sprint',
      level: 'B1',
      tab: 'Opinion',
      icon: Icons.forum_rounded,
      prompt: 'Do you prefer studying alone or with friends?',
      target: 'Give your opinion, one reason and one example.',
      targetSeconds: 45,
      usefulPhrases: [
        'In my opinion...',
        'The main reason is...',
        'For example...',
        'However...',
      ],
      checklist: [
        'State your opinion',
        'Give one reason',
        'Add one example',
        'Use a contrast word',
      ],
      requiredSignals: [
        'opinion|prefer|think',
        'because|reason',
        'example|for example',
        'but|however'
      ],
    ),
  ];

  SpeakingPrompt get _prompt => _prompts[_promptIndex];

  SpeakingAnalysis get _analysis => _analyzeSpeaking(
        text: _transcriptController.text,
        seconds: _recordedSeconds > 0 ? _recordedSeconds : _secondsElapsed,
        prompt: _prompt,
      );

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: IosLiquidMotion.entrance,
    )..forward();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveController.dispose();
    _entryController.dispose();
    _transcriptController.dispose();
    NativeSpeechService.instance.stop();
    super.dispose();
  }

  void _startRecording() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    _waveController.repeat();
    setState(() {
      _state = SpeakingPracticeState.recording;
      _secondsElapsed = 0;
      _recordedSeconds = 0;
      _feedbackVisible = false;
      _aiCoachNote = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsElapsed++);
    });
  }

  void _stopRecording() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _waveController.stop();
    if (!mounted) return;
    setState(() {
      _state = SpeakingPracticeState.recorded;
      _recordedSeconds = math.max(_secondsElapsed, 1);
      _secondsElapsed = _recordedSeconds;
    });
  }

  void _startPlayback() {
    if (_recordedSeconds <= 0) return;
    HapticFeedback.selectionClick();
    _timer?.cancel();
    _waveController.repeat();
    setState(() {
      _state = SpeakingPracticeState.playing;
      _secondsElapsed = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsElapsed >= _recordedSeconds) {
        _stopPlayback();
        return;
      }
      setState(() => _secondsElapsed++);
    });
  }

  void _stopPlayback() {
    _timer?.cancel();
    _waveController.stop();
    if (!mounted) return;
    setState(() {
      _state = SpeakingPracticeState.recorded;
      _secondsElapsed = _recordedSeconds;
    });
  }

  void _retry() {
    HapticFeedback.selectionClick();
    _timer?.cancel();
    _waveController.stop();
    setState(() {
      _state = SpeakingPracticeState.idle;
      _secondsElapsed = 0;
      _recordedSeconds = 0;
      _feedbackVisible = false;
      _aiCoachNote = null;
    });
  }

  void _submit() {
    final analysis = _analysis;
    if (!analysis.isReady) {
      PremiumFeedback.show(
        context,
        message: 'Speak for at least 3 seconds or add a short transcript.',
        tone: PremiumFeedbackTone.info,
      );
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _feedbackVisible = true);
  }

  Future<void> _askAiCoach() async {
    final analysis = _analysis;
    if (!analysis.isReady) {
      PremiumFeedback.show(
        context,
        message: 'Record a short answer before asking the AI coach.',
        tone: PremiumFeedbackTone.info,
      );
      return;
    }

    setState(() => _aiLoading = true);
    try {
      if (AIService.isConfigured && analysis.hasTranscript) {
        final result = await AIService.feedback(
          task: AIFeedbackTask.speaking,
          text: analysis.text,
          context: {
            'prompt': _prompt.prompt,
            'target': _prompt.target,
            'pace': analysis.pace,
            'seconds': _recordedSeconds,
          },
        );
        if (!mounted) return;
        setState(() => _aiCoachNote = result['result']);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (!mounted) return;
        setState(() {
          _aiCoachNote =
              'Voxa coach: ${analysis.localCoachNote} Next time, add one fuller example and keep your pace ${analysis.pace.toLowerCase()}.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _aiCoachNote =
            'Voxa coach: ${analysis.localCoachNote} Next time, add one fuller example and keep your pace ${analysis.pace.toLowerCase()}.';
      });
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Future<void> _playModelAnswer() async {
    await NativeSpeechService.instance.speak(
      _modelAnswerFor(_prompt),
      rate: .9,
    );
  }

  void _changePrompt(int index) {
    _timer?.cancel();
    _waveController.stop();
    setState(() {
      _promptIndex = index;
      _state = SpeakingPracticeState.idle;
      _secondsElapsed = 0;
      _recordedSeconds = 0;
      _feedbackVisible = false;
      _aiCoachNote = null;
      _transcriptController.clear();
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _stateLabel() {
    return switch (_state) {
      SpeakingPracticeState.idle => 'Ready',
      SpeakingPracticeState.recording => 'Recording',
      SpeakingPracticeState.recorded => 'Saved',
      SpeakingPracticeState.playing => 'Preview',
    };
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
                        .map((prompt) => IosPillItem(
                              prompt.tab,
                              icon: prompt.icon,
                            ))
                        .toList(growable: false),
                    selectedIndex: _promptIndex,
                    onChanged: _changePrompt,
                    startColor: tokens.primaryAccent,
                    endColor: tokens.warmAccent,
                  ),
                  const SizedBox(height: 16),
                  _PromptCard(
                    tokens: tokens,
                    prompt: _prompt,
                    onPlayModel: _playModelAnswer,
                  ),
                  const SizedBox(height: 12),
                  _CoachStrip(
                    tokens: tokens,
                    prompt: _prompt,
                    analysis: analysis,
                  ),
                  const SizedBox(height: 14),
                  _RecorderCard(
                    tokens: tokens,
                    state: _state,
                    seconds: _state == SpeakingPracticeState.recorded
                        ? _recordedSeconds
                        : _secondsElapsed,
                    label: _stateLabel(),
                    waveController: _waveController,
                    onMicTap: _state == SpeakingPracticeState.recording
                        ? _stopRecording
                        : _state == SpeakingPracticeState.idle
                            ? _startRecording
                            : null,
                    formatDuration: _formatDuration,
                  ),
                  const SizedBox(height: 12),
                  _TranscriptCard(
                    tokens: tokens,
                    controller: _transcriptController,
                    prompt: _prompt,
                    analysis: analysis,
                    onChanged: () => setState(() {
                      _feedbackVisible = false;
                      _aiCoachNote = null;
                    }),
                  ),
                  const SizedBox(height: 14),
                  _ControlRow(
                    tokens: tokens,
                    state: _state,
                    onStart: _startRecording,
                    onStop: _stopRecording,
                    onPlay: _startPlayback,
                    onStopPlay: _stopPlayback,
                    onRetry: _retry,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 10),
                  _AiCoachPanel(
                    tokens: tokens,
                    enabled: analysis.isReady,
                    loading: _aiLoading,
                    note: _aiCoachNote,
                    onTap: _askAiCoach,
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: IosLiquidMotion.settle,
                    switchInCurve: IosLiquidMotion.selectedCurve,
                    switchOutCurve: IosLiquidMotion.settleCurve,
                    child: _feedbackVisible
                        ? _FeedbackCard(
                            key: const ValueKey('speaking-feedback'),
                            tokens: tokens,
                            prompt: _prompt,
                            analysis: analysis,
                            onRetry: _retry,
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('speaking-empty-feedback'),
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

class _Header extends StatelessWidget {
  final SpeakeryThemeTokens tokens;

  const _Header({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      accent: tokens.primaryAccent,
      borderColor: tokens.border,
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
                  'Speaking Practice',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Local feedback first. AI coach is optional.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.record_voice_over_rounded, color: tokens.primaryAccent),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final SpeakingPrompt prompt;
  final VoidCallback onPlayModel;

  const _PromptCard({
    required this.tokens,
    required this.prompt,
    required this.onPlayModel,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 26,
      padding: const EdgeInsets.all(18),
      accent: tokens.primaryAccent,
      borderColor: tokens.border,
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Tag(tokens: tokens, label: prompt.level),
              const SizedBox(width: 8),
              _Tag(tokens: tokens, label: 'Speaking'),
              const Spacer(),
              _IconAction(
                tokens: tokens,
                icon: Icons.volume_up_rounded,
                onTap: onPlayModel,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            prompt.title,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prompt.prompt,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 14.5,
              height: 1.42,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            prompt.target,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 12.5,
              height: 1.4,
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
  final SpeakingPrompt prompt;
  final SpeakingAnalysis analysis;

  const _CoachStrip({
    required this.tokens,
    required this.prompt,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final targetProgress =
        (analysis.seconds / prompt.targetSeconds).clamp(0.0, 1.0).toDouble();
    return IosLiquidGlassSurface(
      radius: 23,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      accent: tokens.warmAccent,
      borderColor: tokens.border,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.warmAccent.withAlpha(22),
              border: Border.all(color: tokens.warmAccent.withAlpha(58)),
            ),
            child: Icon(
              Icons.psychology_alt_rounded,
              color: tokens.warmAccent,
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
                        'Speaking coach',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 12.4,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${analysis.seconds}/${prompt.targetSeconds}s',
                      style: TextStyle(
                        color: tokens.warmAccent,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
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
                    value: targetProgress,
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

class _RecorderCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final SpeakingPracticeState state;
  final int seconds;
  final String label;
  final AnimationController waveController;
  final VoidCallback? onMicTap;
  final String Function(int) formatDuration;

  const _RecorderCard({
    required this.tokens,
    required this.state,
    required this.seconds,
    required this.label,
    required this.waveController,
    required this.onMicTap,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final active = state == SpeakingPracticeState.recording ||
        state == SpeakingPracticeState.playing;
    final danger = state == SpeakingPracticeState.recording;
    final accent = danger ? tokens.error : tokens.primaryAccent;
    return IosLiquidGlassSurface(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      accent: accent,
      borderColor: tokens.border,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LiveDot(color: danger ? tokens.error : tokens.success),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: danger ? tokens.error : tokens.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatDuration(seconds),
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 62,
            child: AnimatedBuilder(
              animation: waveController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _WaveformPainter(
                    progress: waveController.value,
                    active: active,
                    color: accent,
                    mutedColor: tokens.textMuted,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _MicButton(
            tokens: tokens,
            active: active,
            recording: danger,
            enabled: onMicTap != null,
            onTap: onMicTap,
          ),
          const SizedBox(height: 12),
          Text(
            danger
                ? 'Tap stop when your answer feels complete.'
                : 'Use the transcript box below to help Voxa review your answer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TranscriptCard extends StatefulWidget {
  final SpeakeryThemeTokens tokens;
  final TextEditingController controller;
  final SpeakingPrompt prompt;
  final SpeakingAnalysis analysis;
  final VoidCallback onChanged;

  const _TranscriptCard({
    required this.tokens,
    required this.controller,
    required this.prompt,
    required this.analysis,
    required this.onChanged,
  });

  @override
  State<_TranscriptCard> createState() => _TranscriptCardState();
}

class _TranscriptCardState extends State<_TranscriptCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    return IosLiquidGlassSurface(
      radius: 26,
      padding: const EdgeInsets.all(14),
      accent: tokens.primaryAccent,
      borderColor: tokens.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, color: tokens.primaryAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'What I said',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${widget.analysis.words} words',
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Focus(
            onFocusChange: (value) => setState(() => _focused = value),
            child: AnimatedContainer(
              duration: IosLiquidMotion.quick,
              curve: IosLiquidMotion.settleCurve,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  if (_focused)
                    BoxShadow(
                      color: tokens.primaryAccent
                          .withAlpha(tokens.isLight ? 24 : 34),
                      blurRadius: 20,
                      offset: const Offset(0, 9),
                    ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                minLines: 4,
                maxLines: 7,
                textInputAction: TextInputAction.newline,
                onChanged: (_) => widget.onChanged(),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Optional transcript for smarter feedback...',
                  hintStyle: TextStyle(
                    color: tokens.textMuted.withAlpha(160),
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: tokens.inputSurface,
                  border: _border(tokens.border),
                  enabledBorder: _border(tokens.border),
                  focusedBorder: _border(tokens.primaryAccent, width: 1.5),
                ),
              ),
            ),
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

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _ControlRow extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final SpeakingPracticeState state;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onPlay;
  final VoidCallback onStopPlay;
  final VoidCallback onRetry;
  final VoidCallback onSubmit;

  const _ControlRow({
    required this.tokens,
    required this.state,
    required this.onStart,
    required this.onStop,
    required this.onPlay,
    required this.onStopPlay,
    required this.onRetry,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      SpeakingPracticeState.idle => _ActionButton(
          tokens: tokens,
          icon: Icons.mic_rounded,
          label: 'Start',
          onTap: onStart,
        ),
      SpeakingPracticeState.recording => _ActionButton(
          tokens: tokens,
          icon: Icons.stop_rounded,
          label: 'Stop',
          onTap: onStop,
          danger: true,
        ),
      SpeakingPracticeState.recorded => Row(
          children: [
            Expanded(
              child: _ActionButton(
                tokens: tokens,
                icon: Icons.play_arrow_rounded,
                label: 'Play',
                onTap: onPlay,
                soft: true,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _ActionButton(
                tokens: tokens,
                icon: Icons.refresh_rounded,
                label: 'Retry',
                onTap: onRetry,
                soft: true,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _ActionButton(
                tokens: tokens,
                icon: Icons.fact_check_rounded,
                label: 'Check',
                onTap: onSubmit,
              ),
            ),
          ],
        ),
      SpeakingPracticeState.playing => Row(
          children: [
            Expanded(
              child: _ActionButton(
                tokens: tokens,
                icon: Icons.stop_rounded,
                label: 'Stop',
                onTap: onStopPlay,
                soft: true,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _ActionButton(
                tokens: tokens,
                icon: Icons.refresh_rounded,
                label: 'Retry',
                onTap: onRetry,
                soft: true,
                enabled: false,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _ActionButton(
                tokens: tokens,
                icon: Icons.fact_check_rounded,
                label: 'Check',
                onTap: onSubmit,
                enabled: false,
              ),
            ),
          ],
        ),
    };
  }
}

class _AiCoachPanel extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool enabled;
  final bool loading;
  final String? note;
  final VoidCallback onTap;

  const _AiCoachPanel({
    required this.tokens,
    required this.enabled,
    required this.loading,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !loading;
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
                  Icons.auto_awesome_rounded,
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
                      'Optional AI coach',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Short feedback only when you ask.',
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
                  duration: IosLiquidMotion.quick,
                  opacity: canTap ? 1 : .55,
                  child: AnimatedContainer(
                    duration: IosLiquidMotion.quick,
                    curve: IosLiquidMotion.release,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [tokens.primaryAccent, tokens.warmAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.primaryAccent.withAlpha(35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Coach',
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

class _FeedbackCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final SpeakingPrompt prompt;
  final SpeakingAnalysis analysis;
  final VoidCallback onRetry;

  const _FeedbackCard({
    super.key,
    required this.tokens,
    required this.prompt,
    required this.analysis,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 26,
      padding: const EdgeInsets.all(18),
      accent: tokens.warmAccent,
      borderColor: tokens.border,
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq_rounded, color: tokens.warmAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Speaking Feedback · ${analysis.score}/100',
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
                .map((metric) => _FeedbackMetric(
                      tokens: tokens,
                      metric: metric,
                    ))
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _FeedbackNote(
            tokens: tokens,
            icon: Icons.verified_rounded,
            title: 'Strengths',
            text: analysis.strengths.join(' '),
          ),
          const SizedBox(height: 10),
          _FeedbackNote(
            tokens: tokens,
            icon: Icons.tips_and_updates_rounded,
            title: 'Next step',
            text: analysis.nextSteps.join(' '),
          ),
          const SizedBox(height: 10),
          _FeedbackNote(
            tokens: tokens,
            icon: Icons.flag_rounded,
            title: 'Task target',
            text: prompt.target,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  tokens: tokens,
                  icon: Icons.refresh_rounded,
                  label: 'Try again',
                  onTap: onRetry,
                  soft: true,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _ActionButton(
                  tokens: tokens,
                  icon: Icons.arrow_back_rounded,
                  label: 'Back',
                  onTap: () => Navigator.maybePop(context),
                  soft: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Checklist extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final SpeakingPrompt prompt;
  final SpeakingAnalysis analysis;

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
            'Speaking checklist',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          ...List.generate(prompt.checklist.length, (index) {
            final done = _isChecklistDone(index);
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
                      prompt.checklist[index],
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

  bool _isChecklistDone(int index) {
    final text = analysis.text.toLowerCase();
    if (text.isEmpty) {
      return analysis.seconds >= prompt.targetSeconds && index == 0;
    }
    if (index >= prompt.requiredSignals.length) {
      return analysis.words >= 18;
    }
    return RegExp(prompt.requiredSignals[index], caseSensitive: false)
        .hasMatch(text);
  }
}

class _MicButton extends StatefulWidget {
  final SpeakeryThemeTokens tokens;
  final bool active;
  final bool recording;
  final bool enabled;
  final VoidCallback? onTap;

  const _MicButton({
    required this.tokens,
    required this.active,
    required this.recording,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.recording ? widget.tokens.error : widget.tokens.accent;
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: IosLiquidMotion.quick,
        curve: _pressed ? IosLiquidMotion.press : IosLiquidMotion.release,
        scale: _pressed ? .94 : 1,
        child: AnimatedContainer(
          duration: IosLiquidMotion.settle,
          curve: IosLiquidMotion.selectedCurve,
          width: widget.active ? 92 : 86,
          height: widget.active ? 92 : 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.recording
                  ? [widget.tokens.error, const Color(0xFFE11D48)]
                  : [widget.tokens.primaryAccent, widget.tokens.warmAccent],
            ),
            border: Border.all(color: Colors.white.withAlpha(55)),
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(widget.enabled ? 55 : 18),
                blurRadius: widget.active ? 28 : 20,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: Icon(
            widget.recording ? Icons.stop_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: 34,
          ),
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
  final bool danger;
  final bool enabled;

  const _ActionButton({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.onTap,
    this.soft = false,
    this.danger = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = danger ? tokens.error : tokens.primaryAccent;
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: SizedBox(
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: soft ? tokens.glassSurface : null,
            gradient: soft
                ? null
                : LinearGradient(colors: [accent, tokens.warmAccent]),
            border: Border.all(color: soft ? tokens.border : Colors.white24),
            boxShadow: soft || !enabled
                ? null
                : [
                    BoxShadow(
                      color: accent.withAlpha(42),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: soft ? tokens.textPrimary : Colors.white,
                      size: 18),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: soft ? tokens.textPrimary : Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
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

class _IconAction extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final VoidCallback onTap;

  const _IconAction({
    required this.tokens,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tokens.chipSurface,
          border: Border.all(color: tokens.border),
        ),
        child: Icon(icon, color: tokens.textPrimary, size: 18),
      ),
    );
  }
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
        color: tokens.primaryAccent.withAlpha(22),
        border: Border.all(color: tokens.primaryAccent.withAlpha(55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tokens.primaryAccent,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
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

class _LiveDot extends StatelessWidget {
  final Color color;

  const _LiveDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: IosLiquidMotion.quick,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withAlpha(78), blurRadius: 9)],
      ),
    );
  }
}

class _FeedbackMetric extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final SpeakingMetric metric;

  const _FeedbackMetric({
    required this.tokens,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
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
            metric.label,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${metric.score}',
                style: TextStyle(
                  color: _scoreColor(tokens, metric.score),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
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

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool active;
  final Color color;
  final Color mutedColor;

  const _WaveformPainter({
    required this.progress,
    required this.active,
    required this.color,
    required this.mutedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    const bars = 23;
    final gap = size.width / bars;
    final center = size.height / 2;
    for (var i = 0; i < bars; i++) {
      final wave = math.sin((progress * math.pi * 2) + i * .62);
      final idleWave = math.sin(i * .74);
      final heightFactor =
          active ? (.42 + wave.abs() * .58) : (.24 + idleWave.abs() * .32);
      final barHeight = math.max(10.0, size.height * heightFactor);
      final x = gap * i + gap / 2;
      final alpha = active ? (90 + wave.abs() * 135).round() : 75;
      paint.color = (active ? color : mutedColor).withAlpha(alpha);
      canvas.drawLine(
        Offset(x, center - barHeight / 2),
        Offset(x, center + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.color != color ||
        oldDelegate.mutedColor != mutedColor;
  }
}

SpeakingAnalysis _analyzeSpeaking({
  required String text,
  required int seconds,
  required SpeakingPrompt prompt,
}) {
  final clean = text.trim();
  final words = RegExp(r"[A-Za-z']+").allMatches(clean).length;
  final targetSeconds = prompt.targetSeconds;
  final durationScore =
      ((math.min(seconds, targetSeconds) / targetSeconds) * 100).round();
  final paceWpm = seconds <= 0 ? 0 : (words / seconds * 60).round();
  final paceScore = words == 0
      ? (seconds >= 3 ? 62 : 38)
      : paceWpm < 70
          ? 62
          : paceWpm > 165
              ? 70
              : 88;
  final signalHits = prompt.requiredSignals
      .where((signal) => RegExp(signal, caseSensitive: false).hasMatch(clean))
      .length;
  final taskScore = prompt.requiredSignals.isEmpty
      ? 75
      : ((signalHits / prompt.requiredSignals.length) * 100).round();
  final transcriptScore = words == 0
      ? 58
      : words < 12
          ? 64
          : words < 28
              ? 78
              : 90;
  final score = ((durationScore * .26) +
          (paceScore * .24) +
          (taskScore * .3) +
          (transcriptScore * .2))
      .round()
      .clamp(0, 100);
  final pace = words == 0
      ? 'Unknown'
      : paceWpm < 70
          ? 'Slow'
          : paceWpm > 165
              ? 'Fast'
              : 'Natural';
  final cefr = score >= 86
      ? prompt.level
      : score >= 72
          ? '${prompt.level}+'
          : prompt.level == 'A1'
              ? 'A1'
              : 'Practice';
  final strengths = <String>[
    if (seconds >= 3) 'You completed a real speaking turn.',
    if (seconds >= targetSeconds) 'Your answer reached the time target.',
    if (signalHits > 0) 'You included useful task language.',
    if (words >= 18) 'Your transcript gives enough detail for feedback.',
    if (seconds < 3 && words < 6) 'You are set up and ready to start.',
  ];
  final nextSteps = <String>[
    if (seconds < targetSeconds) 'Add ${targetSeconds - seconds} more seconds.',
    if (signalHits < prompt.requiredSignals.length)
      'Use one more target phrase from the prompt.',
    if (words > 0 && words < 18) 'Expand with one example sentence.',
    if (words == 0)
      'Add a short transcript when you want more precise feedback.',
    if (pace == 'Fast') 'Slow down slightly and leave tiny pauses.',
    if (pace == 'Slow')
      'Connect short ideas with then, because or for example.',
  ];
  return SpeakingAnalysis(
    text: clean,
    words: words,
    seconds: seconds,
    score: score,
    cefrEstimate: cefr,
    pace: pace,
    localCoachNote: _coachNote(score, seconds, targetSeconds, signalHits),
    metrics: [
      SpeakingMetric('Fluency', pace, paceScore),
      SpeakingMetric(
          'Task', '$signalHits/${prompt.requiredSignals.length}', taskScore),
      SpeakingMetric(
          'Time',
          '${math.min(seconds, targetSeconds)}/$targetSeconds s',
          durationScore),
      SpeakingMetric(
          'Detail', words == 0 ? 'Optional' : '$words words', transcriptScore),
    ],
    strengths: strengths,
    nextSteps:
        nextSteps.isEmpty ? ['Repeat once and make it smoother.'] : nextSteps,
  );
}

String _coachNote(int score, int seconds, int target, int hits) {
  if (seconds < 3) return 'Start with one simple sentence, then add a reason.';
  if (score >= 86) {
    return 'Strong turn. Now make it sound a little more natural.';
  }
  if (seconds < target) {
    return 'Good start. Keep speaking until you reach the target time.';
  }
  if (hits == 0) {
    return 'Your timing is ready. Add one target phrase from the prompt.';
  }
  return 'Nice progress. Add one specific example for a fuller answer.';
}

String _modelAnswerFor(SpeakingPrompt prompt) {
  return switch (prompt.tab) {
    'Intro' =>
      'Hi, my name is Deniz. I am from Istanbul. I like music and football. Nice to meet you. What about you?',
    'Opinion' =>
      'In my opinion, studying with friends is better. The main reason is that we can help each other. For example, one friend can explain grammar and another can ask questions. However, I also like studying alone before exams.',
    _ =>
      'On Saturday, I would meet my friends and walk near the sea. After that, we would eat something simple. I like weekends like this because I feel relaxed and happy.',
  };
}

Color _scoreColor(SpeakeryThemeTokens tokens, int score) {
  if (score >= 82) return tokens.success;
  if (score >= 64) return tokens.warning;
  return tokens.error;
}
