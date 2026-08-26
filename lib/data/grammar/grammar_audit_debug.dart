import 'package:speakery/data/grammar/grammar_models.dart';
import 'package:speakery/data/grammar/grammar_generator.dart';
import 'package:speakery/data/grammar/grammar_a1.dart';
import 'package:speakery/data/grammar/grammar_a2.dart';
import 'package:speakery/data/grammar/grammar_b1.dart';
import 'package:speakery/data/grammar/grammar_b2.dart';
import 'package:speakery/data/grammar/grammar_c1.dart';
import 'package:speakery/data/grammar/grammar_c2.dart';

/// PHASE184_GRAMMAR_AUDIT_DEBUG_HELPER
///
/// Put this file here:
/// lib/data/grammar/grammar_audit_debug.dart
///
/// Then call this anywhere temporarily, for example from a debug button,
/// initState, or main.dart after the app starts:
///
///   print(debugFullGrammarAuditReport(verbose: false));
///
/// For full details:
///
///   print(debugFullGrammarAuditReport(verbose: true));
///
/// This file does not change UI. It only checks whether the grammar data,
/// generator blueprint, context pack and quiz source look aligned.

class GrammarAuditResult {
  final String level;
  final String topicTitle;
  final String topicId;
  final String blueprintKey;
  final bool hasLesson;
  final bool blueprintKnown;
  final bool logicOk;
  final bool contextOk;
  final bool quizOk;
  final List<String> issues;

  const GrammarAuditResult({
    required this.level,
    required this.topicTitle,
    required this.topicId,
    required this.blueprintKey,
    required this.hasLesson,
    required this.blueprintKnown,
    required this.logicOk,
    required this.contextOk,
    required this.quizOk,
    required this.issues,
  });

  bool get ok =>
      hasLesson &&
      blueprintKnown &&
      logicOk &&
      contextOk &&
      quizOk &&
      issues.isEmpty;

  String get icon => ok ? '✅' : '❌';

  String shortKey() {
    if (blueprintKey.length <= 42) return blueprintKey;
    return '${blueprintKey.substring(0, 42)}...';
  }

  String oneLine() {
    return '$icon $level → $topicTitle';
  }

  String details() {
    final buffer = StringBuffer();
    buffer.writeln('$icon $level → $topicTitle');
    if (issues.isEmpty) {
      buffer.writeln('   Status: OK');
    } else {
      for (final issue in issues) {
        buffer.writeln('   Reason: $issue');
      }
    }
    return buffer.toString().trimRight();
  }
}

class GrammarLevelAuditSummary {
  final String level;
  final int expectedCount;
  final int actualCount;
  final int okCount;
  final int issueCount;

  const GrammarLevelAuditSummary({
    required this.level,
    required this.expectedCount,
    required this.actualCount,
    required this.okCount,
    required this.issueCount,
  });

  String oneLine() {
    final countIcon = expectedCount == actualCount ? '✅' : '⚠️';
    final qualityIcon = issueCount == 0 ? '✅' : '❌';
    return '$countIcon $qualityIcon $level: topics $actualCount/$expectedCount | ok $okCount | issues $issueCount';
  }
}

String debugFullGrammarAuditReport({bool verbose = false}) {
  final results = debugGrammarAuditResults();
  final summaries = debugGrammarLevelSummaries(results);
  final buffer = StringBuffer();

  buffer.writeln('SPEAKERY GRAMMAR AUDIT');
  buffer.writeln('Curriculum: ${debugGrammarCurriculumSummary()}');
  buffer.writeln('Generated topics checked: ${results.length}');
  buffer.writeln('');
  buffer.writeln('LEVEL SUMMARY');
  for (final summary in summaries) {
    buffer.writeln(summary.oneLine());
  }

  final broken = results.where((result) => !result.ok).toList(growable: false);
  buffer.writeln('');
  buffer.writeln('BROKEN / NEEDS ATTENTION: ${broken.length}');

  if (broken.isEmpty) {
    buffer.writeln(
        '✅ No obvious grammar alignment problems found by the audit helper.');
  } else {
    for (final result in broken) {
      buffer.writeln(result.details());
    }
  }

  if (verbose) {
    buffer.writeln('');
    buffer.writeln('FULL TOPIC REPORT');
    for (final result in results) {
      buffer.writeln(result.details());
    }
  }

  buffer.writeln('');
  buffer.writeln('HOW TO READ THIS');
  buffer.writeln('- Key tells us which generator blueprint the topic matched.');
  buffer.writeln(
      '- Unknown/generic key means the generator did not recognize that topic.');
  buffer.writeln(
      '- Context mismatch means Bağlam probably belongs to another grammar topic.');
  buffer.writeln(
      '- Quiz issue means options/model/avoid may be weak, duplicated, or mismatched.');

  return buffer.toString().trimRight();
}

List<GrammarAuditResult> debugGrammarAuditResults() {
  final results = <GrammarAuditResult>[];
  for (final level in const ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']) {
    for (final topic in _topicsForLevel(level)) {
      results.add(_auditTopic(topic));
    }
  }
  return results;
}

List<GrammarLevelAuditSummary> debugGrammarLevelSummaries(
    List<GrammarAuditResult> results) {
  return const ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
    final levelResults = results
        .where((result) => result.level == level)
        .toList(growable: false);
    final expected = grammarCurriculumForLevel(level).length;
    final ok = levelResults.where((result) => result.ok).length;
    return GrammarLevelAuditSummary(
      level: level,
      expectedCount: expected,
      actualCount: levelResults.length,
      okCount: ok,
      issueCount: levelResults.length - ok,
    );
  }).toList(growable: false);
}

GrammarAuditResult _auditTopic(GrammarTopic topic) {
  final lesson = _lessonForTopic(topic);
  final issues = <String>[];

  if (lesson == null) {
    return GrammarAuditResult(
      level: topic.level,
      topicTitle: topic.title,
      topicId: topic.id,
      blueprintKey: 'NO_LESSON',
      hasLesson: false,
      blueprintKnown: false,
      logicOk: false,
      contextOk: false,
      quizOk: false,
      issues: const ['No lesson returned for this topic.'],
    );
  }

  final blueprintKey = debugGrammarBlueprintKey(lesson);
  final blueprintKnown = _knownBlueprintKeys.contains(blueprintKey);
  if (!blueprintKnown) {
    issues.add('Unknown or generic blueprint key.');
  }

  final logicIssues = _auditLogic(topic, lesson, blueprintKey);
  final contextIssues = _auditContext(topic, lesson, blueprintKey);
  final quizIssues = _auditQuiz(topic, lesson, blueprintKey);

  issues.addAll(logicIssues);
  issues.addAll(contextIssues);
  issues.addAll(quizIssues);

  return GrammarAuditResult(
    level: topic.level,
    topicTitle: topic.title,
    topicId: topic.id,
    blueprintKey: blueprintKey,
    hasLesson: true,
    blueprintKnown: blueprintKnown,
    logicOk: logicIssues.isEmpty,
    contextOk: contextIssues.isEmpty,
    quizOk: quizIssues.isEmpty,
    issues: issues,
  );
}

List<String> _auditLogic(
    GrammarTopic topic, GrammarLesson lesson, String blueprintKey) {
  final issues = <String>[];
  final points = generateGrammarLogicPoints(lesson);

  if (points.isEmpty) {
    issues.add('No generator logic points.');
    return issues;
  }

  if (points.length < 2) {
    issues.add('Too few generator logic points: ${points.length}.');
  }

  for (final point in points) {
    if (!_sentenceLike(point.model)) {
      issues.add('Bad model sentence: "${point.model}"');
    }
    if (!_sentenceLike(point.avoid)) {
      issues.add('Bad avoid sentence: "${point.avoid}"');
    }
    if (_sameClean(point.model, point.avoid)) {
      issues.add('Model and avoid are the same: "${point.model}"');
    }
    if (_looksMeta(point.model) || _looksMeta(point.avoid)) {
      issues.add(
          'Meta text leaked into model/avoid: "${point.model}" / "${point.avoid}"');
    }
  }

  issues.addAll(_topicSpecificBlueprintIssues(blueprintKey, points));
  return issues;
}

List<String> _auditContext(
    GrammarTopic topic, GrammarLesson lesson, String blueprintKey) {
  final issues = <String>[];
  final trPack = generateGrammarContextPack(lesson, false);
  final enPack = generateGrammarContextPack(lesson, true);

  final trText = _packText(trPack).toLowerCase();
  final enText = _packText(enPack).toLowerCase();

  if (trPack.dialogueLines.isEmpty) {
    issues.add('Context has no dialogue lines.');
  }
  if (trPack.scenarios.length < 2) {
    issues.add(
        'Context has too few real-life scenarios: ${trPack.scenarios.length}.');
  }

  // Turkish UI text should be Turkish in title/scene/tip, but dialogue stays English.
  if (_mostlyEnglishUiText('${trPack.title} ${trPack.scene} ${trPack.tip}')) {
    issues.add('Turkish UI context text looks English: "${trPack.title}"');
  }

  for (final line in trPack.dialogueLines) {
    if (_mostlyTurkishDialogue(line.text)) {
      issues.add(
          'Context dialogue should stay English but looks Turkish: "${line.text}"');
      break;
    }
  }

  // Catch the exact bug we saw: be verb context falling into article context.
  if (blueprintKey == 'a1_be_verb') {
    if (_hasAny(
        trText, ['a / an / the', 'article', 'articles', 'bir şeyi ilk kez'])) {
      issues.add('Be verb context looks like article context.');
    }
    if (!_hasAny(enText, ['am', 'is', 'are'])) {
      issues.add('Be verb context does not mention am/is/are.');
    }
  }

  if (blueprintKey == 'a1_articles') {
    if (!_hasAny(enText,
        ['a / an / the', 'article', 'articles', 'a dog', 'an apple', 'the'])) {
      issues.add('Articles context does not look like articles.');
    }
  }

  if (blueprintKey == 'b2_future_perfect') {
    if (!_hasAny(enText, ['will have', 'by'])) {
      issues.add(
          'Future Perfect context does not contain will have / by-time logic.');
    }
  }

  if (blueprintKey == 'b2_future_perfect_continuous') {
    if (!_hasAny(enText, ['will have been', 'for'])) {
      issues.add(
          'Future Perfect Continuous context does not contain will have been / duration logic.');
    }
  }

  if (blueprintKey == 'c1_full_inversion' ||
      blueprintKey == 'c1_inversion' ||
      blueprintKey == 'b2_inversion_intro' ||
      blueprintKey == 'c2_stylistic_inversion') {
    if (_hasAny(enText, ['so / such', 'too / enough'])) {
      issues.add(
          'Inversion context appears to be mismatched with so/such or too/enough.');
    }
    if (!_hasAny(enText,
        ['never have', 'only then', 'little did', 'not only', 'inversion'])) {
      issues.add('Inversion context does not contain inversion signals.');
    }
  }

  return issues;
}

List<String> _auditQuiz(
    GrammarTopic topic, GrammarLesson lesson, String blueprintKey) {
  final issues = <String>[];
  final points = generateGrammarLogicPoints(lesson)
      .where((point) =>
          _sentenceLike(point.model) &&
          _sentenceLike(point.avoid) &&
          !_sameClean(point.model, point.avoid))
      .toList(growable: false);

  if (points.isEmpty) {
    issues.add('Quiz source has no usable model/avoid pair from generator.');
    return issues;
  }

  final first = points.first;
  if (_looksMeta(first.model) || _looksMeta(first.avoid)) {
    issues.add('Quiz source contains meta text instead of sentence options.');
  }

  if (blueprintKey == 'b2_future_perfect' &&
      !first.model.toLowerCase().contains('will have')) {
    issues.add('Future Perfect quiz source does not use will have + V3.');
  }

  if (blueprintKey == 'b2_future_perfect_continuous' &&
      !first.model.toLowerCase().contains('will have been')) {
    issues.add(
        'Future Perfect Continuous quiz source does not use will have been + V-ing.');
  }

  if ((blueprintKey == 'c1_full_inversion' ||
          blueprintKey == 'c1_inversion' ||
          blueprintKey == 'b2_inversion_intro') &&
      _hasAny(first.model.toLowerCase(),
          ['so +', 'such +', 'so cold', 'such a cold'])) {
    issues.add('Inversion quiz source appears to be so/such, not inversion.');
  }

  if (lesson.quiz.isEmpty) {
    issues.add(
        'Lesson quiz list is empty. Engine can still generate quiz, but data quiz is missing.');
  } else {
    for (final q in lesson.quiz.take(3)) {
      if (q.options.length < 3) {
        issues.add('Data quiz has too few options: "${q.prompt}"');
      }
      if (_looksMeta(q.answer)) {
        issues.add('Data quiz answer looks meta: "${q.answer}"');
      }
    }
  }

  return issues;
}

List<String> _topicSpecificBlueprintIssues(
    String key, List<GrammarLogicPoint> points) {
  final issues = <String>[];
  final allModels = points.map((p) => p.model).join(' ').toLowerCase();
  final allAvoids = points.map((p) => p.avoid).join(' ').toLowerCase();
  final all = '$allModels $allAvoids';

  void requireSignal(String label, List<String> signals) {
    if (!_hasAny(allModels, signals)) {
      issues.add(
          '$label model does not contain expected signal: ${signals.join(' / ')}');
    }
  }

  void forbidSignal(String label, List<String> signals) {
    if (_hasAny(all, signals)) {
      issues.add(
          '$label contains forbidden/mismatched signal: ${signals.join(' / ')}');
    }
  }

  void forbidStandaloneSignal(String label, List<String> signals) {
    final normalized =
        ' ${all.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ')} ';
    for (final signal in signals) {
      final needle = ' ${signal.toLowerCase()} ';
      if (normalized.contains(needle)) {
        issues.add(
            '$label contains forbidden/mismatched signal: ${signals.join(' / ')}');
        return;
      }
    }
  }

  switch (key) {
    case 'a1_be_verb':
      requireSignal('am/is/are', [' am ', ' is ', ' are ']);
      forbidSignal('am/is/are', ['a / an / the', 'an apple', 'the dog']);
      break;
    case 'a1_articles':
      requireSignal('articles', [' a ', ' an ', ' the ']);
      break;
    case 'a1_present_simple':
      requireSignal(
          'present simple', ['every', 'does', 'do not', 'studies', 'works']);
      break;
    case 'a2_will':
      requireSignal('will', ['will']);
      forbidSignal('will', ['will have', 'will have been']);
      break;
    case 'b2_future_perfect':
      requireSignal('future perfect', ['will have']);
      forbidSignal(
          'future perfect', ['will go', 'will help', 'will call', 'will open']);
      break;
    case 'b2_future_perfect_continuous':
      requireSignal('future perfect continuous', ['will have been']);
      break;
    case 'b2_inversion_intro':
    case 'c1_full_inversion':
    case 'c1_inversion':
      requireSignal(
          'inversion', ['never have', 'only then', 'little did', 'not only']);
      forbidStandaloneSignal('inversion', ['so', 'such', 'too', 'enough']);
      break;
    case 'c2_stylistic_inversion':
      requireSignal(
          'stylistic inversion', ['rarely have', 'only after', 'little did']);
      break;
    case 'c1_cleft_sentences':
      requireSignal('cleft', ['it was', 'what']);
      break;
    case 'c2_nominalisation':
    case 'academic_nominalisation':
      requireSignal('nominalisation',
          ['development', 'arrival', 'failure', 'implementation', 'analysis']);
      break;
  }

  return issues;
}

List<GrammarTopic> _topicsForLevel(String level) {
  switch (level.toUpperCase()) {
    case 'A1':
      return grammarA1Topics;
    case 'A2':
      return grammarA2Topics;
    case 'B1':
      return grammarB1Topics;
    case 'B2':
      return grammarB2Topics;
    case 'C1':
      return grammarC1Topics;
    case 'C2':
      return grammarC2Topics;
    default:
      return const [];
  }
}

GrammarLesson? _lessonForTopic(GrammarTopic topic) {
  switch (topic.level.toUpperCase()) {
    case 'A1':
      return a1LessonForTopic(topic);
    case 'A2':
      return a2LessonForTopic(topic);
    case 'B1':
      return b1LessonForTopic(topic);
    case 'B2':
      return b2LessonForTopic(topic);
    case 'C1':
      return c1LessonForTopic(topic);
    case 'C2':
      return c2LessonForTopic(topic);
    default:
      return null;
  }
}

String _packText(GrammarContextPack pack) {
  return [
    pack.title,
    pack.subtitle,
    pack.scene,
    pack.tip,
    ...pack.dialogueLines.map((line) => line.text),
    ...pack.scenarios.expand(
        (scenario) => [scenario.title, scenario.sentence, scenario.note]),
  ].join(' ');
}

bool _sentenceLike(String value) {
  final text = value.trim();
  if (text.length < 5) return false;
  if (!RegExp(r'[A-Za-z]').hasMatch(text)) return false;
  if (!RegExp(r'[.!?]$').hasMatch(text)) return false;
  if (_looksMeta(text)) return false;
  return true;
}

bool _looksMeta(String value) {
  final text = value.toLowerCase().trim();
  return _hasAny(text, [
    'choose the',
    'select the',
    'fill in',
    'bu yapıda',
    'doğru cümleyi',
    'boşluğu',
    'ana fiil',
    'yardımcı fiil',
    'pattern:',
  ]);
}

bool _sameClean(String a, String b) {
  return _clean(a) == _clean(b);
}

String _clean(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

bool _hasAny(String text, List<String> needles) {
  final lower = text.toLowerCase();
  return needles.any((needle) => lower.contains(needle.toLowerCase()));
}

bool _mostlyEnglishUiText(String value) {
  final text = value.toLowerCase();
  final englishHits = [
    'use ',
    'this ',
    'structure',
    'sentence',
    'example',
    'future',
    'past',
    'present',
    'context'
  ].where((word) => text.contains(word)).length;
  final turkishHits = [
    'kullan',
    'cümle',
    'yapı',
    'örnek',
    'geçmiş',
    'gelecek',
    'anlat',
    'için',
    'dikkat'
  ].where((word) => text.contains(word)).length;
  return englishHits >= 2 && turkishHits == 0;
}

bool _mostlyTurkishDialogue(String value) {
  final text = value.toLowerCase();
  return _hasAny(text, [
    ' mıyım',
    ' misin',
    ' musun',
    'evet',
    'hayır',
    'çünkü',
    'değil',
    'nasıl',
    'neden'
  ]);
}

const Set<String> _knownBlueprintKeys = {
  // A1
  'a1_be_verb',
  'a1_subject_pronouns',
  'a1_possessive_adjectives',
  'a1_articles',
  'a1_singular_plural',
  'a1_demonstratives',
  'a1_have_has_got',
  'a1_there_is_are',
  'a1_can_cant',
  'a1_imperatives',
  'a1_present_simple',
  'a1_adverbs_frequency',
  'a1_present_continuous',
  'a1_present_simple_vs_continuous',
  'a1_object_pronouns',
  'a1_possessive_s',
  'a1_prepositions_place',
  'a1_prepositions_time',
  'a1_some_any',
  'a1_countable_uncountable',
  'a1_how_much_many',
  'a1_question_words',
  'a1_basic_conjunctions',

  // A2
  'a2_past_simple',
  'a2_past_continuous',
  'a2_past_simple_vs_continuous',
  'a2_will',
  'a2_going_to',
  'a2_must_have_to',
  'a2_should',
  'a2_may_might',
  'a2_present_continuous_future',
  'a2_present_perfect_vs_past_simple',
  'a2_comparatives',
  'a2_superlatives',
  'a2_too_enough',
  'a2_present_perfect_intro',
  'a2_first_conditional',
  'a2_used_to',
  'a2_would_like',
  'a2_gerund_infinitive_intro',
  'a2_gerund_infinitive',
  'a2_relative_clauses_intro',
  'a2_zero_conditional',
  'a2_quantifiers',
  'a2_so_such',

  // B1
  'b1_present_perfect',
  'b1_present_perfect_continuous',
  'b1_present_perfect_vs_past',
  'b1_past_perfect',
  'b1_past_perfect_continuous',
  'b1_future_continuous',
  'b1_future_perfect_intro',
  'b1_first_conditional',
  'b1_second_conditional',
  'b1_passive_voice',
  'b1_passive_voice_by_tense',
  'b1_modal_verbs',
  'b1_reported_speech_intro',
  'b1_reported_questions',
  'b1_reported_commands',
  'b1_relative_clauses',
  'b1_defining_relative_clauses',
  'b1_non_defining_relative_intro',
  'b1_gerund_vs_infinitive',
  'b1_used_to_would',
  'b1_used_to_be_used_to_get_used_to',
  'b1_question_tags_indirect_questions',

  // B2
  'b2_future_perfect',
  'b2_future_perfect_continuous',
  'b2_advanced_gerund_infinitive',
  'b2_passive_reporting',
  'b2_causative_have_get',
  'b2_complex_relative_clauses',
  'b2_participle_clauses_intro',
  'b2_mixed_conditionals',
  'b2_wish_if_only',
  'b2_modal_deduction',
  'b2_modal_perfects',
  'b2_inversion_intro',
  'b2_emphasis_structures',
  'b2_advanced_linking_devices',
  'b2_concession_clauses',
  'b2_purpose_result_reason_clauses',
  'b2_advanced_passive',
  'b2_third_conditional',
  'b2_advanced_quantifiers',
  'b2_formal_comparisons',
  'b2_reported_speech_advanced',
  'b2_non_defining_relative_clauses',

  // C1
  'c1_full_inversion',
  'c1_inversion',
  'c1_cleft_sentences',
  'c1_emphasis_do',
  'c1_advanced_modality',
  'c1_advanced_linkers',
  'c1_noun_clauses',
  'c1_reduced_relative_clauses',
  'c1_nominalisation_intro',
  'c1_advanced_passive',
  'c1_hedging',
  'c1_advanced_conditionals',
  'c1_reduced_clauses',
  'c1_register_control',
  'c1_subjunctive_formulaic',
  'c1_ellipsis_substitution_intro',

  // C2
  'c2_nominalisation',
  'academic_nominalisation',
  'c2_hedging_academic_caution',
  'c2_ellipsis_substitution',
  'c2_fronting_information_flow',
  'c2_advanced_conditionals',
  'c2_discourse_markers',
  'c2_register_and_style',
  'c2_dense_noun_phrases',
  'c2_complex_subordination',
  'c2_advanced_concession',
  'c2_advanced_emphasis',
  'c2_stylistic_inversion',
  'c2_precision_modality',
  'c2_discourse_flow',
  'c2_advanced_conditional_alternatives',
};
