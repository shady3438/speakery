import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'reading_models.dart';

/// Local reading score/progress storage.
///
/// AppProgress already stores completed lesson IDs and XP.
/// This store adds reading-specific attempt data:
/// - latest score
/// - total questions
/// - completion percentage
/// - last attempt time
///
/// It is intentionally separate so we do not bloat AppProgress while the
/// Reading module is still evolving.
class ReadingProgressStore {
  ReadingProgressStore._();

  static final ReadingProgressStore instance = ReadingProgressStore._();

  static const String _key = 'speakery_reading_progress';

  Future<Map<String, ReadingProgress>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return <String, ReadingProgress>{};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return <String, ReadingProgress>{};
      }

      final result = <String, ReadingProgress>{};

      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! Map<String, dynamic>) continue;

        result[entry.key] = ReadingProgress(
          lessonId: entry.key,
          hasOpened: value['hasOpened'] == true,
          hasFinishedReading: value['hasFinishedReading'] == true,
          isCompleted: value['isCompleted'] == true,
          latestScore: _asInt(value['latestScore']),
          totalQuestions: _asInt(value['totalQuestions']),
          lastAttemptAt: _asDate(value['lastAttemptAt']),
        );
      }

      return result;
    } catch (_) {
      return <String, ReadingProgress>{};
    }
  }

  Future<ReadingProgress?> progressFor(String lessonId) async {
    final all = await loadAll();
    return all[_cleanId(lessonId)];
  }

  Future<void> markOpened(String lessonId) async {
    final cleanId = _cleanId(lessonId);
    if (cleanId.isEmpty) return;

    final all = await loadAll();
    final current = all[cleanId] ?? ReadingProgress(lessonId: cleanId);

    all[cleanId] = current.copyWith(hasOpened: true);

    await _saveAll(all);
  }

  Future<void> recordAttempt({
    required String lessonId,
    required int score,
    required int totalQuestions,
    bool completed = true,
  }) async {
    final cleanId = _cleanId(lessonId);
    if (cleanId.isEmpty) return;

    final all = await loadAll();
    final current = all[cleanId] ?? ReadingProgress(lessonId: cleanId);

    all[cleanId] = current.copyWith(
      hasOpened: true,
      hasFinishedReading: true,
      isCompleted: completed,
      latestScore: score.clamp(0, totalQuestions),
      totalQuestions: totalQuestions < 0 ? 0 : totalQuestions,
      lastAttemptAt: DateTime.now(),
    );

    await _saveAll(all);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _saveAll(Map<String, ReadingProgress> progress) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = <String, dynamic>{};
    for (final entry in progress.entries) {
      final item = entry.value;
      encoded[entry.key] = <String, dynamic>{
        'hasOpened': item.hasOpened,
        'hasFinishedReading': item.hasFinishedReading,
        'isCompleted': item.isCompleted,
        'latestScore': item.latestScore,
        'totalQuestions': item.totalQuestions,
        'lastAttemptAt': item.lastAttemptAt?.toIso8601String(),
      };
    }

    await prefs.setString(_key, jsonEncode(encoded));
  }

  static String _cleanId(String value) {
    return value.toLowerCase().trim();
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _asDate(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }
}
