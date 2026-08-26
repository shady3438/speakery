import 'learning_models.dart';

import 'reading_content.dart';
import 'speaking_content.dart';
import 'writing_content.dart';

final Map<String, LessonContent> allLessons = {
  ...readingLessons,
  ...speakingLessons,
  ...writingLessons,
};

LessonContent? getLessonByKey(String key) {
  final cleanKey = key.toLowerCase().trim();

  if (allLessons.containsKey(cleanKey)) {
    return allLessons[cleanKey];
  }

  for (final entry in allLessons.entries) {
    final normalized = entry.key.toLowerCase().trim();

    if (normalized == cleanKey ||
        normalized.contains(cleanKey) ||
        cleanKey.contains(normalized)) {
      return entry.value;
    }
  }

  return null;
}
