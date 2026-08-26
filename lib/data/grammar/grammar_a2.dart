import 'package:flutter/material.dart';

import 'package:speakery/data/grammar/grammar_models.dart';

const List<GrammarTopic> grammarA2Topics = [
  GrammarTopic(
    id: 'a2_past_simple',
    level: 'A2',
    title: 'Past Simple',
    subtitle: 'finished past actions',
    icon: Icons.history_rounded,
    rule:
        'Use Past Simple for finished actions with times like yesterday, last week and two days ago.',
    example: 'I watched a film yesterday. Did you call me?',
    trap: 'After did or did not, use V1: Did you go? I did not watch.',
  ),
  GrammarTopic(
    id: 'a2_will',
    level: 'A2',
    title: 'Future with will',
    subtitle: 'quick decisions and predictions',
    icon: Icons.rocket_launch_rounded,
    rule: 'Use will for quick decisions, promises, offers and predictions.',
    example: 'I will help you. I think it will rain.',
    trap: 'After will, use V1: will go, not will goes.',
  ),
  GrammarTopic(
    id: 'a2_going_to',
    level: 'A2',
    title: 'Be going to',
    subtitle: 'plans and evidence',
    icon: Icons.event_available_rounded,
    rule:
        'Use be going to for plans, intentions and predictions with visible evidence.',
    example: 'I am going to study tonight. It is going to rain.',
    trap: 'Do not drop am, is or are before going to.',
  ),
  GrammarTopic(
    id: 'a2_comparatives',
    level: 'A2',
    title: 'Comparatives',
    subtitle: 'bigger, better, more useful',
    icon: Icons.compare_arrows_rounded,
    rule: 'Use comparatives to compare two people, places, things or ideas.',
    example: 'This bag is cheaper than that one.',
    trap: 'Do not use double comparatives: more better is wrong.',
  ),
  GrammarTopic(
    id: 'a2_superlatives',
    level: 'A2',
    title: 'Superlatives',
    subtitle: 'the biggest, the best',
    icon: Icons.emoji_events_rounded,
    rule: 'Use superlatives to describe the top item in a group.',
    example: 'She is the tallest student in the class.',
    trap: 'Most superlatives need the.',
  ),
  GrammarTopic(
    id: 'a2_countable_uncountable',
    level: 'A2',
    title: 'Countable / Uncountable & Quantifiers',
    subtitle: 'numbers, amounts, a few, a little',
    icon: Icons.inventory_2_rounded,
    rule:
        'Use countable nouns with numbers and plural forms; use uncountable nouns with amount words.',
    example: 'I have a few apples. I need a little water.',
    trap: 'Do not say two waters when you mean an amount of water.',
  ),
  GrammarTopic(
    id: 'a2_some_any_much_many',
    level: 'A2',
    title: 'Some / Any / Much / Many / A lot of',
    subtitle: 'basic quantity choices',
    icon: Icons.pie_chart_rounded,
    rule:
        'Use some, any, much, many and a lot of to talk about unclear amounts.',
    example: 'There are some eggs. There is not much milk.',
    trap:
        'Use many with plural countable nouns and much with uncountable nouns.',
  ),
  GrammarTopic(
    id: 'a2_should',
    level: 'A2',
    title: 'Should / Shouldn\'t',
    subtitle: 'advice and good ideas',
    icon: Icons.health_and_safety_rounded,
    rule: 'Use should and should not to give advice.',
    example: 'You should drink water. You should not sleep late.',
    trap: 'After should, use V1: should study, not should studies.',
  ),
  GrammarTopic(
    id: 'a2_must_have_to',
    level: 'A2',
    title: 'Must / Have to',
    subtitle: 'rules and necessity',
    icon: Icons.rule_rounded,
    rule: 'Use must and have to for rules, duties and strong necessity.',
    example: 'You must wear a seat belt. I have to finish my homework.',
    trap: 'Must not means prohibition; do not have to means no necessity.',
  ),
  GrammarTopic(
    id: 'a2_object_possessive_pronouns',
    level: 'A2',
    title: 'Object Pronouns & Possessive Pronouns',
    subtitle: 'me, him, hers, theirs',
    icon: Icons.people_alt_rounded,
    rule:
        'Use object pronouns after verbs and prepositions; use possessive pronouns without a noun.',
    example: 'Can you help me? This book is mine.',
    trap: 'Do not put a noun after mine, yours, his, hers, ours or theirs.',
  ),
  GrammarTopic(
    id: 'a2_adverbs_frequency_manner',
    level: 'A2',
    title: 'Adverbs of Frequency & Manner',
    subtitle: 'usually, never, slowly, well',
    icon: Icons.speed_rounded,
    rule:
        'Use frequency adverbs for how often and manner adverbs for how something happens.',
    example: 'I usually walk to school. She speaks slowly.',
    trap: 'Frequency adverbs usually go before the main verb but after be.',
  ),
  GrammarTopic(
    id: 'a2_infinitive_purpose',
    level: 'A2',
    title: 'Infinitive of Purpose',
    subtitle: 'to + verb for why',
    icon: Icons.flag_rounded,
    rule: 'Use to + V1 to explain the purpose of an action.',
    example: 'I went to the shop to buy bread.',
    trap: 'Do not use for + verb: for buy is wrong.',
  ),
  GrammarTopic(
    id: 'a2_gerund_infinitive',
    level: 'A2',
    title: 'Gerunds and Infinitives Intro',
    subtitle: 'V-ing or to + V1',
    icon: Icons.account_tree_rounded,
    rule: 'Some verbs are followed by V-ing and some by to + V1.',
    example: 'I enjoy reading. I want to learn English.',
    trap: 'Enjoy takes V-ing; want, need and decide take to + V1.',
  ),
];

GrammarLesson? a2LessonForTopic(GrammarTopic topic) => _a2Lessons[topic.id];

GrammarQuizQuestion _q(
  String id,
  String sentence,
  List<String> options,
  String answer,
  String explanation,
) =>
    GrammarQuizQuestion(
      id: id,
      type: GrammarQuizType.fillBlank,
      prompt: 'Fill in the blank.',
      sentence: sentence,
      options: options,
      answer: answer,
      explanation: explanation,
    );

List<GrammarQuizQuestion> _qs(String prefix, List<List<Object>> rows) {
  return List.generate(rows.length, (index) {
    final row = rows[index];
    return _q(
      '${prefix}_q${index + 1}',
      row[0] as String,
      (row[1] as List).cast<String>(),
      row[2] as String,
      row[3] as String,
    );
  });
}

GrammarLesson _lesson({
  required String title,
  required String goal,
  required String teacher,
  required List<GrammarFormulaRow> formulas,
  required List<String> usage,
  required List<String> examples,
  required String wrong,
  required String right,
  required String reason,
  required String task,
  required String model,
  required List<GrammarQuizQuestion> quiz,
}) =>
    GrammarLesson(
      bigTitle: title,
      oneLineGoal: goal,
      timeLabel: '',
      teacherIntro: teacher,
      formulaRows: formulas,
      usageBullets: usage,
      examples: examples,
      wrong: wrong,
      right: right,
      reason: reason,
      task: task,
      modelAnswer: model,
      quiz: quiz,
    );

final Map<String, GrammarLesson> _a2Lessons = {
  'a2_past_simple': _lesson(
    title: 'Past Simple',
    goal:
        'Talk about finished past events with regular verbs, irregular verbs, negatives and questions.',
    teacher:
        'Past Simple tells the listener that an action is finished. In positive sentences, use V2 or -ed. In negatives and questions, did carries the past meaning, so the main verb returns to V1.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'subject + V2 / V-ed',
          sample: 'I watched a film yesterday.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'subject + did not + V1',
          sample: 'She did not go out.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Did + subject + V1?',
          sample: 'Did you call me?'),
      GrammarFormulaRow(
          label: 'Wh-question',
          pattern: 'Wh + did + subject + V1?',
          sample: 'Where did they stay?'),
    ],
    usage: const [
      'Use Past Simple with finished time: yesterday, last night, two days ago.',
      'Regular verbs usually take -ed: watch -> watched.',
      'Irregular verbs use V2: go -> went, see -> saw.',
      'With did or did not, keep the main verb in V1.',
      'Use did at the start of yes/no questions.',
      'Use wh-word + did + subject + V1 for information questions.',
    ],
    examples: const [
      'I visited my aunt yesterday.',
      'She went to Ankara last week.',
      'We did not watch TV.',
      'Did you finish your homework?',
      'Where did he go after school?',
      'They arrived late.',
    ],
    wrong: 'Did you went home?',
    right: 'Did you go home?',
    reason: 'After did, the main verb stays in V1.',
    task:
        'Write four sentences about yesterday: two positive, one negative and one question.',
    model:
        'I studied English yesterday. I went to the park. I did not watch TV. Did you call your friend?',
    quiz: _qs('a2_past_simple', [
      [
        'I _____ my room yesterday.',
        ['cleaned', 'clean', 'cleans', 'cleaning'],
        'cleaned',
        'Finished past action with a regular verb needs -ed.'
      ],
      [
        'She _____ to school last Monday.',
        ['go', 'goes', 'went', 'going'],
        'went',
        'Go is irregular; the Past Simple form is went.'
      ],
      [
        'We did not _____ TV last night.',
        ['watched', 'watch', 'watches', 'watching'],
        'watch',
        'After did not, use V1.'
      ],
      [
        '_____ you call me yesterday?',
        ['Do', 'Are', 'Were', 'Did'],
        'Did',
        'Past Simple questions start with did.'
      ],
      [
        'They _____ late two days ago.',
        ['arrived', 'arrive', 'arrives', 'arriving'],
        'arrived',
        'Arrive is regular, so the past form is arrived.'
      ],
      [
        'He did not _____ breakfast.',
        ['ate', 'eats', 'eating', 'eat'],
        'eat',
        'After did not, the verb stays in V1.'
      ],
      [
        'Where _____ you go?',
        ['do', 'did', 'were', 'are'],
        'did',
        'Wh- Past Simple questions use did + subject + V1.'
      ],
      [
        'My father _____ a new phone last week.',
        ['buy', 'buys', 'bought', 'buying'],
        'bought',
        'Buy is irregular; the Past Simple form is bought.'
      ],
      [
        'I _____ my keys at home.',
        ['left', 'leave', 'leaves', 'leaving'],
        'left',
        'Leave is irregular; the Past Simple form is left.'
      ],
      [
        'Did she _____ the email?',
        ['sent', 'send', 'sends', 'sending'],
        'send',
        'After did, use V1.'
      ],
    ]),
  ),
  'a2_will': _lesson(
    title: 'Future with will',
    goal: 'Use will for quick decisions, predictions, promises and offers.',
    teacher:
        'Will is useful when the future idea is decided now or when you make a prediction, promise or offer. The verb after will is always V1.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'subject + will + V1',
          sample: 'I will help you.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'subject + will not + V1',
          sample: 'She will not be late.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Will + subject + V1?',
          sample: 'Will you come?'),
      GrammarFormulaRow(
          label: 'Prediction',
          pattern: 'I think + will + V1',
          sample: 'I think it will rain.'),
    ],
    usage: const [
      'Use will for decisions made at the moment of speaking.',
      'Use will for predictions, promises and offers.',
      'After will, use the base verb without -s or to.',
      'Will not can become won\'t.',
      'Use I think, maybe or probably with predictions.',
      'Do not use am/is/are before will.',
    ],
    examples: const [
      'I will open the window.',
      'She will call you tonight.',
      'We will not be late.',
      'Will they arrive soon?',
      'I think it will snow.',
      'I will help you with the bags.',
    ],
    wrong: 'She will comes late.',
    right: 'She will come late.',
    reason: 'After will, use V1.',
    task: 'Write two predictions and two offers with will.',
    model:
        'I think it will rain. I will help you. She will not be late. Will you join us?',
    quiz: _qs('a2_will', [
      [
        'I _____ help you.',
        ['will', 'am', 'do', 'going'],
        'will',
        'A quick offer uses will + V1.'
      ],
      [
        'She will _____ soon.',
        ['comes', 'coming', 'come', 'came'],
        'come',
        'After will, use V1.'
      ],
      [
        'We _____ not be late.',
        ['are', 'will', 'do', 'did'],
        'will',
        'The negative future form is will not + V1.'
      ],
      [
        '_____ you call me tonight?',
        ['Do', 'Are', 'Did', 'Will'],
        'Will',
        'Future questions with will start with Will.'
      ],
      [
        'I think it _____ rain tomorrow.',
        ['will', 'is', 'does', 'did'],
        'will',
        'Predictions commonly use I think + will.'
      ],
      [
        'He will not _____ the meeting.',
        ['missed', 'misses', 'missing', 'miss'],
        'miss',
        'After will not, use V1.'
      ],
      [
        'They _____ arrive at six.',
        ['are', 'will', 'did', 'have'],
        'will',
        'Will + V1 talks about a future prediction.'
      ],
      [
        'Will she _____ us?',
        ['helps', 'helping', 'help', 'helped'],
        'help',
        'After Will + subject, the verb is V1.'
      ],
      [
        'I _____ send the file now.',
        ['will', 'am', 'was', 'have'],
        'will',
        'A decision made now can use will.'
      ],
      [
        'It will _____ cold tonight.',
        ['is', 'be', 'being', 'was'],
        'be',
        'After will, the verb be stays in V1.'
      ],
    ]),
  ),
  'a2_going_to': _lesson(
    title: 'Be going to',
    goal: 'Talk about plans and predictions based on visible evidence.',
    teacher:
        'Be going to is for intentions and plans you already have. It also works when there is evidence now for a future result.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'am/is/are + going to + V1',
          sample: 'I am going to study.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'am/is/are + not + going to + V1',
          sample: 'He is not going to come.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Am/Is/Are + subject + going to + V1?',
          sample: 'Are you going to join us?'),
      GrammarFormulaRow(
          label: 'Evidence',
          pattern: 'Look! + going to',
          sample: 'Look! It is going to rain.'),
    ],
    usage: const [
      'Use be going to for plans and intentions.',
      'Use it for predictions when you can see evidence now.',
      'Do not drop am, is or are.',
      'The verb after to stays in V1.',
      'Use time words like tonight, tomorrow and next weekend for plans.',
      'Use look at... when present evidence supports the prediction.',
    ],
    examples: const [
      'I am going to study tonight.',
      'She is going to visit her aunt.',
      'We are going to start soon.',
      'Are you going to buy it?',
      'Look at the clouds. It is going to rain.',
      'He is not going to come.',
    ],
    wrong: 'I going to study tonight.',
    right: 'I am going to study tonight.',
    reason: 'Be going to needs am, is or are before going to.',
    task: 'Write three plans for this week with be going to.',
    model:
        'I am going to study tonight. We are going to visit my grandparents. I am not going to watch TV.',
    quiz: _qs('a2_going_to', [
      [
        'I _____ going to study tonight.',
        ['am', 'is', 'are', 'will'],
        'am',
        'With I, use am before going to.'
      ],
      [
        'She is going to _____ us.',
        ['visits', 'visiting', 'visit', 'visited'],
        'visit',
        'After going to, use V1.'
      ],
      [
        'They _____ going to move soon.',
        ['is', 'are', 'am', 'will'],
        'are',
        'With they, use are before going to.'
      ],
      [
        '_____ you going to join us?',
        ['Do', 'Will', 'Did', 'Are'],
        'Are',
        'Questions start with am/is/are.'
      ],
      [
        'Look! It _____ going to rain.',
        ['is', 'are', 'am', 'will'],
        'is',
        'With it, use is before going to.'
      ],
      [
        'He is not going to _____ it.',
        ['bought', 'buys', 'buying', 'buy'],
        'buy',
        'After going to, the verb is V1.'
      ],
      [
        'We _____ going to start now.',
        ['is', 'are', 'am', 'do'],
        'are',
        'With we, use are before going to.'
      ],
      [
        'What are you going to _____?',
        ['did', 'does', 'do', 'done'],
        'do',
        'After going to, use V1.'
      ],
      [
        'My sister _____ going to call you.',
        ['is', 'are', 'am', 'will'],
        'is',
        'My sister is singular, so use is.'
      ],
      [
        'Are they going to _____ here?',
        ['stayed', 'stay', 'stays', 'staying'],
        'stay',
        'The verb after going to stays in V1.'
      ],
    ]),
  ),
  'a2_comparatives': _lesson(
    title: 'Comparatives',
    goal: 'Compare two people, places, things or ideas clearly.',
    teacher:
        'Comparatives show the difference between two items. Short adjectives usually take -er. Longer adjectives usually use more. Irregular forms like better and worse must be learned as chunks.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Short adjective',
          pattern: 'adjective + -er + than',
          sample: 'This room is smaller than mine.'),
      GrammarFormulaRow(
          label: 'Long adjective',
          pattern: 'more + adjective + than',
          sample: 'This book is more useful than that one.'),
      GrammarFormulaRow(
          label: 'Irregular',
          pattern: 'better / worse / farther',
          sample: 'This cafe is better than the old one.'),
      GrammarFormulaRow(
          label: 'Equality',
          pattern: 'as + adjective + as',
          sample: 'This test is as easy as the first one.'),
    ],
    usage: const [
      'Use than after a comparative when you name the second item.',
      'Short adjectives often take -er: cold -> colder.',
      'Long adjectives use more: more expensive.',
      'Do not use more and -er together.',
      'Use as + adjective + as when two things are equal.',
      'Learn irregular chunks like better, worse and farther.',
    ],
    examples: const [
      'This bag is cheaper than that one.',
      'Kayseri is colder than Antalya.',
      'English is easier than German for me.',
      'This exercise is more difficult than the last one.',
      'My phone is better than my old phone.',
      'The bus is slower than the train.',
    ],
    wrong: 'This phone is more cheaper than mine.',
    right: 'This phone is cheaper than mine.',
    reason: 'Do not use more with an -er comparative.',
    task: 'Compare your city, your school and two objects around you.',
    model:
        'My city is quieter than Istanbul. This lesson is easier than the last one. My bag is heavier than yours.',
    quiz: _qs('a2_comparatives', [
      [
        'This bag is _____ than that one.',
        ['cheaper', 'cheap', 'cheapest', 'more cheap'],
        'cheaper',
        'Short adjectives often take -er.'
      ],
      [
        'Today is _____ than yesterday.',
        ['cold', 'coldest', 'colder', 'more cold'],
        'colder',
        'Cold becomes colder in the comparative.'
      ],
      [
        'This book is _____ useful than that one.',
        ['most', 'more', 'very', 'too'],
        'more',
        'Long adjectives use more + adjective.'
      ],
      [
        'My phone is _____ than yours.',
        ['good', 'best', 'more good', 'better'],
        'better',
        'Good has the irregular comparative better.'
      ],
      [
        'The train is _____ than the bus.',
        ['faster', 'fast', 'fastest', 'more fast'],
        'faster',
        'Fast is short, so faster is natural.'
      ],
      [
        'This test is not _____ difficult than the last one.',
        ['most', 'very', 'too', 'more'],
        'more',
        'Use more difficult for a comparative.'
      ],
      [
        'Her room is _____ than mine.',
        ['big', 'bigger', 'biggest', 'more big'],
        'bigger',
        'Big doubles the final consonant: bigger.'
      ],
      [
        'This cafe is _____ than the old cafe.',
        ['good', 'best', 'better', 'more good'],
        'better',
        'Good -> better.'
      ],
      [
        'The red dress is _____ expensive than the blue one.',
        ['more', 'most', 'many', 'much'],
        'more',
        'Expensive is long, so use more.'
      ],
      [
        'My house is _____ from school than yours.',
        ['far', 'farther', 'farthest', 'more far'],
        'farther',
        'Farther can compare distance.'
      ],
    ]),
  ),
  'a2_superlatives': _lesson(
    title: 'Superlatives',
    goal:
        'Describe the top item in a group with the -est, the most and irregular forms.',
    teacher:
        'Superlatives choose one item from a group. Most forms need the. Short adjectives often take -est; longer adjectives use the most.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Short adjective',
          pattern: 'the + adjective + -est',
          sample: 'She is the tallest student.'),
      GrammarFormulaRow(
          label: 'Long adjective',
          pattern: 'the most + adjective',
          sample: 'This is the most useful app.'),
      GrammarFormulaRow(
          label: 'Irregular',
          pattern: 'the best / the worst',
          sample: 'This is the best answer.'),
      GrammarFormulaRow(
          label: 'Group',
          pattern: 'in + place/group',
          sample: 'He is the youngest in the class.'),
    ],
    usage: const [
      'Use superlatives when one item is at the top of a group.',
      'Use the before most superlative forms.',
      'Short adjectives often take -est.',
      'Long adjectives use the most.',
      'Use in for places and groups: in my class, in the city.',
      'Learn irregular chunks like the best and the worst.',
    ],
    examples: const [
      'She is the tallest student in class.',
      'This is the most interesting story.',
      'Monday is the busiest day for me.',
      'This is the best restaurant in town.',
      'He is the youngest in his family.',
      'That was the worst day of the trip.',
    ],
    wrong: 'She is tallest student in the class.',
    right: 'She is the tallest student in the class.',
    reason: 'Most superlatives need the.',
    task: 'Write four superlative sentences about your class, city or family.',
    model:
        'My brother is the youngest in my family. This is the best cafe near school.',
    quiz: _qs('a2_superlatives', [
      [
        'She is _____ tallest student.',
        ['the', 'a', 'more', 'most'],
        'the',
        'Most superlatives need the.'
      ],
      [
        'This is the _____ useful app.',
        ['more', 'useful', 'most', 'much'],
        'most',
        'Long adjectives use the most.'
      ],
      [
        'He is the _____ person in the room.',
        ['tall', 'tallest', 'taller', 'more tall'],
        'tallest',
        'Short adjectives often take -est.'
      ],
      [
        'This is the _____ answer.',
        ['good', 'better', 'more good', 'best'],
        'best',
        'Good has the superlative best.'
      ],
      [
        'It is _____ most expensive hotel.',
        ['the', 'a', 'more', 'very'],
        'the',
        'Use the before most expensive.'
      ],
      [
        'Monday is the _____ day for me.',
        ['busy', 'busier', 'more busy', 'busiest'],
        'busiest',
        'Busy becomes busiest.'
      ],
      [
        'This is the _____ movie I know.',
        ['funny', 'funniest', 'funnier', 'more funny'],
        'funniest',
        'Funny becomes funniest.'
      ],
      [
        'That was the _____ meal of the trip.',
        ['bad', 'worse', 'worst', 'more bad'],
        'worst',
        'Bad has the superlative worst.'
      ],
      [
        'She is the youngest _____ the family.',
        ['in', 'on', 'at', 'than'],
        'in',
        'Use in for a group: in the family.'
      ],
      [
        'This is the most _____ question.',
        ['easy', 'important', 'importanter', 'importance'],
        'important',
        'The most is followed by the adjective.'
      ],
    ]),
  ),
  'a2_countable_uncountable': _lesson(
    title: 'Countable / Uncountable & Quantifiers',
    goal:
        'Choose countable or uncountable noun patterns and basic amount words.',
    teacher:
        'Countable nouns can be singular or plural. Uncountable nouns usually stay singular and use amount words like some, a little and a lot of.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Countable singular',
          pattern: 'a/an + noun',
          sample: 'I need an apple.'),
      GrammarFormulaRow(
          label: 'Countable plural',
          pattern: 'number / many / a few + plural noun',
          sample: 'There are a few chairs.'),
      GrammarFormulaRow(
          label: 'Uncountable',
          pattern: 'some / much / a little + noun',
          sample: 'There is a little water.'),
      GrammarFormulaRow(
          label: 'General amount',
          pattern: 'a lot of + countable/uncountable',
          sample: 'We have a lot of time.'),
    ],
    usage: const [
      'Use a/an with singular countable nouns.',
      'Use plural forms after numbers: two apples.',
      'Use a little with uncountable nouns.',
      'Use a few with plural countable nouns.',
      'Use containers to count uncountable nouns: a bottle of water.',
      'A lot of works with both countable and uncountable nouns.',
    ],
    examples: const [
      'I have a few questions.',
      'There is a little milk.',
      'We need two bottles of water.',
      'She has a lot of homework.',
      'There are many chairs.',
      'I do not have much money.',
    ],
    wrong: 'I need two waters.',
    right: 'I need two bottles of water.',
    reason: 'Water is uncountable; use an amount container when you count it.',
    task: 'Write three countable and three uncountable noun phrases.',
    model:
        'A few apples, three books, many chairs. A little water, much money, a lot of homework.',
    quiz: _qs('a2_countable', [
      [
        'I have _____ questions.',
        ['a few', 'a little', 'much', 'an'],
        'a few',
        'Questions are plural countable, so use a few.'
      ],
      [
        'There is _____ water in the bottle.',
        ['a few', 'many', 'a little', 'an'],
        'a little',
        'Water is uncountable, so use a little.'
      ],
      [
        'She has two _____.',
        ['book', 'books', 'a book', 'booking'],
        'books',
        'After two, use a plural countable noun.'
      ],
      [
        'I need a _____ of water.',
        ['many', 'few', 'some', 'bottle'],
        'bottle',
        'Use a container to count water.'
      ],
      [
        'There are _____ chairs in the room.',
        ['many', 'much', 'a little', 'an'],
        'many',
        'Chairs are plural countable, so many works.'
      ],
      [
        'We do not have _____ time.',
        ['many', 'a few', 'an', 'much'],
        'much',
        'Time is uncountable in this meaning.'
      ],
      [
        'I bought _____ apple.',
        ['a', 'an', 'some', 'many'],
        'an',
        'Apple is singular countable and starts with a vowel sound.'
      ],
      [
        'There is a lot of _____ today.',
        ['emails', 'chairs', 'homework', 'students'],
        'homework',
        'Homework is uncountable and works with a lot of.'
      ],
      [
        'Can I have _____ bread?',
        ['some', 'many', 'a few', 'an'],
        'some',
        'Bread is uncountable here; some is natural.'
      ],
      [
        'We need three _____ for the table.',
        ['glass', 'glasses', 'water', 'bread'],
        'glasses',
        'After three, use a plural countable noun.'
      ],
    ]),
  ),
  'a2_some_any_much_many': _lesson(
    title: 'Some / Any / Much / Many / A lot of',
    goal: 'Use common quantity words in positive, negative and question forms.',
    teacher:
        'These words help you talk about amount without an exact number. Some is common in positive sentences; any is common in questions and negatives. Much and many depend on the noun type.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'some / a lot of',
          sample: 'There are some eggs.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'not + any / much / many',
          sample: 'There is not much milk.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'any / much / many?',
          sample: 'Are there any apples?'),
      GrammarFormulaRow(
          label: 'Noun type',
          pattern: 'many + plural / much + uncountable',
          sample: 'many people / much water'),
    ],
    usage: const [
      'Use some in positive sentences.',
      'Use any in most questions and negatives.',
      'Use many with plural countable nouns.',
      'Use much with uncountable nouns.',
      'Use a lot of in everyday positive sentences.',
      'Use some in offers and requests when the answer is likely yes.',
    ],
    examples: const [
      'There are some eggs in the fridge.',
      'There is not any milk.',
      'Do you have any questions?',
      'How many students are there?',
      'How much money do you need?',
      'We have a lot of work today.',
    ],
    wrong: 'How much students are there?',
    right: 'How many students are there?',
    reason: 'Students is plural countable, so use many.',
    task: 'Write five quantity questions for a shopping list.',
    model:
        'Do we have any eggs? How much milk do we need? How many apples do we need?',
    quiz: _qs('a2_quant', [
      [
        'There are _____ apples on the table.',
        ['some', 'any', 'much', 'a'],
        'some',
        'Some is natural in positive plural sentences.'
      ],
      [
        'There is not _____ milk.',
        ['some', 'many', 'any', 'a few'],
        'any',
        'Any is common in negatives.'
      ],
      [
        'How _____ students are in your class?',
        ['much', 'many', 'some', 'any'],
        'many',
        'Students are plural countable.'
      ],
      [
        'How _____ water do you drink?',
        ['many', 'some', 'any', 'much'],
        'much',
        'Water is uncountable.'
      ],
      [
        'Do you have _____ questions?',
        ['any', 'some', 'much', 'a'],
        'any',
        'Any is common in questions.'
      ],
      [
        'We have _____ of homework today.',
        ['many', 'any', 'much', 'a lot'],
        'a lot',
        'A lot of works with uncountable nouns.'
      ],
      [
        'There are not _____ buses at night.',
        ['much', 'many', 'some', 'a'],
        'many',
        'Buses are plural countable.'
      ],
      [
        'Can I have _____ tea?',
        ['any', 'many', 'some', 'a few'],
        'some',
        'Some is natural in requests and offers.'
      ],
      [
        'I do not have _____ money.',
        ['much', 'many', 'a few', 'an'],
        'much',
        'Money is uncountable.'
      ],
      [
        'She has _____ friends here.',
        ['much', 'many', 'any', 'a little'],
        'many',
        'Friends are plural countable.'
      ],
    ]),
  ),
  'a2_should': _lesson(
    title: 'Should / Shouldn\'t',
    goal: 'Give simple advice and say what is a good or bad idea.',
    teacher:
        'Should is a soft advice modal. It does not change with he or she, and the verb after should is always V1.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Advice',
          pattern: 'subject + should + V1',
          sample: 'You should rest.'),
      GrammarFormulaRow(
          label: 'Negative advice',
          pattern: 'subject + should not + V1',
          sample: 'You should not eat too late.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Should + subject + V1?',
          sample: 'Should I call her?'),
      GrammarFormulaRow(
          label: 'Wh-question',
          pattern: 'What should + subject + V1?',
          sample: 'What should we do?'),
    ],
    usage: const [
      'Use should for advice, not strict rules.',
      'Should does not take -s with he or she.',
      'After should, use V1.',
      'Should not can become shouldn\'t.',
      'Use should I...? when you ask for advice.',
      'Use should not for a bad idea, not a strict prohibition.',
    ],
    examples: const [
      'You should drink more water.',
      'He should see a doctor.',
      'You should not sleep late.',
      'Should I call her?',
      'What should we do?',
      'They should study for the test.',
    ],
    wrong: 'She should studies more.',
    right: 'She should study more.',
    reason: 'After should, use V1.',
    task: 'Write four pieces of advice for a friend.',
    model:
        'You should rest. You should not worry. You should drink water. You should call your teacher.',
    quiz: _qs('a2_should', [
      [
        'You _____ drink more water.',
        ['should', 'are', 'do', 'did'],
        'should',
        'Advice uses should + V1.'
      ],
      [
        'She should _____ a doctor.',
        ['sees', 'seeing', 'see', 'saw'],
        'see',
        'After should, use V1.'
      ],
      [
        'You _____ not sleep late.',
        ['are', 'should', 'do', 'did'],
        'should',
        'Negative advice is should not + V1.'
      ],
      [
        '_____ I call him?',
        ['Do', 'Am', 'Did', 'Should'],
        'Should',
        'Advice questions can start with Should.'
      ],
      [
        'He should _____ at home today.',
        ['stay', 'stays', 'staying', 'stayed'],
        'stay',
        'After should, use V1.'
      ],
      [
        'They should not _____ fast.',
        ['drove', 'drives', 'driving', 'drive'],
        'drive',
        'After should not, use V1.'
      ],
      [
        'What should we _____?',
        ['does', 'do', 'doing', 'did'],
        'do',
        'Wh-question: What should we do?'
      ],
      [
        'You should _____ your teacher.',
        ['asked', 'asks', 'ask', 'asking'],
        'ask',
        'After should, use V1.'
      ],
      [
        'My brother _____ study tonight.',
        ['should', 'does', 'is', 'has'],
        'should',
        'Should works with all subjects.'
      ],
      [
        'She should not _____ so much coffee.',
        ['drank', 'drink', 'drinks', 'drinking'],
        'drink',
        'After should not, use V1.'
      ],
    ]),
  ),
  'a2_must_have_to': _lesson(
    title: 'Must / Have to',
    goal: 'Talk about rules, duties and strong necessity.',
    teacher:
        'Must and have to both show obligation. Must often feels direct or official. Have to often describes an outside rule or duty. Must not means something is prohibited.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Rule',
          pattern: 'subject + must + V1',
          sample: 'You must wear a helmet.'),
      GrammarFormulaRow(
          label: 'Duty',
          pattern: 'subject + have/has to + V1',
          sample: 'She has to work today.'),
      GrammarFormulaRow(
          label: 'No necessity',
          pattern: 'do/does not have to + V1',
          sample: 'You do not have to come early.'),
      GrammarFormulaRow(
          label: 'Prohibition',
          pattern: 'must not + V1',
          sample: 'You must not smoke here.'),
    ],
    usage: const [
      'Use must for strong rules and direct necessity.',
      'Use have to for duties and outside rules.',
      'Must not means prohibition.',
      'Do not have to means it is not necessary.',
      'Use has to with he, she and it.',
      'Do not use to after must.',
    ],
    examples: const [
      'You must wear a seat belt.',
      'I have to finish my homework.',
      'She has to leave early.',
      'You must not touch this button.',
      'We do not have to wear uniforms.',
      'Do you have to work tomorrow?',
    ],
    wrong: 'You must to wear a seat belt.',
    right: 'You must wear a seat belt.',
    reason: 'After must, use V1 without to.',
    task: 'Write three rules and two duties with must or have to.',
    model:
        'You must be quiet. I have to study tonight. We do not have to come early.',
    quiz: _qs('a2_must', [
      [
        'You _____ wear a seat belt.',
        ['must', 'are', 'do', 'did'],
        'must',
        'Rules can use must + V1.'
      ],
      [
        'She _____ to work today.',
        ['have', 'must', 'has', 'do'],
        'has',
        'She takes has to for obligation.'
      ],
      [
        'I _____ to finish this report.',
        ['has', 'have', 'must to', 'am'],
        'have',
        'I takes have to.'
      ],
      [
        'You must not _____ here.',
        ['smokes', 'smoking', 'to smoke', 'smoke'],
        'smoke',
        'After must not, use V1.'
      ],
      [
        'We do not _____ to pay today.',
        ['have', 'has', 'must', 'are'],
        'have',
        'No necessity uses do not have to.'
      ],
      [
        'He _____ wear a uniform at school.',
        ['have to', 'must to', 'has', 'has to'],
        'has to',
        'He uses has to + V1.'
      ],
      [
        'Do you _____ to leave now?',
        ['has', 'have', 'must', 'are'],
        'have',
        'Questions with have to use do + subject + have to.'
      ],
      [
        'Students must _____ their phones off.',
        ['turns', 'turning', 'turn', 'turned'],
        'turn',
        'After must, use V1.'
      ],
      [
        'You _____ not park here.',
        ['must', 'have', 'are', 'do'],
        'must',
        'Must not shows prohibition.'
      ],
      [
        'I do not have to _____ early tomorrow.',
        ['woke', 'wake', 'wakes', 'waking'],
        'wake',
        'After have to, use V1.'
      ],
    ]),
  ),
  'a2_object_possessive_pronouns': _lesson(
    title: 'Object Pronouns & Possessive Pronouns',
    goal:
        'Use me, him, her, us, them and mine, yours, hers, ours, theirs naturally.',
    teacher:
        'Object pronouns receive the action or come after prepositions. Possessive pronouns replace a full noun phrase, so they stand alone.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Object',
          pattern: 'verb + me/you/him/her/it/us/them',
          sample: 'Can you help me?'),
      GrammarFormulaRow(
          label: 'After preposition',
          pattern: 'with / for / to + object pronoun',
          sample: 'Come with us.'),
      GrammarFormulaRow(
          label: 'Possessive pronoun',
          pattern: 'mine/yours/his/hers/ours/theirs',
          sample: 'This bag is mine.'),
      GrammarFormulaRow(
          label: 'Whose',
          pattern: 'Whose + noun?',
          sample: 'Whose phone is this?'),
    ],
    usage: const [
      'Use object pronouns after verbs and prepositions.',
      'Use possessive pronouns without a noun after them.',
      'Mine means my + noun, so do not say mine book.',
      'Whose asks about possession.',
      'Use her as an object pronoun and hers as a possessive pronoun.',
      'Use their before a noun, but theirs alone.',
    ],
    examples: const [
      'Can you help me?',
      'I called him yesterday.',
      'She is waiting for us.',
      'This notebook is mine.',
      'The red bag is hers.',
      'Whose keys are these?',
    ],
    wrong: 'This is mine book.',
    right: 'This book is mine.',
    reason: 'Mine already means my book; do not put a noun after it.',
    task: 'Write four sentences with object pronouns and possessive pronouns.',
    model:
        'Can you help me? I called her. This pen is mine. Those shoes are theirs.',
    quiz: _qs('a2_pronouns', [
      [
        'Can you help _____?',
        ['me', 'I', 'my', 'mine'],
        'me',
        'After help, use an object pronoun.'
      ],
      [
        'I called _____ yesterday.',
        ['he', 'his', 'him', 'he is'],
        'him',
        'After called, use him as the object pronoun.'
      ],
      [
        'This book is _____.',
        ['my', 'mine', 'me', 'I'],
        'mine',
        'Mine stands alone without a noun.'
      ],
      [
        'She is waiting for _____.',
        ['we', 'our', 'ours', 'us'],
        'us',
        'After for, use the object pronoun us.'
      ],
      [
        'The red bag is _____.',
        ['hers', 'her', 'she', 'she is'],
        'hers',
        'Hers is a possessive pronoun and stands alone.'
      ],
      [
        'I gave the ticket to _____.',
        ['she', 'her', 'hers', 'his'],
        'her',
        'After to, use the object pronoun her.'
      ],
      [
        'Those keys are _____.',
        ['they', 'their', 'them', 'theirs'],
        'theirs',
        'Theirs stands alone as a possessive pronoun.'
      ],
      [
        'Please come with _____.',
        ['we', 'our', 'us', 'ours'],
        'us',
        'After with, use us.'
      ],
      [
        'Is this phone _____?',
        ['yours', 'your', 'you', 'yourself'],
        'yours',
        'Yours is the possessive pronoun.'
      ],
      [
        'I know _____.',
        ['they', 'them', 'their', 'theirs'],
        'them',
        'After know, use an object pronoun.'
      ],
    ]),
  ),
  'a2_adverbs_frequency_manner': _lesson(
    title: 'Adverbs of Frequency & Manner',
    goal: 'Say how often something happens and how someone does something.',
    teacher:
        'Frequency adverbs answer how often. Manner adverbs answer how. Their position changes with be and other verbs.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Frequency + main verb',
          pattern: 'subject + usually/often + V1',
          sample: 'I usually walk to school.'),
      GrammarFormulaRow(
          label: 'Frequency + be',
          pattern: 'subject + be + always/never',
          sample: 'She is always kind.'),
      GrammarFormulaRow(
          label: 'Manner',
          pattern: 'verb + adverb',
          sample: 'He drives carefully.'),
      GrammarFormulaRow(
          label: 'Good/well',
          pattern: 'good = adjective / well = adverb',
          sample: 'She speaks English well.'),
    ],
    usage: const [
      'Use always, usually, often, sometimes and never for frequency.',
      'Frequency adverbs usually go before the main verb.',
      'With be, frequency adverbs usually go after am/is/are.',
      'Manner adverbs often come after the verb.',
      'Use well as the adverb form of good.',
      'Do not add -ly to every frequency word: never, not neverly.',
    ],
    examples: const [
      'I usually study at night.',
      'She is never late.',
      'We often eat at home.',
      'He drives carefully.',
      'They speak quietly.',
      'She sings very well on stage.',
    ],
    wrong: 'She speaks English good.',
    right: 'She speaks English well.',
    reason: 'Use well as the adverb of good.',
    task: 'Write three routine sentences and three manner sentences.',
    model:
        'I usually walk to school. She is never late. He speaks slowly. They work carefully.',
    quiz: _qs('a2_adverbs', [
      [
        'I _____ study after dinner.',
        ['usually', 'usual', 'good', 'careful'],
        'usually',
        'Usually is a frequency adverb.'
      ],
      [
        'She is _____ late.',
        ['neverly', 'careful', 'never', 'slow'],
        'never',
        'With be, frequency adverbs often come after be.'
      ],
      [
        'He drives _____.',
        ['careful', 'carefully', 'never', 'usual'],
        'carefully',
        'Use an adverb to describe how he drives.'
      ],
      [
        'They speak very _____.',
        ['quiet', 'never', 'usually', 'quietly'],
        'quietly',
        'Quietly describes how they speak.'
      ],
      [
        'We _____ go to the cinema on Fridays.',
        ['good', 'careful', 'slow', 'often'],
        'often',
        'Often tells how frequently something happens.'
      ],
      [
        'She sings _____.',
        ['good', 'well', 'never', 'usual'],
        'well',
        'Well is the adverb form.'
      ],
      [
        'My brother is _____ busy.',
        ['always', 'careful', 'slowly', 'well'],
        'always',
        'With be, always comes after is.'
      ],
      [
        'Please listen _____.',
        ['careful', 'good', 'carefully', 'usual'],
        'carefully',
        'Carefully describes the verb listen.'
      ],
      [
        'I _____ drink coffee at night.',
        ['good', 'careful', 'never', 'well'],
        'never',
        'Never tells frequency.'
      ],
      [
        'She reads _____ in class.',
        ['slow', 'slowly', 'usual', 'oftenly'],
        'slowly',
        'Slowly describes how she reads.'
      ],
    ]),
  ),
  'a2_infinitive_purpose': _lesson(
    title: 'Infinitive of Purpose',
    goal: 'Use to + verb to explain why someone does something.',
    teacher:
        'The infinitive of purpose answers why. It is short and natural after many action verbs: go to buy, call to ask, study to pass.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Purpose',
          pattern: 'action + to + V1',
          sample: 'I went out to buy milk.'),
      GrammarFormulaRow(
          label: 'Negative purpose',
          pattern: 'action + not to + V1',
          sample: 'I wrote it down not to forget.'),
      GrammarFormulaRow(
          label: 'Question answer',
          pattern: 'Why...? To + V1',
          sample: 'Why did you call? To ask a question.'),
      GrammarFormulaRow(
          label: 'No for + verb',
          pattern: 'not: for buy',
          sample: 'I went to the shop to buy bread.'),
    ],
    usage: const [
      'Use to + V1 to explain purpose.',
      'It answers the question why.',
      'Do not use for + verb.',
      'Use not to + V1 for negative purpose.',
      'Use action + to + V1 in everyday sentences.',
      'Short answers can start with To + V1: To ask a question.',
    ],
    examples: const [
      'I went to the shop to buy bread.',
      'She called me to ask a question.',
      'We study to pass the exam.',
      'He saved money to buy a bike.',
      'I wrote it down not to forget.',
      'Why did you come? To see you.',
    ],
    wrong: 'I went to the shop for buy bread.',
    right: 'I went to the shop to buy bread.',
    reason: 'Purpose with a verb uses to + V1, not for + verb.',
    task: 'Write five sentences that explain why you do everyday actions.',
    model:
        'I study to improve my English. I called Ece to ask a question. I went out to buy milk.',
    quiz: _qs('a2_purpose', [
      [
        'I went to the shop _____ buy bread.',
        ['to', 'for', 'so', 'because'],
        'to',
        'Purpose with a verb uses to + V1.'
      ],
      [
        'She called me _____ ask a question.',
        ['for', 'because', 'to', 'so'],
        'to',
        'Use to + V1 to explain purpose.'
      ],
      [
        'We study _____ pass the exam.',
        ['for', 'to', 'because', 'so'],
        'to',
        'The purpose is expressed with to pass.'
      ],
      [
        'He saved money _____ buy a bike.',
        ['for', 'because', 'so', 'to'],
        'to',
        'Use to + V1 after the action.'
      ],
      [
        'I wrote it down not _____ forget.',
        ['to', 'for', 'because', 'so'],
        'to',
        'Negative purpose uses not to + V1.'
      ],
      [
        'They came here _____ see us.',
        ['for', 'because', 'so', 'to'],
        'to',
        'To see explains why they came.'
      ],
      [
        'I opened the window _____ get fresh air.',
        ['for', 'to', 'because', 'so'],
        'to',
        'Use to + V1 for purpose.'
      ],
      [
        'She went online _____ check her email.',
        ['for', 'because', 'to', 'so'],
        'to',
        'To check explains the purpose.'
      ],
      [
        'We left early _____ catch the bus.',
        ['to', 'for', 'because', 'so'],
        'to',
        'To catch explains why we left early.'
      ],
      [
        'He took a taxi _____ be on time.',
        ['for', 'to', 'because', 'so'],
        'to',
        'Use to + V1 for purpose.'
      ],
    ]),
  ),
  'a2_gerund_infinitive': _lesson(
    title: 'Gerunds and Infinitives Intro',
    goal: 'Choose V-ing or to + V1 after common A2 verbs.',
    teacher:
        'Some verbs prefer a gerund and some prefer an infinitive. At A2, learn the most common patterns as chunks: enjoy doing, like doing, want to do, need to do, decide to do.',
    formulas: const [
      GrammarFormulaRow(
          label: 'Gerund',
          pattern: 'enjoy / finish / avoid + V-ing',
          sample: 'I enjoy reading.'),
      GrammarFormulaRow(
          label: 'Infinitive',
          pattern: 'want / need / decide + to + V1',
          sample: 'She wants to learn.'),
      GrammarFormulaRow(
          label: 'Like/love/hate',
          pattern: 'like/love/hate + V-ing',
          sample: 'I like swimming.'),
      GrammarFormulaRow(
          label: 'Purpose overlap',
          pattern: 'verb + to + V1',
          sample: 'I study to pass.'),
    ],
    usage: const [
      'Use V-ing after enjoy, finish and avoid.',
      'Use to + V1 after want, need and decide.',
      'Like, love and hate commonly take V-ing at this level.',
      'Do not add to after enjoy.',
      'Learn common verb patterns as chunks.',
      'Avoid is followed by V-ing.',
    ],
    examples: const [
      'I enjoy reading books.',
      'She finished doing her homework.',
      'We want to learn English.',
      'He needs to call his mother.',
      'They decided to stay home.',
      'I love watching films.',
    ],
    wrong: 'I enjoy to read.',
    right: 'I enjoy reading.',
    reason: 'Enjoy is followed by V-ing.',
    task: 'Write five sentences with enjoy, want, need, decide and love.',
    model:
        'I enjoy reading. I want to learn English. I need to study. We decided to stay home. I love watching films.',
    quiz: _qs('a2_gerund', [
      [
        'I enjoy _____ books.',
        ['reading', 'to read', 'read', 'reads'],
        'reading',
        'Enjoy is followed by V-ing.'
      ],
      [
        'She wants _____ English.',
        ['learn', 'learning', 'to learn', 'learns'],
        'to learn',
        'Want is followed by to + V1.'
      ],
      [
        'We need _____ now.',
        ['leave', 'to leave', 'leaving', 'leaves'],
        'to leave',
        'Need is followed by to + V1.'
      ],
      [
        'He finished _____ his homework.',
        ['to do', 'do', 'does', 'doing'],
        'doing',
        'Finish is followed by V-ing.'
      ],
      [
        'They decided _____ at home.',
        ['to stay', 'staying', 'stay', 'stays'],
        'to stay',
        'Decide is followed by to + V1.'
      ],
      [
        'I love _____ films.',
        ['watch', 'to watching', 'watches', 'watching'],
        'watching',
        'Love commonly takes V-ing at this level.'
      ],
      [
        'She avoided _____ late.',
        ['be', 'being', 'to be', 'is'],
        'being',
        'Avoid is followed by V-ing.'
      ],
      [
        'He hopes _____ a job.',
        ['find', 'finding', 'to find', 'finds'],
        'to find',
        'Hope is followed by to + V1.'
      ],
      [
        'I hate _____ early.',
        ['getting up', 'to getting up', 'get up', 'gets up'],
        'getting up',
        'Hate can take V-ing for a general dislike.'
      ],
      [
        'We plan _____ tomorrow.',
        ['leave', 'to leave', 'leaving', 'left'],
        'to leave',
        'Plan is followed by to + V1.'
      ],
    ]),
  ),
};
