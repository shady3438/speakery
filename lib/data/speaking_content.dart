import 'learning_models.dart';

final Map<String, LessonContent> speakingLessons = {
  'introducing yourself': const LessonContent(
    id: 'introducing yourself',
    title: 'Speaking: Introducing Yourself',
    level: 'A1',
    explanation:
        'Introducing yourself is one of the most important A1 speaking skills. You can say your name, age, city, school/work and hobbies.',
    structures: [
      'My name is...',
      'I am ... years old.',
      'I am from...',
      'I live in...',
      'I like...',
      'Nice to meet you.',
    ],
    examples: [
      'My name is Elif.',
      'I am 14 years old.',
      'I am from Turkey.',
      'I live in Kayseri.',
      'I am a student.',
      'I like music and volleyball.',
      'Nice to meet you.',
    ],
    commonMistakes: [
      'I am live in Kayseri -> I live in Kayseri',
      'My name Elif -> My name is Elif',
      'I have 14 years old -> I am 14 years old',
    ],
    quiz: [
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'My name Ali.',
          'My name is Ali.',
          'My name are Ali.',
          'I name Ali.'
        ],
        correctIndex: 1,
        explanation: 'Correct structure: My name is...',
      ),
      QuizQuestion(
        question: 'I ___ 15 years old.',
        options: ['have', 'am', 'is', 'are'],
        correctIndex: 1,
        explanation: 'Age uses be: I am 15 years old.',
      ),
      QuizQuestion(
        question: 'Nice to ___ you.',
        options: ['meet', 'make', 'do', 'go'],
        correctIndex: 0,
        explanation: 'Correct phrase: Nice to meet you.',
      ),
    ],
    speakingPrompts: [
      'Introduce yourself in 30 seconds.',
      'Tell your name, age, city and hobbies.',
      'Ask your partner: What is your name? Where are you from?',
    ],
    writingPrompts: [
      'Write your self-introduction.',
      'Write 6 sentences about yourself.',
    ],
  ),
};
