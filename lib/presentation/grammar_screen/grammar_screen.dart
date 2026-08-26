import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/speakery_theme_tokens.dart';

class GrammarScreen extends StatefulWidget {
  final String level;

  const GrammarScreen({super.key, required this.level});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _selectedFilter = 'All';

  static const Map<String, List<Map<String, dynamic>>> _lessonsByLevel = {
    'B1': [
      {
        'title': 'Present Perfect',
        'subtitle': 'have/has + past participle',
        'duration': '20 min',
        'xp': 80,
        'completed': true,
        'locked': false,
        'tag': 'Tenses',
      },
      {
        'title': 'Conditionals',
        'subtitle': 'If + present, will',
        'duration': '16 min',
        'xp': 75,
        'completed': false,
        'locked': false,
        'tag': 'Conditionals',
      },
    ],
  };

  static const List<String> _filters = [
    'All',
    'Tenses',
    'Conditionals',
  ];

  List<Map<String, dynamic>> get _lessons {
    final all = _lessonsByLevel[widget.level] ?? _lessonsByLevel['B1']!;
    if (_selectedFilter == 'All') return all;
    return all.where((l) => l['tag'] == _selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = _lessons;
    final levelColor = AppTheme.cefrLevelColor(widget.level);
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: Container(
        decoration: BoxDecoration(gradient: tokens.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _header(levelColor),
              _filtersRow(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final double delay =
                            (index * 0.07).clamp(0.0, 0.8).toDouble();

                        final double raw =
                            ((_animController.value - delay) / (1 - delay))
                                .clamp(0.0, 1.0)
                                .toDouble();

                        final double t = Curves.easeOutCubic.transform(raw);

                        return Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - t)),
                            child: child,
                          ),
                        );
                      },
                      child: _card(lessons[index], levelColor),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Color levelColor) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          ),
          Text(
            'Grammar ${widget.level}',
            style: TextStyle(
              color: levelColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtersRow() {
    final tokens = SpeakeryThemeTokens.of(context);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _filters[index];
          final selected = f == _selectedFilter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : tokens.chipSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primary : tokens.border,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: selected ? Colors.white : tokens.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(Map<String, dynamic> lesson, Color levelColor) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: tokens.isLight
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  levelColor.withAlpha(14),
                  tokens.elevatedSurface,
                  const Color(0xFFFBFCFF),
                ],
              )
            : LinearGradient(
                colors: [tokens.glassStrong, tokens.glassSurface],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tokens.isLight
              ? Color.alphaBlend(levelColor.withAlpha(36), tokens.border)
              : tokens.border,
        ),
        boxShadow: tokens.isLight
            ? [
                BoxShadow(
                  color: const Color(0xFF334155).withAlpha(18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(Icons.book, color: levelColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'],
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  lesson['subtitle'],
                  style: TextStyle(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: tokens.iconSecondary)
        ],
      ),
    );
  }
}
