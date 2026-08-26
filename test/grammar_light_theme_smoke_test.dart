import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:speakery/presentation/grammar_skill_screen/grammar_skill_screen.dart';
import 'package:speakery/theme/app_theme.dart';
import 'package:speakery/theme/speakery_theme_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final themes = <String, ThemeData>{
    'white': AppTheme.whiteTheme,
    'dark': AppTheme.darkTheme,
    'voxa light': AppTheme.voxaLightTheme,
    'voxa dark': AppTheme.voxaDarkTheme,
  };

  for (final entry in themes.entries) {
    for (final isEnglish in <bool>[true, false]) {
      testWidgets(
        'grammar flow renders every tab in ${entry.key} theme '
        '(${isEnglish ? 'EN' : 'TR'})',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(390, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(
            MaterialApp(
              theme: entry.value,
              home: SpeakeryThemeAdapter(
                child: GrammarSkillScreen(isEnglish: isEnglish),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 700));
          expect(tester.takeException(), isNull);

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
          // Invoke the production card action directly; gesture hit testing is
          // covered elsewhere and is not the subject of this render smoke test.
          // ignore: avoid_dynamic_calls
          cardWidget.onTap();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 900));
          expect(find.byType(PageView), findsWidgets);
          expect(tester.takeException(), isNull);

          for (var page = 1; page < 5; page++) {
            await tester.drag(
              find.byType(PageView).first,
              const Offset(-340, 0),
            );
            await tester.pump(const Duration(milliseconds: 650));
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.key} theme failed on grammar tab ${page + 1}.',
            );
          }
        },
      );
    }
  }
}
