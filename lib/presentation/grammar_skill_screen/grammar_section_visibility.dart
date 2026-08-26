// ignore_for_file: unused_element

List<String> grammarVisibleTabLabels(bool isEnglish) => [
      isEnglish ? 'Learn' : 'Öğren',
      isEnglish ? 'Structure' : 'Yapı',
      isEnglish ? 'Examples' : 'Örnekler',
      isEnglish ? 'Usage' : 'Kullanım',
      isEnglish ? 'Control' : 'Kontrol',
    ];

bool grammarShouldShowLegacySupportCard(String title) {
  final normalized = title.trim().toLowerCase();
  const hidden = {
    'mistakes',
    'hatalar',
    'rule check',
    'kural kontrolü',
    'model/avoid',
    'model / avoid',
    'kaçın',
    'common mistake',
  };
  return !hidden.contains(normalized);
}
