import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/premium_feedback.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'Annual';

  bool get _isEnglish => AppProgress.instance.isEnglish;

  String t(String en, String tr) => _isEnglish ? en : tr;

  void _activatePremium() {
    AppProgress.instance.activatePremiumAccess();
    PremiumFeedback.show(
      context,
      message: t('Premium access activated. Premium modules are unlocked.',
          'Premium erişim açıldı. Premium modüller kilitsiz.'),
      tone: PremiumFeedbackTone.success,
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) Navigator.maybePop(context);
    });
  }

  void _restorePurchase() {
    if (AppProgress.instance.isPremium) {
      PremiumFeedback.show(
        context,
        message: t('Premium access restored on this device.',
            'Bu cihazdaki premium erişim geri yüklendi.'),
        tone: PremiumFeedbackTone.success,
      );
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) Navigator.maybePop(context);
      });
      return;
    }

    PremiumFeedback.show(
      context,
      message: t('No previous premium access was found on this device.',
          'Bu cihazda önceki premium erişim bulunamadı.'),
      tone: PremiumFeedbackTone.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final alreadyPremium = AppProgress.instance.isPremium;
    final selectedPlanLabel = _selectedPlan == 'Annual'
        ? t('Annual', 'Yıllık')
        : t('Monthly', 'Aylık');

    return Scaffold(
      backgroundColor: tokens.background,
      body: Container(
        decoration: BoxDecoration(gradient: tokens.pageGradient),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _Glow(color: tokens.primaryAccent, size: 270),
            ),
            Positioned(
              bottom: -130,
              left: -120,
              child: _Glow(color: tokens.secondaryAccent, size: 260),
            ),
            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                children: [
                  _TopBar(tokens: tokens),
                  const SizedBox(height: 14),
                  _Hero(tokens: tokens, isEnglish: _isEnglish),
                  const SizedBox(height: 14),
                  _OfferStrip(tokens: tokens, isEnglish: _isEnglish),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _PlanCard(
                          tokens: tokens,
                          title: t('Monthly', 'Aylık'),
                          price: '149 TL',
                          caption: t('Flexible access', 'Esnek erişim'),
                          selected: _selectedPlan == 'Monthly',
                          onTap: () =>
                              setState(() => _selectedPlan = 'Monthly'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PlanCard(
                          tokens: tokens,
                          title: t('Annual', 'Yıllık'),
                          price: '999 TL',
                          caption: t('Best value', 'En avantajlı'),
                          selected: _selectedPlan == 'Annual',
                          badge: t('Save 44%', '%44 tasarruf'),
                          onTap: () => setState(() => _selectedPlan = 'Annual'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FeatureList(tokens: tokens, isEnglish: _isEnglish),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    tokens: tokens,
                    label: alreadyPremium
                        ? t('Premium Active', 'Premium aktif')
                        : t('Continue with $selectedPlanLabel',
                            '$selectedPlanLabel ile devam et'),
                    onTap: alreadyPremium
                        ? () => Navigator.maybePop(context)
                        : _activatePremium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _restorePurchase,
                    child: Text(
                      t('Restore purchase', 'Satın alımı geri yükle'),
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: Text(
                      t('Continue free', 'Ücretsiz devam et'),
                      style: TextStyle(
                        color: tokens.textMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final SpeakeryThemeTokens tokens;

  const _TopBar({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButton(
          tokens: tokens,
          icon: Icons.close_rounded,
          onTap: () => Navigator.maybePop(context),
        ),
        const Spacer(),
        _Pill(tokens: tokens, label: 'Premium'),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;

  const _Hero({required this.tokens, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      tokens: tokens,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: tokens.brandGradient,
              boxShadow: [
                BoxShadow(
                  color: tokens.primaryAccent.withAlpha(55),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            t('Unlock Speakery Premium', 'Speakery Premium kilidini aç'),
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 30,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t(
              'Exam paths, speaking missions, smart review, and Voxa practice in one polished study flow.',
              'Sınav yolları, konuşma görevleri, akıllı tekrar ve Voxa pratiği tek akıcı çalışma düzeninde.',
            ),
            style: TextStyle(
              color: tokens.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferStrip extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;

  const _OfferStrip({required this.tokens, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _Glass(
      tokens: tokens,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.local_fire_department_rounded, color: tokens.foxAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t(
                'Launch offer: 7-day trial included. Start now and keep every premium study path open.',
                'Başlangıç teklifi: 7 günlük deneme dahil. Şimdi başla, premium çalışma yolları açık kalsın.',
              ),
              style: TextStyle(
                color: tokens.textPrimary,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String title;
  final String price;
  final String caption;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.tokens,
    required this.title,
    required this.price,
    required this.caption,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected
              ? tokens.primaryAccent.withAlpha(24)
              : tokens.glassSurface,
          border: Border.all(
            color:
                selected ? tokens.primaryAccent.withAlpha(95) : tokens.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? tokens.primaryAccent : tokens.textMuted,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 10),
              _Pill(tokens: tokens, label: badge!),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final bool isEnglish;

  const _FeatureList({required this.tokens, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        Icons.mic_rounded,
        t('Speaking missions', 'Konuşma görevleri'),
        t('Guided fluency practice with focused feedback.',
            'Odaklı geri bildirimle yönlendirilmiş akıcılık pratiği.'),
      ),
      _Feature(
        Icons.school_rounded,
        t('Exam paths', 'Sınav yolları'),
        t('IELTS, TOEFL, YDT, and premium study tracks.',
            'IELTS, TOEFL, YDT ve premium çalışma rotaları.'),
      ),
      _Feature(
        Icons.auto_awesome_rounded,
        t('Voxa repairs', 'Voxa onarımları'),
        t('Focused practice prompts for weak spots.',
            'Zayıf noktalar için odaklı pratik önerileri.'),
      ),
      _Feature(
        Icons.query_stats_rounded,
        t('Progress insights', 'İlerleme içgörüleri'),
        t('XP, streaks, badges, and review momentum.',
            'XP, seri, rozet ve tekrar temposu.'),
      ),
    ];

    return _Glass(
      tokens: tokens,
      child: Column(
        children: [
          for (final feature in features) ...[
            _FeatureRow(tokens: tokens, feature: feature),
            if (feature != features.last)
              Divider(height: 18, color: tokens.border),
          ],
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final _Feature feature;

  const _FeatureRow({required this.tokens, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: tokens.primaryAccent.withAlpha(18),
            border: Border.all(color: tokens.primaryAccent.withAlpha(42)),
          ),
          child: Icon(feature.icon, color: tokens.primaryAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                feature.text,
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.tokens,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: tokens.brandGradient,
          boxShadow: [
            BoxShadow(
              color: tokens.primaryAccent.withAlpha(48),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({
    required this.tokens,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tokens.chipSurface,
          border: Border.all(color: tokens.border),
        ),
        child: Icon(icon, color: tokens.textPrimary),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;

  const _Pill({
    required this.tokens,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.primaryAccent.withAlpha(18),
        border: Border.all(color: tokens.primaryAccent.withAlpha(46)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tokens.primaryAccent,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Glass({
    required this.tokens,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: tokens.glassGradient,
            border: Border.all(color: tokens.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(42),
              blurRadius: 110,
              spreadRadius: 36,
            ),
          ],
        ),
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TapScale({required this.child, this.onTap});

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
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String text;

  const _Feature(this.icon, this.title, this.text);
}
