import 'learning_models.dart';

final Map<String, LessonContent> writingLessons = {
  'personal profile writing': const LessonContent(
    id: 'personal profile writing',
    title: 'A1 Writing: Personal Profile',
    level: 'A1',
    explanation:
        'Write a short personal profile about your name, age, city, school/job, family and hobbies.',
    structures: [
      'My name is...',
      'I am ... years old.',
      'I live in...',
      'I am a student / teacher.',
      'I have got...',
      'I like...',
    ],
    examples: [
      'My name is Elif.',
      'I am 13 years old.',
      'I live in Kayseri.',
      'I am a student.',
      'I have got one brother.',
      'I like music and volleyball.',
      'In my free time, I watch films.',
    ],
    commonMistakes: [
      'I have 13 years old -> I am 13 years old',
      'I live at Kayseri -> I live in Kayseri',
      'I am student -> I am a student',
      'My name Elif -> My name is Elif',
    ],
    quiz: [
      QuizQuestion(
        question: 'Which sentence is correct for age?',
        options: [
          'I have 13 years old.',
          'I am 13 years old.',
          'I am 13 years.',
          'I years old 13.'
        ],
        correctIndex: 1,
        explanation: 'Use “I am ... years old.”',
      ),
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'I live in Kayseri.',
          'I live at Kayseri.',
          'I live on Kayseri.',
          'I live to Kayseri.'
        ],
        correctIndex: 0,
        explanation: 'Use “in” with cities.',
      ),
      QuizQuestion(
        question: 'Which sentence needs “a”?',
        options: [
          'I am student.',
          'I am a student.',
          'I am students.',
          'I student.'
        ],
        correctIndex: 1,
        explanation: 'Use “a” before singular jobs/roles.',
      ),
      QuizQuestion(
        question: 'Best sentence for hobby:',
        options: [
          'I like music.',
          'I music like.',
          'I am music.',
          'I do music like.'
        ],
        correctIndex: 0,
        explanation: 'Use “I like + noun/activity.”',
      ),
    ],
    speakingPrompts: [
      'Read your profile aloud.',
      'Tell your partner 3 facts about yourself.',
    ],
    writingPrompts: [
      'Write a 6-sentence personal profile.',
      'Write your name, age, city, school/job, family and hobby.',
      'Improve your profile by adding one free-time activity.',
    ],
  ),
  'simple email writing': const LessonContent(
    id: 'simple email writing',
    title: 'A1 Writing: Simple Email',
    level: 'A1',
    explanation:
        'Write a simple email to a friend using greeting, short information, question and closing phrase.',
    structures: [
      'Hi / Hello...',
      'How are you?',
      'I am fine.',
      'I am writing about...',
      'What about you?',
      'See you soon.',
    ],
    examples: [
      'Hi Tom,',
      'How are you?',
      'I am fine.',
      'My school is big and modern.',
      'My favorite lesson is English.',
      'What about you?',
      'See you soon,',
      'Mert',
    ],
    commonMistakes: [
      'Hi Tom. is okay, but use comma in email: Hi Tom,',
      'I fine -> I am fine',
      'What about you? is natural',
      'See you soon is a closing phrase',
    ],
    quiz: [
      QuizQuestion(
        question: 'Which is a greeting?',
        options: ['Hi Tom,', 'See you soon,', 'Mert', 'What about you?'],
        correctIndex: 0,
        explanation: '“Hi Tom,” is a greeting.',
      ),
      QuizQuestion(
        question: 'Which is a closing phrase?',
        options: [
          'How are you?',
          'See you soon,',
          'I am fine.',
          'My school is big.'
        ],
        correctIndex: 1,
        explanation: '“See you soon,” closes an email.',
      ),
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: ['I fine.', 'I am fine.', 'I be fine.', 'I fine am.'],
        correctIndex: 1,
        explanation: 'Use “I am fine.”',
      ),
      QuizQuestion(
        question: 'Which asks the friend back?',
        options: [
          'What about you?',
          'I am Mert.',
          'My school is big.',
          'See you.'
        ],
        correctIndex: 0,
        explanation: '“What about you?” asks the other person.',
      ),
    ],
    speakingPrompts: [
      'Read your email aloud.',
      'Ask your friend about school.',
    ],
    writingPrompts: [
      'Write a simple email to a friend about your school.',
      'Use: greeting + 4 sentences + closing.',
      'Ask one question in your email.',
    ],
  ),
  'daily routine paragraph writing': const LessonContent(
    id: 'daily routine paragraph writing',
    title: 'A1 Writing: Daily Routine Paragraph',
    level: 'A1',
    explanation:
        'Write a short paragraph about your daily routine using routine verbs and time expressions.',
    structures: [
      'I wake up at...',
      'First, I...',
      'Then, I...',
      'After school/work, I...',
      'In the evening, I...',
      'I go to bed at...',
    ],
    examples: [
      'I wake up at 7 o’clock.',
      'First, I brush my teeth.',
      'Then, I have breakfast.',
      'I go to school at 8.',
      'After school, I do my homework.',
      'In the evening, I watch TV.',
      'I go to bed at 11.',
    ],
    commonMistakes: [
      'I wake at 7 -> I wake up at 7',
      'I go school -> I go to school',
      'I make homework -> I do homework',
      'I go bed -> I go to bed',
    ],
    quiz: [
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'I go school.',
          'I go to school.',
          'I go at school.',
          'I go school to.'
        ],
        correctIndex: 1,
        explanation: 'Correct phrase: go to school.',
      ),
      QuizQuestion(
        question: 'Which phrase is correct?',
        options: [
          'make homework',
          'do homework',
          'go homework',
          'take homework'
        ],
        correctIndex: 1,
        explanation: 'Correct collocation: do homework.',
      ),
      QuizQuestion(
        question: 'Which word organizes routine?',
        options: ['First', 'Blue', 'Doctor', 'Coffee'],
        correctIndex: 0,
        explanation: '“First” shows order.',
      ),
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'I go bed at 11.',
          'I go to bed at 11.',
          'I go in bed at 11.',
          'I bed go at 11.'
        ],
        correctIndex: 1,
        explanation: 'Correct phrase: go to bed.',
      ),
    ],
    speakingPrompts: [
      'Say your routine before writing.',
      'Tell your partner your morning routine.',
    ],
    writingPrompts: [
      'Write your daily routine in 8 sentences.',
      'Use First / Then / In the evening.',
      'Write your weekend routine.',
    ],
  ),
  'family paragraph writing': const LessonContent(
    id: 'family paragraph writing',
    title: 'A1 Writing: Family Paragraph',
    level: 'A1',
    explanation:
        'Write a short paragraph about your family using family vocabulary, jobs and simple descriptions.',
    structures: [
      'There are ... people in my family.',
      'I have got...',
      'My mother/father is...',
      'My brother/sister is...',
      'We live in...',
      'We usually...',
    ],
    examples: [
      'There are four people in my family.',
      'I have got one sister.',
      'My mother is a teacher.',
      'My father is a doctor.',
      'My sister is 10 years old.',
      'We live in Kayseri.',
      'At the weekend, we visit my grandparents.',
    ],
    commonMistakes: [
      'My family are small -> My family is small',
      'I have sister -> I have a sister',
      'My father doctor -> My father is a doctor',
      'She is 10 years -> She is 10 years old',
    ],
    quiz: [
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'I have sister.',
          'I have a sister.',
          'I am sister.',
          'I has sister.'
        ],
        correctIndex: 1,
        explanation: 'Use “a” before singular countable nouns.',
      ),
      QuizQuestion(
        question: 'Choose the correct job sentence.',
        options: [
          'My father doctor.',
          'My father is a doctor.',
          'My father are doctor.',
          'My father a doctor.'
        ],
        correctIndex: 1,
        explanation: 'Use “is a” before a job.',
      ),
      QuizQuestion(
        question: 'Which sentence describes family size?',
        options: [
          'There are four people in my family.',
          'My family four.',
          'I family four.',
          'Four people family.'
        ],
        correctIndex: 0,
        explanation: 'Use “There are...”',
      ),
      QuizQuestion(
        question: 'Which sentence is correct for age?',
        options: [
          'She is 10 years old.',
          'She has 10 years old.',
          'She 10 years old.',
          'She is 10 years.'
        ],
        correctIndex: 0,
        explanation: 'Use “is ... years old.”',
      ),
    ],
    speakingPrompts: [
      'Talk about your family before writing.',
      'Describe one family member.',
    ],
    writingPrompts: [
      'Write 6-8 sentences about your family.',
      'Describe one person in your family.',
      'Write about what your family does at the weekend.',
    ],
  ),
  'cafe dialogue writing': const LessonContent(
    id: 'cafe dialogue writing',
    title: 'A1 Writing: Cafe Dialogue',
    level: 'A1',
    explanation:
        'Write a short cafe dialogue between a waiter and a customer using polite ordering language.',
    structures: [
      'Waiter: What would you like?',
      'Customer: I would like...',
      'Waiter: Anything else?',
      'Customer: Can I have...?',
      'Customer: How much is it?',
      'Waiter: Here you are.',
    ],
    examples: [
      'Waiter: Hello. What would you like?',
      'Customer: I would like a coffee, please.',
      'Waiter: Anything else?',
      'Customer: Yes, a sandwich, please.',
      'Waiter: That is 90 lira.',
      'Customer: Here you are.',
      'Waiter: Thank you. Enjoy!',
    ],
    commonMistakes: [
      'Give me coffee -> Can I have a coffee, please?',
      'I want sandwich -> I would like a sandwich',
      'How many is it? -> How much is it?',
      'Coffee please is okay, but “I would like...” is more polite.',
    ],
    quiz: [
      QuizQuestion(
        question: 'Which is polite?',
        options: [
          'Give me coffee.',
          'Coffee now.',
          'Can I have a coffee, please?',
          'I coffee.'
        ],
        correctIndex: 2,
        explanation: 'Use “Can I have..., please?”',
      ),
      QuizQuestion(
        question: 'What do you ask for price?',
        options: [
          'How much is it?',
          'How many is it?',
          'How old is it?',
          'How are it?'
        ],
        correctIndex: 0,
        explanation: 'Use “How much is it?”',
      ),
      QuizQuestion(
        question: 'Who says “Anything else?”',
        options: [
          'usually the waiter',
          'usually the student',
          'usually the doctor',
          'usually the driver'
        ],
        correctIndex: 0,
        explanation: 'A waiter can ask “Anything else?”',
      ),
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'I would like a sandwich.',
          'I would sandwich.',
          'I sandwich would like.',
          'I would like sandwich a.'
        ],
        correctIndex: 0,
        explanation: 'Correct structure: I would like + noun.',
      ),
    ],
    speakingPrompts: [
      'Act out your dialogue.',
      'Read the waiter lines and customer lines.',
    ],
    writingPrompts: [
      'Write a 6-line cafe dialogue.',
      'Use “Can I have...?” and “How much is it?”',
      'Write a polite order for food and drink.',
    ],
  ),
  'school description writing': const LessonContent(
    id: 'school description writing',
    title: 'A1 Writing: School Description',
    level: 'A1',
    explanation:
        'Write a short description of your school, favorite subject, teacher and after-school activities.',
    structures: [
      'My school is...',
      'There are...',
      'My favorite subject is...',
      'I like it because...',
      'My teacher is...',
      'After school, I...',
    ],
    examples: [
      'My school is big and clean.',
      'There are many students.',
      'My favorite subject is English.',
      'I like English because I like speaking.',
      'My teacher is kind and helpful.',
      'After school, I play football.',
      'I have many friends at school.',
    ],
    commonMistakes: [
      'My school big -> My school is big',
      'There is many students -> There are many students',
      'I like speak -> I like speaking',
      'My teacher kind -> My teacher is kind',
    ],
    quiz: [
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'My school big.',
          'My school is big.',
          'My school are big.',
          'My school be big.'
        ],
        correctIndex: 1,
        explanation: 'Use “is” to describe singular nouns.',
      ),
      QuizQuestion(
        question: 'Which sentence is correct?',
        options: [
          'There is many students.',
          'There are many students.',
          'There many students.',
          'There are much students.'
        ],
        correctIndex: 1,
        explanation: 'Use “There are” with plural nouns.',
      ),
      QuizQuestion(
        question: 'Choose the correct sentence.',
        options: [
          'I like speaking.',
          'I like speak.',
          'I like speaks.',
          'I like to speaking.'
        ],
        correctIndex: 0,
        explanation: 'After “like”, gerund is common: like speaking.',
      ),
      QuizQuestion(
        question: 'Which sentence describes a teacher?',
        options: [
          'My teacher is kind.',
          'My teacher kind.',
          'My teacher are kind.',
          'My teacher do kind.'
        ],
        correctIndex: 0,
        explanation: 'Use “is” before an adjective.',
      ),
    ],
    speakingPrompts: [
      'Talk about your school.',
      'Describe your teacher.',
      'Say your favorite subject.',
    ],
    writingPrompts: [
      'Write 6-8 sentences about your school.',
      'Write about your favorite subject.',
      'Describe your teacher and classmates.',
    ],
  ),
};
