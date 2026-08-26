import 'package:flutter/material.dart';

void showXP(BuildContext context, int amount) {
  final overlay = Overlay.of(context);

  final entry = OverlayEntry(
    builder: (context) => _XPWidget(amount: amount),
  );

  overlay.insert(entry);

  Future.delayed(const Duration(milliseconds: 1400), () {
    entry.remove();
  });
}

class _XPWidget extends StatefulWidget {
  final int amount;

  const _XPWidget({required this.amount});

  @override
  State<_XPWidget> createState() => _XPWidgetState();
}

class _XPWidgetState extends State<_XPWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _translate = Tween(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.translate(
                offset: Offset(0, -_translate.value),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF6366F1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '+${widget.amount} XP',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
