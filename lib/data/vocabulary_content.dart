import 'vocabulary/vocabulary_models.dart';
import 'vocabulary/vocabulary_essentials.dart';
import 'vocabulary/vocabulary_essentials_part2.dart';
import 'vocabulary/vocabulary_essentials_part3.dart';
import 'vocabulary/vocabulary_a1.dart';
import 'vocabulary/vocabulary_a2.dart';
import 'vocabulary/vocabulary_b1.dart';
import 'vocabulary/vocabulary_b2.dart';
import 'vocabulary/vocabulary_c1.dart';
import 'vocabulary/vocabulary_c2.dart';

final List<VocabularyItem> allVocabularyItems = [
  ...vocabularyEssentials,
  ...vocabularyEssentialsPart2,
  ...vocabularyEssentialsPart3,
  ...vocabularyA1,
  ...vocabularyA2,
  ...vocabularyB1,
  ...vocabularyB2,
  ...vocabularyC1,
  ...vocabularyC2,
];

String normalizeVocabularySearch(String value) {
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

List<VocabularyItem> getVocabularyByLevel(String level) {
  final cleanLevel = level.toUpperCase().trim();

  return allVocabularyItems
      .where((item) => item.level.toUpperCase().trim() == cleanLevel)
      .toList();
}

List<VocabularyItem> getVocabularyByCategory(String category) {
  final cleanCategory = category.toLowerCase().trim();

  return allVocabularyItems
      .where((item) => item.category.toLowerCase().trim() == cleanCategory)
      .toList();
}

List<VocabularyItem> searchVocabulary(String query) {
  final cleanQuery = normalizeVocabularySearch(query);

  if (cleanQuery.isEmpty) {
    return allVocabularyItems;
  }

  return allVocabularyItems.where((item) {
    return normalizeVocabularySearch(item.word).contains(cleanQuery) ||
        normalizeVocabularySearch(item.meaningTr).contains(cleanQuery) ||
        normalizeVocabularySearch(item.category).contains(cleanQuery) ||
        normalizeVocabularySearch(item.definitionEn).contains(cleanQuery) ||
        normalizeVocabularySearch(item.partOfSpeech).contains(cleanQuery) ||
        item.synonyms.any((synonym) =>
            normalizeVocabularySearch(synonym).contains(cleanQuery)) ||
        item.collocations.any((collocation) =>
            normalizeVocabularySearch(collocation).contains(cleanQuery));
  }).toList();
}
