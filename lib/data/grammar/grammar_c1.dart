import 'package:flutter/material.dart';

import 'package:speakery/data/grammar/grammar_models.dart';

// PHASE221_C1_AUDIT_LOCK
// Speakery C1 grammar baseline: audit-ready content, clean examples,
// mixed quiz types, and route-compatible lesson builders.

const List<GrammarTopic> grammarC1Topics = [
  GrammarTopic(
    id: 'c1_1',
    level: 'C1',
    title: 'Full Inversion',
    subtitle: 'formal fronted place or direction',
    icon: Icons.swap_vert_circle_rounded,
    rule:
        'Use full inversion after fronted place expressions when the sentence needs a formal or literary flow.',
    example: 'On the wall hung a large old photograph.',
    trap: 'On the wall a large old photograph hung.',
  ),
  GrammarTopic(
    id: 'c1_2',
    level: 'C1',
    title: 'Cleft Sentences',
    subtitle: 'highlighting exact information',
    icon: Icons.center_focus_strong_rounded,
    rule: 'Use cleft sentences to focus attention on one part of the message.',
    example: 'What surprised me was the final result.',
    trap: 'What surprised me it was the final result.',
  ),
  GrammarTopic(
    id: 'c1_3',
    level: 'C1',
    title: 'Emphatic Do',
    subtitle: 'adding insistence in positive sentences',
    icon: Icons.bolt_rounded,
    rule:
        'Use emphatic do to add contrast, correction, or strong confirmation.',
    example: 'I do understand your concern.',
    trap: 'I understand do your concern.',
  ),
  GrammarTopic(
    id: 'c1_4',
    level: 'C1',
    title: 'Advanced Modality',
    subtitle: 'certainty, criticism, and expectation',
    icon: Icons.psychology_alt_rounded,
    rule:
        'Use advanced modality to express probability, criticism, or expectation with precision.',
    example: 'You ought to have told us earlier.',
    trap: 'You ought have told us earlier.',
  ),
  GrammarTopic(
    id: 'c1_5',
    level: 'C1',
    title: 'Advanced Linkers',
    subtitle: 'precise flow between ideas',
    icon: Icons.link_rounded,
    rule:
        'Use advanced linkers to connect contrast, result, and reinforcement smoothly.',
    example:
        'The evidence was limited; nonetheless, the claim remained convincing.',
    trap: 'The evidence was limited; moreover, the claim remained convincing.',
  ),
  GrammarTopic(
    id: 'c1_6',
    level: 'C1',
    title: 'Noun Clauses',
    subtitle: 'complex ideas as sentence parts',
    icon: Icons.account_tree_rounded,
    rule:
        'Use noun clauses to turn full ideas into subjects, objects, or complements.',
    example: 'What the committee decided surprised everyone.',
    trap: 'What did the committee decide surprised everyone.',
  ),
  GrammarTopic(
    id: 'c1_7',
    level: 'C1',
    title: 'Reduced Relative Clauses',
    subtitle: 'compact relative information',
    icon: Icons.compress_rounded,
    rule: 'Use reduced relative clauses to make formal writing more concise.',
    example: 'The documents submitted yesterday require careful review.',
    trap: 'The documents which submitted yesterday require careful review.',
  ),
  GrammarTopic(
    id: 'c1_8',
    level: 'C1',
    title: 'Nominalisation Intro',
    subtitle: 'turning actions into noun phrases',
    icon: Icons.article_rounded,
    rule:
        'Use nominalisation to make formal writing more concise and focused on ideas.',
    example: 'The rapid expansion of the company changed the market.',
    trap: 'The company expanded rapid changed the market.',
  ),
  GrammarTopic(
    id: 'c1_9',
    level: 'C1',
    title: 'Advanced Passive',
    subtitle: 'complex passive structures',
    icon: Icons.layers_rounded,
    rule:
        'Use advanced passive structures when process, result, or responsibility is more important than the actor.',
    example: 'The proposal is believed to have been accepted.',
    trap: 'The proposal believes to have been accepted.',
  ),
  GrammarTopic(
    id: 'c1_10',
    level: 'C1',
    title: 'Hedging',
    subtitle: 'softening claims responsibly',
    icon: Icons.tune_rounded,
    rule: 'Use hedging to make claims cautious, balanced, and responsible.',
    example: 'The results appear to support the hypothesis.',
    trap: 'The results prove to support the hypothesis.',
  ),
  GrammarTopic(
    id: 'c1_11',
    level: 'C1',
    title: 'Advanced Conditionals',
    subtitle: 'formal unreal alternatives',
    icon: Icons.call_split_rounded,
    rule:
        'Use advanced conditionals to express formal hypothetical situations and consequences.',
    example: 'Had we known the risk, we would have changed the plan.',
    trap: 'Had we knew the risk, we would have changed the plan.',
  ),
  GrammarTopic(
    id: 'c1_12',
    level: 'C1',
    title: 'Reduced Clauses',
    subtitle: 'efficient clause reduction',
    icon: Icons.short_text_rounded,
    rule:
        'Use reduced clauses to remove repeated subjects and create fluent written sentences.',
    example: 'Having finished the report, she sent it to the manager.',
    trap: 'Having finish the report, she sent it to the manager.',
  ),
  GrammarTopic(
    id: 'c1_13',
    level: 'C1',
    title: 'Register Control',
    subtitle: 'choosing formal or informal wording',
    icon: Icons.record_voice_over_rounded,
    rule:
        'Use register control to match grammar and vocabulary to the situation.',
    example: 'I would appreciate your assistance with this matter.',
    trap: 'I want you to help me with this thing.',
  ),
  GrammarTopic(
    id: 'c1_14',
    level: 'C1',
    title: 'Subjunctive / Formulaic Structures',
    subtitle: 'formal fixed patterns',
    icon: Icons.rule_rounded,
    rule:
        'Use subjunctive and formulaic structures after verbs like suggest, insist, and recommend.',
    example: 'The manager suggested that he be given more time.',
    trap: 'The manager suggested that he is given more time.',
  ),
  GrammarTopic(
    id: 'c1_15',
    level: 'C1',
    title: 'Ellipsis / Substitution Intro',
    subtitle: 'avoiding unnecessary repetition',
    icon: Icons.repeat_rounded,
    rule:
        'Use ellipsis and substitution to avoid repeating information when the meaning is clear.',
    example: 'I enjoyed the lecture, and so did my colleague.',
    trap: 'I enjoyed the lecture, and so my colleague did.',
  ),
];

class _C1LessonSpec {
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

  const _C1LessonSpec({
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

const List<_C1LessonSpec> _c1Specs = [
  _C1LessonSpec(
    id: 'c1_1',
    bigTitle: 'Full Inversion',
    goal:
        'Formal fronted place or direction yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Full Inversion konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'On the wall hung a large old photograph.',
    pattern2: 'Sık yapılan hata',
    sample2: 'On the wall a large old photograph hung.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'On the wall hung a large old photograph.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'On the wall a large old photograph hung.',
    right: 'On the wall hung a large old photograph.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'On the wall _____ a large old photograph.',
    blankAnswer: 'hung',
    orderItems: [
      'On',
      'the',
      'wall',
      'hung',
      'a',
      'large',
      'old',
      'photograph.'
    ],
    pairs: {
      'stood': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_2',
    bigTitle: 'Cleft Sentences',
    goal:
        'Highlighting exact information yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Cleft Sentences konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'What surprised me was the final result.',
    pattern2: 'Sık yapılan hata',
    sample2: 'What surprised me it was the final result.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'What surprised me was the final result.',
      'What surprised us was the final result.',
      'What surprised me were the final result.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
    ],
    wrong: 'What surprised me it was the final result.',
    right: 'What surprised me was the final result.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'What surprised me _____ the final result.',
    blankAnswer: 'was',
    orderItems: ['What', 'surprised', 'me', 'was', 'the', 'final', 'result.'],
    pairs: {
      'was': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_3',
    bigTitle: 'Emphatic Do',
    goal:
        'Adding insistence in positive sentences yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Emphatic Do konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'I do understand your concern.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I understand do your concern.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'I do understand your concern.',
      'We do understand your concern.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'I understand do your concern.',
    right: 'I do understand your concern.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'I _____ understand your concern.',
    blankAnswer: 'do',
    orderItems: ['I', 'do', 'understand', 'your', 'concern.'],
    pairs: {
      'do': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_4',
    bigTitle: 'Advanced Modality',
    goal:
        'Certainty, criticism, and expectation yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Advanced Modality konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'You ought to have told us earlier.',
    pattern2: 'Sık yapılan hata',
    sample2: 'You ought have told us earlier.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'You ought to have told us earlier.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'You ought have told us earlier.',
    right: 'You ought to have told us earlier.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'You ought to _____ told us earlier.',
    blankAnswer: 'have',
    orderItems: ['You', 'ought', 'to', 'have', 'told', 'us', 'earlier.'],
    pairs: {
      'have': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_5',
    bigTitle: 'Advanced Linkers',
    goal:
        'Precise academic flow yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Advanced Linkers konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1:
        'The evidence was limited; nonetheless, the claim remained convincing.',
    pattern2: 'Sık yapılan hata',
    sample2:
        'The evidence was limited; moreover, the claim remained convincing.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'The evidence was limited; nonetheless, the claim remained convincing.',
      'The evidence were limited; nonetheless, the claim remained convincing.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The evidence was limited; moreover, the claim remained convincing.',
    right:
        'The evidence was limited; nonetheless, the claim remained convincing.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence:
        'The evidence was limited; _____, the claim remained convincing.',
    blankAnswer: 'nonetheless',
    orderItems: [
      'The',
      'evidence',
      'was',
      'limited;',
      'nonetheless,',
      'the',
      'claim',
      'remained',
      'convincing.'
    ],
    pairs: {
      'nonetheless': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_6',
    bigTitle: 'Noun Clauses',
    goal:
        'Complex ideas as sentence parts yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Noun Clauses konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'What the committee decided surprised everyone.',
    pattern2: 'Sık yapılan hata',
    sample2: 'What did the committee decide surprised everyone.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'What the committee decided surprised everyone.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'What did the committee decide surprised everyone.',
    right: 'What the committee decided surprised everyone.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: '_____ the committee decided surprised everyone.',
    blankAnswer: 'What',
    orderItems: [
      'What',
      'the',
      'committee',
      'decided',
      'surprised',
      'everyone.'
    ],
    pairs: {
      'What': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_7',
    bigTitle: 'Reduced Relative Clauses',
    goal:
        'Compact relative information yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Reduced Relative Clauses konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'The documents submitted yesterday require careful review.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The documents which submitted yesterday require careful review.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'The documents submitted yesterday require careful review.',
      'The documents submitted last week require careful review.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The documents which submitted yesterday require careful review.',
    right: 'The documents submitted yesterday require careful review.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'The documents _____ yesterday require careful review.',
    blankAnswer: 'submitted',
    orderItems: [
      'The',
      'documents',
      'submitted',
      'yesterday',
      'require',
      'careful',
      'review.'
    ],
    pairs: {
      'submitted': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_8',
    bigTitle: 'Nominalisation Intro',
    goal:
        'Turning actions into noun phrases yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Nominalisation Intro konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'The rapid expansion of the company changed the market.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The company expanded rapid changed the market.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'The rapid expansion of the company changed the market.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The company expanded rapid changed the market.',
    right: 'The rapid expansion of the company changed the market.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'The rapid _____ of the company changed the market.',
    blankAnswer: 'expansion',
    orderItems: [
      'The',
      'rapid',
      'expansion',
      'of',
      'the',
      'company',
      'changed',
      'the',
      'market.'
    ],
    pairs: {
      'expansion': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_9',
    bigTitle: 'Advanced Passive',
    goal:
        'Complex passive structures yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Advanced Passive konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'The proposal is believed to have been accepted.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The proposal believes to have been accepted.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'The proposal is believed to have been accepted.',
      'The proposal are believed to have been accepted.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The proposal believes to have been accepted.',
    right: 'The proposal is believed to have been accepted.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'The proposal is _____ to have been accepted.',
    blankAnswer: 'believed',
    orderItems: [
      'The',
      'proposal',
      'is',
      'believed',
      'to',
      'have',
      'been',
      'accepted.'
    ],
    pairs: {
      'believed': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_10',
    bigTitle: 'Hedging',
    goal:
        'Softening claims responsibly yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Hedging konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'The results appear to support the hypothesis.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The results prove to support the hypothesis.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'The results appear to support the hypothesis.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The results prove to support the hypothesis.',
    right: 'The results appear to support the hypothesis.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'The results _____ to support the hypothesis.',
    blankAnswer: 'appear',
    orderItems: [
      'The',
      'results',
      'appear',
      'to',
      'support',
      'the',
      'hypothesis.'
    ],
    pairs: {
      'appear': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_11',
    bigTitle: 'Advanced Conditionals',
    goal:
        'Formal unreal alternatives yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Advanced Conditionals konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'Had we known the risk, we would have changed the plan.',
    pattern2: 'Sık yapılan hata',
    sample2: 'Had we knew the risk, we would have changed the plan.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'Had we known the risk, we would have changed the plan.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Had we knew the risk, we would have changed the plan.',
    right: 'Had we known the risk, we would have changed the plan.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'Had we _____ the risk, we would have changed the plan.',
    blankAnswer: 'known',
    orderItems: [
      'Had',
      'we',
      'known',
      'the',
      'risk,',
      'we',
      'would',
      'have',
      'changed',
      'the',
      'plan.'
    ],
    pairs: {
      'known': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_12',
    bigTitle: 'Reduced Clauses',
    goal:
        'Efficient clause reduction yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Reduced Clauses konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'Having finished the report, she sent it to the manager.',
    pattern2: 'Sık yapılan hata',
    sample2: 'Having finish the report, she sent it to the manager.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'Having finished the report, she sent it to the manager.',
      'Having finished the project, she sent it to the manager.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Having finish the report, she sent it to the manager.',
    right: 'Having finished the report, she sent it to the manager.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'Having _____ the report, she sent it to the manager.',
    blankAnswer: 'finished',
    orderItems: [
      'Having',
      'finished',
      'the',
      'report,',
      'she',
      'sent',
      'it',
      'to',
      'the',
      'manager.'
    ],
    pairs: {
      'finished': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_13',
    bigTitle: 'Register Control',
    goal:
        'Choosing formal or informal wording yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Register Control konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'I would appreciate your assistance with this matter.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I want you to help me with this thing.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'I would appreciate your assistance with this matter.',
      'We would appreciate your assistance with this matter.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'I want you to help me with this thing.',
    right: 'I would appreciate your assistance with this matter.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'I would _____ your assistance with this matter.',
    blankAnswer: 'appreciate',
    orderItems: [
      'I',
      'would',
      'appreciate',
      'your',
      'assistance',
      'with',
      'this',
      'matter.'
    ],
    pairs: {
      'appreciate': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_14',
    bigTitle: 'Subjunctive / Formulaic Structures',
    goal:
        'Formal fixed patterns yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Subjunctive / Formulaic Structures konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'The manager suggested that he be given more time.',
    pattern2: 'Sık yapılan hata',
    sample2: 'The manager suggested that he is given more time.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'The manager suggested that he be given more time.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The manager suggested that he is given more time.',
    right: 'The manager suggested that he be given more time.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'The manager suggested that he _____ given more time.',
    blankAnswer: 'be',
    orderItems: [
      'The',
      'manager',
      'suggested',
      'that',
      'he',
      'be',
      'given',
      'more',
      'time.'
    ],
    pairs: {
      'be': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
  _C1LessonSpec(
    id: 'c1_15',
    bigTitle: 'Ellipsis / Substitution Intro',
    goal:
        'Avoiding unnecessary repetition yapısını kontrollü, doğal ve formal cümlelerde kullan.',
    intro:
        'Ellipsis / Substitution Intro konusu, ileri düzey cümlelerde vurgu, resmiyet ve anlam kontrolü sağlar. Yapıyı sadece tanımak değil, doğru bağlamda kullanmak hedeflenir.',
    pattern1: 'Ana yapı',
    sample1: 'I enjoyed the lecture, and so did my colleague.',
    pattern2: 'Sık yapılan hata',
    sample2: 'I enjoyed the lecture, and so my colleague did.',
    pattern3: 'Kullanım odağı',
    sample3: 'Bu yapı cümlede vurgu ve anlam ilişkisini değiştirir.',
    examples: [
      'I enjoyed the lecture, and so did my colleague.',
      'We enjoyed the lecture, and so did our colleague.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'I enjoyed the lecture, and so my colleague did.',
    right: 'I enjoyed the lecture, and so did my colleague.',
    reason:
        'Doğru seçenek hedef C1 yapısını doğru kelime sırasıyla kurar; form ve kullanım açısından doğaldır.',
    blankSentence: 'I enjoyed the lecture, and so _____ my colleague.',
    blankAnswer: 'did',
    orderItems: [
      'I',
      'enjoyed',
      'the',
      'lecture,',
      'and',
      'so',
      'did',
      'my',
      'colleague.'
    ],
    pairs: {
      'did': 'target C1 form',
      'formal control': 'precise written style',
      'word order': 'meaning and emphasis'
    },
  ),
];

GrammarLesson? c1LessonForTopic(GrammarTopic topic) {
  final spec = _c1SpecFor(topic.id);
  if (spec == null) return null;

  return GrammarLesson(
    bigTitle: spec.bigTitle,
    oneLineGoal: _c1GoalFor(spec),
    timeLabel: '8 dk',
    teacherIntro: _c1IntroFor(spec),
    formulaRows: _c1FormulaRowsFor(spec),
    usageBullets: const [
      'Check form, emphasis and register together before you use the structure.',
      'Use the structure only when it improves precision, emphasis or tone.',
      'Reuse the structure in writing, presentations and careful discussion.',
      'Try making the sentence more precise, concise or tactful.',
    ],
    examples: _c1ExamplesFor(spec),
    wrong: spec.wrong,
    right: spec.right,
    reason: _c1ReasonFor(spec),
    task:
        'Write five C1 sentences: two polished written examples, one spoken example, one transformation, and one contrast pair.',
    modelAnswer: spec.right,
    quiz: _c1QuizPack(spec),
  );
}

List<GrammarFormulaRow> _c1FormulaRowsFor(_C1LessonSpec spec) {
  final pattern = switch (spec.id) {
    'c1_1' => 'fronted place/direction + verb + subject',
    'c1_2' => 'What/It + focused clause + be + focus',
    'c1_3' => 'subject + do/does/did + V1',
    'c1_4' => 'modal + have + V3 / ought to have + V3',
    'c1_5' => 'linker + clause with precise logical relation',
    'c1_6' => 'what/whether/how/that + clause as noun phrase',
    'c1_7' => 'noun + V3/V-ing phrase',
    'c1_8' => 'noun phrase built from verb/adjective idea',
    'c1_9' => 'passive reporting + perfect/continuous passive forms',
    'c1_10' => 'appear/seem/tend/be likely to + V1',
    'c1_11' => 'Had/Were/Should + subject + verb',
    'c1_12' => 'Having + V3 / V-ing / V3 phrase + main clause',
    'c1_13' => 'register-appropriate modal phrase + precise noun phrase',
    'c1_14' => 'suggest/insist/recommend that + subject + V1',
    'c1_15' => 'so/neither/nor + auxiliary + subject',
    _ => spec.pattern1,
  };
  return [
    GrammarFormulaRow(
        label: 'Structure', pattern: pattern, sample: spec.sample1),
    GrammarFormulaRow(
        label: 'Form note', pattern: 'Check', sample: _c1FormNoteFor(spec)),
    GrammarFormulaRow(
        label: 'Usage focus', pattern: 'Use', sample: _c1UsageFocusFor(spec)),
  ];
}

String _c1FormNoteFor(_C1LessonSpec spec) {
  return switch (spec.id) {
    'c1_1' =>
      'Use full inversion mainly after a fronted place or direction phrase.',
    'c1_2' => 'Keep one clear focus after what or it.',
    'c1_3' => 'Use do, does or did before the base verb.',
    'c1_4' => 'Keep the modal chain complete before the past participle.',
    'c1_5' => 'Choose the linker by logic: contrast, result or addition.',
    'c1_6' => 'Use statement word order inside noun clauses.',
    'c1_7' => 'Use V3 for passive reduced relatives and V-ing for active ones.',
    'c1_8' => 'Build the noun phrase around a clear head noun.',
    'c1_9' => 'Keep the passive reporting structure complete and readable.',
    'c1_10' => 'Use cautious verbs and phrases to match the evidence.',
    'c1_11' => 'Inverted conditionals omit if but keep conditional meaning.',
    'c1_12' => 'The reduced clause must connect logically to the main subject.',
    'c1_13' => 'Match directness to relationship, audience and purpose.',
    'c1_14' => 'Use the base verb in formal mandative that-clauses.',
    'c1_15' =>
      'Use auxiliary substitution when the repeated verb phrase is clear.',
    _ => spec.sample1,
  };
}

String _c1GoalFor(_C1LessonSpec spec) {
  return switch (spec.id) {
    'c1_1' =>
      'Use full inversion to create polished emphasis after fronted place or direction phrases.',
    'c1_2' =>
      'Use cleft sentences to guide attention to the exact point that matters.',
    'c1_3' =>
      'Use emphatic do to correct, insist or reassure without changing the main verb.',
    'c1_4' =>
      'Express nuanced certainty, criticism, expectation and missed obligation.',
    'c1_5' =>
      'Connect complex ideas with linkers that match contrast, result and reinforcement.',
    'c1_6' =>
      'Turn full ideas into subjects, objects or complements with noun clauses.',
    'c1_7' =>
      'Reduce relative clauses when the noun and verb relationship is clear.',
    'c1_8' =>
      'Use nominalisation to make writing more concise, abstract and idea-focused.',
    'c1_9' =>
      'Use advanced passive structures when process, responsibility or reported result is central.',
    'c1_10' =>
      'Hedge claims so they sound precise, balanced and appropriately cautious.',
    'c1_11' =>
      'Use advanced conditionals to express unreal alternatives with polished emphasis.',
    'c1_12' =>
      'Reduce clauses to build compact sentences without losing the subject relationship.',
    'c1_13' =>
      'Control register by choosing grammar and wording that fit the situation.',
    'c1_14' =>
      'Use subjunctive and formulaic structures after recommendations, demands and requirements.',
    'c1_15' =>
      'Use ellipsis and substitution to avoid repetition while keeping meaning clear.',
    _ => 'Use this C1 grammar point precisely in advanced communication.',
  };
}

String _c1IntroFor(_C1LessonSpec spec) {
  return switch (spec.id) {
    'c1_1' =>
      'Full inversion is not everyday word order. It works best in polished description or careful writing when a fronted place phrase sets the scene.',
    'c1_2' =>
      'Cleft sentences separate the focus from the rest of the message. They are useful when you need to correct, clarify or highlight one exact point.',
    'c1_3' =>
      'Emphatic do adds insistence to a positive sentence. It often responds to doubt, contrast or correction.',
    'c1_4' =>
      'Advanced modality lets you be precise about certainty, expectation, regret and criticism. The auxiliary pattern carries much of the meaning.',
    'c1_5' =>
      'Advanced linkers are not interchangeable. Choose the linker that matches the logic between your ideas.',
    'c1_6' =>
      'Noun clauses let a whole idea act like a noun. This is useful for complex subjects, objects and complements.',
    'c1_7' =>
      'Reduced relative clauses make writing more concise, but only when the relationship to the noun is clear.',
    'c1_8' =>
      'Nominalisation shifts focus from people doing actions to ideas, processes or results.',
    'c1_9' =>
      'Advanced passive forms combine passive voice with reporting, perfect forms and responsibility management.',
    'c1_10' =>
      'Hedging helps you avoid overclaiming. It is useful in professional discussion, analysis and tactful disagreement.',
    'c1_11' =>
      'Advanced conditionals can remove if or mix time references. The result is concise and often more polished.',
    'c1_12' =>
      'Reduced clauses compress information. The key is keeping the subject connection logical.',
    'c1_13' =>
      'Register control means choosing a level of directness and formality that fits the relationship and context.',
    'c1_14' =>
      'The mandative subjunctive keeps the base verb after certain formal verbs and adjectives, especially in recommendations and requirements.',
    'c1_15' =>
      'Ellipsis and substitution prevent repetition. They make writing and speaking smoother when the missing words are obvious.',
    _ =>
      'Study the model, compare it with the common mistake, and use the structure in a high-level context.',
  };
}

String _c1UsageFocusFor(_C1LessonSpec spec) {
  return switch (spec.id) {
    'c1_1' => 'Use it sparingly for scene-setting or emphasis.',
    'c1_2' =>
      'Use it to highlight the exact subject, object, reason or result.',
    'c1_3' => 'Use do/does/did before the base verb for insistence.',
    'c1_4' => 'Keep the modal pattern complete: modal + have + V3.',
    'c1_5' => 'Match the linker to the logic, not just the tone.',
    'c1_6' => 'Use statement word order inside the noun clause.',
    'c1_7' => 'Use V3 for passive meaning and V-ing for active meaning.',
    'c1_8' => 'Use noun phrases to focus on concepts and results.',
    'c1_9' => 'Keep the passive chain complete and readable.',
    'c1_10' => 'Use cautious verbs to avoid claiming too much.',
    'c1_11' =>
      'Use inverted conditionals in polished written or formal speech.',
    'c1_12' =>
      'Check that the reduced clause has the same subject as the main clause.',
    'c1_13' => 'Choose directness, politeness and precision deliberately.',
    'c1_14' => 'Use the base verb after that in mandative patterns.',
    'c1_15' => 'Use auxiliaries to replace repeated verb phrases.',
    _ => spec.sample3,
  };
}

String _c1ReasonFor(_C1LessonSpec spec) {
  return switch (spec.id) {
    'c1_1' =>
      'After a fronted place phrase, full inversion puts the verb before the noun subject for a polished descriptive effect.',
    'c1_2' =>
      'A cleft sentence already contains the focus structure, so do not add an extra subject like it.',
    'c1_3' =>
      'Emphatic do comes before the base verb; it does not move inside the verb phrase.',
    'c1_4' =>
      'Ought to have + V3 expresses a missed obligation or criticism about the past.',
    'c1_5' =>
      'Nonetheless signals contrast; moreover would add information and would change the logic.',
    'c1_6' =>
      'A noun clause uses statement word order, not direct-question word order.',
    'c1_7' =>
      'Submitted is a reduced passive relative clause meaning which were submitted.',
    'c1_8' =>
      'Nominalisation turns the action expanded into the noun phrase expansion.',
    'c1_9' =>
      'The proposal cannot believe something; the passive reporting structure is is believed to have been accepted.',
    'c1_10' =>
      'Appear to support is a cautious claim; prove to support overstates the evidence.',
    'c1_11' => 'In inverted conditionals, Had we known means If we had known.',
    'c1_12' =>
      'Having finished uses having + V3 to show an earlier completed action.',
    'c1_13' =>
      'Would appreciate is more tactful and situation-appropriate than a blunt demand.',
    'c1_14' =>
      'After suggested that in this formal pattern, use the base verb be.',
    'c1_15' =>
      'So did my colleague substitutes for my colleague enjoyed the lecture too.',
    _ => 'The correct option keeps the target C1 structure and meaning intact.',
  };
}

List<String> _c1ExamplesFor(_C1LessonSpec spec) {
  final examples = switch (spec.id) {
    'c1_1' => const [
        'On the wall hung a large old photograph.',
        'At the end of the corridor stood a security guard.',
        'Beyond the village lay a narrow path to the coast.',
        'On the desk sat a folder marked confidential.',
        'In front of the building gathered a small crowd.',
        'Down the hill rolled a line of empty carts.',
      ],
    'c1_2' => const [
        'What surprised me was the final result.',
        'What matters most is whether the policy can be implemented fairly.',
        'It was the timing that caused the problem.',
        'What the team needs is clearer feedback.',
        'It was not the cost that worried us, but the delay.',
        'What I find difficult is explaining the decision tactfully.',
      ],
    'c1_3' => const [
        'I do understand your concern.',
        'She does want to help, even if she seems hesitant.',
        'The plan did improve after the team revised it.',
        'I do appreciate how much effort this took.',
        'He does know the system better than anyone else.',
        'We did warn them about the risk.',
      ],
    'c1_4' => const [
        'You ought to have told us earlier.',
        'She may well have misunderstood the instructions.',
        'They might have been delayed by the traffic.',
        'He should not have approved the design so quickly.',
        'The issue could have been handled more carefully.',
        'You need not have printed the whole report.',
      ],
    'c1_5' => const [
        'The evidence was limited; nonetheless, the claim remained convincing.',
        'The proposal is ambitious; nevertheless, it is realistic.',
        'The budget has been reduced; therefore, the timeline must change.',
        'The process is complex. Moreover, it requires careful communication.',
        'The data is incomplete; consequently, the conclusion should be cautious.',
        'The plan is not perfect; still, it offers a practical way forward.',
      ],
    'c1_6' => const [
        'What the committee decided surprised everyone.',
        'Whether the policy will work remains unclear.',
        'I understand why the team rejected the first version.',
        'The problem is that the deadline keeps changing.',
        'How the issue was handled raised several questions.',
        'What matters now is how quickly we respond.',
      ],
    'c1_7' => const [
        'The documents submitted yesterday require careful review.',
        'Applicants invited to the interview will receive an email.',
        'The people waiting outside looked frustrated.',
        'The proposal discussed at the meeting was approved.',
        'Anyone interested in the role should contact HR.',
        'The data collected last month supports the decision.',
      ],
    'c1_8' => const [
        'The rapid expansion of the company changed the market.',
        'Energy consumption has increased significantly.',
        'The rejection of the proposal surprised the team.',
        'A careful review of the evidence is necessary.',
        'The introduction of remote work changed office routines.',
        'Improved communication reduced the number of mistakes.',
      ],
    'c1_9' => const [
        'The proposal is believed to have been accepted.',
        'The issue appears to have been overlooked during planning.',
        'The decision is expected to be announced next week.',
        'Several errors are thought to have been made during testing.',
        'The contract is understood to have been signed yesterday.',
        'The system should have been updated before launch.',
      ],
    'c1_10' => const [
        'The results appear to support the hypothesis.',
        'The plan appears to be risky.',
        'This may suggest a change in customer behaviour.',
        'The evidence seems to point in a different direction.',
        'There is some indication that the policy is working.',
        'The figures tend to support a more cautious conclusion.',
      ],
    'c1_11' => const [
        'Had we known the risk, we would have changed the plan.',
        'Had the team consulted users earlier, the design would have been clearer.',
        'Were the deadline extended, we could improve the final section.',
        'Should you need further information, please contact me.',
        'Had I been informed sooner, I could have helped.',
        'Were the system simpler, fewer users would need support.',
      ],
    'c1_12' => const [
        'Having finished the report, she sent it to the manager.',
        'Written in clear language, the proposal was easy to follow.',
        'Not knowing the full context, I avoided making a decision.',
        'Having reviewed the data, we changed our recommendation.',
        'Located near the station, the office is easy to reach.',
        'Asked about the delay, the director gave a brief explanation.',
      ],
    'c1_13' => const [
        'I would appreciate your assistance with this matter.',
        'Could you clarify the final point when you have a moment?',
        'The proposal may require further discussion.',
        'I am afraid we may need to revise the timeline.',
        'It would be helpful to receive the documents by Friday.',
        'We need to address this issue without assigning blame.',
      ],
    'c1_14' => const [
        'The manager suggested that he be given more time.',
        'It is essential that every applicant submit the form on time.',
        'The committee recommended that the policy be reviewed.',
        'I insisted that the figures be checked again.',
        'It is important that she be informed immediately.',
        'They requested that the meeting be postponed.',
      ],
    'c1_15' => const [
        'I enjoyed the lecture, and so did my colleague.',
        'She has not approved the plan, nor have I.',
        'The first proposal was rejected, as was the second.',
        'I can attend the morning session, but not the afternoon one.',
        'If you need a copy, I can send you one.',
        'The team expected delays, and so did the client.',
      ],
    _ => _c1CleanExamples(spec),
  };
  return examples;
}

_C1LessonSpec? _c1SpecFor(String id) {
  for (final spec in _c1Specs) {
    if (spec.id == id) return spec;
  }
  return null;
}

List<String> _c1CleanExamples(_C1LessonSpec spec) {
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
  for (final v in _c1ExampleVariants(base)) {
    if (cleaned.length >= 6) break;
    add(v);
  }

  return cleaned.take(6).toList();
}

List<String> _c1ExampleVariants(String sentence) {
  final s = sentence.trim();
  if (s.isEmpty) return const [];

  final variants = <String>[];
  final lower = s.toLowerCase();

  if (lower.startsWith('rarely ')) {
    variants.add(
        s.replaceFirst(RegExp(r'^Rarely\\b', caseSensitive: false), 'Never'));
    variants.add(s.replaceFirst(
        RegExp(r'^Rarely\\b', caseSensitive: false), 'Only then'));
  }

  variants.add(s.replaceFirst(RegExp(r'\\bI\\b'), 'we'));
  variants.add(s.replaceFirst(RegExp(r'\\bI\\b'), 'she'));

  return variants
      .where((v) => v.trim().isNotEmpty && v.trim().toLowerCase() != lower)
      .toList();
}

List<GrammarQuizQuestion> _c1QuizPack(_C1LessonSpec spec) {
  final reason = _c1ReasonFor(spec);

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
      explanation: reason,
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
      explanation: reason,
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
  if (lower == 'hung') return 'hang';
  if (lower == 'stood') return 'stand';
  if (lower == 'was') return 'is';
  if (lower == 'do') return 'does';
  if (lower == 'have') return 'has';
  if (lower == 'nonetheless') return 'moreover';
  if (lower == 'what') return 'What did';
  if (lower == 'submitted') return 'submitting';
  if (lower == 'expansion') return 'expanded';
  if (lower == 'believed') return 'believes';
  if (lower == 'appear') return 'prove';
  if (lower == 'known') return 'knew';
  if (lower == 'finished') return 'finish';
  if (lower == 'appreciate') return 'want';
  if (lower == 'be') return 'is';
  if (lower == 'did') return 'does';
  return '${answer}s';
}

String _thirdBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'hung') return 'hanging';
  if (lower == 'stood') return 'standing';
  if (lower == 'was') return 'were';
  if (lower == 'do') return 'did';
  if (lower == 'have') return 'having';
  if (lower == 'nonetheless') return 'therefore';
  if (lower == 'what') return 'That';
  if (lower == 'submitted') return 'submit';
  if (lower == 'expansion') return 'expand';
  if (lower == 'believed') return 'believing';
  if (lower == 'appear') return 'appears';
  if (lower == 'known') return 'knowing';
  if (lower == 'finished') return 'finishing';
  if (lower == 'appreciate') return 'appreciated';
  if (lower == 'be') return 'being';
  if (lower == 'did') return 'done';
  return 'not';
}

String _fourthBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'hung') return 'hangs';
  if (lower == 'stood') return 'stands';
  if (lower == 'was') return 'be';
  if (lower == 'do') return 'done';
  if (lower == 'have') return 'had';
  if (lower == 'nonetheless') return 'also';
  if (lower == 'what') return 'Which';
  if (lower == 'submitted') return 'submits';
  if (lower == 'expansion') return 'expanding';
  if (lower == 'believed') return 'believe';
  if (lower == 'appear') return 'appeared';
  if (lower == 'known') return 'know';
  if (lower == 'finished') return 'finishes';
  if (lower == 'appreciate') return 'appreciating';
  if (lower == 'be') return 'been';
  if (lower == 'did') return 'do';
  return 'to';
}
