import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../theme/speakery_theme_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;

  const OnboardingScreen({
    super.key,
    this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  String _goal = 'Daily confidence';
  String _level = 'A1';

  static const _goals = [
    _Choice('Daily confidence', Icons.wb_sunny_rounded),
    _Choice('Speaking fluency', Icons.record_voice_over_rounded),
    _Choice('Exam prep', Icons.workspace_premium_rounded),
    _Choice('Travel English', Icons.flight_takeoff_rounded),
  ];

  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    final progress = AppProgress.instance;
    _goal = progress.learningGoal;
    _level = progress.englishLevel;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    AppProgress.instance.setOnboardingChoices(goal: _goal, level: _level);
    widget.onFinish?.call();
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: Container(
        decoration: BoxDecoration(gradient: tokens.pageGradient),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -110,
              child: _Glow(color: tokens.primaryAccent, size: 260),
            ),
            if (!tokens.isLight && tokens.foxAccent == const Color(0xFFFFB071))
              Positioned(
                bottom: -110,
                left: -120,
                child: _Glow(color: tokens.foxAccent, size: 260),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _ProgressDots(index: _index, tokens: tokens),
                        const Spacer(),
                        TextButton(
                          onPressed: _next,
                          child: Text(
                            _index == 2 ? 'Start' : 'Skip',
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: PageView(
                        controller: _controller,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (value) =>
                            setState(() => _index = value),
                        children: [
                          _WelcomeStep(tokens: tokens),
                          _GoalStep(
                            tokens: tokens,
                            selected: _goal,
                            goals: _goals,
                            onSelected: (value) =>
                                setState(() => _goal = value),
                          ),
                          _LevelStep(
                            tokens: tokens,
                            selected: _level,
                            levels: _levels,
                            onSelected: (value) =>
                                setState(() => _level = value),
                          ),
                        ],
                      ),
                    ),
                    _PrimaryButton(
                      tokens: tokens,
                      label: _index == 2 ? 'Continue to Speakery' : 'Continue',
                      onTap: _next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final SpeakeryThemeTokens tokens;

  const _WelcomeStep({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tokens: tokens,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: tokens.brandGradient,
              boxShadow: [
                BoxShadow(
                  color: tokens.primaryAccent.withAlpha(55),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Welcome to Speakery',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 30,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Build English across grammar, reading, vocabulary, speaking, writing, and community practice.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String selected;
  final List<_Choice> goals;
  final ValueChanged<String> onSelected;

  const _GoalStep({
    required this.tokens,
    required this.selected,
    required this.goals,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            tokens: tokens,
            title: 'Choose your learning goal',
            subtitle: 'We will shape the first path around this.',
          ),
          const SizedBox(height: 18),
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChoiceTile(
                tokens: tokens,
                label: goal.label,
                icon: goal.icon,
                selected: selected == goal.label,
                onTap: () => onSelected(goal.label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelStep extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String selected;
  final List<String> levels;
  final ValueChanged<String> onSelected;

  const _LevelStep({
    required this.tokens,
    required this.selected,
    required this.levels,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepTitle(
            tokens: tokens,
            title: 'Pick your English level',
            subtitle: 'Start light. You can change this later.',
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: levels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final level = levels[index];
              return _LevelTile(
                tokens: tokens,
                level: level,
                selected: selected == level,
                onTap: () => onSelected(level),
              );
            },
          ),
          const Spacer(),
          _SummaryStrip(tokens: tokens, level: selected),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String title;
  final String subtitle;

  const _StepTitle({
    required this.tokens,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: tokens.textSecondary,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.tokens,
    required this.label,
    required this.icon,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: selected
              ? tokens.primaryAccent.withAlpha(26)
              : tokens.chipSurface,
          border: Border.all(
            color:
                selected ? tokens.primaryAccent.withAlpha(90) : tokens.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? tokens.primaryAccent : tokens.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? tokens.primaryAccent : tokens.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String level;
  final bool selected;
  final VoidCallback onTap;

  const _LevelTile({
    required this.tokens,
    required this.level,
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
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: selected ? tokens.brandGradient : null,
          color: selected ? null : tokens.chipSurface,
          border: Border.all(
            color: selected ? Colors.transparent : tokens.border,
          ),
        ),
        child: Text(
          level,
          style: TextStyle(
            color: selected ? Colors.white : tokens.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String level;

  const _SummaryStrip({required this.tokens, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: tokens.primaryAccent.withAlpha(tokens.isLight ? 18 : 24),
        border: Border.all(color: tokens.primaryAccent.withAlpha(48)),
      ),
      child: Row(
        children: [
          Icon(Icons.route_rounded, color: tokens.primaryAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$level path ready. Your first lesson waits on Learn.',
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

class _ProgressDots extends StatelessWidget {
  final int index;
  final SpeakeryThemeTokens tokens;

  const _ProgressDots({required this.index, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 6),
          width: index == i ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: index == i ? tokens.primaryAccent : tokens.border,
          ),
        );
      }),
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

class _GlassPanel extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final Widget child;

  const _GlassPanel({
    required this.tokens,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
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

class _Choice {
  final String label;
  final IconData icon;

  const _Choice(this.label, this.icon);
}
