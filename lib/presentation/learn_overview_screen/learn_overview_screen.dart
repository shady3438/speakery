import 'package:flutter/material.dart';

import '../../data/app_progress.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';
import 'package:speakery/presentation/reading_screen/reading_home_screen.dart';
import '../listening_screen/listening_practice_screen.dart';
import '../premium_screen/premium_screen.dart';
import '../speaking_screen/speaking_screen.dart';
import '../vocabulary_screen/vocabulary_screen.dart';
import '../writing_screen/writing_practice_screen.dart';
import '../grammar_skill_screen/grammar_skill_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS  (kept identical — no navigation changes)
// ─────────────────────────────────────────────────────────────────────────────

class LearningUnit {
  final String title;
  final List<String> lessons;
  const LearningUnit(this.title, this.lessons);
}

class LearningModule {
  final String title;
  final String type;
  final IconData icon;
  final Color color1;
  final Color color2;
  final List<LearningUnit> units;
  final bool premium;

  const LearningModule({
    required this.title,
    required this.type,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.units,
    this.premium = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CEFR PALETTE  — single source of truth for level colours
// ─────────────────────────────────────────────────────────────────────────────

class _CEFRPalette {
  final Color start;
  final Color end;
  const _CEFRPalette(this.start, this.end);
}

const _cefrColors = {
  'A1': _CEFRPalette(Color(0xFF00C2FF), Color(0xFF2563EB)),
  'A2': _CEFRPalette(Color(0xFF22C55E), Color(0xFF14B8A6)),
  'B1': _CEFRPalette(Color(0xFFF59E0B), Color(0xFFD97706)),
  'B2': _CEFRPalette(Color(0xFFFF5B8A), Color(0xFFFF2E93)),
  'C1': _CEFRPalette(Color(0xFF8B5CF6), Color(0xFFA855F7)),
  'C2': _CEFRPalette(Color(0xFFFF8A00), Color(0xFFFF4FD8)),
};

_CEFRPalette _cefrPalette(String level) =>
    _cefrColors[level] ??
    const _CEFRPalette(Color(0xFF00C2FF), Color(0xFF2563EB));

// ─────────────────────────────────────────────────────────────────────────────
// LEARN OVERVIEW SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class LearnOverviewScreen extends StatefulWidget {
  const LearnOverviewScreen({super.key});

  @override
  State<LearnOverviewScreen> createState() => _LearnOverviewScreenState();
}

class _LearnOverviewScreenState extends State<LearnOverviewScreen>
    with TickerProviderStateMixin {
  // ── state ──
  bool _isEnglish = AppProgress.instance.isEnglish;
  int _selectedLevelIndex = 0;
  String _searchQuery = '';
  String _skillFilter = 'all';

  // ── animation ──
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  // ── constants ──
  static const _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const _skillOrder = [
    'grammar',
    'reading',
    'vocabulary',
    'writing',
    'listening',
    'speaking',
  ];

  String get _selectedLevel => _levels[_selectedLevelIndex];
  bool get _isEnglish_ => _isEnglish;
  String t(String en, String tr) => _isEnglish_ ? en : tr;

  // ── module definitions ──
  late final List<LearningModule> _modules = [
    const LearningModule(
      title: 'Grammar',
      type: 'grammar',
      icon: Icons.auto_stories_rounded,
      color1: Color(0xFF00C2FF),
      color2: Color(0xFF6366F1),
      units: [
        LearningUnit('CEFR Grammar Roadmap (A1–C2)', [
          'am / is / are',
          'articles',
          'have got / has got',
          'there is / there are',
          'can / can\'t',
          'present simple',
          'present continuous',
          'adverbs of frequency',
          'wh questions',
          'prepositions',
          'some any',
          'countable nouns',
          'object pronouns',
        ]),
      ],
    ),
    const LearningModule(
      title: 'Reading',
      type: 'reading',
      icon: Icons.menu_book_rounded,
      color1: Color(0xFF00C2FF),
      color2: Color(0xFF8B5CF6),
      units: [
        LearningUnit('Reading Library', [
          'a1 short personal text',
          'a1 simple email',
          'daily routine reading',
          'family reading',
          'cafe reading',
          'school reading',
        ]),
      ],
    ),
    const LearningModule(
      title: 'Vocabulary',
      type: 'vocabulary',
      icon: Icons.translate_rounded,
      color1: Color(0xFF8B5CF6),
      color2: Color(0xFF06B6D4),
      units: [
        LearningUnit('Vocabulary Library', [
          'smart flashcards',
          'saved words',
          'review quiz',
          'challenge modes',
        ]),
      ],
    ),
    const LearningModule(
      title: 'Writing',
      type: 'writing',
      icon: Icons.edit_note_rounded,
      color1: Color(0xFF22C55E),
      color2: Color(0xFF0EA5E9),
      units: [
        LearningUnit('A1 Writing', [
          'personal profile writing',
          'simple email writing',
          'daily routine paragraph',
          'family paragraph',
        ]),
      ],
    ),
    const LearningModule(
      title: 'Listening',
      type: 'listening',
      icon: Icons.headphones_rounded,
      color1: Color(0xFFEC4899),
      color2: Color(0xFF8B5CF6),
      units: [
        LearningUnit('Listening Roadmap', [
          'daily conversations',
          'short audio checks',
          'dictation practice',
        ]),
      ],
    ),
    const LearningModule(
      title: 'Speaking',
      type: 'speaking',
      icon: Icons.record_voice_over_rounded,
      color1: Color(0xFF00C2FF),
      color2: Color(0xFFFF4FD8),
      units: [
        LearningUnit('A1 Speaking', [
          'introducing yourself',
          'talking about family',
          'daily routine speaking',
          'ordering food',
        ]),
      ],
    ),
  ];

  List<LearningModule> get _orderedModules {
    return [..._modules]..sort((a, b) {
        final ai = _skillOrder.indexOf(a.type);
        final bi = _skillOrder.indexOf(b.type);
        return (ai == -1 ? 99 : ai).compareTo(bi == -1 ? 99 : bi);
      });
  }

  List<LearningModule> get _visibleModules {
    final query = _searchQuery.trim().toLowerCase();
    return _orderedModules.where((module) {
      if (!_matchesSkillFilter(module)) return false;
      if (query.isEmpty) return true;
      return _moduleSearchText(module).contains(query);
    }).toList(growable: false);
  }

  bool _matchesSkillFilter(LearningModule module) {
    switch (_skillFilter) {
      case 'study':
        return module.type == 'grammar' ||
            module.type == 'reading' ||
            module.type == 'vocabulary';
      case 'practice':
        return module.type == 'writing' ||
            module.type == 'listening' ||
            module.type == 'speaking';
      default:
        return true;
    }
  }

  String _moduleSearchText(LearningModule module) {
    final parts = <String>[module.title, module.type];
    for (final unit in module.units) {
      parts.add(unit.title);
      parts.addAll(unit.lessons);
    }
    return parts.join(' ').toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    AppProgress.instance.addListener(_syncLanguage);
    AppProgress.instance.loadProgress().then((_) => _syncLanguage());
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryFade =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();
  }

  void _syncLanguage() {
    if (!mounted) return;
    final next = AppProgress.instance.isEnglish;
    if (_isEnglish == next) return;
    setState(() => _isEnglish = next);
  }

  @override
  void dispose() {
    AppProgress.instance.removeListener(_syncLanguage);
    _entryCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        color: tokens.background,
        child: IosDynamicGlassBackdrop(
          primary: _cefrPalette(_selectedLevel).start,
          secondary: _cefrPalette(_selectedLevel).end,
          child: SafeArea(
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 12),
                    _buildHeroCard(),
                    const SizedBox(height: 14),
                    _buildLevelSelector(),
                    const SizedBox(height: 20),
                    _buildSectionLabel(
                      t('Skills', 'Beceriler'),
                      t('6 modules', '6 modül'),
                    ),
                    if (_searchQuery.isNotEmpty || _skillFilter != 'all') ...[
                      const SizedBox(height: 10),
                      _buildActiveFilters(),
                    ],
                    const SizedBox(height: 12),
                    _buildModuleGrid(),
                    const SizedBox(height: 20),
                    _buildExamPanel(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TOP BAR
  // ─────────────────────────────────────────────

  Widget _buildTopBar() {
    final pal = _cefrPalette(_selectedLevel);
    final tokens = SpeakeryThemeTokens.of(context);

    return _SolidCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      color: Colors.white.withAlpha(10),
      border: pal.start.withAlpha(32),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [pal.start, pal.end],
              ),
              boxShadow: [
                BoxShadow(
                  color: pal.start.withAlpha(52),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: Column(
                key: ValueKey('learn_header_${_selectedLevel}_$_isEnglish'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t('Learn', 'Öğren'),
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: pal.start.withAlpha(14),
                          border: Border.all(color: pal.start.withAlpha(34)),
                        ),
                        child: Text(
                          _selectedLevel,
                          style: TextStyle(
                            color: pal.start.withAlpha(235),
                            fontSize: 9.8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t(
                      'Pick a skill · Continue from your level',
                      'Bir beceri seç · Seviyenden devam et',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _TopActionButton(
            icon: Icons.search_rounded,
            active: _searchQuery.isNotEmpty,
            onTap: _showSearchSheet,
          ),
          const SizedBox(width: 8),
          _TopActionButton(
            icon: Icons.tune_rounded,
            active: _skillFilter != 'all',
            onTap: _showFilterSheet,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HERO CARD  — animated XP / stats
  // ─────────────────────────────────────────────

  Widget _buildHeroCard() {
    return AnimatedBuilder(
      animation: AppProgress.instance,
      builder: (context, _) {
        final p = AppProgress.instance;
        final pal = _cefrPalette(_selectedLevel);
        final tokens = SpeakeryThemeTokens.of(context);

        return _SolidCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          color: Colors.white.withAlpha(8),
          border: pal.start.withAlpha(28),
          child: Stack(
            children: [
              Positioned(
                right: -36,
                top: -42,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        pal.start.withAlpha(34),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [pal.start, pal.end],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: pal.start.withAlpha(48),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('Your Learning Path', 'Öğrenme Yolun'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: tokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.35,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Lv. ${p.level} · ${p.rankTitle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: tokens.textSecondary,
                                fontSize: 11.6,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MiniTag(
                        icon: Icons.local_fire_department_rounded,
                        label: '${p.streak}',
                        color: const Color(0xFFFF8A00),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      Expanded(
                        child: _AnimatedProgressBar(
                          value: p.levelProgress,
                          start: pal.start,
                          end: pal.end,
                          height: 7,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${p.xpInCurrentLevel}/100 XP',
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _CompactStatChip(
                        icon: Icons.stars_rounded,
                        label: '${p.xp} XP',
                        color: const Color(0xFF8B5CF6),
                      ),
                      _CompactStatChip(
                        icon: Icons.done_all_rounded,
                        label: '${p.completedCount} ${t('done', 'biten')}',
                        color: const Color(0xFF22C55E),
                      ),
                      _CompactStatChip(
                        icon: Icons.workspace_premium_rounded,
                        label: p.isPremium ? 'PRO' : 'Free',
                        color: const Color(0xFFFF8A00),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // LEVEL SELECTOR
  // ─────────────────────────────────────────────

  Widget _buildLevelSelector() {
    final pal = _cefrPalette(_selectedLevel);
    return IosLiquidPillSelector(
      items: _levels.map(IosPillItem.new).toList(growable: false),
      selectedIndex: _selectedLevelIndex,
      startColor: pal.start,
      endColor: pal.end,
      onChanged: (index) {
        if (index == _selectedLevelIndex) return;
        setState(() => _selectedLevelIndex = index);
      },
    );
  }

  // ─────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────

  Widget _buildSectionLabel(String title, String trailing) {
    final pal = _cefrPalette(_selectedLevel);
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: pal.start.withAlpha(13),
            border: Border.all(color: pal.start.withAlpha(36)),
          ),
          child: Text(
            trailing,
            style: TextStyle(
              color: pal.start.withAlpha(235),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    final pal = _cefrPalette(_selectedLevel);
    final tokens = SpeakeryThemeTokens.of(context);
    final parts = <String>[];
    if (_searchQuery.trim().isNotEmpty) {
      parts.add('"${_searchQuery.trim()}"');
    }
    if (_skillFilter != 'all') {
      parts.add(_filterLabel(_skillFilter));
    }

    return _SolidCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white.withAlpha(8),
      border: pal.start.withAlpha(24),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded, color: pal.start, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.join(' - '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _searchQuery = '';
              _skillFilter = 'all';
            }),
            child: Icon(Icons.close_rounded, color: tokens.iconSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyModules() {
    final tokens = SpeakeryThemeTokens.of(context);
    final pal = _cefrPalette(_selectedLevel);
    return _SolidCard(
      radius: 26,
      padding: const EdgeInsets.all(18),
      color: Colors.white.withAlpha(8),
      border: pal.start.withAlpha(26),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: pal.start, size: 30),
          const SizedBox(height: 10),
          Text(
            t('No matching modules', 'Eslesen modul yok'),
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            t('Try another word or clear the filter.',
                'Baska bir kelime dene veya filtreyi temizle.'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(String value) {
    switch (value) {
      case 'study':
        return t('Study skills', 'Çalışma becerileri');
      case 'practice':
        return t('Practice skills', 'Pratik becerileri');
      default:
        return t('All skills', 'Tüm beceriler');
    }
  }

  // ─────────────────────────────────────────────
  // MODULE GRID  — 2-column
  // ─────────────────────────────────────────────

  Widget _buildModuleGrid() {
    final mods = _visibleModules;
    if (mods.isEmpty) {
      return _buildEmptyModules();
    }

    // Build rows of 2
    final rows = <Widget>[];
    for (var i = 0; i < mods.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              child: _ModuleCard(
                module: mods[i],
                selectedLevel: _selectedLevel,
                isEnglish: _isEnglish,
                onTap: () => _openSkill(mods[i]),
              ),
            ),
            const SizedBox(width: 10),
            if (i + 1 < mods.length)
              Expanded(
                child: _ModuleCard(
                  module: mods[i + 1],
                  selectedLevel: _selectedLevel,
                  isEnglish: _isEnglish,
                  onTap: () => _openSkill(mods[i + 1]),
                ),
              )
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
      if (i + 2 < mods.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  // ─────────────────────────────────────────────
  // EXAM PANEL
  // ─────────────────────────────────────────────

  Widget _buildExamPanel() {
    final tokens = SpeakeryThemeTokens.of(context);
    return _SolidCard(
      radius: 28,
      padding: const EdgeInsets.all(18),
      color: Colors.white.withAlpha(8),
      border: const Color(0xFFFF8A00).withAlpha(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFFF8A00).withAlpha(24),
                  border: Border.all(
                    color: const Color(0xFFFF8A00).withAlpha(55),
                  ),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFFFF8A00),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('Exam Prep', 'Sınav Hazırlık'),
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      t('YKS Dil, IELTS & TOEFL packs',
                          'YKS Dil, IELTS & TOEFL paketleri'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFFFF8A00).withAlpha(18),
                  border: Border.all(
                    color: const Color(0xFFFF8A00).withAlpha(45),
                  ),
                ),
                child: Text(
                  t('Plan', 'Plan'),
                  style: const TextStyle(
                    color: Color(0xFFFF8A00),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ExamBtn(label: 'YKS Dil', onTap: () => _showExamPack('YKS Dil')),
              const SizedBox(width: 8),
              _ExamBtn(label: 'IELTS', onTap: () => _showExamPack('IELTS')),
              const SizedBox(width: 8),
              _ExamBtn(label: 'TOEFL', onTap: () => _showExamPack('TOEFL')),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NAVIGATION  — unchanged from original
  // ─────────────────────────────────────────────

  Future<void> _showSearchSheet() async {
    final controller = TextEditingController(text: _searchQuery);
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: SpeakeryThemeTokens.of(context).background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final tokens = SpeakeryThemeTokens.of(context);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            16,
            18,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: tokens.border,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                t('Search lessons', 'Ders ara'),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => Navigator.pop(context, value),
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  hintText: 'grammar, email, speaking...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: tokens.inputSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: tokens.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SheetAction(
                label: t('Apply search', 'Aramayi uygula'),
                onTap: () => Navigator.pop(context, controller.text),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
    if (result == null) return;
    setState(() => _searchQuery = result.trim());
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: SpeakeryThemeTokens.of(context).background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final tokens = SpeakeryThemeTokens.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: tokens.border,
                ),
              ),
              const SizedBox(height: 16),
              for (final value in const ['all', 'study', 'practice'])
                _FilterOption(
                  label: _filterLabel(value),
                  selected: _skillFilter == value,
                  onTap: () => Navigator.pop(context, value),
                ),
            ],
          ),
        );
      },
    );

    if (result == null) return;
    setState(() => _skillFilter = result);
  }

  void _openSkill(LearningModule module) {
    if (module.type == 'vocabulary') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpeakeryThemeAdapter(
            child: VocabularyScreen(
              initialLevel: _selectedLevel,
              isEnglish: _isEnglish,
            ),
          ),
        ),
      );
      return;
    }

    if (module.type == 'grammar') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpeakeryThemeAdapter(
            child: GrammarSkillScreen(
              initialLevel: _selectedLevel,
              isEnglish: _isEnglish,
            ),
          ),
        ),
      );
      return;
    }

    if (module.type == 'reading') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpeakeryThemeAdapter(
            child: ReadingHomeScreen(
              initialLevel: _selectedLevel,
              isEnglish: _isEnglish,
            ),
          ),
        ),
      );
      return;
    }

    if (module.type == 'speaking') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SpeakeryThemeAdapter(child: SpeakingScreen()),
        ),
      );
      return;
    }

    if (module.type == 'writing') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const SpeakeryThemeAdapter(child: WritingPracticeScreen()),
        ),
      );
      return;
    }

    if (module.type == 'listening') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const SpeakeryThemeAdapter(child: ListeningPracticeScreen()),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: SkillLevelScreen(
            module: module,
            levels: _levels,
            isEnglish: _isEnglish,
            openModule: _openModuleAtLevel,
          ),
        ),
      ),
    );
  }

  void _openModuleAtLevel(LearningModule module, String level) {
    if (module.type == 'writing') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const SpeakeryThemeAdapter(child: WritingPracticeScreen()),
        ),
      );
      return;
    }
    if (module.type == 'listening') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const SpeakeryThemeAdapter(child: ListeningPracticeScreen()),
        ),
      );
      return;
    }
    if (module.premium && !AppProgress.instance.isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SpeakeryThemeAdapter(child: PremiumScreen()),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: ModuleDetailScreen(
            module: module,
            isEnglish: _isEnglish,
          ),
        ),
      ),
    );
  }

  void _showExamPack(String exam) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExamPackSheet(exam: exam, isEnglish: _isEnglish),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODULE CARD  — 2-col grid card
// ─────────────────────────────────────────────────────────────────────────────

class _ExamPackSheet extends StatelessWidget {
  final String exam;
  final bool isEnglish;

  const _ExamPackSheet({required this.exam, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  List<String> get _steps {
    return switch (exam) {
      'YKS Dil' => const [
          'High-frequency vocabulary sprint',
          'Grammar trap review',
          'Timed paragraph reading',
        ],
      'IELTS' => const [
          'Task 2 idea builder',
          'Speaking Part 2 cue-card rehearsal',
          'Skimming and matching practice',
        ],
      _ => const [
          'Academic vocabulary warm-up',
          'Integrated writing outline',
          'Lecture note-taking drill',
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: BoxDecoration(
          color: tokens.glassSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: tokens.border),
          boxShadow: [
            BoxShadow(
              color: tokens.shadow.withAlpha(tokens.isLight ? 28 : 85),
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFFF8A00).withAlpha(22),
                    border: Border.all(
                      color: const Color(0xFFFF8A00).withAlpha(52),
                    ),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFFFF8A00),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$exam ${t('Starter Plan', 'Başlangıç Planı')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t(
                          'A focused route using current Speakery tools.',
                          'Mevcut Speakery araçlarıyla odaklı rota.',
                        ),
                        style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _steps.length; i++)
              _ExamPlanRow(index: i + 1, text: _steps[i]),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ExamActionButton(
                    label: t('Writing drill', 'Yazma pratiği'),
                    icon: Icons.edit_note_rounded,
                    primary: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SpeakeryThemeAdapter(
                            child: WritingPracticeScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ExamActionButton(
                    label: t('Reading', 'Okuma'),
                    icon: Icons.menu_book_rounded,
                    primary: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SpeakeryThemeAdapter(
                            child: ReadingHomeScreen(isEnglish: isEnglish),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamPlanRow extends StatelessWidget {
  final int index;
  final String text;

  const _ExamPlanRow({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.primaryAccent.withAlpha(18),
              border: Border.all(color: tokens.primaryAccent.withAlpha(45)),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _ExamActionButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: primary ? tokens.brandGradient : null,
          color: primary ? null : tokens.chipSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primary ? Colors.white.withAlpha(35) : tokens.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primary ? Colors.white : tokens.primaryAccent,
              size: 18,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: primary ? Colors.white : tokens.textPrimary,
                  fontSize: 13,
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

class _TopActionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TopActionButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color:
              active ? tokens.primaryAccent.withAlpha(30) : tokens.chipSurface,
          border: Border.all(
            color: active ? tokens.primaryAccent.withAlpha(70) : tokens.border,
          ),
        ),
        child: Icon(
          icon,
          color: active ? tokens.primaryAccent : tokens.iconSecondary,
          size: 20,
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SheetAction({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: tokens.brandGradient,
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

class _FilterOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected
              ? tokens.primaryAccent.withAlpha(24)
              : tokens.chipSurface,
          border: Border.all(
            color:
                selected ? tokens.primaryAccent.withAlpha(70) : tokens.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? tokens.primaryAccent : tokens.iconSecondary,
              size: 19,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final LearningModule module;
  final String selectedLevel;
  final bool isEnglish;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.module,
    required this.selectedLevel,
    required this.isEnglish,
    required this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  bool get _available {
    return module.type == 'grammar' ||
        module.type == 'reading' ||
        module.type == 'vocabulary' ||
        module.type == 'writing' ||
        module.type == 'listening' ||
        module.type == 'speaking';
  }

  String _subtitle() {
    switch (module.type) {
      case 'grammar':
        return t('A1 – C2 rules', 'A1 – C2 kuralları');
      case 'reading':
        return t('Texts & comprehension', 'Metinler & anlama');
      case 'vocabulary':
        return t('Cards & flashcards', 'Kartlar & tekrarlar');
      case 'writing':
        return t('Tasks & feedback', 'Görevler & geri bildirim');
      case 'listening':
        return t('Audio exercises', 'Ses egzersizleri');
      case 'speaking':
        return t('Practice fluency with Voxa.', 'Voxa ile akıcılık pratiği.');
      default:
        return t('Practice', 'Pratik');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = module.premium && !_available;
    final active = _available;
    final levelPal = _cefrPalette(selectedLevel);
    final tokens = SpeakeryThemeTokens.of(context);

    return _TapScale(
      onTap: onTap,
      child: IosLiquidGlassSurface(
        radius: 24,
        padding: const EdgeInsets.all(14),
        accent: active ? levelPal.start : null,
        borderColor: active ? levelPal.start.withAlpha(42) : tokens.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: active
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [levelPal.start, levelPal.end],
                          )
                        : null,
                    color: active ? null : Colors.white.withAlpha(10),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: levelPal.start.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    locked ? Icons.lock_rounded : module.icon,
                    color: active ? Colors.white : tokens.iconSecondary,
                    size: 19,
                  ),
                ),
                const Spacer(),
                // Status badge
                if (active)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: levelPal.start,
                      boxShadow: [
                        BoxShadow(
                          color: levelPal.start.withAlpha(80),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: tokens.chipSurface,
                      border: Border.all(color: tokens.border),
                    ),
                    child: Text(
                      module.premium ? 'PRO' : t('Ready', 'Hazır'),
                      style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              module.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? tokens.textPrimary : tokens.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _subtitle(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 10.8,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXAM BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ExamBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExamBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Expanded(
      child: _TapScale(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: tokens.chipSurface,
            border: Border.all(color: tokens.border),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 10.8,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CompactStatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(12),
        border: Border.all(color: color.withAlpha(32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.5),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(190),
              fontSize: 10.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          Container(
            height: height,
            width: double.infinity,
            color: tokens.isLight
                ? tokens.border.withAlpha(120)
                : Colors.white.withAlpha(10),
          ),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [start, end]),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: start.withAlpha(70),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SolidCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color border;

  const _SolidCard({
    required this.child,
    required this.radius,
    required this.padding,
    required this.color,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final colorAlpha = (color.a * 255.0).round().clamp(0, 255).toInt();
    final borderAlpha = (border.a * 255.0).round().clamp(0, 255).toInt();
    final resolvedColor =
        tokens.isLight && colorAlpha < 40 ? tokens.glassSurface : color;
    final resolvedBorder =
        tokens.isLight && borderAlpha < 48 ? tokens.border : border;
    return IosLiquidGlassSurface(
      padding: padding,
      radius: radius,
      accent: border,
      borderColor: resolvedBorder,
      gradient: (resolvedColor.a * 255.0).round() >= 80
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                resolvedColor,
                Color.alphaBlend(border.withAlpha(14), resolvedColor),
              ],
            )
          : null,
      child: child,
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
        scale: _pressed ? 0.972 : 1.0,
        duration: const Duration(milliseconds: 210),
        curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKILL LEVEL SCREEN  — unchanged (kept for route compatibility)
// ─────────────────────────────────────────────────────────────────────────────

class SkillLevelScreen extends StatefulWidget {
  final LearningModule module;
  final List<String> levels;
  final bool isEnglish;
  final void Function(LearningModule module, String level) openModule;

  const SkillLevelScreen({
    super.key,
    required this.module,
    required this.levels,
    required this.isEnglish,
    required this.openModule,
  });

  @override
  State<SkillLevelScreen> createState() => _SkillLevelScreenState();
}

class _SkillLevelScreenState extends State<SkillLevelScreen> {
  int _selectedIndex = 0;

  String t(String en, String tr) => widget.isEnglish ? en : tr;
  String get _level => widget.levels[_selectedIndex];

  bool get _available => true;

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final pal = _cefrPalette(_level);
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.4, -0.9),
            radius: 1.3,
            colors: [
              pal.start.withAlpha(tokens.isLight ? 20 : 32),
              tokens.backgroundEnd,
              tokens.background,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            children: [
              // Header row
              Row(
                children: [
                  _TapScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: tokens.chipSurface,
                        border: Border.all(color: tokens.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: tokens.textPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SolidCard(
                      radius: 22,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      color: Colors.white.withAlpha(10),
                      border: Colors.white.withAlpha(16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: module.color1.withAlpha(20),
                              border: Border.all(
                                  color: module.color1.withAlpha(50)),
                            ),
                            child: Icon(module.icon,
                                color: module.color1, size: 19),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: tokens.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  t('Choose your level', 'Seviyeni seç'),
                                  style: TextStyle(
                                    color: tokens.textSecondary,
                                    fontSize: 11.5,
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
              ),
              const SizedBox(height: 16),

              // Hero panel
              _SolidCard(
                radius: 30,
                padding: const EdgeInsets.all(18),
                color: module.color1.withAlpha(12),
                border: module.color1.withAlpha(38),
                child: Stack(
                  children: [
                    Positioned(
                      right: -24,
                      bottom: -24,
                      child: Icon(
                        module.icon,
                        size: 110,
                        color: Colors.white.withAlpha(8),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_level ${module.title}',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _available
                              ? t(
                                  'Lessons, practice and quiz flow.',
                                  'Ders, pratik ve quiz akışı.',
                                )
                              : t(
                                  'Lessons, practice and quiz flow.',
                                  'Ders, pratik ve quiz akışı.',
                                ),
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 13,
                            height: 1.38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Level selector
                        _SkillLevelGrid(
                          levels: widget.levels,
                          selectedIndex: _selectedIndex,
                          onChanged: (i) => setState(() => _selectedIndex = i),
                        ),
                        const SizedBox(height: 16),

                        // Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PlainChip(
                              _available
                                  ? t('Ready', 'Hazır')
                                  : t('Ready', 'Hazır'),
                            ),
                            _PlainChip(t('Level path', 'Seviye yolu')),
                            const _PlainChip('Quiz'),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // CTA
                        _TapScale(
                          onTap: () => widget.openModule(module, _level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [pal.start, pal.end],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: pal.start.withAlpha(50),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _available
                                      ? Icons.play_arrow_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _available
                                        ? t(
                                            'Start $_level ${module.title}',
                                            '$_level ${module.title} Başla',
                                          )
                                        : t(
                                            'Start $_level ${module.title}',
                                            '$_level ${module.title} Başla',
                                          ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _SkillLevelGrid extends StatelessWidget {
  final List<String> levels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SkillLevelGrid({
    required this.levels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tokens.inputSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: List.generate(levels.length, (i) {
          final sel = i == selectedIndex;
          final pal = _cefrPalette(levels[i]);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == levels.length - 1 ? 0 : 3),
              child: _TapScale(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: sel
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [pal.start, pal.end],
                          )
                        : null,
                    color: sel ? null : Colors.transparent,
                    boxShadow: sel
                        ? [
                            BoxShadow(
                              color: pal.start.withAlpha(55),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    levels[i],
                    style: TextStyle(
                      color: sel ? Colors.white : tokens.textSecondary,
                      fontSize: 10.5,
                      fontWeight: sel ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PlainChip extends StatelessWidget {
  final String label;
  const _PlainChip(this.label);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tokens.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODULE DETAIL SCREEN  — unchanged, kept for route compatibility
// ─────────────────────────────────────────────────────────────────────────────

class ModuleDetailScreen extends StatelessWidget {
  final LearningModule module;
  final bool isEnglish;

  const ModuleDetailScreen({
    super.key,
    required this.module,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  String _lessonKey(String title) {
    return _normaliseLessonKey(title);
  }

  String _normaliseLessonKey(String value) {
    return value
        .toLowerCase()
        .replaceAll('\u2019', '')
        .replaceAll("'", '')
        .replaceAll('/', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: tokens.text,
        elevation: 0,
        title: Text(
          module.title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          ...module.units.map((unit) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.title,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(unit.lessons.length, (index) {
                    final lessonTitle = unit.lessons[index];
                    final lessonKey = _lessonKey(lessonTitle);
                    final previousKey =
                        index == 0 ? null : _lessonKey(unit.lessons[index - 1]);
                    final unlocked = index == 0 ||
                        AppProgress.instance.isLessonCompleted(previousKey!);
                    final completed =
                        AppProgress.instance.isLessonCompleted(lessonKey);

                    return GestureDetector(
                      onTap: () {
                        if (!unlocked) {
                          PremiumFeedback.show(
                            context,
                            message: t(
                              'Complete the previous lesson first.',
                              'Complete the previous lesson first.',
                            ),
                            icon: Icons.lock_rounded,
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpeakeryThemeAdapter(
                              child: LessonDetailScreen(
                                module: module,
                                lessonTitle: lessonTitle,
                                isEnglish: isEnglish,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: tokens.glassSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tokens.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              completed
                                  ? Icons.check_circle_rounded
                                  : unlocked
                                      ? module.icon
                                      : Icons.lock_rounded,
                              color: completed
                                  ? const Color(0xFF22C55E)
                                  : tokens.textPrimary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lessonTitle,
                                style: TextStyle(
                                  color: tokens.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: tokens.textMuted,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 18),
                ],
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LESSON DETAIL SCREEN
// Kept local to the overview because module cards open it directly from here.
// ─────────────────────────────────────────────────────────────────────────────

// ignore: must_be_immutable
class LessonDetailScreen extends StatefulWidget {
  final LearningModule module;
  final String lessonTitle;
  final bool isEnglish;

  const LessonDetailScreen({
    super.key,
    required this.module,
    required this.lessonTitle,
    required this.isEnglish,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: tokens.text,
        elevation: 0,
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Lesson: ${widget.lessonTitle}',
            textAlign: TextAlign.center,
            style: TextStyle(color: tokens.textSecondary, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
