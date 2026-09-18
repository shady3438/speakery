import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_progress.dart';
import '../presentation/dictionary_screen/dictionary_screen.dart';
import '../presentation/grammar_skill_screen/grammar_skill_screen.dart';
import '../presentation/listening_screen/listening_practice_screen.dart';
import '../presentation/premium_screen/premium_screen.dart';
import '../presentation/reading_screen/reading_home_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/speaking_screen/speaking_screen.dart';
import '../presentation/vocabulary_screen/vocabulary_screen.dart';
import '../presentation/writing_screen/writing_practice_screen.dart';
import '../theme/speakery_theme_adapter.dart';
import '../theme/speakery_theme_tokens.dart';
import 'ios_liquid_glass.dart';

/// Shell tabs the drawer can switch to directly. The numbers are indices into
/// AppShell's IndexedStack, so they have to stay in step with it.
class AppDestination {
  static const int home = 0;
  static const int learn = 1;
  static const int social = 2;
  static const int chat = 3;
  static const int profile = 4;
}

/// The app's single index of places to go.
///
/// Everything used to hang off Home: five bottom tabs plus a nine-tile grid of
/// practice screens plus the route row. The grid is gone and the practice
/// screens live here instead, so Home can be a dashboard again and the bar can
/// stay down to the four destinations people open every day.
class AppDrawer extends StatelessWidget {
  /// Which shell tab is on screen, so the matching row can read as selected.
  final int currentIndex;

  /// Switch the shell to one of [AppDestination]'s tabs.
  final ValueChanged<int> onSelectTab;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  bool get _isEnglish => AppProgress.instance.isEnglish;
  String _t(String en, String tr) => _isEnglish ? en : tr;

  void _selectTab(BuildContext context, int index) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    onSelectTab(index);
  }

  /// Closes the drawer first, then pushes — otherwise the pushed route is built
  /// while the drawer is still animating out and the transition stutters.
  void _push(BuildContext context, Widget Function() builder) {
    HapticFeedback.selectionClick();
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(child: builder()),
      ),
    );
  }

  String get _level => AppProgress.instance.englishLevel;

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: width * .84 > 340 ? 340 : width * .84,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            // The panel is the one surface that genuinely slides over moving
            // content, so it earns a real backdrop blur where cards do not.
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: IosLiquidGlassSurface(
              radius: 30,
              strong: true,
              interactive: false,
              accent: tokens.primaryAccent,
              padding: EdgeInsets.zero,
              child: SafeArea(
                child: AnimatedBuilder(
                  animation: AppProgress.instance,
                  builder: (context, _) => Column(
                    children: [
                      _Header(tokens: tokens, isEnglish: _isEnglish),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                          physics: const BouncingScrollPhysics(),
                          children: _sections(context, tokens),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, SpeakeryThemeTokens tokens) {
    final accent = tokens.primaryAccent;
    final second = tokens.secondaryAccent;
    final warm = tokens.warmAccent;

    return [
      _SectionLabel(tokens: tokens, label: _t('Main', 'Ana')),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.home_rounded,
        label: _t('Home', 'Ana sayfa'),
        color: second,
        selected: currentIndex == AppDestination.home,
        onTap: () => _selectTab(context, AppDestination.home),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.route_rounded,
        label: _t('Learning path', 'Öğrenme rotası'),
        color: accent,
        selected: currentIndex == AppDestination.learn,
        onTap: () => _selectTab(context, AppDestination.learn),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.forum_rounded,
        label: _t('Voxa chat', 'Voxa sohbet'),
        color: warm,
        selected: currentIndex == AppDestination.chat,
        onTap: () => _selectTab(context, AppDestination.chat),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.people_rounded,
        label: _t('Community', 'Topluluk'),
        color: second,
        selected: currentIndex == AppDestination.social,
        onTap: () => _selectTab(context, AppDestination.social),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.person_rounded,
        label: _t('Profile', 'Profil'),
        color: accent,
        selected: currentIndex == AppDestination.profile,
        onTap: () => _selectTab(context, AppDestination.profile),
      ),

      _SectionLabel(tokens: tokens, label: _t('Practice', 'Pratik')),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.auto_fix_high_rounded,
        label: _t('Grammar', 'Gramer'),
        color: accent,
        onTap: () => _push(
          context,
          () => GrammarSkillScreen(
            initialLevel: _level,
            isEnglish: _isEnglish,
          ),
        ),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.menu_book_rounded,
        label: _t('Reading', 'Okuma'),
        color: second,
        onTap: () => _push(
          context,
          () => ReadingHomeScreen(
            initialLevel: _level,
            isEnglish: _isEnglish,
          ),
        ),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.headphones_rounded,
        label: _t('Listening', 'Dinleme'),
        color: warm,
        onTap: () => _push(context, () => const ListeningPracticeScreen()),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.record_voice_over_rounded,
        label: _t('Speaking', 'Konuşma'),
        color: second,
        onTap: () => _push(context, () => const SpeakingScreen()),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.edit_note_rounded,
        label: _t('Writing', 'Yazma'),
        color: accent,
        onTap: () => _push(context, () => const WritingPracticeScreen()),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.style_rounded,
        label: _t('Vocabulary', 'Kelime'),
        color: warm,
        onTap: () => _push(
          context,
          () => VocabularyScreen(
            initialLevel: _level,
            isEnglish: _isEnglish,
          ),
        ),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.travel_explore_rounded,
        label: _t('Dictionary', 'Sözlük'),
        color: second,
        onTap: () =>
            _push(context, () => DictionaryScreen(isEnglish: _isEnglish)),
      ),

      _SectionLabel(tokens: tokens, label: _t('Play', 'Oyun')),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.emoji_events_rounded,
        label: _t('Arena', 'Arena'),
        color: warm,
        trailing: AppProgress.instance.dailyChallengeDoneToday
            ? null
            : _t('New', 'Yeni'),
        onTap: () => _push(
          context,
          () => VocabularyChallengeScreen(
            initialLevel: _level,
            isEnglish: _isEnglish,
          ),
        ),
      ),

      _SectionLabel(tokens: tokens, label: _t('Account', 'Hesap')),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.workspace_premium_rounded,
        label: AppProgress.instance.isPremium
            ? _t('Premium', 'Premium')
            : _t('Go Premium', 'Premium\'a geç'),
        color: warm,
        onTap: () => _push(context, () => const PremiumScreen()),
      ),
      _DrawerItem(
        tokens: tokens,
        icon: Icons.settings_rounded,
        label: _t('Settings', 'Ayarlar'),
        color: accent,
        onTap: () => _push(context, () => const SettingsScreen()),
      ),
    ];
  }
}

/// Opens [AppDrawer]. Built to match [ThemeToggleButton] on the opposite
/// corner: same 42pt glass pill, same radius, same lift.
class AppMenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const AppMenuButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        width: 42,
        height: 42,
        child: IosLiquidGlassSurface(
          radius: 21,
          blur: 22,
          strong: true,
          accent: tokens.secondaryAccent,
          padding: const EdgeInsets.all(9),
          child: Icon(
            Icons.menu_rounded,
            color: tokens.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;

  const _Header({required this.tokens, required this.isEnglish});

  String _t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final progress = AppProgress.instance;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: tokens.brandGradient,
                  boxShadow: [
                    BoxShadow(
                      color: tokens.primaryAccent.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speakery',
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '${_t('Level', 'Seviye')} ${progress.level} · '
                      '${progress.englishLevel}',
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 6, color: tokens.border),
                FractionallySizedBox(
                  widthFactor: progress.levelProgress.clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(gradient: tokens.brandGradient),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              _HeaderStat(
                tokens: tokens,
                icon: Icons.local_fire_department_rounded,
                value: '${progress.streak}',
              ),
              const SizedBox(width: 12),
              _HeaderStat(
                tokens: tokens,
                icon: Icons.bolt_rounded,
                value: '${progress.xpInCurrentLevel}/100',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String value;

  const _HeaderStat({
    required this.tokens,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: tokens.readableAccent(tokens.warmAccent)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: tokens.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;

  const _SectionLabel({required this.tokens, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 7),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: tokens.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final String? trailing;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.selected = false,
    this.trailing,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final ink = tokens.readableAccent(widget.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      // Same two layers every button in the app is built from: the press
      // scale on the outside, the live glass pane on the inside. The pane is
      // what carries the hover lift, the cursor-tracked specular and the
      // blue/violet rim light that travels round the edge on engagement.
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? .975 : 1,
          duration: const Duration(milliseconds: 210),
          curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
          child: IosLiquidGlassSurface(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            accent: widget.color,
            borderColor: widget.selected
                ? widget.color.withAlpha(tokens.isLight ? 110 : 120)
                : null,
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: widget.color.withAlpha(tokens.isLight ? 30 : 34),
                  ),
                  child: Icon(widget.icon, size: 16, color: ink),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 13.5,
                      fontWeight:
                          widget.selected ? FontWeight.w900 : FontWeight.w700,
                      letterSpacing: -.15,
                    ),
                  ),
                ),
                if (widget.trailing != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: widget.color.withAlpha(tokens.isLight ? 34 : 44),
                    ),
                    child: Text(
                      widget.trailing!,
                      style: TextStyle(
                        color: ink,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else if (widget.selected)
                  Icon(Icons.circle, size: 7, color: ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
