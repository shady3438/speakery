class DictionaryEntry {
  final String word;
  final String partOfSpeech;
  final String cefrLevel;
  final String topic;
  final String meaningEnglish;
  final String meaningTurkish;
  final String exampleEnglish;
  final String exampleTurkish;
  final String teacherNote;
  final List<String> related;

  const DictionaryEntry({
    required this.word,
    required this.partOfSpeech,
    required this.cefrLevel,
    required this.topic,
    required this.meaningEnglish,
    required this.meaningTurkish,
    required this.exampleEnglish,
    required this.exampleTurkish,
    required this.teacherNote,
    required this.related,
  });

  factory DictionaryEntry.generated(String word) {
    final clean = word.trim().isEmpty ? 'word' : word.trim();
    return DictionaryEntry(
      word: clean,
      partOfSpeech: 'unknown',
      cefrLevel: '—',
      topic: 'Custom',
      meaningEnglish:
          'This word is not in the local Speakery dictionary database yet.',
      meaningTurkish:
          'Bu kelime yerel Speakery sözlük veritabanında henüz yok.',
      exampleEnglish: 'Add "$clean" to the dictionary database later.',
      exampleTurkish:
          '"$clean" kelimesini daha sonra sözlük veritabanına ekle.',
      teacherNote:
          'First check the sentence around the word. Context usually gives the first clue before you open a dictionary.',
      related: const ['context', 'example', 'meaning'],
    );
  }
}

DictionaryEntry supplementalEntry({
  required String word,
  required String meaningTurkish,
  String partOfSpeech = 'word',
  String cefrLevel = 'B1',
  String topic = 'General',
  String meaningEnglish = '',
  String exampleEnglish = '',
  String exampleTurkish = '',
  List<String> related = const [],
}) {
  final cleanWord = word.trim();

  return DictionaryEntry(
    word: cleanWord,
    partOfSpeech: partOfSpeech,
    cefrLevel: cefrLevel,
    topic: topic,
    meaningEnglish: meaningEnglish.trim().isEmpty
        ? 'A useful English $partOfSpeech in the topic of $topic.'
        : meaningEnglish.trim(),
    meaningTurkish: meaningTurkish.trim(),
    exampleEnglish: exampleEnglish.trim().isEmpty
        ? 'Try to use "$cleanWord" in your own sentence.'
        : exampleEnglish.trim(),
    exampleTurkish: exampleTurkish.trim().isEmpty
        ? '"$cleanWord" kelimesini kendi cümlende kullanmayı dene.'
        : exampleTurkish.trim(),
    teacherNote:
        'This supplemental dictionary word is useful for $cefrLevel learners. Learn it with a sentence, not as an isolated translation.',
    related:
        related.isEmpty ? const ['context', 'example', 'meaning'] : related,
  );
}
