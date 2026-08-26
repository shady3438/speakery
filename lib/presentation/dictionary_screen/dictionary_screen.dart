import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/dictionary/dictionary_entries.dart';
import '../../services/native_speech_service.dart';

const Color _bg = Color(0xFF050712);
const Color _panel = Color(0xFF0B1020);
const Color _blue = Color(0xFF06B6D4);
const Color _purple = Color(0xFF8B5CF6);
const Color _pink = Color(0xFFEC4899);
const Color _amber = Color(0xFFF59E0B);

class DictionaryScreen extends StatefulWidget {
  final String? initialWord;
  final bool isEnglish;

  const DictionaryScreen({
    super.key,
    this.initialWord,
    this.isEnglish = true,
  });

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late final TextEditingController _searchCtrl;
  final NativeSpeechService _speech = NativeSpeechService.instance;
  DictionaryEntry? _selectedEntry;
  bool _saved = false;

  final List<String> _recentSearches = ['analyze', 'evidence', 'context'];
  final Set<String> _savedWords = <String>{};

  bool get isEnglish => widget.isEnglish;
  String t(String en, String tr) => isEnglish ? en : tr;

  @override
  void initState() {
    super.initState();
    final initial = (widget.initialWord ?? '').trim();
    _searchCtrl = TextEditingController(text: initial);
    if (initial.isNotEmpty) {
      _selectedEntry = _findEntry(initial);
      _remember(initial);
    } else {
      _selectedEntry =
          dictionaryEntries.isNotEmpty ? dictionaryEntries.first : null;
    }
    _saved = _savedWords.contains(_selectedEntry?.word.toLowerCase());
  }

  @override
  void dispose() {
    _speech.stop();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _speak(String text, {double rate = .92}) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    await _speech.speak(clean, rate: rate);
  }

  void _search(String raw) {
    final word = raw.trim();
    if (word.isEmpty) return;
    final entry = _findEntry(word);
    setState(() {
      _selectedEntry = entry;
      _saved = _savedWords.contains(entry.word.toLowerCase());
      _remember(word);
    });
  }

  DictionaryEntry _findEntry(String raw) {
    final clean = raw.toLowerCase().trim();
    return dictionaryEntries.firstWhere(
      (entry) => entry.word.toLowerCase() == clean,
      orElse: () => DictionaryEntry.generated(clean),
    );
  }

  void _remember(String raw) {
    final clean = raw.toLowerCase().trim();
    if (clean.isEmpty) return;
    _recentSearches.remove(clean);
    _recentSearches.insert(0, clean);
    if (_recentSearches.length > 6) {
      _recentSearches.removeRange(6, _recentSearches.length);
    }
  }

  void _toggleSaved() {
    final entry = _selectedEntry;
    if (entry == null) return;
    final key = entry.word.toLowerCase();
    setState(() {
      if (_savedWords.contains(key)) {
        _savedWords.remove(key);
        _saved = false;
      } else {
        _savedWords.add(key);
        _saved = true;
      }
    });
    _showMiniSnack(
      _saved
          ? t('Saved to your word list', 'Kelime listene kaydedildi')
          : t('Removed from saved words', 'Kayıtlı kelimelerden çıkarıldı'),
    );
  }

  List<String> _suggestionsFor(DictionaryEntry? entry) {
    final seen = <String>{};
    final results = <String>[];

    void add(String value) {
      final clean = value.trim();
      if (clean.isEmpty) return;
      final key = clean.toLowerCase();
      if (entry != null && key == entry.word.toLowerCase()) return;
      if (seen.add(key)) results.add(clean);
    }

    if (entry != null) {
      for (final word in entry.related) {
        add(word);
      }

      for (final item in dictionaryEntries) {
        if (results.length >= 8) break;
        if (item.topic.toLowerCase() == entry.topic.toLowerCase()) {
          add(item.word);
        }
      }

      for (final item in dictionaryEntries) {
        if (results.length >= 8) break;
        if (item.cefrLevel.toLowerCase() == entry.cefrLevel.toLowerCase()) {
          add(item.word);
        }
      }
    }

    for (final item in _recentSearches) {
      if (results.length >= 8) break;
      add(item);
    }

    return results.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _selectedEntry;
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _CalmLiquidBackground()),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              children: [
                _topBar(),
                const SizedBox(height: 12),
                _heroSearchCard(),
                const SizedBox(height: 12),
                _smartSuggestionsCard(entry),
                const SizedBox(height: 12),
                if (entry != null) _entryCard(entry),
                const SizedBox(height: 12),
                if (entry != null) _exampleCard(entry),
                const SizedBox(height: 12),
                if (entry != null) _teacherNote(entry),
                const SizedBox(height: 12),
                if (entry != null && entry.related.isNotEmpty)
                  _relatedWords(entry),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        _TapScale(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: Colors.white.withAlpha(9),
              border: Border.all(color: Colors.white.withAlpha(14)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GlassCard(
            radius: 24,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        const LinearGradient(colors: [_blue, _purple, _pink]),
                    boxShadow: [
                      BoxShadow(
                          color: _purple.withAlpha(35),
                          blurRadius: 14,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: const Icon(Icons.travel_explore_rounded,
                      color: Colors.white, size: 19),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('Dictionary', 'Sözlük'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.45,
                            height: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('Fast word lookup for real study',
                            'Gerçek çalışma için hızlı kelime arama'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withAlpha(138),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
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

  Widget _heroSearchCard() {
    return _GlassCard(
      radius: 34,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      strong: true,
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -42,
            child: Icon(Icons.search_rounded,
                size: 130, color: Colors.white.withAlpha(7)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_blue, _purple, _pink]),
                      boxShadow: [
                        BoxShadow(
                            color: _blue.withAlpha(32),
                            blurRadius: 18,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: const Icon(Icons.manage_search_rounded,
                        color: Colors.white, size: 23),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('Quick Dictionary', 'Hızlı Sözlük'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              height: 1),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          t('Meaning, examples, level and teacher notes.',
                              'Anlam, örnekler, seviye ve öğretmen notu.'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white.withAlpha(146),
                              fontSize: 11.6,
                              height: 1.3,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  color: Colors.white.withAlpha(9),
                  border: Border.all(color: Colors.white.withAlpha(18)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(24),
                        blurRadius: 18,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onSubmitted: _search,
                  textInputAction: TextInputAction.search,
                  cursorColor: _blue,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.4,
                      fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    hintText:
                        t('Search an English word', 'İngilizce kelime ara'),
                    hintStyle: TextStyle(
                        color: Colors.white.withAlpha(82),
                        fontWeight: FontWeight.w700),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.white.withAlpha(160), size: 22),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(7),
                      child: _TapScale(
                        onTap: () => _search(_searchCtrl.text),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                                colors: [_blue, _purple, _pink]),
                            boxShadow: [
                              BoxShadow(
                                  color: _pink.withAlpha(32),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5))
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 17),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smartSuggestionsCard(DictionaryEntry? entry) {
    final suggestions = _suggestionsFor(entry);

    return _GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SoftIcon(icon: Icons.auto_awesome_rounded, color: _purple),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('Smart suggestions', 'Akıllı öneriler'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.8,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(
                      t('Related to your current word.',
                          'Mevcut kelimenle alakalı.'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withAlpha(124),
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (suggestions.isEmpty)
            Text(
              t('Search a word to see better suggestions.',
                  'Daha iyi öneriler için bir kelime ara.'),
              style: TextStyle(
                  color: Colors.white.withAlpha(128),
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in suggestions)
                  _WordChip(
                    label: item,
                    icon: Icons.north_east_rounded,
                    color: _recentSearches.contains(item.toLowerCase())
                        ? _blue
                        : _purple,
                    onTap: () {
                      _searchCtrl.text = item;
                      _search(item);
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _entryCard(DictionaryEntry entry) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _GlassCard(
        radius: 35,
        padding: const EdgeInsets.all(16),
        strong: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SoundButton(onTap: () => _speak(entry.word, rate: .82)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.word,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.9,
                            height: 1.02),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _SmallPill(
                              label: entry.partOfSpeech,
                              color: _pink,
                              icon: Icons.category_rounded),
                          _SmallPill(
                              label: entry.cefrLevel,
                              color: _purple,
                              icon: Icons.school_rounded),
                          _SmallPill(
                              label: entry.topic,
                              color: _blue,
                              icon: Icons.tag_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
                _IconButtonCircle(
                    icon: _saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    active: _saved,
                    onTap: _toggleSaved),
              ],
            ),
            const SizedBox(height: 16),
            _MeaningBlock(
                title: t('Turkish meaning', 'Türkçe anlam'),
                value: entry.meaningTurkish,
                icon: Icons.translate_rounded,
                color: _blue),
            const SizedBox(height: 10),
            _MeaningBlock(
                title: t('English definition', 'İngilizce açıklama'),
                value: entry.meaningEnglish,
                icon: Icons.menu_book_rounded,
                color: _pink),
          ],
        ),
      ),
    );
  }

  Widget _exampleCard(DictionaryEntry entry) {
    return _GlassCard(
      radius: 31,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.format_quote_rounded,
              t('Example in context', 'Bağlam içinde örnek')),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withAlpha(7),
              border: Border.all(color: Colors.white.withAlpha(11)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.exampleEnglish,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.2,
                        height: 1.48,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 9),
                Container(height: 1, color: Colors.white.withAlpha(8)),
                const SizedBox(height: 9),
                Text(entry.exampleTurkish,
                    style: TextStyle(
                        color: Colors.white.withAlpha(136),
                        fontSize: 12.6,
                        height: 1.4,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                  child: _ActionPill(
                      icon: Icons.volume_up_rounded,
                      label: t('Listen', 'Dinle'),
                      color: _blue,
                      active: false,
                      onTap: () => _speak(entry.exampleEnglish))),
              const SizedBox(width: 9),
              Expanded(
                  child: _ActionPill(
                      icon: _saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_add_rounded,
                      label: _saved
                          ? t('Saved', 'Kaydedildi')
                          : t('Save word', 'Kaydet'),
                      color: _pink,
                      active: _saved,
                      onTap: _toggleSaved)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teacherNote(DictionaryEntry entry) {
    return _GlassCard(
      radius: 29,
      padding: const EdgeInsets.all(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          color: _amber.withAlpha(10),
          border: Border.all(color: _amber.withAlpha(28)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SoftIcon(icon: Icons.lightbulb_rounded, color: _amber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Teacher note', 'Öğretmen notu'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.6,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(entry.teacherNote,
                      style: TextStyle(
                          color: Colors.white.withAlpha(152),
                          fontSize: 12.2,
                          height: 1.42,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _relatedWords(DictionaryEntry entry) {
    return _GlassCard(
      radius: 30,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              Icons.hub_rounded, t('Related words', 'İlgili kelimeler')),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final word in entry.related.take(8))
                _WordChip(
                  label: word,
                  icon: Icons.north_east_rounded,
                  color: _purple,
                  onTap: () {
                    _searchCtrl.text = word;
                    _search(word);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withAlpha(220), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.2,
                  fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  void _showMiniSnack(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: _panel,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        content: Text(message,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _CalmLiquidBackground extends StatelessWidget {
  const _CalmLiquidBackground();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF07111F), Color(0xFF050712), Color(0xFF040511)],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned(
            top: -150,
            right: -120,
            child: _BackgroundGlow(color: _pink, size: 310, alpha: 38)),
        Positioned(
            top: 220,
            left: -165,
            child: _BackgroundGlow(color: _blue, size: 310, alpha: 34)),
        Positioned(
            bottom: -150,
            right: -150,
            child: _BackgroundGlow(color: _purple, size: 320, alpha: 32)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x0806B6D4),
                  Color(0x00050712),
                  Color(0x22040511)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MeaningBlock(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withAlpha(7),
        border: Border.all(color: color.withAlpha(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(13),
                border: Border.all(color: color.withAlpha(28))),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white.withAlpha(122),
                        fontSize: 10.7,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.7,
                        height: 1.36,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SoundButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_blue, _purple]),
          border: Border.all(color: Colors.white.withAlpha(36)),
          boxShadow: [
            BoxShadow(
                color: _blue.withAlpha(38),
                blurRadius: 20,
                offset: const Offset(0, 9))
          ],
        ),
        child:
            const Icon(Icons.volume_up_rounded, color: Colors.white, size: 25),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SmallPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(11),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withAlpha(210),
                  fontSize: 10.4,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _WordChip(
      {required this.label,
      required this.icon,
      required this.onTap,
      this.color = _blue});

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withAlpha(7),
          border: Border.all(color: color.withAlpha(28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.withAlpha(210), size: 12),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withAlpha(214),
                    fontSize: 11.1,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _ActionPill(
      {required this.icon,
      required this.label,
      required this.color,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: active
              ? LinearGradient(
                  colors: [color.withAlpha(42), color.withAlpha(18)])
              : null,
          color: active ? null : Colors.white.withAlpha(7),
          border: Border.all(
              color: active ? color.withAlpha(46) : Colors.white.withAlpha(13)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? color : Colors.white.withAlpha(190), size: 16),
            const SizedBox(width: 7),
            Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }
}

class _IconButtonCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _IconButtonCircle(
      {required this.icon, required this.onTap, required this.active});

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? _pink.withAlpha(24) : Colors.white.withAlpha(8),
          border: Border.all(
              color: active ? _pink.withAlpha(46) : Colors.white.withAlpha(14)),
        ),
        child: Icon(icon,
            color: active ? _pink : Colors.white.withAlpha(220), size: 20),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SoftIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color.withAlpha(12),
        border: Border.all(color: color.withAlpha(28)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool strong;

  const _GlassCard({
    required this.child,
    required this.padding,
    required this.radius,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: strong
                  ? [
                      Colors.white.withAlpha(13),
                      _blue.withAlpha(7),
                      _pink.withAlpha(6)
                    ]
                  : [Colors.white.withAlpha(9), Colors.white.withAlpha(5)],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withAlpha(strong ? 17 : 13)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(24),
                  blurRadius: 22,
                  offset: const Offset(0, 12))
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final Color color;
  final double size;
  final int alpha;

  const _BackgroundGlow(
      {required this.color, required this.size, required this.alpha});

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
                color: color.withAlpha(alpha),
                blurRadius: 115,
                spreadRadius: 44)
          ],
        ),
      ),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScale({required this.child, required this.onTap});

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
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
