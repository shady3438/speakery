import 'package:flutter_test/flutter_test.dart';

import 'package:speakery/data/grammar/grammar_generator.dart';
import 'package:speakery/data/grammar/grammar_repository.dart';
import 'package:speakery/presentation/grammar_skill_screen/grammar_display_model.dart';
import 'package:speakery/presentation/grammar_skill_screen/grammar_quiz_normalizer.dart';
import 'package:speakery/presentation/grammar_skill_screen/grammar_ui_text.dart';

void main() {
  test('grammar text repair is conservative and idempotent', () {
    const damaged = <String, String>{
      'H?zl? Bak1_': 'Hızlı bakış',
      'Ge�mi_te ba_lay1p bitmi? olaylar1 anlat1r.':
          'Geçmişte başlayıp bitmiş olayları anlatır.',
      'Bir eylemin neden yap?ld1?1n1 a�1klamak i�in to + V1 kullan?l?r.':
          'Bir eylemin neden yapıldığını açıklamak için to + V1 kullanılır.',
      'Mustn?t yasak; don?t have to zorunluluk olmad1?1n1 anlat1r.':
          "Mustn't yasak; don't have to zorunluluk olmadığını anlatır.",
    };

    for (final entry in damaged.entries) {
      final repaired = repairGrammarMojibake(entry.key);
      expect(repaired, entry.value);
      expect(repairGrammarMojibake(repaired), repaired,
          reason: 'repair must be idempotent for "$repaired"');
    }

    const clean = 'İki şeyi karşılaştırırken doğru sıfatı kullan.';
    expect(repairGrammarMojibake(clean), clean);
  });

  test('all A1-C2 grammar lessons have complete bilingual UI content', () {
    const levels = <String>['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    var lessonCount = 0;

    for (final level in levels) {
      for (final topic in GrammarRepository.topicsForLevel(level)) {
        lessonCount++;
        final lesson = GrammarRepository.lessonForTopic(topic);
        final key = grammarDisplayKeyFor(lesson);
        final display = grammarDisplayLessonFor(lesson, true);
        final ref = '$level / ${topic.title}';

        expect(key, isNotEmpty, reason: '$ref has no stable display key');
        expect(display.learnTitleEn.trim(), isNotEmpty,
            reason: '$ref has no English title');
        expect(display.learnTitleTr.trim(), isNotEmpty,
            reason: '$ref has no Turkish title');
        expect(display.learnBodyEn.trim(), isNotEmpty,
            reason: '$ref has no English explanation');
        expect(display.learnBodyTr.trim(), isNotEmpty,
            reason: '$ref has no Turkish explanation');
        expect(display.structureBulletsEn.length, greaterThanOrEqualTo(3),
            reason: '$ref needs at least 3 English structure points');
        expect(display.structureBulletsTr.length, greaterThanOrEqualTo(3),
            reason: '$ref needs at least 3 Turkish structure points');
        expect(display.usageNotesEn.length, greaterThanOrEqualTo(3),
            reason: '$ref needs at least 3 English usage notes');
        expect(display.usageNotesTr.length, greaterThanOrEqualTo(3),
            reason: '$ref needs at least 3 Turkish usage notes');

        for (final text in <String>[
          display.learnTitleEn,
          display.learnTitleTr,
          display.learnBodyEn,
          display.learnBodyTr,
          ...display.structureBulletsEn,
          ...display.structureBulletsTr,
          ...display.usageNotesEn,
          ...display.usageNotesTr,
        ]) {
          expect(_looksBroken(text), isFalse,
              reason: '$ref contains broken visible text: $text');
        }

        if (level == 'A1' || level == 'A2') {
          expect(_containsTurkishLanguage(display.learnBodyTr), isTrue,
              reason: '$ref Turkish body fell back to English');
          expect(
              _containsTurkishLanguage(display.usageNotesTr.join(' ')), isTrue,
              reason: '$ref Turkish usage notes fell back to English');
          expect(_containsTurkishCharacters(display.learnBodyEn), isFalse,
              reason: '$ref English body contains Turkish UI text');
        }

        for (final isEnglish in <bool>[true, false]) {
          final quiz = fillBlankQuizPackForLesson(lesson, isEnglish);
          expect(quiz.length, greaterThanOrEqualTo(6),
              reason:
                  '$ref needs at least 6 ${isEnglish ? 'EN' : 'TR'} quiz questions');
          for (final question in quiz) {
            expect(question.sentence, contains('_____'),
                reason: '$ref quiz needs a visible blank');
            expect(question.options.length, 4,
                reason: '$ref quiz needs 4 options');
            expect(question.options, contains(question.answer),
                reason: '$ref quiz answer must be among options');
            expect(question.explanation.trim(), isNotEmpty,
                reason: '$ref quiz needs an explanation');
            for (final text in <String>[
              question.prompt,
              question.sentence ?? '',
              ...question.options,
              question.answer,
              question.explanation,
            ]) {
              expect(_looksBroken(text), isFalse,
                  reason:
                      '$ref ${isEnglish ? 'EN' : 'TR'} quiz contains broken text: $text');
            }
            if (level == 'A1' || level == 'A2') {
              if (isEnglish) {
                expect(
                    _containsTurkishCharacters(question.explanation), isFalse,
                    reason:
                        '$ref English quiz explanation contains Turkish text');
              } else {
                expect(_containsTurkishLanguage(question.explanation), isTrue,
                    reason:
                        '$ref Turkish quiz explanation fell back to English');
              }
            }
          }
        }

        final logicPoints = generateGrammarLogicPoints(lesson);
        expect(logicPoints, isNotEmpty, reason: '$ref needs logic points');
        for (final point in logicPoints) {
          expect(point.model.trim(), isNotEmpty,
              reason: '$ref has an empty model sentence');
          expect(point.avoid.trim(), isNotEmpty,
              reason: '$ref has an empty mistake sentence');
        }
      }
    }

    expect(lessonCount, 96);
  });
}

bool _looksBroken(String value) {
  return value.contains('\uFFFD') ||
      value.contains('ï¿½') ||
      value.contains('�') ||
      value.contains('â€') ||
      RegExp(r'[ÃÄÅ]').hasMatch(value) ||
      RegExp(r'[a-zA-Z][?1_][a-zA-Z]').hasMatch(value);
}

bool _containsTurkishCharacters(String value) =>
    RegExp(r'[çğıöşüÇĞİÖŞÜ]').hasMatch(value);

bool _containsTurkishLanguage(String value) {
  if (_containsTurkishCharacters(value)) return true;
  final lower = value.toLowerCase();
  return const <String>[
    ' cümle',
    ' fiil',
    ' isim',
    ' doğru',
    ' kullan',
    ' zaman',
    ' soru',
    ' olumsuz',
    ' anlat',
    ' için',
  ].any(lower.contains);
}
