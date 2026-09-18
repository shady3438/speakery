import 'package:flutter_test/flutter_test.dart';
import 'package:speakery/data/grammar/grammar_repository.dart';

/// Guards the hand-written question banks. A wrong answer string, a duplicate
/// option or a blank with no gap is invisible in review but breaks the drill
/// for a learner, so every level that carries a bank is checked here.
void main() {
  // A1 and A2 already shipped ten questions per topic from their own data.
  const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  for (final level in levels) {
    final topics = GrammarRepository.topicsForLevel(level);

    test('$level: every topic carries ten questions', () {
      for (final topic in topics) {
        final quiz = GrammarRepository.lessonForTopic(topic).quiz;
        expect(quiz.length, 10, reason: '${topic.id} (${topic.title})');
      }
    });

    test('$level: every question is answerable', () {
      for (final topic in topics) {
        for (final q in GrammarRepository.lessonForTopic(topic).quiz) {
          expect(q.options, contains(q.answer),
              reason: '${q.id}: answer is not one of the options');
          expect(q.options.length, greaterThanOrEqualTo(2), reason: q.id);
          expect(q.options.toSet().length, q.options.length,
              reason: '${q.id}: duplicate options');
          for (final option in q.options) {
            expect(option.trim(), isNotEmpty,
                reason: '${q.id}: blank option');
          }
          expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        }
      }
    });

    test('$level: no question is asked twice', () {
      for (final topic in topics) {
        final quiz = GrammarRepository.lessonForTopic(topic).quiz;
        // The old generated pack shipped the same blank under two ids, which
        // made a "ten question" drill feel like one. Compare what a learner
        // actually sees, not the id.
        final seen = quiz
            .map((q) => '${q.sentence ?? q.prompt}|${q.options.join(",")}')
            .toSet();
        expect(seen.length, quiz.length,
            reason: '${topic.id}: a question repeats');
      }
    });

    test('$level: bank sentences contain exactly one gap', () {
      for (final topic in topics) {
        final quiz = GrammarRepository.lessonForTopic(topic).quiz;
        for (final q in quiz.where((q) => q.id.contains('_bank_'))) {
          expect(q.sentence, isNotNull, reason: q.id);
          expect('___'.allMatches(q.sentence!).length, 1,
              reason: '${q.id}: expected one gap');
        }
      }
    });
  }
}
