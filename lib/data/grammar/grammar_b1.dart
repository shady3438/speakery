import 'package:flutter/material.dart';

import 'package:speakery/data/grammar/grammar_models.dart';

// PHASE217_B1_EXAMPLE_POLISH
// Speakery B1 grammar baseline: mixed quizzes, clean examples,
// generator-friendly model/avoid pairs, and audit-ready topic coverage.

const List<GrammarTopic> grammarB1Topics = [
  GrammarTopic(
    id: 'b1_1',
    level: 'B1',
    title: 'Present Perfect',
    subtitle: 'life experience and recent results',
    icon: Icons.done_all_rounded,
    rule:
        'Use Present Perfect to connect past experiences or recent results to now.',
    example: 'I have visited Istanbul twice.',
    trap: 'I visited Istanbul twice in my life.',
  ),
  GrammarTopic(
    id: 'b1_2',
    level: 'B1',
    title: 'Present Perfect Continuous',
    subtitle: 'actions continuing until now',
    icon: Icons.av_timer_rounded,
    rule:
        'Use Present Perfect Continuous for actions that started in the past and continue now.',
    example: 'She has been studying for two hours.',
    trap: 'She has studying for two hours.',
  ),
  GrammarTopic(
    id: 'b1_3',
    level: 'B1',
    title: 'Present Perfect vs Past Simple',
    subtitle: 'experience or finished time',
    icon: Icons.compare_arrows_rounded,
    rule:
        'Use Present Perfect for experience without exact time and Past Simple for finished time.',
    example: 'I have met her before.',
    trap: 'I have met her yesterday.',
  ),
  GrammarTopic(
    id: 'b1_4',
    level: 'B1',
    title: 'Past Perfect',
    subtitle: 'earlier past action',
    icon: Icons.undo_rounded,
    rule:
        'Use Past Perfect for an action that happened before another past action.',
    example: 'When I arrived, the film had started.',
    trap: 'When I arrived, the film started already.',
  ),
  GrammarTopic(
    id: 'b1_5',
    level: 'B1',
    title: 'Past Perfect Continuous',
    subtitle: 'earlier continuing past action',
    icon: Icons.hourglass_bottom_rounded,
    rule:
        'Use Past Perfect Continuous for an action that was continuing before another past moment.',
    example: 'She had been waiting for an hour when the bus came.',
    trap: 'She had waiting for an hour when the bus came.',
  ),
  GrammarTopic(
    id: 'b1_6',
    level: 'B1',
    title: 'Future Continuous',
    subtitle: 'action in progress in the future',
    icon: Icons.update_rounded,
    rule:
        'Use Future Continuous for an action that will be in progress at a future time.',
    example: 'At nine, I will be studying.',
    trap: 'At nine, I will studying.',
  ),
  GrammarTopic(
    id: 'b1_7',
    level: 'B1',
    title: 'Future Perfect Intro',
    subtitle: 'completed before a future time',
    icon: Icons.flag_rounded,
    rule:
        'Use Future Perfect for an action completed before a future deadline.',
    example: 'By Friday, I will have finished the report.',
    trap: 'By Friday, I will finished the report.',
  ),
  GrammarTopic(
    id: 'b1_8',
    level: 'B1',
    title: 'First Conditional',
    subtitle: 'real future result',
    icon: Icons.call_split_rounded,
    rule: 'Use the First Conditional for real possible future situations.',
    example: 'If it rains, we will stay home.',
    trap: 'If it will rain, we will stay home.',
  ),
  GrammarTopic(
    id: 'b1_9',
    level: 'B1',
    title: 'Second Conditional',
    subtitle: 'imaginary present or future',
    icon: Icons.psychology_rounded,
    rule: 'Use the Second Conditional for imaginary or unlikely situations.',
    example: 'If I had more time, I would learn French.',
    trap: 'If I would have more time, I would learn French.',
  ),
  GrammarTopic(
    id: 'b1_10',
    level: 'B1',
    title: 'Passive Voice',
    subtitle: 'focus on the action',
    icon: Icons.swap_horiz_rounded,
    rule:
        'Use Passive Voice when the action or result is more important than the doer.',
    example: 'The room was cleaned yesterday.',
    trap: 'The room cleaned yesterday.',
  ),
  GrammarTopic(
    id: 'b1_11',
    level: 'B1',
    title: 'Passive Voice by Tense',
    subtitle: 'passive forms in different tenses',
    icon: Icons.layers_rounded,
    rule: 'Use the correct form of be with V3 to change passive tense.',
    example: 'The emails are sent every morning.',
    trap: 'The emails sent every morning.',
  ),
  GrammarTopic(
    id: 'b1_12',
    level: 'B1',
    title: 'Modal Verbs',
    subtitle: 'ability, advice and obligation',
    icon: Icons.tune_rounded,
    rule:
        'Use modal verbs before V1 to express ability, advice, obligation or possibility.',
    example: 'You should call your doctor.',
    trap: 'You should to call your doctor.',
  ),
  GrammarTopic(
    id: 'b1_13',
    level: 'B1',
    title: 'Modals of Advice, Obligation and Possibility',
    subtitle: 'should, must, might',
    icon: Icons.rule_folder_rounded,
    rule:
        'Use should for advice, must for obligation and might for possibility.',
    example: 'You must show your ID at the entrance.',
    trap: 'You must to show your ID at the entrance.',
  ),
  GrammarTopic(
    id: 'b1_14',
    level: 'B1',
    title: 'Reported Speech Intro',
    subtitle: 'reporting statements',
    icon: Icons.record_voice_over_rounded,
    rule: 'Use reported speech to tell someone what another person said.',
    example: 'She said that she was tired.',
    trap: 'She said that she is tired yesterday.',
  ),
  GrammarTopic(
    id: 'b1_15',
    level: 'B1',
    title: 'Reported Questions',
    subtitle: 'indirect question order',
    icon: Icons.question_answer_rounded,
    rule: 'Use reported questions with statement word order.',
    example: 'He asked where I lived.',
    trap: 'He asked where did I live.',
  ),
  GrammarTopic(
    id: 'b1_16',
    level: 'B1',
    title: 'Reported Commands',
    subtitle: 'tell or ask someone to do something',
    icon: Icons.campaign_rounded,
    rule: 'Use told or asked plus object plus to V1 for reported commands.',
    example: 'The teacher told us to be quiet.',
    trap: 'The teacher told us be quiet.',
  ),
  GrammarTopic(
    id: 'b1_17',
    level: 'B1',
    title: 'Relative Clauses',
    subtitle: 'add information about nouns',
    icon: Icons.link_rounded,
    rule:
        'Use relative clauses to give more information about a person, thing or place.',
    example: 'The woman who lives next door is a doctor.',
    trap: 'The woman which lives next door is a doctor.',
  ),
  GrammarTopic(
    id: 'b1_18',
    level: 'B1',
    title: 'Defining Relative Clauses',
    subtitle: 'essential information',
    icon: Icons.join_inner_rounded,
    rule:
        'Use defining relative clauses when the information is necessary to identify the noun.',
    example: 'The book that you gave me was useful.',
    trap: 'The book what you gave me was useful.',
  ),
  GrammarTopic(
    id: 'b1_19',
    level: 'B1',
    title: 'Non-defining Relative Clauses Intro',
    subtitle: 'extra information with commas',
    icon: Icons.integration_instructions_rounded,
    rule:
        'Use non-defining relative clauses to add extra information with commas.',
    example: 'My brother, who lives in Izmir, is a dentist.',
    trap: 'My brother who lives in Izmir is a dentist.',
  ),
  GrammarTopic(
    id: 'b1_20',
    level: 'B1',
    title: 'Gerund vs Infinitive',
    subtitle: 'V-ing or to V1 after verbs',
    icon: Icons.account_tree_rounded,
    rule: 'Use gerunds and infinitives after different verbs and expressions.',
    example: 'I enjoy learning new words.',
    trap: 'I enjoy to learn new words.',
  ),
  GrammarTopic(
    id: 'b1_21',
    level: 'B1',
    title: 'used to / be used to / get used to',
    subtitle: 'past habits and familiarity',
    icon: Icons.change_circle_rounded,
    rule:
        'Use used to for past habits, be used to for familiarity and get used to for becoming familiar.',
    example: 'I used to wake up late.',
    trap: 'I am used to wake up late.',
  ),
  GrammarTopic(
    id: 'b1_22',
    level: 'B1',
    title: 'Question Tags and Indirect Questions',
    subtitle: 'checking and polite questions',
    icon: Icons.help_outline_rounded,
    rule:
        'Use question tags to check information and indirect questions for polite questions.',
    example: "You are coming, aren't you?",
    trap: 'You are coming, are you?',
  ),
];

class _B1LessonSpec {
  final String id;
  final String bigTitle;
  final String goal;
  final String intro;
  final String pattern1;
  final String sample1;
  final String pattern2;
  final String sample2;
  final String pattern3;
  final String sample3;
  final List<String> examples;
  final String wrong;
  final String right;
  final String reason;
  final String blankSentence;
  final String blankAnswer;
  final List<String> orderItems;
  final Map<String, String> pairs;

  const _B1LessonSpec({
    required this.id,
    required this.bigTitle,
    required this.goal,
    required this.intro,
    required this.pattern1,
    required this.sample1,
    required this.pattern2,
    required this.sample2,
    required this.pattern3,
    required this.sample3,
    required this.examples,
    required this.wrong,
    required this.right,
    required this.reason,
    required this.blankSentence,
    required this.blankAnswer,
    required this.orderItems,
    required this.pairs,
  });
}

const List<_B1LessonSpec> _b1Specs = [
  _B1LessonSpec(
    id: 'b1_1',
    bigTitle: 'Present Perfect',
    goal:
        'Life experience and recent results yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Present Perfect konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I have visited Istanbul twice.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I visited Istanbul twice in my life.',
    pattern3: 'Kullanım odağı',
    sample3:
        'Use have or has plus V3 when the exact past time is not the focus.',
    examples: [
      'I have visited Istanbul twice.',
      'We have visited Istanbul twice.',
      'I have visited Ankara twice.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'I visited Istanbul twice in my life.',
    right: 'I have visited Istanbul twice.',
    reason:
        'Use have or has plus V3 when the exact past time is not the focus.',
    blankSentence: 'I have _____ this film before.',
    blankAnswer: 'seen',
    orderItems: ['I', 'have', 'seen', 'this', 'film', 'before.'],
    pairs: {
      'have seen': 'experience before now',
      'has finished': 'recent result',
      'for two years': 'duration until now'
    },
  ),
  _B1LessonSpec(
    id: 'b1_2',
    bigTitle: 'Present Perfect Continuous',
    goal:
        'Actions continuing until now yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Present Perfect Continuous konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'She has been studying for two hours.',
    pattern2: 'Sık yapılan hata',
    sample2: 'She has studying for two hours.',
    pattern3: 'Kullanım odağı',
    sample3:
        'Use has or have been plus V-ing for an action continuing until now.',
    examples: [
      'She has been studying for two hours.',
      'They have been studying for two hours.',
      'She has been studying for three hours.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'She has studying for two hours.',
    right: 'She has been studying for two hours.',
    reason:
        'Use has or have been plus V-ing for an action continuing until now.',
    blankSentence: 'She has been _____ for two hours.',
    blankAnswer: 'studying',
    orderItems: ['She', 'has', 'been', 'studying', 'for', 'two', 'hours.'],
    pairs: {
      'has been studying': 'continuing action',
      'since morning': 'starting point',
      'for two hours': 'duration'
    },
  ),
  _B1LessonSpec(
    id: 'b1_3',
    bigTitle: 'Present Perfect vs Past Simple',
    goal:
        'Experience or finished time yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Present Perfect vs Past Simple konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I met her yesterday.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I have met her yesterday.',
    pattern3: 'Kullanım odağı',
    sample3:
        'Use Past Simple with finished time expressions like yesterday or last year.',
    examples: [
      'I met her yesterday.',
      'We met her yesterday.',
      'I met her last week.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'I have met her yesterday.',
    right: 'I met her yesterday.',
    reason:
        'Use Past Simple with finished time expressions like yesterday or last year.',
    blankSentence: 'I _____ her yesterday.',
    blankAnswer: 'met',
    orderItems: ['I', 'met', 'her', 'yesterday.'],
    pairs: {
      'have met': 'experience',
      'met yesterday': 'finished time',
      'before': 'no exact time'
    },
  ),
  _B1LessonSpec(
    id: 'b1_4',
    bigTitle: 'Past Perfect',
    goal: 'Earlier past action yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Past Perfect konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'When I arrived, the film had started.',
    pattern2: 'Sık yapılan hata',
    sample2: 'When I arrived, the film started already.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use had plus V3 for the earlier past action.',
    examples: [
      'When I arrived, the film had started.',
      'When We arrived, the film had started.',
      'When I arrived, the meeting had started.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'When I arrived, the film started already.',
    right: 'When I arrived, the film had started.',
    reason: 'Use had plus V3 for the earlier past action.',
    blankSentence: 'The film had _____ before I arrived.',
    blankAnswer: 'started',
    orderItems: ['The', 'film', 'had', 'started', 'before', 'I', 'arrived.'],
    pairs: {
      'had started': 'earlier past',
      'arrived': 'later past',
      'before': 'time link'
    },
  ),
  _B1LessonSpec(
    id: 'b1_5',
    bigTitle: 'Past Perfect Continuous',
    goal:
        'Earlier continuing past action yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Past Perfect Continuous konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'She had been waiting for an hour when the bus came.',
    pattern2: 'Sık yapılan hata',
    sample2: 'She had waiting for an hour when the bus came.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use had been plus V-ing to show duration before a past event.',
    examples: [
      'She had been waiting for an hour when the bus came.',
      'They had been waiting for an hour when the bus came.',
      'She had been waiting for an hour when the train came.',
      'She had been waiting for two hours when the bus came.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
    ],
    wrong: 'She had waiting for an hour when the bus came.',
    right: 'She had been waiting for an hour when the bus came.',
    reason: 'Use had been plus V-ing to show duration before a past event.',
    blankSentence: 'She had been _____ for an hour.',
    blankAnswer: 'waiting',
    orderItems: ['She', 'had', 'been', 'waiting', 'for', 'an', 'hour.'],
    pairs: {
      'had been waiting': 'earlier duration',
      'when': 'past event link',
      'for an hour': 'duration'
    },
  ),
  _B1LessonSpec(
    id: 'b1_6',
    bigTitle: 'Future Continuous',
    goal:
        'Action in progress in the future yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Future Continuous konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'At nine, I will be studying.',
    pattern2: 'Sık yapılan hata',
    sample2: 'At nine, I will studying.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use will be plus V-ing for a future action in progress.',
    examples: [
      'At nine, I will be studying.',
      'At nine, We will be studying.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'At nine, I will studying.',
    right: 'At nine, I will be studying.',
    reason: 'Use will be plus V-ing for a future action in progress.',
    blankSentence: 'At nine, I will be _____.',
    blankAnswer: 'studying',
    orderItems: ['At', 'nine,', 'I', 'will', 'be', 'studying.'],
    pairs: {
      'will be studying': 'future progress',
      'at nine': 'future time',
      'will be working': 'planned progress'
    },
  ),
  _B1LessonSpec(
    id: 'b1_7',
    bigTitle: 'Future Perfect Intro',
    goal:
        'Completed before a future time yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Future Perfect Intro konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'By Friday, I will have finished the report.',
    pattern2: 'Sık yapılan hata',
    sample2: 'By Friday, I will finished the report.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use will have plus V3 for completion before a future time.',
    examples: [
      'By Friday, I will have finished the report.',
      'By Friday, We will have finished the report.',
      'By Monday, I will have finished the project.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'By Friday, I will finished the report.',
    right: 'By Friday, I will have finished the report.',
    reason: 'Use will have plus V3 for completion before a future time.',
    blankSentence: 'By Friday, I will have _____ the report.',
    blankAnswer: 'finished',
    orderItems: [
      'By',
      'Friday,',
      'I',
      'will',
      'have',
      'finished',
      'the',
      'report.'
    ],
    pairs: {
      'will have finished': 'future completion',
      'by Friday': 'deadline',
      'will have done': 'completed by then'
    },
  ),
  _B1LessonSpec(
    id: 'b1_8',
    bigTitle: 'First Conditional',
    goal: 'Real future result yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'First Conditional konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'If it rains, we will stay home.',
    pattern2: 'Sık yapılan hata',
    sample2: 'If it will rain, we will stay home.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use Present Simple after if and will in the result clause.',
    examples: [
      'If it rains, we will stay home.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'If it will rain, we will stay home.',
    right: 'If it rains, we will stay home.',
    reason: 'Use Present Simple after if and will in the result clause.',
    blankSentence: 'If it _____, we will stay home.',
    blankAnswer: 'rains',
    orderItems: ['If', 'it', 'rains,', 'we', 'will', 'stay', 'home.'],
    pairs: {
      'if it rains': 'condition',
      'we will stay': 'result',
      'present simple after if': 'real future'
    },
  ),
  _B1LessonSpec(
    id: 'b1_9',
    bigTitle: 'Second Conditional',
    goal:
        'Imaginary present or future yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Second Conditional konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'If I had more time, I would learn French.',
    pattern2: 'Sık yapılan hata',
    sample2: 'If I would have more time, I would learn French.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use Past Simple after if and would plus V1 in the result.',
    examples: [
      'If I had more time, I would learn French.',
      'If We had more time, We would learn French.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'If I would have more time, I would learn French.',
    right: 'If I had more time, I would learn French.',
    reason: 'Use Past Simple after if and would plus V1 in the result.',
    blankSentence: 'If I _____ more time, I would travel.',
    blankAnswer: 'had',
    orderItems: ['If', 'I', 'had', 'more', 'time,', 'I', 'would', 'travel.'],
    pairs: {
      'if I had': 'imaginary condition',
      'would travel': 'imaginary result',
      'past form': 'unreal meaning'
    },
  ),
  _B1LessonSpec(
    id: 'b1_10',
    bigTitle: 'Passive Voice',
    goal: 'Focus on the action yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Passive Voice konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The room was cleaned yesterday.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The room cleaned yesterday.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use be plus V3 to make a passive sentence.',
    examples: [
      'The room was cleaned yesterday.',
      'The room were cleaned yesterday.',
      'The classroom was cleaned last week.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'The room cleaned yesterday.',
    right: 'The room was cleaned yesterday.',
    reason: 'Use be plus V3 to make a passive sentence.',
    blankSentence: 'The room was _____ yesterday.',
    blankAnswer: 'cleaned',
    orderItems: ['The', 'room', 'was', 'cleaned', 'yesterday.'],
    pairs: {
      'was cleaned': 'past passive',
      'is made': 'present passive',
      'be + V3': 'passive form'
    },
  ),
  _B1LessonSpec(
    id: 'b1_11',
    bigTitle: 'Passive Voice by Tense',
    goal:
        'Passive forms in different tenses yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Passive Voice by Tense konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The emails are sent every morning.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The emails sent every morning.',
    pattern3: 'Kullanım odağı',
    sample3: 'Change be for the tense, but keep the main verb as V3.',
    examples: [
      'The emails are sent every morning.',
      'The emails are sent every evening.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The emails sent every morning.',
    right: 'The emails are sent every morning.',
    reason: 'Change be for the tense, but keep the main verb as V3.',
    blankSentence: 'The emails are _____ every morning.',
    blankAnswer: 'sent',
    orderItems: ['The', 'emails', 'are', 'sent', 'every', 'morning.'],
    pairs: {
      'are sent': 'present passive',
      'were sent': 'past passive',
      'will be sent': 'future passive'
    },
  ),
  _B1LessonSpec(
    id: 'b1_12',
    bigTitle: 'Modal Verbs',
    goal:
        'Ability, advice and obligation yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Modal Verbs konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'You should call your doctor.',
    pattern2: 'Sık yapılan hata',
    sample2: 'You should to call your doctor.',
    pattern3: 'Kullanım odağı',
    sample3: 'After a modal verb, use the base verb without to.',
    examples: [
      'You should call your doctor.',
      'You should call your teacher.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'You should to call your doctor.',
    right: 'You should call your doctor.',
    reason: 'After a modal verb, use the base verb without to.',
    blankSentence: 'You should _____ your doctor.',
    blankAnswer: 'call',
    orderItems: ['You', 'should', 'call', 'your', 'doctor.'],
    pairs: {
      'should call': 'advice',
      'must wear': 'obligation',
      'might rain': 'possibility'
    },
  ),
  _B1LessonSpec(
    id: 'b1_13',
    bigTitle: 'Modals of Advice, Obligation and Possibility',
    goal: 'Should, must, might yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Modals of Advice, Obligation and Possibility konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'You must show your ID at the entrance.',
    pattern2: 'Sık yapılan hata',
    sample2: 'You must to show your ID at the entrance.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use a modal plus V1 without to.',
    examples: [
      'You must show your ID at the entrance.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'You must to show your ID at the entrance.',
    right: 'You must show your ID at the entrance.',
    reason: 'Use a modal plus V1 without to.',
    blankSentence: 'You must _____ your ID.',
    blankAnswer: 'show',
    orderItems: ['You', 'must', 'show', 'your', 'ID', 'at', 'the', 'entrance.'],
    pairs: {
      'should rest': 'advice',
      'must show': 'obligation',
      'might arrive': 'possibility'
    },
  ),
  _B1LessonSpec(
    id: 'b1_14',
    bigTitle: 'Reported Speech Intro',
    goal: 'Reporting statements yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Reported Speech Intro konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'She said that she was tired.',
    pattern2: 'Sık yapılan hata',
    sample2: 'She said that she is tired yesterday.',
    pattern3: 'Kullanım odağı',
    sample3:
        'When the reporting verb is in the past, the tense usually moves back.',
    examples: [
      'She said that she was tired.',
      'They said that she were tired.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'She said that she is tired yesterday.',
    right: 'She said that she was tired.',
    reason:
        'When the reporting verb is in the past, the tense usually moves back.',
    blankSentence: 'She said that she _____ tired.',
    blankAnswer: 'was',
    orderItems: ['She', 'said', 'that', 'she', 'was', 'tired.'],
    pairs: {
      'said that': 'reported statement',
      'was tired': 'backshift',
      'told me': 'reported speaker'
    },
  ),
  _B1LessonSpec(
    id: 'b1_15',
    bigTitle: 'Reported Questions',
    goal: 'Indirect question order yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Reported Questions konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'He asked where I lived.',
    pattern2: 'Sık yapılan hata',
    sample2: 'He asked where did I live.',
    pattern3: 'Kullanım odağı',
    sample3:
        'In reported questions, do not use question word order after the question word.',
    examples: [
      'He asked where I lived.',
      'He asked where We lived.',
      'They asked where I lived.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'He asked where did I live.',
    right: 'He asked where I lived.',
    reason:
        'In reported questions, do not use question word order after the question word.',
    blankSentence: 'He asked where I _____.',
    blankAnswer: 'lived',
    orderItems: ['He', 'asked', 'where', 'I', 'lived.'],
    pairs: {
      'where I lived': 'reported question',
      'asked if': 'yes/no report',
      'no inversion': 'statement order'
    },
  ),
  _B1LessonSpec(
    id: 'b1_16',
    bigTitle: 'Reported Commands',
    goal:
        'Tell or ask someone to do something yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Reported Commands konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The teacher told us to be quiet.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The teacher told us be quiet.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use told or asked plus object plus to V1.',
    examples: [
      'The teacher told us to be quiet.',
      'The manager told us to be quiet.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The teacher told us be quiet.',
    right: 'The teacher told us to be quiet.',
    reason: 'Use told or asked plus object plus to V1.',
    blankSentence: 'The teacher told us _____ be quiet.',
    blankAnswer: 'to',
    orderItems: ['The', 'teacher', 'told', 'us', 'to', 'be', 'quiet.'],
    pairs: {
      'told us to': 'reported command',
      'asked me to': 'polite command',
      'not to run': 'negative command'
    },
  ),
  _B1LessonSpec(
    id: 'b1_17',
    bigTitle: 'Relative Clauses',
    goal:
        'Add information about nouns yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Relative Clauses konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The woman who lives next door is a doctor.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The woman which lives next door is a doctor.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use who for people and which or that for things.',
    examples: [
      'The woman who lives next door is a doctor.',
      'The woman who lives next door are a doctor.',
      'The woman who lives next door is a teacher.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'The woman which lives next door is a doctor.',
    right: 'The woman who lives next door is a doctor.',
    reason: 'Use who for people and which or that for things.',
    blankSentence: 'The woman _____ lives next door is a doctor.',
    blankAnswer: 'who',
    orderItems: [
      'The',
      'woman',
      'who',
      'lives',
      'next',
      'door',
      'is',
      'a',
      'doctor.'
    ],
    pairs: {'who': 'people', 'which': 'things', 'where': 'places'},
  ),
  _B1LessonSpec(
    id: 'b1_18',
    bigTitle: 'Defining Relative Clauses',
    goal: 'Essential information yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Defining Relative Clauses konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The book that you gave me was useful.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The book what you gave me was useful.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use who, which or that, not what, to define a noun.',
    examples: [
      'The book that you gave me was useful.',
      'The book that you gave us was useful.',
      'The book that you gave me were useful.',
      'The article that you gave me was useful.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
    ],
    wrong: 'The book what you gave me was useful.',
    right: 'The book that you gave me was useful.',
    reason: 'Use who, which or that, not what, to define a noun.',
    blankSentence: 'The book _____ you gave me was useful.',
    blankAnswer: 'that',
    orderItems: ['The', 'book', 'that', 'you', 'gave', 'me', 'was', 'useful.'],
    pairs: {
      'that you gave me': 'essential detail',
      'who called me': 'person detail',
      'which I bought': 'thing detail'
    },
  ),
  _B1LessonSpec(
    id: 'b1_19',
    bigTitle: 'Non-defining Relative Clauses Intro',
    goal:
        'Extra information with commas yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Non-defining Relative Clauses Intro konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'My brother, who lives in Izmir, is a dentist.',
    pattern2: 'Sık yapılan hata',
    sample2: 'My brother who lives in Izmir is a dentist.',
    pattern3: 'Kullanım odağı',
    sample3: 'Use commas for extra non-essential information.',
    examples: [
      'My brother, who lives in Izmir, is a dentist.',
      'My brother, who lives in Izmir, are a dentist.',
      'My brother, who lives in Bursa, is a dentist.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'My brother who lives in Izmir is a dentist.',
    right: 'My brother, who lives in Izmir, is a dentist.',
    reason: 'Use commas for extra non-essential information.',
    blankSentence: 'My brother, _____ lives in Izmir, is a dentist.',
    blankAnswer: 'who',
    orderItems: [
      'My',
      'brother,',
      'who',
      'lives',
      'in',
      'Izmir,',
      'is',
      'a',
      'dentist.'
    ],
    pairs: {
      'who lives in Izmir': 'extra detail',
      'commas': 'non-defining marker',
      'which is old': 'extra thing detail'
    },
  ),
  _B1LessonSpec(
    id: 'b1_20',
    bigTitle: 'Gerund vs Infinitive',
    goal:
        'V-ing or to v1 after verbs yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Gerund vs Infinitive konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I enjoy learning new words.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I enjoy to learn new words.',
    pattern3: 'Kullanım odağı',
    sample3: 'Enjoy takes V-ing, but decide and want take to plus V1.',
    examples: [
      'I enjoy learning new words.',
      'We enjoy learning new words.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'I enjoy to learn new words.',
    right: 'I enjoy learning new words.',
    reason: 'Enjoy takes V-ing, but decide and want take to plus V1.',
    blankSentence: 'I enjoy _____ new words.',
    blankAnswer: 'learning',
    orderItems: ['I', 'enjoy', 'learning', 'new', 'words.'],
    pairs: {
      'enjoy learning': 'gerund',
      'decide to study': 'infinitive',
      'avoid making': 'gerund'
    },
  ),
  _B1LessonSpec(
    id: 'b1_21',
    bigTitle: 'used to / be used to / get used to',
    goal:
        'Past habits and familiarity yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'used to / be used to / get used to konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I used to wake up late.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I am used to wake up late.',
    pattern3: 'Kullanım odağı',
    sample3:
        'Used to is followed by V1 for past habits; be used to is followed by noun or V-ing.',
    examples: [
      'I used to wake up late.',
      'We used to wake up late.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'I am used to wake up late.',
    right: 'I used to wake up late.',
    reason:
        'Used to is followed by V1 for past habits; be used to is followed by noun or V-ing.',
    blankSentence: 'I used to _____ up late.',
    blankAnswer: 'wake',
    orderItems: ['I', 'used', 'to', 'wake', 'up', 'late.'],
    pairs: {
      'used to wake': 'past habit',
      'am used to waking': 'familiarity',
      'get used to waking': 'become familiar'
    },
  ),
  _B1LessonSpec(
    id: 'b1_22',
    bigTitle: 'Question Tags and Indirect Questions',
    goal:
        'Checking and polite questions yapısını doğal ve doğru cümlelerde kullan.',
    intro:
        'Question Tags and Indirect Questions konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: "You are coming, aren't you?",
    pattern2: 'Sık yapılan hata',
    sample2: 'You are coming, are you?',
    pattern3: 'Kullanım odağı',
    sample3: 'Use an opposite auxiliary in the question tag.',
    examples: [
      "You are coming, aren't you?",
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'You are coming, are you?',
    right: "You are coming, aren't you?",
    reason: 'Use an opposite auxiliary in the question tag.',
    blankSentence: 'You are coming, _____ you?',
    blankAnswer: "aren't",
    orderItems: ['You', 'are', 'coming,', "aren't", 'you?'],
    pairs: {
      "aren't you": 'negative tag',
      'do you know where': 'indirect question',
      'could you tell me': 'polite opener'
    },
  ),
];

GrammarLesson? b1LessonForTopic(GrammarTopic topic) {
  final spec = _b1SpecFor(topic.id);
  if (spec == null) return null;
  return GrammarLesson(
    bigTitle: spec.bigTitle,
    oneLineGoal: _b1GoalFor(spec),
    timeLabel: '8 dk',
    teacherIntro: _b1IntroFor(spec),
    formulaRows: _b1FormulaRowsFor(spec),
    usageBullets: [
      'Check the time phrase and the helper verb before you choose the form.',
      'Use the pattern in a clear message, short story or everyday explanation.',
      'Use the target structure in one sentence from your own life.',
      'Watch word order: a small change can change the grammar meaning.',
    ],
    examples: _b1ExamplesFor(spec),
    wrong: spec.wrong,
    right: spec.right,
    reason: spec.reason,
    task:
        'Write five sentences with this topic: two positive, one negative, one question or transformation, and one sentence from your own life.',
    modelAnswer: spec.right,
    quiz: _b1QuizPack(spec),
  );
}

List<GrammarFormulaRow> _b1FormulaRowsFor(_B1LessonSpec spec) {
  final pattern = switch (spec.id) {
    'b1_1' => 'have/has + V3',
    'b1_2' => 'have/has been + V-ing',
    'b1_3' => 'Present Perfect: no exact time / Past Simple: finished time',
    'b1_4' => 'had + V3 before past simple',
    'b1_5' => 'had been + V-ing before a past event',
    'b1_6' => 'will be + V-ing',
    'b1_7' => 'will have + V3 by/before + future time',
    'b1_8' => 'if + present simple, will + V1',
    'b1_9' => 'if + past simple, would + V1',
    'b1_10' => 'be + V3',
    'b1_11' => 'be changes tense + V3',
    'b1_12' => 'modal + V1',
    'b1_13' => 'should/must/might/may/could + V1',
    'b1_14' => 'said/told + clause with backshift',
    'b1_15' => 'question word + subject + verb',
    'b1_16' => 'told/asked + object + to + V1',
    'b1_17' => 'noun + who/which/that/where + clause',
    'b1_18' => 'noun + who/which/that + essential detail',
    'b1_19' => 'noun, who/which + extra detail, main clause',
    'b1_20' => 'verb + V-ing / verb + to + V1',
    'b1_21' => 'used to + V1 / be used to + noun or V-ing',
    'b1_22' => 'statement, opposite auxiliary + subject?',
    _ => spec.pattern1,
  };
  return [
    GrammarFormulaRow(
        label: 'Structure', pattern: pattern, sample: spec.sample1),
    GrammarFormulaRow(
        label: 'Form note', pattern: 'Check', sample: spec.sample2),
    GrammarFormulaRow(
        label: 'Usage focus', pattern: 'Use', sample: spec.sample3),
  ];
}

String _b1GoalFor(_B1LessonSpec spec) {
  return switch (spec.id) {
    'b1_1' =>
      'Use Present Perfect for life experience, recent results and unfinished time connected to now.',
    'b1_2' =>
      'Use Present Perfect Continuous to show an action that started before now and is still important.',
    'b1_3' =>
      'Choose Present Perfect for experience and Past Simple for a finished time.',
    'b1_4' => 'Use Past Perfect to show which past action happened first.',
    'b1_5' =>
      'Use Past Perfect Continuous for duration before another past event.',
    'b1_6' => 'Describe an action that will be in progress at a future time.',
    'b1_7' =>
      'Talk about something that will be completed before a future deadline.',
    'b1_8' => 'Talk about a real future condition and its likely result.',
    'b1_9' =>
      'Talk about imaginary or unlikely situations in the present or future.',
    'b1_10' =>
      'Use the passive when the action or result matters more than the doer.',
    'b1_11' =>
      'Change passive sentences across present, past and future tenses.',
    'b1_12' =>
      'Use modal verbs for advice, obligation, ability and possibility.',
    'b1_13' =>
      'Choose should, must, have to, might, may or could for the intended meaning.',
    'b1_14' => 'Report what someone said with natural tense changes.',
    'b1_15' => 'Report questions with statement word order.',
    'b1_16' => 'Report commands and requests with object + to + verb.',
    'b1_17' =>
      'Use relative clauses to add useful information about people, things and places.',
    'b1_18' =>
      'Use defining relative clauses to identify exactly which person or thing you mean.',
    'b1_19' =>
      'Add extra non-essential information with commas in non-defining relative clauses.',
    'b1_20' => 'Choose gerund or infinitive patterns after common B1 verbs.',
    'b1_21' =>
      'Separate past habits, familiarity and the process of becoming familiar.',
    'b1_22' =>
      'Use question tags to check information and indirect questions to sound polite.',
    _ => 'Use this B1 grammar point accurately in real communication.',
  };
}

String _b1IntroFor(_B1LessonSpec spec) {
  return switch (spec.id) {
    'b1_1' =>
      'Present Perfect connects a past experience or result to the present. Use it when the exact finished time is not the main point.',
    'b1_2' =>
      'Present Perfect Continuous focuses on activity and duration. It often answers how long something has been happening.',
    'b1_3' =>
      'The time phrase decides the tense: use Present Perfect for experience before now, but Past Simple with yesterday, last week or another finished time.',
    'b1_4' =>
      'Past Perfect makes the order of two past actions clear. The earlier action uses had + V3.',
    'b1_5' =>
      'Past Perfect Continuous shows that an activity was already in progress before another past event happened.',
    'b1_6' =>
      'Future Continuous places you inside a future moment. It shows what will be happening then.',
    'b1_7' =>
      'Future Perfect looks forward to a deadline and says the action will be complete before that point.',
    'b1_8' =>
      'First Conditional is for realistic future situations: present simple after if, and will in the result.',
    'b1_9' =>
      'Second Conditional is for imagined situations. Use a past form after if and would + V1 for the result.',
    'b1_10' =>
      'Passive voice moves focus from the doer to the action, result or object. The basic form is be + V3.',
    'b1_11' =>
      'In passive sentences, the main verb stays V3. The form of be changes to show the tense.',
    'b1_12' =>
      'Modal verbs do not take to before the main verb. The modal gives the meaning; the next verb stays V1.',
    'b1_13' =>
      'Modals let you adjust strength: should is advice, must is strong obligation, and might/may/could show possibility.',
    'b1_14' =>
      'Reported speech tells another person what someone said. With a past reporting verb, the reported tense often moves back.',
    'b1_15' =>
      'Reported questions are not direct questions, so the word order becomes subject + verb.',
    'b1_16' =>
      'Reported commands and requests use told/asked + person + to + V1. Negative commands use not to + V1.',
    'b1_17' =>
      'Relative clauses help combine ideas without repeating nouns. Choose who for people and which/that for things.',
    'b1_18' =>
      'Defining relative clauses give necessary information. Without the clause, the listener may not know which noun you mean.',
    'b1_19' =>
      'Non-defining relative clauses add extra information. They use commas and do not identify the noun.',
    'b1_20' =>
      'Gerund and infinitive choices are best learned as verb patterns: enjoy doing, avoid doing, decide to do.',
    'b1_21' =>
      'Used to describes a past habit. Be used to means familiar with something. Get used to means become familiar.',
    'b1_22' =>
      'Question tags check or confirm information. Indirect questions keep statement word order and sound more polite.',
    _ =>
      'Study the model, compare it with the common mistake, and use the structure in your own sentence.',
  };
}

List<String> _b1ExamplesFor(_B1LessonSpec spec) {
  final examples = switch (spec.id) {
    'b1_1' => const [
        'I have visited Istanbul twice.',
        'She has just finished her homework.',
        'We have lived here for three years.',
        'Have you ever tried sushi?',
        'I have lost my keys.',
        'They have not called us yet.',
      ],
    'b1_2' => const [
        'She has been studying for two hours.',
        'I have been working here since June.',
        'They have been waiting outside for twenty minutes.',
        'It has been raining all morning.',
        'We have been learning Spanish this year.',
        'How long have you been living here?',
      ],
    'b1_3' => const [
        'I have lost my keys.',
        'I lost my keys yesterday.',
        'She has visited Rome before.',
        'She visited Rome in 2022.',
        'Have you ever met Deniz?',
        'Did you meet Deniz at the party?',
      ],
    'b1_4' => const [
        'When I arrived, the film had started.',
        'She had left before I called.',
        'They had already eaten, so they were not hungry.',
        'I could not pay because I had forgotten my wallet.',
        'After we had finished dinner, we went for a walk.',
        'He had never flown before that trip.',
      ],
    'b1_5' => const [
        'She had been waiting for an hour when the bus came.',
        'I was tired because I had been working all day.',
        'They had been arguing before the teacher arrived.',
        'He had been running, so he was out of breath.',
        'We had been living there for years before we moved.',
        'It had been snowing, so the roads were dangerous.',
      ],
    'b1_6' => const [
        'At nine, I will be studying.',
        'This time tomorrow, we will be flying to Ankara.',
        'Do not call at six; I will be driving.',
        'She will be working when you arrive.',
        'They will be waiting outside the station.',
        'Will you be using the car tonight?',
      ],
    'b1_7' => const [
        'By Friday, I will have finished the report.',
        'By eight, she will have left the office.',
        'We will have arrived before dinner.',
        'They will have built the bridge by next year.',
        'Will you have completed the form by Monday?',
        'I will not have read the whole book by tomorrow.',
      ],
    'b1_8' => const [
        'If it rains, we will stay at home.',
        'If I finish early, I will call you.',
        'You will miss the train if you leave late.',
        'If she studies, she will pass the exam.',
        'If we do not hurry, we will be late.',
        'What will you do if the shop is closed?',
      ],
    'b1_9' => const [
        'If I had more time, I would learn Italian.',
        'If I were you, I would apologize.',
        'She would travel more if she had enough money.',
        'If we lived near the sea, we would swim every day.',
        'What would you do if you lost your phone?',
        'I would not buy that car if I were you.',
      ],
    'b1_10' => const [
        'The window was broken last night.',
        'This bread is made in a small bakery.',
        'The room was cleaned yesterday.',
        'English is spoken in many countries.',
        'The bike was stolen outside the station.',
        'The problem was solved quickly.',
      ],
    'b1_11' => const [
        'The emails are sent every morning.',
        'The emails were sent yesterday.',
        'The emails will be sent tomorrow.',
        'The documents have been checked.',
        'The office is cleaned every evening.',
        'The road was closed after the accident.',
      ],
    'b1_12' => const [
        'You should call your doctor.',
        'We must wear helmets here.',
        'She can speak three languages.',
        'It might rain later.',
        'Could you help me with this box?',
        'You do not have to come early.',
      ],
    'b1_13' => const [
        'You should drink more water.',
        'You must show your ID at the entrance.',
        'We have to finish this today.',
        'It might snow tonight.',
        'May I leave early?',
        'You could ask your teacher for help.',
      ],
    'b1_14' => const [
        'He said he was tired.',
        'She said that she had lost her phone.',
        'They said they were waiting outside.',
        'Mert told me he could not come.',
        'Ece said she would call later.',
        'He said he lived near the station.',
      ],
    'b1_15' => const [
        'He asked where I lived.',
        'She asked if I was ready.',
        'They asked what time the bus left.',
        'I asked him why he was late.',
        'Can you tell me where the station is?',
        'Do you know whether she is coming?',
      ],
    'b1_16' => const [
        'The teacher told us to be quiet.',
        'She asked me to open the window.',
        'He told them not to run in the hall.',
        'My manager asked me to send the file.',
        'The doctor told him to rest.',
        'I asked Deniz not to be late.',
      ],
    'b1_17' => const [
        'The woman who lives next door is a doctor.',
        'The book that I bought yesterday is excellent.',
        'The cafe where we met is closed now.',
        'I know a student who speaks Japanese.',
        'This is the phone which I found on the bus.',
        'The man who called you is my uncle.',
      ],
    'b1_18' => const [
        'The book that you gave me was useful.',
        'The teacher who helped me was very patient.',
        'The film that we watched last night was funny.',
        'The phone which I bought online arrived today.',
        'I need a bag that fits my laptop.',
        'The person who answered the phone was polite.',
      ],
    'b1_19' => const [
        'My brother, who lives in Izmir, is a dentist.',
        'Ankara, which is the capital of Turkey, is very busy.',
        'My car, which I bought last year, is already old.',
        'Ece, who works with me, speaks German.',
        'The hotel, which opened in May, is near the beach.',
        'My aunt, who is a nurse, works at night.',
      ],
    'b1_20' => const [
        'I enjoy learning new words.',
        'She decided to study medicine.',
        'We avoided driving in the snow.',
        'He hopes to find a better job.',
        'They finished painting the kitchen.',
        'I forgot to lock the door.',
      ],
    'b1_21' => const [
        'I used to walk to school.',
        'She used to play tennis when she was younger.',
        'I am used to waking up early now.',
        'He is not used to the noise.',
        'We are getting used to living in a big city.',
        'Did you use to live near here?',
      ],
    'b1_22' => const [
        "You are coming, aren't you?",
        "She does not drive, does she?",
        "They have finished, haven't they?",
        'Could you tell me where the bank is?',
        'Do you know what time the meeting starts?',
        "It is cold today, isn't it?",
      ],
    _ => spec.examples,
  };
  return examples;
}

_B1LessonSpec? _b1SpecFor(String id) {
  for (final spec in _b1Specs) {
    if (spec.id == id) return spec;
  }
  return null;
}

List<GrammarQuizQuestion> _b1QuizPack(_B1LessonSpec spec) {
  return [
    GrammarQuizQuestion(
      id: '${spec.id}_fill_blank',
      type: GrammarQuizType.fillBlank,
      prompt: 'Complete the sentence.',
      sentence: spec.blankSentence,
      options: _cleanOptions([
        spec.blankAnswer,
        _wrongBlank(spec.blankAnswer),
        _thirdBlankOption(spec.blankAnswer),
        _fourthBlankOption(spec.blankAnswer)
      ]),
      answer: spec.blankAnswer,
      explanation: spec.reason,
    ),
    GrammarQuizQuestion(
      id: '${spec.id}_fill_focus',
      type: GrammarQuizType.fillBlank,
      prompt: 'Choose the missing grammar part.',
      sentence: spec.blankSentence,
      options: _cleanOptions([
        spec.blankAnswer,
        _wrongBlank(spec.blankAnswer),
        _thirdBlankOption(spec.blankAnswer),
        _fourthBlankOption(spec.blankAnswer)
      ]),
      answer: spec.blankAnswer,
      explanation: spec.reason,
    ),
  ];
}

List<String> _cleanOptions(List<String> raw) {
  final result = <String>[];
  for (final item in raw) {
    final clean = item.trim();
    if (clean.isNotEmpty && !result.contains(clean)) {
      result.add(clean);
    }
  }

  const fallbacks = [
    'I use the correct B1 form.',
    'The tense needs a helper verb.',
    'The word order is not natural.',
    'The sentence needs a different structure.',
    'The grammar meaning changes here.',
    'This option does not fit the context.',
  ];
  for (final fallback in fallbacks) {
    if (result.length >= 4) break;
    if (!result.contains(fallback)) result.add(fallback);
  }
  return result.take(4).toList();
}

String _wrongBlank(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'seen') return 'saw';
  if (lower == 'studying') return 'study';
  if (lower == 'met') return 'meet';
  if (lower == 'started') return 'start';
  if (lower == 'waiting') return 'wait';
  if (lower == 'finished') return 'finish';
  if (lower == 'rains') return 'will rain';
  if (lower == 'had') return 'would have';
  if (lower == 'cleaned') return 'clean';
  if (lower == 'sent') return 'send';
  if (lower == 'call') return 'to call';
  if (lower == 'show') return 'to show';
  if (lower == 'was') return 'is';
  if (lower == 'lived') return 'did live';
  if (lower == 'to') return '';
  if (lower == 'who') return 'which';
  if (lower == 'that') return 'what';
  if (lower == 'learning') return 'to learn';
  if (lower == 'wake') return 'waking';
  if (lower == "aren't") return 'are';
  return '${answer}s';
}

String _thirdBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'seen') return 'see';
  if (lower == 'studying') return 'studied';
  if (lower == 'met') return 'meeting';
  if (lower == 'started') return 'starting';
  if (lower == 'waiting') return 'waited';
  if (lower == 'finished') return 'finishing';
  if (lower == 'rains') return 'rained';
  if (lower == 'had') return 'have';
  if (lower == 'cleaned') return 'cleans';
  if (lower == 'sent') return 'sending';
  if (lower == 'call') return 'called';
  if (lower == 'show') return 'shows';
  if (lower == 'was') return 'were';
  if (lower == 'lived') return 'lives';
  if (lower == 'to') return 'for';
  if (lower == 'who') return 'where';
  if (lower == 'that') return 'which';
  if (lower == 'learning') return 'learn';
  if (lower == 'wake') return 'woke';
  if (lower == "aren't") return 'do';
  return 'not';
}

String _fourthBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'seen') return 'seeing';
  if (lower == 'studying') return 'studies';
  if (lower == 'met') return 'meets';
  if (lower == 'started') return 'starts';
  if (lower == 'waiting') return 'waits';
  if (lower == 'finished') return 'finishes';
  if (lower == 'rains') return 'rain';
  if (lower == 'had') return 'will have';
  if (lower == 'cleaned') return 'cleaning';
  if (lower == 'sent') return 'sends';
  if (lower == 'call') return 'calling';
  if (lower == 'show') return 'showed';
  if (lower == 'was') return 'be';
  if (lower == 'lived') return 'living';
  if (lower == 'to') return 'at';
  if (lower == 'who') return 'what';
  if (lower == 'that') return 'who';
  if (lower == 'learning') return 'learned';
  if (lower == 'wake') return 'wakes';
  if (lower == "aren't") return 'is';
  return 'to';
}
