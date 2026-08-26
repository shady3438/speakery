import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/app_shell.dart';
import 'presentation/login_screen/login_screen.dart';
import 'presentation/splash_screen/splash_screen.dart';
import 'presentation/onboarding_screen/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'theme/speakery_theme_adapter.dart';
import 'widgets/custom_error_widget.dart';
import 'data/grammar/grammar_audit_debug.dart';
import 'data/app_progress.dart';
import 'services/notification_service.dart';

void main() async {
  // Flutter'ın başlangıç ayarlarını yapar
  WidgetsFlutterBinding.ensureInitialized();

  // Grammar audit report is opt-in even in debug builds.
  assert(() {
    const runGrammarAudit = bool.fromEnvironment('SPEAKERY_GRAMMAR_AUDIT');
    if (runGrammarAudit) {
      // ignore: avoid_print
      print(debugFullGrammarAuditReport(verbose: false));
    }
    return true;
  }());

  // Firebase bağlantısını kurar
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hata ekranını senin özel widget'ınla değiştirir
  await NotificationService.instance.initialize();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(errorDetails: details);
  };

  // Apple "Liquid" görünümü için sistem çubuklarını şeffaf ve akışkan yapar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Uygulamayı sadece dikey modda tutar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppProgress _progress = AppProgress.instance;
  late SpeakeryThemeMode _themeMode;
  bool _themeAssetsReady = false;

  @override
  void initState() {
    super.initState();
    _themeMode = _progress.themeMode;
    _progress.addListener(_handleProgressChanged);
    _progress.loadProgress();
  }

  @override
  void dispose() {
    _progress.removeListener(_handleProgressChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_themeAssetsReady) return;
    _themeAssetsReady = true;
    for (final asset in const [
      'assets/images/voxa_light_wallpaper_v1.jpg',
      'assets/images/voxa_dark_wallpaper_v1.jpg',
    ]) {
      precacheImage(
        ResizeImage(
          AssetImage(asset),
          width: 1080,
          height: 1920,
        ),
        context,
      );
    }
  }

  void _handleProgressChanged() {
    if (!mounted || _themeMode == _progress.themeMode) return;
    setState(() => _themeMode = _progress.themeMode);
  }

  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home-screen';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speakery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeFor(_themeMode),
      themeAnimationDuration: Duration.zero,
      builder: (context, child) => SpeakeryThemeAdapter(
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: splashRoute,
      routes: {
        splashRoute: (context) => const SplashScreen(),
        onboardingRoute: (context) => OnboardingScreen(
              onFinish: () {
                Navigator.pushReplacementNamed(context, loginRoute);
              },
            ),
        loginRoute: (context) => const LoginScreen(),
        homeRoute: (context) => const AppShell(),
      },
    );
  }
}
