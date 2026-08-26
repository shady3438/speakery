class VocabularyItem {
  final String id;
  final String word;
  final String level;
  final String category;
  final String partOfSpeech;
  final String meaningTr;
  final String definitionEn;
  final String exampleEn;
  final String exampleTr;
  final List<String> synonyms;
  final List<String> collocations;

  const VocabularyItem({
    required this.id,
    required this.word,
    required this.level,
    required this.category,
    required this.partOfSpeech,
    required this.meaningTr,
    required this.definitionEn,
    required this.exampleEn,
    required this.exampleTr,
    required this.synonyms,
    required this.collocations,
  });
}
