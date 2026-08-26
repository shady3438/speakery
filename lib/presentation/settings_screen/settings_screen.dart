import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../theme/app_theme.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../services/notification_service.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';
import '../../widgets/voxa_fox_motifs.dart';
import '../premium_screen/premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isEnglish = AppProgress.instance.isEnglish;
  bool notifications = true;
  bool soundEffects = true;
  bool haptics = true;
  String defaultLevel = 'A1';
  String dailyGoal = '10 min';
  String voxaPersonality = 'Friendly Coach';

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    AppProgress.instance.addListener(_syncProgress);
    AppProgress.instance.loadProgress().then((_) => _syncProgress());
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    AppProgress.instance.removeListener(_syncProgress);
    super.dispose();
  }

  void _syncProgress() {
    if (!mounted) return;
    final progress = AppProgress.instance;
    if (isEnglish == progress.isEnglish &&
        soundEffects == progress.soundEffects &&
        haptics == progress.haptics &&
        defaultLevel == progress.englishLevel &&
        dailyGoal == progress.dailyGoal &&
        voxaPersonality == progress.voxaPersonality) {
      return;
    }
    setState(() {
      isEnglish = progress.isEnglish;
      soundEffects = progress.soundEffects;
      haptics = progress.haptics;
      defaultLevel = progress.englishLevel;
      dailyGoal = progress.dailyGoal;
      voxaPersonality = progress.voxaPersonality;
    });
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await NotificationService.instance.isDailyReminderEnabled();
    if (!mounted) return;
    setState(() => notifications = enabled);
  }

  Future<void> _setStudyReminder(bool value) async {
    setState(() => notifications = value);

    if (value) {
      final scheduled =
          await NotificationService.instance.scheduleDailyReminder();
      if (!mounted) return;
      if (!scheduled) {
        setState(() => notifications = false);
        PremiumFeedback.show(
          context,
          message: t('Notification permission was not granted.',
              'Bildirim izni verilmedi.'),
          tone: PremiumFeedbackTone.error,
        );
        return;
      }

      PremiumFeedback.show(
        context,
        message: t('Daily reminder set for 20:00.',
            'Günlük hatırlatıcı 20:00 için kuruldu.'),
        tone: PremiumFeedbackTone.success,
      );
      return;
    }

    await NotificationService.instance.cancelDailyReminder();
    if (!mounted) return;
    PremiumFeedback.show(
      context,
      message: t('Daily reminder disabled.', 'Günlük hatırlatıcı kapatıldı.'),
    );
  }

  void _showPrivacyCenter() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PrivacyCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -120,
            child: _glow(
              tokens.isVoxaTheme
                  ? tokens.primaryAccent
                  : const Color(0xFFEC4899),
              300,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -140,
            child: _glow(
              tokens.isVoxaTheme
                  ? tokens.secondaryAccent
                  : const Color(0xFF06B6D4),
              280,
            ),
          ),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
              children: [
                _topBar(),
                const SizedBox(height: 14),
                _languageCard(),
                const SizedBox(height: 12),
                _appearanceCard(),
                const SizedBox(height: 12),
                _learningCard(),
                const SizedBox(height: 12),
                _experienceCard(),
                const SizedBox(height: 12),
                _voxaCard(),
                const SizedBox(height: 12),
                _accountCard(),
                const SizedBox(height: 12),
                _dangerZone(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        _TapScale(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: tokens.chipSurface,
              border: Border.all(color: tokens.border),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: tokens.textPrimary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _glass(
            borderRadius: 26,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: tokens.isVoxaTheme
                        ? tokens.brandGradient
                        : const LinearGradient(
                            colors: [
                              Color(0xFFEC4899),
                              Color(0xFF8B5CF6),
                            ],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: (tokens.isVoxaTheme
                                ? tokens.primaryAccent
                                : const Color(0xFFEC4899))
                            .withAlpha(55),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('Settings', 'Ayarlar'),
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        t(
                          'Language, appearance, and preferences',
                          'Dil, görünüm ve tercihler',
                        ),
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
          ),
        ),
      ],
    );
  }

  Widget _languageCard() {
    return _SettingsGroup(
      icon: Icons.language_rounded,
      title: t('Language', 'Dil'),
      subtitle: t('Choose the interface language.', 'Arayüz dilini seç.'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FlagLanguageToggle(
            isEnglish: isEnglish,
            onChanged: (value) {
              setState(() => isEnglish = value);
              AppProgress.instance.setEnglishUi(value);
            },
          ),
          const SizedBox(height: 10),
          Text(
            t(
              'Applied across Speakery and saved on this device.',
              'Tüm Speakery arayüzüne uygulanır ve bu cihazda saklanır.',
            ),
            style: TextStyle(
              color: SpeakeryThemeTokens.of(context).textMuted,
              fontSize: 11.2,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appearanceCard() {
    return _SettingsGroup(
      icon: Icons.auto_awesome_rounded,
      title: t('Appearance', 'Görünüm'),
      subtitle: t(
        'Control the visual feel of Speakery.',
        'Speakery’nin görsel hissini ayarla.',
      ),
      child: Column(
        children: [
          _ThemeModeSelector(
            selected: AppProgress.instance.themeMode,
            isEnglish: isEnglish,
            onSelected: AppProgress.instance.setThemeMode,
          ),
          const SizedBox(height: 10),
          Text(
            t(
              'Saved on this device and applied instantly.',
              'Bu cihazda kaydedilir ve aninda uygulanir.',
            ),
            style: TextStyle(
              color: SpeakeryThemeTokens.of(context).textMuted,
              fontSize: 11.2,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _learningCard() {
    final tokens = SpeakeryThemeTokens.of(context);
    return _SettingsGroup(
      icon: Icons.school_rounded,
      title: t('Learning', 'Öğrenme'),
      subtitle: t(
        'Set your default study preferences.',
        'Varsayılan çalışma tercihlerini ayarla.',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('Default level', 'Varsayılan seviye'),
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 13.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _LevelSelector(
            selected: defaultLevel,
            onChanged: (level) {
              AppProgress.instance.setEnglishLevel(level);
              PremiumFeedback.show(
                context,
                message: t('Default level set to $level.',
                    'Varsayılan seviye $level oldu.'),
                tone: PremiumFeedbackTone.success,
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Daily goal',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 13.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _SegmentSelector(
            values: const ['5 min', '10 min', '20 min'],
            selected: dailyGoal,
            onChanged: (value) {
              AppProgress.instance.setDailyGoal(value);
              PremiumFeedback.show(
                context,
                message: t(
                  'Daily goal set to $value.',
                  'Günlük hedef $value oldu.',
                ),
                tone: PremiumFeedbackTone.success,
              );
            },
          ),
          const SizedBox(height: 12),
          _SwitchRow(
            icon: Icons.notifications_active_rounded,
            title: t('Study Reminders', 'Çalışma Hatırlatıcıları'),
            subtitle: t('Daily reminder at 20:00', 'Günlük hatırlatıcı 20:00'),
            value: notifications,
            onChanged: _setStudyReminder,
          ),
        ],
      ),
    );
  }

  Widget _experienceCard() {
    return _SettingsGroup(
      icon: Icons.tune_rounded,
      title: t('Experience', 'Deneyim'),
      subtitle: t(
          'Sound, haptics, and app feel.', 'Ses, titreşim ve uygulama hissi.'),
      child: Column(
        children: [
          _SwitchRow(
            icon: Icons.volume_up_rounded,
            title: t('Sound effects', 'Ses efektleri'),
            subtitle: soundEffects
                ? t('Audio cues are on.', 'Ses ipuçları açık.')
                : t('Audio cues are muted.', 'Ses ipuçları kapalı.'),
            value: soundEffects,
            onChanged: (value) {
              AppProgress.instance.setSoundEffects(value);
              PremiumFeedback.show(
                context,
                message:
                    value ? 'Sound effects enabled.' : 'Sound effects muted.',
              );
            },
          ),
          const SizedBox(height: 12),
          _SwitchRow(
            icon: Icons.vibration_rounded,
            title: t('Haptics', 'Titreşim'),
            subtitle: haptics
                ? t('Tap feedback is on.', 'Dokunma geri bildirimi açık.')
                : t('Tap feedback is off.', 'Dokunma geri bildirimi kapalı.'),
            value: haptics,
            onChanged: (value) {
              AppProgress.instance.setHaptics(value);
              PremiumFeedback.show(
                context,
                message: value ? 'Haptics enabled.' : 'Haptics disabled.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _voxaCard() {
    return _SettingsGroup(
      icon: Icons.auto_awesome_rounded,
      title: 'Voxa',
      subtitle: t('Choose the coach tone.', 'Koç tonunu seç.'),
      child: _SegmentSelector(
        values: const [
          'Friendly Coach',
          'Exam Mentor',
          'Strict Teacher',
          'Casual Partner',
        ],
        selected: voxaPersonality,
        onChanged: (value) {
          AppProgress.instance.setVoxaPersonality(value);
          PremiumFeedback.show(
            context,
            message: t(
              'Voxa personality set to $value.',
              'Voxa tonu $value olarak ayarlandı.',
            ),
            tone: PremiumFeedbackTone.success,
          );
        },
      ),
    );
  }

  Widget _accountCard() {
    return AnimatedBuilder(
      animation: AppProgress.instance,
      builder: (context, _) {
        final progress = AppProgress.instance;
        final tokens = SpeakeryThemeTokens.of(context);
        return _SettingsGroup(
          icon: Icons.person_rounded,
          title: t('Account', 'Hesap'),
          subtitle: t(
            'Plan and learning account options.',
            'Plan ve öğrenme hesabı seçenekleri.',
          ),
          child: Column(
            children: [
              _ActionRow(
                icon: progress.isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.lock_rounded,
                title: progress.isPremium
                    ? t('Premium active', 'Premium aktif')
                    : t('Premium Plan', 'Premium Plan'),
                subtitle: progress.isPremium
                    ? t('All premium tools are enabled.',
                        'Tüm premium araçlar aktif.')
                    : t('See unlock options', 'Açma seçeneklerini gör'),
                trailing: progress.isPremium ? 'ON' : t('Open', 'Aç'),
                onTap: () {
                  if (progress.isPremium) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  );
                },
              ),
              Divider(color: tokens.border, height: 18),
              _ActionRow(
                icon: Icons.privacy_tip_rounded,
                title: t('Privacy', 'Gizlilik'),
                subtitle: t(
                  'Local data, AI requests, and sync.',
                  'Yerel veri, AI istekleri ve senkron.',
                ),
                trailing: t('Open', 'Aç'),
                onTap: _showPrivacyCenter,
              ),
              Divider(color: tokens.border, height: 18),
              _ActionRow(
                icon: Icons.info_rounded,
                title: t('About Speakery', 'Speakery Hakkında'),
                subtitle: t(
                  'Personal English practice with Voxa.',
                  'Voxa ile kişisel İngilizce pratiği.',
                ),
                trailing: t('Open', 'Aç'),
                onTap: () => PremiumFeedback.show(
                  context,
                  message: t('Speakery is ready for daily practice.',
                      'Speakery günlük pratik için hazır.'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dangerZone() {
    return AnimatedBuilder(
      animation: AppProgress.instance,
      builder: (context, _) {
        final progress = AppProgress.instance;
        return _SettingsGroup(
          icon: Icons.restart_alt_rounded,
          title: t('Progress Controls', 'İlerleme Kontrolleri'),
          subtitle: t(
            'Manage local XP, streak and completed lessons.',
            'Yerel XP, seri ve biten dersleri yönet.',
          ),
          child: _ActionRow(
            icon: Icons.delete_sweep_rounded,
            title: t('Reset progress', 'İlerlemeyi sıfırla'),
            subtitle:
                t('XP, streak, completed lessons', 'XP, seri, biten dersler'),
            trailing: t('Reset', 'Sıfırla'),
            danger: true,
            onTap: () => _showResetDialog(progress),
          ),
        );
      },
    );
  }

  Future<void> _showResetDialog(AppProgress progress) async {
    final confirmed = await PremiumFeedback.confirm(
      context,
      title: t('Reset progress?', 'İlerleme sıfırlansın mı?'),
      message: t(
        'This will reset XP, streak and completed lessons on this device.',
        'Bu cihazdaki XP, seri ve tamamlanan dersler sıfırlanır.',
      ),
      confirmLabel: t('Reset', 'Sıfırla'),
      cancelLabel: t('Cancel', 'Vazgeç'),
      tone: PremiumFeedbackTone.error,
    );
    if (!confirmed) return;
    progress.resetLocalProgress();
    if (!mounted) return;
    PremiumFeedback.show(
      context,
      message: t('Progress reset.', 'İlerleme sıfırlandı.'),
      tone: PremiumFeedbackTone.success,
    );
  }

  Widget _glass({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
    double borderRadius = 22,
  }) {
    final tokens = SpeakeryThemeTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tokens.glassSurface,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: tokens.border),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(72),
              blurRadius: 100,
              spreadRadius: 42,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsGroup({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _LiquidCard(
      radius: 30,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: tokens.isVoxaTheme
                      ? tokens.brandGradient
                      : const LinearGradient(
                          colors: [
                            Color(0xFFEC4899),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (tokens.isVoxaTheme
                              ? tokens.primaryAccent
                              : const Color(0xFFEC4899))
                          .withAlpha(40),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 16.2,
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
                        fontSize: 11.3,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FlagLanguageToggle extends StatelessWidget {
  final bool isEnglish;
  final ValueChanged<bool> onChanged;

  const _FlagLanguageToggle({
    required this.isEnglish,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final englishColor = tokens.adaptAccent(const Color(0xFF2563EB));
    final turkishColor = tokens.adaptAccent(const Color(0xFFE11D48), slot: 1);
    return IosLiquidPillSelector(
      key: const ValueKey<String>('settings-language-toggle'),
      items: const [
        IosPillItem('English', icon: Icons.language_rounded),
        IosPillItem('Türkçe', icon: Icons.translate_rounded),
      ],
      selectedIndex: isEnglish ? 0 : 1,
      startColor: isEnglish ? englishColor : turkishColor,
      endColor: isEnglish
          ? tokens.adaptAccent(const Color(0xFF7C3AED), slot: 1)
          : tokens.adaptAccent(const Color(0xFFDC2626)),
      itemColors: [englishColor, turkishColor],
      height: 52,
      onChanged: (index) => onChanged(index == 0),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        _SmallIcon(
          icon: icon,
          color: tokens.adaptAccent(const Color(0xFF38BDF8)),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _rowTitleStyle(tokens)),
              const SizedBox(height: 3),
              Text(subtitle, style: _rowSubtitleStyle(tokens)),
            ],
          ),
        ),
        _IosSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final SpeakeryThemeMode selected;
  final bool isEnglish;
  final ValueChanged<SpeakeryThemeMode> onSelected;

  const _ThemeModeSelector({
    required this.selected,
    required this.isEnglish,
    required this.onSelected,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final items = [
      _ThemeChoice(
        mode: SpeakeryThemeMode.dark,
        icon: Icons.dark_mode_rounded,
        label: t('Dark', 'Koyu'),
        colors: const [Color(0xFF111827), Color(0xFF7C3AED)],
      ),
      _ThemeChoice(
        mode: SpeakeryThemeMode.white,
        icon: Icons.light_mode_rounded,
        label: t('White', 'Beyaz'),
        colors: const [Color(0xFFFFFFFF), Color(0xFF7C3AED)],
      ),
      const _ThemeChoice(
        mode: SpeakeryThemeMode.voxaLight,
        icon: Icons.pets_rounded,
        label: 'Voxa Light',
        colors: [Color(0xFF8A4A20), Color(0xFFFF7A12)],
      ),
      const _ThemeChoice(
        mode: SpeakeryThemeMode.voxaDark,
        icon: Icons.nightlight_round,
        label: 'Voxa Dark',
        colors: [Color(0xFF15103A), Color(0xFF9B6CFF)],
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 2.05,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final active = item.mode == selected;
        final isVoxa = item.mode == SpeakeryThemeMode.voxaLight ||
            item.mode == SpeakeryThemeMode.voxaDark;
        final isVoxaDark = item.mode == SpeakeryThemeMode.voxaDark;

        return GestureDetector(
          onTap: () => onSelected(item.mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: active
                    ? item.colors
                    : isVoxaDark
                        ? const [Color(0xFF0A0921), Color(0xFF1C1244)]
                        : [
                            tokens.elevatedSurface,
                            Color.alphaBlend(
                              item.colors.last.withAlpha(12),
                              tokens.glassSurface,
                            ),
                          ],
              ),
              border: Border.all(
                color: active
                    ? Colors.white.withAlpha(120)
                    : item.colors.last.withAlpha(45),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: item.colors.last.withAlpha(42),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(active ? 45 : 170),
                  ),
                  child: isVoxa
                      ? const VoxaMascot(size: 34)
                      : Icon(
                          item.icon,
                          color: active ? Colors.white : item.colors.last,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 2,
                    style: TextStyle(
                      color: active || isVoxaDark
                          ? Colors.white
                          : tokens.textPrimary,
                      fontSize: 11.5,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (active)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeChoice {
  final SpeakeryThemeMode mode;
  final IconData icon;
  final String label;
  final List<Color> colors;

  const _ThemeChoice({
    required this.mode,
    required this.icon,
    required this.label,
    required this.colors,
  });
}

class _SegmentSelector extends StatelessWidget {
  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentSelector({
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final active = selected == value;
        return _TapScale(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: active
                  ? tokens.primaryAccent.withAlpha(tokens.isLight ? 22 : 30)
                  : tokens.chipSurface,
              border: Border.all(
                color:
                    active ? tokens.primaryAccent.withAlpha(80) : tokens.border,
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: active ? tokens.primaryAccent : tokens.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LevelSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final tokens = SpeakeryThemeTokens.of(context);

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.inputSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          for (final level in levels)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: selected == level
                        ? _levelColor(level, tokens).withAlpha(235)
                        : Colors.transparent,
                    boxShadow: selected == level
                        ? [
                            BoxShadow(
                              color: _levelColor(level, tokens).withAlpha(55),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      color: selected == level
                          ? Colors.white
                          : tokens.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _levelColor(String level, SpeakeryThemeTokens tokens) {
    final index = const ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].indexOf(level);
    if (tokens.isVoxaTheme) {
      return [
        tokens.primaryAccent,
        tokens.warmAccent,
        tokens.secondaryAccent,
      ][index < 0 ? 0 : index % 3];
    }

    switch (level) {
      case 'A1':
        return const Color(0xFF06B6D4);
      case 'A2':
        return const Color(0xFF22C55E);
      case 'B1':
        return const Color(0xFFF59E0B);
      case 'B2':
        return const Color(0xFFEC4899);
      case 'C1':
        return const Color(0xFF8B5CF6);
      case 'C2':
        return const Color(0xFFFF6B57);
      default:
        return const Color(0xFF38BDF8);
    }
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final bool danger;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final color = danger
        ? tokens.adaptAccent(const Color(0xFFEF4444), slot: 1)
        : tokens.adaptAccent(const Color(0xFFEC4899));

    return _TapScale(
      onTap: onTap,
      child: Row(
        children: [
          _SmallIcon(icon: icon, color: color),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _rowTitleStyle(tokens)),
                const SizedBox(height: 3),
                Text(subtitle, style: _rowSubtitleStyle(tokens)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withAlpha(14),
              border: Border.all(color: color.withAlpha(38)),
            ),
            child: Text(
              trailing,
              style: TextStyle(
                color: color.withAlpha(235),
                fontSize: 10.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCenterSheet extends StatelessWidget {
  const _PrivacyCenterSheet();

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final progress = AppProgress.instance;
    final isEnglish = progress.isEnglish;
    String t(String en, String tr) => isEnglish ? en : tr;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: BoxDecoration(
              color: tokens.glassSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: tokens.border),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadow.withAlpha(tokens.isLight ? 35 : 90),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.textMuted.withAlpha(90),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _SmallIcon(
                      icon: Icons.privacy_tip_rounded,
                      color: tokens.primaryAccent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Privacy Center', 'Gizlilik Merkezi'),
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t(
                              'A quick view of what Speakery stores and sends.',
                              'Speakery ne saklar ve ne gönderir: kısa özet.',
                            ),
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PrivacyChip(
                      label: '${progress.xp} XP',
                      icon: Icons.bolt_rounded,
                    ),
                    _PrivacyChip(
                      label: '${progress.streak} streak',
                      icon: Icons.local_fire_department_rounded,
                    ),
                    _PrivacyChip(
                      label: '${progress.savedVocabularyCount} saved words',
                      icon: Icons.bookmark_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _PrivacyInfoRow(
                  icon: Icons.phone_iphone_rounded,
                  title: t('Local progress', 'Yerel ilerleme'),
                  body: t(
                    'XP, streak, lessons and preferences are saved on this device.',
                    'XP, seri, dersler ve tercihler bu cihazda saklanır.',
                  ),
                ),
                _PrivacyInfoRow(
                  icon: Icons.cloud_sync_rounded,
                  title: t('Profile sync', 'Profil senkronu'),
                  body: t(
                    'Profile and social details can sync through the configured cloud account.',
                    'Profil ve sosyal bilgiler ayarlanan bulut hesabı ile senkronlanabilir.',
                  ),
                ),
                _PrivacyInfoRow(
                  icon: Icons.auto_awesome_rounded,
                  title: t('AI feedback', 'AI geri bildirimi'),
                  body: t(
                    'AI requests use compact task text plus small context, not the full app state.',
                    'AI istekleri tüm uygulama durumunu değil, kısa metin ve küçük bağlam gönderir.',
                  ),
                ),
                const SizedBox(height: 12),
                _TapScale(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: tokens.brandGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(35)),
                    ),
                    child: Text(
                      t('Done', 'Tamam'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PrivacyChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.chipSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.primaryAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PrivacyInfoRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SmallIcon(icon: icon, color: tokens.secondaryAccent),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _rowTitleStyle(tokens)),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: _rowSubtitleStyle(tokens),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IosSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _IosSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IosLiquidSwitch(
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SmallIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SmallIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color.withAlpha(13),
        border: Border.all(color: color.withAlpha(32)),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}

class _LiquidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _LiquidCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 24,
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

TextStyle _rowTitleStyle(SpeakeryThemeTokens tokens) => TextStyle(
      color: tokens.textPrimary,
      fontSize: 13.5,
      fontWeight: FontWeight.w900,
    );

TextStyle _rowSubtitleStyle(SpeakeryThemeTokens tokens) => TextStyle(
      color: tokens.textSecondary,
      fontSize: 11.4,
      height: 1.28,
      fontWeight: FontWeight.w700,
    );
