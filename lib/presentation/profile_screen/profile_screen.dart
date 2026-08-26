import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../data/social_profile_store.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';
import '../learn_overview_screen/learn_overview_screen.dart';
import '../premium_screen/premium_screen.dart';
import '../settings_screen/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SocialProfileStore _socialProfile = SocialProfileStore.instance;
  bool isEnglish = false;
  int _selectedTabIndex = 0;

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    _socialProfile.load();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: IosDynamicGlassBackdrop(
        primary: const Color(0xFFEC4899),
        secondary: const Color(0xFF06B6D4),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([AppProgress.instance, _socialProfile]),
            builder: (context, _) {
              final progress = AppProgress.instance;

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 118),
                children: [
                  _topBar(),
                  const SizedBox(height: 14),
                  _socialHero(progress),
                  const SizedBox(height: 12),
                  _socialStats(),
                  const SizedBox(height: 14),
                  IosLiquidPillSelector(
                    selectedIndex: _selectedTabIndex,
                    onChanged: (value) =>
                        setState(() => _selectedTabIndex = value),
                    startColor: const Color(0xFFEC4899),
                    endColor: const Color(0xFF06B6D4),
                    itemColors: const [
                      Color(0xFFEC4899),
                      Color(0xFF06B6D4),
                      Color(0xFF8B5CF6),
                      Color(0xFF22C55E),
                    ],
                    items: [
                      IosPillItem(t('Profile', 'Profil'),
                          icon: Icons.person_rounded),
                      IosPillItem(t('Requests', 'Istekler'),
                          icon: Icons.group_add_rounded),
                      IosPillItem(t('Learning', 'Ogrenme'),
                          icon: Icons.auto_graph_rounded),
                      IosPillItem(t('Settings', 'Ayarlar'),
                          icon: Icons.tune_rounded),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: KeyedSubtree(
                      key: ValueKey(_selectedTabIndex),
                      child: _profileTabBody(progress),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profileTabBody(AppProgress progress) {
    switch (_selectedTabIndex) {
      case 1:
        return _friendRequests();
      case 2:
        return Column(
          children: [
            _learningSummary(progress),
            const SizedBox(height: 12),
            _compactAchievements(progress),
          ],
        );
      case 3:
        return _actions(progress);
      default:
        return Column(
          children: [
            _profileSnapshot(progress),
            const SizedBox(height: 12),
            _compactAchievements(progress),
          ],
        );
    }
  }

  Widget _profileSnapshot(AppProgress progress) {
    return _glass(
      borderRadius: 30,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.grid_view_rounded,
            t('Profile Snapshot', 'Profil Özeti'),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  icon: Icons.bolt_rounded,
                  value: 'Lv. ${progress.level}',
                  label: progress.rankTitle,
                  color: const Color(0xFFEC4899),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.people_alt_rounded,
                  value: '${_socialProfile.friendsCount}',
                  label: t('Friends', 'Arkadas'),
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HeroButton(
                  icon: Icons.person_add_alt_1_rounded,
                  label: t('Find friends', 'Arkadas bul'),
                  filled: false,
                  onTap: _showAddFriendSheet,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _HeroButton(
                  icon: Icons.edit_rounded,
                  label: t('Edit profile', 'Profili düzenle'),
                  filled: true,
                  onTap: _showEditProfileSheet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Expanded(
          child: _HeaderCard(
            title: t('Profile', 'Profil'),
            subtitle: t(
              'Social profile and learning progress',
              'Sosyal profil ve öğrenme ilerlemen',
            ),
            icon: Icons.person_rounded,
          ),
        ),
        const SizedBox(width: 10),
        _IconPill(
          icon: Icons.settings_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const SpeakeryThemeAdapter(child: SettingsScreen()),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _socialHero(AppProgress progress) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _glass(
      borderRadius: 34,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            right: -46,
            top: -48,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFEC4899).withAlpha(48),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _Avatar(
                    label: _socialProfile.displayName,
                    onEdit: _showEditProfileSheet,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _socialProfile.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.45,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _socialProfile.handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF38BDF8).withAlpha(230),
                            fontSize: 12.4,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            _TinyPill(
                              icon: Icons.bolt_rounded,
                              label: 'Lv. ${progress.level}',
                              color: const Color(0xFFEC4899),
                            ),
                            _TinyPill(
                              icon: Icons.workspace_premium_rounded,
                              label: progress.rankTitle,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                _socialProfile.bio,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12.2,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _HeroButton(
                      icon: Icons.edit_rounded,
                      label: t('Edit Profile', 'Profili Düzenle'),
                      filled: true,
                      onTap: _showEditProfileSheet,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _HeroButton(
                      icon: Icons.person_add_alt_1_rounded,
                      label: t('Add Friend', 'Arkadaş Ekle'),
                      filled: false,
                      onTap: _showAddFriendSheet,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialStats() {
    return Row(
      children: [
        _socialStat('${_socialProfile.followersCount}',
            t('Followers', 'Takipçi'), const Color(0xFFEC4899)),
        const SizedBox(width: 9),
        _socialStat('${_socialProfile.followingCount}', t('Following', 'Takip'),
            const Color(0xFF8B5CF6)),
        const SizedBox(width: 9),
        _socialStat('${_socialProfile.friendsCount}', t('Friends', 'Arkadaş'),
            const Color(0xFF06B6D4)),
      ],
    );
  }

  Widget _socialStat(String value, String label, Color color) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: color.withAlpha(12),
          border: Border.all(color: color.withAlpha(34)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 18.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 10.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _friendRequests() {
    final requests = _socialProfile.incomingRequests;
    return _glass(
      borderRadius: 30,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.group_add_rounded,
            t('Friend Requests', 'Arkadaşlık İstekleri'),
            badge: '${requests.length}',
          ),
          const SizedBox(height: 13),
          if (requests.isEmpty)
            _emptySocialMessage(
              t('No pending requests yet.',
                  'Henüz bekleyen arkadaşlık isteği yok.'),
              t('Share your username to let friends find you.',
                  'Arkadaşlarının seni bulması için kullanıcı adını paylaş.'),
            )
          else
            for (final request in requests) ...[
              _requestTile(
                request: request,
                color: request.username.hashCode.isEven
                    ? const Color(0xFFEC4899)
                    : const Color(0xFF06B6D4),
              ),
              if (request != requests.last) const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }

  Widget _emptySocialMessage(String title, String subtitle) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestTile({
    required FriendRequest request,
    required Color color,
  }) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, const Color(0xFF8B5CF6)],
              ),
            ),
            child: Text(
              request.displayName.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.displayName,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.handle,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _SmallAction(
            label: t('Accept', 'Kabul'),
            color: const Color(0xFF22C55E),
            onTap: () => _handleFriendRequest(request, accept: true),
          ),
          const SizedBox(width: 7),
          _SmallAction(
            label: t('No', 'Sil'),
            color: Colors.white,
            onTap: () => _handleFriendRequest(request, accept: false),
          ),
        ],
      ),
    );
  }

  Widget _learningSummary(AppProgress progress) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _glass(
      borderRadius: 30,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.auto_graph_rounded,
            t('Learning Summary', 'Öğrenme Özeti'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.stars_rounded,
                  value: '${progress.xp}',
                  label: 'XP',
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _MetricTile(
                  icon: Icons.local_fire_department_rounded,
                  value: '${progress.streak}',
                  label: t('Streak', 'Seri'),
                  color: const Color(0xFFFF7A12),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _MetricTile(
                  icon: Icons.done_all_rounded,
                  value: '${progress.completedCount}',
                  label: t('Done', 'Biten'),
                  color: const Color(0xFF22C55E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AnimatedProgressBar(
                  value: progress.levelProgress,
                  start: const Color(0xFFEC4899),
                  end: const Color(0xFF06B6D4),
                  height: 9,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                '${progress.xpInCurrentLevel}/100 XP',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  icon: Icons.bookmark_rounded,
                  value: '${progress.savedVocabularyCount}',
                  label: t('Saved', 'Kayıtlı'),
                  color: const Color(0xFF38BDF8),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _MiniMetric(
                  icon: Icons.military_tech_rounded,
                  value: '${progress.masteredVocabularyCount}',
                  label: t('Mastered', 'Pekişmiş'),
                  color: const Color(0xFFFF8A00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactAchievements(AppProgress progress) {
    final badges = [
      _BadgeData(
        icon: Icons.rocket_launch_rounded,
        title: t('First Step', 'İlk Adım'),
        unlocked: progress.completedCount >= 1,
      ),
      _BadgeData(
        icon: Icons.local_fire_department_rounded,
        title: t('Streak Starter', 'Seri'),
        unlocked: progress.streak >= 3,
      ),
      _BadgeData(
        icon: Icons.stars_rounded,
        title: t('XP Hunter', 'XP Avcısı'),
        unlocked: progress.xp >= 250,
      ),
      _BadgeData(
        icon: Icons.school_rounded,
        title: t('Course Builder', 'Kursçu'),
        unlocked: progress.completedCount >= 10,
      ),
      _BadgeData(
        icon: Icons.menu_book_rounded,
        title: t('Reading Explorer', 'Okuma'),
        unlocked: progress.completedCount >= 2,
      ),
      _BadgeData(
        icon: Icons.record_voice_over_rounded,
        title: t('Voxa Talker', 'Voxa'),
        unlocked: progress.xp >= 150,
      ),
      _BadgeData(
        icon: Icons.auto_stories_rounded,
        title: t('Vocabulary Builder', 'Kelime'),
        unlocked: progress.xp >= 100,
      ),
      _BadgeData(
        icon: Icons.edit_note_rounded,
        title: t('Writing Rookie', 'Yazma'),
        unlocked: progress.completedCount >= 3,
      ),
      _BadgeData(
        icon: Icons.groups_rounded,
        title: t('Social Starter', 'Sosyal'),
        unlocked: progress.streak >= 1,
      ),
    ];

    return _glass(
      borderRadius: 30,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.emoji_events_rounded,
            t('Badges', 'Rozetler'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 86,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              separatorBuilder: (_, __) => const SizedBox(width: 9),
              itemBuilder: (context, index) => _badgePill(badges[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgePill(_BadgeData badge) {
    final tokens = SpeakeryThemeTokens.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: badge.unlocked ? 1 : .45,
      child: Container(
        width: 124,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          gradient: badge.unlocked
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF38BDF8)],
                )
              : null,
          color: badge.unlocked ? null : Colors.white.withAlpha(8),
          border: Border.all(
            color: badge.unlocked ? Colors.transparent : tokens.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.unlocked ? badge.icon : Icons.lock_rounded,
              color: badge.unlocked ? Colors.white : tokens.iconSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: badge.unlocked ? Colors.white : tokens.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actions(AppProgress progress) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const SpeakeryThemeAdapter(child: LearnOverviewScreen()),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF38BDF8),
                  Color(0xFFEC4899),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withAlpha(55),
                  blurRadius: 28,
                  offset: const Offset(0, 13),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 35,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('Continue Learning', 'Öğrenmeye Devam Et'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('Jump back into your course.',
                            'Kursa kaldığın yerden devam et.'),
                        style: TextStyle(
                          color: Colors.white.withAlpha(190),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _glass(
          borderRadius: 30,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              _settingsRow(
                Icons.settings_rounded,
                t('Settings', 'Ayarlar'),
                t('Language, appearance and learning preferences',
                    'Dil, görünüm ve öğrenme tercihleri'),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              Divider(
                color: SpeakeryThemeTokens.of(context).border,
                height: 18,
              ),
              _settingsRow(
                progress.isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.lock_rounded,
                progress.isPremium
                    ? t('Premium active', 'Premium aktif')
                    : t('Unlock Premium', 'Premium’u Aç'),
                progress.isPremium
                    ? t('All premium tools are enabled.',
                        'Tüm premium araçlar aktif.')
                    : t('Speaking, Writing and advanced practice',
                        'Speaking, Writing ve gelişmiş pratikler'),
                () {
                  if (progress.isPremium) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsRow(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final tokens = SpeakeryThemeTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: tokens.chipSurface,
                border: Border.all(color: tokens.border),
              ),
              child: Icon(icon, color: tokens.iconPrimary, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.6,
                      height: 1.28,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: tokens.iconSecondary),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title, {String? badge}) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        Icon(icon, color: tokens.textPrimary, size: 20),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 15.8,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFFEC4899).withAlpha(16),
              border: Border.all(color: const Color(0xFFEC4899).withAlpha(38)),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Color(0xFFEC4899),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _glass({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    double borderRadius = 22,
    Color? color,
    Color? border,
  }) {
    final tokens = SpeakeryThemeTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? tokens.glassSurface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border ?? tokens.border),
          ),
          child: child,
        ),
      ),
    );
  }

  Future<void> _handleFriendRequest(
    FriendRequest request, {
    required bool accept,
  }) async {
    try {
      if (accept) {
        await _socialProfile.acceptRequest(request);
      } else {
        await _socialProfile.declineRequest(request);
      }

      if (!mounted) return;
      PremiumFeedback.show(
        context,
        message: accept
            ? t('Friend request accepted.', 'Arkadaşlık isteği kabul edildi.')
            : t('Friend request removed.', 'Arkadaşlık isteği silindi.'),
        tone: accept ? PremiumFeedbackTone.success : PremiumFeedbackTone.info,
      );
    } catch (_) {
      if (!mounted) return;
      PremiumFeedback.show(
        context,
        message:
            t('Could not update this request.', 'Bu istek güncellenemedi.'),
      );
    }
  }

  Future<void> _showEditProfileSheet() async {
    final result = await showModalBottomSheet<_ProfileEditResult>(
      context: context,
      backgroundColor: const Color(0xFF0B1020),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _EditProfileSheet(
        isEnglish: isEnglish,
        displayName: _socialProfile.displayName,
        username: _socialProfile.handle,
        bio: _socialProfile.bio,
      ),
    );

    if (result == null) return;

    try {
      await _socialProfile.updateProfile(
        displayName: result.displayName,
        username: result.username,
        bio: result.bio,
      );
      if (!mounted) return;
      PremiumFeedback.show(
        context,
        message: t('Profile saved.', 'Profil kaydedildi.'),
        tone: PremiumFeedbackTone.success,
      );
    } on SocialProfileException catch (error) {
      if (!mounted) return;
      PremiumFeedback.show(context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      PremiumFeedback.show(
        context,
        message: t('Profile could not be saved.', 'Profil kaydedilemedi.'),
      );
    }
  }

  Future<void> _showAddFriendSheet() async {
    final username = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0B1020),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _AddFriendSheet(isEnglish: isEnglish),
    );

    if (username == null) return;

    try {
      await _socialProfile.sendFriendRequest(username);
      if (!mounted) return;
      PremiumFeedback.show(
        context,
        message: t('Friend request sent.', 'Arkadaşlık isteği gönderildi.'),
        tone: PremiumFeedbackTone.success,
      );
    } on SocialProfileException catch (error) {
      if (!mounted) return;
      PremiumFeedback.show(context, message: error.message);
    } catch (_) {
      if (!mounted) return;
      PremiumFeedback.show(
        context,
        message: t('Could not send friend request.',
            'Arkadaşlık isteği gönderilemedi.'),
      );
    }
  }
}

class _Avatar extends StatelessWidget {
  final String label;
  final VoidCallback onEdit;

  const _Avatar({
    required this.label,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFEC4899),
                Color(0xFF8B5CF6),
                Color(0xFF06B6D4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withAlpha(70),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Text(
            label.trim().isEmpty ? 'S' : label.characters.first.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: _TapScale(
            onTap: onEdit,
            child: Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8),
                border:
                    Border.all(color: Colors.white.withAlpha(210), width: 2),
              ),
              child:
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)])
              : null,
          color: filled ? null : Colors.white.withAlpha(9),
          border: Border.all(
            color: filled ? Colors.transparent : tokens.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? Colors.white : tokens.textPrimary,
              size: 17,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: filled ? Colors.white : tokens.textPrimary,
                  fontSize: 11.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TinyPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(14),
        border: Border.all(color: color.withAlpha(38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: tokens.isLight ? color : Colors.white.withAlpha(215),
              fontSize: 10.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: color.withAlpha(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 10.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: color.withAlpha(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 10.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final isWhite = color == Colors.white;
    final textColor = isWhite ? tokens.textSecondary : color;
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isWhite ? tokens.chipSurface : color.withAlpha(15),
          border: Border.all(
            color: isWhite ? tokens.border : color.withAlpha(38),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _LiquidShell(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEC4899).withAlpha(55),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 11.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconPill({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: tokens.chipSurface,
          border: Border.all(color: tokens.border),
          boxShadow: [
            BoxShadow(
              color: tokens.shadow.withAlpha(tokens.isLight ? 36 : 80),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: tokens.textPrimary, size: 22),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color start;
  final Color end;
  final double height;

  const _AnimatedProgressBar({
    required this.value,
    required this.start,
    required this.end,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: Colors.white.withAlpha(18),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            widthFactor: safeValue,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [start, end]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _LiquidShell({
    required this.child,
    required this.padding,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tokens.glassSurface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: tokens.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TapScale({
    required this.child,
    required this.onTap,
  });

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
        scale: _pressed ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.displayName,
    required this.username,
    required this.bio,
  });

  final String displayName;
  final String username;
  final String bio;
}

class _EditProfileSheet extends StatefulWidget {
  final bool isEnglish;
  final String displayName;
  final String username;
  final String bio;

  const _EditProfileSheet({
    required this.isEnglish,
    required this.displayName,
    required this.username,
    required this.bio,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.displayName);
    _usernameController = TextEditingController(text: widget.username);
    _bioController = TextEditingController(text: widget.bio);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 14),
          _SheetTitle(
            icon: Icons.edit_rounded,
            title: t('Edit Profile', 'Profili Düzenle'),
            subtitle: t(
              'Update your public Speakery profile',
              'Herkese açık Speakery profilini güncelle',
            ),
          ),
          const SizedBox(height: 14),
          _SheetField(
              label: t('Display name', 'Görünen ad'),
              controller: _displayNameController),
          const SizedBox(height: 10),
          _SheetField(
              label: t('Username', 'Kullanıcı adı'),
              controller: _usernameController),
          const SizedBox(height: 10),
          _SheetField(
              label: t('Bio', 'Bio'), controller: _bioController, maxLines: 3),
          const SizedBox(height: 14),
          _SheetButton(
            label: t('Save profile', 'Profili kaydet'),
            onTap: () => Navigator.pop(
              context,
              _ProfileEditResult(
                displayName: _displayNameController.text,
                username: _usernameController.text,
                bio: _bioController.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFriendSheet extends StatefulWidget {
  final bool isEnglish;

  const _AddFriendSheet({required this.isEnglish});

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final TextEditingController _usernameController =
      TextEditingController(text: '@');

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 14),
          _SheetTitle(
            icon: Icons.person_add_alt_1_rounded,
            title: t('Add Friend', 'Arkadaş Ekle'),
            subtitle: t(
              'Send a request by username',
              'Kullanıcı adıyla istek gönder',
            ),
          ),
          const SizedBox(height: 14),
          _SheetField(
            label: t('Search username', 'Kullanıcı adı ara'),
            controller: _usernameController,
          ),
          const SizedBox(height: 12),
          Text(
            t(
              'The other student will see it in their requests after they open Speakery.',
              'Diğer öğrenci Speakery açtığında isteği kendi ekranında görecek.',
            ),
            style: TextStyle(
              color: tokens.textSecondary,
              height: 1.35,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _SheetButton(
            label: t('Send request', 'İstek gönder'),
            onTap: () => Navigator.pop(context, _usernameController.text),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      width: 46,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.border,
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SheetTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _SheetField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: tokens.textSecondary),
        filled: true,
        fillColor: tokens.inputSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEC4899)),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _BadgeData {
  final IconData icon;
  final String title;
  final bool unlocked;

  const _BadgeData({
    required this.icon,
    required this.title,
    required this.unlocked,
  });
}
