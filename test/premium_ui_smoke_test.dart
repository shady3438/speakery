import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:speakery/data/app_progress.dart';
import 'package:speakery/presentation/home_screen/home_screen.dart';
import 'package:speakery/presentation/listening_screen/listening_practice_screen.dart';
import 'package:speakery/presentation/settings_screen/settings_screen.dart';
import 'package:speakery/presentation/writing_screen/writing_practice_screen.dart';
import 'package:speakery/theme/app_theme.dart';
import 'package:speakery/theme/speakery_theme_adapter.dart';
import 'package:speakery/widgets/app_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final whiteTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.light,
    ),
  );
  final voxaTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFFAF4),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF7A12),
      secondary: Color(0xFF8A4A20),
      surface: Color(0xFFFFFDFC),
      onSurface: Color(0xFF3B2116),
    ),
  );
  final voxaDarkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF030617),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF9B6CFF),
      secondary: Color(0xFF2BB7D6),
      tertiary: Color(0xFFC34CE8),
      surface: Color(0xFF0B0A24),
      onSurface: Color(0xFFFFF8F1),
    ),
  );

  test('legacy Voxa theme migrates to Voxa Light', () {
    expect(
      SpeakeryThemeMode.fromStorageKey('voxa'),
      SpeakeryThemeMode.voxaLight,
    );
  });

  testWidgets('liquid tab bar fits and changes tabs on a narrow screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: whiteTheme,
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: AppNavigationBar(
                currentIndex: selected,
                onTabChanged: (value) => setState(() => selected = value),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    final pill = find.byKey(
      const ValueKey<String>('app-nav-active-pill'),
    );
    final startX = tester.getTopLeft(pill).dx;
    await tester.tap(find.text('Chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final movingX = tester.getTopLeft(pill).dx;
    expect(movingX, greaterThan(startX));
    expect(movingX, lessThan(startX + 180));
    await tester.pump(const Duration(milliseconds: 400));
    expect(selected, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings language control uses the premium liquid pill',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppProgress.instance.isEnglish = true;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      AppProgress.instance.isEnglish = true;
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: whiteTheme,
        home: const SettingsScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const ValueKey<String>('settings-language-toggle')),
      findsOneWidget,
    );
    await tester.tap(find.text('Türkçe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 360));

    expect(AppProgress.instance.isEnglish, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final entry in <MapEntry<String, ThemeData>>[
    MapEntry('white', whiteTheme),
    MapEntry('voxa light', voxaTheme),
    MapEntry('voxa dark', voxaDarkTheme),
  ]) {
    testWidgets('premium listening and writing render in ${entry.key} theme',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _TestApp(
          theme: entry.value,
          child: const ListeningPracticeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Listening Lab'), findsOneWidget);
      expect(find.text('A1'), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _TestApp(
          theme: entry.value,
          child: const WritingPracticeScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Writing Practice'), findsOneWidget);
      expect(find.text('Writing coach'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Voxa tab bar uses the normal liquid nav without mascot chrome',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(280, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: voxaTheme,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: AppNavigationBar(
              currentIndex: selected,
              onTabChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.byKey(const ValueKey<String>('voxa-tab-fixed-mascot')),
      findsNothing,
    );

    await tester.drag(
      find.byType(AppNavigationBar),
      const Offset(-120, 0),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(selected, 1);

    await tester.tap(find.text('Social'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(selected, 2);
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(selected, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Voxa Light keeps both wallpaper layers visible', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestApp(
        theme: AppTheme.voxaLightTheme,
        child: const Scaffold(body: SizedBox.expand()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const ValueKey<String>('voxa-wallpaper-base')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('voxa-wallpaper-overlay')),
      findsOneWidget,
    );
    expect(
        Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor,
        Colors.transparent);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home quick actions open the listening lab', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestApp(
        theme: whiteTheme,
        child: const HomeScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    final initialHomeException = tester.takeException();
    expect(initialHomeException, isNull);
    await tester.scrollUntilVisible(
      find.text('Listening Lab'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Listening Lab'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Your 4-step session'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home renders its linked route and actions in Voxa theme',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestApp(
        theme: voxaTheme,
        child: const HomeScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byKey(const ValueKey('home-profile-link')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-route-grammar')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-route-listening')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-route-voxa')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('voxa-care-mission')),
      findsNothing,
    );
    expect(find.textContaining('Voxa'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-action-vocabulary')),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('home-action-speaking')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('home-action-vocabulary')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('listening follows the Turkish app language setting',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final previousLanguage = AppProgress.instance.isEnglish;
    AppProgress.instance.setEnglishUi(false);
    addTearDown(() => AppProgress.instance.setEnglishUi(previousLanguage));

    await tester.pumpWidget(
      _TestApp(
        theme: whiteTheme,
        child: const ListeningPracticeScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Dinleme Laboratuvarı'), findsOneWidget);
    expect(find.text('4 adımlı çalışman'), findsOneWidget);
    expect(find.textContaining('Voxa Koç'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('listening level filter and three training modes work',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _TestApp(
        theme: whiteTheme,
        child: const ListeningPracticeScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('C2').first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Policy under uncertainty'), findsOneWidget);

    for (var attempt = 0;
        attempt < 6 &&
            find
                .byKey(const ValueKey('c2_public_policy-focus-option-0'))
                .evaluate()
                .isEmpty;
        attempt++) {
      await tester.drag(
        find.byType(Scrollable).first,
        const Offset(0, -260),
      );
      await tester.pump(const Duration(milliseconds: 180));
    }
    final focusOption = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('c2_public_policy-focus-option-0')),
    );
    focusOption.onTap!();
    final dynamic focusCheck = tester.widget(
      find.byKey(const ValueKey('c2_public_policy-focus-check')),
    );
    focusCheck.onTap();
    await tester.pump(const Duration(milliseconds: 250));

    final dictationMode = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('listening-mode-1')),
    );
    dictationMode.onTap!();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.enterText(
      find.byKey(const ValueKey('listening-dictation-field')),
      'In practice it privileges the status quo.',
    );
    final dynamic dictationCheck = tester.widget(
      find.byKey(const ValueKey('listening-dictation-check')),
    );
    dictationCheck.onTap();
    await tester.pump(const Duration(milliseconds: 250));

    final shadowMode = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('listening-mode-2')),
    );
    shadowMode.onTap!();
    await tester.pump(const Duration(milliseconds: 250));
    final dynamic shadowStart = tester.widget(
      find.byKey(const ValueKey('listening-shadow-button')),
    );
    shadowStart.onTap();
    await tester.pump(const Duration(seconds: 4));
    final dynamic shadowStop = tester.widget(
      find.byKey(const ValueKey('listening-shadow-button')),
    );
    shadowStop.onTap();
    await tester.pump(const Duration(milliseconds: 250));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('listening-complete-mission')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    final completeButton = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('listening-complete-mission')),
    );
    completeButton.onTap!();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Mission complete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestApp extends StatelessWidget {
  final ThemeData theme;
  final Widget child;

  const _TestApp({
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: SpeakeryThemeAdapter(child: child),
    );
  }
}
