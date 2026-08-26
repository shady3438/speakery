import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/speakery_theme_tokens.dart';
import 'ios_liquid_glass.dart';

class AppNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final bool compact;

  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    this.compact = false,
  });

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar>
    with SingleTickerProviderStateMixin {
  static const double _horizontalMargin = 20;
  static const double _normalHeight = 62;
  static const double _compactHeight = 54;
  double _dragDx = 0;
  late final AnimationController _liquidController;

  final List<_NavItem> _items = const [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.school_outlined, Icons.school_rounded, 'Learn'),
    _NavItem(Icons.people_outline_rounded, Icons.people_rounded, 'Social'),
    _NavItem(
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
      'Chat',
    ),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final tokens = SpeakeryThemeTokens.of(context);
    final isLight = tokens.isLight;
    final barHeight = widget.compact ? _compactHeight : _normalHeight;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: bottomInset > 0 ? 8 : 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / _items.length;
            final selectedLeft = itemWidth * widget.currentIndex;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (_) => _dragDx = 0,
              onHorizontalDragUpdate: (details) => _dragDx += details.delta.dx,
              onHorizontalDragEnd: _handleDragEnd,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: AnimatedContainer(
                    duration: IosLiquidMotion.settle,
                    curve: IosLiquidMotion.settleCurve,
                    height: barHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withAlpha(isLight ? 64 : 15),
                          Colors.white.withAlpha(isLight ? 26 : 5),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withAlpha(isLight ? 112 : 38),
                        width: .9,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.centerLeft,
                      children: [
                        AnimatedPositioned(
                          duration: IosLiquidMotion.expressive,
                          curve: IosLiquidMotion.selectedCurve,
                          left: selectedLeft + 5,
                          top: 6,
                          bottom: 6,
                          width: itemWidth - 10,
                          child: _ActiveLiquidPill(
                            key: const ValueKey<String>('app-nav-active-pill'),
                            tokens: tokens,
                            animation: _liquidController,
                          ),
                        ),
                        Row(
                          children: List.generate(_items.length, (index) {
                            final item = _items[index];
                            final isActive = index == widget.currentIndex;

                            return Expanded(
                              child: _NavTapTarget(
                                item: item,
                                isActive: isActive,
                                compact: widget.compact,
                                onTap: () => widget.onTabChanged(index),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final hasEnoughVelocity = velocity.abs() >= 260;
    final hasEnoughDistance = _dragDx.abs() >= 44;
    if (!hasEnoughVelocity && !hasEnoughDistance) return;

    final direction = hasEnoughDistance ? _dragDx : -velocity;
    final nextIndex = direction < 0
        ? (widget.currentIndex + 1).clamp(0, _items.length - 1)
        : (widget.currentIndex - 1).clamp(0, _items.length - 1);
    if (nextIndex != widget.currentIndex) {
      widget.onTabChanged(nextIndex);
    }
  }
}

class _ActiveLiquidPill extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final Animation<double> animation;

  const _ActiveLiquidPill({
    super.key,
    required this.tokens,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final phase = animation.value * math.pi * 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: tokens.isVoxaTheme
                        ? tokens.secondaryAccent.withAlpha(56)
                        : tokens.isLight
                            ? Colors.white
                            : Colors.white.withAlpha(72),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment(-1 + math.sin(phase) * .24, -1),
                    end: Alignment(1, 1 + math.cos(phase) * .24),
                    colors: tokens.isVoxaTheme
                        ? tokens.isVoxaDark
                            ? [
                                const Color(0xFF161036).withAlpha(225),
                                tokens.primaryAccent.withAlpha(122),
                                tokens.warmAccent.withAlpha(106),
                              ]
                            : [
                                Colors.white.withAlpha(205),
                                tokens.warmAccent.withAlpha(78),
                                tokens.primaryAccent.withAlpha(92),
                              ]
                        : [
                            Colors.white.withAlpha(tokens.isLight ? 82 : 20),
                            tokens.secondaryAccent
                                .withAlpha(tokens.isLight ? 27 : 31),
                            tokens.primaryAccent
                                .withAlpha(tokens.isLight ? 31 : 38),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(tokens.isLight ? 58 : 14),
                      blurRadius: 18,
                      offset: const Offset(0, -2),
                    ),
                    BoxShadow(
                      color: tokens.primaryAccent
                          .withAlpha(tokens.isLight ? 28 : 42),
                      blurRadius: 22,
                      spreadRadius: -3,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 9 + math.sin(phase) * 5,
                right: 9 - math.sin(phase) * 5,
                top: 2,
                child: Container(
                  height: 1.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withAlpha(tokens.isLight ? 190 : 72),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavTapTarget extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool compact;
  final VoidCallback onTap;

  const _NavTapTarget({
    required this.item,
    required this.isActive,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_NavTapTarget> createState() => _NavTapTargetState();
}

class _NavTapTargetState extends State<_NavTapTarget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final color = widget.isActive
        ? tokens.textPrimary
        : tokens.textSecondary.withAlpha(tokens.isLight ? 210 : 170);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed
            ? 0.92
            : widget.isActive
                ? 1.055
                : 1,
        duration: IosLiquidMotion.quick,
        curve: _pressed ? IosLiquidMotion.press : IosLiquidMotion.release,
        child: AnimatedContainer(
          duration: IosLiquidMotion.settle,
          curve: IosLiquidMotion.settleCurve,
          padding: EdgeInsets.symmetric(vertical: widget.compact ? 6 : 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.isActive ? widget.item.activeIcon : widget.item.icon,
                    color: color,
                    size: widget.isActive ? 24 : 22,
                  ),
                  if (tokens.isVoxaTheme && widget.isActive)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: tokens.primaryAccent,
                        size: 9,
                      ),
                    ),
                ],
              ),
              AnimatedSize(
                duration: IosLiquidMotion.settle,
                curve: IosLiquidMotion.settleCurve,
                child: widget.compact
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AnimatedDefaultTextStyle(
                          duration: IosLiquidMotion.quick,
                          curve: IosLiquidMotion.settleCurve,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: widget.isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                            height: 1,
                          ),
                          child: Text(
                            widget.item.label,
                            maxLines: 1,
                            textScaler: TextScaler.noScaling,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}
