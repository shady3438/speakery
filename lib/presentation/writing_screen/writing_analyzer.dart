import 'dart:math' as math;

import 'package:flutter/material.dart';

enum WritingIssueSeverity { info, warning, fix }

class WritingPracticePrompt {
  final String title;
  final String instruction;
  final String target;
  final String tab;
  final IconData icon;
  final String level;
  final String focus;
  final int minWords;
  final int targetSentences;
  final List<String> checklist;
  final List<String> usefulPhrases;
  final List<String> requiredSignals;

  const WritingPracticePrompt({
    required this.title,
    required this.instruction,
    required this.target,
    required this.tab,
    required this.icon,
    required this.level,
    required this.focus,
    required this.minWords,
    required this.targetSentences,
    required this.checklist,
    required this.usefulPhrases,
    required this.requiredSignals,
  });
}

class WritingIssue {
  final WritingIssueSeverity severity;
  final String title;
  final String message;
  final String? example;

  const WritingIssue({
    required this.severity,
    required this.title,
    required this.message,
    this.example,
  });
}

class WritingMetric {
  final String label;
  final int score;
  final String value;

  const WritingMetric({
    required this.label,
    required this.score,
    required this.value,
  });
}

class WritingAnalysis {
  final String text;
  final int words;
  final int sentences;
  final int characters;
  final int score;
  final String cefrEstimate;
  final List<WritingMetric> metrics;
  final List<WritingIssue> issues;
  final List<String> strengths;
  final List<String> nextSteps;
  final String localCoachNote;
  final String suggestedRewrite;

  const WritingAnalysis({
    required this.text,
    required this.words,
    required this.sentences,
    required this.characters,
    required this.score,
    required this.cefrEstimate,
    required this.metrics,
    required this.issues,
    required this.strengths,
    required this.nextSteps,
    required this.localCoachNote,
    required this.suggestedRewrite,
  });

  bool get isReady => words >= 8 && sentences >= 1;
}

class WritingAnalyzer {
  const WritingAnalyzer._();

  static WritingAnalysis analyze(
    String rawText,
    WritingPracticePrompt prompt,
  ) {
    final text = rawText.trim();
    final words = _words(text);
    final sentences = _sentences(text);
    final issues = <WritingIssue>[];
    final strengths = <String>[];
    final nextSteps = <String>[];

    final wordScore =
        _scoreRatio(words.length, prompt.minWords, prompt.minWords + 20);
    final sentenceScore = _scoreRatio(
        sentences.length, prompt.targetSentences, prompt.targetSentences + 2);
    final mechanicsScore = _mechanicsScore(text, sentences, issues);
    final promptScore = _promptScore(text, prompt, issues);
    final grammarScore = _grammarScore(text, prompt, issues);
    final cohesionScore = _cohesionScore(text, prompt, strengths, issues);

    if (text.isEmpty) {
      issues.add(
        const WritingIssue(
          severity: WritingIssueSeverity.info,
          title: 'Start small',
          message: 'Write one clear sentence first. Then add details.',
          example: 'I wake up at seven. Then I have breakfast.',
        ),
      );
    }

    if (words.length >= prompt.minWords) {
      strengths.add('Good length for this task.');
    }
    if (sentences.length >= prompt.targetSentences) {
      strengths.add('You reached the target sentence count.');
    }
    if (_hasAny(text, ['first', 'then', 'after', 'because', 'but', 'and'])) {
      strengths.add('You used linking words to connect ideas.');
    }

    if (words.length < prompt.minWords) {
      nextSteps.add('Add ${prompt.minWords - words.length} more word(s).');
    }
    if (sentences.length < prompt.targetSentences) {
      nextSteps.add(
        'Add ${prompt.targetSentences - sentences.length} more sentence(s).',
      );
    }
    if (!_endsWithPunctuation(text) && text.isNotEmpty) {
      nextSteps.add('Finish the last sentence with . ? or !');
    }
    if (nextSteps.isEmpty) {
      nextSteps.add('Read it aloud once and fix any sentence that sounds odd.');
    }

    final score = _weighted([
      MapEntry(wordScore, 18),
      MapEntry(sentenceScore, 18),
      MapEntry(promptScore, 20),
      MapEntry(grammarScore, 20),
      MapEntry(mechanicsScore, 14),
      MapEntry(cohesionScore, 10),
    ]);

    final metrics = [
      WritingMetric(
          label: 'Task', score: promptScore, value: _label(promptScore)),
      WritingMetric(
          label: 'Grammar', score: grammarScore, value: _label(grammarScore)),
      WritingMetric(
          label: 'Clarity',
          score: mechanicsScore,
          value: _label(mechanicsScore)),
      WritingMetric(
          label: 'Flow', score: cohesionScore, value: _label(cohesionScore)),
    ];

    return WritingAnalysis(
      text: text,
      words: words.length,
      sentences: sentences.length,
      characters: text.length,
      score: score,
      cefrEstimate: _cefr(score, prompt.level),
      metrics: metrics,
      issues: issues.take(6).toList(growable: false),
      strengths:
          strengths.isEmpty ? ['You started the writing task.'] : strengths,
      nextSteps: nextSteps.take(4).toList(growable: false),
      localCoachNote:
          _coachNote(score, prompt, issues, words.length, sentences.length),
      suggestedRewrite: _suggestRewrite(text, prompt),
    );
  }

  static List<String> _words(String text) {
    if (text.trim().isEmpty) return const [];
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), ''))
        .where((w) => w.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _sentences(String text) {
    if (text.trim().isEmpty) return const [];
    final matches = RegExp(r'[^.!?]+[.!?]+|[^.!?]+$')
        .allMatches(text)
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
    return matches;
  }

  static int _mechanicsScore(
    String text,
    List<String> sentences,
    List<WritingIssue> issues,
  ) {
    if (text.trim().isEmpty) return 0;
    var score = 100;
    if (!_endsWithPunctuation(text)) {
      score -= 18;
      issues.add(
        const WritingIssue(
          severity: WritingIssueSeverity.fix,
          title: 'Missing final punctuation',
          message: 'Your last sentence should end with . ? or !',
        ),
      );
    }
    for (final sentence in sentences.take(6)) {
      final trimmed = sentence.trim();
      final first = trimmed.isEmpty ? '' : trimmed[0];
      if (first.isNotEmpty && first.toUpperCase() != first) {
        score -= 10;
        issues.add(
          WritingIssue(
            severity: WritingIssueSeverity.warning,
            title: 'Capital letter',
            message: 'Start sentences with a capital letter.',
            example: _capitalize(sentence),
          ),
        );
        break;
      }
    }
    if (RegExp(r'\s+[,.!?]').hasMatch(text)) {
      score -= 8;
      issues.add(
        const WritingIssue(
          severity: WritingIssueSeverity.warning,
          title: 'Space before punctuation',
          message: 'Remove spaces before commas and full stops.',
        ),
      );
    }
    if (RegExp(r'\b(\w+)\s+\1\b', caseSensitive: false).hasMatch(text)) {
      score -= 10;
      issues.add(
        const WritingIssue(
          severity: WritingIssueSeverity.warning,
          title: 'Repeated word',
          message: 'Check repeated words and remove one if it is accidental.',
        ),
      );
    }
    return score.clamp(0, 100);
  }

  static int _promptScore(
    String text,
    WritingPracticePrompt prompt,
    List<WritingIssue> issues,
  ) {
    if (text.isEmpty) return 0;
    final lower = text.toLowerCase();
    var matched = 0;
    for (final signal in prompt.requiredSignals) {
      if (lower.contains(signal.toLowerCase())) matched++;
    }
    final score = prompt.requiredSignals.isEmpty
        ? 88
        : ((matched / prompt.requiredSignals.length) * 100).round();
    if (score < 70) {
      issues.add(
        WritingIssue(
          severity: WritingIssueSeverity.warning,
          title: 'Task detail missing',
          message:
              'Add more task details: ${prompt.requiredSignals.join(', ')}.',
        ),
      );
    }
    return score.clamp(0, 100);
  }

  static int _grammarScore(
    String text,
    WritingPracticePrompt prompt,
    List<WritingIssue> issues,
  ) {
    if (text.isEmpty) return 0;
    var score = 92;
    final lower = text.toLowerCase();

    void addFix(String title, String message, String example) {
      score -= 14;
      issues.add(
        WritingIssue(
          severity: WritingIssueSeverity.fix,
          title: title,
          message: message,
          example: example,
        ),
      );
    }

    if (RegExp(r'\bi have \d+ years old\b').hasMatch(lower)) {
      addFix(
          'Age structure', 'Use “I am ... years old.”', 'I am 13 years old.');
    }
    if (RegExp(r'\bi am (student|teacher|doctor|engineer)\b').hasMatch(lower)) {
      addFix('Article before jobs', 'Use “a/an” before one job or role.',
          'I am a student.');
    }
    if (RegExp(r'\bi live at [a-z]').hasMatch(lower)) {
      addFix('City preposition', 'Use “in” with cities.', 'I live in Ankara.');
    }
    if (RegExp(r'\bgo school\b').hasMatch(lower)) {
      addFix('Go to school', 'Use “go to school”.', 'I go to school at eight.');
    }
    if (RegExp(r'\bmake homework\b').hasMatch(lower)) {
      addFix('Do homework', 'The natural phrase is “do homework”.',
          'I do my homework.');
    }
    if (RegExp(r'\bi fine\b').hasMatch(lower)) {
      addFix('Be verb', 'Use “am” after I.', 'I am fine.');
    }

    if (prompt.focus.toLowerCase().contains('past') &&
        !RegExp(r'\b(was|were|went|had|saw|played|visited|started|finished|watched|did)\b')
            .hasMatch(lower)) {
      score -= 12;
      issues.add(
        const WritingIssue(
          severity: WritingIssueSeverity.warning,
          title: 'Past Simple signal',
          message: 'This task needs Past Simple. Add one clear past verb.',
          example: 'Yesterday, I visited my friend.',
        ),
      );
    }

    return score.clamp(0, 100);
  }

  static int _cohesionScore(
    String text,
    WritingPracticePrompt prompt,
    List<String> strengths,
    List<WritingIssue> issues,
  ) {
    if (text.isEmpty) return 0;
    final lower = text.toLowerCase();
    final connectors = [
      'first',
      'then',
      'after',
      'after that',
      'because',
      'but',
      'and',
      'finally'
    ];
    final count = connectors.where((c) => lower.contains(c)).length;
    if (count == 0 && prompt.targetSentences >= 4) {
      issues.add(
        const WritingIssue(
          severity: WritingIssueSeverity.info,
          title: 'Add flow',
          message: 'Use one connector to make the paragraph smoother.',
          example: 'First, I wake up. Then, I have breakfast.',
        ),
      );
    }
    if (count >= 2) {
      strengths.add('Your ideas have a natural sequence.');
    }
    return math.min(100, 55 + count * 18);
  }

  static int _scoreRatio(int value, int target, int full) {
    if (target <= 0) return 100;
    if (value >= full) return 100;
    if (value >= target) {
      return 80 + ((value - target) / math.max(1, full - target) * 20).round();
    }
    return (value / target * 80).round().clamp(0, 100);
  }

  static int _weighted(List<MapEntry<int, int>> scores) {
    var total = 0;
    var weight = 0;
    for (final entry in scores) {
      total += entry.key * entry.value;
      weight += entry.value;
    }
    return (total / weight).round().clamp(0, 100);
  }

  static bool _endsWithPunctuation(String text) =>
      text.trim().isNotEmpty && RegExp(r'[.!?]$').hasMatch(text.trim());

  static bool _hasAny(String text, List<String> needles) {
    final lower = text.toLowerCase();
    return needles.any((needle) => lower.contains(needle));
  }

  static String _label(int score) {
    if (score >= 88) return 'Strong';
    if (score >= 72) return 'Good';
    if (score >= 55) return 'Building';
    return 'Needs work';
  }

  static String _cefr(int score, String baseLevel) {
    if (score >= 88) return '$baseLevel+';
    if (score >= 68) return baseLevel;
    return 'Practice';
  }

  static String _coachNote(
    int score,
    WritingPracticePrompt prompt,
    List<WritingIssue> issues,
    int words,
    int sentences,
  ) {
    if (words == 0) {
      return 'Write one simple sentence. I will check structure, task details and clarity.';
    }
    if (issues.any((i) => i.severity == WritingIssueSeverity.fix)) {
      return 'Fix the red grammar point first. One clean sentence is better than many messy ones.';
    }
    if (sentences < prompt.targetSentences) {
      return 'Good start. Add more detail and use one phrase from the phrase bank.';
    }
    if (score >= 85) {
      return 'This is ready. If you want, use optional AI polish for a more natural version.';
    }
    return 'Almost there. Improve flow with a connector and check final punctuation.';
  }

  static String _suggestRewrite(String text, WritingPracticePrompt prompt) {
    if (text.trim().isEmpty) {
      return prompt.usefulPhrases.take(2).join(' ');
    }
    var fixed = text.trim();
    fixed = fixed.replaceAllMapped(
      RegExp(r'\bi have (\d+) years old\b', caseSensitive: false),
      (match) => 'I am ${match.group(1)} years old',
    );
    fixed = fixed.replaceAll(
        RegExp(r'\bI am student\b', caseSensitive: false), 'I am a student');
    fixed = fixed.replaceAll(
        RegExp(r'\bgo school\b', caseSensitive: false), 'go to school');
    fixed = fixed.replaceAll(
        RegExp(r'\bmake homework\b', caseSensitive: false), 'do homework');
    fixed = fixed.replaceAll(RegExp(r'\s+([,.!?])'), r'$1');
    if (!_endsWithPunctuation(fixed)) fixed = '$fixed.';
    return fixed;
  }

  static String _capitalize(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return value;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}
