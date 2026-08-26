// ignore_for_file: unused_element, unused_field
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:speakery/data/app_progress.dart';
import 'package:speakery/data/grammar/grammar_models.dart';
import 'package:speakery/data/grammar/grammar_generator.dart';
import 'package:speakery/data/grammar/grammar_repository.dart';
import 'package:speakery/theme/speakery_theme_tokens.dart';
import 'package:speakery/widgets/ios_liquid_glass.dart';
import 'package:speakery/widgets/premium_feedback.dart';

import 'grammar_display_model.dart';
import 'grammar_ui_text.dart';

const int _grammarLessonRewardXP = 15;

String _grammarProgressId(String level, GrammarTopic topic) =>
    'grammar_${level.toLowerCase()}_${topic.id.toLowerCase()}';

bool _speakeryUseEnglishUi(BuildContext context, bool fallback) {
  // The app already passes the selected UI language with isEnglish.
  // Do not override it with the device/Flutter locale; otherwise Turkish UI can
  // accidentally turn English when the app locale is still en.
  return fallback;
}

bool _isA1A2LessonKey(String key) =>
    key.startsWith('a1_') || key.startsWith('a2_');

Color _grammarAccentText(SpeakeryThemeTokens tokens, Color color) {
  if (!tokens.isLight) return color;
  final mix = color.computeLuminance() > .34 ? .42 : .22;
  return Color.lerp(color, const Color(0xFF111827), mix)!;
}

Color _grammarGlassBorder(
  SpeakeryThemeTokens tokens, {
  Color? accent,
  bool strong = false,
}) {
  if (!tokens.isLight) return Colors.white.withAlpha(strong ? 34 : 24);
  final base = Color(strong ? 0xFFD0D9EA : 0xFFD9E1EF);
  return accent == null
      ? base
      : Color.alphaBlend(accent.withAlpha(strong ? 42 : 26), base);
}

List<Color> _grammarLightGlass(Color accent, {bool strong = false}) => [
      Color.alphaBlend(
        accent.withAlpha(strong ? 24 : 14),
        Colors.white.withAlpha(strong ? 238 : 224),
      ),
      const Color(0xFFEFF4FF).withAlpha(strong ? 224 : 204),
      Colors.white.withAlpha(strong ? 210 : 184),
    ];

bool _hideA1A2TurkishContent(String lessonKey, bool isEnglish) => false;

bool _showTurkishContentSupport(String lessonKey, bool isEnglish) {
  return !_hideA1A2TurkishContent(lessonKey, isEnglish);
}

String _repairMojibake(String value) {
  return repairGrammarMojibake(value);
  /*
  if (!_looksMojibake(value) && !value.contains('\uFFFD')) {
    return _repairTurkishAsciiArtifacts(value);
  }
  var best = value;
  var bestScore = _mojibakeScore(best);

  for (var pass = 0; pass < 3; pass++) {
    final bytes = <int>[];
    var ok = true;
    for (final code in best.runes) {
      final mapped = _windows1252Byte(code);
      if (mapped == null) {
        ok = false;
        break;
      }
      bytes.add(mapped);
    }
    if (!ok) break;
    final decoded = utf8.decode(bytes, allowMalformed: true);
    final score = _mojibakeScore(decoded);
    if (score >= bestScore) break;
    best = decoded;
    bestScore = score;
  }

  return _repairTurkishAsciiArtifacts(best
      .replaceAll('\u00e2\u20ac\u00a2', '"')
      .replaceAll('\u00e2\u20ac\u2122', "'")
      .replaceAll('\u00e2\u20ac\u0153', '"')
      .replaceAll('\u00e2\u20ac\u009d', '"')
      .replaceAll('\u00e2\u20ac\u201d', '-'));
  */
}

String _repairTurkishAsciiArtifacts(String value) {
  var fixed = value;

  const replacements = <String, String>{
    // Common mojibake / replacement-character fragments in Turkish UI text.
    'ï¿½?retmen': 'Öğretmen',
    '�?retmen': 'Öğretmen',
    '�?ren': 'Öğren',
    'ï¿½rnek': 'Örnek',
    '�?rnek': 'Örnek',
    '�rnek': 'örnek',
    'ï¿½zne': 'Özne',
    '�özne': 'Özne',
    'özne': 'özne',
    'özneye': 'özneye',
    'özneden': 'özneden',
    'ï¿½nce': 'Önce',
    '�?nce': 'Önce',
    '�nce': 'önce',
    '�nemli': 'önemli',
    '�neri': 'not',
    '�eyi': 'şeyi',
    '?ey': 'şey',
    '�ey': 'şey',
    '?imdi': 'Şimdi',
    '�imdi': 'Şimdi',
    'cï¿½mle': 'cümle',
    'c�mle': 'cümle',
    'C�mle': 'Cümle',
    'g�nl�k': 'günlük',
    'al1_kanl1k': 'alışkanlık',
    'ger�ek': 'gerçek',
    'd�_�rme': 'düşürme',
    'düzensiz': 'düzensiz',
    'D�zensiz': 'Düzensiz',
    'de?i_im': 'değişim',
    'de?i_tir': 'değiştir',
    'de?i?mez': 'değişmez',
    'değil': 'değil',
    'do?ru': 'doğru',
    'Do?ru': 'Doğru',
    'do�ru': 'doğru',
    'yanl?': 'yanlış',
    'Yanl?': 'Yanlış',
    'yanl��': 'yanlış',
    'yardımcı': 'yardımcı',
    'Yard?mc?': 'Yardımcı',
    'kişi': 'kişi',
    'Ki?i': 'Kişi',
    'e\'ya': 'eşya',
    's?n?f': 'sınıf',
    'S?n?f': 'Sınıf',
    's1n1f': 'sınıf',
    'S?nav': 'Sınav',
    'S?kl?k': 'Sıklık',
    's?kl?k': 'sıklık',
    's?ra': 'sıra',
    's1ra': 'sıra',
    's?fat': 'sıfat',
    's?fat?': 'sıfatı',
    'sahipli?i': 'sahipliği',
    'sahipli_i': 'sahipliği',
    'sahiplişinde': 'sahipliğinde',
    'sahiplişi': 'sahipliği',
    's?rayla': 'sırayla',
    'S?rayla': 'Sırayla',
    'H?zl? Bak1_': 'Hızlı bakış',
    'H?zl? bak1_': 'Hızlı bakış',
    'H?zl?': 'Hızlı',
    'h?zl?': 'hızlı',
    'Bak1_': 'Bakış',
    'bak1_': 'bakış',
    'k1sa': 'kısa',
    'K1sa': 'Kısa',
    'k?sa': 'kısa',
    'K?sa': 'Kısa',
    'kal?b': 'kalıb',
    'kal1p': 'kalıp',
    'kal1b': 'kalıb',
    'kullanırsın': 'kullanırsın',
    'kullanılır': 'kullanılır',
    'kullan?lmaz': 'kullanılmaz',
    'kullan?m': 'kullanım',
    'Kullan?m': 'Kullanım',
    'kullan1m': 'kullanım',
    'Kullan1m': 'Kullanım',
    'Yap1': 'Yapı',
    'yap?': 'yapı',
    'Yap?': 'Yapı',
    'ad1m': 'adım',
    'odakl1': 'odaklı',
    'ayr1l1r': 'ayrılır',
    'haz1r': 'hazır',
    'haz1rlan1rken': 'hazırlanırken',
    'ba_ka': 'başka',
    'ba_lık': 'başlık',
    'başa': 'başa',
    'ba?la': 'bağla',
    'ba?lar': 'başlar',
    'par�ay1': 'parçayı',
    '?ki par�ay1': 'İki parçayı',
    'Kar_1la_t1rmay1': 'Karşılaştırmayı',
    'yal?n': 'yalın',
    'yal1n': 'yalın',
    'b1rak': 'bırak',
    'b?rak': 'bırak',
    'g�r': 'gör',
    'g�re': 'göre',
    'gösterir': 'gösterir',
    'g�n': 'gün',
    'G�n': 'Gün',
    'bug�n': 'bugün',
    'd�n': 'dün',
    'D�n': 'Dün',
    'y�nerge': 'yönerge',
    'Ynerge': 'Yönerge',
    'ynerge': 'yönerge',
    '�o?ul': 'çoğul',
    '�o�ul': 'çoğul',
    '�o?uldur': 'çoğuldur',
    '�o?ullar': 'çoğullar',
    '�o?u': 'çoğu',
    '�n�ne': 'önüne',
    '�ncesindeki': 'öncesindeki',
    '�nceki': 'önceki',
    '�1kar1r': 'çıkarır',
    '�al': 'çalış',
    '�ocuk': 'çocuk',
    '0zin': 'İzin',
    '0sim': 'İsim',
    'Isim': 'İsim',
    'se�': 'seç',
    'a�': 'aç',
    'ya_': 'yaş',
    'Ya_': 'Yaş',
    'Al?s': "Ali's",
    'Ece?s': "Ece's",
    'I?m': "I'm",
    'doesn\'t': "doesn't",
    'don\'t': "don't",
    'isn\'t': "isn't",
    'aren\'t': "aren't",
    'can\'t': "can't",
    'shouldn\'t': "shouldn't",
    'Mustn?t': "Mustn't",
    'mustn\'t': "mustn't",
    'Don\'t': "Don't",
    'didn\'t': "didn't",
    'won\'t': "won't",
    'evideönce': 'evidence',
    'differeönce': 'difference',
    'Forml': 'Formül',
    'Form�l': 'Formül',
    'Temiz �rnekler': 'Temiz örnekler',
    'Ayn1 yap1n1n doğal �rneklerini oku.':
        'Aynı yapının doğal örneklerini oku.',
    'Bir duruma dokun, haz?r c�mleleri al.':
        'Bir duruma dokun, hazır cümleleri al.',
    'Karta dokun, h?zl? kal?b� ve k?sa �neri g�r.':
        'Karta dokun, kalıbı ve kısa notu gör.',
    'Karta dokun, h?zl? kal?b? ve k?sa ?neri g?r.':
        'Karta dokun, kalıbı ve kısa notu gör.',
    'Karta dokun, hızlı kalıbı ve kısa notu gör.':
        'Karta dokun, kalıbı ve kısa notu gör.',
    'Pratikten �nce bilmen gereken �nemli fikir':
        'Pratikten önce bilmen gereken en önemli fikir',
    'Pratikten önce bilmen gereken önemli fikir':
        'Pratikten önce bilmen gereken en önemli fikir',
    'Be fiili özneye g�re ��: I am, he/she/it is, you/we/they are.':
        'Be fiili özneye göre değişir: I am, he/she/it is, you/we/they are.',
    'özne g�re am, is veya are se�ilir': 'Özneye göre am, is veya are seçilir',
    'Olumsuzda not, be fiilinden sonra gelir.':
        'Olumsuzda not, be fiilinden sonra gelir.',
    'Kimlik, duygu, yer ve k1sa cevaplarda do?ru be fiilini kullan.':
        'Kimlik, duygu, yer ve kısa cevaplarda doğru be fiilini kullan.',
    'my, your, his, her Al?s, whose': "my, your, his, her, Ali's, whose",
    'komut, ynerge, rica': 'komut, yönerge, rica',
    'Telefon esk\'yi al?yor.': 'Telefon eski. İyi çalışıyor.',
    'Hi ekme?e ihtiyac?m? var mı?': 'Hiç ekmeğe ihtiyacımız var mı?',
    'Hi ekme?e ihtiyacım? var mı?': 'Hiç ekmeğe ihtiyacımız var mı?',
    'arkada?lar?m': 'arkadaşlarım',
    'arkada__?y?z': 'arkadaşıyız',
    'özne ve Nesne Zamirleri': 'Özne ve nesne zamirleri',
    'Sahiplik Yap1lar1': 'Sahiplik yapıları',
    '�o?ul ve Miktar Temelleri': 'Çoğul ve miktar temelleri',
    'Say?labilen': 'Sayılabilen',
    'Say1lamayan': 'Sayılamayan',
    'S?kl?k ve Durum Zarflar1': 'Sıklık ve durum zarfları',
    'Ama� Bildiren': 'Amaç bildiren',
    'Giri_': 'Giriş',
    'Soru yap?s?n1': 'Soru yapısını',
    'Olumsuz yap?y?': 'Olumsuz yapıyı',
    'yap?y?': 'yapıyı',
    'sonras?nda': 'sonrasında',
    's1n1rlay1c1': 'sınırlayıcı',
    'tamamlanm1_': 'tamamlanmış',
    'anlam?': 'anlamı',
    'süreyi': 'süreyi',
    'vurgular': 'vurgular',
    's?fattan': 'sıfattan',
    'g��lendirir': 'güçlendirir',
    'öznenin': 'öznenin',
    'al1n1r': 'alınır',
    'yap?s?': 'yapısı',
    'c�mlenin': 'cümlenin',
    'bilgisini': 'bilgisini',
  };

  for (final entry in replacements.entries) {
    fixed = fixed.replaceAll(entry.key, entry.value);
  }

  // Extra visible-content cleanup. Keep this outside the const map so duplicate
  // keys can never break compilation while we clean old generated strings.
  fixed = fixed
      .replaceAll('h1zl1', 'hızlı')
      .replaceAll('H1zl1', 'Hızlı')
      .replaceAll('kal?b?', 'kalıbı')
      .replaceAll('&?', '?')
      .replaceAll('?I?', '"I"')
      .replaceAll('?she?', '"she"')
      .replaceAll('?they?', '"they"')
      .replaceAll('?not?', '"not"')
      .replaceAll('?to?', '"to"')
      .replaceAll('?cans?', '"cans"')
      .replaceAll('?was?', '"was"')
      .replaceAll('?were?', '"were"')
      .replaceAll('"have to?', '"have to"')
      .replaceAll('?has to?', '"has to"')
      .replaceAll('?should?', '"should"')
      .replaceAll('?ought?', '"ought"')
      .replaceAll('kal?b�', 'kalıbı')
      .replaceAll('k?sa', 'kısa')
      .replaceAll('�rne?i', 'notu')
      .replaceAll('�rnekleri', 'örnekleri')
      .replaceAll('�rneklerini', 'örneklerini')
      .replaceAll('�neri', 'not')
      .replaceAll('g�r', 'gör')
      .replaceAll('Form�l', 'Formül')
      .replaceAll('Forml', 'Formül')
      .replaceAll('Form�l ve �rnekler', 'Formül ve örnekler')
      .replaceAll('Forml ve Örnekler', 'Formül ve örnekler')
      .replaceAll('Olumlu yap?', 'Olumlu yapı')
      .replaceAll('Olumsuz yap?', 'Olumsuz yapı')
      .replaceAll('Soru yap?s?', 'Soru yapısı')
      .replaceAll('K1sa cevaplar', 'Kısa cevaplar')
      .replaceAll('Kritik uyar1', 'Kritik uyarı')
      .replaceAll('0nsanlar', 'İnsanlar')
      .replaceAll('0sim', 'İsim')
      .replaceAll('0simden', 'İsimden')
      .replaceAll('0simle', 'İsimle')
      .replaceAll('0ki', 'İki')
      .replaceAll('0yi', 'İyi')
      .replaceAll('Ayn1', 'Aynı')
      .replaceAll('ayn1', 'aynı')
      .replaceAll('ayn?', 'aynı')
      .replaceAll('doğal', 'doğal')
      .replaceAll('Do?al', 'Doğal')
      .replaceAll('yap?n?n', 'yapının')
      .replaceAll('yap?n?', 'yapını')
      .replaceAll('özneye', 'özneye')
      .replaceAll('özne', 'özne')
      .replaceAll('özneden', 'özneden')
      .replaceAll('�nce', 'önce')
      .replaceAll('�eyi', 'şeyi')
      .replaceAll('�ey', 'şey')
      .replaceAll('�antas1', 'çantası')
      .replaceAll('�al1_1yor', 'çalışıyor')
      .replaceAll('?yi �al1_1yor', 'İyi çalışıyor')
      .replaceAll('?yi çalışıyor', 'İyi çalışıyor')
      .replaceAll('�al1_1rlar', 'çalışırlar')
      .replaceAll('�al1_1rs1n', 'çalışırsın')
      .replaceAll('�?le', 'Öğle')
      .replaceAll('�?renciyim', 'öğrenciyim')
      .replaceAll('�?retmenim', 'öğretmenim')
      .replaceAll('�?reniyoruz', 'öğreniyoruz')
      .replaceAll('�?retmen', 'Öğretmen')
      .replaceAll('?ngilizce', 'İngilizce')
      .replaceAll('�ocuklar', 'Çocuklar')
      .replaceAll('�ocuk', 'çocuk')
      .replaceAll('�anta', 'Çanta')
      .replaceAll('�anta', 'çanta')
      .replaceAll('çok', 'Çok')
      .replaceAll('çok', 'çok')
      .replaceAll('��', 'Üç')
      .replaceAll('?ki', 'İki')
      .replaceAll('?lk', 'İlk')
      .replaceAll('? g�revi', 'İş görevi')
      .replaceAll('? gÃ¶revi', 'İş görevi')
      .replaceAll('^u', 'Şu')
      .replaceAll('Foto?raf', 'Fotoğraf')
      .replaceAll('sa?l1k', 'sağlık')
      .replaceAll('a�1klamak', 'açıklamak')
      .replaceAll('0htiyaç', 'İhtiyaç')
      .replaceAll('0htiya�', 'İhtiyaç')
      .replaceAll('D�rt', 'Dört')
      .replaceAll('K���k', 'Küçük')
      .replaceAll('K�pek', 'Köpek')
      .replaceAll('G�ne_', 'Güneş')
      .replaceAll('Masan1n', 'Masanın')
      .replaceAll('�st�nde', 'üstünde')
      .replaceAll('a�1k', 'açık')
      .replaceAll('s�t', 'süt')
      .replaceAll('Heyecanl1lar', 'Heyecanlılar')
      .replaceAll('?imdi', 'Şimdi')
      .replaceAll('ya_1yorlar', 'yaşıyorlar')
      .replaceAll('Okulday1z', 'Okuldayız')
      .replaceAll('Odaday1z', 'Odadayız')
      .replaceAll('Kahvalt1y1', 'Kahvaltıyı')
      .replaceAll('yapar1z', 'yaparız')
      .replaceAll('oynamay1', 'oynamayı')
      .replaceAll('Onlar1', 'Onları')
      .replaceAll('ihtiyac1m1z', 'ihtiyacımız')
      .replaceAll('ya_1yorsun', 'yaşıyorsun')
      .replaceAll('S?n?fta', 'Sınıfta')
      .replaceAll('tan1yor', 'tanıyor')
      .replaceAll('Y�zmeyi', 'Yüzmeyi')
      .replaceAll('Mert?in', 'Mert’in')
      .replaceAll('?ki sandalye', 'İki sandalye')
      .replaceAll('erkek karde_imin', 'erkek kardeşimin')
      .replaceAll('kad1n', 'kadın')
      .replaceAll('konu?uyor', 'konuşuyor')
      .replaceAll('Karta dokun, hızlı kalıbı ve kısa örneği gör.',
          'Karta dokun, kalıbı ve kısa notu gör.')
      .replaceAll('Karta dokun, hızlı kalıbı ve kısa notu gör.',
          'Karta dokun, kalıbı ve kısa notu gör.')
      .replaceAll('Karta dokun, hızlı kalıbı ve kısa not gör.',
          'Karta dokun, kalıbı ve kısa notu gör.')
      .replaceAll('Aynı yapının doğal örneklerini oku.',
          'Aynı yapının doğal örneklerini oku.')
      .replaceAll('Kişinin kim olduğunu söyle.', 'Kişinin kim olduğunu söyle.')
      .replaceAll('Özneye göre am, is veya are seç.',
          'Özneye göre am, is veya are seç.')
      .replaceAll('özneye göre am, is veya are seç.',
          'Özneye göre am, is veya are seç.')
      .replaceAll(
          'Be fiili özneye göre ��: I am, he/she/it is, you/we/they are.',
          'Be fiili özneye göre değişir: I am, he/she/it is, you/we/they are.');

  return _decodeGrammarMojibakePass(fixed);
}

String _decodeGrammarMojibakePass(String value) {
  if (!_looksMojibake(value) && !value.contains('\uFFFD')) return value;

  var best = value;
  var bestScore = _mojibakeScore(best);
  for (var pass = 0; pass < 3; pass++) {
    final bytes = <int>[];
    var ok = true;
    for (final code in best.runes) {
      final mapped = _windows1252Byte(code);
      if (mapped == null) {
        ok = false;
        break;
      }
      bytes.add(mapped);
    }
    if (!ok) break;
    final decoded = utf8.decode(bytes, allowMalformed: true);
    final score = _mojibakeScore(decoded);
    if (score >= bestScore) break;
    best = decoded;
    bestScore = score;
  }
  return best;
}

List<String> _repairStringList(List<String> values) {
  return values.map(_repairMojibake).toList(growable: false);
}

Map<String, List<String>> _repairStringListMap(
    Map<String, List<String>> values) {
  return values.map(
    (key, value) => MapEntry(key, _repairStringList(value)),
  );
}

String _repairVisibleGrammarText(String value) => _repairMojibake(value);

bool _looksMojibake(String value) =>
    RegExp(r'[\u00c3\u00c2\u00c4\u00c5\u00e2\u0192]').hasMatch(value);

int _mojibakeScore(String value) {
  var score = 0;
  for (final code in const [0x00c3, 0x00c2, 0x00c4, 0x00c5, 0x00e2, 0x0192]) {
    final marker = String.fromCharCode(code);
    score += marker.allMatches(value).length;
  }
  return score;
}

int? _windows1252Byte(int code) {
  if (code <= 0xFF) return code;
  const map = <int, int>{
    0x20AC: 0x80,
    0x201A: 0x82,
    0x0192: 0x83,
    0x201E: 0x84,
    0x2026: 0x85,
    0x2020: 0x86,
    0x2021: 0x87,
    0x02C6: 0x88,
    0x2030: 0x89,
    0x0160: 0x8A,
    0x2039: 0x8B,
    0x0152: 0x8C,
    0x017D: 0x8E,
    0x2018: 0x91,
    0x2019: 0x92,
    0x201C: 0x93,
    0x201D: 0x94,
    0x2022: 0x95,
    0x2013: 0x96,
    0x2014: 0x97,
    0x02DC: 0x98,
    0x2122: 0x99,
    0x0161: 0x9A,
    0x203A: 0x9B,
    0x0153: 0x9C,
    0x017E: 0x9E,
    0x0178: 0x9F,
  };
  return map[code];
}

class GrammarSkillScreen extends StatefulWidget {
  final String initialLevel;
  final bool isEnglish;

  const GrammarSkillScreen({
    super.key,
    this.initialLevel = 'A1',
    this.isEnglish = true,
  });

  @override
  State<GrammarSkillScreen> createState() => _GrammarSkillScreenState();
}

class _GrammarSkillScreenState extends State<GrammarSkillScreen> {
  static const Color _bg = Color(0xFF050710);
  static const Color _panel = Color(0xFF0B1020);

  late String selectedLevel;
  final List<String> levels = const ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    selectedLevel =
        levels.contains(widget.initialLevel) ? widget.initialLevel : 'A1';
    AppProgress.instance.addListener(_handleProgressChanged);
  }

  @override
  void dispose() {
    AppProgress.instance.removeListener(_handleProgressChanged);
    super.dispose();
  }

  void _handleProgressChanged() {
    if (mounted) setState(() {});
  }

  String t(String en, String tr) =>
      _speakeryUseEnglishUi(context, widget.isEnglish)
          ? en
          : _repairMojibake(tr);

  _LevelPalette get palette => _paletteForLevel(selectedLevel);
  List<GrammarTopic> get topics =>
      GrammarRepository.topicsForLevel(selectedLevel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpeakeryThemeTokens.of(context).background,
      body: _GradientPage(
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
            children: [
              _topBar(),
              const SizedBox(height: 14),
              _hero(),
              const SizedBox(height: 14),
              _levelToggle(),
              const SizedBox(height: 16),
              _sectionTitle(),
              const SizedBox(height: 10),
              if (topics.isEmpty)
                _GrammarEmptyState(
                    color: palette.start,
                    isEnglish: _speakeryUseEnglishUi(context, widget.isEnglish))
              else
                ...List.generate(
                    topics.length,
                    (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: KeyedSubtree(
                            key: ValueKey<String>(
                                'grammar-topic-${topics[i].id}'),
                            child: _TopicCard(
                              topic: topics[i],
                              level: selectedLevel,
                              completed: AppProgress.instance.isLessonCompleted(
                                _grammarProgressId(selectedLevel, topics[i]),
                              ),
                              isEnglish: _speakeryUseEnglishUi(
                                  context, widget.isEnglish),
                              index: i,
                              total: topics.length,
                              palette: palette,
                              onTap: () => _openLesson(i),
                            ),
                          ),
                        )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        _TapScale(
          onTap: () => Navigator.pop(context),
          child: _CircleBackButton(color: palette.start),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Glass(
            radius: 26,
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Row(
              children: [
                _SoftIcon(
                    icon: Icons.auto_stories_rounded, color: palette.start),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('Grammar', 'Dil bilgisi'),
                          style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.35)),
                      const SizedBox(height: 4),
                      Text(
                          t('Choose a topic, open the lesson, and learn step by step',
                              'Konu seç, dersi aç ve adım adım öğren'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700)),
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

  Widget _hero() {
    final tokens = SpeakeryThemeTokens.of(context);
    final completedCount = topics
        .where((topic) => AppProgress.instance
            .isLessonCompleted(_grammarProgressId(selectedLevel, topic)))
        .length;
    return _Glass(
      radius: 34,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: tokens.isLight
            ? _grammarLightGlass(palette.start, strong: true)
            : [
                palette.start.withAlpha(52),
                _panel.withAlpha(238),
                palette.end.withAlpha(38),
              ],
      ),
      child: Stack(
        children: [
          Positioned(
              right: -28,
              bottom: -32,
              child: Icon(Icons.school_rounded,
                  color: palette.start.withAlpha(tokens.isLight ? 18 : 10),
                  size: 138)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SoftIcon(icon: Icons.route_rounded, color: palette.start),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          '$selectedLevel ${t('Grammar Lessons', 'Dil bilgisi dersleri')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.45))),
                  const SizedBox(width: 8),
                  _TinyTag(
                      label: completedCount == 0
                          ? t('${topics.length} lessons',
                              '${topics.length} ders')
                          : '$completedCount/${topics.length}',
                      color: palette.start),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                  t('Mobile-first grammar lessons',
                      'Mobil uyumlu dil bilgisi dersleri'),
                  style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.25,
                      height: 1.15)),
              const SizedBox(height: 7),
              Text(
                  t('Each lesson is split into focused steps: learn, form, examples, usage, and check.',
                      'Her ders kısa adımlara ayrılır: öğren, yapı, örnekler, kullanım ve kontrol.'),
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 12.6,
                      height: 1.35,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _levelToggle() {
    final selectedIndex =
        levels.indexOf(selectedLevel).clamp(0, levels.length - 1);
    final selectedPalette = _paletteForLevel(selectedLevel);

    return IosLiquidPillSelector(
      items: levels.map(IosPillItem.new).toList(growable: false),
      selectedIndex: selectedIndex,
      startColor: selectedPalette.start,
      endColor: selectedPalette.end,
      onChanged: (index) {
        final level = levels[index];
        if (selectedLevel == level) return;
        setState(() => selectedLevel = level);
      },
    );
  }

  Widget _sectionTitle() {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, palette.start);
    return Row(
      children: [
        Expanded(
          child: Text(
            t('Lessons', 'Dersler'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.25),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              t('learn in order', 'sırayla öğren'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: accent, fontSize: 11.2, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openLesson(int topicIndex) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GrammarLessonPlayerScreen(
          level: selectedLevel,
          initialTopicIndex: topicIndex,
          topics: topics,
          palette: palette,
          isEnglish: _speakeryUseEnglishUi(context, widget.isEnglish),
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}

class _GrammarLessonPlayerScreen extends StatefulWidget {
  final String level;
  final int initialTopicIndex;
  final List<GrammarTopic> topics;
  final _LevelPalette palette;
  final bool isEnglish;

  const _GrammarLessonPlayerScreen({
    required this.level,
    required this.initialTopicIndex,
    required this.topics,
    required this.palette,
    required this.isEnglish,
  });

  @override
  State<_GrammarLessonPlayerScreen> createState() =>
      _GrammarLessonPlayerScreenState();
}

class _GrammarLessonPlayerScreenState
    extends State<_GrammarLessonPlayerScreen> {
  static const Color _bg = Color(0xFF050710);
  static const Color _panel = Color(0xFF0B1020);
  static const Color _amber = Color(0xFFFFB020);

  late int topicIndex;
  int pageIndex = 0;
  bool showModelAnswer = false;
  bool chromeCollapsed = false;
  final PageController pageController = PageController();

  bool get useEnglishLabels => _speakeryUseEnglishUi(context, widget.isEnglish);

  String t(String en, String tr) => useEnglishLabels ? en : _repairMojibake(tr);

  List<String> get pageLabels => [
        t('Learn', 'Öğren'),
        t('Structure', 'Yapı'),
        t('Examples', 'Örnekler'),
        t('Usage', 'Kullanım'),
        t('Control', 'Kontrol'),
      ];
  GrammarTopic get topic => widget.topics[topicIndex];
  GrammarLesson get lesson => GrammarRepository.lessonForTopic(topic);
  _LevelPalette get palette => widget.palette;

  bool _completeCurrentLesson(int score, int total) {
    final progress = AppProgress.instance;
    final progressId = _grammarProgressId(widget.level, topic);
    final wasNew = !progress.isLessonCompleted(progressId);
    progress.completeLesson(progressId, rewardXP: _grammarLessonRewardXP);

    if (wasNew && mounted) {
      final tokens = SpeakeryThemeTokens.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: tokens.elevatedSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: palette.start, size: 20),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  t('Lesson complete · +$_grammarLessonRewardXP XP',
                      'Ders tamamlandı · +$_grammarLessonRewardXP XP'),
                  style: TextStyle(
                      color: tokens.textPrimary, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return wasNew;
  }

  @override
  void initState() {
    super.initState();
    topicIndex = widget.initialTopicIndex.clamp(0, widget.topics.length - 1);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void goToPage(int index) {
    final safeIndex = index.clamp(0, pageLabels.length - 1);
    setState(() {
      pageIndex = safeIndex;
      showModelAnswer = false;
    });
    if (pageController.hasClients) {
      pageController.animateToPage(
        safeIndex,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void nextStep() {
    if (pageIndex < pageLabels.length - 1) {
      goToPage(pageIndex + 1);
      return;
    }
    if (topicIndex < widget.topics.length - 1) {
      setState(() {
        topicIndex++;
        pageIndex = 0;
        showModelAnswer = false;
      });
      pageController.jumpToPage(0);
      return;
    }
    final tokens = SpeakeryThemeTokens.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: tokens.elevatedSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Text(
              t('You completed this grammar path.',
                  'Bu seviyedeki grammar yolunu bitirdin.'),
              style: TextStyle(
                  color: tokens.textPrimary, fontWeight: FontWeight.w800))),
    );
  }

  bool _handleLessonScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    final pixels = notification.metrics.pixels;

    // Morph only on real finger-driven vertical movement. Tapping an example card
    // changes the list height, so we ignore non-drag layout/ballistic updates.
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      final delta = notification.scrollDelta ?? 0;

      // Collapse early and decisively while scrolling down.
      if (!chromeCollapsed && pixels > 12 && delta > 0.15) {
        setState(() => chromeCollapsed = true);
      }

      // Expand only when the user is actually dragging back near the top.
      // This prevents bottom example expansions from toggling the header.
      if (chromeCollapsed && pixels < 18 && delta < -0.15) {
        setState(() => chromeCollapsed = false);
      }
    }

    return false;
  }

  Widget _lessonChrome(GrammarLesson currentLesson) {
    final collapsed = chromeCollapsed;
    const expandedHeight = 162.0;
    const collapsedHeight = 58.0;

    final expandedChrome = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _lessonTopBar(currentLesson),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _LessonProgress(
              current: pageIndex,
              total: pageLabels.length,
              color: palette.start),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _LessonStepTabs(
            labels: pageLabels,
            selectedIndex: pageIndex,
            color1: palette.start,
            color2: palette.end,
            onChanged: goToPage,
          ),
        ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
      height: collapsed ? collapsedHeight : expandedHeight,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeInOutCubic,
            top: collapsed ? -10 : 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: collapsed,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
                opacity: collapsed ? 0 : 1,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 480),
                  curve: Curves.easeInOutCubic,
                  scale: collapsed ? 0.985 : 1,
                  alignment: Alignment.topCenter,
                  child: expandedChrome,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeInOutCubic,
            top: collapsed ? 0 : 10,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !collapsed,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeInOutCubic,
                opacity: collapsed ? 1 : 0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 480),
                  curve: Curves.easeInOutCubic,
                  scale: collapsed ? 1 : 0.985,
                  alignment: Alignment.topCenter,
                  child: _collapsedLessonBar(currentLesson),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _collapsedLessonBar(GrammarLesson lesson) {
    final tokens = SpeakeryThemeTokens.of(context);
    final currentLabel = pageLabels[pageIndex.clamp(0, pageLabels.length - 1)];
    final progressText = '${pageIndex + 1}/${pageLabels.length}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => chromeCollapsed = false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: tokens.isLight
                      ? [
                          Color.alphaBlend(palette.start.withAlpha(18),
                              tokens.elevatedSurface),
                          tokens.inputSurface,
                        ]
                      : [
                          const Color(0xFF071A29).withAlpha(252),
                          const Color(0xFF07101D).withAlpha(250),
                        ],
                ),
                border: Border.all(
                  color: tokens.isLight
                      ? Color.alphaBlend(
                          palette.start.withAlpha(36), tokens.border)
                      : Colors.white.withAlpha(11),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            palette.start.withAlpha(16),
                            Colors.transparent,
                            palette.end.withAlpha(7),
                          ],
                          stops: const [0.0, 0.58, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(11, 0, 9, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 23,
                          height: 23,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: palette.start.withAlpha(17),
                          ),
                          child: Icon(_topicIconFor(topic),
                              color: palette.start, size: 12),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _localizedLessonTitle(lesson, useEnglishLabels),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: tokens.textPrimary,
                                  fontSize: 12.6,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.08,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                currentLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.start.withAlpha(205),
                                  fontSize: 10.2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: tokens.isLight
                                ? palette.start.withAlpha(12)
                                : Colors.white.withAlpha(8),
                          ),
                          child: Text(
                            progressText,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 10.8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: tokens.iconSecondary, size: 18),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final currentLesson = lesson;
    return Scaffold(
      backgroundColor: SpeakeryThemeTokens.of(context).background,
      body: _GradientPage(
        child: SafeArea(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleLessonScroll,
            child: Column(
              children: [
                _lessonChrome(currentLesson),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: pageLabels.length,
                    onPageChanged: (index) => setState(() {
                      pageIndex = index;
                      showModelAnswer = false;
                    }),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _LessonPageShell(
                            color: palette.start,
                            number: '01',
                            icon: Icons.lightbulb_rounded,
                            title: t('Learn', 'Öğren'),
                            child: _ExplainLesson(
                                lesson: currentLesson,
                                level: widget.level,
                                color: palette.start,
                                isEnglish: useEnglishLabels),
                          );
                        case 1:
                          return _LessonPageShell(
                            color: palette.end,
                            number: '02',
                            icon: Icons.schema_rounded,
                            title: t('Structure', 'Yapı'),
                            child: _FormLesson(
                                lesson: currentLesson,
                                rows: _normalizedFormulaRowsFor(currentLesson),
                                color: palette.end,
                                isEnglish: useEnglishLabels),
                          );
                        case 2:
                          return _LessonPageShell(
                            color: palette.start,
                            number: '03',
                            icon: Icons.format_quote_rounded,
                            title: t('Examples', 'Örnekler'),
                            child: _ExampleLesson(
                                lesson: currentLesson,
                                formulaRows:
                                    _normalizedFormulaRowsFor(currentLesson),
                                color: palette.start,
                                isEnglish: useEnglishLabels),
                          );
                        case 3:
                          return _LessonPageShell(
                            color: palette.end,
                            number: '04',
                            icon: Icons.forum_rounded,
                            title: t('Usage', 'Kullanım'),
                            child: _ContextLesson(
                              lesson: currentLesson,
                              formulaRows:
                                  _normalizedFormulaRowsFor(currentLesson),
                              color: palette.end,
                              isEnglish: useEnglishLabels,
                            ),
                          );
                        case 4:
                          return _LessonPageShell(
                            color: _amber,
                            number: '05',
                            icon: Icons.quiz_rounded,
                            title: t('Control', 'Kontrol'),
                            child: _QuizLesson(
                              key: ValueKey<String>('grammar-quiz-${topic.id}'),
                              lesson: currentLesson,
                              color: _amber,
                              isEnglish: useEnglishLabels,
                              onCompleted: _completeCurrentLesson,
                            ),
                          );
                        default:
                          return _LessonPageShell(
                            color: _amber,
                            number: '05',
                            icon: Icons.quiz_rounded,
                            title: t('Control', 'Kontrol'),
                            child: _QuizLesson(
                              key: ValueKey<String>('grammar-quiz-${topic.id}'),
                              lesson: currentLesson,
                              color: _amber,
                              isEnglish: useEnglishLabels,
                              onCompleted: _completeCurrentLesson,
                            ),
                          );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                          child: _LessonBottomButton(
                              icon: Icons.arrow_back_rounded,
                              label: pageIndex == 0
                                  ? t('Topics', 'Konular')
                                  : t('Back', 'Geri'),
                              color: Colors.white,
                              soft: true,
                              onTap: pageIndex == 0
                                  ? () => Navigator.pop(context)
                                  : () => goToPage(pageIndex - 1))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _LessonBottomButton(
                              icon: Icons.arrow_forward_rounded,
                              label: pageIndex == pageLabels.length - 1
                                  ? t('Next', 'Sonraki')
                                  : t('Continue', 'Devam'),
                              color: pageIndex == pageLabels.length - 1
                                  ? _amber
                                  : palette.start,
                              soft: false,
                              onTap: nextStep)),
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

  Widget _lessonTopBar(GrammarLesson lesson) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: _Glass(
        radius: 28,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.start.withAlpha(40),
              tokens.isLight
                  ? tokens.elevatedSurface.withAlpha(238)
                  : _panel.withAlpha(238),
              palette.end.withAlpha(26)
            ]),
        child: Row(
          children: [
            _TapScale(
                onTap: () => Navigator.pop(context),
                child: _CircleBackButton(color: palette.start, small: true)),
            const SizedBox(width: 10),
            _SoftIcon(icon: _topicIconFor(topic), color: palette.start),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_localizedLessonTitle(lesson, useEnglishLabels),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.35)),
                  const SizedBox(height: 3),
                  Text(
                      (widget.level == 'A1' || widget.level == 'A2')
                          ? '${widget.level} | ${topicIndex + 1}/${widget.topics.length}'
                          : '${widget.level} | ${_localizedTimeLabel(lesson.timeLabel, widget.isEnglish)} | ${topicIndex + 1}/${widget.topics.length}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 11.4,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localizedTimeLabel(String value, bool isEnglish) {
  final minutes = RegExp(r'\d+').firstMatch(value)?.group(0);
  if (minutes == null) return value.trim();
  return isEnglish ? '$minutes min' : '$minutes dk';
}

class _TopicCard extends StatelessWidget {
  final int index;
  final int total;
  final String level;
  final GrammarTopic topic;
  final _LevelPalette palette;
  final bool completed;
  final bool isEnglish;
  final VoidCallback onTap;

  const _TopicCard(
      {required this.index,
      required this.total,
      required this.level,
      required this.topic,
      required this.palette,
      required this.completed,
      required this.isEnglish,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final lesson = GrammarRepository.lessonForTopic(topic);
    final accent = _grammarAccentText(tokens, palette.start);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index.clamp(0, 8).toInt() * 34)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _TapScale(
        onTap: onTap,
        child: _Glass(
          radius: 28,
          borderColor: tokens.isLight
              ? _grammarGlassBorder(
                  tokens,
                  accent: palette.start,
                  strong: index == 0,
                )
              : null,
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tokens.isLight
                ? _grammarLightGlass(
                    palette.start,
                    strong: index == 0,
                  )
                : [
                    palette.start.withAlpha(index == 0 ? 42 : 24),
                    const Color(0xFF0B1020).withAlpha(238),
                    palette.end.withAlpha(20),
                  ],
          ),
          child: Row(
            children: [
              _LessonBadge(
                label: completed ? '✓' : '${index + 1}',
                color: completed ? const Color(0xFF22C55E) : palette.start,
              ),
              const SizedBox(width: 12),
              _SoftIcon(icon: _topicIconFor(topic), color: palette.start),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_localizedLessonTitle(lesson, isEnglish),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 15.8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2)),
                    const SizedBox(height: 4),
                    Text(_localizedLessonGoal(lesson, isEnglish),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 11.3,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _TopicMiniBadge(
                            label: level,
                            icon: Icons.workspace_premium_rounded,
                            color: palette.start),
                        _TopicMiniBadge(
                            label: _topicSkillLabel(topic, isEnglish),
                            icon: Icons.bolt_rounded,
                            color: palette.end),
                        if (completed)
                          _TopicMiniBadge(
                            label: isEnglish ? 'Completed' : 'Tamamlandı',
                            icon: Icons.check_rounded,
                            color: const Color(0xFF22C55E),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: tokens.isLight ? accent : tokens.iconSecondary,
                  size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrammarEmptyState extends StatelessWidget {
  final Color color;
  final bool isEnglish;

  const _GrammarEmptyState({required this.color, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _Glass(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withAlpha(24),
          tokens.isLight
              ? tokens.elevatedSurface
              : const Color(0xFF0B1020).withAlpha(238),
          tokens.isLight ? tokens.glassStrong : Colors.white.withAlpha(6)
        ],
      ),
      child: Column(
        children: [
          _SoftIcon(icon: Icons.auto_stories_rounded, color: color),
          const SizedBox(height: 12),
          Text(
            t('No grammar lessons here yet',
                'Bu seviyede henüz dil bilgisi dersi yok'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            t('Try another CEFR level while this path is being prepared.',
                'Bu yol hazırlanırken başka bir CEFR seviyesi dene.'),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 12.4,
                height: 1.35,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

IconData _topicIconFor(GrammarTopic topic) {
  final key = '${topic.title} ${topic.subtitle} ${topic.rule}'.toLowerCase();
  if (key.contains('question') || key.contains('wh ')) {
    return Icons.help_rounded;
  }
  if (key.contains('negative') || key.contains("n?t") || key.contains('not ')) {
    return Icons.remove_circle_outline_rounded;
  }
  if (key.contains('perfect')) return Icons.done_all_rounded;
  if (key.contains('continuous') || key.contains('progressive')) {
    return Icons.motion_photos_on_rounded;
  }
  if (key.contains('past')) return Icons.history_rounded;
  if (key.contains('future') ||
      key.contains('will') ||
      key.contains('going to')) {
    return Icons.event_available_rounded;
  }
  if (key.contains('condition')) return Icons.account_tree_rounded;
  if (key.contains('passive')) return Icons.swap_horiz_rounded;
  if (key.contains('reported')) return Icons.record_voice_over_rounded;
  if (key.contains('relative') || key.contains('clause')) {
    return Icons.hub_rounded;
  }
  if (key.contains('modal') ||
      key.contains('should') ||
      key.contains('must') ||
      key.contains('might')) {
    return Icons.tune_rounded;
  }
  if (key.contains('article')) return Icons.article_rounded;
  if (key.contains('plural') ||
      key.contains('countable') ||
      key.contains('many') ||
      key.contains('much')) {
    return Icons.format_list_numbered_rounded;
  }
  if (key.contains('preposition')) return Icons.place_rounded;
  if (key.contains('possessive') || key.contains('have got')) {
    return Icons.key_rounded;
  }
  if (key.contains('pronoun')) return Icons.person_rounded;
  if (key.contains('comparative') || key.contains('superlative')) {
    return Icons.compare_arrows_rounded;
  }
  if (key.contains('inversion') || key.contains('fronting')) {
    return Icons.swap_vert_circle_rounded;
  }
  if (key.contains('hedging') || key.contains('modality')) {
    return Icons.psychology_alt_rounded;
  }
  if (key.contains('register') || key.contains('style')) {
    return Icons.theater_comedy_rounded;
  }
  if (key.contains('nominal') || key.contains('noun phrase')) {
    return Icons.view_agenda_rounded;
  }
  return topic.icon;
}

String _topicSkillLabel(GrammarTopic topic, bool isEnglish) {
  final key = '${topic.title} ${topic.subtitle}'.toLowerCase();
  if (key.contains('speaking') ||
      key.contains('question') ||
      key.contains('reported')) {
    return isEnglish ? 'Speaking' : 'Konuşma';
  }
  if (key.contains('academic') ||
      key.contains('nominal') ||
      key.contains('hedging') ||
      key.contains('register')) {
    return isEnglish ? 'Writing' : 'Yazma';
  }
  if (key.contains('tense') ||
      key.contains('perfect') ||
      key.contains('past') ||
      key.contains('future') ||
      key.contains('present')) {
    return isEnglish ? 'Tense' : 'Zaman';
  }
  if (key.contains('conditional') || key.contains('if ')) {
    return isEnglish ? 'Logic' : 'Mantık';
  }
  if (key.contains('article') ||
      key.contains('pronoun') ||
      key.contains('noun')) {
    return isEnglish ? 'Core' : 'Temel';
  }
  return isEnglish ? 'Practice' : 'Pratik';
}

class _TopicMiniBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TopicMiniBadge(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(16),
        border: Border.all(color: color.withAlpha(35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11.5),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: tokens.isLight ? accent : Colors.white.withAlpha(170),
                fontSize: 9.8,
                fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LessonStepTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final Color color1;
  final Color color2;
  final ValueChanged<int> onChanged;

  const _LessonStepTabs({
    required this.labels,
    required this.selectedIndex,
    required this.color1,
    required this.color2,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final count = labels.isEmpty ? 1 : labels.length;
    final safeIndex = selectedIndex.clamp(0, count - 1);
    return IosLiquidPillSelector(
      items: labels.map(IosPillItem.new).toList(growable: false),
      selectedIndex: safeIndex,
      startColor: color1,
      endColor: color2,
      onChanged: onChanged,
    );
  }
}

class _LessonProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color color;

  const _LessonProgress(
      {required this.current, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: List.generate(total, (index) {
        final active = index <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 5),
            height: 5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: active
                    ? color
                    : tokens.isLight
                        ? tokens.border.withAlpha(170)
                        : Colors.white.withAlpha(13)),
          ),
        );
      }),
    );
  }
}

class _LessonPageShell extends StatelessWidget {
  final Color color;
  final String number;
  final IconData icon;
  final String title;
  final Widget child;

  const _LessonPageShell({
    required this.color,
    required this.number,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final roomy = constraints.maxWidth >= 980;
        final horizontal = roomy ? 30.0 : (wide ? 24.0 : 16.0);
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 940),
                child: _Glass(
                  radius: wide ? 38 : 32,
                  padding: EdgeInsets.fromLTRB(
                      wide ? 22 : 16, 16, wide ? 22 : 16, wide ? 22 : 18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      if (tokens.isLight)
                        ..._grammarLightGlass(color, strong: true)
                      else ...[
                        color.withAlpha(22),
                        const Color(0xFF0B1020).withAlpha(240),
                        const Color(0xFF050710).withAlpha(238),
                      ],
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ModeHeader(
                          number: number,
                          icon: icon,
                          title: title,
                          color: color),
                      const SizedBox(height: 16),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModeHeader extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final Color color;

  const _ModeHeader({
    required this.number,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
                colors: [color.withAlpha(58), color.withAlpha(18)]),
            border: Border.all(
              color: tokens.isLight
                  ? _grammarGlassBorder(tokens, accent: color, strong: true)
                  : color.withAlpha(45),
            ),
          ),
          child: Text(number,
              style: TextStyle(
                  color: tokens.isLight ? accent : Colors.white,
                  fontSize: 11.8,
                  fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 18),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Generator logic moved to lib/data/grammar/grammar_generator.dart.

class _ExplainLesson extends StatefulWidget {
  final GrammarLesson lesson;
  final String level;
  final Color color;
  final bool isEnglish;

  const _ExplainLesson({
    required this.lesson,
    required this.level,
    required this.color,
    required this.isEnglish,
  });

  @override
  State<_ExplainLesson> createState() => _ExplainLessonState();
}

class _ExplainLessonState extends State<_ExplainLesson> {
  int expandedFocusIndex = -1;

  bool get useEnglishLabels => widget.isEnglish;

  String t(String en, String tr) => useEnglishLabels ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final lessonKey = _lessonKey(widget.lesson);
    final showContentSupport =
        _showTurkishContentSupport(lessonKey, useEnglishLabels);
    final displayLesson =
        grammarDisplayLessonFor(widget.lesson, useEnglishLabels);
    final learnTitle = _grammarLearnTitleForDisplay(
        displayLesson.learnTitle(useEnglishLabels), widget.level,
        isEnglish: useEnglishLabels);
    final learnBody = _grammarLearnBodyForDisplay(
        displayLesson.learnBody(useEnglishLabels),
        isEnglish: useEnglishLabels);
    final teacherBullets = _grammarDisplayListForUi(
        displayLesson.structureBullets(useEnglishLabels),
        isEnglish: useEnglishLabels);
    final quickLookItems = _grammarDisplayListForUi(
        displayLesson.usageNotes(useEnglishLabels),
        isEnglish: useEnglishLabels,
        fallback: _genericTurkishGrammarUsageFallback);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PremiumBigIdeaCard(
          color: widget.color,
          title: learnTitle,
          goal: showContentSupport ? learnBody : '',
          sample: _learnModelSentenceFor(widget.lesson, useEnglishLabels),
          right: widget.lesson.right,
          wrong: _learnAvoidSentenceFor(widget.lesson, useEnglishLabels),
          isEnglish: useEnglishLabels,
          showModelBlock: false,
        ),
        const SizedBox(height: 12),
        _TeacherLogicCard(
          color: widget.color,
          bullets: showContentSupport ? teacherBullets : const <String>[],
          isEnglish: useEnglishLabels,
          isA1: true,
          showContent: showContentSupport,
        ),
        const SizedBox(height: 14),
        _QuickLookPanel(
          color: widget.color,
          isEnglish: useEnglishLabels,
          items: showContentSupport ? quickLookItems : const <String>[],
          showContent: showContentSupport,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

const String _genericTurkishGrammarUsageFallback =
    'Bu yapı, cümlede anlamı daha net kurmak için kullanılır. Örnekleri inceleyerek yapının gerçek kullanımını görebilirsin.';

String _grammarLearnTitleForDisplay(
  String value,
  String level, {
  required bool isEnglish,
}) {
  if (isEnglish) {
    final clean = _repairMojibake(value).trim();
    final keyTitle = _visibleGrammarKeyTitle(clean, isEnglish: true);
    return keyTitle ?? clean;
  }

  final clean = _repairVisibleGrammarText(value).trim();
  final keyTitle = _visibleGrammarKeyTitle(clean, isEnglish: false);
  if (keyTitle != null) return keyTitle;
  if (clean.isEmpty ||
      clean.toLowerCase().contains('konu anlat') ||
      _visibleTurkishTextLooksBroken(clean)) {
    return '$level dil bilgisi';
  }
  return clean;
}

String _grammarLearnBodyForDisplay(
  String value, {
  required bool isEnglish,
}) {
  if (isEnglish) return _repairMojibake(value).trim();

  final clean = _repairVisibleGrammarText(value).trim();
  if (clean.isEmpty || _visibleTurkishTextLooksBroken(clean)) {
    return _genericTurkishGrammarUsageFallback;
  }

  final sentences = clean
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((part) => part.trim().isNotEmpty)
      .take(3)
      .join(' ')
      .trim();
  return sentences.isEmpty ? clean : sentences;
}

List<String> _grammarDisplayListForUi(
  List<String> values, {
  required bool isEnglish,
  String fallback = '',
}) {
  final seen = <String>{};
  final cleaned = <String>[];
  for (final raw in values) {
    final repaired =
        isEnglish ? _repairMojibake(raw) : _repairVisibleGrammarText(raw);
    final value = _cleanVisibleGrammarSpacing(repaired)
        .replaceFirst(RegExp(r'^Kısa not:\s*'), '')
        .trim();
    final key = value.toLowerCase();
    if (value.isEmpty || seen.contains(key)) continue;
    if (!isEnglish && _visibleTurkishTextLooksBroken(value)) continue;
    seen.add(key);
    cleaned.add(value);
  }

  if (cleaned.isNotEmpty) return cleaned;
  if (!isEnglish && fallback.trim().isNotEmpty) return [fallback];
  return const <String>[];
}

String _cleanVisibleGrammarSpacing(String value) {
  return value
      .replaceAllMapped(RegExp(r'([.!?])(?=\S)'), (match) => '${match[1]} ')
      .replaceAll('NesneZamirleri', 'Nesne Zamirleri')
      .replaceAll('ÖzneZamirleri', 'Özne Zamirleri')
      .replaceAll('ÖzneveNesneZamirleri', 'Özne ve Nesne Zamirleri')
      .replaceAll('Özne ve NesneZamirleri', 'Özne ve Nesne Zamirleri')
      .replaceAll('wh-sorular1', 'wh-soruları')
      .replaceAll('Wh-sorular1', 'Wh-soruları')
      .replaceAll('Soru yap?s?', 'Soru yapısı')
      .replaceAll('Soruyapısı', 'Soru yapısı')
      .replaceAll('Kullan1m', 'Kullanım')
      .replaceAll('K1sa', 'Kısa')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String? _visibleGrammarKeyTitle(String value, {required bool isEnglish}) {
  final key = value.trim();
  const en = <String, String>{
    'a1_be_verb': 'Be Verb',
    'a1_subject_pronouns': 'Subject Pronouns',
    'a1_possessive_adjectives': 'Possessive Adjectives',
    'a1_there_is_are': 'There is / There are',
    'a1_articles': 'Articles',
    'a1_singular_plural': 'Singular / Plural',
    'a1_present_simple': 'Present Simple',
    'a1_present_continuous': 'Present Continuous',
    'a1_can_cant': "Can / Can't",
    'a1_have_has_got': 'Have got / Has got',
    'a1_basic_prepositions': 'Basic Prepositions',
    'a1_imperatives': 'Imperatives',
    'a1_demonstratives': 'Demonstratives',
  };
  const tr = <String, String>{
    'a1_be_verb': 'To Be / Olmak Fiili',
    'a1_subject_pronouns': 'Özne Zamirleri',
    'a1_possessive_adjectives': 'İyelik Sıfatları',
    'a1_there_is_are': 'There is / There are',
    'a1_articles': 'A / An / The',
    'a1_singular_plural': 'Tekil / Çoğul',
    'a1_present_simple': 'Geniş Zaman',
    'a1_present_continuous': 'Şimdiki Zaman',
    'a1_can_cant': "Can / Can't",
    'a1_have_has_got': 'Have got / Has got',
    'a1_basic_prepositions': 'Temel Edatlar',
    'a1_imperatives': 'Emir Cümleleri',
    'a1_demonstratives': 'İşaret Zamirleri',
  };
  return isEnglish ? en[key] : tr[key];
}

bool _visibleTurkishTextLooksBroken(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return false;
  return clean.contains('ï¿½') ||
      clean.contains('�') ||
      RegExp(r'[ÃÄÅ]').hasMatch(clean) ||
      RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]1[A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(clean) ||
      RegExp(r'[A-Za-zÇĞİÖŞÜçğıöşü]\?[A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(clean);
}

String _hardTurkishLearnTitleFor(GrammarLesson lesson, String level) {
  final cleanTitle = _repairVisibleGrammarText(
    lesson.bigTitle.split('=').first.trim(),
  );
  if (level == 'A1' && cleanTitle.isNotEmpty) return cleanTitle;
  if (cleanTitle.isEmpty) return '$level dil bilgisi';
  return cleanTitle;
}

String _hardTurkishLearnBodyFor(GrammarLesson lesson, String level) {
  final raw =
      '${lesson.bigTitle} ${lesson.oneLineGoal} ${lesson.teacherIntro} ${lesson.right} ${lesson.examples.join(' ')}'
          .toLowerCase();

  if (raw.contains('present simple')) {
    return 'Present Simple; rutinler, alışkanlıklar ve genel doğrular için kullanılır. I, you, we, they ile fiilin yalın hali kullanılır; he, she, it ile olumlu cümlede fiile genellikle -s veya -es gelir. Sorularda ve olumsuzlarda do / does yardımcı fiilini kontrol etmek gerekir.';
  }
  if (raw.contains('present continuous')) {
    return 'Present Continuous, şu anda devam eden eylemleri veya yakın geleceğe ait kesin planları anlatmak için kullanılır. Yapı am / is / are + V-ing şeklindedir. Cümlede now, at the moment, today gibi zaman ipuçları varsa bu yapıyı düşün.';
  }
  if (raw.contains('past simple')) {
    return 'Past Simple, geçmişte belirli bir zamanda başlayıp bitmiş olayları anlatır. Düzenli fiillerde -ed kullanılır; düzensiz fiillerin ikinci hali gerekir. Olumsuz ve soru cümlelerinde did kullanıldığı için ana fiil yalın hale döner.';
  }
  if (raw.contains('past continuous')) {
    return 'Past Continuous, geçmişte belirli bir anda devam eden eylemi anlatır. Yapı was / were + V-ing şeklindedir. Genellikle arka plan eylemi verir veya bir eylem devam ederken başka bir olayın olduğunu gösterir.';
  }
  if (raw.contains('present perfect')) {
    return 'Present Perfect, geçmişte olan bir olayın bugünkü etkisini, sonucunu veya deneyim anlamını anlatır. Yapı have / has + V3 şeklindedir. Zamanın tam olarak ne zaman olduğu önemli değilse veya sonuç hâlâ bugünle bağlantılıysa bu yapı kullanılır.';
  }
  if (raw.contains('past perfect')) {
    return 'Past Perfect, geçmişteki iki olaydan daha önce gerçekleşeni göstermek için kullanılır. Yapı had + V3 şeklindedir. Bir geçmiş olaydan bahsederken ondan önce tamamlanmış başka bir olayı netleştirir.';
  }
  if (raw.contains('future perfect continuous')) {
    return 'Future Perfect Continuous, gelecekteki bir noktaya kadar ne kadar süredir devam etmiş olacak bir eylemi anlatır. Yapı will have been + V-ing şeklindedir. Süre vurgusu önemliyse for veya since gibi ifadelerle kullanılır.';
  }
  if (raw.contains('future perfect')) {
    return 'Future Perfect, gelecekte belirli bir zamandan önce tamamlanmış olacak eylemleri anlatır. Yapı will have + V3 şeklindedir. By Friday, by then, before gibi ifadeler bu yapının önemli ipuçlarıdır.';
  }
  if (raw.contains('future continuous')) {
    return 'Future Continuous, gelecekte belirli bir anda devam ediyor olacak eylemleri anlatır. Yapı will be + V-ing şeklindedir. Planlı akışları veya gelecekteki bir zaman diliminde süren durumları anlatırken kullanılır.';
  }
  if (raw.contains('will') || raw.contains('going to')) {
    return 'Gelecek zaman yapıları; tahmin, plan, ani karar veya gelecekte olacak olayları anlatmak için kullanılır. Will daha çok ani karar, tahmin ve tekliflerde; be going to ise planlarda ve mevcut kanıta dayalı tahminlerde kullanılır.';
  }
  if (raw.contains('conditional') || raw.contains('if ')) {
    return 'Conditional yapılar, şart ve sonuç ilişkisi kurmak için kullanılır. If kısmı şartı, diğer kısım sonucu anlatır. Gerçek ihtimal, hayali durum veya geçmişte gerçekleşmemiş durumlara göre tense seçimi değişir.';
  }
  if (raw.contains('passive')) {
    return 'Passive voice, eylemi yapan kişiden çok eylemin kendisine veya sonucuna odaklanır. Yapı be + V3 temelindedir ve tense değiştikçe be fiili değişir. Yapan kişi önemli değilse, bilinmiyorsa veya vurgulanmak istenmiyorsa passive daha doğaldır.';
  }
  if (raw.contains('modal')) {
    return 'Modal yapılar; olasılık, zorunluluk, tavsiye, izin veya çıkarım gibi anlamları verir. Modal fiilden sonra ana fiil yalın kullanılır. Anlamı doğru seçmek için bağlamı ve konuşanın niyetini iyi okumak gerekir.';
  }
  if (raw.contains('reported')) {
    return 'Reported Speech, birinin söylediği şeyi doğrudan alıntı yapmadan aktarmak için kullanılır. Cümlede zaman, zamir ve yer-zaman ifadeleri bağlama göre değişebilir. Amaç, sözü doğal ve dolaylı şekilde aktarmaktır.';
  }
  if (raw.contains('relative')) {
    return 'Relative clauses, bir isim hakkında ek bilgi vermek için kullanılır. Who, which, that, where gibi kelimelerle kişiyi, nesneyi veya yeri açıklarız. Cümlenin ana fikrini bozmadan daha detaylı anlatım sağlar.';
  }
  if (raw.contains('gerund') || raw.contains('infinitive')) {
    return 'Gerund ve infinitive yapıları, fiilden sonra gelen ikinci eylemi doğru biçimde kullanmayı öğretir. Bazı fiillerden sonra V-ing, bazı fiillerden sonra to + V1 gelir. Doğru seçim çoğu zaman ilk fiilin kalıbına bağlıdır.';
  }
  if (raw.contains('comparative') || raw.contains('superlative')) {
    return 'Karşılaştırma yapıları, iki şeyi kıyaslamak veya bir grubun en belirgin üyesini anlatmak için kullanılır. Kısa sıfatlarda -er / -est, uzun sıfatlarda more / the most kullanılır. Irregular formlara özellikle dikkat edilir.';
  }
  if (raw.contains('article') || raw.contains('a / an / the')) {
    return 'Articles, bir ismin genel mi yoksa belirli mi olduğunu gösterir. A / an ilk kez bahsedilen veya genel tekil isimlerde kullanılır; the ise konuşan ve dinleyenin bildiği belirli isimlerde kullanılır.';
  }
  if (raw.contains('preposition') || raw.contains('in / on / at')) {
    return 'Prepositions, yer ve zaman ilişkisini gösterir. In daha geniş alan ve zamanlarda, on yüzey ve günlerde, at ise nokta yerler ve saatlerde kullanılır. Doğru seçim cümlenin bağlamına göre yapılır.';
  }
  if (raw.contains('inversion')) {
    return 'Inversion, cümleye vurgu veya daha resmi bir ton katmak için kelime sırasının değişmesidir. Özellikle olumsuz zarflardan sonra yardımcı fiil öznenin önüne gelir. Bu yapı ileri seviyede daha güçlü ve etkili anlatım sağlar.';
  }
  if (raw.contains('hedging')) {
    return 'Hedging, kesin konuşmak istemediğimizde ifadeyi daha ölçülü ve dikkatli hale getirir. Özellikle akademik, resmi veya hassas konularda iddiayı yumuşatır. This is wrong yerine This appears to be inaccurate gibi ifadeler kullanılır.';
  }
  if (raw.contains('cleft') || raw.contains('emphasis')) {
    return 'Vurgu yapıları, cümlede özellikle öne çıkarmak istediğimiz bilgiyi belirginleştirir. Normal bir cümleyi daha etkili, daha net veya daha dramatik hale getirir. İleri seviyede anlam kadar ton kontrolü de önemlidir.';
  }
  if (raw.contains('nominalisation') || raw.contains('nominalization')) {
    return 'Nominalisation, fiil veya sıfat temelli bir fikri isim yapısına çevirerek daha resmi ve yoğun bir anlatım kurar. Akademik ve profesyonel yazıda cümleyi daha nesnel ve kompakt hale getirir.';
  }

  if (level == 'A1') {
    return 'Bu derste temel İngilizce cümle kurma mantığını öğrenirsin. Konunun anlamını, hangi durumda kullanıldığını ve basit cümle düzenini adım adım görürsün. Örnek cümleleri inceleyerek yapının gerçek cümlede nasıl çalıştığını fark edebilirsin.';
  }
  if (level == 'A2') {
    return 'Bu derste yapının günlük İngilizcede ne zaman ve nasıl kullanıldığını öğrenirsin. Anlamı, cümle düzenini ve sık yapılan seçimleri birlikte düşünmen gerekir. Örnekler üzerinden yapının doğal kullanımı netleşir.';
  }
  if (level == 'B1') {
    return 'Bu derste yapının iletişimde hangi anlamı taşıdığını ve benzer yapılardan nasıl ayrıldığını öğrenirsin. Cümlede yardımcı fiil, zaman ve bağlam seçimi önemlidir. Amaç sadece formu değil, doğru durumda doğru yapıyı kullanmaktır.';
  }
  if (level == 'B2') {
    return 'Bu derste yapının daha olgun ve doğal İngilizcede nasıl kullanıldığını öğrenirsin. Konu; iş, okul, günlük konuşma ve yazılı anlatımda anlamı daha net kurmana yardım eder. Bağlam, ton ve doğru yapı seçimi birlikte düşünülmelidir.';
  }
  if (level == 'C1') {
    return 'Bu derste ileri seviye dil kontrolü, vurgu ve nüans üzerinde çalışırsın. Yapı sadece gramer olarak değil, resmi ton, bağlam ve anlatım gücü açısından değerlendirilir. Amaç daha doğal, kontrollü ve esnek cümleler kurmaktır.';
  }
  return 'Bu derste ileri düzey İngilizcede anlamı, tonu ve bilgi akışını daha hassas yönetmeyi öğrenirsin. Yapı; akademik, profesyonel veya resmi bağlamlarda daha ölçülü ve etkili anlatım kurmana yardım eder. Örneklerde form kadar vurgu ve bağlam ilişkisine de dikkat et.';
}

List<String> _hardTurkishLearnBulletsFor(GrammarLesson lesson, String level) {
  final body = _hardTurkishLearnBodyFor(lesson, level);
  final parts = body
      .split(RegExp(r'(?<=\.)\s+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .take(3)
      .toList(growable: false);
  return parts.isEmpty ? [body] : parts;
}

List<String> _hardTurkishUsageNotesFor(GrammarLesson lesson, String level) {
  final body = _hardTurkishLearnBodyFor(lesson, level);
  final title =
      _repairVisibleGrammarText(lesson.bigTitle.split('=').first.trim());
  return [
    'Bu yapıyı gerçek iletişimde anlamı daha net vermek için kullanırsın.',
    'Bağlamı kontrol et: zaman, özne, yardımcı fiil ve cümle sırası doğru olmalı.',
    title.isEmpty
        ? 'Örnek cümleleri okuyup aynı yapıyla kendi cümleni kur.'
        : '$title için örnek cümleleri okuyup aynı yapıyla kendi cümleni kur.',
    body.split('.').first.trim().isEmpty
        ? body
        : '${body.split('.').first.trim()}.',
  ];
}

String _canonicalRowModel(GrammarFormulaRow row) {
  final label = row.label.toLowerCase().trim();
  final pattern = row.pattern.toLowerCase().trim();
  final sample = _cleanOptionSentence(row.sample);
  final kind = _rowKind(row);

  bool sampleHasNegative(String v) {
    final l = v.toLowerCase();
    return l.contains(' not ') ||
        l.contains("n?t") ||
        l.contains(' do not ') ||
        l.contains(' does not ') ||
        l.contains(' did not ') ||
        l.contains(' will not ');
  }

  if (kind == 'question' && !sample.trim().endsWith('?')) {
    if (pattern.contains('did')) return 'Did you call me?';
    if (pattern.contains('was') || pattern.contains('were')) {
      return 'Were you studying?';
    }
    if (pattern.contains('will')) return 'Will you join us?';
    if (pattern.contains('should')) return 'Should I call her?';
    if (pattern.contains('going to')) return 'Are you going to join us?';
    if (pattern.contains('have') || pattern.contains('has')) {
      return 'Have you finished your homework?';
    }
    if (pattern.contains('do') || pattern.contains('does')) {
      return 'Does she work every day?';
    }
  }

  if (kind == 'negative' && !sampleHasNegative(sample)) {
    if (pattern.contains('did') || label.contains('did')) {
      return 'I did not go to school.';
    }
    if (pattern.contains('was') || pattern.contains('were')) {
      return 'She was not sleeping.';
    }
    if (pattern.contains('will')) return 'They will not come tonight.';
    if (pattern.contains('should')) return 'You should not sleep late.';
    if (pattern.contains('have to') || pattern.contains('has to')) {
      return 'He does not have to come today.';
    }
    if (pattern.contains('enough')) return 'The room is not big enough.';
    if (pattern.contains('do') ||
        pattern.contains('does') ||
        label.contains('don') ||
        label.contains('doesn')) {
      return 'I do not work every day.';
    }
    return 'I do not work every day.';
  }

  if (kind == 'positive') {
    if ((label.contains('i / you / we / they') ||
            label.contains('you / we') ||
            label.contains('i/you/we/they')) &&
        RegExp(r'^(he|she|it)\b', caseSensitive: false).hasMatch(sample)) {
      return 'I work every day.';
    }
    if ((label.contains('he / she / it') ||
            label.contains('he/she/it') ||
            label.contains('he / she')) &&
        !RegExp(r'^(he|she|it)\b', caseSensitive: false).hasMatch(sample)) {
      return 'She works every day.';
    }
  }

  if (kind == 'irregular' ||
      kind == 'spelling' ||
      kind == 'time' ||
      kind == 'comparison' ||
      kind == 'superlative' ||
      kind == 'condition' ||
      kind == 'modal' ||
      kind == 'passive') {
    if (sample.isNotEmpty &&
        _isSentenceLike(sample) &&
        !_looksLikeMetaOption(sample)) {
      return sample;
    }
  }

  if (sample.isNotEmpty &&
      _isSentenceLike(sample) &&
      !_looksLikeMetaOption(sample)) {
    return sample;
  }
  return 'I use this structure correctly.';
}

String _rowPointText(GrammarFormulaRow row, bool isEnglish) {
  final label = _formulaLabel(row, isEnglish);
  final kind = _rowKind(row);
  if (kind == 'positive') {
    return isEnglish ? 'Build the $label form.' : '$label yapıyı doğru kur.';
  }
  if (kind == 'negative') {
    return isEnglish ? 'Build the negative form.' : 'Olumsuz yapıyı doğru kur.';
  }
  if (kind == 'question') {
    return isEnglish ? 'Build the question form.' : 'Soru yapısını doğru kur.';
  }
  if (kind == 'irregular') {
    return isEnglish ? 'Notice the irregular form.' : 'Düzensiz formu fark et.';
  }
  if (kind == 'spelling') {
    return isEnglish
        ? 'Notice the spelling change.'
        : 'Yazım değişimini fark et.';
  }
  if (kind == 'time') {
    return isEnglish
        ? 'Use the time signal correctly.'
        : 'Zaman ifadesini doğru kullan.';
  }
  if (kind == 'comparison') {
    return isEnglish
        ? 'Compare with the correct form.'
        : 'Karşılaştırmayı doğru formla yap.';
  }
  if (kind == 'modal') {
    return isEnglish
        ? 'Keep the verb after the modal simple.'
        : 'Modal sonrasında fiili yalın bırak.';
  }
  if (kind == 'condition') {
    return isEnglish
        ? 'Connect the two parts clearly.'
        : 'İki parçayı net bağla.';
  }
  return label;
}

String _learnModelSentenceFor(GrammarLesson lesson, bool isEnglish) {
  final blueprint = generateGrammarLogicPoints(lesson);
  if (blueprint.isNotEmpty && _isGoodModelCandidate(blueprint.first.model)) {
    return blueprint.first.model;
  }

  for (final row in _normalizedFormulaRowsFor(lesson)) {
    final model = _canonicalRowModel(row);
    if (_isGoodModelCandidate(model)) return model;
  }

  final right = _cleanOptionSentence(lesson.right);
  if (_isGoodModelCandidate(right)) return right;

  for (final example in lesson.examples) {
    final sample = _cleanOptionSentence(example);
    if (_isGoodModelCandidate(sample)) return sample;
  }

  final key = _lessonKey(lesson);
  final byKey = <String, String>{
    'a2_past_simple': 'I watched a movie yesterday.',
    'a2_past_continuous': 'I was studying when you called.',
    'a2_comparatives': 'Kayseri is colder than Antalya.',
    'a2_superlatives': 'She is the tallest student in the class.',
    'a2_will': 'I will help you after class.',
    'a2_going_to': 'I am going to study tonight.',
    'a2_must_have_to': 'You must wear a seat belt.',
    'a2_should': 'You should drink more water.',
    'a2_too_enough': 'He is old enough to drive.',
    'a2_present_perfect': 'I have visited Istanbul twice.',
  };
  return byKey[key] ??
      (isEnglish
          ? 'I use the target structure correctly.'
          : 'I use the target structure correctly.');
}

bool _isGoodModelCandidate(String value) {
  final clean = _cleanOptionSentence(value);
  if (clean.isEmpty || !_isSentenceLike(clean) || _looksLikeMetaOption(clean)) {
    return false;
  }
  final lower = clean.toLowerCase();
  if (lower.startsWith('use ') ||
      lower.startsWith('avoid ') ||
      lower.startsWith('do not ') ||
      lower.startsWith("don't ")) {
    return false;
  }
  if (lower.startsWith('remember ') ||
      lower.startsWith('after ') ||
      lower.startsWith('before ')) {
    return false;
  }
  return true;
}

String _learnAvoidSentenceFor(GrammarLesson lesson, bool isEnglish) {
  final blueprint = generateGrammarLogicPoints(lesson);
  if (blueprint.isNotEmpty && _isGoodAvoidCandidate(blueprint.first.avoid)) {
    return blueprint.first.avoid;
  }

  final rows = _normalizedFormulaRowsFor(lesson);
  if (rows.isNotEmpty) {
    final first = rows.first;
    final model = _canonicalRowModel(first);
    final avoid = _cleanOptionSentence(_formulaAvoidSample(
        GrammarFormulaRow(
            label: first.label, pattern: first.pattern, sample: model),
        true));
    if (_isGoodAvoidCandidate(avoid) &&
        avoid.toLowerCase() != model.toLowerCase()) {
      return avoid;
    }
  }

  final model = _learnModelSentenceFor(lesson, true);
  final generated = _cleanOptionSentence(_smartCommonMistake(model, '', true));
  if (_isGoodAvoidCandidate(generated) &&
      generated.toLowerCase() != model.toLowerCase()) {
    return generated;
  }

  final key = _lessonKey(lesson);
  final byKey = <String, String>{
    'a2_past_simple': 'I watch a movie yesterday.',
    'a2_past_continuous': 'I studying when you called.',
    'a2_comparatives': 'Kayseri is more cold than Antalya.',
    'a2_superlatives': 'She is tallest student in the class.',
    'a2_will': 'I will helps you after class.',
    'a2_going_to': 'I going to study tonight.',
    'a2_must_have_to': 'You must to wear a seat belt.',
    'a2_should': 'You should drinks more water.',
    'a2_too_enough': 'He is enough old to drive.',
    'a2_present_perfect': 'I have visited Istanbul yesterday.',
  };
  return byKey[key] ?? 'I did not went to school.';
}

bool _isGoodAvoidCandidate(String value) {
  final clean = _cleanOptionSentence(value);
  if (clean.isEmpty || !_isSentenceLike(clean) || _looksLikeMetaOption(clean)) {
    return false;
  }
  final lower = clean.toLowerCase();
  if (lower.startsWith('use ') ||
      lower.startsWith('avoid ') ||
      lower.startsWith('do not ') ||
      lower.startsWith("don't ")) {
    return false;
  }
  if (lower.startsWith('remember ') ||
      lower.startsWith('after ') ||
      lower.startsWith('before ')) {
    return false;
  }
  if (lower.contains('keep the main verb') ||
      lower.contains('forget') ||
      lower.contains('dikkat') ||
      lower.contains('unutma')) {
    return false;
  }
  return true;
}

String _learnRuleReasonFor(GrammarLesson lesson, bool isEnglish) {
  final key = _lessonKey(lesson);
  final a1Reason = _a1LearnRuleReason(key, isEnglish);
  if (a1Reason != null) return a1Reason;
  if (isEnglish) {
    final map = <String, String>{
      'b2_future_perfect':
          'Future Perfect is will have + V3 and means completed before a future point.',
      'b2_future_perfect_continuous':
          'Future Perfect Continuous is will have been + V-ing and emphasizes duration up to a future point.',
      'b2_inversion_intro':
          'After negative or limiting adverbials, use auxiliary + subject + verb.',
      'c1_full_inversion':
          'In formal inversion, the helper verb comes before the subject.',
      'a2_will': 'After will, use the base verb without -s.',
      'a2_so_such':
          'Use so before adjective/adverb; use such before adjective + noun.',
    };
    return map[key] ??
        _englishReasonFor(
            right: lesson.right, wrong: lesson.wrong, reason: lesson.reason);
  }
  final map = <String, String>{
    'b2_future_perfect':
        'Future Perfect yapısı will have + V3 olur; anlamı gelecekte bir noktadan önce tamamlanmış olma durumudur.',
    'b2_future_perfect_continuous':
        'Future Perfect Continuous yapısı will have been + V-ing olur; gelecekte bir noktaya kadar sürecek süreyi vurgular.',
    'b2_inversion_intro':
        'Olumsuz veya sınırlayıcı ifade başa gelince yardımcı fiil öznenin önüne alınır.',
    'c1_full_inversion':
        'Resmi inversion yapısında yardımcı fiil öznenin önüne gelir.',
    'c1_cleft_sentences':
        'Cleft yapılar cümlenin önemli bilgisini öne çıkarır.',
    'a2_past_simple':
        'Did / did not geldiyse fiil V1 kalır. Olumlu cümlede V2 kullanılır.',
    'a2_past_continuous':
        'Past Continuous yapısında V-ingden önce was / were gerekir.',
    'a2_comparatives': 'More ve -er aynı anda kullanılmaz.',
    'a2_superlatives':
        'Superlative yapıda çoğu zaman sıfattan önce the gerekir.',
    'a2_will': 'Willden sonra fiil V1 kalır; -s gelmez.',
    'a2_going_to': 'Going to yapısında am / is / are eksik olamaz.',
    'a2_so_such':
        'So sıfat/zarfı güçlendirir; such ise adjective + noun grubundan önce gelir.',
  };
  return map[key] ??
      'Bu yapıda anlam, yardımcı fiil ve ana fiil formu birlikte kontrol edilmelidir.';
}

String? _a1LearnRuleReason(String key, bool isEnglish) {
  final en = <String, String>{
    'a1_be_verb':
        'Choose am, is or are from the subject: I am, he/she/it is, you/we/they are. In questions, be moves before the subject; in negatives, not comes after be.',
    'a1_subject_pronouns':
        'Use subject pronouns for the person or thing doing the action. Do not repeat a name and a pronoun in the same subject position.',
    'a1_possessive_adjectives':
        'A possessive adjective comes before a noun: my bag, his phone, her room. He/she are subjects; his/her show possession.',
    'a1_there_is_are':
        'Use there is with one thing and there are with more than one thing. In questions, is/are moves to the front.',
    'a1_articles':
        'Use a/an for one general countable thing and the for a specific or known thing. Choose a/an by sound.',
    'a1_singular_plural':
        'After numbers above one, countable nouns become plural: two books, three boxes. Some common plurals are irregular.',
    'a1_present_simple':
        'Use Present Simple for routines, habits and facts. He/she/it takes -s in positive sentences, but after do/does/don\'t/doesn\'t the verb stays base.',
    'a1_present_continuous':
        'Use am/is/are + V-ing for actions happening now. Do not drop the be verb before the -ing form.',
    'a1_can_cant':
        'After can or can\'t, the verb stays base: can swim, can help. Do not use to, -s or -ing after can.',
    'a1_have_has_got':
        'Use have got with I/you/we/they and has got with he/she/it. In questions, Have/Has moves to the front.',
    'a1_basic_prepositions':
        'Use in for inside/wider time, on for surfaces/days, and at for exact points or clock times.',
    'a1_imperatives':
        'Imperatives usually start with the base verb. Use Don\'t + base verb for negative commands and please for a softer tone.',
    'a1_demonstratives':
        'Use this/that for one thing and these/those for plural things. This/these are near; that/those are far.',
  };
  final tr = <String, String>{
    'a1_be_verb':
        'Özneye göre am, is veya are seçilir: I am, he/she/it is, you/we/they are. Soruda be başa gelir; olumsuzda not, be fiilinden sonra gelir.',
    'a1_subject_pronouns':
        'Subject pronoun işi yapan kişi veya şeyi gösterir. Aynı özne yerinde hem isim hem zamir kullanma.',
    'a1_possessive_adjectives':
        'Sahiplik sıfatı isimden önce gelir: my bag, his phone, her room. He/she özne olur; his/her sahiplik anlatır.',
    'a1_there_is_are':
        'Tek bir şey için there is, birden fazla şey için there are kullanılır. Soruda is/are başa gelir.',
    'a1_articles':
        'a/an genel bir tekil sayılabilen isim içindir; the belirli veya bilinen şey içindir. a/an seçimi sese göre yapılır.',
    'a1_singular_plural':
        'Birden fazla sayılabilen isim çoğul olur: two books, three boxes. Bazı yaygın çoğullar düzensizdir.',
    'a1_present_simple':
        'Present Simple rutin, alışkanlık ve genel gerçek anlatır. He/she/it olumlu cümlede -s alır; do/does/don\'t/doesn\'t sonrasında fiil yalın kalır.',
    'a1_present_continuous':
        'Present Continuous şu anda olan eylem için am/is/are + V-ing ister. -ing fiilinden önce be fiilini düşürme.',
    'a1_can_cant':
        'Can/can\'t sonrasında fiil yalın kalır: can swim, can help. Can sonrasında to, -s veya -ing kullanılmaz.',
    'a1_have_has_got':
        'I/you/we/they ile have got; he/she/it ile has got kullanılır. Soruda Have/Has başa gelir.',
    'a1_basic_prepositions':
        'in iç/ay/yıl, on yüzey/gün, at nokta veya saat anlatır.',
    'a1_imperatives':
        'Imperative genelde yalın fiille başlar. Olumsuz emir için Don\'t + yalın fiil, daha kibar ton için please kullanılır.',
    'a1_demonstratives':
        'This/that tekil; these/those çoğuldur. This/these yakın, that/those uzak şeyleri gösterir.',
  };
  return isEnglish ? en[key] : tr[key];
}

String _localizedLessonTitle(GrammarLesson lesson, bool isEnglish) {
  return grammarDisplayLessonFor(lesson, isEnglish).learnTitle(isEnglish);
}

String _legacyLocalizedLessonTitle(GrammarLesson lesson, bool isEnglish) {
  if (isEnglish) return lesson.bigTitle;
  final key = _lessonKey(lesson);
  const titles = <String, String>{
    'a1_be_verb': 'Be: am / is / are',
    'a1_subject_pronouns': 'Özne ve Nesne Zamirleri',
    'a1_possessive_adjectives': 'Sahiplik Yapıları',
    'a1_there_is_are': 'There is / There are',
    'a1_articles': 'Articles: a / an / the',
    'a1_singular_plural': 'Çoğul ve Miktar Temelleri',
    'a1_present_simple': 'Present Simple',
    'a1_present_continuous': 'Present Continuous',
    'a1_can_cant': 'Can / Can\'t',
    'a1_have_has_got': 'Have got / Has got',
    'a1_basic_prepositions': 'in / on / at',
    'a1_imperatives': 'Imperatives',
    'a1_demonstratives': 'This / That / These / Those',
    'a2_past_simple': 'Past Simple',
    'a2_will': 'Future with will',
    'a2_going_to': 'Be going to',
    'a2_comparatives': 'Comparatives',
    'a2_superlatives': 'Superlatives',
    'a2_countable_uncountable': 'Sayılabilen / Sayılamayan İsimler',
    'a2_some_any_much_many': 'Some / Any / Much / Many / A lot of',
    'a2_should': 'Should / Shouldn\'t',
    'a2_must_have_to': 'Must / Have to',
    'a2_object_possessive_pronouns': 'Nesne ve Sahiplik Zamirleri',
    'a2_adverbs_frequency_manner': 'Sıklık ve Durum Zarfları',
    'a2_infinitive_purpose': 'Amaç Bildiren Infinitive',
    'a2_gerund_infinitive': 'Gerund ve Infinitive Giriş',
  };
  return _repairMojibake(titles[key] ?? lesson.bigTitle);
}

String _localizedLessonGoal(GrammarLesson lesson, bool isEnglish) {
  final body = grammarDisplayLessonFor(lesson, isEnglish).learnBody(isEnglish);
  return body
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((part) => part.trim())
      .firstWhere((part) => part.isNotEmpty, orElse: () => body.trim());
}

String _legacyLocalizedLessonGoal(GrammarLesson lesson, bool isEnglish) {
  if (isEnglish) return lesson.oneLineGoal;
  final key = _lessonKey(lesson);
  const goals = <String, String>{
    'a1_be_verb':
        'Kimlik, duygu, yer ve kısa cevaplarda doğru be fiilini kullan.',
    'a1_subject_pronouns':
        'Kişi ve nesneleri özne veya nesne zamiriyle doğru değiştir.',
    'a1_possessive_adjectives':
        'my, your, his, her, \'s ve whose ile sahipliği anlat.',
    'a1_there_is_are': 'Bir yerde ne var/yok, tekil ve çoğula göre söyle.',
    'a1_articles': 'a, an ve the seçimini netleştir.',
    'a1_singular_plural':
        'Tekil/çoğul isimleri ve temel miktar kelimelerini hızlı ayır.',
    'a1_present_simple':
        'Rutin, sıklık, wh-soruları ve sevme/sevmeme cümlelerini kur.',
    'a1_present_continuous': 'Şu anda olan eylemi am/is/are + V-ing ile anlat.',
    'a1_can_cant': 'Yetenek, izin ve ricayı can/can\'t ile kur.',
    'a1_have_has_got': 'Sahiplik ve aile bilgisini have/has got ile söyle.',
    'a1_basic_prepositions': 'Yer ve zamanı in, on, at ile doğal söyle.',
    'a1_imperatives': 'Kısa komut ve yönergeleri yalın fiille ver.',
    'a1_demonstratives': 'Yakın/uzak ve tekil/çoğul ayrımını göster.',
    'a2_past_simple':
        'Geçmişte bitmiş olaylar1 olumlu, olumsuz ve soru olarak anlat.',
    'a2_will': 'Anl1k karar, tahmin, söz ve teklifleri will + V1 ile kur.',
    'a2_going_to':
        'Planlar1 ve g�r�nen kan1ta dayal1 tahminleri be going to ile anlat.',
    'a2_comparatives': '?ki kişi, yer veya şeyi daha net kar?la?t?r.',
    'a2_superlatives':
        'Bir grubun en belirgin �yesini the -est / the most ile anlat.',
    'a2_countable_uncountable':
        'Say?labilen ve say?lamayan isimleri do?ru miktar kelimeleriyle kullan.',
    'a2_some_any_much_many':
        'Some, any, much, many ve a lot of se�imini isim t�r�ne g�re yap.',
    'a2_should': 'Tavsiye ve iyi fikirleri should / shouldn\'t ile s�yle.',
    'a2_must_have_to':
        'Kural, g�rev ve zorunluluklar1 must / have to ile ay1r.',
    'a2_object_possessive_pronouns':
        'Fiilden sonra nesne zamiri, tek başına sahiplik zamiri kullan.',
    'a2_adverbs_frequency_manner':
        'Bir eylemin ne s?kl?kta ve nas1l yap?ld1?1n1 zarfla anlat.',
    'a2_infinitive_purpose': 'Bir eylemin amac1n1 to + V1 yap?s?yla a�1kla.',
    'a2_gerund_infinitive':
        'Yayg1n fiillerden sonra V-ing veya to + V1 se�imini yap.',
  };
  return _repairMojibake(goals[key] ?? lesson.oneLineGoal);
}

String _lessonKey(GrammarLesson lesson) => grammarDisplayKeyFor(lesson);

String _legacyLessonKey(GrammarLesson lesson) {
  final raw =
      '${lesson.bigTitle} ${lesson.oneLineGoal} ${lesson.teacherIntro} ${lesson.right} ${lesson.wrong} ${lesson.modelAnswer} ${lesson.examples.join(' ')} ${lesson.formulaRows.map((e) => '${e.label} ${e.pattern} ${e.sample}').join(' ')}'
          .toLowerCase();

  // Specific / advanced keys must come before broad words like "will", "so" or "such".
  if (raw.contains('future perfect continuous') ||
      raw.contains('will have been')) {
    return 'b2_future_perfect_continuous';
  }
  if (raw.contains('future perfect') ||
      raw.contains('will have + v3') ||
      raw.contains('will have v3')) {
    return 'b2_future_perfect';
  }
  if (raw.contains('past perfect continuous') ||
      raw.contains('had been') && raw.contains('ing')) {
    return 'b1_past_perfect_continuous';
  }
  if (raw.contains('present perfect continuous') ||
      raw.contains('have been') && raw.contains('ing')) {
    return 'b1_present_perfect_continuous';
  }
  if (raw.contains('full inversion') ||
      raw.contains('negative adverbial inversion') ||
      raw.contains('never have i') ||
      raw.contains('only then did') ||
      raw.contains('rarely do')) {
    return 'c1_full_inversion';
  }
  if (raw.contains('inversion intro') ||
      raw.contains('not only did') ||
      raw.contains('little did')) {
    return 'b2_inversion_intro';
  }
  if (raw.contains('stylistic inversion') ||
      raw.contains('on no account') ||
      raw.contains('under no circumstances')) {
    return 'c2_stylistic_inversion';
  }
  if (raw.contains('cleft')) return 'c1_cleft_sentences';
  if (raw.contains('emphatic do')) return 'c1_emphatic_do';
  if (raw.contains('advanced modality')) return 'c1_advanced_modality';
  if (raw.contains('advanced linkers')) return 'c1_advanced_linkers';
  if (raw.contains('noun clauses')) return 'c1_noun_clauses';
  if (raw.contains('reduced relative clauses')) {
    return 'c1_reduced_relative_clauses';
  }
  if (raw.contains('nominalisation intro') ||
      raw.contains('nominalization intro')) {
    return 'c1_nominalisation_intro';
  }
  if (raw.contains('advanced conditionals')) return 'c1_advanced_conditionals';
  if (raw.contains('register control')) return 'c1_register_control';
  if (raw.contains('subjunctive') || raw.contains('formulaic')) {
    return 'c1_subjunctive_formulaic';
  }
  if (raw.contains('ellipsis') || raw.contains('substitution')) {
    return 'c1_ellipsis_substitution';
  }
  if (raw.contains('academic nominalisation') ||
      raw.contains('academic nominalization')) {
    return 'c2_academic_nominalisation';
  }
  if (raw.contains('fronting') || raw.contains('information structure')) {
    return 'c2_fronting_information_structure';
  }
  if (raw.contains('advanced hedging')) return 'c2_advanced_hedging';
  if (raw.contains('register shifts')) return 'c2_register_shifts';
  if (raw.contains('dense noun phrases')) return 'c2_dense_noun_phrases';
  if (raw.contains('complex subordination')) return 'c2_complex_subordination';
  if (raw.contains('advanced c�ncession')) return 'c2_advanced_c�ncession';
  if (raw.contains('advanced emphasis')) return 'c2_advanced_emphasis';
  if (raw.contains('precision with modality')) return 'c2_precision_modality';
  if (raw.contains('discourse flow')) return 'c2_discourse_flow';
  if (raw.contains('advanced conditionals')) return 'c2_advanced_conditionals';

  if (raw.contains('present perfect vs past simple')) {
    return 'a2_present_perfect_vs_past';
  }
  if (raw.contains('past simple vs past continuous')) {
    return 'a2_past_simple_vs_continuous';
  }
  if (raw.contains('past continuous')) return 'a2_past_continuous';
  if (raw.contains('past simple')) return 'a2_past_simple';
  if (raw.contains('going to')) return 'a2_going_to';
  if (raw.contains('present continuous for future')) {
    return 'a2_present_continuous_future';
  }
  if (raw.contains('must') ||
      raw.contains('have to') ||
      raw.contains('has to')) {
    return 'a2_must_have_to';
  }
  if (raw.contains('should')) return 'a2_should';
  if (raw.contains('may') || raw.contains('might')) return 'a2_may_might';
  if (raw.contains('too') || raw.contains('enough')) return 'a2_too_enough';
  if (raw.contains('present perfect')) return 'a2_present_perfect';
  if (raw.contains('first conditional')) return 'a2_first_conditional';
  if (raw.contains('zero conditional')) return 'a2_zero_conditional';
  if (raw.contains('used to')) return 'a2?used_to';
  if (raw.contains('would like')) return 'a2_would_like';
  if (raw.contains('object pronouns') && raw.contains('possessive pronouns')) {
    return 'a2_object_possessive_pronouns';
  }
  if (raw.contains('adverbs of frequency') ||
      raw.contains('frequency adverbs') ||
      raw.contains('manner adverbs')) {
    return 'a2_adverbs_frequency_manner';
  }
  if (raw.contains('infinitive of purpose') ||
      raw.contains('purpose with a verb') ||
      raw.contains('to explain why')) {
    return 'a2_infinitive_purpose';
  }
  if (raw.contains('gerund') || raw.contains('infinitive')) {
    return 'a2_gerund_infinitive';
  }
  if (raw.contains('relative')) return 'a2_relative';
  if (raw.contains('countable / uncountable') ||
      raw.contains('countable nouns with numbers') ||
      raw.contains('uncountable nouns with amount')) {
    return 'a2_countable_uncountable';
  }
  if (raw.contains('some / any / much / many / a lot of') ||
      raw.contains('some, any, much, many and a lot of')) {
    return 'a2_some_any_much_many';
  }
  if (raw.contains('quantifier') ||
      raw.contains('much') ||
      raw.contains('many')) {
    return 'a2_quantifiers';
  }
  if (raw.contains('so / such') ||
      raw.contains(' so ') && raw.contains(' such ')) {
    return 'a2_so_such';
  }
  if (raw.contains('comparative') ||
      raw.contains('colder than') ||
      raw.contains('better than')) {
    return 'a2_comparatives';
  }
  if (raw.contains('superlative') ||
      raw.contains('the most') ||
      raw.contains('the best')) {
    return 'a2_superlatives';
  }
  if (raw.contains('future simple') ||
      raw.contains('will + v1') ||
      raw.contains(' will ')) {
    return 'a2_will';
  }

  if (raw.contains('present simple')) return 'a1_present_simple';
  if (raw.contains('present continuous')) return 'a1_present_continuous';
  if (raw.contains('am / is / are') || raw.contains('be verb')) {
    return 'a1_be_verb';
  }
  if (raw.contains('subject pronouns') ||
      raw.contains('subject & object') ||
      raw.contains('object pronouns')) {
    return 'a1_subject_pronouns';
  }
  if (raw.contains('possessive adjectives') || raw.contains('possessives')) {
    return 'a1_possessive_adjectives';
  }
  if (raw.contains('articles') || raw.contains('a / an / the')) {
    return 'a1_articles';
  }
  if (raw.contains('plural nouns') ||
      raw.contains('two books') ||
      raw.contains('children')) {
    return 'a1_singular_plural';
  }
  if (raw.contains('this / that / these / those') ||
      raw.contains('demonstrative')) {
    return 'a1_demonstratives';
  }
  if (raw.contains('have got') || raw.contains('has got')) {
    return 'a1_have_has_got';
  }
  if (raw.contains('basic prepositions') || raw.contains('in / on / at')) {
    return 'a1_basic_prepositions';
  }
  if (raw.contains('imperatives') || raw.contains('imperative')) {
    return 'a1_imperatives';
  }
  if (raw.contains('there is') || raw.contains('there are')) {
    return 'a1_there_is_are';
  }
  if (raw.contains('can') || raw.contains('ability')) return 'a1_can_cant';

  return '';
}

List<GrammarFormulaRow> _normalizedFormulaRowsFor(GrammarLesson lesson) {
  final key = _lessonKey(lesson);

  List<GrammarFormulaRow> rows(List<GrammarFormulaRow> value) => value;

  switch (key) {
    case 'b2_future_perfect':
      return rows(const [
        GrammarFormulaRow(
            label: 'Completed before future point',
            pattern: 'subject + will have + V3 + by/before + future time',
            sample: 'By Friday, I will have finished the report.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'subject + will not have + V3',
            sample: 'By noon, she will not have completed the task.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Will + subject + have + V3?',
            sample: 'Will you have finished by 8?'),
        GrammarFormulaRow(
            label: 'Time marker',
            pattern: 'by / by the time / before + future point',
            sample: 'By the time you arrive, we will have eaten dinner.'),
      ]);
    case 'b2_future_perfect_continuous':
      return rows(const [
        GrammarFormulaRow(
            label: 'Duration before future point',
            pattern: 'subject + will have been + V-ing + for/since',
            sample: 'By June, I will have been working here for two years.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'subject + will not have been + V-ing',
            sample: 'She will not have been studying for long.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Will + subject + have been + V-ing?',
            sample: 'Will you have been waiting for an hour?'),
      ]);
    case 'b2_inversion_intro':
    case 'c1_full_inversion':
      return rows(const [
        GrammarFormulaRow(
            label: 'Negative adverbial',
            pattern: 'Never/Rarely/Hardly + auxiliary + subject + verb',
            sample: 'Never have I seen such a clear explanation.'),
        GrammarFormulaRow(
            label: 'Only then / Only later',
            pattern: 'Only then + auxiliary + subject + verb',
            sample: 'Only then did I understand the problem.'),
        GrammarFormulaRow(
            label: 'Not only',
            pattern: 'Not only + auxiliary + subject + verb, but also ...',
            sample:
                'Not only did she apologize, but she also offered to help.'),
        GrammarFormulaRow(
            label: 'Avoid',
            pattern:
                'Do not keep normal subject + auxiliary order after fronting',
            sample: 'Never I have seen such a clear explanation.'),
      ]);
    case 'a2_past_simple':
      return rows(const [
        GrammarFormulaRow(
            label: 'Regular positive',
            pattern: 'subject + V-ed',
            sample: 'I watched a movie yesterday.'),
        GrammarFormulaRow(
            label: 'Irregular positive',
            pattern: 'subject + V2',
            sample: 'She went to Ankara last week.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'subject + did not + V1',
            sample: 'I did not go to school.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Did + subject + V1?',
            sample: 'Did you call me?'),
        GrammarFormulaRow(
            label: 'Time words',
            pattern:
                'yesterday / last night / last week / two days ago / in 2020 / when I was a child',
            sample: 'We met two days ago.'),
      ]);
    case 'a2_past_continuous':
      return rows(const [
        GrammarFormulaRow(
            label: 'I / He / She / It',
            pattern: 'was + V-ing',
            sample: 'I was studying at 9 p.m.'),
        GrammarFormulaRow(
            label: 'You / We / They',
            pattern: 'were + V-ing',
            sample: 'They were watching TV at 9.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'was / were + not + V-ing',
            sample: 'She was not sleeping.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Was / Were + subject + V-ing?',
            sample: 'Were you listening?'),
        GrammarFormulaRow(
            label: 'Interrupted action',
            pattern: 'was/were + V-ing + when + V2',
            sample: 'I was studying when you called.'),
      ]);
    case 'a2_comparatives':
      return rows(const [
        GrammarFormulaRow(
            label: 'Short adjectives',
            pattern: 'adjective + -er + than / a little ...er / much ...er',
            sample: 'Kayseri is colder than Antalya.'),
        GrammarFormulaRow(
            label: 'Long adjectives',
            pattern: 'more + adjective + than / much more + adjective',
            sample: 'This lesson is more useful than the last one.'),
        GrammarFormulaRow(
            label: 'Irregular',
            pattern: 'good -> better / bad -> worse',
            sample: 'This answer is better than mine.'),
        GrammarFormulaRow(
            label: 'Spelling',
            pattern: 'big -> bigger / hot -> hotter',
            sample: 'Today is hotter than yesterday.'),
      ]);
    case 'a2_superlatives':
      return rows(const [
        GrammarFormulaRow(
            label: 'Short adjectives',
            pattern: 'the + adjective + -est',
            sample: 'She is the tallest student in the class.'),
        GrammarFormulaRow(
            label: 'Long adjectives',
            pattern: 'the most + adjective',
            sample: 'This is the most useful lesson.'),
        GrammarFormulaRow(
            label: 'Irregular',
            pattern: 'good -> the best / bad -> the worst',
            sample: 'This is the best answer.'),
        GrammarFormulaRow(
            label: 'Group phrase',
            pattern: 'in my class / in the world / of all',
            sample: 'It is the coldest city in the region.'),
      ]);
    case 'a2_will':
      return rows(const [
        GrammarFormulaRow(
            label: 'Positive',
            pattern: 'subject + will + V1',
            sample: 'I will help you.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'subject + will not / won\'t + V1',
            sample: 'They won\'t come tonight.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Will + subject + V1?',
            sample: 'Will you join us?'),
        GrammarFormulaRow(
            label: 'Prediction',
            pattern: 'I think / maybe / probably + will + V1',
            sample: 'I think it will rain.'),
        GrammarFormulaRow(
            label: 'Future signals',
            pattern: 'tomorrow / soon / next week',
            sample: 'They will arrive soon.'),
      ]);
    case 'a2_going_to':
      return rows(const [
        GrammarFormulaRow(
            label: 'I',
            pattern: 'I am going to + V1',
            sample: 'I am going to study tonight.'),
        GrammarFormulaRow(
            label: 'He / She / It',
            pattern: 'is going to + V1',
            sample: 'She is going to call you.'),
        GrammarFormulaRow(
            label: 'You / We / They',
            pattern: 'are going to + V1',
            sample: 'They are going to travel.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Am / Is / Are + subject + going to + V1?',
            sample: 'Are you going to join us?'),
        GrammarFormulaRow(
            label: 'Useful signals',
            pattern: 'tonight / this weekend / next summer / look at...',
            sample: 'Look at the clouds. It is going to rain.'),
      ]);
    case 'a2_must_have_to':
      return rows(const [
        GrammarFormulaRow(
            label: 'Must',
            pattern: 'subject + must + V1',
            sample: 'You must wear a seat belt.'),
        GrammarFormulaRow(
            label: 'Have to',
            pattern: 'I / you / we / they + have to + V1',
            sample: 'I have to finish my homework.'),
        GrammarFormulaRow(
            label: 'Has to',
            pattern: 'he / she / it + has to + V1',
            sample: 'She has to wake up early.'),
        GrammarFormulaRow(
            label: 'No necessity',
            pattern: 'do / does not have to + V1',
            sample: 'You do not have to come early.'),
        GrammarFormulaRow(
            label: 'Rule words',
            pattern: 'must / must not / have to / has to / do not have to',
            sample: 'Visitors must show their ID.'),
      ]);
    case 'a2_should':
      return rows(const [
        GrammarFormulaRow(
            label: 'Advice',
            pattern: 'subject + should + V1',
            sample: 'You should drink more water.'),
        GrammarFormulaRow(
            label: 'Negative advice',
            pattern: 'subject + should not + V1',
            sample: 'You shouldn\'t sleep late.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Should + subject + V1?',
            sample: 'Should I call her?'),
        GrammarFormulaRow(
            label: 'Advice signals',
            pattern:
                'should / should not / maybe you should / I think you should',
            sample: 'Maybe you should rest today.'),
      ]);
    case 'a2_too_enough':
      return rows(const [
        GrammarFormulaRow(
            label: 'Too',
            pattern: 'too + adjective',
            sample: 'This bag is too heavy.'),
        GrammarFormulaRow(
            label: 'Adjective enough',
            pattern: 'adjective + enough',
            sample: 'He is old enough to drive.'),
        GrammarFormulaRow(
            label: 'Enough noun',
            pattern: 'enough + noun',
            sample: 'We have enough time.'),
        GrammarFormulaRow(
            label: 'Not enough',
            pattern: 'not + adjective + enough',
            sample: 'The room is not big enough.'),
      ]);
    case 'a2_present_perfect':
      return rows(const [
        GrammarFormulaRow(
            label: 'Positive',
            pattern: 'subject + have / has + V3',
            sample: 'I have visited Istanbul.'),
        GrammarFormulaRow(
            label: 'Negative',
            pattern: 'have / has not + V3',
            sample: 'She has not finished yet.'),
        GrammarFormulaRow(
            label: 'Question',
            pattern: 'Have / Has + subject + V3?',
            sample: 'Have you ever tried sushi?'),
        GrammarFormulaRow(
            label: 'Time contrast',
            pattern: 'Past Simple with finished time',
            sample: 'I visited Ankara last year.'),
      ]);
    case 'a2_first_conditional':
      return rows(const [
        GrammarFormulaRow(
            label: 'If clause',
            pattern: 'If + present simple',
            sample: 'If it rains,'),
        GrammarFormulaRow(
            label: 'Result',
            pattern: 'will + V1',
            sample: 'I will stay at home.'),
        GrammarFormulaRow(
            label: 'Full sentence',
            pattern: 'If + present simple, will + V1',
            sample: 'If it rains, I will stay at home.'),
        GrammarFormulaRow(
            label: 'Negative result',
            pattern: 'will not + V1',
            sample: 'If I am busy, I won\'t come.'),
      ]);
  }

  final cleaned = lesson.formulaRows.where((row) {
    final label = row.label.toLowerCase().trim();
    final pattern = row.pattern.toLowerCase().trim();
    if (label.startsWith('step')) return false;
    if (label == 'meaning' &&
        (pattern.startsWith('use ') || pattern.contains(' için '))) {
      return false;
    }
    if (label == 'avoid') return false;
    return row.sample.trim().isNotEmpty || row.pattern.trim().isNotEmpty;
  }).toList();

  return cleaned.isNotEmpty ? cleaned : lesson.formulaRows;
}

bool _hasTurkishText(String value) => RegExp(r'[??????]').hasMatch(value);

Map<String, List<String>> _a2TeacherMap(bool isEnglish) {
  if (isEnglish) {
    return const {
      'a2_past_simple': [
        'Past Simple is for finished past events, not actions continuing now.',
        'Use V2 in positive sentences, but after did / did not the verb returns to V1.',
        'Time words like yesterday, last week and ago strongly point to Past Simple.'
      ],
      'a2_past_continuous': [
        'Past Continuous builds a past scene: what was happening at that moment?',
        'Use was / were before the -ing verb; the -ing verb cannot stand alone.',
        'Use when for the short interrupting action and while for longer background actions.'
      ],
      'a2_comparatives': [
        'Comparatives compare two people, places, things or ideas.',
        'Use -er for short adjectives and more for longer adjectives.',
        'Use than before the second side of the comparison.'
      ],
      'a2_superlatives': [
        'Superlatives choose the top item inside a group.',
        'Use the + -est for short adjectives and the most for longer adjectives.',
        'Do not forget the before most superlative forms.'
      ],
      'a2_will': [
        'Will is natural for quick decisions, predictions, promises and offers.',
        'After will, the main verb stays in V1; do not add -s.',
        'For planned future actions, going to is often more natural.'
      ],
      'a2_going_to': [
        'Going to shows a plan, intention or evidence-based future prediction.',
        'Am / is / are is a required part of the structure.',
        'After going to, the main verb stays in V1.'
      ],
      'a2_must_have_to': [
        'Must and have to both show obligation, but the feeling is not always the same.',
        'Mustn?t means prohibition; don\'t have to means no necessity.',
        'Use has to with he / she / it.'
      ],
      'a2_should': [
        'Should gives advice; it is softer than must.',
        'Shouldn?t says something is a bad idea.',
        'After should, use V1 with no to and no -s.'
      ],
      'a2_too_enough': [
        'Too usually shows a problem caused by excess.',
        'Enough means sufficient, but its position changes.',
        'Use adjective + enough, but enough + noun.'
      ],
      'a2_present_perfect': [
        'Present Perfect talks about the past with a present connection.',
        'At A2, focus on experience, recent completion and present result.',
        'Use Past Simple with finished time words like yesterday or last week.'
      ],
      'a2?used_to': [
        'Used to describes a past habit or state that is different now.',
        'In negatives and questions with did, use use to, not used to.',
        'Do not use used to for a current routine.'
      ],
      'a2_would_like': [
        'Would like is a polite way to say want.',
        'Use would like to + V1 before an action.',
        'Would you like...? is natural for offers and invitations.'
      ],
      'a2_first_conditional': [
        'First Conditional describes a real future possibility.',
        'The if part uses Present Simple; the result part uses will + V1.',
        'Do not put will inside the if clause.'
      ],
      'a2_gerund_infinitive': [
        'Some verbs are followed by V-ing; others are followed by to + V1.',
        'Enjoy, avoid and finish are followed by V-ing.',
        'Want, need and decide are followed by to + V1.'
      ],
      'a2_relative': [
        'Relative clauses connect two pieces of information about one noun.',
        'Use who for people and which for things or ideas.',
        'That is a useful safe option in many A2 sentences.'
      ],
      'a2_past_simple_vs_continuous': [
        'Past Continuous gives the background scene.',
        'Past Simple gives the short action that interrupts the scene.',
        'Think: a longer action was happening, then a shorter action happened.'
      ],
      'a2_present_perfect_vs_past': [
        'Choose Past Simple when the finished time is clear.',
        'Choose Present Perfect when the experience or result matters more than the exact time.',
        'Do not use have / has + V3 with yesterday.'
      ],
      'a2_quantifiers': [
        'Choose quantifiers according to countable and uncountable nouns.',
        'Use many and a few with plural countable nouns.',
        'Use much and a little with uncountable nouns.'
      ],
      'a2_countable_uncountable': [
        'Countable nouns can use numbers and plural -s.',
        'Uncountable nouns use amount words like some, much and a little.',
        'Useful chunks: a few apples, a little water, a lot of homework.'
      ],
      'a2_some_any_much_many': [
        'Use some in positive sentences and any in negatives or questions.',
        'Use many with plural countable nouns and much with uncountable nouns.',
        'A lot of works naturally with both countable and uncountable nouns.'
      ],
      'a2_object_possessive_pronouns': [
        'Object pronouns receive the action: help me, call him, tell us.',
        'Possessive pronouns stand alone: mine, yours, hers, ours, theirs.',
        'Do not add a noun after mine, yours, hers, ours or theirs.'
      ],
      'a2_adverbs_frequency_manner': [
        'Frequency adverbs show how often something happens.',
        'Manner adverbs show how an action happens.',
        'Frequency usually sits before the main verb; manner often comes after the verb.'
      ],
      'a2_infinitive_purpose': [
        'Use to + V1 to explain why someone does something.',
        'This is common after go, come, call, open, use and save money.',
        'Do not use for + verb when the meaning is purpose.'
      ],
      'a2_so_such': [
        'So strengthens an adjective or adverb.',
        'Such strengthens a noun phrase.',
        'Use such a/an + adjective + noun for singular countable nouns.'
      ],
      'a2_zero_conditional': [
        'Zero Conditional explains general truths, rules and automatic results.',
        'Use Present Simple on both sides.',
        'Do not use will for a general truth result.'
      ],
    };
  }
  return const {
    'a2_past_simple': [
      'Olay ge�mi_te ba_lad1 ve bitti; bug�n devam etmiyor.',
      'Olumlu cümlede fiil V2/-ed olur ama did geldi?inde fiil tekrar V1?e d�ner.',
      'Yesterday, last week, ago gibi net ge�mi_ zaman ifadeleri bu konunun g��l� ipu�lar1d1r.'
    ],
    'a2_past_continuous': [
      'Bu yap? ge�mi_te bir sahne kurar: o anda ne oluyordu?',
      'Devam eden uzun olay was/were + V-ing ile, araya giren k1sa olay Past Simple ile verilir.',
      'When k1sa olay1, while ise devam eden iki sahneyi g�stermek için çok kullanılır.'
    ],
    'a2_comparatives': [
      'Comparative iki şeyi kar?la?t?r1r; ikinci taraf genelde than ile gelir.',
      'K1sa s?fatlarda -er, uzun s?fatlarda more kullanılır.',
      'Good -> better, bad -> worse gibi düzensiz formlar ezberlenmelidir.'
    ],
    'a2_superlatives': [
      'Superlative bir gruptaki en �st noktay1 anlat1r.',
      'K1sa s?fatlarda the + -est, uzun s?fatlarda the most kullanılır.',
      'The kelimesini atlamak A2?de en s?k yap?lan hatalardan biridir.'
    ],
    'a2_will': [
      'Will �zellikle anl1k karar, tahmin, söz ve tekliflerde doğald1r.',
      'Will\'den sonra fiil her zaman V1 kalır; he/she/it için -s gelmez.',
      '�nceden planlanm1_ niyetlerde going to daha doğal olabilir.'
    ],
    'a2_going_to': [
      'Going to �nceden d�_�n�lm�_ plan ve niyet anlat1r.',
      'Bulut, kan1t veya g�r�nen durum varsa gelecek tahmini için de kullanılır.',
      'Am/is/are yap?n1n zorunlu par�as1d1r; d�_erse c�mle bozulur.'
    ],
    'a2_must_have_to': [
      'Must ve have to zorunluluk anlat1r ama tonlar1 farklıdır.',
      'Mustn?t yasak demektir; don\'t have to ise gerek yok demektir.',
      'Have to he/she/it ile has to olur.'
    ],
    'a2_should': [
      'Should tavsiye verir; must kadar sert değildir.',
      'Shouldn?t yap?lmamas1 daha iyi olan şeyi s�yler.',
      'Should\'dan sonra fiil V1 kalır; to veya -s gelmez.'
    ],
    'a2_too_enough': [
      'Too genelde problem yaratan fazlal1?1 gösterir.',
      'Enough yeterlilik anlam? verir ama yeri de?i_ir.',
      'S1fat + enough, enough + noun s?ras?n1 unutma.'
    ],
    'a2_present_perfect': [
      'Present Perfect ge�mi?i anlat1r ama oda? bug�nk� ba?lant1d1r.',
      'Deneyim, yeni bitmiş i_ ve sonuç fikri bu seviyede en �nemli �� kullan1md1r.',
      'Yesterday veya last week gibi net bitmiş zaman varsa Past Simple daha do?rudur.'
    ],
    'a2?used_to': [
      'Used to ge�mi_te d�zenli olan ama _imdi de?i_mi_ al1_kanl1?1 anlat1r.',
      'Olumlu cümlede used to, soru ve olumsuzda use to kullanılır.',
      'Bu yap? _imdiki al1_kanl1k için kullan?lmaz.'
    ],
    'a2_would_like': [
      'Would like want kelimesinin daha kibar halidir.',
      'Eylem gelirse would like to + V1 kullanılır.',
      'Tekliflerde Would you like...? çok doğal bir kal1pt1r.'
    ],
    'a2_first_conditional': [
      'First Conditional gerçekçi gelecek ihtimalini anlat1r.',
      'If taraf1nda present simple, sonuç taraf1nda will + V1 kullanılır.',
      'If cümlesinde will kullanmak en yaygın hatadır.'
    ],
    'a2_gerund_infinitive': [
      'Baz1 fiiller V-ing, baz1lar1 to V1 ister.',
      'Enjoy, avoid, finish gibi fiillerden sonra V-ing kullanılır.',
      'Want, need, decide gibi fiillerden sonra to V1 gelir.'
    ],
    'a2_relative': [
      'Relative clause iki bilgiyi tek cümlede ba?lar.',
      '0nsan için who, ?ey/fikir için which kullanılır.',
      'That birçok A2 c�mlesinde g�venli bir ba?lay1c1d1r.'
    ],
    'a2_past_simple_vs_continuous': [
      'Past Continuous sahneyi, Past Simple araya giren k1sa olay1 verir.',
      'When genelde k1sa olayla, while devam eden olayla kullanılır.',
      'Sahne devam ederken bir ?ey oldu mant1?1n1 kur.'
    ],
    'a2_present_perfect_vs_past': [
      'Net bitmiş zaman varsa Past Simple se�.',
      'Zaman �nemli değilse ve deneyim/sonuç varsa Present Perfect se�.',
      'Yesterday ile have/has + V3 kullanma.'
    ],
    'a2_quantifiers': [
      'Miktar kelimeleri ismin say1labilir olup olmamas1na g�re de?i_ir.',
      'Many ve a few �o?ul say1labilir isimlerle kullanılır.',
      'Much, a little ve little say1lamaz isimlerle kullanılır.'
    ],
    'a2_countable_uncountable': [
      'Say?labilen isimler say1 ve �o?ul -s alabilir.',
      'Say1lamayan isimler some, much ve a little gibi miktar kelimeleri ister.',
      'Kullan1_l1 kal1plar: a few apples, a little water, a lot of homework.'
    ],
    'a2_some_any_much_many': [
      'Some olumlu cümlede, any genelde olumsuz ve soruda kullanılır.',
      'Many �o?ul say?labilen isimlerle, much say?lamayan isimlerle kullanılır.',
      'A lot of hem say?labilen hem de say?lamayan isimlerle doğal durur.'
    ],
    'a2_object_possessive_pronouns': [
      'Nesne zamirleri eylemden etkilenen kişiyi veya şeyi gösterir: help me, call him, tell us.',
      'Sahiplik zamirleri tek başına kullanılır: mine, yours, hers, ours, theirs.',
      'Mine, yours, hers, ours, theirs sonras?nda tekrar isim kullanma.'
    ],
    'a2_adverbs_frequency_manner': [
      'S?kl?k zarflar1 bir eylemin ne kadar s?k yap?ld1?1n1 gösterir.',
      'Durum zarflar1 bir eylemin nas1l yap?ld1?1n1 anlat1r.',
      'S?kl?k zarf1 genelde ana fiilden �nce, durum zarf1 �o?u zaman fiilden sonra gelir.'
    ],
    'a2_infinitive_purpose': [
      'Bir eylemin neden yap?ld1?1n1 a�1klamak için to + V1 kullanılır.',
      'Go, come, call, open, use ve save money gibi fiillerden sonra çok doğal durur.',
      'Ama� anlat?rken for + verb kullanma; I went to buy bread daha doğald1r.'
    ],
    'a2_so_such': [
      'So s?fat veya zarf1 g��lendirir.',
      'Such isim grubunu g��lendirir.',
      'Such a/an + adjective + noun s?ras?na dikkat et.'
    ],
    'a2_zero_conditional': [
      'Zero Conditional genel ger�ek ve kurallar1 anlat1r.',
      '?ki tarafta da present simple kullanılır.',
      'Bu yap? kişisel tahmin değil, genel sonuç anlat1r.'
    ],
  };
}

Map<String, List<String>> _a1TeacherMap(bool isEnglish) {
  final en = <String, List<String>>{
    'a1_be_verb': [
      'Match be to the subject: I am, he/she/it is, you/we/they are.',
      'Use not after be for negatives.',
      'Move am/is/are before the subject in questions.'
    ],
    'a1_subject_pronouns': [
      'Use I, you, he, she, it, we, they as subjects.',
      'Use me, him, her, us, them after verbs and prepositions.',
      'Replace one person with he/she, one object with it, plural people/things with they.',
      'Do not repeat a name and a pronoun together.'
    ],
    'a1_possessive_adjectives': [
      'Use my, your, his, her, its, our, their before a noun.',
      'Use possessive ?s with names: Ece?s bag.',
      'Use whose to ask who owns something.',
      'Do not use he/she before nouns for possession.',
      'Keep the noun after the possessive adjective.'
    ],
    'a1_there_is_are': [
      'Use there is for one thing and there are for plural things.',
      'Use there isn\'t / there aren\'t for negatives.',
      'Use Is there...? / Are there...? in questions.'
    ],
    'a1_articles': [
      'Use a before consonant sounds and an before vowel sounds.',
      'Use the when the listener knows which thing.',
      'Do not leave singular countable nouns bare when they need an article.'
    ],
    'a1_singular_plural': [
      'Add -s or -es for regular plurals.',
      'Use plural nouns after numbers above one.',
      'Use some/any for basic quantity and many/much for countable or uncountable nouns.',
      'Remember common irregular plurals like people and children.'
    ],
    'a1_present_simple': [
      'Use V1 for routines, habits and facts.',
      'Add -s/-es with he/she/it in positive sentences.',
      'Use frequency adverbs and wh- questions for fuller everyday sentences.',
      'Use like/love/hate with a noun or an -ing verb.',
      'After do/does/don\'t/doesn\'t, keep the main verb base.'
    ],
    'a1_present_continuous': [
      'Use am/is/are + V-ing for actions happening now.',
      'Match am/is/are to the subject.',
      'Do not drop the be verb before V-ing.'
    ],
    'a1_can_cant': [
      'Use can/can\'t + base verb.',
      'Do not add -s, to, or -ing after can.',
      'Use Can I...? for permission and Can you...? for requests.'
    ],
    'a1_have_has_got': [
      'Use have got with I/you/we/they.',
      'Use has got with he/she/it.',
      'Use Have/Has at the start of questions.'
    ],
    'a1_basic_prepositions': [
      'Use in for inside places and months/years.',
      'Use on for surfaces and days.',
      'Use at for clock times and exact points.'
    ],
    'a1_imperatives': [
      'Start commands with the base verb.',
      'Use please for a softer instruction.',
      'Use Don\'t + base verb for negative commands.'
    ],
    'a1_demonstratives': [
      'Use this/that with singular nouns.',
      'Use these/those with plural nouns.',
      'Use this/these for near things and that/those for far things.'
    ],
  };
  final tr = <String, List<String>>{
    'a1_be_verb': [
      'Be fiilini özneye g�re se�: I am, he/she/it is, you/we/they are.',
      'Olumsuzda not, be fiilinden sonra gelir.',
      'Soruda am/is/are öznenin �n�ne ge�er.'
    ],
    'a1_subject_pronouns': [
      'özne olarak I, you, he, she, it, we, they kullanılır.',
      'Fiilden ve edattan sonra me, him, her, us, them kullanılır.',
      'Tek kişi he/she, tek nesne it, �o?ul kişi/?eyler they ile anlat1l1r.',
      '0sim ve zamiri ayn? özne yerinde tekrar etme.'
    ],
    'a1_possessive_adjectives': [
      'my, your, his, her, its, our, their isimden �nce gelir.',
      '0simle sahiplik anlat?rken Ece?s bag gibi ?s kullan.',
      'Kime ait diye sorarken whose kullan.',
      'Sahiplik için isimden �nce he/she kullanma.',
      'Sahiplik sıfatından sonra bir isim gelmelidir.'
    ],
    'a1_there_is_are': [
      'Tek ?ey için there is, �o?ul ?eyler için there are kullanılır.',
      'Olumsuzda there isn\'t / there aren\'t kullanılır.',
      'Soruda Is there...? / Are there...? yap?s? gelir.'
    ],
    'a1_articles': [
      'Sessiz sesle a, sesli sesle an kullanılır.',
      'Dinleyen kişinin bildi?i ?ey için the kullanılır.',
      'Tekil say?labilen isim gerekti?inde articlesiz kalmaz.'
    ],
    'a1_singular_plural': [
      'D�zenli �o?ullarda -s veya -es eklenir.',
      'Birden b�y�k say1lardan sonra isim �o?ul olur.',
      'some/any temel miktar, many/much ise say?labilen ve say?lamayan ayr?m? içindir.',
      'people ve children gibi yayg?n düzensiz �o?ullar1 ayr1 �?ren.'
    ],
    'a1_present_simple': [
      'Rutin, al1_kanl1k ve genel ger�eklerde V1 kullanılır.',
      'He/she/it olumlu cümlede -s/-es al?r.',
      'S?kl?k zarflar1 ve wh-sorular1 g�nl�k c�mleleri tamamlar.',
      'like/love/hate sonras?nda isim veya -ing fiil kullanabilirsin.',
      'do/does/don\'t/doesn\'t sonras?nda ana fiil yal?n kalır.'
    ],
    'a1_present_continuous': [
      '^u an olan eylem için am/is/are + V-ing kullanılır.',
      'am/is/are özneye g�re se�ilir.',
      'V-ing �ncesindeki be fiilini d�_�rme.'
    ],
    'a1_can_cant': [
      'can/can\'t + yal?n fiil kullanılır.',
      'Can sonras?nda -s, to veya -ing gelmez.',
      '0zin için Can I...?, rica için Can you...? kullanılır.'
    ],
    'a1_have_has_got': [
      'I/you/we/they ile have got kullanılır.',
      'He/she/it ile has got kullanılır.',
      'Sorularda Have/Has başa gelir.'
    ],
    'a1_basic_prepositions': [
      'in içindeki yerler ve ay/y1l için kullanılır.',
      'on y�zeyler ve g�nler için kullanılır.',
      'at saatler ve net noktalar için kullanılır.'
    ],
    'a1_imperatives': [
      'Komutlar yal?n fiille ba?lar.',
      'Please y�nergeyi daha kibar yapar.',
      'Olumsuz komutta Don\'t + yal?n fiil kullanılır.'
    ],
    'a1_demonstratives': [
      'This/that tekil isimlerle kullanılır.',
      'These/those �o?ul isimlerle kullanılır.',
      'This/these yak?n, that/those uzak ?eyleri gösterir.'
    ],
  };
  return isEnglish ? en : _repairStringListMap(tr);
}

List<String> _localizedTeacherBulletsFor(GrammarLesson lesson, bool isEnglish) {
  final key = _lessonKey(lesson);
  final a1 = _a1TeacherMap(isEnglish)[key];
  if (a1 != null) return _repairStringList(a1);
  final a2 = _a2TeacherMap(isEnglish)[key];
  if (a2 != null) return _repairStringList(a2);

  if (isEnglish) {
    final raw = lesson.teacherIntro.trim();
    if (raw.isNotEmpty && !_hasTurkishText(raw)) {
      return _splitTeacherIntro(raw,
          fallback: _englishTeacherBulletsFor(lesson));
    }
    return _englishTeacherBulletsFor(lesson);
  }

  final raw = lesson.teacherIntro.trim();
  if (raw.isEmpty || !_hasTurkishText(raw)) {
    return _turkishTeacherBulletsFor(lesson);
  }
  return _repairStringList(
      _splitTeacherIntro(raw, fallback: _turkishTeacherBulletsFor(lesson)));
}

List<String> _splitTeacherIntro(String raw, {required List<String> fallback}) {
  final clean = raw.trim();
  if (clean.isEmpty) return fallback;
  final parts = clean
      .replaceAll('"', '"')
      .replaceAll('"', '"')
      .replaceAll(';', '.')
      .replaceAll('\n', ' ')
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((e) => e.trim())
      .where((e) => e.length > 12)
      .take(4)
      .toList();
  return parts.isEmpty ? fallback : parts;
}

Map<String, List<String>> _a1FocusMap(bool isEnglish) {
  final en = <String, List<String>>{
    'a1_be_verb': [
      'I am / he is / they are',
      'Use not for negatives',
      'Move be before the subject'
    ],
    'a1_subject_pronouns': [
      'Subject: I/he/she/we/they',
      'Object: me/him/her/us/them',
      'Singular vs plural'
    ],
    'a1_possessive_adjectives': [
      'my, your, his, her',
      'Ece?s bag',
      'Whose pen?'
    ],
    'a1_there_is_are': [
      'there is + singular',
      'there are + plural',
      'Questions: Is/Are there'
    ],
    'a1_articles': [
      'a/an for first mention',
      'the for a known thing',
      'Vowel and consonant sounds'
    ],
    'a1_singular_plural': ['-s / -es plural', 'some/any', 'much/many/a lot of'],
    'a1_present_simple': [
      'Use V1 for routines',
      'Frequency: usually/often',
      'Wh- questions',
      'like/love/hate + noun or -ing'
    ],
    'a1_present_continuous': [
      'am/is/are + V-ing',
      'now / right now',
      'Do not drop be'
    ],
    'a1_can_cant': ['can + V1', 'can\'t + V1', 'Can I / Can you'],
    'a1_have_has_got': ['have got', 'has got', 'Have/Has comes first'],
    'a1_basic_prepositions': [
      'in: place/month/year',
      'on: surface/day',
      'at: time/point'
    ],
    'a1_imperatives': [
      'Start with the base verb',
      'Use please to soften',
      'Don\'t + V1'
    ],
    'a1_demonstratives': [
      'this/that singular',
      'these/those plural',
      'near/far difference'
    ],
  };
  final tr = <String, List<String>>{
    'a1_be_verb': [
      'I am / he is / they are',
      'Olumsuzda not kullan',
      'Soruda be başa gelir'
    ],
    'a1_subject_pronouns': [
      'Özne: I/he/she/we/they',
      'Nesne: me/him/her/us/them',
      'Tekil ve çoğul ayrımı'
    ],
    'a1_possessive_adjectives': [
      'my, your, his, her',
      'Ece?s bag',
      'Whose pen?'
    ],
    'a1_there_is_are': [
      'there is + tekil',
      'there are + çoğul',
      'Soruda Is/Are there'
    ],
    'a1_articles': [
      'a/an ilk bahiste',
      'the bilinen şeyde',
      'Sesli/sessiz ses ayrımı'
    ],
    'a1_singular_plural': ['-s / -es çoğul', 'some/any', 'much/many/a lot of'],
    'a1_present_simple': [
      'Rutinlerde V1',
      'Sıklık: usually/often',
      'Wh- soruları',
      'like/love/hate + isim veya -ing'
    ],
    'a1_present_continuous': [
      'am/is/are + V-ing',
      'now / right now',
      'Be fiilini düşürme'
    ],
    'a1_can_cant': ['can + V1', 'can\'t + V1', 'Can I / Can you'],
    'a1_have_has_got': ['have got', 'has got', 'Have/Has başa gelir'],
    'a1_basic_prepositions': [
      'in: iç/ay/yıl',
      'on: yüzey/gün',
      'at: saat/nokta'
    ],
    'a1_imperatives': [
      'Yalın fiille başla',
      'please ile yumuşat',
      'Don\'t + V1'
    ],
    'a1_demonstratives': [
      'this/that tekil',
      'these/those çoğul',
      'near/far ayrımı'
    ],
  };
  return isEnglish ? en : _repairStringListMap(tr);
}

Map<String, List<String>> _a2FocusMap(bool isEnglish) {
  final en = <String, List<String>>{
    'a2_past_simple': [
      'Finished past: yesterday, last night, last week, two days ago, in 2020, when I was a child',
      'Positive: V2 or -ed',
      'Negative and question: did + V1'
    ],
    'a2_will': [
      'Future clues: tomorrow, soon, next week, I think, maybe, probably',
      'Use will for quick decisions, promises, offers and predictions',
      'After will, use V1'
    ],
    'a2_going_to': [
      'Plan clues: tonight, this weekend, next summer, plan to',
      'Evidence clues: look at the clouds, look at that traffic',
      'Use am/is/are + going to + V1'
    ],
    'a2_comparatives': [
      'Compare two things with than',
      'Useful signals: much, a little, faster than, more expensive than',
      'Use -er for short adjectives and more for longer adjectives'
    ],
    'a2_superlatives': [
      'Choose one from a group',
      'Useful signals: the best, the most, in my class, in the world, of all',
      'Most superlatives need the'
    ],
    'a2_quantifiers': [
      'Useful words: some, any, much, many, a lot of, a few, a little',
      'Use many / a few with plural countable nouns',
      'Use much / a little with uncountable nouns'
    ],
    'a2_should': [
      'Advice clues: problem, maybe you should, you should not, it is a good idea to',
      'Use should + V1 for advice',
      'Use should not + V1 for a bad idea'
    ],
    'a2_must_have_to': [
      'Use it for rules, obligation, school/work rules and personal necessity',
      'Must not means forbidden',
      'Do not have to means it is not necessary'
    ],
    'a2_object_possessive_pronouns': [
      'Object pronouns: me, you, him, her, it, us, them',
      'Possessive pronouns: mine, yours, his, hers, ours, theirs',
      'Use possessive pronouns without a noun'
    ],
    'a2_adverbs_frequency_manner': [
      'Frequency: always, usually, often, sometimes, never',
      'Manner: slowly, carefully, quietly, clearly, well',
      'Frequency tells how often; manner tells how'
    ],
    'a2_infinitive_purpose': [
      'Use to + V1 to say why',
      'Useful questions: Why did you...? What did you use it for?',
      'Common pattern: go/call/open/save money + to + V1'
    ],
    'a2_gerund_infinitive': [
      'Verb + -ing: enjoy, like, love, hate',
      'Verb + to + V1: want, need, decide, plan',
      'Learn the verb pattern as a chunk'
    ],
  };
  final tr = <String, List<String>>{
    'a2_past_simple': [
      'Geçmişte ba_lay1p bitmiş olaylar1 anlat1r: yesterday, last night, last week, two days ago, in 2020 gibi.',
      'Olumlu cümlede fiil V2 ya da -ed al?r.',
      'Olumsuz ve soruda did gelir; ana fiil V1 kalır.'
    ],
    'a2_will': [
      'Yar1na ya da yak?n gelece?e dair tahminlerde tomorrow, soon, next week, I think, maybe, probably s?k g�r�l�r.',
      'Anl1k karar, söz, teklif ve tahminlerde will kullanılır.',
      'Will\'den sonra fiil yal?n kalır.'
    ],
    'a2_going_to': [
      'Planlarda tonight, this weekend, next summer gibi zaman ifadeleri c�mleyi netle_tirir.',
      'G�r�nen kan1t varsa look at the clouds gibi ifadeler going to için g��l� ipucudur.',
      'Yap1 am/is/are + going to + V1 _eklindedir.'
    ],
    'a2_comparatives': [
      '?ki şeyi kar?la?t?r1rken than çok s?k kullanılır.',
      'much, a little, faster than, more expensive than gibi ifadeler kar?la?t?rmay1 g��lendirir.',
      'K1sa s?fatlarda -er, uzun s?fatlarda more kullanılır.'
    ],
    'a2_superlatives': [
      'Bir grup içindeki en �st ya da en belirgin kişiyi/şeyi anlat1r.',
      'the best, the most, in my class, in the world, of all gibi ifadeler çok kullanılır.',
      'Superlative yap\'da �o?u zaman the gerekir.'
    ],
    'a2_quantifiers': [
      'some, any, much, many, a lot of, a few, a little miktar anlatmak için kullanılır.',
      'many ve a few �o?ul say?labilen isimlerle kullanılır.',
      'much ve a little say?lamayan isimlerle kullanılır.'
    ],
    'a2_should': [
      'Tavsiye verirken problem, maybe you should, you shouldn\'t, it\'s a good idea to gibi ifadeler i_e yarar.',
      'Should + V1 yap?s? tavsiye verir.',
      'Shouldn?t + V1, bir şeyin iyi fikir olmad??n1 s�yler.'
    ],
    'a2_must_have_to': [
      'Kural, zorunluluk, okul/i_ kurallar1 ve kişisel mecburiyetleri anlat1r.',
      'Mustn?t yasak anlam?na gelir.',
      'Don\'t have to ise ?mecbur değilsin? anlam?ndad1r.'
    ],
    'a2_object_possessive_pronouns': [
      'Nesne zamirleri: me, you, him, her, it, us, them.',
      'Sahiplik zamirleri: mine, yours, his, hers, ours, theirs.',
      'Mine, yours, hers gibi sahiplik zamirlerinden sonra isim gelmez.'
    ],
    'a2_adverbs_frequency_manner': [
      'S?kl?k zarflar1: always, usually, often, sometimes, never.',
      'Durum zarflar1: slowly, carefully, quietly, clearly, well.',
      'S?kl?k zarf1 ?ne kadar s?k?, durum zarf1 ?nas1l? sorusuna cevap verir.'
    ],
    'a2_infinitive_purpose': [
      'Bir eylemin neden yap?ld1?1n1 anlatmak için to + V1 kullanılır.',
      'Why did you...? ve What did you use it for? gibi sorularla doğal kullanılır.',
      'go/call/open/save money + to + V1 kal?b? g�nl�k ?ngilizcede çok i_e yarar.'
    ],
    'a2_gerund_infinitive': [
      'Enjoy, like, love, hate gibi fiillerden sonra genelde V-ing gelir.',
      'Want, need, decide, plan gibi fiillerden sonra to + V1 gelir.',
      'Bu konuda en iyi y�ntem fiili kal1p olarak �?renmektir.'
    ],
  };
  return isEnglish ? en : _repairStringListMap(tr);
}

List<String> _localizedFocusPointsFor(GrammarLesson lesson, bool isEnglish) {
  final key = _lessonKey(lesson);
  final a1 = _a1FocusMap(isEnglish)[key];
  if (a1 != null) return _repairStringList(a1);
  final a2 = _a2FocusMap(isEnglish)[key];
  if (a2 != null) return _repairStringList(a2);

  if (isEnglish) {
    final rawPoints =
        lesson.usageBullets.where((e) => !_hasTurkishText(e)).toList();
    return rawPoints.isNotEmpty ? rawPoints : _englishFocusPointsFor(lesson);
  }

  final rawPoints = lesson.usageBullets
      .where((e) => e.trim().isNotEmpty && _hasTurkishText(e))
      .toList();
  return _repairStringList(
      rawPoints.isNotEmpty ? rawPoints : _turkishFocusPointsFor(lesson));
}

List<String> _turkishTeacherBulletsFor(GrammarLesson lesson) {
  final raw =
      '${lesson.bigTitle} ${lesson.oneLineGoal} ${lesson.right} ${lesson.examples.join(' ')}'
          .toLowerCase();
  final key = _lessonKey(lesson);
  if (raw.contains('present simple')) {
    return const [
      'Present Simple g�nl�k rutin, al1_kanl1k ve genel ger�ek anlat1r.',
      'He / she / it ile olumlu cümlede fiile -s gelir.',
      'Do / does geldiyse ana fiil tekrar V1 kalır.',
    ];
  }
  if (raw.contains('am / is / are') || raw.contains('be verb')) {
    return const [
      'Be verb hareket değil, durum anlat1r: kimlik, yer, duygu ve �zellik.',
      'I ile am, he / she / it ile is, you / we / they ile are kullanılır.',
      'Soruda am / is / are başa gelir; olumsuzda not hemen arkas1na gelir.',
    ];
  }
  if (key == 'a1_articles' ||
      raw.contains('a / an / the') ||
      raw.contains('articles')) {
    return const [
      'A/an "ilk kez bahsetti?in" tekil say?labilir isimler i?indir: a dog, an apple.',
      'The "konuşmada bilinen / belirli" isimler i?indir: the dog (hangi k?pek oldu?u belli).',
      'En pratik ipucu: harf değil ses �nemlidir. Hour � an hour gibi.',
    ];
  }
  if (key == 'a1_there_is_are' ||
      raw.contains('there is') ||
      raw.contains('there are')) {
    return const [
      'There is/are "var/yok" anlam? verir; bir yerde bir şeyin varl??n? s?ylersin.',
      'Tekil: there is. �o?ul: there are. Soruda is/are başa gelir.',
      'En s?k hata: "there is two..." demek. Two ?o?uldur; there are gerekir.',
    ];
  }
  if (key == 'a1_some_any' || raw.contains('some') || raw.contains('any')) {
    return const [
      'Some/any say1 net değilken kullanılır: some water, any questions.',
      'G�venli kural: olumlu cümlede some; soru ve olumsuzda any. (0stisna: teklif/ikram sorular1nda some.)',
      'T?rk?eden birebir ?evirmeye ?al??ma; hedef "miktar net değil" hissi.',
    ];
  }
  if (key == 'a1_how_much_many' ||
      raw.contains('how much') ||
      raw.contains('how many')) {
    return const [
      'How many say1labilir �o?ul isimlerle; how much say?lamayan isimlerle kullanılır.',
      'Books, apples -> how many. Water, money -> how much.',
      'Fiyat sorusunda "How much is it?" ?ok s?k kullanılır.',
    ];
  }
  if (key == 'a1_can_cant' || raw.contains('can') || raw.contains("can't")) {
    return const [
      'Can bir modal verb?d�r; he/she/it ile de?i?mez: She can swim.',
      'Can\'dan sonra fiil yal?n gelir (V1): can go, can speak. "can to go" olmaz.',
      'Olumsuz: can\'t. Soru: Can you...?',
    ];
  }
  if (raw.contains('past continuous')) {
    return const [
      'Past Continuous ge�mi_te devam eden sahneyi anlat1r.',
      'V-ing tek başına yetmez; �n�nde was / were olmal1.',
      'When k1sa olay1, while devam eden sahneyi ba?lamak için çok kullanılır.',
    ];
  }
  if (raw.contains('past simple')) {
    return const [
      'Past Simple ge�mi_te ba_lay1p bitmiş olay1 anlat1r.',
      'Olumlu cümlede V2 kullanılır; did / did not gelirse fiil V1 kalır.',
      'Yesterday, last week ve ago gibi ifadeler bu zaman1 g��l� bi�imde i?aret eder.',
    ];
  }
  if (key.contains('present_perfect')) {
    return const [
      'Present Perfect "deneyim / yeni sonu? / bitmemi? zaman" i?in kullanılır; net bitmiş zaman (yesterday, last week) varsa Past Simple se?.',
      'Yap1: have/has + V3. He/she/it ile has, di?erlerinde have kullanılır.',
      'En yayg?n hata: "I have seen him yesterday" gibi net zamanla Present Perfect kullanmak.',
    ];
  }
  if (key == 'b1_past_perfect' || raw.contains('past perfect')) {
    return const [
      'Past Perfect "ge?mi?te ge?mi?"tir: bir olay, di?er ge?mi? olaydan daha ?nce olduysa kullanılır.',
      'Yap1: had + V3. Genelde when/by the time ile birlikte netle_ir.',
      'En yayg?n hata: iki olay1 da Past Simple ile anlat1p s?ralamay1 belirsiz b1rakmak.',
    ];
  }
  if (key == 'b1_present_perfect_continuous' ||
      raw.contains('present perfect continuous')) {
    return const [
      'Present Perfect Continuous "ba?lad? ve h?l? s?r?yor" vurgusunu ta?r (?zellikle s?re belirtince).',
      'Yap1: have/has been + V-ing. Süre için for, başlangıç için since çok kullanılır.',
      'Present Perfect (have done) ile kar1_t1rma: biri süre/aktivite, di?eri sonuç/bitmişlik vurgusu taşıyabilir.',
    ];
  }
  if (key == 'a2_should' || raw.contains('should')) {
    return const [
      'Should / shouldn\'t tavsiye verirken kullanılır: "bence iyi fikir / bence k?t? fikir".',
      'Should\'dan sonra fiil yal?n gelir (V1): should go, should study. "should to go" veya "should goes" olmaz.',
      'Kibar bir tavsiye tonu vard1r; yasak/otorite gerekiyorsa mustn\'t değil, ba?lama g�re ba_ka yap? se�ilir.',
    ];
  }
  if (key == 'a2_must_have_to' ||
      raw.contains('must') ||
      raw.contains('have to')) {
    return const [
      'Must / have to zorunluluk anlat1r. �nemli ayr1m: mustn\'t = yasak; don\'t have to = mecbur değilsin.',
      'Have to, d? kural/?art gibi duyulabilir; must daha "kesin" ton verir.',
      'Have to soruda/olumsuzda do/does ile gider: Do you have to&? / I don\'t have to&',
    ];
  }
  if (key == 'a2_going_to' || raw.contains('going to')) {
    return const [
      'Be going to plan/niyet ve "i?aret var" dedi?in tahminler i?in kullanılır.',
      'Yap?: am/is/are going to + V1. En b?y?k hata: "I going to..." (be verb eksik).',
      'Plan c�mlelerinde zaman ifadesi eklemek c�mleyi daha doğal yapar: tonight, tomorrow, this weekend.',
    ];
  }
  if (key == 'a2_will' || raw.contains('will')) {
    return const [
      'Will genelde konu_ma anındaki karar, tahmin, teklif ve söz için kullanılır.',
      'Will\'den sonra fiil yal?n gelir (V1): will go, will help. "will goes" olmaz.',
      'Plan/niyet netse going to daha doğal olabilir; ba?lam se�imi �nemli.',
    ];
  }
  if (raw.contains('comparative') || raw.contains('comparatives')) {
    return const [
      'Comparative iki şeyi kar?la?t?r1r.',
      'K1sa s?fatlarda -er, uzun s?fatlarda more kullanılır.',
      'More + -er birlikte kullan?lmaz: more better değil better.',
    ];
  }
  if (raw.contains('must') || raw.contains('have to')) {
    return const [
      'Must ve have to zorunluluk anlat1r.',
      'Mustn?t yasak, don\'t have to ise gerek yok demektir.',
      'He / she / it ile has to kullanılır.',
    ];
  }
  return const [
    '�nce kal?b? fark et, sonra �rnek c�mlenin ayn? mant1kla kurulup kurulmad1?1n1 kontrol et.',
    'Model cümle doğru yapıyı gösterir; kaçın kartı en tipik hatayı gösterir.',
    'Pratikte ayn? yap?y? farkl1 c�mlelerde g�rmeye odaklan.',
  ];
}

List<String> _turkishFocusPointsFor(GrammarLesson lesson) {
  final rows = _normalizedFormulaRowsFor(lesson);
  final points = <String>[];
  for (final row in rows) {
    final label = _formulaLabel(row, false);
    final sample = row.sample.trim();
    if (sample.isEmpty) continue;
    points.add('$label: $sample');
    if (points.length >= 5) break;
  }
  if (points.isNotEmpty) return points;
  return _turkishTeacherBulletsFor(lesson);
}

String _localizedFormulaLabel(String label, bool isEnglish) {
  if (isEnglish) return label;
  final lower = label.toLowerCase().trim();
  if (lower == 'positive' || lower.contains('affirmative')) return 'Olumlu';
  if (lower.contains('regular positive')) return 'Düzenli olumlu';
  if (lower.contains('irregular positive')) return 'Düzensiz olumlu';
  if (lower.contains('interrupted')) return 'Kesilen eylem';
  if (lower.contains('background')) return 'Arka plan';
  if (lower.contains('full sentence')) return 'Tam cümle';
  if (lower.contains('if clause')) return 'If cümlesi';
  if (lower.contains('negative result')) return 'Olumsuz sonuç';
  if (lower.contains('time contrast')) return 'Zaman farkı';
  if (lower.contains('adjective enough')) return 'Sıfat + enough';
  if (lower.contains('enough noun')) return 'Enough + isim';
  if (lower.contains('group phrase')) return 'Grup ifadesi';
  if (lower == 'must') return 'Must';
  if (lower == 'have to') return 'Have to';
  if (lower == 'has to') return 'Has to';
  if (lower == 'too') return 'Too';
  if (lower.contains('negative advice')) return 'Olumsuz tavsiye';
  if (lower.contains('negative')) return 'Olumsuz cümleyi tamamla.';
  if (lower.contains('question')) return 'Soru cümlesini tamamla.';
  if (lower.contains('time word')) return 'Zaman kelimeleri';
  if (lower.contains('short adjective')) return 'Kısa sıfatlar';
  if (lower.contains('long adjective')) return 'Uzun sıfatlar';
  if (lower.contains('irregular')) return 'Düzensiz';
  if (lower.contains('spelling')) return 'Yazım';
  if (lower.contains('comparison')) return 'Karşılaştırma kelimesi';
  if (lower.contains('prediction')) return 'Tahmin';
  if (lower.contains('offer') || lower.contains('promise')) {
    return 'Teklif / söz';
  }
  if (lower.contains('prohibition')) return 'Yasak';
  if (lower.contains('no necessity')) return 'Gerek yok';
  if (lower.contains('advice')) return 'Tavsiye';
  if (lower.contains('problem')) return 'Problem';
  if (lower.contains('signal')) return 'İpucu kelimeler';
  if (lower.contains('experience')) return 'Deneyim';
  if (lower.contains('plan')) return 'Plan';
  if (lower.contains('evidence')) return 'Kanıt';
  if (lower.contains('if')) return 'If yapısı';
  if (lower.contains('result')) return 'Sonuç';
  if (lower.contains('person')) return 'İnsan';
  if (lower.contains('thing')) return 'Şey / fikir';
  if (lower.contains('countable')) return 'Sayılabilir';
  if (lower.contains('uncountable')) return 'Sayılamaz';
  if (lower.contains('zero')) return 'Genel gerçek';
  if (lower == 'model') return 'Model';
  return label;
}

class _PremiumBigIdeaCard extends StatelessWidget {
  final Color color;
  final String title;
  final String goal;
  final String sample;
  final String right;
  final String wrong;
  final bool isEnglish;
  final bool showModelBlock;

  const _PremiumBigIdeaCard({
    required this.color,
    required this.title,
    required this.goal,
    required this.sample,
    required this.right,
    required this.wrong,
    required this.isEnglish,
    this.showModelBlock = true,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  String get _cleanTitle {
    final parts = title.split('=');
    return parts.first.trim().isEmpty ? title : parts.first.trim();
  }

  String get _meaning {
    if (goal.trim().isEmpty) return '';
    if (isEnglish) return _englishGoalForTitle(title, goal);
    if (title.contains('=')) {
      return title.split('=').sublist(1).join('=').trim();
    }
    return goal;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    final model = right.trim().isEmpty ? sample : right;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? _grammarLightGlass(color, strong: true)
              : [
                  Colors.white.withAlpha(13),
                  color.withAlpha(38),
                  const Color(0xFF07111E).withAlpha(242),
                  Colors.black.withAlpha(26),
                ],
          stops: tokens.isLight ? null : const [0, .22, .72, 1],
        ),
        border: Border.all(
          color: tokens.isLight
              ? _grammarGlassBorder(tokens, accent: color, strong: true)
              : Colors.white.withAlpha(16),
        ),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(24),
              blurRadius: 34,
              offset: const Offset(0, 18)),
          BoxShadow(
              color: tokens.isLight
                  ? const Color(0xFF334155).withAlpha(18)
                  : Colors.black.withAlpha(36),
              blurRadius: 18,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SoftIcon(icon: Icons.lightbulb_rounded, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('Main idea', 'Ana fikir'),
                  style: TextStyle(
                      color: accent,
                      fontSize: 12.6,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _cleanTitle,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 22.4,
              height: 1.04,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          if (_meaning.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _meaning,
              style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 13.4,
                  height: 1.40,
                  fontWeight: FontWeight.w700),
            ),
          ],
          if (showModelBlock) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tokens.isLight
                        ? color.withAlpha(10)
                        : Colors.white.withAlpha(9),
                    tokens.isLight
                        ? tokens.inputSurface
                        : Colors.black.withAlpha(22),
                    color.withAlpha(8),
                  ],
                ),
                border: Border.all(
                    color: tokens.isLight
                        ? tokens.border
                        : Colors.white.withAlpha(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Model sentence', 'Model cümle'),
                    style: TextStyle(
                        color: color,
                        fontSize: 11.7,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 9),
                  _MiniModelLine(
                      color: color,
                      icon: Icons.check_circle_rounded,
                      label: t('Model', 'Model'),
                      text: model),
                  if (wrong.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),
                    _MiniModelLine(
                        color: const Color(0xFFFFB020),
                        icon: Icons.warning_amber_rounded,
                        label: t('Avoid', 'Kaçın'),
                        text: wrong),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniModelLine extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String text;

  const _MiniModelLine(
      {required this.color,
      required this.icon,
      required this.label,
      required this.text});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(16),
            tokens.isLight ? tokens.inputSurface : Colors.white.withAlpha(5),
          ],
        ),
        border: Border.all(color: color.withAlpha(36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 15),
          const SizedBox(width: 7),
          Text('$label: ',
              style: TextStyle(
                  color: accent, fontSize: 11.2, fontWeight: FontWeight.w900)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 12.2,
                    height: 1.28,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

String _singleCleanSentence(String value) {
  final clean = _cleanOptionSentence(value);
  final parts = clean
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((e) => e.trim())
      .where(
          (e) => e.isNotEmpty && _isSentenceLike(e) && !_looksLikeMetaOption(e))
      .toList();
  return parts.isNotEmpty ? parts.first : clean;
}

class _RuleCheckCard extends StatefulWidget {
  final Color color;
  final bool isEnglish;
  final String wrong;
  final String right;
  final String reason;
  final List<GrammarQuizQuestion> quiz;

  const _RuleCheckCard({
    required this.color,
    required this.isEnglish,
    required this.wrong,
    required this.right,
    required this.reason,
    required this.quiz,
  });

  @override
  State<_RuleCheckCard> createState() => _RuleCheckCardState();
}

class _RuleCheckCardState extends State<_RuleCheckCard> {
  String? selected;
  bool revealed = false;

  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  List<String> get options {
    // Keep rule check clean: one correct sentence + one typical wrong sentence.
    // Do not pull random quiz options here; that created "one option is a sentence,
    // the other is a structure label" problems on A2.
    final correct = _singleCleanSentence(widget.right);
    var wrong = _singleCleanSentence(widget.wrong);

    if (wrong.isEmpty ||
        wrong.toLowerCase() == correct.toLowerCase() ||
        _looksLikeMetaOption(wrong) ||
        RegExp(r'\bI\s+a\b', caseSensitive: false).hasMatch(wrong)) {
      wrong = _smartCommonMistake(correct, '', widget.isEnglish);
    }
    if (wrong.isEmpty ||
        wrong.toLowerCase() == correct.toLowerCase() ||
        _looksLikeMetaOption(wrong) ||
        RegExp(r'\bI\s+a\b', caseSensitive: false).hasMatch(wrong)) {
      wrong = _safePracticeFallbacks(correct).first;
    }

    final two =
        <String>[correct, wrong].where((e) => e.trim().isNotEmpty).toList();
    if (two.length < 2) {
      return [correct, _smartCommonMistake(correct, '', widget.isEnglish)];
    }
    return correct.length.isEven ? two : two.reversed.toList();
  }

  void choose(String option) {
    setState(() {
      selected = option;
      revealed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localOptions = options;
    final checked = revealed && selected != null;
    final correctOption = _cleanOptionSentence(widget.right);
    final correct = _sameCleanSentence(selected, correctOption);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        color: Colors.white.withAlpha(5),
        border: Border.all(color: widget.color.withAlpha(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: widget.color.withAlpha(20)),
                child: Icon(Icons.bolt_rounded, color: widget.color, size: 16),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('Rule check', 'Kural kontrolü'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: widget.color,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                        t('Which sentence follows the rule?',
                            'Hangi c�mle kurala uyuyor?'),
                        style: TextStyle(
                            color: Colors.white.withAlpha(122),
                            fontSize: 10.9,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              if (checked)
                _TinyTag(
                    label: correct
                        ? t('got it', 'tamam')
                        : t('review', 'tekrar bak'),
                    color: correct
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFFFB020)),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(localOptions.length, (index) {
              final option = localOptions[index];
              final isSelected = selected == option;
              final isAnswer = _sameCleanSentence(option, correctOption);
              final stateColor = checked && isAnswer
                  ? const Color(0xFF22C55E)
                  : checked && isSelected
                      ? const Color(0xFFFF6B6B)
                      : isSelected
                          ? widget.color
                          : Colors.white.withAlpha(44);
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == localOptions.length - 1 ? 0 : 8),
                child: _TapScale(
                  onTap: () => choose(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      color: isSelected
                          ? widget.color.withAlpha(17)
                          : Colors.black.withAlpha(12),
                      border: Border.all(
                          color: stateColor
                              .withAlpha(checked || isSelected ? 160 : 72)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stateColor.withAlpha(18),
                            border: Border.all(color: stateColor.withAlpha(65)),
                          ),
                          child: Text(index == 0 ? 'A' : 'B',
                              style: TextStyle(
                                  color: stateColor,
                                  fontSize: 10.7,
                                  fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withAlpha(184),
                                fontSize: 12.4,
                                height: 1.25,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (checked && isAnswer)
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF22C55E), size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          if (checked) ...[
            const SizedBox(height: 11),
            _ResultExplanationStrip(
              color:
                  correct ? const Color(0xFF22C55E) : const Color(0xFFFFB020),
              icon: correct ? Icons.check_circle_rounded : Icons.info_rounded,
              text: _ruleFeedback(
                  correct: correct,
                  right: widget.right,
                  wrong: widget.wrong,
                  reason: widget.reason,
                  isEnglish: widget.isEnglish),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeacherLogicCard extends StatelessWidget {
  final Color color;
  final List<String> bullets;
  final bool isEnglish;
  final bool isA1;
  final bool showContent;

  const _TeacherLogicCard(
      {required this.color,
      required this.bullets,
      required this.isEnglish,
      this.isA1 = false,
      this.showContent = true});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    final safeBullets = !showContent
        ? const <String>[]
        : bullets.isEmpty
            ? [
                t('Focus on the meaning first, then copy the model sentence.',
                    'Önce anlamı kavra, sonra model cümleyi kopyala.')
              ]
            : bullets;
    final visibleBullets =
        safeBullets.take(isA1 ? 2 : 2).toList(growable: false);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isA1 ? 172 : 0),
      padding: EdgeInsets.fromLTRB(20, isA1 ? 20 : 17, 20, isA1 ? 22 : 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isA1 ? 34 : 30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? _grammarLightGlass(color, strong: isA1)
              : [
                  color.withAlpha(isA1 ? 42 : 28),
                  const Color(0xFF08111F).withAlpha(240),
                  Colors.white.withAlpha(isA1 ? 12 : 8),
                ],
        ),
        border: Border.all(
          color: tokens.isLight
              ? _grammarGlassBorder(
                  tokens,
                  accent: color,
                  strong: isA1,
                )
              : color.withAlpha(isA1 ? 60 : 44),
        ),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(isA1 ? 28 : 18),
              blurRadius: isA1 ? 38 : 30,
              offset: Offset(0, isA1 ? 18 : 16)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isA1 ? 50 : 42,
                height: isA1 ? 50 : 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isA1 ? 21 : 18),
                  color: color.withAlpha(isA1 ? 34 : 26),
                  border: Border.all(color: color.withAlpha(isA1 ? 58 : 44)),
                ),
                child: Icon(Icons.school_rounded,
                    color:
                        tokens.isLight ? accent : (isA1 ? Colors.white : color),
                    size: isA1 ? 24 : 21),
              ),
              SizedBox(width: isA1 ? 13 : 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('Teacher note', 'Öğretmen notu'),
                        style: TextStyle(
                            color: tokens.isLight
                                ? tokens.textPrimary
                                : (isA1 ? Colors.white : color),
                            fontSize: isA1 ? 17.2 : 13.4,
                            fontWeight: FontWeight.w900)),
                    if (showContent) ...[
                      SizedBox(height: isA1 ? 5 : 3),
                      Text(
                        t('One clear idea before practice',
                            'Pratikten önce tek net fikir'),
                        style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: isA1 ? 12.6 : 11.6,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isA1 ? 18 : 15),
          ...List.generate(visibleBullets.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index == visibleBullets.length - 1 ? 0 : 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: isA1 ? 8 : 5),
                    width: isA1 ? 7 : 5,
                    height: isA1 ? 7 : 5,
                    decoration: BoxDecoration(
                        color: color.withAlpha(210), shape: BoxShape.circle),
                  ),
                  SizedBox(width: isA1 ? 12 : 9),
                  Expanded(
                    child: Text(
                      _repairMojibake(visibleBullets[index]),
                      style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: isA1 ? 15.4 : 14.0,
                          height: isA1 ? 1.48 : 1.52,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuickLookPanel extends StatelessWidget {
  final Color color;
  final bool isEnglish;
  final List<String> items;
  final bool showContent;

  const _QuickLookPanel({
    required this.color,
    required this.isEnglish,
    required this.items,
    this.showContent = true,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    final safeItems = !showContent
        ? const <String>[]
        : items.isEmpty
            ? [t('Use the model sentence first.', 'Önce model cümleyi kullan.')]
            : items.map(_repairMojibake).take(4).toList(growable: false);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.scale(
          scale: 0.985 + (value * 0.015),
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tokens.isLight
                ? _grammarLightGlass(color, strong: true)
                : [
                    Colors.white.withAlpha(10),
                    color.withAlpha(38),
                    const Color(0xFF07111E).withAlpha(238),
                    Colors.white.withAlpha(10),
                  ],
            stops: tokens.isLight ? null : const [0, .2, .74, 1],
          ),
          border: Border.all(
              color: tokens.isLight
                  ? _grammarGlassBorder(tokens, accent: color, strong: true)
                  : Colors.white.withAlpha(15)),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(22),
                blurRadius: 34,
                offset: const Offset(0, 16)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: color.withAlpha(34),
                    border: Border.all(color: color.withAlpha(56)),
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: tokens.isLight ? accent : Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('Quick Look', 'Hızlı Bakış'),
                          style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.18)),
                      if (showContent) ...[
                        const SizedBox(height: 3),
                        Text(
                            t('Tiny rules you can use now',
                                'Hemen kullanacağın kısa notlar'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: tokens.textSecondary,
                                fontSize: 11.7,
                                fontWeight: FontWeight.w800)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth >= 560;
                final width = twoColumns
                    ? (constraints.maxWidth - 10) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: safeItems.asMap().entries.map((entry) {
                    return SizedBox(
                      width: width,
                      child: _QuickLookItem(
                        color: color,
                        text: entry.value,
                        index: entry.key,
                      ),
                    );
                  }).toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLookItem extends StatelessWidget {
  final Color color;
  final String text;
  final int index;

  const _QuickLookItem({
    required this.color,
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    const icons = [
      Icons.check_circle_rounded,
      Icons.tune_rounded,
      Icons.help_rounded,
      Icons.lightbulb_rounded,
    ];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index * 45)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 7),
          child: child,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: tokens.isLight
                ? [
                    Colors.white.withAlpha(204),
                    Color.alphaBlend(
                      color.withAlpha(10),
                      const Color(0xFFEAF0FB).withAlpha(196),
                    ),
                  ]
                : [Colors.white.withAlpha(7), Colors.black.withAlpha(18)],
          ),
          border: Border.all(
            color: tokens.isLight
                ? _grammarGlassBorder(tokens, accent: color)
                : tokens.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(22),
                border: Border.all(color: color.withAlpha(45)),
              ),
              child: Icon(icons[index % icons.length], color: accent, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 13.1,
                    height: 1.38,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrammarUseCaseStrip extends StatelessWidget {
  final GrammarLesson lesson;
  final Color color;
  final bool isEnglish;

  const _GrammarUseCaseStrip({
    required this.lesson,
    required this.color,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final pack = generateGrammarContextPack(lesson, isEnglish);
    final lessonKey = _lessonKey(lesson);
    final dialogueLimit = lessonKey.startsWith('a1_') ? 2 : 1;
    final speaking = pack.dialogueLines.isNotEmpty
        ? pack.dialogueLines
            .take(dialogueLimit)
            .map((line) => line.text.trim())
            .where((text) => text.isNotEmpty)
            .join('\n')
        : _learnModelSentenceFor(lesson, isEnglish);
    final writing = lesson.modelAnswer.trim().isNotEmpty
        ? lesson.modelAnswer.trim()
        : _learnModelSentenceFor(lesson, isEnglish);

    return Row(
      children: [
        Expanded(
          child: _UseCaseTile(
            icon: Icons.mic_rounded,
            title: t('Speaking', 'Speaking'),
            body: speaking,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _UseCaseTile(
            icon: Icons.edit_note_rounded,
            title: t('Writing', 'Writing'),
            body: writing,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _UseCaseTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _UseCaseTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withAlpha(10),
        border: Border.all(color: color.withAlpha(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: color,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: tokens.textSecondary,
                fontSize: 11.9,
                height: 1.33,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ResultExplanationStrip extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _ResultExplanationStrip(
      {required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withAlpha(15),
        border: Border.all(color: color.withAlpha(35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 12.0,
                      height: 1.35,
                      fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _PremiumFocusPointCard extends StatelessWidget {
  final Color color;
  final String number;
  final String text;
  final String sample;
  final String mistake;
  final bool expanded;
  final bool isEnglish;
  final VoidCallback onTap;

  const _PremiumFocusPointCard({
    required this.color,
    required this.number,
    required this.text,
    required this.sample,
    required this.mistake,
    required this.expanded,
    required this.isEnglish,
    required this.onTap,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 210),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          color: expanded ? color.withAlpha(13) : Colors.white.withAlpha(5),
          border: Border.all(
              color:
                  expanded ? color.withAlpha(33) : Colors.white.withAlpha(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 29,
                  height: 29,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: color.withAlpha(20),
                    border: Border.all(color: color.withAlpha(31)),
                  ),
                  child: Text(number,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                            color: Colors.white.withAlpha(184),
                            fontSize: 12.9,
                            height: 1.34,
                            fontWeight: FontWeight.w800),
                      ),
                      if (!expanded) ...[
                        const SizedBox(height: 4),
                        Text(sample,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withAlpha(96),
                                fontSize: 11.2,
                                fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                ),
                Icon(expanded ? Icons.remove_rounded : Icons.add_rounded,
                    color: Colors.white.withAlpha(120), size: 19),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 11),
              Container(height: 1, color: Colors.white.withAlpha(9)),
              const SizedBox(height: 10),
              _CompactInsightGrid(
                color: color,
                isEnglish: isEnglish,
                model: sample,
                avoid: mistake,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactInsightGrid extends StatelessWidget {
  final Color color;
  final bool isEnglish;
  final String model;
  final String avoid;

  const _CompactInsightGrid(
      {required this.color,
      required this.isEnglish,
      required this.model,
      required this.avoid});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SmallInsightPill(
            color: color,
            icon: Icons.auto_awesome_rounded,
            label: t('Example', 'Örnek'),
            text: model),
      ],
    );
  }
}

class _SmallInsightPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String text;

  const _SmallInsightPill(
      {required this.color,
      required this.icon,
      required this.label,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withAlpha(16),
        border: Border.all(color: color.withAlpha(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 7),
          Text('$label: ',
              style: TextStyle(
                  color: color, fontSize: 11.4, fontWeight: FontWeight.w900)),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: Colors.white.withAlpha(168),
                      fontSize: 12.1,
                      height: 1.32,
                      fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _FormLesson extends StatefulWidget {
  final GrammarLesson lesson;
  final List<GrammarFormulaRow> rows;
  final Color color;
  final bool isEnglish;

  const _FormLesson(
      {required this.lesson,
      required this.rows,
      required this.color,
      required this.isEnglish});

  @override
  State<_FormLesson> createState() => _FormLessonState();
}

class _FormLessonState extends State<_FormLesson> {
  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final rows = widget.rows
        .where((row) =>
            row.label.trim().isNotEmpty ||
            row.pattern.trim().isNotEmpty ||
            row.sample.trim().isNotEmpty)
        .toList(growable: false);
    final lessonKey = _lessonKey(widget.lesson);
    final useCleanTurkishDisplayPack = !widget.isEnglish;
    final pack = useCleanTurkishDisplayPack
        ? (_cleanDisplayStructurePack(widget.lesson) ??
            _StructurePack.fromLesson(widget.lesson, rows, widget.isEnglish))
        : _StructurePack.fromLesson(widget.lesson, rows, widget.isEnglish);
    final isA1 = lessonKey.startsWith('a1_') || lessonKey.startsWith('a2_');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CleanFormIntroCard(
          color: widget.color,
          isEnglish: widget.isEnglish,
          showContentSupport:
              _showTurkishContentSupport(lessonKey, widget.isEnglish),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 620;
            final gap = twoColumns ? 12.0 : 10.0;
            final cardWidth = twoColumns
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: pack.cards
                  .map((card) => SizedBox(
                        width: cardWidth,
                        child: _StructureCard(
                            card: card,
                            color: widget.color,
                            isEnglish: widget.isEnglish,
                            showTurkishNote: isA1,
                            showContentSupport: _showTurkishContentSupport(
                                lessonKey, widget.isEnglish),
                            initiallyExpanded: !isA1 && pack.cards.length <= 2),
                      ))
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _CleanFormIntroCard extends StatelessWidget {
  final Color color;
  final bool isEnglish;
  final bool showContentSupport;

  const _CleanFormIntroCard(
      {required this.color,
      required this.isEnglish,
      this.showContentSupport = true});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? _grammarLightGlass(color)
              : [
                  color.withAlpha(22),
                  const Color(0xFF10122A).withAlpha(210),
                  Colors.white.withAlpha(6),
                ],
        ),
        border: Border.all(
            color: tokens.isLight
                ? _grammarGlassBorder(tokens, accent: color)
                : color.withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withAlpha(22),
              border: Border.all(color: color.withAlpha(38)),
            ),
            child: Icon(Icons.schema_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Structure', 'Yapı'),
                  style: TextStyle(
                      color: color,
                      fontSize: 13.2,
                      fontWeight: FontWeight.w900),
                ),
                if (showContentSupport) ...[
                  const SizedBox(height: 4),
                  Text(
                    t('See the form, then tap a card for the quick pattern.',
                        'Karta dokun, kalıbı ve kısa notu gör.'),
                    style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12.0,
                        height: 1.32,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanFormulaRowCard extends StatelessWidget {
  final int number;
  final GrammarFormulaRow row;
  final Color color;
  final bool isEnglish;

  const _CleanFormulaRowCard(
      {required this.number,
      required this.row,
      required this.color,
      required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tone = _formulaTone(row, color);
    final label = _repairMojibake(_formulaLabel(row, isEnglish));
    final sample = _repairMojibake(_canonicalRowModel(row));
    final hint = _repairMojibake(_formUsageHint(row, isEnglish));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tone.withAlpha(15),
            const Color(0xFF081225).withAlpha(210),
            Colors.black.withAlpha(8)
          ],
        ),
        border: Border.all(color: tone.withAlpha(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: tone.withAlpha(19),
                  border: Border.all(color: tone.withAlpha(35)),
                ),
                child: Text('$number',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_rowIcon(row), color: tone, size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: tone,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _FormulaMiniCode(pattern: row.pattern, color: tone),
                    if (sample.trim().isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(sample,
                          style: TextStyle(
                              color: Colors.white.withAlpha(220),
                              fontSize: 14.4,
                              height: 1.26,
                              fontWeight: FontWeight.w900)),
                    ],
                    if (hint.trim().isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(hint,
                          style: TextStyle(
                              color: Colors.white.withAlpha(142),
                              fontSize: 11.6,
                              height: 1.28,
                              fontWeight: FontWeight.w700)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrammarMachineCard extends StatelessWidget {
  final List<GrammarFormulaRow> rows;
  final Color color;
  final bool isEnglish;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _GrammarMachineCard(
      {required this.rows,
      required this.color,
      required this.isEnglish,
      required this.selectedIndex,
      required this.onSelect});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final hasRows = rows.isNotEmpty && selectedIndex >= 0;
    final selected =
        hasRows ? rows[selectedIndex.clamp(0, rows.length - 1)] : null;
    final selectedTone =
        selected == null ? color : _formulaTone(selected, color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha(28),
              const Color(0xFF10122A).withAlpha(215),
              Colors.white.withAlpha(7)
            ]),
        border: Border.all(color: color.withAlpha(32)),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(10),
              blurRadius: 24,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: color.withAlpha(23),
                  border: Border.all(color: color.withAlpha(40)),
                ),
                child: Icon(Icons.account_tree_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('Sentence engine', 'C�mle motoru'),
                        style: TextStyle(
                            color: color,
                            fontSize: 13.2,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      t('Choose a structure; the matching block opens below.',
                          'Bir yap? se�; ilgili blok a_a?1da otomatik a�1ls1n.'),
                      style: TextStyle(
                          color: Colors.white.withAlpha(145),
                          fontSize: 11.7,
                          height: 1.28,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(rows.length, (index) {
                final active = index == selectedIndex;
                final tone = _formulaTone(rows[index], color);
                return _TapScale(
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 190),
                    curve: Curves.easeOutCubic,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: active
                          ? tone.withAlpha(34)
                          : Colors.black.withAlpha(18),
                      border: Border.all(
                          color: active
                              ? tone.withAlpha(78)
                              : Colors.white.withAlpha(11)),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: tone.withAlpha(16),
                                  blurRadius: 15,
                                  offset: const Offset(0, 7))
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: active
                                    ? tone
                                    : Colors.white.withAlpha(82))),
                        const SizedBox(width: 7),
                        Text(_formulaLabel(rows[index], isEnglish),
                            style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : Colors.white.withAlpha(150),
                                fontSize: 11.4,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
          if (selected != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withAlpha(18),
                border: Border.all(color: Colors.white.withAlpha(13)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t('Selected structure', 'Se�ilen yap?'),
                      style: TextStyle(
                          color: selectedTone,
                          fontSize: 10.8,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  _FormulaMiniCode(
                      pattern: selected.pattern, color: selectedTone),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_rowIcon(selected), color: selectedTone, size: 14),
                      const SizedBox(width: 7),
                      Expanded(
                          child: Text(selected.sample,
                              style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 12.1,
                                  height: 1.25,
                                  fontWeight: FontWeight.w800))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FormulaMiniCode extends StatelessWidget {
  final String pattern;
  final Color color;

  const _FormulaMiniCode({required this.pattern, required this.color});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: color.withAlpha(13),
        border: Border.all(color: color.withAlpha(28)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_tree_rounded, color: color, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pattern,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 12.8,
                height: 1.18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaStructureCard extends StatelessWidget {
  final int number;
  final GrammarFormulaRow row;
  final Color color;
  final bool isEnglish;
  final bool expanded;
  final VoidCallback onTap;

  const _FormulaStructureCard(
      {required this.number,
      required this.row,
      required this.color,
      required this.isEnglish,
      required this.expanded,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = _formulaLabel(row, isEnglish);
    final action = _formulaAction(row, isEnglish);
    final tone = _formulaTone(row, color);
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: expanded
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tone.withAlpha(24),
                    const Color(0xFF0A1230).withAlpha(210),
                    Colors.black.withAlpha(10)
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                      Colors.white.withAlpha(5),
                      Colors.black.withAlpha(12)
                    ]),
          border: Border.all(
              color:
                  expanded ? tone.withAlpha(50) : Colors.white.withAlpha(10)),
          boxShadow: expanded
              ? [
                  BoxShadow(
                      color: tone.withAlpha(12),
                      blurRadius: 18,
                      offset: const Offset(0, 8))
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormulaNumberBadge(
                    number: number, color: tone, active: expanded),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: tone,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 7),
                          if (!expanded)
                            _FormulaActionChip(label: action, color: tone),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(row.pattern,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.4,
                              height: 1.18,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(_canonicalRowModel(row),
                          style: TextStyle(
                              color: Colors.white.withAlpha(145),
                              fontSize: 12.1,
                              height: 1.28,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Icon(expanded ? Icons.remove_rounded : Icons.add_rounded,
                    color: Colors.white.withAlpha(130), size: 20),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 13),
              Container(height: 1, color: Colors.white.withAlpha(10)),
              const SizedBox(height: 12),
              _FormulaBreakdown(row: row, color: tone, isEnglish: isEnglish),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormulaBreakdown extends StatelessWidget {
  final GrammarFormulaRow row;
  final Color color;
  final bool isEnglish;

  const _FormulaBreakdown(
      {required this.row, required this.color, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final model = _canonicalRowModel(row);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormulaBuildStrip(
            color: color, pattern: row.pattern, isEnglish: isEnglish),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return _FormulaSignalTile(
              color: color,
              icon: Icons.auto_awesome_rounded,
              label: t('Examples', 'Örnekler'),
              text: model,
            );
          },
        ),
        const SizedBox(height: 10),
        _FormulaLogicNote(
            color: color,
            text: _formUsageHint(row, isEnglish),
            isEnglish: isEnglish),
      ],
    );
  }
}

bool _shouldShowAvoidInForm(GrammarFormulaRow row, String model, String avoid) {
  final kind = _rowKind(row);
  final sample = row.sample.trim().toLowerCase();
  final pattern = row.pattern.trim().toLowerCase();
  final modelClean = model.trim().toLowerCase();
  final avoidClean = avoid.trim().toLowerCase();

  if (avoidClean.isEmpty || avoidClean == modelClean) return false;

  // Spelling / word-shape rows are not error-comparison cards.
  // Showing a fake "avoid" sentence here creates nonsense such as
  // "box � ? bus � ? buses". These rows should show examples only.
  if (kind == 'spelling') return false;
  if (sample.contains('� ?') || sample.contains('->')) return false;
  if (pattern.contains('� ?') || pattern.contains('->')) return false;

  // Time-word and signal rows usually present lists, not full wrong sentences.
  if (kind == 'time' && !_isSentenceLike(model)) return false;

  // If either side is not a real sentence, do not force a model/avoid pair.
  if (!_isSentenceLike(model) || !_isSentenceLike(avoid)) return false;

  return true;
}

class _FormulaBuildStrip extends StatelessWidget {
  final Color color;
  final String pattern;
  final bool isEnglish;

  const _FormulaBuildStrip(
      {required this.color, required this.pattern, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withAlpha(13),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Icon(Icons.schema_rounded, color: color, size: 15),
          const SizedBox(width: 8),
          Text(isEnglish ? 'Pattern' : 'Kalıp',
              style: TextStyle(
                  color: color, fontSize: 11.2, fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(pattern,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.7,
                      height: 1.22,
                      fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class _FormulaSignalTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String text;

  const _FormulaSignalTile(
      {required this.color,
      required this.icon,
      required this.label,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withAlpha(15),
        border: Border.all(color: color.withAlpha(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 7),
          Text(text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white.withAlpha(178),
                  fontSize: 11.4,
                  height: 1.26,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _FormulaLogicNote extends StatelessWidget {
  final Color color;
  final String text;
  final bool isEnglish;

  const _FormulaLogicNote(
      {required this.color, required this.text, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withAlpha(5),
        border: Border.all(color: Colors.white.withAlpha(11)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_rounded, color: color, size: 15),
          const SizedBox(width: 8),
          Text('${isEnglish ? 'Logic' : 'Mantık'}: ',
              style: TextStyle(
                  color: color, fontSize: 11.3, fontWeight: FontWeight.w900)),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: Colors.white.withAlpha(166),
                      fontSize: 11.8,
                      height: 1.32,
                      fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

class _FormulaNumberBadge extends StatelessWidget {
  final int number;
  final Color color;
  final bool active;

  const _FormulaNumberBadge(
      {required this.number, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 35,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: active ? color.withAlpha(30) : Colors.white.withAlpha(7),
        border: Border.all(
            color: active ? color.withAlpha(45) : Colors.white.withAlpha(10)),
      ),
      child: Text('$number',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.w900)),
    );
  }
}

class _FormulaActionChip extends StatelessWidget {
  final String label;
  final Color color;

  const _FormulaActionChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(15),
        border: Border.all(color: color.withAlpha(27)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10.2, fontWeight: FontWeight.w900)),
    );
  }
}

String _rowKind(GrammarFormulaRow row) {
  final label = row.label.toLowerCase().trim();
  final pattern = row.pattern.toLowerCase().trim();
  final sample = row.sample.toLowerCase().trim();
  final all = '$label $pattern $sample';

  if (label.contains('avoid') ||
      label.contains('trap') ||
      label.contains('mistake') ||
      label.contains('ka�1n') ||
      label.contains('wrong')) {
    return 'avoid';
  }
  if (label.contains('negative') ||
      label.contains('olumsuz') ||
      label.contains('not enough') ||
      all.contains(' not ') ||
      all.contains("n?t") ||
      all.contains('do not') ||
      all.contains('does not') ||
      all.contains('did not') ||
      all.contains('will not')) {
    return 'negative';
  }
  if (all.contains('?') ||
      label.contains('question') ||
      label.contains('soru') ||
      RegExp(r'^(am|is|are|was|were|do|does|did|will|should|can|have|has)\b')
          .hasMatch(sample)) {
    return 'question';
  }
  if (label.contains('irregular')) return 'irregular';
  if (label.contains('spelling')) return 'spelling';
  if (label.contains('positive') ||
      label.contains('affirmative') ||
      label.contains('olumlu') ||
      label == 'i' ||
      label == 'you' ||
      label == 'he' ||
      label == 'she' ||
      label == 'it' ||
      label.contains('i / he') ||
      label.contains('you / we') ||
      label.contains('he / she') ||
      label.contains('regular')) {
    return 'positive';
  }
  if (label.contains('time') ||
      label.contains('signal') ||
      label.contains('frequency') ||
      label.contains('zaman') ||
      label.contains('s?kl?k') ||
      all.contains('yesterday') ||
      all.contains('last week') ||
      all.contains('ever / never')) {
    return 'time';
  }
  if (label.contains('if') ||
      label.contains('result') ||
      label.contains('conditional') ||
      label.contains('interrupted') ||
      label.contains('background') ||
      pattern.startsWith('if ') ||
      sample.startsWith('if ') ||
      sample.contains(' when ') ||
      sample.contains(' while ')) {
    return 'condition';
  }
  if (label.contains('compar') ||
      label.contains('short adjective') ||
      label.contains('long adjective') ||
      label.contains('spelling') ||
      label.contains('than') ||
      pattern.contains('than')) {
    return 'comparison';
  }
  if (label.contains('superlative') ||
      pattern.contains('the most') ||
      pattern.contains('+ est') ||
      pattern.contains('-est')) {
    return 'superlative';
  }
  if (label.contains('advice') ||
      label.contains('must') ||
      label.contains('have to') ||
      label.contains('has to') ||
      label.contains('should') ||
      pattern.contains('must ') ||
      pattern.contains('should ') ||
      pattern.contains('have to')) {
    return 'modal';
  }
  if (label.contains('passive') ||
      pattern.contains('be + v3') ||
      pattern.contains('was/were + v3')) {
    return 'passive';
  }
  if (label.contains('meaning') ||
      label.contains('use') ||
      label.contains('usage') ||
      label.contains('model') ||
      label.contains('core')) {
    return 'usage';
  }
  return 'positive';
}

IconData _rowIcon(GrammarFormulaRow row) {
  switch (_rowKind(row)) {
    case 'positive':
      return Icons.check_circle_rounded;
    case 'negative':
      return Icons.remove_circle_rounded;
    case 'question':
      return Icons.help_rounded;
    case 'avoid':
      return Icons.warning_amber_rounded;
    case 'time':
      return Icons.schedule_rounded;
    case 'condition':
      return Icons.alt_route_rounded;
    case 'comparison':
    case 'superlative':
      return Icons.compare_arrows_rounded;
    case 'irregular':
      return Icons.shuffle_rounded;
    case 'spelling':
      return Icons.edit_note_rounded;
    case 'modal':
      return Icons.gavel_rounded;
    case 'passive':
      return Icons.sync_alt_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}

Color _formulaTone(GrammarFormulaRow row, Color fallback) {
  switch (_rowKind(row)) {
    case 'positive':
      return const Color(0xFF32D583);
    case 'negative':
      return const Color(0xFFFF6B6B);
    case 'question':
      return const Color(0xFF7C8CFF);
    case 'avoid':
      return const Color(0xFFFFB020);
    case 'time':
      return const Color(0xFF22D3EE);
    case 'condition':
      return const Color(0xFF8B5CF6);
    case 'comparison':
      return const Color(0xFF38BDF8);
    case 'superlative':
      return const Color(0xFFF59E0B);
    case 'irregular':
      return const Color(0xFFFB7185);
    case 'spelling':
      return const Color(0xFF38BDF8);
    case 'modal':
      return const Color(0xFF14B8A6);
    case 'passive':
      return const Color(0xFFA78BFA);
    default:
      return fallback;
  }
}

String _formulaLabel(GrammarFormulaRow row, bool isEnglish) {
  final raw = row.label.trim();
  final lower = raw.toLowerCase();
  final kind = _rowKind(row);

  String baseFromKind() {
    switch (kind) {
      case 'positive':
        return isEnglish ? 'Positive' : 'Olumlu yapı';
      case 'negative':
        return isEnglish ? 'Negative' : 'Olumsuz yapı';
      case 'question':
        return isEnglish ? 'Question' : 'Soru yapısı';
      case 'avoid':
        return isEnglish ? 'Avoid' : 'Dikkat et';
      case 'time':
        return isEnglish ? 'Time words' : 'Zaman kelimeleri';
      case 'condition':
        return lower.contains('result')
            ? (isEnglish ? 'Result clause' : 'Sonuç cümlesi')
            : (isEnglish ? 'If / condition' : 'If / koşul');
      case 'comparison':
        return isEnglish ? 'Comparison' : 'Karşılaştırma';
      case 'irregular':
        return isEnglish ? 'Irregular form' : 'Düzensiz form';
      case 'spelling':
        return isEnglish ? 'Spelling change' : 'Yazım değişimi';
      case 'superlative':
        return isEnglish ? 'Superlative' : 'En üstünlük';
      case 'modal':
        return isEnglish ? 'Modal form' : 'Modal yapı';
      case 'passive':
        return isEnglish ? 'Passive form' : 'Passive yapı';
      default:
        return isEnglish ? 'Usage' : 'Kullanım';
    }
  }

  if (raw.isEmpty ||
      lower.startsWith('step') ||
      lower == 'meaning' ||
      lower == 'model' ||
      lower == 'core pattern' ||
      lower == 'temel yapı') {
    return baseFromKind();
  }

  final localized = _localizedFormulaLabel(raw, isEnglish);
  if (localized.trim().isNotEmpty && localized != raw) return localized;

  if (!isEnglish) {
    if (RegExp(r'^(i|you|we|they|he|she|it|i / he|you / we|he / she)',
            caseSensitive: false)
        .hasMatch(raw)) {
      return '${baseFromKind()} · $raw';
    }
  }

  if (lower.contains('positive') ||
      lower.contains('affirmative') ||
      lower.contains('olumlu')) {
    return isEnglish ? 'Positive' : 'Olumlu';
  }
  if (lower.contains('negative')) {
    return isEnglish ? 'Negative' : 'Olumsuz';
  }
  if (lower.contains('question')) {
    return isEnglish ? 'Question' : 'Soru';
  }
  if (_isHeSheItFormulaLabel(lower)) {
    return isEnglish ? 'Positive - He/She/It' : 'Olumlu - He/She/It';
  }
  return raw;
}

String _formulaAction(GrammarFormulaRow row, bool isEnglish) {
  switch (_rowKind(row)) {
    case 'positive':
      return isEnglish ? 'make' : 'olumlu';
    case 'negative':
      return isEnglish ? 'deny' : 'olumsuz';
    case 'question':
      return isEnglish ? 'ask' : 'soru';
    case 'avoid':
      return isEnglish ? 'avoid' : 'kaçın';
    case 'time':
      return isEnglish ? 'signal' : 'ipucu';
    case 'condition':
      return isEnglish ? 'connect' : 'başla';
    case 'comparison':
    case 'superlative':
      return isEnglish ? 'compare' : 'kıyasla';
    case 'modal':
      return isEnglish ? 'modal' : 'modal';
    default:
      return isEnglish ? 'use' : 'kullan';
  }
}

bool _isHeSheItFormulaLabel(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('he/she/it') ||
      lower.contains('he / she / it') ||
      lower.contains('he/she') ||
      lower.contains('he / she')) {
    return true;
  }
  return RegExp(r'(^|[^a-z])(he|she|it)([^a-z]|$)').hasMatch(lower);
}

String _formulaAvoidSample(GrammarFormulaRow row, bool isEnglish) {
  final label = row.label.toLowerCase();
  final pattern = row.pattern.toLowerCase();
  final sample = row.sample.trim();
  final lowerSample = sample.toLowerCase();

  String fallback() {
    final slip = _smartCommonMistake(sample, row.pattern, true);
    final cleanSlip = _cleanOptionSentence(slip);
    if (_isGoodAvoidCandidate(cleanSlip) &&
        cleanSlip.toLowerCase() != sample.toLowerCase()) {
      return cleanSlip;
    }
    return _isGoodAvoidCandidate(sample) ? sample : 'I did not went to school.';
  }

  if (sample.isEmpty) return 'I did not went to school.';
  if (sample.contains('� ?') ||
      sample.contains('->') ||
      pattern.contains('� ?') ||
      pattern.contains('->')) {
    return '';
  }

  // be verb / was-were rows: produce a real wrong sentence, not a generic warning.
  if (lowerSample.startsWith('i wake')) {
    return sample
        .replaceFirst(RegExp(r'\bI\b', caseSensitive: false), 'I do not')
        .replaceFirst(RegExp(r'\bwake\b', caseSensitive: false), 'wake');
  }
  if (lowerSample.startsWith('i work')) {
    return sample
        .replaceFirst(RegExp(r'\bI\b', caseSensitive: false), 'I do not')
        .replaceFirst(RegExp(r'\bwork\b', caseSensitive: false), 'work');
  }
  if (lowerSample.startsWith('i watch')) {
    return sample.replaceFirst(
        RegExp(r'\bwatch\b', caseSensitive: false), 'watched');
  }
  if (lowerSample.contains(' am ')) {
    return sample.replaceFirst(RegExp(r'\bam\b', caseSensitive: false), 'is');
  }
  if (lowerSample.contains(' is ')) {
    return sample.replaceFirst(RegExp(r'\bis\b', caseSensitive: false), 'are');
  }
  if (lowerSample.contains(' are ')) {
    return sample.replaceFirst(RegExp(r'\bare\b', caseSensitive: false), 'is');
  }
  if (lowerSample.contains(' was ')) {
    return sample.replaceFirst(
        RegExp(r'\bwas\b', caseSensitive: false), 'were');
  }
  if (lowerSample.contains(' were ')) {
    return sample.replaceFirst(
        RegExp(r'\bwere\b', caseSensitive: false), 'was');
  }
  if (lowerSample.contains('did not go')) {
    return sample.replaceFirst(RegExp(r'\bgo\b', caseSensitive: false), 'went');
  }
  if (lowerSample.contains('did you call')) {
    return sample.replaceFirst(
        RegExp(r'\bcall\b', caseSensitive: false), 'called');
  }
  if (lowerSample.contains('watched a movie')) {
    return sample.replaceFirst(
        RegExp(r'\bwatched\b', caseSensitive: false), 'watch');
  }
  if (lowerSample.contains('went to')) {
    return sample.replaceFirst(RegExp(r'\bwent\b', caseSensitive: false), 'go');
  }
  if (lowerSample.contains('colder than')) {
    return sample.replaceFirst(
        RegExp(r'\bcolder\b', caseSensitive: false), 'more cold');
  }
  if (lowerSample.contains('more useful')) {
    return sample.replaceFirst(
        RegExp(r'\bmore useful\b', caseSensitive: false), 'usefuler');
  }
  if (lowerSample.contains('better than')) {
    return sample.replaceFirst(
        RegExp(r'\bbetter\b', caseSensitive: false), 'more better');
  }
  if (lowerSample.contains('old enough')) {
    return sample.replaceFirst(
        RegExp(r'\bold enough\b', caseSensitive: false), 'enough old');
  }
  if (lowerSample.contains('have to') && lowerSample.contains('she')) {
    return sample.replaceFirst(
        RegExp(r'\bhas to\b', caseSensitive: false), 'have to');
  }

  // Questions: keep the same content but show the common word-order error.
  final questionAux = RegExp(
      r'^(Am|Is|Are|Was|Were|Do|Does|Did|Will|Should|Can|Have|Has)\s+([^?]+)\?$',
      caseSensitive: false);
  final questionMatch = questionAux.firstMatch(sample);
  if (questionMatch != null) {
    final aux = questionMatch.group(1)!;
    final rest = questionMatch.group(2)!;
    final parts = rest.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first} $aux ${parts.sublist(1).join(' ')}?';
    }
    return '$rest $aux?';
  }

  // Negatives: show the most typical wrong position/form.
  if (label.contains('negative') ||
      label.contains('olumsuz') ||
      pattern.contains('not') ||
      lowerSample.contains("n?t")) {
    if (lowerSample.contains('did not go')) {
      return sample.replaceFirst(
          RegExp(r'\bgo\b', caseSensitive: false), 'went');
    }
    if (lowerSample.contains('does not work')) {
      return sample.replaceFirst(
          RegExp(r'\bwork\b', caseSensitive: false), 'works');
    }
    if (lowerSample.contains('do not watch')) {
      return sample.replaceFirst(
          RegExp(r'\bwatch\b', caseSensitive: false), 'watches');
    }
    if (lowerSample.contains('will not') || lowerSample.contains("won't")) {
      return sample.replaceFirst(
          RegExp(r"\b(will not|won\'t)\b", caseSensitive: false),
          'don\'t will');
    }
    if (lowerSample.contains('shouldn\'t') ||
        lowerSample.contains('should not')) {
      return sample.replaceFirst(
          RegExp(r"\b(shouldn\'t|should not)\b", caseSensitive: false),
          'don\'t should');
    }
    if (lowerSample.contains('not')) {
      return sample.replaceFirst(RegExp(r'\bnot\s+', caseSensitive: false), '');
    }
  }

  // Tense/modal patterns.
  if (lowerSample.contains('did not go')) {
    return sample.replaceFirst(RegExp(r'\bgo\b', caseSensitive: false), 'went');
  }
  if (lowerSample.contains('did you call')) {
    return sample.replaceFirst(
        RegExp(r'\bcall\b', caseSensitive: false), 'called');
  }
  if (lowerSample.contains('will ')) {
    return sample.replaceFirstMapped(
        RegExp(r'\bwill\s+([a-z]+)', caseSensitive: false),
        (m) => 'will ${m[1]}s');
  }
  if (lowerSample.contains('going to')) {
    return sample.replaceFirst(
        RegExp(r'\b(am|is|are)\s+going to\b', caseSensitive: false),
        'going to');
  }
  if (lowerSample.contains('should ')) {
    return sample.replaceFirstMapped(
        RegExp(r'\bshould\s+([a-z]+)', caseSensitive: false),
        (m) => 'should ${m[1]}s');
  }
  if (lowerSample.contains('must ')) {
    return sample.replaceFirstMapped(
        RegExp(r'\bmust\s+([a-z]+)', caseSensitive: false),
        (m) => 'must to ${m[1]}');
  }
  if (lowerSample.contains('has to')) {
    return sample.replaceFirst(
        RegExp(r'\bhas to\b', caseSensitive: false), 'have to');
  }
  if (lowerSample.contains('have to')) {
    return sample.replaceFirst(
        RegExp(r'\bhave to\b', caseSensitive: false), 'has to');
  }
  if (lowerSample.contains('have visited')) {
    return sample.replaceFirst(
        RegExp(r'\bhave visited\b', caseSensitive: false), 'visited');
  }
  if (lowerSample.contains('has finished')) {
    return sample.replaceFirst(
        RegExp(r'\bhas finished\b', caseSensitive: false), 'finished');
  }

  // Comparison / quantity / connector patterns.
  if (lowerSample.contains('more useful')) {
    return sample.replaceFirst(
        RegExp(r'\bmore useful\b', caseSensitive: false), 'usefuler');
  }
  if (lowerSample.contains('more interesting')) {
    return sample.replaceFirst(
        RegExp(r'\bmore interesting\b', caseSensitive: false), 'interestinger');
  }
  if (lowerSample.contains('better')) {
    return sample.replaceFirst(
        RegExp(r'\bbetter\b', caseSensitive: false), 'more better');
  }
  if (lowerSample.contains('the most')) {
    return sample.replaceFirst(
        RegExp(r'\bthe most\b', caseSensitive: false), 'most');
  }
  if (lowerSample.contains('the best')) {
    return sample.replaceFirst(
        RegExp(r'\bthe best\b', caseSensitive: false), 'best');
  }
  if (lowerSample.contains('old enough')) {
    return sample.replaceFirst(
        RegExp(r'\bold enough\b', caseSensitive: false), 'enough old');
  }
  if (lowerSample.contains('big enough')) {
    return sample.replaceFirst(
        RegExp(r'\bbig enough\b', caseSensitive: false), 'enough big');
  }
  if (lowerSample.contains('enough money')) {
    return sample.replaceFirst(
        RegExp(r'\benough money\b', caseSensitive: false), 'money enough');
  }
  if (lowerSample.contains('too many')) {
    return sample.replaceFirst(
        RegExp(r'\btoo many\b', caseSensitive: false), 'too much');
  }
  if (lowerSample.contains('too much')) {
    return sample.replaceFirst(
        RegExp(r'\btoo much\b', caseSensitive: false), 'too many');
  }
  if (lowerSample.contains('used to')) {
    return sample.replaceFirst(
        RegExp(r'\bused to\b', caseSensitive: false), 'use to');
  }
  if (lowerSample.contains('would like to')) {
    return sample.replaceFirst(
        RegExp(r'\bwould like to\b', caseSensitive: false), 'would like');
  }
  if (lowerSample.contains('if it rains')) {
    return sample.replaceFirst(
        RegExp(r'\bIf it rains\b', caseSensitive: false), 'If it will rain');
  }
  if (lowerSample.contains('enjoy reading')) {
    return sample.replaceFirst(
        RegExp(r'\benjoy reading\b', caseSensitive: false), 'enjoy to read');
  }
  if (lowerSample.contains('who helps')) {
    return sample.replaceFirst(
        RegExp(r'\bwho helps\b', caseSensitive: false), 'which helps');
  }
  if (lowerSample.contains('water, it boils')) {
    return sample.replaceFirst(
        RegExp(r'\bit boils\b', caseSensitive: false), 'it will boil');
  }
  if (lowerSample.contains('there are')) {
    return sample.replaceFirst(
        RegExp(r'\bThere are\b', caseSensitive: false), 'There is');
  }
  if (lowerSample.contains('there is')) {
    return sample.replaceFirst(
        RegExp(r'\bThere is\b', caseSensitive: false), 'There are');
  }
  if (lowerSample.contains('can ')) {
    return sample.replaceFirst(
        RegExp(r'\bcan\s+', caseSensitive: false), 'can to ');
  }

  final smart = _smartCommonMistake(sample, '', isEnglish);
  if (!smart.toLowerCase().contains('yanl? yardımcı') &&
      !smart.toLowerCase().contains('wrong helper')) {
    return smart;
  }
  return fallback();
}

String _smartCommonMistake(String right, String wrong, bool isEnglish) {
  final cleanWrong = wrong.trim();
  if (cleanWrong.isNotEmpty &&
      cleanWrong.toLowerCase() != right.trim().toLowerCase()) {
    return cleanWrong;
  }

  final sentence = right.trim();
  if (sentence.isEmpty) {
    return isEnglish ? 'Wrong word order.' : 'Kelime s?ras? hatal?.';
  }

  final lower = sentence.toLowerCase();
  String mistake = sentence;

  if (lower.contains(' can ')) {
    mistake = sentence.replaceFirst(
        RegExp(r'\bcan\s+', caseSensitive: false), 'can to ');
  } else if (lower.contains(" can't ") || lower.contains(' cannot ')) {
    mistake = sentence
        .replaceFirst(RegExp(r"\bcan\'t\s+", caseSensitive: false), "can't to ")
        .replaceFirst(
            RegExp(r'\bcannot\s+', caseSensitive: false), 'cannot to ');
  } else if (lower.startsWith('she ') ||
      lower.startsWith('he ') ||
      lower.startsWith('it ')) {
    mistake = sentence.replaceFirst(
        RegExp(r'\bworks\b', caseSensitive: false), 'work');
    if (mistake == sentence) {
      mistake = sentence.replaceFirst(
          RegExp(r'\blikes\b', caseSensitive: false), 'like');
    }
    if (mistake == sentence) {
      mistake = sentence.replaceFirst(
          RegExp(r'\bstudies\b', caseSensitive: false), 'study');
    }
  } else if (lower.contains('there are')) {
    mistake = sentence.replaceFirst(
        RegExp(r'\bThere are\b', caseSensitive: false), 'There is');
  } else if (lower.contains('there is')) {
    mistake = sentence.replaceFirst(
        RegExp(r'\bThere is\b', caseSensitive: false), 'There are');
  } else if (lower.contains(' on monday') ||
      lower.contains(' on tuesday') ||
      lower.contains(' on wednesday')) {
    mistake =
        sentence.replaceFirst(RegExp(r'\bon\b', caseSensitive: false), 'in');
  } else if (lower.contains(' at 8') ||
      lower.contains(' at 7') ||
      lower.contains(' at night')) {
    mistake =
        sentence.replaceFirst(RegExp(r'\bat\b', caseSensitive: false), 'in');
  } else {
    final parts = sentence.split(RegExp(r'\s+'));
    if (parts.length > 3) {
      mistake =
          '${parts[0]} ${parts[2]} ${parts[1]} ${parts.sublist(3).join(' ')}';
    }
  }

  if (mistake.trim().isEmpty ||
      mistake.trim().toLowerCase() == sentence.toLowerCase()) {
    return isEnglish
        ? 'Use the wrong helper word.'
        : 'Yanl? yardımcı kelime kullan.';
  }
  return mistake;
}

String _lessonTopicKey(GrammarLesson lesson) {
  return lesson.bigTitle.split('=').first.trim().toLowerCase();
}

String _englishGoalForTitle(String title, String goal) {
  final key = title.split('=').first.trim().toLowerCase();
  if (key.contains('present simple')) {
    return 'routines, habits and general facts';
  }
  if (key.contains('am') && key.contains('is') && key.contains('are')) {
    return 'basic be verb for identity, place and feelings';
  }
  if (key.contains('subject pronoun')) {
    return 'use I, you, he, she, it, we, they instead of names';
  }
  if (key.contains('possessive adjective')) {
    return 'show who owns or is connected to something';
  }
  if (key.contains('article')) {
    return 'use a, an and the before nouns correctly';
  }
  if (key.contains('singular') || key.contains('plural')) {
    return 'talk about one thing or more than one thing';
  }
  if (key.contains('demonstrative')) {
    return 'point to near and far people or things';
  }
  if (key.contains('there is') || key.contains('there are')) {
    return 'say that something exists in a place';
  }
  if (key.contains('have') || key.contains('has got')) {
    return 'talk about possession and personal features';
  }
  if (key.contains('adverb') || key.contains('frequency')) {
    return 'say how often something happens';
  }
  if (key.contains('present continuous')) {
    return 'talk about actions happening now or around now';
  }
  if (key.contains('imperative')) return 'give short instructions and commands';
  if (key.contains('can')) {
    return 'talk about ability, possibility and permission';
  }
  if (key.contains('object pronoun')) {
    return 'use me, you, him, her, it, us and them after verbs';
  }
  if (key.contains('preposition') && key.contains('place')) {
    return 'say where something is';
  }
  if (key.contains('preposition') && key.contains('time')) {
    return 'use at, on and in with times, days and periods';
  }
  if (key.contains('some') || key.contains('any')) {
    return 'talk about an amount in positive, negative and question forms';
  }
  if (key.contains('countable') || key.contains('uncountable')) {
    return 'separate things we can count from things we measure';
  }
  if (key.contains('how much') || key.contains('how many')) {
    return 'ask about amount and number';
  }
  if (key.contains('question word')) return 'ask for specific information';
  if (key.contains("possessive 's") || key.contains('possessive')) {
    return 'show that something belongs to someone';
  }
  if (key.contains('conjunction')) {
    return 'connect simple ideas with and, but, because and so';
  }
  if (goal.trim().isNotEmpty && !RegExp(r'[??????]').hasMatch(goal)) {
    return goal.trim();
  }
  return 'understand the rule and copy the correct model';
}

List<String> _englishTeacherBulletsFor(GrammarLesson lesson) {
  final key = _lessonTopicKey(lesson);
  if (key.contains('present simple')) {
    return const [
      'Present Simple does not mean "right now"; it means "generally".',
      'Use it for routines, habits, schedules and general facts.',
      'The key A1 detail is the -s ending with he / she / it.',
    ];
  }
  if (key.contains('present continuous')) {
    return const [
      'Present Continuous focuses on an action happening now or around now.',
      'Use am / is / are before the verb and add -ing.',
      'Do not use it for every routine; use Present Simple for routines.',
    ];
  }
  if (key.contains('there is') || key.contains('there are')) {
    return const [
      'Use there is / there are to say that something exists in a place.',
      'Use there is with one thing and there are with more than one thing.',
      'The real subject comes after there is / there are.',
    ];
  }
  if (key.contains('preposition') && key.contains('time')) {
    return const [
      'Use at for clock times and fixed points.',
      'Use on for days and dates.',
      'Use in for months, years, seasons and long periods.',
    ];
  }
  if (key.contains('can')) {
    return const [
      'Can is a modal verb, so the main verb stays in its base form.',
      'Do not add to after can.',
      'Use can for ability, permission and simple possibility.',
    ];
  }
  if (key.contains('am') && key.contains('is') && key.contains('are')) {
    return const [
      'Use am with I, is with he / she / it, and are with you / we / they.',
      'Be can describe identity, place, feelings and basic states.',
      'In questions, move am / is / are before the subject.',
    ];
  }
  return const [
    'Focus on the meaning first, then copy the model sentence.',
    'Notice the helper word and the verb form.',
    'Most mistakes happen when students translate word by word.',
  ];
}

List<String> _englishFocusPointsFor(GrammarLesson lesson) {
  final key = _lessonTopicKey(lesson);
  if (key.contains('present simple')) {
    return const [
      'Use it for routines: I wake up at 8.',
      'Add -s with he / she / it: She works.',
      'Use do not / does not + V1 in negatives.',
      'Use Do / Does before the subject in questions.',
      'Frequency adverbs are common with Present Simple.',
    ];
  }
  if (key.contains('present continuous')) {
    return const [
      'Use am / is / are + V-ing for actions now.',
      'Use it for temporary situations around now.',
      'Do not forget the be verb before the -ing verb.',
      'Questions start with am / is / are.',
      'It contrasts with Present Simple routines.',
    ];
  }
  if (key.contains('preposition') && key.contains('time')) {
    return const [
      'Use at with clock times: at 8 o?clock.',
      'Use on with days and dates: on Monday.',
      'Use in with months, years and seasons: in May.',
      'Use at night as a special fixed phrase.',
      'Do not translate Turkish time phrases word by word.',
    ];
  }
  if (key.contains('there is') || key.contains('there are')) {
    return const [
      'Use there is with one thing.',
      'Use there are with plural things.',
      'Place words usually come at the end.',
      'Questions start with Is there / Are there.',
      'Use any in negative and question forms.',
    ];
  }
  if (key.contains('can')) {
    return const [
      'Use can + V1 for ability.',
      'Use cannot / can\'t for negatives.',
      'Questions start with Can + subject.',
      'Do not use to after can.',
      'The verb after can never takes -s.',
    ];
  }
  if (key.contains('am') && key.contains('is') && key.contains('are')) {
    return const [
      'Use am with I.',
      'Use is with he / she / it.',
      'Use are with you / we / they.',
      'Questions move am / is / are to the front.',
      'Negatives add not after am / is / are.',
    ];
  }
  final rows = lesson.formulaRows
      .map((e) => e.label.trim())
      .where((e) => e.isNotEmpty)
      .take(5)
      .toList();
  if (rows.isNotEmpty) return rows;
  return const [
    'Understand the rule meaning.',
    'Copy the correct model.',
    'Avoid word-for-word translation.',
    'Check the helper word.',
    'Check the verb form.',
  ];
}

String _englishReasonFor(
    {required String right, required String wrong, required String reason}) {
  final lower = '$right $wrong $reason'.toLowerCase();
  if (lower.contains('she works') ||
      lower.contains('he works') ||
      lower.contains('he/she/it') ||
      lower.contains('-s')) {
    return 'With he / she / it in a positive sentence, add -s to the verb.';
  }
  if (lower.contains('does not') || lower.contains("doesn't")) {
    return 'After does not, use the base verb without -s.';
  }
  if (lower.contains('does she') ||
      lower.contains('do they') ||
      lower.contains('do you')) {
    return 'In questions, Do / Does comes before the subject and the main verb stays in V1.';
  }
  if (lower.contains('there is') || lower.contains('there are')) {
    return 'Choose is for one thing and are for more than one thing.';
  }
  if (lower.contains(' can ')) {
    return 'After can, use the base verb without to or -s.';
  }
  if (lower.contains(' on monday') ||
      lower.contains(' at 8') ||
      lower.contains(' in may')) {
    return 'Choose the time preposition by the time word: at, on or in.';
  }
  if (reason.trim().isNotEmpty && !RegExp(r'[??????]').hasMatch(reason)) {
    return reason.trim();
  }
  return 'This option follows the grammar model.';
}

String _ruleFeedback({
  required bool correct,
  required String right,
  required String wrong,
  required String reason,
  required bool isEnglish,
}) {
  final tCorrect = isEnglish ? 'Correct.' : 'Doğru.';
  final tAlmost = isEnglish ? 'Almost.' : 'Neredeyse.';
  final cleanReason = isEnglish
      ? _englishReasonFor(right: right, wrong: wrong, reason: reason)
      : reason.trim();
  if (correct) {
    if (cleanReason.isNotEmpty) return '$tCorrect $cleanReason';
    return isEnglish
        ? 'Correct. This sentence follows the model.'
        : 'Doğru. Bu c�mle modele uyuyor.';
  }
  if (cleanReason.isNotEmpty) return '$tAlmost\n$right\n$cleanReason';
  return isEnglish
      ? '$tAlmost\nCorrect model: $right'
      : '$tAlmost\nDo?ru model: $right';
}

String _focusModelFor(int index, String right, List<String> examples,
    String focus, bool isEnglish) {
  final f = focus.toLowerCase();

  // Key-point cards must use a model that belongs to the sentence in the text.
  // Example: "I/you/we/they + V1" cannot show "She studies...".
  if (f.contains('i/you/we/they') ||
      f.contains('i / you / we / they') ||
      f.contains('fiil v1') ||
      f.contains('base verb')) {
    return 'I work every day.';
  }
  if (f.contains('he/she/it') ||
      f.contains('he / she / it') ||
      f.contains('-s') ||
      f.contains('third person')) {
    return 'She studies English after school.';
  }
  if (f.contains('did') || f.contains('v1 kalır') || f.contains('did not')) {
    return 'I did not go to school.';
  }
  if (f.contains('v2') ||
      f.contains('regular') ||
      f.contains('irregular') ||
      f.contains('ge�mi_')) {
    return 'I watched a movie yesterday.';
  }
  if (f.contains('was') ||
      f.contains('were') ||
      f.contains('v-ing') ||
      f.contains('ing')) {
    return 'I was studying when you called.';
  }
  if (f.contains('when')) return 'I was studying when you called.';
  if (f.contains('while')) return 'While I was cooking, she was studying.';
  if (f.contains('than') ||
      f.contains('more') ||
      f.contains('-er') ||
      f.contains('kar?la?t?r')) {
    return 'Kayseri is colder than Antalya.';
  }
  if (f.contains('superlative') ||
      f.contains('the most') ||
      f.contains('the best') ||
      f.contains('en ')) {
    return 'She is the tallest student in the class.';
  }
  if (f.contains('mustn') || f.contains('must not')) {
    return 'You must not smoke here.';
  }
  if (f.contains('have to') || f.contains('has to')) {
    return 'She has to wake up early.';
  }
  if (f.contains('should')) return 'You should drink more water.';

  for (final example in examples) {
    final clean = _cleanOptionSentence(example);
    if (_isGoodModelCandidate(clean)) return clean;
  }
  final cleanRight = _cleanOptionSentence(right);
  return cleanRight.isNotEmpty
      ? cleanRight
      : (isEnglish
          ? 'I use the target structure correctly.'
          : 'Hedef yap?y? do?ru kullan?yorum.');
}

String _focusMistakeFor(
    int index, String model, String wrong, String focus, bool isEnglish) {
  // Mistake is generated from the same model sentence. No unrelated lesson.wrong.
  final generated =
      _cleanOptionSentence(_smartCommonMistake(model, '', isEnglish));
  if (_isGoodAvoidCandidate(generated) &&
      generated.toLowerCase() != _cleanOptionSentence(model).toLowerCase()) {
    return generated;
  }
  return _cleanOptionSentence(_formulaAvoidSample(
      GrammarFormulaRow(label: focus, pattern: focus, sample: model),
      isEnglish));
}

String _formUsageHint(GrammarFormulaRow row, bool isEnglish) {
  final label = row.label.toLowerCase();
  final pattern = row.pattern.toLowerCase();
  final kind = _rowKind(row);
  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  if (kind == 'spelling') {
    if (pattern.contains('es') ||
        label.contains('x') ||
        label.contains('ch') ||
        label.contains('sh') ||
        label.contains('s ending')) {
      return t('For words ending in s, x, ch or sh, add -es: box -> boxes.',
          's, x, ch veya sh ile biten kelimelerde -es ekle: box -> boxes.');
    }
    if (pattern.contains('ies') || pattern.contains('y')) {
      return t('For consonant + y, change y to -ies: city -> cities.',
          'Sessiz harf + y ile biten kelimelerde y d�_er ve -ies gelir: city -> cities.');
    }
    return t('This row shows a spelling change, so copy the example pattern.',
        'Bu sat1r yaz1m de?i_imini gösterir; �rnek kal?b? takip et.');
  }

  switch (kind) {
    case 'positive':
      if (pattern.contains('v-ed') || pattern.contains('v2')) {
        return t('Use this form for a finished past action.',
            'Bitmi? ge�mi_ eylem için bu formu kullan.');
      }
      if (pattern.contains('v-ing') ||
          pattern.contains('was') ||
          pattern.contains('were')) {
        return t('Use am/is/are or was/were before the -ing verb.',
            'V-ing fiilden �nce am/is/are veya was/were kullan.');
      }
      return t('Use this pattern to make a clean positive sentence.',
          'Temiz bir olumlu c�mle kurmak için bu kal?b? kullan.');
    case 'negative':
      return t(
          'This is the negative form. The negative marker must stay with the helper.',
          'Bu olumsuz formdur. Olumsuzluk eki yardımcı yap?yla birlikte kalmal1.');
    case 'question':
      return t(
          'This is the question form. The helper moves before the subject.',
          'Bu soru formudur. Yard1mc1 yap? özneden �nce gelir.');
    case 'time':
      return t('These words show the time or signal of the structure.',
          'Bu kelimeler yap?n1n zaman1n1 veya ipucunu gösterir.');
    case 'condition':
      return t(
          'Condition sentences have two parts: the condition and the result.',
          'Ko?ul c�mlelerinde iki par�a vard1r: ko?ul ve sonuç.');
    case 'comparison':
      return t('Use this pattern to compare two people, places, or things.',
          '?ki kişi, yer veya şeyi k1yaslamak için bu kal?b? kullan.');
    case 'superlative':
      return t('Use this pattern to show the top item in a group.',
          'Bir gruptaki en �st �rne?i g�stermek için bu kal?b? kullan.');
    case 'modal':
      return t('After a modal, keep the main verb in base form.',
          'Modal sonras1 ana fiili yal?n halde tut.');
    case 'passive':
      return t('Passive focuses on the action or object, not the doer.',
          'Passive, yapan kişiden çok eyleme veya nesneye odaklan1r.');
  }

  if (_isHeSheItFormulaLabel(label)) {
    return t('This row is for the he/she/it group. Watch the ending.',
        'Bu sat1r he/she/it grubu içindir. Sondaki eke dikkat et.');
  }
  if (label.contains('you') ||
      label.contains('we') ||
      RegExp(r'(^|[^a-z])they([^a-z]|$)').hasMatch(label)) {
    return t('This row is for you/we/they. Use the plural helper.',
        'Bu sat1r you/we/they içindir. �o?ul yardımcıy1 kullan.');
  }
  return t('Copy the pattern exactly and change only the meaningful words.',
      'Kal1b1 aynen koru; sadece anlam ta_1yan kelimeleri de?i_tir.');
}

class _ExampleCoachCard extends StatelessWidget {
  final Color color;
  final bool isEnglish;

  const _ExampleCoachCard({required this.color, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(16),
            Colors.white.withAlpha(6),
            Colors.black.withAlpha(12)
          ],
        ),
        border: Border.all(color: color.withAlpha(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: color.withAlpha(18),
              border: Border.all(color: color.withAlpha(32)),
            ),
            child: Icon(Icons.view_carousel_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Example types', 'Örnek türleri'),
                  style: TextStyle(
                      color: color,
                      fontSize: 12.4,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .1),
                ),
                const SizedBox(height: 4),
                Text(
                  t('Choose a sentence type and scan several clean examples.',
                      'Cümle türünü seç; aynı yapıda birkaç net örnek gör.'),
                  style: TextStyle(
                      color: Colors.white.withAlpha(164),
                      fontSize: 12.35,
                      height: 1.35,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCategory {
  final String key;
  final String enLabel;
  final String trLabel;
  final String pattern;
  final String enHint;
  final String trHint;
  final Color tint;
  final IconData icon;

  const _ExampleCategory({
    required this.key,
    required this.enLabel,
    required this.trLabel,
    required this.pattern,
    required this.enHint,
    required this.trHint,
    required this.tint,
    required this.icon,
  });

  String label(bool isEnglish) => isEnglish ? enLabel : trLabel;
  String hint(bool isEnglish) => isEnglish ? enHint : trHint;
}

class _ExampleItem {
  final String sentence;
  final _ExampleCategory category;

  const _ExampleItem({required this.sentence, required this.category});
}

class _ExampleLesson extends StatefulWidget {
  final GrammarLesson lesson;
  final List<GrammarFormulaRow> formulaRows;
  final Color color;
  final bool isEnglish;

  const _ExampleLesson({
    required this.lesson,
    required this.formulaRows,
    required this.color,
    required this.isEnglish,
  });

  @override
  State<_ExampleLesson> createState() => _ExampleLessonState();
}

class _ExampleLessonState extends State<_ExampleLesson> {
  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  List<String> get cleanModelExamples {
    final seen = <String>{};
    final out = <String>[];
    final key = _lessonKey(widget.lesson);
    final signature = _exampleSignatureGroupsForKey(key);

    void add(String value) {
      final clean = _cleanOptionSentence(value);
      if (clean.trim().isEmpty || _looksLikeMetaOption(clean)) return;
      if (clean.length < 3) return;
      if (_contextLooksTeacherish(clean)) return;
      if (!_exampleMatchesSignature(clean, signature)) return;
      final key = clean.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (seen.contains(key)) return;
      seen.add(key);
      out.add(clean);
    }

    final points = generateGrammarLogicPoints(widget.lesson)
        .take(7)
        .toList(growable: false);
    for (final point in points) {
      add(point.model);
      if (out.length >= 10) break;
    }

    add(widget.lesson.right);
    add(widget.lesson.modelAnswer);

    for (final bank in _exampleBankForKey(key, widget.isEnglish)) {
      add(bank);
      if (out.length >= 16) break;
    }

    for (final example in widget.lesson.examples) {
      add(example);
      if (out.length >= 18) break;
    }

    for (final row in widget.formulaRows) {
      if (out.length >= 20) break;
      add(_canonicalRowModel(row));
    }

    return out.take(18).toList(growable: false);
  }

  List<String> get cleanMistakeExamples {
    final seen = <String>{};
    final out = <String>[];
    final key = _lessonKey(widget.lesson);
    final signature = _exampleSignatureGroupsForKey(key);

    void add(String value) {
      final clean = _cleanOptionSentence(value);
      if (clean.trim().isEmpty || _looksLikeMetaOption(clean)) return;
      if (!_isSentenceLike(clean)) return;
      if (_contextLooksTeacherish(clean)) return;
      if (!_exampleMatchesSignature(clean, signature)) return;
      final key = clean.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      if (seen.contains(key)) return;
      seen.add(key);
      out.add(clean);
    }

    final points = generateGrammarLogicPoints(widget.lesson)
        .take(7)
        .toList(growable: false);
    for (final point in points) {
      add(point.avoid);
      if (out.length >= 7) break;
    }
    add(widget.lesson.wrong);

    return out.take(9).toList(growable: false);
  }

  String _tagFor(String sentence) {
    final s = sentence.toLowerCase().trim();
    if (s.contains('->')) return t('change', 'dönüşüm');
    if (s.contains('� ?') || s.contains('->')) return t('change', 'dönüşüm');
    if (s.endsWith('?')) return t('question', 'soru');
    if (s.contains(' not ') || s.contains("n?t")) {
      return t('negative', 'olumsuz');
    }
    return t('sentence', 'cümle');
  }

  IconData _iconFor(String sentence) {
    final s = sentence.toLowerCase().trim();
    if (s.contains('� ?') || s.contains('->')) {
      return Icons.compare_arrows_rounded;
    }
    if (s.endsWith('?')) return Icons.help_rounded;
    if (s.contains(' not ') || s.contains("n?t")) {
      return Icons.remove_circle_outline_rounded;
    }
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final key = _lessonKey(widget.lesson);
    final items = cleanModelExamples;
    final mistakes = cleanMistakeExamples;
    final groups = _exampleGroupsFor(key, items, mistakes, widget.isEnglish);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CleanExamplesIntroCard(
            color: widget.color,
            isEnglish: widget.isEnglish,
            showContentSupport:
                _showTurkishContentSupport(key, widget.isEnglish)),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 680;
            final gap = twoColumns ? 12.0 : 12.0;
            final cardWidth = twoColumns
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: groups
                  .map((group) => SizedBox(
                        width: cardWidth,
                        child: _ExampleGroupCard(
                            group: group,
                            color: widget.color,
                            isEnglish: widget.isEnglish),
                      ))
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _ExampleGroupData {
  final String lessonKey;
  final String titleEn;
  final String titleTr;
  final String helperEn;
  final String helperTr;
  final IconData icon;
  final List<String> sentences;

  const _ExampleGroupData({
    required this.lessonKey,
    required this.titleEn,
    required this.titleTr,
    required this.helperEn,
    required this.helperTr,
    required this.icon,
    required this.sentences,
  });

  String title(bool isEnglish) => isEnglish
      ? _repairMojibake(titleEn)
      : _safeExampleGroupTitle(titleEn, titleTr, lessonKey);
  String helper(bool isEnglish) => isEnglish
      ? _repairMojibake(helperEn)
      : _safeExampleGroupHelper(helperEn, helperTr, lessonKey);
}

bool _looksBrokenTurkishVisible(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return false;
  return clean.contains('\uFFFD') ||
      clean.contains('ï¿½') ||
      clean.contains('�') ||
      RegExp(r'[ÃÄÅ]').hasMatch(clean) ||
      RegExp(r'[a-zA-Z][?1_][a-zA-Z]').hasMatch(clean);
}

String _safeTurkishVisible(String value, String fallback) {
  final repaired = _repairMojibake(value).trim();
  if (repaired.isEmpty || _looksBrokenTurkishVisible(repaired)) {
    return fallback;
  }
  return repaired;
}

String _safeExampleGroupTitle(String en, String tr, String lessonKey) {
  final lower = en.toLowerCase();
  var fallback = 'Örnek cümleler';
  if (lower.contains('affirmative') || lower.contains('positive')) {
    fallback = 'Olumlu cümleler';
  } else if (lower.contains('negative')) {
    fallback = 'Olumsuz cümleler';
  } else if (lower.contains('question')) {
    fallback = 'Soru cümleleri';
  } else if (lower.contains('short answer')) {
    fallback = 'Kısa cevaplar';
  } else if (lower.contains('time')) {
    fallback = 'Zaman ifadeleri';
  } else if (lower.contains('decision')) {
    fallback = 'Anlık kararlar';
  } else if (lower.contains('promise') || lower.contains('offer')) {
    fallback = 'Sözler ve teklifler';
  } else if (lower.contains('prediction')) {
    fallback = 'Tahminler';
  } else if (lessonKey.startsWith('c1_') || lessonKey.startsWith('c2_')) {
    fallback = 'İleri seviye örnekler';
  }
  return _safeTurkishVisible(tr, _repairMojibake(fallback));
}

String _safeExampleGroupHelper(String en, String tr, String lessonKey) {
  final lower = en.toLowerCase();
  var fallback = 'Cümleyi oku ve kalıbı fark et.';
  if (lower.contains('clean sentence') || lower.contains('main use')) {
    fallback = 'Yapıyı gerçek cümlede gör.';
  } else if (lower.contains('negative')) {
    fallback = 'Olumsuz yapıda yardımcı fiil ve ana fiili kontrol et.';
  } else if (lower.contains('question')) {
    fallback = 'Soru yapısında kelime sırasını kontrol et.';
  } else if (lower.contains('quick repl') || lower.contains('short')) {
    fallback = 'Konuşmada kısa ve doğal cevapları fark et.';
  } else if (lower.contains('finished') || lower.contains('time')) {
    fallback = 'Zaman ifadesi yapının kullanımını netleştirir.';
  } else if (lower.contains('promise') || lower.contains('offer')) {
    fallback =
        'Bu örnekte hedef yapı doğal bir iletişim amacıyla kullanılıyor.';
  } else if (lessonKey.startsWith('c1_') || lessonKey.startsWith('c2_')) {
    fallback =
        'Bu örnekte yapı daha doğal, vurgulu veya resmi bir anlatım kurar.';
  }
  return _safeTurkishVisible(tr, _repairMojibake(fallback));
}

List<_ExampleGroupData> _exampleGroupsFor(
    String key, List<String> items, List<String> mistakes, bool isEnglish) {
  final curated = _curatedA1ExampleGroups(key);
  if (curated.isNotEmpty) return curated;

  final affirm = <String>[];
  final neg = <String>[];
  final q = <String>[];
  final short = <String>[];

  void addTo(List<String> list, String s) {
    final clean = _cleanOptionSentence(s);
    if (clean.isEmpty) return;
    if (!list.any((e) => e.toLowerCase() == clean.toLowerCase())) {
      list.add(clean);
    }
  }

  for (final s in items) {
    final lower = s.toLowerCase();
    if (s.trim().endsWith('?')) {
      addTo(q, s);
    } else if (lower.startsWith('yes,') || lower.startsWith('no,')) {
      addTo(short, s);
    } else if (lower.contains("n?t") ||
        lower.contains(' not ') ||
        lower.startsWith("don't") ||
        lower.startsWith("doesn't") ||
        lower.startsWith("didn't")) {
      addTo(neg, s);
    } else {
      addTo(affirm, s);
    }
  }

  // Guarantee some variety per topic if possible.
  if (short.isEmpty) {
    if (key == 'a2_past_simple' || key.contains('past_simple')) {
      short.addAll(const ['Yes, I did.', 'No, I didn\'t.']);
    } else if (key.contains('present_perfect')) {
      short.addAll(const ['Yes, I have.', 'No, I haven\'t.']);
    }
  }

  final groups = <_ExampleGroupData>[];

  if (affirm.isNotEmpty) {
    groups.add(
      _ExampleGroupData(
        lessonKey: key,
        titleEn: 'Affirmative',
        titleTr: 'Olumlu',
        helperEn: 'Main use in clean sentences.',
        helperTr: 'Ana kullan1m: temiz c�mleler.',
        icon: Icons.check_circle_rounded,
        sentences: affirm.take(5).toList(growable: false),
      ),
    );
  }
  if (neg.isNotEmpty) {
    groups.add(
      _ExampleGroupData(
        lessonKey: key,
        titleEn: 'Negative',
        titleTr: 'Olumsuz',
        helperEn: 'Use the negative helper correctly.',
        helperTr: 'Olumsuz yardımcı yap?y? do?ru kullan.',
        icon: Icons.remove_circle_outline_rounded,
        sentences: neg.take(5).toList(growable: false),
      ),
    );
  }
  if (q.isNotEmpty) {
    groups.add(
      _ExampleGroupData(
        lessonKey: key,
        titleEn: 'Questions',
        titleTr: 'Soru',
        helperEn: 'Natural question patterns.',
        helperTr: 'Do?al soru kal1plar1.',
        icon: Icons.help_rounded,
        sentences: q.take(5).toList(growable: false),
      ),
    );
  }
  if (short.isNotEmpty) {
    groups.add(
      _ExampleGroupData(
        lessonKey: key,
        titleEn: 'Short answers',
        titleTr: 'K1sa cevap',
        helperEn: 'Quick replies in conversation.',
        helperTr: 'Konuşmada h1zl1 cevap.',
        icon: Icons.short_text_rounded,
        sentences: short.take(4).toList(growable: false),
      ),
    );
  }

  return groups;
}

List<_ExampleGroupData> _curatedA1ExampleGroups(String key) {
  switch (key) {
    case 'a2_past_simple':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_past_simple',
            titleEn: 'Positive past actions',
            titleTr: 'Olumlu ge�mi_ eylemler',
            helperEn: 'Finished actions with V2 or -ed.',
            helperTr: 'V2 veya -ed ile bitmiş eylemler.',
            icon: Icons.history_rounded,
            sentences: [
              'I visited my aunt yesterday.',
              'She went to Ankara last week.',
              'They arrived late.',
              'My father bought a new phone.',
              'We met two days ago.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_past_simple',
            titleEn: 'Negative past actions',
            titleTr: 'Olumsuz ge�mi_ eylemler',
            helperEn: 'Use did not + V1.',
            helperTr: 'Did not + V1 kullanılır.',
            icon: Icons.remove_circle_outline_rounded,
            sentences: [
              'We did not watch TV.',
              'He did not eat breakfast.',
              'I did not leave my keys at home.',
              'She did not call me yesterday.',
              'They did not stay long.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_past_simple',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Use did + subject + V1.',
            helperTr: 'Did + özne + V1 kullanılır.',
            icon: Icons.help_rounded,
            sentences: [
              'Did you finish your homework?',
              'Where did he go after school?',
              'Did she send the email?',
              'What did you do yesterday?',
              'Did they arrive on time?'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_past_simple',
            titleEn: 'Time expressions',
            titleTr: 'Zaman ifadeleri',
            helperEn: 'Finished time makes the past clear.',
            helperTr: 'Zaman ifadesi olay1n ge�mi_te bitti?ini gösterir.',
            icon: Icons.schedule_rounded,
            sentences: [
              'I cleaned my room yesterday.',
              'She called me last night.',
              'We moved here two years ago.',
              'They played tennis on Sunday.',
              'He started school in September.'
            ]),
      ];
    case 'a2_will':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_will',
            titleEn: 'Quick decisions',
            titleTr: 'Anl1k kararlar',
            helperEn: 'Decide at the moment of speaking.',
            helperTr: 'Konu?urken karar ver.',
            icon: Icons.flash_on_rounded,
            sentences: [
              'I will open the window.',
              'I will answer the phone.',
              'We will take a taxi.',
              'I will send the file now.',
              'She will ask the teacher.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_will',
            titleEn: 'Promises and offers',
            titleTr: 'S�zler ve teklifler',
            helperEn: 'Use will when you promise or help.',
            helperTr:
                'S�z verirken veya yard1m teklif ederken will kullanılır.',
            icon: Icons.volunteer_activism_rounded,
            sentences: [
              'I will help you with the bags.',
              'I will call you tonight.',
              'We will wait for you.',
              'I will not tell anyone.',
              'She will bring your book tomorrow.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_will',
            titleEn: 'Predictions',
            titleTr: 'Tahminler',
            helperEn: 'Say what you think about the future.',
            helperTr: 'Gelecek hakk1nda tahmin yap.',
            icon: Icons.cloud_rounded,
            sentences: [
              'I think it will snow.',
              'It will be cold tonight.',
              'They will arrive at six.',
              'The test will be easy.',
              'She will like this song.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_will',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Use Will + subject + V1.',
            helperTr: 'Will + özne + V1 kullanılır.',
            icon: Icons.help_rounded,
            sentences: [
              'Will they arrive soon?',
              'Will she help us?',
              'Will you call me tonight?',
              'Will it rain tomorrow?',
              'Will we need tickets?'
            ]),
      ];
    case 'a2_going_to':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_going_to',
            titleEn: 'Plans',
            titleTr: 'Planlar',
            helperEn: 'Plans and intentions you already have.',
            helperTr: '�nceden olan plan ve niyetler.',
            icon: Icons.event_available_rounded,
            sentences: [
              'I am going to study tonight.',
              'She is going to visit her aunt.',
              'We are going to start soon.',
              'They are going to travel next month.',
              'My sister is going to call you.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_going_to',
            titleEn: 'Negative plans',
            titleTr: 'Olumsuz planlar',
            helperEn: 'Use am/is/are not going to.',
            helperTr: 'Am/is/are not going to kullanılır.',
            icon: Icons.remove_circle_outline_rounded,
            sentences: [
              'He is not going to come.',
              'I am not going to watch TV.',
              'They are not going to buy a car.',
              'We are not going to stay here.',
              'She is not going to join us.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_going_to',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Move am/is/are before the subject.',
            helperTr: 'Am/is/are başa gelir.',
            icon: Icons.help_rounded,
            sentences: [
              'Are you going to buy it?',
              'Are they going to stay here?',
              'What are you going to do?',
              'Is she going to call you?',
              'Are we going to start now?'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_going_to',
            titleEn: 'Visible evidence',
            titleTr: 'G�r�nen i?aret',
            helperEn: 'Use it when the result is visible now.',
            helperTr: 'Sonuç ?u anki durumdan anla_1l1yorsa kullanılır.',
            icon: Icons.visibility_rounded,
            sentences: [
              'Look at the clouds. It is going to rain.',
              'Be careful. The glass is going to fall.',
              'She looks tired. She is going to sleep soon.',
              'The team is playing badly. They are going to lose.',
              'The sky is dark. It is going to snow.'
            ]),
      ];
    case 'a2_comparatives':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_comparatives',
            titleEn: 'Short adjectives',
            titleTr: 'K1sa s?fatlar',
            helperEn: 'Use -er + than.',
            helperTr: '-er + than yap?s? kullanılır.',
            icon: Icons.compare_arrows_rounded,
            sentences: [
              'This bag is cheaper than that one.',
              'Kayseri is colder than Antalya.',
              'The bus is slower than the train.',
              'Her room is bigger than mine.',
              'Today is hotter than yesterday.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_comparatives',
            titleEn: 'More + adjective',
            titleTr: 'More + s?fat',
            helperEn: 'Use more with longer adjectives.',
            helperTr: 'Uzun s?fatlarda more kullanılır.',
            icon: Icons.add_rounded,
            sentences: [
              'This exercise is more difficult than the last one.',
              'This book is more useful than that one.',
              'The red dress is more expensive than the blue one.',
              'This film is more interesting than the first film.',
              'The new app is more helpful than the old app.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_comparatives',
            titleEn: 'Irregular forms',
            titleTr: 'Düzensiz formlar',
            helperEn: 'Learn better, worse and farther as chunks.',
            helperTr: 'Better, worse ve farther kal1plar1n1 �?ren.',
            icon: Icons.auto_fix_high_rounded,
            sentences: [
              'My phone is better than my old phone.',
              'This cafe is better than the old cafe.',
              'The weather is worse than yesterday.',
              'My house is farther from school than yours.',
              'This answer is worse than the first one.'
            ]),
      ];
    case 'a2_superlatives':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_superlatives',
            titleEn: 'The + -est',
            titleTr: 'The + -est',
            helperEn: 'Use the with short superlatives.',
            helperTr: 'K1sa superlative yap?larda the kullanılır.',
            icon: Icons.emoji_events_rounded,
            sentences: [
              'She is the tallest student in the class.',
              'Monday is the busiest day for me.',
              'He is the youngest in his family.',
              'It is the coldest city in the region.',
              'This is the smallest room in the hotel.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_superlatives',
            titleEn: 'The most',
            titleTr: 'The most',
            helperEn: 'Use the most with longer adjectives.',
            helperTr: 'Uzun s?fatlarda the most kullanılır.',
            icon: Icons.star_rounded,
            sentences: [
              'This is the most interesting story.',
              'This is the most useful lesson.',
              'She is the most careful driver I know.',
              'That was the most expensive meal on the menu.',
              'This is the most beautiful park in town.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_superlatives',
            titleEn: 'Best and worst',
            titleTr: 'Best ve worst',
            helperEn: 'Use irregular superlatives naturally.',
            helperTr: 'D�zensiz superlative formlar1 kal1p olarak kullanılır.',
            icon: Icons.workspace_premium_rounded,
            sentences: [
              'This is the best restaurant in town.',
              'That was the worst day of the trip.',
              'She is the best player on the team.',
              'This is the worst answer in the group.',
              'It is the best cafe near school.'
            ]),
      ];
    case 'a2_countable_uncountable':
    case 'a2_some_any_much_many':
    case 'a2_quantifiers':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_quantifiers',
            titleEn: 'Countable nouns',
            titleTr: 'Say1labilir isimler',
            helperEn: 'Use numbers, many and a few with plural nouns.',
            helperTr: '�o?ul isimlerle say1, many ve a few kullanılır.',
            icon: Icons.format_list_numbered_rounded,
            sentences: [
              'I have a few apples.',
              'There are many chairs in the room.',
              'We need three bottles of water.',
              'She asked a few questions.',
              'There are five students in the class.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_quantifiers',
            titleEn: 'Uncountable nouns',
            titleTr: 'Say1lamayan isimler',
            helperEn: 'Use some, much, a little and a lot of.',
            helperTr:
                'Some, much, a little ve a lot of doğal miktar ifadeleridir.',
            icon: Icons.water_drop_rounded,
            sentences: [
              'I need a little water.',
              'We do not have much time.',
              'There is some bread on the table.',
              'She has a lot of homework.',
              'There is not much milk left.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_quantifiers',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Ask with much, many or any.',
            helperTr: 'Much, many veya any ile sor.',
            icon: Icons.help_rounded,
            sentences: [
              'Do we have any eggs?',
              'How much milk do we need?',
              'How many apples are there?',
              'Is there much bread?',
              'Are there any buses at night?'
            ]),
      ];
    case 'a2_should':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_should',
            titleEn: 'Giving advice',
            titleTr: 'Tavsiye vermek',
            helperEn: 'Use should + V1.',
            helperTr: 'Should + V1 ile tavsiye verilir.',
            icon: Icons.health_and_safety_rounded,
            sentences: [
              'You should drink water.',
              'You should see a doctor.',
              'You should review your notes.',
              'He should apologize.',
              'We should leave early.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_should',
            titleEn: 'Negative advice',
            titleTr: 'Olumsuz tavsiye',
            helperEn: 'Use should not + V1.',
            helperTr: 'Should not + V1 ile olumsuz tavsiye verilir.',
            icon: Icons.remove_circle_outline_rounded,
            sentences: [
              'You should not sleep late.',
              'You should not skip breakfast.',
              'She should not drive so fast.',
              'They should not be noisy here.',
              'He should not spend all his money.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_should',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Ask for advice with Should I/we...?',
            helperTr: 'Should I/we ile tavsiye sor.',
            icon: Icons.help_rounded,
            sentences: [
              'Should I call her now?',
              'Should we take a taxi?',
              'Should he tell the teacher?',
              'What should I wear?',
              'Where should we meet?'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_should',
            titleEn: 'Health and school',
            titleTr: 'Sa?l1k ve okul',
            helperEn: 'Advice in everyday situations.',
            helperTr: 'G�nl�k durumlarda tavsiye.',
            icon: Icons.school_rounded,
            sentences: [
              'You should rest today.',
              'You should study before the test.',
              'She should eat more fruit.',
              'He should ask for help.',
              'We should check the homework.'
            ]),
      ];
    case 'a2_must_have_to':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_must_have_to',
            titleEn: 'Rules',
            titleTr: 'Kurallar',
            helperEn: 'Use must for strong rules.',
            helperTr: 'G��l� kurallar için must kullanılır.',
            icon: Icons.rule_rounded,
            sentences: [
              'You must wear a seat belt.',
              'Students must be quiet in the library.',
              'You must show your ticket.',
              'We must turn off our phones.',
              'Visitors must use this door.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_must_have_to',
            titleEn: 'Duties',
            titleTr: 'G�revler',
            helperEn: 'Use have to / has to for duties.',
            helperTr:
                'G�rev ve mecburiyetler için have to / has to kullanılır.',
            icon: Icons.work_rounded,
            sentences: [
              'I have to finish my homework.',
              'She has to wake up early.',
              'We have to clean the classroom.',
              'He has to show his ID.',
              'They have to work tomorrow.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_must_have_to',
            titleEn: 'No necessity',
            titleTr: 'Zorunluluk yok',
            helperEn: 'Do not have to means optional.',
            helperTr: 'Do not have to iste?e ba?l1 demektir.',
            icon: Icons.event_available_rounded,
            sentences: [
              'You do not have to come early.',
              'She does not have to bring food.',
              'We do not have to pay today.',
              'He does not have to wear a uniform.',
              'They do not have to stay after class.'
            ]),
      ];
    case 'a2_object_possessive_pronouns':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_object_possessive_pronouns',
            titleEn: 'Object pronouns',
            titleTr: 'Nesne zamirleri',
            helperEn: 'Use them after verbs and prepositions.',
            helperTr: 'Nesne zamirleri fiil ve edatlardan sonra kullanılır.',
            icon: Icons.person_rounded,
            sentences: [
              'Can you help me?',
              'I can help you.',
              'She knows him.',
              'We like them.',
              'This gift is for us.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_object_possessive_pronouns',
            titleEn: 'Possessive pronouns',
            titleTr: '0yelik zamirleri',
            helperEn: 'Use mine, yours, hers without a noun.',
            helperTr: 'Mine, yours, hers gibi zamirlerden sonra isim gelmez.',
            icon: Icons.key_rounded,
            sentences: [
              'This book is mine.',
              'That phone is yours.',
              'The blue bag is hers.',
              'These seats are ours.',
              'The red bikes are theirs.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_object_possessive_pronouns',
            titleEn: 'Mixed sentences',
            titleTr: 'Kar1_1k c�mleler',
            helperEn: 'Choose object or possessive by position.',
            helperTr: 'Yere g�re nesne veya iyelik se�.',
            icon: Icons.swap_horiz_rounded,
            sentences: [
              'Give it to him.',
              'Mine is in my bag.',
              'I will take them.',
              'Is this notebook yours?',
              'Those books are not ours.'
            ]),
      ];
    case 'a2_adverbs_frequency_manner':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_adverbs_frequency_manner',
            titleEn: 'Frequency',
            titleTr: 'S?kl?k',
            helperEn: 'Say how often something happens.',
            helperTr: 'Bir şeyin ne kadar s?k oldu?unu anlat1r.',
            icon: Icons.schedule_rounded,
            sentences: [
              'I usually walk to school.',
              'She often studies after dinner.',
              'We sometimes eat out.',
              'He never drinks coffee.',
              'They always arrive on time.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_adverbs_frequency_manner',
            titleEn: 'Manner',
            titleTr: 'Nas1l yap?l1r',
            helperEn: 'Say how an action happens.',
            helperTr: 'Eylemin nas1l yap?ld1?1n1 anlat1r.',
            icon: Icons.speed_rounded,
            sentences: [
              'She speaks slowly.',
              'He drives carefully.',
              'They worked quietly.',
              'My sister speaks English well.',
              'Please write clearly.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_adverbs_frequency_manner',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Ask about frequency or manner.',
            helperTr: 'Ne kadar s?k veya nas1l oldu?unu sorars1n.',
            icon: Icons.help_rounded,
            sentences: [
              'Do you usually walk to school?',
              'How often do you study English?',
              'Does she speak quickly?',
              'Are you ever late?',
              'How carefully does he drive?'
            ]),
      ];
    case 'a2_infinitive_purpose':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_infinitive_purpose',
            titleEn: 'Why you go',
            titleTr: 'Neden gidersin',
            helperEn: 'Use to + V1 for purpose.',
            helperTr: 'Ama� anlatmak için to + V1 kullanılır.',
            icon: Icons.flag_rounded,
            sentences: [
              'I went to the shop to buy bread.',
              'She went to the library to study.',
              'We came here to meet you.',
              'He went outside to call his mother.',
              'They travelled to Istanbul to see friends.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_infinitive_purpose',
            titleEn: 'Why you use something',
            titleTr: 'Neden kullanırsın',
            helperEn: 'Explain the purpose of an action.',
            helperTr: 'Bir eylemin amac1n1 a�1kla.',
            icon: Icons.build_rounded,
            sentences: [
              'I use my phone to check emails.',
              'She opened the window to get fresh air.',
              'We saved money to buy a bike.',
              'He took a taxi to be on time.',
              'I called Deniz to ask a question.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_infinitive_purpose',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Ask why someone did something.',
            helperTr: 'Birinin neden yapt1?1n1 sor.',
            icon: Icons.help_rounded,
            sentences: [
              'Why did you go to the shop?',
              'Did you call to ask a question?',
              'What did you buy to make dinner?',
              'Why did she come early?',
              'Did he study to pass the exam?'
            ]),
      ];
    case 'a2_gerund_infinitive':
      return const [
        _ExampleGroupData(
            lessonKey: 'a2_gerund_infinitive',
            titleEn: 'Verb + -ing',
            titleTr: 'Fiil + -ing',
            helperEn: 'Use -ing after enjoy, like and hate.',
            helperTr: 'Enjoy, like ve hate sonras?nda -ing kullanılır.',
            icon: Icons.menu_book_rounded,
            sentences: [
              'I enjoy reading.',
              'She likes swimming.',
              'He hates waiting.',
              'We love playing games.',
              'They enjoy cooking together.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_gerund_infinitive',
            titleEn: 'Verb + to + V1',
            titleTr: 'Fiil + to + V1',
            helperEn: 'Use to + V1 after want, need and decide.',
            helperTr: 'Want, need ve decide sonras?nda to + V1 kullanılır.',
            icon: Icons.task_alt_rounded,
            sentences: [
              'I want to learn English.',
              'She needs to finish her homework.',
              'We decided to stay home.',
              'He wants to borrow this book.',
              'They need to leave early.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a2_gerund_infinitive',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Ask about likes, needs and plans.',
            helperTr: 'Sevme, ihtiya� ve planlar1 sor.',
            icon: Icons.help_rounded,
            sentences: [
              'Do you enjoy reading?',
              'Do you want to borrow this one?',
              'What do you need to do today?',
              'Do you like studying at home?',
              'Did they decide to join us?'
            ]),
      ];
    case 'a1_be_verb':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_be_verb',
            titleEn: 'Identity',
            titleTr: 'Kimlik',
            helperEn: 'Say who or what someone is.',
            helperTr: 'Ki_inin kim oldu?unu s�yle.',
            icon: Icons.badge_rounded,
            sentences: [
              'I am a student.',
              'She is a doctor.',
              'They are my friends.',
              'We are classmates.',
              'He is my brother.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_be_verb',
            titleEn: 'Feelings',
            titleTr: 'Duygular',
            helperEn: 'Use be with simple feelings.',
            helperTr: 'Basit duygu c�mleleri kur.',
            icon: Icons.favorite_rounded,
            sentences: [
              'I am happy.',
              'He is tired.',
              'We are excited.',
              'They are not angry.',
              'She is nervous.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_be_verb',
            titleEn: 'Location',
            titleTr: 'Yer',
            helperEn: 'Say where people or things are.',
            helperTr: 'Ki?i veya e_yan1n nerede oldu?unu anlat.',
            icon: Icons.place_rounded,
            sentences: [
              'She is at home.',
              'We are in class.',
              'The keys are on the table.',
              'Are you at school?',
              'My phone is in my bag.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_be_verb',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Move be before the subject.',
            helperTr: 'Soruda be fiilini başa al.',
            icon: Icons.help_rounded,
            sentences: [
              'Are you ready?',
              'Is she your teacher?',
              'Are they students?',
              'Am I late?',
              'Is it cold today?'
            ]),
      ];
    case 'a1_subject_pronouns':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_subject_pronouns',
            titleEn: 'People',
            titleTr: 'Kişiler',
            helperEn: 'Use he, she, we and they instead of names.',
            helperTr: 'İsim yerine he, she, we ve they kullan.',
            icon: Icons.people_rounded,
            sentences: [
              'Ali is my friend. He is funny.',
              'Ece is here. She is ready.',
              'Ali and Ece are students. They are in class.',
              'My brother and I are at home. We are tired.',
              'You are my teacher.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_subject_pronouns',
            titleEn: 'Things and animals',
            titleTr: 'Eşyalar ve hayvanlar',
            helperEn: 'Use it for one thing and they for more than one.',
            helperTr: 'Tek şey için it, çoğul için they kullan.',
            icon: Icons.inventory_2_rounded,
            sentences: [
              'The phone is old. It works well.',
              'My keys are here. They are on the desk.',
              'The dog is sleeping. It is quiet.',
              'The books are new. They are expensive.',
              'This bag is heavy. It is black.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_subject_pronouns',
            titleEn: 'Subject position',
            titleTr: 'Özne yeri',
            helperEn: 'Put the subject pronoun before the verb.',
            helperTr: 'Özne zamirini fiilden önce kullan.',
            icon: Icons.subject_rounded,
            sentences: [
              'I am Deniz.',
              'You are late.',
              'He plays football on Sundays.',
              'She goes to school.',
              'They study English every day.'
            ]),
      ];
    case 'a1_possessive_adjectives':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_possessive_adjectives',
            titleEn: 'Owner + noun',
            titleTr: 'Sahip + isim',
            helperEn: 'Use my, your, his, her, our and their before nouns.',
            helperTr: 'İsimden önce my, your, his, her, our ve their kullan.',
            icon: Icons.backpack_rounded,
            sentences: [
              'My bag is blue.',
              'Your phone is on the table.',
              'His bike is new.',
              'Her room is clean.',
              'Their house is small.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_possessive_adjectives',
            titleEn: 'Family words',
            titleTr: 'Aile kelimeleri',
            helperEn: 'Show whose family member you mean.',
            helperTr: 'Hangi aile üyesinden bahsettiğini göster.',
            icon: Icons.family_restroom_rounded,
            sentences: [
              'My mother is a nurse.',
              'His brother is tall.',
              'Her sister is at school.',
              'Our father is kind.',
              'Their parents are teachers.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_possessive_adjectives',
            titleEn: 'Not pronouns',
            titleTr: 'Zamir değil',
            helperEn: 'A possessive adjective needs a noun after it.',
            helperTr: 'Sahiplik sıfatından sonra isim gerekir.',
            icon: Icons.key_rounded,
            sentences: [
              'This is my book.',
              'That is your chair.',
              'It is his pencil.',
              'This is her notebook.',
              'Those are our bags.'
            ]),
      ];
    case 'a1_there_is_are':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_there_is_are',
            titleEn: 'There is',
            titleTr: 'There is',
            helperEn: 'Use there is for one thing.',
            helperTr: 'Tek şey için there is kullan.',
            icon: Icons.looks_one_rounded,
            sentences: [
              'There is a bed in my room.',
              'There is a lamp on the desk.',
              'There is a park near here.',
              'There is a cafe on this street.',
              'There is a teacher in the classroom.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_there_is_are',
            titleEn: 'There are',
            titleTr: 'There are',
            helperEn: 'Use there are for plural things.',
            helperTr: 'Çoğul şeyler için there are kullan.',
            icon: Icons.format_list_numbered_rounded,
            sentences: [
              'There are two chairs.',
              'There are books on the shelf.',
              'There are many cafes.',
              'There are three boxes.',
              'There are five students in the room.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_there_is_are',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Move is or are before there.',
            helperTr: 'Soruda is veya are başa gelir.',
            icon: Icons.help_rounded,
            sentences: [
              'Is there a bank on this street?',
              'Is there a park near here?',
              'Are there any buses?',
              'Are there two chairs?',
              'Are there many students?'
            ]),
      ];
    case 'a1_present_simple':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_present_simple',
            titleEn: 'Positive habits',
            titleTr: 'Olumlu rutinler',
            helperEn: 'Daily routines and facts.',
            helperTr: 'G�nl�k rutin ve ger�ekler.',
            icon: Icons.repeat_rounded,
            sentences: [
              'I get up early.',
              'She studies English.',
              'They work on Saturdays.',
              'The bus leaves at eight.',
              'We eat breakfast at home.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_simple',
            titleEn: 'Negative routines',
            titleTr: 'Olumsuz rutinler',
            helperEn: 'Use don\'t / doesn\'t + V1.',
            helperTr: 'Don\'t / doesn\'t + V1 kullan.',
            icon: Icons.remove_circle_outline_rounded,
            sentences: [
              'I don\'t eat meat.',
              'He doesn\'t like coffee.',
              'We don\'t watch TV in the morning.',
              'She doesn\'t work on Sundays.',
              'They don\'t go to school on Sunday.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_simple',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Use do / does before the subject.',
            helperTr: 'Do / does öznenin �n�ne gelir.',
            icon: Icons.help_rounded,
            sentences: [
              'Do you live here?',
              'Does she work here?',
              'Do they play tennis?',
              'Does he like tea?',
              'Do we start at nine?'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_simple',
            titleEn: 'Frequency words',
            titleTr: 'S?kl?k kelimeleri',
            helperEn: 'Show how often something happens.',
            helperTr: 'Bir şeyin ne kadar s?k oldu?unu g�ster.',
            icon: Icons.schedule_rounded,
            sentences: [
              'I usually study at night.',
              'She often walks to school.',
              'We sometimes eat out.',
              'He never drinks coffee.',
              'They always arrive on time.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_simple',
            titleEn: 'Wh- questions',
            titleTr: 'Wh- sorular1',
            helperEn: 'Ask for information with do / does.',
            helperTr: 'Do / does ile bilgi sorusu sor.',
            icon: Icons.travel_explore_rounded,
            sentences: [
              'Where do you live?',
              'When do you study?',
              'What does she like?',
              'How do they go to school?',
              'Why do you study English?'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_simple',
            titleEn: 'Likes',
            titleTr: 'Sevme / sevmeme',
            helperEn: 'Use like, love, and hate with nouns or -ing.',
            helperTr: 'like, love, hate sonras?nda isim veya -ing kullan.',
            icon: Icons.favorite_rounded,
            sentences: [
              'I like music.',
              'She loves swimming.',
              'He hates loud music.',
              'We like playing games.',
              'They enjoy football.'
            ]),
      ];
    case 'a1_present_continuous':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_present_continuous',
            titleEn: 'Actions now',
            titleTr: '^u an olanlar',
            helperEn: 'Use am/is/are + V-ing.',
            helperTr: 'am/is/are + V-ing kullan.',
            icon: Icons.timelapse_rounded,
            sentences: [
              'I am studying now.',
              'She is reading a book.',
              'They are watching a movie.',
              'We are waiting for the bus.',
              'He is cooking dinner.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_continuous',
            titleEn: 'Temporary situations',
            titleTr: 'Ge�ici durumlar',
            helperEn: 'Around now, not forever.',
            helperTr: '^u s?ralar, kal1c1 değil.',
            icon: Icons.hotel_rounded,
            sentences: [
              'I am staying with my aunt.',
              'He is working in Izmir this week.',
              'We are learning English this month.',
              'They are living in Ankara now.',
              'She is taking a short course this week.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_continuous',
            titleEn: 'Negative and questions',
            titleTr: 'Olumsuz ve soru',
            helperEn: 'Put not after be; move be for questions.',
            helperTr: 'Not be fiilinden sonra gelir; soruda be başa gelir.',
            icon: Icons.help_rounded,
            sentences: [
              'He isn\'t listening.',
              'They aren\'t sleeping.',
              'Are you coming?',
              'Is she studying?',
              'I am not working today.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_present_continuous',
            titleEn: 'Now markers',
            titleTr: 'Zaman ipu�lar1',
            helperEn: 'Words that often point to now.',
            helperTr: '^u ana i?aret eden kelimeler.',
            icon: Icons.access_time_rounded,
            sentences: [
              'now',
              'right now',
              'at the moment',
              'today',
              'this week'
            ]),
      ];
    case 'a1_can_cant':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_can_cant',
            titleEn: 'Abilities',
            titleTr: 'Yetenekler',
            helperEn: 'Say what someone can do.',
            helperTr: 'Birinin ne yapabildi?ini s�yle.',
            icon: Icons.bolt_rounded,
            sentences: [
              'I can swim.',
              'She can play the piano.',
              'We can speak English.',
              'He can drive.',
              'They can cook dinner.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_can_cant',
            titleEn: 'Requests',
            titleTr: 'Ricalar',
            helperEn: 'Ask someone to help.',
            helperTr: 'Birinden yard1m iste.',
            icon: Icons.volunteer_activism_rounded,
            sentences: [
              'Can you help me?',
              'Can you open the door?',
              'Can you repeat that?',
              'Can you wait, please?',
              'Can you speak slowly?'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_can_cant',
            titleEn: 'Permission',
            titleTr: '0zin',
            helperEn: 'Ask if something is okay.',
            helperTr: 'Bir şeyin uygun olup olmad??n1 sor.',
            icon: Icons.verified_rounded,
            sentences: [
              'Can I sit here?',
              'Can I use your phone?',
              'Can we go now?',
              'Can I ask a question?',
              'Can we leave early?'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_can_cant',
            titleEn: 'Negative and short answers',
            titleTr: 'Olumsuz ve k1sa cevap',
            helperEn: 'Use can\'t and short replies.',
            helperTr: 'Can\'t ve k1sa cevap kullan.',
            icon: Icons.short_text_rounded,
            sentences: [
              'I can\'t drive.',
              'She can\'t come today.',
              'Yes, I can.',
              'No, she can\'t.',
              'We can\'t hear you.'
            ]),
      ];
    case 'a1_articles':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_articles',
            titleEn: 'a',
            titleTr: 'a',
            helperEn: 'One general thing before consonant sound.',
            helperTr: 'Sessiz sesle genel bir tekil isim.',
            icon: Icons.looks_one_rounded,
            sentences: [
              'I need a pen.',
              'This is a book.',
              'She has a dog.',
              'He is a student.',
              'We live in a small house.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_articles',
            titleEn: 'an',
            titleTr: 'an',
            helperEn: 'One general thing before vowel sound.',
            helperTr: 'Sesli sesle genel bir tekil isim.',
            icon: Icons.record_voice_over_rounded,
            sentences: [
              'She has an umbrella.',
              'He is an engineer.',
              'It is an old phone.',
              'I eat an apple.',
              'This is an easy question.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_articles',
            titleEn: 'the',
            titleTr: 'the',
            helperEn: 'A specific or known thing.',
            helperTr: 'Belirli veya bilinen ?ey.',
            icon: Icons.push_pin_rounded,
            sentences: [
              'The pen is blue.',
              'The dog is black.',
              'The book is on the table.',
              'Open the door, please.',
              'The teacher is in the classroom.'
            ]),
      ];
    case 'a1_singular_plural':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_singular_plural',
            titleEn: 'One thing',
            titleTr: 'Tek şey',
            helperEn: 'Use singular nouns for one person or thing.',
            helperTr: 'Tek kişi veya şey için tekil isim kullan.',
            icon: Icons.looks_one_rounded,
            sentences: [
              'This is one bag.',
              'A boy is running.',
              'One child is here.',
              'That woman is my teacher.',
              'I have one book.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_singular_plural',
            titleEn: 'Regular plurals',
            titleTr: 'Düzenli çoğullar',
            helperEn: 'Add -s or -es for many regular nouns.',
            helperTr: 'Düzenli çoğul isimlere -s veya -es ekle.',
            icon: Icons.format_list_numbered_rounded,
            sentences: [
              'These are two bags.',
              'There are three boxes.',
              'She has five pens.',
              'We need four chairs.',
              'The rooms are clean.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_singular_plural',
            titleEn: 'Irregular plurals',
            titleTr: 'Düzensiz çoğullar',
            helperEn: 'Some plural forms change completely.',
            helperTr: 'Bazı çoğul isimler tamamen değişir.',
            icon: Icons.auto_fix_high_rounded,
            sentences: [
              'Three children are here.',
              'Two women are talking.',
              'The men are at work.',
              'My feet are cold.',
              'The people are friendly.'
            ]),
      ];
    case 'a1_have_has_got':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_have_has_got',
            titleEn: 'Have got',
            titleTr: 'Have got',
            helperEn: 'Use have got with I, you, we and they.',
            helperTr: 'I, you, we ve they ile have got kullan.',
            icon: Icons.inventory_2_rounded,
            sentences: [
              'I have got a bike.',
              'You have got a pen.',
              'We have got a small house.',
              'They have got two cats.',
              'I have got two brothers.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_have_has_got',
            titleEn: 'Has got',
            titleTr: 'Has got',
            helperEn: 'Use has got with he, she and it.',
            helperTr: 'He, she ve it ile has got kullan.',
            icon: Icons.person_rounded,
            sentences: [
              'She has got a brother.',
              'He has got a car.',
              'My sister has got a bike.',
              'It has got a long tail.',
              'Ali has got a new phone.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_have_has_got',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Move have or has before the subject.',
            helperTr: 'Soruda have veya has başa gelir.',
            icon: Icons.help_rounded,
            sentences: [
              'Have you got a pen?',
              'Has she got a phone?',
              'Has he got a car?',
              'Have they got homework?',
              'Have we got enough time?'
            ]),
      ];
    case 'a1_basic_prepositions':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_basic_prepositions',
            titleEn: 'in',
            titleTr: 'in',
            helperEn: 'Inside a place or a wider time.',
            helperTr: 'Bir alan1n içinde veya geni_ zamanda.',
            icon: Icons.inbox_rounded,
            sentences: [
              'The keys are in the bag.',
              'I live in Istanbul.',
              'My birthday is in May.',
              'We are in class.',
              'There is milk in the fridge.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_basic_prepositions',
            titleEn: 'on',
            titleTr: 'on',
            helperEn: 'On a surface or on a day.',
            helperTr: 'Y�zey �st�nde veya g�nlerde.',
            icon: Icons.layers_rounded,
            sentences: [
              'The book is on the table.',
              'The picture is on the wall.',
              'We meet on Monday.',
              'My birthday is on Friday.',
              'The clock is on the wall.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_basic_prepositions',
            titleEn: 'at',
            titleTr: 'at',
            helperEn: 'A point or clock time.',
            helperTr: 'Nokta veya saat.',
            icon: Icons.schedule_rounded,
            sentences: [
              'I am at home.',
              'She is at school.',
              'The lesson starts at seven.',
              'We meet at the bus stop.',
              'He works at a cafe.'
            ]),
      ];
    case 'a1_imperatives':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_imperatives',
            titleEn: 'Classroom commands',
            titleTr: 'Sınıf yönergeleri',
            helperEn: 'Use the base verb to tell someone what to do.',
            helperTr: 'Yönerge verirken fiilin yalın halini kullan.',
            icon: Icons.school_rounded,
            sentences: [
              'Open your books.',
              'Listen carefully.',
              'Write your name.',
              'Look at page ten.',
              'Read the sentence aloud.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_imperatives',
            titleEn: 'Polite commands',
            titleTr: 'Kibar yönergeler',
            helperEn: 'Add please for a softer command.',
            helperTr: 'Daha kibar olmak için please ekle.',
            icon: Icons.volunteer_activism_rounded,
            sentences: [
              'Please sit down.',
              'Please open the window.',
              'Please wait here.',
              'Please speak slowly.',
              'Please close the door.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_imperatives',
            titleEn: 'Negative commands',
            titleTr: 'Olumsuz yönergeler',
            helperEn: 'Use do not or don\'t before the verb.',
            helperTr: 'Fiilden önce do not veya don\'t kullan.',
            icon: Icons.remove_circle_outline_rounded,
            sentences: [
              'Don\'t run.',
              'Don\'t touch that.',
              'Do not open the window.',
              'Please don\'t be late.',
              'Don\'t use your phone here.'
            ]),
      ];
    case 'a1_demonstratives':
      return const [
        _ExampleGroupData(
            lessonKey: 'a1_demonstratives',
            titleEn: 'This and that',
            titleTr: 'This ve that',
            helperEn: 'Use this for near and that for far singular things.',
            helperTr:
                'Yakındaki tekil şeyler için this, uzaktaki tekil şeyler için that kullanılır.',
            icon: Icons.swipe_rounded,
            sentences: [
              'This is one bag.',
              'That is Mert\'s bag.',
              'This book is new.',
              'That chair is broken.',
              'This is my brother\'s phone.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_demonstratives',
            titleEn: 'These and those',
            titleTr: 'These ve those',
            helperEn:
                'Use these for near plural and those for far plural things.',
            helperTr:
                'Yakındaki çoğul şeyler için these, uzaktaki çoğul şeyler için those kullanılır.',
            icon: Icons.collections_rounded,
            sentences: [
              'These are two bags.',
              'Those are my cousins.',
              'These books are new.',
              'Those shoes are cheap.',
              'These apples are fresh.'
            ]),
        _ExampleGroupData(
            lessonKey: 'a1_demonstratives',
            titleEn: 'Questions',
            titleTr: 'Sorular',
            helperEn: 'Ask about near or far people and things.',
            helperTr: 'Yakın veya uzak kişi ve şeyler hakkında soru sor.',
            icon: Icons.help_rounded,
            sentences: [
              'Is this your family?',
              'Is that your teacher?',
              'Are these your books?',
              'Are those your shoes?',
              'Who are those people?'
            ]),
      ];
  }
  return const [];
}

class _ExampleGroupCard extends StatefulWidget {
  final _ExampleGroupData group;
  final Color color;
  final bool isEnglish;

  const _ExampleGroupCard(
      {required this.group, required this.color, required this.isEnglish});

  @override
  State<_ExampleGroupCard> createState() => _ExampleGroupCardState();
}

class _ExampleGroupCardState extends State<_ExampleGroupCard>
    with AutomaticKeepAliveClientMixin<_ExampleGroupCard> {
  late bool expanded = !widget.group.lessonKey.startsWith('a1_') &&
      !widget.group.lessonKey.startsWith('a2_') &&
      widget.group.sentences.length <= 4;

  static const _expandDuration = Duration(milliseconds: 220);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, widget.color);
    final showContentSupport =
        _showTurkishContentSupport(widget.group.lessonKey, widget.isEnglish);
    final title =
        widget.group.title(showContentSupport ? widget.isEnglish : true);
    final helper =
        showContentSupport ? widget.group.helper(widget.isEnglish) : '';
    final preview =
        widget.group.sentences.isEmpty ? '' : widget.group.sentences.first;
    return RepaintBoundary(
      child: _TapScale(
        onTap: () => setState(() => expanded = !expanded),
        child: AnimatedContainer(
          duration: _expandDuration,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14, 14, 14, expanded ? 14 : 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: tokens.isLight
                  ? _grammarLightGlass(widget.color, strong: expanded)
                  : [
                      widget.color.withAlpha(expanded ? 34 : 17),
                      const Color(0xFF07111E).withAlpha(238),
                      Colors.white.withAlpha(expanded ? 12 : 5),
                    ],
            ),
            border: Border.all(
                color: tokens.isLight
                    ? _grammarGlassBorder(
                        tokens,
                        accent: widget.color,
                        strong: expanded,
                      )
                    : expanded
                        ? widget.color.withAlpha(54)
                        : tokens.border),
            boxShadow: expanded
                ? [
                    BoxShadow(
                        color: tokens.isLight
                            ? tokens.shadow
                            : widget.color.withAlpha(24),
                        blurRadius: 28,
                        offset: const Offset(0, 14))
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: _expandDuration,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      color: widget.color.withAlpha(expanded ? 28 : 18),
                      border: Border.all(
                          color: widget.color.withAlpha(expanded ? 48 : 34)),
                    ),
                    child: Icon(widget.group.icon, color: accent, size: 18),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                color: tokens.textPrimary,
                                fontSize: 14.8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.12)),
                        if (helper.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(helper,
                              style: TextStyle(
                                  color: tokens.textSecondary,
                                  fontSize: 11.7,
                                  height: 1.25,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: widget.color.withAlpha(expanded ? 22 : 12),
                      border: Border.all(color: widget.color.withAlpha(28)),
                    ),
                    child: Text(
                      '${widget.group.sentences.length}',
                      style: TextStyle(
                          color: tokens.isLight
                              ? accent
                              : Colors.white.withAlpha(210),
                          fontSize: 10.8,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 7),
                  AnimatedRotation(
                    turns: expanded ? .5 : 0,
                    duration: _expandDuration,
                    curve: Curves.easeOutCubic,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: tokens.iconSecondary, size: 22),
                  ),
                ],
              ),
              if (preview.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _ExamplePreviewStrip(
                    sentence: preview,
                    color: widget.color,
                    compact: expanded,
                  ),
                ),
              AnimatedSize(
                duration: _expandDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                clipBehavior: Clip.hardEdge,
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          children: widget.group.sentences
                              .asMap()
                              .entries
                              .map((entry) {
                            final i = entry.key;
                            final sentence = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: i == widget.group.sentences.length - 1
                                      ? 0
                                      : 10),
                              child: _ExampleSentenceTile(
                                index: i + 1,
                                sentence: sentence,
                                highlight: widget.color,
                                faded: widget.group
                                    .title(false)
                                    .toLowerCase()
                                    .contains('hata'),
                                translation: showContentSupport
                                    ? _turkishExampleTranslation(
                                        widget.group.lessonKey, sentence)
                                    : null,
                              ),
                            );
                          }).toList(growable: false),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamplePreviewStrip extends StatelessWidget {
  final String sentence;
  final Color color;
  final bool compact;

  const _ExamplePreviewStrip({
    required this.sentence,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12, compact ? 8 : 10, 12, compact ? 8 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: tokens.isLight
            ? Color.alphaBlend(
                color.withAlpha(compact ? 10 : 5), tokens.inputSurface)
            : compact
                ? color.withAlpha(10)
                : Colors.black.withAlpha(14),
        border:
            Border.all(color: compact ? color.withAlpha(28) : tokens.border),
      ),
      child: Row(
        children: [
          Icon(compact ? Icons.anchor_rounded : Icons.auto_awesome_rounded,
              color: color, size: 15),
          const SizedBox(width: 9),
          Expanded(
            child: Text(_repairMojibake(sentence),
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: compact ? tokens.textSecondary : tokens.textPrimary,
                    fontSize: compact ? 12.5 : 13.2,
                    fontWeight: FontWeight.w800,
                    height: 1.3)),
          ),
        ],
      ),
    );
  }
}

class _ExampleSentenceTile extends StatelessWidget {
  final int index;
  final String sentence;
  final Color highlight;
  final bool faded;
  final String? translation;

  const _ExampleSentenceTile({
    required this.index,
    required this.sentence,
    required this.highlight,
    required this.faded,
    this.translation,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, highlight);
    final cleanTranslation = _repairMojibake(translation?.trim() ?? '');
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? [
                  tokens.inputSurface,
                  Color.alphaBlend(
                      highlight.withAlpha(8), tokens.elevatedSurface),
                ]
              : [
                  Colors.black.withAlpha(22),
                  highlight.withAlpha(7),
                ],
        ),
        border: Border.all(
          color: tokens.isLight
              ? _grammarGlassBorder(tokens, accent: highlight)
              : tokens.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: highlight.withAlpha(18),
              border: Border.all(color: highlight.withAlpha(32)),
            ),
            child: Text('$index',
                style: TextStyle(
                    color: tokens.isLight ? accent : Colors.white,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Opacity(
              opacity: faded ? 0.75 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sentence,
                      style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 13.2,
                          fontWeight: FontWeight.w800,
                          height: 1.3)),
                  if (cleanTranslation.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      cleanTranslation,
                      style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 11.7,
                          height: 1.28,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TurkishSupportLine extends StatelessWidget {
  final String lessonKey;
  final String sentence;

  const _TurkishSupportLine({required this.lessonKey, required this.sentence});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final translation = _repairMojibake(
        _turkishExampleTranslation(lessonKey, sentence)?.trim() ?? '');
    if (translation.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        translation,
        style: TextStyle(
          color: tokens.textSecondary,
          fontSize: 11.3,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String? _turkishExampleTranslation(String lessonKey, String sentence) {
  final clean = _cleanOptionSentence(sentence);
  if (lessonKey.startsWith('a2_')) {
    final translation = _a2TurkishExampleTranslation(clean);
    return translation == null ? null : _repairMojibake(translation);
  }
  if (!lessonKey.startsWith('a1_') &&
      !_showsTurkishSentenceSupport(lessonKey)) {
    return null;
  }
  const a1DialogueTranslations = <String, String>{
    'Hi, I?m Ece. Are you new here?': 'Merhaba, ben Ece. Burada yeni misin?',
    'Yes, I am. I?m in Room 4.': 'Evet. 4 numaralı odadayım.',
    'Nice! Are you ready for class?': 'Güzel! Derse hazır mısın?',
    'Yes, I am.': 'Evet, hazırım.',
    'Is your sister at home?': 'Kız kardeşin evde mi?',
    'No, she is at school.': 'Hayır, okulda.',
    'Are your parents here?': 'Anne baban burada mı?',
    'Yes, they are in the kitchen.': 'Evet, mutfaktalar.',
    'Where is Ali?': 'Ali nerede?',
    'He is in the classroom.': 'O sınıfta.',
    'And Ay_e?': 'Peki Ayşe?',
    'She is at home.': 'O evde.',
    'Can you help me with English?':
        'İngilizce konusunda bana yardım edebilir misin?',
    'Sure. I can help you.': 'Tabii. Sana yardım edebilirim.',
    'Do you know Ali and Deniz?': 'Ali ve Deniz’i tanıyor musun?',
    'Yes, I know them.': 'Evet, onları tanıyorum.',
    'Is this your notebook?': 'Bu senin defterin mi?',
    'No, my notebook is in my bag.': 'Hayır, benim defterim çantamda.',
    'Whose notebook is this?': 'Bu kimin defteri?',
    'It is her notebook.': 'Bu onun defteri.',
    'Is this Ece?s bag?': 'Bu Ece’nin çantası mı?',
    'No, it is my sister?s bag.': 'Hayır, kız kardeşimin çantası.',
    'Where is your bag?': 'Senin çantan nerede?',
    'My bag is under the desk.': 'Çantam sıranın altında.',
    'Is there a desk in your room?': 'Odanda bir çalışma masası var mı?',
    'Yes, there is. It is small.': 'Evet, var. Küçük.',
    'Are there any shelves?': 'Hiç raf var mı?',
    'Yes, there are two shelves.': 'Evet, iki raf var.',
    'Is there a cafe near school?': 'Okulun yakınında bir kafe var mı?',
    'Yes, there is a small cafe.': 'Evet, küçük bir kafe var.',
    'Are there any buses?': 'Hiç otobüs var mı?',
    'Yes, there are many buses.': 'Evet, çok otobüs var.',
    'Can I have a coffee, please?': 'Bir kahve alabilir miyim, lütfen?',
    'Sure. Do you want an apple too?': 'Tabii. Bir elma da ister misin?',
    'No, thanks. Where is the sugar?': 'Hayır, teşekkürler. Şeker nerede?',
    'The sugar is on the table.': 'Şeker masanın üstünde.',
    'I need a notebook.': 'Bir deftere ihtiyacım var.',
    'There is an orange one here.': 'Burada turuncu bir tane var.',
    'Is the notebook cheap?': 'Defter ucuz mu?',
    'Yes, it is.': 'Evet, ucuz.',
    'How many chairs do we need?': 'Kaç sandalyeye ihtiyacımız var?',
    'We need four chairs.': 'Dört sandalyeye ihtiyacımız var.',
    'And glasses?': 'Peki bardaklar?',
    'Six glasses, please.': 'Altı bardak, lütfen.',
    'Do we need any eggs?': 'Hiç yumurtaya ihtiyacımız var mı?',
    'Yes, we need six eggs.': 'Evet, altı yumurtaya ihtiyacımız var.',
    'How much water do we need?': 'Ne kadar suya ihtiyacımız var?',
    'A lot of water, please.': 'Bol su, lütfen.',
    'What time do you get up?': 'Saat kaçta kalkıyorsun?',
    'I get up at seven.': 'Saat yedide kalkarım.',
    'Do you eat breakfast at home?': 'Kahvaltıyı evde yapar mısın?',
    'Yes, I do.': 'Evet, yaparım.',
    'What do you do after school?': 'Okuldan sonra ne yaparsın?',
    'I usually play football.': 'Genellikle futbol oynarım.',
    'Do you like reading?': 'Okumayı sever misin?',
    'Yes, I love reading comics.': 'Evet, çizgi roman okumayı çok severim.',
    'Hey, what are you doing?': 'Hey, ne yapıyorsun?',
    'I?m studying for my English quiz.':
        'İngilizce küçük sınavıma çalışıyorum.',
    'Are you studying alone?': 'Tek başına mı çalışıyorsun?',
    'No, my sister is helping me.': 'Hayır, kız kardeşim bana yardım ediyor.',
    'Who is this in the photo?': 'Fotoğraftaki bu kişi kim?',
    'That is my brother. He is running.': 'O benim erkek kardeşim. Koşuyor.',
    'And your parents?': 'Peki anne baban?',
    'They are talking near the cafe.': 'Kafenin yakınında konuşuyorlar.',
    'Can you help me with this form?':
        'Bu form için bana yardım edebilir misin?',
    'Sure, I can help you now.': 'Tabii, sana şimdi yardım edebilirim.',
    'Great. Can I ask one more question?':
        'Harika. Bir soru daha sorabilir miyim?',
    'Of course.': 'Elbette.',
    'Can you play the guitar?': 'Gitar çalabilir misin?',
    'No, I can\'t. But I can sing.':
        'Hayır, çalamam. Ama şarkı söyleyebilirim.',
    'Can your sister sing too?': 'Kız kardeşin de şarkı söyleyebilir mi?',
    'Yes, she can.': 'Evet, söyleyebilir.',
    'Have you got a pen?': 'Kalemin var mı?',
    'Yes, I have got two pens.': 'Evet, iki kalemim var.',
    'Great. Have you got your book?': 'Harika. Kitabın var mı?',
    'Yes, it is in my bag.': 'Evet, çantamda.',
    'Have you got a sister?': 'Kız kardeşin var mı?',
    'Yes, I have got one sister.': 'Evet, bir kız kardeşim var.',
    'Has she got a bike?': 'Onun bisikleti var mı?',
    'No, she hasn\'t.': 'Hayır, yok.',
    'Where is my phone?': 'Telefonum nerede?',
    'It is on the sofa.': 'Kanepenin üstünde.',
    'And my wallet?': 'Peki cüzdanım?',
    'It is in your coat.': 'Montunun içinde.',
    'When is the lesson?': 'Ders ne zaman?',
    'It is at seven.': 'Saat yedide.',
    'Is it on Monday?': 'Pazartesi mi?',
    'Yes, on Monday in Room 4.': 'Evet, pazartesi günü 4 numaralı odada.',
    'Open your books, please.': 'Kitaplarınızı açın, lütfen.',
    'Which page?': 'Hangi sayfa?',
    'Look at page ten.': 'Onuncu sayfaya bakın.',
    'Okay.': 'Tamam.',
    'Can I open the window?': 'Pencereyi açabilir miyim?',
    'Yes, open it, please.': 'Evet, lütfen aç.',
    'Can I run here?': 'Burada koşabilir miyim?',
    'No, don\'t run in the house.': 'Hayır, evin içinde koşma.',
    'Is this your family?': 'Bu senin ailen mi?',
    'Yes, this is my mother.': 'Evet, bu benim annem.',
    'Who are those people?': 'Şu insanlar kim?',
    'Those are my cousins.': 'Onlar benim kuzenlerim.',
    'Is this bag new?': 'Bu çanta yeni mi?',
    'Yes, this is new.': 'Evet, bu yeni.',
    'Are those shoes expensive?': 'Şu ayakkabılar pahalı mı?',
    'No, those shoes are cheap.': 'Hayır, o ayakkabılar ucuz.',
  };
  final a1DialogueTranslation = a1DialogueTranslations[clean];
  if (lessonKey.startsWith('a1_') && a1DialogueTranslation != null) {
    return a1DialogueTranslation;
  }
  final a2Translation = _a2TurkishExampleTranslation(clean);
  if (a2Translation != null) return a2Translation;
  const translations = <String, String>{
    'I am a student.': 'Ben bir �?renciyim.',
    'She is a doctor.': 'O bir doktor.',
    'They are my friends.': 'Onlar benim arkada_lar1m.',
    'We are classmates.': 'Biz s?n?f arkada_1y1z.',
    'I am happy.': 'Ben mutluyum.',
    'He is tired.': 'O yorgun.',
    'We are excited.': 'Biz heyecanl1y1z.',
    'They are not angry.': 'Onlar k1zg1n değil.',
    'She is at home.': 'O evde.',
    'We are in class.': 'Biz s?n?ftay1z.',
    'The keys are on the table.': 'Anahtarlar masan1n �st�nde.',
    'Are you at school?': 'Okulda m1s1n?',
    'Are you ready?': 'Haz1r m1s1n?',
    'Is she your teacher?': 'O senin �?retmenin mi?',
    'Are they students?': 'Onlar �?renci mi?',
    'Am I late?': 'Ge� mi kald1m?',
    'I get up early.': 'Erken kalkar1m.',
    'She studies English.': 'O ?ngilizce �al1_1r.',
    'They work on Saturdays.': 'Onlar cumartesileri �al1_1r.',
    'The bus leaves at eight.': 'Otob�s sekizde kalkar.',
    'I don\'t eat meat.': 'Et yemem.',
    'He doesn\'t like coffee.': 'O kahve sevmez.',
    'We don\'t watch TV in the morning.': 'Sabah televizyon izlemeyiz.',
    'She doesn\'t work on Sundays.': 'O pazar g�nleri �al1_maz.',
    'Do you live here?': 'Burada m1 ya_1yorsun?',
    'Does she work here?': 'O burada m1 �al1_1yor?',
    'Do they play tennis?': 'Onlar tenis oynar m1?',
    'Does he like tea?': 'O �ay sever mi?',
    'I usually study at night.': 'Genelde gece �al1_1r1m.',
    'She often walks to school.': 'O s?k s?k okula y�r�r.',
    'We sometimes eat out.': 'Bazen d1_ar1da yemek yeriz.',
    'He never drinks coffee.': 'O asla kahve i�mez.',
    'I am studying now.': '^u an ders �al1_1yorum.',
    'She is reading a book.': 'O kitap okuyor.',
    'They are watching a movie.': 'Onlar film izliyor.',
    'We are waiting for the bus.': 'Otob�s� bekliyoruz.',
    'I can swim.': 'Y�zebilirim.',
    'She can play the piano.': 'O piyano �alabilir.',
    'We can speak English.': '?ngilizce konu_abiliriz.',
    'He can drive.': 'O araba sürebilir.',
    'Can you help me?': 'Bana yard1m edebilir misin?',
    'Can you open the door?': 'Kap1y1 a�abilir misin?',
    'Can you repeat that?': 'Bunu tekrar edebilir misin?',
    'Can you wait, please?': 'L�tfen bekleyebilir misin?',
    'I need a pen.': 'Bir kaleme ihtiyac1m var.',
    'This is a book.': 'Bu bir kitap.',
    'She has a dog.': 'Onun bir k�pe?i var.',
    'He is a student.': 'O bir �?renci.',
    'The pen is blue.': 'Kalem mavi.',
    'The dog is black.': 'K�pek siyah.',
    'Open the door, please.': 'L�tfen kap1y1 a�.',
    'The keys are in the bag.': 'Anahtarlar �antan1n içinde.',
    'I live in Istanbul.': '?stanbul\'da ya_1yorum.',
    'My birthday is in May.': 'Do?um g�n�m may1sta.',
    'The book is on the table.': 'Kitap masan1n �st�nde.',
    'The picture is on the wall.': 'Resim duvarda.',
    'We meet on Monday.': 'Pazartesi bulu?uruz.',
    'I am at home.': 'Evdeyim.',
    'The lesson starts at seven.': 'Ders yedide ba?lar.',
  };
  const moreA1Translations = <String, String>{
    'Do you have the books?': 'Kitaplar sende mi?',
    'Has Ece got a brother?': 'Ece\'nin erkek kardeşi var mı?',
    'Has he got a bike?': 'Onun bisikleti var mı?',
    'It is in my bag.': 'Çantamda.',
    'Nice. What about their parents?': 'Güzel. Peki anne babaları?',
    'They are on the desk.': 'Masanın üstündeler.',
    'Yes, he?s working on his laptop.':
        'Evet, dizüstü bilgisayarında çalışıyor.',
    'Yes. It has an orange collar.': 'Evet. Turuncu bir tasması var.',
    'Ali and Deniz are students. They are in class.':
        'Ali ve Deniz öğrenci. Sınıftalar.',
    'A girl is drawing a picture.': 'Bir kız resim çiziyor.',
    'And my phone?': 'Peki telefonum?',
    'And those shoes?': 'Peki şu ayakkabılar?',
    'Are there buses at night?': 'Gece otobüs var mı?',
    'Are you tired?': 'Yorgun musun?',
    'Does your brother play football?': 'Erkek kardeşin futbol oynar mı?',
    'Do we meet on Monday?': 'Pazartesi buluşuyor muyuz?',
    'Don\'t touch it.': 'Ona dokunma.',
    'Do you watch the game?': 'Maçı izler misin?',
    'He hates waiting for buses.': 'Otobüs beklemekten nefret eder.',
    'He plans to borrow this book.': 'Bu kitabı ödünç almayı planlıyor.',
    'He?s sleeping in his room.': 'Odasında uyuyor.',
    'How many books do you have?': 'Kaç kitabın var?',
    'How much is this bag?': 'Bu çanta ne kadar?',
    'I can see a dog outside.': 'Dışarıda bir köpek görebiliyorum.',
    'I can try.': 'Deneyebilirim.',
    'I have a phone. The phone is old.': 'Bir telefonum var. Telefon eski.',
    'Is Ali in your class?': 'Ali senin sınıfında mı?',
    'Is her brother a student?': 'Onun erkek kardeşi öğrenci mi?',
    'Is the cafe open?': 'Kafe açık mı?',
    'Is the dog small?': 'Köpek küçük mü?',
    'Is there a cafe near here?': 'Yakınlarda bir kafe var mı?',
    'Is your dad working?': 'Baban çalışıyor mu?',
    'Is your teacher nice?': 'Öğretmenin iyi mi?',
    'It is 300 lira.': '300 lira.',
    'It is in your bag.': 'Çantanda.',
    'Look at this button.': 'Bu düğmeye bak.',
    'Maybe the dog lives near here.': 'Belki köpek yakınlarda yaşıyordur.',
    'No, I don\'t. I study English.': 'Hayır, izlemem. İngilizce çalışırım.',
    'No, I haven\'t. It is at home.': 'Hayır, yok. Evde.',
    'No, I?m okay. I?m just hungry.': 'Hayır, iyiyim. Sadece açım.',
    'No, it is my sister?s notebook.': 'Hayır, kız kardeşimin defteri.',
    'Read the sign, please.': 'Lütfen tabelayı oku.',
    'Really? Can you sing this song?':
        'Gerçekten mi? Bu şarkıyı söyleyebilir misin?',
    'She has a bag. The bag is red.': 'Onun bir çantası var. Çanta kırmızı.',
    'She is in another class.': 'O başka bir sınıfta.',
    'Six glasses are on the table.': 'Masada altı bardak var.',
    'That house is big.': 'Şu ev büyük.',
    'That is your car.': 'Şu senin araban.',
    'The shop opens at nine.': 'Dükkan dokuzda açılır.',
    'There is a desk near the window.':
        'Pencerenin yanında bir çalışma masası var.',
    'These are my keys.': 'Bunlar benim anahtarlarım.',
    'These shoes are new.': 'Bu ayakkabılar yeni.',
    'They enjoy cooking at home.': 'Evde yemek yapmaktan hoşlanırlar.',
    'Those are my friends.': 'Şunlar benim arkadaşlarım.',
    'Those are on sale.': 'Şunlar indirimde.',
    'Those books are old.': 'Şu kitaplar eski.',
    'This is my phone.': 'Bu benim telefonum.',
    'Two boxes are in the car.': 'İki kutu arabada.',
    'Wait here.': 'Burada bekle.',
    'We love playing games together.': 'Birlikte oyun oynamayı severiz.',
    'Where are my keys?': 'Anahtarlarım nerede?',
    'Where is your brother?': 'Erkek kardeşin nerede?',
    'Where is your notebook?': 'Defterin nerede?',
    'What about the boxes?': 'Peki kutular?',
    'Yes, and his school is near here.': 'Evet, onun okulu buraya yakın.',
    'Yes, at the school gate.': 'Evet, okul kapısında.',
    'Yes, but there are not many.': 'Evet, ama çok değil.',
    'Yes, he has got a blue bike.': 'Evet, onun mavi bir bisikleti var.',
    'Yes, he is. He sits near me.': 'Evet. Benim yakınımda oturuyor.',
    'Yes, he plays on Sundays.': 'Evet, pazar günleri oynar.',
    'Yes, I have three books.': 'Evet, üç kitabım var.',
    'Yes, she has got one brother.': 'Evet, bir erkek kardeşi var.',
    'Yes, she is very kind.': 'Evet, çok nazik.',
    'Yes, there is one on this street.': 'Evet, bu sokakta bir tane var.',
    'Ali and Ece are students. They are in class.':
        'Ali ve Ece öğrenci. Sınıftalar.',
    'Ali has got a new phone.': 'Ali\'nin yeni bir telefonu var.',
    'Are there many students?': 'Çok öğrenci var mı?',
    'Are there two chairs?': 'İki sandalye var mı?',
    'Are these your books?': 'Bunlar senin kitapların mı?',
    'Are those your shoes?': 'Şunlar senin ayakkabıların mı?',
    'Can we leave early?': 'Erken ayrılabilir miyiz?',
    'Can you speak slowly?': 'Yavaş konuşabilir misin?',
    'Do we start at nine?': 'Dokuzda mı başlıyoruz?',
    'Don\'t use your phone here.': 'Burada telefonunu kullanma.',
    'Ece is here. She is ready.': 'Ece burada. Hazır.',
    'Have we got enough time?': 'Yeterince zamanımız var mı?',
    'He has got a car.': 'Onun bir arabası var.',
    'He is cooking dinner.': 'Akşam yemeği yapıyor.',
    'He is my brother.': 'O benim erkek kardeşim.',
    'He works at a cafe.': 'Bir kafede çalışır.',
    'I am not working today.': 'Bugün çalışmıyorum.',
    'I have got two brothers.': 'İki erkek kardeşim var.',
    'I have one book.': 'Bir kitabım var.',
    'Is it cold today?': 'Bugün hava soğuk mu?',
    'Is that your teacher?': 'Şu senin öğretmenin mi?',
    'Is there a bank on this street?': 'Bu sokakta bir banka var mı?',
    'Is there a park near here?': 'Yakınlarda bir park var mı?',
    'It has got a long tail.': 'Uzun bir kuyruğu var.',
    'It is his pencil.': 'Bu onun kalemi.',
    'My brother and I are at home. We are tired.':
        'Erkek kardeşim ve ben evdeyiz. Yorgunuz.',
    'My birthday is on Friday.': 'Doğum günüm cuma günü.',
    'My feet are cold.': 'Ayaklarım üşüyor.',
    'My sister has got a bike.': 'Kız kardeşimin bir bisikleti var.',
    'Open your books.': 'Kitaplarınızı açın.',
    'Please close the door.': 'Lütfen kapıyı kapat.',
    'Please open the window.': 'Lütfen pencereyi aç.',
    'Please speak slowly.': 'Lütfen yavaş konuş.',
    'Please wait here.': 'Lütfen burada bekle.',
    'Read the sentence aloud.': 'Cümleyi sesli oku.',
    'She is nervous.': 'O gergin.',
    'She is taking a short course this week.':
        'Bu hafta kısa bir kursa gidiyor.',
    'That chair is broken.': 'Şu sandalye kırık.',
    'That is Mert\'s bag.': 'Şu Mert\'in çantası.',
    'That is your chair.': 'Şu senin sandalyen.',
    'That woman is my teacher.': 'Şu kadın benim öğretmenim.',
    'The books are new. They are expensive.': 'Kitaplar yeni. Pahalılar.',
    'The clock is on the wall.': 'Saat duvarda.',
    'The dog is sleeping. It is quiet.': 'Köpek uyuyor. Sessiz.',
    'The men are at work.': 'Adamlar işte.',
    'The people are friendly.': 'İnsanlar cana yakın.',
    'The rooms are clean.': 'Odalar temiz.',
    'The teacher is in the classroom.': 'Öğretmen sınıfta.',
    'Their house is small.': 'Onların evi küçük.',
    'Their parents are teachers.': 'Onların anne babası öğretmen.',
    'There are five students in the room.': 'Odada beş öğrenci var.',
    'There is a cafe on this street.': 'Bu sokakta bir kafe var.',
    'There is a teacher in the classroom.': 'Sınıfta bir öğretmen var.',
    'There is milk in the fridge.': 'Buzdolabında süt var.',
    'These apples are fresh.': 'Bu elmalar taze.',
    'These books are new.': 'Bu kitaplar yeni.',
    'They can cook dinner.': 'Akşam yemeği pişirebilirler.',
    'They don\'t go to school on Sunday.': 'Pazar günü okula gitmezler.',
    'They enjoy football.': 'Futboldan hoşlanırlar.',
    'This bag is heavy. It is black.': 'Bu çanta ağır. Siyah.',
    'This book is new.': 'Bu kitap yeni.',
    'This is an easy question.': 'Bu kolay bir soru.',
    'This is her notebook.': 'Bu onun defteri.',
    'This is my book.': 'Bu benim kitabım.',
    'This is my brother\'s phone.': 'Bu erkek kardeşimin telefonu.',
    'Those are our bags.': 'Şunlar bizim çantalarımız.',
    'Those shoes are cheap.': 'Şu ayakkabılar ucuz.',
    'We can\'t hear you.': 'Seni duyamıyoruz.',
    'We live in a small house.': 'Küçük bir evde yaşıyoruz.',
    'We meet at the bus stop.': 'Otobüs durağında buluşuruz.',
    'Why do you study English?': 'Neden İngilizce çalışıyorsun?',
    'You are late.': 'Geç kaldın.',
    'You are my teacher.': 'Sen benim öğretmenimsin.',
    'You have got a pen.': 'Bir kalemin var.',
    'A boy is running.': 'Bir �ocuk ko?uyor.',
    'A teacher helps students.': 'Bir �?retmen �?rencilere yard1m eder.',
    'Ali is my friend. He is funny.': 'Ali benim arkada_1m. O komik.',
    'Are there any buses?': 'Hi� otob�s var m1?',
    'Are there any eggs?': 'Hi� yumurta var m1?',
    'Are you coming?': 'Geliyor musun?',
    'Are you listening?': 'Dinliyor musun?',
    'Are you okay?': '?yi misin?',
    'Ay_e is my sister. She is kind.': 'Ay_e benim k1z karde_im. O nazik.',
    'Can I ask a question?': 'Bir soru sorabilir miyim?',
    'Can I have a ticket?': 'Bir bilet alabilir miyim?',
    'Can I sit here?': 'Buraya oturabilir miyim?',
    'Can I use your phone?': 'Telefonunu kullanabilir miyim?',
    'Can we go now?': '?imdi gidebilir miyiz?',
    'Cats like milk.': 'Kediler s�t sever.',
    'Do not open the window.': 'Pencereyi a�ma.',
    'Do you watch TV at night?': 'Gece televizyon izler misin?',
    'Don\'t run.': 'Ko_ma.',
    'Don\'t touch that.': 'Ona dokunma.',
    'Has he got a car?': 'Onun arabas1 var m1?',
    'Has she got a phone?': 'Onun telefonu var m1?',
    'Have they got homework?': 'Onlar1n �devi var m1?',
    'Have you got a pen?': 'Kalemin var m1?',
    'He can\'t drive.': 'Araba kullanamaz.',
    'He hates loud music.': 'Y�ksek sesli m�zikten nefret eder.',
    'He is an engineer.': 'O bir m�hendis.',
    'He is working in Izmir this week.': 'Bu hafta ?zmir\'de �al1_1yor.',
    'He isn\'t listening.': 'Dinlemiyor.',
    'He plays football on Sundays.': 'Pazar g�nleri futbol oynar.',
    'He wants an apple.': 'Bir elma istiyor.',
    'Her room is clean.': 'Onun odas1 temiz.',
    'Her sister is at school.': 'Onun k1z karde_i okulda.',
    'His bike is new.': 'Onun bisikleti yeni.',
    'His brother is tall.': 'Onun erkek karde_i uzun.',
    'How do they go to school?': 'Okula nas1l giderler?',
    'I am Deniz.': 'Ben Deniz.',
    'I am coming now.': '?imdi geliyorum.',
    'I am staying with my aunt.': 'Teyzemde kal1yorum.',
    'I am working right now.': '^u anda �al1_1yorum.',
    'I can help you.': 'Sana yard1m edebilirim.',
    'I can\'t drive.': 'Araba kullanamam.',
    'I drink a lot of water.': 'çok su i�erim.',
    'I eat an apple.': 'Bir elma yerim.',
    'I have got a bike.': 'Bir bisikletim var.',
    'I have two books.': '?ki kitab1m var.',
    'I like music.': 'M�zik severim.',
    'I like tea.': '�ay severim.',
    'I see a dog. The dog is small.': 'Bir k�pek g�r�yorum. K�pek k���k.',
    'I study at night.': 'Gece ders �al1_1r1m.',
    'I wake up at seven.': 'Yedide uyan1r1m.',
    'Is she studying?': 'Ders �al1_1yor mu?',
    'It is Ece?s pen.': 'Bu Ece?nin kalemi.',
    'It is an old phone.': 'Bu eski bir telefon.',
    'Listen carefully.': 'Dikkatlice dinle.',
    'My bag is blue.': '�antam mavi.',
    'My birthday is in June.': 'Do?um g�n�m haziranda.',
    'My keys are here. They are on the desk.':
        'Anahtarlar1m burada. Masan1n �st�nde.',
    'My mother is a nurse.': 'Annem hem_ire.',
    'My parents are here. They are happy.': 'Ailem burada. Mutlular.',
    'My phone is in my bag.': 'Telefonum �antamda.',
    'No, she can\'t.': 'Hay1r, yapamaz.',
    'One child is here.': 'Bir �ocuk burada.',
    'Open the door.': 'Kap1y1 a�.',
    'Our father is kind.': 'Babam1z nazik.',
    'Please don\'t be late.': 'L�tfen ge� kalma.',
    'Please sit down.': 'L�tfen otur.',
    'She can\'t come today.': 'Bug�n gelemez.',
    'She does not drink coffee.': 'Kahve i�mez.',
    'She goes to school.': 'Okula gider.',
    'She has an umbrella.': 'Onun bir _emsiyesi var.',
    'She has five pens.': 'Be_ kalemi var.',
    'She has got a brother.': 'Bir erkek karde_i var.',
    'She is at school.': 'Okulda.',
    'She is in class.': 'S?n?fta.',
    'She is my teacher.': 'O benim �?retmenim.',
    'She knows him.': 'Onu tan1yor.',
    'She loves swimming.': 'Y�zmeyi sever.',
    'That is Mert?s bag.': 'O Mert?in �antas1.',
    'The children are playing.': '�ocuklar oynuyor.',
    'The dog is sleeping.': 'K�pek uyuyor.',
    'The phone is old. It works well.': 'Telefon eski. ?yi �al1_1yor.',
    'The sun rises in the morning.': 'G�ne_ sabah do?ar.',
    'There are books on the shelf.': 'Rafta kitaplar var.',
    'There are many cafes.': 'çok kafe var.',
    'There are three boxes.': '�� kutu var.',
    'There are two chairs.': '?ki sandalye var.',
    'There is a bank on this street.': 'Bu sokakta bir banka var.',
    'There is a bed in my room.': 'Odamda bir yatak var.',
    'There is a cafe. The cafe is open.': 'Bir kafe var. Kafe a�1k.',
    'There is a lamp on the desk.': 'Masan1n �st�nde bir lamba var.',
    'There is a park near here.': 'Buralarda bir park var.',
    'There is some milk.': 'Biraz s�t var.',
    'These are two bags.': 'Bunlar iki �anta.',
    'They are excited.': 'Heyecanl1lar.',
    'They are living in Ankara now.': '?imdi Ankara\'da ya_1yorlar.',
    'They are watching TV.': 'Televizyon izliyorlar.',
    'They aren\'t sleeping.': 'Uyumuyorlar.',
    'They have got two cats.': '?ki kedileri var.',
    'They study English every day.': 'Her g�n ?ngilizce �al1_1rlar.',
    'This bag is new. It is black.': 'Bu �anta yeni. Siyah.',
    'This is a book. The book is new.': 'Bu bir kitap. Kitap yeni.',
    'This is my brother?s phone.': 'Bu erkek karde_imin telefonu.',
    'This is one bag.': 'Bu bir �anta.',
    'Three children are here.': '�� �ocuk burada.',
    'Two women are talking.': '?ki kad1n konu?uyor.',
    'Water boils at 100 degrees.': 'Su 100 derecede kaynar.',
    'We are at school.': 'Okulday1z.',
    'We are eating lunch.': '�?le yeme?i yiyoruz.',
    'We are in the room.': 'Odaday1z.',
    'We are learning English this month.': 'Bu ay ?ngilizce �?reniyoruz.',
    'We eat breakfast at home.': 'Kahvalt1y1 evde yapar1z.',
    'We have got a small house.': 'K���k bir evimiz var.',
    'We like playing games.': 'Oyun oynamay1 severiz.',
    'We like them.': 'Onlar1 severiz.',
    'We need four chairs.': 'D�rt sandalyeye ihtiyac1m1z var.',
    'We need many apples.': 'çok elmaya ihtiyac1m1z var.',
    'What does she like?': 'O ne sever?',
    'When do you study?': 'Ne zaman ders �al1_1rs1n?',
    'Where do you live?': 'Nerede ya_1yorsun?',
    'Whose pen is this?': 'Bu kimin kalemi?',
    'Write your name.': 'Ad1n1 yaz.',
    'Yes, I can.': 'Evet, yapabilirim.',
    'Your phone is on the table.': 'Telefonun masan1n �st�nde.',
    'at the moment': '?u anda',
    'now': '_imdi',
    'right now': 'tam ?u anda',
    'this week': 'bu hafta',
    'today': 'bug�n',
  };
  final translation = translations[clean] ?? moreA1Translations[clean];
  return translation == null ? null : _repairMojibake(translation);
}

bool _showsTurkishSentenceSupport(String lessonKey) =>
    !_isA1A2LessonKey(lessonKey);

String? _a2TurkishExampleTranslation(String clean) {
  const translations = <String, String>{
    'I watched a movie last night.': 'D�n gece film izledim.',
    'We visited my uncle yesterday.': 'D�n amcam1 ziyaret ettik.',
    'She cleaned her room.': 'Odas1n1 temizledi.',
    'They played football after school.': 'Okuldan sonra futbol oynad1lar.',
    'He cooked dinner at home.': 'Evde ak?am yeme?i yapt1.',
    'Did you call your teacher?': '�?retmenini arad1n m1?',
    'Where did you go yesterday?': 'D�n nereye gittin?',
    'What did you eat for breakfast?': 'Kahvalt1da ne yedin?',
    'Did they arrive on time?': 'Zamanında geldiler mi?',
    'When did the lesson start?': 'Ders ne zaman ba_lad1?',
    'I moved here in 2020.': 'Buraya 2020 y1l1nda ta_1nd1m.',
    'We met two days ago.': '?ki g�n �nce bulu_tuk.',
    'I visited my aunt yesterday.': 'D�n teyzemi ziyaret ettim.',
    'She went to Ankara last week.': 'Ge�en hafta Ankara\'ya gitti.',
    'We did not watch TV.': 'Televizyon izlemedik.',
    'Did you finish your homework?': '�devini bitirdin mi?',
    'They arrived late.': 'Ge� geldiler.',
    'I will open the window.': 'Pencereyi a�aca?1m.',
    'I will answer the phone.': 'Telefona cevap verece?im.',
    'We will take a taxi.': 'Taksiye binece?iz.',
    'I will help you with the bags.': '�antalar için sana yard1m edece?im.',
    'I will call you tonight.': 'Bu gece seni arayaca?1m.',
    'I think it will rain tomorrow.': 'Bence yar1n ya?mur ya?acak.',
    'Will you call me tonight?': 'Bu gece beni arayacak m1s1n?',
    'I am going to study tonight.': 'Bu gece ders �al1_aca?1m.',
    'She is going to visit her aunt.': 'Teyzesini ziyaret edecek.',
    'We are going to start soon.': 'Yak1nda ba_layaca?1z.',
    'It is going to rain.': 'Ya?mur ya?acak gibi.',
    'Are you going to buy it?': 'Onu sat1n alacak m1s1n?',
    'What are you going to do tonight?': 'Bu gece ne yapacaks1n?',
    'This bag is cheaper than that one.': 'Bu �anta ondan daha ucuz.',
    'The train is faster than the bus.': 'Tren otob�sten daha h1zl1.',
    'Kayseri is colder than Antalya.': 'Kayseri Antalya\'dan daha so?uk.',
    'This exercise is more difficult than the last one.':
        'Bu al1_t1rma �ncekinden daha zor.',
    'My phone is better than my old phone.':
        'Telefonum eski telefonumdan daha iyi.',
    'She is the tallest student in the class.': 'O s?n?ftaki en uzun �?renci.',
    'This is the best restaurant in town.': 'Bu _ehirdeki en iyi restoran.',
    'This is the most useful lesson.': 'Bu en yararl1 ders.',
    'Monday is the busiest day for me.': 'Pazartesi benim için en yo?un g�n.',
    'We need some eggs.': 'Biraz yumurtaya ihtiyac1m1z var.',
    'There is not much milk left.': 'Fazla s�t kalmad1.',
    'I want a few apples.': 'Birka� elma istiyorum.',
    'We have a lot of rice.': 'çok pirincimiz var.',
    'Do we need any bread?': 'Hi� ekme?e ihtiyac1m1z var m1?',
    'How much water do you drink?': 'Ne kadar su i�ersin?',
    'How many chairs are there?': 'Ka� sandalye var?',
    'I need a little water.': 'Biraz suya ihtiyac1m var.',
    'There are many chairs in the room.': 'Odada çok sandalye var.',
    'You should drink water.': 'Su i�melisin.',
    'You should drink more water.': 'Daha fazla su i�melisin.',
    'You should see a doctor.': 'Bir doktora g�r�nmelisin.',
    'You should rest today.': 'Bug�n dinlenmelisin.',
    'You should review your notes.': 'Notlar1n1 g�zden ge�irmelisin.',
    'You should not sleep late.': 'Ge� uyumamal1s1n.',
    'Should I call her now?': 'Onu _imdi aramal1 m1y1m?',
    'What should I wear?': 'Ne giymeliyim?',
    'You must wear a seat belt.': 'Emniyet kemeri takmal1s1n.',
    'Students must be quiet in the library.':
        '�?renciler k�t�phanede sessiz olmal1.',
    'I have to finish my homework.': '�devimi bitirmem gerekiyor.',
    'She has to wake up early.': 'Erken kalkmas1 gerekiyor.',
    'You do not have to come early.': 'Erken gelmek zorunda değilsin.',
    'You must not smoke here.': 'Burada sigara i�memelisin.',
    'I can help you.': 'Sana yard1m edebilirim.',
    'She knows him.': 'Onu tan1yor.',
    'We like them.': 'Onlar1 seviyoruz.',
    'This book is mine.': 'Bu kitap benim.',
    'That phone is yours.': 'O telefon senin.',
    'The blue bag is hers.': 'Mavi �anta onun.',
    'These seats are ours.': 'Bu koltuklar bizim.',
    'The red bikes are theirs.': 'K1rm1z1 bisikletler onlar1n.',
    'I usually walk to school.': 'Genellikle okula y�r�r�m.',
    'She speaks slowly.': 'O yava_ konu?ur.',
    'He drives carefully.': 'O dikkatli araba kullan1r.',
    'My sister speaks English well.': 'K1z karde_im iyi ?ngilizce konu?ur.',
    'Do you usually walk to school?': 'Genellikle okula y�r�r m�s�n?',
    'How often do you study English?': 'Ne s?kl?kla ?ngilizce �al1_1rs1n?',
    'I went to the shop to buy bread.': 'Ekmek almak için d�kkana gittim.',
    'She went to the library to study.':
        'Ders �al1_mak için k�t�phaneye gitti.',
    'We came here to meet you.': 'Seninle bulu_mak için buraya geldik.',
    'I use my phone to check emails.':
        'E-postalar1 kontrol etmek için telefonumu kullan1r1m.',
    'Why did you go to the shop?': 'D�kkana neden gittin?',
    'I enjoy reading comics.': '�izgi roman okumaktan ho_lan1r1m.',
    'She likes swimming in summer.': 'Yaz1n y�zmeyi sever.',
    'I want to learn English.': '?ngilizce �?renmek istiyorum.',
    'She needs to finish her homework.': '�devini bitirmesi gerekiyor.',
    'Do you enjoy reading?': 'Okumaktan ho_lan1r m1s1n?',
    'Do you want to borrow this one?': 'Bunu �d�n� almak ister misin?',
  };
  const moreTranslations = <String, String>{
    'There are five students in the class.': 'S?n?fta be_ �?renci var.',
    'Are there any buses at night?': 'Gece hi� otob�s var m1?',
    'Are there many buses at night?': 'Gece çok otob�s var m1?',
    'Are they going to stay here?': 'Burada kalacaklar m1?',
    'Are we going to start now?': '?imdi ba_layacak m1y1z?',
    'Are you ever late?': 'Hi� ge� kalır m1s1n?',
    'Be careful. The glass is going to fall.': 'Dikkatli ol. Bardak d�_ecek.',
    'Can you help me?': 'Bana yard1m edebilir misin?',
    'Did he study to pass the exam?': 'S?nav1 ge�mek için �al1_t1 m1?',
    'Did she come early to study?': 'Ders �al1_mak için erken mi geldi?',
    'Did she send the email?': 'E-postay1 g�nderdi mi?',
    'Did they decide to join us?': 'Bize kat1lmaya karar verdiler mi?',
    'Did you call to ask a question?': 'Soru sormak için mi arad1n?',
    'Do we have any eggs?': 'Hi� yumurtam1z var m1?',
    'Do you have any money?': 'Hi� paran var m1?',
    'Do you have any notes from the lesson?': 'Dersten hi� notun var m1?',
    'Do you like studying at home?': 'Evde ders �al1_may1 sever misin?',
    'Does she speak quickly?': 'O h1zl1 konu?ur mu?',
    'Give it to him.': 'Onu ona ver.',
    'He bought this phone last week.': 'Bu telefonu ge�en hafta ald1.',
    'He did not eat breakfast.': 'Kahvalt1 yapmad1.',
    'He does not have to stay after class.':
        'Dersten sonra kalmak zorunda değil.',
    'He does not have to wear a uniform.': '�niforma giymek zorunda değil.',
    'He has to show his ID.': 'Kimli?ini g�stermesi gerekiyor.',
    'He has to work tomorrow.': 'Yar1n �al1_mas1 gerekiyor.',
    'He hates waiting.': 'Beklemekten nefret eder.',
    'He is not going to come.': 'Gelmeyecek.',
    'He is the youngest in his family.': 'Ailesindeki en gen� kişi o.',
    'He never drinks coffee.': 'O asla kahve i�mez.',
    'He should apologize.': '�z�r dilemeli.',
    'He should ask for help.': 'Yard1m istemeli.',
    'He should not spend all his money.': 'T�m paras1n1 harcamamal1.',
    'He started school in September.': 'Okula eyl�lde ba_lad1.',
    'He took a taxi to be on time.': 'Zamanında olmak için taksiye bindi.',
    'He wants to borrow this book.': 'Bu kitab1 �d�n� almak istiyor.',
    'He went outside to call his mother.': 'Annesini aramak için d1_ar1 �1kt1.',
    'Her room is bigger than mine.': 'Onun odas1 benimkinden daha b�y�k.',
    'How carefully does he drive?': 'Ne kadar dikkatli araba kullan1r?',
    'How many apples are there?': 'Ka� elma var?',
    'How much milk do we need?': 'Ne kadar s�te ihtiyac1m1z var?',
    'I am not going to watch TV.': 'Televizyon izlemeyece?im.',
    'I called Deniz to ask a question.': 'Soru sormak için Deniz?i arad1m.',
    'I can help you after class.': 'Dersten sonra sana yard1m edebilirim.',
    'I cleaned my room yesterday.': 'D�n odam1 temizledim.',
    'I did not leave my keys at home.': 'Anahtarlar1m1 evde b1rakmad1m.',
    'I enjoy reading.': 'Okumaktan ho_lan1r1m.',
    'I have a few apples.': 'Birka� elmam var.',
    'I have a lot of homework tonight.': 'Bu gece çok �devim var.',
    'I think it will snow.': 'Bence kar ya?acak.',
    'I will not tell anyone.': 'Kimseye s�ylemeyece?im.',
    'I will send the file now.': 'Dosyay1 _imdi g�nderece?im.',
    'I will take them to her.': 'Onlar1 ona g�t�rece?im.',
    'I will take them.': 'Onlar1 alaca?1m.',
    'Is she going to call you?': 'Seni arayacak m1?',
    'Is she going to join us?': 'Bize kat1lacak m1?',
    'Is there much bread?': 'çok ekmek var m1?',
    'Is there much traffic today?': 'Bug�n çok trafik var m1?',
    'Is this notebook yours?': 'Bu defter senin mi?',
    'It is the best cafe near school.': 'Okul yak?n1ndaki en iyi kafe.',
    'It is the cheapest cafe near school.': 'Okul yak?n1ndaki en ucuz kafe.',
    'It is the coldest city in the region.': 'B�lgedeki en so?uk _ehir.',
    'It will be cold tonight.': 'Bu gece hava so?uk olacak.',
    'Look at the clouds. It is going to rain.':
        'Bulutlara bak. Ya?mur ya?acak.',
    'Maybe they will arrive soon.': 'Belki yak?nda gelirler.',
    'Maybe you should eat something warm.': 'Belki s1cak bir ?ey yemelisin.',
    'Mine is in my bag.': 'Benimki �antamda.',
    'Mount Everest is the highest mountain in the world.':
        'Everest d�nyan1n en y�ksek da?1d1r.',
    'My father bought a new phone.': 'Babam yeni bir telefon ald1.',
    'My house is farther from school than yours.':
        'Benim evim okula seninkinden daha uzak.',
    'My room is bigger than my brother?s room.':
        'Benim odam erkek karde_imin odas1ndan daha b�y�k.',
    'My sister is going to call you after dinner.':
        'K1z karde_im yemekten sonra seni arayacak.',
    'My sister is going to call you.': 'K1z karde_im seni arayacak.',
    'Please write clearly.': 'L�tfen anla_1l1r _ekilde yaz.',
    'She asked a few questions.': 'Birka� soru sordu.',
    'She called me last night.': 'D�n gece beni arad1.',
    'She did not call me yesterday.': 'D�n beni aramad1.',
    'She does not have to bring food.': 'Yiyecek getirmek zorunda değil.',
    'She has a lot of homework.': 'Onun çok �devi var.',
    'She is going to visit her aunt this weekend.':
        'Bu hafta sonu teyzesini ziyaret edecek.',
    'She is not going to join us.': 'Bize kat1lmayacak.',
    'She is the best player on the team.': 'Tak1mdaki en iyi oyuncu o.',
    'She is the most careful driver I know.': 'Tan1d1?1m en dikkatli s�r�c� o.',
    'She knows him well.': 'Onu iyi tan1yor.',
    'She learned to swim when she was a child.': '�ocukken y�zmeyi �?rendi.',
    'She likes swimming.': 'Y�zmeyi sever.',
    'She looks tired. She is going to sleep soon.':
        'Yorgun g�r�n�yor. Yak1nda uyuyacak.',
    'She often studies after dinner.': 'Yemekten sonra s?k s?k ders �al1_1r.',
    'She opened the window to get fresh air.':
        'Temiz hava almak için pencereyi a�t1.',
    'She should eat more fruit.': 'Daha fazla meyve yemeli.',
    'She should not drive so fast.': 'O kadar h1zl1 araba kullanmamal1.',
    'She will ask the teacher.': '�?retmene soracak.',
    'She will bring your book tomorrow.': 'Yar1n kitab1n1 getirecek.',
    'She will like this song.': 'Bu _ark1y1 sevecek.',
    'Should he tell his parents?': 'Ailesine s�ylemeli mi?',
    'Should he tell the teacher?': '�?retmene s�ylemeli mi?',
    'Should we take a taxi?': 'Taksiye binmeli miyiz?',
    'That shop has the most delicious cakes.':
        'O d�kkanda en lezzetli pastalar var.',
    'That was the most exciting match of all.':
        'Bu hepsinin en heyecanl1 ma�1yd1.',
    'That was the most expensive meal on the menu.':
        'Men�deki en pahal1 yemek oydu.',
    'That was the worst day of the trip.': 'Gezinin en k�t� g�n�yd�.',
    'The black phone is more expensive than the blue one.':
        'Siyah telefon mavi telefondan daha pahal1.',
    'The bus is a little cheaper than the train.':
        'Otob�s trenden biraz daha ucuz.',
    'The bus is slower than the train.': 'Otob�s trenden daha yava_.',
    'The city center is busier than my neighborhood.':
        '^ehir merkezi mahallemden daha kalabal1k.',
    'The new app is more helpful than the old app.':
        'Yeni uygulama eski uygulamadan daha faydal1.',
    'The park is cleaner than the street.': 'Park sokaktan daha temiz.',
    'The red dress is more expensive than the blue one.':
        'K1rm1z1 elbise mavi elbiseden daha pahal1.',
    'The sky is dark. It is going to snow.': 'G�ky�z� karanl1k. Kar ya?acak.',
    'The small cafe has the best tea.': 'K���k kafede en iyi �ay var.',
    'The small laptop is lighter than the old one.':
        'K���k diz�st� bilgisayar eskisinden daha hafif.',
    'The taxi is more comfortable than the bus.': 'Taksi otob�sten daha rahat.',
    'The teacher called us.': '�?retmen bizi �a?1rd1.',
    'The team is playing badly. They are going to lose.':
        'Tak1m k�t� oynuyor. Kaybedecekler.',
    'The test will be easy.': 'S?nav kolay olacak.',
    'The test will probably be easy.': 'S?nav muhtemelen kolay olacak.',
    'The traffic is terrible. We are going to be late.':
        'Trafik çok k�t�. Ge� kalaca?1z.',
    'The weather is worse than yesterday.': 'Hava d�nk�nden daha k�t�.',
    'There are many students in the room.': 'Odada çok �?renci var.',
    'There is some bread on the table.': 'Masada biraz ekmek var.',
    'They always arrive on time.': 'Onlar her zaman zamanında gelir.',
    'They are going to travel next month.': 'Gelecek ay seyahat edecekler.',
    'They are going to travel next summer.': 'Gelecek yaz seyahat edecekler.',
    'They are not going to buy a car.': 'Araba almayacaklar.',
    'They did not stay long.': 'Uzun süre kalmad1lar.',
    'They do not have to finish it tonight.':
        'Bunu bu gece bitirmek zorunda değiller.',
    'They do not have to stay after class.':
        'Dersten sonra kalmak zorunda değiller.',
    'They enjoy cooking together.': 'Birlikte yemek yapmaktan ho_lan1rlar.',
    'They have to wear a uniform.': '�niforma giymeleri gerekiyor.',
    'They have to work tomorrow.': 'Yar1n �al1_malar1 gerekiyor.',
    'They need to leave early.': 'Erken ayr1lmalar1 gerekiyor.',
    'They played tennis on Sunday.': 'Pazar g�n� tenis oynad1lar.',
    'They should not be noisy here.': 'Burada g�r�lt� yapmamal1lar.',
    'They travelled to Istanbul to see friends.':
        'Arkada_lar1n1 g�rmek için ?stanbul?a seyahat ettiler.',
    'They travelled to Izmir last summer.':
        'Ge�en yaz ?zmir?e seyahat ettiler.',
    'They will arrive at six.': 'Saat alt1da varacaklar.',
    'They worked quietly.': 'Sessizce �al1_t1lar.',
    'This answer is better than the first one.': 'Bu cevap ilkinden daha iyi.',
    'This answer is worse than the first one.': 'Bu cevap ilkinden daha k�t�.',
    'This book is more useful than that one.': 'Bu kitap ondan daha faydal1.',
    'This cafe is better than the old cafe.': 'Bu kafe eski kafeden daha iyi.',
    'This cafe is quieter than the old cafe.':
        'Bu kafe eski kafeden daha sessiz.',
    'This film is more interesting than the first film.':
        'Bu film ilk filmden daha ilgin�.',
    'This gift is for us.': 'Bu hediye bizim için.',
    'This is the easiest exercise today.': 'Bu bug�n�n en kolay al1_t1rmas1.',
    'This is the longest river in the country.': 'Bu �lkedeki en uzun nehir.',
    'This is the most beautiful park in town.': 'Bu _ehirdeki en g�zel park.',
    'This is the most interesting story.': 'Bu en ilgin� hikaye.',
    'This is the most useful rule in the lesson.':
        'Bu dersteki en faydal1 kural.',
    'This is the smallest room in the hotel.': 'Bu oteldeki en k���k oda.',
    'This is the worst answer in the group.': 'Bu gruptaki en k�t� cevap.',
    'This jacket is warmer than mine.':
        'Bu ceket benimkinden daha s1cak tutuyor.',
    'This park is the quietest place here.': 'Bu park buradaki en sessiz yer.',
    'This route is much longer than the other one.':
        'Bu rota di?erinden çok daha uzun.',
    'This was the worst day of the trip.': 'Bu gezinin en k�t� g�n�yd�.',
    'Those books are not ours.': 'O kitaplar bizim değil.',
    'Today is hotter than yesterday.': 'Bug�n d�nden daha s1cak.',
    'Visitors must show their ID.': 'Ziyaret�iler kimliklerini g�stermeli.',
    'Visitors must use this door.': 'Ziyaret�iler bu kap1y1 kullanmal1.',
    'Walking is slower than taking the metro.':
        'Y�r�mek metroya binmekten daha yava_.',
    'We are not going to stay here.': 'Burada kalmayaca?1z.',
    'We decided to stay home.': 'Evde kalmaya karar verdik.',
    'We do not have much time.': 'çok zaman1m1z yok.',
    'We do not have to pay today.': 'Bug�n �deme yapmak zorunda değiliz.',
    'We have to clean the classroom.': 'S?n?f1 temizlememiz gerekiyor.',
    'We like them a lot.': 'Onlar1 çok seviyoruz.',
    'We love playing games.': 'Oyun oynamay1 çok severiz.',
    'We moved here two years ago.': 'Buraya iki y1l �nce ta_1nd1k.',
    'We must turn off our phones.': 'Telefonlar1m1z1 kapatmal1y1z.',
    'We need three bottles of water.': '�� _i_e suya ihtiyac1m1z var.',
    'We saved money to buy a bike.': 'Bisiklet almak için para biriktirdik.',
    'We should check the homework.': '�devi kontrol etmeliyiz.',
    'We should leave early.': 'Erken ayr1lmal1y1z.',
    'We sometimes eat out.': 'Bazen d1_ar1da yemek yeriz.',
    'We will wait for you.': 'Seni bekleyece?iz.',
    'What are you going to do?': 'Ne yapacaks1n?',
    'What did you buy to make dinner?': 'Ak_am yeme?i yapmak için ne ald1n?',
    'What did you do yesterday?': 'D�n ne yapt1n?',
    'What do you need to do today?': 'Bug�n ne yapman gerekiyor?',
    'When are we going to leave?': 'Ne zaman ayr1laca?1z?',
    'Where did he go after school?': 'Okuldan sonra nereye gitti?',
    'Where should we meet?': 'Nerede bulu_mal1y1z?',
    'Why did she come early?': 'Neden erken geldi?',
    'Will it rain tomorrow?': 'Yar1n ya?mur ya?acak m1?',
    'Will she help us?': 'Bize yard1m edecek mi?',
    'Will they arrive soon?': 'Yak1nda varacaklar m1?',
    'Will we need tickets?': 'Bilete ihtiyac1m1z olacak m1?',
    'You must show your ticket.': 'Biletini g�stermelisin.',
    'You should ask the teacher.': '�?retmene sormal1s1n.',
    'You should check your answers.': 'Cevaplar1n1 kontrol etmelisin.',
    'You should not skip breakfast.': 'Kahvalt1y1 atlamamal1s1n.',
    'You should not study all night.': 'B�t�n gece ders �al1_mamal1s1n.',
    'You should practise before the test.': 'S?navdan �nce pratik yapmal1s1n.',
    'You should study before the test.': 'S?navdan �nce ders �al1_mal1s1n.',
    'A little milk is enough.': 'Biraz s�t yeterli.',
    'And who is the youngest?': 'Peki en gen� kim?',
    'Are you going to stay there?': 'Orada kalacak m1s1n?',
    'Are you going to take an umbrella?': '^emsiye alacak m1s1n?',
    'But the black one is bigger.': 'Ama siyah olan daha b�y�k.',
    'Can you help us after class?': 'Dersten sonra bize yard1m edebilir misin?',
    'Deniz is the tallest.': 'Deniz en uzun.',
    'Did he answer?': 'Cevap verdi mi?',
    'Did you buy milk too?': 'S�t de ald1n m1?',
    'Did you like it?': 'Onu be?endin mi?',
    'Did you stay long?': 'Uzun süre kald1n m1?',
    'Did you watch the film last night?': 'D�n gece filmi izledin mi?',
    'Do we have to turn off our phones?':
        'Telefonlar1m1z1 kapatmam1z gerekiyor mu?',
    'Do you have to work tomorrow?': 'Yar1n �al1_man gerekiyor mu?',
    'Great, I will take them.': 'Harika, onlar1 alaca?1m.',
    'I agree.': 'Kat1l1yorum.',
    'I am going to visit my cousins.': 'Kuzenlerimi ziyaret edece?im.',
    'I am worried about the test.': 'S?nav için endi_eliyim.',
    'I called him to ask a question.': 'Soru sormak için onu arad1m.',
    'I have a headache.': 'Ba_1m a?r1yor.',
    'I need to finish my homework.': '�devimi bitirmem gerekiyor.',
    'I think Ali is the youngest.': 'Bence Ali en gen�.',
    'I think it will rain soon.': 'Bence yak?nda ya?mur ya?acak.',
    'I visited my aunt.': 'Teyzemi ziyaret ettim.',
    'I went there to buy bread.': 'Oraya ekmek almak için gittim.',
    'I will carry it for you.': 'Onu senin için ta_1yaca?1m.',
    'Is it the cheapest too?': 'O da en ucuz mu?',
    'Is the train faster than the bus?': 'Tren otob�sten daha h1zl1 m1?',
    'Look at the sky.': 'G�ky�z�ne bak.',
    'Look at those clouds.': '^u bulutlara bak.',
    'Maybe it is Deniz\'s.': 'Belki Deniz?indir.',
    'Maybe. I will check the weather.':
        'Belki. Hava durumunu kontrol edece?im.',
    'Must you wear a uniform?': '�niforma giymen _art m1?',
    'No, I am going to come back at night.': 'Hay1r, gece geri d�nece?im.',
    'No, I am never late.': 'Hay1r, asla ge� kalmam.',
    'No, I came home early.': 'Hay1r, eve erken geldim.',
    'No, but it has the best tea.': 'Hay1r, ama en iyi �ay onda.',
    'No, but there is a lot of rice.': 'Hay1r, ama çok pirin� var.',
    'No, mine is in my bag.': 'Hay1r, benimki �antamda.',
    'No, she speaks slowly and clearly.': 'Hay1r, yava_ ve anla_1l1r konu?ur.',
    'No, you should sleep early.': 'Hay1r, erken uyumal1s1n.',
    'Okay, teacher.': 'Tamam �?retmenim.',
    'Should I go home?': 'Eve gitmeli miyim?',
    'Should I study all night?': 'B�t�n gece ders �al1_mal1 m1y1m?',
    'Sure, I can help you.': 'Elbette, sana yard1m edebilirim.',
    'Sure, I will wait.': 'Tabii, bekleyece?im.',
    'Thanks. She practices carefully.': 'Te_ekk�rler. Dikkatli pratik yap?yor.',
    'Thanks. Will you wait here?': 'Te_ekk�rler. Burada bekleyecek misin?',
    'The blue one is cheaper.': 'Mavi olan daha ucuz.',
    'The small one is the best.': 'K���k olan en iyisi.',
    'Then the bus is better for us.': 'O zaman otob�s bizim için daha iyi.',
    'There are a few apples.': 'Birka� elma var.',
    'These books are theirs.': 'Bu kitaplar onlar1n.',
    'This bag is heavy.': 'Bu �anta a?1r.',
    'True. It is more useful too.': 'Doğru. O daha faydal1 da.',
    'What are you going to do on Saturday?': 'Cumartesi ne yapacaks1n?',
    'Which bag do you like?': 'Hangi �antay1 be?eniyorsun?',
    'Which cafe is the best near school?':
        'Okul yak?n1ndaki en iyi kafe hangisi?',
    'Who is the tallest student?': 'En uzun �?renci kim?',
    'Why did you call Deniz?': 'Deniz?i neden arad1n?',
    'Will we cancel the picnic?': 'Pikni?i iptal edecek miyiz?',
    'Yes, I am.': 'Evet.',
    'Yes, I bought milk to make coffee.': 'Evet, kahve yapmak için s�t ald1m.',
    'Yes, I can give it to him.': 'Evet, onu ona verebilirim.',
    'Yes, I enjoy reading comics.': 'Evet, �izgi roman okumaktan ho_lan1r1m.',
    'Yes, I have to start at nine.': 'Evet, dokuzda ba_lamam gerekiyor.',
    'Yes, I like studying in my room.': 'Evet, odamda ders �al1_may1 severim.',
    'Yes, I must wear one.': 'Evet, bir tane giymeliyim.',
    'Yes, I usually walk.': 'Evet, genellikle y�r�r�m.',
    'Yes, I want to read it tonight.': 'Evet, onu bu gece okumak istiyorum.',
    'Yes, I watched it with Deniz.': 'Evet, Deniz?le izledim.',
    'Yes, but I did not like the ending.': 'Evet, ama sonunu be?enmedim.',
    'Yes, but it is more expensive.': 'Evet, ama daha pahal1.',
    'Yes, he answered to help me.': 'Evet, bana yard1m etmek için cevap verdi.',
    'Yes, we have some eggs.': 'Evet, biraz yumurtam1z var.',
    'Yes, you have to turn them off.': 'Evet, onlar1 kapatman1z gerekiyor.',
    'Yes, you should rest.': 'Evet, dinlenmelisin.',
    'You must be quiet in the library.': 'K�t�phanede sessiz olmal1s1n.',
    'You should drink some water.': 'Biraz su i�melisin.',
    'Your sister speaks English well.': 'K1z karde_in iyi ?ngilizce konu?uyor.',
  };
  return translations[clean] ?? moreTranslations[clean];
}

class _StructurePack {
  final List<_StructureCardData> cards;
  const _StructurePack({required this.cards});

  static _StructurePack fromLesson(
      GrammarLesson lesson, List<GrammarFormulaRow> rows, bool isEnglish) {
    final key = _lessonKey(lesson);
    final points = generateGrammarLogicPoints(lesson);

    _StructureCardData card({
      required String titleEn,
      required String titleTr,
      required IconData icon,
      required String pattern,
      required List<String> examples,
      List<String> chips = const [],
      String noteEn = '',
      String noteTr = '',
    }) {
      return _StructureCardData(
        titleEn: titleEn,
        titleTr: titleTr,
        icon: icon,
        pattern: pattern.trim(),
        examples: examples
            .where((e) => e.trim().isNotEmpty)
            .take(3)
            .toList(growable: false),
        chips: chips
            .where((e) => e.trim().isNotEmpty)
            .take(5)
            .toList(growable: false),
        noteEn: noteEn,
        noteTr: noteTr,
      );
    }

    List<String> examplesOfKind(String kind, {int max = 2}) {
      final out = <String>[];
      for (final p in points) {
        if (p.kind != kind) continue;
        final sample = _cleanOptionSentence(p.model);
        if (sample.isEmpty ||
            !_isSentenceLike(sample) ||
            _looksLikeMetaOption(sample)) {
          continue;
        }
        if (!out.any((e) => e.toLowerCase() == sample.toLowerCase())) {
          out.add(sample);
        }
        if (out.length >= max) break;
      }
      if (out.isNotEmpty) return out;

      // Fall back to formula rows.
      for (final row in rows) {
        final rowKind = _rowKind(row);
        if (rowKind != kind) continue;
        final sample = _cleanOptionSentence(_canonicalRowModel(row));
        if (sample.isEmpty ||
            !_isSentenceLike(sample) ||
            _looksLikeMetaOption(sample)) {
          continue;
        }
        if (!out.any((e) => e.toLowerCase() == sample.toLowerCase())) {
          out.add(sample);
        }
        if (out.length >= max) break;
      }
      return out;
    }

    String pickPatternForKind(String kind) {
      for (final row in rows) {
        final rowKind = _rowKind(row);
        if (rowKind != kind) continue;
        final p = row.pattern.trim();
        if (p.isNotEmpty) return p;
      }
      // Friendly fallback patterns per kind.
      switch (kind) {
        case 'positive':
          return isEnglish ? 'Subject + verb' : 'özne + fiil';
        case 'negative':
          return isEnglish ? 'Helper + not + verb' : 'Yard1mc1 + not + fiil';
        case 'question':
          return isEnglish
              ? 'Helper + subject + verb?'
              : 'Yard1mc1 + özne + fiil?';
        case 'time':
          return isEnglish ? 'Signal words' : 'Sinyal kelimeler';
      }
      return isEnglish ? 'Pattern' : 'Kal1p';
    }

    final a1Pack = _a1StructurePackForKey(key);
    if (a1Pack != null) {
      return _StructurePack(
        cards: a1Pack.cards
            .where((card) => card.titleEn.toLowerCase() != 'key warning')
            .toList(growable: false),
      );
    }

    // Hand-crafted packs for core high-traffic topics.
    switch (key) {
      case 'a1_be_verb':
        return _StructurePack(cards: [
          card(
            titleEn: 'Affirmative',
            titleTr: 'Olumlu',
            icon: Icons.check_circle_rounded,
            pattern: 'I am / he is / they are + adjective / noun / place',
            examples: const ['I am ready.', 'She is at home.'],
            chips: const ['I -> am', 'he/she/it -> is', 'we/you/they -> are'],
          ),
          card(
            titleEn: 'Negative',
            titleTr: 'Olumsuz',
            icon: Icons.remove_circle_outline_rounded,
            pattern: 'am/is/are + not',
            examples: const ['He is not late.', 'They are not here.'],
            chips: const ['not be\'den hemen sonra gelir'],
          ),
          card(
            titleEn: 'Question',
            titleTr: 'Soru',
            icon: Icons.help_rounded,
            pattern: 'Am/Is/Are + subject + & ?',
            examples: const ['Are you okay?', 'Is she tired?'],
            chips: const ['be verb başa gelir'],
          ),
          card(
            titleEn: 'Short answers',
            titleTr: 'K1sa cevap',
            icon: Icons.short_text_rounded,
            pattern: 'Yes, I am. / No, I?m not.',
            examples: const [
              'A: Are you ready? B: Yes, I am.',
              'A: Is he here? B: No, he isn\'t.'
            ],
          ),
        ]);
      case 'a1_present_simple':
        return _StructurePack(cards: [
          card(
            titleEn: 'Affirmative',
            titleTr: 'Olumlu',
            icon: Icons.check_circle_rounded,
            pattern: 'I/you/we/they + V1 " he/she/it + V1+s',
            examples: const ['I work every day.', 'She studies English.'],
            chips: const ['he/she/it -> -s/-es'],
          ),
          card(
            titleEn: 'Negative',
            titleTr: 'Olumsuz',
            icon: Icons.remove_circle_outline_rounded,
            pattern: 'don\'t/doesn\'t + V1',
            examples: const ['I don\'t eat meat.', 'He doesn\'t like tea.'],
            chips: const ['doesn\'t + V1 (s yok)'],
          ),
          card(
            titleEn: 'Question',
            titleTr: 'Soru',
            icon: Icons.help_rounded,
            pattern: 'Do/Does + subject + V1 ?',
            examples: const ['Do you work here?', 'Does she live in Ankara?'],
            chips: const ['does gelince fiil V1'],
          ),
          card(
            titleEn: 'Time expressions',
            titleTr: 'Zaman ifadeleri',
            icon: Icons.schedule_rounded,
            pattern: pickPatternForKind('time'),
            examples: const [
              'every day',
              'usually / often / never',
              'on Mondays'
            ],
          ),
        ]);
      case 'a1_present_continuous':
        return _StructurePack(cards: [
          card(
            titleEn: 'Affirmative',
            titleTr: 'Olumlu',
            icon: Icons.check_circle_rounded,
            pattern: 'am/is/are + V-ing',
            examples: const ['I am studying now.', 'They are waiting.'],
            chips: const ['be + V-ing'],
          ),
          card(
            titleEn: 'Negative',
            titleTr: 'Olumsuz',
            icon: Icons.remove_circle_outline_rounded,
            pattern: 'am/is/are + not + V-ing',
            examples: const ['She isn\'t working today.', 'I?m not sleeping.'],
          ),
          card(
            titleEn: 'Question',
            titleTr: 'Soru',
            icon: Icons.help_rounded,
            pattern: 'Am/Is/Are + subject + V-ing ?',
            examples: const ['Are you coming?', 'Is he studying?'],
          ),
          card(
            titleEn: 'Signal words',
            titleTr: 'Sinyal kelimeler',
            icon: Icons.bolt_rounded,
            pattern: pickPatternForKind('time'),
            examples: const [
              'now',
              'right now',
              'at the moment',
              'today / this week'
            ],
          ),
        ]);
      default:
        // Generic structure pack from detected logic points.
        final cards = <_StructureCardData>[];
        final positive = examplesOfKind('positive');
        if (positive.isNotEmpty) {
          cards.add(card(
            titleEn: 'Affirmative',
            titleTr: 'Olumlu',
            icon: Icons.check_circle_rounded,
            pattern: pickPatternForKind('positive'),
            examples: positive,
          ));
        }
        final negative = examplesOfKind('negative');
        if (negative.isNotEmpty) {
          cards.add(card(
            titleEn: 'Negative',
            titleTr: 'Olumsuz',
            icon: Icons.remove_circle_outline_rounded,
            pattern: pickPatternForKind('negative'),
            examples: negative,
          ));
        }
        final question = examplesOfKind('question');
        if (question.isNotEmpty) {
          cards.add(card(
            titleEn: 'Question',
            titleTr: 'Soru',
            icon: Icons.help_rounded,
            pattern: pickPatternForKind('question'),
            examples: question,
          ));
        }

        // Signal words from time points or lesson text.
        final timeWords = _signalWordsForKey(key, isEnglish);
        if (timeWords.isNotEmpty) {
          cards.add(card(
            titleEn: 'Signal words',
            titleTr: 'Sinyal kelimeler',
            icon: Icons.schedule_rounded,
            pattern: pickPatternForKind('time'),
            examples: timeWords.take(4).toList(growable: false),
          ));
        }

        if (cards.isEmpty) {
          cards.add(card(
            titleEn: 'Structure',
            titleTr: 'Yapı',
            icon: Icons.schema_rounded,
            pattern: rows.isNotEmpty
                ? rows.first.pattern
                : (isEnglish ? 'Pattern' : 'Kal1p'),
            examples: [_learnModelSentenceFor(lesson, isEnglish)],
          ));
        }
        return _StructurePack(cards: cards);
    }
  }
}

_StructurePack? _cleanDisplayStructurePack(GrammarLesson lesson) {
  final bullets = grammarDisplayLessonFor(lesson, false)
      .structureBulletsTr
      .map(_repairVisibleGrammarText)
      .where((item) => item.trim().isNotEmpty)
      .toList(growable: false);
  if (bullets.isEmpty) return null;

  const icons = <IconData>[
    Icons.looks_one_rounded,
    Icons.looks_two_rounded,
    Icons.looks_3_rounded,
    Icons.looks_4_rounded,
    Icons.looks_5_rounded,
  ];

  return _StructurePack(
    cards: List.generate(bullets.length, (index) {
      final bullet = bullets[index];
      return _StructureCardData(
        titleEn: 'Rule ${index + 1}',
        titleTr: 'Kural ${index + 1}',
        icon: icons[index < icons.length ? index : icons.length - 1],
        pattern: bullet,
        examples: const <String>[],
        noteTr: '',
      );
    }),
  );
}

class _StructureCardData {
  final String titleEn;
  final String titleTr;
  final IconData icon;
  final String pattern;
  final List<String> examples;
  final List<String> chips;
  final String noteEn;
  final String noteTr;

  const _StructureCardData({
    required this.titleEn,
    required this.titleTr,
    required this.icon,
    required this.pattern,
    required this.examples,
    this.chips = const [],
    this.noteEn = '',
    this.noteTr = '',
  });

  String title(bool isEnglish) =>
      isEnglish ? _repairMojibake(titleEn) : _repairMojibake(titleTr);
  String note(bool isEnglish) =>
      isEnglish ? _repairMojibake(noteEn) : _repairMojibake(noteTr);
}

_StructurePack? _a1StructurePackForKey(String key) {
  _StructureCardData c({
    required String titleEn,
    required String titleTr,
    required IconData icon,
    required String pattern,
    required List<String> examples,
    required String noteTr,
    String noteEn = '',
    List<String> chips = const [],
  }) {
    return _StructureCardData(
      titleEn: titleEn,
      titleTr: titleTr,
      icon: icon,
      pattern: pattern,
      examples: examples.take(2).toList(growable: false),
      chips: chips.take(4).toList(growable: false),
      noteEn: noteEn.isEmpty ? noteTr : noteEn,
      noteTr: noteTr,
    );
  }

  switch (key) {
    case 'a1_be_verb':
      return _StructurePack(cards: [
        c(
            titleEn: 'Positive form',
            titleTr: 'Olumlu yapı',
            icon: Icons.check_circle_rounded,
            pattern: 'I am / He-She-It is / You-We-They are',
            examples: const ['I am ready.', 'She is at home.'],
            noteTr: 'özneye g�re am, is veya are se�.',
            chips: const ['I ? am', 'he/she/it ? is', 'you/we/they ? are']),
        c(
            titleEn: 'Negative form',
            titleTr: 'Olumsuz yapı',
            icon: Icons.remove_circle_outline_rounded,
            pattern: 'subject + am/is/are + not',
            examples: const ['He is not late.', 'They are not here.'],
            noteTr: 'not, be fiilinden hemen sonra gelir.',
            chips: const ['is not', 'are not', "I?m not"]),
        c(
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            icon: Icons.help_rounded,
            pattern: 'Am/Is/Are + subject + ... ?',
            examples: const ['Are you okay?', 'Is she tired?'],
            noteTr: 'Soruda am/is/are başa gelir.'),
        c(
            titleEn: 'Short answers',
            titleTr: 'K1sa cevaplar',
            icon: Icons.short_text_rounded,
            pattern: 'Yes, subject + be. / No, subject + be + not.',
            examples: const ['Yes, I am.', "No, he isn't."],
            noteTr: 'K1sa cevapta ana fiil değil, be fiili kullanılır.'),
      ]);
    case 'a1_subject_pronouns':
      return _StructurePack(cards: [
        c(
            titleEn: 'People',
            titleTr: '0nsanlar',
            icon: Icons.people_rounded,
            pattern: 'I / you / he / she / we / they',
            examples: const [
              'Ali is my friend. He is funny.',
              'Ece is here. She is ready.'
            ],
            noteTr: '0simden sonra ayn? kişiyi zamirle anlat.',
            chips: const ['Ali ? he', 'Ece ? she', 'Ali and Ece ? they']),
        c(
            titleEn: 'Things',
            titleTr: 'E_yalar',
            icon: Icons.inventory_2_rounded,
            pattern: 'it = one thing / they = many things',
            examples: const [
              'The phone is old. It works well.',
              'My keys are here. They are on the desk.'
            ],
            noteTr: 'Tek e_ya için it, �o?ul e_yalar için they kullan.'),
        c(
            titleEn: 'Object pronouns',
            titleTr: 'Nesne zamirleri',
            icon: Icons.reply_rounded,
            pattern: 'verb + me/you/him/her/it/us/them',
            examples: const ['Can you help me?', 'I like them.'],
            noteTr:
                'Fiilden sonra I/he/she/we/they değil me/him/her/us/them kullan.'),
        c(
            titleEn: 'Key warning',
            titleTr: 'Kritik uyar1',
            icon: Icons.warning_amber_rounded,
            pattern: 'Ali is happy. He is happy.',
            examples: const ['Ali is happy.', 'He is happy.'],
            noteTr: 'Ayn1 özne yerinde isim ve zamiri birlikte kullanma.'),
      ]);
    case 'a1_possessive_adjectives':
      return _StructurePack(cards: [
        c(
            titleEn: 'Owner + noun',
            titleTr: 'Sahip + isim',
            icon: Icons.backpack_rounded,
            pattern: 'my/your/his/her/our/their + noun',
            examples: const ['My bag is blue.', 'Her room is clean.'],
            noteTr: 'Sahiplik sıfatından sonra isim gelir.',
            chips: const ['my bag', 'your phone', 'their house']),
        c(
            titleEn: 'Family words',
            titleTr: 'Aile kelimeleri',
            icon: Icons.family_restroom_rounded,
            pattern: 'my mother / his brother / their parents',
            examples: const [
              'My mother is a nurse.',
              'Their parents are teachers.'
            ],
            noteTr:
                'Aileden bahsederken sahiplik s?fat? + aile kelimesi _eklinde d�_�n.'),
        c(
            titleEn: 'Possessive ?s / whose',
            titleTr: 'Possessive ?s / whose',
            icon: Icons.key_rounded,
            pattern: 'Ece?s bag / Whose bag is this?',
            examples: const ['This is Ece?s bag.', 'Whose pen is this?'],
            noteTr:
                '0simle sahiplik anlat?rken ?s; kime ait diye sorarken whose kullan.'),
        c(
            titleEn: 'Key warning',
            titleTr: 'Kritik uyar1',
            icon: Icons.warning_amber_rounded,
            pattern: 'his = erkek / her = kad1n',
            examples: const ['His sister is kind.', 'Her brother is tall.'],
            noteTr:
                'his/her se�imi sahip olan kişiye g�re yap?l1r; isimden �nce he/she kullanma.'),
      ]);
    case 'a1_there_is_are':
      return _StructurePack(cards: [
        c(
            titleEn: 'Singular',
            titleTr: 'Tekil',
            icon: Icons.looks_one_rounded,
            pattern: 'There is + singular noun',
            examples: const ['There is a bed.', 'There is a cafe.'],
            noteTr: 'Bir tane ?ey varsa there is kullan.',
            chips: const ['a bed', 'one cafe']),
        c(
            titleEn: 'Plural',
            titleTr: '�o?ul',
            icon: Icons.format_list_numbered_rounded,
            pattern: 'There are + plural noun',
            examples: const ['There are two chairs.', 'There are many cafes.'],
            noteTr: 'Birden fazla ?ey varsa there are kullan.',
            chips: const ['two chairs', 'many cafes']),
        c(
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            icon: Icons.help_rounded,
            pattern: 'Is/Are there + noun?',
            examples: const ['Is there a bank?', 'Are there any buses?'],
            noteTr:
                'Soruda is/are başa gelir; �o?ul soruda any s?k kullanılır.'),
      ]);
    case 'a1_articles':
      return _StructurePack(cards: [
        c(
            titleEn: 'a / an',
            titleTr: 'a / an',
            icon: Icons.looks_one_rounded,
            pattern: 'a/an + singular countable noun',
            examples: const ['I need a pen.', 'She has an umbrella.'],
            noteTr:
                '?lk kez bahsedilen tekil say?labilen isimlerde a/an kullan.',
            chips: const ['a pen', 'an apple']),
        c(
            titleEn: 'the',
            titleTr: 'the',
            icon: Icons.push_pin_rounded,
            pattern: 'the + known noun',
            examples: const [
              'I see a dog. The dog is small.',
              'Open the door.'
            ],
            noteTr:
                'Dinleyen kişi hangi ?eyden bahsetti?ini biliyorsa the kullan.'),
        c(
            titleEn: 'No article',
            titleTr: 'Articles1z',
            icon: Icons.block_rounded,
            pattern: 'plural/general noun',
            examples: const ['I like cats.', 'We eat breakfast.'],
            noteTr: 'Genel �o?ul isimlerde �o?u zaman a/an kullan?lmaz.'),
      ]);
    case 'a1_singular_plural':
      return _StructurePack(cards: [
        c(
            titleEn: 'Regular plural',
            titleTr: 'D�zenli �o?ul',
            icon: Icons.add_circle_rounded,
            pattern: 'noun + -s / -es',
            examples: const ['one book / two books', 'one box / three boxes'],
            noteTr: 'Birden b�y�k say1lardan sonra isim �o?ul olur.',
            chips: const ['book ? books', 'box ? boxes']),
        c(
            titleEn: 'Irregular plural',
            titleTr: 'Düzensiz çoğul',
            icon: Icons.change_circle_rounded,
            pattern: 'person ? people / child ? children',
            examples: const ['One child is here.', 'Three children are here.'],
            noteTr: 'people ve children gibi yayg?n �o?ullar1 ayr1 �?ren.'),
        c(
            titleEn: 'Quantity basics',
            titleTr: 'Miktar temelleri',
            icon: Icons.water_drop_rounded,
            pattern: 'some/any, much/many, a lot of',
            examples: const ['There is some milk.', 'Are there any eggs?'],
            noteTr:
                'many say?labilen �o?ullar, much say?lamayan isimler içindir.'),
        c(
            titleEn: 'Key warning',
            titleTr: 'Kritik uyar1',
            icon: Icons.warning_amber_rounded,
            pattern: 'two books, not two book',
            examples: const ['I have two books.', 'These are my keys.'],
            noteTr: '�o?ul isimden �nce a/an kullanma.'),
      ]);
    case 'a1_present_simple':
      return _StructurePack(cards: [
        c(
            titleEn: 'Positive form',
            titleTr: 'Olumlu yapı',
            icon: Icons.check_circle_rounded,
            pattern: 'I/you/we/they + V1 / he/she/it + V1+s',
            examples: const ['I work every day.', 'She studies English.'],
            noteTr: 'he/she/it ile olumlu cümlede fiile -s gelir.',
            chips: const ['work', 'works', 'study ? studies']),
        c(
            titleEn: 'Negative form',
            titleTr: 'Olumsuz yapı',
            icon: Icons.remove_circle_outline_rounded,
            pattern: "don't / doesn't + V1",
            examples: const ["I don't eat meat.", "He doesn't like tea."],
            noteTr: "doesn't gelince fiilde -s kalmaz."),
        c(
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            icon: Icons.help_rounded,
            pattern: 'Do/Does + subject + V1?',
            examples: const ['Do you work here?', 'Does she live in Ankara?'],
            noteTr: 'Soruda do/does başa gelir, fiil yal?n kalır.'),
        c(
            titleEn: 'Wh- questions',
            titleTr: 'Wh- sorular1',
            icon: Icons.travel_explore_rounded,
            pattern: 'Where/When/What + do/does + subject + V1?',
            examples: const ['Where do you live?', 'What does she like?'],
            noteTr:
                'Bilgi sorular1nda wh-word ba_ta, do/does hemen arkas1ndan gelir.'),
        c(
            titleEn: 'Short answers',
            titleTr: 'K1sa cevaplar',
            icon: Icons.short_text_rounded,
            pattern: 'Yes, I do. / No, he does not.',
            examples: const ['Yes, I do.', "No, he doesn't."],
            noteTr: 'K1sa cevapta do veya does kullan.'),
        c(
            titleEn: 'Time words',
            titleTr: 'Zaman kelimeleri',
            icon: Icons.schedule_rounded,
            pattern: 'every day / usually / often / never',
            examples: const [
              'I usually study at night.',
              'He never drinks coffee.'
            ],
            noteTr: 'Rutin ve al1_kanl1k ipu�lar1d1r.'),
        c(
            titleEn: 'Likes',
            titleTr: 'Sevme / sevmeme',
            icon: Icons.favorite_rounded,
            pattern: 'like/love/hate + noun or V-ing',
            examples: const ['I love reading.', 'He hates loud music.'],
            noteTr:
                'like/love/hate sonras?nda isim veya -ing kullanabilirsin.'),
      ]);
    case 'a1_present_continuous':
      return _StructurePack(cards: [
        c(
            titleEn: 'Positive form',
            titleTr: 'Olumlu yapı',
            icon: Icons.timelapse_rounded,
            pattern: 'am/is/are + V-ing',
            examples: const ['I am studying now.', 'They are waiting.'],
            noteTr: '^u anda olan eylem için be + V-ing kur.',
            chips: const ['am studying', 'is reading', 'are waiting']),
        c(
            titleEn: 'Negative form',
            titleTr: 'Olumsuz yapı',
            icon: Icons.remove_circle_outline_rounded,
            pattern: 'am/is/are + not + V-ing',
            examples: const ["She isn't working today.", "I?m not sleeping."],
            noteTr: 'not, am/is/are sonras1na gelir.'),
        c(
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            icon: Icons.help_rounded,
            pattern: 'Am/Is/Are + subject + V-ing?',
            examples: const ['Are you coming?', 'Is he studying?'],
            noteTr: 'Soruda am/is/are başa gelir.'),
        c(
            titleEn: 'Now markers',
            titleTr: '^u an ipu�lar1',
            icon: Icons.bolt_rounded,
            pattern: 'now / right now / at the moment / today',
            examples: const [
              'We are studying right now.',
              'She is working today.'
            ],
            noteTr: 'Bu kelimeler �o?u zaman devam eden eylemi gösterir.'),
      ]);
    case 'a1_can_cant':
      return _StructurePack(cards: [
        c(
            titleEn: 'Ability',
            titleTr: 'Yetenek',
            icon: Icons.bolt_rounded,
            pattern: 'subject + can + V1',
            examples: const ['I can swim.', 'She can play the piano.'],
            noteTr: 'can sonras?nda fiil yal?n gelir.'),
        c(
            titleEn: 'Negative',
            titleTr: 'Olumsuz',
            icon: Icons.remove_circle_outline_rounded,
            pattern: "subject + can't + V1",
            examples: const ["He can't drive.", "She can't come today."],
            noteTr: "can't sonras?nda da fiil yal?n kalır."),
        c(
            titleEn: 'Question',
            titleTr: 'Soru',
            icon: Icons.help_rounded,
            pattern: 'Can + subject + V1?',
            examples: const ['Can you help me?', 'Can I ask a question?'],
            noteTr: 'Rica ve izin sorular1nda can başa gelir.'),
        c(
            titleEn: 'Short answers',
            titleTr: 'K1sa cevaplar',
            icon: Icons.short_text_rounded,
            pattern: "Yes, I can. / No, I can't.",
            examples: const ['Yes, I can.', "No, she can't."],
            noteTr: 'K1sa cevapta ana fiili tekrar etme.'),
      ]);
    case 'a1_have_has_got':
      return _StructurePack(cards: [
        c(
            titleEn: 'Positive form',
            titleTr: 'Olumlu yapı',
            icon: Icons.inventory_2_rounded,
            pattern: 'I/you/we/they have got / he/she/it has got',
            examples: const ['I have got a bike.', 'She has got a brother.'],
            noteTr: 'he/she/it ile has got kullan.'),
        c(
            titleEn: 'Negative form',
            titleTr: 'Olumsuz yapı',
            icon: Icons.remove_circle_outline_rounded,
            pattern: "haven't got / hasn't got",
            examples: const ["I haven't got a car.", "He hasn't got a phone."],
            noteTr: 'Olumsuzda have/has sonras1na not gelir.'),
        c(
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            icon: Icons.help_rounded,
            pattern: 'Have/Has + subject + got?',
            examples: const ['Have you got a pen?', 'Has she got a phone?'],
            noteTr: 'Soruda have veya has başa gelir.'),
      ]);
    case 'a1_basic_prepositions':
      return _StructurePack(cards: [
        c(
            titleEn: 'in',
            titleTr: 'in',
            icon: Icons.inbox_rounded,
            pattern: 'in + place/month/longer time',
            examples: const [
              'My phone is in my bag.',
              'My birthday is in June.'
            ],
            noteTr: '0�inde olmak veya daha geni_ zaman için in kullan.'),
        c(
            titleEn: 'on',
            titleTr: 'on',
            icon: Icons.layers_rounded,
            pattern: 'on + surface/day',
            examples: const ['The book is on the table.', 'We meet on Monday.'],
            noteTr: 'Y�zey ve g�nlerde on kullan.'),
        c(
            titleEn: 'at',
            titleTr: 'at',
            icon: Icons.schedule_rounded,
            pattern: 'at + point/time',
            examples: const [
              'She is at school.',
              'The lesson starts at seven.'
            ],
            noteTr: 'Nokta yer ve saat için at kullan.'),
      ]);
    case 'a1_imperatives':
      return _StructurePack(cards: [
        c(
            titleEn: 'Instruction',
            titleTr: 'Y�nerge',
            icon: Icons.campaign_rounded,
            pattern: 'base verb + object',
            examples: const ['Open the door.', 'Write your name.'],
            noteTr: 'Emir c�mlesi �o?u zaman yal?n fiille ba?lar.'),
        c(
            titleEn: 'Polite instruction',
            titleTr: 'Kibar y�nerge',
            icon: Icons.volunteer_activism_rounded,
            pattern: 'Please + base verb',
            examples: const ['Please sit down.', 'Please listen carefully.'],
            noteTr: 'please c�mleyi daha kibar yapar.'),
        c(
            titleEn: 'Negative',
            titleTr: 'Olumsuz',
            icon: Icons.remove_circle_outline_rounded,
            pattern: "Don't + base verb",
            examples: const ["Don't run.", "Don't touch that."],
            noteTr: "Yapma demek için don't ile ba_la."),
      ]);
    case 'a1_demonstratives':
      return _StructurePack(cards: [
        c(
            titleEn: 'Near',
            titleTr: 'Yak1n',
            icon: Icons.touch_app_rounded,
            pattern: 'this is + singular / these are + plural',
            examples: const ['This is my phone.', 'These are my keys.'],
            noteTr: 'Yak1ndaki tekil için this, �o?ul için these kullan.'),
        c(
            titleEn: 'Far',
            titleTr: 'Uzak',
            icon: Icons.near_me_rounded,
            pattern: 'that is + singular / those are + plural',
            examples: const ['That is your bag.', 'Those are my shoes.'],
            noteTr: 'Uzaktaki tekil için that, �o?ul için those kullan.'),
        c(
            titleEn: 'Key warning',
            titleTr: 'Kritik uyar1',
            icon: Icons.warning_amber_rounded,
            pattern: 'this/that is / these/those are',
            examples: const ['This is my seat.', 'These are my books.'],
            noteTr: 'this/that ile is, these/those ile are kullan.'),
      ]);
  }
  return null;
}

class _StructureCard extends StatefulWidget {
  final _StructureCardData card;
  final Color color;
  final bool isEnglish;
  final bool showTurkishNote;
  final bool showContentSupport;
  final bool initiallyExpanded;

  const _StructureCard(
      {required this.card,
      required this.color,
      required this.isEnglish,
      this.showTurkishNote = false,
      this.showContentSupport = true,
      this.initiallyExpanded = false});

  @override
  State<_StructureCard> createState() => _StructureCardState();
}

class _StructureCardState extends State<_StructureCard>
    with AutomaticKeepAliveClientMixin<_StructureCard> {
  late bool expanded = widget.initiallyExpanded;
  static const _expandDuration = Duration(milliseconds: 220);

  @override
  bool get wantKeepAlive => true;

  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tokens = SpeakeryThemeTokens.of(context);
    final card = widget.card;
    final color = widget.color;
    final accent = _grammarAccentText(tokens, color);
    final title =
        card.title(widget.showContentSupport ? widget.isEnglish : true);
    final pattern = _repairMojibake(card.pattern);
    final note = widget.showContentSupport
        ? _repairMojibake(
                card.note(widget.showTurkishNote ? false : widget.isEnglish))
            .trim()
        : '';
    final preview = widget.showContentSupport
        ? _repairMojibake(
            card.examples.isNotEmpty ? card.examples.first : pattern)
        : pattern;

    return RepaintBoundary(
      child: _TapScale(
        onTap: () => setState(() => expanded = !expanded),
        child: AnimatedContainer(
          duration: _expandDuration,
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14, 14, 14, expanded ? 14 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: tokens.isLight
                  ? _grammarLightGlass(color, strong: expanded)
                  : [
                      color.withAlpha(expanded ? 34 : 17),
                      const Color(0xFF07111E).withAlpha(238),
                      Colors.white.withAlpha(expanded ? 12 : 5),
                    ],
            ),
            border: Border.all(
                color: expanded
                    ? tokens.isLight
                        ? _grammarGlassBorder(
                            tokens,
                            accent: color,
                            strong: true,
                          )
                        : color.withAlpha(54)
                    : tokens.isLight
                        ? _grammarGlassBorder(tokens, accent: color)
                        : Colors.white.withAlpha(12)),
            boxShadow: expanded
                ? [
                    BoxShadow(
                        color: color.withAlpha(22),
                        blurRadius: 28,
                        offset: const Offset(0, 14))
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: _expandDuration,
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: color.withAlpha(expanded ? 28 : 18),
                      border: Border.all(
                          color: color.withAlpha(expanded ? 48 : 34)),
                    ),
                    child: Icon(card.icon, color: accent, size: 18),
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
                          style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 14.4,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expanded && widget.showContentSupport
                              ? t('Formula and examples', 'Formül ve örnekler')
                              : preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 11.5,
                              height: 1.22,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: color.withAlpha(expanded ? 22 : 12),
                      border: Border.all(color: color.withAlpha(28)),
                    ),
                    child: Text(
                      t('FORM', 'KALIP'),
                      style: TextStyle(
                          color: tokens.isLight
                              ? accent
                              : Colors.white.withAlpha(205),
                          fontSize: 9.8,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 7),
                  AnimatedRotation(
                    turns: expanded ? .5 : 0,
                    duration: _expandDuration,
                    curve: Curves.easeOutCubic,
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: tokens.iconSecondary, size: 22),
                  ),
                ],
              ),
              AnimatedSize(
                duration: _expandDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                clipBehavior: Clip.hardEdge,
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormulaMiniCode(
                                pattern: _repairMojibake(pattern),
                                color: color),
                            if (note.isNotEmpty) ...[
                              const SizedBox(height: 9),
                              Text(note,
                                  style: TextStyle(
                                      color: tokens.textSecondary,
                                      fontSize: 11.7,
                                      height: 1.3,
                                      fontWeight: FontWeight.w700)),
                            ],
                            if (widget.showContentSupport &&
                                card.chips.isNotEmpty) ...[
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: card.chips
                                    .map((chip) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 7),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            color: tokens.inputSurface,
                                            border: Border.all(
                                                color: tokens.border),
                                          ),
                                          child: Text(_repairMojibake(chip),
                                              style: TextStyle(
                                                  color: tokens.textPrimary,
                                                  fontSize: 10.7,
                                                  fontWeight: FontWeight.w800)),
                                        ))
                                    .toList(growable: false),
                              ),
                            ],
                            if (card.examples.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              ...card.examples.take(2).map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color.withAlpha(210)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _repairMojibake(e),
                                          style: TextStyle(
                                              color: tokens.textPrimary,
                                              fontSize: 13.0,
                                              height: 1.35,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _a1StructureWarningPattern(String key, bool isEnglish) {
  switch (key) {
    case 'a1_be_verb':
      return isEnglish
          ? 'Do not mix am / is / are.'
          : 'am / is / are kar1_t1rma.';
    case 'a1_subject_pronouns':
      return isEnglish
          ? 'Use name or pronoun, not both.'
          : '0sim veya zamir kullan; ikisini ayn? özne yapma.';
    case 'a1_possessive_adjectives':
      return isEnglish
          ? 'Possessive adjective + noun'
          : 'Sahiplik s?fat? + isim';
    case 'a1_there_is_are':
      return isEnglish
          ? 'there is + singular / there are + plural'
          : 'there is + tekil / there are + �o?ul';
    case 'a1_articles':
      return isEnglish
          ? 'a/an + singular countable noun'
          : 'a/an + tekil say?labilen isim';
    case 'a1_singular_plural':
      return isEnglish ? 'number + plural noun' : 'say1 + �o?ul isim';
    case 'a1_present_simple':
      return isEnglish
          ? 'does / doesn\'t + base verb'
          : 'does / doesn\'t + yal?n fiil';
    case 'a1_present_continuous':
      return isEnglish
          ? 'be + V-ing, not only V-ing'
          : 'be + V-ing; sadece V-ing yetmez';
    case 'a1_can_cant':
      return isEnglish ? 'can + base verb' : 'can + yal?n fiil';
    case 'a1_have_has_got':
      return isEnglish ? 'he/she/it has got' : 'he/she/it ile has got';
    case 'a1_basic_prepositions':
      return isEnglish
          ? 'in / on / at depends on place or time'
          : 'in / on / at yer ve zamana g�re se�ilir';
    case 'a1_imperatives':
      return isEnglish ? 'Start with the base verb.' : 'Yal1n fiille ba_la.';
    case 'a1_demonstratives':
      return isEnglish
          ? 'this/that is, these/those are'
          : 'this/that is, these/those are';
  }
  return isEnglish ? 'Check the key form.' : 'Ana kal?b? kontrol et.';
}

String _a1StructureWarningNote(String key, bool isEnglish) {
  switch (key) {
    case 'a1_present_simple':
      return isEnglish
          ? 'The -s appears only in positive he/she/it sentences.'
          : '-s sadece olumlu he/she/it c�mlesinde gelir.';
    case 'a1_can_cant':
      return isEnglish
          ? 'Do not add to, -s or -ing after can.'
          : 'can sonras?nda to, -s veya -ing kullanma.';
    case 'a1_present_continuous':
      return isEnglish
          ? 'Always keep am/is/are before the -ing verb.'
          : '-ing fiilinden �nce mutlaka am/is/are kullan.';
    case 'a1_be_verb':
      return isEnglish
          ? 'The subject chooses the be verb.'
          : 'Be fiilini özne belirler.';
    case 'a1_articles':
      return isEnglish
          ? 'A/an is for one general thing; the is for a known thing.'
          : 'a/an genel bir tekil ?ey; the bilinen ?ey içindir.';
  }
  return isEnglish
      ? 'This is the most common A1 mistake for this topic.'
      : 'Bu, konunun en s?k yap?lan A1 hatas1d1r.';
}

List<String> _signalWordsForKey(String key, bool isEnglish) {
  // Short lists only: Structure tab should be visual, not paragraphs.
  switch (key) {
    case 'a1_present_simple':
      return const ['every day', 'usually', 'often', 'never'];
    case 'a1_present_continuous':
      return const ['now', 'right now', 'at the moment', 'today'];
    case 'a2_past_simple':
      return const ['yesterday', 'last week', 'ago', 'in 2020'];
    case 'a2_past_continuous':
      return const ['while', 'when', 'at 8 pm', 'all day'];
    case 'a2_present_perfect':
    case 'b1_present_perfect':
      return const ['ever', 'never', 'already', 'yet', 'just'];
    case 'a2_will':
      return const ['I think&', 'probably', 'maybe', 'I promise'];
    case 'a2_going_to':
      return const ['tonight', 'tomorrow', 'this weekend', 'next week'];
    case 'a2_first_conditional':
      return const ['if', 'unless', 'when'];
    default:
      return const [];
  }
}

class _CleanExamplesIntroCard extends StatelessWidget {
  final Color color;
  final bool isEnglish;
  final bool showContentSupport;

  const _CleanExamplesIntroCard(
      {required this.color,
      required this.isEnglish,
      this.showContentSupport = true});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? _grammarLightGlass(color)
              : [
                  color.withAlpha(20),
                  const Color(0xFF071923).withAlpha(218),
                  Colors.black.withAlpha(8)
                ],
        ),
        border: Border.all(
            color: tokens.isLight
                ? _grammarGlassBorder(tokens, accent: color)
                : color.withAlpha(28)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withAlpha(20),
              border: Border.all(color: color.withAlpha(34)),
            ),
            child: Icon(Icons.format_quote_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('Clean examples', 'Örnek cümleler'),
                    style: TextStyle(
                        color: color,
                        fontSize: 13.2,
                        fontWeight: FontWeight.w900)),
                if (showContentSupport) ...[
                  const SizedBox(height: 4),
                  Text(
                      t('Read natural examples of the same grammar.',
                          'Yapıyı gerçek cümlede gör.'),
                      style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 12.0,
                          height: 1.32,
                          fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<Set<String>> _exampleSignatureGroupsForKey(String key) {
  switch (key) {
    case 'a1_there_is_are':
      return const [
        {'there', 'is'},
        {'there', 'are'},
      ];
    case 'a1_articles':
      return const [
        {'a'},
        {'an'},
        {'the'},
      ];
    case 'a1_some_any':
      return const [
        {'some'},
        {'any'},
      ];
    case 'a1_how_much_many':
      return const [
        {'how', 'many'},
        {'how', 'much'},
      ];
    case 'a1_can_cant':
      return const [
        {'can'},
        {"can't"},
      ];
    case 'a1_demonstratives':
      return const [
        {'this'},
        {'that'},
        {'these'},
        {'those'},
      ];
    case 'a1_possessive_adjectives':
      return const [
        {'my'},
        {'your'},
        {'his'},
        {'her'},
        {'our'},
        {'their'},
      ];
    case 'a1_subject_pronouns':
      return const [
        {'i'},
        {'you'},
        {'he'},
        {'she'},
        {'it'},
        {'we'},
        {'they'},
      ];
    case 'a1_object_pronouns':
      return const [
        {'me'},
        {'him'},
        {'her'},
        {'us'},
        {'them'},
      ];
    case 'a2_present_perfect':
    case 'a2_present_perfect_vs_past':
    case 'b1_present_perfect':
      return const [
        {'have'},
        {'has'},
        {"haven't"},
        {"hasn't"},
      ];
    case 'b1_present_perfect_continuous':
      return const [
        {'have', 'been'},
        {'has', 'been'},
      ];
    case 'b1_past_perfect':
      return const [
        {'had'},
      ];
    case 'b1_past_perfect_continuous':
      return const [
        {'had', 'been'},
      ];
    case 'a2_will':
    case 'b1_future_continuous':
    case 'b2_future_perfect':
    case 'b2_future_perfect_continuous':
      return const [
        {'will'},
        {"won't"},
      ];
    case 'a2_going_to':
    case 'a2_present_continuous_future':
      return const [
        {'going', 'to'},
      ];
    case 'a2_first_conditional':
    case 'a2_zero_conditional':
      return const [
        {'if'},
        {'unless'},
      ];
    case 'a2_must_have_to':
      return const [
        {'must'},
        {'have', 'to'},
        {'has', 'to'},
        {"mustn't"},
      ];
    case 'a2_should':
      return const [
        {'should'},
        {"shouldn't"},
        {'ought', 'to'},
      ];
    case 'a2_may_might':
      return const [
        {'may'},
        {'might'},
      ];
    case 'a2?used_to':
      return const [
        {'used', 'to'},
        {"didn't", 'use', 'to'},
      ];
    case 'a2_comparatives':
      return const [
        {'than'},
        {'more'},
      ];
    case 'a2_superlatives':
      return const [
        {'the', 'most'},
        {'the', 'best'},
        {'the', 'worst'},
      ];
    default:
      if (key.contains('passive')) {
        return const [
          {'was'},
          {'were'},
          {'is'},
          {'are'},
          {'been'},
        ];
      }
      if (key.contains('relative')) {
        return const [
          {'who'},
          {'which'},
          {'that'},
          {'where'},
        ];
      }
      if (key.contains('reported')) {
        return const [
          {'said'},
          {'told'},
          {'asked'},
        ];
      }
      return const [];
  }
}

bool _exampleMatchesSignature(
    String sentence, List<Set<String>> signatureGroups) {
  if (signatureGroups.isEmpty) return true;
  final lower = sentence.toLowerCase();
  for (final group in signatureGroups) {
    var ok = true;
    for (final token in group) {
      if (!RegExp(r'\b' + RegExp.escape(token) + r'\b').hasMatch(lower)) {
        ok = false;
        break;
      }
    }
    if (ok) return true;
  }
  return false;
}

List<String> _exampleBankForKey(String key, bool isEnglish) {
  // Keep these short, natural, and topic-specific.
  switch (key) {
    case 'a1_demonstratives':
      return const [
        'This is my book.',
        'That is your bag.',
        'These are my pens.',
        'Those are her shoes.',
        'This is a small room.',
        'Are those your books?',
      ];
    case 'a1_possessive_adjectives':
      return const [
        'This is my book.',
        'Your bag is blue.',
        'His name is Ali.',
        'Her phone is new.',
        'Our classroom is big.',
        'Their house is big.',
      ];
    case 'a1_subject_pronouns':
      return const [
        'I am a teacher.',
        'You are my friend.',
        'He is ten years old.',
        'She is at home.',
        'They are students.',
        'We are ready.',
      ];
    case 'a1_object_pronouns':
      return const [
        'Call me later.',
        'I like her.',
        'Can you help us?',
        'Look at them.',
        'He knows him.',
      ];
    case 'a1_be_verb':
      return const [
        'I am a student.',
        'You are happy.',
        'He is my brother.',
        'We are at school.',
        'They are friends.',
        'Are you ready?',
      ];
    case 'a1_present_simple':
      return const [
        'I like tea.',
        'You play football.',
        'He goes to school.',
        'She watches TV.',
        'We study English.',
        'Do you drink tea?',
      ];
    case 'a1_present_continuous':
      return const [
        'I am reading now.',
        'You are listening.',
        'He is playing football.',
        'She is cooking.',
        'They are studying.',
        'Are you coming?',
      ];
    case 'a1_articles':
      return const [
        'This is a pen.',
        'It is an apple.',
        'The book is on the desk.',
        'I have a bag.',
        'She has an umbrella.',
      ];
    case 'a1_there_is_are':
      return const [
        'There is a book on the table.',
        'There is a cat in the room.',
        'There are two chairs.',
        'There are five students.',
        'There is not a computer here.',
        'Are there any questions?',
      ];
    case 'a1_some_any':
      return const [
        'I have some water.',
        'Do you have any questions?',
        'There isn\'t any sugar.',
        'Would you like some tea?',
        'We need some help.',
      ];
    case 'a1_how_much_many':
      return const [
        'How many books do you have?',
        'How much water do you drink?',
        'How many students are in the class?',
        'How much is this?',
      ];
    case 'a1_can_cant':
      return const [
        'I can swim.',
        'She can sing.',
        'He can ride a bike.',
        'We can speak English.',
        'I can\'t fly.',
        'Can you help me?',
      ];
    case 'a1_singular_plural':
      return const [
        'This is one apple.',
        'These are two apples.',
        'I have one book.',
        'We have three books.',
        'The child is happy.',
        'The children are happy.',
      ];
    case 'a1_have_has_got':
      return const [
        'I have got a car.',
        'You have got a phone.',
        'He has got a brother.',
        'She has got a cat.',
        'They have got a house.',
        'Have you got a pen?',
      ];
    case 'a1_basic_prepositions':
      return const [
        'The book is on the table.',
        'The cat is under the chair.',
        'The bag is in the room.',
        'The school is next to the park.',
        'The pen is near the book.',
        'The keys are in the bag.',
      ];
    case 'a1_imperatives':
      return const [
        'Open the door.',
        'Close your book.',
        'Listen to me.',
        'Don\'t run.',
        'Please sit down.',
        'Write your name.',
      ];
    case 'a2_past_simple':
      return const [
        'I called you yesterday.',
        'She visited her grandmother last weekend.',
        'We didn\'t go out last night.',
        'Did you finish the homework?',
        'He bought a new jacket.',
        'They arrived late.',
      ];
    case 'a2_past_continuous':
      return const [
        'I was cooking when you called.',
        'They were studying at 9 pm.',
        'She wasn\'t sleeping.',
        'Were you listening to music?',
        'We were waiting in line.',
      ];
    case 'a2_present_perfect':
    case 'b1_present_perfect':
      return const [
        'I have never been to London.',
        'She has already finished her work.',
        'Have you ever tried sushi?',
        'They haven\'t seen this film yet.',
        'I?ve just arrived.',
        'We have had two lessons this week.',
        'He has lived here for three years.',
      ];
    case 'a2_present_perfect_vs_past':
    case 'b1_present_perfect_vs_past':
      return const [
        'Have you seen this movie?',
        'Yes, I have.',
        'When did you see it?',
        'I saw it last night.',
        'I have never tried sushi.',
        'I tried sushi yesterday.',
      ];
    case 'a2_should':
      return const [
        'You should see a doctor.',
        'You shouldn\'t stay up late.',
        'She should talk to her teacher.',
        'Should I call him now?',
        'You ought to rest today.',
      ];
    case 'a2_must_have_to':
      return const [
        'You must wear a seatbelt.',
        'I have to wake up early tomorrow.',
        'He has to show his ID.',
        'You mustn\'t smoke here.',
        'You don\'t have to come today.',
      ];
    case 'a2_will':
      return const [
        'I think it will rain.',
        'I?ll call you later.',
        'Will you help me with this?',
        'Don\'t worry, I?ll handle it.',
        'We won\'t be late.',
      ];
    case 'a2_going_to':
      return const [
        'I?m going to study tonight.',
        'She is going to travel next month.',
        'Are you going to join us?',
        'They aren\'t going to buy a car.',
        'It\'s going to snow (look at the sky).',
      ];
    default:
      if (key.contains('passive')) {
        return const [
          'The room was cleaned yesterday.',
          'The emails are sent every morning.',
          'My phone was stolen.',
          'When was the bridge built?',
          'This product is made in Germany.',
        ];
      }
      return const [];
  }
}

String _exampleLabelFor(String sentence, String lessonKey, bool isEnglish) {
  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);
  final s = sentence.toLowerCase();
  if (sentence.trim().endsWith('?')) return t('Question', 'Soru');
  if (s.contains("n?t") ||
      s.contains(' not ') ||
      s.startsWith("don't") ||
      s.startsWith("doesn't")) {
    return t('Negative', 'Olumsuz');
  }

  if (lessonKey.contains('present_perfect')) {
    if (s.contains('ever') || s.contains('never')) {
      return t('Experience', 'Deneyim');
    }
    if (s.contains('already') || s.contains('yet') || s.contains('just')) {
      return t('Result', 'Sonuç');
    }
    if (s.contains('this week') ||
        s.contains('today') ||
        s.contains('so far')) {
      return t('Unfinished time', 'Bitmemi_ zaman');
    }
    return t('Common use', 'Yayg1n kullan1m');
  }
  if (lessonKey == 'a2_should') return t('Advice', 'Tavsiye');
  if (lessonKey == 'a2_must_have_to') return t('Obligation', 'Zorunluluk');
  if (lessonKey == 'a2_will') {
    return t('Prediction / decision', 'Tahmin / karar');
  }
  if (lessonKey == 'a2_going_to') return t('Plan', 'Plan');

  return t('Positive', 'Olumlu');
}

IconData _exampleIconFor(String sentence, String lessonKey) {
  final s = sentence.toLowerCase();
  if (sentence.trim().endsWith('?')) return Icons.help_rounded;
  if (s.contains("n?t") ||
      s.contains(' not ') ||
      s.startsWith("don't") ||
      s.startsWith("doesn't")) {
    return Icons.remove_circle_outline_rounded;
  }
  if (lessonKey.contains('present_perfect')) return Icons.done_all_rounded;
  if (lessonKey == 'a2_should') return Icons.volunteer_activism_rounded;
  if (lessonKey == 'a2_must_have_to') return Icons.gpp_good_rounded;
  if (lessonKey.contains('passive')) return Icons.swap_horiz_rounded;
  return Icons.check_circle_rounded;
}

class _CleanExampleCard extends StatelessWidget {
  final int number;
  final String sentence;
  final String tag;
  final IconData icon;
  final Color color;

  const _CleanExampleCard(
      {required this.number,
      required this.sentence,
      required this.tag,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha(13),
              const Color(0xFF071A29).withAlpha(210),
              Colors.black.withAlpha(8)
            ]),
        border: Border.all(color: color.withAlpha(26)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withAlpha(18),
              border: Border.all(color: color.withAlpha(32)),
            ),
            child: Text('$number',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 14),
                    const SizedBox(width: 6),
                    Text(tag,
                        style: TextStyle(
                            color: color,
                            fontSize: 10.8,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(sentence,
                    style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 14.3,
                        height: 1.28,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTypeSelector extends StatelessWidget {
  final List<_ExampleCategory> categories;
  final int selectedIndex;
  final bool isEnglish;
  final ValueChanged<int> onSelected;

  const _ExampleTypeSelector({
    required this.categories,
    required this.selectedIndex,
    required this.isEnglish,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: List.generate(categories.length, (index) {
        final category = categories[index];
        return _TapScale(
          onTap: () => onSelected(index),
          child: _CompactTypePill(
              category: category,
              isEnglish: isEnglish,
              selected: selectedIndex == index),
        );
      }),
    );
  }
}

class _CompactTypePill extends StatelessWidget {
  final _ExampleCategory category;
  final bool isEnglish;
  final bool selected;

  const _CompactTypePill(
      {required this.category,
      required this.isEnglish,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: 36),
      padding: EdgeInsets.symmetric(
          horizontal: selected ? 15 : 13, vertical: selected ? 10 : 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color:
            selected ? category.tint.withAlpha(26) : Colors.white.withAlpha(6),
        border: Border.all(
            color: selected
                ? category.tint.withAlpha(58)
                : Colors.white.withAlpha(12)),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: category.tint.withAlpha(14),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon,
              color: selected ? category.tint : Colors.white.withAlpha(132),
              size: 15.5),
          const SizedBox(width: 7),
          Text(
            category.label(isEnglish),
            style: TextStyle(
              color: selected
                  ? category.tint.withAlpha(244)
                  : Colors.white.withAlpha(166),
              fontSize: 12.35,
              fontWeight: FontWeight.w900,
              letterSpacing: .05,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleMinimalPanel extends StatelessWidget {
  final _ExampleCategory category;
  final String sentence;
  final String trap;
  final bool isEnglish;

  const _ExampleMinimalPanel({
    required this.category,
    required this.sentence,
    required this.trap,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowTrapComparison(sentence, trap)) {
      return const SizedBox.shrink();
    }
    final trapText = trap == sentence
        ? t('Do not mix this structure with another rule.',
            'Bu yap?y? ba_ka bir kuralla kar1_t1rma.')
        : trap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MiniCompareTile(
          color: const Color(0xFFFFB020),
          icon: Icons.warning_amber_rounded,
          label: t('Trap', 'Tuzak'),
          text: trapText,
        ),
      ],
    );
  }
}

bool _shouldShowTrapComparison(String model, String trap) {
  final modelClean = _cleanOptionSentence(model);
  final trapClean = _cleanOptionSentence(trap);
  if (modelClean.isEmpty || trapClean.isEmpty) return false;
  if (_sameCleanSentence(modelClean, trapClean)) return false;

  // Do not create/show trap cards for lexical lists, short phrases or pattern rows.
  // Examples like "a book, an apple", "box � boxes", "my + noun" are teaching
  // samples, not full sentence pairs. Showing a fake trap for them creates noise.
  if (_looksLikePatternSample(modelClean) ||
      _looksLikePatternSample(trapClean)) {
    return false;
  }
  if (!_looksLikeNaturalTrapSentence(modelClean)) return false;
  if (!_looksLikeNaturalTrapSentence(trapClean)) return false;
  return true;
}

bool _looksLikeNaturalTrapSentence(String value) {
  final clean = value.trim();
  if (clean.length < 10) return false;
  if (clean.contains(',') &&
      !RegExp(r'\b(and|but|because|so)\b', caseSensitive: false)
          .hasMatch(clean)) {
    return false;
  }
  if (clean.contains('�') || clean.contains('->')) return false;
  if (clean.contains('/') || clean.contains('+')) return false;
  if (RegExp(r'^[a-z]+\s*[:=]', caseSensitive: false).hasMatch(clean)) {
    return false;
  }
  final words =
      clean.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).length;
  if (words < 4) return false;
  return _isSentenceLike(clean);
}

bool _looksLikePatternSample(String value) {
  final clean = value.trim();
  final lower = clean.toLowerCase();
  if (clean.contains('�') || clean.contains('->')) return true;
  if (clean.contains('/') || clean.contains('+')) return true;
  if (clean.contains(',') &&
      !RegExp(r'\b(and|but|because|so)\b').hasMatch(lower)) {
    return true;
  }
  if (RegExp(r'^(a|an|the)\s+[a-z]+\s*,\s*(a|an|the)\s+[a-z]+$')
      .hasMatch(lower)) {
    return true;
  }
  if (RegExp(r'^(my|your|his|her|its|our|their)\s+\+?\s*[a-z]+')
      .hasMatch(lower)) {
    return true;
  }
  if (RegExp(r'^(noun|verb|subject|object|adjective|adverb)\b')
      .hasMatch(lower)) {
    return true;
  }
  return false;
}

class _MiniCompareTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String text;

  const _MiniCompareTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: color.withAlpha(10),
        border: Border.all(color: color.withAlpha(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 13.5),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .1)),
            ],
          ),
          const SizedBox(height: 6),
          Text(text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Colors.white.withAlpha(195),
                  fontSize: 11.9,
                  height: 1.24,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

String _shortBuildSentenceFor(
    String right, List<String> examples, List<GrammarFormulaRow> rows,
    {String? avoid}) {
  final cleanRight = _cleanOptionSentence(right).toLowerCase();
  final cleanAvoid = _cleanOptionSentence(avoid ?? '').toLowerCase();
  final candidates = <String>[
    ...rows.map((row) => _canonicalRowModel(row)),
    ...examples,
    right,
  ];

  String clean(String value) =>
      _cleanOptionSentence(value).replaceAll(RegExp(r'\s+'), ' ').trim();

  bool good(String value) {
    final text = clean(value);
    if (text.isEmpty || _looksLikeMetaOption(text)) return false;
    final words = text
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .length;
    return words >= 3 &&
        words <= 8 &&
        _isSentenceLike(text) &&
        !text.contains(':') &&
        !text.contains(';');
  }

  for (final candidate in candidates) {
    final c = clean(candidate);
    final lower = c.toLowerCase();
    if ((lower == cleanRight || lower == cleanAvoid) && candidates.length > 1) {
      continue;
    }
    if (good(candidate)) return c;
  }
  for (final candidate in candidates) {
    final c = clean(candidate);
    final lower = c.toLowerCase();
    if (lower == cleanAvoid && candidates.length > 1) continue;
    if (good(candidate)) return c;
  }
  final fallback = clean(right);
  if (fallback.isNotEmpty && !_looksLikeMetaOption(fallback)) return fallback;
  return 'I studied English yesterday.';
}

GrammarFormulaRow? _bestPracticeFixRow(
    List<GrammarFormulaRow> rows, String mainRight) {
  final cleanMain = _cleanOptionSentence(mainRight).toLowerCase();
  final orderedKinds = [
    'negative',
    'question',
    'positive',
    'modal',
    'comparison',
    'condition',
    'time'
  ];
  for (final kind in orderedKinds) {
    for (final row in rows) {
      final sample = _cleanOptionSentence(_canonicalRowModel(row));
      if (sample.isEmpty ||
          sample.toLowerCase() == cleanMain ||
          _looksLikeMetaOption(sample)) {
        continue;
      }
      if (_rowKind(row) == kind && _isSentenceLike(sample)) return row;
    }
  }
  for (final row in rows) {
    final sample = _cleanOptionSentence(_canonicalRowModel(row));
    if (sample.isNotEmpty &&
        sample.toLowerCase() != cleanMain &&
        _isSentenceLike(sample) &&
        !_looksLikeMetaOption(sample)) {
      return row;
    }
  }
  return null;
}

String _practiceReasonForRow(
    GrammarFormulaRow? row, String fallback, bool isEnglish) {
  if (row == null) return fallback;
  final label = _formulaLabel(row, isEnglish);
  final pattern = row.pattern.trim();
  if (pattern.isEmpty) return fallback;
  return isEnglish
      ? 'This correction follows the $label pattern: $pattern.'
      : 'Bu d�zeltme $label kal?b?na uyuyor: $pattern.';
}

class _ContextLesson extends StatelessWidget {
  final GrammarLesson lesson;
  final List<GrammarFormulaRow> formulaRows;
  final Color color;
  final bool isEnglish;

  const _ContextLesson({
    required this.lesson,
    required this.formulaRows,
    required this.color,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final key = _lessonKey(lesson);
    final showContentSupport = _showTurkishContentSupport(key, isEnglish);
    final useCleanTurkishUsagePack = !isEnglish;
    final contentIsEnglish = showContentSupport ? isEnglish : true;
    final pack = _ContextPack.fromLesson(lesson, formulaRows, contentIsEnglish);
    final situation = useCleanTurkishUsagePack
        ? 'Kullanım'
        : _contextSituationLabelForKey(key, contentIsEnglish);
    final situations = useCleanTurkishUsagePack
        ? _cleanDisplayUsageSituations(lesson)
        : _usageSituationsForKey(key, lesson, formulaRows, contentIsEnglish);
    final dialogueSets = useCleanTurkishUsagePack
        ? _cleanDisplayUsageDialogueSets(lesson)
        : _usageDialogueSetsForKey(key, contentIsEnglish);
    final tipText = useCleanTurkishUsagePack ? '' : pack.tip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContextDialogueHeader(
          situation: showContentSupport ? situation : '',
          title: isEnglish ? 'Where you use it' : 'Nerede kullanırsın?',
          subtitle: showContentSupport
              ? (isEnglish
                  ? 'Tap a situation and borrow the sentences.'
                  : 'Bir duruma dokun, hazır cümleleri al.')
              : '',
          color: color,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 700;
            const gap = 12.0;
            final cardWidth = twoColumns
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: situations
                  .map((s) => SizedBox(
                        width: cardWidth,
                        child: _UsageSituationCard(
                            situation: s,
                            color: color,
                            isEnglish: isEnglish,
                            highlightKey: key),
                      ))
                  .toList(growable: false),
            );
          },
        ),
        if (dialogueSets.isNotEmpty) ...[
          const SizedBox(height: 14),
          _CleanSectionTitle(
              icon: Icons.chat_bubble_rounded,
              title: isEnglish ? 'Mini dialogues' : 'Mini diyaloglar',
              color: color),
          const SizedBox(height: 10),
          _UsageDialogueCarousel(
              dialogues: dialogueSets, color: color, lessonKey: key),
        ] else if (_shouldShowMiniDialogue(key, pack.dialogueLines)) ...[
          const SizedBox(height: 14),
          _CleanSectionTitle(
              icon: Icons.chat_bubble_rounded,
              title: isEnglish ? 'Mini dialogue' : 'Mini diyalog',
              color: color),
          const SizedBox(height: 10),
          _ContextDialogueCard(
              lines: pack.dialogueLines, color: color, highlightKey: key),
        ],
        if (showContentSupport && tipText.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _ContextTinyTip(text: tipText, color: color, isEnglish: isEnglish),
        ],
      ],
    );
  }
}

List<_UsageSituationData> _cleanDisplayUsageSituations(GrammarLesson lesson) {
  final lessonKey = _lessonKey(lesson);
  final notes = grammarDisplayLessonFor(lesson, false)
      .usageNotesTr
      .map(_repairVisibleGrammarText)
      .where((note) =>
          note.trim().isNotEmpty && !_visibleTurkishTextLooksBroken(note))
      .toList(growable: false);
  if (notes.isEmpty) {
    return const [
      _UsageSituationData(
        icon: Icons.lightbulb_rounded,
        titleEn: 'Usage',
        titleTr: 'Kullanım',
        contextEn: _genericTurkishGrammarUsageFallback,
        contextTr: _genericTurkishGrammarUsageFallback,
        sentences: <String>[],
      ),
    ];
  }

  final nonDialogue = notes
      .where((note) => !_looksLikeA1DisplayDialogueNote(note))
      .toList(growable: false);
  final context = _stripUsageLeadLabel(
      nonDialogue.isNotEmpty ? nonDialogue.first : notes.first);
  final extraNotes = nonDialogue.skip(1).toList(growable: false);

  return [
    _UsageSituationData(
      icon: Icons.lightbulb_rounded,
      titleEn: 'Daily context',
      titleTr: 'Günlük bağlam',
      contextEn: context,
      contextTr: context,
      sentences: _distinctUsageSentences(context, extraNotes, lessonKey),
    ),
  ];
}

List<_UsageDialogueData> _cleanDisplayUsageDialogueSets(GrammarLesson lesson) {
  final key = _lessonKey(lesson);
  final goldA1 = _goldA1UsageDialogueSets(key, false);
  if (goldA1.isNotEmpty) return goldA1;

  final lines = <_ContextDialogueLine>[];
  for (final note in grammarDisplayLessonFor(lesson, false).usageNotesTr) {
    lines.addAll(_splitA1DisplayDialogueNote(_repairVisibleGrammarText(note)));
  }
  if (lines.isEmpty) return const <_UsageDialogueData>[];

  return [
    _UsageDialogueData(
      icon: Icons.chat_bubble_rounded,
      title: 'Mini diyalog',
      lines: lines,
    ),
  ];
}

List<String> _distinctUsageSentences(
  String context,
  List<String> notes,
  String lessonKey,
) {
  final contextKey = _usageDedupKey(context);
  final seen = <String>{contextKey};
  final out = <String>[];
  for (final raw in notes) {
    final clean = _repairVisibleGrammarText(raw).trim();
    if (clean.isEmpty || _looksLikeA1DisplayDialogueNote(clean)) continue;
    final key = _usageDedupKey(clean);
    if (key.isEmpty || seen.contains(key)) continue;
    if (contextKey.contains(key) || key.contains(contextKey)) continue;
    seen.add(key);
    out.add(clean);
  }
  if (out.isNotEmpty) return out.take(3).toList(growable: false);
  return _fallbackA1UsageNotesForKey(lessonKey);
}

String _usageDedupKey(String value) {
  return _repairVisibleGrammarText(value)
      .toLowerCase()
      .replaceAll(RegExp(r'^(günlük bağlam|kısa not)\s*:\s*'), '')
      .replaceAll(RegExp(r'[^\wçğıöşü]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _stripUsageLeadLabel(String value) {
  return _repairVisibleGrammarText(value)
      .replaceFirst(RegExp(r'^(Günlük bağlam|Kısa not)\s*:\s*'), '')
      .trim();
}

List<String> _fallbackA1UsageNotesForKey(String key) {
  switch (key) {
    case 'a1_be_verb':
      return const ['Kısa not: Önce özneyi bul, sonra am/is/are seç.'];
    case 'a1_subject_pronouns':
      return const ['Kısa not: İsim tekrarını azaltmak için zamir kullan.'];
    case 'a1_possessive_adjectives':
      return const ['Kısa not: Sahiplik sıfatından sonra mutlaka isim gelir.'];
    case 'a1_there_is_are':
      return const [
        'Kısa not: Tekil için there is, çoğul için there are kullan.'
      ];
    case 'a1_articles':
      return const [
        'Kısa not: A/an genel tekil isim, the bilinen isim içindir.'
      ];
    case 'a1_singular_plural':
      return const ['Kısa not: Birden büyük sayılarda isim çoğul olur.'];
    case 'a1_present_simple':
      return const ['Kısa not: Rutinlerde he/she/it olumlu cümlede -s alır.'];
    case 'a1_present_continuous':
      return const ['Kısa not: Şu an olan eylemde am/is/are + V-ing kullan.'];
    case 'a1_can_cant':
      return const ['Kısa not: Can sonrasında fiil yalın kalır.'];
    case 'a1_have_has_got':
      return const ['Kısa not: He/she/it ile has got kullan.'];
    case 'a1_basic_prepositions':
      return const ['Kısa not: In iç/alan, on yüzey, at net nokta anlatır.'];
    case 'a1_imperatives':
      return const ['Kısa not: Komutlar yalın fiille başlar.'];
    case 'a1_demonstratives':
      return const [
        'Kısa not: Yakın/uzak ve tekil/çoğul bilgisini birlikte kontrol et.'
      ];
  }
  return const [
    'Kısa not: Örnekleri inceleyip aynı yapıyla kendi cümleni kur.'
  ];
}

bool _looksLikeA1DisplayDialogueNote(String value) {
  final trimmed = value.trim();
  return trimmed.startsWith('A:') ||
      trimmed.startsWith('B:') ||
      RegExp(r'\bA:\s*.+\bB:\s*').hasMatch(trimmed);
}

List<_ContextDialogueLine> _splitA1DisplayDialogueNote(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return const <_ContextDialogueLine>[];

  final combinedMatch = RegExp(r'A:\s*(.*?)\s+B:\s*(.*)$').firstMatch(trimmed);
  if (combinedMatch != null) {
    return [
      _ContextDialogueLine('A', combinedMatch.group(1)!.trim()),
      _ContextDialogueLine('B', combinedMatch.group(2)!.trim()),
    ];
  }

  if (trimmed.startsWith('A:')) {
    return [_ContextDialogueLine('A', trimmed.substring(2).trim())];
  }
  if (trimmed.startsWith('B:')) {
    return [_ContextDialogueLine('B', trimmed.substring(2).trim())];
  }
  return const <_ContextDialogueLine>[];
}

bool _shouldShowMiniDialogue(String key, List<_ContextDialogueLine> lines) {
  if (lines.length < 3) return false;
  if (key.startsWith('a1_')) return true;
  // Show mini dialogue only for high-value conversational topics.
  return key.contains('present_perfect') ||
      key.contains('past_simple') ||
      key == 'a2_should' ||
      key == 'a2_going_to';
}

class _UsageSituationData {
  final IconData icon;
  final String titleEn;
  final String titleTr;
  final String contextEn;
  final String contextTr;
  final List<String> sentences;

  const _UsageSituationData({
    required this.icon,
    required this.titleEn,
    required this.titleTr,
    required this.contextEn,
    required this.contextTr,
    required this.sentences,
  });

  String title(bool isEnglish) =>
      isEnglish ? _repairMojibake(titleEn) : _safeUsageTitle(titleEn, titleTr);
  String context(bool isEnglish) => isEnglish
      ? _repairMojibake(contextEn)
      : _safeUsageContext(contextEn, contextTr);
}

String _safeUsageTitle(String en, String tr) {
  final lower = en.toLowerCase();
  var fallback = 'Günlük kullanım';
  if (lower.contains('introduce')) fallback = 'Kendini tanıtmak';
  if (lower.contains('where')) fallback = 'Nerede olduğunu söylemek';
  if (lower.contains('feeling')) fallback = 'Duyguları anlatmak';
  if (lower.contains('people')) fallback = 'İnsanlardan bahsetmek';
  if (lower.contains('things')) fallback = 'Eşyaları anlatmak';
  if (lower.contains('belong')) fallback = 'Sahiplik anlatmak';
  if (lower.contains('family')) fallback = 'Aileden bahsetmek';
  if (lower.contains('room')) fallback = 'Odayı tarif etmek';
  if (lower.contains('city')) fallback = 'Şehirde ne var?';
  if (lower.contains('shop') || lower.contains('buy')) {
    fallback = 'Alışverişte kullanmak';
  }
  if (lower.contains('known')) fallback = 'Bilinen şeyi anlatmak';
  if (lower.contains('count')) fallback = 'Şeyleri saymak';
  if (lower.contains('plan')) fallback = 'Plan yapmak';
  if (lower.contains('advice') || lower.contains('sick')) {
    fallback = 'Tavsiye vermek';
  }
  if (lower.contains('rule') || lower.contains('duty')) {
    fallback = 'Kural ve zorunluluk';
  }
  if (lower.contains('compare') || lower.contains('choice')) {
    fallback = 'Karşılaştırma yapmak';
  }
  if (lower.contains('dialogue')) fallback = 'Mini diyalog';
  return _safeTurkishVisible(tr, _repairMojibake(fallback));
}

String _safeUsageContext(String en, String tr) {
  final lower = en.toLowerCase();
  var fallback =
      'Bu yapı, cümlede anlamı daha net kurmak için kullanılır. Örnekleri inceleyerek yapının gerçek kullanımını görebilirsin.';
  if (lower.contains('formal') ||
      lower.contains('advanced') ||
      lower.contains('report') ||
      lower.contains('academic')) {
    fallback =
        'Bu yapı daha doğal, daha resmi veya daha vurgulu bir anlatım kurmak için kullanılır. Bağlama göre ton değişebilir.';
  } else if (lower.contains('ask') || lower.contains('answer')) {
    fallback =
        'Soru sorarken veya kısa cevap verirken yapıyı doğal bağlamda kullanırsın.';
  } else if (lower.contains('plan')) {
    fallback =
        'Plan, niyet veya gelecek durum anlatırken yapının bağlama nasıl oturduğunu görürsün.';
  } else if (lower.contains('compare')) {
    fallback =
        'İki kişi, yer veya şeyi karşılaştırırken farkı daha net anlatırsın.';
  } else if (lower.contains('rule') || lower.contains('duty')) {
    fallback =
        'Kural, sorumluluk veya zorunluluk anlatırken cümlenin tonunu netleştirirsin.';
  }
  return _safeTurkishVisible(tr, _repairMojibake(fallback));
}

List<_UsageSituationData> _cleanA1UsageSituationsForKey(String key) {
  _UsageSituationData s(IconData icon, String en, String tr, String contextTr,
          List<String> sentences) =>
      _UsageSituationData(
        icon: icon,
        titleEn: en,
        titleTr: tr,
        contextEn: en,
        contextTr: contextTr,
        sentences: sentences,
      );

  switch (key) {
    case 'a1_be_verb':
      return [
        s(Icons.badge_rounded, 'Introduce yourself', 'Kendini tanıtmak',
            'İsim, rol, yer veya duygu söylerken kullanılır.', const [
          'I am Deniz.',
          'I am a student.',
          'She is my teacher.',
          'We are classmates.',
        ]),
        s(
            Icons.place_rounded,
            'Say where someone is',
            'Nerede olduğunu söylemek',
            'Kişinin veya eşyanın nerede olduğunu anlatırsın.', const [
          'I am at home.',
          'She is in class.',
          'The keys are on the table.',
          'My phone is in my bag.',
        ]),
      ];
    case 'a1_subject_pronouns':
      return [
        s(Icons.people_rounded, 'Talk about people', 'İnsanlardan bahsetmek',
            'İsimleri sürekli tekrar etmeden konuşursun.', const [
          'Ali is my friend. He is funny.',
          'Ayşe is my sister. She is kind.',
          'My parents are here. They are happy.',
        ]),
        s(Icons.reply_rounded, 'After the verb', 'Fiilden sonra',
            'Eylemi alan kişi için nesne zamiri kullanırsın.', const [
          'Can you help me?',
          'I can help you.',
          'She knows him.',
          'We like them.',
        ]),
      ];
    case 'a1_possessive_adjectives':
      return [
        s(
            Icons.backpack_rounded,
            'Talk about belongings',
            'Sahip olduğun şeyler',
            'Çanta, telefon, oda veya fikrin kime ait olduğunu söylersin.',
            const [
              'My bag is blue.',
              'Your phone is on the table.',
              'His bike is new.',
              'Her room is clean.',
            ]),
        s(
            Icons.family_restroom_rounded,
            'Talk about family',
            'Aileden bahsetmek',
            'Ailendeki kişilerden doğal şekilde bahsedersin.', const [
          'My mother is a nurse.',
          'His brother is tall.',
          'Her sister is at school.',
          'Their parents are teachers.',
        ]),
      ];
    case 'a1_articles':
      return [
        s(Icons.shopping_bag_rounded, 'Name one thing', 'Bir şey istemek',
            'Belirli olmayan tek bir şeyden bahsederken kullanılır.', const [
          'I need a pen.',
          'She has an umbrella.',
          'Can I have a ticket?',
          'He wants an apple.',
        ]),
        s(Icons.visibility_rounded, 'Known thing', 'Bilinen şeyi anlatmak',
            'İkinizin de bildiği şeyi tekrar anlatırsın.', const [
          'I see a dog. The dog is small.',
          'This is a book. The book is new.',
          'There is a cafe. The cafe is open.',
        ]),
      ];
    case 'a1_singular_plural':
      return [
        s(Icons.format_list_numbered_rounded, 'Count things', 'Şeyleri saymak',
            'Alışveriş, sınıf veya çanta listesi yaparken kullanılır.', const [
          'I have two books.',
          'There are three boxes.',
          'We need four chairs.',
          'Six glasses are on the table.',
        ]),
        s(Icons.inventory_rounded, 'One and many', 'Tekil ve çoğul ayırmak',
            'Tek bir şeyle bir grup şeyi ayırırsın.', const [
          'This is one bag.',
          'These are two bags.',
          'One child is here.',
          'Three children are here.',
        ]),
      ];
    case 'a1_there_is_are':
      return [
        s(Icons.meeting_room_rounded, 'Describe a room', 'Odayı tarif etmek',
            'Bir yerde ne olduğunu anlatırsın.', const [
          'There is a bed in my room.',
          'There are two chairs.',
          'There is a lamp on the desk.',
        ]),
        s(Icons.location_city_rounded, 'Talk about a city', 'Şehirde ne var',
            'Yakındaki yerleri sormak ve anlatmak için kullanılır.', const [
          'There is a park near here.',
          'There are many cafes.',
          'Are there any buses?',
        ]),
      ];
    case 'a1_present_simple':
      return [
        s(Icons.wb_sunny_rounded, 'Daily routine', 'Günlük rutin anlatmak',
            'Normal bir gününün nasıl geçtiğini anlatırsın.', const [
          'I wake up at seven.',
          'She goes to school.',
          'We eat breakfast at home.',
          'They study English every day.',
        ]),
        s(Icons.favorite_rounded, 'Habits and likes', 'Alışkanlık ve zevkler',
            'Sevdiğin ve genelde yaptığın şeyleri söylersin.', const [
          'I like tea.',
          'He plays football on Sundays.',
          'She does not drink coffee.',
          'Do you watch TV at night?',
        ]),
      ];
    case 'a1_present_continuous':
      return [
        s(Icons.phone_iphone_rounded, 'Right now', 'Şu an olanlar',
            'Konuşma anında devam eden eylemleri anlatırsın.', const [
          'I am studying English.',
          'She is cooking dinner.',
          'They are playing football.',
          'Are you listening?',
        ]),
        s(Icons.image_rounded, 'Describe a photo', 'Fotoğrafı tarif etmek',
            'Fotoğrafta insanların ne yaptığını anlatırsın.', const [
          'The boy is running.',
          'Two women are talking.',
          'The children are smiling.',
        ]),
      ];
    case 'a1_can_cant':
      return [
        s(
            Icons.volunteer_activism_rounded,
            'Ask for help',
            'Yardım istemek',
            'Yapabildiğin şeyi söylemek veya yardım istemek için kullanılır.',
            const [
              'Can you help me?',
              'I can help you now.',
              'Can I ask a question?',
            ]),
        s(Icons.music_note_rounded, 'Abilities', 'Yetenekler',
            'Bir şeyi yapıp yapamadığını anlatırsın.', const [
          'I can swim.',
          'She can sing.',
          "He can't drive.",
          "They can't come today.",
        ]),
      ];
    case 'a1_have_has_got':
      return [
        s(Icons.inventory_2_rounded, 'Personal things', 'Kişisel eşyalar',
            'Çantanda, evinde veya ailende ne olduğunu söylersin.', const [
          'I have got a pen.',
          'She has got a brother.',
          'We have got a small house.',
        ]),
        s(Icons.help_rounded, 'Ask about things', 'Eşya sormak',
            'Birinde gerekli eşya var mı diye sorarsın.', const [
          'Have you got a pencil?',
          'Has she got a phone?',
          'Have they got tickets?',
        ]),
      ];
    case 'a1_basic_prepositions':
      return [
        s(Icons.place_rounded, 'Find things', 'Eşyaları bulmak',
            'Bir şeyin nerede olduğunu söylerken kullanılır.', const [
          'The bag is on the chair.',
          'The keys are in my pocket.',
          'She is at school.',
        ]),
        s(Icons.schedule_rounded, 'Time words', 'Zaman söylemek',
            'Saat, gün ve daha geniş zaman ifadelerinde kullanılır.', const [
          'The class is at nine.',
          'The meeting is on Monday.',
          'My birthday is in May.',
        ]),
      ];
    case 'a1_imperatives':
      return [
        s(Icons.campaign_rounded, 'Give instructions', 'Yönerge vermek',
            'Sınıfta veya evde kısa ve net yönergeler verirsin.', const [
          'Open your book.',
          'Listen carefully.',
          'Please sit down.',
          "Don't run.",
        ]),
        s(Icons.touch_app_rounded, 'Polite requests', 'Kibar rica',
            'Please ekleyerek komutu daha yumuşak söylersin.', const [
          'Please close the door.',
          'Please wait here.',
          'Please call me later.',
        ]),
      ];
    case 'a1_demonstratives':
      return [
        s(
            Icons.touch_app_rounded,
            'Point to things',
            'Yakındaki şeyleri göstermek',
            'Yakındaki veya uzaktaki şeyleri gösterirken kullanılır.', const [
          'This is my bag.',
          'That is your phone.',
          'These are my books.',
          'Those are your keys.',
        ]),
        s(Icons.image_rounded, 'Showing photos', 'Fotoğraf göstermek',
            'Fotoğraf veya ekrandaki kişileri ve eşyaları gösterirsin.', const [
          'This is my brother.',
          'That is our school.',
          'These are my friends.',
          'Those are old photos.',
        ]),
      ];
  }
  return const [];
}

List<_UsageSituationData> _usageSituationsForKey(
  String key,
  GrammarLesson lesson,
  List<GrammarFormulaRow> rows,
  bool isEnglish,
) {
  if (!isEnglish && key.startsWith('a1_')) {
    final cleanA1 = _cleanA1UsageSituationsForKey(key);
    if (cleanA1.isNotEmpty) return cleanA1;
  }

  // Build topic-aligned situation packs (3-5 useful sentences each).
  List<String> pool() {
    final list = <String>[
      ..._exampleBankForKey(key, true),
      ...lesson.examples,
      lesson.right,
      lesson.modelAnswer,
      ...rows.map((r) => r.sample),
      ...generateGrammarLogicPoints(lesson).map((p) => p.model),
    ]
        .map(_cleanOptionSentence)
        .where((s) =>
            s.isNotEmpty &&
            _isSentenceLike(s) &&
            !_looksLikeMetaOption(s) &&
            !_contextLooksTeacherish(s))
        .toList();
    final uniq = <String>[];
    for (final s in list) {
      if (!uniq.any((e) => e.toLowerCase() == s.toLowerCase())) uniq.add(s);
    }
    return uniq;
  }

  List<String> pick(bool Function(String) test, int max) {
    final out = <String>[];
    for (final s in pool()) {
      if (!test(s)) continue;
      out.add(s);
      if (out.length >= max) break;
    }
    return out;
  }

  bool isQuestion(String s) => s.trim().endsWith('?');
  bool isNegative(String s) {
    final l = s.toLowerCase();
    return l.contains("n?t") ||
        l.contains(' not ') ||
        l.startsWith("don't") ||
        l.startsWith("doesn't") ||
        l.startsWith("didn't");
  }

  List<_UsageSituationData> a1(List<_UsageSituationData> data) => data;

  switch (key) {
    case 'a1_be_verb':
      return a1(const [
        _UsageSituationData(
            icon: Icons.badge_rounded,
            titleEn: 'Introduce yourself',
            titleTr: 'Kendini tan1tmak',
            contextEn: 'First names, roles, and quick introductions.',
            contextTr: '?lk tan1_mada isim, rol ve k1sa bilgi verirsin.',
            sentences: [
              'I am Deniz.',
              'I am a student.',
              'She is my teacher.',
              'They are my friends.',
              'We are classmates.'
            ]),
        _UsageSituationData(
            icon: Icons.place_rounded,
            titleEn: 'Say where someone is',
            titleTr: 'Nerede oldu?unu s�ylemek',
            contextEn: 'Tell someone where a person or thing is.',
            contextTr: 'Bir kişinin veya e_yan1n nerede oldu?unu s�ylersin.',
            sentences: [
              'I am at home.',
              'She is in class.',
              'We are at school.',
              'The keys are on the table.',
              'My phone is in my bag.'
            ]),
        _UsageSituationData(
            icon: Icons.favorite_rounded,
            titleEn: 'Talk about feelings',
            titleTr: 'Duygular1 anlatmak',
            contextEn: 'Check in with people and answer simply.',
            contextTr: 'Birinin halini sorar veya k1sa cevap verirsin.',
            sentences: [
              'I am happy.',
              'He is tired.',
              'They are excited.',
              'Are you okay?',
              'She is nervous.'
            ]),
      ]);
    case 'a1_subject_pronouns':
      return a1(const [
        _UsageSituationData(
            icon: Icons.people_rounded,
            titleEn: 'Talk about people',
            titleTr: '0nsanlardan bahsetmek',
            contextEn: 'Keep talking without repeating every name.',
            contextTr: '0simleri sürekli tekrar etmeden konu?ursun.',
            sentences: [
              'Ali is my friend. He is funny.',
              'Ay_e is my sister. She is kind.',
              'My parents are here. They are happy.',
              'Ece is here. She is ready.',
              'Ali and Deniz are students. They are in class.'
            ]),
        _UsageSituationData(
            icon: Icons.inventory_2_rounded,
            titleEn: 'Talk about things',
            titleTr: 'E_yalardan bahsetmek',
            contextEn: 'Point back to things you already mentioned.',
            contextTr: 'Daha �nce s�yledi?in e_yalardan tekrar bahsedersin.',
            sentences: [
              'This bag is new. It is black.',
              'My keys are here. They are on the desk.',
              'The phone is old. It works well.',
              'The dog is sleeping. It is quiet.',
              'The books are new. They are expensive.'
            ]),
        _UsageSituationData(
            icon: Icons.reply_rounded,
            titleEn: 'After the verb',
            titleTr: 'Fiilden sonra',
            contextEn: 'Use object pronouns when someone receives the action.',
            contextTr: 'Eylemi alan kişi için nesne zamiri kullanırsın.',
            sentences: [
              'Can you help me?',
              'I can help you.',
              'She knows him.',
              'We like them.',
              'The teacher called us.'
            ]),
      ]);
    case 'a1_possessive_adjectives':
      return a1(const [
        _UsageSituationData(
            icon: Icons.backpack_rounded,
            titleEn: 'Talk about belongings',
            titleTr: 'Sahip oldu?un ?eyler',
            contextEn: 'Say whose bag, phone, room, or idea it is.',
            contextTr:
                '�anta, telefon, oda veya fikrin kime ait oldu?unu s�ylersin.',
            sentences: [
              'My bag is blue.',
              'Your phone is on the table.',
              'His bike is new.',
              'Her room is clean.',
              'Their house is small.'
            ]),
        _UsageSituationData(
            icon: Icons.family_restroom_rounded,
            titleEn: 'Talk about family',
            titleTr: 'Aileden bahsetmek',
            contextEn: 'Talk about people in your family naturally.',
            contextTr: 'Ailendeki kişilerden doğal _ekilde bahsedersin.',
            sentences: [
              'My mother is a nurse.',
              'His brother is tall.',
              'Her sister is at school.',
              'Our father is kind.',
              'Their parents are teachers.'
            ]),
        _UsageSituationData(
            icon: Icons.key_rounded,
            titleEn: 'Ask whose',
            titleTr: 'Kime ait diye sormak',
            contextEn: 'Ask and answer who owns a small object.',
            contextTr: 'K���k bir e_yan1n kime ait oldu?unu sorars1n.',
            sentences: [
              'Whose pen is this?',
              'It is Ece?s pen.',
              'This is my brother?s phone.',
              'That is Mert?s bag.',
              'This is her notebook.'
            ]),
      ]);
    case 'a1_there_is_are':
      return a1(const [
        _UsageSituationData(
            icon: Icons.meeting_room_rounded,
            titleEn: 'Describe a room',
            titleTr: 'Oday1 tarif etmek',
            contextEn: 'Describe what someone can find in a room.',
            contextTr: 'Bir odada neler oldu?unu anlat1rs1n.',
            sentences: [
              'There is a bed in my room.',
              'There are two chairs.',
              'There is a lamp on the desk.',
              'There are books on the shelf.',
              'There is a desk near the window.'
            ]),
        _UsageSituationData(
            icon: Icons.location_city_rounded,
            titleEn: 'Talk about a city',
            titleTr: '^ehirde ne var',
            contextEn: 'Ask about cafes, parks, buses, and places nearby.',
            contextTr: 'Yak1ndaki kafe, park, otob�s ve yerleri sorars1n.',
            sentences: [
              'There is a park near here.',
              'There are many cafes.',
              'There is a bank on this street.',
              'Are there any buses?',
              'There are five students in the room.'
            ]),
      ]);
    case 'a1_articles':
      return a1(const [
        _UsageSituationData(
            icon: Icons.shopping_bag_rounded,
            titleEn: 'Name one thing',
            titleTr: 'Bir ?ey istemek',
            contextEn: 'Ask for one item when the exact one is not important.',
            contextTr: 'Hangi tane oldu?u �nemli değilken bir ?ey istersin.',
            sentences: [
              'I need a pen.',
              'She has an umbrella.',
              'Can I have a ticket?',
              'He wants an apple.',
              'This is an easy question.'
            ]),
        _UsageSituationData(
            icon: Icons.visibility_rounded,
            titleEn: 'Talk about a known thing',
            titleTr: 'Bilinen şeyi anlatmak',
            contextEn: 'Refer to the thing both people already know.',
            contextTr: '?kinizin de bildi?i ?eyden tekrar bahsedersin.',
            sentences: [
              'I see a dog. The dog is small.',
              'This is a book. The book is new.',
              'There is a cafe. The cafe is open.',
              'I have a phone. The phone is old.',
              'She has a bag. The bag is red.'
            ]),
      ]);
    case 'a1_singular_plural':
      return a1(const [
        _UsageSituationData(
            icon: Icons.format_list_numbered_rounded,
            titleEn: 'Count things',
            titleTr: '^eyleri saymak',
            contextEn: 'Make shopping, classroom, or packing lists.',
            contextTr: 'Al1_veri_, s?n?f veya �anta listesi yapars1n.',
            sentences: [
              'I have two books.',
              'There are three boxes.',
              'We need four chairs.',
              'She has five pens.',
              'Six glasses are on the table.'
            ]),
        _UsageSituationData(
            icon: Icons.inventory_rounded,
            titleEn: 'Compare one and many',
            titleTr: 'Tekil ve �o?ul ay1rmak',
            contextEn: 'Move between one item and a group of items.',
            contextTr: 'Tek bir ?eyle bir grup şeyi ay1r1rs1n.',
            sentences: [
              'This is one bag.',
              'These are two bags.',
              'One child is here.',
              'Three children are here.',
              'Two women are talking.'
            ]),
        _UsageSituationData(
            icon: Icons.water_drop_rounded,
            titleEn: 'Talk about quantity',
            titleTr: 'Miktar s�ylemek',
            contextEn: 'Use simple quantity words in shopping or food talk.',
            contextTr:
                'Al1_veri_te veya yemekte temel miktar kelimeleri kullanırsın.',
            sentences: [
              'There is some milk.',
              'Are there any eggs?',
              'We need many apples.',
              'I drink a lot of water.',
              'How many books do you have?'
            ]),
      ]);
    case 'a1_present_simple':
      return a1(const [
        _UsageSituationData(
            icon: Icons.wb_sunny_rounded,
            titleEn: 'Daily routine',
            titleTr: 'G�nl�k rutin anlatmak',
            contextEn: 'Tell someone what your normal day looks like.',
            contextTr: 'Normal bir g�n�n�n nas1l ge�ti?ini anlat1rs1n.',
            sentences: [
              'I wake up at seven.',
              'She goes to school.',
              'We eat breakfast at home.',
              'They study English every day.',
              'The bus leaves at eight.'
            ]),
        _UsageSituationData(
            icon: Icons.favorite_rounded,
            titleEn: 'Habits and likes',
            titleTr: 'Al1_kanl1k ve zevkler',
            contextEn: 'Talk about what you like and usually do.',
            contextTr: 'Sevdi?in ve genelde yapt1?1n ?eyleri s�ylersin.',
            sentences: [
              'I like tea.',
              'He plays football on Sundays.',
              'She does not drink coffee.',
              'Do you watch TV at night?',
              'We sometimes eat out.'
            ]),
        _UsageSituationData(
            icon: Icons.public_rounded,
            titleEn: 'General facts',
            titleTr: 'Genel ger�ekler',
            contextEn: 'Share simple facts everyone understands.',
            contextTr: 'Herkesin bildi?i basit ger�ekleri s�ylersin.',
            sentences: [
              'Water boils at 100 degrees.',
              'The sun rises in the morning.',
              'Cats like milk.',
              'A teacher helps students.',
              'The shop opens at nine.'
            ]),
        _UsageSituationData(
            icon: Icons.travel_explore_rounded,
            titleEn: 'Ask for details',
            titleTr: 'Detay sormak',
            contextEn: 'Use wh- questions in everyday routines.',
            contextTr: 'G�nl�k rutinlerde wh-sorular1 kullanırsın.',
            sentences: [
              'Where do you live?',
              'When do you study?',
              'What does she like?',
              'How do they go to school?',
              'Why do you study English?'
            ]),
      ]);
    case 'a1_present_continuous':
      return a1(const [
        _UsageSituationData(
            icon: Icons.timelapse_rounded,
            titleEn: 'Say what is happening now',
            titleTr: '^u an ne oluyor',
            contextEn: 'Answer "What are you doing?" in the moment.',
            contextTr: 'O anda "Ne yap?yorsun?" sorusuna cevap verirsin.',
            sentences: [
              'I am studying now.',
              'She is reading a book.',
              'We are waiting for the bus.',
              'They are watching TV.',
              'He is cooking dinner.'
            ]),
        _UsageSituationData(
            icon: Icons.phone_iphone_rounded,
            titleEn: 'Explain your situation on the phone',
            titleTr: 'Telefonda durumunu anlatmak',
            contextEn: 'Explain why you are busy, late, or unavailable.',
            contextTr: 'Neden me_gul, ge� veya m�sait olmad??n1 s�ylersin.',
            sentences: [
              'I am coming now.',
              'I am working right now.',
              'We are eating lunch.',
              'Are you listening?',
              'I am not working today.'
            ]),
        _UsageSituationData(
            icon: Icons.image_rounded,
            titleEn: 'Describe a picture',
            titleTr: 'Foto?raf1 tarif etmek',
            contextEn: 'Describe what people are doing in a photo.',
            contextTr: 'Foto?rafta insanlar1n ne yapt1?1n1 anlat1rs1n.',
            sentences: [
              'A boy is running.',
              'Two women are talking.',
              'The dog is sleeping.',
              'The children are playing.',
              'A girl is drawing a picture.'
            ]),
      ]);
    case 'a1_can_cant':
      return a1(const [
        _UsageSituationData(
            icon: Icons.auto_awesome_rounded,
            titleEn: 'Talk about abilities',
            titleTr: 'Yeteneklerinden bahsetmek',
            contextEn: 'Talk about skills at school, work, or home.',
            contextTr: 'Okulda, i_te veya evde becerilerden bahsedersin.',
            sentences: [
              'I can swim.',
              'She can play the piano.',
              'We can speak English.',
              'He can\'t drive.',
              'They can cook dinner.'
            ]),
        _UsageSituationData(
            icon: Icons.volunteer_activism_rounded,
            titleEn: 'Ask for help',
            titleTr: 'Yard1m istemek',
            contextEn: 'Ask for quick help without sounding too formal.',
            contextTr: 'çok resmi olmadan h1zl1ca yard1m istersin.',
            sentences: [
              'Can you help me?',
              'Can you open the door?',
              'Can you repeat that?',
              'Can I ask a question?',
              'Can you speak slowly?'
            ]),
      ]);
    case 'a1_have_has_got':
      return a1(const [
        _UsageSituationData(
            icon: Icons.inventory_2_rounded,
            titleEn: 'Talk about things you have',
            titleTr: 'Sahip olduklar1n1 s�ylemek',
            contextEn: 'Say what is in your bag, home, or family.',
            contextTr: '�antanda, evinde veya ailende ne oldu?unu s�ylersin.',
            sentences: [
              'I have got a bike.',
              'She has got a brother.',
              'We have got a small house.',
              'They have got two cats.',
              'You have got a pen.'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask about possessions',
            titleTr: 'Birinde ne var sormak',
            contextEn: 'Check if someone has the thing you need.',
            contextTr: '0htiyac1n olan ?ey birinde var m1 diye sorars1n.',
            sentences: [
              'Have you got a pen?',
              'Has he got a car?',
              'Have they got homework?',
              'Has she got a phone?',
              'Have we got enough time?'
            ]),
      ]);
    case 'a1_basic_prepositions':
      return a1(const [
        _UsageSituationData(
            icon: Icons.place_rounded,
            titleEn: 'Say where something is',
            titleTr: 'Nerede oldu?unu s�ylemek',
            contextEn: 'Help someone find a person or object.',
            contextTr: 'Bir kişiyi veya e_yay1 bulmas1na yard1m edersin.',
            sentences: [
              'The book is on the table.',
              'My phone is in my bag.',
              'She is at school.',
              'We are in the room.',
              'The clock is on the wall.'
            ]),
        _UsageSituationData(
            icon: Icons.schedule_rounded,
            titleEn: 'Talk about time',
            titleTr: 'Zamandan bahsetmek',
            contextEn: 'Make simple plans with times and days.',
            contextTr: 'Saat ve g�nlerle basit plan yapars1n.',
            sentences: [
              'The lesson starts at seven.',
              'We meet on Monday.',
              'My birthday is in June.',
              'I study at night.',
              'We meet at the bus stop.'
            ]),
      ]);
    case 'a1_imperatives':
      return a1(const [
        _UsageSituationData(
            icon: Icons.campaign_rounded,
            titleEn: 'Give simple instructions',
            titleTr: 'K1sa y�nerge vermek',
            contextEn: 'Give clear instructions in class or at home.',
            contextTr: 'S?n?fta veya evde net y�nergeler verirsin.',
            sentences: [
              'Open the door.',
              'Please sit down.',
              'Listen carefully.',
              'Write your name.',
              'Read the sentence aloud.'
            ]),
        _UsageSituationData(
            icon: Icons.remove_circle_outline_rounded,
            titleEn: 'Say what not to do',
            titleTr: 'Yapma demek',
            contextEn: 'Warn someone quickly and clearly.',
            contextTr: 'Birini h1zl1 ve net _ekilde uyar1rs1n.',
            sentences: [
              'Don\'t run.',
              'Don\'t touch that.',
              'Do not open the window.',
              'Please don\'t be late.',
              'Don\'t use your phone here.'
            ]),
      ]);
    case 'a1_demonstratives':
      return a1(const [
        _UsageSituationData(
            icon: Icons.touch_app_rounded,
            titleEn: 'Point to near things',
            titleTr: 'Yak1ndaki şeyi g�stermek',
            contextEn: 'Show things close to you while shopping or talking.',
            contextTr:
                'Al1_veri_te veya konu?urken yak?ndaki ?eyleri gösterirsin.',
            sentences: [
              'This is my phone.',
              'This bag is heavy.',
              'These are my keys.',
              'These shoes are new.',
              'This book is new.'
            ]),
        _UsageSituationData(
            icon: Icons.near_me_rounded,
            titleEn: 'Point to far things',
            titleTr: 'Uzaktaki şeyi g�stermek',
            contextEn: 'Point to things farther away from you.',
            contextTr: 'Senden uzakta duran ?eyleri gösterirsin.',
            sentences: [
              'That is your car.',
              'That house is big.',
              'Those are my friends.',
              'Those books are old.',
              'Those shoes are cheap.'
            ]),
      ]);
  }
  final curatedA2 = _curatedA2UsageSituations(key);
  if (curatedA2.isNotEmpty) return curatedA2;
  if (key == 'a2_past_simple' || key.contains('past_simple')) {
    return [
      _UsageSituationData(
        icon: Icons.calendar_month_rounded,
        titleEn: 'Talk about yesterday',
        titleTr: 'D�n ne yapt1?1n1 anlatmak',
        contextEn: 'You?re telling someone what happened and it\'s finished.',
        contextTr: 'Bitmi? olaylar1 anlat1yorsun.',
        sentences: pick((s) => !isQuestion(s) && !isNegative(s), 5),
      ),
      _UsageSituationData(
        icon: Icons.help_rounded,
        titleEn: 'Ask about the past',
        titleTr: 'Geçmişte olan1 sormak',
        contextEn: 'Use did + V1 questions.',
        contextTr: 'Did + V1 ile soru sor.',
        sentences: pick(isQuestion, 5),
      ),
      _UsageSituationData(
        icon: Icons.cancel_rounded,
        titleEn: 'Say it didn\'t happen',
        titleTr: 'Olmad1?1n1 s�ylemek',
        contextEn: 'Use didn\'t + V1 (not V2).',
        contextTr: 'didn\'t + V1 kullan (V2 değil).',
        sentences: pick(isNegative, 5),
      ),
    ];
  }

  if (key.contains('present_perfect')) {
    return [
      _UsageSituationData(
        icon: Icons.travel_explore_rounded,
        titleEn: 'Life experiences',
        titleTr: 'Deneyim konu_mas1',
        contextEn: 'Ever/never questions and answers.',
        contextTr: 'Ever/never ile deneyim sor/cevapla.',
        sentences: pick(
            (s) =>
                s.toLowerCase().contains('ever') ||
                s.toLowerCase().contains('never') ||
                isQuestion(s),
            5),
      ),
      _UsageSituationData(
        icon: Icons.task_alt_rounded,
        titleEn: 'Recent results',
        titleTr: 'Yeni sonuçlar',
        contextEn: 'Already/yet/just.',
        contextTr: 'Already/yet/just gibi ipu�lar1yla.',
        sentences: pick(
            (s) =>
                s.toLowerCase().contains('already') ||
                s.toLowerCase().contains('yet') ||
                s.toLowerCase().contains('just'),
            5),
      ),
      _UsageSituationData(
        icon: Icons.schedule_rounded,
        titleEn: 'Unfinished time',
        titleTr: 'Bitmemi_ zaman',
        contextEn: 'This week/today/so far.',
        contextTr: 'This week/today/so far gibi ?bitmemi_? zamanlar.',
        sentences: pick(
            (s) =>
                s.toLowerCase().contains('this week') ||
                s.toLowerCase().contains('today') ||
                s.toLowerCase().contains('so far') ||
                s.toLowerCase().contains('for ') ||
                s.toLowerCase().contains('since '),
            5),
      ),
    ];
  }

  if (key == 'a2_should') {
    return [
      _UsageSituationData(
        icon: Icons.volunteer_activism_rounded,
        titleEn: 'Give advice',
        titleTr: 'Tavsiye vermek',
        contextEn: 'Friendly recommendation.',
        contextTr: 'Arkada_�a �neri.',
        sentences: pick(
            (s) =>
                s.toLowerCase().contains('should') ||
                s.toLowerCase().contains('ought to') ||
                s.toLowerCase().contains('had better'),
            5),
      ),
      _UsageSituationData(
        icon: Icons.remove_circle_outline_rounded,
        titleEn: 'Negative advice',
        titleTr: 'Olumsuz tavsiye',
        contextEn: 'Say what is a bad idea.',
        contextTr: 'K�t� fikir oldu?unu s�yle.',
        sentences: pick((s) => s.toLowerCase().contains("shouldn't"), 5),
      ),
    ];
  }

  if (key.contains('passive')) {
    return [
      _UsageSituationData(
        icon: Icons.newspaper_rounded,
        titleEn: 'News / report',
        titleTr: 'Haber / rapor dili',
        contextEn: 'Focus on what happened, not who did it.',
        contextTr: 'Yapan kişiden çok olan olaya odaklan.',
        sentences: pick(
            (s) =>
                s.toLowerCase().contains('was ') ||
                s.toLowerCase().contains('were ') ||
                s.toLowerCase().contains('is ') ||
                s.toLowerCase().contains('are '),
            5),
      ),
    ];
  }

  // Generic fallback: three mixed situation buckets.
  final positives = pick((s) => !isQuestion(s) && !isNegative(s), 4);
  final negatives = pick(isNegative, 4);
  final questions = pick(isQuestion, 4);
  final out = <_UsageSituationData>[];
  if (positives.isNotEmpty) {
    out.add(_UsageSituationData(
      icon: Icons.chat_bubble_rounded,
      titleEn: 'Natural use',
      titleTr: 'Do?al kullan1m',
      contextEn: 'Use it in a simple situation.',
      contextTr: 'Basit bir durumda kullan.',
      sentences: positives,
    ));
  }
  if (questions.isNotEmpty) {
    out.add(_UsageSituationData(
      icon: Icons.help_rounded,
      titleEn: 'Ask and reply',
      titleTr: 'Sor ve cevapla',
      contextEn: 'A short question pattern.',
      contextTr: 'K1sa soru kal?b?.',
      sentences: questions,
    ));
  }
  if (negatives.isNotEmpty) {
    out.add(_UsageSituationData(
      icon: Icons.cancel_rounded,
      titleEn: 'Say "no"',
      titleTr: 'Olumsuz s�yle',
      contextEn: 'A negative version in context.',
      contextTr: 'Ba?lam içinde olumsuz hali.',
      sentences: negatives,
    ));
  }
  return out;
}

List<_UsageSituationData> _curatedA2UsageSituations(String key) {
  switch (key) {
    case 'a2_past_simple':
      return const [
        _UsageSituationData(
            icon: Icons.calendar_month_rounded,
            titleEn: 'Talk about yesterday',
            titleTr: 'D�n ne yapt1?1n1 anlatmak',
            contextEn: 'Finished actions from a clear past time.',
            contextTr: 'Geçmişte ba_lay1p bitmiş olaylar1 anlat1rs1n.',
            sentences: [
              'I watched a movie last night.',
              'We visited my uncle yesterday.',
              'She cleaned her room.',
              'They played football after school.',
              'He cooked dinner at home.'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask about the past',
            titleTr: 'Geçmişte olan bir şeyi sormak',
            contextEn: 'Use did to ask about finished events.',
            contextTr: 'Bitmi? olaylar1 did ile sorars1n.',
            sentences: [
              'Did you call your teacher?',
              'Where did you go yesterday?',
              'What did you eat for breakfast?',
              'Did they arrive on time?',
              'When did the lesson start?'
            ]),
        _UsageSituationData(
            icon: Icons.schedule_rounded,
            titleEn: 'Use past time words',
            titleTr: 'Ge�mi_ zaman ifadeleri kullanmak',
            contextEn: 'Time words make the past moment clear.',
            contextTr: 'Zaman ifadesi olay1n ne zaman bitti?ini gösterir.',
            sentences: [
              'I moved here in 2020.',
              'She learned to swim when she was a child.',
              'We met two days ago.',
              'He bought this phone last week.',
              'They travelled to Izmir last summer.'
            ]),
      ];
    case 'a2_will':
      return const [
        _UsageSituationData(
            icon: Icons.flash_on_rounded,
            titleEn: 'Make a quick decision',
            titleTr: 'Anl1k karar vermek',
            contextEn: 'Decide while you are speaking.',
            contextTr: 'Konu?urken karar verirsin.',
            sentences: [
              'I will answer the phone.',
              'We will take a taxi.',
              'I will send the file now.',
              'She will ask the teacher.',
              'I will open the window.'
            ]),
        _UsageSituationData(
            icon: Icons.volunteer_activism_rounded,
            titleEn: 'Offer or promise',
            titleTr: 'Teklif etmek veya söz vermek',
            contextEn: 'Use will when you offer help or make a promise.',
            contextTr: 'Yard1m teklif ederken veya söz verirken kullanırsın.',
            sentences: [
              'I will help you with the bags.',
              'I will call you tonight.',
              'We will wait for you.',
              'I will not tell anyone.',
              'She will bring your book tomorrow.'
            ]),
        _UsageSituationData(
            icon: Icons.cloud_rounded,
            titleEn: 'Make a prediction',
            titleTr: 'Tahmin yapmak',
            contextEn: 'Say what you think will happen.',
            contextTr: 'Gelecekte ne olaca?1n1 d�_�nd�?�n� s�ylersin.',
            sentences: [
              'I think it will rain tomorrow.',
              'Maybe they will arrive soon.',
              'The test will probably be easy.',
              'She will like this song.',
              'It will be cold tonight.'
            ]),
      ];
    case 'a2_going_to':
      return const [
        _UsageSituationData(
            icon: Icons.event_available_rounded,
            titleEn: 'Talk about plans',
            titleTr: 'Planlardan bahsetmek',
            contextEn: 'Use it for plans you already have.',
            contextTr: '�nceden d�_�nd�?�n planlar1 anlat1rs1n.',
            sentences: [
              'I am going to study tonight.',
              'She is going to visit her aunt this weekend.',
              'We are going to start soon.',
              'They are going to travel next summer.',
              'My sister is going to call you after dinner.'
            ]),
        _UsageSituationData(
            icon: Icons.visibility_rounded,
            titleEn: 'Use visible evidence',
            titleTr: 'G�r�nen kan1ta g�re tahmin etmek',
            contextEn: 'The situation now points to the future.',
            contextTr: '^u an g�rd�?�n durum gelece?e i?aret eder.',
            sentences: [
              'Look at the clouds. It is going to rain.',
              'Be careful. The glass is going to fall.',
              'She looks tired. She is going to sleep soon.',
              'The team is playing badly. They are going to lose.',
              'The traffic is terrible. We are going to be late.'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask about plans',
            titleTr: 'Plan sormak',
            contextEn: 'Ask what someone has decided to do.',
            contextTr: 'Birinin ne yapmay1 planlad1?1n1 sorars1n.',
            sentences: [
              'Are you going to buy it?',
              'What are you going to do tonight?',
              'Is she going to join us?',
              'Are they going to stay here?',
              'When are we going to leave?'
            ]),
      ];
    case 'a2_comparatives':
      return const [
        _UsageSituationData(
            icon: Icons.shopping_bag_rounded,
            titleEn: 'Compare products',
            titleTr: '�r�nleri kar?la?t?rmak',
            contextEn: 'Choose between two things.',
            contextTr: '?ki ?ey aras1nda se�im yapars1n.',
            sentences: [
              'This bag is cheaper than that one.',
              'The black phone is more expensive than the blue one.',
              'This jacket is warmer than mine.',
              'The small laptop is lighter than the old one.',
              'This answer is better than the first one.'
            ]),
        _UsageSituationData(
            icon: Icons.directions_bus_rounded,
            titleEn: 'Compare travel options',
            titleTr: 'Yolculuk seçeneklerini kar?la?t?rmak',
            contextEn: 'Talk about speed, price and comfort.',
            contextTr: 'H1z, fiyat ve rahatl1k kar?la?t?r1rs1n.',
            sentences: [
              'The train is faster than the bus.',
              'The bus is a little cheaper than the train.',
              'This route is much longer than the other one.',
              'The taxi is more comfortable than the bus.',
              'Walking is slower than taking the metro.'
            ]),
        _UsageSituationData(
            icon: Icons.location_city_rounded,
            titleEn: 'Compare places',
            titleTr: 'Yerleri kar?la?t?rmak',
            contextEn: 'Describe differences between cities or places.',
            contextTr: '^ehirler veya yerler aras1ndaki farklar1 anlat1rs1n.',
            sentences: [
              'Kayseri is colder than Antalya.',
              'This cafe is quieter than the old cafe.',
              'My room is bigger than my brother?s room.',
              'The park is cleaner than the street.',
              'The city center is busier than my neighborhood.'
            ]),
      ];
    case 'a2_superlatives':
      return const [
        _UsageSituationData(
            icon: Icons.school_rounded,
            titleEn: 'Talk about a class',
            titleTr: 'S?n?ftaki enleri anlatmak',
            contextEn: 'Choose one person or thing in a group.',
            contextTr:
                'Bir grup içindeki en belirgin kişiyi veya şeyi s�ylersin.',
            sentences: [
              'She is the tallest student in the class.',
              'This is the easiest exercise today.',
              'Monday is the busiest day for me.',
              'He is the youngest in his family.',
              'This is the most useful rule in the lesson.'
            ]),
        _UsageSituationData(
            icon: Icons.restaurant_rounded,
            titleEn: 'Recommend the best place',
            titleTr: 'En iyi yeri �nermek',
            contextEn: 'Say which place is number one for you.',
            contextTr: 'Senin için en iyi yeri s�ylersin.',
            sentences: [
              'This is the best restaurant in town.',
              'It is the cheapest cafe near school.',
              'That shop has the most delicious cakes.',
              'This park is the quietest place here.',
              'The small cafe has the best tea.'
            ]),
        _UsageSituationData(
            icon: Icons.emoji_events_rounded,
            titleEn: 'Talk about records',
            titleTr: 'Rekorlardan ve u� noktalardan bahsetmek',
            contextEn: 'Use superlatives for the top point.',
            contextTr: 'En �st noktay1 anlat1rs1n.',
            sentences: [
              'Mount Everest is the highest mountain in the world.',
              'This was the worst day of the trip.',
              'She is the best player on the team.',
              'That was the most exciting match of all.',
              'This is the longest river in the country.'
            ]),
      ];
    case 'a2_countable_uncountable':
    case 'a2_some_any_much_many':
    case 'a2_quantifiers':
      return const [
        _UsageSituationData(
            icon: Icons.shopping_cart_rounded,
            titleEn: 'Make a shopping list',
            titleTr: 'Al1_veri_ listesi yapmak',
            contextEn: 'Use quantity words with food and items.',
            contextTr: 'Yiyecek ve e_yalar için miktar s�ylersin.',
            sentences: [
              'We need some eggs.',
              'There is not much milk left.',
              'I want a few apples.',
              'We have a lot of rice.',
              'Do we need any bread?'
            ]),
        _UsageSituationData(
            icon: Icons.school_rounded,
            titleEn: 'Talk about school work',
            titleTr: 'Okul i_leri hakk1nda konu_mak',
            contextEn: 'Talk about homework, questions and time.',
            contextTr: '�dev, soru ve zaman miktar1n1 anlat1rs1n.',
            sentences: [
              'I have a lot of homework tonight.',
              'She asked a few questions.',
              'We do not have much time.',
              'There are many students in the room.',
              'Do you have any notes from the lesson?'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask about amounts',
            titleTr: 'Miktar sormak',
            contextEn: 'Use much, many and any in questions.',
            contextTr: 'Sorularda much, many ve any kullanırsın.',
            sentences: [
              'How much water do you drink?',
              'How many chairs are there?',
              'Do you have any money?',
              'Is there much traffic today?',
              'Are there many buses at night?'
            ]),
      ];
    case 'a2_should':
      return const [
        _UsageSituationData(
            icon: Icons.health_and_safety_rounded,
            titleEn: 'Give health advice',
            titleTr: 'Sa?l1k tavsiyesi vermek',
            contextEn: 'Suggest a good idea for a health problem.',
            contextTr: 'Bir sa?l1k problemi için iyi fikir s�ylersin.',
            sentences: [
              'You should drink more water.',
              'You should rest today.',
              'You should see a doctor.',
              'You should not sleep late.',
              'Maybe you should eat something warm.'
            ]),
        _UsageSituationData(
            icon: Icons.school_rounded,
            titleEn: 'Give school advice',
            titleTr: 'Okul için tavsiye vermek',
            contextEn: 'Help someone make a better study choice.',
            contextTr: 'Birine daha iyi �al1_ma se�ene?i �nerirsin.',
            sentences: [
              'You should review your notes.',
              'You should ask the teacher.',
              'You should not study all night.',
              'You should practise before the test.',
              'You should check your answers.'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask for advice',
            titleTr: 'Tavsiye istemek',
            contextEn: 'Ask what the best choice is.',
            contextTr: 'En iyi se�ene?in ne oldu?unu sorars1n.',
            sentences: [
              'Should I call her now?',
              'Should we take a taxi?',
              'What should I wear?',
              'Where should we meet?',
              'Should he tell his parents?'
            ]),
      ];
    case 'a2_must_have_to':
      return const [
        _UsageSituationData(
            icon: Icons.rule_rounded,
            titleEn: 'Explain rules',
            titleTr: 'Kurallar1 a�1klamak',
            contextEn: 'Talk about what is required or forbidden.',
            contextTr: 'Neyin zorunlu ya da yasak oldu?unu s�ylersin.',
            sentences: [
              'You must wear a seat belt.',
              'Students must be quiet in the library.',
              'You must not smoke here.',
              'Visitors must show their ID.',
              'We must turn off our phones.'
            ]),
        _UsageSituationData(
            icon: Icons.work_rounded,
            titleEn: 'Talk about duties',
            titleTr: 'G�revlerden bahsetmek',
            contextEn: 'Use have to for work, school and daily duties.',
            contextTr: '?, okul ve g�nl�k mecburiyetleri anlat1rs1n.',
            sentences: [
              'I have to finish my homework.',
              'She has to wake up early.',
              'We have to clean the classroom.',
              'He has to work tomorrow.',
              'They have to wear a uniform.'
            ]),
        _UsageSituationData(
            icon: Icons.event_available_rounded,
            titleEn: 'Say it is optional',
            titleTr: 'Mecbur olmad??n1 s�ylemek',
            contextEn: 'Use do not have to when there is no necessity.',
            contextTr: 'Zorunluluk yoksa do not have to kullanırsın.',
            sentences: [
              'You do not have to come early.',
              'She does not have to bring food.',
              'We do not have to pay today.',
              'He does not have to stay after class.',
              'They do not have to finish it tonight.'
            ]),
      ];
    case 'a2_object_possessive_pronouns':
      return const [
        _UsageSituationData(
            icon: Icons.volunteer_activism_rounded,
            titleEn: 'Help people',
            titleTr: '0nsanlara yard1m etmek',
            contextEn: 'Use object pronouns after verbs.',
            contextTr: 'Fiilden sonra nesne zamiri kullanırsın.',
            sentences: [
              'Can you help me?',
              'I can help you after class.',
              'She knows him well.',
              'We like them a lot.',
              'The teacher called us.'
            ]),
        _UsageSituationData(
            icon: Icons.backpack_rounded,
            titleEn: 'Talk about belongings',
            titleTr: 'E_yalar1n kime ait oldu?unu s�ylemek',
            contextEn: 'Use possessive pronouns without a noun.',
            contextTr: 'Sahiplik zamirlerini isim olmadan kullanırsın.',
            sentences: [
              'This book is mine.',
              'That phone is yours.',
              'The blue bag is hers.',
              'These seats are ours.',
              'The red bikes are theirs.'
            ]),
        _UsageSituationData(
            icon: Icons.swap_horiz_rounded,
            titleEn: 'Return things',
            titleTr: 'E_yalar1 sahibine vermek',
            contextEn: 'Use object and possessive pronouns together.',
            contextTr: 'Nesne ve sahiplik zamirlerini birlikte kullanırsın.',
            sentences: [
              'Give it to him.',
              'Mine is in my bag.',
              'I will take them to her.',
              'Is this notebook yours?',
              'Those books are not ours.'
            ]),
      ];
    case 'a2_adverbs_frequency_manner':
      return const [
        _UsageSituationData(
            icon: Icons.schedule_rounded,
            titleEn: 'Talk about routines',
            titleTr: 'Rutinlerden bahsetmek',
            contextEn: 'Use frequency adverbs for habits.',
            contextTr: 'Al1_kanl1klar için s?kl?k zarflar1 kullanırsın.',
            sentences: [
              'I usually walk to school.',
              'She often studies after dinner.',
              'We sometimes eat out.',
              'He never drinks coffee.',
              'They always arrive on time.'
            ]),
        _UsageSituationData(
            icon: Icons.speed_rounded,
            titleEn: 'Say how something happens',
            titleTr: 'Bir şeyin nas1l oldu?unu anlatmak',
            contextEn: 'Use manner adverbs to describe an action.',
            contextTr: 'Eylemin nas1l yap?ld1?1n1 durum zarf1yla s�ylersin.',
            sentences: [
              'She speaks slowly.',
              'He drives carefully.',
              'They worked quietly.',
              'My sister speaks English well.',
              'Please write clearly.'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask about habits and manner',
            titleTr: 'Al1_kanl1k ve tarz sormak',
            contextEn: 'Ask how often or how something happens.',
            contextTr: 'Ne kadar s?k ya da nas1l oldu?unu sorars1n.',
            sentences: [
              'Do you usually walk to school?',
              'How often do you study English?',
              'Does she speak quickly?',
              'Are you ever late?',
              'How carefully does he drive?'
            ]),
      ];
    case 'a2_infinitive_purpose':
      return const [
        _UsageSituationData(
            icon: Icons.local_grocery_store_rounded,
            titleEn: 'Explain why you went somewhere',
            titleTr: 'Bir yere neden gitti?ini a�1klamak',
            contextEn: 'Use to + V1 after a movement action.',
            contextTr: 'Gitme eyleminden sonra amac1 s�ylersin.',
            sentences: [
              'I went to the shop to buy bread.',
              'She went to the library to study.',
              'We came here to meet you.',
              'He went outside to call his mother.',
              'They travelled to Istanbul to see friends.'
            ]),
        _UsageSituationData(
            icon: Icons.build_rounded,
            titleEn: 'Explain why you used something',
            titleTr: 'Bir şeyi neden kulland1?1n1 a�1klamak',
            contextEn: 'Use to + V1 to show purpose.',
            contextTr: 'Ama� g�stermek için to + V1 kullanırsın.',
            sentences: [
              'I use my phone to check emails.',
              'She opened the window to get fresh air.',
              'We saved money to buy a bike.',
              'He took a taxi to be on time.',
              'I called Deniz to ask a question.'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask about purpose',
            titleTr: 'Ama� sormak',
            contextEn: 'Ask why someone did something.',
            contextTr: 'Birinin bir şeyi neden yapt1?1n1 sorars1n.',
            sentences: [
              'Why did you go to the shop?',
              'Did you call to ask a question?',
              'What did you buy to make dinner?',
              'Did she come early to study?',
              'Did he study to pass the exam?'
            ]),
      ];
    case 'a2_gerund_infinitive':
      return const [
        _UsageSituationData(
            icon: Icons.favorite_rounded,
            titleEn: 'Talk about likes',
            titleTr: 'Sevdi?in ?eylerden bahsetmek',
            contextEn: 'Use -ing after enjoy, like, love and hate.',
            contextTr: 'Enjoy, like, love ve hate sonras?nda -ing kullanırsın.',
            sentences: [
              'I enjoy reading comics.',
              'She likes swimming in summer.',
              'He hates waiting for buses.',
              'We love playing games together.',
              'They enjoy cooking at home.'
            ]),
        _UsageSituationData(
            icon: Icons.task_alt_rounded,
            titleEn: 'Talk about needs and plans',
            titleTr: '0htiya� ve planlardan bahsetmek',
            contextEn: 'Use to + V1 after want, need, decide and plan.',
            contextTr:
                'Want, need, decide ve plan sonras?nda to + V1 kullanırsın.',
            sentences: [
              'I want to learn English.',
              'She needs to finish her homework.',
              'We decided to stay home.',
              'He plans to borrow this book.',
              'They need to leave early.'
            ]),
        _UsageSituationData(
            icon: Icons.help_rounded,
            titleEn: 'Ask about choices',
            titleTr: 'Tercihleri ve planlar1 sormak',
            contextEn: 'Ask about likes, needs and decisions.',
            contextTr: 'Sevilen ?eyleri, ihtiya�lar1 ve kararlar1 sorars1n.',
            sentences: [
              'Do you enjoy reading?',
              'Do you want to borrow this one?',
              'What do you need to do today?',
              'Do you like studying at home?',
              'Did they decide to join us?'
            ]),
      ];
  }
  return const [];
}

class _UsageSituationCard extends StatefulWidget {
  final _UsageSituationData situation;
  final Color color;
  final bool isEnglish;
  final String highlightKey;

  const _UsageSituationCard(
      {required this.situation,
      required this.color,
      required this.isEnglish,
      required this.highlightKey});

  @override
  State<_UsageSituationCard> createState() => _UsageSituationCardState();
}

class _UsageSituationCardState extends State<_UsageSituationCard>
    with AutomaticKeepAliveClientMixin<_UsageSituationCard> {
  late bool expanded = !widget.highlightKey.startsWith('a1_') &&
      !widget.highlightKey.startsWith('a2_');

  static const _expandDuration = Duration(milliseconds: 220);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, widget.color);
    final preview = widget.situation.sentences.isEmpty
        ? ''
        : widget.situation.sentences.first;
    final showContentSupport =
        _showTurkishContentSupport(widget.highlightKey, widget.isEnglish);
    final contextText =
        showContentSupport ? widget.situation.context(widget.isEnglish) : '';
    return RepaintBoundary(
      child: _TapScale(
          onTap: () => setState(() => expanded = !expanded),
          child: AnimatedContainer(
            duration: _expandDuration,
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(14, 14, 14, expanded ? 14 : 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tokens.isLight
                    ? _grammarLightGlass(widget.color, strong: expanded)
                    : [
                        widget.color.withAlpha(expanded ? 31 : 15),
                        const Color(0xFF07111E).withAlpha(238),
                        Colors.white.withAlpha(expanded ? 11 : 5)
                      ],
              ),
              border: Border.all(
                  color: tokens.isLight
                      ? _grammarGlassBorder(
                          tokens,
                          accent: widget.color,
                          strong: expanded,
                        )
                      : expanded
                          ? widget.color.withAlpha(50)
                          : tokens.border),
              boxShadow: expanded
                  ? [
                      BoxShadow(
                          color: tokens.isLight
                              ? tokens.shadow
                              : widget.color.withAlpha(20),
                          blurRadius: 26,
                          offset: const Offset(0, 14))
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: widget.color.withAlpha(expanded ? 28 : 18),
                        border: Border.all(
                            color: widget.color.withAlpha(expanded ? 48 : 34)),
                      ),
                      child:
                          Icon(widget.situation.icon, color: accent, size: 18),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              widget.situation.title(
                                  showContentSupport ? widget.isEnglish : true),
                              style: TextStyle(
                                  color: tokens.textPrimary,
                                  fontSize: 14.2,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.12)),
                          if (contextText.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(contextText,
                                style: TextStyle(
                                    color: tokens.textSecondary,
                                    fontSize: 11.7,
                                    height: 1.25,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: expanded ? .5 : 0,
                      duration: _expandDuration,
                      curve: Curves.easeOutCubic,
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: tokens.iconSecondary, size: 22),
                    ),
                  ],
                ),
                if (preview.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _ExamplePreviewStrip(
                      sentence: preview,
                      color: widget.color,
                      compact: expanded,
                    ),
                  ),
                AnimatedSize(
                  duration: _expandDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.hardEdge,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            children: widget.situation.sentences
                                .asMap()
                                .entries
                                .map((entry) {
                              final i = entry.key;
                              final s = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: i ==
                                            widget.situation.sentences.length -
                                                1
                                        ? 0
                                        : 10),
                                child: _ExampleSentenceTile(
                                    index: i + 1,
                                    sentence: s,
                                    highlight: widget.color,
                                    faded: false,
                                    translation: showContentSupport
                                        ? _turkishExampleTranslation(
                                            widget.highlightKey, s)
                                        : null),
                              );
                            }).toList(growable: false),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          )),
    );
  }
}

class _ContextDialogueHeader extends StatelessWidget {
  final String situation;
  final String title;
  final String subtitle;
  final Color color;

  const _ContextDialogueHeader(
      {required this.situation,
      required this.title,
      required this.subtitle,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? _grammarLightGlass(color)
              : [
                  color.withAlpha(18),
                  const Color(0xFF07111E).withAlpha(238),
                  Colors.white.withAlpha(5)
                ],
        ),
        border: Border.all(
          color: tokens.isLight
              ? _grammarGlassBorder(tokens, accent: color)
              : tokens.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: color.withAlpha(18),
              border: Border.all(color: color.withAlpha(34)),
            ),
            child: Icon(Icons.forum_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_repairMojibake(title),
                    style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 14.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.12)),
                if (subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(_repairMojibake(subtitle),
                      style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 11.7,
                          height: 1.25,
                          fontWeight: FontWeight.w700)),
                ],
                if (situation.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: tokens.inputSurface,
                      border: Border.all(color: tokens.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_rounded, color: accent, size: 14),
                        const SizedBox(width: 6),
                        Text(_repairMojibake(situation),
                            style: TextStyle(
                                color: tokens.textSecondary,
                                fontSize: 10.9,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextTinyTip extends StatelessWidget {
  final String text;
  final Color color;
  final bool isEnglish;

  const _ContextTinyTip(
      {required this.text, required this.color, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: tokens.isLight
            ? LinearGradient(colors: _grammarLightGlass(color))
            : null,
        color: tokens.isLight ? null : tokens.elevatedSurface,
        border: Border.all(
          color: tokens.isLight
              ? _grammarGlassBorder(tokens, accent: color)
              : tokens.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEnglish ? text : '${t('Small tip:', 'Küçük ipucu:')} $text',
              style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12.0,
                  height: 1.35,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextPack {
  final IconData heroIcon;
  final List<IconData> backgroundIcons;
  final String title;
  final String subtitle;
  final String scene;
  final List<_ContextDialogueLine> dialogueLines;
  final List<_ContextScenario> scenarios;
  final String tip;

  const _ContextPack({
    required this.heroIcon,
    required this.backgroundIcons,
    required this.title,
    required this.subtitle,
    required this.scene,
    required this.dialogueLines,
    required this.scenarios,
    required this.tip,
  });

  static _ContextPack fromLesson(
      GrammarLesson lesson, List<GrammarFormulaRow> rows, bool isEnglish) {
    final pack = generateGrammarContextPack(lesson, isEnglish);
    final rawScenarios = pack.scenarios
        .map((scenario) => _ContextScenario(
              scenario.icon,
              scenario.title,
              scenario.sentence,
              scenario.note,
            ))
        .toList();
    final safeScenarios =
        _safeContextScenarios(lesson, rows, rawScenarios, isEnglish);
    final safeDialogue = _safeContextDialogue(
      lesson,
      pack.dialogueLines
          .map((line) => _ContextDialogueLine(line.speaker, line.text))
          .toList(),
      safeScenarios,
      isEnglish,
    );

    return _ContextPack(
      heroIcon: pack.heroIcon,
      backgroundIcons: pack.backgroundIcons,
      title: _shortContextTitle(pack.title, lesson),
      subtitle: _shortContextSubtitle(pack.subtitle, isEnglish),
      scene: _shortContextScene(pack.scene, isEnglish),
      dialogueLines: safeDialogue,
      scenarios: safeScenarios,
      tip: isEnglish ? pack.tip : grammarTurkishUsageSummaryFor(lesson),
    );
  }
}

String _shortContextTitle(String value, GrammarLesson lesson) {
  final clean = value.trim();
  if (clean.isEmpty || clean.length > 48) {
    return lesson.bigTitle.split('=').first.trim();
  }
  return clean;
}

String _shortContextSubtitle(String value, bool isEnglish) {
  final clean = value.trim();
  if (clean.isEmpty || clean.length > 54) {
    return isEnglish ? 'Use it in real situations.' : 'Gerçek durumda kullan.';
  }
  return clean;
}

String _shortContextScene(String value, bool isEnglish) {
  final clean = value.trim();
  if (clean.isEmpty || clean.length > 96) {
    return isEnglish
        ? 'Look at a short dialogue and ready-to-use example sentences.'
        : 'Kısa diyalog ve hazır örnek cümlelere bak.';
  }
  return clean;
}

List<_ContextScenario> _safeContextScenarios(
  GrammarLesson lesson,
  List<GrammarFormulaRow> rows,
  List<_ContextScenario> rawScenarios,
  bool isEnglish,
) {
  final blocked = <String>{
    _contextClean(lesson.wrong),
    ...generateGrammarLogicPoints(lesson)
        .map((point) => _contextClean(point.avoid)),
  }..removeWhere((value) => value.isEmpty);

  bool usable(_ContextScenario scenario) {
    final sentence = scenario.sentence.trim();
    final title = scenario.title.toLowerCase();
    if (!_contextLooksSentence(sentence)) return false;
    if (blocked.contains(_contextClean(sentence))) return false;
    if (_contextLooksTeacherish(
        '${scenario.title} ${scenario.sentence} ${scenario.note}')) {
      return false;
    }
    if (title.contains('mistake') ||
        title.contains('wrong') ||
        title.contains('avoid') ||
        title.contains('s?k hata') ||
        title.contains('hata')) {
      return false;
    }
    return true;
  }

  final result = <_ContextScenario>[];
  for (final scenario in rawScenarios) {
    if (result.length >= 4) break;
    if (usable(scenario) &&
        !result.any((item) =>
            _contextClean(item.sentence) == _contextClean(scenario.sentence))) {
      result.add(_neutralContextScenario(scenario, result.length, isEnglish));
    }
  }

  const icons = [
    Icons.chat_bubble_rounded,
    Icons.school_rounded,
    Icons.home_rounded,
    Icons.reply_rounded
  ];
  const titlesEn = [
    'Real situation',
    'Short scene',
    'Natural use',
    'Quick response'
  ];
  const titlesTr = [
    'Gerçek durum',
    'Kısa sahne',
    'Doğal kullanım',
    'Hızlı cevap'
  ];
  final candidates = _contextSentenceCandidates(lesson, rows, blocked);
  for (final sentence in candidates) {
    if (result.length >= 4) break;
    if (result.any(
        (item) => _contextClean(item.sentence) == _contextClean(sentence))) {
      continue;
    }
    final i = result.length;
    result.add(_ContextScenario(
      icons[i % icons.length],
      isEnglish ? titlesEn[i % titlesEn.length] : titlesTr[i % titlesTr.length],
      sentence,
      isEnglish
          ? 'Say this naturally in the situation.'
          : 'Bu durumda doğal şekilde kullan.',
    ));
  }

  if (result.isEmpty) {
    result.add(_ContextScenario(
      Icons.chat_bubble_rounded,
      isEnglish ? 'Real situation' : 'Gerçek durum',
      lesson.right.trim().isNotEmpty ? lesson.right.trim() : 'I am ready.',
      isEnglish
          ? 'Say this naturally in the situation.'
          : 'Bu durumda doğal şekilde kullan.',
    ));
  }
  return result;
}

_ContextScenario _neutralContextScenario(
    _ContextScenario scenario, int index, bool isEnglish) {
  const fallbackEn = [
    'Real situation',
    'Short scene',
    'Natural use',
    'Quick response'
  ];
  const fallbackTr = [
    'Gerçek durum',
    'Kısa sahne',
    'Doğal kullanım',
    'Hızlı cevap'
  ];
  final rawTitle = scenario.title.trim();
  final safeTitle = rawTitle.isNotEmpty &&
          !_contextLooksTeacherish(rawTitle) &&
          rawTitle.length <= 34
      ? rawTitle
      : (isEnglish
          ? fallbackEn[index % fallbackEn.length]
          : fallbackTr[index % fallbackTr.length]);
  return _ContextScenario(
    scenario.icon,
    safeTitle,
    scenario.sentence.trim(),
    isEnglish
        ? 'Say this naturally in the situation.'
        : 'Bu durumda doğal _ekilde kullan.',
  );
}

List<String> _contextSentenceCandidates(
    GrammarLesson lesson, List<GrammarFormulaRow> rows, Set<String> blocked) {
  final raw = <String>[
    ...lesson.examples,
    ...rows.map((row) => row.sample),
    lesson.right,
    ..._splitContextSentences(lesson.modelAnswer),
  ];

  final out = <String>[];
  for (final item in raw) {
    final sentence = item.trim();
    final clean = _contextClean(sentence);
    if (!_contextLooksSentence(sentence)) continue;
    if (blocked.contains(clean)) continue;
    if (_contextLooksTeacherish(sentence)) continue;
    if (out.any((value) => _contextClean(value) == clean)) continue;
    out.add(sentence);
  }
  return out;
}

List<String> _splitContextSentences(String value) {
  final matches = RegExp(r'[^.!?]+[.!?]').allMatches(value);
  return matches
      .map((m) => m.group(0)!.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

List<_ContextDialogueLine> _safeContextDialogue(
  GrammarLesson lesson,
  List<_ContextDialogueLine> rawLines,
  List<_ContextScenario> scenarios,
  bool isEnglish,
) {
  // Context must feel like real use, not another teaching block.  We first try
  // a topic-aware dialogue.  Raw generator lines are used only when they are
  // already natural and not meta-teacher language like "Notice the form".
  final topicDialogue =
      _topicAwareContextDialogue(lesson, scenarios, isEnglish);
  if (topicDialogue.length >= 2) return topicDialogue;

  final cleanedRaw = rawLines
      .where((line) =>
          _contextLooksSentence(line.text) &&
          !_contextLooksTeacherish(line.text) &&
          !_contextLooksMetaDialogue(line.text))
      .map((line) => _ContextDialogueLine(line.speaker, line.text.trim()))
      .toList();

  if (cleanedRaw.length >= 2) {
    return cleanedRaw.take(4).toList();
  }

  return _fallbackContextDialogue(scenarios, isEnglish);
}

List<_ContextDialogueLine> _topicAwareContextDialogue(
  GrammarLesson lesson,
  List<_ContextScenario> scenarios,
  bool isEnglish,
) {
  final key = _lessonKey(lesson);
  final s1 = _scenarioSentence(scenarios, 0, 'I am ready.');
  final s2 = _scenarioSentence(scenarios, 1, 'She is tired.');

  switch (key) {
    case 'a1_be_verb':
      return const [
        _ContextDialogueLine('A', 'Are you new here?'),
        _ContextDialogueLine('B', 'Yes, I am. I?m in Room 4.'),
        _ContextDialogueLine('A', 'Is your teacher kind?'),
        _ContextDialogueLine('B', 'Yes, he is.'),
      ];
    case 'a1_subject_pronouns':
      return const [
        _ContextDialogueLine('A', 'Where is Ali?'),
        _ContextDialogueLine('B', 'He is in the classroom.'),
        _ContextDialogueLine('A', 'And Ay_e?'),
        _ContextDialogueLine('B', 'She is at home.'),
      ];
    case 'a1_possessive_adjectives':
      return const [
        _ContextDialogueLine('A', 'Is this your phone?'),
        _ContextDialogueLine('B', 'No, my phone is in my bag.'),
        _ContextDialogueLine('A', 'Whose notebook is this?'),
        _ContextDialogueLine('B', 'It is her notebook.'),
      ];
    case 'a1_articles':
      return const [
        _ContextDialogueLine('A', 'What is that?'),
        _ContextDialogueLine('B', 'It is a bag.'),
        _ContextDialogueLine('A', 'Is the bag yours?'),
        _ContextDialogueLine('B', 'Yes, the bag is mine.'),
      ];
    case 'a1_singular_plural':
      return const [
        _ContextDialogueLine('A', 'How many books are on the desk?'),
        _ContextDialogueLine('B', 'There are two books.'),
        _ContextDialogueLine('A', 'Is there one pen?'),
        _ContextDialogueLine('B', 'Yes, there is one pen.'),
      ];
    case 'a1_demonstratives':
      return const [
        _ContextDialogueLine('A', 'Is this your bag?'),
        _ContextDialogueLine('B', 'Yes, this is my bag.'),
        _ContextDialogueLine('A', 'Are those your shoes?'),
        _ContextDialogueLine('B', 'No, those are my brother?s shoes.'),
      ];
    case 'a1_have_has_got':
      return const [
        _ContextDialogueLine('A', 'Have you got a phone?'),
        _ContextDialogueLine('B', 'Yes, I have got a phone.'),
        _ContextDialogueLine('A', 'Has your sister got a phone too?'),
        _ContextDialogueLine('B', 'Yes, she has got a phone.'),
      ];
    case 'a1_there_is_are':
      return const [
        _ContextDialogueLine('A', 'What is in the room?'),
        _ContextDialogueLine('B', 'There is a desk in the room.'),
        _ContextDialogueLine('A', 'Are there any chairs?'),
        _ContextDialogueLine('B', 'Yes, there are two chairs.'),
      ];
    case 'a1_can_cant':
      return const [
        _ContextDialogueLine('A', 'Can you help me, please?'),
        _ContextDialogueLine('B', 'Yes, I can.'),
        _ContextDialogueLine('A', 'Can your sister speak English?'),
        _ContextDialogueLine('B', 'No, she can\'t.'),
      ];
    case 'a1_imperatives':
      return const [
        _ContextDialogueLine('A', 'What should I do?'),
        _ContextDialogueLine('B', 'Open the door, please.'),
        _ContextDialogueLine('A', 'Can I run here?'),
        _ContextDialogueLine('B', 'No, do not run.'),
      ];
    case 'a1_present_simple':
      return const [
        _ContextDialogueLine('A', 'What time do you start work?'),
        _ContextDialogueLine('B', 'I start at 9.'),
        _ContextDialogueLine('A', 'Does she work on Sundays?'),
        _ContextDialogueLine('B', 'No, she doesn\'t.'),
      ];
    case 'a1_adverbs_frequency':
      return const [
        _ContextDialogueLine('A', 'How often do you study English?'),
        _ContextDialogueLine('B', 'I usually study at night.'),
        _ContextDialogueLine('A', 'Is he late to class?'),
        _ContextDialogueLine('B', 'No, he is never late.'),
      ];
    case 'a1_present_continuous':
      return const [
        _ContextDialogueLine('A', 'What are you doing right now?'),
        _ContextDialogueLine('B', 'I?m studying right now.'),
        _ContextDialogueLine('A', 'Is he coming?'),
        _ContextDialogueLine('B', 'Yes, he is.'),
      ];
    case 'a1_present_simple_vs_continuous':
      return const [
        _ContextDialogueLine('A', 'Do you study every day?'),
        _ContextDialogueLine('B', 'Yes, I study every day.'),
        _ContextDialogueLine('A', 'Are you studying now?'),
        _ContextDialogueLine('B', 'Yes, I am studying now.'),
      ];
    case 'a1_object_pronouns':
      return const [
        _ContextDialogueLine('A', 'Can you call Ali?'),
        _ContextDialogueLine('B', 'Yes, I can call him.'),
        _ContextDialogueLine('A', 'Can you help us?'),
        _ContextDialogueLine('B', 'Yes, I can help you.'),
      ];
    case 'a1_possessive_s':
      return const [
        _ContextDialogueLine('A', 'Whose book is this?'),
        _ContextDialogueLine('B', 'It is Ali?s book.'),
        _ContextDialogueLine('A', 'Whose phone is that?'),
        _ContextDialogueLine('B', 'It is my mother?s phone.'),
      ];
    case 'a1_prepositions_place':
      return const [
        _ContextDialogueLine('A', 'Where is the book?'),
        _ContextDialogueLine('B', 'The book is on the table.'),
        _ContextDialogueLine('A', 'Where are the keys?'),
        _ContextDialogueLine('B', 'They are in the bag.'),
      ];
    case 'a1_prepositions_time':
      return const [
        _ContextDialogueLine('A', 'When is the lesson?'),
        _ContextDialogueLine('B', 'The lesson starts at seven.'),
        _ContextDialogueLine('A', 'When do we meet?'),
        _ContextDialogueLine('B', 'We meet on Monday.'),
      ];
    case 'a1_some_any':
      return const [
        _ContextDialogueLine('A', 'Do you have any water?'),
        _ContextDialogueLine('B', 'Yes, I have some water.'),
        _ContextDialogueLine('A', 'Is there any milk?'),
        _ContextDialogueLine('B', 'No, there is not any milk.'),
      ];
    case 'a1_countable_uncountable':
      return const [
        _ContextDialogueLine('A', 'What do you need?'),
        _ContextDialogueLine('B', 'I need some water.'),
        _ContextDialogueLine('A', 'Do you need apples too?'),
        _ContextDialogueLine('B', 'Yes, I need two apples.'),
      ];
    case 'a1_how_much_many':
      return const [
        _ContextDialogueLine('A', 'How many books do you have?'),
        _ContextDialogueLine('B', 'I have three books.'),
        _ContextDialogueLine('A', 'How much water do you drink?'),
        _ContextDialogueLine('B', 'I drink a lot of water.'),
      ];
    case 'a1_question_words':
      return const [
        _ContextDialogueLine('A', 'Where do you live?'),
        _ContextDialogueLine('B', 'I live in Kayseri.'),
        _ContextDialogueLine('A', 'What is your name?'),
        _ContextDialogueLine('B', 'My name is Deniz.'),
      ];
    case 'a1_basic_conjunctions':
      return const [
        _ContextDialogueLine('A', 'Do you like tea?'),
        _ContextDialogueLine('B', 'I like tea and coffee.'),
        _ContextDialogueLine('A', 'Why are you tired?'),
        _ContextDialogueLine('B', 'I am tired because I work a lot.'),
      ];
  }

  if (s1.isNotEmpty && s2.isNotEmpty && s1 != s2) {
    return [
      _ContextDialogueLine(
          'A',
          isEnglish
              ? 'Can you give me an example?'
              : 'Can you give me an example?'),
      _ContextDialogueLine('B', s1),
      _ContextDialogueLine(
          'A', isEnglish ? 'And another one?' : 'And another one?'),
      _ContextDialogueLine('B', s2),
    ];
  }

  return const [];
}

String _scenarioSentence(
    List<_ContextScenario> scenarios, int index, String fallback) {
  if (index >= 0 && index < scenarios.length) {
    final text = scenarios[index].sentence.trim();
    if (_contextLooksSentence(text)) return text;
  }
  return fallback;
}

List<_ContextDialogueLine> _fallbackContextDialogue(
    List<_ContextScenario> scenarios, bool isEnglish) {
  final first = _scenarioSentence(scenarios, 0, 'I am ready.');
  final second = _scenarioSentence(scenarios, 1, 'She is tired.');
  return [
    _ContextDialogueLine(
        'A', isEnglish ? 'What can I say here?' : 'What can I say here?'),
    _ContextDialogueLine('B', first),
    _ContextDialogueLine(
        'A',
        isEnglish
            ? 'What about this situation?'
            : 'What about this situation?'),
    _ContextDialogueLine('B', second),
  ];
}

bool _contextLooksMetaDialogue(String value) {
  final text = value.toLowerCase().trim();
  return text.contains('look at this sentence') ||
      text.contains('what should i notice') ||
      text.contains('notice the') ||
      text.contains('exactly') ||
      text.contains('say:') ||
      text.contains('use this sentence') ||
      text.contains('one more example') ||
      text.contains('another example') ||
      text.contains('ready-to-use') ||
      text.contains('haz1r c�mle') ||
      text.contains('bu durum için');
}

bool _contextLooksSentence(String value) {
  final text = value.trim();
  return text.length >= 4 &&
      RegExp(r'[A-Za-z]').hasMatch(text) &&
      RegExp(r'[.!?]$').hasMatch(text);
}

bool _contextLooksTeacherish(String value) {
  final text = value.toLowerCase();
  return text.contains('avoid') ||
      text.contains('notice') ||
      text.contains('look at this sentence') ||
      text.contains('what should i notice') ||
      text.contains('exactly') ||
      text.contains('say:') ||
      text.contains('form:') ||
      text.contains('common mistake') ||
      text.contains('wrong') ||
      text.contains('correct form') ||
      text.contains('rule') ||
      text.contains('pattern') ||
      text.contains(' + ') ||
      text.contains('s?k hata') ||
      text.contains('hata') ||
      text.contains('kal1p') ||
      text.contains('dikkat') ||
      text.contains('kural');
}

String _contextClean(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

class _ContextDialogueLine {
  final String speaker;
  final String text;
  const _ContextDialogueLine(this.speaker, this.text);
}

class _UsageDialogueData {
  final IconData icon;
  final String title;
  final List<_ContextDialogueLine> lines;

  const _UsageDialogueData({
    required this.icon,
    required this.title,
    required this.lines,
  });
}

List<_UsageDialogueData> _premiumA1UsageDialogueSets(
    String key, bool isEnglish) {
  _UsageDialogueData d(IconData icon, String en, String tr,
          List<_ContextDialogueLine> lines) =>
      _UsageDialogueData(
        icon: icon,
        title: isEnglish ? en : tr,
        lines: lines,
      );

  switch (key) {
    case 'a1_be_verb':
      return [
        d(Icons.school_rounded, 'First day', 'İlk gün', const [
          _ContextDialogueLine('Ece', "Hi, I'm Ece. Are you new here?"),
          _ContextDialogueLine('Mert', "Yes, I am. I'm in Room 4."),
          _ContextDialogueLine('Ece', 'Are you ready for class?'),
          _ContextDialogueLine('Mert', 'Yes, I am.'),
        ]),
      ];
    case 'a1_subject_pronouns':
      return [
        d(Icons.people_rounded, 'In class', 'Sınıfta', const [
          _ContextDialogueLine('Ece', 'Where is Ali?'),
          _ContextDialogueLine('Mert', 'He is in the classroom.'),
          _ContextDialogueLine('Ece', 'Can you help me?'),
          _ContextDialogueLine('Mert', 'Sure. I can help you.'),
        ]),
      ];
    case 'a1_possessive_adjectives':
      return [
        d(Icons.backpack_rounded, 'Lost notebook', 'Kayıp defter', const [
          _ContextDialogueLine('Mert', 'Is this your notebook?'),
          _ContextDialogueLine('Ece', 'No, my notebook is in my bag.'),
          _ContextDialogueLine('Mert', 'Whose notebook is this?'),
          _ContextDialogueLine('Ece', 'It is her notebook.'),
        ]),
      ];
    case 'a1_articles':
      return [
        d(Icons.shopping_bag_rounded, 'At a shop', 'Mağazada', const [
          _ContextDialogueLine('Mert', 'I need a notebook.'),
          _ContextDialogueLine('Ece', 'There is an orange one here.'),
          _ContextDialogueLine('Mert', 'Is the notebook cheap?'),
          _ContextDialogueLine('Ece', 'Yes, it is.'),
        ]),
      ];
    case 'a1_singular_plural':
      return [
        d(Icons.format_list_numbered_rounded, 'Shopping list',
            'Alışveriş listesi', const [
          _ContextDialogueLine('Ece', 'Do we need any eggs?'),
          _ContextDialogueLine('Mert', 'Yes, we need six eggs.'),
          _ContextDialogueLine('Ece', 'How much water do we need?'),
          _ContextDialogueLine('Mert', 'A lot of water, please.'),
        ]),
      ];
    case 'a1_there_is_are':
      return [
        d(Icons.storefront_rounded, 'Near school', 'Okul yakınında', const [
          _ContextDialogueLine('Ece', 'Is there a cafe near school?'),
          _ContextDialogueLine('Mert', 'Yes, there is a small cafe.'),
          _ContextDialogueLine('Ece', 'Are there any buses?'),
          _ContextDialogueLine('Mert', 'Yes, there are many buses.'),
        ]),
      ];
    case 'a1_present_simple':
      return [
        d(Icons.wb_sunny_rounded, 'Morning routine', 'Sabah rutini', const [
          _ContextDialogueLine('Ece', 'What time do you get up?'),
          _ContextDialogueLine('Mert', 'I get up at seven.'),
          _ContextDialogueLine('Ece', 'Do you eat breakfast at home?'),
          _ContextDialogueLine('Mert', 'Yes, I do.'),
        ]),
      ];
    case 'a1_present_continuous':
      return [
        d(Icons.image_rounded, 'Photo', 'Fotoğraf', const [
          _ContextDialogueLine('Mert', 'Who is this in the photo?'),
          _ContextDialogueLine('Ece', 'That is my brother. He is running.'),
          _ContextDialogueLine('Mert', 'And your parents?'),
          _ContextDialogueLine('Ece', 'They are talking near the cafe.'),
        ]),
      ];
    case 'a1_can_cant':
      return [
        d(Icons.volunteer_activism_rounded, 'Quick help', 'Kısa yardım', const [
          _ContextDialogueLine('Ece', 'Can you help me with this form?'),
          _ContextDialogueLine('Mert', 'Sure, I can help you now.'),
          _ContextDialogueLine('Ece', 'Can I ask one more question?'),
          _ContextDialogueLine('Mert', 'Of course.'),
        ]),
      ];
    case 'a1_have_has_got':
      return [
        d(Icons.inventory_2_rounded, 'School bag', 'Okul çantası', const [
          _ContextDialogueLine('Ece', 'Have you got a pen?'),
          _ContextDialogueLine('Mert', 'Yes, I have got two pens.'),
          _ContextDialogueLine('Ece', 'Has your sister got a bag?'),
          _ContextDialogueLine('Mert', 'Yes, she has.'),
        ]),
      ];
    case 'a1_basic_prepositions':
      return [
        d(Icons.place_rounded, 'Finding things', 'Eşyaları bulmak', const [
          _ContextDialogueLine('Ece', 'Where is my bag?'),
          _ContextDialogueLine('Mert', 'It is on the chair.'),
          _ContextDialogueLine('Ece', 'Where are my keys?'),
          _ContextDialogueLine('Mert', 'They are in your pocket.'),
        ]),
      ];
    case 'a1_imperatives':
      return [
        d(Icons.campaign_rounded, 'In class', 'Sınıfta', const [
          _ContextDialogueLine('Teacher', 'Open your books, please.'),
          _ContextDialogueLine('Student', 'Okay.'),
          _ContextDialogueLine('Teacher', 'Listen and repeat.'),
          _ContextDialogueLine('Student', 'Sure.'),
        ]),
      ];
    case 'a1_demonstratives':
      return [
        d(Icons.image_rounded, 'Showing photos', 'Fotoğraf göstermek', const [
          _ContextDialogueLine('Ece', 'This is my brother.'),
          _ContextDialogueLine('Mert', 'And who are those people?'),
          _ContextDialogueLine('Ece', 'Those are my cousins.'),
          _ContextDialogueLine('Mert', 'Nice photo.'),
        ]),
      ];
  }
  return const [];
}

List<_UsageDialogueData> _cleanA1UsageDialogueSets(String key, bool isEnglish) {
  _UsageDialogueData d(IconData icon, String en, String tr,
          List<_ContextDialogueLine> lines) =>
      _UsageDialogueData(
          icon: icon,
          title: isEnglish ? en : _safeUsageTitle(en, tr),
          lines: lines);

  switch (key) {
    case 'a1_be_verb':
      return [
        d(Icons.school_rounded, 'First day', '?lk g�n', const [
          _ContextDialogueLine('Ece', "Hi, I?m Ece. Are you new here?"),
          _ContextDialogueLine('Mert', "Yes, I am. I?m in Room 4."),
          _ContextDialogueLine('Ece', 'Nice! Are you ready for class?'),
          _ContextDialogueLine('Mert', 'Yes, I am.'),
        ]),
        d(Icons.home_rounded, 'At home', 'Evde', const [
          _ContextDialogueLine('Mert', 'Is your sister at home?'),
          _ContextDialogueLine('Ece', 'No, she is at school.'),
          _ContextDialogueLine('Mert', 'Are your parents here?'),
          _ContextDialogueLine('Ece', 'Yes, they are in the kitchen.'),
        ]),
      ];
    case 'a1_subject_pronouns':
      return [
        d(Icons.people_rounded, 'In class', 'S?n?fta', const [
          _ContextDialogueLine('Ece', 'Where is Ali?'),
          _ContextDialogueLine('Mert', 'He is in the classroom.'),
          _ContextDialogueLine('Ece', 'And Ay_e?'),
          _ContextDialogueLine('Mert', 'She is at home.'),
        ]),
        d(Icons.reply_rounded, 'After school', 'Okuldan sonra', const [
          _ContextDialogueLine('Ece', 'Can you help me with English?'),
          _ContextDialogueLine('Mert', 'Sure. I can help you.'),
          _ContextDialogueLine('Ece', 'Do you know Ali and Deniz?'),
          _ContextDialogueLine('Mert', 'Yes, I know them.'),
        ]),
      ];
    case 'a1_possessive_adjectives':
      return [
        d(Icons.backpack_rounded, 'Lost notebook', 'Kay1p defter', const [
          _ContextDialogueLine('Mert', 'Is this your notebook?'),
          _ContextDialogueLine('Ece', 'No, my notebook is in my bag.'),
          _ContextDialogueLine('Mert', 'Whose notebook is this?'),
          _ContextDialogueLine('Ece', 'It is her notebook.'),
        ]),
        d(Icons.key_rounded, 'Family bag', 'Aile �antas1', const [
          _ContextDialogueLine('Mert', 'Is this Ece?s bag?'),
          _ContextDialogueLine('Ece', 'No, it is my sister?s bag.'),
          _ContextDialogueLine('Mert', 'Where is your bag?'),
          _ContextDialogueLine('Ece', 'My bag is under the desk.'),
        ]),
      ];
    case 'a1_there_is_are':
      return [
        d(Icons.meeting_room_rounded, 'My room', 'Odam', const [
          _ContextDialogueLine('Ece', 'Is there a desk in your room?'),
          _ContextDialogueLine('Mert', 'Yes, there is. It is small.'),
          _ContextDialogueLine('Ece', 'Are there any shelves?'),
          _ContextDialogueLine('Mert', 'Yes, there are two shelves.'),
        ]),
        d(Icons.storefront_rounded, 'Near school', 'Okul yak?n1nda', const [
          _ContextDialogueLine('Ece', 'Is there a cafe near school?'),
          _ContextDialogueLine('Mert', 'Yes, there is a small cafe.'),
          _ContextDialogueLine('Ece', 'Are there any buses?'),
          _ContextDialogueLine('Mert', 'Yes, there are many buses.'),
        ]),
      ];
    case 'a1_articles':
      return [
        d(Icons.coffee_rounded, 'At a cafe', 'Kafede', const [
          _ContextDialogueLine('Ece', 'Can I have a coffee, please?'),
          _ContextDialogueLine('Mert', 'Sure. Do you want an apple too?'),
          _ContextDialogueLine('Ece', 'No, thanks. Where is the sugar?'),
          _ContextDialogueLine('Mert', 'The sugar is on the table.'),
        ]),
        d(Icons.shopping_bag_rounded, 'At a shop', 'Ma?azada', const [
          _ContextDialogueLine('Mert', 'I need a notebook.'),
          _ContextDialogueLine('Ece', 'There is an orange one here.'),
          _ContextDialogueLine('Mert', 'Is the notebook cheap?'),
          _ContextDialogueLine('Ece', 'Yes, it is.'),
        ]),
      ];
    case 'a1_singular_plural':
      return [
        d(Icons.format_list_numbered_rounded, 'Party list',
            'Parti listesi', const [
          _ContextDialogueLine('Ece', 'How many chairs do we need?'),
          _ContextDialogueLine('Mert', 'We need four chairs.'),
          _ContextDialogueLine('Ece', 'And glasses?'),
          _ContextDialogueLine('Mert', 'Six glasses, please.'),
        ]),
        d(Icons.water_drop_rounded, 'Shopping list',
            'Al1_veri_ listesi', const [
          _ContextDialogueLine('Ece', 'Do we need any eggs?'),
          _ContextDialogueLine('Mert', 'Yes, we need six eggs.'),
          _ContextDialogueLine('Ece', 'How much water do we need?'),
          _ContextDialogueLine('Mert', 'A lot of water, please.'),
        ]),
      ];
    case 'a1_present_simple':
      return [
        d(Icons.wb_sunny_rounded, 'Morning routine', 'Sabah rutini', const [
          _ContextDialogueLine('Ece', 'What time do you get up?'),
          _ContextDialogueLine('Mert', 'I get up at seven.'),
          _ContextDialogueLine('Ece', 'Do you eat breakfast at home?'),
          _ContextDialogueLine('Mert', 'Yes, I do.'),
        ]),
        d(Icons.favorite_rounded, 'Free time', 'Bo_ zaman', const [
          _ContextDialogueLine('Ece', 'What do you do after school?'),
          _ContextDialogueLine('Mert', 'I usually play football.'),
          _ContextDialogueLine('Ece', 'Do you like reading?'),
          _ContextDialogueLine('Mert', 'Yes, I love reading comics.'),
        ]),
      ];
    case 'a1_present_continuous':
      return [
        d(Icons.phone_iphone_rounded, 'On the phone', 'Telefonda', const [
          _ContextDialogueLine('Mert', 'Hey, what are you doing?'),
          _ContextDialogueLine('Ece', "I?m studying for my English quiz."),
          _ContextDialogueLine('Mert', 'Are you studying alone?'),
          _ContextDialogueLine('Ece', 'No, my sister is helping me.'),
        ]),
        d(Icons.image_rounded, 'Photo', 'Foto?raf', const [
          _ContextDialogueLine('Mert', 'Who is this in the photo?'),
          _ContextDialogueLine('Ece', 'That is my brother. He is running.'),
          _ContextDialogueLine('Mert', 'And your parents?'),
          _ContextDialogueLine('Ece', 'They are talking near the cafe.'),
        ]),
      ];
    case 'a1_can_cant':
      return [
        d(Icons.volunteer_activism_rounded, 'Quick help', 'K1sa yard1m', const [
          _ContextDialogueLine('Ece', 'Can you help me with this form?'),
          _ContextDialogueLine('Mert', 'Sure, I can help you now.'),
          _ContextDialogueLine('Ece', 'Great. Can I ask one more question?'),
          _ContextDialogueLine('Mert', 'Of course.'),
        ]),
        d(Icons.music_note_rounded, 'Abilities', 'Yetenekler', const [
          _ContextDialogueLine('Mert', 'Can you play the guitar?'),
          _ContextDialogueLine('Ece', "No, I can't. But I can sing."),
          _ContextDialogueLine('Mert', 'Can your sister sing too?'),
          _ContextDialogueLine('Ece', 'Yes, she can.'),
        ]),
      ];
    case 'a1_have_has_got':
      return [
        d(Icons.inventory_2_rounded, 'School bag', 'Okul �antas1', const [
          _ContextDialogueLine('Ece', 'Have you got a pen?'),
          _ContextDialogueLine('Mert', 'Yes, I have got two pens.'),
          _ContextDialogueLine('Ece', 'Great. Have you got your book?'),
          _ContextDialogueLine('Mert', 'Yes, it is in my bag.'),
        ]),
        d(Icons.family_restroom_rounded, 'Family', 'Aile', const [
          _ContextDialogueLine('Mert', 'Have you got a sister?'),
          _ContextDialogueLine('Ece', 'Yes, I have got one sister.'),
          _ContextDialogueLine('Mert', 'Has she got a bike?'),
          _ContextDialogueLine('Ece', 'No, she hasn\'t.'),
        ]),
      ];
    case 'a1_basic_prepositions':
      return [
        d(Icons.place_rounded, 'Finding things', 'E_yalar1 bulma', const [
          _ContextDialogueLine('Mert', 'Where is my phone?'),
          _ContextDialogueLine('Ece', 'It is on the sofa.'),
          _ContextDialogueLine('Mert', 'And my wallet?'),
          _ContextDialogueLine('Ece', 'It is in your coat.'),
        ]),
        d(Icons.schedule_rounded, 'Meeting time', 'Bulu_ma zaman1', const [
          _ContextDialogueLine('Ece', 'When is the lesson?'),
          _ContextDialogueLine('Mert', 'It is at seven.'),
          _ContextDialogueLine('Ece', 'Is it on Monday?'),
          _ContextDialogueLine('Mert', 'Yes, on Monday in Room 4.'),
        ]),
      ];
    case 'a1_imperatives':
      return [
        d(Icons.campaign_rounded, 'In class', 'S?n?fta', const [
          _ContextDialogueLine('Teacher', 'Open your books, please.'),
          _ContextDialogueLine('Ece', 'Which page?'),
          _ContextDialogueLine('Teacher', 'Look at page ten.'),
          _ContextDialogueLine('Ece', 'Okay.'),
        ]),
        d(Icons.warning_amber_rounded, 'At home', 'Evde', const [
          _ContextDialogueLine('Mert', 'Can I open the window?'),
          _ContextDialogueLine('Ece', 'Yes, open it, please.'),
          _ContextDialogueLine('Mert', 'Can I run here?'),
          _ContextDialogueLine('Ece', 'No, don\'t run in the house.'),
        ]),
      ];
    case 'a1_demonstratives':
      return [
        d(Icons.touch_app_rounded, 'Family photo', 'Aile foto?raf1', const [
          _ContextDialogueLine('Mert', 'Is this your family?'),
          _ContextDialogueLine('Ece', 'Yes, this is my mother.'),
          _ContextDialogueLine('Mert', 'Who are those people?'),
          _ContextDialogueLine('Ece', 'Those are my cousins.'),
        ]),
        d(Icons.shopping_bag_rounded, 'At a shop', 'Ma?azada', const [
          _ContextDialogueLine('Mert', 'Is this bag new?'),
          _ContextDialogueLine('Ece', 'Yes, this is new.'),
          _ContextDialogueLine('Mert', 'Are those shoes expensive?'),
          _ContextDialogueLine('Ece', 'No, those shoes are cheap.'),
        ]),
      ];
  }
  return const [];
}

List<_UsageDialogueData> _goldA1UsageDialogueSets(String key, bool isEnglish) {
  _UsageDialogueData d(IconData icon, String en, String tr,
          List<_ContextDialogueLine> lines) =>
      _UsageDialogueData(
          icon: icon,
          title: isEnglish ? en : _safeUsageTitle(en, tr),
          lines: lines);

  switch (key) {
    case 'a1_be_verb':
      return [
        d(Icons.school_rounded, 'First day', 'İlk gün', const [
          _ContextDialogueLine('A', 'Are you a student?'),
          _ContextDialogueLine('B', 'Yes, I am.'),
          _ContextDialogueLine('A', 'Are you from Kayseri?'),
          _ContextDialogueLine('B', 'No, I am from Ankara.'),
        ]),
        d(Icons.people_rounded, 'Family', 'Aile', const [
          _ContextDialogueLine('A', 'Is she your teacher?'),
          _ContextDialogueLine('B', 'Yes, she is.'),
          _ContextDialogueLine('A', 'Is he your brother?'),
          _ContextDialogueLine('B', "No, he isn't."),
        ]),
      ];
    case 'a1_subject_pronouns':
      return [
        d(Icons.people_rounded, 'People', 'Kişiler', const [
          _ContextDialogueLine('A', 'Where is Ali?'),
          _ContextDialogueLine('B', 'He is in class.'),
          _ContextDialogueLine('A', 'Where is Ece?'),
          _ContextDialogueLine('B', 'She is at home.'),
        ]),
        d(Icons.group_rounded, 'Objects and friends',
            'Eşyalar ve arkadaşlar', const [
          _ContextDialogueLine('A', 'Where are the books?'),
          _ContextDialogueLine('B', 'They are on the desk.'),
          _ContextDialogueLine('A', 'Can you help us?'),
          _ContextDialogueLine('B', 'Yes, I can help you.'),
        ]),
      ];
    case 'a1_possessive_adjectives':
      return [
        d(Icons.backpack_rounded, 'School bag', 'Okul çantası', const [
          _ContextDialogueLine('A', 'Is this your bag?'),
          _ContextDialogueLine('B', 'No, my bag is blue.'),
          _ContextDialogueLine('A', 'Is this her notebook?'),
          _ContextDialogueLine('B', 'Yes, it is her notebook.'),
        ]),
        d(Icons.family_restroom_rounded, 'Family', 'Aile', const [
          _ContextDialogueLine('A', 'Is his brother a student?'),
          _ContextDialogueLine('B', 'Yes, his brother is in my class.'),
          _ContextDialogueLine('A', 'Are their parents teachers?'),
          _ContextDialogueLine('B', 'Yes, their parents are teachers.'),
        ]),
      ];
    case 'a1_there_is_are':
      return [
        d(Icons.meeting_room_rounded, 'My room', 'Odam', const [
          _ContextDialogueLine('A', 'Is there a desk in your room?'),
          _ContextDialogueLine('B', 'Yes, there is.'),
          _ContextDialogueLine('A', 'Are there any books?'),
          _ContextDialogueLine('B', 'Yes, there are two books.'),
        ]),
        d(Icons.place_rounded, 'Near school', 'Okul yakınında', const [
          _ContextDialogueLine('A', 'Is there a cafe near school?'),
          _ContextDialogueLine('B', 'Yes, there is a small cafe.'),
          _ContextDialogueLine('A', 'Are there buses there?'),
          _ContextDialogueLine('B', 'Yes, there are many buses.'),
        ]),
      ];
    case 'a1_articles':
      return [
        d(Icons.coffee_rounded, 'At a cafe', 'Kafede', const [
          _ContextDialogueLine('A', 'Can I have a tea, please?'),
          _ContextDialogueLine('B', 'Sure. Do you want an apple?'),
          _ContextDialogueLine('A', 'No, thanks. Where is the sugar?'),
          _ContextDialogueLine('B', 'The sugar is on the table.'),
        ]),
        d(Icons.pets_rounded, 'A dog', 'Bir köpek', const [
          _ContextDialogueLine('A', 'I can see a dog.'),
          _ContextDialogueLine('B', 'Is the dog small?'),
          _ContextDialogueLine('A', 'Yes. It has an orange collar.'),
          _ContextDialogueLine('B', 'Maybe the dog lives near here.'),
        ]),
      ];
    case 'a1_singular_plural':
      return [
        d(Icons.format_list_numbered_rounded, 'Counting', 'Saymak', const [
          _ContextDialogueLine('A', 'Is this one apple?'),
          _ContextDialogueLine('B', 'Yes, one apple.'),
          _ContextDialogueLine('A', 'Are these two apples?'),
          _ContextDialogueLine('B', 'Yes, two apples.'),
        ]),
        d(Icons.shopping_cart_rounded, 'Shopping list',
            'Alışveriş listesi', const [
          _ContextDialogueLine('A', 'How many chairs do we need?'),
          _ContextDialogueLine('B', 'We need four chairs.'),
          _ContextDialogueLine('A', 'How much water do we need?'),
          _ContextDialogueLine('B', 'A lot of water, please.'),
        ]),
      ];
    case 'a1_present_simple':
      return [
        d(Icons.local_cafe_rounded, 'Tea', 'Çay', const [
          _ContextDialogueLine('A', 'Do you like tea?'),
          _ContextDialogueLine('B', 'Yes, I do.'),
          _ContextDialogueLine('A', 'Do you drink tea every day?'),
          _ContextDialogueLine('B', "No, I don't."),
        ]),
        d(Icons.sports_soccer_rounded, 'After school', 'Okuldan sonra', const [
          _ContextDialogueLine('A', 'Does he play football?'),
          _ContextDialogueLine('B', 'Yes, he does.'),
          _ContextDialogueLine('A', 'Does he play after school?'),
          _ContextDialogueLine('B', 'Yes, he does.'),
        ]),
      ];
    case 'a1_present_continuous':
      return [
        d(Icons.phone_iphone_rounded, 'Now', 'Şimdi', const [
          _ContextDialogueLine('A', 'What are you doing?'),
          _ContextDialogueLine('B', 'I am studying English.'),
          _ContextDialogueLine('A', 'Is your sister studying too?'),
          _ContextDialogueLine('B', 'No, she is reading.'),
        ]),
        d(Icons.image_rounded, 'Photo', 'Fotoğraf', const [
          _ContextDialogueLine('A', 'What is he doing?'),
          _ContextDialogueLine('B', 'He is running.'),
          _ContextDialogueLine('A', 'What are they doing?'),
          _ContextDialogueLine('B', 'They are talking.'),
        ]),
      ];
    case 'a1_can_cant':
      return [
        d(Icons.pool_rounded, 'Abilities', 'Yetenekler', const [
          _ContextDialogueLine('A', 'Can you swim?'),
          _ContextDialogueLine('B', 'Yes, I can.'),
          _ContextDialogueLine('A', 'Can your brother swim?'),
          _ContextDialogueLine('B', "No, he can't."),
        ]),
        d(Icons.help_rounded, 'Help', 'Yardım', const [
          _ContextDialogueLine('A', 'Can you help me?'),
          _ContextDialogueLine('B', 'Yes, I can help you.'),
          _ContextDialogueLine('A', 'Can I use your pen?'),
          _ContextDialogueLine('B', 'Yes, you can.'),
        ]),
      ];
    case 'a1_have_has_got':
      return [
        d(Icons.inventory_2_rounded, 'School bag', 'Okul çantası', const [
          _ContextDialogueLine('A', 'Have you got a pen?'),
          _ContextDialogueLine('B', 'Yes, I have got two pens.'),
          _ContextDialogueLine('A', 'Have you got your book?'),
          _ContextDialogueLine('B', "No, I haven't."),
        ]),
        d(Icons.family_restroom_rounded, 'Family', 'Aile', const [
          _ContextDialogueLine('A', 'Has she got a brother?'),
          _ContextDialogueLine('B', 'Yes, she has got one brother.'),
          _ContextDialogueLine('A', 'Has he got a bike?'),
          _ContextDialogueLine('B', 'Yes, he has got a blue bike.'),
        ]),
      ];
    case 'a1_basic_prepositions':
      return [
        d(Icons.place_rounded, 'Finding things', 'Eşyaları bulmak', const [
          _ContextDialogueLine('A', 'Where is my phone?'),
          _ContextDialogueLine('B', 'It is on the sofa.'),
          _ContextDialogueLine('A', 'Where are my keys?'),
          _ContextDialogueLine('B', 'They are in your bag.'),
        ]),
        d(Icons.schedule_rounded, 'Time and place', 'Zaman ve yer', const [
          _ContextDialogueLine('A', 'When is the lesson?'),
          _ContextDialogueLine('B', 'It is at seven.'),
          _ContextDialogueLine('A', 'Is it on Monday?'),
          _ContextDialogueLine('B', 'Yes, in Room 4.'),
        ]),
      ];
    case 'a1_imperatives':
      return [
        d(Icons.school_rounded, 'In class', 'Sınıfta', const [
          _ContextDialogueLine('Teacher', 'Open your books, please.'),
          _ContextDialogueLine('Student', 'Okay.'),
          _ContextDialogueLine('Teacher', 'Listen and repeat.'),
          _ContextDialogueLine('Student', 'Sure.'),
        ]),
        d(Icons.warning_amber_rounded, 'Warning', 'Uyarı', const [
          _ContextDialogueLine('A', 'Can I run here?'),
          _ContextDialogueLine('B', "No, don't run."),
          _ContextDialogueLine('A', 'What should I do?'),
          _ContextDialogueLine('B', 'Walk slowly, please.'),
        ]),
      ];
    case 'a1_demonstratives':
      return [
        d(Icons.touch_app_rounded, 'On the desk', 'Masada', const [
          _ContextDialogueLine('A', 'What is this?'),
          _ContextDialogueLine('B', 'This is my book.'),
          _ContextDialogueLine('A', 'What are these?'),
          _ContextDialogueLine('B', 'These are my pens.'),
        ]),
        d(Icons.shopping_bag_rounded, 'In a shop', 'Mağazada', const [
          _ContextDialogueLine('A', 'Is that your bag?'),
          _ContextDialogueLine('B', 'No, that is her bag.'),
          _ContextDialogueLine('A', 'Are those your shoes?'),
          _ContextDialogueLine('B', 'Yes, those are my shoes.'),
        ]),
      ];
  }
  return const [];
}

List<_UsageDialogueData> _usageDialogueSetsForKey(String key, bool isEnglish) {
  final goldA1 = _goldA1UsageDialogueSets(key, isEnglish);
  if (goldA1.isNotEmpty) return goldA1;

  final cleanA1 = _cleanA1UsageDialogueSets(key, isEnglish);
  if (cleanA1.isNotEmpty) return cleanA1;

  _UsageDialogueData d(IconData icon, String en, String tr,
          List<_ContextDialogueLine> lines) =>
      _UsageDialogueData(
          icon: icon,
          title: isEnglish ? en : _safeUsageTitle(en, tr),
          lines: lines);

  switch (key) {
    case 'a2_past_simple':
      return [
        d(Icons.history_rounded, 'Yesterday', 'D�n', const [
          _ContextDialogueLine('Ece', 'What did you do yesterday?'),
          _ContextDialogueLine('Mert', 'I visited my aunt.'),
          _ContextDialogueLine('Ece', 'Did you stay long?'),
          _ContextDialogueLine('Mert', 'No, I came home early.'),
        ]),
        d(Icons.movie_rounded, 'After the movie', 'Filmden sonra', const [
          _ContextDialogueLine('Mert', 'Did you watch the film last night?'),
          _ContextDialogueLine('Ece', 'Yes, I watched it with Deniz.'),
          _ContextDialogueLine('Mert', 'Did you like it?'),
          _ContextDialogueLine('Ece', 'Yes, but I did not like the ending.'),
        ]),
      ];
    case 'a2_will':
      return [
        d(Icons.volunteer_activism_rounded, 'Quick offer',
            'Hızlı teklif', const [
          _ContextDialogueLine('Ece', 'This bag is heavy.'),
          _ContextDialogueLine('Mert', 'I will carry it for you.'),
          _ContextDialogueLine('Ece', 'Thanks. Will you wait here?'),
          _ContextDialogueLine('Mert', 'Sure, I will wait.'),
        ]),
        d(Icons.cloud_rounded, 'Prediction', 'Tahmin', const [
          _ContextDialogueLine('Mert', 'Look at the sky.'),
          _ContextDialogueLine('Ece', 'I think it will rain soon.'),
          _ContextDialogueLine('Mert', 'Will we cancel the picnic?'),
          _ContextDialogueLine('Ece', 'Maybe. I will check the weather.'),
        ]),
      ];
    case 'a2_going_to':
      return [
        d(Icons.event_available_rounded, 'Weekend plan',
            'Hafta sonu plan1', const [
          _ContextDialogueLine('Ece', 'What are you going to do on Saturday?'),
          _ContextDialogueLine('Mert', 'I am going to visit my cousins.'),
          _ContextDialogueLine('Ece', 'Are you going to stay there?'),
          _ContextDialogueLine('Mert', 'No, I am going to come back at night.'),
        ]),
        d(Icons.umbrella_rounded, 'Visible evidence', 'G�r�nen i?aret', const [
          _ContextDialogueLine('Mert', 'Look at those clouds.'),
          _ContextDialogueLine('Ece', 'It is going to rain.'),
          _ContextDialogueLine('Mert', 'Are you going to take an umbrella?'),
          _ContextDialogueLine('Ece', 'Yes, I am.'),
        ]),
      ];
    case 'a2_comparatives':
      return [
        d(Icons.shopping_bag_rounded, 'Choosing a bag', '�anta se�mek', const [
          _ContextDialogueLine('Ece', 'Which bag do you like?'),
          _ContextDialogueLine('Mert', 'The blue one is cheaper.'),
          _ContextDialogueLine('Ece', 'But the black one is bigger.'),
          _ContextDialogueLine('Mert', 'True. It is more useful too.'),
        ]),
        d(Icons.directions_bus_rounded, 'Travel choice',
            'Yolculuk se�imi', const [
          _ContextDialogueLine('Mert', 'Is the train faster than the bus?'),
          _ContextDialogueLine('Ece', 'Yes, but it is more expensive.'),
          _ContextDialogueLine('Mert', 'Then the bus is better for us.'),
          _ContextDialogueLine('Ece', 'I agree.'),
        ]),
      ];
    case 'a2_superlatives':
      return [
        d(Icons.emoji_events_rounded, 'Class survey', 'S?n?f anketi', const [
          _ContextDialogueLine('Ece', 'Who is the tallest student?'),
          _ContextDialogueLine('Mert', 'Deniz is the tallest.'),
          _ContextDialogueLine('Ece', 'And who is the youngest?'),
          _ContextDialogueLine('Mert', 'I think Ali is the youngest.'),
        ]),
        d(Icons.restaurant_rounded, 'Best place', 'En iyi yer', const [
          _ContextDialogueLine('Mert', 'Which cafe is the best near school?'),
          _ContextDialogueLine('Ece', 'The small one is the best.'),
          _ContextDialogueLine('Mert', 'Is it the cheapest too?'),
          _ContextDialogueLine('Ece', 'No, but it has the best tea.'),
        ]),
      ];
    case 'a2_quantifiers':
    case 'a2_countable_uncountable':
    case 'a2_some_any_much_many':
      return [
        d(Icons.shopping_cart_rounded, 'Shopping list',
            'Al1_veri_ listesi', const [
          _ContextDialogueLine('Ece', 'Do we have any eggs?'),
          _ContextDialogueLine('Mert', 'Yes, we have some eggs.'),
          _ContextDialogueLine('Ece', 'How much milk do we need?'),
          _ContextDialogueLine('Mert', 'A little milk is enough.'),
        ]),
        d(Icons.kitchen_rounded, 'In the kitchen', 'Mutfakta', const [
          _ContextDialogueLine('Mert', 'How many apples are there?'),
          _ContextDialogueLine('Ece', 'There are a few apples.'),
          _ContextDialogueLine('Mert', 'Is there much bread?'),
          _ContextDialogueLine('Ece', 'No, but there is a lot of rice.'),
        ]),
      ];
    case 'a2_should':
      return [
        d(Icons.health_and_safety_rounded, 'Feeling sick',
            'Hasta hissetmek', const [
          _ContextDialogueLine('Ece', 'I have a headache.'),
          _ContextDialogueLine('Mert', 'You should drink some water.'),
          _ContextDialogueLine('Ece', 'Should I go home?'),
          _ContextDialogueLine('Mert', 'Yes, you should rest.'),
        ]),
        d(Icons.school_rounded, 'Before a test', 'S?navdan �nce', const [
          _ContextDialogueLine('Mert', 'I am worried about the test.'),
          _ContextDialogueLine('Ece', 'You should review your notes.'),
          _ContextDialogueLine('Mert', 'Should I study all night?'),
          _ContextDialogueLine('Ece', 'No, you should sleep early.'),
        ]),
      ];
    case 'a2_must_have_to':
      return [
        d(Icons.rule_rounded, 'School rule', 'Okul kural1', const [
          _ContextDialogueLine('Teacher', 'You must be quiet in the library.'),
          _ContextDialogueLine('Mert', 'Do we have to turn off our phones?'),
          _ContextDialogueLine('Teacher', 'Yes, you have to turn them off.'),
          _ContextDialogueLine('Mert', 'Okay, teacher.'),
        ]),
        d(Icons.work_rounded, 'Work duty', '? g�revi', const [
          _ContextDialogueLine('Ece', 'Do you have to work tomorrow?'),
          _ContextDialogueLine('Mert', 'Yes, I have to start at nine.'),
          _ContextDialogueLine('Ece', 'Must you wear a uniform?'),
          _ContextDialogueLine('Mert', 'Yes, I must wear one.'),
        ]),
      ];
    case 'a2_object_possessive_pronouns':
      return [
        d(Icons.backpack_rounded, 'Lost notebook', 'Kay1p defter', const [
          _ContextDialogueLine('Mert', 'Is this notebook yours?'),
          _ContextDialogueLine('Ece', 'No, mine is in my bag.'),
          _ContextDialogueLine('Mert', 'Maybe it is Deniz\'s.'),
          _ContextDialogueLine('Ece', 'Yes, I can give it to him.'),
        ]),
        d(Icons.group_rounded, 'Helping friends', 'Arkada_lara yard1m', const [
          _ContextDialogueLine('Ece', 'Can you help us after class?'),
          _ContextDialogueLine('Mert', 'Sure, I can help you.'),
          _ContextDialogueLine('Ece', 'These books are theirs.'),
          _ContextDialogueLine('Mert', 'Great, I will take them.'),
        ]),
      ];
    case 'a2_adverbs_frequency_manner':
      return [
        d(Icons.schedule_rounded, 'Routine', 'Rutin', const [
          _ContextDialogueLine('Ece', 'Do you usually walk to school?'),
          _ContextDialogueLine('Mert', 'Yes, I usually walk.'),
          _ContextDialogueLine('Ece', 'Are you ever late?'),
          _ContextDialogueLine('Mert', 'No, I am never late.'),
        ]),
        d(Icons.record_voice_over_rounded, 'How it happens',
            'Nas1l olur', const [
          _ContextDialogueLine('Mert', 'Your sister speaks English well.'),
          _ContextDialogueLine('Ece', 'Thanks. She practices carefully.'),
          _ContextDialogueLine('Mert', 'Does she speak quickly?'),
          _ContextDialogueLine('Ece', 'No, she speaks slowly and clearly.'),
        ]),
      ];
    case 'a2_infinitive_purpose':
      return [
        d(Icons.local_grocery_store_rounded, 'Why did you go?',
            'Neden gittin?', const [
          _ContextDialogueLine('Ece', 'Why did you go to the shop?'),
          _ContextDialogueLine('Mert', 'I went there to buy bread.'),
          _ContextDialogueLine('Ece', 'Did you buy milk too?'),
          _ContextDialogueLine('Mert', 'Yes, I bought milk to make coffee.'),
        ]),
        d(Icons.phone_rounded, 'Quick call', 'K1sa arama', const [
          _ContextDialogueLine('Mert', 'Why did you call Deniz?'),
          _ContextDialogueLine('Ece', 'I called him to ask a question.'),
          _ContextDialogueLine('Mert', 'Did he answer?'),
          _ContextDialogueLine('Ece', 'Yes, he answered to help me.'),
        ]),
      ];
    case 'a2_gerund_infinitive':
      return [
        d(Icons.menu_book_rounded, 'Hobbies', 'Hobiler', const [
          _ContextDialogueLine('Ece', 'Do you enjoy reading?'),
          _ContextDialogueLine('Mert', 'Yes, I enjoy reading comics.'),
          _ContextDialogueLine('Ece', 'Do you want to borrow this one?'),
          _ContextDialogueLine('Mert', 'Yes, I want to read it tonight.'),
        ]),
        d(Icons.task_alt_rounded, 'Plans', 'Planlar', const [
          _ContextDialogueLine('Mert', 'What do you need to do today?'),
          _ContextDialogueLine('Ece', 'I need to finish my homework.'),
          _ContextDialogueLine('Mert', 'Do you like studying at home?'),
          _ContextDialogueLine('Ece', 'Yes, I like studying in my room.'),
        ]),
      ];
    case 'a1_present_continuous':
      return [
        d(Icons.phone_iphone_rounded, 'On the phone', 'Telefonda', const [
          _ContextDialogueLine('Mert', 'Hey, what are you doing?'),
          _ContextDialogueLine('Ece', 'I?m studying for my English quiz.'),
          _ContextDialogueLine('Mert', 'Are you studying alone?'),
          _ContextDialogueLine('Ece', 'No, my sister is helping me.'),
        ]),
        d(Icons.home_rounded, 'At home', 'Evde', const [
          _ContextDialogueLine('Mum', 'Where is your brother?'),
          _ContextDialogueLine('Ece', 'He?s sleeping in his room.'),
          _ContextDialogueLine('Mum', 'Is your dad working?'),
          _ContextDialogueLine('Ece', 'Yes, he?s working on his laptop.'),
        ]),
      ];
    case 'a1_can_cant':
      return [
        d(Icons.volunteer_activism_rounded, 'Asking for help',
            'Yard1m istemek', const [
          _ContextDialogueLine('Ece', 'Can you help me with this form?'),
          _ContextDialogueLine('Mert', 'Sure, I can help you now.'),
          _ContextDialogueLine('Ece', 'Great. Can I ask one more question?'),
          _ContextDialogueLine('Mert', 'Of course.'),
        ]),
        d(Icons.music_note_rounded, 'Talking about abilities',
            'Yeteneklerden bahsetmek', const [
          _ContextDialogueLine('Mert', 'Can you play the guitar?'),
          _ContextDialogueLine('Ece', 'No, I can\'t. But I can sing.'),
          _ContextDialogueLine('Mert', 'Really? Can you sing this song?'),
          _ContextDialogueLine('Ece', 'I can try.'),
        ]),
      ];
    case 'a1_be_verb':
      return [
        d(Icons.school_rounded, 'First day', '?lk g�n', const [
          _ContextDialogueLine('Ece', 'Hi, I?m Ece. Are you new here?'),
          _ContextDialogueLine('Mert', 'Yes, I am. I?m in Room 4.'),
          _ContextDialogueLine('Ece', 'Is your teacher nice?'),
          _ContextDialogueLine('Mert', 'Yes, she is very kind.'),
        ]),
        d(Icons.favorite_rounded, 'After class', 'Dersten sonra', const [
          _ContextDialogueLine('Mert', 'Are you tired?'),
          _ContextDialogueLine('Ece', 'No, I?m okay. I?m just hungry.'),
          _ContextDialogueLine('Mert', 'Is the cafe open?'),
          _ContextDialogueLine('Ece', 'Yes, it is.'),
        ]),
      ];
    case 'a1_present_simple':
      return [
        d(Icons.wb_sunny_rounded, 'Morning routine', 'Sabah rutini', const [
          _ContextDialogueLine('Ece', 'What time do you get up?'),
          _ContextDialogueLine('Mert', 'I get up at seven.'),
          _ContextDialogueLine('Ece', 'Do you eat breakfast at home?'),
          _ContextDialogueLine('Mert', 'Yes, I do.'),
        ]),
        d(Icons.sports_soccer_rounded, 'Weekend', 'Hafta sonu', const [
          _ContextDialogueLine('Mert', 'Does your brother play football?'),
          _ContextDialogueLine('Ece', 'Yes, he plays on Sundays.'),
          _ContextDialogueLine('Mert', 'Do you watch the game?'),
          _ContextDialogueLine('Ece', 'No, I don\'t. I study English.'),
        ]),
      ];
    case 'a1_subject_pronouns':
      return [
        d(Icons.people_rounded, 'Talking about friends',
            'Arkada_lardan bahsetmek', const [
          _ContextDialogueLine('Ece', 'Is Ali in your class?'),
          _ContextDialogueLine('Mert', 'Yes, he is. He sits near me.'),
          _ContextDialogueLine('Ece', 'And Ay_e?'),
          _ContextDialogueLine('Mert', 'She is in another class.'),
        ]),
        d(Icons.inventory_2_rounded, 'Finding things',
            'E_yalar1 bulmak', const [
          _ContextDialogueLine('Mert', 'Where are my keys?'),
          _ContextDialogueLine('Ece', 'They are on the desk.'),
          _ContextDialogueLine('Mert', 'And my phone?'),
          _ContextDialogueLine('Ece', 'It is in your bag.'),
        ]),
      ];
    case 'a1_possessive_adjectives':
      return [
        d(Icons.backpack_rounded, 'At school', 'Okulda', const [
          _ContextDialogueLine('Mert', 'Is this your notebook?'),
          _ContextDialogueLine('Ece', 'No, it is my sister?s notebook.'),
          _ContextDialogueLine('Mert', 'Where is your notebook?'),
          _ContextDialogueLine('Ece', 'It is in my bag.'),
        ]),
        d(Icons.family_restroom_rounded, 'Family chat', 'Aile sohbeti', const [
          _ContextDialogueLine('Ece', 'Is her brother a student?'),
          _ContextDialogueLine('Mert', 'Yes, and his school is near here.'),
          _ContextDialogueLine('Ece', 'Nice. What about their parents?'),
          _ContextDialogueLine('Mert', 'Their parents are teachers.'),
        ]),
      ];
    case 'a1_there_is_are':
      return [
        d(Icons.meeting_room_rounded, 'New room', 'Yeni oda', const [
          _ContextDialogueLine('Ece', 'Is there a desk in your room?'),
          _ContextDialogueLine('Mert', 'Yes, there is. It is small.'),
          _ContextDialogueLine('Ece', 'Are there any shelves?'),
          _ContextDialogueLine('Mert', 'Yes, there are two shelves.'),
        ]),
        d(Icons.location_city_rounded, 'Near here', 'Buralarda', const [
          _ContextDialogueLine('Mert', 'Is there a cafe near here?'),
          _ContextDialogueLine('Ece', 'Yes, there is one on this street.'),
          _ContextDialogueLine('Mert', 'Are there buses at night?'),
          _ContextDialogueLine('Ece', 'Yes, but there are not many.'),
        ]),
      ];
    case 'a1_articles':
      return [
        d(Icons.shopping_bag_rounded, 'Buying something',
            'Bir ?ey almak', const [
          _ContextDialogueLine('Ece', 'Can I have a coffee, please?'),
          _ContextDialogueLine('Mert', 'Sure. Do you want an apple too?'),
          _ContextDialogueLine('Ece', 'No, thanks. Where is the sugar?'),
          _ContextDialogueLine('Mert', 'The sugar is on the table.'),
        ]),
        d(Icons.visibility_rounded, 'A quick story', 'K1sa bir hikaye', const [
          _ContextDialogueLine('Mert', 'I can see a dog outside.'),
          _ContextDialogueLine('Ece', 'Is the dog small?'),
          _ContextDialogueLine('Mert', 'Yes. It has an orange collar.'),
          _ContextDialogueLine('Ece', 'Maybe the dog lives near here.'),
        ]),
      ];
    case 'a1_singular_plural':
      return [
        d(Icons.format_list_numbered_rounded, 'Making a list',
            'Liste yapmak', const [
          _ContextDialogueLine('Ece', 'How many chairs do we need?'),
          _ContextDialogueLine('Mert', 'We need four chairs.'),
          _ContextDialogueLine('Ece', 'And glasses?'),
          _ContextDialogueLine('Mert', 'Six glasses, please.'),
        ]),
        d(Icons.inventory_rounded, 'Packing a bag', '�anta haz1rlamak', const [
          _ContextDialogueLine('Mert', 'Do you have the books?'),
          _ContextDialogueLine('Ece', 'Yes, I have three books.'),
          _ContextDialogueLine('Mert', 'What about the boxes?'),
          _ContextDialogueLine('Ece', 'Two boxes are in the car.'),
        ]),
      ];
    case 'a1_have_has_got':
      return [
        d(Icons.inventory_2_rounded, 'Checking your bag',
            '�antan1 kontrol etmek', const [
          _ContextDialogueLine('Ece', 'Have you got a pen?'),
          _ContextDialogueLine('Mert', 'Yes, I have got two pens.'),
          _ContextDialogueLine('Ece', 'Great. Have you got your book?'),
          _ContextDialogueLine('Mert', 'No, I haven\'t. It is at home.'),
        ]),
        d(Icons.family_restroom_rounded, 'Talking about family',
            'Aileden bahsetmek', const [
          _ContextDialogueLine('Mert', 'Has Ece got a brother?'),
          _ContextDialogueLine('Deniz', 'Yes, she has got one brother.'),
          _ContextDialogueLine('Mert', 'Has he got a bike?'),
          _ContextDialogueLine('Deniz', 'Yes, he has got a blue bike.'),
        ]),
      ];
    case 'a1_basic_prepositions':
      return [
        d(Icons.place_rounded, 'Looking for things', 'E_ya aramak', const [
          _ContextDialogueLine('Mert', 'Where is my phone?'),
          _ContextDialogueLine('Ece', 'It is on the sofa.'),
          _ContextDialogueLine('Mert', 'And my wallet?'),
          _ContextDialogueLine('Ece', 'It is in your coat.'),
        ]),
        d(Icons.schedule_rounded, 'Making a plan', 'Plan yapmak', const [
          _ContextDialogueLine('Ece', 'When is the lesson?'),
          _ContextDialogueLine('Mert', 'It is at seven.'),
          _ContextDialogueLine('Ece', 'Do we meet on Monday?'),
          _ContextDialogueLine('Mert', 'Yes, at the school gate.'),
        ]),
      ];
    case 'a1_imperatives':
      return [
        d(Icons.campaign_rounded, 'In class', 'S?n?fta', const [
          _ContextDialogueLine('Teacher', 'Open your books, please.'),
          _ContextDialogueLine('Ece', 'Which page?'),
          _ContextDialogueLine('Teacher', 'Look at page ten.'),
          _ContextDialogueLine('Ece', 'Okay.'),
        ]),
        d(Icons.remove_circle_outline_rounded, 'Quick warning',
            'K1sa uyar1', const [
          _ContextDialogueLine('Mert', 'Look at this button.'),
          _ContextDialogueLine('Ece', 'Don\'t touch it.'),
          _ContextDialogueLine('Mert', 'Read the sign, please.'),
          _ContextDialogueLine('Ece', 'Wait here.'),
        ]),
      ];
    case 'a1_demonstratives':
      return [
        d(Icons.touch_app_rounded, 'In a shop', 'Ma?azada', const [
          _ContextDialogueLine('Ece', 'How much is this bag?'),
          _ContextDialogueLine('Mert', 'It is 300 lira.'),
          _ContextDialogueLine('Ece', 'And those shoes?'),
          _ContextDialogueLine('Mert', 'Those are on sale.'),
        ]),
        d(Icons.near_me_rounded, 'Showing photos', 'Foto?raf g�stermek', const [
          _ContextDialogueLine('Mert', 'Is this your family?'),
          _ContextDialogueLine('Ece', 'Yes, this is my mother.'),
          _ContextDialogueLine('Mert', 'Who are those people?'),
          _ContextDialogueLine('Ece', 'Those are my cousins.'),
        ]),
      ];
  }
  return const [];
}

class _UsageDialogueCarousel extends StatefulWidget {
  final List<_UsageDialogueData> dialogues;
  final Color color;
  final String lessonKey;

  const _UsageDialogueCarousel({
    required this.dialogues,
    required this.color,
    required this.lessonKey,
  });

  @override
  State<_UsageDialogueCarousel> createState() => _UsageDialogueCarouselState();
}

class _UsageDialogueCarouselState extends State<_UsageDialogueCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageHeight = constraints.maxWidth < 360 ? 356.0 : 332.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: pageHeight,
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (value) => setState(() => _page = value),
                itemCount: widget.dialogues.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                      right: index == widget.dialogues.length - 1 ? 0 : 8),
                  child: _UsageDialogueCard(
                    dialogue: widget.dialogues[index],
                    color: widget.color,
                    lessonKey: widget.lessonKey,
                  ),
                ),
              ),
            ),
            if (widget.dialogues.length > 1) ...[
              const SizedBox(height: 9),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.dialogues.length, (index) {
                  final active = index == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: active ? 18 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: active ? widget.color : tokens.border,
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _UsageDialogueCard extends StatelessWidget {
  final _UsageDialogueData dialogue;
  final Color color;
  final String lessonKey;

  const _UsageDialogueCard(
      {required this.dialogue, required this.color, required this.lessonKey});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? _grammarLightGlass(color, strong: true)
              : [
                  color.withAlpha(24),
                  const Color(0xFF07111E).withAlpha(238),
                  Colors.white.withAlpha(7),
                ],
        ),
        border: Border.all(
            color: tokens.isLight
                ? _grammarGlassBorder(tokens, accent: color, strong: true)
                : color.withAlpha(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: color.withAlpha(24),
                  border: Border.all(color: color.withAlpha(42)),
                ),
                child: Icon(dialogue.icon, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_repairMojibake(dialogue.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 14.8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxBubble = (constraints.maxWidth * 0.84)
                    .clamp(230.0, constraints.maxWidth);
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: dialogue.lines.asMap().entries.map((entry) {
                      final isLeft = entry.key.isEven;
                      final line = entry.value;
                      return Align(
                        alignment: isLeft
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: maxBubble),
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isLeft ? 5 : 18),
                              bottomRight: Radius.circular(isLeft ? 18 : 5),
                            ),
                            color: isLeft
                                ? tokens.inputSurface
                                : color.withAlpha(30),
                            border: Border.all(
                                color: isLeft
                                    ? tokens.border
                                    : color.withAlpha(38)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_repairMojibake(line.speaker),
                                  style: TextStyle(
                                      color: tokens.isLight
                                          ? accent
                                          : color.withAlpha(235),
                                      fontSize: 10.6,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text(_repairMojibake(line.text),
                                  style: TextStyle(
                                      color: tokens.textPrimary,
                                      fontSize: 12.8,
                                      height: 1.25,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextScenario {
  final IconData icon;
  final String title;
  final String sentence;
  final String note;
  const _ContextScenario(this.icon, this.title, this.sentence, this.note);
}

String _contextTopicKey(GrammarLesson lesson) {
  return '${lesson.bigTitle} ${lesson.oneLineGoal} ${lesson.teacherIntro}'
      .toLowerCase();
}

class _ContextHeroCard extends StatelessWidget {
  final _ContextPack pack;
  final Color color;
  final bool isEnglish;
  const _ContextHeroCard(
      {required this.pack, required this.color, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final watermarkIcon = pack.backgroundIcons.isNotEmpty
        ? pack.backgroundIcons.first
        : pack.heroIcon;
    final secondIcon = pack.backgroundIcons.length > 1
        ? pack.backgroundIcons[1]
        : pack.heroIcon;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(30),
            Colors.white.withAlpha(6),
            Colors.black.withAlpha(12),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(14), width: 1),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(10),
              blurRadius: 26,
              offset: const Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              right: -26,
              bottom: -30,
              child: IgnorePointer(
                child: Icon(
                  watermarkIcon,
                  size: 118,
                  color: Colors.white.withAlpha(12),
                ),
              ),
            ),
            Positioned(
              right: 22,
              top: 20,
              child: IgnorePointer(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(7),
                    border: Border.all(color: Colors.white.withAlpha(9)),
                  ),
                  child: Icon(secondIcon,
                      color: Colors.white.withAlpha(35), size: 16),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IgnorePointer(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withAlpha(18), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withAlpha(22),
                        border: Border.all(color: color.withAlpha(38)),
                      ),
                      child: Icon(pack.heroIcon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 44),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pack.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.35,
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pack.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 12.1,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withAlpha(26),
                    border: Border.all(color: Colors.white.withAlpha(9)),
                  ),
                  child: Text(
                    pack.scene,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(205),
                      fontSize: 12.6,
                      fontWeight: FontWeight.w800,
                      height: 1.32,
                    ),
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

class _ContextSectionTitle extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  const _ContextSectionTitle(
      {required this.color,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(18)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.1)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withAlpha(130),
                      fontSize: 11.4,
                      fontWeight: FontWeight.w700,
                      height: 1.25)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContextDialogueCard extends StatelessWidget {
  final List<_ContextDialogueLine> lines;
  final Color color;
  final String highlightKey;
  const _ContextDialogueCard(
      {required this.lines, required this.color, required this.highlightKey});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBubble = (constraints.maxWidth * 0.82).clamp(260.0, 460.0);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: tokens.isLight
                ? LinearGradient(colors: _grammarLightGlass(color))
                : null,
            color: tokens.isLight ? null : tokens.elevatedSurface,
            border: Border.all(
              color: tokens.isLight
                  ? _grammarGlassBorder(tokens, accent: color)
                  : tokens.border,
            ),
          ),
          child: Column(
            children: lines.asMap().entries.map((entry) {
              final line = entry.value;
              final isA = entry.key.isEven;
              return Align(
                alignment: isA ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxBubble),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isA ? 5 : 18),
                      bottomRight: Radius.circular(isA ? 18 : 5),
                    ),
                    color: isA ? tokens.inputSurface : color.withAlpha(30),
                    border: Border.all(
                        color: isA ? tokens.border : color.withAlpha(34)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_repairMojibake(line.text),
                          style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 13.2,
                              fontWeight: FontWeight.w800,
                              height: 1.3)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _HighlightedDialogueText extends StatelessWidget {
  final String text;
  final List<RegExp> patterns;
  final Color highlight;

  const _HighlightedDialogueText(
      {required this.text, required this.patterns, required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 13.2,
            fontWeight: FontWeight.w800,
            height: 1.3));
  }
}

List<RegExp> _highlightPatternsForKey(String key) {
  // Keep it conservative: highlight only stable ?forms?, not random words.
  switch (key) {
    case 'a1_be_verb':
      return [RegExp(r'\b(am|is|are)\b', caseSensitive: false)];
    case 'a1_present_simple':
      return [RegExp(r"\b(do|does|don\'t|doesn\'t)\b", caseSensitive: false)];
    case 'a1_present_continuous':
      return [RegExp(r'\b(am|is|are)\b\s+\w+ing\b', caseSensitive: false)];
    case 'a1_subject_pronouns':
      return [RegExp(r'\b(I|you|he|she|it|we|they)\b', caseSensitive: false)];
    case 'a1_possessive_adjectives':
      return [
        RegExp(r'\b(my|your|his|her|its|our|their)\b', caseSensitive: false)
      ];
    case 'a1_singular_plural':
      return [
        RegExp(r'\b(two|three|four|five|these|those)\b\s+\w+s\b',
            caseSensitive: false)
      ];
    case 'a1_demonstratives':
      return [RegExp(r'\b(this|that|these|those)\b', caseSensitive: false)];
    case 'a1_have_has_got':
      return [
        RegExp(r"\b(have|has|haven\'t|hasn\'t)\s+got\b", caseSensitive: false)
      ];
    case 'a1_basic_prepositions':
      return [RegExp(r'\b(in|on|at)\b', caseSensitive: false)];
    case 'a1_imperatives':
      return [
        RegExp(
            r"^(Please\s+)?(Open|Sit|Listen|Write|Don\'t|Do not|Look|Repeat)\b",
            caseSensitive: false)
      ];
    case 'a2_past_simple':
      return [
        RegExp(r"\b(did|didn\'t)\b", caseSensitive: false),
        RegExp(r'\b\w+ed\b', caseSensitive: false),
      ];
    case 'a2_past_continuous':
      return [RegExp(r'\b(was|were)\b\s+\w+ing\b', caseSensitive: false)];
    case 'a2_present_perfect':
    case 'a2_present_perfect_vs_past':
    case 'b1_present_perfect':
      return [
        RegExp(r"\b(have|has|haven\'t|hasn\'t)\b\s+\w+(ed|en)\b",
            caseSensitive: false)
      ];
    case 'b1_present_perfect_continuous':
      return [RegExp(r'\b(have|has)\s+been\s+\w+ing\b', caseSensitive: false)];
    case 'b1_past_perfect':
      return [RegExp(r'\bhad\b\s+\w+(ed|en)\b', caseSensitive: false)];
    case 'b1_past_perfect_continuous':
      return [RegExp(r'\bhad\s+been\s+\w+ing\b', caseSensitive: false)];
    case 'a2_should':
      return [
        RegExp(r"\b(should|shouldn\'t|ought to|had better)\b",
            caseSensitive: false)
      ];
    case 'a2_must_have_to':
      return [
        RegExp(
            r"\b(must|mustn\'t|have to|has to|don\'t have to|doesn\'t have to)\b",
            caseSensitive: false)
      ];
    case 'a2_will':
      return [RegExp(r"\b(will|won\'t)\b", caseSensitive: false)];
    case 'a2_going_to':
      return [RegExp(r'\b(am|is|are)\s+going to\b', caseSensitive: false)];
    default:
      if (key.contains('passive')) {
        return [
          RegExp(r'\b(am|is|are|was|were|been)\b\s+\w+(ed|en)\b',
              caseSensitive: false)
        ];
      }
      if (key == 'a1_articles') {
        return [RegExp(r'\b(a|an|the)\b', caseSensitive: false)];
      }
      if (key == 'a1_there_is_are') {
        return [RegExp(r'\bthere\s+(is|are)\b', caseSensitive: false)];
      }
      if (key == 'a1_some_any') {
        return [RegExp(r'\b(some|any)\b', caseSensitive: false)];
      }
      if (key == 'a1_how_much_many') {
        return [RegExp(r'\bhow\s+(much|many)\b', caseSensitive: false)];
      }
      if (key == 'a1_can_cant') {
        return [RegExp(r"\b(can|can\'t)\b", caseSensitive: false)];
      }
      return const [];
  }
}

String _contextSituationLabelForKey(String key, bool isEnglish) {
  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);
  switch (key) {
    case 'a1_be_verb':
      return t('At home', 'Evde');
    case 'a1_present_simple':
      return t('Morning routine', 'Sabah rutini');
    case 'a1_present_continuous':
      return t('Right now', '^u an');
    case 'a2_past_simple':
      return t('Yesterday evening', 'D�n ak?am');
    case 'a2_past_continuous':
      return t('In the middle of it', 'Tam ortas1nda');
    case 'a2_present_perfect':
    case 'b1_present_perfect':
      return t('At a cafe', 'Kafede');
    case 'a2_should':
      return t('Before an exam', 'Sınav öncesi');
    case 'a2_going_to':
      return t('Weekend plans', 'Hafta sonu plan1');
    case 'a2_will':
      return t('Quick decision', 'Anl1k karar');
    default:
      if (key.contains('passive')) return t('News / report', 'Haber / rapor');
      if (key.contains('conditional')) {
        return t('Planning together', 'Birlikte plan');
      }
      return t('Daily life', 'G�nl�k hayat');
  }
}

class _ContextPatternCard extends StatelessWidget {
  final GrammarLogicPoint point;
  final int index;
  final Color color;
  final bool isEnglish;

  const _ContextPatternCard({
    required this.point,
    required this.index,
    required this.color,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final title = point.title(isEnglish);
    final rule = point.logic(isEnglish);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(20),
            const Color(0xFF08111C).withAlpha(232),
            Colors.white.withAlpha(5),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(12), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 18,
              offset: const Offset(0, 9)),
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: color.withAlpha(22),
                  border: Border.all(color: color.withAlpha(36)),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.05),
                ),
              ),
              _ContextMicroPill(label: t('MODEL', 'MODEL'), color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            point.model,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.2,
              fontWeight: FontWeight.w900,
              height: 1.16,
              letterSpacing: -0.22,
            ),
          ),
          const SizedBox(height: 9),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black.withAlpha(24),
              border: Border.all(color: Colors.white.withAlpha(8)),
            ),
            child: Text(
              rule,
              style: TextStyle(
                  color: Colors.white.withAlpha(178),
                  fontSize: 12.1,
                  fontWeight: FontWeight.w800,
                  height: 1.32),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.close_rounded,
                  color: const Color(0xFFFF6B6B).withAlpha(220), size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  point.avoid,
                  style: TextStyle(
                    color: Colors.white.withAlpha(125),
                    fontSize: 12.2,
                    fontWeight: FontWeight.w800,
                    height: 1.26,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: const Color(0xFFFF6B6B).withAlpha(170),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextMicroPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ContextMicroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(32)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: Colors.white.withAlpha(205),
            fontSize: 9.6,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.45),
      ),
    );
  }
}

class _ContextScenarioCard extends StatelessWidget {
  final _ContextScenario scenario;
  final int index;
  final Color color;
  final bool isEnglish;

  const _ContextScenarioCard({
    required this.scenario,
    required this.index,
    required this.color,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 13, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(15),
            const Color(0xFF07111E).withAlpha(238),
            Colors.white.withAlpha(5),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(10), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(16),
              blurRadius: 15,
              offset: const Offset(0, 7)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: color.withAlpha(15),
              border: Border.all(color: color.withAlpha(28)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(scenario.icon, color: color.withAlpha(230), size: 17),
                const SizedBox(height: 5),
                Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 9.2,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        scenario.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color.withAlpha(235),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.03,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withAlpha(7),
                        border: Border.all(color: Colors.white.withAlpha(8)),
                      ),
                      child: Text(
                        t('SAY', 'SÖYLE'),
                        style: TextStyle(
                          color: Colors.white.withAlpha(150),
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  scenario.sentence,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.6,
                    fontWeight: FontWeight.w900,
                    height: 1.18,
                    letterSpacing: -0.16,
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

class _ContextTipCard extends StatelessWidget {
  final String tip;
  final Color color;
  final bool isEnglish;
  const _ContextTipCard(
      {required this.tip, required this.color, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: color.withAlpha(13),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tip,
                style: TextStyle(
                    color: Colors.white.withAlpha(210),
                    fontSize: 12.7,
                    fontWeight: FontWeight.w800,
                    height: 1.38)),
          ),
        ],
      ),
    );
  }
}

class _PracticeLesson extends StatefulWidget {
  final String task;
  final String modelAnswer;
  final String wrong;
  final String right;
  final String reason;
  final List<GrammarQuizQuestion> quiz;
  final List<String> examples;
  final List<GrammarFormulaRow> formulaRows;
  final bool revealed;
  final Color color;
  final bool isEnglish;
  final VoidCallback onReveal;

  const _PracticeLesson({
    required this.task,
    required this.modelAnswer,
    required this.wrong,
    required this.right,
    required this.reason,
    required this.quiz,
    required this.examples,
    required this.formulaRows,
    required this.revealed,
    required this.color,
    required this.isEnglish,
    required this.onReveal,
  });

  @override
  State<_PracticeLesson> createState() => _PracticeLessonState();
}

class _PracticeLessonState extends State<_PracticeLesson> {
  int modeIndex = 0;
  String? selectedFix;
  bool fixChecked = false;

  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  GrammarFormulaRow? get _fixRow =>
      _bestPracticeFixRow(widget.formulaRows, widget.right);
  String get fixRight => _cleanOptionSentence(
      _fixRow == null ? widget.right : _canonicalRowModel(_fixRow!));
  String get fixWrong => _cleanOptionSentence(_fixRow == null
      ? widget.wrong
      : _formulaAvoidSample(
          GrammarFormulaRow(
              label: _fixRow!.label,
              pattern: _fixRow!.pattern,
              sample: fixRight),
          true));
  List<String> get fixOptions => _practiceFixOptions(fixRight, fixWrong);

  void switchMode(int index) {
    if (index == modeIndex) return;
    setState(() {
      modeIndex = index;
      selectedFix = null;
      fixChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final modes = [t('Fix', 'Düzelt'), t('Build', 'Kur')];
    final safeIndex = modeIndex.clamp(0, modes.length - 1);
    final mission = _PracticeMissionData.forIndex(safeIndex, widget.isEnglish);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PracticeMissionPanel(
          color: widget.color,
          mission: mission,
          labels: modes,
          selectedIndex: safeIndex,
          onChanged: switchMode,
        ),
        const SizedBox(height: 14),
        _activePracticeMode(safeIndex),
      ],
    );
  }

  Widget _activePracticeMode(int safeIndex) {
    if (safeIndex == 0) {
      return _FixPracticePanel(
        wrong: fixWrong,
        right: fixRight,
        reason: _practiceReasonForRow(_fixRow, widget.reason, widget.isEnglish),
        options: fixOptions,
        selected: selectedFix,
        checked: fixChecked,
        color: widget.color,
        isEnglish: widget.isEnglish,
        onSelect: (value) => setState(() {
          selectedFix = value;
          fixChecked = false;
        }),
        onCheck: () => setState(() => fixChecked = selectedFix != null),
      );
    }

    return _BuildSentenceCard(
        answer: _shortBuildSentenceFor(
            widget.right, widget.examples, widget.formulaRows,
            avoid: fixRight),
        color: widget.color,
        isEnglish: widget.isEnglish);
  }
}

class _PracticeMissionData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PracticeMissionData(
      {required this.icon, required this.title, required this.subtitle});

  static _PracticeMissionData forIndex(int index, bool isEnglish) {
    String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);
    if (index == 1) {
      return _PracticeMissionData(
        icon: Icons.view_agenda_rounded,
        title: t('Build the sentence', 'Cümle kur'),
        subtitle: t('Drag words into the sentence area.',
            'Kelimeleri cümle alanına sürükle.'),
      );
    }
    return _PracticeMissionData(
      icon: Icons.auto_fix_high_rounded,
      title: t('Fix the mistake', 'Hatalı cümleyi düzelt'),
      subtitle: t('Read the wrong sentence, then choose the corrected version.',
          'Yanlış cümleyi oku, sonra düzeltilmiş hâlini seç.'),
    );
  }
}

class _PracticeMissionPanel extends StatelessWidget {
  final Color color;
  final _PracticeMissionData mission;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PracticeMissionPanel({
    required this.color,
    required this.mission,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(32),
            Colors.white.withAlpha(7),
            Colors.black.withAlpha(18)
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(13)),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(7),
              blurRadius: 24,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: color.withAlpha(24),
                  border: Border.all(color: color.withAlpha(42)),
                ),
                child: Icon(mission.icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.4,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.25)),
                    const SizedBox(height: 4),
                    Text(mission.subtitle,
                        style: TextStyle(
                            color: Colors.white.withAlpha(145),
                            fontSize: 12.1,
                            height: 1.25,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _PracticeModeTabs(
              labels: labels,
              selectedIndex: selectedIndex,
              color: color,
              onChanged: onChanged),
        ],
      ),
    );
  }
}

class _FixPracticePanel extends StatelessWidget {
  final String wrong;
  final String right;
  final String reason;
  final List<String> options;
  final String? selected;
  final bool checked;
  final Color color;
  final bool isEnglish;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;

  const _FixPracticePanel({
    required this.wrong,
    required this.right,
    required this.reason,
    required this.options,
    required this.selected,
    required this.checked,
    required this.color,
    required this.isEnglish,
    required this.onSelect,
    required this.onCheck,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final isCorrect = selected != null &&
        _cleanOptionSentence(selected!).toLowerCase() ==
            _cleanOptionSentence(right).toLowerCase();
    return _PracticeShell(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PracticeTitleRow(
              icon: Icons.auto_fix_high_rounded,
              color: color,
              title: t('Fix the sentence', 'Hatalı cümleyi düzelt'),
              trailing: ''),
          const SizedBox(height: 12),
          _BrokenSentenceBox(color: color, wrong: wrong, isEnglish: isEnglish),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final option = options[index];
            final chosen = selected == option;
            final correctOption = _cleanOptionSentence(option).toLowerCase() ==
                _cleanOptionSentence(right).toLowerCase();
            return Padding(
              padding:
                  EdgeInsets.only(bottom: index == options.length - 1 ? 0 : 9),
              child: _PracticeOptionTile(
                letter: String.fromCharCode(65 + index),
                text: option,
                color: color,
                selected: chosen,
                checked: checked,
                correct: correctOption,
                onTap: () => onSelect(option),
              ),
            );
          }),
          if (checked) ...[
            const SizedBox(height: 12),
            _PracticeResultCard(
              correct: isCorrect,
              color: color,
              title: isCorrect
                  ? t('Nice correction', 'Güzel düzeltme')
                  : t('Correct version', 'Doğru hâli'),
              body: isCorrect
                  ? _naturalPracticeReason(reason, right, isEnglish)
                  : right,
            ),
          ],
          const SizedBox(height: 14),
          _MiniActionButton(
            label: selected == null
                ? t('Choose an answer', 'Bir cevap seç')
                : t('Check answer', 'Cevabı kontrol et'),
            icon: Icons.search_rounded,
            color: color,
            soft: selected == null,
            onTap: selected == null ? () {} : onCheck,
          ),
        ],
      ),
    );
  }
}

class _BrokenSentenceBox extends StatelessWidget {
  final Color color;
  final String wrong;
  final bool isEnglish;

  const _BrokenSentenceBox(
      {required this.color, required this.wrong, required this.isEnglish});

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFFFF5F6D).withAlpha(11),
        border: Border.all(color: const Color(0xFFFF5F6D).withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('Sentence to fix', 'Düzeltilecek cümle'),
              style: const TextStyle(
                  color: Color(0xFFFF8A94),
                  fontSize: 11,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(wrong,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.25,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _PracticeOptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final Color color;
  final bool selected;
  final bool checked;
  final bool correct;
  final VoidCallback onTap;

  const _PracticeOptionTile({
    required this.letter,
    required this.text,
    required this.color,
    required this.selected,
    required this.checked,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final showCorrect = checked && correct;
    final showWrong = checked && selected && !correct;
    final borderColor = showCorrect
        ? const Color(0xFF28E681).withAlpha(95)
        : showWrong
            ? const Color(0xFFFF6B6B).withAlpha(85)
            : selected
                ? color.withAlpha(88)
                : Colors.white.withAlpha(14);
    final fillColor = showCorrect
        ? const Color(0xFF28E681).withAlpha(16)
        : showWrong
            ? const Color(0xFFFF6B6B).withAlpha(14)
            : selected
                ? color.withAlpha(22)
                : Colors.black.withAlpha(16);

    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: fillColor,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 29,
              height: 29,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(8),
                border: Border.all(color: Colors.white.withAlpha(13)),
              ),
              child: Text(letter,
                  style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 11),
            Expanded(
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.2,
                        height: 1.25,
                        fontWeight: FontWeight.w800))),
            if (showCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF28E681), size: 20),
            if (showWrong)
              const Icon(Icons.cancel_rounded,
                  color: Color(0xFFFF6B6B), size: 20),
          ],
        ),
      ),
    );
  }
}

List<String> _practiceFixOptions(String right, String wrong) {
  final cleanRight = _cleanOptionSentence(right);
  final cleanWrong = _cleanOptionSentence(wrong);
  final options = <String>[];

  void add(String value) {
    final clean = _cleanOptionSentence(value);
    if (clean.isEmpty ||
        !_isSentenceLike(clean) ||
        _looksLikeMetaOption(clean)) {
      return;
    }
    if (options.any((e) => e.toLowerCase() == clean.toLowerCase())) return;
    options.add(clean);
  }

  add(cleanWrong);
  add(cleanRight);
  for (final value in _sameTopicSlips(cleanRight)) {
    if (options.length >= 4) break;
    add(value);
  }
  for (final value in _safePracticeFallbacks(cleanRight)) {
    if (options.length >= 4) break;
    add(value);
  }
  var guard = 0;
  while (options.length < 4 && guard < 8) {
    final fallback = _safeFallbackByIndex(cleanRight, guard);
    add(fallback);
    guard++;
  }
  if (!options.any((e) => e.toLowerCase() == cleanRight.toLowerCase())) {
    add(cleanRight);
  }
  return options.take(4).toList();
}

bool _sameCleanSentence(String? a, String b) {
  if (a == null) return false;
  String norm(String value) => _cleanOptionSentence(value)
      .toLowerCase()
      .replaceAll(RegExp(r'[.!?]+$'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return norm(a) == norm(b);
}

String _cleanOptionSentence(String value) {
  var clean = value
      .replaceAll('�R', '')
      .replaceAll('�S&', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (clean.isEmpty) return clean;
  final lower = clean.toLowerCase();

  // Teacher-note/trap text must never become an option. Convert common
  // warning lines into the actual wrong sentence instead.
  if (lower.contains('i was studying, not i studying') ||
      lower.contains('not i studying')) {
    return 'I studying when you called.';
  }
  if (lower.contains('did not went')) return 'I did not went to school.';
  if (lower.contains('will goes')) return 'She will goes tomorrow.';
  if (lower.contains('i going to study')) return 'I going to study tonight.';
  if (lower.contains('more better')) return 'This answer is more better.';
  if (lower.contains('more easier')) {
    return 'This lesson is more easier than the last one.';
  }
  if (lower.contains('enough old')) return 'He is enough old to drive.';

  if (lower.startsWith('do not ') ||
      lower.startsWith('don\'t ') ||
      lower.startsWith("don't ") ||
      lower.startsWith('avoid ') ||
      lower.startsWith('ka�1')) {
    final afterColon = clean.split(':').last.trim();
    if (afterColon != clean && afterColon.length > 4) clean = afterColon;
  }

  // Any option / rule-check / practice sentence must be a single sentence.
  // This prevents choices like ?I watched a movie yesterday. She went...? from
  // appearing inside one button.
  final boundary = RegExp(r'[.!?]\s*(?=[A-Z])').firstMatch(clean);
  if (boundary != null && boundary.end < clean.length) {
    clean = clean.substring(0, boundary.start + 1).trim();
  }

  return clean.trim();
}

bool _isSentenceLike(String value) {
  final words =
      value.split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).length;
  return words >= 3 && !value.contains(':');
}

bool _looksLikeMetaOption(String value) {
  final lower = value.toLowerCase();
  return lower.contains('wrong word order') ||
      lower.contains('copy turkish') ||
      lower.contains('mistake') ||
      lower.contains('option uses') ||
      lower.contains('subject-form') ||
      lower.contains('yanl? yardımcı') ||
      lower.contains('kelime s?ras?') ||
      lower.startsWith('do not forget') ||
      lower.startsWith('remember ') ||
      lower.startsWith('use ') &&
          !lower.contains(' i ') &&
          !lower.contains(' she ') &&
          !lower.contains(' they ') ||
      lower.contains('before v-ing') ||
      lower.contains('after will') ||
      lower.contains('keep the main verb') ||
      lower.contains('do not mix') ||
      lower.contains('bu yap?y?') ||
      lower.contains('word order matters');
}

List<String> _sameTopicSlips(String right) {
  final clean = _cleanOptionSentence(right);
  final lower = clean.toLowerCase();
  final list = <String>[];
  void add(String value) {
    final v = _cleanOptionSentence(value);
    if (v.isEmpty || v.toLowerCase() == clean.toLowerCase()) return;
    if (!_isSentenceLike(v)) return;
    if (list.any((e) => e.toLowerCase() == v.toLowerCase())) return;
    list.add(v);
  }

  if (lower.contains('did not go')) {
    add(clean.replaceFirst('did not go', 'did not went'));
  }
  if (lower.contains(' was ') || lower.contains(' were ')) {
    add(clean.replaceFirst(RegExp(r'\b(was|were)\s+'), ''));
  }
  if (lower.contains('will go')) {
    add(clean.replaceFirst('will go', 'will goes'));
  }
  if (lower.contains('will ')) {
    add(clean.replaceFirstMapped(
        RegExp(r'\bwill\s+(\w+)'), (m) => 'will ${m[1]}s'));
  }
  if (lower.contains('going to')) {
    add(clean.replaceFirst(RegExp(r'\b(am|is|are)\s+going to\b'), 'going to'));
  }
  if (lower.contains('should ')) {
    add(clean.replaceFirstMapped(
        RegExp(r'\bshould\s+(\w+)'), (m) => 'should ${m[1]}s'));
  }
  if (lower.contains('must ')) {
    add(clean.replaceFirstMapped(
        RegExp(r'\bmust\s+(\w+)'), (m) => 'must to ${m[1]}'));
  }
  if (lower.contains('has to')) add(clean.replaceFirst('has to', 'have to'));
  if (lower.contains('old enough')) {
    add(clean.replaceFirst('old enough', 'enough old'));
  }
  if (lower.contains('enough money')) {
    add(clean.replaceFirst('enough money', 'money enough'));
  }
  if (lower.contains('better')) {
    add(clean.replaceFirst('better', 'more better'));
  }
  if (lower.contains('more useful')) {
    add(clean.replaceFirst('more useful', 'usefuler'));
  }
  if (lower.contains('the most')) add(clean.replaceFirst('the most', 'most'));
  if (lower.contains('used to')) add(clean.replaceFirst('used to', 'use to'));
  if (lower.contains('would like to')) {
    add(clean.replaceFirst('would like to', 'would like'));
  }
  if (lower.contains('if it rains')) {
    add(clean.replaceFirst('If it rains', 'If it will rain'));
  }
  if (lower.contains('enjoy reading')) {
    add(clean.replaceFirst('enjoy reading', 'enjoy to read'));
  }
  if (lower.contains('who helps')) {
    add(clean.replaceFirst('who helps', 'which helps'));
  }
  if (clean.contains(' works')) add(clean.replaceFirst(' works', ' work'));
  if (clean.contains(' likes')) add(clean.replaceFirst(' likes', ' like'));
  if (clean.contains(' studies')) add(clean.replaceFirst(' studies', ' study'));
  if (clean.contains(' does not ')) {
    add(clean
        .replaceAll(RegExp(r'\bwork\b'), 'works')
        .replaceAll(RegExp(r'\blike\b'), 'likes'));
  }
  return list;
}

List<String> _safePracticeFallbacks(String right) {
  final clean = _cleanOptionSentence(right).toLowerCase();
  if (clean.contains('was studying') || clean.contains('were watching')) {
    return [
      'I studying when you called.',
      'They was watching TV at 9.',
      'I was study when you called.'
    ];
  }
  if (clean.contains('did not go') || clean.contains('yesterday')) {
    return [
      'I did not went to school.',
      'Did you called me?',
      'She go to Ankara last week.'
    ];
  }
  if (clean.contains('will ')) {
    return [
      'She will goes tomorrow.',
      'They will to come.',
      'He wills call later.'
    ];
  }
  if (clean.contains('going to')) {
    return [
      'I going to study tonight.',
      'She are going to call.',
      'They going travel next month.'
    ];
  }
  if (clean.contains('should ')) {
    return [
      'She should studies more.',
      'You should to rest.',
      'He should goes home.'
    ];
  }
  if (clean.contains('must ') ||
      clean.contains('have to') ||
      clean.contains('has to')) {
    return [
      'She have to wake up early.',
      'You must to listen.',
      'He does not has to come.'
    ];
  }
  if (clean.contains('enough') || clean.contains('too ')) {
    return [
      'He is enough old.',
      'We have money enough.',
      'There are too much people.'
    ];
  }
  if (clean.contains('than')) {
    return [
      'This lesson is more easier than the last one.',
      'Kayseri is more cold than Antalya.',
      'This answer is more better.'
    ];
  }
  if (clean.contains('the most') ||
      clean.contains('the best') ||
      clean.contains('the tallest')) {
    return [
      'She is tallest student.',
      'This is most interesting lesson.',
      'He is the goodest player.'
    ];
  }
  if (clean.contains('used to')) {
    return [
      'Did you used to play football?',
      'I use to live there when I was a child.',
      'She didn\'t used to work.'
    ];
  }
  if (clean.contains('would like')) {
    return [
      'I would like go home.',
      'Would you like joining us?',
      'She would likes tea.'
    ];
  }
  if (clean.contains('if ')) {
    return [
      'If it will rain, I will stay home.',
      'If you heat water, it will boils.',
      'If students practised, they improve.'
    ];
  }
  if (clean.contains('who ') ||
      clean.contains('which ') ||
      clean.contains('that ')) {
    return [
      'A teacher is a person which helps students.',
      'This is the book who I bought.',
      'Kayseri is a city who has cold winters.'
    ];
  }
  if (clean.startsWith('does ')) {
    return [
      'Does she works every day?',
      'Does he likes tea?',
      'Does your brother plays football?'
    ];
  }
  if (clean.contains('does not')) {
    return [
      'She does not works every day.',
      'He does not likes tea.',
      'They does not watches TV.'
    ];
  }
  if (clean.contains('usually')) {
    return [
      'I drink usually tea in the morning.',
      'I usually drinks tea in the morning.',
      'I am usually drink tea.'
    ];
  }
  final smart = _smartCommonMistake(right, '', true);
  final swapped = _swapFirstTwoContentWords(right);
  final noHelper = _removeLikelyHelper(right);
  final out = <String>[];
  void add(String value) {
    final cleanValue = _cleanOptionSentence(value);
    if (cleanValue.isEmpty || cleanValue.toLowerCase() == right.toLowerCase()) {
      return;
    }
    if (!_isSentenceLike(cleanValue) || _looksLikeMetaOption(cleanValue)) {
      return;
    }
    if (out.any((e) => e.toLowerCase() == cleanValue.toLowerCase())) return;
    out.add(cleanValue);
  }

  add(smart);
  add(swapped);
  add(noHelper);
  if (out.isEmpty) {
    return [
      'I did not went to school.',
      'She will goes tomorrow.',
      'I studying when you called.'
    ];
  }
  return out;
}

String _swapFirstTwoContentWords(String sentence) {
  final parts = sentence.trim().split(RegExp(r'\s+'));
  if (parts.length < 4) return sentence;
  final copy = List<String>.from(parts);
  final temp = copy[1];
  copy[1] = copy[2];
  copy[2] = temp;
  return copy.join(' ');
}

String _removeLikelyHelper(String sentence) {
  return sentence
      .replaceFirst(
          RegExp(r'\b(am|is|are|was|were)\s+', caseSensitive: false), '')
      .replaceFirst(
          RegExp(r'\b(will|should|must|can)\s+', caseSensitive: false), '')
      .replaceFirst(RegExp(r'\b(have|has)\s+', caseSensitive: false), '');
}

String _safeFallbackByIndex(String right, int index) {
  final pool = _safePracticeFallbacks(right);
  return pool[index % pool.length];
}

String _naturalPracticeReason(String reason, String right, bool isEnglish) {
  if (reason.trim().isNotEmpty) return reason;
  return isEnglish
      ? 'This sentence uses the target grammar correctly: $right'
      : 'Bu cümle hedef yapıyı doğru kullanıyor: $right';
}

class _BuildSentenceCard extends StatefulWidget {
  final String answer;
  final Color color;
  final bool isEnglish;

  const _BuildSentenceCard(
      {required this.answer, required this.color, required this.isEnglish});

  @override
  State<_BuildSentenceCard> createState() => _BuildSentenceCardState();
}

class _BuildSentenceCardState extends State<_BuildSentenceCard> {
  late final List<String> words;
  final List<String> selectedWords = <String>[];
  bool checked = false;
  bool hoveringDropZone = false;

  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  @override
  void initState() {
    super.initState();
    final raw = widget.answer
        .replaceAll(RegExp(r'[?.!]$'), '')
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .toList();
    words = _deterministicScramble(raw);
  }

  bool get correct {
    final built = selectedWords.join(' ').toLowerCase();
    final target =
        widget.answer.replaceAll(RegExp(r'[?.!]$'), '').toLowerCase().trim();
    return built == target;
  }

  List<String> get availableWords {
    final available = List<String>.from(words);
    for (final selected in selectedWords) {
      available.remove(selected);
    }
    return available;
  }

  void addWord(String word) {
    if (!availableWords.contains(word)) return;
    setState(() {
      selectedWords.add(word);
      checked = false;
      hoveringDropZone = false;
    });
  }

  void reset() {
    setState(() {
      selectedWords.clear();
      checked = false;
      hoveringDropZone = false;
    });
  }

  void check() {
    if (selectedWords.isEmpty) return;
    setState(() => checked = true);
  }

  void moveSelectedWord(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= selectedWords.length) return;
    if (newIndex > selectedWords.length) newIndex = selectedWords.length;
    if (newIndex > oldIndex) newIndex -= 1;
    setState(() {
      final item = selectedWords.removeAt(oldIndex);
      selectedWords.insert(newIndex, item);
      checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final available = availableWords;
    final progress = words.isEmpty ? 0.0 : selectedWords.length / words.length;

    return _PracticeShell(
      color: widget.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PracticeTitleRow(
            icon: Icons.view_agenda_rounded,
            color: widget.color,
            title: t('Build one sentence', 'Tek cümle kur'),
            trailing: '${selectedWords.length}/${words.length}',
          ),
          const SizedBox(height: 7),
          Text(
            t('Use all word cards to build the target sentence.',
                'Kartların hepsini kullanıp tek hedef cümleyi kur.'),
            style: TextStyle(
                color: Colors.white.withAlpha(110),
                fontSize: 11.4,
                height: 1.25,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withAlpha(10),
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            ),
          ),
          const SizedBox(height: 12),
          DragTarget<String>(
            onWillAcceptWithDetails: (details) =>
                available.contains(details.data),
            onMove: (_) {
              if (!hoveringDropZone) setState(() => hoveringDropZone = true);
            },
            onLeave: (_) => setState(() => hoveringDropZone = false),
            onAcceptWithDetails: (details) => addWord(details.data),
            builder: (context, candidateData, rejectedData) {
              final active = hoveringDropZone || candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 72),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: active
                      ? widget.color.withAlpha(18)
                      : Colors.black.withAlpha(20),
                  border: Border.all(
                      color: active
                          ? widget.color.withAlpha(60)
                          : widget.color.withAlpha(26)),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: widget.color.withAlpha(12),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ]
                      : null,
                ),
                child: selectedWords.isEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t('Drop zone', 'Cümle alanı'),
                              style: TextStyle(
                                  color: widget.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 5),
                          Text(
                            t('Drag words here.', 'Kelimeleri buraya sürükle.'),
                            style: TextStyle(
                                color: Colors.white.withAlpha(115),
                                fontSize: 11.6,
                                height: 1.2,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withAlpha(18),
                              border:
                                  Border.all(color: widget.color.withAlpha(22)),
                            ),
                            child: Text(
                              selectedWords.join(' '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withAlpha(235),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          SizedBox(
                            height: 30,
                            child: ReorderableListView.builder(
                              scrollDirection: Axis.horizontal,
                              buildDefaultDragHandles: false,
                              proxyDecorator: (child, index, animation) =>
                                  Material(
                                      color: Colors.transparent, child: child),
                              onReorder: moveSelectedWord,
                              itemCount: selectedWords.length,
                              itemBuilder: (context, index) {
                                final word = selectedWords[index];
                                return Padding(
                                  key: ValueKey('selected_${word}_$index'),
                                  padding: const EdgeInsets.only(right: 5),
                                  child: ReorderableDelayedDragStartListener(
                                    index: index,
                                    child: _BuildChip(
                                      label: word,
                                      color: widget.color,
                                      selected: true,
                                      dragHint: false,
                                      compact: true,
                                      onTap: () => setState(() {
                                        selectedWords.removeAt(index);
                                        checked = false;
                                      }),
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
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Text(t('Word cards', 'Kelime kartlar1'),
                  style: TextStyle(
                      color: Colors.white.withAlpha(135),
                      fontSize: 11.6,
                      fontWeight: FontWeight.w900)),
              const Spacer(),
              Text(t('drag or tap', 'sürükle veya dokun'),
                  style: TextStyle(
                      color: Colors.white.withAlpha(82),
                      fontSize: 10.6,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: available.isEmpty
                ? [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: widget.color.withAlpha(16),
                        border: Border.all(color: widget.color.withAlpha(30)),
                      ),
                      child: Text(t('All words added', 'Tüm kelimeler eklendi'),
                          style: TextStyle(
                              color: Colors.white.withAlpha(145),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800)),
                    ),
                  ]
                : available.map((word) {
                    final chip = _BuildChip(
                      label: word,
                      color: widget.color,
                      selected: false,
                      dragHint: false,
                      compact: true,
                      onTap: () => addWord(word),
                    );
                    return Draggable<String>(
                      data: word,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _BuildChip(
                            label: word,
                            color: widget.color,
                            selected: true,
                            dragHint: false,
                            compact: true,
                            onTap: () {}),
                      ),
                      childWhenDragging: Opacity(opacity: 0.32, child: chip),
                      child: chip,
                    );
                  }).toList(),
          ),
          if (checked) ...[
            const SizedBox(height: 13),
            _PracticeResultCard(
              correct: correct,
              color: widget.color,
              title: correct
                  ? t('Perfect order', 'Sıralama doğru')
                  : t('Correct order', 'Doğru sıra'),
              body: correct
                  ? t('The sentence is built correctly.',
                      'Cümleyi doğru kurdun.')
                  : widget.answer,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _MiniActionButton(
                      label: t('Reset', 'S1f1rla'),
                      icon: Icons.refresh_rounded,
                      color: widget.color,
                      soft: true,
                      onTap: reset)),
              const SizedBox(width: 9),
              Expanded(
                  child: _MiniActionButton(
                      label: t('Check order', 'S1ray1 kontrol et'),
                      icon: Icons.check_rounded,
                      color: widget.color,
                      soft: false,
                      onTap: check)),
            ],
          ),
        ],
      ),
    );
  }
}

List<String> _deterministicScramble(List<String> original) {
  final words = List<String>.from(original);
  if (words.length <= 2) return words.reversed.toList();
  final first = words.removeAt(0);
  final last = words.removeLast();
  words.insert(0, last);
  words.add(first);
  return words;
}

class _BuildChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final bool dragHint;
  final bool compact;
  final VoidCallback onTap;

  const _BuildChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.dragHint,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = compact ? 10.0 : 12.0;
    final vertical = compact ? 5.0 : 9.0;
    final fontSize = compact ? 13.2 : 12.0;
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? color.withAlpha(22) : Colors.white.withAlpha(7),
          border: Border.all(
              color:
                  selected ? color.withAlpha(40) : Colors.white.withAlpha(13)),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withAlpha(7),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dragHint && !compact) ...[
              Icon(Icons.drag_indicator_rounded, color: color, size: 13),
              const SizedBox(width: 5)
            ],
            Text(label,
                style: TextStyle(
                    color: Colors.white.withAlpha(235),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    height: 1)),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.close_rounded,
                  color: Colors.white.withAlpha(115), size: 13)
            ],
          ],
        ),
      ),
    );
  }
}

class _PracticeWritingCard extends StatefulWidget {
  final String task;
  final String modelAnswer;
  final bool revealed;
  final Color color;
  final bool isEnglish;
  final VoidCallback onReveal;

  const _PracticeWritingCard({
    required this.task,
    required this.modelAnswer,
    required this.revealed,
    required this.color,
    required this.isEnglish,
    required this.onReveal,
  });

  @override
  State<_PracticeWritingCard> createState() => _PracticeWritingCardState();
}

class _PracticeWritingCardState extends State<_PracticeWritingCard> {
  late final TextEditingController controller;
  bool checked = false;

  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int get wordCount {
    final clean = controller.text.trim();
    if (clean.isEmpty) return 0;
    return clean.split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).length;
  }

  bool get enough => wordCount >= 5;

  @override
  Widget build(BuildContext context) {
    return _PracticeShell(
      color: widget.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PracticeTitleRow(
              icon: Icons.edit_note_rounded,
              color: widget.color,
              title: t('Write a natural sentence', 'Doğal bir cümle yaz'),
              trailing: t('$wordCount words', '$wordCount kelime')),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.black.withAlpha(20),
                border: Border.all(color: Colors.white.withAlpha(12))),
            child: Text(
                t('Write one clear sentence from daily life.',
                    'Günlük hayattan net bir cümle yaz.'),
                style: TextStyle(
                    color: Colors.white.withAlpha(165),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 6,
            onChanged: (_) => setState(() => checked = false),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13.2,
                height: 1.35,
                fontWeight: FontWeight.w700),
            cursorColor: widget.color,
            decoration: InputDecoration(
              hintText: t('Example: I usually drink tea in the morning.',
                  'Örnek: I usually drink tea in the morning.'),
              hintStyle: TextStyle(
                  color: Colors.white.withAlpha(72),
                  fontSize: 12.8,
                  fontWeight: FontWeight.w700),
              filled: true,
              fillColor: Colors.black.withAlpha(24),
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withAlpha(14))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: widget.color.withAlpha(85))),
            ),
          ),
          if (checked) ...[
            const SizedBox(height: 13),
            _PracticeResultCard(
              correct: enough,
              color: widget.color,
              title: enough
                  ? t('Good start', 'İyi başlangıç')
                  : t('Add a little more', 'Biraz daha ekle'),
              body: enough
                  ? t('Now compare it with the example sentence.',
                      'Şimdi örnek cümleyle karşılaştırabilirsin.')
                  : t('Aim for at least five words.',
                      'En az be_ kelime hedefle.'),
            ),
          ],
          if (widget.revealed) ...[
            const SizedBox(height: 13),
            _PracticeResultCard(
                correct: true,
                color: widget.color,
                title: t('Example sentence', 'Örnek cümle'),
                body: widget.modelAnswer),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _MiniActionButton(
                      label: t('Check answer', 'Cevabı kontrol et'),
                      icon: Icons.spellcheck_rounded,
                      color: widget.color,
                      soft: false,
                      onTap: () => setState(() => checked = true))),
              const SizedBox(width: 9),
              Expanded(
                  child: _MiniActionButton(
                      label: t('Show example', 'Örneği göster'),
                      icon: Icons.visibility_rounded,
                      color: widget.color,
                      soft: true,
                      onTap: widget.onReveal)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PracticeShell extends StatelessWidget {
  final Color color;
  final Widget child;

  const _PracticeShell({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withAlpha(6),
        border: Border.all(color: Colors.white.withAlpha(13)),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(6),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: child,
    );
  }
}

class _PracticeTitleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String trailing;

  const _PracticeTitleRow(
      {required this.icon,
      required this.color,
      required this.title,
      required this.trailing});

  @override
  Widget build(BuildContext context) {
    final showTrailing = trailing.trim().isNotEmpty;
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.2,
                    fontWeight: FontWeight.w900))),
        if (showTrailing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: color.withAlpha(18),
                border: Border.all(color: color.withAlpha(32))),
            child: Text(trailing,
                style: TextStyle(
                    color: color, fontSize: 10.8, fontWeight: FontWeight.w900)),
          ),
      ],
    );
  }
}

class _PracticeResultCard extends StatelessWidget {
  final bool correct;
  final Color color;
  final String title;
  final String body;

  const _PracticeResultCard(
      {required this.correct,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) {
    final c = correct ? const Color(0xFF28E681) : const Color(0xFFFFB020);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: c.withAlpha(15),
          border: Border.all(color: c.withAlpha(34))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(correct ? Icons.check_circle_rounded : Icons.lightbulb_rounded,
              color: c, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: c, fontSize: 12.1, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(body,
                    style: TextStyle(
                        color: Colors.white.withAlpha(170),
                        fontSize: 12.2,
                        height: 1.3,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeModeTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final Color color;
  final ValueChanged<int> onChanged;

  const _PracticeModeTabs(
      {required this.labels,
      required this.selectedIndex,
      required this.color,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.black.withAlpha(22),
          border: Border.all(color: Colors.white.withAlpha(12))),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = selectedIndex == index;
          return Expanded(
            child: _TapScale(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: selected
                      ? LinearGradient(
                          colors: [color.withAlpha(170), color.withAlpha(86)])
                      : null,
                  color: selected ? null : Colors.transparent,
                ),
                child: Text(labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withAlpha(125),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

List<GrammarQuizQuestion> _engineQuizQuestionsFor(
    GrammarLesson lesson, bool isEnglish) {
  final points = generateGrammarLogicPoints(lesson)
      .where((point) =>
          _isSentenceLike(point.model) &&
          _isSentenceLike(point.avoid) &&
          !_sameCleanSentence(point.model, point.avoid))
      .toList();

  String clean(String value) => _cleanOptionSentence(value);

  List<String> optionsForPoint(GrammarLogicPoint point, int seed) {
    final answer = clean(point.model);
    final opts = <String>[];

    void add(String value) {
      final v = clean(value);
      if (v.isEmpty) return;
      if (!_isSentenceLike(v) || _looksLikeMetaOption(v)) return;
      if (opts.any((x) => x.toLowerCase() == v.toLowerCase())) return;
      opts.add(v);
    }

    add(answer);
    add(point.avoid);

    for (final slip in _sameTopicSlips(answer)) {
      if (opts.length >= 4) break;
      add(slip);
    }

    for (final other in points) {
      if (opts.length >= 4) break;
      if (!_sameCleanSentence(other.model, answer)) add(other.avoid);
    }

    for (final fallback in _safePracticeFallbacks(answer)) {
      if (opts.length >= 4) break;
      add(fallback);
    }

    var guard = 0;
    while (opts.length < 4 && guard < 12) {
      add(_smallGrammarSlip(answer, seed + guard));
      guard++;
    }

    return opts.take(4).toList();
  }

  if (points.isNotEmpty) {
    return List.generate(10, (index) {
      final point = points[index % points.length];
      final answer = clean(point.model);
      return GrammarQuizQuestion(
        id: 'engine_point_$index',
        type: _quizTypeForPoint(point, index),
        prompt: _quizPromptForPoint(point, answer, index, isEnglish),
        options: optionsForPoint(point, index),
        answer: answer,
        explanation: point.logic(isEnglish),
      );
    });
  }

  final rows = _normalizedFormulaRowsFor(lesson);
  final right = _cleanOptionSentence(_learnModelSentenceFor(lesson, isEnglish));
  final wrong = _cleanOptionSentence(_learnAvoidSentenceFor(lesson, isEnglish));
  final reason = _learnRuleReasonFor(lesson, isEnglish);
  final examples = <String>[
    right,
    ...rows.map((row) => _cleanOptionSentence(_canonicalRowModel(row))),
    ...lesson.examples.map((e) => _cleanOptionSentence(e.trim())),
  ]
      .where(
          (e) => e.isNotEmpty && !_looksLikeMetaOption(e) && _isSentenceLike(e))
      .toList();

  final unique = <String>[];
  for (final e in examples) {
    if (!unique.any((x) => x.toLowerCase() == e.toLowerCase())) unique.add(e);
  }

  List<String> optionsFor(String answer, int seed, {GrammarFormulaRow? row}) {
    final opts = <String>[answer];
    void add(String v) {
      final clean = _cleanOptionSentence(v);
      if (clean.isEmpty ||
          !_isSentenceLike(clean) ||
          _looksLikeMetaOption(clean)) {
        return;
      }
      if (opts.any((x) => x.toLowerCase() == clean.toLowerCase())) return;
      opts.add(clean);
    }

    if (row != null) add(_formulaAvoidSample(row, true));
    for (final slip in _sameTopicSlips(answer)) {
      if (opts.length >= 4) break;
      add(slip);
    }
    add(_smartCommonMistake(answer, reason, isEnglish));
    add(wrong);
    var i = 0;
    while (opts.length < 4 && i < 8) {
      add(_smallGrammarSlip(answer, seed + i));
      i++;
    }
    i = 0;
    while (opts.length < 4 && i < 8) {
      add(_safeFallbackByIndex(answer, seed + i));
      i++;
    }
    while (opts.length < 4) {
      opts.add(isEnglish ? 'Wrong grammar form.' : 'Yanlış grammar formu.');
    }
    return opts.take(4).toList();
  }

  final questions = <GrammarQuizQuestion>[];
  void addQ(
      String id, String prompt, String answer, int seed, String explanation,
      {GrammarFormulaRow? row, GrammarQuizType? type}) {
    final cleanAnswer = _cleanOptionSentence(answer);
    if (cleanAnswer.isEmpty) return;
    questions.add(GrammarQuizQuestion(
      id: id,
      type: GrammarQuizType.fillBlank,
      prompt: prompt,
      options: optionsFor(cleanAnswer, seed, row: row),
      answer: cleanAnswer,
      explanation: explanation,
    ));
  }

  for (var i = 0; i < rows.length && questions.length < 8; i++) {
    final row = rows[i];
    addQ(
      'engine_row_$i',
      _quizPromptForRow(row, _canonicalRowModel(row), i, isEnglish),
      _canonicalRowModel(row),
      i + 1,
      isEnglish
          ? 'This example matches the form: ${row.pattern}.'
          : 'Bu örnek şu kalıba uyuyor: ${row.pattern}.',
      row: row,
      type: GrammarQuizType.fillBlank,
    );
  }
  for (var i = 0; i < unique.length && questions.length < 10; i++) {
    addQ(
      'engine_example_$i',
      _quizPromptForExample(unique[i], i, isEnglish),
      unique[i],
      i + 7,
      reason,
      type: GrammarQuizType.fillBlank,
    );
  }
  while (questions.length < 10) {
    addQ(
      'engine_fill_${questions.length}',
      _quizPromptForExample(right, questions.length, isEnglish),
      right,
      questions.length + 10,
      reason,
      type: GrammarQuizType.fillBlank,
    );
  }
  return questions.take(10).toList();
}

class _ClozeSpec {
  final String sentence; // contains ____ placeholder
  final String answer;
  final List<String> options; // should include answer + 3 distractors
  final String explanationTr;
  final String explanationEn;

  const _ClozeSpec({
    required this.sentence,
    required this.answer,
    required this.options,
    required this.explanationTr,
    required this.explanationEn,
  });
}

List<GrammarQuizQuestion> _fillBlankQuizPackForLesson(
    GrammarLesson lesson, bool isEnglish) {
  final key = _lessonKey(lesson);
  final specs = _clozeBankForKey(key);

  final questions = <GrammarQuizQuestion>[];

  void addSpec(_ClozeSpec spec, int index) {
    final answer = _repairMojibake(spec.answer.trim());
    final opts = _fillBlankOptions(
        spec.options.map(_repairMojibake).toList(growable: false), answer);
    if (opts.length != 4) return;
    questions.add(
      GrammarQuizQuestion(
        id: 'cloze_${key}_$index',
        type: GrammarQuizType.fillBlank,
        prompt: isEnglish ? 'Complete the sentence.' : 'Boşluğu doldur.',
        sentence: _normalizeBlankMarker(_repairMojibake(spec.sentence)),
        options: opts,
        answer: answer,
        explanation: _repairMojibake(
            isEnglish ? spec.explanationEn : spec.explanationTr),
      ),
    );
  }

  for (var i = 0; i < specs.length; i++) {
    addSpec(specs[i], i);
    if (questions.length >= 10) break;
  }

  if (questions.length >= 6) return questions;

  // Generic fallback generator: build cloze from clean example sentences.
  final sentencePool = <String>[
    ..._exampleBankForKey(key, true),
    ...lesson.examples,
    lesson.right,
    lesson.modelAnswer,
    ...generateGrammarLogicPoints(lesson).map((p) => p.model),
  ]
      .map(_cleanOptionSentence)
      .where((s) =>
          s.isNotEmpty &&
          _isSentenceLike(s) &&
          !_looksLikeMetaOption(s) &&
          !_contextLooksTeacherish(s))
      .toList(growable: false);

  final tokens = _blankTokenCandidatesForKey(key);
  var guard = 0;

  for (final s in sentencePool) {
    if (questions.length >= 10 || guard > 40) break;
    guard++;
    final built = _buildTokenCloze(s, tokens);
    if (built == null) continue;

    final opts = _fillBlankOptions(
        _distractorsForToken(built.answer, key), built.answer);
    if (opts.length != 4) continue;

    questions.add(
      GrammarQuizQuestion(
        id: 'auto_${key}_${questions.length}',
        type: GrammarQuizType.fillBlank,
        prompt: isEnglish ? 'Complete the sentence.' : 'Boşluğu doldur.',
        sentence: _normalizeBlankMarker(_repairMojibake(built.sentence)),
        options: opts,
        answer: _repairMojibake(built.answer),
        explanation: isEnglish
            ? 'Choose the correct form for this structure.'
            : 'Bu yapıda doğru formu seç. Yardımcı fiil ve fiil formunu kontrol et.',
      ),
    );
  }

  return questions.take(10).toList(growable: false);
}

List<String> _fillBlankOptions(List<String> raw, String answer) {
  final seen = <String>{};
  final out = <String>[];
  void add(String v) {
    final clean = _cleanQuizOptionText(v);
    if (clean.isEmpty) return;
    final key = clean.toLowerCase();
    if (seen.contains(key)) return;
    seen.add(key);
    out.add(clean);
  }

  for (final o in raw) {
    add(o);
  }
  add(answer);

  return out.take(4).toList(growable: false);
}

List<_ClozeSpec> _clozeBankForKey(String key) {
  // Premium: sentence is natural, answer is unique, distractors are plausible.
  switch (key) {
    case 'a1_be_verb':
      return const [
        _ClozeSpec(
          sentence: 'I ____ hungry.',
          answer: 'am',
          options: ['am', 'is', 'are', 'be'],
          explanationTr:
              'I öznesi ile be verb olarak "am" kullanılır: I am hungry. "is/are" I ile kullanılmaz.',
          explanationEn: 'With ?I?, the correct be verb is "am": I am hungry.',
        ),
        _ClozeSpec(
          sentence: 'She ____ at home.',
          answer: 'is',
          options: ['is', 'am', 'are', 'be'],
          explanationTr:
              'She ile "is" gelir: She is at home. "are" çoğul/you için, "am" sadece I içindir.',
          explanationEn: 'With ?she?, use "is": She is at home.',
        ),
        _ClozeSpec(
          sentence: 'They ____ students.',
          answer: 'are',
          options: ['are', 'is', 'am', 'be'],
          explanationTr:
              'They çoğuldur, bu yüzden "are" kullanılır: They are students.',
          explanationEn: 'With ?they?, use "are": They are students.',
        ),
        _ClozeSpec(
          sentence: '____ you tired?',
          answer: 'Are',
          options: ['Are', 'Is', 'Am', 'Do'],
          explanationTr:
              'Soruda be verb başa gelir: Are you tired? "Do" be verb sorularında kullanılmaz.',
          explanationEn: 'In questions, be verb comes first: Are you tired?',
        ),
        _ClozeSpec(
          sentence: 'He ____ not ready.',
          answer: 'is',
          options: ['is', 'are', 'am', 'do'],
          explanationTr:
              'Olumsuzda "not" be verbden sonra gelir: He is not ready.',
          explanationEn: 'In negatives, ?not? comes after be: He is not ready.',
        ),
      ];
    case 'a1_present_simple':
      return const [
        _ClozeSpec(
          sentence: 'She ____ to school every day.',
          answer: 'goes',
          options: ['goes', 'go', 'going', 'went'],
          explanationTr:
              'He/She/It ile Present Simple olumlu cümlede fiile -s/-es gelir: she goes. "go" eksik kalır.',
          explanationEn:
              'With he/she/it, Present Simple affirmative takes -s/-es: she goes.',
        ),
        _ClozeSpec(
          sentence: 'They ____ coffee in the morning.',
          answer: 'drink',
          options: ['drink', 'drinks', 'drinking', 'drank'],
          explanationTr:
              'They ile fiil yalın kalır: they drink. -s sadece he/she/it ile gelir.',
          explanationEn: 'With they, use base verb: they drink.',
        ),
        _ClozeSpec(
          sentence: 'He ____ like tea.',
          answer: "doesn't",
          options: ["doesn't", "don't", "isn't", "didn't"],
          explanationTr:
              'Olumsuz Present Simple: he doesn\'t + V1. "don\'t" I/you/we/they içindir.',
          explanationEn: 'Present Simple negative with he: he doesn\'t + V1.',
        ),
        _ClozeSpec(
          sentence: '____ she work here?',
          answer: 'Does',
          options: ['Does', 'Do', 'Is', 'Did'],
          explanationTr:
              'Soruda Does + özne + V1 kullanılır: Does she work? "works" olmaz çünkü does zaten -s ekini taşır.',
          explanationEn: 'Use Does + subject + base verb: Does she work&?',
        ),
        _ClozeSpec(
          sentence: 'We ____ usually eat out.',
          answer: "don't",
          options: ["don't", "doesn't", "isn't", "aren't"],
          explanationTr:
              'We ile olumsuz: don\'t + V1. "doesn\'t" he/she/it içindir.',
          explanationEn: 'With we, negative is don\'t + base verb.',
        ),
      ];
    case 'a1_present_continuous':
      return const [
        _ClozeSpec(
          sentence: 'They ____ watching a movie now.',
          answer: 'are',
          options: ['are', 'is', 'am', 'do'],
          explanationTr:
              'Present Continuous: am/is/are + V-ing. They ile "are" kullanılır: They are watching.',
          explanationEn:
              'Present Continuous uses am/is/are + V-ing. With they, use are.',
        ),
        _ClozeSpec(
          sentence: 'She ____ studying at the moment.',
          answer: 'is',
          options: ['is', 'are', 'am', 'does'],
          explanationTr:
              'She ile "is" gelir: She is studying. Yardımcı fiil olmadan V-ing tek başına yetmez.',
          explanationEn: 'With she, use is: She is studying&',
        ),
        _ClozeSpec(
          sentence: 'I ____ not working today.',
          answer: 'am',
          options: ['am', 'is', 'are', 'do'],
          explanationTr: 'I ile "am" kullanılır: I am not working today.',
          explanationEn: 'With I, use am: I am not working today.',
        ),
        _ClozeSpec(
          sentence: '____ you coming with us?',
          answer: 'Are',
          options: ['Are', 'Do', 'Is', 'Does'],
          explanationTr:
              'Present Continuous sorusu: Are you coming? "Do" ile kurulmaz.',
          explanationEn: 'Present Continuous question: Are you coming&?',
        ),
      ];
    case 'a1_can_cant':
      return const [
        _ClozeSpec(
          sentence: 'I ____ swim, but I can\'t dive.',
          answer: 'can',
          options: ['can', 'am', 'do', 'have'],
          explanationTr:
              'Yetenek için "can" kullanırız: I can swim. Can kelimesinden sonra fiil yalın gelir.',
          explanationEn:
              'Use ?can? for ability: I can swim. After can, use the base verb.',
        ),
        _ClozeSpec(
          sentence: 'She ____ speak English very well.',
          answer: 'can',
          options: ['can', 'cans', 'can to', 'is'],
          explanationTr:
              'Can, he/she/it ile -s almaz: She can speak. "cans" yanlış.',
          explanationEn: 'Can never takes -s: She can speak& ?cans? is wrong.',
        ),
        _ClozeSpec(
          sentence: 'He ____ drive. He is only 14.',
          answer: "can't",
          options: ["can't", "doesn't", "isn't", "don't"],
          explanationTr:
              'Olumsuz yetenek: can\'t/cannot + V1. "doesn\'t" can ile kullanılmaz.',
          explanationEn: 'Negative ability: can\'t/cannot + base verb.',
        ),
        _ClozeSpec(
          sentence: '____ you help me, please?',
          answer: 'Can',
          options: ['Can', 'Do', 'Are', 'Does'],
          explanationTr:
              'Soru: Can + özne + V1? Do/does can sorularında kullanılmaz.',
          explanationEn: 'Questions start with Can: Can you&?',
        ),
        _ClozeSpec(
          sentence: 'Can you ____ the window? (request)',
          answer: 'open',
          options: ['open', 'opens', 'opening', 'to open'],
          explanationTr:
              'Can kelimesinden sonra fiil yalın gelir: can open. "to open" veya "opens" olmaz.',
          explanationEn: 'After can, use base verb: can open (no "to", no -s).',
        ),
        _ClozeSpec(
          sentence: 'No, I ____ . I can\'t come today.',
          answer: "can't",
          options: ["can't", "am not", "don't", "isn't"],
          explanationTr:
              'Kısa cevap: No, I can\'t. "Can you?" sorusuna cevapta can/can\'t kullanılır.',
          explanationEn: 'Short answer mirrors the question: No, I can\'t.',
        ),
      ];
    case 'a2_past_simple':
      return const [
        _ClozeSpec(
          sentence: 'Ali ____ football yesterday.',
          answer: 'played',
          options: ['played', 'play', 'plays', 'playing'],
          explanationTr:
              'Bitmiş geçmiş zaman (yesterday) varsa Past Simple kullanılır. Olumlu cümlede fiil V2 olur: play -> played.',
          explanationEn:
              'With a finished past time (yesterday), use Past Simple: play -> played.',
        ),
        _ClozeSpec(
          sentence: 'She ____ go to school yesterday.',
          answer: "didn't",
          options: ["didn't", "doesn't", "isn't", "wasn't"],
          explanationTr:
              'Past Simple olumsuz: didn\'t + V1. ?wasn\'t? sadece be verb ile olur (wasn\'t at school).',
          explanationEn: 'Past Simple negative uses didn\'t + base verb (V1).',
        ),
        _ClozeSpec(
          sentence: '____ you watch the film last night?',
          answer: 'Did',
          options: ['Did', 'Do', 'Are', 'Were'],
          explanationTr:
              'Geçmişte bitmiş zaman (last night) için soru ?Did + özne + V1? olur: Did you watch...?',
          explanationEn: 'Past Simple question: Did + subject + base verb.',
        ),
        _ClozeSpec(
          sentence: 'Where did he ____ after school?',
          answer: 'go',
          options: ['go', 'went', 'going', 'goes'],
          explanationTr:
              'Did geldikten sonra fiil V1 olur: go. "went" sadece olumlu Past Simple\'da kullanılır.',
          explanationEn: 'After did, use base verb (go), not went.',
        ),
        _ClozeSpec(
          sentence: 'We ____ to the park two days ago.',
          answer: 'went',
          options: ['went', 'go', 'goes', 'going'],
          explanationTr:
              'Olumlu Past Simple\'da düzensiz fiil V2 olur: go -> went. "two days ago" bitmiş zamandır.',
          explanationEn:
              'In affirmative Past Simple, irregular verbs use V2: go -> went.',
        ),
      ];
    case 'a2_past_continuous':
      return const [
        _ClozeSpec(
          sentence: 'They ____ watching TV at 9 pm.',
          answer: 'were',
          options: ['were', 'was', 'are', 'did'],
          explanationTr:
              'Past Continuous: was/were + V-ing. They ile ?were? kullanılır.',
          explanationEn:
              'Past Continuous uses was/were + V-ing. With they, use were.',
        ),
        _ClozeSpec(
          sentence: 'I ____ cooking when you called.',
          answer: 'was',
          options: ['was', 'were', 'am', 'did'],
          explanationTr:
              'I ile Past Continuous\'da ?was? gelir: I was cooking&',
          explanationEn: 'With I, use was: I was cooking&',
        ),
        _ClozeSpec(
          sentence: 'She ____ not listening.',
          answer: 'was',
          options: ['was', 'were', 'did', 'is'],
          explanationTr: 'Olumsuz Past Continuous: was/were + not + V-ing.',
          explanationEn: 'Negative Past Continuous: was/were + not + V-ing.',
        ),
        _ClozeSpec(
          sentence: '____ you studying at 8?',
          answer: 'Were',
          options: ['Were', 'Was', 'Did', 'Do'],
          explanationTr: 'Soruda was/were başa gelir: Were you studying&?',
          explanationEn: 'Questions: Was/Were + subject + V-ing?',
        ),
      ];
    case 'a2_will':
      return const [
        _ClozeSpec(
          sentence: 'I think it ____ rain tomorrow.',
          answer: 'will',
          options: ['will', 'is', 'does', 'did'],
          explanationTr:
              'Tahmin için will kullanılır: I think it will rain& Will\'den sonra fiil yal?n kalır.',
          explanationEn: 'Use will for predictions: I think it will rain&',
        ),
        _ClozeSpec(
          sentence: 'I ____ help you. Don\'t worry.',
          answer: 'will',
          options: ['will', 'am', 'do', 'did'],
          explanationTr:
              'Konuşma anında verilen söz/karar için will kullanılır: I will help you.',
          explanationEn:
              'Use will for a quick decision/promise: I will help you.',
        ),
        _ClozeSpec(
          sentence: 'He will ____ you later.',
          answer: 'call',
          options: ['call', 'calls', 'called', 'calling'],
          explanationTr:
              'Will\'den sonra fiil V1 olur: will call. ?will calls? olmaz.',
          explanationEn: 'After will, use base verb: will call.',
        ),
        _ClozeSpec(
          sentence: '____ you help me with this?',
          answer: 'Will',
          options: ['Will', 'Do', 'Did', 'Are'],
          explanationTr: 'Will ile soru: Will you + V1...?',
          explanationEn: 'Will questions: Will you + base verb&?',
        ),
      ];
    case 'a2_going_to':
      return const [
        _ClozeSpec(
          sentence: 'I ____ going to study tonight.',
          answer: 'am',
          options: ['am', 'is', 'are', 'do'],
          explanationTr:
              'Be going to: am/is/are going to + V1. I ile "am" gerekir.',
          explanationEn: 'Be going to needs am/is/are. With I, use am.',
        ),
        _ClozeSpec(
          sentence: 'She is going to ____ next month.',
          answer: 'travel',
          options: ['travel', 'travels', 'traveled', 'traveling'],
          explanationTr: 'Going to\'dan sonra fiil V1 olur: going to travel.',
          explanationEn: 'After going to, use base verb: going to travel.',
        ),
        _ClozeSpec(
          sentence: '____ you going to join us?',
          answer: 'Are',
          options: ['Are', 'Do', 'Did', 'Will'],
          explanationTr: 'Soru: Are you going to&? (be verb başa gelir).',
          explanationEn: 'Questions: Are you going to&?',
        ),
        _ClozeSpec(
          sentence: 'They ____ going to buy a car. (They decided not to.)',
          answer: "aren't",
          options: ["aren't", "don't", "didn't", "won't"],
          explanationTr:
              'Going to olumsuz: am/is/are + not. They � aren\'t going to&',
          explanationEn: 'Negative: am/is/are + not going to&',
        ),
      ];
    case 'a2_must_have_to':
      return const [
        _ClozeSpec(
          sentence: 'You ____ wear a seatbelt.',
          answer: 'must',
          options: ['must', 'should', 'can', 'did'],
          explanationTr:
              'Zorunluluk için must kullanılır: You must wear& "should" tavsiyedir.',
          explanationEn: 'Use must for obligation: You must wear&',
        ),
        _ClozeSpec(
          sentence: 'You ____ smoke here. (It\'s forbidden.)',
          answer: "mustn't",
          options: ["mustn't", "don't have to", "shouldn't", "can't to"],
          explanationTr:
              'Mustn?t = yasak. ?Don\'t have to? yasak değil, mecbur değilsin anlamıdır.',
          explanationEn: 'Mustn?t means prohibition (forbidden).',
        ),
        _ClozeSpec(
          sentence: 'I ____ to wake up early tomorrow.',
          answer: 'have',
          options: ['have', 'has', 'had', 'am'],
          explanationTr:
              'I ile "have to? kullanılır: I have to& ?has to? he/she/it içindir.',
          explanationEn: 'With I, use have to: I have to&',
        ),
        _ClozeSpec(
          sentence: 'He ____ to show his ID.',
          answer: 'has',
          options: ['has', 'have', 'had', 'is'],
          explanationTr: 'He/she/it ile ?has to? gelir: He has to&',
          explanationEn: 'With he/she/it, use has to: He has to&',
        ),
        _ClozeSpec(
          sentence: 'You ____ have to come today. (It\'s optional.)',
          answer: "don't",
          options: ["don't", "mustn't", "doesn't", "isn't"],
          explanationTr:
              'Don\'t have to = mecbur değilsin. ?mustn\'t? yasaktır; anlam? farklıdır.',
          explanationEn:
              'Don\'t have to means no necessity (optional), not prohibition.',
        ),
      ];
    case 'a2_present_perfect':
    case 'b1_present_perfect':
      return const [
        _ClozeSpec(
          sentence: 'I ____ never been to London.',
          answer: 'have',
          options: ['have', 'has', 'did', 'am'],
          explanationTr:
              'Present Perfect: have/has + V3. I ile "have" gelir: I have never been. "has" he/she/it içindir.',
          explanationEn: 'Present Perfect: have/has + V3. With I, use have.',
        ),
        _ClozeSpec(
          sentence: 'She ____ already finished her work.',
          answer: 'has',
          options: ['has', 'have', 'did', 'is'],
          explanationTr:
              'She ile "has" kullanılır: She has already finished. "have" I/you/we/they içindir.',
          explanationEn: 'With she, use has: She has already finished.',
        ),
        _ClozeSpec(
          sentence: '____ you ever tried sushi?',
          answer: 'Have',
          options: ['Have', 'Has', 'Did', 'Are'],
          explanationTr:
              'Present Perfect soru: Have you ever...? Deneyim sorarken Past Simple "Did" değil, Present Perfect kullanırız.',
          explanationEn:
              'Experience questions use Present Perfect: Have you ever...?',
        ),
        _ClozeSpec(
          sentence: 'They ____ seen this film yet.',
          answer: "haven't",
          options: ["haven't", "hasn't", "didn't", "aren't"],
          explanationTr:
              'They ile olumsuz Present Perfect: haven\'t + V3. "hasn\'t" he/she/it içindir.',
          explanationEn: 'With they, negative is haven\'t + V3.',
        ),
        _ClozeSpec(
          sentence: 'I have just ____.',
          answer: 'arrived',
          options: ['arrived', 'arrive', 'arrives', 'arriving'],
          explanationTr:
              '"have + V3" yapısında fiil V3 olur: have just arrived. "arrive" (V1) burada eksik kalır.',
          explanationEn:
              'After have/has, use past participle (V3): have just arrived.',
        ),
      ];
    case 'a2_should':
      return const [
        _ClozeSpec(
          sentence: 'You ____ see a doctor.',
          answer: 'should',
          options: ['should', 'must', 'can', 'did'],
          explanationTr:
              'Tavsiye verirken "should" kullanırız: You should see a doctor. "must" daha çok zorunluluktur.',
          explanationEn:
              'Use "should" to give advice: You should see a doctor.',
        ),
        _ClozeSpec(
          sentence: 'You ____ stay up late tonight.',
          answer: "shouldn't",
          options: ["shouldn't", "don't", "mustn't", "can't"],
          explanationTr:
              'Olumsuz tavsiye: shouldn\'t + V1. "mustn\'t" yasak anlamına kayabilir; tavsiyede en doğal seçenek shouldn\'t.',
          explanationEn: 'Negative advice uses shouldn\'t + base verb.',
        ),
        _ClozeSpec(
          sentence: '____ I call her now?',
          answer: 'Should',
          options: ['Should', 'Do', 'Did', 'Am'],
          explanationTr:
              'Should sorusu: Should I + V1...? "Do" yardımcı fiili burada kullanılmaz.',
          explanationEn: 'Should questions: Should I + base verb?',
        ),
        _ClozeSpec(
          sentence: 'You ____ to rest today.',
          answer: 'ought',
          options: ['ought', 'should', 'must', 'will'],
          explanationTr:
              '"ought to" tavsiye verir. Cümlede boşluk "ought"tur çünkü devamında "to" zaten var: ought to rest.',
          explanationEn:
              '"ought to" is advice. If "to" is already there, the blank is "ought".',
        ),
      ];
    default:
      return const [];
  }
}

class _TokenCloze {
  final String sentence;
  final String answer;
  const _TokenCloze(this.sentence, this.answer);
}

List<String> _blankTokenCandidatesForKey(String key) {
  switch (key) {
    case 'a1_be_verb':
      return const ['am', 'is', 'are'];
    case 'a1_present_simple':
      return const ["don't", "doesn't", 'do', 'does', 'goes', 'works', 'likes'];
    case 'a1_present_continuous':
      return const ['am', 'is', 'are'];
    case 'a1_subject_pronouns':
      return const ['I', 'you', 'he', 'she', 'it', 'we', 'they'];
    case 'a1_singular_plural':
      return const ['books', 'boxes', 'children', 'bags', 'chairs', 'pens'];
    case 'a1_have_has_got':
      return const ['have got', 'has got', 'have', 'has'];
    case 'a1_basic_prepositions':
      return const ['in', 'on', 'at'];
    case 'a1_imperatives':
      return const ['Open', 'sit', 'Listen', 'Write', "Don't", 'Do not'];
    case 'a2_past_simple':
      return const ["didn't", 'did', 'went', 'saw', 'bought'];
    case 'a2_past_continuous':
      return const ['was', 'were'];
    case 'a2_present_perfect':
    case 'a2_present_perfect_vs_past':
    case 'b1_present_perfect':
      return const ["haven't", "hasn't", 'have', 'has', 'been'];
    case 'b1_present_perfect_continuous':
      return const ['have been', 'has been', 'been'];
    case 'b1_past_perfect':
      return const ['had'];
    case 'b1_past_perfect_continuous':
      return const ['had been', 'had'];
    case 'a2_should':
      return const ["shouldn't", 'should', 'ought to', 'had better'];
    case 'a2_must_have_to':
      return const ["mustn't", 'must', 'have to', 'has to', "don't have to"];
    case 'a2_will':
      return const ["won't", 'will'];
    case 'a2_going_to':
      return const ['am going to', 'is going to', 'are going to', 'going to'];
    case 'a2_first_conditional':
      return const ['if', 'will', "won't", 'unless'];
    case 'a2_zero_conditional':
      return const ['if', 'when'];
    case 'a2_comparatives':
      return const ['than', 'more', 'better', 'worse'];
    case 'a2_superlatives':
      return const ['the most', 'the best', 'the worst', 'the'];
    default:
      if (key.contains('passive')) {
        return const ['was', 'were', 'is', 'are', 'been'];
      }
      if (key.contains('reported')) return const ['said', 'told', 'asked'];
      if (key.contains('relative')) {
        return const ['who', 'which', 'that', 'where'];
      }

      // Fall back to signature-based tokens so every topic can generate cloze.
      final sig = _exampleSignatureGroupsForKey(key);
      if (sig.isNotEmpty) {
        final tokens = <String>[];
        for (final group in sig) {
          for (final token in group) {
            // Avoid pronoun-like tokens; quizzes should target grammar, not ?which pronoun? here.
            if (const {
              'i',
              'you',
              'he',
              'she',
              'it',
              'we',
              'they',
              'me',
              'him',
              'her',
              'us',
              'them'
            }.contains(token.toLowerCase())) {
              continue;
            }
            if (!tokens.contains(token)) tokens.add(token);
          }
        }
        return tokens.take(8).toList(growable: false);
      }
      return const [];
  }
}

_TokenCloze? _buildTokenCloze(String sentence, List<String> candidateTokens) {
  final clean = sentence.trim();
  if (clean.isEmpty) return null;
  for (final token in candidateTokens) {
    final pattern =
        RegExp(r'\b' + RegExp.escape(token) + r'\b', caseSensitive: false);
    final m = pattern.firstMatch(clean);
    if (m == null) continue;
    final answer = clean.substring(m.start, m.end);
    final withBlank = clean.replaceRange(m.start, m.end, '_____');
    return _TokenCloze(withBlank, answer);
  }
  return null;
}

List<String> _distractorsForToken(String answer, String key) {
  final a = answer.trim();
  final lower = a.toLowerCase();

  // Token-level distractors: keep them plausible and in the same ?slot?.
  if (key == 'a1_be_verb') return [a, 'is', 'are', 'am'];
  if (key == 'a1_present_continuous') return [a, 'is', 'are', 'am'];
  if (key == 'a2_past_continuous') return [a, 'was', 'were', 'did'];
  if (key.contains('present_perfect')) return [a, 'have', 'has', 'did'];
  if (key == 'a2_should') return [a, 'should', 'must', 'can'];
  if (key == 'a2_must_have_to') return [a, 'must', 'have to', "don't have to"];
  if (key == 'a2_will') return [a, 'will', "won't", 'going to'];
  if (key == 'a2_going_to') return [a, 'am going to', 'will', 'going'];
  if (key == 'a1_articles') return [a, 'a', 'an', 'the'];
  if (key == 'a1_there_is_are') return [a, 'is', 'are', 'am'];
  if (key == 'a1_some_any') return [a, 'some', 'any', 'many'];
  if (key == 'a1_how_much_many') return [a, 'many', 'much', 'some'];
  if (key == 'a1_can_cant') return [a, 'can', "can't", 'cannot'];
  if (key == 'a1_demonstratives') return [a, 'this', 'that', 'these', 'those'];
  if (key == 'a1_possessive_adjectives') {
    return [a, 'my', 'your', 'his', 'her', 'their'];
  }
  if (key == 'a1_subject_pronouns') return [a, 'I', 'you', 'he', 'she'];
  if (key == 'a1_singular_plural') {
    return [a, 'book', 'books', 'child', 'children'];
  }
  if (key == 'a1_have_has_got') {
    return [a, 'have got', 'has got', 'have', 'has'];
  }
  if (key == 'a1_basic_prepositions') return [a, 'in', 'on', 'at', 'to'];
  if (key == 'a1_imperatives') {
    if (lower == "don't" || lower == 'do not') {
      return [a, "Don't", 'Do', 'Not', 'No'];
    }
    return [a, 'open', 'opens', 'opening', 'to open'];
  }
  if (key == 'a1_object_pronouns') return [a, 'me', 'him', 'her', 'them'];

  // Generic fallback: light variations.
  if (lower == 'am') return const ['am', 'is', 'are', 'be'];
  if (lower == 'is') return const ['is', 'am', 'are', 'be'];
  if (lower == 'are') return const ['are', 'is', 'am', 'be'];
  if (lower == 'do') return const ['do', 'does', 'did', 'done'];
  if (lower == 'does') return const ['does', 'do', 'did', 'done'];
  if (lower == 'did') return const ['did', 'do', 'does', 'done'];
  if (lower == 'have') return const ['have', 'has', 'had', 'did'];
  if (lower == 'has') return const ['has', 'have', 'had', 'did'];
  if (lower == 'had') return const ['had', 'have', 'has', 'did'];

  return [
    a,
    _smallGrammarSlip(a, 1),
    _smallGrammarSlip(a, 2),
    _smallGrammarSlip(a, 3)
  ];
}

GrammarQuizType _quizTypeForPoint(GrammarLogicPoint point, int index) {
  return GrammarQuizType.fillBlank;
}

GrammarQuizType _quizTypeForRow(GrammarFormulaRow row, int index) {
  return GrammarQuizType.fillBlank;
}

GrammarQuizType _quizTypeForExample(int index) {
  return GrammarQuizType.fillBlank;
}

String _quizPromptForPoint(
    GrammarLogicPoint point, String answer, int index, bool isEnglish) {
  final avoid = _cleanOptionSentence(point.avoid);
  final gap = _gapPromptFromSentence(answer);
  final type = _quizTypeForPoint(point, index);
  if (type == GrammarQuizType.fillBlank && gap.isNotEmpty) {
    return isEnglish ? 'Gap fill: $gap' : 'Boşluk doldur: $gap';
  }
  if (type == GrammarQuizType.errorCorrection && avoid.isNotEmpty) {
    return isEnglish
        ? 'Error correction: fix "$avoid".'
        : 'Hata düzeltme: "$avoid" cümlesini düzelt.';
  }
  if (type == GrammarQuizType.transformation && avoid.isNotEmpty) {
    return isEnglish
        ? 'Transformation: keep the meaning, but make the grammar natural.'
        : 'Dönüştürme: anlamı koru, grammar yapısını doğal yap.';
  }
  if (type == GrammarQuizType.sentenceOrder) {
    return isEnglish
        ? 'Sentence order: choose the option with the correct word order.'
        : 'Cümle sırası: doğru kelime sırasını seç.';
  }
  return isEnglish ? 'Choose the correct option.' : 'Doğru seçeneği seç.';
}

String _quizPromptForRow(
    GrammarFormulaRow row, String answer, int index, bool isEnglish) {
  final kind = _rowKind(row);
  final gap = _gapPromptFromSentence(answer);
  if (kind == 'question') {
    return isEnglish
        ? 'Question form: choose the correctly ordered question.'
        : 'Soru yapısı: doğru sıralanmış soruyu seç.';
  }
  if (kind == 'negative') {
    return isEnglish
        ? 'Negative form: choose the sentence that uses the negative correctly.'
        : 'Olumsuz yapı: olumsuzu doğru kullanan cümleyi seç.';
  }
  if (gap.isNotEmpty && index.isEven) {
    return isEnglish ? 'Gap fill: $gap' : 'Boşluk doldur: $gap';
  }
  return isEnglish
      ? 'Form check: which option follows "${row.pattern}"?'
      : 'Form kontrolü: hangi seçenek "${row.pattern}" kalıbına uyuyor?';
}

String _quizPromptForExample(String answer, int index, bool isEnglish) {
  final gap = _gapPromptFromSentence(answer);
  switch (_quizTypeForExample(index)) {
    case GrammarQuizType.fillBlank:
      return gap.isEmpty
          ? (isEnglish
              ? 'Gap fill: choose the best grammar form.'
              : 'Boşluk doldur: en iyi grammar formunu seç.')
          : (isEnglish ? 'Gap fill: $gap' : 'Boşluk doldur: $gap');
    case GrammarQuizType.errorCorrection:
      return isEnglish
          ? 'Error detection: which option is grammatically correct?'
          : 'Hata bulma: hangi seçenek grammar olarak doğru?';
    case GrammarQuizType.transformation:
      return isEnglish
          ? 'Transformation: choose the most natural corrected sentence.'
          : 'Dönüştürme: en doğal düzeltilmiş cümleyi seç.';
    case GrammarQuizType.sentenceOrder:
      return isEnglish
          ? 'Word order: choose the sentence with clean English order.'
          : 'Kelime sırası: temiz İngilizce sırayı seç.';
    default:
      return isEnglish ? 'Choose the correct option.' : 'Doğru seçeneği seç.';
  }
}

String _gapPromptFromSentence(String answer) {
  final words = _cleanOptionSentence(answer)
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .toList();
  if (words.length < 3) return '';
  final lowerWords = words
      .map((word) => word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ''))
      .toList();
  final targets = [
    'am',
    'is',
    'are',
    'was',
    'were',
    'do',
    'does',
    'did',
    'have',
    'has',
    'had',
    'will',
    'would',
    'should',
    'must',
    'can',
    'might',
    'may',
    'been',
    'being',
    'to',
    'than'
  ];
  var targetIndex = lowerWords.indexWhere((word) => targets.contains(word));
  if (targetIndex < 0) targetIndex = words.length > 4 ? 2 : 1;
  final copy = [...words];
  copy[targetIndex] = '_____';
  return copy.join(' ');
}

String _quizTypeLabel(GrammarQuizType type, bool isEnglish) {
  switch (type) {
    case GrammarQuizType.fillBlank:
      return isEnglish ? 'Fill in the blank' : 'Boşluk doldurma';
    case GrammarQuizType.sentenceOrder:
      return isEnglish ? 'Word order' : 'Sıralama';
    case GrammarQuizType.errorCorrection:
      return isEnglish ? 'Correction' : 'Düzeltme';
    case GrammarQuizType.transformation:
      return isEnglish ? 'Transform' : 'Dönüştür';
    case GrammarQuizType.matching:
      return isEnglish ? 'Match' : 'Eşle';
    case GrammarQuizType.multipleChoice:
      return isEnglish ? 'Multiple choice' : 'Çoktan seçmeli';
  }
}

class _MistakesLesson extends StatelessWidget {
  final GrammarLesson lesson;
  final List<GrammarFormulaRow> formulaRows;
  final Color color;
  final bool isEnglish;

  const _MistakesLesson({
    required this.lesson,
    required this.formulaRows,
    required this.color,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final wrong = lesson.wrong.trim();
    final right = lesson.right.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withAlpha(18),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('Common mistake', 'Yaygın hata'),
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
          ),
          if (wrong.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(wrong,
                style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
          ],
          if (right.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(right,
                style: TextStyle(
                    color: color, fontSize: 12.5, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

class _QuizLesson extends StatefulWidget {
  final GrammarLesson lesson;
  final Color color;
  final bool isEnglish;
  final bool Function(int score, int total) onCompleted;

  const _QuizLesson({
    super.key,
    required this.lesson,
    required this.color,
    required this.isEnglish,
    required this.onCompleted,
  });

  @override
  State<_QuizLesson> createState() => _QuizLessonState();
}

class _QuizLessonState extends State<_QuizLesson> {
  int quizIndex = 0;
  String? selected;
  bool checked = false;
  bool finished = false;
  int correctCount = 0;
  final Set<int> answeredCorrectly = <int>{};
  final Map<int, String> userAnswers = <int, String>{};
  bool reviewWrongMode = false;
  List<int> reviewIndexes = <int>[];
  bool rewardEarned = false;

  String t(String en, String tr) => widget.isEnglish ? en : _repairMojibake(tr);

  List<GrammarQuizQuestion> get questions {
    final raw = <GrammarQuizQuestion>[
      ...widget.lesson.quiz,
      ..._fillBlankQuizPackForLesson(widget.lesson, widget.isEnglish),
    ];
    if (raw.isEmpty) return const <GrammarQuizQuestion>[];

    final normalized = <GrammarQuizQuestion>[];
    final seenPrompts = <String>{};
    for (final q in raw) {
      final next = _normalizedQuizQuestion(
          q, normalized.length, widget.lesson, widget.isEnglish);
      final sentence = (next.sentence ?? '').trim();
      final promptKey =
          '${sentence.toLowerCase()}|${next.answer.toLowerCase()}';
      if (!sentence.contains('_____')) continue;
      if (next.options.length != 4) continue;
      if (next.answer.trim().isEmpty) continue;
      if (seenPrompts.contains(promptKey)) continue;
      seenPrompts.add(promptKey);
      normalized.add(next);
      if (normalized.length >= 10) break;
    }

    return normalized;
  }

  GrammarQuizQuestion _normalizedQuizQuestion(
      GrammarQuizQuestion q, int index, GrammarLesson lesson, bool isEnglish) {
    final lessonKey = _lessonKey(lesson);
    final showContentSupport = _showTurkishContentSupport(lessonKey, isEnglish);
    final explanation = showContentSupport
        ? _quizExplanationDisplay(q, isEnglish)
        : (isEnglish
            ? 'Choose the form that completes the target structure.'
            : 'Hedef yapıyı tamamlayan formu seç.');
    return _legacyQuestionAsFillBlank(
      q,
      index,
      lesson,
      isEnglish,
      explanation,
    );
  }

  int get activeQuestionIndex => reviewWrongMode && reviewIndexes.isNotEmpty
      ? reviewIndexes[quizIndex.clamp(0, reviewIndexes.length - 1)]
      : quizIndex.clamp(0, questions.length - 1);

  GrammarQuizQuestion get currentQuestion => questions[activeQuestionIndex];

  void selectOption(String value) {
    if (checked || finished) return;
    setState(() => selected = value);
  }

  void checkOption() {
    if (selected == null || finished) return;

    final correct =
        _quizAnswerKey(selected!) == _quizAnswerKey(currentQuestion.answer);

    setState(() {
      checked = true;
      userAnswers[activeQuestionIndex] = selected!;
      if (correct && !answeredCorrectly.contains(activeQuestionIndex)) {
        answeredCorrectly.add(activeQuestionIndex);
        correctCount++;
      }
    });

    PremiumFeedback.show(
      context,
      message: correct
          ? t(
              'Correct. Voxa found the pattern with you.',
              'Doğru. Voxa kalıbı seninle birlikte buldu.',
            )
          : t(
              'Not quite. Voxa points to the rule; check the explanation.',
              'Henüz değil. Voxa kuralı işaret ediyor; açıklamaya bak.',
            ),
      tone: correct ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );
  }

  void nextOption() {
    if (!checked) {
      checkOption();
      return;
    }

    final completingFullQuiz =
        !reviewWrongMode && quizIndex >= questions.length - 1;

    setState(() {
      final maxIndex =
          reviewWrongMode ? reviewIndexes.length - 1 : questions.length - 1;
      if (quizIndex < maxIndex) {
        quizIndex++;
        final nextRealIndex = activeQuestionIndex;
        selected = userAnswers[nextRealIndex];
        checked = selected != null;
      } else {
        finished = true;
        reviewWrongMode = false;
        reviewIndexes = <int>[];
      }
    });

    if (completingFullQuiz) {
      final wasNew = widget.onCompleted(correctCount, questions.length);
      if (mounted && rewardEarned != wasNew) {
        setState(() => rewardEarned = wasNew);
      }
    }
  }

  void retry() {
    setState(() {
      quizIndex = 0;
      selected = null;
      checked = false;
      finished = false;
      correctCount = 0;
      answeredCorrectly.clear();
      userAnswers.clear();
      reviewWrongMode = false;
      reviewIndexes = <int>[];
      rewardEarned = false;
    });
  }

  void reviewWrong() {
    final wrongOnly = List.generate(questions.length, (index) => index)
        .where((index) => !answeredCorrectly.contains(index))
        .toList();

    setState(() {
      reviewIndexes = wrongOnly.isEmpty ? <int>[0] : wrongOnly;
      reviewWrongMode = true;
      quizIndex = 0;
      final firstRealIndex = reviewIndexes.first;
      selected = userAnswers[firstRealIndex];
      checked = selected != null;
      finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = reviewWrongMode ? reviewIndexes.length : questions.length;
    final lessonKey = _lessonKey(widget.lesson);
    final showContentSupport =
        _showTurkishContentSupport(lessonKey, widget.isEnglish);

    if (finished) {
      return _QuizResultCard(
        color: widget.color,
        score: correctCount,
        total: total,
        isEnglish: widget.isEnglish,
        showContentSupport: showContentSupport,
        isA1A2: _isA1A2LessonKey(lessonKey),
        rewardEarned: rewardEarned,
        onRetry: retry,
        onReviewWrong: reviewWrong,
      );
    }

    final question = currentQuestion;
    final isCorrect = selected != null &&
        _quizAnswerKey(selected!) == _quizAnswerKey(question.answer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompactQuizProgress(
          color: widget.color,
          current: quizIndex + 1,
          total: total,
          score: correctCount,
          isEnglish: widget.isEnglish,
        ),
        const SizedBox(height: 12),
        _QuizQuestionCard(
          question: question,
          selected: selected,
          checked: checked,
          isCorrect: isCorrect,
          color: widget.color,
          index: quizIndex,
          total: total,
          onSelect: selectOption,
          onCheck: checkOption,
          onNext: nextOption,
          isEnglish: widget.isEnglish,
          showContentSupport: showContentSupport,
        ),
      ],
    );
  }
}

GrammarQuizQuestion _questionWithBalancedOptions(
    GrammarQuizQuestion question, int index) {
  final answer = question.answer.trim();
  final seen = <String>{};
  final options = <String>[];

  // If the lesson already provides a full, curated option set, do not inject
  // extra ?smart slips? that can create off-topic A1 distractors.
  final originalClean = question.options
      .map(_cleanQuizOptionText)
      .where((e) => e.trim().isNotEmpty)
      .toList(growable: false);
  if (originalClean.isNotEmpty) {
    final unique = <String>[];
    final uniqueKeys = <String>{};
    for (final o in originalClean) {
      final key = _quizAnswerKey(o);
      if (key.isEmpty || uniqueKeys.contains(key)) continue;
      uniqueKeys.add(key);
      unique.add(o);
    }
    final answerKey = _quizAnswerKey(answer);
    final hasAnswer = unique.any((o) => _quizAnswerKey(o) == answerKey);
    if (hasAnswer && unique.length >= 4) {
      final firstFour = unique.take(4).toList(growable: false);
      if (firstFour.any((o) => _quizAnswerKey(o) == answerKey)) {
        return GrammarQuizQuestion(
          id: question.id,
          type: question.type,
          prompt: question.prompt,
          options: firstFour,
          answer: question.answer,
          explanation: question.explanation,
          sentence: question.sentence,
          items: question.items,
          pairs: question.pairs,
        );
      }
      // If the curated answer exists but falls outside the first 4, keep 3 + answer.
      final withoutAnswer = firstFour
          .where((o) => _quizAnswerKey(o) != answerKey)
          .take(3)
          .toList();
      return GrammarQuizQuestion(
        id: question.id,
        type: question.type,
        prompt: question.prompt,
        options: [
          ...withoutAnswer,
          unique.firstWhere((o) => _quizAnswerKey(o) == answerKey)
        ],
        answer: question.answer,
        explanation: question.explanation,
        sentence: question.sentence,
        items: question.items,
        pairs: question.pairs,
      );
    }
  }

  bool isSentenceOptionType() {
    switch (question.type) {
      case GrammarQuizType.fillBlank:
      case GrammarQuizType.sentenceOrder:
        return false;
      case GrammarQuizType.multipleChoice:
      case GrammarQuizType.errorCorrection:
      case GrammarQuizType.transformation:
      case GrammarQuizType.matching:
        return true;
    }
  }

  void add(String value, {bool force = false}) {
    final clean = _cleanQuizOptionText(value);
    if (clean.isEmpty) return;
    if (!force && isSentenceOptionType()) {
      if (!_isSentenceLike(clean)) return;
      if (_looksLikeMetaOption(clean)) return;
    }
    final key = clean.toLowerCase();
    if (seen.contains(key)) return;
    seen.add(key);
    options.add(clean);
  }

  for (final option in question.options) {
    add(option);
  }
  add(answer, force: true);

  if (isSentenceOptionType()) {
    for (final slip in _sameTopicSlips(answer)) {
      add(slip);
      if (options.length >= 4) break;
    }
    add(_smartCommonMistake(answer, '', true));
  }

  var guard = 0;
  while (options.length < 4 && guard < 12) {
    add(_smallGrammarSlip(answer, guard));
    guard++;
  }

  final answerIndex =
      options.indexWhere((e) => e.trim().toLowerCase() == answer.toLowerCase());
  if (answerIndex == -1) {
    options.insert(0, answer);
  }

  final normalizedAnswerIndex =
      options.indexWhere((e) => e.trim().toLowerCase() == answer.toLowerCase());
  final answerText = options.removeAt(normalizedAnswerIndex);
  final targetSlots = [1, 3, 0, 2, 2, 0, 3, 1, 0, 2];
  final target = targetSlots[index % targetSlots.length].clamp(0, 3).toInt();

  final finalOptions = options.take(3).toList();
  while (finalOptions.length < 3) {
    finalOptions.add(_smallGrammarSlip(answer, finalOptions.length + index));
  }
  finalOptions.insert(target, answerText);

  return GrammarQuizQuestion(
    id: question.id,
    type: question.type,
    prompt: question.prompt,
    options: finalOptions.take(4).toList(),
    answer: question.answer,
    explanation: question.explanation,
  );
}

GrammarQuizQuestion _legacyQuestionAsFillBlank(
  GrammarQuizQuestion question,
  int index,
  GrammarLesson lesson,
  bool isEnglish,
  String explanation,
) {
  final lessonKey = _lessonKey(lesson);
  var answer = _cleanQuizOptionText(question.answer);
  var sentence = _normalizeBlankMarker(question.sentence ?? '');

  if (!sentence.contains('_____')) {
    final fromPrompt = _extractBlankSentence(question.prompt);
    if (fromPrompt.isNotEmpty) sentence = fromPrompt;
  }

  if (!sentence.contains('_____') || _looksLikeSentenceAnswer(answer)) {
    final source = _bestClozeSource(question, lesson);
    final built =
        _buildTokenCloze(source, _blankTokenCandidatesForKey(lessonKey));
    if (built != null) {
      sentence = _normalizeBlankMarker(built.sentence);
      answer = _cleanQuizOptionText(built.answer);
    }
  }

  if (!sentence.contains('_____')) {
    final generated = _fillBlankQuizPackForLesson(lesson, isEnglish);
    if (generated.isNotEmpty) {
      final fallback = generated[index % generated.length];
      sentence = _normalizeBlankMarker(fallback.sentence ?? '');
      answer = _cleanQuizOptionText(fallback.answer);
    }
  }

  if (answer.isEmpty) {
    final built =
        _buildTokenCloze(lesson.right, _blankTokenCandidatesForKey(lessonKey));
    if (built != null) {
      sentence = _normalizeBlankMarker(built.sentence);
      answer = _cleanQuizOptionText(built.answer);
    }
  }

  final options = _balancedFillBlankOptions(
    [
      ...question.options,
      ..._distractorsForToken(answer, lessonKey),
      _smallGrammarSlip(answer, index + 2),
      _smallGrammarSlip(answer, index + 3),
      _smallGrammarSlip(answer, index + 4),
      _smallGrammarSlip(answer, index + 1),
      answer,
    ],
    answer,
    lessonKey,
    index,
  );

  return GrammarQuizQuestion(
    id: question.id,
    type: GrammarQuizType.fillBlank,
    prompt: isEnglish ? 'Complete the sentence.' : 'Boşluğu doldur.',
    sentence: sentence,
    options: options,
    answer: answer,
    explanation: explanation.trim().isEmpty
        ? (isEnglish
            ? 'The selected form fits the grammar pattern in the sentence.'
            : 'Seçilen form cümledeki grammar kalıbına uyar.')
        : explanation,
  );
}

List<String> _balancedFillBlankOptions(
  List<String> raw,
  String answer,
  String lessonKey,
  int index,
) {
  final cleanAnswer = _cleanQuizOptionText(answer);
  final seen = <String>{};
  final distractors = <String>[];

  void add(String value) {
    final clean = _cleanQuizOptionText(value);
    if (clean.isEmpty) return;
    if (_looksLikeSentenceAnswer(clean)) return;
    final key = _quizAnswerKey(clean);
    if (key.isEmpty || key == _quizAnswerKey(cleanAnswer)) return;
    if (seen.contains(key)) return;
    seen.add(key);
    distractors.add(clean);
  }

  for (final option in raw) {
    add(option);
  }

  var guard = 0;
  while (distractors.length < 3 && guard < 20) {
    add(_smallGrammarSlip(cleanAnswer, guard + index));
    guard++;
  }
  guard = 0;
  while (distractors.length < 3 && guard < 20) {
    add(_safeFallbackByIndex(cleanAnswer, guard + index));
    guard++;
  }
  guard = 0;
  while (distractors.length < 3 && guard < 8) {
    add('not ${guard == 0 ? cleanAnswer : '$cleanAnswer ${guard + 1}'}');
    guard++;
  }

  final slot = _stableAnswerSlot(lessonKey, index);
  final finalOptions = distractors.take(3).toList(growable: true);
  finalOptions.insert(slot, cleanAnswer);
  return finalOptions.take(4).toList(growable: false);
}

String _normalizeBlankMarker(String value) {
  return _repairMojibake(value)
      .replaceAll(RegExp(r'_{2,}'), '_____')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _extractBlankSentence(String prompt) {
  final clean = _normalizeBlankMarker(prompt);
  if (!clean.contains('_____')) return '';
  final marker = clean.indexOf('_____');
  final before = clean.lastIndexOf(RegExp(r'[:"]'), marker);
  final start = before < 0 ? 0 : before + 1;
  return clean.substring(start).replaceAll('"', '').trim();
}

String _bestClozeSource(GrammarQuizQuestion question, GrammarLesson lesson) {
  final candidates = [
    question.answer,
    question.sentence ?? '',
    lesson.right,
    lesson.modelAnswer,
    ...lesson.examples,
  ];
  for (final candidate in candidates) {
    final clean = _cleanOptionSentence(candidate);
    if (_isSentenceLike(clean) &&
        !_looksLikeMetaOption(clean) &&
        !_contextLooksTeacherish(clean)) {
      return clean;
    }
  }
  return lesson.right;
}

bool _looksLikeSentenceAnswer(String value) {
  final clean = value.trim();
  if (clean.split(RegExp(r'\s+')).length > 5) return true;
  return RegExp(r'[.?!]$').hasMatch(clean);
}

int _stableAnswerSlot(String lessonKey, int index) {
  final seed = lessonKey.codeUnits.fold<int>(0, (total, code) => total + code);
  const pattern = [1, 3, 0, 2, 2, 0, 3, 1];
  return pattern[(seed + index) % pattern.length];
}

String _cleanQuizOptionText(String value) {
  return _repairMojibake(value)
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('?.', '?')
      .replaceAll('..', '.')
      .trim();
}

String _quizAnswerKey(String value) {
  return _cleanQuizOptionText(value)
      .replaceAll(RegExp(r'[.?!]$'), '')
      .toLowerCase()
      .trim();
}

String _smallGrammarSlip(String value, int seed) {
  final clean = _cleanQuizOptionText(value);
  if (clean.isEmpty) return 'I am study every day.';

  final lower = clean.toLowerCase();
  final isToken =
      !clean.contains(' ') && RegExp(r"^[A-Za-z']+$").hasMatch(clean);
  if (isToken) {
    final token = lower;
    final candidates = <String>[];
    void add(String t) {
      final v = t.trim();
      if (v.isEmpty) return;
      if (v.toLowerCase() == token) return;
      if (!candidates.any((e) => e.toLowerCase() == v.toLowerCase())) {
        candidates.add(v);
      }
    }

    switch (token) {
      case 'am':
        add('is');
        add('are');
        add('be');
        break;
      case 'is':
        add('am');
        add('are');
        add('be');
        break;
      case 'are':
        add('am');
        add('is');
        add('be');
        break;
      case 'do':
        add('does');
        add('did');
        add('done');
        break;
      case 'does':
        add('do');
        add('did');
        add('done');
        break;
      case 'did':
        add('do');
        add('does');
        add('done');
        break;
      case 'have':
        add('has');
        add('had');
        add('having');
        break;
      case 'has':
        add('have');
        add('had');
        add('having');
        break;
      case 'had':
        add('have');
        add('has');
        add('having');
        break;
      case 'been':
        add('being');
        add('be');
        add('went');
        break;
      case 'will':
        add('would');
        add('can');
        add('going');
        break;
      case 'would':
        add('will');
        add('could');
        add('should');
        break;
      case 'should':
        add('must');
        add('would');
        add('could');
        break;
      case 'must':
        add('should');
        add('have to');
        add('might');
        break;
      case 'can':
        add('could');
        add('may');
        add('must');
        break;
      case 'may':
        add('might');
        add('can');
        add('must');
        break;
      case 'might':
        add('may');
        add('can');
        add('must');
        break;
      case 'to':
        add('for');
        add('in');
        add('at');
        break;
      case 'than':
        add('then');
        add('that');
        add('as');
        break;
      default:
        add('${clean}s');
        add('${clean}ed');
        add('${clean}ing');
        add(clean.replaceAll("'", ''));
        break;
    }

    if (candidates.isEmpty) return clean;
    return candidates[seed % candidates.length];
  }
  final questionMark = clean.endsWith('?');

  final candidates = <String>[];

  String finish(String text) {
    final trimmed = _cleanQuizOptionText(text);
    if (trimmed.isEmpty) return clean;
    if (questionMark) {
      return trimmed.endsWith('?') ? trimmed : '$trimmed?';
    }
    if (trimmed.endsWith('?')) return trimmed;
    return trimmed.endsWith('.') ? trimmed : '$trimmed.';
  }

  void add(String text) {
    final item = finish(text);
    if (item.toLowerCase() != clean.toLowerCase() &&
        !candidates.map((e) => e.toLowerCase()).contains(item.toLowerCase())) {
      candidates.add(item);
    }
  }

  if (lower.contains('does ') || lower.startsWith('does ')) {
    add(clean.replaceAll(RegExp(r'\bplay\b', caseSensitive: false), 'plays'));
    add(clean.replaceAll(RegExp(r'\blike\b', caseSensitive: false), 'likes'));
    add(clean.replaceAll(RegExp(r'\bwork\b', caseSensitive: false), 'works'));
    add(clean.replaceFirst(RegExp(r'\bDoes\b', caseSensitive: false), 'Do'));
  }

  if (lower.contains('do ')) {
    add(clean.replaceFirst(RegExp(r'\bDo\b', caseSensitive: false), 'Does'));
    add(clean.replaceAll(
        RegExp(r'\bstudy\b', caseSensitive: false), 'studies'));
    add(clean.replaceAll(
        RegExp(r'\bwatch\b', caseSensitive: false), 'watches'));
  }

  if (lower.contains('does not ') || lower.contains("doesn't ")) {
    add(clean.replaceAll(RegExp(r'\bwork\b', caseSensitive: false), 'works'));
    add(clean.replaceAll(RegExp(r'\blike\b', caseSensitive: false), 'likes'));
    add(clean.replaceFirst(RegExp(r'\bdoes\b', caseSensitive: false), 'do'));
  }

  if (lower.contains('do not ') || lower.contains("don't ")) {
    add(clean.replaceFirst(RegExp(r'\bdo\b', caseSensitive: false), 'does'));
    add(clean.replaceAll(
        RegExp(r'\bwatch\b', caseSensitive: false), 'watches'));
  }

  if (RegExp(r'\b(she|he|it)\b', caseSensitive: false).hasMatch(clean)) {
    add(clean.replaceAll(RegExp(r'\bworks\b', caseSensitive: false), 'work'));
    add(clean.replaceAll(RegExp(r'\blikes\b', caseSensitive: false), 'like'));
    add(clean.replaceAll(RegExp(r'\bplays\b', caseSensitive: false), 'play'));
    add(clean.replaceAll(
        RegExp(r'\bstudies\b', caseSensitive: false), 'study'));
    add(clean.replaceAll(
        RegExp(r'\bwatches\b', caseSensitive: false), 'watch'));
  }

  if (lower.contains('usually ') ||
      lower.contains('always ') ||
      lower.contains('often ') ||
      lower.contains('sometimes ')) {
    add(clean.replaceAll('usually drink', 'drink usually'));
    add(clean.replaceAll('always walks', 'walks always'));
    add(clean.replaceAll('often watch', 'watch often'));
    add(clean.replaceAll('sometimes study', 'study sometimes'));
    add(clean.replaceAll('usually wake', 'wake usually'));
  }

  if (lower.contains('every day')) {
    add(clean.replaceAll('every day', 'everydays'));
  }
  if (lower.contains('at school')) {
    add(clean.replaceAll('at school', 'in school'));
  }
  if (lower.contains('tea')) add(clean.replaceAll('drink tea', 'drinks tea'));

  add('She work every day.');
  add('She does works every day.');
  add('Does she works every day?');
  add('I drink usually tea in the morning.');
  add('They watches TV every night.');
  add('He do not work here.');

  return candidates[seed % candidates.length];
}

class _QuizResultCard extends StatelessWidget {
  final Color color;
  final int score;
  final int total;
  final bool isEnglish;
  final bool showContentSupport;
  final bool isA1A2;
  final bool rewardEarned;
  final VoidCallback onRetry;
  final VoidCallback onReviewWrong;

  const _QuizResultCard({
    required this.color,
    required this.score,
    required this.total,
    required this.isEnglish,
    this.showContentSupport = true,
    this.isA1A2 = false,
    this.rewardEarned = false,
    required this.onRetry,
    required this.onReviewWrong,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final percent = total == 0 ? 0 : ((score / total) * 100).round();
    final strong = percent >= 80;
    final mid = percent >= 60 && percent < 80;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? [
                  tokens.elevatedSurface,
                  Color.alphaBlend(color.withAlpha(14), tokens.elevatedSurface),
                  tokens.inputSurface,
                ]
              : [
                  color.withAlpha(34),
                  Colors.white.withAlpha(7),
                  const Color(0xFF050710).withAlpha(90)
                ],
        ),
        border: Border.all(
            color: tokens.isLight ? tokens.border : color.withAlpha(30)),
        boxShadow: [
          BoxShadow(
              color: tokens.isLight ? tokens.shadow : color.withAlpha(18),
              blurRadius: 26,
              offset: const Offset(0, 14))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: 0, end: total == 0 ? 0 : score / total),
                duration: const Duration(milliseconds: 760),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return SizedBox(
                    width: 112,
                    height: 112,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: tokens.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          strong ? const Color(0xFF22C55E) : color),
                    ),
                  );
                },
              ),
              Column(
                children: [
                  Text('$percent%',
                      style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.7)),
                  const SizedBox(height: 2),
                  Text('$score/$total',
                      style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            strong
                ? t('Great work', 'Harika iş')
                : mid
                    ? t('Almost there', 'Az kaldı')
                    : t('Review needed', 'Tekrar gerekli'),
            style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5),
          ),
          if (showContentSupport) ...[
            const SizedBox(height: 7),
            Text(
              strong
                  ? t('You are ready for the next topic.',
                      'Sonraki konuya hazırsın.')
                  : t('Review the form, then try the wrong answers again.',
                      'Yapıyı tekrar et, sonra yanlışları yeniden çöz.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12.6,
                  height: 1.35,
                  fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            key: const ValueKey<String>('grammar-lesson-complete'),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF22C55E).withAlpha(18),
              border: Border.all(color: const Color(0xFF22C55E).withAlpha(45)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF16A34A), size: 17),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    rewardEarned
                        ? t('Lesson complete · +$_grammarLessonRewardXP XP',
                            'Ders tamamlandı · +$_grammarLessonRewardXP XP')
                        : t('Lesson complete', 'Ders tamamlandı'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tokens.isLight
                          ? const Color(0xFF166534)
                          : const Color(0xFF86EFAC),
                      fontSize: 11.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              color: tokens.inputSurface,
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                _ResultMiniStat(
                    color: color,
                    icon: Icons.check_circle_rounded,
                    label: t('Correct', 'Doğru'),
                    value: '$score'),
                Container(width: 1, height: 34, color: tokens.border),
                _ResultMiniStat(
                    color: color,
                    icon: Icons.close_rounded,
                    label: t('Wrong', 'Yanlış'),
                    value: '${total - score}'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniActionButton(
                  label: t('Review wrong', 'Yanlışları gözden geçir'),
                  icon: Icons.manage_search_rounded,
                  color: color,
                  soft: true,
                  onTap: onReviewWrong,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _MiniActionButton(
                  label: t('Try again', 'Tekrar dene'),
                  icon: Icons.replay_rounded,
                  color: color,
                  soft: false,
                  onTap: onRetry,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultMiniStat extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;

  const _ResultMiniStat({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900)),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 10.8,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactQuizProgress extends StatelessWidget {
  final Color color;
  final int current;
  final int total;
  final int score;
  final bool isEnglish;

  const _CompactQuizProgress({
    required this.color,
    required this.current,
    required this.total,
    required this.score,
    required this.isEnglish,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final progress = total == 0 ? 0.0 : current / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: color.withAlpha(11),
        border: Border.all(color: color.withAlpha(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${t('Question', 'Soru')} $current/$total',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11.8,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${t('Score', 'Puan')}: $score',
                      maxLines: 1,
                      style: TextStyle(
                          color: color,
                          fontSize: 11.8,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: tokens.border,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _localizedQuizPrompt(String prompt, bool isEnglish) {
  final clean = prompt.trim();
  final lower = clean.toLowerCase();
  if (isEnglish) {
    if (lower.contains('bo_lu?u') ||
        lower.contains('boslugu') ||
        lower.contains('blank')) {
      return 'Fill in the blank.';
    }
    if (_looksTurkishOrBrokenQuizText(clean)) {
      return 'Choose the correct option.';
    }
    return clean;
  }

  if (lower.startsWith('complete:')) {
    final rest = clean.substring(clean.indexOf(':') + 1).trim();
    return rest.isEmpty ? 'Cümleyi tamamla.' : _repairMojibake(rest);
  }
  if (lower.contains('correct negative')) return 'Olumsuz cümleyi tamamla.';
  if (lower.contains('correct question')) return 'Soru cümlesini tamamla.';
  if (lower.contains('correct sentence')) return 'Cümleyi tamamla.';
  if (lower.contains('follows the rule')) return 'Kurala uygun seçeneği seç.';
  if (lower.contains('clean model')) return 'Model cümleyi tamamla.';
  if (lower.contains('correct form')) return 'Doğru formu seç.';
  if (lower.contains('choose the correct')) return 'Doğru seçeneği seç.';
  if (lower.contains('which sentence')) return 'Doğru cümleyi seç.';
  if (lower.contains('question')) return 'Soru cümlesini tamamla.';
  if (lower.contains('negative')) return 'Olumsuz cümleyi tamamla.';

  if (lower.startsWith('complete:')) {
    final rest = clean.substring(clean.indexOf(':') + 1).trim();
    return rest.isEmpty ? 'Cümleyi tamamla.' : _repairMojibake(rest);
  }
  if (lower.contains('correct negative')) return 'Olumsuz cümleyi tamamla.';
  if (lower.contains('correct question')) return 'Soru cümlesini tamamla.';
  if (lower.contains('correct sentence')) return 'Cümleyi tamamla.';
  if (lower.contains('follows the rule')) return 'Kurala uygun seçeneği seç.';
  if (lower.contains('clean model')) return 'Model cümleyi tamamla.';
  if (lower.contains('correct form')) return 'Doğru formu seç.';
  if (lower.contains('choose the correct')) return 'Doğru seçeneği seç.';
  if (lower.contains('which sentence')) return 'Doğru cümleyi seç.';
  if (lower.contains('question')) return 'Soru cümlesini tamamla.';
  if (lower.contains('negative')) return 'Olumsuz cümleyi tamamla.';

  return _repairMojibake(clean);
}

String _localizedQuizExplanation(String explanation, bool isEnglish) {
  final clean = explanation.trim();
  if (isEnglish) {
    if (clean.isEmpty || _looksTurkishOrBrokenQuizText(clean)) {
      return 'The correct answer matches the grammar pattern in this lesson.';
    }
    return clean;
  }
  final lower = clean.toLowerCase();

  if (clean.isEmpty || _looksBrokenTurkishVisible(_repairMojibake(clean))) {
    return _turkishQuizDefaultExplanation(GrammarQuizType.multipleChoice);
  }
  if (lower.contains('correct option follows') ||
      lower.contains('lesson pattern')) {
    return 'Doğru seçenek dersin hedef yapısına uyuyor.';
  }
  if (lower.contains('target grammar') || lower.contains('grammar form')) {
    return 'Doğru seçenek hedef yapının formunu koruyor.';
  }
  if (lower.contains('correct')) {
    return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
  }

  return _repairMojibake(clean);
}

bool _looksTurkishText(String value) {
  final v = value.trim();
  if (v.isEmpty) return false;
  final lower = v.toLowerCase();
  return RegExp(r'[�?1�_��?0�^�]').hasMatch(v) ||
      lower.contains('c�mle') ||
      lower.contains('kural') ||
      lower.contains('do?ru') ||
      lower.contains('yanl?') ||
      lower.contains('kelime');
}

bool _looksTurkishOrBrokenQuizText(String value) {
  final v = value.trim();
  if (v.isEmpty) return false;
  final lower = v.toLowerCase();
  if (_looksTurkishText(v)) return true;
  if (RegExp(
          r'[\u00c7\u00e7\u011e\u011f\u0130\u0131\u00d6\u00f6\u015e\u015f\u00dc\u00fc]')
      .hasMatch(v)) {
    return true;
  }
  if (RegExp(r'[\u00c3\u00c4\u00c5\u00ef\u00bf\u00bd\uFFFD]').hasMatch(v)) {
    return true;
  }

  const turkishFragments = <String>[
    'c?mle',
    'cumle',
    'kural',
    'do?ru',
    'dogru',
    'yanl',
    'se?enek',
    'secenek',
    'özne',
    'ozne',
    'fiil',
    'yap?',
    'yapi',
    'kal?p',
    'kalip',
    'kullan',
    'olumsuz',
    'soru',
    'yard?mc',
    'yardimci',
    'hedef',
    'dersin',
    'model c',
  ];
  return turkishFragments.any(lower.contains);
}

String _quizPromptDisplay(GrammarQuizQuestion question, bool isEnglish) {
  if (question.type == GrammarQuizType.fillBlank) {
    final sentence = (question.sentence ?? '').trim();
    if (sentence.contains('____')) return _normalizeBlankMarker(sentence);

    final prompt = question.prompt.trim();
    if (prompt.contains('____')) return _normalizeBlankMarker(prompt);

    if (!isEnglish) return _turkishQuizPromptFallback(question.type);
    return isEnglish ? 'Fill in the blank.' : 'Boşluğu doldur.';
  }
  if (isEnglish) return _localizedQuizPrompt(question.prompt, true);
  final prompt = question.prompt.trim();
  if (_looksTurkishText(prompt) && !_looksBrokenTurkishVisible(prompt)) {
    return prompt;
  }
  if (_looksBrokenTurkishVisible(_repairMojibake(prompt))) {
    return _turkishQuizPromptFallback(question.type);
  }
  if (!_looksTurkishText(prompt)) {
    return _turkishQuizPromptFallback(question.type);
  }
  if (_looksTurkishText(prompt)) return prompt;

  switch (question.type) {
    case GrammarQuizType.fillBlank:
      return 'Boşluğu doldur.';
    case GrammarQuizType.errorCorrection:
      return 'Cümleyi düzelt.';
    case GrammarQuizType.transformation:
      return 'Cümleyi düzenle.';
    case GrammarQuizType.sentenceOrder:
      return 'Kelimeleri sıraya koy.';
    case GrammarQuizType.matching:
      return 'Eşleştir.';
    case GrammarQuizType.multipleChoice:
      return 'Doğru seçeneği seç.';
  }
}

String _quizExplanationDisplay(GrammarQuizQuestion question, bool isEnglish) {
  if (isEnglish) return _localizedQuizExplanation(question.explanation, true);
  final explanation = question.explanation.trim();
  final repaired = _repairMojibake(explanation);
  if (explanation.isEmpty || _looksBrokenTurkishVisible(repaired)) {
    return _turkishQuizDefaultExplanation(question.type);
  }
  if (_looksTurkishText(repaired)) return repaired;
  if (explanation.isEmpty) return '';
  if (_looksTurkishText(explanation)) return explanation;
  if (!_looksTurkishText(repaired)) {
    return _turkishQuizDefaultExplanation(question.type);
  }

  final lower = explanation.toLowerCase();
  if (lower.contains('word order')) {
    return 'Kelime sırası doğru olmalı. Yardımcı fiil, özne ve ana fiil yerlerini kontrol et.';
  }
  if (lower.contains('pattern') || lower.contains('form')) {
    return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
  }
  if (lower.contains('meaning')) {
    return 'Anlam aynı kalırken form düzeltilmeli. Yardımcı fiil ve fiil formuna dikkat et.';
  }
  if (lower.contains('correct') || lower.contains('right')) {
    return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
  }

  return 'Model cümleye bak: doğru cevap hedef yapıyı bozmadan anlamı verir.';
}

String _turkishQuizDefaultExplanation(GrammarQuizType type) {
  final useCleanFallback = type.index >= 0;
  if (useCleanFallback) {
    switch (type) {
      case GrammarQuizType.fillBlank:
        return 'Do\u011fru cevap. Bu bo\u015flukta hedef yap\u0131ya uygun form kullan\u0131lmal\u0131.';
      case GrammarQuizType.sentenceOrder:
        return 'Kelime s\u0131ras\u0131 hedef yap\u0131ya uygun olmal\u0131. \u00d6zne, yard\u0131mc\u0131 fiil ve ana fiilin yerini kontrol et.';
      case GrammarQuizType.errorCorrection:
        return 'Bu se\u00e7enek hedef yap\u0131ya uymuyor. \u00d6zne, zaman ve fiil formunu tekrar kontrol et.';
      case GrammarQuizType.transformation:
        return 'Anlam korunmal\u0131, ama c\u00fcmle hedef yap\u0131n\u0131n do\u011fru formuyla yeniden kurulmal\u0131.';
      case GrammarQuizType.matching:
        return 'E\u015fle\u015fme hedef yap\u0131n\u0131n anlam\u0131 ve formuyla uyumlu olmal\u0131.';
      case GrammarQuizType.multipleChoice:
        return 'Do\u011fru cevap. Bu bo\u015flukta hedef yap\u0131ya uygun form kullan\u0131lmal\u0131.';
    }
  }
  switch (type) {
    case GrammarQuizType.fillBlank:
      return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
    case GrammarQuizType.sentenceOrder:
      return 'Kelime sırası hedef yapıya uygun olmalı. Özne, yardımcı fiil ve ana fiilin yerini kontrol et.';
    case GrammarQuizType.errorCorrection:
      return 'Bu seçenek hedef yapıya uymuyor. Özneye ve fiil formuna tekrar bak.';
    case GrammarQuizType.transformation:
      return 'Anlam korunmalı, ama cümle hedef yapının doğru formuyla yeniden kurulmalı.';
    case GrammarQuizType.matching:
      return 'Eşleşme hedef yapının anlamı ve formuyla uyumlu olmalı.';
    case GrammarQuizType.multipleChoice:
      return 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.';
  }
}

String _turkishQuizPromptFallback(GrammarQuizType type) {
  final useCleanFallback = type.index >= 0;
  if (useCleanFallback) {
    switch (type) {
      case GrammarQuizType.fillBlank:
        return 'Bo\u015flu\u011fu doldur.';
      case GrammarQuizType.errorCorrection:
        return 'C\u00fcmleyi d\u00fczelt.';
      case GrammarQuizType.transformation:
        return 'C\u00fcmleyi d\u00fczenle.';
      case GrammarQuizType.sentenceOrder:
        return 'Kelimeleri s\u0131raya koy.';
      case GrammarQuizType.matching:
        return 'E\u015fle\u015ftir.';
      case GrammarQuizType.multipleChoice:
        return 'Do\u011fru se\u00e7ene\u011fi se\u00e7.';
    }
  }
  switch (type) {
    case GrammarQuizType.fillBlank:
      return 'Boşluğu doldur.';
    case GrammarQuizType.errorCorrection:
      return 'Cümleyi düzelt.';
    case GrammarQuizType.transformation:
      return 'Cümleyi düzenle.';
    case GrammarQuizType.sentenceOrder:
      return 'Kelimeleri sıraya koy.';
    case GrammarQuizType.matching:
      return 'Eşleştir.';
    case GrammarQuizType.multipleChoice:
      return 'Doğru seçeneği seç.';
  }
}

class _InlineMcqCard extends StatelessWidget {
  final GrammarQuizQuestion question;
  final String? selected;
  final bool checked;
  final bool isCorrect;
  final Color color;
  final int index;
  final int total;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool isEnglish;
  final bool showContentSupport;

  const _InlineMcqCard({
    required this.question,
    required this.selected,
    required this.checked,
    required this.isCorrect,
    required this.color,
    required this.index,
    required this.total,
    required this.onSelect,
    required this.onCheck,
    required this.onNext,
    required this.isEnglish,
    this.showContentSupport = true,
  });

  String t(String en, String tr) => isEnglish ? en : _repairMojibake(tr);

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final answerText = checked
        ? _quizAnswerFeedbackText(question, isCorrect, isEnglish)
        : showContentSupport
            ? t('Choose the best answer, then check.',
                'En uygun cevabı seç, sonra kontrol et.')
            : '';
    final explanationText = _quizExplanationDisplay(question, isEnglish);
    final feedbackText =
        _combineQuizFeedback(answerText, explanationText, isEnglish);
    final showFeedback = feedbackText.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? [
                  tokens.elevatedSurface,
                  Color.alphaBlend(color.withAlpha(10), tokens.elevatedSurface),
                  tokens.inputSurface,
                ]
              : [
                  color.withAlpha(12),
                  Colors.white.withAlpha(6),
                  Colors.black.withAlpha(18)
                ],
        ),
        border: Border.all(
            color: tokens.isLight ? tokens.border : color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LessonBadge(label: '${index + 1}', color: color),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _quizTypeLabel(question.type, isEnglish),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: tokens.inputSurface,
                  border: Border.all(color: tokens.border),
                ),
                child: Text(
                  '${index + 1}/$total',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 10.7,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: tokens.inputSurface,
              border: Border.all(color: tokens.border),
            ),
            child: Text(
              _quizPromptDisplay(question, isEnglish),
              style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 15.0,
                  height: 1.33,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(question.options.length, (optionIndex) {
            final option = question.options[optionIndex];
            final isSelected = selected == option;
            final isAnswer = option.trim().toLowerCase() ==
                question.answer.trim().toLowerCase();
            final optionLetter = String.fromCharCode(65 + optionIndex);
            final statusColor = checked && isAnswer
                ? const Color(0xFF22C55E)
                : checked && isSelected
                    ? const Color(0xFFFF6B6B)
                    : isSelected
                        ? color
                        : tokens.border;
            final fillColor = checked && isAnswer
                ? const Color(0xFF22C55E).withAlpha(16)
                : checked && isSelected
                    ? const Color(0xFFFF6B6B).withAlpha(13)
                    : isSelected
                        ? color.withAlpha(20)
                        : tokens.inputSurface;

            return Padding(
              key: ValueKey<String>('grammar-quiz-option-$optionIndex'),
              padding: EdgeInsets.only(
                  bottom: optionIndex == question.options.length - 1 ? 0 : 8),
              child: _TapScale(
                onTap: () => onSelect(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 10, 11, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    color: fillColor,
                    border: Border.all(color: statusColor),
                    boxShadow: isSelected || (checked && isAnswer)
                        ? [
                            BoxShadow(
                                color: statusColor.withAlpha(16),
                                blurRadius: 15,
                                offset: const Offset(0, 7))
                          ]
                        : const [],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _QuizOptionLetterBadge(
                        letter: optionLetter,
                        color: statusColor,
                        active: isSelected || (checked && isAnswer),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 12.8,
                              height: 1.30,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 160),
                        child: Icon(
                          checked && isAnswer
                              ? Icons.check_circle_rounded
                              : checked && isSelected
                                  ? Icons.cancel_rounded
                                  : isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_unchecked_rounded,
                          key: ValueKey<String>(
                              '$checked-$isSelected-$isAnswer'),
                          color: statusColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (showFeedback) ...[
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: checked
                    ? (isCorrect
                        ? const Color(0xFF22C55E).withAlpha(12)
                        : const Color(0xFFFFB020).withAlpha(12))
                    : tokens.inputSurface,
                border: Border.all(
                  color: checked
                      ? (isCorrect
                          ? const Color(0xFF22C55E).withAlpha(40)
                          : const Color(0xFFFFB020).withAlpha(45))
                      : tokens.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    checked
                        ? (isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.info_rounded)
                        : Icons.touch_app_rounded,
                    color: checked
                        ? (isCorrect
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFFFB020))
                        : color,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feedbackText,
                      style: TextStyle(
                          color: tokens.textSecondary,
                          fontSize: 11.9,
                          height: 1.35,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  key: const ValueKey<String>('grammar-quiz-check'),
                  opacity: checked ? 0.62 : 1,
                  child: _MiniActionButton(
                    label: checked
                        ? t('Completed', 'Tamamlandı')
                        : t('Check answer', 'Cevabı kontrol et'),
                    icon: checked ? Icons.done_rounded : Icons.check_rounded,
                    color: color,
                    soft: checked,
                    onTap: checked ? () {} : onCheck,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Opacity(
                  key: ValueKey<String>(index == total - 1
                      ? 'grammar-quiz-results'
                      : 'grammar-quiz-next'),
                  opacity: checked ? 1 : 0.72,
                  child: _MiniActionButton(
                    label: index == total - 1
                        ? t('Results', 'Tamamlandı')
                        : t('Next question', 'Sonraki soru'),
                    icon: Icons.arrow_forward_rounded,
                    color: color,
                    soft: !checked,
                    onTap: checked ? onNext : onCheck,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _quizAnswerFeedbackText(
  GrammarQuizQuestion question,
  bool isCorrect,
  bool isEnglish,
) {
  if (isEnglish) {
    return isCorrect ? 'Correct. Nice.' : 'Answer: ${question.answer}';
  }
  final topicFeedback = _a1TurkishQuizFeedbackText(question, isCorrect);
  if (topicFeedback != null) return topicFeedback;

  final explanation = _quizExplanationDisplay(question, false).trim();
  if (explanation.isNotEmpty &&
      !_isGenericTurkishQuizExplanation(explanation)) {
    return isCorrect
        ? explanation
        : 'Do\u011fru cevap: ${question.answer}\n$explanation';
  }

  return isCorrect
      ? 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.'
      : 'Bu seçenek uygun değil. Özneye ve fiil formuna tekrar bak.';
}

String? _a1TurkishQuizFeedbackText(
  GrammarQuizQuestion question,
  bool isCorrect,
) {
  final clue =
      '${question.id} ${question.prompt} ${question.sentence ?? ''} ${question.answer} ${question.explanation}'
          .toLowerCase();

  if (clue.contains('a1_dem') ||
      clue.contains('demonstrative') ||
      clue.contains('this / that / these / those')) {
    if (isCorrect) {
      if (clue.contains('phone') && clue.contains('this')) {
        return "Doğru cevap. 'Phone' tekil ve yakında olduğu için this kullanılır.";
      }
      return 'Doğru cevap. Tekil/çoğul ve yakın/uzak durumuna uygun gösterme sözcüğü seçilmeli.';
    }
    return 'Bu seçenek uygun değil. Tekil/çoğul ve yakın/uzak ayrımını tekrar kontrol et.';
  }

  if (clue.contains('a1_ps') ||
      clue.contains('present simple') ||
      clue.contains("doesn't") ||
      clue.contains('does ') ||
      clue.contains(' do ')) {
    return isCorrect
        ? 'Doğru cevap. Bu cümlede özneye uygun fiil formu kullanılmalı.'
        : 'Bu seçenek uygun değil. Özneye ve fiil formuna tekrar bak.';
  }

  if (clue.contains('a1_be') ||
      clue.contains('be verb') ||
      clue.contains(' am ') ||
      clue.contains(' is ') ||
      clue.contains(' are ')) {
    return isCorrect
        ? 'Doğru cevap. Özneye uygun be verb formu kullanılmalı.'
        : 'Bu seçenek uygun değil. I için am, he/she/it için is, you/we/they için are kullanılır.';
  }

  return null;
}

String _combineQuizFeedback(
  String answerText,
  String explanationText,
  bool isEnglish,
) {
  final answer = answerText.trim();
  final explanation = explanationText.trim();
  if (answer.isEmpty) return explanation;
  if (explanation.isEmpty) return answer;

  String normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'cevap:\s*.+$', multiLine: true), '')
      .replaceAll(RegExp(r'answer:\s*.+$', multiLine: true), '')
      .replaceAll(RegExp(r'[^\wçğıöşü]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final normalizedAnswer = normalize(answer);
  final normalizedExplanation = normalize(explanation);
  if (normalizedAnswer == normalizedExplanation) return answer;
  if (normalizedAnswer.contains(normalizedExplanation)) return answer;
  if (normalizedExplanation.contains(normalizedAnswer)) return answer;

  if (!isEnglish) {
    if (_isFinalTurkishQuizFeedback(answer)) return answer;
    if (_isFinalA1TurkishQuizFeedback(answer)) return answer;
    if (_isGenericTurkishQuizExplanation(explanation)) return answer;

    final answerStartsCorrect = answer.startsWith('Doğru cevap.');
    final explanationStartsCorrect = explanation.startsWith('Doğru cevap.');
    if (answerStartsCorrect && explanationStartsCorrect) return answer;

    final answerStartsWrong =
        answer.startsWith('Bu seçenek hedef yapıya uymuyor.');
    final explanationStartsWrong =
        explanation.startsWith('Bu seçenek hedef yapıya uymuyor.');
    if (answerStartsWrong && explanationStartsWrong) return answer;
  }

  return '$answer\n$explanation';
}

bool _isFinalTurkishQuizFeedback(String value) {
  final clean = _repairVisibleGrammarText(value).trim();
  return clean.startsWith('Doğru cevap.') ||
      clean.startsWith('Bu seçenek uygun değil.') ||
      clean.startsWith('Bu seçenek hedef yapıya uymuyor.');
}

bool _isFinalA1TurkishQuizFeedback(String value) {
  final clean = value.trim();
  return clean.contains('Phone tekil ve yakında') ||
      clean.contains('Tekil/çoğul ve yakın/uzak') ||
      clean.contains('özneye uygun fiil formu') ||
      clean.contains('Özneye ve fiil formuna tekrar bak') ||
      clean.contains('Özneye uygun be verb formu') ||
      clean.contains('I için am, he/she/it için is');
}

bool _isGenericTurkishQuizExplanation(String value) {
  final clean = value.trim();
  return clean == 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.' ||
      clean ==
          'Bu seçenek hedef yapıya uymuyor. Özneye ve fiil formuna tekrar bak.' ||
      clean.startsWith('Kelime sırası hedef yapıya uygun olmalı.') ||
      clean.startsWith(
          'Anlam korunmalı, ama cümle hedef yapının doğru formuyla') ||
      clean.startsWith('Eşleşme hedef yapının anlamı ve formuyla');
}

String _sentenceOrderFeedbackText(
  GrammarQuizQuestion question,
  bool checked,
  bool isCorrect,
  bool isEnglish,
) {
  if (!checked) {
    return isEnglish ? 'Build, then check.' : 'Kur, sonra kontrol et.';
  }
  final base = isCorrect
      ? (isEnglish
          ? 'Correct.'
          : 'Doğru cevap. Bu boşlukta hedef yapıya uygun form kullanılmalı.')
      : (isEnglish
          ? 'Answer: ${question.answer}'
          : 'Bu seçenek uygun değil. Özneye ve fiil formuna tekrar bak.');
  final explanation = _quizExplanationDisplay(question, isEnglish);
  return _combineQuizFeedback(base, explanation, isEnglish);
}

class _QuizQuestionCard extends StatelessWidget {
  final GrammarQuizQuestion question;
  final String? selected;
  final bool checked;
  final bool isCorrect;
  final Color color;
  final int index;
  final int total;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool isEnglish;
  final bool showContentSupport;

  const _QuizQuestionCard({
    required this.question,
    required this.selected,
    required this.checked,
    required this.isCorrect,
    required this.color,
    required this.index,
    required this.total,
    required this.onSelect,
    required this.onCheck,
    required this.onNext,
    required this.isEnglish,
    this.showContentSupport = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case GrammarQuizType.fillBlank:
        return _InlineFillBlankCard(
          question: question,
          selected: selected,
          checked: checked,
          isCorrect: isCorrect,
          color: color,
          index: index,
          total: total,
          onSelect: onSelect,
          onCheck: onCheck,
          onNext: onNext,
          isEnglish: isEnglish,
          showContentSupport: showContentSupport,
        );
      case GrammarQuizType.errorCorrection:
      case GrammarQuizType.transformation:
        return _InlinePromptWithSentenceCard(
          question: question,
          selected: selected,
          checked: checked,
          isCorrect: isCorrect,
          color: color,
          index: index,
          total: total,
          onSelect: onSelect,
          onCheck: onCheck,
          onNext: onNext,
          isEnglish: isEnglish,
        );
      case GrammarQuizType.sentenceOrder:
        return _InlineSentenceOrderCard(
          question: question,
          selected: selected,
          checked: checked,
          isCorrect: isCorrect,
          color: color,
          index: index,
          total: total,
          onSelect: onSelect,
          onCheck: onCheck,
          onNext: onNext,
          isEnglish: isEnglish,
        );
      case GrammarQuizType.matching:
        // Not supported yet; fall back to MCQ rendering if options exist.
        return _InlineMcqCard(
          question: question,
          selected: selected,
          checked: checked,
          isCorrect: isCorrect,
          color: color,
          index: index,
          total: total,
          onSelect: onSelect,
          onCheck: onCheck,
          onNext: onNext,
          isEnglish: isEnglish,
        );
      case GrammarQuizType.multipleChoice:
        return _InlineMcqCard(
          question: question,
          selected: selected,
          checked: checked,
          isCorrect: isCorrect,
          color: color,
          index: index,
          total: total,
          onSelect: onSelect,
          onCheck: onCheck,
          onNext: onNext,
          isEnglish: isEnglish,
        );
    }
  }
}

class _InlinePromptWithSentenceCard extends StatelessWidget {
  final GrammarQuizQuestion question;
  final String? selected;
  final bool checked;
  final bool isCorrect;
  final Color color;
  final int index;
  final int total;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool isEnglish;

  const _InlinePromptWithSentenceCard({
    required this.question,
    required this.selected,
    required this.checked,
    required this.isCorrect,
    required this.color,
    required this.index,
    required this.total,
    required this.onSelect,
    required this.onCheck,
    required this.onNext,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final sentence = (question.sentence ?? '').trim();
    final cleanSentence = sentence.isEmpty ? '' : sentence;
    final prompt = _quizPromptDisplay(question, isEnglish);

    return _InlineMcqCard(
      question: GrammarQuizQuestion(
        id: question.id,
        type: GrammarQuizType.multipleChoice,
        prompt: cleanSentence.isEmpty ? prompt : '$prompt\n\n"$cleanSentence"',
        options: question.options,
        answer: question.answer,
        explanation: _quizExplanationDisplay(question, isEnglish),
      ),
      selected: selected,
      checked: checked,
      isCorrect: isCorrect,
      color: color,
      index: index,
      total: total,
      onSelect: onSelect,
      onCheck: onCheck,
      onNext: onNext,
      isEnglish: isEnglish,
    );
  }
}

class _InlineFillBlankCard extends StatelessWidget {
  final GrammarQuizQuestion question;
  final String? selected;
  final bool checked;
  final bool isCorrect;
  final Color color;
  final int index;
  final int total;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool isEnglish;
  final bool showContentSupport;

  const _InlineFillBlankCard({
    required this.question,
    required this.selected,
    required this.checked,
    required this.isCorrect,
    required this.color,
    required this.index,
    required this.total,
    required this.onSelect,
    required this.onCheck,
    required this.onNext,
    required this.isEnglish,
    this.showContentSupport = true,
  });

  @override
  Widget build(BuildContext context) {
    final sentence = (question.sentence ?? '').trim();

    return _InlineMcqCard(
      question: GrammarQuizQuestion(
        id: question.id,
        type: GrammarQuizType.fillBlank,
        prompt: question.prompt,
        sentence: sentence.isEmpty ? null : sentence,
        options: question.options,
        answer: question.answer,
        explanation: _quizExplanationDisplay(question, isEnglish),
      ),
      selected: selected,
      checked: checked,
      isCorrect: isCorrect,
      color: color,
      index: index,
      total: total,
      onSelect: onSelect,
      onCheck: onCheck,
      onNext: onNext,
      isEnglish: isEnglish,
      showContentSupport: showContentSupport,
    );
  }
}

class _InlineSentenceOrderCard extends StatefulWidget {
  final GrammarQuizQuestion question;
  final String? selected;
  final bool checked;
  final bool isCorrect;
  final Color color;
  final int index;
  final int total;
  final ValueChanged<String> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool isEnglish;

  const _InlineSentenceOrderCard({
    required this.question,
    required this.selected,
    required this.checked,
    required this.isCorrect,
    required this.color,
    required this.index,
    required this.total,
    required this.onSelect,
    required this.onCheck,
    required this.onNext,
    required this.isEnglish,
  });

  @override
  State<_InlineSentenceOrderCard> createState() =>
      _InlineSentenceOrderCardState();
}

class _InlineSentenceOrderCardState extends State<_InlineSentenceOrderCard> {
  late final List<String> pool =
      widget.question.items.where((e) => e.trim().isNotEmpty).toList();
  final List<String> built = <String>[];

  void addWord(String w) {
    if (widget.checked) return;
    if (!pool.contains(w)) return;
    setState(() {
      built.add(w);
      pool.remove(w);
    });
    widget.onSelect(built.join(' '));
  }

  void removeAt(int index) {
    if (widget.checked) return;
    if (index < 0 || index >= built.length) return;
    setState(() {
      final w = built.removeAt(index);
      pool.add(w);
    });
    widget.onSelect(built.join(' '));
  }

  void reset() {
    if (widget.checked) return;
    setState(() {
      pool.addAll(built);
      built.clear();
    });
    widget.onSelect('');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final prompt = _quizPromptDisplay(widget.question, widget.isEnglish);
    final header =
        '$prompt\n\n${widget.isEnglish ? 'Tap words to build the sentence.' : 'Kelimelere dokunarak cümleyi kur.'}';
    final current = built.join(' ').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tokens.isLight
              ? [
                  tokens.elevatedSurface,
                  Color.alphaBlend(
                      widget.color.withAlpha(10), tokens.elevatedSurface),
                  tokens.inputSurface,
                ]
              : [
                  widget.color.withAlpha(12),
                  Colors.white.withAlpha(6),
                  Colors.black.withAlpha(18)
                ],
        ),
        border: Border.all(
            color: tokens.isLight ? tokens.border : widget.color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LessonBadge(label: '${widget.index + 1}', color: widget.color),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _quizTypeLabel(widget.question.type, widget.isEnglish),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: tokens.inputSurface,
                  border: Border.all(color: tokens.border),
                ),
                child: Text(
                  '${widget.index + 1}/${widget.total}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 10.7,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21),
              color: tokens.inputSurface,
              border: Border.all(color: tokens.border),
            ),
            child: Text(
              header,
              style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 14.6,
                  height: 1.35,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: widget.checked
                  ? (widget.isCorrect
                      ? const Color(0xFF22C55E).withAlpha(10)
                      : widget.color.withAlpha(12))
                  : tokens.inputSurface,
              border: Border.all(
                  color: widget.checked
                      ? (widget.isCorrect
                          ? const Color(0xFF22C55E).withAlpha(45)
                          : widget.color.withAlpha(35))
                      : tokens.border),
            ),
            child: current.isEmpty
                ? Text(
                    widget.isEnglish
                        ? 'Build the sentence here.'
                        : 'Cümleyi burada kur.',
                    style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 12.4,
                        height: 1.3,
                        fontWeight: FontWeight.w700),
                  )
                : Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: List.generate(built.length, (i) {
                      final w = built[i];
                      return _TapScale(
                        onTap: () => removeAt(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: widget.color.withAlpha(18),
                            border:
                                Border.all(color: widget.color.withAlpha(40)),
                          ),
                          child: Text(w,
                              style: TextStyle(
                                  color: tokens.textPrimary,
                                  fontSize: 12.3,
                                  fontWeight: FontWeight.w900)),
                        ),
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: pool.map((w) {
              return _TapScale(
                onTap: () => addWord(w),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: tokens.inputSurface,
                    border: Border.all(color: tokens.border),
                  ),
                  child: Text(w,
                      style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 12.1,
                          fontWeight: FontWeight.w800)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: widget.checked
                  ? (widget.isCorrect
                      ? const Color(0xFF22C55E).withAlpha(12)
                      : const Color(0xFFFFB020).withAlpha(12))
                  : tokens.inputSurface,
              border: Border.all(
                color: widget.checked
                    ? (widget.isCorrect
                        ? const Color(0xFF22C55E).withAlpha(40)
                        : const Color(0xFFFFB020).withAlpha(45))
                    : tokens.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.checked
                      ? (widget.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded)
                      : Icons.touch_app_rounded,
                  color: widget.checked
                      ? (widget.isCorrect
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFFFB020))
                      : widget.color,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _sentenceOrderFeedbackText(
                      widget.question,
                      widget.checked,
                      widget.isCorrect,
                      widget.isEnglish,
                    ),
                    style: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 11.9,
                        height: 1.35,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: widget.checked ? 0.62 : 1,
                  child: _MiniActionButton(
                    label: widget.checked
                        ? (widget.isEnglish ? 'Completed' : 'Tamamlandı')
                        : (widget.isEnglish
                            ? 'Check answer'
                            : 'Cevabı kontrol et'),
                    icon: widget.checked
                        ? Icons.done_rounded
                        : Icons.check_rounded,
                    color: widget.color,
                    soft: widget.checked,
                    onTap: widget.checked ? () {} : widget.onCheck,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Opacity(
                  opacity: widget.checked ? 1 : 0.72,
                  child: _MiniActionButton(
                    label: widget.index == widget.total - 1
                        ? (widget.isEnglish ? 'Results' : 'Tamamlandı')
                        : (widget.isEnglish ? 'Next question' : 'Sonraki soru'),
                    icon: Icons.arrow_forward_rounded,
                    color: widget.color,
                    soft: !widget.checked,
                    onTap: widget.checked ? widget.onNext : widget.onCheck,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              _TapScale(
                onTap: reset,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: tokens.inputSurface,
                    border: Border.all(color: tokens.border),
                  ),
                  child: Icon(Icons.refresh_rounded,
                      color: tokens.iconSecondary, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizOptionLetterBadge extends StatelessWidget {
  final String letter;
  final Color color;
  final bool active;

  const _QuizOptionLetterBadge({
    required this.letter,
    required this.color,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color.withAlpha(30) : tokens.chipSurface,
        border: Border.all(color: active ? color.withAlpha(75) : tokens.border),
      ),
      child: Text(
        letter,
        style: TextStyle(
            color: active ? color : tokens.textSecondary,
            fontSize: 11.2,
            fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _CleanSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _CleanSectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 14.2,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2),
          ),
        ),
      ],
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool soft;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.soft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: soft
              ? LinearGradient(colors: [
                  tokens.chipSurface,
                  tokens.glassSurface,
                ])
              : LinearGradient(
                  colors: [color.withAlpha(155), color.withAlpha(82)]),
          border: Border.all(color: soft ? tokens.border : color.withAlpha(45)),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: soft ? tokens.textSecondary : Colors.white,
                    size: 16),
                const SizedBox(width: 6),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: soft ? tokens.textPrimary : Colors.white,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonBottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool soft;
  final VoidCallback onTap;
  const _LessonBottomButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.soft,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: soft
              ? LinearGradient(colors: [
                  tokens.chipSurface,
                  tokens.glassSurface,
                ])
              : LinearGradient(
                  colors: [color.withAlpha(180), color.withAlpha(90)]),
          border: Border.all(color: soft ? tokens.border : color.withAlpha(55)),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(soft ? 8 : 20),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: soft ? tokens.textSecondary : Colors.white,
                    size: 17),
                const SizedBox(width: 7),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: soft ? tokens.textPrimary : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  final Color color;
  final bool small;
  const _CircleBackButton({required this.color, this.small = false});
  @override
  Widget build(BuildContext context) {
    final size = small ? 38.0 : 48.0;
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(small ? 999 : 18),
            color: tokens.chipSurface,
            border: Border.all(color: tokens.border)),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: tokens.textPrimary, size: small ? 14 : 15));
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SoftIcon({required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withAlpha(42),
            border: Border.all(color: color.withAlpha(56))),
        child: Icon(icon,
            color: tokens.isLight ? accent : Colors.white, size: 20));
  }
}

class _TinyTag extends StatelessWidget {
  final String label;
  final Color color;
  const _TinyTag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 86),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: color.withAlpha(14),
            border: Border.all(color: color.withAlpha(38))),
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: tokens.isLight ? accent : Colors.white,
                fontSize: 9.8,
                fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _LessonBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _LessonBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final accent = _grammarAccentText(tokens, color);
    return Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: tokens.isLight
                  ? [
                      Color.alphaBlend(
                        color.withAlpha(28),
                        Colors.white.withAlpha(232),
                      ),
                      const Color(0xFFEAF0FB).withAlpha(205),
                    ]
                  : [
                      color.withAlpha(48),
                      Colors.white.withAlpha(8),
                    ],
            ),
            border: Border.all(
                color: tokens.isLight
                    ? _grammarGlassBorder(
                        tokens,
                        accent: color,
                        strong: true,
                      )
                    : color.withAlpha(72)),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(tokens.isLight ? 18 : 34),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ]),
        child: Text(label,
            style: TextStyle(
                color: tokens.isLight ? accent : Colors.white,
                fontSize: 11.2,
                fontWeight: FontWeight.w900)));
  }
}

class _Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final Color? borderColor;
  const _Glass(
      {required this.child,
      this.padding = const EdgeInsets.all(14),
      this.radius = 24,
      this.gradient,
      this.borderColor});
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return IosLiquidGlassSurface(
      radius: radius,
      padding: padding,
      gradient: gradient ??
          (tokens.isLight
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _grammarLightGlass(tokens.primaryAccent),
                )
              : null),
      borderColor: borderColor ?? _grammarGlassBorder(tokens),
      child: child,
    );
  }
}

class _GradientPage extends StatelessWidget {
  final Widget child;
  const _GradientPage({required this.child});
  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return IosDynamicGlassBackdrop(
      primary: tokens.secondaryAccent,
      secondary: tokens.primaryAccent,
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
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => pressed = true),
        onTapCancel: () => setState(() => pressed = false),
        onTapUp: (_) => setState(() => pressed = false),
        child: AnimatedScale(
            scale: pressed ? 0.985 : 1.0,
            duration: const Duration(milliseconds: 210),
            curve: pressed ? Curves.easeOutCubic : Curves.easeOutBack,
            child: widget.child));
  }
}

class _LevelPalette {
  final Color start, end;
  const _LevelPalette(this.start, this.end);
}

_LevelPalette _paletteForLevel(String level) {
  switch (level) {
    case 'A1':
      return const _LevelPalette(Color(0xFF00C2FF), Color(0xFF2563EB));
    case 'A2':
      return const _LevelPalette(Color(0xFF22C55E), Color(0xFF14B8A6));
    case 'B1':
      return const _LevelPalette(Color(0xFFF59E0B), Color(0xFFFFB020));
    case 'B2':
      return const _LevelPalette(Color(0xFFFF5B8A), Color(0xFFFF2E93));
    case 'C1':
      return const _LevelPalette(Color(0xFF8B5CF6), Color(0xFFA855F7));
    case 'C2':
      return const _LevelPalette(Color(0xFFFF8A00), Color(0xFFFF4FD8));
    default:
      return const _LevelPalette(Color(0xFF00C2FF), Color(0xFF8B5CF6));
  }
}
