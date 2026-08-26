import 'package:flutter/material.dart';

import 'package:speakery/data/grammar/grammar_models.dart';

// PHASE224_C2_AUDIT_LOCK
// Speakery C2 grammar baseline: audit-ready content, clean examples,
// mixed quiz types, and route-compatible lesson builders.

const List<GrammarTopic> grammarC2Topics = [
  GrammarTopic(
      id: 'c2_1',
      level: 'C2',
      title: 'Advanced Nominalisation',
      subtitle: 'dense precise noun phrases',
      icon: Icons.article_rounded,
      rule:
          'Use advanced nominalisation to package actions and processes as precise noun phrases.',
      example: 'The rapid development of the service surprised investors.',
      trap: 'The service developed rapid surprised investors.'),
  GrammarTopic(
      id: 'c2_2',
      level: 'C2',
      title: 'Fronting / Information Structure',
      subtitle: 'marked word order for emphasis',
      icon: Icons.low_priority_rounded,
      rule:
          'Use fronting to control information flow and place emphasis where the reader needs it.',
      example: 'This problem we cannot ignore.',
      trap: 'This problem cannot ignore we.'),
  GrammarTopic(
      id: 'c2_3',
      level: 'C2',
      title: 'Ellipsis and Substitution',
      subtitle: 'compressed reference and cohesion',
      icon: Icons.repeat_rounded,
      rule:
          'Use ellipsis and substitution to avoid repetition while keeping the message precise.',
      example: 'The company reduced prices and will continue to do so.',
      trap: 'The company reduced prices and will continue to do it.'),
  GrammarTopic(
      id: 'c2_4',
      level: 'C2',
      title: 'Advanced Hedging',
      subtitle: 'caution and probability',
      icon: Icons.tune_rounded,
      rule:
          'Use advanced hedging to make claims careful, credible, and proportionate to the evidence.',
      example: 'It appears that the policy has reduced costs.',
      trap: 'The policy definitely reduced costs.'),
  GrammarTopic(
      id: 'c2_5',
      level: 'C2',
      title: 'Register Shifts',
      subtitle: 'moving between formal and neutral tone',
      icon: Icons.record_voice_over_rounded,
      rule:
          'Use register shifts to adapt grammar and wording to audience, purpose, and formality.',
      example: 'I would be grateful if you could send the documents.',
      trap: 'Send me the documents.'),
  GrammarTopic(
      id: 'c2_6',
      level: 'C2',
      title: 'Dense Noun Phrases',
      subtitle: 'compact precise information',
      icon: Icons.view_agenda_rounded,
      rule:
          'Use dense noun phrases to express complex information compactly and accurately.',
      example: 'The long-term economic impact remains unclear.',
      trap: 'The impact economic long-term remains unclear.'),
  GrammarTopic(
      id: 'c2_7',
      level: 'C2',
      title: 'Complex Subordination',
      subtitle: 'precise relationships between ideas',
      icon: Icons.account_tree_rounded,
      rule:
          'Use complex subordination to connect contrast, reason, limitation, and explanation without overloading the sentence.',
      example: 'Although the sample was small, the findings were useful.',
      trap: 'Although the sample was small, but the findings were useful.'),
  GrammarTopic(
      id: 'c2_8',
      level: 'C2',
      title: 'Advanced Concession',
      subtitle: 'formal contrast and concession',
      icon: Icons.compare_arrows_rounded,
      rule:
          'Use advanced concession to acknowledge a point while moving the argument forward.',
      example: 'Be that as it may, the decision must be reviewed.',
      trap: 'Be that it may, the decision must be reviewed.'),
  GrammarTopic(
      id: 'c2_9',
      level: 'C2',
      title: 'Advanced Emphasis',
      subtitle: 'sharp focus and contrast',
      icon: Icons.center_focus_strong_rounded,
      rule:
          'Use advanced emphasis to control what the reader notices first and why it matters.',
      example: 'What matters is whether the solution is sustainable.',
      trap: 'What matters are whether the solution is sustainable.'),
  GrammarTopic(
      id: 'c2_10',
      level: 'C2',
      title: 'Stylistic Inversion',
      subtitle: 'formal and literary emphasis',
      icon: Icons.swap_vert_circle_rounded,
      rule:
          'Use stylistic inversion to create formal emphasis after fronted negative or limiting expressions.',
      example: 'Rarely have I seen such careful analysis.',
      trap: 'Rarely I have seen such careful analysis.'),
  GrammarTopic(
      id: 'c2_11',
      level: 'C2',
      title: 'Precision with Modality',
      subtitle: 'nuanced probability and caution',
      icon: Icons.psychology_alt_rounded,
      rule:
          'Use precise modality to show probability, caution, and responsibility without sounding absolute.',
      example: 'This approach may well reduce long-term costs.',
      trap: 'This approach may to reduce long-term costs.'),
  GrammarTopic(
      id: 'c2_12',
      level: 'C2',
      title: 'Discourse Flow',
      subtitle: 'linking ideas across sentences',
      icon: Icons.alt_route_rounded,
      rule:
          'Use discourse flow devices to guide the reader through contrast, consequence, and synthesis.',
      example: 'The evidence is limited. That said, the trend is clear.',
      trap: 'The evidence is limited. Therefore, the trend is limited.'),
  GrammarTopic(
      id: 'c2_13',
      level: 'C2',
      title: 'Advanced Conditionals',
      subtitle: 'formal conditional alternatives',
      icon: Icons.call_split_rounded,
      rule:
          'Use advanced conditionals to express formal alternatives, hypothetical limits, and precise consequences.',
      example: 'Were it not for your help, we would have failed.',
      trap: 'Were it not for your help, we will have failed.'),
];

class _C2LessonSpec {
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

  const _C2LessonSpec({
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

const List<_C2LessonSpec> _c2Specs = [
  _C2LessonSpec(
    id: 'c2_1',
    bigTitle: 'Academic Nominalisation',
    goal:
        'Dense academic noun phrases yapısını kontrollü, doğal ve akademik cümlelerde kullan.',
    intro:
        'Academic Nominalisation konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Ana yapı',
    sample1: 'The rapid development of the service surprised investors.',
    pattern2: 'Common trap',
    sample2: 'The service developed rapid surprised investors.',
    pattern3: 'Academic focus',
    sample3: 'The implementation of the policy reduced costs.',
    examples: [
      'The rapid development of the service surprised investors.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The service developed rapid surprised investors.',
    right: 'The rapid development of the service surprised investors.',
    reason:
        'The correct version uses a controlled noun phrase instead of a loose verb-based structure.',
    blankSentence: 'The rapid _____ of the service surprised investors.',
    blankAnswer: 'development',
    orderItems: [
      'The',
      'rapid',
      'development',
      'of',
      'the',
      'service',
      'surprised',
      'investors.'
    ],
    pairs: {
      'development': 'nominalised process',
      'of the service': 'noun phrase expansion',
      'academic style': 'compressed information'
    },
  ),
  _C2LessonSpec(
    id: 'c2_2',
    bigTitle: 'Fronting / Information Structure',
    goal: 'Marked word order ile vurguyu ve bilgi akışını bilinçli yönet.',
    intro:
        'Fronting / Information Structure konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Object fronting',
    sample1: 'This problem we cannot ignore.',
    pattern2: 'Common trap',
    sample2: 'This problem cannot ignore we.',
    pattern3: 'Focused opening',
    sample3: 'What matters most is how clearly we explain the result.',
    examples: [
      'This problem we cannot ignore.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'This problem cannot ignore we.',
    right: 'This problem we cannot ignore.',
    reason:
        'The object can be fronted for emphasis, but the subject and verb order inside the clause must remain correct.',
    blankSentence: 'This problem we cannot _____.',
    blankAnswer: 'ignore',
    orderItems: ['This', 'problem', 'we', 'cannot', 'ignore.'],
    pairs: {
      'fronted object': 'emphasis',
      'we cannot ignore': 'correct clause grammar',
      'information flow': 'reader focus'
    },
  ),
  _C2LessonSpec(
    id: 'c2_3',
    bigTitle: 'Ellipsis and Substitution',
    goal: 'Repetition azaltarak cohesion ve precision oluştur.',
    intro:
        'Ellipsis and Substitution konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Do so',
    sample1: 'The company reduced prices and will continue to do so.',
    pattern2: 'Common trap',
    sample2: 'The company reduced prices and will continue to do it.',
    pattern3: 'Auxiliary ellipsis',
    sample3: 'Some students passed the exam, but others did not.',
    examples: [
      'The company reduced prices and will continue to do so.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The company reduced prices and will continue to do it.',
    right: 'The company reduced prices and will continue to do so.',
    reason:
        'Do so replaces a repeated action more formally and more precisely than do it in this context.',
    blankSentence: 'The company reduced prices and will continue to _____ so.',
    blankAnswer: 'do',
    orderItems: [
      'The',
      'company',
      'reduced',
      'prices',
      'and',
      'will',
      'continue',
      'to',
      'do',
      'so.'
    ],
    pairs: {
      'do so': 'action substitution',
      'did not': 'auxiliary ellipsis',
      'cohesion': 'less repetition'
    },
  ),
  _C2LessonSpec(
    id: 'c2_4',
    bigTitle: 'Advanced Hedging',
    goal: 'Claims daha cautious, credible ve akademik hale getir.',
    intro:
        'Advanced Hedging konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'It appears that',
    sample1: 'It appears that the policy has reduced costs.',
    pattern2: 'Common trap',
    sample2: 'The policy definitely reduced costs.',
    pattern3: 'Tends to',
    sample3: 'Online feedback tends to improve learner motivation.',
    examples: [
      'This trend may well continue next year.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'This trend may to continue next year.',
    right: 'This trend may well continue next year.',
    reason:
        'May well expresses strong but cautious possibility without adding to before the main verb.',
    blankSentence: 'This trend may _____ continue next year.',
    blankAnswer: 'well',
    orderItems: ['This', 'trend', 'may', 'well', 'continue', 'next', 'year.'],
    pairs: {
      'may well': 'cautious probability',
      'tends to': 'careful generalisation',
      'appears that': 'softened claim'
    },
  ),
  _C2LessonSpec(
    id: 'c2_5',
    bigTitle: 'Register Shifts',
    goal: 'Formal, neutral ve spoken style arasında kontrollü geçiş yap.',
    intro:
        'Register Shifts konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Formal request',
    sample1: 'I would be grateful if you could send the documents.',
    pattern2: 'Common trap',
    sample2: 'Send me the documents.',
    pattern3: 'Neutral alternative',
    sample3: 'Could you send the documents when possible?',
    examples: [
      'I would be grateful if you could send the documents.',
      'We would be grateful if you could send the documents.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Send me the documents.',
    right: 'I would be grateful if you could send the documents.',
    reason:
        'The correct version uses indirect grammar to create a formal and respectful register.',
    blankSentence: 'I would be _____ if you could send the documents.',
    blankAnswer: 'grateful',
    orderItems: [
      'I',
      'would',
      'be',
      'grateful',
      'if',
      'you',
      'could',
      'send',
      'the',
      'documents.'
    ],
    pairs: {
      'would be grateful': 'formal request',
      'could you': 'polite neutral request',
      'register': 'tone control'
    },
  ),
  _C2LessonSpec(
    id: 'c2_6',
    bigTitle: 'Dense Noun Phrases',
    goal: 'Complex information tek bir kontrollü noun phrase içinde paketle.',
    intro:
        'Dense Noun Phrases konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Pre-modified noun phrase',
    sample1: 'The long-term economic impact remains unclear.',
    pattern2: 'Common trap',
    sample2: 'The impact economic long-term remains unclear.',
    pattern3: 'Expanded noun phrase',
    sample3: 'A gradual decline in learner motivation was observed.',
    examples: [
      'The long-term economic impact remains unclear.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'The impact economic long-term remains unclear.',
    right: 'The long-term economic impact remains unclear.',
    reason:
        'Dense noun phrases need a controlled modifier order before the head noun.',
    blankSentence: 'The long-term economic _____ remains unclear.',
    blankAnswer: 'impact',
    orderItems: [
      'The',
      'long-term',
      'economic',
      'impact',
      'remains',
      'unclear.'
    ],
    pairs: {
      'long-term': 'time modifier',
      'economic': 'topic modifier',
      'impact': 'head noun'
    },
  ),
  _C2LessonSpec(
    id: 'c2_7',
    bigTitle: 'Complex Subordination',
    goal: 'Fikir ilişkilerini çift bağlaç yapmadan net kur.',
    intro:
        'Complex Subordination konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Although + clause',
    sample1: 'Although the sample was small, the findings were useful.',
    pattern2: 'Common trap',
    sample2: 'Although the sample was small, but the findings were useful.',
    pattern3: 'In that + clause',
    sample3: 'The method is useful in that it encourages reflection.',
    examples: [
      'Although the sample was small, the findings were useful.',
      'Although the sample were small, the findings were useful.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Although the sample was small, but the findings were useful.',
    right: 'Although the sample was small, the findings were useful.',
    reason:
        'Although already marks contrast, so adding but creates a double connector error.',
    blankSentence: 'Although the sample was small, the findings _____ useful.',
    blankAnswer: 'were',
    orderItems: [
      'Although',
      'the',
      'sample',
      'was',
      'small,',
      'the',
      'findings',
      'were',
      'useful.'
    ],
    pairs: {
      'although': 'contrast',
      'whereas': 'comparison',
      'in that': 'specific explanation'
    },
  ),
  _C2LessonSpec(
    id: 'c2_8',
    bigTitle: 'Advanced Concession',
    goal: 'Formal concession ile argümanı daha güçlü ilerlet.',
    intro:
        'Advanced Concession konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Be that as it may',
    sample1: 'Be that as it may, the decision must be reviewed.',
    pattern2: 'Common trap',
    sample2: 'Be that it may, the decision must be reviewed.',
    pattern3: 'For all its flaws',
    sample3: 'For all its flaws, the system remains effective.',
    examples: [
      'Be that as it may, the decision must be reviewed.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Be that it may, the decision must be reviewed.',
    right: 'Be that as it may, the decision must be reviewed.',
    reason: 'Be that as it may is a fixed formal concession phrase.',
    blankSentence: 'Be that _____ it may, the decision must be reviewed.',
    blankAnswer: 'as',
    orderItems: [
      'Be',
      'that',
      'as',
      'it',
      'may,',
      'the',
      'decision',
      'must',
      'be',
      'reviewed.'
    ],
    pairs: {
      'be that as it may': 'formal concession',
      'admittedly': 'concede a point',
      'nevertheless': 'contrast continuation'
    },
  ),
  _C2LessonSpec(
    id: 'c2_9',
    bigTitle: 'Advanced Emphasis',
    goal:
        'Focus ve contrast yapısını okuyucunun dikkatini yönetmek için kullan.',
    intro:
        'Advanced Emphasis konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'What matters is',
    sample1: 'What matters is whether the solution is sustainable.',
    pattern2: 'Common trap',
    sample2: 'What matters are whether the solution is sustainable.',
    pattern3: 'Not X but Y',
    sample3: 'It is not speed but accuracy that matters most.',
    examples: [
      'What matters is whether the solution is sustainable.',
      'What matters are whether the solution are sustainable.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'What matters are whether the solution is sustainable.',
    right: 'What matters is whether the solution is sustainable.',
    reason: 'The focused clause takes singular agreement in this structure.',
    blankSentence: 'What matters _____ whether the solution is sustainable.',
    blankAnswer: 'is',
    orderItems: [
      'What',
      'matters',
      'is',
      'whether',
      'the',
      'solution',
      'is',
      'sustainable.'
    ],
    pairs: {
      'what matters is': 'focus structure',
      'not X but Y': 'contrast emphasis',
      'very reason': 'strong noun focus'
    },
  ),
  _C2LessonSpec(
    id: 'c2_10',
    bigTitle: 'Stylistic Inversion',
    goal: 'Formal veya literary emphasis için inversion kullan.',
    intro:
        'Stylistic Inversion konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Rarely + auxiliary',
    sample1: 'Rarely have I seen such careful analysis.',
    pattern2: 'Common trap',
    sample2: 'Rarely I have seen such careful analysis.',
    pattern3: 'Only after',
    sample3: 'Only after reviewing the data did we change our view.',
    examples: [
      'Rarely have I seen such careful analysis.',
      'Rarely have We seen such careful analysis.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Rarely I have seen such careful analysis.',
    right: 'Rarely have I seen such careful analysis.',
    reason: 'A fronted negative adverbial triggers auxiliary inversion.',
    blankSentence: 'Rarely _____ I seen such careful analysis.',
    blankAnswer: 'have',
    orderItems: ['Rarely', 'have', 'I', 'seen', 'such', 'careful', 'analysis.'],
    pairs: {
      'rarely have I': 'negative adverbial inversion',
      'only after did': 'limiting phrase inversion',
      'little did': 'stylistic emphasis'
    },
  ),
  _C2LessonSpec(
    id: 'c2_11',
    bigTitle: 'Precision with Modality',
    goal: 'Probability ve caution derecesini net ayarla.',
    intro:
        'Precision with Modality konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'May well',
    sample1: 'This approach may well reduce long-term costs.',
    pattern2: 'Common trap',
    sample2: 'This approach may to reduce long-term costs.',
    pattern3: 'Likely to',
    sample3: 'The change is likely to affect smaller schools.',
    examples: [
      'This approach may well reduce long-term costs.',
      'The findings might indicate a broader shift.',
      'The policy is likely to affect smaller firms.',
      'A temporary decline cannot be ruled out.',
      'The revised model should prove more reliable.',
      'The change could conceivably create new risks.',
    ],
    wrong: 'This approach may to reduce long-term costs.',
    right: 'This approach may well reduce long-term costs.',
    reason:
        'May is followed by the base verb, and well adds cautious strength to the possibility.',
    blankSentence: 'This approach may _____ reduce long-term costs.',
    blankAnswer: 'well',
    orderItems: [
      'This',
      'approach',
      'may',
      'well',
      'reduce',
      'long-term',
      'costs.'
    ],
    pairs: {
      'may well': 'strong possibility',
      'likely to': 'probability',
      'cannot be ruled out': 'cautious passive modal'
    },
  ),
  _C2LessonSpec(
    id: 'c2_12',
    bigTitle: 'Discourse Flow',
    goal: 'Ideas arası contrast, consequence ve synthesis akışını yönet.',
    intro:
        'Discourse Flow konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'That said',
    sample1: 'The evidence is limited. That said, the trend is clear.',
    pattern2: 'Common trap',
    sample2: 'The evidence is limited. Therefore, the trend is limited.',
    pattern3: 'In turn',
    sample3:
        'Better feedback improves confidence, which in turn increases participation.',
    examples: [
      'Better feedback improves confidence, which in turn increases participation.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong:
        'Better feedback improves confidence, which in turns increases participation.',
    right:
        'Better feedback improves confidence, which in turn increases participation.',
    reason:
        'In turn is a fixed discourse phrase that shows a chain of effects.',
    blankSentence:
        'Better feedback improves confidence, which in _____ increases participation.',
    blankAnswer: 'turn',
    orderItems: [
      'Better',
      'feedback',
      'improves',
      'confidence,',
      'which',
      'in',
      'turn',
      'increases',
      'participation.'
    ],
    pairs: {
      'that said': 'contrast management',
      'in turn': 'effect chain',
      'taken together': 'synthesis'
    },
  ),
  _C2LessonSpec(
    id: 'c2_13',
    bigTitle: 'Advanced Conditionals',
    goal: 'Formal conditional alternatives ile hypothetical meaning kur.',
    intro:
        'Advanced Conditionals konusu, akademik ve çok ileri düzey anlatımda nüans, akış ve üslup kontrolü sağlar. Odak, doğal ve kontrollü ifade üretmektir.',
    pattern1: 'Were it not for',
    sample1: 'Were it not for your help, we would have failed.',
    pattern2: 'Common trap',
    sample2: 'Were it not for your help, we will have failed.',
    pattern3: 'Had it not been for',
    sample3: 'Had it not been for the delay, we would have arrived earlier.',
    examples: [
      'Were it not for your help, we would have failed.',
      'The teacher explained the answer clearly.',
      'The students completed the task before the break.',
      'We checked the details during the lesson.',
      'The manager changed the plan after the meeting.',
    ],
    wrong: 'Were it not for your help, we will have failed.',
    right: 'Were it not for your help, we would have failed.',
    reason:
        'This formal unreal conditional needs would have for the hypothetical result.',
    blankSentence: 'Were it not for your help, we _____ have failed.',
    blankAnswer: 'would',
    orderItems: [
      'Were',
      'it',
      'not',
      'for',
      'your',
      'help,',
      'we',
      'would',
      'have',
      'failed.'
    ],
    pairs: {
      'were it not for': 'formal unreal condition',
      'had it not been for': 'past unreal condition',
      'should you need': 'formal future condition'
    },
  ),
];

GrammarLesson? c2LessonForTopic(GrammarTopic topic) {
  final spec = _c2SpecFor(topic.id);
  if (spec == null) return null;

  return GrammarLesson(
    bigTitle: spec.bigTitle,
    oneLineGoal: _c2GoalFor(spec),
    timeLabel: '9 dk',
    teacherIntro: _c2IntroFor(spec),
    formulaRows: _c2FormulaRowsFor(spec),
    usageBullets: const [
      'Control form, tone, information flow and precision at the same time.',
      'Choose the structure because it improves nuance, cohesion or register.',
      'Reuse the structure in polished writing, formal speaking and nuanced discussion.',
      'Try making the sentence denser, more controlled or more carefully qualified.',
    ],
    examples: _c2ExamplesFor(spec),
    wrong: spec.wrong,
    right: spec.right,
    reason: _c2ReasonFor(spec),
    task:
        'Write five C2 sentences: two polished written examples, one formal message, one natural spoken nuance, and one transformation sentence.',
    modelAnswer: spec.right,
    quiz: _c2QuizPack(spec),
  );
}

_C2LessonSpec? _c2SpecFor(String id) {
  for (final spec in _c2Specs) {
    if (spec.id == id) return spec;
  }
  return null;
}

List<GrammarFormulaRow> _c2FormulaRowsFor(_C2LessonSpec spec) {
  final pattern = switch (spec.id) {
    'c2_1' => 'nominalised noun phrase + precise expansion',
    'c2_2' => 'fronted object/topic + subject + verb',
    'c2_3' => 'do so / auxiliary substitution / ellipsis',
    'c2_4' => 'it appears/seems that / may well / tends to',
    'c2_5' => 'indirect modal request + precise noun phrase',
    'c2_6' => 'pre-modifiers + head noun + post-modifier',
    'c2_7' => 'subordinator + clause, main clause',
    'c2_8' => 'fixed concession phrase + main point',
    'c2_9' => 'what matters/is clear/remains unclear + clause',
    'c2_10' => 'negative/limiting adverbial + auxiliary + subject',
    'c2_11' => 'modal + stance adverb + V1',
    'c2_12' => 'discourse marker + sentence-level relation',
    'c2_13' => 'inverted conditional + hypothetical result',
    _ => spec.pattern1,
  };
  return [
    GrammarFormulaRow(
        label: 'Structure', pattern: pattern, sample: spec.sample1),
    GrammarFormulaRow(
        label: 'Form note', pattern: 'Check', sample: _c2FormNoteFor(spec)),
    GrammarFormulaRow(
        label: 'Usage focus', pattern: 'Use', sample: _c2UsageFocusFor(spec)),
  ];
}

String _c2FormNoteFor(_C2LessonSpec spec) {
  return switch (spec.id) {
    'c2_1' => 'Use nominalisation only when the noun phrase stays clear.',
    'c2_2' => 'After fronting, keep the clause grammar intact.',
    'c2_3' => 'Make the substitution refer to a clear previous action or idea.',
    'c2_4' =>
      'Use cautious stance language without weakening the main point too much.',
    'c2_5' =>
      'Shift register through modal choice, indirectness and noun phrase precision.',
    'c2_6' => 'Order modifiers logically around the head noun.',
    'c2_7' => 'Use one connector to express one relationship clearly.',
    'c2_8' => 'Keep fixed concession phrases intact.',
    'c2_9' => 'Treat what-clauses as singular focus units when needed.',
    'c2_10' => 'Use auxiliary inversion after negative or limiting openings.',
    'c2_11' =>
      'Place stance adverbs naturally after the modal or around the verb phrase.',
    'c2_12' =>
      'Use discourse markers to connect whole ideas, not isolated words.',
    'c2_13' =>
      'Match formal inverted conditions with would, could or might results.',
    _ => spec.sample1,
  };
}

String _c2GoalFor(_C2LessonSpec spec) {
  return switch (spec.id) {
    'c2_1' =>
      'Use nominalisation to compress complex actions into precise, elegant noun phrases.',
    'c2_2' =>
      'Control information flow by moving the topic or contrast point to the front.',
    'c2_3' =>
      'Use ellipsis and substitution to avoid repetition while keeping cohesion clear.',
    'c2_4' =>
      'Make high-level claims sound proportionate, credible and carefully qualified.',
    'c2_5' =>
      'Shift between formal, neutral and natural spoken register with control.',
    'c2_6' =>
      'Build dense noun phrases that stay readable and logically ordered.',
    'c2_7' =>
      'Connect contrast, reason, limitation and explanation without overloading the sentence.',
    'c2_8' =>
      'Acknowledge a point elegantly while moving the argument forward.',
    'c2_9' =>
      'Use advanced emphasis to guide the listener or reader to the key issue.',
    'c2_10' =>
      'Use inversion after negative or limiting openings for controlled emphasis.',
    'c2_11' =>
      'Show nuanced probability, caution and responsibility through modality.',
    'c2_12' =>
      'Guide discourse across sentences with contrast, consequence and synthesis.',
    'c2_13' =>
      'Use formal conditional alternatives for precise hypothetical meaning.',
    _ => 'Use this C2 grammar point with expert-level precision.',
  };
}

String _c2IntroFor(_C2LessonSpec spec) {
  return switch (spec.id) {
    'c2_1' =>
      'Nominalisation turns actions into concepts. At C2, the challenge is not sounding heavier, but choosing a noun phrase that is compact and genuinely clearer.',
    'c2_2' =>
      'Fronting changes what the reader notices first. It is powerful in contrastive or corrective statements, but the clause after the fronted element must remain grammatical.',
    'c2_3' =>
      'Ellipsis and substitution create cohesion by leaving out or replacing repeated material. The replacement must refer to the whole action, not just a loose object.',
    'c2_4' =>
      'Advanced hedging is a precision tool. It lets you make strong points without claiming more than the evidence allows.',
    'c2_5' =>
      'Register shifts depend on audience, purpose and relationship. C2 control means being able to sound direct, neutral or diplomatic by choice.',
    'c2_6' =>
      'Dense noun phrases carry a lot of information before and after the head noun. Modifier order and readability matter.',
    'c2_7' =>
      'Complex subordination shows the exact relation between ideas. Avoid double connectors such as although...but.',
    'c2_8' =>
      'Advanced concession phrases acknowledge a limitation without surrendering the main point.',
    'c2_9' =>
      'Advanced emphasis structures help frame the issue: what matters, what remains unclear, what should be examined.',
    'c2_10' =>
      'Stylistic inversion is marked and emphatic. Use it deliberately after negative or limiting openings, not as ordinary word order.',
    'c2_11' =>
      'Precision with modality lets you calibrate confidence: possible, probable, hard to rule out, or strongly implied.',
    'c2_12' =>
      'Discourse flow devices connect whole sentences and paragraphs. Choose them for the logical relationship, not just for sophistication.',
    'c2_13' =>
      'Advanced conditionals can sound elegant and concise, especially when if is omitted. The hypothetical result still needs the correct modal form.',
    _ =>
      'Study the model, compare it with the common mistake, and use the structure in a near-native context.',
  };
}

String _c2UsageFocusFor(_C2LessonSpec spec) {
  return switch (spec.id) {
    'c2_1' => 'Prefer nominalisation when it improves focus, not just density.',
    'c2_2' =>
      'Keep the normal subject-verb relationship after the fronted topic.',
    'c2_3' => 'Use do so for repeated actions in polished writing.',
    'c2_4' => 'Use hedges to match claim strength to evidence.',
    'c2_5' => 'Choose formality deliberately rather than automatically.',
    'c2_6' => 'Keep modifier order logical before the head noun.',
    'c2_7' => 'Use one main connector for one logical relation.',
    'c2_8' => 'Learn fixed concession phrases as whole chunks.',
    'c2_9' => 'Use singular agreement when a clause is the focus.',
    'c2_10' => 'Invert the auxiliary after fronted negative adverbials.',
    'c2_11' => 'Do not add to after modal verbs.',
    'c2_12' => 'Make the discourse marker match the relation between ideas.',
    'c2_13' =>
      'Pair formal inverted conditions with would/could/might results.',
    _ => spec.sample3,
  };
}

String _c2ReasonFor(_C2LessonSpec spec) {
  return switch (spec.id) {
    'c2_1' =>
      'Development packages the process as a controlled noun phrase; developed rapid is not grammatical or precise.',
    'c2_2' =>
      'The object can be fronted for emphasis, but the clause still needs subject + modal + verb: we cannot ignore.',
    'c2_3' =>
      'Do so substitutes for the whole previous action and creates smoother cohesion than do it here.',
    'c2_4' =>
      'May well adds cautious strength, while modal verbs are followed by the base verb without to.',
    'c2_5' =>
      'The indirect request is appropriately formal and diplomatic; the direct command is too blunt for this register.',
    'c2_6' =>
      'The modifiers long-term and economic belong before the head noun impact in a controlled noun phrase.',
    'c2_7' =>
      'Although already marks contrast, so adding but creates a double-connector error.',
    'c2_8' =>
      'Be that as it may is a fixed concession phrase; changing the middle words breaks the expression.',
    'c2_9' =>
      'What matters is treated as a singular focus structure before the whether-clause.',
    'c2_10' =>
      'Rarely at the front triggers auxiliary inversion: rarely have I seen.',
    'c2_11' =>
      'May is followed directly by the base verb; well strengthens the possibility without becoming absolute.',
    'c2_12' =>
      'In turn is a fixed discourse phrase showing a chain of effects.',
    'c2_13' =>
      'Were it not for creates an unreal condition, so the result needs would have, not will have.',
    _ =>
      'The correct option preserves the target C2 grammar logic and register.',
  };
}

List<String> _c2ExamplesFor(_C2LessonSpec spec) {
  final examples = switch (spec.id) {
    'c2_1' => const [
        'The rapid development of the service surprised investors.',
        'The decision drew widespread criticism.',
        'Energy consumption has increased sharply.',
        'The gradual erosion of trust became difficult to ignore.',
        'A full review of the process would be premature.',
        'The rejection of the proposal raised several questions.',
      ],
    'c2_2' => const [
        'This problem we cannot ignore.',
        'That argument I find difficult to accept.',
        'The practical details we can discuss later.',
        'What remains unclear is whether the policy can be implemented without unintended consequences.',
        'The final decision, however, I would rather postpone.',
        'Such behaviour we should not normalise.',
      ],
    'c2_3' => const [
        'The company reduced prices and will continue to do so.',
        'Some supported the proposal; others did not.',
        'If the first plan fails, the second may do so as well.',
        'The report does not address the issue, nor does the summary.',
        'I asked for clarification, but no one provided any.',
        'The new policy may help; if so, it should be expanded.',
      ],
    'c2_4' => const [
        'It appears that the policy has reduced costs.',
        'This appears unlikely to be the case.',
        'The findings would seem to support a cautious conclusion.',
        'There is little evidence to suggest that the problem is temporary.',
        'The results may well reflect a broader shift in behaviour.',
        'The proposal is unlikely to resolve the issue on its own.',
      ],
    'c2_5' => const [
        'I would be grateful if you could send the documents.',
        'Could you send the documents when possible?',
        'Send me the documents when you get a chance.',
        'I was wondering whether you might be able to clarify this point.',
        'We need to revisit this decision before Friday.',
        'This wording is too direct for a first message to a client.',
      ],
    'c2_6' => const [
        'The long-term economic impact remains unclear.',
        'A gradual decline in learner motivation was observed.',
        'The post-launch user feedback review begins tomorrow.',
        'The committee raised concerns about data privacy compliance.',
        'A lack of cross-team communication slowed the project.',
        'The early-stage implementation costs were underestimated.',
      ],
    'c2_7' => const [
        'Although the sample was small, the findings were useful.',
        'Whereas the first plan was ambitious, the second was realistic.',
        'The method is useful in that it encourages reflection.',
        'While the results are promising, further testing is needed.',
        'Given that the deadline is fixed, we should reduce the scope.',
        'Unless the data is updated, the conclusion will remain tentative.',
      ],
    'c2_8' => const [
        'Be that as it may, the decision must be reviewed.',
        'For all its flaws, the system remains effective.',
        'Granted, the proposal is expensive; nevertheless, it solves a real problem.',
        'However persuasive the argument may be, it overlooks implementation costs.',
        'The report, though comprehensive, leaves several questions unanswered.',
        'Rather than being dismissed outright, the argument should be examined in context.',
      ],
    'c2_9' => const [
        'What matters is whether the solution is sustainable.',
        'What remains unclear is who will be responsible for implementation.',
        'It is the lack of follow-up that worries me most.',
        'The real issue is not cost but accountability.',
        'What the proposal fails to address is long-term maintenance.',
        'The very reason we delayed the launch was user safety.',
      ],
    'c2_10' => const [
        'Rarely have I seen such careful analysis.',
        'No sooner had the announcement been made than concerns began to emerge.',
        'At no point did the company consult users.',
        'Only after the review did the problem become clear.',
        'Not until the final meeting did they acknowledge the risk.',
        'Under no circumstances should the data be shared externally.',
      ],
    'c2_11' => const [
        'This approach may well reduce long-term costs.',
        'The change is likely to affect smaller schools.',
        'The issue cannot be ruled out entirely.',
        'The delay might conceivably have affected the outcome.',
        'The team should arguably have communicated the risk earlier.',
        'This explanation is unlikely to satisfy all stakeholders.',
      ],
    'c2_12' => const [
        'The evidence is limited. That said, the trend is clear.',
        'Better feedback improves confidence, which in turn increases participation.',
        'Taken together, the results suggest a gradual shift.',
        'The proposal is costly. Even so, rejecting it outright would be premature.',
        'The first option is faster; the second, by contrast, is more reliable.',
        'The policy was unpopular. In practical terms, however, it worked.',
      ],
    'c2_13' => const [
        'Were it not for your help, we would have failed.',
        'Had it not been for early intervention, the situation might have deteriorated further.',
        'Should you require further details, I would be happy to provide them.',
        'Were the evidence stronger, the conclusion would be more convincing.',
        'Had the warning been clearer, the mistake could have been avoided.',
        'Were this a minor issue, I would not raise it now.',
      ],
    _ => _c2CleanExamples(spec),
  };
  return examples;
}

List<String> _c2CleanExamples(_C2LessonSpec spec) {
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
  for (final v in _c2ExampleVariants(base)) {
    if (cleaned.length >= 6) break;
    add(v);
  }

  return cleaned.take(6).toList();
}

List<String> _c2ExampleVariants(String sentence) {
  final s = sentence.trim();
  if (s.isEmpty) return const [];

  final variants = <String>[];
  final lower = s.toLowerCase();

  if (lower.startsWith('it ') && lower.contains('appears')) {
    variants.add('It would appear that the results are improving.');
    variants.add('It seems that the policy has reduced costs.');
  }

  variants.add(s.replaceFirst(RegExp(r'\\bI\\b'), 'we'));
  variants.add(s.replaceFirst(RegExp(r'\\bI\\b'), 'they'));

  return variants
      .where((v) => v.trim().isNotEmpty && v.trim().toLowerCase() != lower)
      .toList();
}

List<GrammarQuizQuestion> _c2QuizPack(_C2LessonSpec spec) {
  final reason = _c2ReasonFor(spec);

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
        explanation: reason),
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
        explanation: reason),
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
  if (lower == 'development') return 'developed';
  if (lower == 'ignore') return 'ignored';
  if (lower == 'do') return 'doing';
  if (lower == 'well') return 'to';
  if (lower == 'grateful') return 'thankful';
  if (lower == 'impact') return 'impacting';
  if (lower == 'were') return 'was';
  if (lower == 'as') return 'it';
  if (lower == 'is') return 'are';
  if (lower == 'have') return 'has';
  if (lower == 'turn') return 'turns';
  if (lower == 'would') return 'will';
  return '${answer}s';
}

String _thirdBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'development') return 'developing';
  if (lower == 'ignore') return 'ignoring';
  if (lower == 'do') return 'make';
  if (lower == 'well') return 'very';
  if (lower == 'grateful') return 'great';
  if (lower == 'impact') return 'effect';
  if (lower == 'were') return 'are';
  if (lower == 'as') return 'so';
  if (lower == 'is') return 'was';
  if (lower == 'have') return 'had';
  if (lower == 'turn') return 'return';
  if (lower == 'would') return 'could';
  return 'not';
}

String _fourthBlankOption(String answer) {
  final lower = answer.toLowerCase();
  if (lower == 'development') return 'develop';
  if (lower == 'ignore') return 'ignores';
  if (lower == 'do') return 'did';
  if (lower == 'well') return 'good';
  if (lower == 'grateful') return 'gratefully';
  if (lower == 'impact') return 'impacts';
  if (lower == 'were') return 'be';
  if (lower == 'as') return 'than';
  if (lower == 'is') return 'be';
  if (lower == 'have') return 'having';
  if (lower == 'turn') return 'turned';
  if (lower == 'would') return 'should';
  return 'to';
}
