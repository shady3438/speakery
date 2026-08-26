import 'package:flutter/material.dart';

import 'package:speakery/data/grammar/grammar_models.dart';

// PHASE218_B2_AUDIT_LOCK
// Speakery B2 grammar baseline: premium examples, mixed quizzes,
// clean model/avoid pairs, and audit-ready topic coverage.

const List<GrammarTopic> grammarB2Topics = [
  GrammarTopic(
    id: 'b2_1',
    level: 'B2',
    title: 'Future Perfect',
    subtitle: 'completed before a future point',
    icon: Icons.flag_circle_rounded,
    rule:
        'Use Future Perfect to show that an action will be finished before a future time.',
    example: 'By June, I will have completed the course.',
    trap: 'By June, I will complete the course already.',
  ),
  GrammarTopic(
    id: 'b2_2',
    level: 'B2',
    title: 'Future Perfect Continuous',
    subtitle: 'duration before a future point',
    icon: Icons.timelapse_rounded,
    rule:
        'Use Future Perfect Continuous to show how long an action will have continued before a future time.',
    example: 'By noon, she will have been working for six hours.',
    trap: 'By noon, she will be working for six hours.',
  ),
  GrammarTopic(
    id: 'b2_3',
    level: 'B2',
    title: 'Advanced Gerund / Infinitive',
    subtitle: 'verb patterns with meaning changes',
    icon: Icons.route_rounded,
    rule:
        'Some verbs are followed by a gerund or an infinitive, and the choice can change the meaning.',
    example: 'I remember locking the door before I left.',
    trap: 'I remember to lock the door before I left.',
  ),
  GrammarTopic(
    id: 'b2_4',
    level: 'B2',
    title: 'Passive Reporting Structures',
    subtitle: 'careful reporting language',
    icon: Icons.campaign_rounded,
    rule:
        'Use passive reporting structures to report beliefs, claims, or expectations in careful writing.',
    example: 'It is believed that the plan will succeed.',
    trap: 'People believes that the plan will succeed.',
  ),
  GrammarTopic(
    id: 'b2_5',
    level: 'B2',
    title: 'Have Something Done',
    subtitle: 'services done by another person',
    icon: Icons.build_circle_rounded,
    rule:
        'Use have something done when someone arranges for another person to do a service.',
    example: 'I had my laptop repaired yesterday.',
    trap: 'I repaired my laptop by the technician yesterday.',
  ),
  GrammarTopic(
    id: 'b2_6',
    level: 'B2',
    title: 'Complex Relative Clauses',
    subtitle: 'extra information inside longer sentences',
    icon: Icons.account_tree_rounded,
    rule:
        'Use complex relative clauses to add precise information about people, things, or ideas.',
    example: 'The woman whose car was stolen called the police.',
    trap: 'The woman who her car was stolen called the police.',
  ),
  GrammarTopic(
    id: 'b2_7',
    level: 'B2',
    title: 'Participle Clauses',
    subtitle: 'shortened clauses for fluent writing',
    icon: Icons.compress_rounded,
    rule:
        'Use participle clauses to shorten information when the subject connection is clear.',
    example: 'Feeling tired, I went home early.',
    trap: 'Felt tired, I went home early.',
  ),
  GrammarTopic(
    id: 'b2_8',
    level: 'B2',
    title: 'Conditionals Review and Mixed Conditionals',
    subtitle: 'real, unreal, and mixed results',
    icon: Icons.call_split_rounded,
    rule:
        'Use mixed conditionals when a past condition has a present result or a present condition had a past result.',
    example: 'If I had studied harder, I would have a better job now.',
    trap: 'If I studied harder, I would have had a better job now.',
  ),
  GrammarTopic(
    id: 'b2_9',
    level: 'B2',
    title: 'Wish / If Only',
    subtitle: 'regret and unreal desire',
    icon: Icons.auto_awesome_rounded,
    rule:
        'Use wish and if only to talk about regrets, complaints, or unreal desires.',
    example: 'I wish I had listened to your advice.',
    trap: 'I wish I listened to your advice yesterday.',
  ),
  GrammarTopic(
    id: 'b2_10',
    level: 'B2',
    title: 'Modal Perfects',
    subtitle: 'past deduction or criticism',
    icon: Icons.psychology_alt_rounded,
    rule:
        'Use modal perfects to talk about past possibility, deduction, or criticism.',
    example: 'She must have forgotten the meeting.',
    trap: 'She must forgot the meeting.',
  ),
  GrammarTopic(
    id: 'b2_11',
    level: 'B2',
    title: 'Inversion Intro',
    subtitle: 'emphasis with negative adverbials',
    icon: Icons.swap_vert_circle_rounded,
    rule:
        'Use inversion after negative adverbials to create emphasis in careful writing.',
    example: 'Rarely have I seen such a clear explanation.',
    trap: 'Rarely I have seen such a clear explanation.',
  ),
  GrammarTopic(
    id: 'b2_12',
    level: 'B2',
    title: 'Emphasis Structures',
    subtitle: 'cleft sentences and focus',
    icon: Icons.center_focus_strong_rounded,
    rule:
        'Use emphasis structures to highlight the most important part of a sentence.',
    example: 'What I need is more time.',
    trap: 'What I need it is more time.',
  ),
  GrammarTopic(
    id: 'b2_13',
    level: 'B2',
    title: 'Advanced Linking Devices',
    subtitle: 'clear flow between ideas',
    icon: Icons.link_rounded,
    rule:
        'Use advanced linking devices to show contrast, addition, result, and concession clearly.',
    example: 'The task was difficult; nevertheless, we completed it.',
    trap: 'The task was difficult; moreover, we completed it.',
  ),
  GrammarTopic(
    id: 'b2_14',
    level: 'B2',
    title: 'Concession Clauses',
    subtitle: 'unexpected contrast',
    icon: Icons.compare_rounded,
    rule:
        'Use concession clauses to show that one idea is surprising despite another fact.',
    example: 'Although the evidence was weak, the claim was accepted.',
    trap: 'Although the evidence was weak, but the claim was accepted.',
  ),
  GrammarTopic(
    id: 'b2_15',
    level: 'B2',
    title: 'Purpose Result and Reason Clauses',
    subtitle: 'why something happens',
    icon: Icons.alt_route_rounded,
    rule:
        'Use purpose, result, and reason clauses to connect actions with causes and outcomes.',
    example: 'I left early so that I could catch the train.',
    trap: 'I left early for catch the train.',
  ),
  GrammarTopic(
    id: 'b2_16',
    level: 'B2',
    title: 'Advanced Passive Voice',
    subtitle: 'passive with complex objects',
    icon: Icons.layers_rounded,
    rule:
        'Use advanced passive forms when the action or reported result is more important than the actor.',
    example: 'The documents should have been sent yesterday.',
    trap: 'The documents should have sent yesterday.',
  ),
  GrammarTopic(
    id: 'b2_17',
    level: 'B2',
    title: 'Third Conditional',
    subtitle: 'imaginary past result',
    icon: Icons.history_edu_rounded,
    rule:
        'Use the third conditional to talk about an unreal past condition and its unreal past result.',
    example: 'If we had left earlier, we would have caught the train.',
    trap: 'If we would have left earlier, we would have caught the train.',
  ),
  GrammarTopic(
    id: 'b2_18',
    level: 'B2',
    title: 'Modal Deduction',
    subtitle: 'certainty and possibility now',
    icon: Icons.search_rounded,
    rule:
        'Use modal deduction to show how sure you are about a present or past situation.',
    example: "He can't be at home because his car is not here.",
    trap: 'He must not be at home because his car is not here.',
  ),
  GrammarTopic(
    id: 'b2_19',
    level: 'B2',
    title: 'Advanced Quantifiers',
    subtitle: 'precise amount and limitation',
    icon: Icons.pie_chart_rounded,
    rule:
        'Use advanced quantifiers to express amount, limitation, or sufficiency more precisely.',
    example: 'Few people understood the last question.',
    trap: 'A few people understood the last question, so nobody answered.',
  ),
  GrammarTopic(
    id: 'b2_20',
    level: 'B2',
    title: 'Precise Comparisons',
    subtitle: 'clear comparison language',
    icon: Icons.balance_rounded,
    rule:
        'Use precise comparison structures to compare results, changes, or qualities clearly.',
    example: 'This method is far more effective than the old one.',
    trap: 'This method is very more effective than the old one.',
  ),
];

class _B2LessonSpec {
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

  const _B2LessonSpec({
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

const List<_B2LessonSpec> _b2Specs = [
  _B2LessonSpec(
    id: 'b2_1',
    bigTitle: 'Future Perfect',
    goal:
        'Completed before a future point yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Future Perfect konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'By June, I will have completed the course.',
    pattern2: 'Sık yapılan hata',
    sample2: 'By June, I will complete the course already.',
    pattern3: 'Kullanım odağı',
    sample3: 'Will have completed gives the sentence its B2 meaning.',
    examples: [
      'By June, I will have completed the course.',
      'By June, We will have completed the course.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'By June, I will complete the course already.',
    right: 'By June, I will have completed the course.',
    reason: 'Will have completed is the correct focus for this B2 structure.',
    blankSentence: 'By June, I will have _____ the course.',
    blankAnswer: 'completed',
    orderItems: [
      'By',
      'June,',
      'I',
      'will',
      'have',
      'completed',
      'the',
      'course.'
    ],
    pairs: {
      'will have completed': 'finished before a future time',
      'by June': 'future deadline',
      'will have sent': 'completed result'
    },
  ),
  _B2LessonSpec(
    id: 'b2_2',
    bigTitle: 'Future Perfect Continuous',
    goal:
        'Duration before a future point yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Future Perfect Continuous konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'By noon, she will have been working for six hours.',
    pattern2: 'Sık yapılan hata',
    sample2: 'By noon, she will be working for six hours.',
    pattern3: 'Kullanım odağı',
    sample3: 'Will have been working gives the sentence its B2 meaning.',
    examples: [
      'By noon, she will have been working for six hours.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'By noon, she will be working for six hours.',
    right: 'By noon, she will have been working for six hours.',
    reason:
        'Will have been working is the correct focus for this B2 structure.',
    blankSentence: 'By noon, she will have been _____ for six hours.',
    blankAnswer: 'working',
    orderItems: [
      'By',
      'noon,',
      'she',
      'will',
      'have',
      'been',
      'working',
      'for',
      'six',
      'hours.'
    ],
    pairs: {
      'will have been working': 'future duration',
      'for six hours': 'length of time',
      'by noon': 'future point'
    },
  ),
  _B2LessonSpec(
    id: 'b2_3',
    bigTitle: 'Advanced Gerund / Infinitive',
    goal:
        'Verb patterns with meaning changes yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Advanced Gerund / Infinitive konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I remember locking the door before I left.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I remember to lock the door before I left.',
    pattern3: 'Kullanım odağı',
    sample3: 'Remember locking gives the sentence its B2 meaning.',
    examples: [
      'I remember locking the door before I left.',
      'Please remember to lock the office before you leave.',
      'I regret telling her the secret.',
      'We tried restarting the router.',
      'He stopped smoking last year.',
      'He stopped to answer the phone.',
    ],
    wrong: 'I remember to lock the door before I left.',
    right: 'I remember locking the door before I left.',
    reason: 'Remember locking is the correct focus for this B2 structure.',
    blankSentence: 'I remember _____ the door before I left.',
    blankAnswer: 'locking',
    orderItems: [
      'I',
      'remember',
      'locking',
      'the',
      'door',
      'before',
      'I',
      'left.'
    ],
    pairs: {
      'remember locking': 'memory of a past action',
      'remember to lock': 'do not forget a future action',
      'stop working': 'end an activity'
    },
  ),
  _B2LessonSpec(
    id: 'b2_4',
    bigTitle: 'Passive Reporting Structures',
    goal:
        'Formal reporting language yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Passive Reporting Structures konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'It is believed that the plan will succeed.',
    pattern2: 'Sık yapılan hata',
    sample2: 'People believes that the plan will succeed.',
    pattern3: 'Kullanım odağı',
    sample3: 'It is believed that gives the sentence its B2 meaning.',
    examples: [
      'It is believed that the plan will succeed.',
      'It are believed that the plan will succeed.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'People believes that the plan will succeed.',
    right: 'It is believed that the plan will succeed.',
    reason: 'It is believed that is the correct focus for this B2 structure.',
    blankSentence: 'It is _____ that the plan will succeed.',
    blankAnswer: 'believed',
    orderItems: [
      'It',
      'is',
      'believed',
      'that',
      'the',
      'plan',
      'will',
      'succeed.'
    ],
    pairs: {
      'it is believed that': 'formal report',
      'is expected to': 'prediction about subject',
      'people say that': 'less formal report'
    },
  ),
  _B2LessonSpec(
    id: 'b2_5',
    bigTitle: 'Have Something Done',
    goal:
        'Services done by another person yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Have Something Done konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I had my laptop repaired yesterday.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I repaired my laptop by the technician yesterday.',
    pattern3: 'Kullanım odağı',
    sample3: 'Had my laptop repaired gives the sentence its B2 meaning.',
    examples: [
      'I had my laptop repaired yesterday.',
      'We had our laptop repaired yesterday.',
      'I had my laptop repaired last week.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'I repaired my laptop by the technician yesterday.',
    right: 'I had my laptop repaired yesterday.',
    reason:
        'Had my laptop repaired is the correct focus for this B2 structure.',
    blankSentence: 'I had my laptop _____ yesterday.',
    blankAnswer: 'repaired',
    orderItems: ['I', 'had', 'my', 'laptop', 'repaired', 'yesterday.'],
    pairs: {
      'had my laptop repaired': 'service by another person',
      'got my hair cut': 'informal service form',
      'repaired my laptop': 'did it myself'
    },
  ),
  _B2LessonSpec(
    id: 'b2_6',
    bigTitle: 'Complex Relative Clauses',
    goal:
        'Extra information inside longer sentences yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Complex Relative Clauses konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The woman whose car was stolen called the police.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The woman who her car was stolen called the police.',
    pattern3: 'Kullanım odağı',
    sample3: 'Whose car was stolen gives the sentence its B2 meaning.',
    examples: [
      'The woman whose car was stolen called the police.',
      'The woman whose car were stolen called the police.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The woman who her car was stolen called the police.',
    right: 'The woman whose car was stolen called the police.',
    reason: 'Whose car was stolen is the correct focus for this B2 structure.',
    blankSentence: 'The woman _____ car was stolen called the police.',
    blankAnswer: 'whose',
    orderItems: [
      'The',
      'woman',
      'whose',
      'car',
      'was',
      'stolen',
      'called',
      'the',
      'police.'
    ],
    pairs: {
      'whose': 'possession in relative clauses',
      'which': 'things and ideas',
      'where': 'places'
    },
  ),
  _B2LessonSpec(
    id: 'b2_7',
    bigTitle: 'Participle Clauses',
    goal:
        'Shortened clauses for fluent writing yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Participle Clauses konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'Feeling tired, I went home early.',
    pattern2: 'Sık yapılan hata',
    sample2: 'Felt tired, I went home early.',
    pattern3: 'Kullanım odağı',
    sample3: 'Feeling tired gives the sentence its B2 meaning.',
    examples: [
      'Feeling tired, I went home early.',
      'Feeling tired, We went home early.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Felt tired, I went home early.',
    right: 'Feeling tired, I went home early.',
    reason: 'Feeling tired is the correct focus for this B2 structure.',
    blankSentence: '_____ tired, I went home early.',
    blankAnswer: 'Feeling',
    orderItems: ['Feeling', 'tired,', 'I', 'went', 'home', 'early.'],
    pairs: {
      'feeling tired': 'reason or state',
      'written in 2020': 'passive participle clause',
      'having finished': 'earlier action'
    },
  ),
  _B2LessonSpec(
    id: 'b2_8',
    bigTitle: 'Conditionals Review and Mixed Conditionals',
    goal:
        'Real, unreal, and mixed results yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Conditionals Review and Mixed Conditionals konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'If I had studied harder, I would have a better job now.',
    pattern2: 'Sık yapılan hata',
    sample2: 'If I studied harder, I would have had a better job now.',
    pattern3: 'Kullanım odağı',
    sample3: 'Past condition present result gives the sentence its B2 meaning.',
    examples: [
      'If I had studied harder, I would have a better job now.',
      'If We had studied harder, We would have a better job now.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'If I studied harder, I would have had a better job now.',
    right: 'If I had studied harder, I would have a better job now.',
    reason:
        'Past condition present result is the correct focus for this B2 structure.',
    blankSentence: 'If I had studied harder, I _____ have a better job now.',
    blankAnswer: 'would',
    orderItems: [
      'If',
      'I',
      'had',
      'studied',
      'harder,',
      'I',
      'would',
      'have',
      'a',
      'better',
      'job',
      'now.'
    ],
    pairs: {
      'had studied': 'past condition',
      'would have now': 'present result',
      'would have passed': 'past result'
    },
  ),
  _B2LessonSpec(
    id: 'b2_9',
    bigTitle: 'Wish / If Only',
    goal:
        'Regret and unreal desire yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Wish / If Only konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I wish I had listened to your advice.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I wish I listened to your advice yesterday.',
    pattern3: 'Kullanım odağı',
    sample3: 'Wish plus past perfect gives the sentence its B2 meaning.',
    examples: [
      'I wish I had listened to your advice.',
      'We wish We had listened to your advice.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'I wish I listened to your advice yesterday.',
    right: 'I wish I had listened to your advice.',
    reason:
        'Wish plus past perfect is the correct focus for this B2 structure.',
    blankSentence: 'I wish I had _____ to your advice.',
    blankAnswer: 'listened',
    orderItems: ['I', 'wish', 'I', 'had', 'listened', 'to', 'your', 'advice.'],
    pairs: {
      'wish I had listened': 'past regret',
      'wish I were': 'unreal present',
      'if only': 'strong regret'
    },
  ),
  _B2LessonSpec(
    id: 'b2_10',
    bigTitle: 'Modal Perfects',
    goal:
        'Past deduction or criticism yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Modal Perfects konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'She must have forgotten the meeting.',
    pattern2: 'Sık yapılan hata',
    sample2: 'She must forgot the meeting.',
    pattern3: 'Kullanım odağı',
    sample3: 'Must have forgotten gives the sentence its B2 meaning.',
    examples: [
      'She must have forgotten the meeting.',
      'They must have forgotten the meeting.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'She must forgot the meeting.',
    right: 'She must have forgotten the meeting.',
    reason: 'Must have forgotten is the correct focus for this B2 structure.',
    blankSentence: 'She must have _____ the meeting.',
    blankAnswer: 'forgotten',
    orderItems: ['She', 'must', 'have', 'forgotten', 'the', 'meeting.'],
    pairs: {
      'must have forgotten': 'strong past deduction',
      'could have helped': 'past possibility',
      'should have called': 'past criticism'
    },
  ),
  _B2LessonSpec(
    id: 'b2_11',
    bigTitle: 'Inversion Intro',
    goal:
        'Emphasis with negative adverbials yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Inversion Intro konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'Rarely have I seen such a clear explanation.',
    pattern2: 'Sık yapılan hata',
    sample2: 'Rarely I have seen such a clear explanation.',
    pattern3: 'Kullanım odağı',
    sample3: 'Rarely have i seen gives the sentence its B2 meaning.',
    examples: [
      'Rarely have I seen such a clear explanation.',
      'Never had she seen such a detailed report.',
      'Only then did the team understand the risk.',
      'Not until Friday did they announce the result.',
      'Under no circumstances should you share the password.',
      'Seldom do we receive such detailed feedback.',
    ],
    wrong: 'Rarely I have seen such a clear explanation.',
    right: 'Rarely have I seen such a clear explanation.',
    reason: 'Rarely have i seen is the correct focus for this B2 structure.',
    blankSentence: 'Rarely _____ I seen such a clear explanation.',
    blankAnswer: 'have',
    orderItems: [
      'Rarely',
      'have',
      'I',
      'seen',
      'such',
      'a',
      'clear',
      'explanation.'
    ],
    pairs: {
      'rarely have I': 'negative adverbial inversion',
      'never had she': 'past perfect inversion',
      'not only did he': 'emphatic addition'
    },
  ),
  _B2LessonSpec(
    id: 'b2_12',
    bigTitle: 'Emphasis Structures',
    goal:
        'Cleft sentences and focus yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Emphasis Structures konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'What I need is more time.',
    pattern2: 'Sık yapılan hata',
    sample2: 'What I need it is more time.',
    pattern3: 'Kullanım odağı',
    sample3: 'What i need is gives the sentence its B2 meaning.',
    examples: [
      'What I need is more time.',
      'What We need is more time.',
      'What I need are more time.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'What I need it is more time.',
    right: 'What I need is more time.',
    reason: 'What i need is is the correct focus for this B2 structure.',
    blankSentence: 'What I need _____ more time.',
    blankAnswer: 'is',
    orderItems: ['What', 'I', 'need', 'is', 'more', 'time.'],
    pairs: {
      'what I need is': 'focus on thing',
      'it was Ali who': 'focus on person',
      'the reason why': 'focus on reason'
    },
  ),
  _B2LessonSpec(
    id: 'b2_13',
    bigTitle: 'Advanced Linking Devices',
    goal:
        'Formal flow between ideas yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Advanced Linking Devices konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The task was difficult; nevertheless, we completed it.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The task was difficult; moreover, we completed it.',
    pattern3: 'Kullanım odağı',
    sample3: 'Nevertheless for contrast gives the sentence its B2 meaning.',
    examples: [
      'The task was difficult; nevertheless, we completed it.',
      'The task were difficult; nevertheless, we completed it.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The task was difficult; moreover, we completed it.',
    right: 'The task was difficult; nevertheless, we completed it.',
    reason:
        'Nevertheless for contrast is the correct focus for this B2 structure.',
    blankSentence: 'The task was difficult; _____, we completed it.',
    blankAnswer: 'nevertheless',
    orderItems: [
      'The',
      'task',
      'was',
      'difficult;',
      'nevertheless,',
      'we',
      'completed',
      'it.'
    ],
    pairs: {
      'nevertheless': 'contrast',
      'moreover': 'addition',
      'therefore': 'result'
    },
  ),
  _B2LessonSpec(
    id: 'b2_14',
    bigTitle: 'Concession Clauses',
    goal: 'Unexpected contrast yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Concession Clauses konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'Although the evidence was weak, the claim was accepted.',
    pattern2: 'Sık yapılan hata',
    sample2: 'Although the evidence was weak, but the claim was accepted.',
    pattern3: 'Kullanım odağı',
    sample3: 'Although without but gives the sentence its B2 meaning.',
    examples: [
      'Although the evidence was weak, the claim was accepted.',
      'Although the evidence were weak, the claim were accepted.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Although the evidence was weak, but the claim was accepted.',
    right: 'Although the evidence was weak, the claim was accepted.',
    reason: 'Although without but is the correct focus for this B2 structure.',
    blankSentence: 'Although the evidence was weak, the claim _____ accepted.',
    blankAnswer: 'was',
    orderItems: [
      'Although',
      'the',
      'evidence',
      'was',
      'weak,',
      'the',
      'claim',
      'was',
      'accepted.'
    ],
    pairs: {
      'although': 'contrast clause',
      'despite': 'noun phrase contrast',
      'even though': 'strong concession'
    },
  ),
  _B2LessonSpec(
    id: 'b2_15',
    bigTitle: 'Purpose Result and Reason Clauses',
    goal:
        'Why something happens yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Purpose Result and Reason Clauses konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'I left early so that I could catch the train.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I left early for catch the train.',
    pattern3: 'Kullanım odağı',
    sample3: 'So that for purpose gives the sentence its B2 meaning.',
    examples: [
      'I left early so that I could catch the train.',
      'We left early so that We could catch the train.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'I left early for catch the train.',
    right: 'I left early so that I could catch the train.',
    reason: 'So that for purpose is the correct focus for this B2 structure.',
    blankSentence: 'I left early so that I _____ catch the train.',
    blankAnswer: 'could',
    orderItems: [
      'I',
      'left',
      'early',
      'so',
      'that',
      'I',
      'could',
      'catch',
      'the',
      'train.'
    ],
    pairs: {'so that': 'purpose', 'because': 'reason', 'so': 'result'},
  ),
  _B2LessonSpec(
    id: 'b2_16',
    bigTitle: 'Advanced Passive Voice',
    goal:
        'Passive with complex objects yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Advanced Passive Voice konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'The documents should have been sent yesterday.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The documents should have sent yesterday.',
    pattern3: 'Kullanım odağı',
    sample3: 'Should have been sent gives the sentence its B2 meaning.',
    examples: [
      'The documents should have been sent yesterday.',
      'The documents should have been sent last week.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The documents should have sent yesterday.',
    right: 'The documents should have been sent yesterday.',
    reason: 'Should have been sent is the correct focus for this B2 structure.',
    blankSentence: 'The documents should have been _____ yesterday.',
    blankAnswer: 'sent',
    orderItems: [
      'The',
      'documents',
      'should',
      'have',
      'been',
      'sent',
      'yesterday.'
    ],
    pairs: {
      'should have been sent': 'modal perfect passive',
      'is being reviewed': 'continuous passive',
      'was expected to': 'reporting passive'
    },
  ),
  _B2LessonSpec(
    id: 'b2_17',
    bigTitle: 'Third Conditional',
    goal:
        'Imaginary past result yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Third Conditional konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'If we had left earlier, we would have caught the train.',
    pattern2: 'Sık yapılan hata',
    sample2: 'If we would have left earlier, we would have caught the train.',
    pattern3: 'Kullanım odağı',
    sample3: 'If plus past perfect gives the sentence its B2 meaning.',
    examples: [
      'If we had left earlier, we would have caught the train.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'If we would have left earlier, we would have caught the train.',
    right: 'If we had left earlier, we would have caught the train.',
    reason: 'If plus past perfect is the correct focus for this B2 structure.',
    blankSentence: 'If we had left earlier, we _____ have caught the train.',
    blankAnswer: 'would',
    orderItems: [
      'If',
      'we',
      'had',
      'left',
      'earlier,',
      'we',
      'would',
      'have',
      'caught',
      'the',
      'train.'
    ],
    pairs: {
      'had left': 'unreal past condition',
      'would have caught': 'unreal past result',
      'could have arrived': 'past possibility'
    },
  ),
  _B2LessonSpec(
    id: 'b2_18',
    bigTitle: 'Modal Deduction',
    goal:
        'Certainty and possibility now yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Modal Deduction konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: "He can't be at home because his car is not here.",
    pattern2: 'Sık yapılan hata',
    sample2: 'He must not be at home because his car is not here.',
    pattern3: 'Kullanım odağı',
    sample3: 'Can’t be for impossibility gives the sentence its B2 meaning.',
    examples: [
      "He can't be at home because his car is not here.",
      "They can't be at home because his car are not here.",
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'He must not be at home because his car is not here.',
    right: "He can't be at home because his car is not here.",
    reason:
        'Can’t be for impossibility is the correct focus for this B2 structure.',
    blankSentence: 'He _____ be at home because his car is not here.',
    blankAnswer: "can't",
    orderItems: [
      'He',
      "can't",
      'be',
      'at',
      'home',
      'because',
      'his',
      'car',
      'is',
      'not',
      'here.'
    ],
    pairs: {
      "can't be": 'impossible now',
      'must be': 'strong deduction now',
      'might be': 'possible now'
    },
  ),
  _B2LessonSpec(
    id: 'b2_19',
    bigTitle: 'Advanced Quantifiers',
    goal:
        'Precise amount and limitation yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Advanced Quantifiers konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'Few students understood the final question.',
    pattern2: 'Sık yapılan hata',
    sample2:
        'A few students understood the final question, so nobody answered.',
    pattern3: 'Kullanım odağı',
    sample3: 'Few versus a few gives the sentence its B2 meaning.',
    examples: [
      'Few students understood the final question.',
      'Few managers understood the final question.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'A few students understood the final question, so nobody answered.',
    right: 'Few students understood the final question.',
    reason: 'Few versus a few is the correct focus for this B2 structure.',
    blankSentence: '_____ students understood the final question.',
    blankAnswer: 'Few',
    orderItems: ['Few', 'students', 'understood', 'the', 'final', 'question.'],
    pairs: {
      'few students': 'not many and often negative',
      'a few students': 'some and often positive',
      'hardly any': 'almost none'
    },
  ),
  _B2LessonSpec(
    id: 'b2_20',
    bigTitle: 'Formal Comparisons',
    goal:
        'Academic comparison language yapısını akıcı ve kontrollü cümlelerde kullan.',
    intro:
        'Formal Comparisons konusunun amacı, iki fikir arasındaki zaman ve anlam ilişkisini doğru kurmaktır. Kalıbı ezberlemek yerine hangi durumda kullanıldığını örneklerle gör.',
    pattern1: 'Ana yapı',
    sample1: 'This method is far more effective than the old one.',
    pattern2: 'Sık yapılan hata',
    sample2: 'This method is very more effective than the old one.',
    pattern3: 'Kullanım odağı',
    sample3: 'Far more effective gives the sentence its B2 meaning.',
    examples: [
      'This method is far more effective than the old one.',
      'This method are far more effective than the old one.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'This method is very more effective than the old one.',
    right: 'This method is far more effective than the old one.',
    reason: 'Far more effective is the correct focus for this B2 structure.',
    blankSentence: 'This method is far more _____ than the old one.',
    blankAnswer: 'effective',
    orderItems: [
      'This',
      'method',
      'is',
      'far',
      'more',
      'effective',
      'than',
      'the',
      'old',
      'one.'
    ],
    pairs: {
      'far more effective': 'stronger comparison',
      'slightly less useful': 'small difference',
      'as reliable as': 'equal comparison'
    },
  ),
];

GrammarLesson? b2LessonForTopic(GrammarTopic topic) {
  final spec = _b2SpecFor(topic.id);
  if (spec == null) return null;
  return GrammarLesson(
    bigTitle: spec.bigTitle,
    oneLineGoal: _b2GoalFor(spec),
    timeLabel: '9 dk',
    teacherIntro: _b2IntroFor(spec),
    formulaRows: _b2FormulaRowsFor(spec),
    usageBullets: [
      'Check the time reference, helper verb and focus of the sentence together.',
      'Small form changes can change the meaning, tone or clarity of a B2 sentence.',
      'Use the pattern in a real message, explanation or short written paragraph.',
      'Reuse the structure in a workplace, study or everyday communication context.',
    ],
    examples: _b2ExamplesFor(spec),
    wrong: spec.wrong,
    right: spec.right,
    reason: _b2ReasonFor(spec),
    task:
        'Write four B2 sentences with this structure: one workplace or study example, one everyday example, one question or negative form, and one polished written sentence.',
    modelAnswer: spec.right,
    quiz: _b2QuizPack(spec),
  );
}

List<GrammarFormulaRow> _b2FormulaRowsFor(_B2LessonSpec spec) {
  final pattern = switch (spec.id) {
    'b2_1' => 'will have + V3 by/before + future point',
    'b2_2' => 'will have been + V-ing + for/since',
    'b2_3' => 'verb + V-ing / verb + to + V1 with meaning change',
    'b2_4' => 'It is said/believed/expected that + clause',
    'b2_5' => 'have/get + object + V3',
    'b2_6' => 'noun + whose/where/which/who + clause',
    'b2_7' => 'V-ing / V3 participle phrase + main clause',
    'b2_8' => 'if + past perfect, would + V1 now',
    'b2_9' => 'wish/if only + past simple or past perfect',
    'b2_10' => 'modal + have + V3',
    'b2_11' => 'negative adverbial + auxiliary + subject + verb',
    'b2_12' => 'what/it + focus clause',
    'b2_13' => 'linker + clause with contrast/result/addition meaning',
    'b2_14' => 'although/even though + clause / despite + noun phrase',
    'b2_15' => 'so that + clause / because + clause / so + result',
    'b2_16' => 'modal + have been + V3 / be being + V3',
    'b2_17' => 'if + past perfect, would have + V3',
    'b2_18' => "must/might/can't + be / have + V3",
    'b2_19' => 'few/a few/little/a little/enough/plenty of + noun',
    'b2_20' => 'far/slightly/much + comparative / as + adjective + as',
    _ => spec.pattern1,
  };
  return [
    GrammarFormulaRow(
        label: 'Structure', pattern: pattern, sample: spec.sample1),
    GrammarFormulaRow(
        label: 'Form note', pattern: 'Check', sample: _b2FormNoteFor(spec)),
    GrammarFormulaRow(
        label: 'Usage focus', pattern: 'Use', sample: _b2UsageFocusFor(spec)),
  ];
}

String _b2FormNoteFor(_B2LessonSpec spec) {
  return switch (spec.id) {
    'b2_1' => 'Use by or before to mark the future deadline.',
    'b2_2' => 'Keep have been before the -ing verb.',
    'b2_3' => 'Learn the verb pattern together with the meaning.',
    'b2_4' => 'Use it is reported that or subject + is reported to.',
    'b2_5' => 'The object receives the action: have + object + V3.',
    'b2_6' => 'Use whose for possession and which/that for things.',
    'b2_7' => 'Use V-ing for active meaning and V3 for passive meaning.',
    'b2_8' => 'Mixed conditionals connect two different time frames.',
    'b2_9' => 'Use past perfect after wish for past regret.',
    'b2_10' => 'Keep the full modal perfect chain: modal + have + V3.',
    'b2_11' => 'After a negative opening, invert auxiliary and subject.',
    'b2_12' => 'Use what or it to place the focus clearly.',
    'b2_13' => 'Choose the linker for the logical relationship.',
    'b2_14' => 'Although takes a clause; despite takes a noun phrase or -ing.',
    'b2_15' => 'Use so that for purpose and so for result.',
    'b2_16' => 'Keep be/been before the past participle in passive forms.',
    'b2_17' =>
      'Use past perfect in the if-clause and would have + V3 in the result.',
    'b2_18' => 'Choose must, might or cannot according to certainty.',
    'b2_19' => 'Few/little sound limited; a few/a little sound positive.',
    'b2_20' => 'Use degree words before comparatives, not before more twice.',
    _ => spec.sample1,
  };
}

String _b2UsageFocusFor(_B2LessonSpec spec) {
  return switch (spec.id) {
    'b2_1' => 'Use it for deadlines, plans and expected completion.',
    'b2_2' => 'Use it when the duration up to a future time matters.',
    'b2_3' => 'Use it when a verb pattern changes the exact message.',
    'b2_4' =>
      'Use it for careful reporting when the source is general or less important.',
    'b2_5' => 'Use it for services, repairs and arranged work.',
    'b2_6' => 'Use it to add precise identifying or extra information.',
    'b2_7' => 'Use it mostly in writing when the subject connection is clear.',
    'b2_8' => 'Use it to explain present results of unreal past situations.',
    'b2_9' => 'Use it for regrets, complaints and unreal wishes.',
    'b2_10' => 'Use it to discuss past probability, regret or criticism.',
    'b2_11' => 'Use it sparingly in careful writing or formal speech.',
    'b2_12' => 'Use it to highlight the key person, thing, reason or result.',
    'b2_13' => 'Use it to make longer explanations easier to follow.',
    'b2_14' => 'Use it when the second idea is unexpected.',
    'b2_15' => 'Use it to explain purpose, reason and result clearly.',
    'b2_16' => 'Use it when the process or result matters more than the actor.',
    'b2_17' => 'Use it for unreal past alternatives and consequences.',
    'b2_18' =>
      'Use it when evidence makes a situation certain, possible or impossible.',
    'b2_19' => 'Use it to make quantity sound exact and natural.',
    'b2_20' => 'Use it to describe the size of a difference accurately.',
    _ => spec.sample3,
  };
}

String _b2GoalFor(_B2LessonSpec spec) {
  return switch (spec.id) {
    'b2_1' => 'Show that an action will be complete before a future point.',
    'b2_2' =>
      'Show how long an action will have continued before a future point.',
    'b2_3' => 'Choose gerund or infinitive patterns when the meaning changes.',
    'b2_4' =>
      'Report beliefs, claims or expectations without over-focusing on the speaker.',
    'b2_5' => 'Explain services or repairs arranged for another person to do.',
    'b2_6' =>
      'Add precise information about possession, places, people and ideas.',
    'b2_7' => 'Shorten connected information with clear participle clauses.',
    'b2_8' =>
      'Connect an unreal past condition with a present result, or the reverse.',
    'b2_9' => 'Express regret, complaint or unreal desire clearly.',
    'b2_10' =>
      'Talk about past deduction, possibility, missed chances and criticism.',
    'b2_11' =>
      'Use inversion after negative adverbials for emphasis in careful writing.',
    'b2_12' => 'Highlight the most important part of a sentence.',
    'b2_13' =>
      'Connect ideas clearly with contrast, result, addition and concession.',
    'b2_14' =>
      'Show an unexpected contrast between two ideas without over-linking.',
    'b2_15' =>
      'Connect actions with purpose, reason and result in natural sentences.',
    'b2_16' =>
      'Use complex passive forms when the action or result is the focus.',
    'b2_17' =>
      'Talk about unreal past situations and the results that did not happen.',
    'b2_18' => 'Show how sure you are about present and past situations.',
    'b2_19' =>
      'Use quantifiers to express amount, limitation and sufficiency precisely.',
    'b2_20' =>
      'Compare results, changes and qualities with precise degree language.',
    _ => 'Use this B2 grammar point clearly in real communication.',
  };
}

String _b2IntroFor(_B2LessonSpec spec) {
  return switch (spec.id) {
    'b2_1' =>
      'Future Perfect looks from now to a future deadline and says the action will be finished before that point.',
    'b2_2' =>
      'Future Perfect Continuous focuses on duration up to a future moment. It is useful for work, study and long-running plans.',
    'b2_3' =>
      'Some verbs change meaning with gerund or infinitive. Learn the pattern and the meaning together.',
    'b2_4' =>
      'Passive reporting is useful when the information matters more than who says it. Keep the reporting structure clear.',
    'b2_5' =>
      'Causative have/get shows that you arrange a service. You are not saying you personally did the work.',
    'b2_6' =>
      'Complex relative clauses make sentences more precise. Use whose for possession and where for places.',
    'b2_7' =>
      'Participle clauses make writing smoother when the subject connection is clear. Avoid them if the subject becomes confusing.',
    'b2_8' =>
      'Mixed conditionals connect different times: a past condition can explain a present result.',
    'b2_9' =>
      'Wish and if only express distance from reality. Use past forms for present wishes and past perfect for past regret.',
    'b2_10' =>
      'Modal perfects use modal + have + V3. They let you discuss past certainty, possibility, regret and criticism.',
    'b2_11' =>
      'Inversion changes word order after negative adverbials like rarely, never and not only. It adds emphasis.',
    'b2_12' =>
      'Emphasis structures help guide the listener to the key information: the problem, the person, the time or the action.',
    'b2_13' =>
      'Linking devices should match the logic. Nevertheless contrasts; therefore shows result; moreover adds information.',
    'b2_14' =>
      'Concession clauses show that the result is surprising. Use although/even though with a clause and despite with a noun phrase.',
    'b2_15' =>
      'Purpose, reason and result clauses explain why something happens and what follows from it.',
    'b2_16' =>
      'Advanced passive forms combine passive voice with modals, perfect forms and continuous forms.',
    'b2_17' =>
      'Third Conditional imagines a different past. The condition and result are both unreal now.',
    'b2_18' =>
      'Deduction modals show confidence. Must is strong, might is possible, and cannot/can\'t means impossible.',
    'b2_19' =>
      'Advanced quantifiers make amount more precise. Few and a few are not the same; little and a little are not the same.',
    'b2_20' =>
      'Precise comparisons use degree words like far, much, slightly and nearly to show how big the difference is.',
    _ =>
      'Study the model, compare it with the common mistake, and use the structure in a real context.',
  };
}

String _b2ReasonFor(_B2LessonSpec spec) {
  return switch (spec.id) {
    'b2_1' =>
      'Future Perfect uses will have + past participle to show completion before a future deadline.',
    'b2_2' =>
      'Future Perfect Continuous uses will have been + -ing to show duration up to a future point.',
    'b2_3' =>
      'The gerund refers to an earlier remembered action; the infinitive points to a future responsibility.',
    'b2_4' =>
      'Passive reporting keeps the claim careful and impersonal: it is believed that or is expected to.',
    'b2_5' =>
      'Have something done shows an arranged service; the subject arranges the action rather than doing it personally.',
    'b2_6' =>
      'Whose connects possession directly to the noun, so the sentence stays compact and precise.',
    'b2_7' =>
      'A participle clause works when the subject relationship is clear and the participle form matches active or passive meaning.',
    'b2_8' =>
      'The sentence links an unreal past condition to a present result, so the two time frames must both be clear.',
    'b2_9' =>
      'Wish + past perfect expresses regret about a past action that cannot now be changed.',
    'b2_10' =>
      'Modal perfects require modal + have + past participle to discuss past deduction, possibility or criticism.',
    'b2_11' =>
      'A negative adverbial at the front triggers auxiliary inversion: rarely have I, not rarely I have.',
    'b2_12' =>
      'The focus structure already contains the subject and verb, so no extra subject is needed.',
    'b2_13' =>
      'Nevertheless signals contrast, while moreover adds information; the linker must match the logic.',
    'b2_14' =>
      'Although already introduces concession, so the main clause should not add another contrast connector.',
    'b2_15' =>
      'So that introduces purpose and is followed by a clause with a subject and modal when needed.',
    'b2_16' =>
      'Advanced passive forms keep the passive chain complete with be or been before the past participle.',
    'b2_17' =>
      'The third conditional uses if + past perfect and would have + past participle for an unreal past result.',
    'b2_18' =>
      'Cannot be expresses impossibility based on evidence; must not would sound like prohibition or a different deduction.',
    'b2_19' =>
      'Few emphasizes a very small number; a few means some and sounds more positive.',
    'b2_20' =>
      'Degree words such as far, much and slightly modify comparative adjectives naturally.',
    _ => 'The correct option keeps the target B2 form and meaning clear.',
  };
}

List<String> _b2ExamplesFor(_B2LessonSpec spec) {
  final examples = switch (spec.id) {
    'b2_1' => const [
        'By June, I will have completed the course.',
        'The report will have been sent before the meeting.',
        'By the time you arrive, we will have finished dinner.',
        'She will have saved enough money by December.',
        'Will you have read the contract by Monday?',
        'They will not have moved into the new office by then.',
      ],
    'b2_2' => const [
        'By noon, she will have been working for six hours.',
        'By next year, I will have been living here for ten years.',
        'When the project ends, we will have been testing it for months.',
        'By July, he will have been training with the team for a year.',
        'How long will you have been studying English by December?',
        'They will have been waiting for an hour by the time we arrive.',
      ],
    'b2_3' => const [
        'I remember locking the door before I left.',
        'Please remember to lock the door when you leave.',
        'She stopped drinking coffee last month.',
        'We stopped to buy coffee on the way.',
        'He tried calling the office, but no one answered.',
        'I regret telling him about the plan.',
      ],
    'b2_4' => const [
        'It is believed that the plan will succeed.',
        'The plan is expected to reduce costs.',
        'It was reported that the road had been closed.',
        'The company is said to be hiring new staff.',
        'It is thought that the decision will take time.',
        'The painting is believed to be over two hundred years old.',
      ],
    'b2_5' => const [
        'I had my laptop repaired yesterday.',
        'She is getting her house painted this week.',
        'We had the documents translated before the meeting.',
        'He got his phone screen replaced.',
        'They are having the office cleaned tonight.',
        'I need to have my car checked.',
      ],
    'b2_6' => const [
        'The woman whose car was stolen called the police.',
        'The building where I work is being renovated.',
        'The report, which was published yesterday, is very detailed.',
        'I spoke to a manager whose team works remotely.',
        'The course that I chose starts next week.',
        'The colleague who helped me has moved to Ankara.',
      ],
    'b2_7' => const [
        'Feeling tired, I went home early.',
        'Written in simple language, the guide is easy to follow.',
        'Having finished the report, she sent it to her manager.',
        'Working from home, he saves two hours a day.',
        'Located near the station, the hotel is easy to find.',
        'Not knowing the answer, I asked for help.',
      ],
    'b2_8' => const [
        'If I had studied harder, I would have a better job now.',
        'If she spoke French, she would have applied for that role.',
        'If we had left earlier, we would be there now.',
        'If I were more organized, I would not have missed the deadline.',
        'If he had taken the job, he would be living in London now.',
        'If they knew the area better, they would not have got lost.',
      ],
    'b2_9' => const [
        'I wish I had listened to your advice.',
        'I wish I had more free time.',
        'If only we had booked earlier.',
        'She wishes her neighbors were quieter.',
        'I wish I could speak Italian.',
        'If only I had not sent that message.',
      ],
    'b2_10' => const [
        'She must have forgotten the appointment.',
        'He might have taken the wrong train.',
        'You should have called me earlier.',
        'They could have finished the work yesterday.',
        'The email may have gone to spam.',
        'She cannot have seen the message yet.',
      ],
    'b2_11' => const [
        'Rarely have I seen such a clear explanation.',
        'Never had she felt so confident before.',
        'Not only did he apologize, but he also offered to help.',
        'Only then did I understand the problem.',
        'Hardly had we arrived when it started raining.',
        'Seldom do we get such direct feedback.',
      ],
    'b2_12' => const [
        'What I need is more time.',
        'It was Deniz who solved the problem.',
        'What surprised me was the cost.',
        'The thing I like most is the clear layout.',
        'It was after the meeting that she called me.',
        'What matters now is the deadline.',
      ],
    'b2_13' => const [
        'The task was difficult; nevertheless, we completed it.',
        'The price is high; however, the quality is excellent.',
        'The team worked quickly; therefore, the report was ready early.',
        'The plan is simple. Moreover, it is easy to explain.',
        'The meeting was short; nevertheless, it was useful.',
        'The data is limited; as a result, the conclusion is cautious.',
      ],
    'b2_14' => const [
        'Although the evidence was weak, the claim was accepted.',
        'Despite the delay, we arrived on time.',
        'Even though she was tired, she finished the presentation.',
        'Despite working late, he looked relaxed.',
        'Although the room was small, it was comfortable.',
        'In spite of the noise, I managed to concentrate.',
      ],
    'b2_15' => const [
        'I left early so that I could catch the train.',
        'She lowered her voice so as not to wake the baby.',
        'We moved the meeting because several people were away.',
        'The roads were icy, so we drove slowly.',
        'He saved the receipt in case he needed to return the item.',
        'The instructions were unclear, which caused several mistakes.',
      ],
    'b2_16' => const [
        'The documents should have been sent yesterday.',
        'The house is being renovated this month.',
        'The issue has been discussed several times.',
        'The results will be announced tomorrow.',
        'The report was being reviewed when I called.',
        'The mistake could have been avoided.',
      ],
    'b2_17' => const [
        'If we had left earlier, we would have caught the train.',
        'If I had known about the meeting, I would have joined.',
        'She would have passed if she had studied more.',
        'If they had checked the address, they would not have got lost.',
        'Would you have accepted the job if they had offered it?',
        'If he had called me, I could have helped.',
      ],
    'b2_18' => const [
        "He can't be at home because his car is not here.",
        'She must be at work; her laptop is open.',
        'They might be stuck in traffic.',
        'He must have forgotten the appointment.',
        'She cannot have finished already.',
        'The package may have been delivered to the wrong address.',
      ],
    'b2_19' => const [
        'Few students understood the final question.',
        'A few people stayed after the meeting.',
        'There is little time left.',
        'There is a little milk in the fridge.',
        'Plenty of seats are still available.',
        'Hardly any customers complained.',
      ],
    'b2_20' => const [
        'This method is far more effective than the old one.',
        'The new office is slightly larger than the old one.',
        'This route is much quicker in the morning.',
        'The two plans are nearly as expensive as each other.',
        'Her explanation was considerably clearer than mine.',
        'The second version is no less useful than the first.',
      ],
    _ => _b2CleanExamples(spec),
  };
  return examples;
}

_B2LessonSpec? _b2SpecFor(String id) {
  for (final spec in _b2Specs) {
    if (spec.id == id) return spec;
  }
  return null;
}

List<String> _b2CleanExamples(_B2LessonSpec spec) {
  bool isPlaceholder(String s) {
    final v = s.toLowerCase().trim();
    return v.contains('the teacher explained') ||
        v.contains('the students completed') ||
        v.contains('we checked the details') ||
        v.contains('the manager changed the plan');
  }

  final must = <String>[
    spec.right,
    spec.sample1,
    spec.sample3,
  ].where((e) => e.trim().isNotEmpty).toList();

  final cleaned = <String>[];
  void add(String v) {
    final t = v.trim();
    if (t.isEmpty) return;
    if (isPlaceholder(t)) return;
    if (cleaned.any((e) => e.toLowerCase() == t.toLowerCase())) return;
    cleaned.add(t);
  }

  for (final e in spec.examples) {
    add(e);
  }
  for (final e in must) {
    add(e);
  }

  final base = cleaned.isNotEmpty ? cleaned.first : spec.right;
  for (final v in _b2ExampleVariants(base)) {
    if (cleaned.length >= 6) break;
    add(v);
  }

  return cleaned.take(6).toList();
}

List<String> _b2ExampleVariants(String sentence) {
  final s = sentence.trim();
  if (s.isEmpty) return const [];

  final variants = <String>[];
  final lower = s.toLowerCase();

  String swapSubject(String from, String to) {
    if (!RegExp('^${RegExp.escape(from)}\\b', caseSensitive: false)
        .hasMatch(s)) {
      return s;
    }
    return s.replaceFirst(
        RegExp('^${RegExp.escape(from)}\\b', caseSensitive: false), to);
  }

  variants.add(swapSubject('I', 'She'));
  variants.add(swapSubject('I', 'They'));
  variants.add(swapSubject('I', 'We'));

  if (lower.startsWith('by ')) {
    variants.add(s.replaceFirst(
        RegExp(r'^By\\b', caseSensitive: false), 'By next week'));
    variants.add(s.replaceFirst(
        RegExp(r'^By\\b', caseSensitive: false), 'By the end of this month'));
  }

  return variants
      .where((v) => v.trim().isNotEmpty && v.trim().toLowerCase() != lower)
      .toList();
}

List<GrammarQuizQuestion> _b2QuizPack(_B2LessonSpec spec) {
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
      explanation: _b2ReasonFor(spec),
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
      explanation: _b2ReasonFor(spec),
    ),
  ];
}

List<String> _cleanOptions(List<String> raw) {
  final result = <String>[];
  for (final item in raw) {
    final clean = item.trim();
    if (clean.isNotEmpty && !result.contains(clean)) result.add(clean);
  }
  return result.take(4).toList();
}

String _wrongBlank(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'completed') return 'complete';
  if (lower == 'working') return 'work';
  if (lower == 'locking') return 'to lock';
  if (lower == 'believed') return 'believe';
  if (lower == 'repaired') return 'repair';
  if (lower == 'whose') return 'who';
  if (lower == 'feeling') return 'Felt';
  if (lower == 'would') return 'will';
  if (lower == 'listened') return 'listen';
  if (lower == 'forgotten') return 'forgot';
  if (lower == 'have') return 'had';
  if (lower == 'is') return 'are';
  if (lower == 'nevertheless') return 'moreover';
  if (lower == 'was') return 'were';
  if (lower == 'could') return 'can';
  if (lower == 'sent') return 'send';
  if (lower == "can't") return 'must not';
  if (lower == 'few') return 'A few';
  if (lower == 'effective') return 'effectively';
  return '${answer}s';
}

String _thirdBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'completed') return 'completing';
  if (lower == 'working') return 'worked';
  if (lower == 'locking') return 'lock';
  if (lower == 'believed') return 'believing';
  if (lower == 'repaired') return 'repairs';
  if (lower == 'whose') return 'which';
  if (lower == 'feeling') return 'Feel';
  if (lower == 'would') return 'did';
  if (lower == 'listened') return 'listening';
  if (lower == 'forgotten') return 'forgetting';
  if (lower == 'have') return 'has';
  if (lower == 'is') return 'be';
  if (lower == 'nevertheless') return 'therefore';
  if (lower == 'was') return 'is';
  if (lower == 'could') return 'would';
  if (lower == 'sent') return 'sending';
  if (lower == "can't") return 'may';
  if (lower == 'few') return 'Much';
  if (lower == 'effective') return 'effect';
  return 'not';
}

String _fourthBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'completed') return 'completes';
  if (lower == 'working') return 'works';
  if (lower == 'locking') return 'locked';
  if (lower == 'believed') return 'believes';
  if (lower == 'repaired') return 'repairing';
  if (lower == 'whose') return 'where';
  if (lower == 'feeling') return 'Feels';
  if (lower == 'would') return 'should';
  if (lower == 'listened') return 'listens';
  if (lower == 'forgotten') return 'forgets';
  if (lower == 'have') return 'be';
  if (lower == 'is') return 'has';
  if (lower == 'nevertheless') return 'also';
  if (lower == 'was') return 'be';
  if (lower == 'could') return 'must';
  if (lower == 'sent') return 'sends';
  if (lower == "can't") return 'must';
  if (lower == 'few') return 'Any';
  if (lower == 'effective') return 'efficiency';
  return 'to';
}
