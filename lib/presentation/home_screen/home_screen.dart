import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../grammar_skill_screen/grammar_skill_screen.dart';
import '../listening_screen/listening_practice_screen.dart';
import '../reading_screen/reading_home_screen.dart';
import '../speaking_screen/speaking_screen.dart';
import '../vocabulary_screen/vocabulary_screen.dart';
import '../writing_screen/writing_practice_screen.dart';

const Color _blue = Color(0xFF3B82F6);
const Color _purple = Color(0xFF8B5CF6);
const Color _pink = Color(0xFFEC4899);
const Color _green = Color(0xFF10B981);
const Color _orange = Color(0xFFFF8A3D);

class HomeScreen extends StatefulWidget {
  final String userName;
  final ValueChanged<int>? onNavigate;

  const HomeScreen({
    super.key,
    this.userName = 'Learner',
    this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool get _isEnglish => AppProgress.instance.isEnglish;
  String t(String english, String turkish) => _isEnglish ? english : turkish;

  Color _tone(
    SpeakeryThemeTokens tokens,
    Color fallback, [
    int slot = 0,
  ]) {
    if (!tokens.isVoxaTheme) return fallback;
    return switch (slot % 4) {
      1 => tokens.secondaryAccent,
      2 => const Color(0xFFB85C24),
      3 => const Color(0xFF6F351F),
      _ => tokens.primaryAccent,
    };
  }

  String get _firstLetter {
    final name = widget.userName.trim();
    return name.isEmpty ? 'S' : name.substring(0, 1).toUpperCase();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return t('Good morning', 'Günaydın');
    if (hour < 18) return t('Good afternoon', 'İyi günler');
    return t('Good evening', 'İyi akşamlar');
  }

  void _go(int index) => widget.onNavigate?.call(index);

  void _openWriting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpeakeryThemeAdapter(
          child: WritingPracticeScreen(),
        ),
      ),
    );
  }

  void _openGrammar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: GrammarSkillScreen(
            initialLevel: AppProgress.instance.englishLevel,
            isEnglish: _isEnglish,
          ),
        ),
      ),
    );
  }

  void _openReading() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: ReadingHomeScreen(
            initialLevel: AppProgress.instance.englishLevel,
            isEnglish: _isEnglish,
          ),
        ),
      ),
    );
  }

  void _openListening() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpeakeryThemeAdapter(
          child: ListeningPracticeScreen(),
        ),
      ),
    );
  }

  void _openVocabulary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: VocabularyScreen(
            initialLevel: AppProgress.instance.englishLevel,
            isEnglish: _isEnglish,
          ),
        ),
      ),
    );
  }

  void _openArena() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: VocabularyChallengeScreen(
            initialLevel: AppProgress.instance.englishLevel,
            isEnglish: _isEnglish,
          ),
        ),
      ),
    );
  }

  void _openSpeaking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpeakeryThemeAdapter(child: SpeakingScreen()),
      ),
    );
  }

  void _openRecommended(AppProgress progress) {
    switch (progress.completedCount % 3) {
      case 1:
        _openListening();
        return;
      case 2:
        _openReading();
        return;
      default:
        _openGrammar();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: IosDynamicGlassBackdrop(
        primary: tokens.secondaryAccent,
        secondary: tokens.primaryAccent,
        child: Stack(
          children: [
            _Glow(
              alignment: const Alignment(-1.25, -1.05),
              color: tokens.secondaryAccent,
              size: 260,
            ),
            _Glow(
              alignment: const Alignment(1.2, -.2),
              color: tokens.isLight ? _pink : tokens.primaryAccent,
              size: 230,
            ),
            if (!tokens.isLight)
              _Glow(
                alignment: const Alignment(.95, 1.05),
                color: tokens.foxAccent,
                size: 210,
              ),
            SafeArea(
              child: AnimatedBuilder(
                animation: AppProgress.instance,
                builder: (context, _) {
                  final progress = AppProgress.instance;
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 122),
                    children: [
                      _hero(tokens),
                      const SizedBox(height: 14),
                      _continueLearning(tokens, progress),
                      const SizedBox(height: 14),
                      _todayProgress(tokens, progress),
                      const SizedBox(height: 18),
                      _ArenaSpotlight(
                        tokens: tokens,
                        isEnglish: _isEnglish,
                        streak: progress.dailyChallengeStreak,
                        doneToday: progress.dailyChallengeDoneToday,
                        onTap: _openArena,
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle(
                        tokens,
                        t('Today\'s route', 'Bugünün rotası'),
                      ),
                      const SizedBox(height: 10),
                      _dailyRoute(tokens),
                      const SizedBox(height: 18),
                      _sectionTitle(
                        tokens,
                        t('Quick actions', 'Hızlı işlemler'),
                      ),
                      const SizedBox(height: 10),
                      _quickActions(tokens),
                      const SizedBox(height: 14),
                      _socialPreview(tokens),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(SpeakeryThemeTokens tokens) {
    return _GlassCard(
      tokens: tokens,
      accent: tokens.secondaryAccent,
      padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
      child: Row(
        children: [
          GestureDetector(
            key: const ValueKey('home-profile-link'),
            onTap: () => _go(4),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: tokens.brandGradient,
                border: Border.all(color: Colors.white.withAlpha(105)),
                boxShadow: [
                  BoxShadow(
                    color: tokens.primaryAccent
                        .withAlpha(tokens.isLight ? 34 : 72),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                _firstLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, ${widget.userName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t(
                    'Small, focused practice. Real progress.',
                    'Kısa ve odaklı çalışma. Gerçek ilerleme.',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _SoftPill(
            tokens: tokens,
            icon: Icons.forum_rounded,
            label: t('Coach', 'Koc'),
            color: tokens.secondaryAccent,
            onTap: () => _go(3),
          ),
        ],
      ),
    );
  }

  Widget _continueLearning(
    SpeakeryThemeTokens tokens,
    AppProgress progress,
  ) {
    final level = progress.englishLevel.isEmpty ? 'A1' : progress.englishLevel;
    final value = progress.levelProgress.clamp(0.08, 1.0);
    final recommendation = progress.completedCount % 3;
    final title = switch (recommendation) {
      1 => t('Listening mission', 'Dinleme görevi'),
      2 => t('Read at your level', 'Seviyende oku'),
      _ => t('Grammar focus', 'Gramer odağı'),
    };
    final subtitle = switch (recommendation) {
      1 => t('$level · Listen, write, speak', '$level · Dinle, yaz, konuş'),
      2 => t('$level · Reading library', '$level · Okuma kütüphanesi'),
      _ => t('$level · Continue your pathway', '$level · Rotana devam et'),
    };
    final icon = switch (recommendation) {
      1 => Icons.headphones_rounded,
      2 => Icons.menu_book_rounded,
      _ => Icons.auto_fix_high_rounded,
    };
    final color = switch (recommendation) {
      1 => _tone(tokens, _orange),
      2 => _tone(tokens, _blue, 1),
      _ => _tone(tokens, AppTheme.cefrLevelColor(level), 2),
    };

    return _GlassCard(
      tokens: tokens,
      accent: tokens.primaryAccent,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconTile(tokens: tokens, icon: icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('Continue learning', 'Öğrenmeye devam et'),
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _SoftPill(
                tokens: tokens,
                icon: Icons.bolt_rounded,
                label: '${(value * 100).round()}%',
                color: tokens.primaryAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: value,
              backgroundColor: tokens.inputSurface,
              color: tokens.primaryAccent,
            ),
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            tokens: tokens,
            label: t('Continue $title', '$title ile devam et'),
            icon: Icons.arrow_forward_rounded,
            onTap: () => _openRecommended(progress),
          ),
        ],
      ),
    );
  }

  Widget _todayProgress(SpeakeryThemeTokens tokens, AppProgress progress) {
    if (tokens.isVoxaTheme) {
      return Row(
        children: [
          _ProgressTile(
            tokens: tokens,
            icon: Icons.restaurant_rounded,
            label: t('Fullness', 'Tokluk'),
            value: progress.studiedToday ? t('Full', 'Tok') : t('Hungry', 'Aç'),
            color: tokens.primaryAccent,
          ),
          const SizedBox(width: 10),
          _ProgressTile(
            tokens: tokens,
            icon: Icons.favorite_rounded,
            label: t('Friendship', 'Arkadaşlık'),
            value: t('${progress.streak} days', '${progress.streak} gün'),
            color: tokens.secondaryAccent,
          ),
          const SizedBox(width: 10),
          _ProgressTile(
            tokens: tokens,
            icon: Icons.bolt_rounded,
            label: t('Energy', 'Enerji'),
            value: '${progress.xp}',
            color: tokens.warmAccent,
          ),
        ],
      );
    }

    return Row(
      children: [
        _ProgressTile(
          tokens: tokens,
          icon: Icons.local_fire_department_rounded,
          label: t('Streak', 'Seri'),
          value: t('${progress.streak} days', '${progress.streak} gün'),
          color: _orange,
        ),
        const SizedBox(width: 10),
        _ProgressTile(
          tokens: tokens,
          icon: Icons.bolt_rounded,
          label: t('Today XP', 'Bugünkü XP'),
          value: progress.studiedToday ? '+${progress.xp.clamp(10, 90)}' : '+0',
          color: _purple,
        ),
        const SizedBox(width: 10),
        _ProgressTile(
          tokens: tokens,
          icon: Icons.flag_rounded,
          label: t('Daily goal', 'Günlük hedef'),
          value: progress.studiedToday ? t('Done', 'Tamam') : '10 dk',
          color: _green,
        ),
      ],
    );
  }

  Widget _quickActions(SpeakeryThemeTokens tokens) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 760 ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - ((columnCount - 1) * 10)) / columnCount;

        return GridView.count(
          crossAxisCount: columnCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: itemWidth / 96,
          children: [
            _ActionCard(
              key: const ValueKey('home-action-grammar'),
              tokens: tokens,
              icon: Icons.auto_fix_high_rounded,
              title: t('Practice Grammar', 'Gramer çalış'),
              subtitle: t('A1-C2 lessons', 'A1-C2 dersleri'),
              color: _tone(tokens, _purple),
              onTap: _openGrammar,
            ),
            _ActionCard(
              key: const ValueKey('home-action-listening'),
              tokens: tokens,
              icon: Icons.headphones_rounded,
              title: t('Listening Lab', 'Dinleme Laboratuvarı'),
              subtitle: t('Guided missions', 'Rehberli görevler'),
              color: _tone(tokens, _orange, 2),
              onTap: _openListening,
            ),
            _ActionCard(
              key: const ValueKey('home-action-reading'),
              tokens: tokens,
              icon: Icons.menu_book_rounded,
              title: t('Read a Story', 'Bir hikâye oku'),
              subtitle: t('Reading library', 'Okuma kütüphanesi'),
              color: _tone(tokens, _blue, 1),
              onTap: _openReading,
            ),
            _ActionCard(
              key: const ValueKey('home-action-voxa'),
              tokens: tokens,
              icon: Icons.chat_bubble_rounded,
              title: t('Talk to Voxa', 'Voxa ile konuş'),
              subtitle: t('AI language coach', 'AI dil koçu'),
              color: _tone(tokens, _pink, 3),
              onTap: () => _go(3),
            ),
            _ActionCard(
              key: const ValueKey('home-action-arena'),
              tokens: tokens,
              icon: Icons.emoji_events_rounded,
              title: t('Arena', 'Arena'),
              subtitle: t('Daily XP games', 'Günlük XP oyunları'),
              color: _tone(tokens, _orange, 2),
              onTap: _openArena,
            ),
            _ActionCard(
              key: const ValueKey('home-action-writing'),
              tokens: tokens,
              icon: Icons.edit_note_rounded,
              title: t('Writing Studio', 'Yazma Stüdyosu'),
              subtitle: t('Write with feedback', 'Geri bildirimle yaz'),
              color: _tone(tokens, _green, 2),
              onTap: _openWriting,
            ),
            _ActionCard(
              key: const ValueKey('home-action-learn'),
              tokens: tokens,
              icon: Icons.route_rounded,
              title: t('Learning Path', 'Öğrenme Rotası'),
              subtitle: t('All skills', 'Tüm beceriler'),
              color: _tone(tokens, tokens.secondaryAccent, 1),
              onTap: () => _go(1),
            ),
            _ActionCard(
              key: const ValueKey('home-action-speaking'),
              tokens: tokens,
              icon: Icons.record_voice_over_rounded,
              title: t('Speaking Room', 'Konuşma Odası'),
              subtitle: t('Record and practise', 'Kaydet ve pratik yap'),
              color: _tone(tokens, tokens.secondaryAccent, 3),
              onTap: _openSpeaking,
            ),
            _ActionCard(
              key: const ValueKey('home-action-vocabulary'),
              tokens: tokens,
              icon: Icons.style_rounded,
              title: t('Vocabulary', 'Kelime Çalışması'),
              subtitle: t('Cards and review', 'Kartlar ve tekrar'),
              color: _tone(tokens, tokens.foxAccent),
              onTap: _openVocabulary,
            ),
          ],
        );
      },
    );
  }

  Widget _dailyRoute(SpeakeryThemeTokens tokens) {
    return Row(
      children: [
        Expanded(
          child: _RouteStep(
            key: const ValueKey('home-route-grammar'),
            tokens: tokens,
            number: '1',
            title: t('Grammar', 'Gramer'),
            subtitle: t('Build', 'Kur'),
            icon: Icons.auto_fix_high_rounded,
            color: _tone(tokens, _purple),
            onTap: _openGrammar,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _RouteStep(
            key: const ValueKey('home-route-listening'),
            tokens: tokens,
            number: '2',
            title: t('Listening', 'Dinleme'),
            subtitle: t('Decode', 'Çöz'),
            icon: Icons.headphones_rounded,
            color: _tone(tokens, _orange, 2),
            onTap: _openListening,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _RouteStep(
            key: const ValueKey('home-route-voxa'),
            tokens: tokens,
            number: '3',
            title: 'Voxa',
            subtitle: t('Use it', 'Kullan'),
            icon: Icons.forum_rounded,
            color: _tone(tokens, tokens.foxAccent, 1),
            onTap: () => _go(3),
          ),
        ),
      ],
    );
  }

  Widget _socialPreview(SpeakeryThemeTokens tokens) {
    return _GlassCard(
      tokens: tokens,
      accent: _tone(tokens, _pink, 2),
      padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
      child: Row(
        children: [
          _IconTile(
            tokens: tokens,
            icon: tokens.isVoxaTheme
                ? Icons.favorite_rounded
                : Icons.groups_rounded,
            color: _tone(tokens, _pink, 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tokens.isVoxaTheme
                      ? t('Voxa feels social', 'Voxa sosyalleşmek istiyor')
                      : t('Community prompt', 'Topluluk sorusu'),
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tokens.isVoxaTheme
                      ? t(
                          'Share a sentence so Voxa does not feel alone.',
                          'Voxa yalnız hissetmesin diye bir cümle paylaş.',
                        )
                      : t(
                          'Share one sentence about your day.',
                          'Günün hakkında bir cümle paylaş.',
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _MiniButton(
            tokens: tokens,
            label: t('Open', 'Aç'),
            onTap: () => _go(2),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(SpeakeryThemeTokens tokens, String title) {
    return Text(
      title,
      style: TextStyle(
        color: tokens.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;

  const _GlassCard({
    required this.tokens,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidGlassSurface(
      radius: 26,
      padding: padding,
      accent: accent,
      borderColor: tokens.isLight && accent != null
          ? Color.alphaBlend(accent!.withAlpha(28), tokens.border)
          : null,
      child: child,
    );
  }
}

class _ArenaSpotlight extends StatefulWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;
  final int streak;
  final bool doneToday;
  final VoidCallback onTap;

  const _ArenaSpotlight({
    required this.tokens,
    required this.isEnglish,
    required this.streak,
    required this.doneToday,
    required this.onTap,
  });

  @override
  State<_ArenaSpotlight> createState() => _ArenaSpotlightState();
}

class _ArenaSpotlightState extends State<_ArenaSpotlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _pressed = false;

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final accent = tokens.adaptAccent(const Color(0xFFFF8A00), slot: 2);
    final end = tokens.adaptAccent(const Color(0xFFFF4FD8), slot: 3);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: IosLiquidMotion.quick,
        curve: _pressed ? IosLiquidMotion.press : IosLiquidMotion.release,
        scale: _pressed ? .982 : 1,
        child: IosLiquidGlassSurface(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          accent: accent,
          borderColor: tokens.border,
          strong: true,
          child: Stack(
            children: [
              Positioned(
                right: -18,
                top: -20,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: .96 + (_controller.value * .08),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              end.withAlpha(tokens.isLight ? 38 : 48),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  _ArenaBadgeIcon(
                    animation: _controller,
                    start: accent,
                    end: end,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t('Arena', 'Arena'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: tokens.textPrimary,
                                  fontSize: 22,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            _SoftPill(
                              tokens: tokens,
                              icon: widget.doneToday
                                  ? Icons.check_rounded
                                  : Icons.bolt_rounded,
                              label: widget.doneToday
                                  ? t('Done', 'Tamam')
                                  : '+50 XP',
                              color: widget.doneToday ? tokens.success : accent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t(
                            'Fast word games, daily streaks and duels.',
                            'Hızlı kelime oyunları, günlük seri ve duello.',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 12.2,
                            height: 1.34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ArenaMiniMeter(
                                color: accent,
                                active: true,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _ArenaMiniMeter(
                                color: end,
                                active: widget.streak >= 2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _ArenaMiniMeter(
                                color: tokens.success,
                                active: widget.doneToday,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              t('${widget.streak} streak',
                                  '${widget.streak} seri'),
                              style: TextStyle(
                                color: tokens.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: tokens.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArenaMiniMeter extends StatelessWidget {
  final Color color;
  final bool active;

  const _ArenaMiniMeter({
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: IosLiquidMotion.settle,
      curve: IosLiquidMotion.selectedCurve,
      height: 7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active ? color : color.withAlpha(32),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withAlpha(42),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
    );
  }
}

class _ArenaBadgeIcon extends StatelessWidget {
  final Animation<double> animation;
  final Color start;
  final Color end;

  const _ArenaBadgeIcon({
    required this.animation,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final glow = animation.value;
        return Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [start, end],
            ),
            border: Border.all(color: Colors.white.withAlpha(105)),
            boxShadow: [
              BoxShadow(
                color: start.withAlpha(44 + (glow * 32).round()),
                blurRadius: 18 + (glow * 12),
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: Colors.white.withAlpha(42),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                right: 9,
                top: 8,
                child: Transform.rotate(
                  angle: -.18,
                  child: Icon(
                    Icons.bolt_rounded,
                    color: Colors.white.withAlpha(210),
                    size: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 30,
              ),
              Positioned(
                left: 11,
                bottom: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(230),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(90),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconTile extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final Color color;

  const _IconTile({
    required this.tokens,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withAlpha(tokens.isLight ? 24 : 34),
        border: Border.all(color: color.withAlpha(tokens.isLight ? 58 : 70)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProgressTile({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _GlassCard(
        tokens: tokens,
        accent: color,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 9),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    super.key,
    required this.tokens,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
        scale: _pressed ? .975 : 1,
        child: _GlassCard(
          tokens: widget.tokens,
          accent: widget.color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: widget.color.withAlpha(
                    widget.tokens.isLight ? 22 : 32,
                  ),
                  border: Border.all(
                    color: widget.color.withAlpha(
                      widget.tokens.isLight ? 52 : 66,
                    ),
                  ),
                ),
                child: Icon(widget.icon, color: widget.color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.tokens.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.tokens.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteStep extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RouteStep({
    super.key,
    required this.tokens,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: IosLiquidGlassSurface(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
        accent: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withAlpha(tokens.isLight ? 28 : 38),
                    border: Border.all(
                      color: color.withAlpha(tokens.isLight ? 68 : 82),
                    ),
                  ),
                  child: Text(
                    number,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(icon, color: color, size: 19),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: tokens.textMuted,
                  size: 13,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.tokens,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: tokens.brandGradient,
          boxShadow: [
            BoxShadow(
              color: tokens.primaryAccent.withAlpha(tokens.isLight ? 32 : 60),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Icon(icon, color: Colors.white, size: 19),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final VoidCallback onTap;

  const _MiniButton({
    required this.tokens,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: tokens.primaryAccent.withAlpha(tokens.isLight ? 22 : 34),
          border: Border.all(
            color: tokens.primaryAccent.withAlpha(tokens.isLight ? 58 : 72),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: tokens.primaryAccent,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SoftPill({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(tokens.isLight ? 20 : 30),
        border: Border.all(color: color.withAlpha(tokens.isLight ? 58 : 70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;
    return _TapScale(onTap: onTap!, child: pill);
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScale({required this.child, required this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .975 : 1,
        duration: const Duration(milliseconds: 210),
        curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;

  const _Glow({
    required this.alignment,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(34),
                blurRadius: 90,
                spreadRadius: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
