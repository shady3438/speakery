import 'reading_a1.dart';
import 'reading_a2.dart';
import 'reading_b1.dart';
import 'reading_b2.dart';
import 'reading_c1.dart';
import 'reading_c2.dart';
import 'reading_level_specs.dart';
import 'reading_models.dart';

/// Simple in-memory repository for the Reading module.
/// Later this can be replaced by local database / backend / premium unlock logic.

class ReadingRepository {
  const ReadingRepository();

  List<ReadingLevelSpec> get levelSpecs => readingLevelSpecs;

  List<ReadingCluster> get allClusters => [
        ...readingA1Clusters,
        ...readingA2Clusters,
        ...readingB1Clusters,
        ...readingB2Clusters,
        ...readingC1Clusters,
        ...readingC2Clusters,
      ];

  List<ReadingCluster> clustersByLevel(ReadingLevel level) {
    return allClusters
        .where((cluster) => cluster.level == level)
        .toList(growable: false);
  }

  List<ReadingLesson> lessonsByLevel(ReadingLevel level) {
    return clustersByLevel(level)
        .expand((cluster) => cluster.lessons)
        .toList(growable: false);
  }

  ReadingLevelSpec specForLevel(ReadingLevel level) {
    return levelSpecs.firstWhere((spec) => spec.level == level);
  }

  ReadingLesson? lessonById(String id) {
    for (final cluster in allClusters) {
      for (final lesson in cluster.lessons) {
        if (lesson.id == id) return lesson;
      }
    }
    return null;
  }

  ReadingCluster? clusterById(String id) {
    for (final cluster in allClusters) {
      if (cluster.id == id) return cluster;
    }
    return null;
  }

  double completionForLevel(
    ReadingLevel level,
    Map<String, ReadingProgress> progress,
  ) {
    final lessons = lessonsByLevel(level);
    if (lessons.isEmpty) return 0;

    final completed = lessons.where((lesson) {
      final item = progress[lesson.id];
      return item?.isCompleted ?? false;
    }).length;

    return completed / lessons.length;
  }

  bool isLevelMastered(
    ReadingLevel level,
    Map<String, ReadingProgress> progress,
  ) {
    final lessons = lessonsByLevel(level);
    if (lessons.isEmpty) return false;

    final completedWithScore = lessons.where((lesson) {
      final item = progress[lesson.id];
      if (item == null || !item.isCompleted) return false;
      return item.percentage >= .70;
    }).length;

    return completedWithScore / lessons.length >= .80;
  }
}
