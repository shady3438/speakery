import 'package:flutter_test/flutter_test.dart';

import 'package:speakery/data/grammar/grammar_models.dart';
import 'package:speakery/data/grammar/grammar_generator.dart';
import 'package:speakery/data/grammar/grammar_repository.dart';
import 'package:speakery/presentation/grammar_skill_screen/grammar_quiz_normalizer.dart';

void main() {
  test('Speakery grammar quality audit - staged locked levels', () {
    final audit = GrammarQualityAudit();
    final report = audit.run();

    // Shows a compact report in the terminal even when the test passes.
    // Full details are printed only for problems.
    // ignore: avoid_print
    print(report.summary);

    if (report.warnings.isNotEmpty) {
      // ignore: avoid_print
      print('\nWARNINGS / SHOULD REVIEW: ${report.warnings.length}');
      for (final warning in report.warnings.take(80)) {
        // ignore: avoid_print
        print('�  $warning');
      }
      if (report.warnings.length > 80) {
        // ignore: avoid_print
        print('... ${report.warnings.length - 80} more warnings hidden');
      }
    }

    if (report.failures.isNotEmpty) {
      // ignore: avoid_print
      print('\nBROKEN / MUST FIX: ${report.failures.length}');
      for (final failure in report.failures) {
        // ignore: avoid_print
        print('L $failure');
      }
    }

    expect(report.failures, isEmpty, reason: report.failureText);
  });
}

class GrammarQualityAudit {
  // Add a level here only after its grammar_*.dart file is rebuilt and installed.
  // This keeps the audit useful while A2-B2-C2 are still under construction.
  static const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  GrammarAuditReport run() {
    final failures = <String>[];
    final warnings = <String>[];
    var topicCount = 0;
    var lessonCount = 0;
    var quizCount = 0;
    var contextScenarioCount = 0;

    for (final level in levels) {
      final topics = GrammarRepository.topicsForLevel(level);
      if (topics.isEmpty) {
        failures.add(
            '$level � no topics found in GrammarRepository.topicsForLevel');
        continue;
      }

      final ids = <String>{};
      for (final topic in topics) {
        topicCount++;
        final ref = '${topic.level} � ${topic.title} (${topic.id})';

        _require(
            topic.id.trim().isNotEmpty, '$ref � topic id is empty', failures);
        _require(ids.add(topic.id), '$ref � duplicate topic id: ${topic.id}',
            failures);
        _warn(topic.title.trim().isNotEmpty, '$ref � topic title is empty',
            warnings);
        _warn(topic.subtitle.trim().isNotEmpty,
            '$ref � topic subtitle is empty', warnings);
        _warn(_notMeta(topic.rule),
            '$ref � topic rule looks meta/generic: ${topic.rule}', warnings);
        _warn(
            _notMeta(topic.example),
            '$ref � topic example looks meta/generic: ${topic.example}',
            warnings);

        late GrammarLesson lesson;
        try {
          lesson = GrammarRepository.lessonForTopic(topic);
          lessonCount++;
        } catch (error) {
          failures.add('$ref � lessonForTopic throws: $error');
          continue;
        }

        final quiz = fillBlankQuizPackForLesson(lesson, true);
        _auditLesson(ref, topic, lesson, quiz, failures, warnings);
        quizCount += quiz.length;

        try {
          final logicPoints = generateGrammarLogicPoints(lesson);
          _auditLogicPoints(ref, logicPoints, failures, warnings);
        } catch (error) {
          failures.add('$ref � generateGrammarLogicPoints throws: $error');
        }

        for (final isEnglish in [true, false]) {
          try {
            final pack = generateGrammarContextPack(lesson, isEnglish);
            contextScenarioCount += pack.scenarios.length;
            _auditContext(ref, pack, isEnglish, failures, warnings);
          } catch (error) {
            failures.add(
                '$ref � generateGrammarContextPack(${isEnglish ? 'EN' : 'TR'}) throws: $error');
          }
        }
      }
    }

    return GrammarAuditReport(
      topicCount: topicCount,
      lessonCount: lessonCount,
      quizCount: quizCount,
      contextScenarioCount: contextScenarioCount,
      failures: failures,
      warnings: warnings,
    );
  }

  void _auditLesson(
    String ref,
    GrammarTopic topic,
    GrammarLesson lesson,
    List<GrammarQuizQuestion> quiz,
    List<String> failures,
    List<String> warnings,
  ) {
    _require(lesson.bigTitle.trim().isNotEmpty,
        '$ref � lesson.bigTitle is empty', failures);
    _require(lesson.oneLineGoal.trim().isNotEmpty,
        '$ref � lesson.oneLineGoal is empty', failures);
    _require(lesson.teacherIntro.trim().isNotEmpty,
        '$ref � lesson.teacherIntro is empty', failures);
    _warn(
        lesson.teacherIntro.length <= 520,
        '$ref � teacherIntro is too long for mobile (${lesson.teacherIntro.length} chars)',
        warnings);
    _warn(!_looksGeneric(lesson.teacherIntro),
        '$ref � teacherIntro looks generic: ${lesson.teacherIntro}', warnings);

    final isA1 = topic.level == 'A1' || topic.id.startsWith('a1_');
    if (isA1) {
      _auditA1LessonStrict(ref, topic, lesson, failures);
    }

    _require(lesson.formulaRows.length >= 3,
        '$ref � formulaRows should have at least 3 rows', failures);
    for (final row in lesson.formulaRows) {
      final rowRef = '$ref � formula row "${row.label}"';
      _require(
          row.label.trim().isNotEmpty, '$rowRef � label is empty', failures);
      _require(row.pattern.trim().isNotEmpty, '$rowRef � pattern is empty',
          failures);
      _require(
          row.sample.trim().isNotEmpty, '$rowRef � sample is empty', failures);
      _warn(!_looksBrokenGeneratedText(row.sample),
          '$rowRef � sample looks broken: ${row.sample}', warnings);
    }

    _require(lesson.examples.length >= 5,
        '$ref � examples should have at least 5 clean items', failures);
    for (final example in lesson.examples) {
      final clean = _clean(example);
      _require(clean.isNotEmpty, '$ref � empty example', failures);
      _warn(_notMeta(clean), '$ref � example looks meta/generic: $clean',
          warnings);
      _warn(!_looksBrokenGeneratedText(clean),
          '$ref � example looks broken: $clean', warnings);
      _warn(
          _isSentenceLike(clean),
          '$ref � example is not a full sentence; keep phrase/list examples in formula rows, not Examples tab: $clean',
          warnings);
    }

    _require(lesson.right.trim().isNotEmpty, '$ref � lesson.right is empty',
        failures);
    _require(lesson.wrong.trim().isNotEmpty, '$ref � lesson.wrong is empty',
        failures);
    _require(!_same(lesson.right, lesson.wrong),
        '$ref � wrong and right are the same: ${lesson.right}', failures);
    _warn(_isSentenceLike(lesson.right),
        '$ref � right is not a full sentence: ${lesson.right}', warnings);
    _warn(_isSentenceLike(lesson.wrong),
        '$ref � wrong is not a full sentence: ${lesson.wrong}', warnings);
    _warn(!_looksPatternOrList(lesson.right),
        '$ref � right looks like pattern/list: ${lesson.right}', warnings);
    _warn(!_looksPatternOrList(lesson.wrong),
        '$ref � wrong looks like pattern/list: ${lesson.wrong}', warnings);

    _require(quiz.length >= 5, '$ref � quiz should have at least 5 questions',
        failures);
    if (quiz.length < 8) {
      warnings.add(
          '$ref � quiz has ${quiz.length} questions; premium target is 8-10');
    }

    final quizIds = <String>{};
    for (final q in quiz) {
      _auditQuizQuestion(ref, q, quizIds, failures, warnings);
    }
  }

  void _auditQuizQuestion(
    String ref,
    GrammarQuizQuestion q,
    Set<String> quizIds,
    List<String> failures,
    List<String> warnings,
  ) {
    final qRef = '$ref � quiz ${q.id} (${q.type.name})';
    _require(q.id.trim().isNotEmpty, '$qRef � id is empty', failures);
    _require(quizIds.add(q.id), '$qRef � duplicate quiz id', failures);
    _require(q.prompt.trim().isNotEmpty, '$qRef � prompt is empty', failures);
    _require(q.answer.trim().isNotEmpty, '$qRef � answer is empty', failures);
    _warn(q.explanation.trim().isNotEmpty, '$qRef � explanation is empty',
        warnings);
    _warn(!_looksBrokenGeneratedText(q.prompt),
        '$qRef � prompt looks broken: ${q.prompt}', warnings);

    switch (q.type) {
      case GrammarQuizType.multipleChoice:
        _require(q.options.length >= 3,
            '$qRef � multipleChoice needs at least 3 options', failures);
        _require(q.options.map(_clean).contains(_clean(q.answer)),
            '$qRef � answer is not in options: ${q.answer}', failures);
        if (q.options.map(_clean).toSet().length != q.options.length) {
          failures.add('$qRef � duplicate options: ${q.options}');
        }
        for (final option in q.options) {
          _warn(!_looksBrokenGeneratedText(option),
              '$qRef � option looks broken: $option', warnings);
        }
        break;
      case GrammarQuizType.fillBlank:
        _require(q.prompt.contains('___') || (q.sentence ?? '').contains('___'),
            '$qRef � fillBlank needs ___ in prompt or sentence', failures);
        break;
      case GrammarQuizType.sentenceOrder:
        _require(q.items.length >= 3,
            '$qRef � sentenceOrder needs at least 3 items', failures);
        break;
      case GrammarQuizType.errorCorrection:
        _require(
            (q.sentence ?? '').trim().isNotEmpty || q.prompt.trim().isNotEmpty,
            '$qRef � errorCorrection needs a sentence/prompt',
            failures);
        break;
      case GrammarQuizType.transformation:
        _require(q.prompt.trim().isNotEmpty,
            '$qRef � transformation needs a prompt', failures);
        break;
      case GrammarQuizType.matching:
        _require(q.pairs.length >= 3, '$qRef � matching needs at least 3 pairs',
            failures);
        break;
    }
  }

  void _auditLogicPoints(
    String ref,
    List<GrammarLogicPoint> points,
    List<String> failures,
    List<String> warnings,
  ) {
    _require(points.isNotEmpty, '$ref � generator returned no logic points',
        failures);
    if (points.length < 3)
      warnings
          .add('$ref � generator returned only ${points.length} logic points');

    for (final point in points) {
      final pRef = '$ref � logic ${point.titleEn}';
      _require(
          point.model.trim().isNotEmpty, '$pRef � model is empty', failures);
      _require(
          point.avoid.trim().isNotEmpty, '$pRef � avoid is empty', failures);
      _require(!_same(point.model, point.avoid),
          '$pRef � model and avoid are the same: ${point.model}', failures);
      _warn(_isSentenceLike(point.model),
          '$pRef � model is not a full sentence: ${point.model}', warnings);
      _warn(_isSentenceLike(point.avoid),
          '$pRef � avoid is not a full sentence: ${point.avoid}', warnings);
      _warn(!_looksPatternOrList(point.model),
          '$pRef � model looks like pattern/list: ${point.model}', warnings);
      _warn(!_looksPatternOrList(point.avoid),
          '$pRef � avoid looks like pattern/list: ${point.avoid}', warnings);
      _warn(!_looksBrokenGeneratedText(point.avoid),
          '$pRef � avoid looks broken: ${point.avoid}', warnings);
      _warn(_notMeta(point.logicEn) && _notMeta(point.logicTr),
          '$pRef � logic looks generic/meta', warnings);
    }
  }

  void _auditContext(
    String ref,
    GrammarContextPack pack,
    bool isEnglish,
    List<String> failures,
    List<String> warnings,
  ) {
    final lang = isEnglish ? 'EN' : 'TR';
    _require(pack.title.trim().isNotEmpty,
        '$ref � context $lang title is empty', failures);
    _require(pack.scene.trim().isNotEmpty,
        '$ref � context $lang scene is empty', failures);
    _warn(
        pack.scene.length <= 130,
        '$ref � context $lang scene is too long (${pack.scene.length} chars)',
        warnings);
    _warn(!_looksTeacherishContext(pack.title),
        '$ref � context $lang title looks teacherish: ${pack.title}', warnings);
    _warn(!_looksTeacherishContext(pack.scene),
        '$ref � context $lang scene looks teacherish: ${pack.scene}', warnings);

    _require(pack.dialogueLines.length >= 2,
        '$ref � context $lang dialogue needs at least 2 lines', failures);
    for (final line in pack.dialogueLines) {
      final text = _clean(line.text);
      _require(text.isNotEmpty, '$ref � context $lang empty dialogue line',
          failures);
      _warn(!_looksTeacherishContext(text),
          '$ref � context $lang dialogue is teacherish/meta: $text', warnings);
      _warn(!_looksBrokenGeneratedText(text),
          '$ref � context $lang dialogue looks broken: $text', warnings);
    }

    _require(pack.scenarios.length >= 3,
        '$ref � context $lang needs at least 3 scenarios', failures);
    for (final scenario in pack.scenarios) {
      final sRef = '$ref � context $lang scenario "${scenario.title}"';
      _require(
          scenario.title.trim().isNotEmpty, '$sRef � title is empty', failures);
      _require(scenario.sentence.trim().isNotEmpty, '$sRef � sentence is empty',
          failures);
      _warn(!_looksTeacherishContext(scenario.title),
          '$sRef � title looks teacherish: ${scenario.title}', warnings);
      _warn(
          !_looksTeacherishContext(scenario.sentence),
          '$sRef � sentence looks teacherish/meta: ${scenario.sentence}',
          warnings);
      _warn(
          _isSentenceLike(scenario.sentence),
          '$sRef � sentence is not a full sentence: ${scenario.sentence}',
          warnings);
      _warn(
          !_looksPatternOrList(scenario.sentence),
          '$sRef � sentence looks like pattern/list: ${scenario.sentence}',
          warnings);
      _warn(!_looksBrokenGeneratedText(scenario.sentence),
          '$sRef � sentence looks broken: ${scenario.sentence}', warnings);
    }
  }

  static void _require(bool condition, String message, List<String> failures) {
    if (!condition) failures.add(message);
  }

  static void _warn(bool condition, String message, List<String> warnings) {
    if (!condition) warnings.add(message);
  }

  void _auditA1LessonStrict(
    String ref,
    GrammarTopic topic,
    GrammarLesson lesson,
    List<String> failures,
  ) {
    // Hard A1 content bans (must never appear in A1 UI).
    const bannedPhrases = [
      'konu oda?',
      'core form',
      'meaning focus',
      'grammar focus',
      'the sentence sounds natural',
      'the form changes the meaning',
      'i use this structure correctly',
    ];

    final allText = <String>[
      topic.title,
      topic.subtitle,
      topic.rule,
      topic.example,
      topic.trap,
      lesson.bigTitle,
      lesson.oneLineGoal,
      lesson.timeLabel,
      lesson.teacherIntro,
      ...lesson.formulaRows.expand((r) => [r.label, r.pattern, r.sample]),
      ...lesson.usageBullets,
      ...lesson.examples,
      lesson.wrong,
      lesson.right,
      lesson.reason,
      lesson.task,
      lesson.modelAnswer,
      ...lesson.quiz.expand((q) => [
            q.id,
            q.prompt,
            q.answer,
            q.explanation,
            q.sentence ?? '',
            ...q.options,
            ...q.items,
            ...q.pairs.entries.expand((e) => [e.key, e.value]),
          ]),
    ].where((v) => v.trim().isNotEmpty).toList(growable: false);

    for (final phrase in bannedPhrases) {
      if (allText.any((t) => _clean(t).toLowerCase().contains(phrase))) {
        failures.add('$ref � A1 banned phrase found: "$phrase"');
      }
    }

    if (lesson.quiz.length < 8) {
      failures.add(
          '$ref � A1 quiz must have at least 8 questions (has ${lesson.quiz.length})');
    }

    // Raw row labels may stay English because the UI localizes them.
    for (final row in lesson.formulaRows) {
      _require(row.label.trim().isNotEmpty,
          '$ref � A1 formula row label is empty', failures);
    }

    for (final q in lesson.quiz) {
      final qRef = '$ref � quiz ${q.id}';

      final prompt = q.prompt.trim();
      final promptLower = prompt.toLowerCase();
      if (promptLower == 'bo_lu?u doldur.' || promptLower == 'bo_lu?u doldur') {
        failures.add('$qRef � prompt is too vague: "${q.prompt}"');
      }
      if (promptLower.contains('ba?lam')) {
        failures.add('$qRef � prompt must not include "Ba?lam": "${q.prompt}"');
      }

      // Turkish UI must not contain English teacher-command prompts.
      if (_looksLikeEnglishTeacherCommand(prompt) && !_looksTurkish(q.prompt)) {
        failures
            .add('$qRef � A1 quiz prompt must be Turkish (got "${q.prompt}")');
      }

      // Guard against ?random slot word lists? (am / can / do / have &) on unrelated topics.
      if (q.type == GrammarQuizType.multipleChoice && q.options.isNotEmpty) {
        if (_looksLikeRandomAuxOptionSet(q.options) &&
            !_a1AllowsAuxOptionSet(topic.id)) {
          failures.add(
              '$qRef � options look like random auxiliaries for an unrelated topic: ${q.options}');
        }
      }
    }

    // Context packs are part of A1 UX: enforce non-generic, non-teacherish context.
    for (final isEnglish in [true, false]) {
      final pack = generateGrammarContextPack(lesson, isEnglish);
      final cxRef = '$ref � context ${isEnglish ? 'EN' : 'TR'}';

      if (_clean(pack.title).toLowerCase().contains('konu oda?')) {
        failures.add(
            '$cxRef � context title must not contain "Konu oda?": ${pack.title}');
      }

      // A1 context must be real-life usage, not a grammar lecture.
      _require(!_looksTeacherishContext(pack.title),
          '$cxRef � title looks teacherish: ${pack.title}', failures);
      _require(!_looksTeacherishContext(pack.scene),
          '$cxRef � scene looks teacherish: ${pack.scene}', failures);

      for (final scenario in pack.scenarios) {
        _require(
            !_looksTeacherishContext(scenario.title),
            '$cxRef � scenario title looks teacherish: ${scenario.title}',
            failures);
        _require(
            !_looksTeacherishContext(scenario.note),
            '$cxRef � scenario note looks teacherish: ${scenario.note}',
            failures);
      }
    }
  }
}

bool _looksLikeEnglishTeacherCommand(String value) {
  final lower = _clean(value).toLowerCase();
  return lower.startsWith('complete') ||
      lower.startsWith('choose') ||
      lower.startsWith('which') ||
      lower.startsWith('find') ||
      lower.startsWith('make it') ||
      lower.contains('choose the') ||
      lower.contains('complete:') ||
      lower.contains('choose the correct') ||
      lower.contains('select the') ||
      lower.contains('fill in');
}

bool _looksTurkish(String value) {
  final v = _clean(value);
  if (v.isEmpty) return false;
  if (RegExp(r'[�?1�_��?0�^�]').hasMatch(v)) return true;
  final lower = v.toLowerCase();
  return lower.contains('c�mle') ||
      lower.contains('do?ru') ||
      lower.contains('se�') ||
      lower.contains('tamamla') ||
      lower.contains('d�zelt') ||
      lower.contains('s?raya') ||
      lower.contains('soru') ||
      lower.contains('k1sa cevap');
}

bool _looksLikeRandomAuxOptionSet(List<String> options) {
  final clean = options
      .map((o) => _clean(o).toLowerCase())
      .where((o) => o.isNotEmpty)
      .toList(growable: false);
  if (clean.length < 3) return false;
  // Single-token or very short modal/aux lists with no sentence context.
  final allShort = clean.every((o) => o.split(RegExp(r'\s+')).length <= 2);
  if (!allShort) return false;

  const aux = {
    'am',
    'is',
    'are',
    'do',
    'does',
    'did',
    'have',
    'has',
    'can',
    "can't",
    'cannot',
    'will',
    "won't",
    'would',
    'should',
    "shouldn't",
    'must',
    "mustn't",
    'a',
    'an',
    'the',
    'some',
    'any',
    'much',
    'many',
    'this',
    'that',
    'these',
    'those',
  };

  final auxCount = clean.where((o) => aux.contains(o)).length;
  return auxCount >= (clean.length - 1);
}

bool _a1AllowsAuxOptionSet(String topicId) {
  // Topics where ?slot word? options are expected and not random.
  const allowed = {
    'a1_be_verb',
    'a1_there_is_are',
    'a1_can_cant',
    'a1_articles',
    'a1_some_any',
    'a1_countable_uncountable',
    'a1_how_much_many',
    'a1_demonstratives',
    'a1_subject_pronouns',
    'a1_object_pronouns',
    'a1_present_simple_positive',
    'a1_present_simple_negative',
    'a1_present_simple_questions',
    'a1_present_continuous',
    'a1_present_simple_vs_continuous',
    'a1_have_has_got',
  };
  return allowed.contains(topicId);
}

class GrammarAuditReport {
  final int topicCount;
  final int lessonCount;
  final int quizCount;
  final int contextScenarioCount;
  final List<String> failures;
  final List<String> warnings;

  const GrammarAuditReport({
    required this.topicCount,
    required this.lessonCount,
    required this.quizCount,
    required this.contextScenarioCount,
    required this.failures,
    required this.warnings,
  });

  String get summary =>
      '''\nSPEAKERY GRAMMAR QUALITY AUDIT\nTopics checked: $topicCount\nLessons checked: $lessonCount\nQuiz questions checked: $quizCount\nContext scenarios checked: $contextScenarioCount\nFailures: ${failures.length}\nWarnings: ${warnings.length}\n''';

  String get failureText {
    if (failures.isEmpty) return 'No blocking grammar quality failures found.';
    return failures.take(50).join('\n');
  }
}

String _clean(String value) => value.trim().replaceAll(RegExp(r'\s+'), ' ');

bool _same(String a, String b) =>
    _clean(a).toLowerCase() == _clean(b).toLowerCase();

bool _isSentenceLike(String value) {
  final text = _clean(value);
  if (text.length < 4) return false;
  if (_looksPatternOrList(text)) return false;
  final lower = text.toLowerCase();

  // Questions are valid examples even when they start with an auxiliary.
  if (text.endsWith('?') &&
      RegExp(r"^(am|is|are|was|were|do|does|did|have|has|had|can|could|will|would|should|must|may|might|where|what|when|who|why|how)\b")
          .hasMatch(lower)) {
    return true;
  }

  // Imperatives do not need an explicit subject: Open your book. / Don?t run.
  if (RegExp(
          r"^(please\s+)?(open|close|listen|look|call|turn|sit|stand|start|stop|write|read|repeat|choose|complete|match|correct|fill|ask|answer|wait|come|go|drink|eat|study|watch|touch|run|help|leave|join|reply|let\'s|do not|don't|don't)\b")
      .hasMatch(lower)) {
    return true;
  }

  // Pedagogical wrong imperatives are still useful audit items:
  // You open the door. / Not run. / Please listens carefully.
  if (RegExp(
          r"^(you\s+)?(open|close|listen|look|call|turn|sit|stand|start|stop|write|read|repeat|choose|complete|match|correct|fill|ask|answer|wait|come|go|drink|eat|study|watch|touch|run|help|leave|join|reply)\b")
      .hasMatch(lower)) {
    return true;
  }
  if (RegExp(
          r"^not\s+(run|touch|listen|open|go|come|sleep|worry|speak|write|read)\b")
      .hasMatch(lower)) {
    return true;
  }
  if (RegExp(r"^please\s+\w+s\b").hasMatch(lower)) {
    return true;
  }

  // C1/C2 ellipsis/substitution can be short but valid: I think so. / I hope so.
  if (RegExp(r"^i\s+(think|hope|suppose|guess)\s+(so|not|it)[.!?]?$")
      .hasMatch(lower)) {
    return true;
  }

  // Conditional sentences are valid even when they begin with if.
  if (RegExp(r"^if\b.*[,].*[.!?]$").hasMatch(lower)) {
    return true;
  }

  // C1/C2 formal sentences may use dense noun phrases or inversion, so avoid
  // false warnings when the item looks like a normal punctuated sentence.
  final wordCount =
      lower.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  if (wordCount >= 4 &&
      RegExp(r'[.!?]$').hasMatch(text) &&
      !_looksPatternOrList(text)) {
    return true;
  }

  final hasVerbSignal = RegExp(
    r"\b(am|is|are|was|were|be|been|being|do|does|did|have|has|had|can|cannot|can't|could|will|would|should|must|may|might|go|goes|went|goed|come|comes|came|study|studies|studied|studying|work|works|worked|working|like|likes|liked|want|wants|wanted|need|needs|needed|watch|watched|play|played|read|reading|write|wrote|written|make|makes|made|take|took|get|gets|got|see|saw|seen|buy|bought|eat|ate|eaten|drink|drank|drunk|live|lives|lived|speak|speaks|spoke|spoken|help|helps|helped|call|calls|called|meet|meets|met|finish|finishes|finished|wake|wakes|brush|brushes|rise|rises|start|starts|sleep|sleeps|travel|travels|drive|drives|know|knows|ask|asks|open|opens|listen|listens|run|runs|visit|visits|visited|clean|cleans|cleaned|join|joins|joined|agree|agrees|agreed|arrive|arrives|arrived|rain|rains|rained|snow|snows|boil|boils|press|presses|turn|turns|use|uses|used|argue|argues|shape|shapes|fly|flies|flying|heat|heats|send|sends|sent|try|tries|tried|enjoy|enjoys|enjoyed|enjoying|learn|learns|learned|learning|practice|practices|practiced|sound|sounds|change|changes|understand|understands|aren't|arent|isn't|isnt|eat|eats|ate|decide|decides|decided|stay|stays|stayed|hate|hates|hated|wait|waits|waiting|waited|complete|completes|completed|continue|continues|continued|succeed|succeeds|believe|believes|believed|arrange|arranges|arranged|repair|repairs|repaired|steal|steals|stolen|feel|feels|felt|left|catch|catches|caught|forget|forgets|forgot|forgotten|accept|accepts|accepted|compare|compares|compared|notice|notices|noticed|control|controls|controlled|keep|keeps|caught|understand|understands|understood|risk|risks|risked|lose|loses|losing|lost|manage|manages|managed|remember|remembers|remembered|lock|locks|locked|win|wins|won|give|gives|gave|ignore|ignores|ignored|surprise|surprises|surprised|listen|listens|listened|miss|misses|missed|require|requires|required|matter|matters|practise|practises|practised|become|becomes|became|offer|offers|offered|apologize|apologizes|apologized|graduate|graduates|graduated|train|trains|trained|live|lives|lived|hang|hangs|hung|stand|stands|stood|surprise|surprises|understand|understands|understood|concern|concerns|tell|tells|told|support|supports|supported|remain|remains|remained|convince|convinces|convinced|decide|decides|decided|depend|depends|select|selects|selected|receive|receives|received|expand|expands|expanded|reduce|reduces|reduced|expect|expects|expected|review|reviews|reviewed|prove|proves|proved|suggest|suggests|suggested|improve|improves|improved|clarify|clarifies|clarified|submit|submits|submitted|lecture|lectures|enjoy|enjoys|enjoyed|colleague|help|helped|appreciate|appreciates|appreciated|hope|hopes|hoped)\b",
  ).hasMatch(lower);
  final hasSubjectSignal = RegExp(
          r"\b(i|me|you|he|him|she|her|it|we|us|they|them|there|this|that|these|those|the|my|your|his|our|their|ali|ay_e|deniz|students|student|teacher|people|children|room|lesson|sun|phone|notebook|class|dog|city|answer|chairs|door|food|kayseri|antalya|ankara|istanbul|today|yesterday|ground|light|water|essay|technology|documents|time|aunt|weekend|lunch|lines|sentence|form|structure|message|grammar|emails|email|letter|words|word|manager|proposal|discussion|students|difference|speaker|course|plan|laptop|technician|woman|car|police|evidence|claim|train|documents|document|method|question|explanation|advice|meeting|door|home|noon|june|friday|result|deadline|service|information|idea|style|situation|contract|writer|book|prize|speech|warning|everyone|advice|patience|project|speed|accuracy|decision|future|training|month|year)\b")
      .hasMatch(lower);
  return hasVerbSignal && hasSubjectSignal;
}

bool _looksPatternOrList(String value) {
  final text = _clean(value);
  final lower = text.toLowerCase();
  if (text.contains('�') || text.contains('->')) return true;
  if (text.contains(' + ')) return true;
  if (text.contains(' / ')) return true;
  if (RegExp(r'^[a-z]+\s*/\s*[a-z]+', caseSensitive: false).hasMatch(text))
    return true;
  if (RegExp(
          r'\b(noun|verb|subject|object|adjective|adverb|v1|v2|v3|ing|clause|phrase)\b')
      .hasMatch(lower)) return true;

  // A comma can be a normal sentence comma: "Open the window, please."
  // Treat it as a list only when it does not look like a full sentence.
  if (text.contains(',') &&
      !RegExp(r'[.!?]$').hasMatch(text) &&
      !text
          .toLowerCase()
          .contains(RegExp(r'\b(and|but|because|so|when|while|if|please)\b'))) {
    return true;
  }

  final words = lower.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  if (words <= 4 && !RegExp(r'[.!?]$').hasMatch(text)) return true;
  return false;
}

bool _looksTeacherishContext(String value) {
  final lower = _clean(value).toLowerCase();
  const banned = [
    'look at this sentence',
    'notice the form',
    'say:',
    'avoid:',
    'wrong',
    'correct form',
    'rule',
    'pattern',
    'model',
    'common mistake',
    'dikkat',
    'kural',
    'kal1p',
    'ka�1n',
    'tuzak',
    'yanl?',
    'do?ru form',
  ];
  return banned.any(lower.contains);
}

bool _notMeta(String value) {
  final lower = _clean(value).toLowerCase();
  const bad = [
    'use this structure in short',
    'check the helper word',
    'choose the natural model sentence',
    'which option best fits the rule',
    'choose the best a2 example',
    'target structure',
    'grammar idea',
    'same grammar idea',
  ];
  return !bad.any(lower.contains);
}

bool _looksGeneric(String value) {
  final lower = _clean(value).toLowerCase();
  return lower.contains('use this structure in short') ||
      lower.contains('check the helper word') ||
      lower.contains('write five clear sentences using') ||
      lower.contains('target structure correctly');
}

bool _looksBrokenGeneratedText(String value) {
  final text = _clean(value);
  final lower = text.toLowerCase();
  if (text.contains('  ')) return true;
  if (RegExp(r'\b(a an|an a|is are|are is|to to|the the)\b').hasMatch(lower))
    return true;
  if (lower.contains('arranged.')) return true;
  if (lower.contains('phone was ringing me')) return true;
  if (lower.contains('did watch is wrong in positive sentences')) return true;
  return false;
}
