import 'package:flutter_test/flutter_test.dart';

import 'package:speakery/data/reading/reading_models.dart';
import 'package:speakery/data/reading/reading_repository.dart';

void main() {
  test('Reading quality audit (pure data)', () {
    const repository = ReadingRepository();
    final failures = <String>[];

    final seenClusterIds = <String>{};
    final seenLessonIds = <String>{};
    final seenQuestionIds = <String>{};
    final validQuestionTypes = ReadingQuestionType.values.toSet();

    for (final spec in repository.levelSpecs) {
      _require(
        spec.minWords > 0 && spec.maxWords >= spec.minWords,
        '${spec.level.code}: invalid word range',
        failures,
      );
      _require(
        spec.minQuestions > 0 && spec.maxQuestions >= spec.minQuestions,
        '${spec.level.code}: invalid question range',
        failures,
      );
      _require(
        spec.readingGoal.trim().isNotEmpty,
        '${spec.level.code}: readingGoal is empty',
        failures,
      );
      _require(
        spec.textTypes.isNotEmpty,
        '${spec.level.code}: textTypes is empty',
        failures,
      );
      _require(
        spec.questionTypes.isNotEmpty,
        '${spec.level.code}: questionTypes is empty',
        failures,
      );
    }

    for (final cluster in repository.allClusters) {
      final clusterRef =
          '${cluster.level.code} cluster -> ${cluster.title} (${cluster.id})';

      _require(
          cluster.id.trim().isNotEmpty, '$clusterRef: id is empty', failures);
      _require(
        seenClusterIds.add(cluster.id),
        '$clusterRef: duplicate cluster id: ${cluster.id}',
        failures,
      );
      _require(cluster.title.trim().isNotEmpty, '$clusterRef: title is empty',
          failures);
      _require(cluster.subtitle.trim().isNotEmpty,
          '$clusterRef: subtitle is empty', failures);
      _require(cluster.lessons.isNotEmpty, '$clusterRef: lessons is empty',
          failures);
      _require(!_looksPlaceholder(cluster.title),
          '$clusterRef: title looks placeholder', failures);
      _require(!_looksPlaceholder(cluster.subtitle),
          '$clusterRef: subtitle looks placeholder', failures);

      for (final lesson in cluster.lessons) {
        final ref = '${lesson.level.code} -> ${lesson.title} (${lesson.id})';

        _require(lesson.id.trim().isNotEmpty, '$ref: id is empty', failures);
        _require(
          seenLessonIds.add(lesson.id),
          '$ref: duplicate lesson id: ${lesson.id}',
          failures,
        );
        _require(
          lesson.clusterId == cluster.id,
          '$ref: clusterId mismatch. expected=${cluster.id}, got=${lesson.clusterId}',
          failures,
        );
        _require(
          lesson.level == cluster.level,
          '$ref: lesson level does not match cluster level',
          failures,
        );
        _require(
            lesson.title.trim().isNotEmpty, '$ref: title is empty', failures);
        _require(lesson.subtitle.trim().isNotEmpty, '$ref: subtitle is empty',
            failures);
        _require(lesson.textType.trim().isNotEmpty, '$ref: textType is empty',
            failures);
        _require(
          lesson.orientationEnglish.trim().isNotEmpty,
          '$ref: orientationEnglish is empty',
          failures,
        );
        _require(!_looksPlaceholder(lesson.title),
            '$ref: title looks placeholder', failures);
        _require(!_looksPlaceholder(lesson.subtitle),
            '$ref: subtitle looks placeholder', failures);
        _require(
          !_looksPlaceholder(lesson.orientationEnglish),
          '$ref: orientationEnglish looks placeholder',
          failures,
        );

        // B1-C2 may be present later as premium/coming soon. For now only audit full
        // lesson quality when there is actual reading text and questions.
        if (lesson.isPremium) continue;

        _require(lesson.paragraphs.isNotEmpty, '$ref: paragraphs are empty',
            failures);
        _require(
            lesson.questions.isNotEmpty, '$ref: questions are empty', failures);

        for (var i = 0; i < lesson.paragraphs.length; i++) {
          final paragraph = lesson.paragraphs[i];
          _require(
            paragraph.number == i + 1,
            '$ref: paragraph number should be ${i + 1}, got ${paragraph.number}',
            failures,
          );
          _require(
            paragraph.text.trim().isNotEmpty,
            '$ref: paragraph ${paragraph.number} is empty',
            failures,
          );
          _require(
            !_looksPlaceholder(paragraph.text),
            '$ref: paragraph ${paragraph.number} looks placeholder',
            failures,
          );
        }

        final computed = lesson.wordCount;
        final spec = repository.specForLevel(lesson.level);
        final mobileRange = _mobileWordRangeFor(lesson.level);

        // Mobile-first reading ranges.
        // Speakery is a phone-first app, so lessons should feel readable on
        // small screens instead of becoming long exam passages.
        _require(
          computed >= mobileRange.min,
          '$ref: computed word count too small: $computed, expected mobile range ${mobileRange.min}-${mobileRange.max}',
          failures,
        );
        _require(
          computed <= mobileRange.max,
          '$ref: computed word count too large: $computed, expected mobile range ${mobileRange.min}-${mobileRange.max}',
          failures,
        );

        _require(
          lesson.questions.length >= spec.minQuestions - 1,
          '$ref: questions too few: ${lesson.questions.length}, expected around ${spec.minQuestions}-${spec.maxQuestions}',
          failures,
        );
        _require(
          lesson.questions.length <= spec.maxQuestions + 2,
          '$ref: questions too many: ${lesson.questions.length}, expected around ${spec.minQuestions}-${spec.maxQuestions}',
          failures,
        );

        for (final gloss in lesson.glosses) {
          final gRef = '$ref: gloss ${gloss.word}';
          _require(
              gloss.word.trim().isNotEmpty, '$gRef: word is empty', failures);
          _require(
            gloss.meaningEnglish.trim().isNotEmpty,
            '$gRef: meaningEnglish is empty',
            failures,
          );
          _require(gloss.example.trim().isNotEmpty, '$gRef: example is empty',
              failures);
          _require(!_looksPlaceholder(gloss.word),
              '$gRef: word looks placeholder', failures);
          _require(
            !_looksPlaceholder(gloss.meaningEnglish),
            '$gRef: meaningEnglish looks placeholder',
            failures,
          );
        }

        for (final item in lesson.vocabularyReview) {
          final vRef = '$ref: vocab review ${item.word}';
          _require(
              item.word.trim().isNotEmpty, '$vRef: word is empty', failures);
          _require(
            item.originalSentence.trim().isNotEmpty,
            '$vRef: originalSentence is empty',
            failures,
          );
          _require(
            item.newExampleSentence.trim().isNotEmpty,
            '$vRef: newExampleSentence is empty',
            failures,
          );
          _require(
            item.meaningEnglish.trim().isNotEmpty,
            '$vRef: meaningEnglish is empty',
            failures,
          );
        }

        for (final q in lesson.questions) {
          final qRef = '$ref: q ${q.id}';

          _require(q.id.trim().isNotEmpty, '$qRef: id is empty', failures);
          _require(seenQuestionIds.add(q.id), '$qRef: duplicate question id',
              failures);
          _require(validQuestionTypes.contains(q.type),
              '$qRef: invalid question type', failures);
          _require(q.question.trim().isNotEmpty, '$qRef: question is empty',
              failures);
          _require(
              q.answer.trim().isNotEmpty, '$qRef: answer is empty', failures);
          _require(
            q.explanationEnglish.trim().isNotEmpty,
            '$qRef: explanationEnglish is empty',
            failures,
          );
          _require(!_looksPlaceholder(q.question),
              '$qRef: question looks placeholder', failures);
          _require(
            !_looksPlaceholder(q.explanationEnglish),
            '$qRef: explanationEnglish looks placeholder',
            failures,
          );

          if (q.evidenceParagraph != null) {
            _require(
              q.evidenceParagraph! >= 1 &&
                  q.evidenceParagraph! <= lesson.paragraphs.length,
              '$qRef: evidenceParagraph out of range: ${q.evidenceParagraph}',
              failures,
            );
          }

          if (q.options.isNotEmpty) {
            final normalized = q.options.map(_norm).toList();

            _require(
              normalized.toSet().length == normalized.length,
              '$qRef: duplicate options: ${q.options}',
              failures,
            );
            _require(
              q.options.contains(q.answer),
              '$qRef: answer is not inside options. answer=${q.answer}, options=${q.options}',
              failures,
            );

            if (q.type == ReadingQuestionType.trueFalse) {
              _require(
                normalized.length == 2,
                '$qRef: trueFalse should have exactly 2 options',
                failures,
              );
              _require(
                normalized.contains('true') && normalized.contains('false'),
                '$qRef: trueFalse options should include True and False',
                failures,
              );
            } else if (q.type == ReadingQuestionType.trueFalseNotGiven) {
              _require(
                normalized.length == 3,
                '$qRef: trueFalseNotGiven should have exactly 3 options',
                failures,
              );
            } else {
              _require(
                q.options.length >= 3,
                '$qRef: objective question should have at least 3 options',
                failures,
              );
            }
          }
        }
      }
    }

    expect(failures.isEmpty, true, reason: failures.join('\n'));
  });
}

({int min, int max}) _mobileWordRangeFor(ReadingLevel level) {
  switch (level) {
    case ReadingLevel.a1:
      return (min: 45, max: 120);
    case ReadingLevel.a2:
      return (min: 80, max: 180);
    case ReadingLevel.b1:
      return (min: 160, max: 320);
    case ReadingLevel.b2:
      return (min: 250, max: 450);
    case ReadingLevel.c1:
      return (min: 320, max: 600);
    case ReadingLevel.c2:
      return (min: 400, max: 750);
  }
}

void _require(bool ok, String message, List<String> failures) {
  if (!ok) failures.add(message);
}

bool _looksPlaceholder(String value) {
  final v = value.toLowerCase();
  return v.contains('lorem') ||
      v.contains('placeholder') ||
      v.contains('todo') ||
      v.contains('coming soon');
}

String _norm(String text) {
  return text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
