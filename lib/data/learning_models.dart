class LessonContent {
  final String id;
  final String title;
  final String level;
  final String explanation;
  final List<String> structures;
  final List<String> examples;
  final List<String> commonMistakes;
  final List<QuizQuestion> quiz;
  final List<String> speakingPrompts;
  final List<String> writingPrompts;

  const LessonContent({
    required this.id,
    required this.title,
    required this.level,
    required this.explanation,
    required this.structures,
    required this.examples,
    required this.commonMistakes,
    required this.quiz,
    required this.speakingPrompts,
    required this.writingPrompts,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
