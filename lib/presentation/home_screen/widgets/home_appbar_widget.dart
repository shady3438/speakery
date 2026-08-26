import 'dart:ui';

import '../../../core/app_export.dart';
import '../../../data/app_progress.dart';
import '../../../services/notification_service.dart';
import '../../../widgets/premium_feedback.dart';

class HomeAppBarWidget extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final String avatarSemantic;
  final String level;
  final AnimationController entranceController;
  final VoidCallback? onProfileTap;

  const HomeAppBarWidget({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.avatarSemantic,
    required this.level,
    required this.entranceController,
    this.onProfileTap,
  });

  String _greeting(bool isEnglish) {
    final hour = DateTime.now().hour;
    if (hour < 12) return isEnglish ? 'Good morning' : 'Günaydın';
    if (hour < 17) return isEnglish ? 'Good afternoon' : 'İyi günler';
    return isEnglish ? 'Good evening' : 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = AppProgress.instance.isEnglish;
    String t(String en, String tr) => isEnglish ? en : tr;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting(isEnglish)}, $userName',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cefrLevelColor(level).withAlpha(46),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.cefrLevelColor(
                                level,
                              ).withAlpha(102),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            t('Level $level', '$level seviye'),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cefrLevelColor(level),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('Your daily goal awaits!',
                              'Günlük hedefin seni bekliyor!'),
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Notification bell
                  GestureDetector(
                    onTap: () => _showNotificationCenter(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.glassWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Avatar
                  GestureDetector(
                    onTap: onProfileTap ??
                        () => PremiumFeedback.show(
                              context,
                              message: t(
                                'Open your profile from the bottom bar.',
                                'Profilini alt menüden açabilirsin.',
                              ),
                              icon: Icons.person_rounded,
                            ),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(77),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: avatarUrl,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          semanticLabel: avatarSemantic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _NotificationCenterSheet(
        userName: userName,
        level: level,
        isEnglish: AppProgress.instance.isEnglish,
      ),
    );
  }
}

class _NotificationCenterSheet extends StatefulWidget {
  final String userName;
  final String level;
  final bool isEnglish;

  const _NotificationCenterSheet({
    required this.userName,
    required this.level,
    required this.isEnglish,
  });

  @override
  State<_NotificationCenterSheet> createState() =>
      _NotificationCenterSheetState();
}

class _NotificationCenterSheetState extends State<_NotificationCenterSheet> {
  bool _reminderEnabled = false;
  String _reminderTime = '20:00';

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final enabled = await NotificationService.instance.isDailyReminderEnabled();
    final time = await NotificationService.instance.dailyReminderTime();
    if (!mounted) return;
    setState(() {
      _reminderEnabled = enabled;
      _reminderTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _toggleReminder() async {
    if (_reminderEnabled) {
      await NotificationService.instance.cancelDailyReminder();
      if (!mounted) return;
      setState(() => _reminderEnabled = false);
      PremiumFeedback.show(
        context,
        message: t(
          'Daily reminder disabled.',
          'Günlük hatırlatıcı kapatıldı.',
        ),
      );
      return;
    }

    final scheduled =
        await NotificationService.instance.scheduleDailyReminder();
    if (!mounted) return;
    if (!scheduled) {
      PremiumFeedback.show(
        context,
        message: t(
          'Notification permission was not granted.',
          'Bildirim izni verilmedi.',
        ),
        tone: PremiumFeedbackTone.error,
      );
      return;
    }

    await _loadReminder();
    if (!mounted) return;
    PremiumFeedback.show(
      context,
      message: t(
        'Daily reminder set for $_reminderTime.',
        'Günlük hatırlatıcı $_reminderTime için kuruldu.',
      ),
      tone: PremiumFeedbackTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = AppProgress.instance;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        16,
        18,
        MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: AppTheme.glassBorder,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('Notification Center', 'Bildirim Merkezi'),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.userName} - Level ${widget.level}',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _NotificationTile(
                icon: Icons.local_fire_department_rounded,
                title: t('Streak', 'Seri'),
                subtitle: progress.studiedToday
                    ? t('You studied today. Nice.', 'Bugün çalıştın. Güzel.')
                    : t('Finish one lesson to protect your streak.',
                        'Serini korumak için bir ders bitir.'),
                trailing: '${progress.streak}d',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 9),
              _NotificationTile(
                icon: Icons.bolt_rounded,
                title: t('XP progress', 'XP ilerlemesi'),
                subtitle: t(
                  '${progress.xpInCurrentLevel}/100 XP to next level',
                  'Sonraki seviye için ${progress.xpInCurrentLevel}/100 XP',
                ),
                trailing: '${progress.xp}',
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 9),
              _NotificationTile(
                icon: _reminderEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                title: t('Daily reminder', 'Günlük hatırlatıcı'),
                subtitle: _reminderEnabled
                    ? t('Scheduled every day at $_reminderTime.',
                        'Her gün $_reminderTime için kurulu.')
                    : t('No daily reminder is active.',
                        'Aktif günlük hatırlatıcı yok.'),
                trailing: _reminderEnabled ? 'ON' : 'OFF',
                color: const Color(0xFF06B6D4),
                onTap: _toggleReminder,
              ),
              const SizedBox(height: 14),
              _NotificationAction(
                label: _reminderEnabled
                    ? t('Turn off reminder', 'Hatırlatıcıyı kapat')
                    : t('Enable 20:00 reminder', '20:00 hatırlatıcısını aç'),
                onTap: _toggleReminder,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final Color color;
  final VoidCallback? onTap;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppTheme.glassWhite,
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: color.withAlpha(26),
                border: Border.all(color: color.withAlpha(55)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11.4,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailing,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NotificationAction({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: AppTheme.primaryGradient,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
