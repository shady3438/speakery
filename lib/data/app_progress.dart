import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class AppProgress extends ChangeNotifier {
  AppProgress._();

  static final AppProgress instance = AppProgress._();

  static const String _xpKey = 'speakery_xp';
  static const String _streakKey = 'speakery_streak';
  static const String _premiumKey = 'speakery_premium';
  static const String _lastStudyDateKey = 'speakery_last_study_date';
  static const String _completedLessonsKey = 'speakery_completed_lessons';
  static const String _savedVocabularyKey = 'speakery_saved_vocabulary';
  static const String _knownVocabularyKey = 'speakery_known_vocabulary';
  static const String _masteredVocabularyKey = 'speakery_mastered_vocabulary';
  static const String _challengeXPKey = 'speakery_challenge_xp';
  static const String _totalChallengeGamesKey =
      'speakery_total_challenge_games';
  static const String _classicBestScoreKey = 'speakery_classic_best_score';
  static const String _timeAttackBestScoreKey =
      'speakery_time_attack_best_score';
  static const String _dailyBestScoreKey = 'speakery_daily_best_score';
  static const String _survivalBestScoreKey = 'speakery_survival_best_score';
  static const String _duelWinsKey = 'speakery_duel_wins';
  static const String _duelLossesKey = 'speakery_duel_losses';
  static const String _duelDrawsKey = 'speakery_duel_draws';
  static const String _dailyChallengeDateKey = 'speakery_daily_challenge_date';
  static const String _dailyChallengeStreakKey =
      'speakery_daily_challenge_streak';
  static const String _tabooGamesKey = 'speakery_taboo_games';
  static const String _tabooWinsTeamAKey = 'speakery_taboo_wins_team_a';
  static const String _tabooWinsTeamBKey = 'speakery_taboo_wins_team_b';
  static const String _isEnglishUiKey = 'speakery_is_english_ui';
  static const String _themeModeKey = 'speakery_theme_mode';
  static const String _learningGoalKey = 'speakery_learning_goal';
  static const String _englishLevelKey = 'speakery_english_level';
  static const String _soundEffectsKey = 'speakery_sound_effects';
  static const String _hapticsKey = 'speakery_haptics';
  static const String _dailyGoalKey = 'speakery_daily_goal';
  static const String _voxaPersonalityKey = 'speakery_voxa_personality';

  int xp = 0;
  int streak = 0;
  bool isPremium = false;
  bool isEnglish = true;
  SpeakeryThemeMode themeMode = SpeakeryThemeMode.dark;
  String learningGoal = 'Daily confidence';
  String englishLevel = 'A1';
  bool soundEffects = true;
  bool haptics = true;
  String dailyGoal = '10 min';
  String voxaPersonality = 'Friendly Coach';
  bool _hasLoaded = false;

  int challengeXP = 0;
  int totalChallengeGames = 0;
  int classicBestScore = 0;
  int timeAttackBestScore = 0;
  int dailyBestScore = 0;
  int survivalBestScore = 0;
  int duelWins = 0;
  int duelLosses = 0;
  int duelDraws = 0;
  int dailyChallengeStreak = 0;
  int tabooGames = 0;
  int tabooWinsTeamA = 0;
  int tabooWinsTeamB = 0;
  String? dailyChallengeDate;

  DateTime? lastStudyDate;
  final Set<String> completedLessons = <String>{};

  final Set<String> savedVocabularyWords = <String>{};
  final Set<String> knownVocabularyWords = <String>{};
  final Set<String> masteredVocabularyWords = <String>{};

  int get level => (xp ~/ 100) + 1;
  int get xpInCurrentLevel => xp % 100;
  double get levelProgress => xpInCurrentLevel / 100;
  int get completedCount => completedLessons.length;

  int get savedVocabularyCount => savedVocabularyWords.length;
  int get knownVocabularyCount => knownVocabularyWords.length;
  int get masteredVocabularyCount => masteredVocabularyWords.length;

  int get totalDuelGames => duelWins + duelLosses + duelDraws;
  int get totalTabooWins => tabooWinsTeamA + tabooWinsTeamB;

  String get todayKey {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  bool get dailyChallengeDoneToday => dailyChallengeDate == todayKey;

  String get rankTitle {
    if (xp >= 1000) return 'Speakery Elite';
    if (xp >= 700) return 'Fluent Hunter';
    if (xp >= 400) return 'Grammar Slayer';
    if (xp >= 200) return 'Rising Speaker';
    if (xp >= 100) return 'Active Learner';
    return 'New Learner';
  }

  String _cleanId(String value) {
    return value.toLowerCase().trim();
  }

  Future<void> loadProgress() async {
    if (_hasLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    xp = prefs.getInt(_xpKey) ?? 0;
    streak = prefs.getInt(_streakKey) ?? 0;
    isPremium = prefs.getBool(_premiumKey) ?? false;
    isEnglish = prefs.getBool(_isEnglishUiKey) ?? true;
    themeMode =
        SpeakeryThemeMode.fromStorageKey(prefs.getString(_themeModeKey));
    learningGoal = prefs.getString(_learningGoalKey) ?? learningGoal;
    englishLevel = prefs.getString(_englishLevelKey) ?? englishLevel;
    soundEffects = prefs.getBool(_soundEffectsKey) ?? soundEffects;
    haptics = prefs.getBool(_hapticsKey) ?? haptics;
    dailyGoal = prefs.getString(_dailyGoalKey) ?? dailyGoal;
    voxaPersonality = prefs.getString(_voxaPersonalityKey) ?? voxaPersonality;

    challengeXP = prefs.getInt(_challengeXPKey) ?? 0;
    totalChallengeGames = prefs.getInt(_totalChallengeGamesKey) ?? 0;
    classicBestScore = prefs.getInt(_classicBestScoreKey) ?? 0;
    timeAttackBestScore = prefs.getInt(_timeAttackBestScoreKey) ?? 0;
    dailyBestScore = prefs.getInt(_dailyBestScoreKey) ?? 0;
    survivalBestScore = prefs.getInt(_survivalBestScoreKey) ?? 0;
    duelWins = prefs.getInt(_duelWinsKey) ?? 0;
    duelLosses = prefs.getInt(_duelLossesKey) ?? 0;
    duelDraws = prefs.getInt(_duelDrawsKey) ?? 0;
    dailyChallengeDate = prefs.getString(_dailyChallengeDateKey);
    dailyChallengeStreak = prefs.getInt(_dailyChallengeStreakKey) ?? 0;
    tabooGames = prefs.getInt(_tabooGamesKey) ?? 0;
    tabooWinsTeamA = prefs.getInt(_tabooWinsTeamAKey) ?? 0;
    tabooWinsTeamB = prefs.getInt(_tabooWinsTeamBKey) ?? 0;

    final lastStudyRaw = prefs.getString(_lastStudyDateKey);
    lastStudyDate =
        lastStudyRaw == null ? null : DateTime.tryParse(lastStudyRaw);

    completedLessons
      ..clear()
      ..addAll((prefs.getStringList(_completedLessonsKey) ?? const <String>[])
          .map(_cleanId));

    savedVocabularyWords
      ..clear()
      ..addAll((prefs.getStringList(_savedVocabularyKey) ?? const <String>[])
          .map(_cleanId));

    knownVocabularyWords
      ..clear()
      ..addAll((prefs.getStringList(_knownVocabularyKey) ?? const <String>[])
          .map(_cleanId));

    masteredVocabularyWords
      ..clear()
      ..addAll((prefs.getStringList(_masteredVocabularyKey) ?? const <String>[])
          .map(_cleanId));

    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_xpKey, xp);
    await prefs.setInt(_streakKey, streak);
    await prefs.setBool(_premiumKey, isPremium);
    await prefs.setBool(_isEnglishUiKey, isEnglish);
    await prefs.setString(_themeModeKey, themeMode.storageKey);
    await prefs.setString(_learningGoalKey, learningGoal);
    await prefs.setString(_englishLevelKey, englishLevel);
    await prefs.setBool(_soundEffectsKey, soundEffects);
    await prefs.setBool(_hapticsKey, haptics);
    await prefs.setString(_dailyGoalKey, dailyGoal);
    await prefs.setString(_voxaPersonalityKey, voxaPersonality);

    await prefs.setInt(_challengeXPKey, challengeXP);
    await prefs.setInt(_totalChallengeGamesKey, totalChallengeGames);
    await prefs.setInt(_classicBestScoreKey, classicBestScore);
    await prefs.setInt(_timeAttackBestScoreKey, timeAttackBestScore);
    await prefs.setInt(_dailyBestScoreKey, dailyBestScore);
    await prefs.setInt(_survivalBestScoreKey, survivalBestScore);
    await prefs.setInt(_duelWinsKey, duelWins);
    await prefs.setInt(_duelLossesKey, duelLosses);
    await prefs.setInt(_duelDrawsKey, duelDraws);
    await prefs.setInt(_dailyChallengeStreakKey, dailyChallengeStreak);
    await prefs.setInt(_tabooGamesKey, tabooGames);
    await prefs.setInt(_tabooWinsTeamAKey, tabooWinsTeamA);
    await prefs.setInt(_tabooWinsTeamBKey, tabooWinsTeamB);

    if (dailyChallengeDate == null) {
      await prefs.remove(_dailyChallengeDateKey);
    } else {
      await prefs.setString(_dailyChallengeDateKey, dailyChallengeDate!);
    }

    if (lastStudyDate == null) {
      await prefs.remove(_lastStudyDateKey);
    } else {
      await prefs.setString(
          _lastStudyDateKey, lastStudyDate!.toIso8601String());
    }

    await prefs.setStringList(
        _completedLessonsKey, completedLessons.toList()..sort());
    await prefs.setStringList(
        _savedVocabularyKey, savedVocabularyWords.toList()..sort());
    await prefs.setStringList(
        _knownVocabularyKey, knownVocabularyWords.toList()..sort());
    await prefs.setStringList(
        _masteredVocabularyKey, masteredVocabularyWords.toList()..sort());
  }

  void _notifyAndSave() {
    notifyListeners();
    saveProgress();
  }

  void setEnglishUi(bool value) {
    if (isEnglish == value) return;
    isEnglish = value;
    _notifyAndSave();
  }

  void setThemeMode(SpeakeryThemeMode value) {
    if (themeMode == value) return;
    themeMode = value;
    _notifyAndSave();
  }

  void setOnboardingChoices({
    required String goal,
    required String level,
  }) {
    learningGoal = goal.trim().isEmpty ? learningGoal : goal.trim();
    englishLevel = level.trim().isEmpty ? englishLevel : level.trim();
    _notifyAndSave();
  }

  void setSoundEffects(bool value) {
    if (soundEffects == value) return;
    soundEffects = value;
    _notifyAndSave();
  }

  void setHaptics(bool value) {
    if (haptics == value) return;
    haptics = value;
    _notifyAndSave();
  }

  void setEnglishLevel(String value) {
    final clean = value.trim();
    if (clean.isEmpty || englishLevel == clean) return;
    englishLevel = clean;
    _notifyAndSave();
  }

  void setDailyGoal(String value) {
    final clean = value.trim();
    if (clean.isEmpty || dailyGoal == clean) return;
    dailyGoal = clean;
    _notifyAndSave();
  }

  void setVoxaPersonality(String value) {
    final clean = value.trim();
    if (clean.isEmpty || voxaPersonality == clean) return;
    voxaPersonality = clean;
    _notifyAndSave();
  }

  void addXP(int amount) {
    if (amount <= 0) return;
    xp += amount;
    updateStreak();
    _notifyAndSave();
  }

  void completeLesson(String lessonId, {int rewardXP = 0}) {
    final cleanId = _cleanId(lessonId);
    if (cleanId.isEmpty) return;

    final wasNew = completedLessons.add(cleanId);

    if (wasNew && rewardXP > 0) {
      xp += rewardXP;
    }

    updateStreak();
    _notifyAndSave();
  }

  bool isLessonCompleted(String lessonId) {
    return completedLessons.contains(_cleanId(lessonId));
  }

  bool isVocabularySaved(String wordId) {
    return savedVocabularyWords.contains(_cleanId(wordId));
  }

  bool isVocabularyKnown(String wordId) {
    return knownVocabularyWords.contains(_cleanId(wordId));
  }

  bool isVocabularyMastered(String wordId) {
    return masteredVocabularyWords.contains(_cleanId(wordId));
  }

  void toggleSavedVocabulary(String wordId) {
    final cleanId = _cleanId(wordId);
    if (cleanId.isEmpty) return;

    if (savedVocabularyWords.contains(cleanId)) {
      savedVocabularyWords.remove(cleanId);
      _notifyAndSave();
      return;
    }

    savedVocabularyWords.add(cleanId);
    addXP(1);
  }

  void toggleKnownVocabulary(String wordId) {
    final cleanId = _cleanId(wordId);
    if (cleanId.isEmpty) return;

    if (knownVocabularyWords.contains(cleanId)) {
      knownVocabularyWords.remove(cleanId);
      _notifyAndSave();
      return;
    }

    knownVocabularyWords.add(cleanId);
    addXP(2);
  }

  void markVocabularyMastered(String wordId) {
    final cleanId = _cleanId(wordId);
    if (cleanId.isEmpty) return;

    final wasNew = masteredVocabularyWords.add(cleanId);
    knownVocabularyWords.add(cleanId);

    if (wasNew) {
      addXP(5);
      return;
    }

    _notifyAndSave();
  }

  void unmarkVocabularyMastered(String wordId) {
    final cleanId = _cleanId(wordId);
    if (cleanId.isEmpty) return;

    masteredVocabularyWords.remove(cleanId);
    _notifyAndSave();
  }

  void completeVocabularyPractice({
    int rewardXP = 10,
  }) {
    if (rewardXP > 0) {
      xp += rewardXP;
    }

    updateStreak();
    _notifyAndSave();
  }

  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastStudyDate == null) {
      streak = 1;
      lastStudyDate = today;
      return;
    }

    final last = DateTime(
      lastStudyDate!.year,
      lastStudyDate!.month,
      lastStudyDate!.day,
    );

    final difference = today.difference(last).inDays;

    if (difference == 0) {
      lastStudyDate = today;
      return;
    }

    if (difference == 1) {
      streak += 1;
    } else {
      streak = 1;
    }

    lastStudyDate = today;
  }

  bool get studiedToday {
    if (lastStudyDate == null) return false;

    final now = DateTime.now();
    return lastStudyDate!.year == now.year &&
        lastStudyDate!.month == now.month &&
        lastStudyDate!.day == now.day;
  }

  void recordChallengeResult({
    required String mode,
    required int score,
    required int total,
    required int earnedXP,
    int opponentScore = 0,
  }) {
    final cleanMode = mode.toLowerCase().trim();
    totalChallengeGames += 1;
    challengeXP += earnedXP.clamp(0, 100000);
    xp += maxInt(0, earnedXP ~/ 2);

    switch (cleanMode) {
      case 'classic':
        classicBestScore = maxInt(classicBestScore, score);
        break;
      case 'timed':
        timeAttackBestScore = maxInt(timeAttackBestScore, score);
        break;
      case 'daily':
        dailyBestScore = maxInt(dailyBestScore, score);
        if (!dailyChallengeDoneToday) {
          dailyChallengeDate = todayKey;
          dailyChallengeStreak += 1;
        }
        break;
      case 'survival':
        survivalBestScore = maxInt(survivalBestScore, score);
        break;
      case 'duel':
        if (score > opponentScore) {
          duelWins += 1;
        } else if (score < opponentScore) {
          duelLosses += 1;
        } else {
          duelDraws += 1;
        }
        break;
    }

    updateStreak();
    _notifyAndSave();
  }

  void recordTabooResult({
    required int teamAScore,
    required int teamBScore,
  }) {
    tabooGames += 1;

    if (teamAScore > teamBScore) {
      tabooWinsTeamA += 1;
    } else if (teamBScore > teamAScore) {
      tabooWinsTeamB += 1;
    }

    challengeXP += maxInt(teamAScore, teamBScore) * 4;
    updateStreak();
    _notifyAndSave();
  }

  int maxInt(int a, int b) => a > b ? a : b;

  void activatePremiumAccess() {
    isPremium = true;
    _notifyAndSave();
  }

  void deactivatePremiumAccess() {
    isPremium = false;
    _notifyAndSave();
  }

  void resetLocalProgress() {
    xp = 0;
    streak = 0;
    isPremium = false;
    soundEffects = true;
    haptics = true;
    dailyGoal = '10 min';
    voxaPersonality = 'Friendly Coach';
    lastStudyDate = null;
    completedLessons.clear();
    savedVocabularyWords.clear();
    knownVocabularyWords.clear();
    masteredVocabularyWords.clear();
    challengeXP = 0;
    totalChallengeGames = 0;
    classicBestScore = 0;
    timeAttackBestScore = 0;
    dailyBestScore = 0;
    survivalBestScore = 0;
    duelWins = 0;
    duelLosses = 0;
    duelDraws = 0;
    dailyChallengeDate = null;
    dailyChallengeStreak = 0;
    tabooGames = 0;
    tabooWinsTeamA = 0;
    tabooWinsTeamB = 0;
    _notifyAndSave();
  }
}
