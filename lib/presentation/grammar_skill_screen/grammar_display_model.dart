// ignore_for_file: unused_element, curly_braces_in_flow_control_structures

import 'package:speakery/data/grammar/grammar_models.dart';

import 'grammar_ui_text.dart';

class GrammarDisplayLesson {
  final String learnTitleEn;
  final String learnTitleTr;
  final String learnBodyEn;
  final String learnBodyTr;
  final List<String> structureBulletsEn;
  final List<String> structureBulletsTr;
  final List<String> usageNotesEn;
  final List<String> usageNotesTr;

  const GrammarDisplayLesson({
    required this.learnTitleEn,
    required this.learnTitleTr,
    required this.learnBodyEn,
    required this.learnBodyTr,
    required this.structureBulletsEn,
    required this.structureBulletsTr,
    required this.usageNotesEn,
    required this.usageNotesTr,
  });

  String learnTitle(bool isEnglish) => isEnglish ? learnTitleEn : learnTitleTr;
  String learnBody(bool isEnglish) => isEnglish ? learnBodyEn : learnBodyTr;
  List<String> structureBullets(bool isEnglish) =>
      isEnglish ? structureBulletsEn : structureBulletsTr;
  List<String> usageNotes(bool isEnglish) =>
      isEnglish ? usageNotesEn : usageNotesTr;
}

String grammarDisplayKeyFor(GrammarLesson lesson) => _grammarDisplayKey(lesson);

String grammarLessonKey(GrammarLesson lesson) {
  final raw =
      '${lesson.bigTitle} ${lesson.oneLineGoal} ${lesson.teacherIntro} ${lesson.right} ${lesson.wrong} ${lesson.modelAnswer} ${lesson.examples.join(' ')} ${lesson.formulaRows.map((e) => '${e.label} ${e.pattern} ${e.sample}').join(' ')}'
          .toLowerCase();

  if (lesson.bigTitle.toLowerCase().trim() == 'advanced conditionals') {
    if (raw.contains('were it not for') ||
        raw.contains('had it not been for')) {
      return 'c2_advanced_conditionals';
    }
    return 'c1_advanced_conditionals';
  }
  if (raw.contains('precise comparisons')) return 'b2_formal_comparisons';
  if (raw.contains('advanced nominalisation') ||
      raw.contains('advanced nominalization')) {
    return 'c2_academic_nominalisation';
  }

  if (raw.contains('future perfect continuous') ||
      raw.contains('will have been')) return 'b2_future_perfect_continuous';
  if (raw.contains('future perfect') ||
      raw.contains('will have + v3') ||
      raw.contains('will have v3')) return 'b2_future_perfect';
  if (raw.contains('past perfect continuous') ||
      raw.contains('had been') && raw.contains('ing'))
    return 'b1_past_perfect_continuous';
  if (raw.contains('present perfect continuous') ||
      raw.contains('have been') && raw.contains('ing'))
    return 'b1_present_perfect_continuous';
  if (raw.contains('full inversion') ||
      raw.contains('negative adverbial inversion') ||
      raw.contains('never have i') ||
      raw.contains('only then did') ||
      raw.contains('rarely do')) return 'c1_full_inversion';
  if (raw.contains('inversion intro') ||
      raw.contains('not only did') ||
      raw.contains('little did')) return 'b2_inversion_intro';
  if (raw.contains('stylistic inversion') ||
      raw.contains('on no account') ||
      raw.contains('under no circumstances')) return 'c2_stylistic_inversion';
  if (raw.contains('cleft')) return 'c1_cleft_sentences';
  if (raw.contains('emphatic do')) return 'c1_emphatic_do';
  if (raw.contains('advanced modality')) return 'c1_advanced_modality';
  if (raw.contains('advanced linkers')) return 'c1_advanced_linkers';
  if (raw.contains('noun clauses')) return 'c1_noun_clauses';
  if (raw.contains('reduced relative clauses'))
    return 'c1_reduced_relative_clauses';
  if (raw.contains('nominalisation intro') ||
      raw.contains('nominalization intro')) return 'c1_nominalisation_intro';
  if (raw.contains('advanced conditionals')) return 'c1_advanced_conditionals';
  if (raw.contains('register control')) return 'c1_register_control';
  if (raw.contains('subjunctive') || raw.contains('formulaic'))
    return 'c1_subjunctive_formulaic';
  if (raw.contains('ellipsis') || raw.contains('substitution'))
    return 'c1_ellipsis_substitution';
  if (raw.contains('academic nominalisation') ||
      raw.contains('academic nominalization'))
    return 'c2_academic_nominalisation';
  if (raw.contains('fronting') || raw.contains('information structure'))
    return 'c2_fronting_information_structure';
  if (raw.contains('advanced hedging')) return 'c2_advanced_hedging';
  if (raw.contains('register shifts')) return 'c2_register_shifts';
  if (raw.contains('dense noun phrases')) return 'c2_dense_noun_phrases';
  if (raw.contains('complex subordination')) return 'c2_complex_subordination';
  if (raw.contains('advanced concession')) return 'c2_advanced_concession';
  if (raw.contains('advanced emphasis')) return 'c2_advanced_emphasis';
  if (raw.contains('precision with modality')) return 'c2_precision_modality';
  if (raw.contains('discourse flow')) return 'c2_discourse_flow';
  if (raw.contains('advanced conditionals')) return 'c2_advanced_conditionals';

  if (raw.contains('present perfect vs past simple'))
    return 'a2_present_perfect_vs_past';
  if (raw.contains('past simple vs past continuous'))
    return 'a2_past_simple_vs_continuous';
  if (raw.contains('past continuous')) return 'a2_past_continuous';
  if (raw.contains('past simple')) return 'a2_past_simple';
  if (raw.contains('going to')) return 'a2_going_to';
  if (raw.contains('present continuous for future'))
    return 'a2_present_continuous_future';
  if (raw.contains('must') || raw.contains('have to') || raw.contains('has to'))
    return 'a2_must_have_to';
  if (raw.contains('should')) return 'a2_should';
  if (raw.contains('may') || raw.contains('might')) return 'a2_may_might';
  if (raw.contains('too') || raw.contains('enough')) return 'a2_too_enough';
  if (raw.contains('present perfect')) return 'a2_present_perfect';
  if (raw.contains('first conditional')) return 'a2_first_conditional';
  if (raw.contains('zero conditional')) return 'a2_zero_conditional';
  if (raw.contains('used to')) return 'a2_used_to';
  if (raw.contains('would like')) return 'a2_would_like';
  if (raw.contains('object pronouns') && raw.contains('possessive pronouns')) {
    return 'a2_object_possessive_pronouns';
  }
  if (raw.contains('adverbs of frequency') ||
      raw.contains('frequency adverbs') ||
      raw.contains('manner adverbs')) {
    return 'a2_adverbs_frequency_manner';
  }
  if (raw.contains('infinitive of purpose') ||
      raw.contains('purpose with a verb') ||
      raw.contains('to explain why')) {
    return 'a2_infinitive_purpose';
  }
  if (raw.contains('gerund') || raw.contains('infinitive'))
    return 'a2_gerund_infinitive';
  if (raw.contains('relative')) return 'a2_relative';
  if (raw.contains('countable / uncountable') ||
      raw.contains('countable nouns with numbers') ||
      raw.contains('uncountable nouns with amount')) {
    return 'a2_countable_uncountable';
  }
  if (raw.contains('some / any / much / many / a lot of') ||
      raw.contains('some, any, much, many and a lot of')) {
    return 'a2_some_any_much_many';
  }
  if (raw.contains('quantifier') ||
      raw.contains('much') ||
      raw.contains('many')) return 'a2_quantifiers';
  if (raw.contains('so / such') ||
      raw.contains(' so ') && raw.contains(' such ')) return 'a2_so_such';
  if (raw.contains('comparative') ||
      raw.contains('colder than') ||
      raw.contains('better than')) return 'a2_comparatives';
  if (raw.contains('superlative') ||
      raw.contains('the most') ||
      raw.contains('the best')) return 'a2_superlatives';
  if (raw.contains('future simple') ||
      raw.contains('will + v1') ||
      raw.contains(' will ')) return 'a2_will';

  if (raw.contains('present simple')) return 'a1_present_simple';
  if (raw.contains('present continuous')) return 'a1_present_continuous';
  if (raw.contains('am / is / are') || raw.contains('be verb'))
    return 'a1_be_verb';
  if (raw.contains('subject pronouns') ||
      raw.contains('subject & object') ||
      raw.contains('object pronouns')) return 'a1_subject_pronouns';
  if (raw.contains('possessive adjectives') || raw.contains('possessives')) {
    return 'a1_possessive_adjectives';
  }
  if (raw.contains('articles') || raw.contains('a / an / the'))
    return 'a1_articles';
  if (raw.contains('plural nouns') ||
      raw.contains('two books') ||
      raw.contains('children')) return 'a1_singular_plural';
  if (raw.contains('this / that / these / those') ||
      raw.contains('demonstrative')) return 'a1_demonstratives';
  if (raw.contains('have got') || raw.contains('has got'))
    return 'a1_have_has_got';
  if (raw.contains('basic prepositions') || raw.contains('in / on / at'))
    return 'a1_basic_prepositions';
  if (raw.contains('imperatives') || raw.contains('imperative'))
    return 'a1_imperatives';
  if (raw.contains('there is') || raw.contains('there are'))
    return 'a1_there_is_are';
  if (raw.contains('can') || raw.contains('ability')) return 'a1_can_cant';
  if (raw.contains('wh') && raw.contains('question')) return 'a1_wh_questions';

  return '';
}

List<GrammarFormulaRow> normalizedGrammarFormulaRowsFor(GrammarLesson lesson) {
  final key = grammarLessonKey(lesson);

  List<GrammarFormulaRow> rows(List<GrammarFormulaRow> value) => value;

  switch (key) {
    case 'b2_future_perfect':
      return rows(const [
        GrammarFormulaRow(
            label: 'Completed before future point',
            pattern: 'subject + will have + V3 + by/before + future time',
            sample: 'By Friday, I will have finished the report.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'subject + will not have + V3',
            sample: 'By noon, she will not have completed the task.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Will + subject + have + V3?',
            sample: 'Will you have finished by 8?'),
        GrammarFormulaRow(
            label: 'Time marker',
            pattern: 'by / by the time / before + future point',
            sample: 'By the time you arrive, we will have eaten dinner.'),
      ]);
    case 'b2_future_perfect_continuous':
      return rows(const [
        GrammarFormulaRow(
            label: 'Duration before future point',
            pattern: 'subject + will have been + V-ing + for/since',
            sample: 'By June, I will have been working here for two years.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'subject + will not have been + V-ing',
            sample: 'She will not have been studying for long.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Will + subject + have been + V-ing?',
            sample: 'Will you have been waiting for an hour?'),
      ]);
    case 'b2_inversion_intro':
    case 'c1_full_inversion':
      return rows(const [
        GrammarFormulaRow(
            label: 'Negative adverbial',
            pattern: 'Never/Rarely/Hardly + auxiliary + subject + verb',
            sample: 'Never have I seen such a clear explanation.'),
        GrammarFormulaRow(
            label: 'Only then / Only later',
            pattern: 'Only then + auxiliary + subject + verb',
            sample: 'Only then did I understand the problem.'),
        GrammarFormulaRow(
            label: 'Not only',
            pattern: 'Not only + auxiliary + subject + verb, but also ...',
            sample:
                'Not only did she apologize, but she also offered to help.'),
        GrammarFormulaRow(
            label: 'Avoid',
            pattern:
                'Do not keep normal subject + auxiliary order after fronting',
            sample: 'Never I have seen such a clear explanation.'),
      ]);
    case 'a2_past_simple':
      return rows(const [
        GrammarFormulaRow(
            label: 'Regular positive',
            pattern: 'subject + V-ed',
            sample: 'I watched a movie yesterday.'),
        GrammarFormulaRow(
            label: 'Irregular positive',
            pattern: 'subject + V2',
            sample: 'She went to Ankara last week.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'subject + did not + V1',
            sample: 'I did not go to school.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Did + subject + V1?',
            sample: 'Did you call me?'),
        GrammarFormulaRow(
            label: 'Time words',
            pattern:
                'yesterday / last night / last week / two days ago / in 2020',
            sample: 'We met two days ago.'),
      ]);
    case 'a2_past_continuous':
      return rows(const [
        GrammarFormulaRow(
            label: 'I / He / She / It',
            pattern: 'was + V-ing',
            sample: 'I was studying at 9 p.m.'),
        GrammarFormulaRow(
            label: 'You / We / They',
            pattern: 'were + V-ing',
            sample: 'They were watching TV at 9.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'was / were + not + V-ing',
            sample: 'She was not sleeping.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Was / Were + subject + V-ing?',
            sample: 'Were you listening?'),
        GrammarFormulaRow(
            label: 'Interrupted action',
            pattern: 'was/were + V-ing + when + V2',
            sample: 'I was studying when you called.'),
      ]);
    case 'a2_comparatives':
      return rows(const [
        GrammarFormulaRow(
            label: 'Short adjectives',
            pattern: 'adjective + -er + than',
            sample: 'Kayseri is colder than Antalya.'),
        GrammarFormulaRow(
            label: 'Long adjectives',
            pattern: 'more + adjective + than',
            sample: 'This lesson is more useful than the last one.'),
        GrammarFormulaRow(
            label: 'Irregular',
            pattern: 'good -> better / bad -> worse',
            sample: 'This answer is better than mine.'),
        GrammarFormulaRow(
            label: 'Spelling',
            pattern: 'big -> bigger / hot -> hotter',
            sample: 'Today is hotter than yesterday.'),
      ]);
    case 'a2_superlatives':
      return rows(const [
        GrammarFormulaRow(
            label: 'Short adjectives',
            pattern: 'the + adjective + -est',
            sample: 'She is the tallest student in the class.'),
        GrammarFormulaRow(
            label: 'Long adjectives',
            pattern: 'the most + adjective',
            sample: 'This is the most useful lesson.'),
        GrammarFormulaRow(
            label: 'Irregular',
            pattern: 'good -> the best / bad -> the worst',
            sample: 'This is the best answer.'),
        GrammarFormulaRow(
            label: 'Group phrase',
            pattern: 'in my class / in the world / of all',
            sample: 'It is the coldest city in the region.'),
      ]);
    case 'a2_will':
      return rows(const [
        GrammarFormulaRow(
            label: 'Positive',
            pattern: 'subject + will + V1',
            sample: 'I will help you.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: "subject + will not / won't + V1",
            sample: "They won't come tonight."),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Will + subject + V1?',
            sample: 'Will you join us?'),
        GrammarFormulaRow(
            label: 'Prediction',
            pattern: 'I think / maybe / probably + will + V1',
            sample: 'I think it will rain.'),
        GrammarFormulaRow(
            label: 'Future signals',
            pattern: 'tomorrow / soon / next week',
            sample: 'They will arrive soon.'),
      ]);
    case 'a2_going_to':
      return rows(const [
        GrammarFormulaRow(
            label: 'I',
            pattern: 'I am going to + V1',
            sample: 'I am going to study tonight.'),
        GrammarFormulaRow(
            label: 'He / She / It',
            pattern: 'is going to + V1',
            sample: 'She is going to call you.'),
        GrammarFormulaRow(
            label: 'You / We / They',
            pattern: 'are going to + V1',
            sample: 'They are going to travel.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Am / Is / Are + subject + going to + V1?',
            sample: 'Are you going to join us?'),
        GrammarFormulaRow(
            label: 'Useful signals',
            pattern: 'tonight / this weekend / next summer / look at...',
            sample: 'Look at the clouds. It is going to rain.'),
      ]);
    case 'a2_must_have_to':
      return rows(const [
        GrammarFormulaRow(
            label: 'Must',
            pattern: 'subject + must + V1',
            sample: 'You must wear a seat belt.'),
        GrammarFormulaRow(
            label: 'Have to',
            pattern: 'I / you / we / they + have to + V1',
            sample: 'I have to finish my homework.'),
        GrammarFormulaRow(
            label: 'Has to',
            pattern: 'he / she / it + has to + V1',
            sample: 'She has to wake up early.'),
        GrammarFormulaRow(
            label: 'No necessity',
            pattern: 'do / does not have to + V1',
            sample: 'You do not have to come early.'),
        GrammarFormulaRow(
            label: 'Rule words',
            pattern: 'must / must not / have to / has to / do not have to',
            sample: 'Visitors must show their ID.'),
      ]);
    case 'a2_should':
      return rows(const [
        GrammarFormulaRow(
            label: 'Advice',
            pattern: 'subject + should + V1',
            sample: 'You should drink more water.'),
        GrammarFormulaRow(
            label: 'Negative advice',
            pattern: "subject + should not + V1",
            sample: "You shouldn't sleep late."),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Should + subject + V1?',
            sample: 'Should I call her?'),
        GrammarFormulaRow(
            label: 'Advice signals',
            pattern: 'should / should not / maybe you should',
            sample: 'Maybe you should rest today.'),
      ]);
    case 'a2_too_enough':
      return rows(const [
        GrammarFormulaRow(
            label: 'Too',
            pattern: 'too + adjective',
            sample: 'This bag is too heavy.'),
        GrammarFormulaRow(
            label: 'Adjective enough',
            pattern: 'adjective + enough',
            sample: 'He is old enough to drive.'),
        GrammarFormulaRow(
            label: 'Enough noun',
            pattern: 'enough + noun',
            sample: 'We have enough time.'),
        GrammarFormulaRow(
            label: 'Not enough',
            pattern: 'not + adjective + enough',
            sample: 'The room is not big enough.'),
      ]);
    case 'a2_present_perfect':
      return rows(const [
        GrammarFormulaRow(
            label: 'Positive',
            pattern: 'subject + have / has + V3',
            sample: 'I have visited Istanbul.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'have / has not + V3',
            sample: 'She has not finished yet.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Have / Has + subject + V3?',
            sample: 'Have you ever tried sushi?'),
        GrammarFormulaRow(
            label: 'Time contrast',
            pattern: 'Past Simple with finished time',
            sample: 'I visited Ankara last year.'),
      ]);
    case 'a2_first_conditional':
      return rows(const [
        GrammarFormulaRow(
            label: 'If clause',
            pattern: 'If + present simple',
            sample: 'If it rains,'),
        GrammarFormulaRow(
            label: 'Result',
            pattern: 'will + V1',
            sample: 'I will stay at home.'),
        GrammarFormulaRow(
            label: 'Full sentence',
            pattern: 'If + present simple, will + V1',
            sample: 'If it rains, I will stay at home.'),
        GrammarFormulaRow(
            label: 'Negative result',
            pattern: 'will not + V1',
            sample: "If I am busy, I won't come."),
      ]);
  }

  final cleaned = lesson.formulaRows.where((row) {
    final label = row.label.toLowerCase().trim();
    final pattern = row.pattern.toLowerCase().trim();
    if (label.startsWith('step')) return false;
    if (label == 'meaning' &&
        (pattern.startsWith('use ') || pattern.contains(' için ')))
      return false;
    if (label == 'avoid') return false;
    return row.sample.trim().isNotEmpty || row.pattern.trim().isNotEmpty;
  }).toList();

  return cleaned.isNotEmpty ? cleaned : lesson.formulaRows;
}

// ─────────────────────────────────────────────────────────────────────────────
// CLEAN A1 TURKISH TEXT PACKS  (no mojibake, no repairMojibake dependency)
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the clean A1 Turkish learn title for the given topic key.
/// Returns null for non-A1 keys so callers can fall through to other logic.
String? _a1CleanTurkishLearnTitle(String key) {
  const map = <String, String>{
    'a1_be_verb': 'To Be / Olmak Fiili',
    'a1_subject_pronouns': 'Özne Zamirleri',
    'a1_possessive_adjectives': 'İyelik Sıfatları',
    'a1_there_is_are': 'There is / There are',
    'a1_articles': 'A / An / The',
    'a1_singular_plural': 'Tekil / Çoğul',
    'a1_present_simple': 'Geniş Zaman',
    'a1_present_continuous': 'Şimdiki Zaman',
    'a1_can_cant': "Can / Can't",
    'a1_have_has_got': 'Have got / Has got',
    'a1_basic_prepositions': 'Temel Edatlar',
    'a1_imperatives': 'Emir Cümleleri',
    'a1_demonstratives': 'İşaret Zamirleri',
    'a1_wh_questions': 'Wh- Soruları',
  };
  return _cleanA1DisplayText(map[key]);
}

String _a1CleanEnglishLearnTitle(String key, GrammarLesson lesson) {
  const map = <String, String>{
    'a1_be_verb': 'Be Verb',
    'a1_subject_pronouns': 'Subject Pronouns',
    'a1_possessive_adjectives': 'Possessive Adjectives',
    'a1_there_is_are': 'There is / There are',
    'a1_articles': 'Articles',
    'a1_singular_plural': 'Singular / Plural',
    'a1_present_simple': 'Present Simple',
    'a1_present_continuous': 'Present Continuous',
    'a1_can_cant': "Can / Can't",
    'a1_have_has_got': 'Have got / Has got',
    'a1_basic_prepositions': 'Basic Prepositions',
    'a1_imperatives': 'Imperatives',
    'a1_demonstratives': 'Demonstratives',
  };
  return map[key] ?? _cleanRawGrammarKey(key) ?? lesson.bigTitle;
}

/// Clean A1 Turkish learn body — 1-2 short sentences, no mojibake.
String? _a1CleanTurkishLearnBody(String key) {
  const map = <String, String>{
    'a1_be_verb':
        'Be verb, kişinin kim olduğunu, nerede olduğunu veya nasıl hissettiğini anlatır. I ile am, he/she/it ile is, you/we/they ile are kullanılır.',
    'a1_subject_pronouns':
        'Özne zamirleri cümlede işi yapan kişiyi gösterir. Nesne zamirleri ise fiilden sonra gelir ve eylemden etkilenen kişiyi anlatır.',
    'a1_possessive_adjectives':
        'Sahiplik sıfatları bir şeyin kime ait olduğunu gösterir. My, your, his, her gibi kelimeler isimden önce gelir.',
    'a1_there_is_are':
        'There is / there are, bir yerde bir şeyin var olduğunu anlatmak için kullanılır. Tekil isimlerde there is, çoğul isimlerde there are kullanılır.',
    'a1_articles':
        'A/an, bir şeyden ilk kez veya genel olarak bahsederken kullanılır. The ise konuşan ve dinleyen kişinin bildiği belirli bir şeyi gösterir.',
    'a1_singular_plural':
        'Tekil isim bir şeyi, çoğul isim birden fazla şeyi anlatır. Çoğu isim çoğul olurken -s veya -es alır; bazı kelimeler düzensiz değişir.',
    'a1_present_simple':
        'Present Simple, rutinleri, alışkanlıkları ve genel doğruları anlatır. I/you/we/they ile fiil yalın kalır; he/she/it ile fiile genellikle -s veya -es eklenir.',
    'a1_present_continuous':
        'Present Continuous, şu anda devam eden eylemleri anlatmak için kullanılır. Yapı am/is/are + V-ing şeklindedir.',
    'a1_can_cant':
        "Can, bir şeyi yapabilme becerisini anlatır. Can veya can't sonrasında fiil yalın haliyle kullanılır.",
    'a1_have_has_got':
        'Have got / has got, sahip olduğumuz şeyleri anlatır. I/you/we/they ile have got, he/she/it ile has got kullanılır.',
    'a1_basic_prepositions':
        'In, on ve at yer veya zaman bilgisi verir. In daha geniş alanlarda, on yüzeylerde ve günlerde, at ise net nokta veya saatlerde kullanılır.',
    'a1_imperatives':
        "Imperatives, kısa komut, yönerge veya rica vermek için kullanılır. Cümle genellikle fiilin yalın haliyle başlar; olumsuz için Don't + V1 kullanılır.",
    'a1_demonstratives':
        'This/that/these/those, bir şeyi yakında veya uzakta göstermeye yarar. This/that tekil, these/those çoğul isimlerle kullanılır.',
    'a1_wh_questions':
        'Wh- questions, bilgi almak için kullanılan soru kelimeleriyle kurulur. Soru kelimesinden sonra do/does veya be verb doğru sırayla kullanılır.',
  };
  return _cleanA1DisplayText(map[key]);
}

/// Clean A1 Turkish structure bullets — no mojibake.
List<String>? _a1CleanTurkishStructureBullets(String key) {
  const map = <String, List<String>>{
    'a1_be_verb': [
      'I ile am kullanılır.',
      'He/she/it ile is kullanılır.',
      'You/we/they ile are kullanılır.',
      'Olumsuzda not, be fiilinden sonra gelir.',
      'Soruda am/is/are cümlenin başına gelir.',
    ],
    'a1_subject_pronouns': [
      'Özne zamirleri cümlenin başında işi yapan kişiyi gösterir.',
      'Nesne zamirleri fiilden veya edattan sonra gelir.',
      'He, she, it tekil kişiler veya şeyler için kullanılır.',
      'Me, him, her, us, them eylemden etkilenen kişiyi anlatır.',
    ],
    'a1_possessive_adjectives': [
      'My, your, his, her, our, their isimden önce gelir.',
      'Sahiplik sıfatından sonra mutlaka bir isim kullanılır.',
      'His/her seçimi sahip olan kişiye göre yapılır.',
      "Whose sorusu bir şeyin kime ait olduğunu sorar.",
    ],
    'a1_articles': [
      'A/an, tekil ve sayılabilen isimlerle kullanılır.',
      'A sessiz sesle, an sesli sesle başlayan kelimelerde kullanılır.',
      'The, konuşan ve dinleyen kişinin bildiği şeyi gösterir.',
      'Çoğul veya sayılamayan isimlerde a/an kullanılmaz.',
    ],
    'a1_singular_plural': [
      'Tekil isim bir şeyi anlatır.',
      'Çoğul isim birden fazla şeyi anlatır.',
      'Çoğu isim çoğul olurken -s veya -es alır.',
      'Bazı kelimeler düzensiz değişir: child → children.',
      'Çoğul isimlerle genellikle are kullanılır.',
    ],
    'a1_there_is_are': [
      'Tekil isimler için there is kullanılır.',
      'Çoğul isimler için there are kullanılır.',
      'Olumsuzda there is not / there are not kullanılır.',
      'Soruda is veya are başa gelir.',
      'Önce ismin tekil mi çoğul mu olduğuna bak.',
    ],
    'a1_present_simple': [
      'Olumlu cümlede özne + fiil kullanılır.',
      'I/you/we/they ile fiil yalın kalır.',
      'He/she/it ile fiile genellikle -s veya -es eklenir.',
      'Olumsuzda do not / does not kullanılır.',
      'Soruda do / does başa gelir.',
    ],
    'a1_present_continuous': [
      'Yapı am/is/are + V-ing şeklindedir.',
      'I ile am, he/she/it ile is kullanılır.',
      'You/we/they ile are kullanılır.',
      'Olumsuzda not, am/is/are sonrasına gelir.',
      'Soruda am/is/are cümlenin başına gelir.',
    ],
    'a1_can_cant': [
      "Can ve can't bütün öznelerle aynı kalır.",
      "Can/can't sonrasında fiil yalın haliyle kullanılır.",
      'He/she/it ile fiile -s eklenmez.',
      'Soruda can cümlenin başına gelir.',
      "Can't yapamama anlamı verir.",
    ],
    'a1_have_has_got': [
      'I/you/we/they ile have got kullanılır.',
      'He/she/it ile has got kullanılır.',
      'Olumsuzda have not got / has not got kullanılır.',
      'Soruda have veya has cümlenin başına gelir.',
    ],
    'a1_basic_prepositions': [
      'In genellikle oda, şehir, ay veya yıl için kullanılır.',
      'On yüzeyler ve günler için kullanılır.',
      'At saatler ve net noktalar için kullanılır.',
      'Edat seçimi bağlama göre yapılır.',
    ],
    'a1_imperatives': [
      'Cümle doğrudan fiilin yalın haliyle başlar.',
      'Özne genellikle yazılmaz.',
      "Olumsuz komutta Don't + fiil kullanılır.",
      'Please eklemek cümleyi daha kibar yapar.',
    ],
    'a1_demonstratives': [
      'Yakındaki tekil şeyler için this kullanılır.',
      'Yakındaki çoğul şeyler için these kullanılır.',
      'Uzaktaki tekil şeyler için that kullanılır.',
      'Uzaktaki çoğul şeyler için those kullanılır.',
      'This/that tekil, these/those çoğul isimlerle kullanılır.',
    ],
    'a1_wh_questions': [
      'Where, when, what, who, why ve how bilgi sorularında kullanılır.',
      'Present Simple sorularında wh-word + do/does + subject + V1 kullanılır.',
      'Be verb sorularında wh-word + am/is/are + subject kullanılır.',
      'Soru kelimesinden sonra do/does soru sırasını korur.',
    ],
  };
  return map[key]?.map(_cleanA1DisplayText).nonNulls.toList(growable: false);
}

/// Clean A1 Turkish usage notes — compact premium blocks.
List<String>? _a1CleanTurkishUsageNotes(String key) {
  const map = <String, List<String>>{
    'a1_be_verb': [
      'Günlük bağlam: Kendini tanıtma, yer ve duygu bildirme.',
      'Kısa not: Önce özneyi bul, sonra doğru be fiilini seç.',
      'Kimlik, duygu ve yer bildirirken be fiili cümlede görünür olmalı.',
      'Soruda am/is/are başa gelir; kısa cevapta aynı be fiili kullanılır.',
    ],
    'a1_subject_pronouns': [
      'Günlük bağlam: Aynı kişiden tekrar söz ederken cümleyi kısalt.',
      'Kısa not: He/she/they gibi zamirler özne yerinde kullanılır.',
      'Me/him/her/us/them fiilden veya edattan sonra gelir.',
      'Aynı özne yerinde isim ve zamiri birlikte kullanma.',
    ],
    'a1_possessive_adjectives': [
      'Günlük bağlam: Çanta, telefon, aile ve kişisel bilgiler.',
      'Kısa not: Sahiplik sıfatından sonra mutlaka bir isim gelir.',
      'His/her seçimi sahip olan kişiye göre yapılır.',
      'Whose...? bir şeyin kime ait olduğunu sormak için kullanılır.',
    ],
    'a1_articles': [
      'Günlük bağlam: Bir şeyi ilk kez tanıtırken a/an; bilinen şeyi söylerken the.',
      'Kısa not: A/an genel tekil isim, the bilinen isim içindir.',
      'A/an seçimi harfe değil, kelimenin ilk sesine göre yapılır.',
      'Çoğul veya sayılamayan isimlerde a/an kullanma.',
    ],
    'a1_singular_plural': [
      'Günlük bağlam: Sayı, miktar ve eşya anlatmak.',
      'Kısa not: Birden büyük sayılardan sonra isim genellikle çoğul olur.',
      'Düzenli çoğullarda genellikle -s veya -es gelir.',
      'Child → children gibi düzensiz çoğulları ayrı öğren.',
    ],
    'a1_there_is_are': [
      'Günlük bağlam: Oda, sınıf ve şehirde ne olduğunu anlatmak.',
      'Kısa not: Önce ismin tekil mi çoğul mu olduğuna bak.',
      'Tekil isimle there is, çoğul isimle there are kullan.',
      'Sorularda is/are başa gelir: Is there...? / Are there...?',
    ],
    'a1_present_simple': [
      'Günlük bağlam: Rutinler, alışkanlıklar ve genel gerçekler.',
      'Kısa not: Rutin anlatırken Present Simple kullan.',
      'Every day, usually ve often bu yapının güçlü ipuçlarıdır.',
      'Does/doesn\'t varsa ana fiil yalın kalır.',
    ],
    'a1_present_continuous': [
      'Günlük bağlam: Şu anda olan bir hareketi anlatmak.',
      'Kısa not: Şu an olan eylemde am/is/are + V-ing kullan.',
      'Now, right now ve at the moment bu yapının ipuçlarıdır.',
      'Be fiili yoksa cümle eksik olur: She is reading.',
    ],
    'a1_can_cant': [
      'Günlük bağlam: Yetenek belirtmek, kibar izin veya rica.',
      'Kısa not: Can sonrasında fiil yalın kalır.',
      "Can sonrasında fiile -s, -ing veya to eklenmez.",
      'Kısa cevapta yine can/can\'t kullanılır.',
    ],
    'a1_have_has_got': [
      'Günlük bağlam: Aile, eşya ve kişisel özellikler.',
      'Kısa not: He/she/it ile has got kullan.',
      'I/you/we/they ile have got kullan.',
      'Kısa cevapta got tekrar edilmez: Yes, I have.',
    ],
    'a1_basic_prepositions': [
      'Günlük bağlam: Bir şeyin nerede olduğunu veya ne zaman olacağını söylemek.',
      'Kısa not: Önce bağlama bak: alan mı, yüzey mi, net nokta mı?',
      'In iç/alan, on yüzey/gün, at net nokta/saat anlatır.',
      'Yer ve zaman örneklerini ayrı ayrı kontrol et.',
    ],
    'a1_imperatives': [
      'Günlük bağlam: Sınıfta, evde veya günlük yönergelerde.',
      'Kısa not: Komutlar genellikle yalın fiille başlar.',
      'Please eklemek komutu daha yumuşak ve kibar yapar.',
      "Olumsuz komut için Don't + fiil kullanılır.",
    ],
    'a1_demonstratives': [
      'Günlük bağlam: Bir şeyi gösterirken, tanıtırken veya seçerken.',
      'Kısa not: Yakın/uzak ve tekil/çoğul bilgisini birlikte kontrol et.',
      'This/that tekil; these/those çoğul isimlerle kullanılır.',
      'This/these yakın, that/those uzak şeyleri gösterir.',
    ],
    'a1_wh_questions': [
      'Günlük bağlam: Kişi, yer, zaman veya sebep hakkında bilgi almak.',
      'Kısa not: Soru kelimesinden sonra doğru soru sırasını koru.',
      'Do/does soru sırasını korur; does sonrasında fiil yalın kalır.',
      'Wh-soruları kısa ve net bilgi ister: yer, zaman, kişi veya sebep.',
    ],
  };
  return map[key]?.map(_cleanA1DisplayText).nonNulls.toList(growable: false);
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

GrammarDisplayLesson grammarDisplayLessonFor(
    GrammarLesson lesson, bool isEnglish) {
  final key = _grammarDisplayKey(lesson);

  // A1: always use clean Turkish packs — never rely on repairMojibake
  final isA1 = key.startsWith('a1_');

  final titleTr = isA1
      ? (_a1CleanTurkishLearnTitle(key) ??
          _cleanRawGrammarKey(key) ??
          'A1 Dil bilgisi')
      : _safeTurkishLearnTitleFor(lesson, key);

  final bodyTr = isA1
      ? (_a1CleanTurkishLearnBody(key) ??
          _genericTurkishLearnBodyFor(lesson, key))
      : _safeTurkishLearnBodyFor(lesson, key);

  final structureTr = isA1
      ? (_a1CleanTurkishStructureBullets(key) ??
          _genericTurkishStructureFor(lesson, key))
      : _safeTurkishStructureFor(lesson, key, bodyTr);

  final usageTr = isA1
      ? (_a1CleanTurkishUsageNotes(key) ??
          _genericTurkishUsageFor(lesson, key, bodyTr))
      : _safeTurkishUsageFor(lesson, key, bodyTr);

  return GrammarDisplayLesson(
    learnTitleEn: isA1
        ? _a1CleanEnglishLearnTitle(key, lesson)
        : _cleanEnglishLessonTitle(lesson),
    learnTitleTr: titleTr,
    learnBodyEn: _cleanEnglishLessonBody(lesson),
    learnBodyTr: bodyTr,
    structureBulletsEn: _englishStructureBullets(lesson),
    structureBulletsTr: structureTr,
    usageNotesEn: _englishUsageNotes(lesson),
    usageNotesTr: usageTr,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// NON-A1 SAFE HELPERS (unchanged logic, preserved for B1-C2)
// ─────────────────────────────────────────────────────────────────────────────

String _safeTurkishLearnTitleFor(GrammarLesson lesson, String key) {
  final direct = _cleanTurkishTextOrNull(_turkishLearnTitleForKey(key));
  if (direct != null) return direct;
  final level = _levelLabelFromGrammarKey(key);
  final englishTitle = _cleanEnglishLessonTitle(lesson).trim();
  if (englishTitle.isEmpty) return '$level Dil bilgisi konusu';
  return '$level Konu anlatımı: $englishTitle';
}

String _safeTurkishLearnBodyFor(GrammarLesson lesson, String key) {
  final direct = _cleanTurkishTextOrNull(_turkishLearnBodyForKey(key));
  if (direct != null) return direct;
  return _genericTurkishLearnBodyFor(lesson, key);
}

List<String> _safeTurkishStructureFor(
  GrammarLesson lesson,
  String key,
  String bodyTr,
) {
  final fromBody = _turkishLearnBullets(bodyTr)
      .map(repairGrammarMojibake)
      .where((item) =>
          item.trim().isNotEmpty &&
          !_looksEnglishFallback(item) &&
          !_looksBrokenTurkishDisplayText(item))
      .toList(growable: false);
  if (fromBody.length >= 3) return fromBody;
  return _genericTurkishStructureFor(lesson, key);
}

List<String> _safeTurkishUsageFor(
  GrammarLesson lesson,
  String key,
  String bodyTr,
) {
  final direct = grammarTurkishUsageNotesFor(lesson)
      .map(repairGrammarMojibake)
      .where((item) =>
          item.trim().isNotEmpty &&
          !_looksEnglishFallback(item) &&
          !_looksBrokenTurkishDisplayText(item))
      .toList(growable: false);
  if (direct.isNotEmpty) return direct;
  return _genericTurkishUsageFor(lesson, key, bodyTr);
}

String? _cleanTurkishTextOrNull(String? value) {
  final clean =
      _cleanDisplaySpacing(repairGrammarMojibake((value ?? '').trim()));
  if (clean.isEmpty) return null;
  if (_looksEnglishFallback(clean)) return null;
  if (_looksBrokenTurkishDisplayText(clean)) return null;
  return clean;
}

String? _cleanA1DisplayText(String? value) {
  final clean =
      _cleanDisplaySpacing(repairGrammarMojibake((value ?? '').trim()));
  if (clean.isEmpty) return null;
  if (_looksBrokenTurkishDisplayText(clean)) return null;
  return clean;
}

String _cleanDisplaySpacing(String value) {
  return value
      .replaceAllMapped(RegExp(r'([.!?])(?=\S)'), (match) => '${match[1]} ')
      .replaceAll('NesneZamirleri', 'Nesne Zamirleri')
      .replaceAll('ÖzneZamirleri', 'Özne Zamirleri')
      .replaceAll('ÖzneveNesneZamirleri', 'Özne ve Nesne Zamirleri')
      .replaceAll('Özne ve NesneZamirleri', 'Özne ve Nesne Zamirleri')
      .replaceAll('İyelikSıfatları', 'İyelik Sıfatları')
      .replaceAll('SahiplikSıfatları', 'Sahiplik Sıfatları')
      .replaceAll('EmirCümleleri', 'Emir Cümleleri')
      .replaceAll('İşaretZamirleri', 'İşaret Zamirleri')
      .replaceAll('TemelEdatlar', 'Temel Edatlar')
      .replaceAll('wh-sorular1', 'wh-soruları')
      .replaceAll('Wh-sorular1', 'Wh-soruları')
      .replaceAll('Soru yap?s?', 'Soru yapısı')
      .replaceAll('Soruyapısı', 'Soru yapısı')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String? _cleanRawGrammarKey(String key) {
  if (!RegExp(r'^[a-c][12]_').hasMatch(key)) return null;
  final words = key
      .replaceFirst(RegExp(r'^[a-c][12]_'), '')
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part == 'cant'
          ? "Can't"
          : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
  return words.isEmpty ? null : words;
}

bool _looksBrokenTurkishDisplayText(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return false;
  const turkishLetters = 'A-Za-zÇĞİÖŞÜçğıöşü';
  return clean.contains('\uFFFD') ||
      clean.contains('ï¿½') ||
      clean.contains('â€') ||
      RegExp(r'[ÃÄÅ]').hasMatch(clean) ||
      // digit-1 replacing Turkish vowels, e.g. "yap1" instead of "yapı"
      RegExp('[$turkishLetters]1[$turkishLetters]').hasMatch(clean) ||
      // ? inside Turkish words
      RegExp('[$turkishLetters]\\?[$turkishLetters]').hasMatch(clean) ||
      // underscore replacement
      RegExp('[$turkishLetters]_[$turkishLetters]').hasMatch(clean) ||
      // leading ?/^ replacement in words such as "?lk" or "^u".
      RegExp(r'(^|\s)[?^][A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(clean);
}

bool _looksEnglishFallback(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return true;
  final hasTurkishChars = RegExp(r'[çğıöşüÇĞİÖŞÜ]').hasMatch(clean);
  if (hasTurkishChars) return false;
  final lower = clean.toLowerCase();
  final englishMarkers = <String>[
    'use ',
    'uses ',
    'this lesson',
    'you can ',
    'you will ',
    'subject +',
    'verb +',
    'when we ',
    'we use ',
    'common in',
    'formal ',
    'informal ',
    'present ',
    'past ',
    'future ',
    'conditional',
    'passive ',
    'relative ',
    'modal ',
  ];
  final markerHits =
      englishMarkers.where((marker) => lower.contains(marker)).length;
  if (markerHits >= 1 && !lower.contains('öğren')) return true;
  final wordCount = clean.split(RegExp(r'\s+')).length;
  final asciiWordCount = RegExp(r'\b[a-zA-Z]{3,}\b').allMatches(clean).length;
  return wordCount >= 5 && asciiWordCount >= wordCount * 0.75;
}

String _levelLabelFromGrammarKey(String key) {
  if (key.startsWith('a1_')) return 'A1';
  if (key.startsWith('a2_')) return 'A2';
  if (key.startsWith('b1_')) return 'B1';
  if (key.startsWith('b2_')) return 'B2';
  if (key.startsWith('c1_')) return 'C1';
  if (key.startsWith('c2_')) return 'C2';
  return 'Bu';
}

String _genericTurkishLearnBodyFor(GrammarLesson lesson, String key) {
  final title =
      _turkishLearnTitleForKey(key) ?? _cleanEnglishLessonTitle(lesson).trim();
  final purpose = _turkishPurposeForKey(key);
  final focus = _turkishFormFocusForKey(key);
  final register = _turkishLevelFocusForKey(key);
  return '$title, $purpose. $focus. $register.';
}

List<String> _genericTurkishStructureFor(GrammarLesson lesson, String key) {
  final rows = normalizedGrammarFormulaRowsFor(lesson)
      .where((row) => row.pattern.trim().isNotEmpty)
      .take(3)
      .toList(growable: true);
  final bullets = <String>[
    for (final row in rows)
      'Kalıp: ${repairGrammarMojibake(row.pattern.trim())}',
    _turkishFormFocusForKey(key),
    'Kontrol: ${_turkishTeacherUsageNoteForKey(key)}',
  ];
  return bullets
      .where((item) => item.trim().isNotEmpty)
      .take(5)
      .toList(growable: false);
}

List<String> _genericTurkishUsageFor(
    GrammarLesson lesson, String key, String bodyTr) {
  final example = _grammarPracticalExample(lesson);
  return <String>[
    'Ne zaman: ${_turkishPurposeForKey(key)}.',
    'Bağlam: ${_turkishUsageContextForKey(key)}',
    'Pratik örnek: $example',
    'Öğretmen notu: ${_turkishTeacherUsageNoteForKey(key)}',
  ];
}

String _turkishPurposeForKey(String key) {
  if (key.contains('present_simple')) {
    return 'rutinleri, alışkanlıkları ve genel doğruları anlatmak için kullanılır';
  }
  if (key.contains('present_continuous')) {
    return 'şu anda süren eylemleri veya kesinleşmiş yakın planları anlatmak için kullanılır';
  }
  if (key.contains('past_perfect')) {
    return 'geçmişte başka bir olaydan önce gerçekleşen eylemi ve süreyi netleştirmek için kullanılır';
  }
  if (key.contains('past_continuous')) {
    return 'geçmişte belirli bir anda devam eden eylemi ve olayın arka planını anlatmak için kullanılır';
  }
  if (key.contains('past_simple')) {
    return 'geçmişte başlayıp bitmiş olayları belirli bir zamanla anlatmak için kullanılır';
  }
  if (key.contains('future_perfect_continuous')) {
    return 'gelecekteki bir noktaya kadar sürecek eylemin süresini vurgulamak için kullanılır';
  }
  if (key.contains('future_perfect')) {
    return 'gelecekteki bir noktadan önce tamamlanmış olacak eylemleri anlatmak için kullanılır';
  }
  if (key.contains('future_continuous')) {
    return 'gelecekte belirli bir anda devam ediyor olacak eylemleri anlatmak için kullanılır';
  }
  if (key.contains('present_perfect_continuous')) {
    return 'geçmişte başlayıp şimdiye kadar süren eylemin süresini veya güncel sonucunu vurgulamak için kullanılır';
  }
  if (key.contains('present_perfect')) {
    return 'geçmiş deneyimi, güncel sonucu ve şimdiyle bağlantısı olan olayları anlatmak için kullanılır';
  }
  if (key.contains('conditional')) {
    return 'şart ile sonuç arasındaki gerçek, olası, hayali veya geçmişe dönük ilişkiyi kurmak için kullanılır';
  }
  if (key.contains('passive')) {
    return 'eylemi yapan kişiden çok eyleme, sonuca veya sürece odaklanmak için kullanılır';
  }
  if (key.contains('reported')) {
    return 'başka birinin sözünü, sorusunu veya talebini dolaylı biçimde aktarmak için kullanılır';
  }
  if (key.contains('relative')) {
    return 'bir isim hakkında ek bilgi verip cümleleri daha akıcı biçimde birleştirmek için kullanılır';
  }
  if (key.contains('gerund') || key.contains('infinitive')) {
    return 'fiilden sonra V-ing ya da to + V1 seçimini anlam ve fiil kalıbına göre yapmak için kullanılır';
  }
  if (key.contains('modal')) {
    return 'olasılık, zorunluluk, tavsiye, çıkarım ve konuşanın kesinlik derecesini göstermek için kullanılır';
  }
  if (key.contains('inversion')) {
    return 'kelime sırasını değiştirerek güçlü vurgu ve daha resmi bir ton kurmak için kullanılır';
  }
  if (key.contains('emphasis') || key.contains('cleft')) {
    return 'cümlenin en önemli bölümünü öne çıkarıp odağı bilinçli biçimde yönetmek için kullanılır';
  }
  if (key.contains('hedging')) {
    return 'iddiaları kanıt düzeyine uygun, ölçülü ve akademik bir tonla sunmak için kullanılır';
  }
  if (key.contains('nominalisation')) {
    return 'eylem ve süreçleri isim gruplarına dönüştürerek daha yoğun ve resmi anlatım kurmak için kullanılır';
  }
  if (key.contains('link') ||
      key.contains('concession') ||
      key.contains('subordination') ||
      key.contains('discourse')) {
    return 'fikirler arasındaki karşıtlık, neden, sonuç ve bilgi akışını açık biçimde kurmak için kullanılır';
  }
  if (key.contains('register')) {
    return 'dilbilgisi ve kelime seçimini hedef kitleye, amaca ve resmiyet düzeyine uyarlamak için kullanılır';
  }
  if (key.contains('ellipsis') || key.contains('substitution')) {
    return 'gereksiz tekrarı azaltırken anlamı ve metin içi bağı korumak için kullanılır';
  }
  if (key.contains('comparison') || key.contains('comparative')) {
    return 'kişi, nesne veya fikirler arasındaki farkı hassas biçimde karşılaştırmak için kullanılır';
  }
  if (key.contains('quantifier') ||
      key.contains('countable') ||
      key.contains('some_any')) {
    return 'isim türüne göre miktarı, sayıyı ve belirsiz niceliği doğru ifade etmek için kullanılır';
  }
  if (key.contains('question')) {
    return 'doğru soru kelimesi ve kelime sırasıyla net bilgi istemek için kullanılır';
  }
  if (key.contains('pronoun') || key.contains('possessive')) {
    return 'kişi, nesne ve sahiplik ilişkilerini tekrar etmeden açık biçimde göstermek için kullanılır';
  }
  if (key.contains('article')) {
    return 'bir ismin genel, ilk kez söylenen veya belirli olduğunu göstermek için kullanılır';
  }
  if (key.contains('preposition')) {
    return 'yer, zaman ve nesneler arasındaki ilişkiyi doğru edatla anlatmak için kullanılır';
  }
  if (key.contains('will') || key.contains('going_to')) {
    return 'gelecek kararlarını, planları, niyetleri ve tahminleri uygun yapıyla anlatmak için kullanılır';
  }
  if (key.contains('wish')) {
    return 'gerçek olmayan istekleri, pişmanlığı ve değişmesini istediğin durumları anlatmak için kullanılır';
  }
  return 'anlamı doğru kelime sırası ve uygun fiil formuyla açık biçimde kurmak için kullanılır';
}

String _turkishFormFocusForKey(String key) {
  if (key.contains('question') || key.contains('inversion')) {
    return 'Yardımcı fiilin özneye göre seçimine ve cümledeki yerine özellikle dikkat et';
  }
  if (key.contains('perfect')) {
    return 'Have, has veya had yardımcı fiili ile V3 formunu; continuous yapılarda ayrıca been + V-ing bölümünü kontrol et';
  }
  if (key.contains('passive')) {
    return 'Zamana uygun be formunu seç ve ana fiili V3 biçiminde kullan';
  }
  if (key.contains('conditional')) {
    return 'If bölümü ile sonuç bölümünün zaman ve anlam ilişkisini birlikte kontrol et';
  }
  if (key.contains('modal')) {
    return 'Modal fiilden sonra ana fiili yalın kullan ve seçtiğin modalın kesinlik derecesini koru';
  }
  if (key.contains('relative')) {
    return 'Tanımlanan isme göre who, which, that, whose veya where seçimini yap';
  }
  if (key.contains('gerund') || key.contains('infinitive')) {
    return 'İlk fiilin istediği V-ing veya to + V1 kalıbını bir bütün olarak öğren';
  }
  if (key.contains('comparison')) {
    return 'Sıfatın uzunluğuna ve düzensiz biçimine göre doğru karşılaştırma kalıbını seç';
  }
  if (key.contains('nominalisation') || key.contains('noun_phrase')) {
    return 'Ana anlamı korurken fiil, sıfat ve yan cümleleri kontrollü bir isim grubuna dönüştür';
  }
  return 'Özne, yardımcı fiil, ana fiil ve tamamlayıcıların sırasını model cümleyle karşılaştır';
}

String _turkishLevelFocusForKey(String key) {
  if (key.startsWith('a1_')) {
    return 'Önce kısa ve temiz bir model cümle kur; olumsuz ve soru biçimini sonra ekle';
  }
  if (key.startsWith('a2_')) {
    return 'Zaman ipucunu ve konuşma amacını bulduktan sonra uygun yapıyı seç';
  }
  if (key.startsWith('b1_')) {
    return 'Biçim kadar olaylar arasındaki zaman ve anlam ilişkisini de kontrol et';
  }
  if (key.startsWith('b2_')) {
    return 'Benzer yapılar arasındaki anlam farkını ve doğal kullanım bağlamını birlikte değerlendir';
  }
  if (key.startsWith('c1_') || key.startsWith('c2_')) {
    return 'Doğruluğun yanında vurgu, bilgi akışı, resmiyet ve nüans etkisini de değerlendir';
  }
  return 'Model cümleyi incele ve aynı yapıyla kendi örneğini kur';
}

String _grammarDisplayKey(GrammarLesson lesson) {
  final title = lesson.bigTitle.toLowerCase().trim();
  if (title == 'advanced conditionals') {
    final raw =
        '${lesson.oneLineGoal} ${lesson.teacherIntro} ${lesson.right} ${lesson.examples.join(' ')}'
            .toLowerCase();
    if (raw.contains('were it not for') ||
        raw.contains('had it not been for')) {
      return 'c2_advanced_conditionals';
    }
    return 'c1_advanced_conditionals';
  }
  const byTitle = <String, String>{
    'be: am / is / are': 'a1_be_verb',
    'subject and object pronouns': 'a1_subject_pronouns',
    'subject & object pronouns': 'a1_subject_pronouns',
    'possessive adjectives': 'a1_possessive_adjectives',
    'possessives': 'a1_possessive_adjectives',
    'there is / there are': 'a1_there_is_are',
    'articles: a / an / the': 'a1_articles',
    'plural and quantity basics': 'a1_singular_plural',
    'plural & quantity basics': 'a1_singular_plural',
    'present simple': 'a1_present_simple',
    'present continuous': 'a1_present_continuous',
    "can / can't": 'a1_can_cant',
    'have got / has got': 'a1_have_has_got',
    'prepositions: in / on / at': 'a1_basic_prepositions',
    'basic prepositions: in / on / at': 'a1_basic_prepositions',
    'imperatives': 'a1_imperatives',
    'this / that / these / those': 'a1_demonstratives',
    'wh- questions': 'a1_wh_questions',
    'past simple': 'a2_past_simple',
    'future with will': 'a2_will',
    'be going to': 'a2_going_to',
    'comparatives': 'a2_comparatives',
    'superlatives': 'a2_superlatives',
    'countable / uncountable & quantifiers': 'a2_countable_uncountable',
    'some / any / much / many / a lot of': 'a2_some_any_much_many',
    "should / shouldn't": 'a2_should',
    'must / have to': 'a2_must_have_to',
    'object pronouns & possessive pronouns': 'a2_object_possessive_pronouns',
    'adverbs of frequency & manner': 'a2_adverbs_frequency_manner',
    'infinitive of purpose': 'a2_infinitive_purpose',
    'gerunds and infinitives intro': 'a2_gerund_infinitive',
    'present perfect': 'b1_present_perfect',
    'present perfect continuous': 'b1_present_perfect_continuous',
    'present perfect vs past simple': 'b1_present_perfect_vs_past_simple',
    'past perfect': 'b1_past_perfect',
    'past perfect continuous': 'b1_past_perfect_continuous',
    'future continuous': 'b1_future_continuous',
    'future perfect intro': 'b1_future_perfect_intro',
    'first conditional': 'b1_first_conditional',
    'second conditional': 'b1_second_conditional',
    'passive voice': 'b1_passive_voice',
    'passive voice by tense': 'b1_passive_by_tense',
    'modal verbs': 'b1_modal_verbs',
    'modals of advice, obligation and possibility': 'b1_modal_meanings',
    'reported speech intro': 'b1_reported_speech',
    'reported questions': 'b1_reported_questions',
    'reported commands': 'b1_reported_commands',
    'relative clauses': 'b1_relative_clauses',
    'defining relative clauses': 'b1_defining_relative_clauses',
    'non-defining relative clauses intro': 'b1_non_defining_relative_clauses',
    'gerund vs infinitive': 'b1_gerund_vs_infinitive',
    'used to / be used to / get used to': 'b1_used_to_forms',
    'question tags and indirect questions': 'b1_tags_indirect_questions',
    'future perfect': 'b2_future_perfect',
    'future perfect continuous': 'b2_future_perfect_continuous',
    'advanced gerund / infinitive': 'b2_advanced_gerund_infinitive',
    'passive reporting structures': 'b2_passive_reporting',
    'have something done': 'b2_have_something_done',
    'complex relative clauses': 'b2_complex_relative_clauses',
    'participle clauses': 'b2_participle_clauses',
    'conditionals review and mixed conditionals': 'b2_mixed_conditionals',
    'wish / if only': 'b2_wish_if_only',
    'modal perfects': 'b2_modal_perfects',
    'inversion intro': 'b2_inversion_intro',
    'emphasis structures': 'b2_emphasis_structures',
    'advanced linking devices': 'b2_advanced_linking',
    'concession clauses': 'b2_concession_clauses',
    'purpose result and reason clauses': 'b2_purpose_result_reason',
    'advanced passive voice': 'b2_advanced_passive',
    'third conditional': 'b2_third_conditional',
    'modal deduction': 'b2_modal_deduction',
    'advanced quantifiers': 'b2_advanced_quantifiers',
    'formal comparisons': 'b2_formal_comparisons',
    'precise comparisons': 'b2_formal_comparisons',
    'full inversion': 'c1_full_inversion',
    'cleft sentences': 'c1_cleft_sentences',
    'emphatic do': 'c1_emphatic_do',
    'advanced modality': 'c1_advanced_modality',
    'advanced linkers': 'c1_advanced_linkers',
    'noun clauses': 'c1_noun_clauses',
    'reduced relative clauses': 'c1_reduced_relative_clauses',
    'nominalisation intro': 'c1_nominalisation_intro',
    'advanced passive': 'c1_advanced_passive',
    'hedging': 'c1_hedging',
    'reduced clauses': 'c1_reduced_clauses',
    'register control': 'c1_register_control',
    'subjunctive / formulaic structures': 'c1_subjunctive_formulaic',
    'ellipsis / substitution intro': 'c1_ellipsis_substitution',
    'academic nominalisation': 'c2_academic_nominalisation',
    'advanced nominalisation': 'c2_academic_nominalisation',
    'fronting / information structure': 'c2_fronting_information_structure',
    'ellipsis and substitution': 'c2_ellipsis_substitution',
    'advanced hedging': 'c2_advanced_hedging',
    'register shifts': 'c2_register_shifts',
    'dense noun phrases': 'c2_dense_noun_phrases',
    'complex subordination': 'c2_complex_subordination',
    'advanced concession': 'c2_advanced_concession',
    'advanced emphasis': 'c2_advanced_emphasis',
    'stylistic inversion': 'c2_stylistic_inversion',
    'precision with modality': 'c2_precision_modality',
    'discourse flow': 'c2_discourse_flow',
  };
  return byTitle[title] ?? grammarLessonKey(lesson);
}

String? _turkishLearnTitleForKey(String key) => _turkishLearnTitles[key];
String? _turkishLearnBodyForKey(String key) => _turkishLearnBodies[key];

List<String> _turkishLearnBullets(String body) {
  final sentences = body
      .split(RegExp(r'(?<=\.)\s+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .take(3)
      .toList(growable: false);
  return sentences.isEmpty ? [body] : sentences;
}

bool _hasTurkishText(String value) {
  return RegExp(
          r'[\u00c7\u00e7\u011e\u011f\u0130\u0131\u00d6\u00f6\u015e\u015f\u00dc\u00fc]')
      .hasMatch(value);
}

List<String> _englishTeacherBulletsFor(GrammarLesson lesson) {
  final intro = lesson.teacherIntro
      .split(RegExp(r'[.\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty && !_hasTurkishText(e))
      .take(4)
      .toList(growable: false);
  if (intro.isNotEmpty) return intro;
  final formulaRows = lesson.formulaRows
      .map((row) => row.pattern.trim())
      .where((e) => e.isNotEmpty)
      .take(4)
      .toList(growable: false);
  if (formulaRows.isNotEmpty) return formulaRows;
  return lesson.examples
      .where((e) => e.trim().isNotEmpty && !_hasTurkishText(e))
      .take(4)
      .toList(growable: false);
}

List<String> _englishFocusPointsFor(GrammarLesson lesson) {
  final usage = lesson.usageBullets
      .where((e) => e.trim().isNotEmpty && !_hasTurkishText(e))
      .take(4)
      .toList(growable: false);
  if (usage.isNotEmpty) return usage;
  return _englishTeacherBulletsFor(lesson);
}

List<String> _englishStructureBullets(GrammarLesson lesson) {
  final rows = normalizedGrammarFormulaRowsFor(lesson)
      .where((row) => row.pattern.trim().isNotEmpty)
      .take(4)
      .map((row) {
    final label = row.label.trim();
    final prefix = label.isEmpty ? 'Pattern' : label;
    return '$prefix: ${row.pattern.trim()}';
  }).toList(growable: false);
  if (rows.isNotEmpty) return rows;
  return _englishTeacherBulletsFor(lesson);
}

List<String> _englishUsageNotes(GrammarLesson lesson) {
  final raw = lesson.usageBullets
      .where((e) => e.trim().isNotEmpty && !_hasTurkishText(e))
      .toList(growable: false);
  if (raw.isNotEmpty) return raw;
  return <String>[
    lesson.oneLineGoal.trim(),
    'Context: ${lesson.teacherIntro.trim()}',
    'Model: ${_grammarPracticalExample(lesson)}',
    'Check the meaning, word order, helper verb, and main verb form.',
  ].where((item) => item.isNotEmpty).take(4).toList(growable: false);
}

String _cleanEnglishLessonTitle(GrammarLesson lesson) => lesson.bigTitle;

String _cleanEnglishLessonBody(GrammarLesson lesson) {
  final goal = lesson.oneLineGoal.trim();
  final intro = lesson.teacherIntro.trim();
  if (goal.isNotEmpty && !_hasTurkishText(goal)) return goal;
  if (intro.isNotEmpty && !_hasTurkishText(intro)) return intro;
  return _englishTeacherBulletsFor(lesson).join(' ');
}

String _grammarPracticalExample(GrammarLesson lesson) {
  final candidates = <String>[
    lesson.right,
    ...lesson.examples,
    ...lesson.formulaRows.map((row) => row.sample),
  ];
  final example = candidates
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .firstWhere((value) => value.length <= 120,
          orElse: () => candidates.first.trim());
  return example.endsWith('.') || example.endsWith('?') || example.endsWith('!')
      ? example
      : '$example.';
}

// ─────────────────────────────────────────────────────────────────────────────
// TURKISH USAGE NOTES (non-A1 topics)
// ─────────────────────────────────────────────────────────────────────────────

List<String> grammarTurkishUsageNotesFor(GrammarLesson lesson) {
  final key = _grammarDisplayKey(lesson);
  // A1 usage notes are handled by _a1CleanTurkishUsageNotes — not here.
  if (key.startsWith('a1_')) return const <String>[];

  final body = _turkishLearnBodyForKey(key);
  if (body == null || body.trim().isEmpty) return const <String>[];

  final when = _firstSentence(body);
  final context = _turkishUsageContextForKey(key);
  final example = _grammarPracticalExample(lesson);
  final note = _turkishTeacherUsageNoteForKey(key);

  return <String>[
    'Ne zaman: $when',
    'Bağlam: $context',
    'Pratik örnek: $example',
    'Öğretmen notu: $note',
  ];
}

String grammarTurkishUsageSummaryFor(GrammarLesson lesson) {
  return grammarTurkishUsageNotesFor(lesson).join('\n');
}

String _firstSentence(String value) {
  final parts = value
      .split(RegExp(r'(?<=\.)\s+'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  return parts.isEmpty ? value.trim() : parts.first;
}

String _turkishUsageContextForKey(String key) {
  if (key.startsWith('a1_')) {
    const a1ctx = <String, String>{
      'a1_be_verb':
          'Tanışma, sınıf içi konuşma, yaş, meslek, duygu ve yer bilgisinde kullanılır.',
      'a1_present_simple':
          'Günlük rutin, okul, iş, aile ve genel alışkanlık anlatırken kullanılır.',
      'a1_present_continuous':
          'Şu anda olan bir işi telefonda, sınıfta veya günlük konuşmada anlatırken kullanılır.',
      'a1_can_cant':
          'Yetenek, izin ve kısa rica durumlarında doğal bir seçimdir.',
      'a1_basic_prepositions':
          'Eşyanın yeri, buluşma noktası, saat ve gün bilgisi verirken kullanılır.',
      'a1_wh_questions':
          'Kişi, yer, zaman ve sebep hakkında bilgi almak istediğinde kullanılır.',
    };
    return a1ctx[key] ??
        'Kendini tanıtma, sınıf, ev ve basit günlük konuşmalarda kullanılır.';
  }
  if (key.startsWith('a2_')) {
    if (key.contains('past_simple'))
      return 'Dün, geçen hafta, tatil veya bitmiş bir olay anlatırken kullanılır.';
    if (key == 'a2_will')
      return 'Hızlı karar, teklif, söz verme veya tahmin yaparken kullanılır.';
    if (key == 'a2_going_to')
      return 'Planlarını veya gördüğün kanıta dayalı tahminleri anlatırken kullanılır.';
    if (key == 'a2_comparatives')
      return 'İki kişi, yer, nesne veya seçeneği karşılaştırırken kullanılır.';
    if (key == 'a2_superlatives')
      return 'Bir grubun en belirgin üyesini veya özelliğini anlatırken kullanılır.';
    if (key == 'a2_countable_uncountable')
      return 'Alışverişte, tariflerde ve miktar konuşmalarında isim türünü doğru seçmek için kullanılır.';
    if (key == 'a2_some_any_much_many')
      return 'Yiyecek, içecek, para, zaman ve günlük ihtiyaçların miktarını anlatırken kullanılır.';
    if (key == 'a2_should')
      return 'Arkadaşına veya ekip arkadaşına yumuşak tavsiye verirken kullanılır.';
    if (key == 'a2_must_have_to')
      return 'Kural, görev, zorunluluk ve yapılması gereken işleri anlatırken kullanılır.';
    if (key == 'a2_object_possessive_pronouns')
      return 'Kişileri ve sahipliği tekrar etmeden daha doğal cümleler kurarken kullanılır.';
    if (key == 'a2_adverbs_frequency_manner')
      return 'Bir eylemin ne sıklıkta veya nasıl yapıldığını anlatırken kullanılır.';
    if (key == 'a2_infinitive_purpose')
      return 'Bir yere neden gittiğini veya bir işi hangi amaçla yaptığını açıklarken kullanılır.';
    if (key == 'a2_gerund_infinitive')
      return 'Sevdiğin, bitirdiğin, istediğin veya karar verdiğin eylemleri anlatırken kullanılır.';
    return 'Günlük plan, alışveriş, okul, iş ve basit problem çözme konuşmalarında kullanılır.';
  }
  if (key.startsWith('b1_')) {
    if (key.contains('present_perfect'))
      return 'Deneyim, yakın sonuç ve geçmişin bugüne etkisi önemli olduğunda kullanılır.';
    if (key.contains('passive'))
      return 'Eylemi yapan kişi bilinmiyorsa, önemsizse veya sonuç daha önemliyse kullanılır.';
    if (key.contains('reported'))
      return 'Birinin söylediği, sorduğu veya istediği şeyi dolaylı aktarmak için kullanılır.';
    if (key.contains('conditional'))
      return 'Gerçekçi veya hayali şartlar ve sonuçlar hakkında konuşurken kullanılır.';
    return 'Sohbet, iş, okul ve anlatı içinde iki fikir arasındaki ilişkiyi daha net kurmak için kullanılır.';
  }
  return 'Gerçek iletişimde anlamı daha net, doğal ve bağlama uygun kurmak için kullanılır.';
}

String _turkishTeacherUsageNoteForKey(String key) {
  if (key.contains('question') || key.contains('reported_questions')) {
    return 'Soru gibi görünse bile kelime sırasına dikkat et; yapı çoğu zaman düz cümle mantığı ister.';
  }
  if (key.contains('passive')) {
    return 'Önce odak noktasını seç: yapan kişi mi önemli, yoksa yapılan iş ve sonuç mu?';
  }
  if (key.contains('conditional') || key.contains('wish')) {
    return 'Zaman biçimi gerçek zamanı değil, durumun gerçeklik derecesini de gösterebilir.';
  }
  if (key.contains('modal')) {
    return 'Modal seçimi sadece anlamı değil, konuşanın ne kadar emin konuştuğunu gösterir.';
  }
  if (key.contains('inversion') || key.contains('emphasis')) {
    return 'Bu yapıları her cümlede kullanma; gerçekten vurgu veya resmi ton gerektiğinde seç.';
  }
  if (key.startsWith('a1_')) {
    return 'Önce özne ve yardımcı kelimeyi doğru seç; kısa ve temiz cümle yeterlidir.';
  }
  if (key.startsWith('a2_')) {
    return 'Cümledeki zaman ipucunu ve konuşma amacını bul; doğru yapı genellikle oradan anlaşılır.';
  }
  return 'Yapıyı tek başına değil, konuşma amacıyla birlikte düşün.';
}

// ─────────────────────────────────────────────────────────────────────────────
// STATIC TITLE / BODY MAPS  (non-A1; A1 served by clean packs above)
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, String> _turkishLearnTitles = {
  // A2
  'a2_past_simple': 'Geçmiş Zaman (Past Simple)',
  'a2_will': 'Will ile Gelecek',
  'a2_going_to': 'Be Going To ile Planlar',
  'a2_comparatives': 'Karşılaştırma Sıfatları',
  'a2_superlatives': 'En Üstünlük Sıfatları',
  'a2_countable_uncountable': 'Sayılabilen / sayılamayan isimler',
  'a2_some_any_much_many': 'Miktar Bildiren Sözcükler',
  'a2_should': "Should ile Tavsiye",
  'a2_must_have_to': 'Must / Have To ile Zorunluluk',
  'a2_object_possessive_pronouns': 'Nesne ve sahiplik zamirleri',
  'a2_adverbs_frequency_manner': 'Sıklık ve durum zarfları',
  'a2_infinitive_purpose': 'Amaç Bildiren To + Fiil',
  'a2_gerund_infinitive': 'Gerund ve Infinitive Girişi',
  // B1
  'b1_present_perfect': 'Present Perfect',
  'b1_present_perfect_continuous': 'Present Perfect Continuous',
  'b1_present_perfect_vs_past_simple': 'Present Perfect ve Past Simple',
  'b1_past_perfect': 'Past Perfect',
  'b1_past_perfect_continuous': 'Past Perfect Continuous',
  'b1_future_continuous': 'Future Continuous',
  'b1_future_perfect_intro': 'Future Perfect Giriş',
  'b1_first_conditional': 'First Conditional',
  'b1_second_conditional': 'Second Conditional',
  'b1_passive_voice': 'Passive Voice',
  'b1_passive_by_tense': 'Tense ile Passive Voice',
  'b1_modal_verbs': 'Modal Verbs',
  'b1_modal_meanings': 'Tavsiye, Zorunluluk ve Olasılık Modalları',
  'b1_reported_speech': 'Reported Speech Giriş',
  'b1_reported_questions': 'Reported Questions',
  'b1_reported_commands': 'Reported Commands',
  'b1_relative_clauses': 'Relative Clauses',
  'b1_defining_relative_clauses': 'Defining Relative Clauses',
  'b1_non_defining_relative_clauses': 'Non-defining Relative Clauses',
  'b1_gerund_vs_infinitive': 'Gerund vs Infinitive',
  'b1_used_to_forms': 'used to / be used to / get used to',
  'b1_tags_indirect_questions': 'Question Tags ve Indirect Questions',
  // B2
  'b2_future_perfect': 'Future Perfect',
  'b2_future_perfect_continuous': 'Future Perfect Continuous',
  'b2_advanced_gerund_infinitive': 'Advanced Gerund / Infinitive',
  'b2_passive_reporting': 'Passive Reporting Structures',
  'b2_have_something_done': 'Have Something Done',
  'b2_complex_relative_clauses': 'Complex Relative Clauses',
  'b2_participle_clauses': 'Participle Clauses',
  'b2_mixed_conditionals': 'Mixed Conditionals',
  'b2_wish_if_only': 'Wish / If Only',
  'b2_modal_perfects': 'Modal Perfects',
  'b2_inversion_intro': 'Inversion Intro',
  'b2_emphasis_structures': 'Emphasis Structures',
  'b2_advanced_linking': 'Advanced Linking Devices',
  'b2_concession_clauses': 'Concession Clauses',
  'b2_purpose_result_reason': 'Purpose, result and reason clauses',
  'b2_advanced_passive': 'Advanced Passive Voice',
  'b2_third_conditional': 'Third Conditional',
  'b2_modal_deduction': 'Modal Deduction',
  'b2_advanced_quantifiers': 'Advanced Quantifiers',
  'b2_formal_comparisons': 'Formal Comparisons',
  // C1
  'c1_full_inversion': 'Full Inversion',
  'c1_cleft_sentences': 'Cleft Sentences',
  'c1_emphatic_do': 'Emphatic Do',
  'c1_advanced_modality': 'Advanced Modality',
  'c1_advanced_linkers': 'Advanced Linkers',
  'c1_noun_clauses': 'Noun Clauses',
  'c1_reduced_relative_clauses': 'Reduced Relative Clauses',
  'c1_nominalisation_intro': 'Nominalisation Intro',
  'c1_advanced_passive': 'Advanced Passive',
  'c1_hedging': 'Hedging',
  'c1_advanced_conditionals': 'Advanced Conditionals',
  'c1_reduced_clauses': 'Reduced Clauses',
  'c1_register_control': 'Register Control',
  'c1_subjunctive_formulaic': 'Subjunctive / Formulaic Structures',
  'c1_ellipsis_substitution': 'Ellipsis / Substitution Intro',
  // C2
  'c2_academic_nominalisation': 'Academic Nominalisation',
  'c2_fronting_information_structure': 'Fronting / Information Structure',
  'c2_ellipsis_substitution': 'Ellipsis and Substitution',
  'c2_advanced_hedging': 'Advanced Hedging',
  'c2_register_shifts': 'Register Shifts',
  'c2_dense_noun_phrases': 'Dense Noun Phrases',
  'c2_complex_subordination': 'Complex Subordination',
  'c2_advanced_concession': 'Advanced Concession',
  'c2_advanced_emphasis': 'Advanced Emphasis',
  'c2_stylistic_inversion': 'Stylistic Inversion',
  'c2_precision_modality': 'Precision with Modality',
  'c2_discourse_flow': 'Discourse Flow',
  'c2_advanced_conditionals': 'Advanced Conditionals',
};

// Non-A1 bodies only; A1 bodies come from _a1CleanTurkishLearnBody
const Map<String, String> _turkishLearnBodies = {
  'a2_past_simple':
      'Past Simple geçmişte belirli bir zamanda başlayıp bitmiş olayları anlatmak için kullanılır. Düzenli fiillerde genellikle -ed eklenir; düzensiz fiillerin ikinci hali kullanılır. Olumsuz ve soruda did kullanıldığı için ana fiil yalın hale döner.',
  'a2_will':
      'Will hızlı kararlar, tahminler, söz verme ve tekliflerde kullanılır. Will bütün öznelerle aynı kalır. Will sonrasında fiilin yalın hali gelir.',
  'a2_going_to':
      'Be going to planları ve eldeki kanıta dayalı tahminleri anlatır. Am, is veya are + going to + fiil yapısı kullanılır. Önceden niyet ettiğin şeylerde will yerine çoğu zaman going to daha doğaldır.',
  'a2_comparatives':
      'Comparatives iki kişi, yer, şey veya fikri karşılaştırmak için kullanılır. Kısa sıfatlarda genellikle -er, uzun sıfatlarda more kullanılır. Karşılaştırılan ikinci bölüm çoğu zaman than ile gelir.',
  'a2_superlatives':
      'Superlatives bir gruptaki en yüksek veya en belirgin özelliği anlatır. Kısa sıfatlarda genellikle -est, uzun sıfatlarda most kullanılır. Çoğu superlative yapısında the gerekir.',
  'a2_countable_uncountable':
      'Sayılabilen isimler tekil veya çoğul olabilir ve sayılarla kullanılabilir. Sayılamayan isimler genellikle çoğul -s almaz; miktarları some, much veya a little gibi ifadelerle anlatılır. A few sayılabilen çoğul isimlerle, a little sayılamayan isimlerle kullanılır.',
  'a2_some_any_much_many':
      'Some genellikle olumlu cümlelerde, any ise soru ve olumsuz cümlelerde kullanılır. Many sayılabilen çoğul isimlerle, much sayılamayan isimlerle gelir. A lot of hem sayılabilen çoğul hem de sayılamayan isimlerle kullanılabilir.',
  'a2_should':
      "Should öneri, tavsiye ve iyi fikir anlatmak için kullanılır. Should sonrasında fiilin yalın hali gelir. Should not veya shouldn't, bir şeyi yapmamanın daha iyi olduğunu söyler.",
  'a2_must_have_to':
      'Must ve have to zorunluluk veya gereklilik anlatır. Must çoğu zaman konuşanın güçlü kuralını vurgular; have to dış kural veya durumdan gelen zorunluluğu anlatabilir. Must not yasak, do not have to ise zorunda değilsin anlamındadır.',
  'a2_object_possessive_pronouns':
      'Nesne zamirleri fiilden veya edattan sonra gelir: me, him, her, us, them. Sahiplik zamirleri bir ismin yerini tutar: mine, yours, his, hers, ours, theirs. Her bir isimle birlikte kullanılabilir; hers ise tek başına kullanılır.',
  'a2_adverbs_frequency_manner':
      'Sıklık zarfları bir eylemin ne kadar sık olduğunu anlatır ve genellikle ana fiilden önce gelir. Be fiiliyle kullanıldığında usually, often veya never gibi zarflar be fiilinden sonra gelir. Durum zarfları eylemin nasıl yapıldığını anlatır: slowly, carefully, well.',
  'a2_infinitive_purpose':
      'To + fiilin yalın hali bir eylemin amacını açıklar. I went to the shop to buy bread cümlesinde to buy, gitme nedenini gösterir. Amaç anlatırken for + fiil yerine to + V1 kullanılır.',
  'a2_gerund_infinitive':
      'Bazı fiillerden sonra V-ing, bazı fiillerden sonra to + V1 gelir. Enjoy, finish ve avoid sonrasında V-ing; want, need ve decide sonrasında to + V1 kullanılır. Bu fiil kalıplarını tek tek değil, kısa ifadeler halinde öğrenmek daha güvenlidir.',
  'b1_present_perfect':
      'Present Perfect geçmişte yaşanan bir olayın bugünkü etkisini veya deneyimini anlatmak için kullanılır. Zamanın tam olarak ne zaman olduğu önemli değilse have/has + V3 yapısı kullanılır. Ever, never, already, yet ve just bu yapıyla sık görülür.',
  'b1_present_perfect_continuous':
      'Present Perfect Continuous geçmişte başlayıp şimdiye kadar süren veya sonucu şimdi görülen eylemleri anlatır. Yapı have/has been + V-ing şeklindedir. Süreyi vurgulamak istediğinde for ve since çok kullanılır.',
  'b1_past_perfect':
      'Past Perfect geçmişteki iki olaydan daha önce olanı anlatır. Yapı had + V3 şeklindedir. Özellikle before, after ve by the time ile olay sırasını netleştirmek için kullanılır.',
  'b1_passive_voice':
      'Passive Voice eylemi yapan kişiden çok eyleme veya sonuca odaklanır. Yapı be + V3 şeklindedir. Yapan kişi bilinmiyorsa, önemsizse veya özellikle gizli kalıyorsa passive daha doğal olabilir.',
  'b1_first_conditional':
      'First Conditional gerçekçi gelecek sonuçları anlatır. If bölümünde Present Simple, sonuç bölümünde genellikle will + V1 kullanılır. Olası bir şart ve onun muhtemel sonucunu bağlar.',
  'b1_second_conditional':
      'Second Conditional gerçek olmayan veya şu anda pek olası olmayan durumları anlatır. If bölümünde Past Simple, sonuç bölümünde would + V1 kullanılır. Hayal, öneri veya varsayım kurmak için kullanılır.',
  'b2_future_perfect':
      'Future Perfect gelecekteki bir noktadan önce tamamlanmış olacak eylemleri anlatır. Yapı will have + V3 şeklindedir. İş, teslim tarihi veya planlı hedeflerde tamamlanma vurgusu verir.',
  'b2_mixed_conditionals':
      'Mixed Conditionals farklı zamanlardaki şart ve sonuçları birleştirir. Geçmişteki bir durumun bugünkü sonucunu veya bugünkü bir durumun geçmişteki etkisini anlatabilir. Zaman ilişkisini doğru okumak ana noktadır.',
  'b2_modal_perfects':
      'Modal Perfects geçmiş hakkında olasılık, eleştiri veya kaçırılmış fırsat anlatır. Yapı modal + have + V3 şeklindedir. Must have güçlü çıkarım, might have olasılık, should have ise geçmişe dönük tavsiye verir.',
  'b2_inversion_intro':
      'Inversion cümleye vurgu ve daha resmi bir ton katmak için kullanılır. Özellikle olumsuz zarflardan sonra yardımcı fiil öznenin önüne gelir. Bu yapı günlük konuşmadan çok yazılı ve etkili anlatımda görülür.',
  'c1_full_inversion':
      'Full Inversion cümleye güçlü vurgu ve resmi bir ton verir. Never, rarely, only then gibi ifadeler başa geldiğinde yardımcı fiil öznenin önüne geçer. Bu yapı özellikle yazılı anlatımda dikkatli kullanılmalıdır.',
  'c1_cleft_sentences':
      'Cleft Sentences cümlenin bir parçasını özellikle vurgulamak için kullanılır. It is... that veya what... is yapıları odağı değiştirir. Konuşmada açıklık, yazıda ise vurgu ve düzen sağlar.',
  'c1_hedging':
      'Hedging kesin konuşmak istemediğimizde daha dikkatli ve ölçülü bir ton kurmak için kullanılır. It seems, may, appears to ve tends to gibi ifadeler iddiayı yumuşatır. Akademik, resmi veya hassas konularda çok önemlidir.',
  'c2_academic_nominalisation':
      'Academic Nominalisation karmaşık fikirleri isim grupları halinde yoğunlaştırır. Eylem yerine süreç, sonuç veya kavram öne çıkar. Akademik ve profesyonel yazıda daha nesnel ve sıkı bir anlatım sağlar.',
  'c2_advanced_hedging':
      'Advanced Hedging iddiaları çok hassas bir kesinlik derecesiyle sunar. Arguably, appears to, is likely to ve may well gibi ifadeler kanıt ile iddia arasındaki mesafeyi ayarlar. Akademik ve diplomatik dilde güvenilir ton kurar.',
};
