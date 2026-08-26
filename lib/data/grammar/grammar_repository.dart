import 'package:speakery/data/grammar/grammar_a1.dart';
import 'package:speakery/data/grammar/grammar_a2.dart';
import 'package:speakery/data/grammar/grammar_b1.dart';
import 'package:speakery/data/grammar/grammar_b2.dart';
import 'package:speakery/data/grammar/grammar_c1.dart';
import 'package:speakery/data/grammar/grammar_c2.dart';
import 'package:speakery/data/grammar/grammar_models.dart';

class GrammarRepository {
  const GrammarRepository._();

  static List<GrammarTopic> topicsForLevel(String level) {
    switch (level) {
      case 'A1':
        return grammarA1Topics;
      case 'A2':
        return grammarA2Topics;
      case 'B1':
        return grammarB1Topics;
      case 'B2':
        return grammarB2Topics;
      case 'C1':
        return grammarC1Topics;
      case 'C2':
        return grammarC2Topics;
      default:
        return grammarA1Topics;
    }
  }

  static GrammarLesson lessonForTopic(GrammarTopic topic) {
    if (topic.level == 'A1') {
      final lesson = a1LessonForTopic(topic);
      if (lesson != null) return lesson;
    }

    if (topic.level == 'A2') {
      final lesson = a2LessonForTopic(topic);
      if (lesson != null) return lesson;
    }

    if (topic.level == 'B1') {
      final lesson = b1LessonForTopic(topic);
      if (lesson != null) return lesson;
    }

    if (topic.level == 'B2') {
      final lesson = b2LessonForTopic(topic);
      if (lesson != null) return lesson;
    }

    if (topic.level == 'C1') {
      final lesson = c1LessonForTopic(topic);
      if (lesson != null) return lesson;
    }

    if (topic.level == 'C2') {
      final lesson = c2LessonForTopic(topic);
      if (lesson != null) return lesson;
    }

    return GrammarLesson(
      bigTitle: topic.title,
      oneLineGoal: topic.subtitle,
      timeLabel: '6 dk',
      teacherIntro: topic.rule,
      formulaRows: [
        GrammarFormulaRow(
            label: 'Step 1', pattern: 'Meaning', sample: topic.rule),
        GrammarFormulaRow(
            label: 'Step 2', pattern: 'Model', sample: topic.example),
        GrammarFormulaRow(
            label: 'Step 3', pattern: 'Avoid', sample: topic.trap),
      ],
      usageBullets: const [
        'Model cümleyi dikkatlice oku.',
        'Fiil formuna ve kelime sırasına dikkat et.',
        'Aynı yapıyla kendi cümleni kur.',
      ],
      examples: [topic.example],
      wrong: topic.trap,
      right: topic.example,
      reason: 'Model cümleyle karşılaştır ve kelime sırasını kontrol et.',
      task: 'Bu grammar konusu ile bir cümle yaz.',
      modelAnswer: topic.example,
      quiz: [
        GrammarQuizQuestion(
          id: '${topic.id}_mcq_1',
          type: GrammarQuizType.multipleChoice,
          prompt: 'Choose the correct sentence.',
          options: [
            topic.example,
            topic.trap,
            'Check the model sentence again.',
            'Not enough information.',
          ],
          answer: topic.example,
          explanation: 'The correct option follows the target grammar pattern.',
        ),
      ],
    );
  }
}
