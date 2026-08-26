import 'package:flutter/material.dart';

enum GrammarQuizType {
  multipleChoice,
  fillBlank,
  sentenceOrder,
  errorCorrection,
  transformation,
  matching,
}

class GrammarTopic {
  final String id;
  final String level;
  final String title;
  final String subtitle;
  final IconData icon;
  final String rule;
  final String example;
  final String trap;

  const GrammarTopic({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.rule,
    required this.example,
    required this.trap,
  });
}

class GrammarLesson {
  final String bigTitle;
  final String oneLineGoal;
  final String timeLabel;
  final String teacherIntro;
  final List<GrammarFormulaRow> formulaRows;
  final List<String> usageBullets;
  final List<String> examples;
  final String wrong;
  final String right;
  final String reason;
  final String task;
  final String modelAnswer;
  final List<GrammarQuizQuestion> quiz;

  const GrammarLesson({
    required this.bigTitle,
    required this.oneLineGoal,
    required this.timeLabel,
    required this.teacherIntro,
    required this.formulaRows,
    required this.usageBullets,
    required this.examples,
    required this.wrong,
    required this.right,
    required this.reason,
    required this.task,
    required this.modelAnswer,
    this.quiz = const [],
  });
}

class GrammarFormulaRow {
  final String label;
  final String pattern;
  final String sample;

  const GrammarFormulaRow({
    required this.label,
    required this.pattern,
    required this.sample,
  });
}

class GrammarQuizQuestion {
  final String id;
  final GrammarQuizType type;
  final String prompt;
  final List<String> options;
  final String answer;
  final String explanation;
  final String? sentence;
  final List<String> items;
  final Map<String, String> pairs;

  const GrammarQuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.options = const [],
    this.sentence,
    this.items = const [],
    this.pairs = const {},
  });
}
