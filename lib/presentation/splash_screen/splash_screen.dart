import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;

  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _fade = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );

    _scale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutBack,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _introController.forward();

    Future.delayed(const Duration(milliseconds: 2600), _goNext);
  }

  void _goNext() {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      user != null ? '/home-screen' : '/onboarding',
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            top: -80,
            left: -90,
            child: _glowOrb(
              size: 260,
              color: const Color(0xFF3B82F6),
              opacity: 0.25,
            ),
          ),
          Positioned(
            bottom: -90,
            right: -80,
            child: _glowOrb(
              size: 300,
              color: const Color(0xFFEC4899),
              opacity: 0.22,
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: ScaleTransition(
                  scale: _scale,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseController,
                      _dotsController,
                    ]),
                    builder: (context, child) {
                      final pulse = 1 +
                          (sin(_pulseController.value * 2 * pi) * 0.035);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: pulse,
                            child: _logo(),
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'Speakery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Speak. Connect. Grow.',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _loadingDots(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 154,
      height: 154,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(120),
            blurRadius: 52,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFF38BDF8).withAlpha(70),
            blurRadius: 70,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _loadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final phase = (_dotsController.value + index * 0.22) % 1.0;
        final opacity = 0.35 + (sin(phase * 2 * pi) + 1) * 0.325;
        final scale = 0.75 + (sin(phase * 2 * pi) + 1) * 0.15;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((opacity * 255).toInt()),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }

  Widget _glowOrb({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha((opacity * 255).toInt()),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}