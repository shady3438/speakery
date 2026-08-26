import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_progress.dart';
import '../../data/vocabulary_content.dart';
import '../../data/vocabulary/vocabulary_models.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';

class VocabularyChallengeScreen extends StatelessWidget {
  final String initialLevel;
  final bool isEnglish;

  const VocabularyChallengeScreen({
    super.key,
    this.initialLevel = 'A1',
    this.isEnglish = true,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final cleanedAll = allVocabularyItems
        .where(
          (item) =>
              item.word.trim().isNotEmpty && item.meaningTr.trim().isNotEmpty,
        )
        .toList(growable: false);
    final level = initialLevel.trim().isEmpty ? 'A1' : initialLevel.trim();
    final levelWords = cleanedAll
        .where((item) => item.level.toUpperCase() == level.toUpperCase())
        .toList(growable: false);
    final source = levelWords.length >= 4 ? levelWords : cleanedAll;

    if (source.length < 4) {
      return Scaffold(
        backgroundColor: SpeakeryThemeTokens.of(context).background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t('Not enough vocabulary for Challenge yet.',
                  'Challenge icin yeterli kelime yok.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SpeakeryThemeTokens.of(context).textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SpeakeryThemeTokens.of(context).background,
      body: IosDynamicGlassBackdrop(
        primary: const Color(0xFFFF8A00),
        secondary: const Color(0xFF8B5CF6),
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 28),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(12),
                          border: Border.all(color: Colors.white.withAlpha(18)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Arena', 'Arena'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            t('Choose a game type first.',
                                'Önce oyun türünü seç.'),
                            style: TextStyle(
                              color: Colors.white.withAlpha(178),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              InlineChallengeArenaSection(
                words: source,
                allWords: cleanedAll,
                selectedLevel: level,
                isEnglish: isEnglish,
                onOpenWord: (item) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) {
                      return _WordDetailSheet(
                        item: item,
                        isEnglish: isEnglish,
                        categoryLabel: item.category,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VocabularyScreen extends StatefulWidget {
  final String initialLevel;
  final bool isEnglish;

  const VocabularyScreen({
    super.key,
    this.initialLevel = 'A1',
    this.isEnglish = true,
  });

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late String selectedLevel;
  String selectedCategory = 'All';
  String searchText = '';
  String selectedMode = 'Cards';
  String selectedMainTab = 'Learn';

  int practiceIndex = 0;
  int pageIndex = 0;
  int focusedCardIndex = 0;
  int cardTransitionDirection = 1;
  bool showTeacherSide = false;
  bool showLearnTools = false;
  bool setReviewSheetOpen = false;
  final Map<String, int> _memoryPageByScope = {};
  final Map<String, int> _memoryCardByScope = {};
  static const int wordsPerPage = 6;

  static const String _lastLevelKey = 'speakery_vocab_last_level';
  static const String _lastModeKey = 'speakery_vocab_last_mode';
  static const String _lastCategoryKey = 'speakery_vocab_last_category';
  static const String _lastMainTabKey = 'speakery_vocab_last_main_tab';
  static const String _lastPagePrefix = 'speakery_vocab_last_page_';
  static const String _lastCardPrefix = 'speakery_vocab_last_card_';

  bool hasRestoredVocabularyPosition = false;

  final TextEditingController searchController = TextEditingController();

  bool get isEnglish => widget.isEnglish;

  String t(String en, String tr) => isEnglish ? en : tr;

  String get _progressScope {
    final level = selectedLevel.trim().isEmpty ? 'A1' : selectedLevel.trim();
    final mode = selectedMode.trim().isEmpty ? 'Cards' : selectedMode.trim();
    final category =
        selectedCategory.trim().isEmpty ? 'All' : selectedCategory.trim();
    return '${level}_${mode}_$category'
        .replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_');
  }

  Future<void> restoreVocabularyPosition() async {
    final prefs = await SharedPreferences.getInstance();

    final storedLevel = prefs.getString(_lastLevelKey);
    final storedMode = prefs.getString(_lastModeKey);
    final storedCategory = prefs.getString(_lastCategoryKey);
    final storedMainTab = prefs.getString(_lastMainTabKey);

    final nextLevel = (storedLevel == null || storedLevel.trim().isEmpty)
        ? selectedLevel
        : storedLevel.trim();
    final rawNextMode = (storedMode == null || storedMode.trim().isEmpty)
        ? selectedMode
        : storedMode.trim();
    final nextMode = rawNextMode == 'Saved Review' ? 'Saved' : rawNextMode;
    final nextCategory =
        (storedCategory == null || storedCategory.trim().isEmpty)
            ? selectedCategory
            : storedCategory.trim();
    final nextMainTab = (storedMainTab == null || storedMainTab.trim().isEmpty)
        ? selectedMainTab
        : storedMainTab.trim();

    final scope = '${nextLevel}_${nextMode}_$nextCategory'
        .replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_');
    final nextPage = prefs.getInt('$_lastPagePrefix$scope') ?? 0;
    final nextCard = prefs.getInt('$_lastCardPrefix$scope') ?? 0;

    if (!mounted) return;

    setState(() {
      selectedLevel = nextLevel;
      selectedMode = nextMode;
      selectedCategory = nextCategory;
      selectedMainTab = nextMainTab == 'Challenge' ? 'Learn' : nextMainTab;
      pageIndex = max(0, nextPage);
      focusedCardIndex = max(0, nextCard);
      showTeacherSide = false;
      hasRestoredVocabularyPosition = true;
    });
  }

  Future<void> saveVocabularyPosition() async {
    if (!hasRestoredVocabularyPosition) return;

    final prefs = await SharedPreferences.getInstance();
    final scope = _progressScope;

    await prefs.setString(_lastLevelKey, selectedLevel);
    await prefs.setString(_lastModeKey, selectedMode);
    await prefs.setString(_lastCategoryKey, selectedCategory);
    await prefs.setString(_lastMainTabKey, selectedMainTab);
    await prefs.setInt('$_lastPagePrefix$scope', max(0, pageIndex));
    await prefs.setInt('$_lastCardPrefix$scope', max(0, focusedCardIndex));
  }

  void saveVocabularyPositionSoon() {
    unawaited(saveVocabularyPosition());
  }

  bool get isSavedMode {
    return selectedMode == 'Saved' || selectedMode == 'Saved Review';
  }

  bool get isQuizMode {
    return selectedMode == 'Meaning Quiz' ||
        selectedMode == 'Word Quiz' ||
        selectedMode == 'Fill Blank' ||
        selectedMode == 'Collocation Match';
  }

  String normalizeSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .trim();
  }

  IconData categoryIcon(String category) {
    final c = normalizeSearch(category);

    if (c.contains('animal')) return Icons.pets_rounded;
    if (c.contains('food') || c.contains('drink')) {
      return Icons.restaurant_rounded;
    }
    if (c.contains('feeling') || c.contains('emotion')) {
      return Icons.favorite_rounded;
    }
    if (c.contains('body') || c.contains('health')) {
      return Icons.health_and_safety_rounded;
    }
    if (c.contains('city') || c.contains('public') || c.contains('place')) {
      return Icons.location_city_rounded;
    }
    if (c.contains('communication') || c.contains('classroom')) {
      return Icons.chat_bubble_rounded;
    }
    if (c.contains('clothes') || c.contains('appearance')) {
      return Icons.checkroom_rounded;
    }
    if (c.contains('home') || c.contains('house')) return Icons.home_rounded;
    if (c.contains('travel') || c.contains('transport')) {
      return Icons.flight_takeoff_rounded;
    }
    if (c.contains('calendar') || c.contains('month')) {
      return Icons.calendar_month_rounded;
    }
    if (c.contains('colors')) return Icons.palette_rounded;
    if (c.contains('school')) return Icons.school_rounded;
    if (c.contains('family') || c.contains('people')) {
      return Icons.groups_rounded;
    }
    if (c.contains('digital')) return Icons.phone_iphone_rounded;
    if (c.contains('verb') || c.contains('action')) {
      return Icons.directions_run_rounded;
    }
    if (c.contains('adjective') || c.contains('describing')) {
      return Icons.auto_awesome_rounded;
    }
    if (c.contains('collocation') ||
        c.contains('phrase') ||
        c.contains('expression') ||
        c.contains('idiom')) {
      return Icons.hub_rounded;
    }
    if (c.contains('opposite')) return Icons.compare_arrows_rounded;
    if (c.contains('connector')) return Icons.link_rounded;

    return Icons.category_rounded;
  }

  @override
  void initState() {
    super.initState();
    final clean = widget.initialLevel.toUpperCase().trim();
    selectedLevel = clean.isEmpty ? 'A1' : clean;
    unawaited(AppProgress.instance.loadProgress());
    unawaited(restoreVocabularyPosition());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<VocabularyItem> get levelWords {
    if (selectedLevel == 'All') return allVocabularyItems;
    return getVocabularyByLevel(selectedLevel);
  }

  Map<String, int> get savedCountByLevel {
    final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final counts = <String, int>{for (final level in levels) level: 0};

    for (final item in _deduplicateWords(allVocabularyItems)) {
      if (!AppProgress.instance.isVocabularySaved(item.id)) continue;
      final level = item.level.toUpperCase().trim();
      if (counts.containsKey(level)) {
        counts[level] = (counts[level] ?? 0) + 1;
      }
    }

    counts['All'] = counts.values.fold<int>(0, (sum, value) => sum + value);
    return counts;
  }

  String _baseCategory(String category) {
    return category
        .replaceAll(
            RegExp(r'^(A1|A2|B1|B2|C1|C2)\s+', caseSensitive: false), '')
        .replaceAll(
            RegExp(r'\s+(I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII|XIII|\d+)$',
                caseSensitive: false),
            '')
        .trim();
  }

  String categoryLabel(String category) {
    final base = _baseCategory(category).toLowerCase();

    if (base.contains('useful vocabulary')) {
      return t('Useful Vocabulary', 'Faydalı Kelimeler');
    }
    if (base.contains('advanced verb')) {
      return t('Advanced Verbs', 'İleri Seviye Fiiller');
    }
    if (base.contains('abstract noun')) {
      return t('Abstract Nouns', 'Soyut İsimler');
    }
    if (base.contains('precise adjective')) {
      return t('Precise Adjectives', 'Net Sıfatlar');
    }
    if (base.contains('strong collocation')) {
      return t('Strong Collocations', 'Güçlü Kalıplar');
    }
    if (base.contains('collocation')) return t('Collocations', 'Kalıplar');
    if (base.contains('natural expression')) {
      return t('Natural Expressions', 'Doğal İfadeler');
    }
    if (base.contains('professional phrase')) {
      return t('Professional Phrases', 'Profesyonel İfadeler');
    }
    if (base.contains('academic')) {
      return t('Academic Phrases', 'Akademik İfadeler');
    }
    if (base.contains('idiom')) return t('Idioms', 'Deyimler');
    if (base.contains('phrasal verb')) {
      return t('Phrasal Verbs', 'Phrasal Verbs');
    }
    if (base.contains('appearance')) return t('Appearance', 'Dış Görünüş');
    if (base.contains('people')) return t('People', 'İnsanlar');
    if (base.contains('family')) return t('Family', 'Aile');
    if (base.contains('transport')) return t('Transport', 'Ulaşım');
    if (base.contains('travel')) return t('Travel', 'Seyahat');
    if (base.contains('animals')) return t('Animals', 'Hayvanlar');
    if (base.contains('feelings')) return t('Feelings', 'Duygular');
    if (base.contains('food')) return t('Food & Drink', 'Yiyecek & İçecek');
    if (base.contains('weather')) return t('Weather', 'Hava Durumu');
    if (base.contains('colors')) return t('Colors', 'Renkler');
    if (base.contains('shopping')) return t('Shopping', 'Alışveriş');
    if (base.contains('school')) return t('School', 'Okul');
    if (base.contains('house')) return t('House', 'Ev');
    if (base.contains('body')) return t('Body', 'Vücut');
    if (base.contains('health')) return t('Health', 'Sağlık');
    if (base.contains('adverbs')) return t('Adverbs', 'Zarflar');
    if (base.contains('prepositions')) return t('Prepositions', 'Edatlar');

    if (category.trim().isEmpty) return t('Other', 'Diğer');
    return _baseCategory(category);
  }

  List<String> get categories {
    final unique =
        levelWords.map((item) => categoryLabel(item.category)).toSet().toList();
    unique.sort();
    return [t('All', 'Tümü'), ...unique];
  }

  bool get _isAllCategorySelected {
    return selectedCategory == 'All' || selectedCategory == t('All', 'Tümü');
  }

  List<VocabularyItem> _deduplicateWords(List<VocabularyItem> source) {
    final seen = <String>{};
    final result = <VocabularyItem>[];

    for (final item in source) {
      final key =
          '${item.level.toUpperCase().trim()}_${normalizeSearch(item.word)}';
      if (key.trim().isEmpty) continue;
      if (seen.add(key)) {
        result.add(item);
      }
    }

    return result;
  }

  List<VocabularyItem> get filteredWords {
    var words = _deduplicateWords(levelWords);

    if (!_isAllCategorySelected) {
      words = words
          .where((item) => categoryLabel(item.category) == selectedCategory)
          .toList();
    }

    final cleanSearch = normalizeSearch(searchText);

    if (cleanSearch.isNotEmpty) {
      words = words.where((item) {
        return normalizeSearch(item.word).contains(cleanSearch) ||
            normalizeSearch(item.meaningTr).contains(cleanSearch) ||
            normalizeSearch(item.definitionEn).contains(cleanSearch) ||
            normalizeSearch(item.category).contains(cleanSearch) ||
            normalizeSearch(categoryLabel(item.category))
                .contains(cleanSearch) ||
            normalizeSearch(item.partOfSpeech).contains(cleanSearch) ||
            item.synonyms.any(
                (synonym) => normalizeSearch(synonym).contains(cleanSearch)) ||
            item.collocations.any((collocation) =>
                normalizeSearch(collocation).contains(cleanSearch));
      }).toList();
    }

    if (selectedMode == 'Saved' || selectedMode == 'Saved Review') {
      words = words
          .where((item) => AppProgress.instance.isVocabularySaved(item.id))
          .toList();
    }

    return _deduplicateWords(words);
  }

  void changeLevel(String level) {
    final previousScope = _progressScope;
    _memoryPageByScope[previousScope] = pageIndex;
    _memoryCardByScope[previousScope] = focusedCardIndex;

    final nextCategory = t('All', 'Tümü');
    final nextScope = '${level}_${selectedMode}_$nextCategory'
        .replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_');
    final rememberedPage = _memoryPageByScope[nextScope];
    final rememberedCard = _memoryCardByScope[nextScope];

    setState(() {
      selectedLevel = level;
      selectedCategory = nextCategory;
      searchText = '';
      practiceIndex = 0;
      pageIndex = max(0, rememberedPage ?? pageIndex);
      focusedCardIndex = max(0, rememberedCard ?? focusedCardIndex);
      showTeacherSide = false;
      searchController.clear();
    });
    saveVocabularyPositionSoon();
  }

  void changeMode(String mode) {
    if (mode == 'Random 10') {
      openRandom10ArenaSheet(allVocabularyItems);
      return;
    }

    final previousScope = _progressScope;
    _memoryPageByScope[previousScope] = pageIndex;
    _memoryCardByScope[previousScope] = focusedCardIndex;

    final nextScope = '${selectedLevel}_${mode}_$selectedCategory'
        .replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_');
    final rememberedPage = _memoryPageByScope[nextScope];
    final rememberedCard = _memoryCardByScope[nextScope];

    setState(() {
      selectedMode = mode;
      practiceIndex = 0;
      pageIndex = max(0, rememberedPage ?? 0);
      focusedCardIndex = max(0, rememberedCard ?? 0);
      showTeacherSide = false;
    });
    saveVocabularyPositionSoon();
  }

  void showWordSheet(VocabularyItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _WordDetailSheet(
          item: item,
          isEnglish: isEnglish,
          categoryLabel: categoryLabel(item.category),
        );
      },
    );
  }

  Future<void> openRandom10ArenaSheet(List<VocabularyItem> currentWords) async {
    final cleanedAll = allVocabularyItems
        .where((item) =>
            item.word.trim().isNotEmpty && item.meaningTr.trim().isNotEmpty)
        .toList();

    final cleanedCurrent = currentWords
        .where((item) =>
            item.word.trim().isNotEmpty && item.meaningTr.trim().isNotEmpty)
        .toList();

    final source = cleanedCurrent.length >= 4 ? cleanedCurrent : cleanedAll;

    if (source.length < 4) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('Not enough vocabulary for Challenge yet.',
              'Challenge icin yeterli kelime yok.')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SpeakeryThemeAdapter(
          child: _ChallengeArenaScreen(
            words: source,
            allWords: cleanedAll.isEmpty ? source : cleanedAll,
            isEnglish: isEnglish,
            onOpenWord: showWordSheet,
          ),
        ),
      ),
    );

    if (!mounted) return;
    setState(() {});
    saveVocabularyPositionSoon();
  }

  void resetSetQuizState() {}

  List<_SetQuizQuestion> buildSetReviewQuestions(
      List<VocabularyItem> setWords) {
    final usable = setWords
        .where((item) =>
            item.word.trim().isNotEmpty && item.meaningTr.trim().isNotEmpty)
        .toList();

    if (usable.isEmpty) return [];

    final allMeanings = usable
        .map((item) => item.meaningTr.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    final allWords = usable
        .map((item) => item.word.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    String fallbackMeaning(int i) {
      final values = [
        isEnglish ? 'different meaning' : 'farklı anlam',
        isEnglish ? 'wrong meaning' : 'yanlış anlam',
        isEnglish ? 'not this word' : 'bu kelime değil',
        isEnglish ? 'another option' : 'başka seçenek',
      ];
      return values[i % values.length];
    }

    String fallbackWord(int i) {
      final values = ['option', 'example', 'practice', 'answer'];
      return values[i % values.length];
    }

    return usable.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final useMeaning = index.isEven;

      final correct = useMeaning ? item.meaningTr.trim() : item.word.trim();
      final pool = useMeaning ? allMeanings : allWords;
      final options = <String>{correct};

      for (final option in pool) {
        if (options.length >= 4) break;
        if (option.trim().isNotEmpty && option != correct) {
          options.add(option);
        }
      }

      var guard = 0;
      while (options.length < 4 && guard < 12) {
        options.add(useMeaning ? fallbackMeaning(guard) : fallbackWord(guard));
        guard++;
      }

      final optionList = options.take(4).toList()..shuffle();

      return _SetQuizQuestion(
        item: item,
        type: useMeaning ? 'meaning' : 'word',
        prompt: useMeaning ? item.word : item.meaningTr,
        correctAnswer: correct,
        options: optionList,
      );
    }).toList();
  }

  Future<void> openSetReviewSheet({
    required List<VocabularyItem> setWords,
    required int safePageIndex,
    required int totalPages,
  }) async {
    if (setReviewSheetOpen) return;

    setReviewSheetOpen = true;

    final questions = buildSetReviewQuestions(setWords);
    final lastCardInThisSet =
        max(0, min(wordsPerPage - 1, setWords.length - 1));

    if (questions.isEmpty) {
      if (!mounted) return;
      setState(() {
        setReviewSheetOpen = false;
        if (safePageIndex < totalPages - 1) {
          pageIndex = safePageIndex + 1;
          focusedCardIndex = 0;
        } else {
          pageIndex = safePageIndex;
          focusedCardIndex = lastCardInThisSet;
        }
        showTeacherSide = false;
      });
      saveVocabularyPositionSoon();
      return;
    }

    if (mounted) {
      setState(() {
        showTeacherSide = false;
      });
    }

    final shouldGoNext = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (_) {
        return _SetReviewSheet(
          questions: questions,
          setNumber: safePageIndex + 1,
          totalSets: totalPages,
          isEnglish: isEnglish,
        );
      },
    );

    if (!mounted) return;

    setState(() {
      setReviewSheetOpen = false;
      if (shouldGoNext == true && safePageIndex < totalPages - 1) {
        pageIndex = safePageIndex + 1;
        focusedCardIndex = 0;
      } else {
        pageIndex = safePageIndex;
        focusedCardIndex = shouldGoNext == true ? 0 : lastCardInThisSet;
      }
      showTeacherSide = false;
    });

    saveVocabularyPositionSoon();
  }

  Widget _buildLearningArea(List<VocabularyItem> words) {
    if (isQuizMode) {
      final quizWords = words.isNotEmpty ? words : allVocabularyItems;

      return _VocabularyQuizPanel(
        key: ValueKey(
            '$selectedMode-$selectedLevel-$selectedCategory-$searchText-${quizWords.length}'),
        mode: selectedMode,
        words: quizWords,
        allWords: allVocabularyItems,
        isEnglish: isEnglish,
        onOpenWord: showWordSheet,
      );
    }

    if (words.isEmpty) {
      return _EmptyState(
        isEnglish: isEnglish,
        icon:
            isSavedMode ? Icons.bookmark_add_rounded : Icons.search_off_rounded,
        title: isSavedMode
            ? t('No saved words yet', 'Henüz kayıtlı kelimen yok')
            : null,
        subtitle: isSavedMode
            ? t('Tap the bookmark on any word card to collect it here.',
                'Bir kelime kartındaki kaydet ikonuna basınca burada görünür.')
            : null,
      );
    }

    final totalPages =
        words.isEmpty ? 1 : ((words.length - 1) ~/ wordsPerPage) + 1;
    final maxAbsoluteIndex = max(0, words.length - 1);
    final rawAbsoluteIndex = (pageIndex * wordsPerPage) + focusedCardIndex;
    final absoluteIndex = rawAbsoluteIndex.clamp(0, maxAbsoluteIndex);
    final safePageIndex = absoluteIndex ~/ wordsPerPage;
    final safeFocusedIndex = absoluteIndex % wordsPerPage;
    final currentSetStart = safePageIndex * wordsPerPage;
    final currentSetEnd = min(currentSetStart + wordsPerPage, words.length);
    final setWords = words.sublist(currentSetStart, currentSetEnd);

    if (pageIndex != safePageIndex || focusedCardIndex != safeFocusedIndex) {
      pageIndex = safePageIndex;
      focusedCardIndex = safeFocusedIndex;
    }

    final previousPreviewItem =
        absoluteIndex > 0 ? words[absoluteIndex - 1] : null;
    final nextPreviewItem =
        absoluteIndex < words.length - 1 ? words[absoluteIndex + 1] : null;

    return _CardDeckViewport(
      words: words,
      globalStartIndex: 0,
      currentIndex: absoluteIndex,
      totalWords: words.length,
      currentPage: safePageIndex + 1,
      totalPages: totalPages,
      previousPreviewItem: previousPreviewItem,
      nextPreviewItem: nextPreviewItem,
      transitionDirection: cardTransitionDirection,
      isSavedMode: isSavedMode,
      isEnglish: isEnglish,
      categoryLabel: categoryLabel,
      showTeacherSide: showTeacherSide,
      onToggleTeacher: () {
        setState(() {
          showTeacherSide = !showTeacherSide;
        });
      },
      onOpenWord: showWordSheet,
      onPreviousCard: () {
        if (absoluteIndex <= 0) return;

        final nextAbsoluteIndex = absoluteIndex - 1;
        setState(() {
          cardTransitionDirection = -1;
          pageIndex = nextAbsoluteIndex ~/ wordsPerPage;
          focusedCardIndex = nextAbsoluteIndex % wordsPerPage;
          showTeacherSide = false;
        });
        saveVocabularyPositionSoon();
      },
      onNextCard: () {
        if (absoluteIndex >= words.length - 1) {
          if (!isSavedMode) {
            unawaited(
              openSetReviewSheet(
                setWords: setWords,
                safePageIndex: safePageIndex,
                totalPages: totalPages,
              ),
            );
          }
          return;
        }

        final nextAbsoluteIndex = absoluteIndex + 1;
        final shouldReviewCurrentSet = !isSavedMode &&
            safeFocusedIndex == wordsPerPage - 1 &&
            safePageIndex < totalPages - 1;

        if (shouldReviewCurrentSet) {
          unawaited(
            openSetReviewSheet(
              setWords: setWords,
              safePageIndex: safePageIndex,
              totalPages: totalPages,
            ),
          );
          return;
        }

        setState(() {
          cardTransitionDirection = 1;
          pageIndex = nextAbsoluteIndex ~/ wordsPerPage;
          focusedCardIndex = nextAbsoluteIndex % wordsPerPage;
          showTeacherSide = false;
        });
        saveVocabularyPositionSoon();
      },
      onPreviousSet: safePageIndex == 0
          ? null
          : () {
              final nextAbsoluteIndex =
                  max(0, (safePageIndex - 1) * wordsPerPage);
              setState(() {
                pageIndex = nextAbsoluteIndex ~/ wordsPerPage;
                focusedCardIndex = nextAbsoluteIndex % wordsPerPage;
                showTeacherSide = false;
                resetSetQuizState();
              });
              saveVocabularyPositionSoon();
            },
      onNextSet: safePageIndex >= totalPages - 1
          ? null
          : () {
              final nextAbsoluteIndex =
                  min(words.length - 1, (safePageIndex + 1) * wordsPerPage);
              setState(() {
                pageIndex = nextAbsoluteIndex ~/ wordsPerPage;
                focusedCardIndex = nextAbsoluteIndex % wordsPerPage;
                showTeacherSide = false;
                resetSetQuizState();
              });
              saveVocabularyPositionSoon();
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = filteredWords;
    final tokens = SpeakeryThemeTokens.of(context);
    final totalPagesForBuild = max(1, (words.length / wordsPerPage).ceil());
    if (pageIndex >= totalPagesForBuild) {
      pageIndex = totalPagesForBuild - 1;
    }
    if (focusedCardIndex >= wordsPerPage) {
      focusedCardIndex = wordsPerPage - 1;
    }
    if (focusedCardIndex < 0) {
      focusedCardIndex = 0;
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          const _BackgroundGlow(),
          DecoratedBox(
            decoration: BoxDecoration(gradient: tokens.pageGradient),
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  _MainSectionTabs(
                    selectedTab: selectedMainTab,
                    selectedLevel: selectedLevel,
                    isEnglish: isEnglish,
                    onBack: () => Navigator.pop(context),
                    onChanged: (tab) {
                      setState(() {
                        selectedMainTab = tab;
                      });
                      saveVocabularyPositionSoon();
                    },
                  ),
                  const SizedBox(height: 10),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        );

                        return FadeTransition(
                          opacity: curved,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.01),
                              end: Offset.zero,
                            ).animate(curved),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: const ValueKey('learn_tab'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: AppProgress.instance,
                            builder: (context, _) {
                              final liveTotalWords = levelWords.length;
                              final liveProgressWords = levelWords
                                  .where(
                                    (item) =>
                                        AppProgress.instance
                                            .isVocabularyKnown(item.id) ||
                                        AppProgress.instance
                                            .isVocabularyMastered(item.id),
                                  )
                                  .length;

                              return _CleanLearnIntro(
                                selectedLevel: selectedLevel,
                                progressWords: liveProgressWords,
                                totalWords: liveTotalWords,
                                savedWords:
                                    AppProgress.instance.savedVocabularyCount,
                                selectedMode: selectedMode,
                                isEnglish: isEnglish,
                                toolsOpen: showLearnTools,
                                onToggleTools: () {
                                  setState(() {
                                    showLearnTools = !showLearnTools;
                                  });
                                },
                                onStudyCards: () => changeMode('Cards'),
                                onSavedReview: () => changeMode('Saved'),
                                onQuickQuiz: () => changeMode('Meaning Quiz'),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _DailyGoalStrip(
                            isEnglish: isEnglish,
                            studiedToday: isSavedMode
                                ? 0
                                : min(
                                    30,
                                    (pageIndex * wordsPerPage) +
                                        focusedCardIndex +
                                        1),
                            dailyGoal: 30,
                            accent: _styleForLevel(selectedLevel).start,
                          ),
                          const SizedBox(height: 8),
                          _CompactLevelToggle(
                            selectedLevel: selectedLevel,
                            onChanged: changeLevel,
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: showLearnTools
                                ? _LearnToolsPanel(
                                    key: const ValueKey('learn_tools_open'),
                                    selectedLevel: selectedLevel,
                                    selectedMode: selectedMode,
                                    isEnglish: isEnglish,
                                    searchController: searchController,
                                    searchHint: t(
                                        'Search word, Turkish meaning, category or collocation...',
                                        'Kelime, Türkçe anlam, kategori veya kalıp ara...'),
                                    onSearchChanged: (value) {
                                      setState(() {
                                        searchText = value;
                                        practiceIndex = 0;
                                        pageIndex = 0;
                                        focusedCardIndex = 0;
                                        showTeacherSide = false;
                                      });
                                    },
                                    onModeChanged: changeMode,
                                    categoryTitle: t('Category', 'Kategori'),
                                    allLabel: t('All', 'Tümü'),
                                    categories: categories,
                                    selectedCategory: _isAllCategorySelected
                                        ? t('All', 'Tümü')
                                        : selectedCategory,
                                    iconForCategory: categoryIcon,
                                    onCategoryChanged: (category) {
                                      setState(() {
                                        selectedCategory = category;
                                        practiceIndex = 0;
                                        pageIndex = 0;
                                        focusedCardIndex = 0;
                                        showTeacherSide = false;
                                      });
                                    },
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('learn_tools_closed')),
                          ),
                          const SizedBox(height: 7),
                          if (searchText.trim().isNotEmpty) ...[
                            _LearnModeStatusBar(
                              selectedMode: selectedMode,
                              selectedLevel: selectedLevel,
                              selectedCategory: _isAllCategorySelected
                                  ? t('All', 'Tümü')
                                  : selectedCategory,
                              searchText: searchText,
                              isEnglish: isEnglish,
                              onClearSearch: () {
                                setState(() {
                                  searchText = '';
                                  searchController.clear();
                                  practiceIndex = 0;
                                  pageIndex = 0;
                                  focusedCardIndex = 0;
                                });
                              },
                            ),
                            const SizedBox(height: 7),
                          ],
                          _buildLearningArea(words),
                        ],
                      ),
                    ),
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

class _DailyGoalStrip extends StatelessWidget {
  final bool isEnglish;
  final int studiedToday;
  final int dailyGoal;
  final Color accent;

  const _DailyGoalStrip({
    required this.isEnglish,
    required this.studiedToday,
    required this.dailyGoal,
    required this.accent,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final safeGoal = dailyGoal <= 0 ? 1 : dailyGoal;
    final progress = (studiedToday / safeGoal).clamp(0.0, 1.0);
    final completed = studiedToday >= dailyGoal;
    final paused = studiedToday <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: completed
              ? LinearGradient(colors: [
                  const Color(0xFF22C55E).withAlpha(22),
                  accent.withAlpha(14)
                ])
              : null,
          color: completed ? null : Colors.white.withAlpha(6),
          border: Border.all(
              color: completed
                  ? const Color(0xFF22C55E).withAlpha(42)
                  : Colors.white.withAlpha(10)),
        ),
        child: Row(
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (completed
                        ? const Color(0xFF22C55E)
                        : paused
                            ? Colors.white
                            : accent)
                    .withAlpha(paused ? 10 : 18),
                border: Border.all(
                  color: (completed
                          ? const Color(0xFF22C55E)
                          : paused
                              ? Colors.white
                              : accent)
                      .withAlpha(paused ? 22 : 42),
                ),
              ),
              child: Icon(
                completed
                    ? Icons.done_rounded
                    : paused
                        ? Icons.pause_rounded
                        : Icons.flag_rounded,
                color: completed
                    ? const Color(0xFF22C55E)
                    : paused
                        ? Colors.white.withAlpha(170)
                        : accent,
                size: 15,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paused
                        ? t('Today’s goal', 'Bugünkü hedef')
                        : completed
                            ? t('Goal complete', 'Hedef tamam')
                            : t('Today’s goal', 'Bugünkü hedef'),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: paused ? 0.0 : progress,
                      minHeight: 3.4,
                      backgroundColor: Colors.white.withAlpha(10),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed
                            ? const Color(0xFF22C55E)
                            : paused
                                ? Colors.white.withAlpha(80)
                                : accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withAlpha(completed ? 13 : 8),
                border: Border.all(color: Colors.white.withAlpha(12)),
              ),
              child: Text(
                paused
                    ? '—/$dailyGoal'
                    : completed
                        ? t('+30 XP', '+30 XP')
                        : '$studiedToday/$dailyGoal',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.2,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CleanLearnIntro extends StatelessWidget {
  final String selectedLevel;
  final int progressWords;
  final int totalWords;
  final int savedWords;
  final String selectedMode;
  final bool isEnglish;
  final bool toolsOpen;
  final VoidCallback onToggleTools;
  final VoidCallback onStudyCards;
  final VoidCallback onSavedReview;
  final VoidCallback onQuickQuiz;

  const _CleanLearnIntro({
    required this.selectedLevel,
    required this.progressWords,
    required this.totalWords,
    required this.savedWords,
    required this.selectedMode,
    required this.isEnglish,
    required this.toolsOpen,
    required this.onToggleTools,
    required this.onStudyCards,
    required this.onSavedReview,
    required this.onQuickQuiz,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final style = _styleForLevel(selectedLevel);
    final progress =
        totalWords == 0 ? 0.0 : (progressWords / totalWords).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              style.start.withAlpha(35),
              const Color(0xFF111827).withAlpha(235),
              style.end.withAlpha(24),
            ],
          ),
          border: Border.all(color: Colors.white.withAlpha(16)),
          boxShadow: [
            BoxShadow(
                color: style.end.withAlpha(20),
                blurRadius: 24,
                offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [style.start, style.end]),
                    boxShadow: [
                      BoxShadow(
                          color: style.end.withAlpha(45),
                          blurRadius: 18,
                          offset: const Offset(0, 9)),
                    ],
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 17),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('Learn Path', 'Öğrenme Alanı'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.2,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t('Progress and saved words.',
                            'İlerleme ve kayıtlılar.'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withAlpha(160),
                            fontSize: 9.9,
                            fontWeight: FontWeight.w700,
                            height: 1.15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3.5,
                backgroundColor: Colors.white.withAlpha(12),
                valueColor:
                    AlwaysStoppedAnimation<Color>(style.start.withAlpha(150)),
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                _LearnIntroMiniStat(
                  icon: Icons.trending_up_rounded,
                  label:
                      '$progressWords/$totalWords ${t('progress', 'ilerleme')}',
                  color: style.start,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withAlpha(132),
                        fontSize: 9.4,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _LearnToolsCallout(
              isEnglish: isEnglish,
              toolsOpen: toolsOpen,
              color: style.start,
              endColor: style.end,
              onTap: onToggleTools,
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: _LearnPathButton(
                    icon: Icons.style_rounded,
                    label: t('Study', 'Çalış'),
                    subtitle: t('', ''),
                    selected: selectedMode == 'Cards',
                    color: style.start,
                    onTap: onStudyCards,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _LearnPathButton(
                    icon: Icons.bookmark_rounded,
                    label: t('Saved', 'Kayıtlı'),
                    subtitle: t('', ''),
                    selected: selectedMode == 'Saved' ||
                        selectedMode == 'Saved Review',
                    color: const Color(0xFFFFB020),
                    onTap: onSavedReview,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _LearnPathButton(
                    icon: Icons.quiz_rounded,
                    label: t('Quiz', 'Quiz'),
                    subtitle: t('', ''),
                    selected: selectedMode == 'Meaning Quiz',
                    color: const Color(0xFFEC4899),
                    onTap: onQuickQuiz,
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

class _LearnIntroMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LearnIntroMiniStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(12),
        border: Border.all(color: color.withAlpha(36)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.2,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _LearnToolsCallout extends StatelessWidget {
  final bool isEnglish;
  final bool toolsOpen;
  final Color color;
  final Color endColor;
  final VoidCallback onTap;

  const _LearnToolsCallout({
    required this.isEnglish,
    required this.toolsOpen,
    required this.color,
    required this.endColor,
    required this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: toolsOpen
                ? [color.withAlpha(72), endColor.withAlpha(54)]
                : [Colors.white.withAlpha(10), color.withAlpha(14)],
          ),
          border: Border.all(
              color:
                  toolsOpen ? color.withAlpha(70) : Colors.white.withAlpha(15)),
          boxShadow: toolsOpen
              ? [
                  BoxShadow(
                    color: endColor.withAlpha(22),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [color, endColor]),
              ),
              child: Icon(toolsOpen ? Icons.close_rounded : Icons.tune_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                toolsOpen
                    ? t('Hide search & filters', 'Arama ve filtreleri gizle')
                    : t('Search & filters', 'Arama ve filtreler'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.4,
                    fontWeight: FontWeight.w900,
                    height: 1.0),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withAlpha(190), size: 19),
          ],
        ),
      ),
    );
  }
}

class _LearnPathButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _LearnPathButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cleanSubtitle = subtitle.trim();
    final fullLabel = cleanSubtitle.isEmpty
        ? label
        : (label == 'Quiz' || label == 'Quiz')
            ? (cleanSubtitle == 'Quick' || cleanSubtitle == 'Hızlı'
                ? 'Quick Quiz'
                : '$cleanSubtitle Quiz')
            : '$label $cleanSubtitle';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? color.withAlpha(30) : Colors.white.withAlpha(7),
          border: Border.all(
              color:
                  selected ? color.withAlpha(82) : Colors.white.withAlpha(13)),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withAlpha(20),
                      blurRadius: 11,
                      offset: const Offset(0, 6)),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? color : Colors.white.withAlpha(165),
                size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                fullLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.6,
                    fontWeight: FontWeight.w900,
                    height: 1.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnToolsPanel extends StatelessWidget {
  final String selectedLevel;
  final String selectedMode;
  final bool isEnglish;
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onModeChanged;
  final String categoryTitle;
  final String allLabel;
  final List<String> categories;
  final String selectedCategory;
  final IconData Function(String category) iconForCategory;
  final ValueChanged<String> onCategoryChanged;

  const _LearnToolsPanel({
    super.key,
    required this.selectedLevel,
    required this.selectedMode,
    required this.isEnglish,
    required this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
    required this.onModeChanged,
    required this.categoryTitle,
    required this.allLabel,
    required this.categories,
    required this.selectedCategory,
    required this.iconForCategory,
    required this.onCategoryChanged,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final style = _styleForLevel(selectedLevel == 'All' ? 'C1' : selectedLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              style.start.withAlpha(18),
              const Color(0xFF101426).withAlpha(232),
              style.end.withAlpha(13),
            ],
          ),
          border: Border.all(color: Colors.white.withAlpha(13)),
          boxShadow: [
            BoxShadow(
              color: style.end.withAlpha(14),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: style.start.withAlpha(14),
                    border: Border.all(color: style.start.withAlpha(36)),
                  ),
                  child: Icon(Icons.tune_rounded, color: style.start, size: 15),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('Learning tools', 'Araçlar'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t('Search, filter and switch practice style.',
                            'Ara, filtrele ve pratik türünü seç.'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withAlpha(135),
                            fontSize: 9.8,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            _SearchBox(
              controller: searchController,
              selectedLevel: selectedLevel,
              hint: searchHint,
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 10),
            _ModeChips(
              selectedMode: selectedMode,
              selectedLevel: selectedLevel,
              isEnglish: isEnglish,
              onChanged: onModeChanged,
            ),
            const SizedBox(height: 10),
            _CategoryFilterButton(
              title: categoryTitle,
              allLabel: allLabel,
              categories: categories,
              selectedCategory: selectedCategory,
              iconForCategory: iconForCategory,
              onChanged: onCategoryChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnModeStatusBar extends StatelessWidget {
  final String selectedMode;
  final String selectedLevel;
  final String selectedCategory;
  final String searchText;
  final bool isEnglish;
  final VoidCallback onClearSearch;

  const _LearnModeStatusBar({
    required this.selectedMode,
    required this.selectedLevel,
    required this.selectedCategory,
    required this.searchText,
    required this.isEnglish,
    required this.onClearSearch,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final style = _styleForLevel(selectedLevel);
    final hasSearch = searchText.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withAlpha(7),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: style.start.withAlpha(20),
                border: Border.all(color: style.start.withAlpha(50)),
              ),
              child:
                  Icon(_modeIcon(selectedMode), color: style.start, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasSearch
                    ? '${t('Searching', 'Aranıyor')}: "$searchText"'
                    : '$selectedMode • $selectedCategory',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 11,
                    fontWeight: FontWeight.w800),
              ),
            ),
            if (hasSearch)
              GestureDetector(
                onTap: onClearSearch,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(8),
                    border: Border.all(color: Colors.white.withAlpha(14)),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _modeIcon(String mode) {
    if (mode == 'Saved' || mode == 'Saved Review') {
      return Icons.bookmark_rounded;
    }
    if (mode.contains('Quiz')) return Icons.quiz_rounded;
    if (mode.contains('Fill')) return Icons.short_text_rounded;
    if (mode.contains('Collocation')) return Icons.hub_rounded;
    return Icons.style_rounded;
  }
}

class _MainSectionTabs extends StatelessWidget {
  final String selectedTab;
  final String selectedLevel;
  final bool isEnglish;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;

  const _MainSectionTabs({
    required this.selectedTab,
    required this.selectedLevel,
    required this.isEnglish,
    required this.onBack,
    required this.onChanged,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final levelStyle = _styleForLevel(selectedLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 66,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(31),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tokens.isLight
                ? [tokens.glassStrong, tokens.glassSurface]
                : [
                    Colors.white.withAlpha(19),
                    Colors.white.withAlpha(8),
                  ],
          ),
          border: Border.all(
              color:
                  tokens.isLight ? tokens.border : Colors.white.withAlpha(24)),
          boxShadow: [
            BoxShadow(
              color: tokens.shadow.withAlpha(tokens.isLight ? 28 : 22),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            _PressableScale(
              onTap: onBack,
              child: Container(
                width: 42,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: tokens.chipSurface,
                  border: Border.all(color: tokens.border),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: tokens.textPrimary, size: 14),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _TopSectionTabButton(
                label: t('Learn', 'Öğren'),
                icon: Icons.auto_stories_rounded,
                selected: selectedTab == 'Learn',
                style: levelStyle,
                tokens: tokens,
                onTap: () => onChanged('Learn'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSectionTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final _LevelStyle style;
  final SpeakeryThemeTokens tokens;
  final VoidCallback onTap;

  const _TopSectionTabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.style,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [style.start.withAlpha(255), style.end],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: tokens.isLight
                      ? [tokens.inputSurface, tokens.glassSurface]
                      : [
                          Colors.white.withAlpha(18),
                          Colors.white.withAlpha(8),
                        ],
                ),
          border: Border.all(
              color: selected
                  ? Colors.white.withAlpha(72)
                  : tokens.isLight
                      ? tokens.border
                      : Colors.white.withAlpha(23)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: style.end.withAlpha(42),
                    blurRadius: 13,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? Colors.white.withAlpha(34) : tokens.chipSurface,
                border: Border.all(
                    color:
                        selected ? Colors.white.withAlpha(52) : tokens.border),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : tokens.textPrimary,
                  size: 19),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : tokens.textPrimary,
                  fontSize: 16.4,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(child: _PremiumDarkBase()),
        Positioned.fill(child: _SubtleGlassWash()),
        Positioned(
          top: 42,
          left: -20,
          right: -20,
          child: _AmbientLightSweep(
            height: 86,
            angle: -0.08,
            start: Color(0x0C0EA5E9),
            middle: Color(0x0300D4FF),
            end: Color(0x0B7C3AED),
          ),
        ),
        Positioned.fill(child: _SoftDepthFade()),
      ],
    );
  }
}

class _PremiumDarkBase extends StatelessWidget {
  const _PremiumDarkBase();

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.backgroundEnd,
            tokens.background,
          ],
        ),
      ),
    );
  }
}

class _SubtleGlassWash extends StatelessWidget {
  const _SubtleGlassWash();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.42, 0.72, 1.0],
            colors: [
              Color(0x117C3AED),
              Color(0x060EA5E9),
              Color(0x0614B8A6),
              Color(0x00070814),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmbientLightSweep extends StatelessWidget {
  final double height;
  final double angle;
  final Color start;
  final Color middle;
  final Color end;

  const _AmbientLightSweep({
    required this.height,
    required this.angle,
    required this.start,
    required this.middle,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: angle,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [start, middle, end],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftDepthFade extends StatelessWidget {
  const _SoftDepthFade();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x10050712),
            Color(0x00050712),
            Color(0x30050712),
          ],
        ),
      ),
    );
  }
}

class StickyCompactHeader extends StatelessWidget {
  final String selectedLevel;
  final int totalLevelWords;
  final int visibleWords;
  final int savedWords;
  final bool isEnglish;
  final VoidCallback onBack;

  const StickyCompactHeader({
    super.key,
    required this.selectedLevel,
    required this.totalLevelWords,
    required this.visibleWords,
    required this.savedWords,
    required this.isEnglish,
    required this.onBack,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final style = _styleForLevel(selectedLevel);

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
                border: Border.all(color: Colors.white.withAlpha(12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        t('Vocabulary', 'Kelime'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.2,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient:
                            LinearGradient(colors: [style.start, style.end]),
                      ),
                      child: Text(
                        selectedLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$visibleWords/$totalLevelWords • ${t('saved', 'kayıtlı')}: $savedWords',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 10.8,
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

class _LevelStyle {
  final Color start;
  final Color end;

  const _LevelStyle(this.start, this.end);
}

_LevelStyle _styleForLevel(String level) {
  switch (level) {
    case 'A1':
      return const _LevelStyle(Color(0xFF00C2FF), Color(0xFF2563EB));
    case 'A2':
      return const _LevelStyle(Color(0xFF22C55E), Color(0xFF0F766E));
    case 'B1':
      return const _LevelStyle(Color(0xFFFBBF24), Color(0xFFD97706));
    case 'B2':
      return const _LevelStyle(Color(0xFFFB7185), Color(0xFFBE123C));
    case 'C1':
      return const _LevelStyle(Color(0xFFA78BFA), Color(0xFF6D28D9));
    case 'C2':
      return const _LevelStyle(Color(0xFFFDE68A), Color(0xFF92400E));
    default:
      return const _LevelStyle(Color(0xFF94A3B8), Color(0xFF475569));
  }
}

class _CompactLevelToggle extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onChanged;

  const _CompactLevelToggle({
    required this.selectedLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final selectedIndex =
        levels.indexOf(selectedLevel).clamp(0, levels.length - 1);
    final selectedStyle =
        _styleForLevel(selectedLevel == 'All' ? 'C1' : selectedLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: IosLiquidPillSelector(
        items: levels.map(IosPillItem.new).toList(growable: false),
        selectedIndex: selectedIndex,
        startColor: selectedStyle.start,
        endColor: selectedStyle.end,
        onChanged: (index) => onChanged(levels[index]),
      ),
    );
  }
}

class _EmbeddedSetProgress extends StatelessWidget {
  final String setLabel;
  final String cardLabel;
  final double progress;
  final Color color;

  const _EmbeddedSetProgress({
    required this.setLabel,
    required this.cardLabel,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);
    final tokens = SpeakeryThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withAlpha(20),
              border: Border.all(color: color.withAlpha(55)),
            ),
            child: Text(
              setLabel,
              style: TextStyle(
                  color: tokens.isLight ? color : Colors.white,
                  fontSize: 10.2,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: tokens.inputSurface,
              border: Border.all(color: tokens.border),
            ),
            child: Text(
              cardLabel,
              style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 10.1,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: tokens.isLight
                        ? tokens.border.withAlpha(120)
                        : Colors.white.withAlpha(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: safeProgress,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient:
                          LinearGradient(colors: [color, color.withAlpha(180)]),
                    ),
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

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String selectedLevel;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.controller,
    required this.selectedLevel,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final style = _styleForLevel(selectedLevel == 'All' ? 'C1' : selectedLevel);
    final tokens = SpeakeryThemeTokens.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tokens.inputSurface,
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withAlpha(tokens.isLight ? 22 : 20),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 13.2,
            fontWeight: FontWeight.w800),
        cursorColor: style.start,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: tokens.textMuted,
              fontSize: 11.7,
              fontWeight: FontWeight.w700),
          prefixIcon:
              Icon(Icons.search_rounded, color: tokens.iconSecondary, size: 20),
          suffixIcon: controller.text.trim().isEmpty
              ? Icon(Icons.auto_awesome_rounded,
                  color: style.start.withAlpha(140), size: 16)
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        ),
      ),
    );
  }
}

class _ModeChips extends StatelessWidget {
  final String selectedMode;
  final String selectedLevel;
  final bool isEnglish;
  final ValueChanged<String> onChanged;

  const _ModeChips({
    required this.selectedMode,
    required this.selectedLevel,
    required this.isEnglish,
    required this.onChanged,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final modes = <_ModeOption>[
      _ModeOption('Cards', t('', ''), Icons.style_rounded),
      _ModeOption('Saved', t('Saved', 'Kayıtlı'), Icons.bookmark_rounded),
      _ModeOption('Meaning Quiz', t('Mixed Quiz', 'Karışık Quiz'),
          Icons.auto_awesome_rounded),
    ];

    final levelStyle =
        _styleForLevel(selectedLevel == 'All' ? 'C1' : selectedLevel);
    final tokens = SpeakeryThemeTokens.of(context);

    return Row(
      children: modes.asMap().entries.map((entry) {
        final index = entry.key;
        final mode = entry.value;

        final selected = selectedMode == mode.id ||
            (mode.id == 'Saved' && selectedMode == 'Saved Review') ||
            (mode.id == 'Meaning Quiz' &&
                (selectedMode == 'Word Quiz' ||
                    selectedMode == 'Fill Blank' ||
                    selectedMode == 'Collocation Match'));

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == modes.length - 1 ? 0 : 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(mode.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  gradient: selected
                      ? LinearGradient(colors: [
                          levelStyle.start.withAlpha(210),
                          levelStyle.end
                        ])
                      : null,
                  color: selected ? null : tokens.chipSurface,
                  border: Border.all(
                      color: selected
                          ? Colors.white.withAlpha(38)
                          : tokens.border),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: levelStyle.end.withAlpha(28),
                            blurRadius: 13,
                            offset: const Offset(0, 7),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(mode.icon,
                        color: selected ? Colors.white : tokens.iconSecondary,
                        size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        mode.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? Colors.white : tokens.textSecondary,
                          fontSize: 11.7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class Random10Hero extends StatefulWidget {
  final String selectedLevel;
  final bool isEnglish;
  final bool isSelected;
  final VoidCallback onTap;

  const Random10Hero({
    super.key,
    required this.selectedLevel,
    required this.isEnglish,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<Random10Hero> createState() => _Random10HeroState();
}

class _Random10HeroState extends State<Random10Hero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.985,
      upperBound: 1.015,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelStyle = _styleForLevel(widget.selectedLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ScaleTransition(
        scale: _pulse,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF171726),
                  Color(0xFF211A36),
                  Color(0xFF2B1F44),
                ],
              ),
              border: Border.all(color: Colors.white.withAlpha(14)),
              boxShadow: [
                BoxShadow(
                  color: levelStyle.end.withAlpha(30),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 74,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF9A3C),
                        const Color(0xFFD946EF),
                        levelStyle.end
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(12),
                        border: Border.all(color: Colors.white.withAlpha(18)),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Challenge Arena', 'Challenge Arena'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            t('Time attack • duel • leaderboard',
                                'Süreli mod • düello • liderlik'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withAlpha(190),
                              fontSize: 11.4,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF944D), Color(0xFFD946EF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD946EF).withAlpha(40),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t('Enter', 'Gir'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 15),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ChallengeMiniStat(
                        icon: Icons.flash_on_rounded,
                        label: t('Speed', 'Hız'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: _ChallengeMiniStat(
                        icon: Icons.emoji_events_rounded,
                        label: 'XP',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ChallengeMiniStat(
                        icon: Icons.sports_kabaddi_rounded,
                        label: t('1v1', '1v1'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ChallengeMiniStat(
                        icon: Icons.workspace_premium_rounded,
                        label: widget.selectedLevel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withAlpha(6),
                    border: Border.all(color: Colors.white.withAlpha(10)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChallengeTag(label: t('Timed', 'Süreli')),
                      _ChallengeTag(label: t('1v1 Duel', '1v1 Düello')),
                      _ChallengeTag(label: t('Ranked', 'Ranked')),
                      _ChallengeTag(
                          label:
                              '${widget.selectedLevel} ${t('focus', 'odak')}'),
                    ],
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

class _ChallengeTag extends StatelessWidget {
  final String label;

  const _ChallengeTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withAlpha(18),
        border: Border.all(color: Colors.white.withAlpha(22)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ChallengeMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChallengeMiniStat({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withAlpha(14),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOption {
  final String id;
  final String label;
  final IconData icon;

  const _ModeOption(this.id, this.label, this.icon);
}

class _CategoryFilterButton extends StatelessWidget {
  final String title;
  final String allLabel;
  final List<String> categories;
  final String selectedCategory;
  final IconData Function(String category) iconForCategory;
  final ValueChanged<String> onChanged;

  const _CategoryFilterButton({
    required this.title,
    required this.allLabel,
    required this.categories,
    required this.selectedCategory,
    required this.iconForCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final shownCategory =
        selectedCategory.trim().isEmpty ? allLabel : selectedCategory;
    final isAll = shownCategory == allLabel ||
        shownCategory == 'All' ||
        shownCategory == 'Tümü';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) {
            return _CategoryPickerSheet(
              title: title,
              categories: categories,
              selectedCategory: shownCategory,
              iconForCategory: iconForCategory,
              onChanged: onChanged,
            );
          },
        );
      },
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withAlpha(7),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: Row(
          children: [
            Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF22D3EE).withAlpha(12),
                border:
                    Border.all(color: const Color(0xFF22D3EE).withAlpha(30)),
              ),
              child: Icon(
                  isAll ? Icons.tune_rounded : iconForCategory(shownCategory),
                  color: const Color(0xFF67E8F9),
                  size: 14),
            ),
            const SizedBox(width: 9),
            Text(
              '$title:',
              style: TextStyle(
                  color: Colors.white.withAlpha(145),
                  fontSize: 11.2,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                shownCategory,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withAlpha(170), size: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  final String title;
  final List<String> categories;
  final String selectedCategory;
  final IconData Function(String category) iconForCategory;
  final ValueChanged<String> onChanged;

  const _CategoryPickerSheet({
    required this.title,
    required this.categories,
    required this.selectedCategory,
    required this.iconForCategory,
    required this.onChanged,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String query = '';

  String normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final clean = normalize(query);
    final visibleCategories = clean.isEmpty
        ? widget.categories
        : widget.categories
            .where((category) => normalize(category).contains(clean))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
          decoration: const BoxDecoration(
            color: Color(0xFF080A18),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999))),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.filter_alt_rounded,
                      color: Color(0xFF9EEBFF)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(widget.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900))),
                  Text('${visibleCategories.length}',
                      style: const TextStyle(
                          color: Color(0xFFBFC3D9),
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => query = value),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Search category...',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(90)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF9EEBFF)),
                  filled: true,
                  fillColor: Colors.white.withAlpha(10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide:
                          BorderSide(color: Colors.white.withAlpha(18))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide:
                          BorderSide(color: Colors.white.withAlpha(18))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFF9EEBFF))),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  itemCount: visibleCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 56,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                  ),
                  itemBuilder: (context, index) {
                    final category = visibleCategories[index];
                    final selected = category == widget.selectedCategory;

                    return GestureDetector(
                      onTap: () {
                        widget.onChanged(category);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: selected
                              ? const LinearGradient(colors: [
                                  Color(0xFF6D5BFF),
                                  Color(0xFF00D4FF)
                                ])
                              : null,
                          color: selected ? null : Colors.white.withAlpha(12),
                          border: Border.all(
                              color: selected
                                  ? Colors.white.withAlpha(45)
                                  : Colors.white.withAlpha(18)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Colors.white.withAlpha(selected ? 36 : 14),
                                border: Border.all(
                                    color: Colors.white
                                        .withAlpha(selected ? 52 : 20)),
                              ),
                              child: Icon(
                                selected
                                    ? Icons.check_rounded
                                    : widget.iconForCategory(category),
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SetReviewSheet extends StatefulWidget {
  final List<_SetQuizQuestion> questions;
  final int setNumber;
  final int totalSets;
  final bool isEnglish;

  const _SetReviewSheet({
    required this.questions,
    required this.setNumber,
    required this.totalSets,
    required this.isEnglish,
  });

  @override
  State<_SetReviewSheet> createState() => _SetReviewSheetState();
}

class _SetReviewSheetState extends State<_SetReviewSheet> {
  int questionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool answered = false;

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  void answer(_SetQuizQuestion question, String option) {
    if (answered) return;

    final correct = option == question.correctAnswer;

    setState(() {
      selectedAnswer = option;
      answered = true;
      if (correct) {
        score += 1;
        AppProgress.instance.markVocabularyMastered(question.item.id);
      } else {
        AppProgress.instance.toggleSavedVocabulary(question.item.id);
      }
    });

    PremiumFeedback.show(
      context,
      message: correct
          ? t(
              'Correct. Voxa added this word to the den.',
              'Doğru. Voxa bu kelimeyi yuvasına ekledi.',
            )
          : t(
              'Voxa marked this word for another quick review.',
              'Voxa bu kelimeyi kısa bir tekrar için işaretledi.',
            ),
      tone: correct ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );
  }

  void next() {
    if (questionIndex >= widget.questions.length - 1) {
      AppProgress.instance
          .completeVocabularyPractice(rewardXP: max(3, score * 2));
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      questionIndex += 1;
      selectedAnswer = null;
      answered = false;
    });
  }

  void skip() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = questionIndex.clamp(0, widget.questions.length - 1);
    final question = widget.questions[safeIndex];
    final style = _styleForLevel(question.item.level);
    final progress = (safeIndex + 1) / widget.questions.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              color: const Color(0xFF0A0F1D),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF131A2A),
                  style.start.withAlpha(44),
                  style.end.withAlpha(34),
                  const Color(0xFF0A0E1A),
                ],
              ),
              border: Border.all(color: style.end.withAlpha(66)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(150),
                  blurRadius: 34,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.white.withAlpha(38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              LinearGradient(colors: [style.start, style.end]),
                          boxShadow: [
                            BoxShadow(
                              color: style.end.withAlpha(72),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('Set Review', 'Set Tekrarı'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${t('Set', 'Set')} ${widget.setNumber}/${widget.totalSets} • ${widget.questions.length} ${t('mini questions', 'mini soru')}',
                              style: const TextStyle(
                                  color: Color(0xFFCAD0E6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: skip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.white.withAlpha(18),
                            border:
                                Border.all(color: Colors.white.withAlpha(26)),
                          ),
                          child: Text(
                            t('Skip', 'Geç'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withAlpha(20),
                      valueColor: AlwaysStoppedAnimation<Color>(style.start),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: style.start.withAlpha(18),
                          border: Border.all(color: style.start.withAlpha(38)),
                        ),
                        child: Text(
                          '${safeIndex + 1}/${widget.questions.length}',
                          style: TextStyle(
                              color: style.start,
                              fontSize: 12,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$score/${widget.questions.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      question.type == 'meaning'
                          ? t('Choose the Turkish meaning.',
                              'Türkçe anlamı seç.')
                          : t('Choose the English word.',
                              'İngilizce kelimeyi seç.'),
                      style: TextStyle(
                          color: style.start,
                          fontSize: 13,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Container(
                      key: ValueKey(
                          'sheet_prompt_${safeIndex}_${question.prompt}'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1020).withAlpha(214),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: style.end.withAlpha(34)),
                      ),
                      child: Text(
                        question.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 58,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: answered
                          ? _SetReviewFeedbackCard(
                              key: ValueKey(
                                  'review_feedback_${safeIndex}_$selectedAnswer'),
                              correct: selectedAnswer == question.correctAnswer,
                              correctAnswer: question.correctAnswer,
                              isEnglish: widget.isEnglish,
                              color: selectedAnswer == question.correctAnswer
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFFF4D6D),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('review_feedback_empty')),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...question.options.map((option) {
                    final isSelected = selectedAnswer == option;
                    final isCorrect = option == question.correctAnswer;
                    final showCorrect = answered && isCorrect;
                    final showWrong = answered && isSelected && !isCorrect;

                    Color borderColor = Colors.white.withAlpha(16);
                    Color backgroundColor = Colors.white.withAlpha(13);
                    IconData icon = Icons.circle_outlined;

                    if (showCorrect) {
                      borderColor = const Color(0xFF22C55E);
                      backgroundColor = const Color(0xFF22C55E).withAlpha(42);
                      icon = Icons.check_circle_rounded;
                    } else if (showWrong) {
                      borderColor = const Color(0xFFFF4D6D);
                      backgroundColor = const Color(0xFFFF4D6D).withAlpha(42);
                      icon = Icons.cancel_rounded;
                    } else if (isSelected) {
                      borderColor = style.start;
                      backgroundColor = style.start.withAlpha(30);
                      icon = Icons.radio_button_checked_rounded;
                    }

                    final scale = showCorrect
                        ? 1.012
                        : showWrong
                            ? 0.988
                            : 1.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        scale: scale,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap:
                              answered ? null : () => answer(question, option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 210),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: showCorrect || showWrong
                                  ? [
                                      BoxShadow(
                                        color: borderColor.withAlpha(24),
                                        blurRadius: 14,
                                        offset: const Offset(0, 7),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(icon, color: Colors.white, size: 19),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: answered
                          ? _ActionButton(
                              key: ValueKey(
                                  'set_review_next_${safeIndex}_$selectedAnswer'),
                              icon: safeIndex >= widget.questions.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.chevron_right_rounded,
                              label: safeIndex >= widget.questions.length - 1
                                  ? t('Next Set', 'Sonraki Set')
                                  : t('Next', 'Sonraki'),
                              startColor: style.start,
                              endColor: style.end,
                              onTap: next,
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('set_review_next_empty')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetReviewFeedbackCard extends StatelessWidget {
  final bool correct;
  final String correctAnswer;
  final bool isEnglish;
  final Color color;

  const _SetReviewFeedbackCard({
    super.key,
    required this.correct,
    required this.correctAnswer,
    required this.isEnglish,
    required this.color,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          color: color.withAlpha(20),
          border: Border.all(color: color.withAlpha(50)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(22),
                border: Border.all(color: color.withAlpha(55)),
              ),
              child: Icon(correct ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                correct
                    ? t('Correct.', 'Doğru.')
                    : '${t('Answer:', 'Cevap:')} $correctAnswer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.2,
                    height: 1.22,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetQuizQuestion {
  final VocabularyItem item;
  final String type;
  final String prompt;
  final String correctAnswer;
  final List<String> options;

  const _SetQuizQuestion({
    required this.item,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
  });
}

class _CardDeckViewport extends StatelessWidget {
  final List<VocabularyItem> words;
  final int globalStartIndex;
  final int currentIndex;
  final int totalWords;
  final int currentPage;
  final int totalPages;
  final VocabularyItem? previousPreviewItem;
  final VocabularyItem? nextPreviewItem;
  final int transitionDirection;
  final bool isSavedMode;
  final bool isEnglish;
  final String Function(String category) categoryLabel;
  final bool showTeacherSide;
  final VoidCallback onToggleTeacher;
  final ValueChanged<VocabularyItem> onOpenWord;
  final VoidCallback? onPreviousCard;
  final VoidCallback? onNextCard;
  final VoidCallback? onPreviousSet;
  final VoidCallback? onNextSet;

  const _CardDeckViewport({
    required this.words,
    required this.globalStartIndex,
    required this.currentIndex,
    required this.totalWords,
    required this.currentPage,
    required this.totalPages,
    required this.previousPreviewItem,
    required this.nextPreviewItem,
    required this.transitionDirection,
    required this.isSavedMode,
    required this.isEnglish,
    required this.categoryLabel,
    required this.showTeacherSide,
    required this.onToggleTeacher,
    required this.onOpenWord,
    required this.onPreviousCard,
    required this.onNextCard,
    required this.onPreviousSet,
    required this.onNextSet,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) return _EmptyState(isEnglish: isEnglish);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      child: SizedBox(
        height: 520,
        child: _SmoothVocabularyPageDeck(
          words: words,
          globalStartIndex: globalStartIndex,
          currentIndex: currentIndex,
          totalWords: totalWords,
          currentPage: currentPage,
          totalPages: totalPages,
          isSavedMode: isSavedMode,
          isEnglish: isEnglish,
          categoryLabel: categoryLabel,
          showTeacherSide: showTeacherSide,
          onToggleTeacher: onToggleTeacher,
          onOpenWord: onOpenWord,
          onPreviousCard: onPreviousCard,
          onNextCard: onNextCard,
          labelBuilder: t,
        ),
      ),
    );
  }
}

class _SmoothVocabularyPageDeck extends StatefulWidget {
  final List<VocabularyItem> words;
  final int globalStartIndex;
  final int currentIndex;
  final int totalWords;
  final int currentPage;
  final int totalPages;
  final bool isSavedMode;
  final bool isEnglish;
  final String Function(String category) categoryLabel;
  final bool showTeacherSide;
  final VoidCallback onToggleTeacher;
  final ValueChanged<VocabularyItem> onOpenWord;
  final VoidCallback? onPreviousCard;
  final VoidCallback? onNextCard;
  final String Function(String en, String tr) labelBuilder;

  const _SmoothVocabularyPageDeck({
    required this.words,
    required this.globalStartIndex,
    required this.currentIndex,
    required this.totalWords,
    required this.currentPage,
    required this.totalPages,
    required this.isSavedMode,
    required this.isEnglish,
    required this.categoryLabel,
    required this.showTeacherSide,
    required this.onToggleTeacher,
    required this.onOpenWord,
    required this.onPreviousCard,
    required this.onNextCard,
    required this.labelBuilder,
  });

  @override
  State<_SmoothVocabularyPageDeck> createState() =>
      _SmoothVocabularyPageDeckState();
}

class _SmoothVocabularyPageDeckState extends State<_SmoothVocabularyPageDeck> {
  late final PageController controller;
  bool internalPageChange = false;

  @override
  void initState() {
    super.initState();
    controller =
        PageController(initialPage: widget.currentIndex, viewportFraction: 1.0);
  }

  @override
  void didUpdateWidget(covariant _SmoothVocabularyPageDeck oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.words.map((e) => e.id).join('|') !=
        widget.words.map((e) => e.id).join('|')) {
      internalPageChange = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !controller.hasClients || widget.words.isEmpty) return;
        controller
            .jumpToPage(widget.currentIndex.clamp(0, widget.words.length - 1));
      });
      return;
    }

    if (!internalPageChange && controller.hasClients) {
      final page = controller.page?.round() ?? controller.initialPage;
      if (page != widget.currentIndex) {
        controller.animateToPage(
          widget.currentIndex.clamp(0, widget.words.length - 1),
          duration: const Duration(milliseconds: 210),
          curve: Curves.easeOutCubic,
        );
      }
    }

    internalPageChange = false;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      physics: const BouncingScrollPhysics(parent: PageScrollPhysics()),
      clipBehavior: Clip.none,
      itemCount: widget.words.length,
      onPageChanged: (index) {
        if (index == widget.currentIndex) return;

        final movingForward = index > widget.currentIndex;
        final crossedReviewBoundary = !widget.isSavedMode &&
            movingForward &&
            widget.currentIndex % 6 == 5 &&
            index == widget.currentIndex + 1;

        if (crossedReviewBoundary) {
          internalPageChange = false;
          if (controller.hasClients) {
            controller.animateToPage(
              widget.currentIndex.clamp(0, widget.words.length - 1),
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
            );
          }
          widget.onNextCard?.call();
          return;
        }

        internalPageChange = true;
        if (movingForward) {
          widget.onNextCard?.call();
        } else {
          widget.onPreviousCard?.call();
        }
      },
      itemBuilder: (context, index) {
        final item = widget.words[index];
        final setNumber = (index ~/ 6) + 1;
        final setCount = max(1, ((widget.words.length - 1) ~/ 6) + 1);
        final cardInSet = (index % 6) + 1;
        final currentSetSize =
            min(6, widget.words.length - ((setNumber - 1) * 6));
        final setProgress =
            (cardInSet / (currentSetSize == 0 ? 1 : currentSetSize))
                .clamp(0.0, 1.0);
        final savedProgress =
            ((index + 1) / (widget.words.isEmpty ? 1 : widget.words.length))
                .clamp(0.0, 1.0);

        return _CurrentDeckCardFrame(
          child: _FlipCardShell(
            showBack: widget.showTeacherSide,
            front: _VocabularyCard(
              key: ValueKey('front_${item.id}'),
              item: item,
              index: widget.globalStartIndex + index,
              isEnglish: widget.isEnglish,
              categoryLabel: widget.categoryLabel(item.category),
              setLabel: widget.isSavedMode
                  ? widget.labelBuilder('Saved', 'Saved')
                  : '${widget.labelBuilder('Set', 'Set')} $setNumber/$setCount',
              cardLabel: widget.isSavedMode
                  ? '${index + 1}/${widget.words.length}'
                  : '$cardInSet/$currentSetSize',
              setProgress: widget.isSavedMode ? savedProgress : setProgress,
              onTap: widget.onToggleTeacher,
            ),
            back: _TeacherBackCard(
              key: ValueKey('teacher_${item.id}'),
              item: item,
              isEnglish: widget.isEnglish,
              categoryLabel: widget.categoryLabel(item.category),
              onFlipBack: widget.onToggleTeacher,
              onOpenFull: () => widget.onOpenWord(item),
            ),
          ),
        );
      },
    );
  }
}

class _CurrentDeckCardFrame extends StatelessWidget {
  final Widget child;

  const _CurrentDeckCardFrame({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(46),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF0EA5E9).withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FlipCardShell extends StatelessWidget {
  final bool showBack;
  final Widget front;
  final Widget back;

  const _FlipCardShell({
    required this.showBack,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: showBack ? 1 : 0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubicEmphasized,
      builder: (context, value, child) {
        final angle = value * pi;
        final isBackVisible = value > 0.5;
        final depth = sin(angle).abs();
        final cardTransform = Matrix4.identity();
        cardTransform.setEntry(3, 2, 0.0015);
        cardTransform.translateByDouble(0.0, -2.0 * depth, 0.0, 1.0);
        cardTransform.rotateY(angle);

        return Transform(
          alignment: Alignment.center,
          transform: cardTransform,
          child: Transform.scale(
            scale: 1 - (0.018 * depth),
            child: isBackVisible
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: back,
                  )
                : front,
          ),
        );
      },
    );
  }
}

class _TeacherBackCard extends StatelessWidget {
  final VocabularyItem item;
  final bool isEnglish;
  final String categoryLabel;
  final VoidCallback onFlipBack;
  final VoidCallback onOpenFull;

  const _TeacherBackCard({
    super.key,
    required this.item,
    required this.isEnglish,
    required this.categoryLabel,
    required this.onFlipBack,
    required this.onOpenFull,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final style = _styleForLevel(item.level);

    return GestureDetector(
      onTap: onFlipBack,
      child: Container(
        key: ValueKey('teacher_${item.id}'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              style.end.withAlpha(26),
              style.start.withAlpha(16),
              Colors.white.withAlpha(10),
            ],
          ),
          border: Border.all(color: style.start.withAlpha(56)),
          boxShadow: [
            BoxShadow(
                color: style.end.withAlpha(18),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              LinearGradient(colors: [style.start, style.end]),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t('Teacher Card', 'Öğretici Kart'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t('tap to flip', 'dokun çevir'),
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.flip_to_front_rounded,
                              color: Colors.white54, size: 18),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.word,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _SmallTag(text: item.level, color: style.start),
                              _SmallTag(
                                  text: item.partOfSpeech, color: style.end),
                              _SmallTag(
                                  text: categoryLabel,
                                  color: style.start.withAlpha(180)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _MiniTeacherLine(
                              icon: Icons.translate_rounded,
                              title: t('Meaning', 'Anlam'),
                              text: item.meaningTr,
                              color: style.start),
                          const SizedBox(height: 10),
                          _MiniTeacherLine(
                              icon: Icons.menu_book_rounded,
                              title: t('Definition', 'Tanım'),
                              text: item.definitionEn,
                              color: style.start),
                          const SizedBox(height: 10),
                          _MiniTeacherLine(
                            icon: Icons.lightbulb_rounded,
                            title: t('Use it like this', 'Böyle kullan'),
                            text: item.collocations.isNotEmpty
                                ? item.collocations.take(2).join(' • ')
                                : t('Create your own sentence with this word.',
                                    'Bu kelimeyle kendi cümleni kur.'),
                            color: style.start,
                          ),
                          const SizedBox(height: 10),
                          _MiniTeacherLine(
                              icon: Icons.format_quote_rounded,
                              title: t('Example', 'Örnek'),
                              text: '${item.exampleEn}\n${item.exampleTr}',
                              color: style.start),
                          if (item.collocations.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _MiniTeacherLine(
                                icon: Icons.bolt_rounded,
                                title: t('Chunk', 'Kalıp'),
                                text: item.collocations.take(3).join(' • '),
                                color: style.start),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.flip_to_front_rounded,
                          label: t('Back', 'Geri'),
                          startColor: style.start,
                          endColor: style.end,
                          onTap: onFlipBack,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.open_in_full_rounded,
                          label: t('Full Card', 'Tam Kart'),
                          startColor: style.start,
                          endColor: style.end,
                          onTap: onOpenFull,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniTeacherLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const _MiniTeacherLine({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withAlpha(34),
        border: Border.all(color: color.withAlpha(44)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  final VocabularyItem item;
  final int index;
  final bool isEnglish;
  final String categoryLabel;
  final String setLabel;
  final String cardLabel;
  final double setProgress;
  final VoidCallback onTap;

  const _VocabularyCard({
    super.key,
    required this.item,
    required this.index,
    required this.isEnglish,
    required this.categoryLabel,
    required this.setLabel,
    required this.cardLabel,
    required this.setProgress,
    required this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final levelStyle = _styleForLevel(item.level);

    return AnimatedBuilder(
      animation: AppProgress.instance,
      builder: (context, _) {
        final saved = AppProgress.instance.isVocabularySaved(item.id);
        final known = AppProgress.instance.isVocabularyKnown(item.id);
        final mastered = AppProgress.instance.isVocabularyMastered(item.id);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            key: ValueKey('front_${item.id}'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  levelStyle.start.withAlpha(24),
                  levelStyle.end.withAlpha(12),
                  Colors.white.withAlpha(10),
                ],
              ),
              border: Border.all(
                color: mastered
                    ? const Color(0xFF22C55E).withAlpha(110)
                    : levelStyle.end.withAlpha(60),
              ),
              boxShadow: [
                BoxShadow(
                  color: levelStyle.end.withAlpha(18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EmbeddedSetProgress(
                        setLabel: setLabel,
                        cardLabel: cardLabel,
                        progress: setProgress,
                        color: levelStyle.start,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: [levelStyle.start, levelStyle.end]),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.word,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 7,
                                  runSpacing: 7,
                                  children: [
                                    _SmallTag(
                                        text: item.level,
                                        color: levelStyle.start),
                                    _SmallTag(
                                        text: item.partOfSpeech,
                                        color: levelStyle.end),
                                    _SmallTag(
                                        text: categoryLabel,
                                        color: levelStyle.start.withAlpha(180)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t(
                                      'Pronunciation audio will be connected here.',
                                      'Telaffuz sesi buraya bağlanacak.')),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(milliseconds: 950),
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    colors: [levelStyle.start, levelStyle.end]),
                                boxShadow: [
                                  BoxShadow(
                                      color: levelStyle.end.withAlpha(34),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6)),
                                ],
                              ),
                              child: const Icon(Icons.volume_up_rounded,
                                  color: Colors.white, size: 19),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => AppProgress.instance
                                .toggleSavedVocabulary(item.id),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: saved
                                    ? const Color(0xFFFFD166).withAlpha(22)
                                    : Colors.white.withAlpha(8),
                                border: Border.all(
                                    color: saved
                                        ? const Color(0xFFFFD166).withAlpha(62)
                                        : Colors.white.withAlpha(16)),
                              ),
                              child: Icon(
                                saved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_add_outlined,
                                color: saved
                                    ? const Color(0xFFFFD166)
                                    : Colors.white.withAlpha(180),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withAlpha(28),
                          border:
                              Border.all(color: levelStyle.end.withAlpha(28)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.translate_rounded,
                                    color: levelStyle.start, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.meaningTr,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(26),
                              levelStyle.start.withAlpha(12),
                            ],
                          ),
                          border:
                              Border.all(color: levelStyle.end.withAlpha(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_quote_rounded,
                                    color: levelStyle.start, size: 17),
                                const SizedBox(width: 6),
                                Text(
                                  t('Example', 'Örnek'),
                                  style: TextStyle(
                                      color: levelStyle.start,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.exampleEn,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.exampleTr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFFBFC3D9),
                                  fontSize: 12.5,
                                  height: 1.25,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          t('tap card to flip for teacher notes',
                              'Öğretmen notları için karta dokun'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withAlpha(96),
                            fontSize: 9.8,
                            height: 1.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _VocabularyCardActionBar(
                        saved: saved,
                        known: known,
                        mastered: mastered,
                        color: levelStyle.start,
                        endColor: levelStyle.end,
                        isEnglish: isEnglish,
                        onSave: () =>
                            AppProgress.instance.toggleSavedVocabulary(item.id),
                        onKnown: () =>
                            AppProgress.instance.toggleKnownVocabulary(item.id),
                        onLearned: () => AppProgress.instance
                            .markVocabularyMastered(item.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VocabularyCardActionBar extends StatelessWidget {
  final bool saved;
  final bool known;
  final bool mastered;
  final Color color;
  final Color endColor;
  final bool isEnglish;
  final VoidCallback onSave;
  final VoidCallback onKnown;
  final VoidCallback onLearned;

  const _VocabularyCardActionBar({
    required this.saved,
    required this.known,
    required this.mastered,
    required this.color,
    required this.endColor,
    required this.isEnglish,
    required this.onSave,
    required this.onKnown,
    required this.onLearned,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withAlpha(38),
        border: Border.all(color: Colors.white.withAlpha(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _VocabularyActionPill(
              active: saved,
              icon:
                  saved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
              label: saved ? t('Saved', 'Kayıtlı') : t('Save', 'Kaydet'),
              color: const Color(0xFFFFD166),
              onTap: onSave,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _VocabularyActionPill(
              active: known,
              icon: known ? Icons.check_circle_rounded : Icons.check_rounded,
              label: known ? t('Known', 'Biliyorum') : t('Know', 'Biliyorum'),
              color: color,
              onTap: onKnown,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _VocabularyActionPill(
              active: mastered,
              icon: mastered
                  ? Icons.workspace_premium_rounded
                  : Icons.military_tech_outlined,
              label: mastered
                  ? t('Learned', 'Öğrendim')
                  : t('Learned', 'Öğrendim'),
              color: endColor,
              onTap: onLearned,
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyActionPill extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _VocabularyActionPill({
    required this.active,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        height: 38,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withAlpha(220),
                    color.withAlpha(118),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(9),
                    Colors.white.withAlpha(4),
                  ],
                ),
          border: Border.all(
              color: active
                  ? Colors.white.withAlpha(44)
                  : Colors.white.withAlpha(12)),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withAlpha(30),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? Colors.white : color.withAlpha(220), size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white.withAlpha(188),
                  fontSize: 10.4,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final VocabularyItem item;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
  final String type;

  const _QuizQuestion({
    required this.item,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
    required this.type,
  });
}

class _LightGameBackground extends StatelessWidget {
  const _LightGameBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF070814),
            Color(0xFF07111F),
            Color(0xFF09081A),
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class TeamScrambleScreen extends StatefulWidget {
  final List<VocabularyItem> words;
  final List<VocabularyItem> allWords;
  final bool isEnglish;

  const TeamScrambleScreen({
    super.key,
    required this.words,
    required this.allWords,
    required this.isEnglish,
  });

  @override
  State<TeamScrambleScreen> createState() => _TeamScrambleScreenState();
}

class _TeamScrambleScreenState extends State<TeamScrambleScreen>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  final TextEditingController answerController = TextEditingController();
  final TextEditingController teamAController =
      TextEditingController(text: 'Team A');
  final TextEditingController teamBController =
      TextEditingController(text: 'Team B');

  late AnimationController pulseController;
  Timer? turnTimer;

  List<VocabularyItem> deck = [];
  VocabularyItem? currentItem;
  String selectedLevel = 'Mixed';
  String scrambledWord = '';
  String feedbackText = '';
  Color feedbackColor = const Color(0xFF8B5CF6);

  int activeTeam = 0;
  int teamAScore = 0;
  int teamBScore = 0;
  int round = 1;
  int targetScore = 10;
  int turnSeconds = 45;
  int secondsLeft = 45;

  bool matchStarted = false;
  bool turnRunning = false;
  bool matchFinished = false;
  bool showFeedback = false;
  bool onlineMode = false;
  bool matchmaking = false;
  bool aiOpponent = false;
  bool aiThinking = false;
  int matchmakingSeconds = 0;
  int lastScoredTeam = -1;
  int feedbackSerial = 0;
  int lastRewardXP = 0;
  bool rewardsApplied = false;
  final Set<String> recentlyUsedWordIds = <String>{};
  Timer? matchmakingTimer;

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      lowerBound: 0.96,
      upperBound: 1.04,
    );
  }

  @override
  void dispose() {
    turnTimer?.cancel();
    matchmakingTimer?.cancel();
    pulseController.dispose();
    answerController.dispose();
    teamAController.dispose();
    teamBController.dispose();
    super.dispose();
  }

  String cleanWord(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  bool isPlayable(VocabularyItem item) {
    final word = cleanWord(item.word);
    if (word.length < 3 || word.length > 12) return false;
    if (!RegExp(r'^[a-z]+$').hasMatch(word)) return false;
    return item.meaningTr.trim().isNotEmpty;
  }

  List<VocabularyItem> applyLevel(List<VocabularyItem> source) {
    if (selectedLevel == 'Mixed') return source;

    final allowed = selectedLevel
        .split('-')
        .map((level) => level.toUpperCase().trim())
        .where((level) => level.isNotEmpty)
        .toSet();

    return source
        .where((item) => allowed.contains(item.level.toUpperCase().trim()))
        .toList();
  }

  List<VocabularyItem> buildDeck() {
    final current = applyLevel(widget.words.where(isPlayable).toList());
    final fallback = applyLevel(widget.allWords.where(isPlayable).toList());
    final mixedFallback = widget.allWords.where(isPlayable).toList();

    final picked = current.length >= 10
        ? current
        : fallback.length >= 10
            ? fallback
            : mixedFallback;

    final seen = <String>{};
    final unique = <VocabularyItem>[];

    for (final item in picked) {
      final key = cleanWord(item.word);
      if (seen.add(key)) unique.add(item);
    }

    unique.shuffle(random);
    return unique.take(800).toList();
  }

  int get playablePoolCount {
    final current = applyLevel(widget.words.where(isPlayable).toList());
    final fallback = applyLevel(widget.allWords.where(isPlayable).toList());
    final mixedFallback = widget.allWords.where(isPlayable).toList();

    final picked = current.length >= 10
        ? current
        : fallback.length >= 10
            ? fallback
            : mixedFallback;

    return picked.map((item) => cleanWord(item.word)).toSet().length;
  }

  String scramble(String word) {
    final letters = word.split('');
    if (letters.length < 2) return word;

    for (var i = 0; i < 12; i++) {
      letters.shuffle(random);
      final candidate = letters.join('');
      if (candidate != word) return candidate;
    }

    return letters.reversed.join();
  }

  void rebuildDeckForLevel(String level) {
    turnTimer?.cancel();
    matchmakingTimer?.cancel();

    setState(() {
      selectedLevel = level;
      matchmaking = false;
      matchStarted = false;
      matchFinished = false;
      rewardsApplied = false;
      lastRewardXP = 0;
      onlineMode = false;
      aiOpponent = false;
      aiThinking = false;
      showFeedback = false;
      feedbackText = '';
      lastScoredTeam = -1;
      feedbackSerial = 0;
      deck = [];
      recentlyUsedWordIds.clear();
      currentItem = null;
      scrambledWord = '';
      answerController.clear();
    });
  }

  void nextWord({bool resetAnswer = false}) {
    if (deck.isEmpty) {
      currentItem = null;
      scrambledWord = '';
      return;
    }

    var available =
        deck.where((item) => !recentlyUsedWordIds.contains(item.id)).toList();

    if (available.isEmpty) {
      recentlyUsedWordIds.clear();
      available = List<VocabularyItem>.from(deck);
    }

    currentItem = available[random.nextInt(available.length)];
    recentlyUsedWordIds.add(currentItem!.id);

    if (recentlyUsedWordIds.length > min(40, deck.length)) {
      recentlyUsedWordIds.remove(recentlyUsedWordIds.first);
    }

    scrambledWord = scramble(cleanWord(currentItem!.word));
    if (resetAnswer) answerController.clear();
  }

  void ensureDeckReady() {
    if (deck.isNotEmpty) return;

    deck = buildDeck();
    recentlyUsedWordIds.clear();

    if (deck.isNotEmpty) {
      nextWord(resetAnswer: true);
    }
  }

  void startMatch({bool online = false, bool vsAI = false}) {
    ensureDeckReady();
    if (deck.isEmpty) return;

    matchmakingTimer?.cancel();

    setState(() {
      teamAScore = 0;
      teamBScore = 0;
      activeTeam = 0;
      round = 1;
      matchFinished = false;
      matchStarted = true;
      matchmaking = false;
      rewardsApplied = false;
      lastRewardXP = 0;
      onlineMode = online || vsAI;
      aiOpponent = vsAI;
      aiThinking = false;
      showFeedback = false;
      feedbackText = '';
      secondsLeft = turnSeconds;
      if (vsAI) {
        teamBController.text = 'Voxa AI';
      }
      nextWord(resetAnswer: true);
    });

    startTimer();
  }

  void startOnlineMatchmaking() {
    ensureDeckReady();
    if (deck.isEmpty) return;

    turnTimer?.cancel();
    matchmakingTimer?.cancel();

    setState(() {
      matchmaking = true;
      matchStarted = false;
      matchFinished = false;
      onlineMode = true;
      aiOpponent = false;
      aiThinking = false;
      matchmakingSeconds = 0;
      feedbackText = '';
      showFeedback = false;
      teamAScore = 0;
      teamBScore = 0;
      activeTeam = 0;
      round = 1;
    });

    matchmakingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !matchmaking) {
        timer.cancel();
        return;
      }

      setState(() {
        matchmakingSeconds += 1;
      });

      if (matchmakingSeconds >= 4) {
        timer.cancel();
        if (!mounted || !matchmaking) return;
        startMatch(online: true, vsAI: true);
      }
    });
  }

  void cancelMatchmaking() {
    matchmakingTimer?.cancel();
    setState(() {
      matchmaking = false;
      onlineMode = false;
      aiOpponent = false;
      matchmakingSeconds = 0;
    });
  }

  void startTimer() {
    turnTimer?.cancel();

    if (currentItem == null || deck.isEmpty) {
      finishMatch();
      return;
    }

    if (aiOpponent && activeTeam == 1) {
      runAiTurn();
      return;
    }

    setState(() {
      turnRunning = true;
      secondsLeft = turnSeconds;
    });

    turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || matchFinished || !matchStarted) {
        timer.cancel();
        return;
      }

      if (secondsLeft <= 1) {
        timer.cancel();
        handleTimeout();
        return;
      }

      setState(() {
        secondsLeft -= 1;
      });
    });
  }

  void runAiTurn() {
    if (!mounted || matchFinished || currentItem == null) return;

    setState(() {
      aiThinking = true;
      turnRunning = false;
      showFeedback = false;
      feedbackText = '';
      secondsLeft = turnSeconds;
    });

    Future.delayed(Duration(milliseconds: 950 + random.nextInt(850)), () {
      if (!mounted ||
          matchFinished ||
          !matchStarted ||
          activeTeam != 1 ||
          currentItem == null) {
        return;
      }

      final difficultyBoost = selectedLevel == 'C1-C2'
          ? 12
          : selectedLevel == 'B1-B2'
              ? 7
              : 0;
      final aiCorrect =
          random.nextInt(100) < (68 + difficultyBoost).clamp(0, 88);

      setState(() {
        aiThinking = false;
        showFeedback = true;

        if (aiCorrect) {
          teamBScore += 1;
          lastScoredTeam = 1;
          feedbackSerial += 1;
          feedbackColor = const Color(0xFFFF8A00);
          feedbackText =
              t('Voxa AI solved the scramble.', 'Voxa AI scramble’ı çözdü.');
        } else {
          lastScoredTeam = -1;
          feedbackSerial += 1;
          feedbackColor = const Color(0xFFFF4D6D);
          feedbackText =
              '${t('Voxa AI missed.', 'Voxa AI kaçırdı.')} ${t('Answer', 'Cevap')}: ${currentItem!.word}';
        }
      });

      if (teamBScore >= targetScore) {
        Future.delayed(const Duration(milliseconds: 750), () {
          if (!mounted) return;
          finishMatch();
        });
      } else {
        delayedNextTurn();
      }
    });
  }

  void handleTimeout() {
    setState(() {
      turnRunning = false;
      showFeedback = true;
      lastScoredTeam = -1;
      feedbackSerial += 1;
      feedbackColor = const Color(0xFFFF4D6D);
      feedbackText =
          t('Time is up. Turn switched.', 'Süre bitti. Sıra değişti.');
    });
    delayedNextTurn();
  }

  void submitAnswer() {
    if (!matchStarted ||
        matchFinished ||
        currentItem == null ||
        showFeedback ||
        aiThinking ||
        (aiOpponent && activeTeam == 1)) {
      return;
    }

    final answer = cleanWord(answerController.text);

    if (answer.isEmpty) {
      setState(() {
        showFeedback = true;
        lastScoredTeam = -1;
        feedbackSerial += 1;
        feedbackColor = const Color(0xFFFFB020);
        feedbackText = t('Type a word before submitting.',
            'Göndermeden önce bir kelime yaz.');
      });

      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted || matchFinished) return;
        setState(() {
          showFeedback = false;
          feedbackText = '';
        });
      });
      return;
    }

    final correct = answer == cleanWord(currentItem!.word);

    turnTimer?.cancel();
    unawaited(
      pulseController.forward(from: 0.96).then((_) {
        if (mounted) pulseController.reverse();
      }),
    );

    setState(() {
      turnRunning = false;
      showFeedback = true;

      if (correct) {
        if (activeTeam == 0) {
          teamAScore += 1;
        } else {
          teamBScore += 1;
        }
        lastScoredTeam = activeTeam;
        feedbackSerial += 1;
        feedbackColor = const Color(0xFF22C55E);
        feedbackText =
            t('Correct! Team score popped.', 'Doğru! Takım puanı yükseldi.');
        AppProgress.instance.markVocabularyMastered(currentItem!.id);
      } else {
        lastScoredTeam = -1;
        feedbackSerial += 1;
        feedbackColor = const Color(0xFFFF4D6D);
        feedbackText =
            '${t('Not quite.', 'Tam olmadı.')} ${t('Answer', 'Cevap')}: ${currentItem!.word}';
      }
    });

    if (teamAScore >= targetScore || teamBScore >= targetScore) {
      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        finishMatch();
      });
    } else {
      delayedNextTurn();
    }
  }

  void passWord() {
    if (!matchStarted ||
        matchFinished ||
        currentItem == null ||
        showFeedback ||
        aiThinking ||
        (aiOpponent && activeTeam == 1)) {
      return;
    }

    turnTimer?.cancel();
    setState(() {
      turnRunning = false;
      showFeedback = true;
      lastScoredTeam = -1;
      feedbackSerial += 1;
      feedbackColor = const Color(0xFFFFB020);
      feedbackText =
          '${t('Passed.', 'Pas geçildi.')} ${t('Answer', 'Cevap')}: ${currentItem!.word}';
    });
    delayedNextTurn();
  }

  void delayedNextTurn() {
    final delay = aiOpponent
        ? const Duration(milliseconds: 980)
        : const Duration(milliseconds: 850);

    Future.delayed(delay, () {
      if (!mounted || matchFinished) return;
      setState(() {
        activeTeam = activeTeam == 0 ? 1 : 0;
        round += 1;
        showFeedback = false;
        feedbackText = '';
        aiThinking = false;
        lastScoredTeam = -1;
        nextWord(resetAnswer: true);
      });
      startTimer();
    });
  }

  int calculateScrambleRewardXP() {
    final won = teamAScore >= teamBScore;
    const base = 18;
    final scoreXP = teamAScore * 7;
    final winBonus = won ? 24 : 8;
    final onlineBonus = onlineMode ? 10 : 0;
    final aiBonus = aiOpponent ? 6 : 0;
    final targetBonus = targetScore >= 20
        ? 10
        : targetScore >= 15
            ? 6
            : 0;

    return max(
        10, base + scoreXP + winBonus + onlineBonus + aiBonus + targetBonus);
  }

  void applyScrambleRewards() {
    if (rewardsApplied) return;

    final reward = calculateScrambleRewardXP();

    rewardsApplied = true;
    lastRewardXP = reward;

    AppProgress.instance.completeVocabularyPractice(rewardXP: reward);
  }

  void finishMatch() {
    if (matchFinished) return;

    turnTimer?.cancel();
    matchmakingTimer?.cancel();

    applyScrambleRewards();

    setState(() {
      matchFinished = true;
      turnRunning = false;
      showFeedback = false;
    });
  }

  void restartSetup() {
    turnTimer?.cancel();
    setState(() {
      matchStarted = false;
      matchFinished = false;
      rewardsApplied = false;
      lastRewardXP = 0;
      matchmaking = false;
      onlineMode = false;
      aiOpponent = false;
      aiThinking = false;
      turnRunning = false;
      showFeedback = false;
      lastScoredTeam = -1;
      feedbackSerial = 0;
      answerController.clear();
      deck = buildDeck();
      recentlyUsedWordIds.clear();
      if (deck.isNotEmpty) nextWord(resetAnswer: true);
    });
  }

  void shuffleCurrent() {
    if (currentItem == null ||
        showFeedback ||
        aiThinking ||
        (aiOpponent && activeTeam == 1)) {
      return;
    }
    setState(() {
      scrambledWord = scramble(cleanWord(currentItem!.word));
      feedbackText = '';
      lastScoredTeam = -1;
    });
  }

  String hintFor(VocabularyItem item) {
    if (item.definitionEn.trim().isNotEmpty) return item.definitionEn.trim();
    if (item.meaningTr.trim().isNotEmpty) return item.meaningTr.trim();
    if (item.exampleEn.trim().isNotEmpty) return item.exampleEn.trim();
    return t('No hint available.', 'İpucu yok.');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          const _LightGameBackground(),
          SafeArea(
            child: matchmaking
                ? _buildMatchmaking()
                : matchFinished
                    ? _buildFinish()
                    : matchStarted
                        ? (deck.isEmpty ? _buildEmpty() : _buildGame())
                        : _buildSetup(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          _PressableScale(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
                border: Border.all(color: Colors.white.withAlpha(18)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team Scramble',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withAlpha(158),
                      fontSize: 11.3,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                  colors: [Color(0xFF00C2FF), Color(0xFFEC4899)]),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFEC4899).withAlpha(34),
                    blurRadius: 16,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Text(
              '$playablePoolCount ${t('pool', 'havuz')}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.8,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withAlpha(8),
            border: Border.all(color: Colors.white.withAlpha(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.extension_off_rounded,
                  color: Color(0xFFEC4899), size: 46),
              const SizedBox(height: 12),
              Text(
                t('Scramble needs short English words.',
                    'Scramble için kısa İngilizce kelimeler lazım.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              Text(
                t('Switch to Mixed or add 3–12 letter words.',
                    'Mixed seç veya 3–12 harfli kelimeler ekle.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _TabooPrimaryButton(
                label: t('Back to setup', 'Ayarlara dön'),
                icon: Icons.tune_rounded,
                onTap: () {
                  setState(() {
                    matchStarted = false;
                    matchFinished = false;
                    deck = [];
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          _buildTopBar(t('Set match options.', 'Maç ayarlarını seç.')),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00C2FF).withAlpha(26),
                    const Color(0xFF101426).withAlpha(236),
                    const Color(0xFFEC4899).withAlpha(28),
                  ],
                ),
                border: Border.all(color: Colors.white.withAlpha(13)),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF8B5CF6).withAlpha(16),
                      blurRadius: 14,
                      offset: const Offset(0, 7)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompactModeIntro(
                    icon: Icons.extension_rounded,
                    title: 'Team Scramble',
                    subtitle: t('Unscramble words. Score for your team.',
                        'Kelimeleri çöz. Takımına puan kazandır.'),
                    startColor: const Color(0xFF00C2FF),
                    endColor: const Color(0xFFEC4899),
                  ),
                  const SizedBox(height: 12),
                  _ScrambleChoiceGroup(
                    title: t('Level', 'Seviye'),
                    options: const ['Mixed', 'A1-A2', 'B1-B2', 'C1-C2'],
                    selected: selectedLevel,
                    labels: const ['All', 'Core', 'Mid', 'Pro'],
                    onSelected: rebuildDeckForLevel,
                  ),
                  const SizedBox(height: 10),
                  _ScrambleChoiceGroup(
                    title: t('Turn Time', 'Tur Süresi'),
                    options: const ['30s', '45s', '60s'],
                    selected: '${turnSeconds}s',
                    labels: const ['Fast', 'Classic', 'Relax'],
                    onSelected: (value) {
                      setState(() {
                        turnSeconds =
                            int.tryParse(value.replaceAll('s', '')) ?? 45;
                        secondsLeft = turnSeconds;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _ScrambleChoiceGroup(
                    title: t('Target', 'Hedef'),
                    options: const ['10', '15', '20'],
                    selected: '$targetScore',
                    labels: const ['Short', 'Match', 'Long'],
                    onSelected: (value) {
                      setState(() {
                        targetScore = int.tryParse(value) ?? 10;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ScrambleTeamNameField(
                          label: t('Team A', 'Takım A'),
                          controller: teamAController,
                          color: const Color(0xFF00C2FF),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _ScrambleTeamNameField(
                          label: t('Team B', 'Takım B'),
                          controller: teamBController,
                          color: const Color(0xFFFF8A00),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CompactSetupNote(
                    icon: Icons.travel_explore_rounded,
                    title: t('Online fallback', 'Online yedek'),
                    subtitle: t('Real player first. Voxa AI if no one joins.',
                        'Önce gerçek oyuncu. Kimse yoksa Voxa AI.'),
                    code:
                        '${(deck.isEmpty ? widget.allWords.length : deck.length)} ${t('pool', 'havuz')}',
                    color: const Color(0xFF00C2FF),
                  ),
                  const SizedBox(height: 14),
                  _TabooPrimaryButton(
                    label: t('Find Online Match', 'Online Rakip Bul'),
                    icon: Icons.travel_explore_rounded,
                    onTap: startOnlineMatchmaking,
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _ScrambleSmallButton(
                          label: t('Local', 'Lokal'),
                          icon: Icons.play_arrow_rounded,
                          color: const Color(0xFF8B5CF6),
                          onTap: () => startMatch(),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _ScrambleSmallButton(
                          label: t('Voxa AI', 'Voxa AI'),
                          icon: Icons.smart_toy_rounded,
                          color: const Color(0xFF00C2FF),
                          onTap: () => startMatch(online: true, vsAI: true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchmaking() {
    final dots = '.' * ((matchmakingSeconds % 3) + 1);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00C2FF), Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withAlpha(42),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: pulseController,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(18),
                    border: Border.all(color: Colors.white.withAlpha(32)),
                  ),
                  child: const Icon(Icons.radar_rounded,
                      color: Colors.white, size: 42),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${t('Finding online opponent', 'Online rakip aranıyor')}$dots',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4),
              ),
              const SizedBox(height: 8),
              Text(
                t('If nobody joins, Voxa AI will match with you automatically.',
                    'Kimse bulunamazsa Voxa AI otomatik eşleşecek.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12.2,
                    height: 1.28,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (matchmakingSeconds / 4).clamp(0.0, 1.0),
                  minHeight: 9,
                  backgroundColor: Colors.white.withAlpha(34),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.black.withAlpha(22),
                  border: Border.all(color: Colors.white.withAlpha(18)),
                ),
                child: Text(
                  matchmakingSeconds >= 3
                      ? t('Preparing AI fallback...',
                          'Voxa AI rakibi kuruluyor...')
                      : t('Checking rooms and live players...',
                          'Odalar ve aktif oyuncular kontrol ediliyor...'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 18),
              _ScrambleSmallButton(
                label: t('Cancel Search', 'Aramayı İptal Et'),
                icon: Icons.close_rounded,
                color: const Color(0xFF111827),
                onTap: cancelMatchmaking,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    final item = currentItem;
    if (item == null) return _buildEmpty();

    final activeColor =
        activeTeam == 0 ? const Color(0xFF00C2FF) : const Color(0xFFFF8A00);
    final activeName = activeTeam == 0
        ? (teamAController.text.trim().isEmpty
            ? 'Team A'
            : teamAController.text.trim())
        : (teamBController.text.trim().isEmpty
            ? 'Team B'
            : teamBController.text.trim());
    final progress =
        turnSeconds <= 0 ? 0.0 : (secondsLeft / turnSeconds).clamp(0.0, 1.0);

    return Column(
      children: [
        _buildTopBar(t('Unscramble before the timer ends.',
            'Süre bitmeden kelimeyi çöz.')),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Expanded(
                  child: _ScrambleTeamScoreCard(
                      name: teamAController.text.trim().isEmpty
                          ? 'Team A'
                          : teamAController.text.trim(),
                      score: teamAScore,
                      color: const Color(0xFF00C2FF),
                      active: activeTeam == 0,
                      pop: lastScoredTeam == 0)),
              const SizedBox(width: 10),
              Expanded(
                  child: _ScrambleTeamScoreCard(
                      name: teamBController.text.trim().isEmpty
                          ? 'Team B'
                          : teamBController.text.trim(),
                      score: teamBScore,
                      color: const Color(0xFFFF8A00),
                      active: activeTeam == 1,
                      pop: lastScoredTeam == 1)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withAlpha(8),
              border: Border.all(color: activeColor.withAlpha(38)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _ScrambleMiniBadge(
                        icon: Icons.groups_rounded,
                        label: activeName,
                        color: activeColor),
                    const SizedBox(width: 8),
                    _ScrambleMiniBadge(
                        icon: Icons.flag_rounded,
                        label: '$teamAScore-$teamBScore / $targetScore',
                        color: const Color(0xFF8B5CF6)),
                    const Spacer(),
                    if (onlineMode) ...[
                      _ScrambleMiniBadge(
                        icon: aiOpponent
                            ? Icons.smart_toy_rounded
                            : Icons.wifi_tethering_rounded,
                        label: aiOpponent ? 'Voxa AI' : 'Online',
                        color: aiOpponent
                            ? const Color(0xFF00C2FF)
                            : const Color(0xFF22C55E),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      'R$round',
                      style: TextStyle(
                          color: Colors.white.withAlpha(160),
                          fontSize: 11,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withAlpha(12),
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$secondsLeft s',
                  style: TextStyle(
                      color: activeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: ScaleTransition(
              scale: pulseController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF101426).withAlpha(238),
                      activeColor.withAlpha(28),
                      const Color(0xFFEC4899).withAlpha(20),
                    ],
                  ),
                  border: Border.all(color: activeColor.withAlpha(42)),
                  boxShadow: [
                    BoxShadow(
                        color: activeColor.withAlpha(20),
                        blurRadius: 24,
                        offset: const Offset(0, 14)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      t('Unscramble this word', 'Bu kelimeyi çöz'),
                      style: TextStyle(
                          color: Colors.white.withAlpha(170),
                          fontSize: 12,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          scrambledWord.split('').asMap().entries.map((entry) {
                        return _ScrambleLetterTile(
                          letter: entry.value.toUpperCase(),
                          color: activeColor,
                          index: entry.key,
                          thinking: aiThinking,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.black.withAlpha(28),
                        border: Border.all(color: Colors.white.withAlpha(12)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_rounded,
                              color: Colors.white.withAlpha(190), size: 18),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              hintFor(item),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white.withAlpha(168),
                                  fontSize: 11.3,
                                  height: 1.28,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (aiThinking) ...[
                      const SizedBox(height: 14),
                      _ScrambleThinkingCard(
                        label:
                            t('Voxa AI is thinking...', 'Voxa AI düşünüyor...'),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: answerController,
                      enabled: !showFeedback &&
                          !aiThinking &&
                          !(aiOpponent && activeTeam == 1),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => submitAnswer(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900),
                      cursorColor: activeColor,
                      decoration: InputDecoration(
                        hintText: t('Type the word...', 'Kelimeyi yaz...'),
                        hintStyle: TextStyle(
                            color: Colors.white.withAlpha(90),
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                        prefixIcon:
                            Icon(Icons.keyboard_rounded, color: activeColor),
                        filled: true,
                        fillColor: Colors.white.withAlpha(8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.white.withAlpha(13)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: activeColor.withAlpha(160)),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.white.withAlpha(10)),
                        ),
                      ),
                    ),
                    if (showFeedback) ...[
                      const SizedBox(height: 12),
                      _ScrambleFeedbackCard(
                          key: ValueKey('scramble_feedback_$feedbackSerial'),
                          label: feedbackText,
                          color: feedbackColor),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ScrambleSmallButton(
                            label: t('Shuffle', 'Karıştır'),
                            icon: Icons.shuffle_rounded,
                            color: const Color(0xFF8B5CF6),
                            onTap: shuffleCurrent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ScrambleSmallButton(
                            label: t('Pass', 'Pas'),
                            icon: Icons.skip_next_rounded,
                            color: const Color(0xFFFFB020),
                            onTap: passWord,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _TabooPrimaryButton(
                      label: t('Submit Answer', 'Cevabı Gönder'),
                      icon: Icons.check_rounded,
                      onTap: submitAnswer,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinish() {
    final teamAName = teamAController.text.trim().isEmpty
        ? 'Team A'
        : teamAController.text.trim();
    final teamBName = teamBController.text.trim().isEmpty
        ? 'Team B'
        : teamBController.text.trim();
    final aWins = teamAScore >= teamBScore;
    final winnerName = aWins ? teamAName : teamBName;
    final winnerColor =
        aWins ? const Color(0xFF00C2FF) : const Color(0xFFFF8A00);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        children: [
          _buildTopBar(
              t('Match results and restart.', 'Maç sonucu ve yeniden başlat.')),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  winnerColor.withAlpha(34),
                  const Color(0xFF101426).withAlpha(238),
                  const Color(0xFFEC4899).withAlpha(28),
                ],
              ),
              border: Border.all(color: winnerColor.withAlpha(46)),
              boxShadow: [
                BoxShadow(
                    color: winnerColor.withAlpha(24),
                    blurRadius: 24,
                    offset: const Offset(0, 14)),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [winnerColor, const Color(0xFFEC4899)]),
                    boxShadow: [
                      BoxShadow(
                          color: winnerColor.withAlpha(40),
                          blurRadius: 14,
                          offset: const Offset(0, 7)),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 42),
                ),
                const SizedBox(height: 14),
                Text(
                  t('$winnerName wins!', '$winnerName kazandı!'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  onlineMode
                      ? (aiOpponent
                          ? 'Online AI Match • $teamAScore - $teamBScore'
                          : 'Online Match • $teamAScore - $teamBScore')
                      : '$teamAScore - $teamBScore',
                  style: TextStyle(
                      color: Colors.white.withAlpha(190),
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                _ScrambleRewardSummaryCard(
                  xp: lastRewardXP == 0
                      ? calculateScrambleRewardXP()
                      : lastRewardXP,
                  mastered: teamAScore,
                  won: teamAScore >= teamBScore,
                  isEnglish: widget.isEnglish,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                        child: _ScrambleTeamScoreCard(
                            name: teamAName,
                            score: teamAScore,
                            color: const Color(0xFF00C2FF),
                            active: aWins,
                            pop: false)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _ScrambleTeamScoreCard(
                            name: teamBName,
                            score: teamBScore,
                            color: const Color(0xFFFF8A00),
                            active: !aWins,
                            pop: false)),
                  ],
                ),
                const SizedBox(height: 18),
                _TabooPrimaryButton(
                  label: t('Play Again', 'Tekrar Oyna'),
                  icon: Icons.replay_rounded,
                  onTap: () => startMatch(online: onlineMode, vsAI: aiOpponent),
                ),
                const SizedBox(height: 10),
                _ScrambleSmallButton(
                  label: t('Back to Setup', 'Ayarlara Dön'),
                  icon: Icons.tune_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: restartSetup,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrambleRewardSummaryCard extends StatelessWidget {
  final int xp;
  final int mastered;
  final bool won;
  final bool isEnglish;

  const _ScrambleRewardSummaryCard({
    required this.xp,
    required this.mastered,
    required this.won,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB020).withAlpha(22),
            Colors.white.withAlpha(7),
            const Color(0xFF22C55E).withAlpha(15),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFB020), Color(0xFFFF4FD8)]),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFFB020).withAlpha(24),
                    blurRadius: 14,
                    offset: const Offset(0, 8)),
              ],
            ),
            child:
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Progress saved', 'İlerleme kaydedildi'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  won
                      ? t('Win bonus, score XP and mastered words added.',
                          'Galibiyet bonusu, skor XP ve öğrenilen kelimeler eklendi.')
                      : t('Practice XP and mastered words added.',
                          'Pratik XP ve öğrenilen kelimeler eklendi.'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withAlpha(145),
                      fontSize: 10.3,
                      height: 1.2,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFFFFB020).withAlpha(14),
                  border:
                      Border.all(color: const Color(0xFFFFB020).withAlpha(35)),
                ),
                child: Text(
                  '+$xp XP',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.3,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+$mastered ${t('words', 'kelime')}',
                style: TextStyle(
                    color: Colors.white.withAlpha(160),
                    fontSize: 9.4,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactModeIntro extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;

  const _CompactModeIntro({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [startColor, endColor]),
            boxShadow: [
              BoxShadow(
                  color: endColor.withAlpha(16),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white.withAlpha(158),
                    fontSize: 11.2,
                    height: 1.18,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactSetupNote extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String code;
  final Color color;

  const _CompactSetupNote({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withAlpha(7),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(14),
              border: Border.all(color: color.withAlpha(34)),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.4,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withAlpha(135),
                      fontSize: 10.2,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.black.withAlpha(22),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.3,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrambleChoiceGroup extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final List<String> labels;
  final ValueChanged<String> onSelected;

  const _ScrambleChoiceGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.labels,
    required this.onSelected,
  });

  _LevelStyle styleForOption(String value) {
    switch (value) {
      case 'Mixed':
        return const _LevelStyle(Color(0xFF7C3AED), Color(0xFFEC4899));
      case 'A1-A2':
        return const _LevelStyle(Color(0xFF00C2FF), Color(0xFF22C55E));
      case 'B1-B2':
        return const _LevelStyle(Color(0xFFF59E0B), Color(0xFFEF4444));
      case 'C1-C2':
        return const _LevelStyle(Color(0xFFA78BFA), Color(0xFFFDE68A));
      case '30s':
        return const _LevelStyle(Color(0xFF22D3EE), Color(0xFF2563EB));
      case '45s':
        return const _LevelStyle(Color(0xFF8B5CF6), Color(0xFFEC4899));
      case '60s':
        return const _LevelStyle(Color(0xFF10B981), Color(0xFF06B6D4));
      case '10':
        return const _LevelStyle(Color(0xFF8B5CF6), Color(0xFFEC4899));
      case '15':
        return const _LevelStyle(Color(0xFF00C2FF), Color(0xFF8B5CF6));
      case '20':
        return const _LevelStyle(Color(0xFFFF8A00), Color(0xFFEC4899));
      default:
        return const _LevelStyle(Color(0xFF94A3B8), Color(0xFF475569));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        Row(
          children: List.generate(options.length, (index) {
            final option = options[index];
            final selectedOption = selected == option;
            final style = styleForOption(option);
            final label = index < labels.length ? labels[index] : '';

            return Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(right: index == options.length - 1 ? 0 : 7),
                child: GestureDetector(
                  onTap: () => onSelected(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: options.length == 4 ? 50 : 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: selectedOption
                          ? LinearGradient(colors: [style.start, style.end])
                          : null,
                      color: selectedOption ? null : Colors.white.withAlpha(8),
                      border: Border.all(
                          color: selectedOption
                              ? Colors.white.withAlpha(42)
                              : Colors.white.withAlpha(13)),
                      boxShadow: selectedOption
                          ? [
                              BoxShadow(
                                  color: style.end.withAlpha(32),
                                  blurRadius: 13,
                                  offset: const Offset(0, 7)),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: options.length == 4 ? 11.0 : 12.2,
                              fontWeight: FontWeight.w900),
                        ),
                        if (label.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white
                                    .withAlpha(selectedOption ? 210 : 115),
                                fontSize: 8.6,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ScrambleTeamNameField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final ValueChanged<String> onChanged;

  const _ScrambleTeamNameField({
    required this.label,
    required this.controller,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
          color: Colors.white, fontSize: 12.6, fontWeight: FontWeight.w900),
      cursorColor: color,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.white.withAlpha(120),
            fontSize: 10,
            fontWeight: FontWeight.w800),
        prefixIcon: Icon(Icons.groups_rounded, color: color, size: 18),
        filled: true,
        fillColor: color.withAlpha(9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color.withAlpha(35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color.withAlpha(100)),
        ),
      ),
    );
  }
}

class _ScrambleTeamScoreCard extends StatelessWidget {
  final String name;
  final int score;
  final Color color;
  final bool active;
  final bool pop;

  const _ScrambleTeamScoreCard({
    required this.name,
    required this.score,
    required this.color,
    required this.active,
    required this.pop,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutBack,
      scale: pop ? 1.045 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: color.withAlpha(active ? 22 : 11),
          border: Border.all(color: color.withAlpha(active || pop ? 84 : 28)),
          boxShadow: active || pop
              ? [
                  BoxShadow(
                      color: color.withAlpha(pop ? 34 : 24),
                      blurRadius: pop ? 20 : 16,
                      offset: const Offset(0, 8)),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
                pop
                    ? Icons.add_circle_rounded
                    : active
                        ? Icons.bolt_rounded
                        : Icons.groups_rounded,
                color: color,
                size: 20),
            const SizedBox(height: 6),
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child));
              },
              child: Text(
                '$score',
                key: ValueKey('score_$name$score'),
                style: TextStyle(
                    color: color, fontSize: 24, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrambleMiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ScrambleMiniBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(12),
        border: Border.all(color: color.withAlpha(34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.2,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ScrambleLetterTile extends StatefulWidget {
  final String letter;
  final Color color;
  final int index;
  final bool thinking;

  const _ScrambleLetterTile({
    required this.letter,
    required this.color,
    required this.index,
    required this.thinking,
  });

  @override
  State<_ScrambleLetterTile> createState() => _ScrambleLetterTileState();
}

class _ScrambleLetterTileState extends State<_ScrambleLetterTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 760 + (widget.index * 45)),
      lowerBound: 0.96,
      upperBound: 1.06,
    );

    if (widget.thinking) {
      Future.delayed(Duration(milliseconds: widget.index * 80), () {
        if (mounted) controller.repeat(reverse: true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _ScrambleLetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.thinking && !oldWidget.thinking) {
      Future.delayed(Duration(milliseconds: widget.index * 80), () {
        if (mounted) controller.repeat(reverse: true);
      });
    }

    if (!widget.thinking && oldWidget.thinking) {
      controller.stop();
      controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = widget.thinking ? controller.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 42,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withAlpha(widget.thinking ? 100 : 80),
                  Colors.white.withAlpha(widget.thinking ? 20 : 13),
                ],
              ),
              border: Border.all(
                  color: widget.color.withAlpha(widget.thinking ? 76 : 58)),
              boxShadow: [
                BoxShadow(
                    color: widget.color.withAlpha(widget.thinking ? 34 : 24),
                    blurRadius: widget.thinking ? 18 : 14,
                    offset: const Offset(0, 7)),
              ],
            ),
            child: Text(
              widget.letter,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );
  }
}

class _ScrambleFeedbackCard extends StatelessWidget {
  final String label;
  final Color color;

  const _ScrambleFeedbackCard({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withAlpha(18),
          border: Border.all(color: color.withAlpha(48)),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(18),
                blurRadius: 18,
                offset: const Offset(0, 9)),
          ],
        ),
        child: Row(
          children: [
            Icon(
                color == const Color(0xFF22C55E) ||
                        color == const Color(0xFFFF8A00)
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                color: Colors.white,
                size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    height: 1.22,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrambleThinkingCard extends StatelessWidget {
  final String label;

  const _ScrambleThinkingCard({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final pulse = 0.96 + (sin(value * pi) * 0.05);
        return Transform.scale(scale: pulse, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF00C2FF).withAlpha(18),
          border: Border.all(color: const Color(0xFF00C2FF).withAlpha(44)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF00C2FF).withAlpha(18),
                blurRadius: 18,
                offset: const Offset(0, 9)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 19),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    height: 1.22,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrambleSmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScrambleSmallButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha(20),
              Colors.white.withAlpha(7),
            ],
          ),
          border: Border.all(color: color.withAlpha(42)),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamTabooScreen extends StatefulWidget {
  final List<VocabularyItem> words;
  final List<VocabularyItem> allWords;
  final bool isEnglish;

  const TeamTabooScreen({
    super.key,
    required this.words,
    required this.allWords,
    required this.isEnglish,
  });

  @override
  State<TeamTabooScreen> createState() => _TeamTabooScreenState();
}

class _TeamTabooScreenState extends State<TeamTabooScreen>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  late AnimationController pulseController;
  Timer? turnTimer;

  late List<_TabooCardData> cards;
  int cardIndex = 0;
  int activeTeam = 0;
  int teamAScore = 0;
  int teamBScore = 0;
  int round = 1;
  int targetScore = 10;
  int turnSeconds = 45;
  int secondsLeft = 45;
  String selectedTabooLevel = 'Mixed';
  String teamAName = 'Team A';
  String teamBName = 'Team B';
  final TextEditingController teamAController =
      TextEditingController(text: 'Team A');
  final TextEditingController teamBController =
      TextEditingController(text: 'Team B');
  int turnCorrect = 0;
  int turnPass = 0;
  int turnTaboo = 0;
  bool matchStarted = false;
  bool turnRunning = false;
  bool showTurnSummary = false;
  bool matchFinished = false;
  String lastAction = '';

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      lowerBound: 0.98,
      upperBound: 1.02,
    );
    pulseController.value = 1.0;
    cards = const [];
  }

  @override
  void dispose() {
    turnTimer?.cancel();
    teamAController.dispose();
    teamBController.dispose();
    pulseController.dispose();
    super.dispose();
  }

  bool isSingleEnglishWord(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return false;
    if (clean.contains(' ')) return false;
    if (clean.contains('-')) return false;
    if (RegExp(r'[ğüşöçıİĞÜŞÖÇ]').hasMatch(clean)) return false;
    return RegExp(r'^[A-Za-z]+$').hasMatch(clean);
  }

  String cleanEnglishClue(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z]'), '').trim();
  }

  List<VocabularyItem> playableWords() {
    bool playable(VocabularyItem item) {
      return item.word.trim().isNotEmpty &&
          item.meaningTr.trim().isNotEmpty &&
          isSingleEnglishWord(item.word);
    }

    List<VocabularyItem> applyLevel(List<VocabularyItem> source) {
      if (selectedTabooLevel == 'Mixed') return source;

      final allowedLevels = selectedTabooLevel
          .split('-')
          .map((level) => level.toUpperCase().trim())
          .where((level) => level.isNotEmpty)
          .toSet();

      if (allowedLevels.isEmpty) return source;

      return source.where((item) {
        final level = item.level.toUpperCase().trim();
        return allowedLevels.contains(level);
      }).toList();
    }

    final currentLevelSource =
        applyLevel(widget.words.where(playable).toList());
    final currentLevelFallback =
        applyLevel(widget.allWords.where(playable).toList());

    final mixedFallback = widget.allWords.where(playable).toList();

    final picked = currentLevelSource.length >= 12
        ? currentLevelSource
        : currentLevelFallback.length >= 8
            ? currentLevelFallback
            : mixedFallback;

    final seen = <String>{};
    final unique = <VocabularyItem>[];
    for (final item in picked) {
      final key = item.word.toLowerCase().trim();
      if (seen.add(key)) unique.add(item);
    }

    unique.shuffle(random);
    return unique.take(45).toList();
  }

  List<String> importantEnglishWordsFrom(String value) {
    const blocked = {
      'a',
      'an',
      'the',
      'and',
      'or',
      'but',
      'to',
      'of',
      'in',
      'on',
      'at',
      'for',
      'with',
      'without',
      'by',
      'from',
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'can',
      'could',
      'would',
      'should',
      'will',
      'may',
      'might',
      'this',
      'that',
      'these',
      'those',
      'someone',
      'something',
      'people',
      'thing',
      'things',
      'person',
      'used',
      'use',
      'make',
      'makes',
      'get',
      'very',
      'more',
      'most',
      'word',
      'meaning',
      'example',
      'english',
    };

    return value
        .split(RegExp(r'[^A-Za-z]+'))
        .map(cleanEnglishClue)
        .where(isSingleEnglishWord)
        .where((word) => word.length >= 4)
        .where((word) => !blocked.contains(word.toLowerCase()))
        .toSet()
        .toList();
  }

  int clueScore(String clue, VocabularyItem item) {
    final lower = clue.toLowerCase();
    var score = 0;

    if (item.synonyms.any((value) => value.toLowerCase().contains(lower))) {
      score += 8;
    }
    if (item.collocations.any((value) => value.toLowerCase().contains(lower))) {
      score += 6;
    }
    if (item.definitionEn.toLowerCase().contains(lower)) score += 7;
    if (item.exampleEn.toLowerCase().contains(lower)) score += 4;
    if (item.category.toLowerCase().contains(lower)) score += 3;

    score += clue.length.clamp(0, 8);
    return score;
  }

  List<String> forbiddenWordsFor(
      VocabularyItem item, List<VocabularyItem> pool) {
    final result = <String>{};

    void addClue(String value) {
      final clean = cleanEnglishClue(value);
      if (!isSingleEnglishWord(clean)) return;
      if (clean.length < 3) return;
      if (clean.toLowerCase() == item.word.toLowerCase().trim()) return;
      result.add(clean);
    }

    final candidates = <String>[];

    for (final synonym in item.synonyms) {
      candidates.addAll(importantEnglishWordsFrom(synonym));
    }

    for (final collocation in item.collocations) {
      candidates.addAll(importantEnglishWordsFrom(collocation));
    }

    candidates.addAll(importantEnglishWordsFrom(item.definitionEn));
    candidates.addAll(importantEnglishWordsFrom(item.exampleEn));

    final sameCategory = pool
        .where(
            (other) => other.id != item.id && other.category == item.category)
        .map((other) => other.word.trim())
        .where(isSingleEnglishWord)
        .toList()
      ..shuffle(random);

    candidates.addAll(sameCategory.take(12));

    final rankedCandidates = candidates
        .where(isSingleEnglishWord)
        .where((clue) => clue.toLowerCase() != item.word.toLowerCase())
        .toSet()
        .toList()
      ..sort((a, b) => clueScore(b, item).compareTo(clueScore(a, item)));

    for (final clue in rankedCandidates) {
      addClue(clue);
      if (result.length >= 5) break;
    }

    final categoryFallback =
        sameCategory.where((word) => word.length >= 4).toList();
    for (final clue in categoryFallback) {
      addClue(clue);
      if (result.length >= 5) break;
    }

    final harderFallback = [
      'describe',
      'object',
      'place',
      'action',
      'reason',
      'feeling',
      'common',
      'daily',
      'similar',
      'opposite',
    ]..shuffle(random);

    for (final clue in harderFallback) {
      addClue(clue);
      if (result.length >= 5) break;
    }

    return result.take(5).toList();
  }

  List<_TabooCardData> buildCards() {
    final pool = playableWords();

    if (pool.isEmpty) return [];

    return pool.where((item) => isSingleEnglishWord(item.word)).map((item) {
      return _TabooCardData(
        word: item.word.trim(),
        meaning: item.meaningTr.trim(),
        level: item.level.trim().isEmpty ? 'A1' : item.level.trim(),
        category: item.category.trim(),
        tabooWords: forbiddenWordsFor(item, pool),
      );
    }).toList();
  }

  void syncTeamNames() {
    final cleanA = teamAController.text.trim();
    final cleanB = teamBController.text.trim();

    teamAName = cleanA.isEmpty ? t('Team A', 'Takım A') : cleanA;
    teamBName = cleanB.isEmpty ? t('Team B', 'Takım B') : cleanB;
  }

  Color get activeTeamColor =>
      activeTeam == 0 ? const Color(0xFF00C2FF) : const Color(0xFFFF8A00);
  Color get otherTeamColor =>
      activeTeam == 0 ? const Color(0xFFFF8A00) : const Color(0xFF00C2FF);

  String get activeTeamName => activeTeam == 0 ? teamAName : teamBName;
  String get otherTeamName => activeTeam == 0 ? teamBName : teamAName;

  int get activeTeamScore => activeTeam == 0 ? teamAScore : teamBScore;
  int get otherTeamScore => activeTeam == 0 ? teamBScore : teamAScore;

  double get timerProgress {
    if (turnSeconds <= 0) return 0;
    return (secondsLeft / turnSeconds).clamp(0.0, 1.0);
  }

  Color get timerColor {
    if (secondsLeft <= 7) return const Color(0xFFFF3B5C);
    if (secondsLeft <= 15) return const Color(0xFFFFB020);
    return const Color(0xFF10B981);
  }

  bool get hasWinner => teamAScore >= targetScore || teamBScore >= targetScore;

  void startMatch() {
    syncTeamNames();
    cards = buildCards();
    if (cards.isEmpty) return;
    setState(() {
      matchStarted = true;
      matchFinished = false;
      activeTeam = 0;
      teamAScore = 0;
      teamBScore = 0;
      round = 1;
      cardIndex = 0;
      turnCorrect = 0;
      turnPass = 0;
      turnTaboo = 0;
      showTurnSummary = false;
      secondsLeft = turnSeconds;
      lastAction = '';
    });
    startTurn();
  }

  void startTurn() {
    turnTimer?.cancel();
    setState(() {
      turnRunning = true;
      showTurnSummary = false;
      turnCorrect = 0;
      turnPass = 0;
      turnTaboo = 0;
      secondsLeft = turnSeconds;
      lastAction = '';
    });

    turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!turnRunning || matchFinished) {
        timer.cancel();
        return;
      }

      if (secondsLeft <= 1) {
        timer.cancel();
        endTurn();
        return;
      }

      setState(() {
        secondsLeft -= 1;
      });
    });
  }

  void endTurn() {
    turnTimer?.cancel();
    if (!mounted) return;

    setState(() {
      turnRunning = false;
      showTurnSummary = true;

      if (hasWinner) {
        matchFinished = true;
        AppProgress.instance.recordTabooResult(
          teamAScore: teamAScore,
          teamBScore: teamBScore,
        );
      }
    });
  }

  void nextCard({required String action}) {
    if (cards.isEmpty || !turnRunning) return;

    setState(() {
      lastAction = action;
      cardIndex = (cardIndex + 1) % cards.length;
    });
  }

  void correct() {
    if (!turnRunning) return;

    setState(() {
      if (activeTeam == 0) {
        teamAScore += 1;
      } else {
        teamBScore += 1;
      }
      turnCorrect += 1;
    });

    if (hasWinner) {
      endTurn();
      return;
    }

    nextCard(action: t('Correct +1', 'Doğru +1'));
  }

  void pass() {
    if (!turnRunning) return;
    setState(() {
      turnPass += 1;
    });
    nextCard(action: t('Pass', 'Pas'));
  }

  void taboo() {
    if (!turnRunning) return;
    setState(() {
      turnTaboo += 1;
    });
    nextCard(action: t('Taboo!', 'Taboo!'));
  }

  void manualEndTurn() {
    if (!turnRunning) return;
    endTurn();
  }

  void nextTeam() {
    if (matchFinished) return;

    setState(() {
      activeTeam = activeTeam == 0 ? 1 : 0;
      if (activeTeam == 0) round += 1;
      showTurnSummary = false;
      turnRunning = false;
      secondsLeft = turnSeconds;
      lastAction = '';
    });

    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted || matchFinished) return;
      startTurn();
    });
  }

  void resetMatch() {
    turnTimer?.cancel();
    setState(() {
      matchStarted = false;
      matchFinished = false;
      turnRunning = false;
      showTurnSummary = false;
      activeTeam = 0;
      teamAScore = 0;
      teamBScore = 0;
      round = 1;
      cardIndex = 0;
      turnCorrect = 0;
      turnPass = 0;
      turnTaboo = 0;
      secondsLeft = turnSeconds;
      lastAction = '';
      syncTeamNames();
      cards = buildCards();
    });
  }

  void changeSeconds(int value) {
    setState(() {
      turnSeconds = value;
      secondsLeft = value;
    });
  }

  void changeTarget(int value) {
    setState(() {
      targetScore = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shouldResetOnBack =
        matchStarted || turnRunning || showTurnSummary || matchFinished;
    final tokens = SpeakeryThemeTokens.of(context);

    return PopScope(
      canPop: !shouldResetOnBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && shouldResetOnBack) {
          resetMatch();
        }
      },
      child: Scaffold(
        backgroundColor: tokens.background,
        body: Stack(
          children: [
            const _LightGameBackground(),
            SafeArea(
              child: matchFinished
                  ? _buildWinner()
                  : !matchStarted
                      ? _buildSetup()
                      : cards.isEmpty
                          ? _buildEmpty()
                          : showTurnSummary
                              ? _buildTurnSummary()
                              : _buildGame(),
            ),
          ],
        ),
      ),
    );
  }

  void handleTabooBack() {
    if (matchStarted || turnRunning || showTurnSummary || matchFinished) {
      resetMatch();
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _buildTopBar(String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: handleTabooBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(16),
                border: Border.all(color: Colors.white.withAlpha(24)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Taboo Teams',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withAlpha(165),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _TabooGlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.groups_2_rounded,
                  color: Color(0xFFEC4899), size: 50),
              const SizedBox(height: 14),
              Text(
                t('Taboo needs more single-word English cards.',
                    'Taboo için daha fazla tek kelimelik İngilizce kart lazım.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              Text(
                t('Switch to Mixed or add more vocabulary, then start again.',
                    'Mixed seç veya daha fazla kelime ekle, sonra tekrar başlat.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _TabooPrimaryButton(
                label: t('Back to setup', 'Ayarlara dön'),
                icon: Icons.tune_rounded,
                onTap: resetMatch,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      child: Column(
        children: [
          _buildTopBar(t('Set match options.', 'Maç ayarlarını seç.')),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF171726),
                  Color(0xFF241A3A),
                  Color(0xFF111827)
                ],
              ),
              border: Border.all(color: Colors.white.withAlpha(14)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFEC4899).withAlpha(18),
                    blurRadius: 14,
                    offset: const Offset(0, 7)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompactModeIntro(
                  icon: Icons.groups_2_rounded,
                  title: t('Team Taboo', 'Takımlı Taboo'),
                  subtitle: t('Explain the word. Avoid forbidden clues.',
                      'Kelimeyi anlat. Yasak ipuçlarından kaç.'),
                  startColor: const Color(0xFF7C3AED),
                  endColor: const Color(0xFFEC4899),
                ),
                const SizedBox(height: 12),
                _TabooLevelSelector(
                  title: t('Level', 'Seviye'),
                  selectedLevel: selectedTabooLevel,
                  onSelected: (level) {
                    setState(() {
                      selectedTabooLevel = level;
                      cards = const [];
                      cardIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _TabooSetupGroup(
                  title: t('Turn Time', 'Tur Süresi'),
                  options: const [30, 45, 60],
                  selected: turnSeconds,
                  suffix: 's',
                  onSelected: changeSeconds,
                ),
                const SizedBox(height: 10),
                _TabooSetupGroup(
                  title: t('Target', 'Hedef'),
                  options: const [10, 15, 20],
                  selected: targetScore,
                  suffix: '',
                  onSelected: changeTarget,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TeamNameField(
                        controller: teamAController,
                        label: t('Team A', 'Takım A'),
                        color: const Color(0xFF00C2FF),
                        onChanged: (_) => syncTeamNames(),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _TeamNameField(
                        controller: teamBController,
                        label: t('Team B', 'Takım B'),
                        color: const Color(0xFFFF8A00),
                        onChanged: (_) => syncTeamNames(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _CompactSetupNote(
                  icon: Icons.hub_rounded,
                  title: t('Local room ready', 'Lokal oda hazır'),
                  subtitle: t('Online sync can be connected later.',
                      'Online senkron sonra bağlanabilir.'),
                  code:
                      'SPK-${((cards.isEmpty ? widget.allWords.length : cards.length) * 7 + targetScore).toString().padLeft(3, '0')}',
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 14),
                _TabooPrimaryButton(
                  label: t('Start Match', 'Maçı Başlat'),
                  icon: Icons.play_arrow_rounded,
                  onTap: startMatch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    final card = cards[cardIndex];
    final urgent = secondsLeft <= 7;

    return Column(
      children: [
        _TabooGameTopBar(
          title: 'Taboo Arena',
          subtitle:
              '${t('Round', 'Tur')} $round • $activeTeamName ${t('turn', 'sırası')}',
          onBack: handleTabooBack,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: _TabooScoreBoard(
            teamAName: teamAName,
            teamBName: teamBName,
            teamAScore: teamAScore,
            teamBScore: teamBScore,
            activeTeam: activeTeam,
            round: round,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: _TabooTimerBar(
            secondsLeft: secondsLeft,
            progress: timerProgress,
            color: timerColor,
            urgent: urgent,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 290),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                    parent: animation, curve: Curves.easeOutCubic);
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0.0),
                      end: Offset.zero,
                    ).animate(curved),
                    child: child,
                  ),
                );
              },
              child: _TabooHeroCard(
                key: ValueKey('${card.word}_$cardIndex'),
                card: card,
                activeColor: activeTeamColor,
                urgent: urgent,
                lastAction: lastAction,
                isEnglish: widget.isEnglish,
              ),
            ),
          ),
        ),
        _TabooActionDock(
          isEnglish: widget.isEnglish,
          onPass: pass,
          onCorrect: correct,
          onTaboo: taboo,
          onEndTurn: manualEndTurn,
        ),
      ],
    );
  }

  Widget _buildTurnSummary() {
    final nextTeamIndex = activeTeam == 0 ? 1 : 0;
    final nextColor =
        nextTeamIndex == 0 ? const Color(0xFF00C2FF) : const Color(0xFFFF8A00);
    final nextName = nextTeamIndex == 0 ? teamAName : teamBName;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: _TabooGlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    activeTeamColor,
                    activeTeamColor.withAlpha(120)
                  ]),
                  boxShadow: [
                    BoxShadow(
                        color: activeTeamColor.withAlpha(55),
                        blurRadius: 16,
                        offset: const Offset(0, 9)),
                  ],
                ),
                child: const Icon(Icons.flag_rounded,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              Text(
                t('Turn Complete', 'Tur Tamamlandı'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.45),
              ),
              const SizedBox(height: 6),
              Text(
                '$activeTeamName  •  +$turnCorrect ${t('points', 'puan')}',
                style: TextStyle(
                    color: activeTeamColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _TabooResultTile(
                          label: t('Correct', 'Doğru'),
                          value: '$turnCorrect',
                          color: const Color(0xFF22C55E))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _TabooResultTile(
                          label: t('Pass', 'Pas'),
                          value: '$turnPass',
                          color: const Color(0xFF64748B))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _TabooResultTile(
                          label: 'Taboo',
                          value: '$turnTaboo',
                          color: const Color(0xFFFF3B5C))),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: nextColor.withAlpha(18),
                  border: Border.all(color: nextColor.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: nextColor.withAlpha(28),
                        border: Border.all(color: nextColor.withAlpha(70)),
                      ),
                      child: Icon(Icons.groups_rounded,
                          color: nextColor, size: 23),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('Get ready', 'Hazırlanın'),
                            style: TextStyle(
                                color: Colors.white.withAlpha(155),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$nextName ${t('plays next', 'sırada')}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _TabooPrimaryButton(
                label: t('Start Next Turn', 'Sonraki Turu Başlat'),
                icon: Icons.arrow_forward_rounded,
                onTap: nextTeam,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinner() {
    final winnerA = teamAScore >= teamBScore;
    final winnerName = winnerA ? teamAName : teamBName;
    final winnerColor =
        winnerA ? const Color(0xFF00C2FF) : const Color(0xFFFF8A00);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      child: Column(
        children: [
          _buildTopBar(t(
              'Final score and match winner.', 'Final skor ve kazanan takım.')),
          const SizedBox(height: 24),
          _TabooGlassPanel(
            child: Column(
              children: [
                ScaleTransition(
                  scale: pulseController,
                  child: Icon(Icons.emoji_events_rounded,
                      color: winnerColor, size: 78),
                ),
                const SizedBox(height: 14),
                Text(
                  t('Winner', 'Kazanan'),
                  style: TextStyle(
                      color: Colors.white.withAlpha(170),
                      fontSize: 13,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  winnerName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _TeamPreviewCard(
                            name: teamAName,
                            color: const Color(0xFF00C2FF),
                            score: teamAScore)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _TeamPreviewCard(
                            name: teamBName,
                            color: const Color(0xFFFF8A00),
                            score: teamBScore)),
                  ],
                ),
                const SizedBox(height: 20),
                _TabooPrimaryButton(
                  label: t('Play Again', 'Tekrar Oyna'),
                  icon: Icons.replay_rounded,
                  onTap: resetMatch,
                ),
                const SizedBox(height: 10),
                _TabooSecondaryButton(
                  label: t('Back to Challenge', 'Challenge’a Dön'),
                  icon: Icons.home_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabooGameTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TabooGameTopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(14),
                border: Border.all(color: Colors.white.withAlpha(22)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 17),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.45),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withAlpha(165),
                      fontSize: 12,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabooScoreBoard extends StatelessWidget {
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  final int activeTeam;
  final int round;

  const _TabooScoreBoard({
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
    required this.activeTeam,
    required this.round,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TeamScoreCard(
            name: teamAName,
            score: teamAScore,
            color: const Color(0xFF00C2FF),
            active: activeTeam == 0,
          ),
        ),
        const SizedBox(width: 9),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withAlpha(55),
            border: Border.all(color: Colors.white.withAlpha(18)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(45),
                  blurRadius: 16,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Round',
                  style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 9,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('$round',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _TeamScoreCard(
            name: teamBName,
            score: teamBScore,
            color: const Color(0xFFFF8A00),
            active: activeTeam == 1,
          ),
        ),
      ],
    );
  }
}

class _TabooHeroCard extends StatelessWidget {
  final _TabooCardData card;
  final Color activeColor;
  final bool urgent;
  final String lastAction;
  final bool isEnglish;

  const _TabooHeroCard({
    super.key,
    required this.card,
    required this.activeColor,
    required this.urgent,
    required this.lastAction,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFFF3B5C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            activeColor.withAlpha(58),
            const Color(0xFF111827).withAlpha(235),
            const Color(0xFF26143A).withAlpha(225),
          ],
        ),
        border: Border.all(
            color: urgent
                ? dangerColor.withAlpha(105)
                : activeColor.withAlpha(78)),
        boxShadow: [
          BoxShadow(
            color: (urgent ? dangerColor : activeColor).withAlpha(35),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _TabooChip(label: card.level, color: activeColor),
              const SizedBox(width: 8),
              Expanded(
                child: _TabooChip(
                  label: card.category.isEmpty
                      ? t('Vocabulary', 'Kelime')
                      : card.category,
                  color: Colors.white.withAlpha(170),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.black.withAlpha(38),
              border: Border.all(color: Colors.white.withAlpha(12)),
            ),
            child: Column(
              children: [
                Text(
                  card.word,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  card.meaning,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withAlpha(175),
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: dangerColor.withAlpha(14),
              border: Border.all(color: dangerColor.withAlpha(45)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block_rounded,
                        color: Color(0xFFFF3B5C), size: 18),
                    const SizedBox(width: 7),
                    Text(
                      t('Forbidden words', 'Yasak kelimeler'),
                      style: const TextStyle(
                          color: Color(0xFFFF6B86),
                          fontSize: 15,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ForbiddenWordGrid(words: card.tabooWords),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 18,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: lastAction.isEmpty
                  ? Text(
                      t('Explain without saying the forbidden words.',
                          'Yasak kelimeleri söylemeden anlat.'),
                      key: const ValueKey('hint'),
                      style: TextStyle(
                          color: Colors.white.withAlpha(125),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700),
                    )
                  : Text(
                      lastAction,
                      key: ValueKey(lastAction),
                      style: TextStyle(
                          color: activeColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForbiddenWordGrid extends StatelessWidget {
  final List<String> words;

  const _ForbiddenWordGrid({required this.words});

  @override
  Widget build(BuildContext context) {
    final safeWords =
        words.isEmpty ? ['word', 'meaning', 'example', 'English'] : words;

    return Column(
      children: [
        for (int i = 0; i < safeWords.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 >= safeWords.length ? 0 : 9),
            child: Row(
              children: [
                Expanded(child: _ForbiddenWordPill(word: safeWords[i])),
                if (i + 1 < safeWords.length) ...[
                  const SizedBox(width: 9),
                  Expanded(child: _ForbiddenWordPill(word: safeWords[i + 1])),
                ] else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
      ],
    );
  }
}

class _TabooActionDock extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onPass;
  final VoidCallback onCorrect;
  final VoidCallback onTaboo;
  final VoidCallback onEndTurn;

  const _TabooActionDock({
    required this.isEnglish,
    required this.onPass,
    required this.onCorrect,
    required this.onTaboo,
    required this.onEndTurn,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.black.withAlpha(45),
        border: Border.all(color: Colors.white.withAlpha(14)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 22,
              offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TabooActionButton(
                  label: t('Pass', 'Pas'),
                  icon: Icons.skip_next_rounded,
                  color: const Color(0xFF64748B),
                  onTap: onPass,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _TabooActionButton(
                  label: t('Correct', 'Doğru'),
                  icon: Icons.check_rounded,
                  color: const Color(0xFF22C55E),
                  onTap: onCorrect,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _TabooActionButton(
                  label: 'Taboo',
                  icon: Icons.warning_rounded,
                  color: const Color(0xFFFF3B5C),
                  onTap: onTaboo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _TabooSecondaryButton(
            label: t('End Turn / Next Team', 'Turu Bitir / Sıradaki Takım'),
            icon: Icons.flag_rounded,
            onTap: onEndTurn,
          ),
        ],
      ),
    );
  }
}

class _TabooCardData {
  final String word;
  final String meaning;
  final String level;
  final String category;
  final List<String> tabooWords;

  const _TabooCardData({
    required this.word,
    required this.meaning,
    required this.level,
    required this.category,
    required this.tabooWords,
  });
}

class _TabooGlassPanel extends StatelessWidget {
  final Widget child;

  const _TabooGlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171726), Color(0xFF2B1F44), Color(0xFF111827)],
        ),
        border: Border.all(color: Colors.white.withAlpha(16)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFEC4899).withAlpha(14),
              blurRadius: 14,
              offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

class _TabooLevelSelector extends StatelessWidget {
  final String title;
  final String selectedLevel;
  final ValueChanged<String> onSelected;

  const _TabooLevelSelector({
    required this.title,
    required this.selectedLevel,
    required this.onSelected,
  });

  _LevelStyle styleForOption(String level) {
    switch (level) {
      case 'Mixed':
        return const _LevelStyle(Color(0xFF7C3AED), Color(0xFFEC4899));
      case 'A1-A2':
        return const _LevelStyle(Color(0xFF00C2FF), Color(0xFF22C55E));
      case 'B1-B2':
        return const _LevelStyle(Color(0xFFF59E0B), Color(0xFFEF4444));
      case 'C1-C2':
        return const _LevelStyle(Color(0xFFA78BFA), Color(0xFFFDE68A));
      default:
        return const _LevelStyle(Color(0xFF94A3B8), Color(0xFF475569));
    }
  }

  String subtitleFor(String level) {
    switch (level) {
      case 'Mixed':
        return 'All';
      case 'A1-A2':
        return 'Core';
      case 'B1-B2':
        return 'Mid';
      case 'C1-C2':
        return 'Pro';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = ['Mixed', 'A1-A2', 'B1-B2', 'C1-C2'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            Text(
              '4 presets',
              style: TextStyle(
                  color: Colors.white.withAlpha(120),
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: levels.map((level) {
            final selected = selectedLevel == level;
            final style = styleForOption(level);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: level == levels.last ? 0 : 7),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: selected
                          ? LinearGradient(colors: [style.start, style.end])
                          : null,
                      color: selected ? null : Colors.white.withAlpha(8),
                      border: Border.all(
                        color: selected
                            ? Colors.white.withAlpha(44)
                            : Colors.white.withAlpha(13),
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: style.end.withAlpha(34),
                                blurRadius: 14,
                                offset: const Offset(0, 7),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          level,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withAlpha(selected ? 255 : 176),
                            fontSize: level == 'Mixed' ? 11.6 : 11.2,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitleFor(level),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withAlpha(selected ? 220 : 110),
                            fontSize: 8.6,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TabooSetupGroup extends StatelessWidget {
  final String title;
  final List<int> options;
  final int selected;
  final String suffix;
  final ValueChanged<int> onSelected;

  const _TabooSetupGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.suffix,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            final active = option == selected;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: option == options.last ? 0 : 8),
                child: GestureDetector(
                  onTap: () => onSelected(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: active
                          ? const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFFEC4899)])
                          : null,
                      color: active ? null : Colors.white.withAlpha(8),
                      border: Border.all(
                          color: active
                              ? Colors.white.withAlpha(34)
                              : Colors.white.withAlpha(14)),
                    ),
                    child: Text(
                      '$option$suffix',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(active ? 255 : 175),
                        fontSize: 13.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TeamNameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color color;
  final ValueChanged<String> onChanged;

  const _TeamNameField({
    required this.controller,
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: 14,
      style: const TextStyle(
          color: Colors.white, fontSize: 12.6, fontWeight: FontWeight.w900),
      cursorColor: color,
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.white.withAlpha(140),
            fontSize: 10.8,
            fontWeight: FontWeight.w700),
        prefixIcon: Icon(Icons.groups_rounded, color: color, size: 18),
        filled: true,
        fillColor: color.withAlpha(14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color.withAlpha(48)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: color.withAlpha(120), width: 1.4),
        ),
      ),
    );
  }
}

class _TeamPreviewCard extends StatelessWidget {
  final String name;
  final Color color;
  final int score;

  const _TeamPreviewCard(
      {required this.name, required this.color, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: color.withAlpha(16),
        border: Border.all(color: color.withAlpha(58)),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_rounded, color: color, size: 22),
          const SizedBox(height: 8),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('$score',
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _TeamScoreCard extends StatelessWidget {
  final String name;
  final int score;
  final Color color;
  final bool active;

  const _TeamScoreCard({
    required this.name,
    required this.score,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withAlpha(active ? 28 : 10),
        border: Border.all(color: color.withAlpha(active ? 90 : 35)),
        boxShadow: active
            ? [
                BoxShadow(
                    color: color.withAlpha(36),
                    blurRadius: 18,
                    offset: const Offset(0, 8)),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(name,
              style: TextStyle(
                  color: Colors.white.withAlpha(active ? 255 : 170),
                  fontSize: 12,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('$score',
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _TabooTimerBar extends StatelessWidget {
  final int secondsLeft;
  final double progress;
  final Color color;
  final bool urgent;

  const _TabooTimerBar({
    required this.secondsLeft,
    required this.progress,
    required this.color,
    required this.urgent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: color.withAlpha(urgent ? 38 : 22),
        border: Border.all(color: color.withAlpha(urgent ? 90 : 55)),
      ),
      child: Row(
        children: [
          Icon(urgent ? Icons.warning_rounded : Icons.timer_rounded,
              color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 11,
                backgroundColor: Colors.white.withAlpha(14),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${secondsLeft}s',
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _TabooChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TabooChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(24),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ForbiddenWordPill extends StatelessWidget {
  final String word;

  const _ForbiddenWordPill({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFFF3B5C).withAlpha(18),
        border: Border.all(color: const Color(0xFFFF3B5C).withAlpha(55)),
      ),
      child: Text(
        word,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _TabooActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TabooActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: color.withAlpha(38),
          border: Border.all(color: color.withAlpha(75)),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(22),
                blurRadius: 14,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 5),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _TabooPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TabooPrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
              colors: [Color(0xFFFF8A00), Color(0xFFEC4899)]),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFEC4899).withAlpha(40),
                blurRadius: 18,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _TabooSecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TabooSecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withAlpha(8),
          border: Border.all(color: Colors.white.withAlpha(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _TabooResultTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TabooResultTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withAlpha(22),
        border: Border.all(color: color.withAlpha(58)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class InlineChallengeArenaSection extends StatefulWidget {
  final List<VocabularyItem> words;
  final List<VocabularyItem> allWords;
  final String selectedLevel;
  final bool isEnglish;
  final ValueChanged<VocabularyItem> onOpenWord;

  const InlineChallengeArenaSection({
    super.key,
    required this.words,
    required this.allWords,
    required this.selectedLevel,
    required this.isEnglish,
    required this.onOpenWord,
  });

  @override
  State<InlineChallengeArenaSection> createState() =>
      _InlineChallengeArenaSectionState();
}

class _InlineChallengeArenaSectionState
    extends State<InlineChallengeArenaSection> {
  String selectedArenaTab = 'Quick';

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  List<VocabularyItem> get cleanAll {
    return widget.allWords
        .where((item) =>
            item.word.trim().isNotEmpty && item.meaningTr.trim().isNotEmpty)
        .toList(growable: false);
  }

  List<VocabularyItem> get cleanCurrent {
    return widget.words
        .where((item) =>
            item.word.trim().isNotEmpty && item.meaningTr.trim().isNotEmpty)
        .toList(growable: false);
  }

  List<VocabularyItem> get sourceWords {
    final current = cleanCurrent;
    final all = cleanAll;
    return current.length >= 4 ? current : all;
  }

  _ChallengeTabStyle get tabStyle {
    switch (selectedArenaTab) {
      case 'Competitive':
        return const _ChallengeTabStyle(
          start: Color(0xFFFF8A00),
          end: Color(0xFFFF4FD8),
          icon: Icons.emoji_events_rounded,
        );
      case 'Party':
        return const _ChallengeTabStyle(
          start: Color(0xFF8B5CF6),
          end: Color(0xFFFF4FD8),
          icon: Icons.groups_2_rounded,
        );
      default:
        return const _ChallengeTabStyle(
          start: Color(0xFF00C2FF),
          end: Color(0xFF8B5CF6),
          icon: Icons.bolt_rounded,
        );
    }
  }

  void showNotEnoughWords() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('Not enough vocabulary for Challenge yet.',
            'Challenge için yeterli kelime yok.')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Route<void> lightweightRoute(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 1),
      reverseTransitionDuration: const Duration(milliseconds: 1),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity:
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        );
      },
    );
  }

  void openMode(String mode) {
    final source = sourceWords;
    final all = cleanAll;
    if (source.length < 4) {
      showNotEnoughWords();
      return;
    }

    Navigator.of(context).push(
      lightweightRoute(
        _ChallengeArenaScreen(
          words: source,
          allWords: all.isEmpty ? source : all,
          isEnglish: widget.isEnglish,
          onOpenWord: widget.onOpenWord,
          initialMode: mode,
        ),
      ),
    );
  }

  void openTaboo() {
    final source = sourceWords;
    final all = cleanAll;
    if (source.length < 4) {
      showNotEnoughWords();
      return;
    }

    Navigator.of(context).push(
      lightweightRoute(
        TeamTabooScreen(
          words: source,
          allWords: all.isEmpty ? source : all,
          isEnglish: widget.isEnglish,
        ),
      ),
    );
  }

  void openScramble() {
    final source = sourceWords;
    final all = cleanAll;
    if (source.length < 4) {
      showNotEnoughWords();
      return;
    }

    Navigator.of(context).push(
      lightweightRoute(
        TeamScrambleScreen(
          words: source,
          allWords: all.isEmpty ? source : all,
          isEnglish: widget.isEnglish,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['Quick', 'Competitive', 'Party'];
    final style = tabStyle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                style.start.withAlpha(58),
                const Color(0xFF0B1020).withAlpha(238),
                style.end.withAlpha(62),
              ],
            ),
            border: Border.all(color: Colors.white.withAlpha(22)),
            boxShadow: [
              BoxShadow(
                color: style.end.withAlpha(24),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EmbeddedChallengeHeader(
                selectedTab: selectedArenaTab,
                tabs: tabs,
                style: style,
                selectedLevel: widget.selectedLevel,
                isEnglish: widget.isEnglish,
                onTabChanged: (tab) {
                  if (tab == selectedArenaTab) return;
                  setState(() => selectedArenaTab = tab);
                },
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  final curved = CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic);
                  return FadeTransition(opacity: curved, child: child);
                },
                child: selectedArenaTab == 'Quick'
                    ? _buildQuick()
                    : selectedArenaTab == 'Competitive'
                        ? _buildCompetitive()
                        : _buildParty(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuick() {
    return Column(
      key: const ValueKey('quick_modes_phase142_final'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArenaSectionTitle(
          title: t('Quick modes', 'Hızlı modlar'),
          subtitle: t('Clean daily runs with visible XP rewards.',
              'Net günlük turlar ve görünür XP ödülleri.'),
        ),
        const SizedBox(height: 10),
        _PremiumArenaModeCard(
          icon: Icons.auto_awesome_rounded,
          title: t('Classic 10', 'Klasik 10'),
          subtitle: t('10 clean questions for a fast warm-up.',
              'Hızlı ısınma için 10 net soru.'),
          chips: [t('10 questions', '10 soru'), '+20 XP', 'Combo'],
          ctaLabel: t('Start', 'Başla'),
          startColor: const Color(0xFF00C2FF),
          endColor: const Color(0xFF8B5CF6),
          onTap: () => openMode('classic'),
        ),
        const SizedBox(height: 10),
        _PremiumArenaModeCard(
          icon: Icons.timer_rounded,
          title: t('Time Attack', 'Zamana Karşı'),
          subtitle: t('Answer under pressure before time runs out.',
              'Süre bitmeden baskı altında cevapla.'),
          chips: ['75s', '+30 XP', t('Timer', 'Süre')],
          ctaLabel: t('Beat Time', 'Süreyi Yen'),
          startColor: const Color(0xFF10B981),
          endColor: const Color(0xFF06B6D4),
          onTap: () => openMode('timed'),
        ),
        const SizedBox(height: 10),
        _PremiumArenaModeCard(
          icon: Icons.calendar_month_rounded,
          title: t('Daily Challenge', 'Günlük Challenge'),
          subtitle: t('One focused run for daily momentum.',
              'Günlük ivme için tek odaklı tur.'),
          chips: [
            t('Daily', 'Günlük'),
            '+50 XP',
            '${AppProgress.instance.dailyChallengeStreak} streak'
          ],
          ctaLabel: t('Today', 'Bugün'),
          startColor: const Color(0xFFF59E0B),
          endColor: const Color(0xFFEF4444),
          onTap: () => openMode('daily'),
        ),
        const SizedBox(height: 10),
        _ArenaFooterPanel(
          icon: Icons.route_rounded,
          title: t('Recommended flow', 'Önerilen akış'),
          subtitle: t('Classic 10 → Time Attack → Daily Challenge.',
              'Klasik 10 → Süreli → Günlük Challenge.'),
          startColor: const Color(0xFF00C2FF),
          endColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildCompetitive() {
    return Column(
      key: const ValueKey('competitive_modes_phase142_final'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArenaSectionTitle(
          title: t('Competitive', 'Rekabet'),
          subtitle: t('Score pressure, streak control and weekly rank.',
              'Skor baskısı, seri kontrolü ve haftalık rank.'),
        ),
        const SizedBox(height: 10),
        _PremiumArenaModeCard(
          icon: Icons.sports_kabaddi_rounded,
          title: t('1v1 Duel', '1v1 Düello'),
          subtitle: t('Beat the rival score and climb the rank.',
              'Rakip skoru geç ve rank yükselt.'),
          chips: ['1v1', '+40 XP', t('Ranked', 'Ranked')],
          ctaLabel: t('Queue', 'Sıraya Gir'),
          startColor: const Color(0xFFFF8A00),
          endColor: const Color(0xFFFF4FD8),
          onTap: () => openMode('duel'),
        ),
        const SizedBox(height: 10),
        _PremiumArenaModeCard(
          icon: Icons.shield_rounded,
          title: t('Survival Mode', 'Hayatta Kalma'),
          subtitle: t('One mistake ends the run. Stay clean.',
              'Bir hata turu bitirir. Temiz kal.'),
          chips: [t('1 life', '1 can'), '+60 XP', t('Hard', 'Zor')],
          ctaLabel: t('Survive', 'Dayan'),
          startColor: const Color(0xFF14B8A6),
          endColor: const Color(0xFF2563EB),
          onTap: () => openMode('survival'),
        ),
        const SizedBox(height: 10),
        _LeaderboardModeCard(isEnglish: widget.isEnglish),
      ],
    );
  }

  Widget _buildParty() {
    return Column(
      key: const ValueKey('party_modes_phase142_final'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArenaSectionTitle(
          title: t('Party games', 'Party oyunları'),
          subtitle: t('Speaking and team word games for class energy.',
              'Sınıf enerjisi için konuşma ve takım oyunları.'),
        ),
        const SizedBox(height: 10),
        _PartyTabooHeroCard(
          title: t('Taboo Teams', 'Takımlı Taboo'),
          subtitle: t('Explain fast. Avoid forbidden words.',
              'Hızlı anlat. Yasak kelimelerden kaç.'),
          chips: [
            t('2 Teams', '2 Takım'),
            '+Team XP',
            t('Speaking', 'Speaking')
          ],
          ctaLabel: t('Start Match', 'Maçı Başlat'),
          onTap: openTaboo,
        ),
        const SizedBox(height: 10),
        _PartyScrambleCard(
          title: t('Team Scramble', 'Takımlı Scramble'),
          subtitle: t('Unscramble before the timer ends.',
              'Süre bitmeden karışık kelimeyi çöz.'),
          chips: [t('2 Teams', '2 Takım'), '+Team XP', t('Puzzle', 'Puzzle')],
          ctaLabel: t('Start Puzzle', 'Puzzle Başlat'),
          onTap: openScramble,
        ),
        const SizedBox(height: 10),
        _PartyRotationCard(isEnglish: widget.isEnglish),
      ],
    );
  }
}

class _EmbeddedChallengeHeader extends StatelessWidget {
  final String selectedTab;
  final List<String> tabs;
  final _ChallengeTabStyle style;
  final String selectedLevel;
  final bool isEnglish;
  final ValueChanged<String> onTabChanged;

  const _EmbeddedChallengeHeader({
    required this.selectedTab,
    required this.tabs,
    required this.style,
    required this.selectedLevel,
    required this.isEnglish,
    required this.onTabChanged,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    final levelText = selectedLevel == 'All'
        ? t('All levels', 'Tüm seviyeler')
        : selectedLevel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style.start.withAlpha(52),
            Colors.white.withAlpha(12),
            style.end.withAlpha(42),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [style.start, style.end]),
                  boxShadow: [
                    BoxShadow(
                        color: style.end.withAlpha(42),
                        blurRadius: 18,
                        offset: const Offset(0, 9)),
                  ],
                ),
                child: Icon(style.icon, color: Colors.white, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('Challenge Arena', 'Challenge Arena'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.55,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      t('Fast modes, XP rewards and team games.',
                          'Hızlı modlar, XP ödülleri ve takım oyunları.'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(198),
                        fontSize: 12.8,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withAlpha(10),
                  border: Border.all(color: Colors.white.withAlpha(15)),
                ),
                child: Text(
                  levelText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.2,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ArenaTabSwitch(
            tabs: tabs,
            selected: selectedTab,
            accentStart: style.start,
            accentEnd: style.end,
            onChanged: onTabChanged,
          ),
        ],
      ),
    );
  }
}

class _ChallengeTabStyle {
  final Color start;
  final Color end;
  final IconData icon;
  const _ChallengeTabStyle({
    required this.start,
    required this.end,
    required this.icon,
  });
}

class _ArenaFooterPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;

  const _ArenaFooterPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              startColor.withAlpha(26),
              const Color(0xFF0B1020).withAlpha(220),
              endColor.withAlpha(24),
            ],
          ),
          border: Border.all(color: Colors.white.withAlpha(14)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: startColor.withAlpha(16),
                border: Border.all(color: startColor.withAlpha(34)),
              ),
              child: Icon(icon, color: Colors.white.withAlpha(220), size: 17),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.2,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withAlpha(132),
                        fontSize: 10.0,
                        height: 1.18,
                        fontWeight: FontWeight.w700),
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

class _ArenaSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ArenaSectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 23,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF8A00), Color(0xFFFF4FD8)],
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(190),
                    fontSize: 11.4,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
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

class _ArenaTabSwitch extends StatelessWidget {
  final List<String> tabs;
  final String selected;
  final Color accentStart;
  final Color accentEnd;
  final ValueChanged<String> onChanged;

  const _ArenaTabSwitch({
    required this.tabs,
    required this.selected,
    this.accentStart = const Color(0xFFFF8A00),
    this.accentEnd = const Color(0xFFFF4FD8),
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = tabs.indexOf(selected).clamp(0, tabs.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 8) / tabs.length;

        return Container(
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.black.withAlpha(22),
            border: Border.all(color: Colors.white.withAlpha(10)),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(colors: [accentStart, accentEnd]),
                    boxShadow: [
                      BoxShadow(
                        color: accentEnd.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: tabs.map((tab) {
                  final active = selected == tab;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(tab),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            color: Colors.white.withAlpha(active ? 255 : 148),
                            fontSize: 10.5,
                            fontWeight:
                                active ? FontWeight.w900 : FontWeight.w800,
                          ),
                          child: Text(tab,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumArenaModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> chips;
  final String ctaLabel;
  final Color startColor;
  final Color endColor;
  final VoidCallback onTap;

  const _PremiumArenaModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.ctaLabel,
    required this.startColor,
    required this.endColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _PressableScale(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 124),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                startColor.withAlpha(125),
                const Color(0xFF101426).withAlpha(224),
                endColor.withAlpha(138),
              ],
            ),
            border: Border.all(color: Colors.white.withAlpha(24)),
            boxShadow: [
              BoxShadow(
                color: endColor.withAlpha(22),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [startColor, endColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: endColor.withAlpha(36),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(205),
                        fontSize: 12.0,
                        height: 1.16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: chips
                          .take(3)
                          .map((chip) => _CleanArenaChip(label: chip))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _CleanCTA(label: ctaLabel, color: endColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartyTabooHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> chips;
  final String ctaLabel;
  final VoidCallback onTap;

  const _PartyTabooHeroCard({
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const startColor = Color(0xFF8B5CF6);
    const midColor = Color(0xFFEC4899);
    const endColor = Color(0xFFFF8A00);

    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 112,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              startColor.withAlpha(72),
              const Color(0xFF101426).withAlpha(232),
              endColor.withAlpha(70),
            ],
          ),
          border: Border.all(color: midColor.withAlpha(52)),
          boxShadow: [
            BoxShadow(
              color: midColor.withAlpha(26),
              blurRadius: 22,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [startColor, midColor, endColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: midColor.withAlpha(42),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: const Icon(Icons.groups_2_rounded,
                  color: Colors.white, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(176),
                      fontSize: 9.8,
                      height: 1.16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: chips
                        .take(3)
                        .map((chip) => _CleanArenaChip(label: chip))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _CleanCTA(label: ctaLabel, color: midColor),
          ],
        ),
      ),
    );
  }
}

class _PartyScrambleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> chips;
  final String ctaLabel;
  final VoidCallback onTap;

  const _PartyScrambleCard({
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.ctaLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const startColor = Color(0xFF00C2FF);
    const midColor = Color(0xFF8B5CF6);
    const endColor = Color(0xFFEC4899);

    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 112,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              startColor.withAlpha(55),
              const Color(0xFF101426).withAlpha(234),
              endColor.withAlpha(64),
            ],
          ),
          border: Border.all(color: midColor.withAlpha(48)),
          boxShadow: [
            BoxShadow(
              color: midColor.withAlpha(24),
              blurRadius: 22,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [startColor, midColor, endColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: midColor.withAlpha(40),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: const Icon(Icons.extension_rounded,
                  color: Colors.white, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(176),
                      fontSize: 9.8,
                      height: 1.16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: chips
                        .take(3)
                        .map((chip) => _CleanArenaChip(label: chip))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _CleanCTA(label: ctaLabel, color: endColor),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardModeCard extends StatelessWidget {
  final bool isEnglish;

  const _LeaderboardModeCard({required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    const entries = [
      _ArenaLeaderboardEntry(name: 'Lina', xp: 1840, streak: 16),
      _ArenaLeaderboardEntry(name: 'Mert', xp: 1710, streak: 13),
      _ArenaLeaderboardEntry(name: 'Sena', xp: 1605, streak: 11),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD166).withAlpha(22),
            const Color(0xFF101426).withAlpha(232),
            const Color(0xFF8B5CF6).withAlpha(26),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD166).withAlpha(16),
                  border:
                      Border.all(color: const Color(0xFFFFD166).withAlpha(42)),
                ),
                child: const Icon(Icons.leaderboard_rounded,
                    color: Color(0xFFFFD166), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('Leaderboard', 'Liderlik'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.4,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t('This week\'s top players.', 'Bu haftanın en iyileri.'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(145),
                        fontSize: 10.2,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withAlpha(8),
                  border: Border.all(color: Colors.white.withAlpha(12)),
                ),
                child: Text(
                  t('This week', 'Bu hafta'),
                  style: TextStyle(
                    color: Colors.white.withAlpha(210),
                    fontSize: 9.6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            final rank = index + 1;
            final color = rank == 1
                ? const Color(0xFFFFD166)
                : rank == 2
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFFFB923C);
            return Padding(
              padding:
                  EdgeInsets.only(bottom: index == entries.length - 1 ? 0 : 6),
              child: _LeaderboardMiniRow(
                rank: rank,
                name: entry.name,
                xp: entry.xp,
                streak: entry.streak,
                color: color,
              ),
            );
          }),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withAlpha(7),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_rounded,
                    color: Colors.white.withAlpha(180), size: 15),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    t('Your preview rank', 'Senin önizleme sıran'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(175),
                      fontSize: 10.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Text(
                  '#12',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.3,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 10),
                Text(
                  '980 XP',
                  style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 10.2,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardMiniRow extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final int streak;
  final Color color;

  const _LeaderboardMiniRow({
    required this.rank,
    required this.name,
    required this.xp,
    required this.streak,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withAlpha(10),
        border: Border.all(color: color.withAlpha(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(16),
              border: Border.all(color: color.withAlpha(40)),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                  color: color, fontSize: 9.8, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.2,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$xp XP',
            style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 10.0,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withAlpha(8),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Text(
              '$streak streak',
              style: TextStyle(
                  color: Colors.white.withAlpha(190),
                  fontSize: 8.9,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyRotationCard extends StatelessWidget {
  final bool isEnglish;

  const _PartyRotationCard({required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withAlpha(6),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(8),
              border: Border.all(color: Colors.white.withAlpha(12)),
            ),
            child: Icon(Icons.route_rounded,
                color: Colors.white.withAlpha(180), size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Classroom rotation', 'Sinif rotasyonu'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  t('Play Taboo for speaking, then Scramble for spelling. Swap teams after each round.',
                      'Once Taboo ile konus, sonra Scramble ile yazimi pekistir. Her turdan sonra takimlari degistir.'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 10.6,
                      fontWeight: FontWeight.w700,
                      height: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        scale: pressed ? 0.985 : 1.0,
        child: widget.child,
      ),
    );
  }
}

class _CleanArenaChip extends StatelessWidget {
  final String label;

  const _CleanArenaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withAlpha(10),
        border: Border.all(color: Colors.white.withAlpha(13)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withAlpha(220),
          fontSize: 9.1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CleanCTA extends StatelessWidget {
  final String label;
  final Color color;

  const _CleanCTA({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(colors: [color.withAlpha(210), color]),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(26),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.7,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

class _ArenaAnswerFeedback extends StatelessWidget {
  final bool correct;
  final String mode;
  final int combo;
  final int streak;
  final Color color;
  final bool isEnglish;

  const _ArenaAnswerFeedback({
    required this.correct,
    required this.mode,
    required this.combo,
    required this.streak,
    required this.color,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  String get message {
    if (correct) {
      if (mode == 'timed') {
        return t('Speed hit. Timer pressure handled.',
            'Hızlı vuruş. Süre baskısı kontrol edildi.');
      }
      if (mode == 'duel') {
        return t('Point pressure applied to the rival.',
            'Rakibe skor baskısı uygulandı.');
      }
      if (mode == 'survival') {
        return t(
            'Shield intact. Streak protected.', 'Kalkan sağlam. Seri korundu.');
      }
      if (mode == 'daily') {
        return t('Daily streak momentum gained.',
            'Günlük seri momentumu kazanıldı.');
      }
      return t('Clean answer. Combo glow activated.',
          'Temiz cevap. Combo glow aktif.');
    }

    if (mode == 'survival') {
      return t(
          'Survival mistake. Run will end.', 'Survival hatası. Tur bitecek.');
    }
    if (mode == 'duel') {
      return t('Rival gets a chance. Recover fast.',
          'Rakip fırsat yakaladı. Hızlı toparlan.');
    }
    if (mode == 'timed') {
      return t(
          'Missed under pressure. Keep tempo.', 'Baskıda kaçtı. Tempoyu koru.');
    }
    return t('Saved for review. Learn and move on.',
        'Tekrar için kaydedildi. Öğren ve devam et.');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      scale: 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          color: color.withAlpha(18),
          border: Border.all(color: color.withAlpha(44)),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(18),
                blurRadius: 18,
                offset: const Offset(0, 9)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(20),
                border: Border.all(color: color.withAlpha(52)),
              ),
              child: Icon(
                  correct ? Icons.check_rounded : Icons.priority_high_rounded,
                  color: Colors.white,
                  size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.6,
                    height: 1.22,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.black.withAlpha(24),
                border: Border.all(color: Colors.white.withAlpha(10)),
              ),
              child: Text(
                correct ? 'x$combo' : '$streak streak',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeArenaQuestion {
  final VocabularyItem item;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
  final String type;

  const _ChallengeArenaQuestion({
    required this.item,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
    required this.type,
  });
}

class _ChallengeArenaScreen extends StatefulWidget {
  final List<VocabularyItem> words;
  final List<VocabularyItem> allWords;
  final bool isEnglish;
  final ValueChanged<VocabularyItem> onOpenWord;
  final String? initialMode;

  const _ChallengeArenaScreen({
    required this.words,
    required this.allWords,
    required this.isEnglish,
    required this.onOpenWord,
    this.initialMode,
  });

  @override
  State<_ChallengeArenaScreen> createState() => _ChallengeArenaScreenState();
}

class _ChallengeArenaScreenState extends State<_ChallengeArenaScreen>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  late List<_ChallengeArenaQuestion> questions;
  int currentIndex = 0;
  int score = 0;
  int streak = 0;
  int bestStreak = 0;
  int combo = 1;
  int earnedXP = 0;
  int opponentScore = 0;
  String selectedLeaderboardTab = 'Weekly';
  String? selectedAnswer;
  bool answered = false;
  bool finished = false;
  bool started = false;
  bool matchmaking = false;
  bool survivalEndedByMistake = false;
  String selectedArenaMode = 'classic';
  String opponentName = 'NovaFox';
  late AnimationController pulseController;
  Timer? arenaTimer;
  int secondsLeft = 0;
  int totalSeconds = 0;

  static const List<_ArenaLeaderboardEntry> _seedLeaderboard = [
    _ArenaLeaderboardEntry(name: 'Lina', xp: 1840, streak: 16),
    _ArenaLeaderboardEntry(name: 'Mert', xp: 1710, streak: 13),
    _ArenaLeaderboardEntry(name: 'Sena', xp: 1605, streak: 11),
    _ArenaLeaderboardEntry(name: 'Eren', xp: 1495, streak: 10),
    _ArenaLeaderboardEntry(name: 'Aylin', xp: 1400, streak: 9),
  ];

  List<_ArenaLeaderboardEntry> get arenaLeaderboard {
    final progress = AppProgress.instance;
    final liveRunXP = finished ? 0 : earnedXP;
    final playerXP = max(0, progress.challengeXP + liveRunXP);
    final playerStreak = max(0,
        max(progress.dailyChallengeStreak, max(progress.streak, bestStreak)));
    final entries = <_ArenaLeaderboardEntry>[
      ..._seedLeaderboard,
      _ArenaLeaderboardEntry(
        name: t('You', 'Sen'),
        xp: playerXP,
        streak: playerStreak,
        isCurrentUser: true,
      ),
    ]..sort((a, b) {
        final xpCompare = b.xp.compareTo(a.xp);
        if (xpCompare != 0) return xpCompare;
        return b.streak.compareTo(a.streak);
      });

    return entries;
  }

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    questions = buildQuestions();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      lowerBound: 0.96,
      upperBound: 1.04,
    );

    final mode = widget.initialMode;
    if (mode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (mode == 'duel') {
          startMatchmaking();
        } else {
          startArena(mode);
        }
      });
    }
  }

  @override
  void dispose() {
    arenaTimer?.cancel();
    pulseController.dispose();
    super.dispose();
  }

  List<VocabularyItem> uniqueWords(List<VocabularyItem> source) {
    final seen = <String>{};
    final result = <VocabularyItem>[];

    for (final item in source) {
      final key = item.id.toLowerCase().trim();
      if (key.isEmpty) continue;
      if (seen.add(key)) result.add(item);
    }

    return result;
  }

  bool isPhraseItem(VocabularyItem item) {
    final category = item.category.toLowerCase();
    final pos = item.partOfSpeech.toLowerCase();
    final word = item.word.trim();

    return category.contains('collocation') ||
        category.contains('expression') ||
        category.contains('phrase') ||
        category.contains('idiom') ||
        pos == 'phrase' ||
        pos == 'phrasal verb' ||
        word.contains(' ');
  }

  bool canMakeFill(VocabularyItem item) {
    final word = item.word.trim();
    final example = item.exampleEn.trim();
    if (word.length <= 2 || example.split(' ').length < 3) return false;

    final escaped = RegExp.escape(word);
    final exact =
        RegExp('(?<![A-Za-z])$escaped(?![A-Za-z])', caseSensitive: false);
    return exact.hasMatch(example);
  }

  String blankExample(VocabularyItem item) {
    final word = item.word.trim();
    final example = item.exampleEn.trim();
    if (word.isEmpty || example.isEmpty) return '_____';

    final exact = RegExp('(?<![A-Za-z])${RegExp.escape(word)}(?![A-Za-z])',
        caseSensitive: false);
    if (exact.hasMatch(example)) {
      return example.replaceFirst(exact, '_____');
    }

    return example;
  }

  List<VocabularyItem> playableSource() {
    bool playable(VocabularyItem item) {
      final wordOk = item.word.trim().isNotEmpty;
      final meaningOk = item.meaningTr.trim().isNotEmpty;
      return wordOk && meaningOk;
    }

    final primary = uniqueWords(widget.words).where(playable).toList();
    final fallback = uniqueWords(widget.allWords).where(playable).toList();
    final source = primary.length >= 6 ? primary : fallback;

    final shuffled = [...source]..shuffle(random);
    return shuffled.take(12).toList();
  }

  List<String> optionPool({
    required String type,
    required VocabularyItem current,
    required List<VocabularyItem> source,
  }) {
    final sameLevel = source
        .where((item) => item.id != current.id)
        .where((item) =>
            item.level.toUpperCase().trim() ==
            current.level.toUpperCase().trim())
        .toList();

    final samePos = sameLevel
        .where((item) =>
            item.partOfSpeech.toLowerCase().trim() ==
            current.partOfSpeech.toLowerCase().trim())
        .toList();

    final sameCategory = sameLevel
        .where((item) =>
            item.category.toLowerCase().trim() ==
            current.category.toLowerCase().trim())
        .toList();
    final pool = [
      ...sameCategory,
      ...samePos,
      ...sameLevel,
      ...source.where((item) => item.id != current.id)
    ]..shuffle(random);

    if (type == 'meaning') {
      return pool
          .map((item) => item.meaningTr.trim())
          .where(
              (value) => value.isNotEmpty && value != current.meaningTr.trim())
          .toSet()
          .take(3)
          .toList();
    }

    return pool
        .map((item) => item.word.trim())
        .where((value) => value.isNotEmpty && value != current.word.trim())
        .toSet()
        .take(3)
        .toList();
  }

  _ChallengeArenaQuestion buildQuestion(
      VocabularyItem item, List<VocabularyItem> source) {
    final level = item.level.toUpperCase().trim();
    final types = <String>['meaning', 'word'];

    if (canMakeFill(item)) types.add('fill');
    if (level != 'A1' && level != 'A2' && item.definitionEn.trim().isNotEmpty) {
      types.add('definition');
    }
    if (level != 'A1' && isPhraseItem(item)) types.add('chunk');

    if (selectedArenaMode == 'timed') {
      types.remove('definition');
    }
    if (selectedArenaMode == 'duel') {
      types.remove('definition');
      if (!types.contains('fill') && canMakeFill(item)) types.add('fill');
    }

    final type = types[random.nextInt(types.length)];

    late String prompt;
    late String correctAnswer;
    late String explanation;

    if (type == 'meaning') {
      prompt = item.word;
      correctAnswer = item.meaningTr.trim();
      explanation = t(
        '“${item.word}” means “${item.meaningTr}”. Example: ${item.exampleEn}',
        '“${item.word}” kelimesi “${item.meaningTr}” demektir. Örnek: ${item.exampleEn}',
      );
    } else if (type == 'word') {
      prompt = item.meaningTr.trim();
      correctAnswer = item.word.trim();
      explanation = t(
        'The correct English word is “${item.word}”.',
        'Doğru İngilizce kelime “${item.word}”.',
      );
    } else if (type == 'definition') {
      prompt = item.definitionEn.trim();
      correctAnswer = item.word.trim();
      explanation = t(
        'This definition matches “${item.word}”.',
        'Bu tanım “${item.word}” kelimesine ait.',
      );
    } else if (type == 'fill') {
      prompt = blankExample(item);
      correctAnswer = item.word.trim();
      explanation = t(
        'Correct sentence: ${item.exampleEn}',
        'Doğru cümle: ${item.exampleEn}',
      );
    } else {
      prompt = item.meaningTr.trim().isNotEmpty
          ? item.meaningTr.trim()
          : item.definitionEn.trim();
      correctAnswer = item.word.trim();
      explanation = t(
        'This chunk is taught as: “${item.word}”.',
        'Bu kalıp şu şekilde öğretilir: “${item.word}”.',
      );
    }

    final options = <String>{correctAnswer};
    options.addAll(optionPool(
        type: type == 'meaning' ? 'meaning' : 'word',
        current: item,
        source: source));

    var guard = 0;
    while (options.length < 4 && widget.allWords.isNotEmpty && guard < 80) {
      final fallbackItem =
          widget.allWords[random.nextInt(widget.allWords.length)];
      final fallback = type == 'meaning'
          ? fallbackItem.meaningTr.trim()
          : fallbackItem.word.trim();
      if (fallback.isNotEmpty && fallback != correctAnswer) {
        options.add(fallback);
      }
      guard++;
    }

    final optionList = options.take(4).toList()..shuffle(random);

    return _ChallengeArenaQuestion(
      item: item,
      prompt: prompt,
      correctAnswer: correctAnswer,
      options: optionList,
      explanation: explanation,
      type: type,
    );
  }

  List<_ChallengeArenaQuestion> buildQuestions() {
    final source = playableSource();

    final int count;
    switch (selectedArenaMode) {
      case 'survival':
        count = min(40, source.length);
        break;
      case 'daily':
        count = min(10, source.length);
        break;
      case 'timed':
        count = min(20, source.length);
        break;
      case 'duel':
        count = min(10, source.length);
        break;
      default:
        count = min(10, source.length);
    }

    return source
        .map((item) => buildQuestion(item, source))
        .take(count)
        .toList();
  }

  IconData typeIcon(String type) {
    switch (type) {
      case 'meaning':
        return Icons.translate_rounded;
      case 'word':
        return Icons.abc_rounded;
      case 'definition':
        return Icons.menu_book_rounded;
      case 'fill':
        return Icons.short_text_rounded;
      case 'chunk':
        return Icons.bolt_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  String typeLabel(String type) {
    switch (type) {
      case 'meaning':
        return t('Translate', 'Çeviri');
      case 'word':
        return t('Word', 'Kelime');
      case 'definition':
        return t('Definition', 'Tanım');
      case 'fill':
        return t('Fill', 'Boşluk');
      case 'chunk':
        return t('Chunk', 'Kalıp');
      default:
        return t('Question', 'Soru');
    }
  }

  String instruction(String type) {
    switch (type) {
      case 'meaning':
        return t('Pick the Turkish meaning.', 'Türkçe anlamı seç.');
      case 'word':
        return t('Pick the English word.', 'İngilizce kelimeyi seç.');
      case 'definition':
        return t('Pick the word matching the definition.',
            'Tanıma uyan kelimeyi seç.');
      case 'fill':
        return t('Complete the missing part.', 'Eksik kısmı tamamla.');
      case 'chunk':
        return t('Pick the taught chunk.', 'Öğretilen kalıbı seç.');
      default:
        return t('Choose the best answer.', 'En iyi cevabı seç.');
    }
  }

  String modeTitle(String mode) {
    switch (mode) {
      case 'timed':
        return t('Time Attack', 'Zamana Karşı');
      case 'duel':
        return t('1v1 Duel', '1v1 Düello');
      case 'daily':
        return t('Daily Challenge', 'Günlük Challenge');
      case 'survival':
        return t('Survival Mode', 'Hayatta Kalma');
      default:
        return t('Classic 10', 'Klasik 10');
    }
  }

  bool get hasActiveTimer =>
      selectedArenaMode == 'timed' ||
      selectedArenaMode == 'duel' ||
      selectedArenaMode == 'daily';

  double get timerProgress {
    if (!hasActiveTimer || totalSeconds <= 0) return 1.0;
    return (secondsLeft / totalSeconds).clamp(0.0, 1.0);
  }

  Color get timerColor {
    if (!hasActiveTimer) return const Color(0xFF8B5CF6);
    if (secondsLeft <= 10) return const Color(0xFFFF3B5C);
    if (secondsLeft <= 25) return const Color(0xFFFFB020);
    return const Color(0xFF10B981);
  }

  String modeSubtitle(String mode) {
    switch (mode) {
      case 'timed':
        return t(
            'Beat the clock and stack combo.', 'Süre dolmadan combo topla.');
      case 'duel':
        return t('Live-style battle and ranked feeling.',
            'Canlı hissiyatlı ranked mücadele.');
      case 'daily':
        return t('One focused daily run. 10 questions, 45 seconds.',
            'Günlük odak turu. 10 soru, 45 saniye.');
      case 'survival':
        return t('One mistake ends the run. Stay alive.',
            'Tek yanlışta biter. Hayatta kal.');
      default:
        return t('Balanced challenge with 10 questions.',
            '10 soruluk dengeli challenge.');
    }
  }

  void stopArenaTimer() {
    arenaTimer?.cancel();
    arenaTimer = null;
  }

  void startArenaTimer() {
    stopArenaTimer();

    if (totalSeconds <= 0) return;

    arenaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (!started || finished || matchmaking) {
        timer.cancel();
        return;
      }

      if (secondsLeft <= 1) {
        setState(() {
          secondsLeft = 0;
        });
        timer.cancel();
        finishArena();
        return;
      }

      setState(() {
        secondsLeft -= 1;
      });
    });
  }

  void startArena(String mode) {
    setState(() {
      selectedArenaMode = mode;
      questions = buildQuestions();
      currentIndex = 0;
      score = 0;
      streak = 0;
      bestStreak = 0;
      combo = 1;
      earnedXP = 0;
      opponentScore = 0;
      selectedAnswer = null;
      answered = false;
      finished = false;
      started = true;
      matchmaking = false;
      survivalEndedByMistake = false;
      opponentName =
          ['NovaFox', 'Lexa', 'Ares', 'Mina', 'Lumi'][random.nextInt(5)];

      if (mode == 'timed') {
        totalSeconds = 75;
        secondsLeft = 75;
      } else if (mode == 'duel') {
        totalSeconds = 60;
        secondsLeft = 60;
      } else if (mode == 'daily') {
        totalSeconds = 45;
        secondsLeft = 45;
      } else {
        totalSeconds = 0;
        secondsLeft = 0;
      }
    });

    if (mode == 'timed' || mode == 'duel' || mode == 'daily') {
      startArenaTimer();
    } else {
      stopArenaTimer();
    }
  }

  void finishArena() {
    if (finished) return;
    stopArenaTimer();
    setState(() {
      finished = true;
    });
    AppProgress.instance.recordChallengeResult(
      mode: selectedArenaMode,
      score: score,
      total: questions.length,
      earnedXP: max(10, earnedXP),
      opponentScore: opponentScore,
    );
  }

  void startMatchmaking() {
    stopArenaTimer();
    setState(() {
      selectedArenaMode = 'duel';
      matchmaking = true;
      started = false;
      finished = false;
      opponentName =
          ['NovaFox', 'Lexa', 'Ares', 'Mina', 'Lumi'][random.nextInt(5)];
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || !matchmaking) return;
      startArena('duel');
    });
  }

  void answer(String option) {
    if (answered || finished || questions.isEmpty) return;

    final question = questions[currentIndex];
    final correct = option == question.correctAnswer;

    setState(() {
      selectedAnswer = option;
      answered = true;

      if (correct) {
        final bonus = streak >= 2 ? 2 : 1;
        score += 1;
        if (selectedArenaMode == 'duel' && currentIndex.isOdd) {
          opponentScore = min(opponentScore + 1, questions.length);
        }
        streak += 1;
        bestStreak = max(bestStreak, streak);
        combo = min(8, combo + 1);
        earnedXP += selectedArenaMode == 'survival'
            ? 10 * combo * bonus
            : 8 * combo * bonus;
        AppProgress.instance.markVocabularyMastered(question.item.id);
      } else {
        streak = 0;
        combo = 1;
        earnedXP += 2;
        if (selectedArenaMode == 'duel') {
          opponentScore = min(opponentScore + 1, questions.length);
        }
        if (selectedArenaMode == 'survival') {
          survivalEndedByMistake = true;
        }
        AppProgress.instance.toggleSavedVocabulary(question.item.id);
      }
    });

    PremiumFeedback.show(
      context,
      message: correct
          ? t(
              'Correct. Voxa is cheering for your combo.',
              'Doğru. Voxa serin için seviniyor.',
            )
          : t(
              'Voxa saved the clue. Reset and keep moving.',
              'Voxa ipucunu sakladı. Yeniden odaklan ve devam et.',
            ),
      tone: correct ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );

    unawaited(
      pulseController.forward(from: 0.96).then((_) {
        if (mounted) pulseController.reverse();
      }),
    );

    if (!correct && selectedArenaMode == 'survival') {
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted || finished) return;
        finishArena();
      });
    }
  }

  void next() {
    if (currentIndex >= questions.length - 1) {
      finishArena();
      return;
    }

    setState(() {
      currentIndex += 1;
      selectedAnswer = null;
      answered = false;
    });
  }

  void restart() {
    stopArenaTimer();
    setState(() {
      questions = buildQuestions();
      currentIndex = 0;
      score = 0;
      streak = 0;
      bestStreak = 0;
      combo = 1;
      earnedXP = 0;
      opponentScore = 0;
      selectedAnswer = null;
      answered = false;
      finished = false;
      started = false;
      matchmaking = false;
      survivalEndedByMistake = false;
      totalSeconds = 0;
      secondsLeft = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        questions.isEmpty ? 0.0 : (currentIndex + 1) / questions.length;
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: questions.isEmpty
                ? _buildEmpty()
                : finished
                    ? _buildFinish()
                    : matchmaking
                        ? _buildMatchmaking()
                        : !started
                            ? _buildLobby()
                            : _buildQuestion(progress),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withAlpha(14),
            border: Border.all(color: Colors.white.withAlpha(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sports_esports_rounded,
                  color: Color(0xFFFF4FD8), size: 48),
              const SizedBox(height: 12),
              Text(
                t('Not enough words for Challenge',
                    'Challenge için yeterli kelime yok'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                icon: Icons.close_rounded,
                label: t('Close', 'Kapat'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(16),
                border: Border.all(color: Colors.white.withAlpha(24)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Challenge',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white.withAlpha(178),
                        fontSize: 11.4,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            child: ScaleTransition(
              key: ValueKey('xp_$earnedXP'),
              scale: pulseController,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A00), Color(0xFFFF4FD8)]),
                ),
                child: Text(
                  '+$earnedXP XP',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobby() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        children: [
          _buildTopBar(
              subtitle: t('Choose a mode and start your run.',
                  'Modunu seç ve tura başla.')),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t('Choose a mode and start your run.',
                        'Modunu seç ve tura başla.'),
                    style: TextStyle(
                      color: Colors.white.withAlpha(178),
                      fontSize: 12.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _ArenaStatChip(
                  icon: Icons.flash_on_rounded,
                  label: t('XP rewards', 'XP ödülleri'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ArenaModeCard(
            index: 0,
            icon: Icons.auto_awesome_rounded,
            title: t('Classic 10', 'Klasik 10'),
            subtitle: t('Balanced round with 10 questions and clean pacing.',
                'Temiz akışlı 10 soruluk dengeli tur.'),
            chips: [t('Mixed', 'Karışık'), t('XP', 'XP'), t('Combo', 'Combo')],
            difficulty: t('Easy', 'Kolay'),
            reward: '+80 XP',
            startColor: const Color(0xFF00C2FF),
            endColor: const Color(0xFF8B5CF6),
            onTap: () => startArena('classic'),
          ),
          const SizedBox(height: 12),
          _ArenaModeCard(
            index: 1,
            icon: Icons.timer_rounded,
            title: t('Time Attack', 'Zamana Karşı'),
            subtitle: t('75 seconds. Race the clock, stack combo, earn XP.',
                '75 saniye. Süreyle yarış, combo yap, XP kazan.'),
            chips: [
              t('75s timer', '75s süre'),
              t('Speed bonus', 'Hız bonusu'),
              t('Urgency glow', 'Süre baskısı')
            ],
            difficulty: t('Medium', 'Orta'),
            reward: '+120 XP',
            startColor: const Color(0xFF10B981),
            endColor: const Color(0xFF06B6D4),
            onTap: () => startArena('timed'),
          ),
          const SizedBox(height: 12),
          _ArenaModeCard(
            index: 2,
            icon: Icons.calendar_month_rounded,
            title: t('Daily Challenge', 'Günlük Challenge'),
            subtitle: t('A focused 10-question daily run with a 45s timer.',
                '45 saniyelik 10 soruluk günlük odak turu.'),
            chips: [
              AppProgress.instance.dailyChallengeDoneToday
                  ? t('Done today', 'Bugün bitti')
                  : t('Daily', 'Günlük'),
              t('45s', '45s'),
              '${AppProgress.instance.dailyChallengeStreak} streak'
            ],
            difficulty: t('Daily', 'Günlük'),
            reward: '+150 XP',
            startColor: const Color(0xFFF59E0B),
            endColor: const Color(0xFFEF4444),
            onTap: () => startArena('daily'),
          ),
          const SizedBox(height: 12),
          _ArenaModeCard(
            index: 3,
            icon: Icons.shield_rounded,
            title: t('Survival Mode', 'Hayatta Kalma'),
            subtitle: t(
                'One wrong answer ends the run. Build your best streak.',
                'Tek yanlışta biter. En iyi serini yap.'),
            chips: [t('1 life', '1 can'), '+60 XP', t('Hard', 'Zor')],
            difficulty: t('Hard', 'Zor'),
            reward: '+200 XP',
            startColor: const Color(0xFF14B8A6),
            endColor: const Color(0xFF2563EB),
            onTap: () => startArena('survival'),
          ),
          const SizedBox(height: 12),
          _ArenaModeCard(
            index: 4,
            icon: Icons.sports_kabaddi_rounded,
            title: t('1v1 Duel', '1v1 Düello'),
            subtitle: t('Matchmaking, pressure and ranked energy.',
                'Matchmaking, baskı ve ranked hissi.'),
            chips: [
              t('Matchmaking', 'Matchmaking'),
              t('Live score', 'Canlı skor'),
              t('Versus', 'Versus')
            ],
            difficulty: t('Ranked', 'Ranked'),
            reward: '+250 XP',
            startColor: const Color(0xFFFF8A00),
            endColor: const Color(0xFFFF4FD8),
            onTap: startMatchmaking,
          ),
          const SizedBox(height: 16),
          _ArenaModeCard(
            index: 5,
            icon: Icons.groups_2_rounded,
            title: t('Taboo Teams', 'Takımlı Taboo'),
            subtitle: t(
                'Local team game: explain the word without forbidden clues.',
                'Tek ekranda takım oyunu: yasak kelimeleri kullanmadan anlat.'),
            chips: [
              t('Team Play', 'Takım'),
              t('Speaking', 'Konuşma'),
              t('Timer', 'Süre')
            ],
            difficulty: t('Team', 'Takım'),
            reward: '+Team XP',
            startColor: const Color(0xFF7C3AED),
            endColor: const Color(0xFFEC4899),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 420),
                  pageBuilder: (_, animation, __) {
                    return FadeTransition(
                      opacity: animation,
                      child: TeamTabooScreen(
                        words: widget.words,
                        allWords: widget.allWords,
                        isEnglish: widget.isEnglish,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ArenaLeaderboardPanel(
            title: t('Leaderboard Arena', 'Liderlik Arenası'),
            subtitle: t('Weekly XP race and streak pressure.',
                'Haftalık XP yarışı ve streak baskısı.'),
            selectedTab: selectedLeaderboardTab,
            entries: arenaLeaderboard,
            streakLabel: t('Streak', 'Seri'),
            isEnglish: widget.isEnglish,
            onChanged: (tab) {
              setState(() {
                selectedLeaderboardTab = tab;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMatchmaking() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A00), Color(0xFFFF4FD8), Color(0xFF7C3AED)],
            ),
            border: Border.all(color: Colors.white.withAlpha(34)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: pulseController,
                child: const Icon(Icons.radar_rounded,
                    color: Colors.white, size: 72),
              ),
              const SizedBox(height: 14),
              Text(t('Finding an opponent...', 'Rakip aranıyor...'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                '${t('Estimated rival', 'Tahmini rakip')}: $opponentName',
                style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 13,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              const LinearProgressIndicator(
                minHeight: 10,
                backgroundColor: Color(0x40FFFFFF),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 18),
              _ActionButton(
                icon: Icons.close_rounded,
                label: t('Cancel', 'İptal'),
                startColor: const Color(0xFF111827),
                endColor: const Color(0xFF1F2937),
                onTap: () {
                  setState(() {
                    matchmaking = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(double progress) {
    final question = questions[currentIndex];
    final style = _styleForLevel(question.item.level);

    return Column(
      children: [
        _buildTopBar(subtitle: modeSubtitle(selectedArenaMode)),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withAlpha(12),
              border: Border.all(color: Colors.white.withAlpha(18)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _ChallengeBadge(
                        icon: Icons.videogame_asset_rounded,
                        label: modeTitle(selectedArenaMode),
                        color: const Color(0xFFFF8A00)),
                    const SizedBox(width: 8),
                    _ChallengeBadge(
                        icon: typeIcon(question.type),
                        label: typeLabel(question.type),
                        color: style.start),
                    const Spacer(),
                    if (selectedArenaMode != 'classic')
                      _ChallengeBadge(
                        icon: selectedArenaMode == 'survival'
                            ? Icons.shield_rounded
                            : Icons.timer_rounded,
                        label: selectedArenaMode == 'survival'
                            ? t('1 life', '1 can')
                            : selectedArenaMode == 'duel'
                                ? '1v1 • ${secondsLeft}s'
                                : '${secondsLeft}s',
                        color: selectedArenaMode == 'survival'
                            ? const Color(0xFF14B8A6)
                            : timerColor,
                      ),
                  ],
                ),
                if (hasActiveTimer) ...[
                  const SizedBox(height: 12),
                  _ArenaTimerStrip(
                    secondsLeft: secondsLeft,
                    totalSeconds: totalSeconds,
                    progress: timerProgress,
                    color: timerColor,
                    label: selectedArenaMode == 'duel'
                        ? t('Duel Clock', 'Düello Süresi')
                        : t('Time Attack', 'Zamana Karşı'),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _ArenaScoreChip(
                            label: t('Score', 'Skor'), value: '$score')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _ArenaScoreChip(
                            label: t('Streak', 'Seri'), value: '$streak')),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            _ArenaScoreChip(label: 'XP', value: '+$earnedXP')),
                    if (selectedArenaMode == 'duel') ...[
                      const SizedBox(width: 8),
                      Expanded(
                          child: _ArenaScoreChip(
                              label: opponentName, value: '$opponentScore')),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: Colors.white.withAlpha(14),
                    valueColor: AlwaysStoppedAnimation<Color>(style.end),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Container(
                key:
                    ValueKey('challenge_card_${currentIndex}_${question.type}'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0B1020),
                      style.start.withAlpha(42),
                      const Color(0xFFFF4FD8).withAlpha(20),
                      style.end.withAlpha(24),
                    ],
                  ),
                  border: Border.all(color: style.end.withAlpha(58)),
                  boxShadow: [
                    BoxShadow(
                        color: style.end.withAlpha(28),
                        blurRadius: 24,
                        offset: const Offset(0, 12)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instruction(question.type),
                      style: TextStyle(
                          color: style.start,
                          fontSize: 13,
                          fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.black.withAlpha(44),
                        border: Border.all(color: style.end.withAlpha(32)),
                      ),
                      child: Text(
                        question.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ...question.options.map((option) =>
                              _buildOption(option, question, style)),
                          if (answered) ...[
                            const SizedBox(height: 4),
                            _ArenaAnswerFeedback(
                              correct: selectedAnswer == question.correctAnswer,
                              mode: selectedArenaMode,
                              combo: combo,
                              streak: streak,
                              color: selectedAnswer == question.correctAnswer
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFFF4D6D),
                              isEnglish: widget.isEnglish,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black.withAlpha(36),
                                border: Border.all(
                                    color: Colors.white.withAlpha(14)),
                              ),
                              child: Text(
                                question.explanation,
                                style: const TextStyle(
                                    color: Color(0xFFEAFBFF),
                                    fontSize: 12.5,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            children: [
              if (!answered)
                Text(
                  t('Answer to unlock the next move.',
                      'Devam etmek için cevap ver.'),
                  style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700),
                ),
              if (!answered) const SizedBox(height: 10),
              _ActionButton(
                icon: answered
                    ? (currentIndex >= questions.length - 1
                        ? Icons.flag_rounded
                        : Icons.chevron_right_rounded)
                    : Icons.touch_app_rounded,
                label: answered
                    ? (currentIndex >= questions.length - 1
                        ? t('Finish', 'Bitir')
                        : t('Next', 'Sonraki'))
                    : t('Answer first', 'Önce cevap ver'),
                startColor: answered
                    ? const Color(0xFFFF8A00)
                    : const Color(0xFF374151),
                endColor: answered
                    ? const Color(0xFFFF4FD8)
                    : const Color(0xFF4B5563),
                onTap: answered ? next : () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
      String option, _ChallengeArenaQuestion question, _LevelStyle style) {
    final isSelected = selectedAnswer == option;
    final isCorrect = option == question.correctAnswer;
    final showCorrect = answered && isCorrect;
    final showWrong = answered && isSelected && !isCorrect;

    Color borderColor = Colors.white.withAlpha(17);
    Color backgroundColor = Colors.white.withAlpha(10);
    Color glowColor = Colors.transparent;
    IconData icon = Icons.circle_outlined;
    double scale = 1.0;

    if (showCorrect) {
      borderColor = const Color(0xFF22C55E);
      backgroundColor = const Color(0xFF22C55E).withAlpha(35);
      glowColor = const Color(0xFF22C55E).withAlpha(28);
      icon = Icons.check_circle_rounded;
      scale = 1.015;
    } else if (showWrong) {
      borderColor = const Color(0xFFFF4D6D);
      backgroundColor = const Color(0xFFFF4D6D).withAlpha(35);
      glowColor = const Color(0xFFFF4D6D).withAlpha(26);
      icon = Icons.cancel_rounded;
      scale = 0.985;
    } else if (isSelected) {
      borderColor = style.start;
      backgroundColor = style.start.withAlpha(26);
      glowColor = style.start.withAlpha(18);
      icon = Icons.radio_button_checked_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        scale: scale,
        child: InkWell(
          borderRadius: BorderRadius.circular(21),
          onTap: answered ? null : () => answer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: borderColor),
              boxShadow: glowColor == Colors.transparent
                  ? null
                  : [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinish() {
    final total = questions.isEmpty ? 1 : questions.length;
    final percent = ((score / total) * 100).round();
    final title = selectedArenaMode == 'survival'
        ? (survivalEndedByMistake
            ? t('Survival Run Ended', 'Survival Turu Bitti')
            : t('Perfect Survival', 'Kusursuz Survival'))
        : selectedArenaMode == 'daily'
            ? (percent >= 80
                ? t('Daily Completed', 'Günlük Tamamlandı')
                : t('Daily Practice Done', 'Günlük Pratik Bitti'))
            : percent >= 90
                ? t('Arena Master', 'Arena Ustası')
                : percent >= 70
                    ? t('Strong Run', 'Güçlü Seri')
                    : t('Training Complete', 'Antrenman Tamam');

    final duelResult = selectedArenaMode == 'duel'
        ? (score > opponentScore
            ? t('Victory', 'Galibiyet')
            : score == opponentScore
                ? t('Draw', 'Berabere')
                : t('Defeat', 'Mağlubiyet'))
        : null;

    final Color summaryAccent = selectedArenaMode == 'duel'
        ? (score > opponentScore
            ? const Color(0xFF22C55E)
            : score == opponentScore
                ? const Color(0xFF60A5FA)
                : const Color(0xFFFF7A12))
        : selectedArenaMode == 'daily'
            ? const Color(0xFFF59E0B)
            : selectedArenaMode == 'survival'
                ? const Color(0xFF14B8A6)
                : const Color(0xFF8B5CF6);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        children: [
          _buildTopBar(
              subtitle: t('Rewards, results and restart.',
                  'Ödüller, sonuçlar ve yeniden başlat.')),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF151423),
                  Color(0xFF201A36),
                  Color(0xFF2A1E43),
                ],
              ),
              border: Border.all(color: Colors.white.withAlpha(16)),
              boxShadow: [
                BoxShadow(
                    color: summaryAccent.withAlpha(24),
                    blurRadius: 24,
                    offset: const Offset(0, 14)),
              ],
            ),
            child: Column(
              children: [
                ScaleTransition(
                  scale: pulseController,
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          summaryAccent.withAlpha(210),
                          Colors.white.withAlpha(26)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withAlpha(18)),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 42),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900),
                ),
                if (selectedArenaMode == 'daily' ||
                    selectedArenaMode == 'survival') ...[
                  const SizedBox(height: 6),
                  Text(
                    modeSubtitle(selectedArenaMode),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: summaryAccent,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800),
                  ),
                ],
                if (duelResult != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    duelResult,
                    style: TextStyle(
                        color: summaryAccent,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black.withAlpha(24),
                      border: Border.all(color: Colors.white.withAlpha(12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sports_kabaddi_rounded,
                                color: Colors.white, size: 17),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                t('Competitive Summary', 'Rekabet Özeti'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            Text(
                              '${(score - opponentScore).abs()} ${t('pt gap', 'puan fark')}',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(165),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _DuelPlayerCard(
                                name: t('You', 'Sen'),
                                score: score,
                                accent: summaryAccent,
                                isPrimary: true,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.white.withAlpha(8),
                                  border: Border.all(
                                      color: Colors.white.withAlpha(12)),
                                ),
                                child: const Text(
                                  'VS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _DuelPlayerCard(
                                name: opponentName,
                                score: opponentScore,
                                accent: Colors.white.withAlpha(160),
                                isPrimary: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score/$total',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('•',
                          style: TextStyle(
                              color: Colors.white.withAlpha(110),
                              fontSize: 28,
                              fontWeight: FontWeight.w900)),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _RewardTile(
                            label: t('XP', 'XP'), value: '+$earnedXP')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _RewardTile(
                            label: t('Best Streak', 'En İyi Seri'),
                            value: '$bestStreak')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _RewardTile(
                            label: t('Combo', 'Combo'), value: 'x$combo')),
                  ],
                ),
                const SizedBox(height: 16),
                _ArenaLeaderboardPanel(
                  title: t('Arena Highlights', 'Arena Öne Çıkanlar'),
                  subtitle: t('Your run joins the weekly race.',
                      'Bu koşu haftalık yarışa eklenir.'),
                  selectedTab: selectedLeaderboardTab,
                  entries: arenaLeaderboard.take(3).toList(),
                  streakLabel: t('Streak', 'Seri'),
                  isEnglish: widget.isEnglish,
                  onChanged: (tab) {
                    setState(() {
                      selectedLeaderboardTab = tab;
                    });
                  },
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  icon: Icons.replay_rounded,
                  label: t('Play Again', 'Tekrar Oyna'),
                  onTap: restart,
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  icon: Icons.home_rounded,
                  label: t('Back to Modes', 'Modlara Dön'),
                  startColor: const Color(0xFF111827),
                  endColor: const Color(0xFF1F2937),
                  onTap: restart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaModeCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> chips;
  final String difficulty;
  final String reward;
  final Color startColor;
  final Color endColor;
  final VoidCallback onTap;

  const _ArenaModeCard({
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.difficulty,
    required this.reward,
    required this.startColor,
    required this.endColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              startColor.withAlpha(76),
              const Color(0xFF111827).withAlpha(225),
              endColor.withAlpha(70),
            ],
          ),
          border: Border.all(color: endColor.withAlpha(58)),
          boxShadow: [
            BoxShadow(
              color: endColor.withAlpha(30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              top: -16,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(7),
                  border: Border.all(color: Colors.white.withAlpha(8)),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            LinearGradient(colors: [startColor, endColor]),
                        boxShadow: [
                          BoxShadow(
                            color: endColor.withAlpha(52),
                            blurRadius: 18,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withAlpha(190),
                              fontSize: 11.7,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Colors.white.withAlpha(12),
                        border: Border.all(color: Colors.white.withAlpha(16)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Go',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.chevron_right_rounded,
                              color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: _ArenaMetaBadge(
                        icon: Icons.speed_rounded,
                        label: difficulty,
                        color: startColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ArenaMetaBadge(
                        icon: Icons.bolt_rounded,
                        label: reward,
                        color: endColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      chips.map((chip) => _ArenaModeChip(label: chip)).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArenaMetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ArenaMetaBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(13),
        border: Border.all(color: color.withAlpha(35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.4,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaModeChip extends StatelessWidget {
  final String label;

  const _ArenaModeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withAlpha(11),
        border: Border.all(color: Colors.white.withAlpha(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 10.2, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ArenaStatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ArenaStatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withAlpha(14),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class _ArenaTimerStrip extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;
  final double progress;
  final Color color;
  final String label;

  const _ArenaTimerStrip({
    required this.secondsLeft,
    required this.totalSeconds,
    required this.progress,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final urgent = secondsLeft <= 10 && totalSeconds > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withAlpha(urgent ? 46 : 28),
            Colors.white.withAlpha(8),
          ],
        ),
        border: Border.all(color: color.withAlpha(urgent ? 95 : 55)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(urgent ? 42 : 18),
            blurRadius: urgent ? 22 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(32),
              border: Border.all(color: color.withAlpha(80)),
            ),
            child: Center(
              child: Text(
                '$secondsLeft',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  urgent ? 'HURRY UP' : label,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withAlpha(14),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            urgent ? Icons.warning_rounded : Icons.timer_rounded,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ArenaScoreChip extends StatelessWidget {
  final String label;
  final String value;

  const _ArenaScoreChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withAlpha(26),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Column(
        children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white.withAlpha(160),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ArenaLeaderboardPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final String selectedTab;
  final List<_ArenaLeaderboardEntry> entries;
  final String streakLabel;
  final bool isEnglish;
  final ValueChanged<String> onChanged;

  const _ArenaLeaderboardPanel({
    required this.title,
    required this.subtitle,
    required this.selectedTab,
    required this.entries,
    required this.streakLabel,
    required this.isEnglish,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Weekly', 'Global'];
    final topThree = entries.take(3).toList();
    final others = entries.skip(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(8),
            const Color(0xFFFFD166).withAlpha(10),
            const Color(0xFF8B5CF6).withAlpha(8),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.leaderboard_rounded,
                color: Color(0xFFFFD166),
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(150),
                        fontSize: 11.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.black.withAlpha(24),
              border: Border.all(color: Colors.white.withAlpha(10)),
            ),
            child: Row(
              children: tabs.map((tab) {
                final selected = selectedTab == tab;
                final label = isEnglish
                    ? tab
                    : tab == 'Weekly'
                        ? 'Haftalık'
                        : 'Genel';
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFFFB020), Color(0xFFD946EF)],
                              )
                            : null,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.white.withAlpha(145),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(topThree.length, (index) {
              final rank = index + 1;
              final e = topThree[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == topThree.length - 1 ? 0 : 8,
                  ),
                  child: _ArenaPodiumMiniCard(
                    rank: rank,
                    entry: e,
                    streakLabel: streakLabel,
                  ),
                ),
              );
            }),
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...others.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return Padding(
                padding:
                    EdgeInsets.only(bottom: i == others.length - 1 ? 0 : 9),
                child: _ArenaLeaderboardTile(
                  rank: i + 4,
                  entry: e,
                  streakLabel: streakLabel,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ArenaLeaderboardEntry {
  final String name;
  final int xp;
  final int streak;
  final bool isCurrentUser;

  const _ArenaLeaderboardEntry(
      {required this.name,
      required this.xp,
      required this.streak,
      this.isCurrentUser = false});
}

class _ArenaPodiumMiniCard extends StatelessWidget {
  final int rank;
  final _ArenaLeaderboardEntry entry;
  final String streakLabel;

  const _ArenaPodiumMiniCard({
    required this.rank,
    required this.entry,
    required this.streakLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color glow = rank == 1
        ? const Color(0xFFFFD166)
        : rank == 2
            ? const Color(0xFFCBD5E1)
            : const Color(0xFFFB923C);
    final borderColor =
        entry.isCurrentUser ? Colors.white.withAlpha(170) : glow.withAlpha(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            glow.withAlpha(22),
            Colors.white.withAlpha(8),
          ],
        ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: glow.withAlpha(rank == 1 ? 34 : 18),
            blurRadius: rank == 1 ? 18 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [glow.withAlpha(70), Colors.white.withAlpha(18)]),
                  border: Border.all(color: glow.withAlpha(70)),
                ),
                child: Text(
                  entry.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 19,
                  height: 19,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: glow,
                    border:
                        Border.all(color: const Color(0xFF070814), width: 2),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.xp} XP',
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$streakLabel ${entry.streak}',
            style: TextStyle(
              color: glow,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaLeaderboardTile extends StatelessWidget {
  final int rank;
  final _ArenaLeaderboardEntry entry;
  final String streakLabel;

  const _ArenaLeaderboardTile({
    required this.rank,
    required this.entry,
    required this.streakLabel,
  });

  @override
  Widget build(BuildContext context) {
    const glow = Color(0xFF60A5FA);
    final borderColor = entry.isCurrentUser
        ? Colors.white.withAlpha(150)
        : Colors.white.withAlpha(12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withAlpha(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glow.withAlpha(18),
                  border: Border.all(color: glow.withAlpha(50)),
                ),
                child: Text(
                  entry.name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF111827),
                    border: Border.all(color: glow.withAlpha(60)),
                  ),
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.xp} XP  •  $streakLabel ${entry.streak}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(170),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.trending_up_rounded,
            color: glow,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _ChallengeBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChallengeBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(22),
        border: Border.all(color: color.withAlpha(48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11.5, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final String label;
  final String value;

  const _RewardTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withAlpha(18),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
                color: Colors.white.withAlpha(210),
                fontSize: 10.5,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _DuelPlayerCard extends StatelessWidget {
  final String name;
  final int score;
  final Color accent;
  final bool isPrimary;

  const _DuelPlayerCard({
    required this.name,
    required this.score,
    required this.accent,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withAlpha(isPrimary ? 10 : 6),
        border: Border.all(color: accent.withAlpha(isPrimary ? 80 : 36)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withAlpha(28),
              border: Border.all(color: accent.withAlpha(60)),
            ),
            child: Icon(
              isPrimary ? Icons.person_rounded : Icons.person_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: TextStyle(
                color: isPrimary ? accent : Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900),
          ),
          Text(
            'PTS',
            style: TextStyle(
                color: Colors.white.withAlpha(150),
                fontSize: 10.5,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _VocabularyQuizPanel extends StatefulWidget {
  final String mode;
  final List<VocabularyItem> words;
  final List<VocabularyItem> allWords;
  final bool isEnglish;
  final ValueChanged<VocabularyItem> onOpenWord;

  const _VocabularyQuizPanel({
    super.key,
    required this.mode,
    required this.words,
    required this.allWords,
    required this.isEnglish,
    required this.onOpenWord,
  });

  @override
  State<_VocabularyQuizPanel> createState() => _VocabularyQuizPanelState();
}

class _VocabularyQuizPanelState extends State<_VocabularyQuizPanel> {
  final Random random = Random();
  late List<_QuizQuestion> questions;
  int currentIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool answered = false;
  bool finished = false;

  String t(String en, String tr) => widget.isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    questions = _buildQuestions();
  }

  List<VocabularyItem> _uniqueWords(List<VocabularyItem> source) {
    final seen = <String>{};
    final result = <VocabularyItem>[];

    for (final item in source) {
      final key = item.id.toLowerCase().trim();
      if (key.isEmpty) continue;
      if (seen.add(key)) result.add(item);
    }

    return result;
  }

  bool _isTaughtPhraseItem(VocabularyItem item) {
    final category = item.category.toLowerCase();
    final pos = item.partOfSpeech.toLowerCase();
    final word = item.word.trim();

    return category.contains('collocation') ||
        category.contains('expression') ||
        category.contains('phrase') ||
        category.contains('idiom') ||
        pos == 'phrase' ||
        pos == 'phrasal verb' ||
        word.contains(' ');
  }

  bool _sameCategory(VocabularyItem a, VocabularyItem b) {
    String clean(String value) {
      return value
          .toLowerCase()
          .replaceAll(RegExp(r'^(a1|a2|b1|b2|c1|c2)\s+'), '')
          .replaceAll(
              RegExp(r'\s+(i|ii|iii|iv|v|vi|vii|viii|ix|x|xi|xii|xiii|\d+)$'),
              '')
          .trim();
    }

    return clean(a.category) == clean(b.category);
  }

  List<VocabularyItem> _sourceWords() {
    final clean = _uniqueWords(widget.words);

    if (widget.mode == 'Saved Review') {
      return clean
          .where((item) => AppProgress.instance.isVocabularySaved(item.id))
          .toList();
    }

    if (widget.mode == 'Collocation Match') {
      return clean.where(_isTaughtPhraseItem).toList();
    }

    if (widget.mode == 'Random 10') {
      bool playable(VocabularyItem item) {
        final level = item.level.toUpperCase().trim();
        final wordOk = item.word.trim().isNotEmpty;
        final meaningOk = item.meaningTr.trim().isNotEmpty;
        final exampleOk = item.exampleEn.trim().isNotEmpty;

        if (level == 'A1' || level == 'A2') {
          return wordOk && meaningOk;
        }

        return wordOk && meaningOk && exampleOk;
      }

      final primary = clean.where(playable).toList();
      final fallback = _uniqueWords(widget.allWords).where(playable).toList();
      final emergency = _uniqueWords(widget.allWords)
          .where((item) =>
              item.word.trim().isNotEmpty && item.meaningTr.trim().isNotEmpty)
          .toList();

      final source = primary.length >= 4
          ? primary
          : fallback.length >= 4
              ? fallback
              : emergency;

      final shuffled = [...source]..shuffle(random);
      return shuffled.take(10).toList();
    }

    return clean;
  }

  List<VocabularyItem> _prioritizedDistractorItems(VocabularyItem current) {
    final all = _uniqueWords(widget.allWords)
        .where((item) => item.id != current.id)
        .where((item) => item.word.trim().isNotEmpty)
        .toList();

    final sameLevelSameCategorySamePos = all
        .where((item) =>
            item.level.toUpperCase().trim() ==
                current.level.toUpperCase().trim() &&
            _sameCategory(item, current) &&
            item.partOfSpeech.toLowerCase().trim() ==
                current.partOfSpeech.toLowerCase().trim())
        .toList();

    final sameLevelSameCategory = all
        .where((item) =>
            item.level.toUpperCase().trim() ==
                current.level.toUpperCase().trim() &&
            _sameCategory(item, current))
        .toList();

    final sameLevelSamePos = all
        .where((item) =>
            item.level.toUpperCase().trim() ==
                current.level.toUpperCase().trim() &&
            item.partOfSpeech.toLowerCase().trim() ==
                current.partOfSpeech.toLowerCase().trim())
        .toList();

    final sameLevel = all
        .where((item) =>
            item.level.toUpperCase().trim() ==
            current.level.toUpperCase().trim())
        .toList();

    final result = <VocabularyItem>[];
    final seen = <String>{};

    void addGroup(List<VocabularyItem> group) {
      final shuffled = [...group]..shuffle(random);
      for (final item in shuffled) {
        if (seen.add(item.id)) result.add(item);
      }
    }

    addGroup(sameLevelSameCategorySamePos);
    addGroup(sameLevelSameCategory);
    addGroup(sameLevelSamePos);
    addGroup(sameLevel);
    addGroup(all);

    return result;
  }

  List<String> _optionPool(String type, VocabularyItem current) {
    final pool = _prioritizedDistractorItems(current);

    if (type == 'meaning') {
      return pool
          .map((item) => item.meaningTr)
          .where(
              (value) => value.trim().isNotEmpty && value != current.meaningTr)
          .toSet()
          .take(3)
          .toList();
    }

    if (type == 'word' ||
        type == 'fill' ||
        type == 'definition' ||
        type == 'collocationItem') {
      return pool
          .map((item) => item.word)
          .where((value) => value.trim().isNotEmpty && value != current.word)
          .toSet()
          .take(3)
          .toList();
    }

    final sameLevelPhraseItems = pool
        .where(_isTaughtPhraseItem)
        .map((item) => item.word)
        .where((value) => value.trim().isNotEmpty && value != current.word)
        .toSet()
        .take(3)
        .toList();

    if (sameLevelPhraseItems.length >= 3) return sameLevelPhraseItems;

    final collocations = <String>[];
    for (final item in pool) {
      collocations.addAll(item.collocations);
      if (collocations.length >= 8) break;
    }

    return collocations
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .take(3)
        .toList();
  }

  String _blankExample(VocabularyItem item) {
    final word = item.word.trim();
    final example = item.exampleEn.trim();

    if (word.isEmpty || example.isEmpty) return '_____';

    final escaped = RegExp.escape(word);
    final regex =
        RegExp('(?<![A-Za-z])$escaped(?![A-Za-z])', caseSensitive: false);

    if (regex.hasMatch(example)) {
      return example.replaceFirst(regex, '_____');
    }

    final firstPart = word.contains(' ') ? word.split(' ').first : word;
    final regexFirst = RegExp(
        '(?<![A-Za-z])${RegExp.escape(firstPart)}(?![A-Za-z])',
        caseSensitive: false);

    if (regexFirst.hasMatch(example)) {
      return example.replaceFirst(regexFirst, '_____');
    }

    return example.isNotEmpty
        ? '$example\n\n${t('Choose the missing word.', 'Eksik kelimeyi seç.')}'
        : '_____';
  }

  _QuizQuestion _buildQuestion(VocabularyItem item, String mode) {
    String type = 'meaning';

    bool canMakeSafeBlank(VocabularyItem value) {
      final word = value.word.trim();
      final example = value.exampleEn.trim();
      if (word.isEmpty || example.isEmpty) return false;
      if (word.length <= 3) return false;

      final level = value.level.toUpperCase().trim();
      final pos = value.partOfSpeech.toLowerCase().trim();

      final ambiguousBasicCategories = {
        'body',
        'animals',
        'food & drink',
        'clothes',
        'colors',
        'family',
        'daily objects',
        'home',
      };

      if ((level == 'A1' || level == 'A2') &&
          ambiguousBasicCategories
              .contains(value.category.toLowerCase().trim())) {
        return false;
      }

      final safeParts = {
        'verb',
        'phrasal verb',
        'adjective',
        'adverb',
        'phrase',
        'expression'
      };
      if (example.split(' ').length < 4) return false;
      if (!safeParts.contains(pos) && !word.contains(' ')) return false;

      final escaped = RegExp.escape(word);
      final exact =
          RegExp('(?<![A-Za-z])$escaped(?![A-Za-z])', caseSensitive: false);
      return exact.hasMatch(example);
    }

    if (mode == 'Random 10') {
      final level = item.level.toUpperCase().trim();
      final possibleTypes = <String>['meaning', 'word'];

      if (level != 'A1' && level != 'A2') {
        possibleTypes.add('definition');
      }

      if (level != 'A1' && level != 'A2' && canMakeSafeBlank(item)) {
        possibleTypes.add('fill');
      }

      if ((level == 'B1' || level == 'B2' || level == 'C1' || level == 'C2') &&
          _isTaughtPhraseItem(item)) {
        possibleTypes.add('collocationItem');
      }

      type = possibleTypes[random.nextInt(possibleTypes.length)];
    } else if (mode == 'Meaning Quiz') {
      final possibleTypes = <String>['meaning', 'word'];

      if (_isTaughtPhraseItem(item) &&
          item.level.toUpperCase().trim() != 'A1' &&
          item.level.toUpperCase().trim() != 'A2') {
        possibleTypes.add('collocationItem');
      }

      type = possibleTypes[random.nextInt(possibleTypes.length)];
    }

    if (mode == 'Word Quiz') type = 'word';
    if (mode == 'Fill Blank') {
      type = canMakeSafeBlank(item) ? 'fill' : 'meaning';
    }
    if (mode == 'Collocation Match') {
      type = _isTaughtPhraseItem(item) ? 'collocationItem' : 'meaning';
    }
    if (mode == 'Saved Review') type = random.nextBool() ? 'meaning' : 'word';

    if (type == 'collocation' && item.collocations.isEmpty) type = 'meaning';

    late String prompt;
    late String correctAnswer;
    late String explanation;

    if (type == 'meaning') {
      prompt = item.word;
      correctAnswer = item.meaningTr;
      explanation = t(
        '“${item.word}” means “${item.meaningTr}”. Example: ${item.exampleEn}',
        '“${item.word}” kelimesi “${item.meaningTr}” demektir. Örnek: ${item.exampleEn}',
      );
    } else if (type == 'word') {
      prompt = item.meaningTr;
      correctAnswer = item.word;
      explanation = t(
        'The best word for “${item.meaningTr}” is “${item.word}”.',
        '“${item.meaningTr}” için en uygun kelime “${item.word}”.',
      );
    } else if (type == 'fill') {
      prompt =
          '${_blankExample(item)}\n\n${t('Hint', 'İpucu')}: ${item.meaningTr}';
      correctAnswer = item.word;
      explanation = t(
        'Correct sentence: ${item.exampleEn}',
        'Doğru cümle: ${item.exampleEn}',
      );
    } else if (type == 'definition') {
      prompt = item.definitionEn;
      correctAnswer = item.word;
      explanation = t(
        'This definition matches “${item.word}”. Example: ${item.exampleEn}',
        'Bu tanım “${item.word}” kelimesine aittir. Örnek: ${item.exampleEn}',
      );
    } else if (type == 'collocationItem') {
      prompt = item.meaningTr.isNotEmpty ? item.meaningTr : item.definitionEn;
      correctAnswer = item.word;
      explanation = t(
        'This is a taught phrase/chunk: “${item.word}”. Example: ${item.exampleEn}',
        'Bu öğretilen bir phrase/chunk: “${item.word}”. Örnek: ${item.exampleEn}',
      );
    } else {
      prompt = item.word;
      correctAnswer = item.collocations.first;
      explanation = t(
        'A useful collocation with “${item.word}” is “$correctAnswer”.',
        '“${item.word}” ile faydalı bir kalıp: “$correctAnswer”.',
      );
    }

    final options = <String>{correctAnswer};
    options.addAll(_optionPool(type, item));

    var guard = 0;
    while (options.length < 4 && widget.allWords.isNotEmpty && guard < 60) {
      final fallbackItem =
          widget.allWords[random.nextInt(widget.allWords.length)];
      final fallback =
          type == 'meaning' ? fallbackItem.meaningTr : fallbackItem.word;
      if (fallback.trim().isNotEmpty && fallback != correctAnswer) {
        options.add(fallback);
      }
      guard++;
    }

    final optionList = options.take(4).toList()..shuffle(random);

    return _QuizQuestion(
      item: item,
      prompt: prompt,
      correctAnswer: correctAnswer,
      options: optionList,
      explanation: explanation,
      type: type,
    );
  }

  List<_QuizQuestion> _buildQuestions() {
    final source = _sourceWords();
    if (source.isEmpty) return [];

    final shuffled = [...source]..shuffle(random);
    final count = widget.mode == 'Random 10'
        ? min(10, shuffled.length)
        : min(12, shuffled.length);

    return shuffled
        .take(count)
        .map((item) => _buildQuestion(item, widget.mode))
        .toList();
  }

  void answer(String option) {
    if (answered) return;

    final question = questions[currentIndex];
    final isCorrect = option == question.correctAnswer;

    setState(() {
      selectedAnswer = option;
      answered = true;
      if (isCorrect) {
        score += 1;
        AppProgress.instance.markVocabularyMastered(question.item.id);
      } else {
        AppProgress.instance.toggleSavedVocabulary(question.item.id);
      }
    });

    PremiumFeedback.show(
      context,
      message: isCorrect
          ? t(
              'Correct. Voxa knows this word is settling in.',
              'Doğru. Voxa bu kelimenin yerleştiğini biliyor.',
            )
          : t(
              'One more look will do it. Voxa marked the answer.',
              'Bir kez daha bakınca olacak. Voxa cevabı işaretledi.',
            ),
      tone: isCorrect ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );
  }

  void next() {
    if (currentIndex >= questions.length - 1) {
      setState(() {
        finished = true;
      });
      AppProgress.instance
          .completeVocabularyPractice(rewardXP: max(5, score * 2));
      return;
    }

    setState(() {
      currentIndex += 1;
      selectedAnswer = null;
      answered = false;
    });
  }

  void restart() {
    setState(() {
      questions = _buildQuestions();
      currentIndex = 0;
      score = 0;
      selectedAnswer = null;
      answered = false;
      finished = false;
    });
  }

  String _modeTitle() {
    switch (widget.mode) {
      case 'Meaning Quiz':
        return t('Mixed Quiz', 'Karışık Quiz');
      case 'Word Quiz':
        return t('Word Quiz', 'Kelime Testi');
      case 'Fill Blank':
        return t('Fill in the Blank', 'Boşluk Doldurma');
      case 'Collocation Match':
        return t('Collocation Match', 'Kalıp Eşleştirme');
      case 'Saved Review':
        return t('Saved Words Review', 'Kayıtlı Kelimeler Tekrarı');
      case 'Random 10':
        return t('Challenge', 'Challenge');
      default:
        return widget.mode;
    }
  }

  String _questionInstruction(_QuizQuestion question) {
    switch (question.type) {
      case 'meaning':
        return t(
            'Choose the correct Turkish meaning.', 'Doğru Türkçe anlamı seç.');
      case 'word':
        return t('Choose the correct English word.',
            'Doğru İngilizce kelimeyi seç.');
      case 'fill':
        return t('Complete the sentence with the missing word.',
            'Cümleyi eksik kelimeyle tamamla.');
      case 'definition':
        return t('Choose the word that matches the definition.',
            'Tanıma uyan kelimeyi seç.');
      case 'collocation':
        return t(
            'Choose the most natural collocation.', 'En doğal kalıbı seç.');
      case 'collocationItem':
        return t(
            'Choose the taught phrase/chunk.', 'Öğretilen phrase/kalıbı seç.');
      default:
        return t('Choose the best answer.', 'En iyi cevabı seç.');
    }
  }

  IconData _typeIcon(_QuizQuestion question) {
    switch (question.type) {
      case 'meaning':
        return Icons.translate_rounded;
      case 'word':
        return Icons.abc_rounded;
      case 'fill':
        return Icons.short_text_rounded;
      case 'definition':
        return Icons.menu_book_rounded;
      case 'collocationItem':
        return Icons.bolt_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  String _typeLabel(_QuizQuestion question) {
    switch (question.type) {
      case 'meaning':
        return t('Translation', 'Çeviri');
      case 'word':
        return t('Word Pick', 'Kelime Seç');
      case 'fill':
        return t('Fill Blank', 'Boşluk Doldur');
      case 'definition':
        return t('Definition', 'Tanım');
      case 'collocationItem':
        return t('Chunk', 'Kalıp');
      default:
        return t('Challenge', 'Challenge');
    }
  }

  Widget _buildRandom10Challenge(
      _QuizQuestion question, double progress, _LevelStyle accent) {
    final isFinal = currentIndex >= questions.length - 1;
    final typeIcon = _typeIcon(question);
    final typeLabel = _typeLabel(question);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0B1020),
              accent.start.withAlpha(34),
              const Color(0xFFFF4FD8).withAlpha(18),
              accent.end.withAlpha(20),
              const Color(0xFF070814),
            ],
          ),
          border: Border.all(color: accent.end.withAlpha(60)),
          boxShadow: [
            BoxShadow(
              color: accent.end.withAlpha(26),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withAlpha(34),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF8A00),
                        Color(0xFFFF4FD8),
                        Color(0xFF7C3AED)
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4FD8).withAlpha(80),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_fire_department_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Challenge Arena',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('Mixed questions • streak • score + XP',
                            'Karışık sorular • seri • skor + XP'),
                        style: const TextStyle(
                            color: Color(0xFFCAD0E6),
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withAlpha(14),
                    border: Border.all(color: Colors.white.withAlpha(24)),
                  ),
                  child: Text(
                    '$score/${questions.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: Colors.white.withAlpha(14),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF4FD8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${currentIndex + 1}/${questions.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: accent.start.withAlpha(22),
                    border: Border.all(color: accent.start.withAlpha(44)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, color: accent.start, size: 16),
                      const SizedBox(width: 7),
                      Text(
                        typeLabel,
                        style: TextStyle(
                            color: accent.start,
                            fontSize: 12,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withAlpha(10),
                    border: Border.all(color: Colors.white.withAlpha(18)),
                  ),
                  child: Text(
                    question.item.level,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _questionInstruction(question),
                style: TextStyle(
                    color: accent.start,
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Container(
                key: ValueKey(
                    'arena_prompt_${currentIndex}_${question.type}_${question.prompt}'),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: Colors.black.withAlpha(56),
                  border: Border.all(color: accent.end.withAlpha(34)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  question.prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.22,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...question.options.map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = option == question.correctAnswer;
              final showCorrect = answered && isCorrect;
              final showWrong = answered && isSelected && !isCorrect;

              Color borderColor = Colors.white.withAlpha(17);
              Color backgroundColor = Colors.white.withAlpha(10);
              IconData icon = Icons.circle_outlined;

              if (showCorrect) {
                borderColor = const Color(0xFF22C55E);
                backgroundColor = const Color(0xFF22C55E).withAlpha(35);
                icon = Icons.check_circle_rounded;
              } else if (showWrong) {
                borderColor = const Color(0xFFFF4D6D);
                backgroundColor = const Color(0xFFFF4D6D).withAlpha(35);
                icon = Icons.cancel_rounded;
              } else if (isSelected) {
                borderColor = accent.start;
                backgroundColor = accent.start.withAlpha(26);
                icon = Icons.radio_button_checked_rounded;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: InkWell(
                  borderRadius: BorderRadius.circular(21),
                  onTap: answered ? null : () => answer(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.25,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: answered
                    ? _ActionButton(
                        key: ValueKey(
                            'quiz_next_${currentIndex}_$selectedAnswer'),
                        icon: isFinal
                            ? Icons.flag_rounded
                            : Icons.chevron_right_rounded,
                        label: isFinal
                            ? t('Finish Challenge', 'Challenge Bitir')
                            : t('Next', 'Sonraki'),
                        startColor: const Color(0xFFFF8A00),
                        endColor: const Color(0xFFFF4FD8),
                        onTap: next,
                      )
                    : const SizedBox.shrink(key: ValueKey('quiz_next_empty')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(14),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.quiz_rounded,
                    color: Color(0xFF9EEBFF), size: 42),
                const SizedBox(height: 12),
                Text(
                  widget.mode == 'Saved Review'
                      ? t('No saved words yet', 'Henüz kayıtlı kelimen yok')
                      : t('Not enough words for this quiz',
                          'Bu quiz için yeterli kelime yok'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.mode == 'Saved Review'
                      ? t('Save words first, then review them here.',
                          'Önce kelime kaydet, sonra burada tekrar et.')
                      : t('Try another level, category or All mode.',
                          'Başka bir seviye, kategori ya da All modu dene.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFFBFC3D9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (finished) {
      final percent = ((score / questions.length) * 100).round();

      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(colors: [
              Color(0xFFFF8A00),
              Color(0xFFFF4FD8),
              Color(0xFF7C3AED)
            ]),
            border: Border.all(color: Colors.white.withAlpha(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                  widget.mode == 'Random 10'
                      ? Icons.local_fire_department_rounded
                      : Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 52),
              const SizedBox(height: 14),
              Text(
                widget.mode == 'Random 10'
                    ? t('Challenge Complete', 'Challenge Tamamlandı')
                    : t('Challenge Complete', 'Challenge Tamamlandı'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text('$score/${questions.length}  •  $percent%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(
                percent >= 90
                    ? t('Perfect run. Elite recall.',
                        'Mükemmel seri. Elite hatırlama.')
                    : percent >= 70
                        ? t('Strong run. Keep the streak.',
                            'Güçlü seri. Streak’i koru.')
                        : t('Good start. Review and retry.',
                            'İyi başlangıç. Tekrar et ve yeniden dene.'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: t('Play Again', 'Tekrar Oyna'),
                  onTap: restart),
            ],
          ),
        ),
      );
    }

    final question = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;
    final accent = _styleForLevel(question.item.level);

    if (widget.mode == 'Random 10') {
      return _buildRandom10Challenge(question, progress, accent);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.start.withAlpha(26),
              accent.end.withAlpha(12),
              Colors.white.withAlpha(10)
            ],
          ),
          border: Border.all(color: accent.end.withAlpha(46)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.mode == 'Random 10') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A00), Color(0xFFFF4FD8)]),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t('Challenge mode with mixed questions and instant feedback.',
                            'Karışık sorular ve anlık dönüt içeren challenge modu.'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Icon(Icons.quiz_rounded, color: accent.start),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_modeTitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900)),
                ),
                Text('${currentIndex + 1}/${questions.length}',
                    style: const TextStyle(
                        color: Color(0xFFBFC3D9),
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withAlpha(20),
                  valueColor: AlwaysStoppedAnimation<Color>(accent.start)),
            ),
            const SizedBox(height: 14),
            Text(_questionInstruction(question),
                style: TextStyle(
                    color: accent.start,
                    fontSize: 13,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(42),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accent.end.withAlpha(28)),
              ),
              child: Text(question.prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.25,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 16),
            ...question.options.map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = option == question.correctAnswer;
              final showCorrect = answered && isCorrect;
              final showWrong = answered && isSelected && !isCorrect;

              Color borderColor = Colors.white.withAlpha(20);
              Color backgroundColor = Colors.white.withAlpha(12);
              IconData icon = Icons.circle_outlined;

              if (showCorrect) {
                borderColor = const Color(0xFF22C55E);
                backgroundColor = const Color(0xFF22C55E).withAlpha(35);
                icon = Icons.check_circle_rounded;
              } else if (showWrong) {
                borderColor = const Color(0xFFFF4D6D);
                backgroundColor = const Color(0xFFFF4D6D).withAlpha(35);
                icon = Icons.cancel_rounded;
              } else if (isSelected) {
                borderColor = accent.start;
                backgroundColor = accent.start.withAlpha(28);
                icon = Icons.radio_button_checked_rounded;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => answer(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor)),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(option,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.25,
                                    fontWeight: FontWeight.w800))),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: answered
                    ? Row(
                        key: ValueKey(
                            'quiz_action_row_${currentIndex}_$selectedAnswer'),
                        children: [
                          Expanded(
                            flex: 6,
                            child: _ActionButton(
                              icon: currentIndex >= questions.length - 1
                                  ? Icons.flag_rounded
                                  : Icons.chevron_right_rounded,
                              label: currentIndex >= questions.length - 1
                                  ? t('Finish', 'Bitir')
                                  : t('Next', 'Sonraki'),
                              startColor: accent.start,
                              endColor: accent.end,
                              onTap: next,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: _ActionButton(
                              icon: Icons.auto_awesome_rounded,
                              label: t('Teacher Card', 'Öğretici Kart'),
                              startColor: accent.start,
                              endColor: accent.end,
                              onTap: () => widget.onOpenWord(question.item),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('quiz_action_row_empty')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordDetailSheet extends StatelessWidget {
  final VocabularyItem item;
  final bool isEnglish;
  final String categoryLabel;

  const _WordDetailSheet({
    required this.item,
    required this.isEnglish,
    required this.categoryLabel,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  String whyUsefulText() {
    final pos = item.partOfSpeech.toLowerCase();
    final category = categoryLabel.toLowerCase();

    if (pos == 'adjective') {
      return t(
        'This word helps you describe people, places or situations with clearer meaning.',
        'Bu kelime insanları, yerleri veya durumları daha net anlatmana yardım eder.',
      );
    }

    if (pos == 'verb' || pos == 'phrasal verb') {
      return t(
        'This is useful because verbs make your sentences active and communicative.',
        'Bu faydalıdır çünkü fiiller cümlelerini aktif ve iletişim odaklı yapar.',
      );
    }

    if (pos == 'phrase' ||
        category.contains('collocation') ||
        category.contains('expression') ||
        category.contains('phrase')) {
      return t(
        'Learn this as a chunk. Natural English often comes from ready-made phrases, not single words.',
        'Bunu kalıp olarak öğren. Doğal İngilizce çoğu zaman tek kelimeden değil hazır phrase/chunklardan gelir.',
      );
    }

    if (pos == 'noun') {
      return t(
        'This word helps you name common ideas, objects or situations more precisely.',
        'Bu kelime yaygın fikirleri, nesneleri veya durumları daha net adlandırmana yardım eder.',
      );
    }

    return t(
      'This item becomes useful when you connect it with context and your own sentence.',
      'Bu ifade bağlamla ve kendi cümlenle birleştiğinde faydalı hale gelir.',
    );
  }

  String miniTipText() {
    if (item.collocations.isNotEmpty) {
      return t(
        'Learn it with: ${item.collocations.take(3).join(' • ')}',
        'Şunlarla birlikte öğren: ${item.collocations.take(3).join(' • ')}',
      );
    }

    return t(
      'Do not only memorize the meaning. Make your own sentence with it.',
      'Sadece anlamını ezberleme. Bu kelimeyle kendi cümleni kur.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppProgress.instance,
      builder: (context, _) {
        final saved = AppProgress.instance.isVocabularySaved(item.id);
        final known = AppProgress.instance.isVocabularyKnown(item.id);
        final mastered = AppProgress.instance.isVocabularyMastered(item.id);

        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
              decoration: const BoxDecoration(
                color: Color(0xFF080A18),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                      child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(999)))),
                  const SizedBox(height: 18),
                  Text(item.word,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _SmallTag(text: item.level),
                    _SmallTag(text: item.partOfSpeech),
                    _SmallTag(text: categoryLabel),
                  ]),
                  const SizedBox(height: 18),
                  _TeacherBox(
                      title: t('Why learn this?', 'Bunu neden öğrenmeli?'),
                      text: whyUsefulText(),
                      icon: Icons.psychology_rounded),
                  const SizedBox(height: 12),
                  _TeacherBox(
                      title: t('Mini Tip', 'Mini İpucu'),
                      text: miniTipText(),
                      icon: Icons.lightbulb_rounded),
                  const SizedBox(height: 12),
                  _TeacherBox(
                      title: t('Turkish Meaning', 'Türkçe Anlam'),
                      text: item.meaningTr,
                      icon: Icons.translate_rounded),
                  const SizedBox(height: 12),
                  _TeacherBox(
                      title: t('English Definition', 'İngilizce Tanım'),
                      text: item.definitionEn,
                      icon: Icons.menu_book_rounded),
                  const SizedBox(height: 12),
                  _TeacherBox(
                      title: t('Example', 'Örnek'),
                      text: '${item.exampleEn}\n\n${item.exampleTr}',
                      icon: Icons.format_quote_rounded),
                  if (item.collocations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _TeacherBox(
                        title: t('Collocations', 'Kalıplar'),
                        text: item.collocations.join(' • '),
                        icon: Icons.bolt_rounded),
                  ],
                  if (item.synonyms.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _TeacherBox(
                        title: t('Synonyms', 'Eş Anlamlılar'),
                        text: item.synonyms.join(' • '),
                        icon: Icons.sync_alt_rounded),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                          child: _ActionButton(
                              icon: saved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_add_outlined,
                              label: saved
                                  ? t('Saved', 'Kayıtlı')
                                  : t('Save', 'Kaydet'),
                              onTap: () => AppProgress.instance
                                  .toggleSavedVocabulary(item.id))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _ActionButton(
                              icon: known
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              label: known
                                  ? t('Known', 'Biliyorum')
                                  : t('Known', 'Biliyorum'),
                              onTap: () => AppProgress.instance
                                  .toggleKnownVocabulary(item.id))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _ActionButton(
                              icon: mastered
                                  ? Icons.workspace_premium_rounded
                                  : Icons.school_rounded,
                              label: mastered
                                  ? t('Learned', 'Öğrendim')
                                  : t('Learn', 'Öğren'),
                              onTap: () => AppProgress.instance
                                  .markVocabularyMastered(item.id))),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TeacherBox extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _TeacherBox(
      {required this.title, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withAlpha(12),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF9EEBFF), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF9EEBFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Text(text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String text;
  final Color? color;

  const _SmallTag({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final base = color ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: base.withAlpha(28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: base.withAlpha(46)),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: base.withAlpha(235),
            fontSize: 10.8,
            fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? startColor;
  final Color? endColor;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.startColor,
    this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    final start = startColor ?? const Color(0xFF9EEBFF);
    final end = endColor ?? start;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 43),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              start.withAlpha(26),
              end.withAlpha(16),
            ],
          ),
          border: Border.all(color: end.withAlpha(82)),
          boxShadow: [
            BoxShadow(
              color: end.withAlpha(18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: start, size: 16),
            const SizedBox(width: 6),
            Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFFEAFBFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isEnglish;
  final IconData? icon;
  final String? title;
  final String? subtitle;

  const _EmptyState({
    required this.isEnglish,
    this.icon,
    this.title,
    this.subtitle,
  });

  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0EA5E9).withAlpha(16),
              Colors.white.withAlpha(8),
              const Color(0xFF8B5CF6).withAlpha(14),
            ],
          ),
          border: Border.all(color: Colors.white.withAlpha(14)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(32),
                blurRadius: 22,
                offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.search_off_rounded,
                color: const Color(0xFFBFC3D9), size: 42),
            const SizedBox(height: 12),
            Text(
              title ?? t('No words found', 'Kelime bulunamadı'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle ??
                  t(
                    'Try another level, category or search term.',
                    'Başka seviye, kategori veya arama dene.',
                  ),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 12.4,
                  height: 1.25,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
