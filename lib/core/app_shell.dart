import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../presentation/home_screen/home_screen.dart' as home_screen;
import '../presentation/learn_overview_screen/learn_overview_screen.dart';
import '../presentation/social_screen/social_screen.dart';
import '../presentation/chat_screen/chat_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../theme/speakery_theme_adapter.dart';
import '../theme/speakery_theme_tokens.dart';
import '../widgets/app_navigation.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _isNavCompact = false;

  late final List<Widget> _screens = [
    home_screen.HomeScreen(
      userName: 'Learner',
      onNavigate: _navigateFromHome,
    ),
    const LearnOverviewScreen(),
    const SocialScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  void _navigateFromHome(int index) {
    if (index < 0 || index >= _screens.length) return;
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 1.5 && !_isNavCompact) {
        setState(() => _isNavCompact = true);
      } else if (delta < -1.5 && _isNavCompact) {
        setState(() => _isNavCompact = false);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final overlayStyle = tokens.isLight
        ? SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: IndexedStack(
                  sizing: StackFit.expand,
                  index: _currentIndex,
                  children: _screens.asMap().entries.map((entry) {
                    return TickerMode(
                      enabled: entry.key == _currentIndex,
                      child: SizedBox.expand(
                        child: SpeakeryThemeAdapter(
                          child: entry.value,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppNavigationBar(
                currentIndex: _currentIndex,
                onTabChanged: _navigateFromHome,
                compact: _isNavCompact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
