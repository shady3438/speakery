// ignore_for_file: unused_element, curly_braces_in_flow_control_structures

import 'package:speakery/data/grammar/grammar_generator.dart';
import 'package:speakery/data/grammar/grammar_models.dart';

import 'grammar_display_model.dart';
import 'grammar_ui_text.dart';

String grammarSmallGrammarSlip(String value, int seed) =>
    _smallGrammarSlip(value, seed);
GrammarQuizType grammarQuizTypeForPoint(GrammarLogicPoint point, int index) =>
    _quizTypeForPoint(point, index);
String grammarQuizPromptForPoint(
        GrammarLogicPoint point, String answer, int index, bool isEnglish) =>
    _quizPromptForPoint(point, answer, index, isEnglish);
String grammarQuizPromptForRow(
        GrammarFormulaRow row, String answer, int index, bool isEnglish) =>
    _quizPromptForRow(row, answer, index, isEnglish);
String grammarQuizPromptForExample(String answer, int index, bool isEnglish) =>
    _quizPromptForExample(answer, index, isEnglish);
String grammarQuizAnswerKey(String value) => _quizAnswerKey(value);
String grammarQuizTypeLabel(GrammarQuizType type, bool isEnglish) =>
    _quizTypeLabel(type, isEnglish);

class _ClozeSpec {
  final String sentence; // contains _____ placeholder
  final String answer;
  final List<String> options; // should include answer + 3 distractors
  final String explanationTr;
  final String explanationEn;

  const _ClozeSpec({
    required this.sentence,
    required this.answer,
    required this.options,
    required this.explanationTr,
    required this.explanationEn,
  });
}

String _a1A2ClozeExplanation(
  String key,
  GrammarQuizQuestion source,
  String answer,
  bool isEnglish,
) {
  if (isEnglish && key.startsWith('a1_')) {
    switch (key) {
      case 'a1_be_verb':
        return 'Choose am, is, or are to match the subject. The answer here is "$answer".';
      case 'a1_subject_pronouns':
        return 'Use a subject pronoun before the verb and an object pronoun after it. The correct form is "$answer".';
      case 'a1_possessive_adjectives':
        return 'Use the possessive form that matches the owner. The correct choice is "$answer".';
      case 'a1_there_is_are':
        return 'Use there is for one thing and there are for plural things. The correct form is "$answer".';
      case 'a1_articles':
        return 'Choose the article from the noun sound and whether the noun is specific. The answer is "$answer".';
      case 'a1_singular_plural':
        return 'Match the noun and quantity form. The correct answer is "$answer".';
      case 'a1_present_simple':
        return 'Check the subject and whether the sentence is positive, negative, or a question. Use "$answer" here.';
      case 'a1_present_continuous':
        return 'Present Continuous uses am/is/are + V-ing. The missing form is "$answer".';
      case 'a1_can_cant':
        return 'Can and can\'t are followed by the base verb. The correct choice is "$answer".';
      case 'a1_have_has_got':
        return 'Use have got with I/you/we/they and has got with he/she/it. The answer is "$answer".';
      case 'a1_basic_prepositions':
        return 'Choose in, on, or at from the place or time expression. The answer is "$answer".';
      case 'a1_imperatives':
        return 'Imperatives use the base verb; negative commands use don\'t + base verb. The answer is "$answer".';
      case 'a1_demonstratives':
        return 'Match near/far and singular/plural. The correct demonstrative is "$answer".';
    }
  }

  if (!isEnglish && key.startsWith('a2_')) {
    switch (key) {
      case 'a2_past_simple':
        return 'Bitmiş geçmiş zamanda olumlu cümlede V2, did/didn\'t sonrasında V1 kullanılır. Bu boşlukta doğru cevap "$answer".';
      case 'a2_will':
        return 'Will hızlı karar, teklif, söz veya tahmin anlatır; sonrasında fiil yalın kalır. Doğru cevap "$answer".';
      case 'a2_going_to':
        return 'Plan ve kanıta dayalı tahminde am/is/are + going to + V1 kullanılır. Doğru cevap "$answer".';
      case 'a2_comparatives':
        return 'İki şeyi karşılaştırırken kısa sıfatta -er, uzun sıfatta more ve çoğu zaman than kullanılır. Doğru cevap "$answer".';
      case 'a2_superlatives':
        return 'Bir grubun en üstün üyesini anlatırken the + -est veya the most kullanılır. Doğru cevap "$answer".';
      case 'a2_countable_uncountable':
        return 'İsmin sayılabilen mi sayılamayan mı olduğuna göre miktar ifadesini seç. Doğru cevap "$answer".';
      case 'a2_some_any_much_many':
        return 'Cümle türünü ve ismin sayılabilirliğini kontrol et: some/any, much/many veya a lot of. Doğru cevap "$answer".';
      case 'a2_should':
        return 'Tavsiye için should/shouldn\'t + V1 kullanılır. Bu cümlede doğru cevap "$answer".';
      case 'a2_must_have_to':
        return 'Zorunluluk, yasak ve gerekmeme anlamlarını ayır: must, have to, mustn\'t, don\'t have to. Doğru cevap "$answer".';
      case 'a2_object_possessive_pronouns':
        return 'Fiilden sonra nesne zamiri, ismin yerine ise sahiplik zamiri kullanılır. Doğru cevap "$answer".';
      case 'a2_adverbs_frequency_manner':
        return 'Zarfın eylemin sıklığını mı, yapılış biçimini mi anlattığını ve cümledeki yerini kontrol et. Doğru cevap "$answer".';
      case 'a2_infinitive_purpose':
        return 'Amaç bildirirken to + V1 kullanılır. Bu cümlede doğru cevap "$answer".';
      case 'a2_gerund_infinitive':
        return 'İlk fiilin istediği kalıbı seç: V-ing veya to + V1. Doğru cevap "$answer".';
    }
  }

  return quizExplanationDisplay(source, isEnglish);
}

List<GrammarQuizQuestion> fillBlankQuizPackForLesson(
    GrammarLesson lesson, bool isEnglish) {
  final key = grammarLessonKey(lesson);
  final specs = _clozeBankForKey(key);

  final questions = <GrammarQuizQuestion>[];
  final seenQuestions = <String>{};

  bool reserveQuestion(String sentence, String answer) {
    final questionKey = '${sentence.toLowerCase()}|${answer.toLowerCase()}';
    return seenQuestions.add(questionKey);
  }

  for (var i = 0; i < lesson.quiz.length && questions.length < 10; i++) {
    final source = lesson.quiz[i];
    final sentence = _normalizeBlankMarker(
      source.sentence?.trim().isNotEmpty == true
          ? source.sentence!
          : source.prompt,
    );
    final answer = _cleanQuizOptionText(source.answer);
    if (!sentence.contains('_____') || answer.isEmpty) continue;
    if (!reserveQuestion(sentence, answer)) continue;

    final options = _balancedFillBlankOptions(
      source.options,
      answer,
      key,
      questions.length,
    );
    if (options.length != 4) continue;

    questions.add(
      GrammarQuizQuestion(
        id: source.id.isEmpty ? 'curated_${key}_$i' : source.id,
        type: GrammarQuizType.fillBlank,
        prompt:
            isEnglish ? 'Complete the sentence.' : 'Bo\u015flu\u011fu doldur.',
        sentence: sentence,
        options: options,
        answer: answer,
        explanation: _a1A2ClozeExplanation(key, source, answer, isEnglish),
      ),
    );
  }

  void addSpec(_ClozeSpec spec, int index) {
    final answer = repairGrammarMojibake(spec.answer.trim());
    final sentence =
        _normalizeBlankMarker(repairGrammarMojibake(spec.sentence));
    if (!reserveQuestion(sentence, answer)) return;
    final opts = _fillBlankOptions(
        spec.options.map(repairGrammarMojibake).toList(growable: false),
        answer);
    if (opts.length != 4) return;
    questions.add(
      GrammarQuizQuestion(
        id: 'cloze_${key}_$index',
        type: GrammarQuizType.fillBlank,
        prompt: isEnglish ? 'Complete the sentence.' : 'Boşluğu doldur.',
        sentence: sentence,
        options: opts,
        answer: answer,
        explanation: repairGrammarMojibake(
            isEnglish ? spec.explanationEn : spec.explanationTr),
      ),
    );
  }

  for (var i = 0; i < specs.length; i++) {
    addSpec(specs[i], i);
    if (questions.length >= 10) break;
  }

  if (questions.length >= 8) return questions;

  // Generic fallback generator: build cloze from clean example sentences.
  final sentencePool = <String>[
    ..._exampleBankForKey(key, true),
    ...lesson.examples,
    lesson.right,
    lesson.modelAnswer,
    ...normalizedGrammarFormulaRowsFor(lesson).map((row) => row.sample),
    ...generateGrammarLogicPoints(lesson).map((p) => p.model),
  ]
      .map(_cleanOptionSentence)
      .where((s) =>
          s.isNotEmpty &&
          _isSentenceLike(s) &&
          !_looksLikeMetaOption(s) &&
          !_contextLooksTeacherish(s))
      .toList(growable: false);

  final tokens = <String>[
    ..._blankTokenCandidatesForKey(key),
    ..._genericClozeTokensForKey(key),
  ];
  for (final s in sentencePool) {
    if (questions.length >= 10) break;
    var generatedForSentence = 0;
    for (final token in tokens) {
      if (questions.length >= 10 || generatedForSentence >= 2) {
        break;
      }
      final built = _buildTokenCloze(s, [token]);
      if (built == null) continue;
      final questionKey =
          '${built.sentence.toLowerCase()}|${built.answer.toLowerCase()}';
      if (!seenQuestions.add(questionKey)) continue;

      final opts = _balancedFillBlankOptions(
        _distractorsForToken(built.answer, key),
        built.answer,
        key,
        questions.length,
      );
      if (opts.length != 4) continue;

      questions.add(GrammarQuizQuestion(
        id: 'auto_${key}_${questions.length}',
        type: GrammarQuizType.fillBlank,
        prompt: isEnglish ? 'Complete the sentence.' : 'Boşluğu doldur.',
        sentence: _normalizeBlankMarker(repairGrammarMojibake(built.sentence)),
        options: opts,
        answer: repairGrammarMojibake(built.answer),
        explanation: isEnglish
            ? _generatedClozeExplanation(built.answer, true)
            : _generatedClozeExplanation(built.answer, false),
      ));
      generatedForSentence++;
    }
  }

  return questions.take(10).toList(growable: false);
}

List<String> _genericClozeTokensForKey(String key) {
  final tokens = <String>[];

  void addAll(Iterable<String> values) {
    for (final value in values) {
      if (!tokens.contains(value)) tokens.add(value);
    }
  }

  if (key.contains('perfect')) {
    addAll(const [
      'will have been',
      'will have',
      'had been',
      'have been',
      'has been',
      'had',
      'have',
      'has',
      'been',
    ]);
  }
  if (key.contains('conditional') || key.contains('wish')) {
    addAll(const [
      'would have',
      'could have',
      'might have',
      'would',
      'could',
      'if',
      'unless',
      'had',
      'were',
    ]);
  }
  if (key.contains('modal')) {
    addAll(const [
      'must have',
      'might have',
      'could have',
      'should have',
      'must',
      'might',
      'could',
      'should',
      'may',
    ]);
  }
  if (key.contains('passive') || key.contains('causative')) {
    addAll(const [
      'is believed to',
      'are believed to',
      'was said to',
      'were said to',
      'have been',
      'has been',
      'was',
      'were',
      'is',
      'are',
      'been',
      'being',
      'get',
      'have',
    ]);
  }
  if (key.contains('reported')) {
    addAll(const ['had', 'would', 'could', 'said', 'told', 'asked', 'whether']);
  }
  if (key.contains('relative')) {
    addAll(const ['whose', 'which', 'who', 'that', 'where', 'when']);
  }
  if (key.contains('inversion')) {
    addAll(const [
      'under no circumstances',
      'not only',
      'only then',
      'rarely',
      'never',
      'hardly',
      'seldom',
      'had',
      'have',
      'has',
      'did',
      'do',
      'does',
      'were',
      'should',
    ]);
  }
  if (key.contains('link') ||
      key.contains('concession') ||
      key.contains('discourse')) {
    addAll(const [
      'even though',
      'as a result',
      'in spite of',
      'although',
      'despite',
      'however',
      'therefore',
      'whereas',
      'while',
    ]);
  }
  if (key.contains('comparison')) {
    addAll(const ['as much as', 'as many as', 'than', 'as', 'more', 'less']);
  }
  if (key.contains('gerund') || key.contains('infinitive')) {
    addAll(const [
      'remember to',
      'to lock',
      'to buy',
      'to answer',
      'locking',
      'drinking',
      'calling',
      'telling',
      'remember',
      'stopped',
      'tried',
      'regret',
      'being',
      'having',
      'to',
    ]);
  }
  if (key.contains('precision_modality')) {
    addAll(const [
      'cannot be ruled out',
      'likely to',
      'unlikely to',
      'may well',
      'conceivably',
      'arguably',
      'well',
    ]);
  }

  addAll(const [
    'will have been',
    'will have',
    'would have',
    'could have',
    'should have',
    'might have',
    'must have',
    'had been',
    'have been',
    'has been',
    'would',
    'should',
    'could',
    'might',
    'must',
    'will',
    'may',
    'can',
    'had',
    'have',
    'has',
    'was',
    'were',
    'is',
    'are',
    'am',
    'been',
    'being',
    'does',
    'do',
    'did',
    'to',
    'than',
    'who',
    'which',
    'that',
    'if',
    'unless',
    'although',
    'despite',
    'however',
    'therefore',
    'whose',
    'where',
    'when',
    'so',
    'such',
    'enough',
    'too',
    'the',
    'an',
    'a',
  ]);

  return tokens;
}

String _generatedClozeExplanation(String answer, bool isEnglish) {
  final cleanAnswer = repairGrammarMojibake(answer).trim();
  if (isEnglish) {
    return '"$cleanAnswer" completes the target grammar pattern in this sentence.';
  }
  return '"$cleanAnswer" bu cümlede hedef dil bilgisi kalıbını doğru biçimde tamamlar.';
}

List<String> _fillBlankOptions(List<String> raw, String answer) {
  final seen = <String>{};
  final out = <String>[];
  void add(String v) {
    final clean = _cleanQuizOptionText(v);
    if (clean.isEmpty) return;
    final key = clean.toLowerCase();
    if (seen.contains(key)) return;
    seen.add(key);
    out.add(clean);
  }

  for (final o in raw) {
    add(o);
  }
  add(answer);

  return out.take(4).toList(growable: false);
}

List<_ClozeSpec> _clozeBankForKey(String key) {
  // Premium: sentence is natural, answer is unique, distractors are plausible.
  switch (key) {
    case 'a1_be_verb':
      return const [
        _ClozeSpec(
          sentence: 'I _____ hungry.',
          answer: 'am',
          options: ['am', 'is', 'are', 'be'],
          explanationTr:
              'I öznesi ile be verb olarak "am" kullanılır: I am hungry. "is/are" I ile kullanılmaz.',
          explanationEn: 'With ?I?, the correct be verb is "am": I am hungry.',
        ),
        _ClozeSpec(
          sentence: 'She _____ at home.',
          answer: 'is',
          options: ['is', 'am', 'are', 'be'],
          explanationTr:
              'She ile "is" gelir: She is at home. "are" çoğul/you için, "am" sadece I içindir.',
          explanationEn: 'With ?she?, use "is": She is at home.',
        ),
        _ClozeSpec(
          sentence: 'They _____ students.',
          answer: 'are',
          options: ['are', 'is', 'am', 'be'],
          explanationTr:
              'They çoğuldur, bu yüzden "are" kullanılır: They are students.',
          explanationEn: 'With ?they?, use "are": They are students.',
        ),
        _ClozeSpec(
          sentence: '_____ you tired?',
          answer: 'Are',
          options: ['Are', 'Is', 'Am', 'Do'],
          explanationTr:
              'Soruda be verb başa gelir: Are you tired? "Do" be verb sorularında kullanılmaz.',
          explanationEn: 'In questions, be verb comes first: Are you tired?',
        ),
        _ClozeSpec(
          sentence: 'He _____ not ready.',
          answer: 'is',
          options: ['is', 'are', 'am', 'do'],
          explanationTr:
              'Olumsuzda "not" be verbden sonra gelir: He is not ready.',
          explanationEn: 'In negatives, ?not? comes after be: He is not ready.',
        ),
      ];
    case 'a1_present_simple':
      return const [
        _ClozeSpec(
          sentence: 'She _____ to school every day.',
          answer: 'goes',
          options: ['goes', 'go', 'going', 'went'],
          explanationTr:
              'He/She/It ile Present Simple olumlu cümlede fiile -s/-es gelir: she goes. "go" eksik kalır.',
          explanationEn:
              'With he/she/it, Present Simple affirmative takes -s/-es: she goes.',
        ),
        _ClozeSpec(
          sentence: 'They _____ coffee in the morning.',
          answer: 'drink',
          options: ['drink', 'drinks', 'drinking', 'drank'],
          explanationTr:
              'They ile fiil yalın kalır: they drink. -s sadece he/she/it ile gelir.',
          explanationEn: 'With they, use base verb: they drink.',
        ),
        _ClozeSpec(
          sentence: 'He _____ like tea.',
          answer: "doesn't",
          options: ["doesn't", "don't", "isn't", "didn't"],
          explanationTr:
              'Olumsuz Present Simple: he doesn\'t + V1. "don\'t" I/you/we/they içindir.',
          explanationEn: 'Present Simple negative with he: he doesn\'t + V1.',
        ),
        _ClozeSpec(
          sentence: '_____ she work here?',
          answer: 'Does',
          options: ['Does', 'Do', 'Is', 'Did'],
          explanationTr:
              'Soruda Does + özne + V1 kullanılır: Does she work? "works" olmaz çünkü does zaten -s ekini taşır.',
          explanationEn: 'Use Does + subject + base verb: Does she work&?',
        ),
        _ClozeSpec(
          sentence: 'We _____ usually eat out.',
          answer: "don't",
          options: ["don't", "doesn't", "isn't", "aren't"],
          explanationTr:
              'We ile olumsuz: don\'t + V1. "doesn\'t" he/she/it içindir.',
          explanationEn: 'With we, negative is don\'t + base verb.',
        ),
      ];
    case 'a1_present_continuous':
      return const [
        _ClozeSpec(
          sentence: 'They _____ watching a movie now.',
          answer: 'are',
          options: ['are', 'is', 'am', 'do'],
          explanationTr:
              'Present Continuous: am/is/are + V-ing. They ile "are" kullanılır: They are watching.',
          explanationEn:
              'Present Continuous uses am/is/are + V-ing. With they, use are.',
        ),
        _ClozeSpec(
          sentence: 'She _____ studying at the moment.',
          answer: 'is',
          options: ['is', 'are', 'am', 'does'],
          explanationTr:
              'She ile "is" gelir: She is studying. Yardımcı fiil olmadan V-ing tek başına yetmez.',
          explanationEn: 'With she, use is: She is studying&',
        ),
        _ClozeSpec(
          sentence: 'I _____ not working today.',
          answer: 'am',
          options: ['am', 'is', 'are', 'do'],
          explanationTr: 'I ile "am" kullanılır: I am not working today.',
          explanationEn: 'With I, use am: I am not working today.',
        ),
        _ClozeSpec(
          sentence: '_____ you coming with us?',
          answer: 'Are',
          options: ['Are', 'Do', 'Is', 'Does'],
          explanationTr:
              'Present Continuous sorusu: Are you coming? "Do" ile kurulmaz.',
          explanationEn: 'Present Continuous question: Are you coming&?',
        ),
      ];
    case 'a1_can_cant':
      return const [
        _ClozeSpec(
          sentence: 'I _____ swim, but I can\'t dive.',
          answer: 'can',
          options: ['can', 'am', 'do', 'have'],
          explanationTr:
              'Yetenek için "can" kullanırız: I can swim. Can kelimesinden sonra fiil yalın gelir.',
          explanationEn:
              'Use ?can? for ability: I can swim. After can, use the base verb.',
        ),
        _ClozeSpec(
          sentence: 'She _____ speak English very well.',
          answer: 'can',
          options: ['can', 'cans', 'can to', 'is'],
          explanationTr:
              'Can, he/she/it ile -s almaz: She can speak. "cans" yanlış.',
          explanationEn: 'Can never takes -s: She can speak& ?cans? is wrong.',
        ),
        _ClozeSpec(
          sentence: 'He _____ drive. He is only 14.',
          answer: "can't",
          options: ["can't", "doesn't", "isn't", "don't"],
          explanationTr:
              'Olumsuz yetenek: can\'t/cannot + V1. "doesn\'t" can ile kullanılmaz.',
          explanationEn: 'Negative ability: can\'t/cannot + base verb.',
        ),
        _ClozeSpec(
          sentence: '_____ you help me, please?',
          answer: 'Can',
          options: ['Can', 'Do', 'Are', 'Does'],
          explanationTr:
              'Soru: Can + özne + V1? Do/does can sorularında kullanılmaz.',
          explanationEn: 'Questions start with Can: Can you&?',
        ),
        _ClozeSpec(
          sentence: 'Can you _____ the window? (request)',
          answer: 'open',
          options: ['open', 'opens', 'opening', 'to open'],
          explanationTr:
              'Can kelimesinden sonra fiil yalın gelir: can open. "to open" veya "opens" olmaz.',
          explanationEn: 'After can, use base verb: can open (no "to", no -s).',
        ),
        _ClozeSpec(
          sentence: 'No, I _____ . I can\'t come today.',
          answer: "can't",
          options: ["can't", "am not", "don't", "isn't"],
          explanationTr:
              'Kısa cevap: No, I can\'t. "Can you?" sorusuna cevapta can/can\'t kullanılır.',
          explanationEn: 'Short answer mirrors the question: No, I can\'t.',
        ),
      ];
    case 'a2_past_simple':
      return const [
        _ClozeSpec(
          sentence: 'Ali _____ football yesterday.',
          answer: 'played',
          options: ['played', 'play', 'plays', 'playing'],
          explanationTr:
              'Bitmiş geçmiş zaman (yesterday) varsa Past Simple kullanılır. Olumlu cümlede fiil V2 olur: play -> played.',
          explanationEn:
              'With a finished past time (yesterday), use Past Simple: play -> played.',
        ),
        _ClozeSpec(
          sentence: 'She _____ go to school yesterday.',
          answer: "didn't",
          options: ["didn't", "doesn't", "isn't", "wasn't"],
          explanationTr:
              'Past Simple olumsuz: didn\'t + V1. ?wasn\'t? sadece be verb ile olur (wasn\'t at school).',
          explanationEn: 'Past Simple negative uses didn\'t + base verb (V1).',
        ),
        _ClozeSpec(
          sentence: '_____ you watch the film last night?',
          answer: 'Did',
          options: ['Did', 'Do', 'Are', 'Were'],
          explanationTr:
              'Geçmişte bitmiş zaman (last night) için soru ?Did + özne + V1? olur: Did you watch...?',
          explanationEn: 'Past Simple question: Did + subject + base verb.',
        ),
        _ClozeSpec(
          sentence: 'Where did he _____ after school?',
          answer: 'go',
          options: ['go', 'went', 'going', 'goes'],
          explanationTr:
              'Did geldikten sonra fiil V1 olur: go. "went" sadece olumlu Past Simple\'da kullanılır.',
          explanationEn: 'After did, use base verb (go), not went.',
        ),
        _ClozeSpec(
          sentence: 'We _____ to the park two days ago.',
          answer: 'went',
          options: ['went', 'go', 'goes', 'going'],
          explanationTr:
              'Olumlu Past Simple\'da düzensiz fiil V2 olur: go -> went. "two days ago" bitmiş zamandır.',
          explanationEn:
              'In affirmative Past Simple, irregular verbs use V2: go -> went.',
        ),
      ];
    case 'a2_past_continuous':
      return const [
        _ClozeSpec(
          sentence: 'They _____ watching TV at 9 pm.',
          answer: 'were',
          options: ['were', 'was', 'are', 'did'],
          explanationTr:
              'Past Continuous: was/were + V-ing. They ile ?were? kullanılır.',
          explanationEn:
              'Past Continuous uses was/were + V-ing. With they, use were.',
        ),
        _ClozeSpec(
          sentence: 'I _____ cooking when you called.',
          answer: 'was',
          options: ['was', 'were', 'am', 'did'],
          explanationTr:
              'I ile Past Continuous\'da ?was? gelir: I was cooking&',
          explanationEn: 'With I, use was: I was cooking&',
        ),
        _ClozeSpec(
          sentence: 'She _____ not listening.',
          answer: 'was',
          options: ['was', 'were', 'did', 'is'],
          explanationTr: 'Olumsuz Past Continuous: was/were + not + V-ing.',
          explanationEn: 'Negative Past Continuous: was/were + not + V-ing.',
        ),
        _ClozeSpec(
          sentence: '_____ you studying at 8?',
          answer: 'Were',
          options: ['Were', 'Was', 'Did', 'Do'],
          explanationTr: 'Soruda was/were başa gelir: Were you studying&?',
          explanationEn: 'Questions: Was/Were + subject + V-ing?',
        ),
      ];
    case 'a2_will':
      return const [
        _ClozeSpec(
          sentence: 'I think it _____ rain tomorrow.',
          answer: 'will',
          options: ['will', 'is', 'does', 'did'],
          explanationTr:
              'Tahmin için will kullanılır: I think it will rain& Will\'den sonra fiil yal?n kalır.',
          explanationEn: 'Use will for predictions: I think it will rain&',
        ),
        _ClozeSpec(
          sentence: 'I _____ help you. Don\'t worry.',
          answer: 'will',
          options: ['will', 'am', 'do', 'did'],
          explanationTr:
              'Konuşma anında verilen söz/karar için will kullanılır: I will help you.',
          explanationEn:
              'Use will for a quick decision/promise: I will help you.',
        ),
        _ClozeSpec(
          sentence: 'He will _____ you later.',
          answer: 'call',
          options: ['call', 'calls', 'called', 'calling'],
          explanationTr:
              'Will\'den sonra fiil V1 olur: will call. ?will calls? olmaz.',
          explanationEn: 'After will, use base verb: will call.',
        ),
        _ClozeSpec(
          sentence: '_____ you help me with this?',
          answer: 'Will',
          options: ['Will', 'Do', 'Did', 'Are'],
          explanationTr: 'Will ile soru: Will you + V1...?',
          explanationEn: 'Will questions: Will you + base verb&?',
        ),
      ];
    case 'a2_going_to':
      return const [
        _ClozeSpec(
          sentence: 'I _____ going to study tonight.',
          answer: 'am',
          options: ['am', 'is', 'are', 'do'],
          explanationTr:
              'Be going to: am/is/are going to + V1. I ile "am" gerekir.',
          explanationEn: 'Be going to needs am/is/are. With I, use am.',
        ),
        _ClozeSpec(
          sentence: 'She is going to _____ next month.',
          answer: 'travel',
          options: ['travel', 'travels', 'traveled', 'traveling'],
          explanationTr: 'Going to\'dan sonra fiil V1 olur: going to travel.',
          explanationEn: 'After going to, use base verb: going to travel.',
        ),
        _ClozeSpec(
          sentence: '_____ you going to join us?',
          answer: 'Are',
          options: ['Are', 'Do', 'Did', 'Will'],
          explanationTr: 'Soru: Are you going to&? (be verb başa gelir).',
          explanationEn: 'Questions: Are you going to&?',
        ),
        _ClozeSpec(
          sentence: 'They _____ going to buy a car. (They decided not to.)',
          answer: "aren't",
          options: ["aren't", "don't", "didn't", "won't"],
          explanationTr:
              'Going to olumsuz: am/is/are + not. They � aren\'t going to&',
          explanationEn: 'Negative: am/is/are + not going to&',
        ),
      ];
    case 'a2_must_have_to':
      return const [
        _ClozeSpec(
          sentence: 'You _____ wear a seatbelt.',
          answer: 'must',
          options: ['must', 'should', 'can', 'did'],
          explanationTr:
              'Zorunluluk için must kullanılır: You must wear& "should" tavsiyedir.',
          explanationEn: 'Use must for obligation: You must wear&',
        ),
        _ClozeSpec(
          sentence: 'You _____ smoke here. (It\'s forbidden.)',
          answer: "mustn't",
          options: ["mustn't", "don't have to", "shouldn't", "can't to"],
          explanationTr:
              'Mustn?t = yasak. ?Don\'t have to? yasak değil, mecbur değilsin anlamıdır.',
          explanationEn: 'Mustn?t means prohibition (forbidden).',
        ),
        _ClozeSpec(
          sentence: 'I _____ to wake up early tomorrow.',
          answer: 'have',
          options: ['have', 'has', 'had', 'am'],
          explanationTr:
              'I ile "have to? kullanılır: I have to& ?has to? he/she/it içindir.',
          explanationEn: 'With I, use have to: I have to&',
        ),
        _ClozeSpec(
          sentence: 'He _____ to show his ID.',
          answer: 'has',
          options: ['has', 'have', 'had', 'is'],
          explanationTr: 'He/she/it ile ?has to? gelir: He has to&',
          explanationEn: 'With he/she/it, use has to: He has to&',
        ),
        _ClozeSpec(
          sentence: 'You _____ have to come today. (It\'s optional.)',
          answer: "don't",
          options: ["don't", "mustn't", "doesn't", "isn't"],
          explanationTr:
              'Don\'t have to = mecbur değilsin. ?mustn\'t? yasaktır; anlam? farklıdır.',
          explanationEn:
              'Don\'t have to means no necessity (optional), not prohibition.',
        ),
      ];
    case 'a2_present_perfect':
    case 'b1_present_perfect':
      return const [
        _ClozeSpec(
          sentence: 'I _____ never been to London.',
          answer: 'have',
          options: ['have', 'has', 'did', 'am'],
          explanationTr:
              'Present Perfect: have/has + V3. I ile "have" gelir: I have never been. "has" he/she/it içindir.',
          explanationEn: 'Present Perfect: have/has + V3. With I, use have.',
        ),
        _ClozeSpec(
          sentence: 'She _____ already finished her work.',
          answer: 'has',
          options: ['has', 'have', 'did', 'is'],
          explanationTr:
              'She ile "has" kullanılır: She has already finished. "have" I/you/we/they içindir.',
          explanationEn: 'With she, use has: She has already finished.',
        ),
        _ClozeSpec(
          sentence: '_____ you ever tried sushi?',
          answer: 'Have',
          options: ['Have', 'Has', 'Did', 'Are'],
          explanationTr:
              'Present Perfect soru: Have you ever...? Deneyim sorarken Past Simple "Did" değil, Present Perfect kullanırız.',
          explanationEn:
              'Experience questions use Present Perfect: Have you ever...?',
        ),
        _ClozeSpec(
          sentence: 'They _____ seen this film yet.',
          answer: "haven't",
          options: ["haven't", "hasn't", "didn't", "aren't"],
          explanationTr:
              'They ile olumsuz Present Perfect: haven\'t + V3. "hasn\'t" he/she/it içindir.',
          explanationEn: 'With they, negative is haven\'t + V3.',
        ),
        _ClozeSpec(
          sentence: 'I have just _____.',
          answer: 'arrived',
          options: ['arrived', 'arrive', 'arrives', 'arriving'],
          explanationTr:
              '"have + V3" yapısında fiil V3 olur: have just arrived. "arrive" (V1) burada eksik kalır.',
          explanationEn:
              'After have/has, use past participle (V3): have just arrived.',
        ),
      ];
    case 'a2_should':
      return const [
        _ClozeSpec(
          sentence: 'You _____ see a doctor.',
          answer: 'should',
          options: ['should', 'must', 'can', 'did'],
          explanationTr:
              'Tavsiye verirken "should" kullanırız: You should see a doctor. "must" daha çok zorunluluktur.',
          explanationEn:
              'Use "should" to give advice: You should see a doctor.',
        ),
        _ClozeSpec(
          sentence: 'You _____ stay up late tonight.',
          answer: "shouldn't",
          options: ["shouldn't", "don't", "mustn't", "can't"],
          explanationTr:
              'Olumsuz tavsiye: shouldn\'t + V1. "mustn\'t" yasak anlamına kayabilir; tavsiyede en doğal seçenek shouldn\'t.',
          explanationEn: 'Negative advice uses shouldn\'t + base verb.',
        ),
        _ClozeSpec(
          sentence: '_____ I call her now?',
          answer: 'Should',
          options: ['Should', 'Do', 'Did', 'Am'],
          explanationTr:
              'Should sorusu: Should I + V1...? "Do" yardımcı fiili burada kullanılmaz.',
          explanationEn: 'Should questions: Should I + base verb?',
        ),
        _ClozeSpec(
          sentence: 'You _____ to rest today.',
          answer: 'ought',
          options: ['ought', 'should', 'must', 'will'],
          explanationTr:
              '"ought to" tavsiye verir. Cümlede boşluk "ought"tur çünkü devamında "to" zaten var: ought to rest.',
          explanationEn:
              '"ought to" is advice. If "to" is already there, the blank is "ought".',
        ),
      ];
    default:
      return const [];
  }
}

class _TokenCloze {
  final String sentence;
  final String answer;
  const _TokenCloze(this.sentence, this.answer);
}

List<String> _blankTokenCandidatesForKey(String key) {
  switch (key) {
    case 'a1_be_verb':
      return const ['am', 'is', 'are'];
    case 'a1_present_simple':
      return const ["don't", "doesn't", 'do', 'does', 'goes', 'works', 'likes'];
    case 'a1_present_continuous':
      return const ['am', 'is', 'are'];
    case 'a1_subject_pronouns':
      return const ['I', 'you', 'he', 'she', 'it', 'we', 'they'];
    case 'a1_singular_plural':
      return const ['books', 'boxes', 'children', 'bags', 'chairs', 'pens'];
    case 'a1_have_has_got':
      return const ['have got', 'has got', 'have', 'has'];
    case 'a1_basic_prepositions':
      return const ['in', 'on', 'at'];
    case 'a1_imperatives':
      return const ['Open', 'sit', 'Listen', 'Write', "Don't", 'Do not'];
    case 'a2_past_simple':
      return const ["didn't", 'did', 'went', 'saw', 'bought'];
    case 'a2_past_continuous':
      return const ['was', 'were'];
    case 'a2_present_perfect':
    case 'a2_present_perfect_vs_past':
    case 'b1_present_perfect':
      return const ["haven't", "hasn't", 'have', 'has', 'been'];
    case 'b1_present_perfect_continuous':
      return const ['have been', 'has been', 'been'];
    case 'b1_past_perfect':
      return const ['had'];
    case 'b1_past_perfect_continuous':
      return const ['had been', 'had'];
    case 'a2_should':
      return const ["shouldn't", 'should', 'ought to', 'had better'];
    case 'a2_must_have_to':
      return const ["mustn't", 'must', 'have to', 'has to', "don't have to"];
    case 'a2_will':
      return const ["won't", 'will'];
    case 'a2_going_to':
      return const ['am going to', 'is going to', 'are going to', 'going to'];
    case 'a2_first_conditional':
      return const ['if', 'will', "won't", 'unless'];
    case 'a2_zero_conditional':
      return const ['if', 'when'];
    case 'a2_comparatives':
      return const ['than', 'more', 'better', 'worse'];
    case 'a2_superlatives':
      return const ['the most', 'the best', 'the worst', 'the'];
    default:
      if (key.contains('passive'))
        return const ['was', 'were', 'is', 'are', 'been'];
      if (key.contains('reported')) return const ['said', 'told', 'asked'];
      if (key.contains('relative'))
        return const ['who', 'which', 'that', 'where'];

      // Fall back to signature-based tokens so every topic can generate cloze.
      final sig = _exampleSignatureGroupsForKey(key);
      if (sig.isNotEmpty) {
        final tokens = <String>[];
        for (final group in sig) {
          for (final token in group) {
            // Avoid pronoun-like tokens; quizzes should target grammar, not ?which pronoun? here.
            if (const {
              'i',
              'you',
              'he',
              'she',
              'it',
              'we',
              'they',
              'me',
              'him',
              'her',
              'us',
              'them'
            }.contains(token.toLowerCase())) {
              continue;
            }
            if (!tokens.contains(token)) tokens.add(token);
          }
        }
        return tokens.take(8).toList(growable: false);
      }
      return const [];
  }
}

_TokenCloze? _buildTokenCloze(String sentence, List<String> candidateTokens) {
  final clean = sentence.trim();
  if (clean.isEmpty) return null;
  for (final token in candidateTokens) {
    final pattern =
        RegExp(r'\b' + RegExp.escape(token) + r'\b', caseSensitive: false);
    final m = pattern.firstMatch(clean);
    if (m == null) continue;
    final answer = clean.substring(m.start, m.end);
    final withBlank = clean.replaceRange(m.start, m.end, '_____');
    return _TokenCloze(withBlank, answer);
  }
  return null;
}

List<String> _distractorsForToken(String answer, String key) {
  final a = answer.trim();
  final lower = a.toLowerCase();

  // Token-level distractors: keep them plausible and in the same ?slot?.
  if (key == 'a1_be_verb') return [a, 'is', 'are', 'am'];
  if (key == 'a1_present_continuous') return [a, 'is', 'are', 'am'];
  if (key == 'a2_past_continuous') return [a, 'was', 'were', 'did'];
  if (key.contains('present_perfect')) return [a, 'have', 'has', 'did'];
  if (key == 'a2_should') return [a, 'should', 'must', 'can'];
  if (key == 'a2_must_have_to') return [a, 'must', 'have to', "don't have to"];
  if (key == 'a2_will') return [a, 'will', "won't", 'going to'];
  if (key == 'a2_going_to') return [a, 'am going to', 'will', 'going'];
  if (key == 'a1_articles') return [a, 'a', 'an', 'the'];
  if (key == 'a1_there_is_are') return [a, 'is', 'are', 'am'];
  if (key == 'a1_some_any') return [a, 'some', 'any', 'many'];
  if (key == 'a1_how_much_many') return [a, 'many', 'much', 'some'];
  if (key == 'a1_can_cant') return [a, 'can', "can't", 'cannot'];
  if (key == 'a1_demonstratives') return [a, 'this', 'that', 'these', 'those'];
  if (key == 'a1_possessive_adjectives')
    return [a, 'my', 'your', 'his', 'her', 'their'];
  if (key == 'a1_subject_pronouns') return [a, 'I', 'you', 'he', 'she'];
  if (key == 'a1_singular_plural')
    return [a, 'book', 'books', 'child', 'children'];
  if (key == 'a1_have_has_got')
    return [a, 'have got', 'has got', 'have', 'has'];
  if (key == 'a1_basic_prepositions') return [a, 'in', 'on', 'at', 'to'];
  if (key == 'a1_imperatives') {
    if (lower == "don't" || lower == 'do not')
      return [a, "Don't", 'Do', 'Not', 'No'];
    return [a, 'open', 'opens', 'opening', 'to open'];
  }
  if (key == 'a1_object_pronouns') return [a, 'me', 'him', 'her', 'them'];

  // Generic fallback: light variations.
  if (lower == 'am') return const ['am', 'is', 'are', 'be'];
  if (lower == 'is') return const ['is', 'am', 'are', 'be'];
  if (lower == 'are') return const ['are', 'is', 'am', 'be'];
  if (lower == 'do') return const ['do', 'does', 'did', 'done'];
  if (lower == 'does') return const ['does', 'do', 'did', 'done'];
  if (lower == 'did') return const ['did', 'do', 'does', 'done'];
  if (lower == 'have') return const ['have', 'has', 'had', 'did'];
  if (lower == 'has') return const ['has', 'have', 'had', 'did'];
  if (lower == 'had') return const ['had', 'have', 'has', 'did'];

  return [
    a,
    _smallGrammarSlip(a, 1),
    _smallGrammarSlip(a, 2),
    _smallGrammarSlip(a, 3)
  ];
}

List<String> _exampleBankForKey(String key, bool isEnglish) => const [];

List<Set<String>> _exampleSignatureGroupsForKey(String key) => const [];

String _rowKind(GrammarFormulaRow row) {
  final raw = '${row.label} ${row.pattern}'.toLowerCase();
  if (raw.contains('negative') || raw.contains('not')) return 'negative';
  if (raw.contains('question') || raw.contains('?')) return 'question';
  if (raw.contains('time')) return 'time';
  if (raw.contains('avoid')) return 'avoid';
  return 'model';
}

String _cleanOptionSentence(String value) {
  var clean = repairGrammarMojibake(value)
      .replaceAll('ï¿½R', '')
      .replaceAll('ï¿½S&', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (clean.isEmpty) return clean;
  final lower = clean.toLowerCase();
  if (lower.contains('did not went')) return 'I did not went to school.';
  if (lower.contains('will goes')) return 'She will goes tomorrow.';
  if (lower.contains('i going to study')) return 'I going to study tonight.';
  if (lower.contains('more better')) return 'This answer is more better.';
  final boundary = RegExp(r'[.!?]\s*(?=[A-Z])').firstMatch(clean);
  if (boundary != null && boundary.end < clean.length) {
    clean = clean.substring(0, boundary.start + 1).trim();
  }
  return clean;
}

bool _isSentenceLike(String value) {
  final clean = value.trim();
  if (clean.length < 4) return false;
  if (!RegExp(r'[A-Za-z]').hasMatch(clean)) return false;
  return clean.split(RegExp(r'\s+')).length >= 2;
}

bool _looksLikeMetaOption(String value) {
  final lower = value.toLowerCase();
  const blocked = [
    'choose ',
    'correct option',
    'rule',
    'grammar',
    'mistake:',
    'avoid:',
    'model:',
    'explanation',
  ];
  return blocked.any(lower.contains);
}

bool _contextLooksTeacherish(String value) {
  final lower = value.toLowerCase();
  const blocked = [
    'this lesson',
    'you use',
    'we use',
    'remember',
    'rule',
    'pattern',
    'structure',
  ];
  return blocked.any(lower.contains);
}

List<String> _sameTopicSlips(String right) => const [];

String _smartCommonMistake(String right, String wrong, bool isEnglish) {
  final cleanWrong = wrong.trim();
  if (cleanWrong.isNotEmpty &&
      cleanWrong.toLowerCase() != right.trim().toLowerCase()) {
    return cleanWrong;
  }
  return _smallGrammarSlip(right, 0);
}

String _safeFallbackByIndex(String right, int index) {
  final fallback = _smallGrammarSlip(right, index);
  if (fallback.trim().isNotEmpty &&
      fallback.toLowerCase() != right.trim().toLowerCase()) {
    return fallback;
  }
  const fallbacks = [
    'She work every day.',
    'I am study now.',
    'Did you went there?',
    'He will goes tomorrow.',
  ];
  return fallbacks[index % fallbacks.length];
}

GrammarQuizType _quizTypeForPoint(GrammarLogicPoint point, int index) {
  return GrammarQuizType.fillBlank;
}

GrammarQuizType _quizTypeForRow(GrammarFormulaRow row, int index) {
  return GrammarQuizType.fillBlank;
}

GrammarQuizType _quizTypeForExample(int index) {
  return GrammarQuizType.fillBlank;
}

String _quizPromptForPoint(
    GrammarLogicPoint point, String answer, int index, bool isEnglish) {
  final avoid = _cleanOptionSentence(point.avoid);
  final gap = _gapPromptFromSentence(answer);
  final type = _quizTypeForPoint(point, index);
  if (type == GrammarQuizType.fillBlank && gap.isNotEmpty) {
    return isEnglish ? 'Gap fill: $gap' : 'Boşluk doldur: $gap';
  }
  if (type == GrammarQuizType.errorCorrection && avoid.isNotEmpty) {
    return isEnglish
        ? 'Error correction: fix "$avoid".'
        : 'Hata düzeltme: "$avoid" cümlesini düzelt.';
  }
  if (type == GrammarQuizType.transformation && avoid.isNotEmpty) {
    return isEnglish
        ? 'Transformation: keep the meaning, but make the grammar natural.'
        : 'Dönüştürme: anlamı koru, grammar yapısını doğal yap.';
  }
  if (type == GrammarQuizType.sentenceOrder) {
    return isEnglish
        ? 'Sentence order: choose the option with the correct word order.'
        : 'Cümle sırası: doğru kelime sırasını seç.';
  }
  return isEnglish ? 'Choose the correct option.' : 'Doğru seçeneği seç.';
}

String _quizPromptForRow(
    GrammarFormulaRow row, String answer, int index, bool isEnglish) {
  final kind = _rowKind(row);
  final gap = _gapPromptFromSentence(answer);
  if (kind == 'question') {
    return isEnglish
        ? 'Question form: choose the correctly ordered question.'
        : 'Soru yapısı: doğru sıralanmış soruyu seç.';
  }
  if (kind == 'negative') {
    return isEnglish
        ? 'Negative form: choose the sentence that uses the negative correctly.'
        : 'Olumsuz yapı: olumsuzu doğru kullanan cümleyi seç.';
  }
  if (gap.isNotEmpty && index.isEven) {
    return isEnglish ? 'Gap fill: $gap' : 'Boşluk doldur: $gap';
  }
  return isEnglish
      ? 'Form check: which option follows "${row.pattern}"?'
      : 'Form kontrolü: hangi seçenek "${row.pattern}" kalıbına uyuyor?';
}

String _quizPromptForExample(String answer, int index, bool isEnglish) {
  final gap = _gapPromptFromSentence(answer);
  switch (_quizTypeForExample(index)) {
    case GrammarQuizType.fillBlank:
      return gap.isEmpty
          ? (isEnglish
              ? 'Gap fill: choose the best grammar form.'
              : 'Boşluk doldur: en iyi grammar formunu seç.')
          : (isEnglish ? 'Gap fill: $gap' : 'Boşluk doldur: $gap');
    case GrammarQuizType.errorCorrection:
      return isEnglish
          ? 'Error detection: which option is grammatically correct?'
          : 'Hata bulma: hangi seçenek grammar olarak doğru?';
    case GrammarQuizType.transformation:
      return isEnglish
          ? 'Transformation: choose the most natural corrected sentence.'
          : 'Dönüştürme: en doğal düzeltilmiş cümleyi seç.';
    case GrammarQuizType.sentenceOrder:
      return isEnglish
          ? 'Word order: choose the sentence with clean English order.'
          : 'Kelime sırası: temiz İngilizce sırayı seç.';
    default:
      return isEnglish ? 'Choose the correct option.' : 'Doğru seçeneği seç.';
  }
}

String _gapPromptFromSentence(String answer) {
  final words = _cleanOptionSentence(answer)
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .toList();
  if (words.length < 3) return '';
  final lowerWords = words
      .map((word) => word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''))
      .toList();
  final targets = [
    'am',
    'is',
    'are',
    'was',
    'were',
    'do',
    'does',
    'did',
    'have',
    'has',
    'had',
    'will',
    'would',
    'should',
    'must',
    'can',
    'might',
    'may',
    'been',
    'being',
    'to',
    'than'
  ];
  var targetIndex = lowerWords.indexWhere((word) => targets.contains(word));
  if (targetIndex < 0) targetIndex = words.length > 4 ? 2 : 1;
  final copy = [...words];
  copy[targetIndex] = '_____';
  return copy.join(' ');
}

String _quizTypeLabel(GrammarQuizType type, bool isEnglish) {
  switch (type) {
    case GrammarQuizType.fillBlank:
      return isEnglish ? 'Fill in the blank' : 'Boşluk doldurma';
    case GrammarQuizType.sentenceOrder:
      return isEnglish ? 'Word order' : 'Sıralama';
    case GrammarQuizType.errorCorrection:
      return isEnglish ? 'Correction' : 'Düzeltme';
    case GrammarQuizType.transformation:
      return isEnglish ? 'Transform' : 'Dönüştür';
    case GrammarQuizType.matching:
      return isEnglish ? 'Match' : 'Eşle';
    case GrammarQuizType.multipleChoice:
      return isEnglish ? 'Multiple choice' : 'Çoktan seçmeli';
  }
}

GrammarQuizQuestion _questionWithBalancedOptions(
    GrammarQuizQuestion question, int index) {
  final answer = question.answer.trim();
  final seen = <String>{};
  final options = <String>[];

  // If the lesson already provides a full, curated option set, do not inject
  // extra ?smart slips? that can create off-topic A1 distractors.
  final originalClean = question.options
      .map(_cleanQuizOptionText)
      .where((e) => e.trim().isNotEmpty)
      .toList(growable: false);
  if (originalClean.isNotEmpty) {
    final unique = <String>[];
    final uniqueKeys = <String>{};
    for (final o in originalClean) {
      final key = _quizAnswerKey(o);
      if (key.isEmpty || uniqueKeys.contains(key)) continue;
      uniqueKeys.add(key);
      unique.add(o);
    }
    final answerKey = _quizAnswerKey(answer);
    final hasAnswer = unique.any((o) => _quizAnswerKey(o) == answerKey);
    if (hasAnswer && unique.length >= 4) {
      final firstFour = unique.take(4).toList(growable: false);
      if (firstFour.any((o) => _quizAnswerKey(o) == answerKey)) {
        return GrammarQuizQuestion(
          id: question.id,
          type: question.type,
          prompt: question.prompt,
          options: firstFour,
          answer: question.answer,
          explanation: question.explanation,
          sentence: question.sentence,
          items: question.items,
          pairs: question.pairs,
        );
      }
      // If the curated answer exists but falls outside the first 4, keep 3 + answer.
      final withoutAnswer = firstFour
          .where((o) => _quizAnswerKey(o) != answerKey)
          .take(3)
          .toList();
      return GrammarQuizQuestion(
        id: question.id,
        type: question.type,
        prompt: question.prompt,
        options: [
          ...withoutAnswer,
          unique.firstWhere((o) => _quizAnswerKey(o) == answerKey)
        ],
        answer: question.answer,
        explanation: question.explanation,
        sentence: question.sentence,
        items: question.items,
        pairs: question.pairs,
      );
    }
  }

  bool isSentenceOptionType() {
    switch (question.type) {
      case GrammarQuizType.fillBlank:
      case GrammarQuizType.sentenceOrder:
        return false;
      case GrammarQuizType.multipleChoice:
      case GrammarQuizType.errorCorrection:
      case GrammarQuizType.transformation:
      case GrammarQuizType.matching:
        return true;
    }
  }

  void add(String value, {bool force = false}) {
    final clean = _cleanQuizOptionText(value);
    if (clean.isEmpty) return;
    if (!force && isSentenceOptionType()) {
      if (!_isSentenceLike(clean)) return;
      if (_looksLikeMetaOption(clean)) return;
    }
    final key = clean.toLowerCase();
    if (seen.contains(key)) return;
    seen.add(key);
    options.add(clean);
  }

  for (final option in question.options) {
    add(option);
  }
  add(answer, force: true);

  if (isSentenceOptionType()) {
    for (final slip in _sameTopicSlips(answer)) {
      add(slip);
      if (options.length >= 4) break;
    }
    add(_smartCommonMistake(answer, '', true));
  }

  var guard = 0;
  while (options.length < 4 && guard < 12) {
    add(_smallGrammarSlip(answer, guard));
    guard++;
  }

  final answerIndex =
      options.indexWhere((e) => e.trim().toLowerCase() == answer.toLowerCase());
  if (answerIndex == -1) {
    options.insert(0, answer);
  }

  final normalizedAnswerIndex =
      options.indexWhere((e) => e.trim().toLowerCase() == answer.toLowerCase());
  final answerText = options.removeAt(normalizedAnswerIndex);
  final targetSlots = [1, 3, 0, 2, 2, 0, 3, 1, 0, 2];
  final target = targetSlots[index % targetSlots.length].clamp(0, 3).toInt();

  final finalOptions = options.take(3).toList();
  while (finalOptions.length < 3) {
    finalOptions.add(_smallGrammarSlip(answer, finalOptions.length + index));
  }
  finalOptions.insert(target, answerText);

  return GrammarQuizQuestion(
    id: question.id,
    type: question.type,
    prompt: question.prompt,
    options: finalOptions.take(4).toList(),
    answer: question.answer,
    explanation: question.explanation,
  );
}

GrammarQuizQuestion legacyQuestionAsFillBlank(
  GrammarQuizQuestion question,
  int index,
  GrammarLesson lesson,
  bool isEnglish,
  String explanation,
) {
  final lessonKey = grammarLessonKey(lesson);
  var answer = _cleanQuizOptionText(question.answer);
  var sentence = _normalizeBlankMarker(question.sentence ?? '');

  if (!sentence.contains('_____')) {
    final fromPrompt = _extractBlankSentence(question.prompt);
    if (fromPrompt.isNotEmpty) sentence = fromPrompt;
  }

  if (!sentence.contains('_____') || _looksLikeSentenceAnswer(answer)) {
    final source = _bestClozeSource(question, lesson);
    final built =
        _buildTokenCloze(source, _blankTokenCandidatesForKey(lessonKey));
    if (built != null) {
      sentence = _normalizeBlankMarker(built.sentence);
      answer = _cleanQuizOptionText(built.answer);
    }
  }

  if (!sentence.contains('_____')) {
    final generated = fillBlankQuizPackForLesson(lesson, isEnglish);
    if (generated.isNotEmpty) {
      final fallback = generated[index % generated.length];
      sentence = _normalizeBlankMarker(fallback.sentence ?? '');
      answer = _cleanQuizOptionText(fallback.answer);
    }
  }

  if (answer.isEmpty) {
    final built =
        _buildTokenCloze(lesson.right, _blankTokenCandidatesForKey(lessonKey));
    if (built != null) {
      sentence = _normalizeBlankMarker(built.sentence);
      answer = _cleanQuizOptionText(built.answer);
    }
  }

  final options = _balancedFillBlankOptions(
    [
      ...question.options,
      ..._distractorsForToken(answer, lessonKey),
      _smallGrammarSlip(answer, index + 2),
      _smallGrammarSlip(answer, index + 3),
      _safeFallbackByIndex(answer, index + 4),
      _smallGrammarSlip(answer, index + 1),
      answer,
    ],
    answer,
    lessonKey,
    index,
  );

  return GrammarQuizQuestion(
    id: question.id,
    type: GrammarQuizType.fillBlank,
    prompt: isEnglish ? 'Complete the sentence.' : 'Boşluğu doldur.',
    sentence: sentence,
    options: options,
    answer: answer,
    explanation: explanation.trim().isEmpty
        ? (isEnglish
            ? 'The selected form fits the grammar pattern in the sentence.'
            : 'Seçilen form cümledeki grammar kalıbına uyar.')
        : explanation,
  );
}

List<String> _balancedFillBlankOptions(
  List<String> raw,
  String answer,
  String lessonKey,
  int index,
) {
  final cleanAnswer = _cleanQuizOptionText(answer);
  final seen = <String>{};
  final distractors = <String>[];

  void add(String value) {
    final clean = _cleanQuizOptionText(value);
    if (clean.isEmpty) return;
    if (_looksLikeSentenceAnswer(clean)) return;
    final key = _quizAnswerKey(clean);
    if (key.isEmpty || key == _quizAnswerKey(cleanAnswer)) return;
    if (seen.contains(key)) return;
    seen.add(key);
    distractors.add(clean);
  }

  for (final option in raw) {
    add(option);
  }

  var guard = 0;
  while (distractors.length < 3 && guard < 20) {
    add(_smallGrammarSlip(cleanAnswer, guard + index));
    guard++;
  }
  guard = 0;
  while (distractors.length < 3 && guard < 20) {
    add(_safeFallbackByIndex(cleanAnswer, guard + index));
    guard++;
  }
  guard = 0;
  while (distractors.length < 3 && guard < 8) {
    add('not ${guard == 0 ? cleanAnswer : '$cleanAnswer ${guard + 1}'}');
    guard++;
  }

  final slot = _stableAnswerSlot(lessonKey, index);
  final finalOptions = distractors.take(3).toList(growable: true);
  finalOptions.insert(slot, cleanAnswer);
  return finalOptions.take(4).toList(growable: false);
}

String _normalizeBlankMarker(String value) {
  return repairGrammarMojibake(value)
      .replaceAll(RegExp(r'_{2,}'), '_____')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _extractBlankSentence(String prompt) {
  final clean = _normalizeBlankMarker(prompt);
  if (!clean.contains('_____')) return '';
  final marker = clean.indexOf('_____');
  final before = clean.lastIndexOf(RegExp(r'[:"]'), marker);
  final start = before < 0 ? 0 : before + 1;
  return clean.substring(start).replaceAll('"', '').trim();
}

String _bestClozeSource(GrammarQuizQuestion question, GrammarLesson lesson) {
  final candidates = [
    question.answer,
    question.sentence ?? '',
    lesson.right,
    lesson.modelAnswer,
    ...lesson.examples,
  ];
  for (final candidate in candidates) {
    final clean = _cleanOptionSentence(candidate);
    if (_isSentenceLike(clean) &&
        !_looksLikeMetaOption(clean) &&
        !_contextLooksTeacherish(clean)) {
      return clean;
    }
  }
  return lesson.right;
}

bool _looksLikeSentenceAnswer(String value) {
  final clean = value.trim();
  if (clean.split(RegExp(r'\s+')).length > 5) return true;
  return RegExp(r'[.?!]$').hasMatch(clean);
}

int _stableAnswerSlot(String lessonKey, int index) {
  final seed = lessonKey.codeUnits.fold<int>(0, (total, code) => total + code);
  const pattern = [1, 3, 0, 2, 2, 0, 3, 1];
  return pattern[(seed + index) % pattern.length];
}

String _cleanQuizOptionText(String value) {
  return repairGrammarMojibake(value)
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('?.', '?')
      .replaceAll('..', '.')
      .trim();
}

String _quizAnswerKey(String value) {
  return _cleanQuizOptionText(value)
      .replaceAll(RegExp(r'[.?!]$'), '')
      .toLowerCase()
      .trim();
}

String _smallGrammarSlip(String value, int seed) {
  final clean = _cleanQuizOptionText(value);
  if (clean.isEmpty) return 'I am study every day.';

  final lower = clean.toLowerCase();
  final isToken =
      !clean.contains(' ') && RegExp(r"^[A-Za-z']+$").hasMatch(clean);
  if (isToken) {
    final token = lower;
    final candidates = <String>[];
    void add(String t) {
      final v = t.trim();
      if (v.isEmpty) return;
      if (v.toLowerCase() == token) return;
      if (!candidates.any((e) => e.toLowerCase() == v.toLowerCase()))
        candidates.add(v);
    }

    switch (token) {
      case 'am':
        add('is');
        add('are');
        add('be');
        break;
      case 'is':
        add('am');
        add('are');
        add('be');
        break;
      case 'are':
        add('am');
        add('is');
        add('be');
        break;
      case 'do':
        add('does');
        add('did');
        add('done');
        break;
      case 'does':
        add('do');
        add('did');
        add('done');
        break;
      case 'did':
        add('do');
        add('does');
        add('done');
        break;
      case 'have':
        add('has');
        add('had');
        add('having');
        break;
      case 'has':
        add('have');
        add('had');
        add('having');
        break;
      case 'had':
        add('have');
        add('has');
        add('having');
        break;
      case 'been':
        add('being');
        add('be');
        add('went');
        break;
      case 'will':
        add('would');
        add('can');
        add('going');
        break;
      case 'would':
        add('will');
        add('could');
        add('should');
        break;
      case 'should':
        add('must');
        add('would');
        add('could');
        break;
      case 'must':
        add('should');
        add('have to');
        add('might');
        break;
      case 'can':
        add('could');
        add('may');
        add('must');
        break;
      case 'may':
        add('might');
        add('can');
        add('must');
        break;
      case 'might':
        add('may');
        add('can');
        add('must');
        break;
      case 'to':
        add('for');
        add('in');
        add('at');
        break;
      case 'than':
        add('then');
        add('that');
        add('as');
        break;
      default:
        add('${clean}s');
        add('${clean}ed');
        add('${clean}ing');
        add(clean.replaceAll("'", ''));
        break;
    }

    if (candidates.isEmpty) return clean;
    return candidates[seed % candidates.length];
  }
  final questionMark = clean.endsWith('?');

  final candidates = <String>[];

  String finish(String text) {
    final trimmed = _cleanQuizOptionText(text);
    if (trimmed.isEmpty) return clean;
    if (questionMark) {
      return trimmed.endsWith('?') ? trimmed : '$trimmed?';
    }
    if (trimmed.endsWith('?')) return trimmed;
    return trimmed.endsWith('.') ? trimmed : '$trimmed.';
  }

  void add(String text) {
    final item = finish(text);
    if (item.toLowerCase() != clean.toLowerCase() &&
        !candidates.map((e) => e.toLowerCase()).contains(item.toLowerCase())) {
      candidates.add(item);
    }
  }

  if (lower.contains('does ') || lower.startsWith('does ')) {
    add(clean.replaceAll(RegExp(r'\bplay\b', caseSensitive: false), 'plays'));
    add(clean.replaceAll(RegExp(r'\blike\b', caseSensitive: false), 'likes'));
    add(clean.replaceAll(RegExp(r'\bwork\b', caseSensitive: false), 'works'));
    add(clean.replaceFirst(RegExp(r'\bDoes\b', caseSensitive: false), 'Do'));
  }

  if (lower.contains('do ')) {
    add(clean.replaceFirst(RegExp(r'\bDo\b', caseSensitive: false), 'Does'));
    add(clean.replaceAll(
        RegExp(r'\bstudy\b', caseSensitive: false), 'studies'));
    add(clean.replaceAll(
        RegExp(r'\bwatch\b', caseSensitive: false), 'watches'));
  }

  if (lower.contains('does not ') || lower.contains("doesn't ")) {
    add(clean.replaceAll(RegExp(r'\bwork\b', caseSensitive: false), 'works'));
    add(clean.replaceAll(RegExp(r'\blike\b', caseSensitive: false), 'likes'));
    add(clean.replaceFirst(RegExp(r'\bdoes\b', caseSensitive: false), 'do'));
  }

  if (lower.contains('do not ') || lower.contains("don't ")) {
    add(clean.replaceFirst(RegExp(r'\bdo\b', caseSensitive: false), 'does'));
    add(clean.replaceAll(
        RegExp(r'\bwatch\b', caseSensitive: false), 'watches'));
  }

  if (RegExp(r'\b(she|he|it)\b', caseSensitive: false).hasMatch(clean)) {
    add(clean.replaceAll(RegExp(r'\bworks\b', caseSensitive: false), 'work'));
    add(clean.replaceAll(RegExp(r'\blikes\b', caseSensitive: false), 'like'));
    add(clean.replaceAll(RegExp(r'\bplays\b', caseSensitive: false), 'play'));
    add(clean.replaceAll(
        RegExp(r'\bstudies\b', caseSensitive: false), 'study'));
    add(clean.replaceAll(
        RegExp(r'\bwatches\b', caseSensitive: false), 'watch'));
  }

  if (lower.contains('usually ') ||
      lower.contains('always ') ||
      lower.contains('often ') ||
      lower.contains('sometimes ')) {
    add(clean.replaceAll('usually drink', 'drink usually'));
    add(clean.replaceAll('always walks', 'walks always'));
    add(clean.replaceAll('often watch', 'watch often'));
    add(clean.replaceAll('sometimes study', 'study sometimes'));
    add(clean.replaceAll('usually wake', 'wake usually'));
  }

  if (lower.contains('every day'))
    add(clean.replaceAll('every day', 'everydays'));
  if (lower.contains('at school'))
    add(clean.replaceAll('at school', 'in school'));
  if (lower.contains('tea')) add(clean.replaceAll('drink tea', 'drinks tea'));

  add('She work every day.');
  add('She does works every day.');
  add('Does she works every day?');
  add('I drink usually tea in the morning.');
  add('They watches TV every night.');
  add('He do not work here.');

  return candidates[seed % candidates.length];
}

String _localizedQuizPrompt(String prompt, bool isEnglish) {
  final clean = prompt.trim();
  final lower = clean.toLowerCase();
  if (isEnglish) {
    if (lower.contains('bo_lu?u') ||
        lower.contains('boslugu') ||
        lower.contains('blank')) {
      return 'Fill in the blank.';
    }
    if (_looksTurkishOrBrokenQuizText(clean)) {
      return 'Choose the correct option.';
    }
    return clean;
  }

  if (lower.startsWith('complete:')) {
    final rest = clean.substring(clean.indexOf(':') + 1).trim();
    return rest.isEmpty ? 'Cümleyi tamamla.' : repairGrammarMojibake(rest);
  }
  if (lower.contains('correct negative')) return 'Olumsuz cümleyi tamamla.';
  if (lower.contains('correct question')) return 'Soru cümlesini tamamla.';
  if (lower.contains('correct sentence')) return 'Cümleyi tamamla.';
  if (lower.contains('follows the rule')) return 'Kurala uygun seçeneği seç.';
  if (lower.contains('clean model')) return 'Model cümleyi tamamla.';
  if (lower.contains('correct form')) return 'Doğru formu seç.';
  if (lower.contains('choose the correct')) return 'Doğru seçeneği seç.';
  if (lower.contains('which sentence')) return 'Doğru cümleyi seç.';
  if (lower.contains('question')) return 'Soru cümlesini tamamla.';
  if (lower.contains('negative')) return 'Olumsuz cümleyi tamamla.';

  return repairGrammarMojibake(clean);
}

String _localizedQuizExplanation(String explanation, bool isEnglish) {
  final clean = explanation.trim();
  if (isEnglish) {
    if (clean.isEmpty || _looksTurkishOrBrokenQuizText(clean)) {
      return 'The correct answer matches the grammar pattern in this lesson.';
    }
    return clean;
  }
  final lower = clean.toLowerCase();

  if (lower.contains('correct option follows') ||
      lower.contains('lesson pattern')) {
    return 'Doğru seçenek dersin hedef yapısına uyuyor.';
  }
  if (lower.contains('target grammar') || lower.contains('grammar form')) {
    return 'Doğru seçenek hedef yapının formunu koruyor.';
  }
  if (lower.contains('correct')) {
    return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
  }

  return repairGrammarMojibake(clean);
}

bool _looksTurkishText(String value) {
  final v = value.trim();
  if (v.isEmpty) return false;
  final lower = v.toLowerCase();
  return RegExp(r'[�?1�_��?0�^�]').hasMatch(v) ||
      lower.contains('c�mle') ||
      lower.contains('kural') ||
      lower.contains('do?ru') ||
      lower.contains('yanl?') ||
      lower.contains('kelime');
}

bool _looksTurkishOrBrokenQuizText(String value) {
  final v = value.trim();
  if (v.isEmpty) return false;
  final lower = v.toLowerCase();
  if (_looksTurkishText(v)) return true;
  if (RegExp(
          r'[\u00c7\u00e7\u011e\u011f\u0130\u0131\u00d6\u00f6\u015e\u015f\u00dc\u00fc]')
      .hasMatch(v)) {
    return true;
  }
  if (RegExp(r'[\u00c3\u00c4\u00c5\u00ef\u00bf\u00bd\uFFFD]').hasMatch(v)) {
    return true;
  }

  const turkishFragments = <String>[
    'c?mle',
    'cumle',
    'kural',
    'do?ru',
    'dogru',
    'yanl',
    'se?enek',
    'secenek',
    'özne',
    'ozne',
    'fiil',
    'yap?',
    'yapi',
    'kal?p',
    'kalip',
    'kullan',
    'olumsuz',
    'soru',
    'yard?mc',
    'yardimci',
    'hedef',
    'dersin',
    'model c',
  ];
  return turkishFragments.any(lower.contains);
}

bool _looksBrokenTurkishQuizText(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return false;
  const turkishLetters = 'A-Za-zÇĞİÖŞÜçğıöşü';
  return clean.contains('\uFFFD') ||
      clean.contains('ï¿½') ||
      clean.contains('�') ||
      RegExp(r'[ÃÄÅ]').hasMatch(clean) ||
      RegExp('[$turkishLetters][?1_][$turkishLetters]').hasMatch(clean) ||
      RegExp(r'(^|\s)[?^][A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(clean);
}

String _turkishQuizDefaultExplanation(GrammarQuizType type) {
  switch (type) {
    case GrammarQuizType.fillBlank:
      return 'Do\u011fru cevap. Bu bo\u015flukta hedef yap\u0131ya uygun form kullan\u0131lmal\u0131.';
    case GrammarQuizType.sentenceOrder:
      return 'Kelime s\u0131ras\u0131 hedef yap\u0131ya uygun olmal\u0131. \u00d6zne, yard\u0131mc\u0131 fiil ve ana fiilin yerini kontrol et.';
    case GrammarQuizType.errorCorrection:
      return 'Bu se\u00e7enek hedef yap\u0131ya uymuyor. \u00d6zneye ve fiil formuna tekrar bak.';
    case GrammarQuizType.transformation:
      return 'Anlam korunmal\u0131, ama c\u00fcmle hedef yap\u0131n\u0131n do\u011fru formuyla yeniden kurulmal\u0131.';
    case GrammarQuizType.matching:
      return 'E\u015fle\u015fme hedef yap\u0131n\u0131n anlam\u0131 ve formuyla uyumlu olmal\u0131.';
    case GrammarQuizType.multipleChoice:
      return 'Do\u011fru cevap. Bu bo\u015flukta hedef yap\u0131ya uygun form kullan\u0131lmal\u0131.';
  }
}

String _turkishQuizPromptFallback(GrammarQuizType type) {
  switch (type) {
    case GrammarQuizType.fillBlank:
      return 'Bo\u015flu\u011fu doldur.';
    case GrammarQuizType.errorCorrection:
      return 'C\u00fcmleyi d\u00fczelt.';
    case GrammarQuizType.transformation:
      return 'C\u00fcmleyi d\u00fczenle.';
    case GrammarQuizType.sentenceOrder:
      return 'Kelimeleri s\u0131raya koy.';
    case GrammarQuizType.matching:
      return 'E\u015fle\u015ftir.';
    case GrammarQuizType.multipleChoice:
      return 'Do\u011fru se\u00e7ene\u011fi se\u00e7.';
  }
}

String quizPromptDisplay(GrammarQuizQuestion question, bool isEnglish) {
  if (question.type == GrammarQuizType.fillBlank) {
    final sentence = (question.sentence ?? '').trim();
    if (sentence.contains('_____')) return _normalizeBlankMarker(sentence);

    final prompt = question.prompt.trim();
    if (prompt.contains('_____')) return _normalizeBlankMarker(prompt);

    if (!isEnglish) return _turkishQuizPromptFallback(question.type);
    return isEnglish ? 'Fill in the blank.' : 'Boşluğu doldur.';
  }
  if (isEnglish) return _localizedQuizPrompt(question.prompt, true);
  final prompt = question.prompt.trim();
  if (_looksTurkishText(prompt) && !_looksBrokenTurkishQuizText(prompt)) {
    return prompt;
  }
  if (_looksBrokenTurkishQuizText(repairGrammarMojibake(prompt))) {
    return _turkishQuizPromptFallback(question.type);
  }
  if (!_looksTurkishText(prompt))
    return _turkishQuizPromptFallback(question.type);
  if (_looksTurkishText(prompt)) return prompt;

  switch (question.type) {
    case GrammarQuizType.fillBlank:
      return 'Boşluğu doldur.';
    case GrammarQuizType.errorCorrection:
      return 'Cümleyi düzelt.';
    case GrammarQuizType.transformation:
      return 'Cümleyi düzenle.';
    case GrammarQuizType.sentenceOrder:
      return 'Kelimeleri sıraya koy.';
    case GrammarQuizType.matching:
      return 'Eşleştir.';
    case GrammarQuizType.multipleChoice:
      return 'Doğru seçeneği seç.';
  }
}

String quizExplanationDisplay(GrammarQuizQuestion question, bool isEnglish) {
  if (isEnglish) return _localizedQuizExplanation(question.explanation, true);
  final explanation = question.explanation.trim();
  final repaired = repairGrammarMojibake(explanation);
  if (explanation.isEmpty || _looksBrokenTurkishQuizText(repaired)) {
    return _turkishQuizDefaultExplanation(question.type);
  }
  if (_looksTurkishText(repaired)) return repaired;
  if (explanation.isEmpty) return '';
  if (_looksTurkishText(explanation)) return explanation;
  if (!_looksTurkishText(repaired)) {
    return _turkishQuizDefaultExplanation(question.type);
  }

  final lower = explanation.toLowerCase();
  if (lower.contains('word order')) {
    return 'Kelime sırası doğru olmalı. Yardımcı fiil, özne ve ana fiil yerlerini kontrol et.';
  }
  if (lower.contains('pattern') || lower.contains('form')) {
    return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
  }
  if (lower.contains('meaning')) {
    return 'Anlam aynı kalırken form düzeltilmeli. Yardımcı fiil ve fiil formuna dikkat et.';
  }
  if (lower.contains('correct') || lower.contains('right')) {
    return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
  }

  return 'Model cümleye bak: doğru cevap hedef yapıyı bozmadan anlamı verir.';
}
