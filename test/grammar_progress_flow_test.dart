import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speakery/data/app_progress.dart';
import 'package:speakery/presentation/grammar_skill_screen/grammar_skill_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('finishing a grammar quiz records progress and awards XP once',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final progress = AppProgress.instance;
    progress.completedLessons.clear();
    progress.xp = 0;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C3AED),
            brightness: Brightness.light,
          ),
        ),
        home: const GrammarSkillScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    final firstLesson = find.byKey(
      const ValueKey<String>('grammar-topic-a1_be_verb'),
    );
    final topicCard = find.descendant(
      of: firstLesson,
      matching: find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_TopicCard',
      ),
    );
    final dynamic cardWidget = tester.widget(topicCard);
    // ignore: avoid_dynamic_calls
    cardWidget.onTap();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    final player = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_GrammarLessonPlayerScreen',
    );
    final dynamic playerState = tester.state(player);
    // Use the production tab transition directly so the quiz is fully settled.
    // ignore: avoid_dynamic_calls
    playerState.goToPage(4);
    // The screen has continuous glass animations, so jump the controller
    // instead of waiting for the whole widget tree to settle.
    // ignore: avoid_dynamic_calls
    playerState.pageController.jumpToPage(4);
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.byKey(const ValueKey<String>('grammar-quiz-option-0')),
      findsOneWidget,
    );

    var reachedResults = false;
    for (var question = 0; question < 12; question++) {
      final option =
          find.byKey(const ValueKey<String>('grammar-quiz-option-0'));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump();

      final check = find.byKey(const ValueKey<String>('grammar-quiz-check'));
      await tester.ensureVisible(check);
      await tester.tap(check);
      await tester.pump();

      final results =
          find.byKey(const ValueKey<String>('grammar-quiz-results'));
      if (results.evaluate().isNotEmpty) {
        await tester.tap(results);
        await tester.pump(const Duration(milliseconds: 500));
        reachedResults = true;
        break;
      }

      final next = find.byKey(const ValueKey<String>('grammar-quiz-next'));
      await tester.tap(next);
      await tester.pump(const Duration(milliseconds: 220));
    }

    expect(reachedResults, isTrue);
    expect(
      find.byKey(const ValueKey<String>('grammar-lesson-complete')),
      findsOneWidget,
    );

    const progressId = 'grammar_a1_a1_be_verb';
    expect(progress.isLessonCompleted(progressId), isTrue);
    expect(progress.xp, 15);

    progress.completeLesson(progressId, rewardXP: 15);
    expect(progress.xp, 15);

    Navigator.of(tester.element(player)).pop();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Completed'), findsOneWidget);
  });
}
