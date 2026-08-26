import '../app_progress.dart';
import '../reading/reading_models.dart';
import '../reading/reading_repository.dart';

/// Speakery level progression rules.
///
/// This is NOT premium logic.
/// This file only decides whether a CEFR level should be open based on
/// learning progress.
///
/// Current product logic:
/// - A1 is always open.
/// - Reading levels unlock when the previous level reaches 60% completion.
/// - Grammar levels unlock when the previous level reaches 50% completion.
/// - Vocabulary should not be hard locked; show a warning for higher levels.
class LevelUnlockService {
  const LevelUnlockService({
    this.readingRepository = const ReadingRepository(),
  });

  final ReadingRepository readingRepository;

  static const double readingUnlockThreshold = .60;
  static const double grammarUnlockThreshold = .50;

  bool isReadingLevelUnlocked(
    ReadingLevel level, {
    AppProgress? progress,
  }) {
    if (level == ReadingLevel.a1) return true;

    final appProgress = progress ?? AppProgress.instance;
    final previous = previousReadingLevel(level);
    if (previous == null) return true;

    return readingLevelCompletion(previous, appProgress) >=
        readingUnlockThreshold;
  }

  double readingLevelCompletion(
    ReadingLevel level,
    AppProgress progress,
  ) {
    final lessons = readingRepository.lessonsByLevel(level);
    if (lessons.isEmpty) return 0;

    final completed = lessons.where((lesson) {
      return progress.isLessonCompleted(lesson.id);
    }).length;

    return completed / lessons.length;
  }

  int completedReadingLessons(
    ReadingLevel level,
    AppProgress progress,
  ) {
    final lessons = readingRepository.lessonsByLevel(level);
    return lessons.where((lesson) {
      return progress.isLessonCompleted(lesson.id);
    }).length;
  }

  int totalReadingLessons(ReadingLevel level) {
    return readingRepository.lessonsByLevel(level).length;
  }

  ReadingLevel? previousReadingLevel(ReadingLevel level) {
    const values = ReadingLevel.values;
    final index = values.indexOf(level);
    if (index <= 0) return null;
    return values[index - 1];
  }

  ReadingLevel? nextReadingLevel(ReadingLevel level) {
    const values = ReadingLevel.values;
    final index = values.indexOf(level);
    if (index == -1 || index + 1 >= values.length) return null;
    return values[index + 1];
  }

  String readingLockedMessage(
    ReadingLevel level, {
    required bool isEnglish,
    AppProgress? progress,
  }) {
    final previous = previousReadingLevel(level);
    if (previous == null) {
      return isEnglish ? '${level.code} is available.' : '${level.code} açık.';
    }

    final appProgress = progress ?? AppProgress.instance;
    final completion = readingLevelCompletion(previous, appProgress);
    final current = (completion * 100).round();
    final target = (readingUnlockThreshold * 100).round();

    return isEnglish
        ? 'Complete $target% of ${previous.code} Reading to unlock ${level.code}. Current: $current%.'
        : '${level.code} açmak için ${previous.code} Reading’in %$target kadarı bitmeli. Şu an: %$current.';
  }

  /// Grammar is currently backed by AppProgress lesson IDs, but its full
  /// repository is separate from Reading. Keep this generic so Grammar can pass
  /// lesson keys by level later.
  bool isGrammarLevelUnlocked({
    required String levelCode,
    required Map<String, List<String>> lessonKeysByLevel,
    AppProgress? progress,
  }) {
    if (levelCode == 'A1') return true;

    final previousCode = previousLevelCode(levelCode);
    if (previousCode == null) return true;

    final appProgress = progress ?? AppProgress.instance;
    final completion = grammarLevelCompletion(
      levelCode: previousCode,
      lessonKeysByLevel: lessonKeysByLevel,
      progress: appProgress,
    );

    return completion >= grammarUnlockThreshold;
  }

  double grammarLevelCompletion({
    required String levelCode,
    required Map<String, List<String>> lessonKeysByLevel,
    required AppProgress progress,
  }) {
    final keys = lessonKeysByLevel[levelCode] ?? const <String>[];
    if (keys.isEmpty) return 0;

    final completed = keys.where(progress.isLessonCompleted).length;
    return completed / keys.length;
  }

  bool shouldWarnBeforeVocabularyLevel(String levelCode) {
    return levelCode == 'B1' ||
        levelCode == 'B2' ||
        levelCode == 'C1' ||
        levelCode == 'C2';
  }

  String? previousLevelCode(String levelCode) {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final index = levels.indexOf(levelCode.toUpperCase());
    if (index <= 0) return null;
    return levels[index - 1];
  }

  String? nextLevelCode(String levelCode) {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final index = levels.indexOf(levelCode.toUpperCase());
    if (index == -1 || index + 1 >= levels.length) return null;
    return levels[index + 1];
  }
}
