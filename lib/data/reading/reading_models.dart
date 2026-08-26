import 'package:flutter/material.dart';

/// Speakery Reading Module Models
///
/// Put this file here:
/// lib/data/reading/reading_models.dart
///
/// Expected companion files:
/// - reading_level_specs.dart
/// - reading_a1.dart
/// - reading_a2.dart
/// - reading_repository.dart

enum ReadingLevel {
  a1,
  a2,
  b1,
  b2,
  c1,
  c2,
}

extension ReadingLevelX on ReadingLevel {
  String get code {
    switch (this) {
      case ReadingLevel.a1:
        return 'A1';
      case ReadingLevel.a2:
        return 'A2';
      case ReadingLevel.b1:
        return 'B1';
      case ReadingLevel.b2:
        return 'B2';
      case ReadingLevel.c1:
        return 'C1';
      case ReadingLevel.c2:
        return 'C2';
    }
  }

  String get title {
    switch (this) {
      case ReadingLevel.a1:
        return 'Beginner Reading';
      case ReadingLevel.a2:
        return 'Elementary Reading';
      case ReadingLevel.b1:
        return 'Intermediate Reading';
      case ReadingLevel.b2:
        return 'Upper Intermediate Reading';
      case ReadingLevel.c1:
        return 'Advanced Reading';
      case ReadingLevel.c2:
        return 'Mastery Reading';
    }
  }

  /// Speakery-approved CEFR level colors.
  /// Keep these consistent across Grammar, Vocabulary, Reading, etc.
  Color get accent {
    switch (this) {
      case ReadingLevel.a1:
        return const Color(0xFF41E6A7); // mint / green
      case ReadingLevel.a2:
        return const Color(0xFF55D7FF); // cyan / light blue
      case ReadingLevel.b1:
        return const Color(0xFF5B8CFF); // blue
      case ReadingLevel.b2:
        return const Color(0xFF9C6BFF); // purple
      case ReadingLevel.c1:
        return const Color(0xFFFF5CC8); // pink / magenta
      case ReadingLevel.c2:
        return const Color(0xFFFFC857); // amber / gold
    }
  }

  IconData get icon {
    switch (this) {
      case ReadingLevel.a1:
        return Icons.menu_book_rounded;
      case ReadingLevel.a2:
        return Icons.auto_stories_rounded;
      case ReadingLevel.b1:
        return Icons.article_rounded;
      case ReadingLevel.b2:
        return Icons.library_books_rounded;
      case ReadingLevel.c1:
        return Icons.psychology_alt_rounded;
      case ReadingLevel.c2:
        return Icons.workspace_premium_rounded;
    }
  }
}

enum ReadingQuestionType {
  multipleChoice,
  trueFalse,
  trueFalseNotGiven,
  mainIdea,
  detail,
  inference,
  vocabularyInContext,
  matchingHeadings,
  sequence,
  gapFill,
}

enum ReadingSupportLevel {
  highTurkishSupport,
  moderateTurkishSupport,
  strategicTurkishTips,
  englishOnly,
  fullImmersion,
}

class ReadingLevelSpec {
  final ReadingLevel level;
  final int minWords;
  final int maxWords;
  final int minQuestions;
  final int maxQuestions;
  final String readingGoal;
  final String sentenceComplexity;
  final String vocabularyLoad;
  final ReadingSupportLevel supportLevel;
  final List<String> textTypes;
  final List<ReadingQuestionType> questionTypes;
  final List<String> sampleTopics;
  final List<String> turkishLearnerDifficulties;

  const ReadingLevelSpec({
    required this.level,
    required this.minWords,
    required this.maxWords,
    required this.minQuestions,
    required this.maxQuestions,
    required this.readingGoal,
    required this.sentenceComplexity,
    required this.vocabularyLoad,
    required this.supportLevel,
    required this.textTypes,
    required this.questionTypes,
    required this.sampleTopics,
    this.turkishLearnerDifficulties = const [],
  });
}

class ReadingCluster {
  final String id;
  final ReadingLevel level;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ReadingLesson> lessons;

  const ReadingCluster({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lessons,
  });
}

class ReadingLesson {
  final String id;
  final ReadingLevel level;
  final String clusterId;
  final String title;
  final String subtitle;
  final IconData icon;
  final int estimatedMinutes;
  final String textType;
  final String orientationEnglish;
  final String? orientationTurkish;
  final String? readingTipTurkish;
  final List<ReadingParagraph> paragraphs;
  final List<ReadingGloss> glosses;
  final List<ReadingQuestion> questions;
  final List<ReadingVocabularyReviewItem> vocabularyReview;
  final String? reflectionPrompt;
  final String? reflectionPromptTurkish;
  final bool isPremium;

  const ReadingLesson({
    required this.id,
    required this.level,
    required this.clusterId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.estimatedMinutes,
    required this.textType,
    required this.orientationEnglish,
    this.orientationTurkish,
    this.readingTipTurkish,
    required this.paragraphs,
    required this.glosses,
    required this.questions,
    this.vocabularyReview = const [],
    this.reflectionPrompt,
    this.reflectionPromptTurkish,
    this.isPremium = false,
  });

  String get fullText => paragraphs.map((p) => p.text).join('\n\n');

  int get wordCount {
    final words = fullText
        .replaceAll(RegExp(r'[^\w\s-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
    return words;
  }
}

class ReadingParagraph {
  final int number;
  final String text;

  const ReadingParagraph({
    required this.number,
    required this.text,
  });
}

class ReadingGloss {
  final String word;
  final String meaningEnglish;
  final String? meaningTurkish;
  final String example;

  const ReadingGloss({
    required this.word,
    required this.meaningEnglish,
    this.meaningTurkish,
    required this.example,
  });
}

class ReadingQuestion {
  final String id;
  final ReadingQuestionType type;
  final String question;
  final List<String> options;
  final String answer;
  final String explanationEnglish;
  final String? explanationTurkish;
  final int? evidenceParagraph;
  final String? evidenceText;
  final List<String> sequenceItems;

  const ReadingQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.answer,
    required this.explanationEnglish,
    this.options = const [],
    this.explanationTurkish,
    this.evidenceParagraph,
    this.evidenceText,
    this.sequenceItems = const [],
  });

  bool get isObjective {
    return options.isNotEmpty ||
        type == ReadingQuestionType.trueFalse ||
        type == ReadingQuestionType.trueFalseNotGiven;
  }

  bool get hasValidOptions {
    if (type == ReadingQuestionType.trueFalse) {
      return options.length == 2;
    }
    if (type == ReadingQuestionType.trueFalseNotGiven) {
      return options.length == 3;
    }
    return options.length >= 3;
  }
}

class ReadingVocabularyReviewItem {
  final String word;
  final String originalSentence;
  final String newExampleSentence;
  final String meaningEnglish;
  final String? meaningTurkish;

  const ReadingVocabularyReviewItem({
    required this.word,
    required this.originalSentence,
    required this.newExampleSentence,
    required this.meaningEnglish,
    this.meaningTurkish,
  });
}

class ReadingProgress {
  final String lessonId;
  final bool hasOpened;
  final bool hasFinishedReading;
  final bool isCompleted;
  final int latestScore;
  final int totalQuestions;
  final DateTime? lastAttemptAt;

  const ReadingProgress({
    required this.lessonId,
    this.hasOpened = false,
    this.hasFinishedReading = false,
    this.isCompleted = false,
    this.latestScore = 0,
    this.totalQuestions = 0,
    this.lastAttemptAt,
  });

  double get percentage {
    if (totalQuestions == 0) return 0;
    return latestScore / totalQuestions;
  }

  ReadingProgress copyWith({
    bool? hasOpened,
    bool? hasFinishedReading,
    bool? isCompleted,
    int? latestScore,
    int? totalQuestions,
    DateTime? lastAttemptAt,
  }) {
    return ReadingProgress(
      lessonId: lessonId,
      hasOpened: hasOpened ?? this.hasOpened,
      hasFinishedReading: hasFinishedReading ?? this.hasFinishedReading,
      isCompleted: isCompleted ?? this.isCompleted,
      latestScore: latestScore ?? this.latestScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }
}
