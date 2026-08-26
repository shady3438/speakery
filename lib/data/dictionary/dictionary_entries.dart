import '../vocabulary_content.dart';
import '../vocabulary/vocabulary_models.dart';
import 'dictionary_models.dart';
import 'dictionary_supplement_entries.dart';

export 'dictionary_models.dart';

final List<DictionaryEntry> dictionaryEntries = _buildDictionaryEntries();

List<DictionaryEntry> _buildDictionaryEntries() {
  final seen = <String>{};
  final result = <DictionaryEntry>[];

  for (final item in allVocabularyItems) {
    final word = item.word.trim();
    final meaning = item.meaningTr.trim();
    if (word.isEmpty || meaning.isEmpty) continue;

    final key = _normalize(word);
    if (key.isEmpty || !seen.add(key)) continue;

    result.add(_fromVocabularyItem(item));
  }

  for (final entry in supplementalDictionaryEntries) {
    final key = _normalize(entry.word);
    if (key.isEmpty || !seen.add(key)) continue;
    result.add(entry);
  }

  result.sort((a, b) {
    final levelCompare =
        _levelRank(a.cefrLevel).compareTo(_levelRank(b.cefrLevel));
    if (levelCompare != 0) return levelCompare;
    return a.word.toLowerCase().compareTo(b.word.toLowerCase());
  });

  return List.unmodifiable(result);
}

DictionaryEntry findDictionaryEntry(String raw) {
  final clean = _normalize(raw);
  if (clean.isEmpty) return DictionaryEntry.generated(raw);

  for (final entry in dictionaryEntries) {
    if (_normalize(entry.word) == clean) return entry;
  }

  for (final entry in dictionaryEntries) {
    final word = _normalize(entry.word);
    if (word.contains(clean) || clean.contains(word)) return entry;
  }

  return DictionaryEntry.generated(raw);
}

List<DictionaryEntry> searchDictionaryEntries(String raw, {int limit = 50}) {
  final clean = _normalize(raw);
  if (clean.isEmpty) {
    return dictionaryEntries.take(limit).toList(growable: false);
  }

  final starts = <DictionaryEntry>[];
  final contains = <DictionaryEntry>[];

  for (final entry in dictionaryEntries) {
    final word = _normalize(entry.word);
    final meaning = _normalize(entry.meaningTurkish);
    final definition = _normalize(entry.meaningEnglish);
    final topic = _normalize(entry.topic);

    if (word.startsWith(clean)) {
      starts.add(entry);
    } else if (word.contains(clean) ||
        meaning.contains(clean) ||
        definition.contains(clean) ||
        topic.contains(clean)) {
      contains.add(entry);
    }

    if (starts.length + contains.length >= limit * 2) break;
  }

  return [...starts, ...contains].take(limit).toList(growable: false);
}

DictionaryEntry _fromVocabularyItem(VocabularyItem item) {
  final related = <String>[
    ...item.synonyms,
    ...item.collocations,
  ]
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .take(8)
      .toList(growable: false);

  return DictionaryEntry(
    word: item.word.trim(),
    partOfSpeech:
        item.partOfSpeech.trim().isEmpty ? 'unknown' : item.partOfSpeech.trim(),
    cefrLevel: item.level.trim().isEmpty ? '—' : item.level.trim(),
    topic: item.category.trim().isEmpty ? 'General' : item.category.trim(),
    meaningEnglish: item.definitionEn.trim().isEmpty
        ? 'No English definition has been added yet.'
        : item.definitionEn.trim(),
    meaningTurkish: item.meaningTr.trim().isEmpty
        ? 'Türkçe anlam henüz eklenmedi.'
        : item.meaningTr.trim(),
    exampleEnglish: item.exampleEn.trim().isEmpty
        ? 'Use "${item.word.trim()}" in your own sentence.'
        : item.exampleEn.trim(),
    exampleTurkish: item.exampleTr.trim().isEmpty
        ? 'Bu kelimeyle kendi cümleni kur.'
        : item.exampleTr.trim(),
    teacherNote: _teacherNoteFor(item),
    related: related.isEmpty ? _fallbackRelated(item) : related,
  );
}

String _teacherNoteFor(VocabularyItem item) {
  final level = item.level.trim().isEmpty ? 'this level' : item.level.trim();
  final pos =
      item.partOfSpeech.trim().isEmpty ? 'word' : item.partOfSpeech.trim();

  if (item.collocations.isNotEmpty) {
    final examples = item.collocations.take(3).join(', ');
    return 'This $pos is useful at $level. Notice common combinations such as: $examples.';
  }

  if (item.synonyms.isNotEmpty) {
    final examples = item.synonyms.take(3).join(', ');
    return 'This $pos is useful at $level. Compare it with: $examples.';
  }

  return 'This $pos is useful at $level. Learn it with the example sentence, not as a single isolated word.';
}

List<String> _fallbackRelated(VocabularyItem item) {
  final topicWords = item.category
      .split(RegExp(r'[^A-Za-z]+'))
      .map((value) => value.toLowerCase().trim())
      .where((value) => value.length > 3)
      .take(4)
      .toList();

  if (topicWords.isNotEmpty) return topicWords;
  return const ['context', 'example', 'meaning'];
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

int _levelRank(String value) {
  switch (value.toUpperCase().trim()) {
    case 'A1':
      return 1;
    case 'A2':
      return 2;
    case 'B1':
      return 3;
    case 'B2':
      return 4;
    case 'C1':
      return 5;
    case 'C2':
      return 6;
    default:
      return 99;
  }
}
