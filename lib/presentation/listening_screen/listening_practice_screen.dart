import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../data/app_progress.dart';
import '../../data/listening/listening_content.dart';
import '../../services/ai_service.dart';
import '../../services/native_speech_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';

class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({super.key});

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen>
    with TickerProviderStateMixin {
  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  static const _modes = <_ListeningMode>[
    _ListeningMode('Listen', 'Dinle', Icons.hearing_rounded),
    _ListeningMode('Write', 'Yaz', Icons.edit_note_rounded),
    _ListeningMode('Speak', 'Konuş', Icons.record_voice_over_rounded),
    _ListeningMode('Reply', 'Yanıtla', Icons.forum_rounded),
  ];
  static const _speechRates = [.8, 1.0, 1.2];
  static const _speechLabels = ['0.8x', '1.0x', '1.2x'];

  late final AnimationController _waveController;
  late final AnimationController _entryController;
  final TextEditingController _dictationController = TextEditingController();
  final NativeSpeechService _speech = NativeSpeechService.instance;
  final AudioRecorder _voiceRecorder = AudioRecorder();

  Timer? _shadowTimer;
  bool _nativeRecording = false;
  int _levelIndex = 0;
  int _modeIndex = 0;
  int _missionIndex = 0;
  int _speechRateIndex = 1;
  int? _selectedAnswer;
  int _shadowSeconds = 0;
  bool _playing = false;
  bool _showTranscript = false;
  bool _showTranslation = false;
  bool _answerChecked = false;
  bool _shadowing = false;
  bool _aiLoading = false;
  bool _showMissionLibrary = false;
  double? _dictationScore;
  String? _aiCoachNote;
  final Set<int> _passedModes = <int>{};

  bool get _isEnglish => AppProgress.instance.isEnglish;
  String _copy(String english, String turkish) =>
      _isEnglish ? english : turkish;

  String get _level => _levels[_levelIndex];
  List<ListeningMission> get _missions => listeningMissionsForLevel(_level);
  ListeningMission get _mission => _missions[_missionIndex];

  @override
  void initState() {
    super.initState();
    final savedLevel =
        _levels.indexOf(AppProgress.instance.englishLevel.toUpperCase());
    if (savedLevel >= 0) _levelIndex = savedLevel;
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 920),
    );
    _entryController = AnimationController(
      vsync: this,
      duration: IosLiquidMotion.entrance,
    )..forward();
    _speech.onComplete = _handleSpeechComplete;
    AppProgress.instance.addListener(_syncLanguage);
    unawaited(AppProgress.instance.loadProgress().then((_) => _syncLanguage()));
  }

  @override
  void dispose() {
    AppProgress.instance.removeListener(_syncLanguage);
    _speech.onComplete = null;
    unawaited(_speech.stop());
    if (_nativeRecording) unawaited(_voiceRecorder.stop());
    unawaited(_voiceRecorder.dispose());
    _shadowTimer?.cancel();
    _entryController.dispose();
    _waveController.dispose();
    _dictationController.dispose();
    super.dispose();
  }

  void _syncLanguage() {
    if (mounted) setState(() {});
  }

  void _handleSpeechComplete() {
    if (!mounted) return;
    setState(() => _playing = false);
    _waveController.stop();
  }

  Future<void> _togglePlayback() async {
    if (_playing) {
      await _speech.stop();
      _handleSpeechComplete();
      return;
    }

    setState(() => _playing = true);
    _waveController.repeat(reverse: true);
    await _speech.speak(
      _mission.transcript,
      rate: _speechRates[_speechRateIndex],
    );
  }

  void _cycleSpeechRate() {
    setState(() {
      _speechRateIndex = (_speechRateIndex + 1) % _speechRates.length;
    });
    if (_playing) {
      unawaited(_speech.stop());
      _handleSpeechComplete();
    }
  }

  void _selectLevel(int index) {
    if (index == _levelIndex) return;
    setState(() {
      _levelIndex = index;
      _missionIndex = 0;
      _aiCoachNote = null;
    });
    _resetMission();
  }

  void _selectMission(int index) {
    if (index == _missionIndex) return;
    setState(() => _missionIndex = index);
    _resetMission();
  }

  void _selectMode(int index) {
    if (index == _modeIndex) return;
    _shadowTimer?.cancel();
    if (_nativeRecording) {
      unawaited(_voiceRecorder.stop());
      _nativeRecording = false;
    }
    setState(() {
      _modeIndex = index;
      _selectedAnswer = null;
      _answerChecked = false;
      _dictationScore = null;
      _aiCoachNote = null;
      _shadowing = false;
      _shadowSeconds = 0;
      _dictationController.clear();
    });
  }

  void _resetMission() {
    _shadowTimer?.cancel();
    if (_nativeRecording) {
      unawaited(_voiceRecorder.stop());
      _nativeRecording = false;
    }
    unawaited(_speech.stop());
    _waveController.stop();
    setState(() {
      _modeIndex = 0;
      _playing = false;
      _showTranscript = false;
      _showTranslation = false;
      _selectedAnswer = null;
      _answerChecked = false;
      _dictationScore = null;
      _aiCoachNote = null;
      _aiLoading = false;
      _shadowing = false;
      _shadowSeconds = 0;
      _passedModes.clear();
      _dictationController.clear();
    });
  }

  void _checkChoice(int correctIndex) {
    if (_selectedAnswer == null) {
      PremiumFeedback.show(
        context,
        message: _copy('Choose an answer first.', 'Önce bir cevap seç.'),
        tone: PremiumFeedbackTone.error,
      );
      return;
    }
    final correct = _selectedAnswer == correctIndex;
    setState(() {
      _answerChecked = true;
      _aiCoachNote = null;
      if (correct) _passedModes.add(_modeIndex);
    });
    PremiumFeedback.show(
      context,
      message: correct
          ? _copy('Correct. You caught the key detail.',
              'Doğru. Ana detayı yakaladın.')
          : _copy('Not quite. Listen once more and retry.',
              'Henüz değil. Bir kez daha dinleyip tekrar dene.'),
      tone: correct ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );
  }

  void _checkDictation() {
    if (_dictationController.text.trim().isEmpty) {
      PremiumFeedback.show(
        context,
        message: _copy('Type what you heard first.', 'Önce duyduğunu yaz.'),
        tone: PremiumFeedbackTone.error,
      );
      return;
    }
    final score = _wordAccuracy(
      _dictationController.text,
      _mission.dictationTarget,
    );
    setState(() {
      _dictationScore = score;
      _aiCoachNote = null;
      if (score >= .72) _passedModes.add(_modeIndex);
    });
    PremiumFeedback.show(
      context,
      message: score >= .72
          ? _copy(
              'Great dictation. ${(_dictationScore! * 100).round()}% match.',
              'Harika dikte. %${(_dictationScore! * 100).round()} eşleşme.')
          : _copy('Listen again. Aim for the key content words.',
              'Tekrar dinle. Anahtar kelimelere odaklan.'),
      tone:
          score >= .72 ? PremiumFeedbackTone.success : PremiumFeedbackTone.info,
    );
  }

  double _wordAccuracy(String attempt, String target) {
    final typed = _normalise(attempt).split(' ').where((e) => e.isNotEmpty);
    final expected = _normalise(target).split(' ').where((e) => e.isNotEmpty);
    final typedWords = typed.toList();
    final expectedWords = expected.toList();
    if (expectedWords.isEmpty) return 0;
    var matches = 0;
    final used = <int>{};
    for (final word in typedWords) {
      for (var i = 0; i < expectedWords.length; i++) {
        if (!used.contains(i) && expectedWords[i] == word) {
          used.add(i);
          matches++;
          break;
        }
      }
    }
    return (matches / expectedWords.length).clamp(0, 1);
  }

  String _normalise(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9' ]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _toggleShadowing() {
    if (_shadowing) {
      unawaited(_stopShadowing());
      return;
    }

    setState(() {
      _shadowing = true;
      _shadowSeconds = 0;
      _nativeRecording = false;
    });
    _shadowTimer?.cancel();
    _shadowTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _shadowSeconds++);
      if (_shadowSeconds >= 30) unawaited(_stopShadowing());
    });
    unawaited(_beginNativeRecording());
  }

  Future<void> _beginNativeRecording() async {
    var nativeRecording = false;
    try {
      if (await _voiceRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/speakery_shadow_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _voiceRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            numChannels: 1,
            echoCancel: true,
            noiseSuppress: true,
            autoGain: true,
          ),
          path: path,
        );
        nativeRecording = true;
      }
    } catch (_) {
      nativeRecording = false;
    }
    if (!mounted || !_shadowing) {
      if (nativeRecording) {
        try {
          await _voiceRecorder.stop();
        } catch (_) {
          return;
        }
      }
      return;
    }
    setState(() => _nativeRecording = nativeRecording);
  }

  Future<void> _stopShadowing() async {
    _shadowTimer?.cancel();
    final shouldStopRecorder = _nativeRecording;
    final passed = _shadowSeconds >= 3;
    setState(() {
      _shadowing = false;
      _nativeRecording = false;
      _aiCoachNote = null;
      if (passed) _passedModes.add(_modeIndex);
    });
    if (shouldStopRecorder) {
      try {
        await _voiceRecorder.stop();
      } catch (_) {
        // The timed practice still completes if the recorder stops externally.
      }
    }
    if (!mounted) return;
    PremiumFeedback.show(
      context,
      message: passed
          ? _copy('Your speaking turn is saved.', 'Konuşma turun kaydedildi.')
          : _copy('Keep speaking for at least 3 seconds.',
              'En az 3 saniye konuşmaya devam et.'),
      tone: passed ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );
  }

  void _completeMission() {
    if (_passedModes.length < 3) {
      PremiumFeedback.show(
        context,
        message: _copy(
          'Pass at least 3 training modes to complete this mission.',
          'Bu görevi tamamlamak için en az 3 adımı geç.',
        ),
        tone: PremiumFeedbackTone.info,
      );
      return;
    }
    final reward = 8 + (_levelIndex * 2);
    AppProgress.instance.completeLesson(
      'listening-${_mission.id}',
      rewardXP: reward,
    );
    PremiumFeedback.show(
      context,
      message: _copy(
        'Mission complete. +$reward XP',
        'Görev tamamlandı. +$reward XP',
      ),
      tone: PremiumFeedbackTone.success,
    );
    setState(() {});
  }

  void _nextMission() {
    if (_missionIndex >= _missions.length - 1) return;
    setState(() => _missionIndex++);
    _resetMission();
  }

  void _goToRecommendedStep() {
    if (_passedModes.contains(_modeIndex)) {
      for (var index = 0; index < _modes.length; index++) {
        if (!_passedModes.contains(index)) {
          _selectMode(index);
          return;
        }
      }
      _completeMission();
      return;
    }

    if (_modeIndex <= 2) {
      unawaited(_togglePlayback());
      return;
    }

    PremiumFeedback.show(
      context,
      message: _copy(
        'Choose the reply you would send to Voxa below.',
        'Aşağıdan Voxa’ya göndereceğin yanıtı seç.',
      ),
    );
  }

  Future<void> _askAiCoach() async {
    if (_playing) {
      await _speech.stop();
      _handleSpeechComplete();
    }

    setState(() => _aiLoading = true);
    try {
      if (AIService.isConfigured) {
        final dictation = _dictationController.text.trim();
        final result = await AIService.feedback(
          task: AIFeedbackTask.listening,
          text: _mission.transcript,
          context: {
            'level': _level,
            'mission': _mission.titleEn,
            'mode': _modes[_modeIndex].labelEn,
            'passed': _passedModes.length,
            if (dictation.isNotEmpty) 'dictation': dictation,
          },
        );
        if (!mounted) return;
        setState(() => _aiCoachNote = result['result']);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (!mounted) return;
        setState(() => _aiCoachNote = _localAiListeningNote());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _aiCoachNote = _localAiListeningNote());
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  String _localAiListeningNote() {
    final passed = _passedModes.length;
    if (_modeIndex == 1 && _dictationScore != null) {
      final percent = (_dictationScore! * 100).round();
      if (_dictationScore! >= .72) {
        return _copy(
          'Voxa coach: strong dictation at $percent%. Replay once at ${_speechLabels[_speechRateIndex]} and shadow only the stressed words.',
          'Voxa koçu: dikte güçlü, %$percent. ${_speechLabels[_speechRateIndex]} hızında bir kez daha dinle ve sadece vurgulu kelimeleri tekrar et.',
        );
      }
      return _copy(
        'Voxa coach: you caught $percent%. Listen for content words first, then fill grammar words like a, the and to.',
        'Voxa koçu: %$percent yakaladın. Önce içerik kelimelerini dinle, sonra a, the ve to gibi küçük kelimeleri tamamla.',
      );
    }
    if (_answerChecked && _selectedAnswer != null) {
      final correct = _modeIndex == 3
          ? _selectedAnswer == _mission.dialogueAnswer
          : _selectedAnswer == _mission.focusAnswer;
      return correct
          ? _copy(
              'Voxa coach: you caught the key meaning. Move to the next step and keep the transcript hidden first.',
              'Voxa koçu: ana anlamı yakaladın. Sonraki adıma geç ve metni önce kapalı tut.',
            )
          : _copy(
              'Voxa coach: replay once slower, ignore every small word, and listen for the answer clue.',
              'Voxa koçu: bir kez daha yavaş dinle, küçük kelimelere takılma ve cevap ipucunu ara.',
            );
    }
    if (_shadowSeconds >= 3 || _passedModes.contains(2)) {
      return _copy(
        'Voxa coach: good shadowing turn. Repeat the same chunk one more time with shorter pauses.',
        'Voxa koçu: iyi bir shadowing turu. Aynı parçayı daha kısa duraklamalarla bir kez daha söyle.',
      );
    }
    if (passed >= 3) {
      return _copy(
        'Voxa coach: this mission is ready to finish. Review the transcript after you complete it.',
        'Voxa koçu: bu görev tamamlanmaya hazır. Bitirdikten sonra transkripti gözden geçir.',
      );
    }
    return _copy(
      'Voxa coach: listen once without text, answer the current step, then use transcript only as a check.',
      'Voxa koçu: metinsiz bir kez dinle, mevcut adımı cevapla, sonra transkripti sadece kontrol için aç.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final levelColor = AppTheme.cefrLevelColor(_level);
    final completed = _missions
        .where(
          (mission) =>
              AppProgress.instance.isLessonCompleted('listening-${mission.id}'),
        )
        .length;

    return Scaffold(
      backgroundColor: tokens.background,
      body: IosDynamicGlassBackdrop(
        primary: tokens.secondaryAccent,
        secondary: tokens.warmAccent,
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entryController,
              curve: IosLiquidMotion.settleCurve,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .035),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _entryController,
                  curve: IosLiquidMotion.settleCurve,
                ),
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
                children: [
                  _Header(
                    tokens: tokens,
                    isEnglish: _isEnglish,
                    completed: completed,
                    total: _missions.length,
                  ),
                  const SizedBox(height: 14),
                  IosLiquidPillSelector(
                    items: _levels.map(IosPillItem.new).toList(growable: false),
                    selectedIndex: _levelIndex,
                    onChanged: _selectLevel,
                    startColor: levelColor,
                    endColor: levelColor,
                    itemColors: _levels
                        .map(AppTheme.cefrLevelColor)
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  _ListeningFocusPanel(
                    tokens: tokens,
                    isEnglish: _isEnglish,
                    mission: _mission,
                    level: _level,
                    color: levelColor,
                    modeIndex: _modeIndex,
                    passed: _passedModes,
                    completed: completed,
                    total: _missions.length,
                    aiLoading: _aiLoading,
                    aiNote: _aiCoachNote,
                    onContinue: _goToRecommendedStep,
                    onCoach: _askAiCoach,
                  ),
                  const SizedBox(height: 12),
                  RepaintBoundary(
                    child: _PlayerCard(
                      tokens: tokens,
                      mission: _mission,
                      isEnglish: _isEnglish,
                      playing: _playing,
                      animation: _waveController,
                      showTranscript: _showTranscript,
                      showTranslation: _showTranslation,
                      rateLabel: _speechLabels[_speechRateIndex],
                      onPlay: _togglePlayback,
                      onRate: _cycleSpeechRate,
                      onTranscript: () => setState(
                        () => _showTranscript = !_showTranscript,
                      ),
                      onTranslation: () => setState(
                        () => _showTranslation = !_showTranslation,
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  _SectionTitle(
                    tokens: tokens,
                    title: _copy('Your 4-step session', '4 adımlı çalışman'),
                    trailing: '${_passedModes.length}/4',
                  ),
                  const SizedBox(height: 9),
                  _ModeGrid(
                    tokens: tokens,
                    modes: _modes,
                    selected: _modeIndex,
                    passedModes: _passedModes,
                    isEnglish: _isEnglish,
                    onChanged: _selectMode,
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: KeyedSubtree(
                      key: ValueKey('${_mission.id}-$_modeIndex'),
                      child: RepaintBoundary(child: _buildExercise(tokens)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _MissionProgressCard(
                    tokens: tokens,
                    isEnglish: _isEnglish,
                    passed: _passedModes.length,
                    completed: AppProgress.instance
                        .isLessonCompleted('listening-${_mission.id}'),
                    canGoNext: _missionIndex < _missions.length - 1,
                    onComplete: _completeMission,
                    onNext: _nextMission,
                  ),
                  const SizedBox(height: 19),
                  _MissionLibraryToggle(
                    tokens: tokens,
                    isEnglish: _isEnglish,
                    level: _level,
                    count: _missions.length,
                    expanded: _showMissionLibrary,
                    onTap: () => setState(
                      () => _showMissionLibrary = !_showMissionLibrary,
                    ),
                  ),
                  if (_showMissionLibrary) ...[
                    const SizedBox(height: 9),
                    RepaintBoundary(
                      child: Column(
                        children: List.generate(_missions.length, (index) {
                          final mission = _missions[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _missions.length - 1 ? 0 : 10,
                            ),
                            child: _MissionCard(
                              key: ValueKey('listening-mission-${mission.id}'),
                              tokens: tokens,
                              mission: mission,
                              isEnglish: _isEnglish,
                              selected: index == _missionIndex,
                              completed: AppProgress.instance
                                  .isLessonCompleted('listening-${mission.id}'),
                              onTap: () => _selectMission(index),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExercise(SpeakeryThemeTokens tokens) {
    switch (_modeIndex) {
      case 0:
        return _ChoiceExercise(
          tokens: tokens,
          keyPrefix: '${_mission.id}-focus',
          title: _copy('Catch the key detail', 'Ana detayı yakala'),
          prompt: _copy(
            _mission.focusQuestionEn,
            _mission.focusQuestionTr,
          ),
          options: _mission.focusOptions,
          selected: _selectedAnswer,
          correct: _mission.focusAnswer,
          checked: _answerChecked,
          buttonLabel: _copy('Check answer', 'Cevabı kontrol et'),
          onSelected: (value) => setState(() {
            _selectedAnswer = value;
            _answerChecked = false;
          }),
          onCheck: () => _checkChoice(_mission.focusAnswer),
        );
      case 1:
        return _DictationExercise(
          tokens: tokens,
          isEnglish: _isEnglish,
          controller: _dictationController,
          score: _dictationScore,
          target: _mission.dictationTarget,
          onReplay: _togglePlayback,
          onCheck: _checkDictation,
        );
      case 2:
        return _ShadowExercise(
          tokens: tokens,
          isEnglish: _isEnglish,
          chunk: _mission.shadowChunk,
          seconds: _shadowSeconds,
          active: _shadowing,
          passed: _passedModes.contains(2),
          onPlay: _togglePlayback,
          onRecord: _toggleShadowing,
        );
      default:
        return _ChoiceExercise(
          tokens: tokens,
          keyPrefix: '${_mission.id}-dialogue',
          title: _copy('Continue the dialogue', 'Diyalogu devam ettir'),
          prompt: _copy(
            _mission.dialoguePromptEn,
            _mission.dialoguePromptTr,
          ),
          options: _mission.dialogueOptions,
          selected: _selectedAnswer,
          correct: _mission.dialogueAnswer,
          checked: _answerChecked,
          buttonLabel: _copy('Check response', 'Yanıtı kontrol et'),
          conversation: true,
          onSelected: (value) => setState(() {
            _selectedAnswer = value;
            _answerChecked = false;
          }),
          onCheck: () => _checkChoice(_mission.dialogueAnswer),
        );
    }
  }
}

class _Header extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;
  final int completed;
  final int total;

  const _Header({
    required this.tokens,
    required this.isEnglish,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: _IconBox(
            tokens: tokens,
            icon: Icons.arrow_back_ios_new_rounded,
            color: tokens.textPrimary,
            size: 43,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnglish ? 'Listening Lab' : 'Dinleme Laboratuvarı',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                isEnglish
                    ? 'Listen, decode, repeat and respond.'
                    : 'Dinle, çözümle, tekrar et ve yanıtla.',
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _MetaPill(
          tokens: tokens,
          icon: Icons.workspace_premium_rounded,
          text: '$completed/$total',
        ),
      ],
    );
  }
}

class _ListeningFocusPanel extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;
  final ListeningMission mission;
  final String level;
  final Color color;
  final int modeIndex;
  final Set<int> passed;
  final int completed;
  final int total;
  final bool aiLoading;
  final String? aiNote;
  final VoidCallback onContinue;
  final VoidCallback onCoach;

  const _ListeningFocusPanel({
    required this.tokens,
    required this.isEnglish,
    required this.mission,
    required this.level,
    required this.color,
    required this.modeIndex,
    required this.passed,
    required this.completed,
    required this.total,
    required this.aiLoading,
    required this.aiNote,
    required this.onContinue,
    required this.onCoach,
  });

  String get _coachMessage {
    const english = [
      'Listen once without text, then catch one key detail.',
      'Replay and type the sentence. Focus on content words.',
      'Copy the rhythm, then record a short speaking turn.',
      'Choose the reply that sounds natural in the dialogue.',
    ];
    const turkish = [
      'Metinsiz bir kez dinle, sonra tek ana detayı yakala.',
      'Tekrar dinle ve cümleyi yaz. İçerik kelimelerine odaklan.',
      'Ritmi kopyala, sonra kısa bir konuşma turu kaydet.',
      'Diyalogda doğal duyulan yanıtı seç.',
    ];
    return isEnglish ? english[modeIndex] : turkish[modeIndex];
  }

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final currentDone = passed.contains(modeIndex);

    return IosLiquidGlassSurface(
      radius: 25,
      padding: const EdgeInsets.all(13),
      accent: color,
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withAlpha(22),
                  border: Border.all(color: color.withAlpha(68)),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'Focus mission' : 'Odak görevi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mission.duration}  |  '
                      '${_sceneLabel(mission.scene, isEnglish)}  |  '
                      '${passed.length}/4',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 11.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: aiLoading ? null : onCoach,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [tokens.primaryAccent, tokens.warmAccent],
                    ),
                  ),
                  child: aiLoading
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: tokens.border,
              color: color,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isEnglish ? 'Voxa Coach' : 'Voxa Koç'} · '
                      '${modeIndex + 1}/4',
                      style: TextStyle(
                        color: color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      aiNote?.trim().isNotEmpty == true
                          ? aiNote!
                          : _coachMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        height: 1.32,
                        fontSize: 11.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onContinue,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: (currentDone ? tokens.success : color).withAlpha(20),
                    border: Border.all(
                      color:
                          (currentDone ? tokens.success : color).withAlpha(56),
                    ),
                  ),
                  child: Text(
                    currentDone
                        ? (isEnglish ? 'Next' : 'Sonraki')
                        : (isEnglish ? 'Start' : 'Başla'),
                    style: TextStyle(
                      color: currentDone ? tokens.success : color,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final ListeningMission mission;
  final bool isEnglish;
  final bool playing;
  final Animation<double> animation;
  final bool showTranscript;
  final bool showTranslation;
  final String rateLabel;
  final VoidCallback onPlay;
  final VoidCallback onRate;
  final VoidCallback onTranscript;
  final VoidCallback onTranslation;

  const _PlayerCard({
    required this.tokens,
    required this.mission,
    required this.isEnglish,
    required this.playing,
    required this.animation,
    required this.showTranscript,
    required this.showTranslation,
    required this.rateLabel,
    required this.onPlay,
    required this.onRate,
    required this.onTranscript,
    required this.onTranslation,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      strong: true,
      radius: 31,
      accent: tokens.secondaryAccent,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(
                tokens: tokens,
                icon: mission.icon,
                color: tokens.secondaryAccent,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? mission.titleEn : mission.titleTr,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? mission.subtitleEn : mission.subtitleTr,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12.3,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            height: 86,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: tokens.inputSurface.withAlpha(tokens.isLight ? 126 : 65),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                _PlayButton(
                  tokens: tokens,
                  playing: playing,
                  onTap: onPlay,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => CustomPaint(
                      painter: _WavePainter(
                        color: tokens.secondaryAccent,
                        phase: playing ? animation.value : .18,
                      ),
                      size: const Size(double.infinity, 52),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onRate,
                  child: _MetaPill(
                    tokens: tokens,
                    icon: Icons.speed_rounded,
                    text: rateLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _MetaPill(
                  tokens: tokens,
                  icon: Icons.timer_rounded,
                  text: mission.duration,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _MetaPill(
                  tokens: tokens,
                  icon: Icons.signal_cellular_alt_rounded,
                  text: mission.level,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _MetaPill(
                  tokens: tokens,
                  icon: Icons.place_rounded,
                  text: _sceneLabel(mission.scene, isEnglish),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _MiniGlassButton(
                  tokens: tokens,
                  icon: showTranscript
                      ? Icons.visibility_rounded
                      : Icons.subject_rounded,
                  label: isEnglish ? 'Transcript' : 'Metin',
                  active: showTranscript,
                  onTap: onTranscript,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniGlassButton(
                  tokens: tokens,
                  icon: Icons.translate_rounded,
                  label: isEnglish ? 'Translation' : 'Çeviri',
                  active: showTranslation,
                  onTap: onTranslation,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: !showTranscript && !showTranslation
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: tokens.primaryAccent.withAlpha(13),
                        border: Border.all(
                          color: tokens.primaryAccent.withAlpha(42),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showTranscript)
                            Text(
                              mission.transcript,
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontSize: 12.2,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          if (showTranscript && showTranslation)
                            const SizedBox(height: 9),
                          if (showTranslation)
                            Text(
                              mission.translationTr,
                              style: TextStyle(
                                color: tokens.textSecondary,
                                fontSize: 11.7,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ModeGrid extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final List<_ListeningMode> modes;
  final int selected;
  final Set<int> passedModes;
  final bool isEnglish;
  final ValueChanged<int> onChanged;

  const _ModeGrid({
    required this.tokens,
    required this.modes,
    required this.selected,
    required this.passedModes,
    required this.isEnglish,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(modes.length, (index) {
        final mode = modes[index];
        final active = index == selected;
        final passed = passedModes.contains(index);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == modes.length - 1 ? 0 : 7),
            child: GestureDetector(
              key: ValueKey('listening-mode-$index'),
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 230),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: active
                      ? tokens.secondaryAccent.withAlpha(24)
                      : tokens.glassSurface.withAlpha(70),
                  border: Border.all(
                    color: passed
                        ? tokens.success.withAlpha(85)
                        : active
                            ? tokens.secondaryAccent.withAlpha(75)
                            : tokens.border,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      passed ? Icons.check_circle_rounded : mode.icon,
                      color: passed
                          ? tokens.success
                          : active
                              ? tokens.secondaryAccent
                              : tokens.iconSecondary,
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEnglish ? mode.labelEn : mode.labelTr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            active ? tokens.textPrimary : tokens.textSecondary,
                        fontSize: 9.6,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _VoxaChatBubble extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String text;

  const _VoxaChatBubble({
    required this.tokens,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [tokens.foxAccent, tokens.primaryAccent],
            ),
          ),
          child: const Icon(
            Icons.pets_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(19),
                bottomLeft: Radius.circular(19),
                bottomRight: Radius.circular(19),
                topLeft: Radius.circular(6),
              ),
              color: tokens.foxAccent.withAlpha(15),
              border: Border.all(color: tokens.foxAccent.withAlpha(48)),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 13.4,
                height: 1.4,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceExercise extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String keyPrefix;
  final String title;
  final String prompt;
  final List<String> options;
  final int? selected;
  final int correct;
  final bool checked;
  final String buttonLabel;
  final bool conversation;
  final ValueChanged<int> onSelected;
  final VoidCallback onCheck;

  const _ChoiceExercise({
    required this.tokens,
    required this.keyPrefix,
    required this.title,
    required this.prompt,
    required this.options,
    required this.selected,
    required this.correct,
    required this.checked,
    required this.buttonLabel,
    this.conversation = false,
    required this.onSelected,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 27,
      accent: tokens.primaryAccent,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (conversation)
            _VoxaChatBubble(
              tokens: tokens,
              text: prompt,
            )
          else ...[
            _ExerciseHeading(
                tokens: tokens, icon: Icons.quiz_rounded, text: title),
            const SizedBox(height: 11),
            Text(
              prompt,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final isSelected = selected == index;
            final isCorrect = checked && index == correct;
            final isWrong = checked && isSelected && index != correct;
            final color = isCorrect
                ? tokens.success
                : isWrong
                    ? tokens.error
                    : tokens.primaryAccent;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                key: ValueKey('$keyPrefix-option-$index'),
                onTap: checked ? null : () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 210),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: (isSelected || isCorrect)
                        ? color.withAlpha(18)
                        : tokens.inputSurface.withAlpha(
                            tokens.isLight ? 120 : 55,
                          ),
                    border: Border.all(
                      color: (isSelected || isCorrect)
                          ? color.withAlpha(75)
                          : tokens.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withAlpha(
                            (isSelected || isCorrect) ? 28 : 8,
                          ),
                          border: Border.all(
                            color: (isSelected || isCorrect)
                                ? color.withAlpha(95)
                                : tokens.border,
                          ),
                        ),
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: TextStyle(
                            color: (isSelected || isCorrect)
                                ? color
                                : tokens.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 12.2,
                            height: 1.3,
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
          _PrimaryGlassButton(
            key: ValueKey('$keyPrefix-check'),
            tokens: tokens,
            label: buttonLabel,
            icon: Icons.check_rounded,
            onTap: onCheck,
          ),
        ],
      ),
    );
  }
}

class _DictationExercise extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;
  final TextEditingController controller;
  final double? score;
  final String target;
  final VoidCallback onReplay;
  final VoidCallback onCheck;

  const _DictationExercise({
    required this.tokens,
    required this.isEnglish,
    required this.controller,
    required this.score,
    required this.target,
    required this.onReplay,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 27,
      accent: tokens.primaryAccent,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExerciseHeading(
            tokens: tokens,
            icon: Icons.edit_note_rounded,
            text: isEnglish ? 'Write what you hear' : 'Duyduğunu yaz',
          ),
          const SizedBox(height: 10),
          Text(
            isEnglish
                ? 'Replay the clip, then type the key sentence.'
                : 'Kaydı tekrar dinle ve ana cümleyi yaz.',
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12.2,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 11),
          TextField(
            key: const ValueKey('listening-dictation-field'),
            controller: controller,
            minLines: 2,
            maxLines: 4,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: isEnglish ? 'Type the sentence...' : 'Cümleyi yaz...',
              filled: true,
              fillColor:
                  tokens.inputSurface.withAlpha(tokens.isLight ? 160 : 75),
              border: _inputBorder(tokens.border),
              enabledBorder: _inputBorder(tokens.border),
              focusedBorder: _inputBorder(tokens.primaryAccent, width: 1.4),
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: (score! >= .72 ? tokens.success : tokens.warning)
                    .withAlpha(15),
                border: Border.all(
                  color: (score! >= .72 ? tokens.success : tokens.warning)
                      .withAlpha(55),
                ),
              ),
              child: Text(
                '${isEnglish ? 'Target' : 'Hedef'}: $target\n'
                '${isEnglish ? 'Word match' : 'Kelime eşleşmesi'}: '
                '${(score! * 100).round()}%',
                style: TextStyle(
                  color: tokens.textSecondary,
                  height: 1.45,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _MiniGlassButton(
                  tokens: tokens,
                  icon: Icons.replay_rounded,
                  label: isEnglish ? 'Replay' : 'Tekrar dinle',
                  onTap: onReplay,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PrimaryGlassButton(
                  key: const ValueKey('listening-dictation-check'),
                  tokens: tokens,
                  label: isEnglish ? 'Check' : 'Kontrol et',
                  icon: Icons.spellcheck_rounded,
                  onTap: onCheck,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(19),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _ShadowExercise extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;
  final String chunk;
  final int seconds;
  final bool active;
  final bool passed;
  final VoidCallback onPlay;
  final VoidCallback onRecord;

  const _ShadowExercise({
    required this.tokens,
    required this.isEnglish,
    required this.chunk,
    required this.seconds,
    required this.active,
    required this.passed,
    required this.onPlay,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 27,
      accent: tokens.warmAccent,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExerciseHeading(
            tokens: tokens,
            icon: Icons.record_voice_over_rounded,
            text: isEnglish ? 'Speak with Voxa' : 'Voxa ile konuş',
          ),
          const SizedBox(height: 11),
          _VoxaChatBubble(
            tokens: tokens,
            text: chunk,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(19),
                  bottomLeft: Radius.circular(19),
                  bottomRight: Radius.circular(6),
                  topRight: Radius.circular(19),
                ),
                color: tokens.secondaryAccent.withAlpha(18),
                border: Border.all(
                  color: tokens.secondaryAccent.withAlpha(55),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active
                        ? Icons.graphic_eq_rounded
                        : passed
                            ? Icons.check_circle_rounded
                            : Icons.mic_none_rounded,
                    color: passed ? tokens.success : tokens.secondaryAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      active
                          ? '${isEnglish ? 'Recording your reply' : 'Yanıtın kaydediliyor'} · ${seconds}s'
                          : passed
                              ? (isEnglish
                                  ? 'Voice reply sent to Voxa'
                                  : 'Sesli yanıt Voxa’ya gönderildi')
                              : (isEnglish
                                  ? 'Your voice reply'
                                  : 'Senin sesli yanıtın'),
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniGlassButton(
                  tokens: tokens,
                  icon: Icons.volume_up_rounded,
                  label: isEnglish ? 'Hear Voxa' : 'Voxa’yı dinle',
                  onTap: onPlay,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PrimaryGlassButton(
                  key: const ValueKey('listening-shadow-button'),
                  tokens: tokens,
                  label: active
                      ? '${isEnglish ? 'Stop' : 'Durdur'} ${seconds}s'
                      : passed
                          ? (isEnglish ? 'Try again' : 'Yeniden dene')
                          : (isEnglish
                              ? 'Send voice reply'
                              : 'Sesli yanıt gönder'),
                  icon: active
                      ? Icons.stop_rounded
                      : passed
                          ? Icons.check_rounded
                          : Icons.mic_rounded,
                  onTap: onRecord,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            isEnglish
                ? 'Listen to Voxa, then answer with the same rhythm and stress.'
                : 'Voxa’yı dinle, sonra aynı ritim ve vurguyla yanıt ver.',
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 11.2,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionProgressCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;
  final int passed;
  final bool completed;
  final bool canGoNext;
  final VoidCallback onComplete;
  final VoidCallback onNext;

  const _MissionProgressCard({
    required this.tokens,
    required this.isEnglish,
    required this.passed,
    required this.completed,
    required this.canGoNext,
    required this.onComplete,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 23,
      padding: const EdgeInsets.all(12),
      accent: completed ? tokens.success : tokens.secondaryAccent,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (completed ? tokens.success : tokens.secondaryAccent)
                  .withAlpha(20),
              border: Border.all(
                color: (completed ? tokens.success : tokens.secondaryAccent)
                    .withAlpha(60),
              ),
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.track_changes_rounded,
              color: completed ? tokens.success : tokens.secondaryAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed
                      ? (isEnglish ? 'Mission complete' : 'Görev tamamlandı')
                      : (isEnglish
                          ? '$passed of 4 steps passed'
                          : '4 adımın $passed tanesi geçildi'),
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 12.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  completed
                      ? (isEnglish
                          ? 'Progress and XP saved.'
                          : 'İlerleme ve XP kaydedildi.')
                      : (isEnglish
                          ? 'Complete any 3 steps.'
                          : 'Herhangi 3 adımı tamamla.'),
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            key: const ValueKey('listening-complete-mission'),
            onTap: completed && canGoNext ? onNext : onComplete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: completed
                      ? [tokens.success, tokens.secondaryAccent]
                      : [tokens.secondaryAccent, tokens.primaryAccent],
                ),
              ),
              child: Text(
                completed && canGoNext
                    ? (isEnglish ? 'Next' : 'Sonraki')
                    : (isEnglish ? 'Finish' : 'Tamamla'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final ListeningMission mission;
  final bool isEnglish;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _MissionCard({
    super.key,
    required this.tokens,
    required this.mission,
    required this.isEnglish,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IosLiquidGlassSurface(
        radius: 24,
        accent: selected ? tokens.secondaryAccent : tokens.primaryAccent,
        padding: const EdgeInsets.all(13),
        borderColor:
            selected ? tokens.secondaryAccent.withAlpha(72) : tokens.border,
        child: Row(
          children: [
            _IconBox(
              tokens: tokens,
              icon: completed ? Icons.check_rounded : mission.icon,
              color: completed
                  ? tokens.success
                  : selected
                      ? tokens.secondaryAccent
                      : tokens.primaryAccent,
              size: 42,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? mission.titleEn : mission.titleTr,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mission.level}  |  ${mission.duration}  |  '
                    '${_sceneLabel(mission.scene, isEnglish)}',
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.graphic_eq_rounded : Icons.chevron_right_rounded,
              color: selected ? tokens.secondaryAccent : tokens.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionLibraryToggle extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;
  final String level;
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  const _MissionLibraryToggle({
    required this.tokens,
    required this.isEnglish,
    required this.level,
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: IosLiquidGlassSurface(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        accent: tokens.secondaryAccent,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokens.secondaryAccent.withAlpha(18),
                border: Border.all(
                  color: tokens.secondaryAccent.withAlpha(48),
                ),
              ),
              child: Icon(
                Icons.library_music_rounded,
                color: tokens.secondaryAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish
                        ? '$level mission library'
                        : '$level gorev kutuphanesi',
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 13.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isEnglish
                        ? '$count missions. Hidden to keep focus clean.'
                        : '$count görev. Odak temiz kalsın diye kapalı.',
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 10.9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? .5 : 0,
              duration: IosLiquidMotion.quick,
              curve: IosLiquidMotion.settleCurve,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: tokens.iconSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String title;
  final String trailing;

  const _SectionTitle({
    required this.tokens,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            color: tokens.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ExerciseHeading extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String text;

  const _ExerciseHeading({
    required this.tokens,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: tokens.primaryAccent, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryGlassButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryGlassButton({
    super.key,
    required this.tokens,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 43,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [tokens.secondaryAccent, tokens.primaryAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: tokens.primaryAccent.withAlpha(35),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniGlassButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _MiniGlassButton({
    required this.tokens,
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 210),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active
              ? tokens.primaryAccent.withAlpha(20)
              : tokens.inputSurface.withAlpha(tokens.isLight ? 115 : 55),
          border: Border.all(
            color: active ? tokens.primaryAccent.withAlpha(65) : tokens.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? tokens.primaryAccent : tokens.iconSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? tokens.textPrimary : tokens.textSecondary,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool playing;
  final VoidCallback onTap;

  const _PlayButton({
    required this.tokens,
    required this.playing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('listening-play-button'),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 53,
        height: 53,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [tokens.secondaryAccent, tokens.primaryAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: tokens.secondaryAccent.withAlpha(playing ? 65 : 42),
              blurRadius: playing ? 24 : 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Icon(
          playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final Color color;
  final double size;

  const _IconBox({
    required this.tokens,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .36),
        color: color.withAlpha(tokens.isLight ? 18 : 28),
        border: Border.all(color: color.withAlpha(tokens.isLight ? 55 : 70)),
      ),
      child: Icon(icon, color: color, size: size * .46),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String text;

  const _MetaPill({
    required this.tokens,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.inputSurface.withAlpha(tokens.isLight ? 112 : 48),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: tokens.secondaryAccent, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 10.3,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double phase;

  const _WavePainter({required this.color, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const bars = 22;
    final gap = size.width / bars;
    for (var i = 0; i < bars; i++) {
      final wave = math.sin((i * .72) + phase * math.pi * 2);
      final secondary = math.cos((i * .31) - phase * math.pi);
      final height = 8 + ((wave.abs() * 22) + (secondary.abs() * 9));
      final x = (i + .5) * gap;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint..color = color.withAlpha(95 + ((i % 5) * 27)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}

class _ListeningMode {
  final String labelEn;
  final String labelTr;
  final IconData icon;

  const _ListeningMode(this.labelEn, this.labelTr, this.icon);
}

String _sceneLabel(String scene, bool isEnglish) {
  if (isEnglish) return scene;
  return switch (scene) {
    'Cafe' => 'Kafe',
    'School' => 'Okul',
    'Town' => 'Şehir',
    'Travel' => 'Seyahat',
    'Health' => 'Sağlık',
    'Friends' => 'Arkadaşlar',
    'Work' => 'İş',
    'Housing' => 'Konut',
    'Podcast' => 'Podcast',
    'Career' => 'Kariyer',
    'News' => 'Haber',
    'Service' => 'Hizmet',
    'Lecture' => 'Ders',
    'Business' => 'İş dünyası',
    'Documentary' => 'Belgesel',
    'Debate' => 'Tartışma',
    'Culture' => 'Kültür',
    'Forum' => 'Forum',
    _ => scene,
  };
}
