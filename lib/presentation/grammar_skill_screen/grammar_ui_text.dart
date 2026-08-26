// ignore_for_file: unused_element

import 'dart:convert';

bool speakeryUseEnglishUi(Object? context, bool fallback) {
  // The app already passes the selected UI language with isEnglish.
  // Do not override it with the device/Flutter locale; otherwise Turkish UI can
  // accidentally turn English when the app locale is still en.
  return fallback;
}

bool isA1A2LessonKey(String key) =>
    key.startsWith('a1_') || key.startsWith('a2_');

bool hideA1A2TurkishContent(String lessonKey, bool isEnglish) => false;

bool showTurkishContentSupport(String lessonKey, bool isEnglish) {
  return true;
}

String repairGrammarMojibake(String value) => _repairMojibake(value);

String _repairMojibake(String value) {
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
}

String _repairTurkishAsciiArtifacts(String value) {
  var fixed = value
      // Repair long lossy fragments before shorter dictionary entries such as
      // "yap?" or "a�" can partially consume them.
      .replaceAll('yap?ld1?1n1', 'yapıldığını')
      .replaceAll('yap?ld1?1', 'yapıldığı')
      .replaceAll('a�1klamak', 'açıklamak')
      .replaceAll('olmad1?1n1', 'olmadığını')
      .replaceAll('ba_lang1�', 'başlangıç')
      .replaceAll('ba_lay1p', 'başlayıp')
      .replaceAll('anlat1rs1n', 'anlatırsın')
      .replaceAll('kullan1rs1n', 'kullanırsın')
      .replaceAll('anla_1l1yorsa', 'anlaşılıyorsa')
      .replaceAll('konu_ma an1nda', 'konuşma anında')
      .replaceAll('Konu_ma an1nda', 'Konuşma anında')
      .replaceAll('g�r�nen', 'görünen')
      .replaceAll('g�stermek', 'göstermek')
      .replaceAll('G��l�', 'Güçlü')
      .replaceAll('g��l�', 'güçlü');

  const replacements = <String, String>{
    // Common mojibake / replacement-character fragments in Turkish UI text.
    'ï¿½?retmen': 'Öğretmen',
    '�?retmen': 'Öğretmen',
    '�?ren': 'Öğren',
    'ï¿½rnek': 'Örnek',
    '�?rnek': 'Örnek',
    '�rnek': 'örnek',
    'ï¿½zne': 'Özne',
    '�?zne': 'Özne',
    '�zne': 'özne',
    '�zneye': 'özneye',
    '�zneden': 'özneden',
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
    'd�zensiz': 'düzensiz',
    'D�zensiz': 'Düzensiz',
    'de?i_im': 'değişim',
    'de?i_tir': 'değiştir',
    'de?i?mez': 'değişmez',
    'de?il': 'değil',
    'do?ru': 'doğru',
    'Do?ru': 'Doğru',
    'do�ru': 'doğru',
    'yanl?': 'yanlış',
    'Yanl?': 'Yanlış',
    'yanl��': 'yanlış',
    'yard?mc?': 'yardımcı',
    'Yard?mc?': 'Yardımcı',
    'ki?i': 'kişi',
    'Ki?i': 'Kişi',
    'e?ya': 'eşya',
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
    'kullan?rs?n': 'kullanırsın',
    'kullan?l?r': 'kullanılır',
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
    'ba_a': 'başa',
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
    'g�sterir': 'gösterir',
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
    'doesn?t': "doesn't",
    'don?t': "don't",
    'isn?t': "isn't",
    'aren?t': "aren't",
    'can?t': "can't",
    'shouldn?t': "shouldn't",
    'Mustn?t': "Mustn't",
    'mustn?t': "mustn't",
    'Don?t': "Don't",
    'didn?t': "didn't",
    'won?t': "won't",
    'evideönce': 'evidence',
    'differeönce': 'difference',
    'Forml': 'Formül',
    'Form�l': 'Formül',
    'Temiz �rnekler': 'Temiz örnekler',
    'Ayn1 yap1n1n do?al �rneklerini oku.':
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
    'Be fiili �zneye g�re ��: I am, he/she/it is, you/we/they are.':
        'Be fiili özneye göre değişir: I am, he/she/it is, you/we/they are.',
    '�zne g�re am, is veya are se�ilir': 'Özneye göre am, is veya are seçilir',
    'Olumsuzda not, be fiilinden sonra gelir.':
        'Olumsuzda not, be fiilinden sonra gelir.',
    'Kimlik, duygu, yer ve k1sa cevaplarda do?ru be fiilini kullan.':
        'Kimlik, duygu, yer ve kısa cevaplarda doğru be fiilini kullan.',
    'my, your, his, her Al?s, whose': "my, your, his, her, Ali's, whose",
    'komut, ynerge, rica': 'komut, yönerge, rica',
    'Telefon esk?yi al?yor.': 'Telefon eski. İyi çalışıyor.',
    'Hi ekme?e ihtiyac?m? var mı?': 'Hiç ekmeğe ihtiyacımız var mı?',
    'Hi ekme?e ihtiyacım? var mı?': 'Hiç ekmeğe ihtiyacımız var mı?',
    'arkada?lar?m': 'arkadaşlarım',
    'arkada__?y?z': 'arkadaşıyız',
    '�zne ve Nesne Zamirleri': 'Özne ve nesne zamirleri',
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
    's�reyi': 'süreyi',
    'vurgular': 'vurgular',
    's?fattan': 'sıfattan',
    'g��lendirir': 'güçlendirir',
    '�znenin': 'öznenin',
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
      .replaceAll('?have to?', '"have to"')
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
      .replaceAll('do?al', 'doğal')
      .replaceAll('Do?al', 'Doğal')
      .replaceAll('yap?n?n', 'yapının')
      .replaceAll('yap?n?', 'yapını')
      .replaceAll('�zneye', 'özneye')
      .replaceAll('�zne', 'özne')
      .replaceAll('�zneden', 'özneden')
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
      .replaceAll('�ok', 'Çok')
      .replaceAll('�ok', 'çok')
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
          'Be fiili özneye göre değişir: I am, he/she/it is, you/we/they are.')
      // Older generated grammar packs lost Turkish characters as ?, 1, _ or
      // U+FFFD. These replacements are whole recurring fragments, never
      // single-character guesses, so the repair stays conservative.
      .replaceAll('i�in', 'için')
      .replaceAll('i�indir', 'içindir')
      .replaceAll('i?in', 'için')
      .replaceAll('ge�mi_', 'geçmiş')
      .replaceAll('Ge�mi_', 'Geçmiş')
      .replaceAll('bitmi?', 'bitmiş')
      .replaceAll('Bitmi?', 'Bitmiş')
      .replaceAll('ba_lay1p', 'başlayıp')
      .replaceAll('ba_lang1�', 'başlangıç')
      .replaceAll('ba_1na', 'başına')
      .replaceAll('olaylar1', 'olayları')
      .replaceAll('olay1', 'olayı')
      .replaceAll('olan1', 'olanı')
      .replaceAll('anlat1rs1n', 'anlatırsın')
      .replaceAll('anlat1r', 'anlatır')
      .replaceAll('sorars1n', 'sorarsın')
      .replaceAll('kullan1rs1n', 'kullanırsın')
      .replaceAll('kullan?l?r', 'kullanılır')
      .replaceAll('kullan?rs?n', 'kullanırsın')
      .replaceAll('oldu?unu', 'olduğunu')
      .replaceAll('oldu?u', 'olduğu')
      .replaceAll('olmad1?1n1', 'olmadığını')
      .replaceAll('yap?ld1?1n1', 'yapıldığını')
      .replaceAll('yap?ld1?1', 'yapıldığı')
      .replaceAll('yap?y?', 'yapıyı')
      .replaceAll('yap?s?', 'yapısı')
      .replaceAll('sonras?nda', 'sonrasında')
      .replaceAll('s�ylersin', 'söylersin')
      .replaceAll('s�z', 'söz')
      .replaceAll('S�z', 'Söz')
      .replaceAll('s�re', 'süre')
      .replaceAll('S�re', 'Süre')
      .replaceAll('yard1m', 'yardım')
      .replaceAll('yard?mc?', 'yardımcı')
      .replaceAll('kal?r', 'kalır')
      .replaceAll('nas1l', 'nasıl')
      .replaceAll('kan1t', 'kanıt')
      .replaceAll('ayr1m', 'ayrım')
      .replaceAll('formlar1', 'formları')
      .replaceAll('sorular1nda', 'sorularında')
      .replaceAll('say1 ', 'sayı ')
      .replaceAll('an1ndaki', 'anındaki')
      .replaceAll('Hay1r', 'Hayır')
      .replaceAll('hay1r', 'hayır')
      .replaceAll('say?labilen', 'sayılabilen')
      .replaceAll('say1labilen', 'sayılabilen')
      .replaceAll('say?lamayan', 'sayılamayan')
      .replaceAll('say1lamayan', 'sayılamayan')
      .replaceAll('s?fatlarda', 'sıfatlarda')
      .replaceAll('s1fatlarda', 'sıfatlarda')
      .replaceAll('D�zensiz', 'Düzensiz')
      .replaceAll('d�zensiz', 'düzensiz')
      .replaceAll('d�zensiz', 'düzensiz')
      .replaceAll('k�t�', 'kötü')
      .replaceAll('g�r�nen', 'görünen')
      .replaceAll('g�stermek', 'göstermek')
      .replaceAll('G�rev', 'Görev')
      .replaceAll('g�rev', 'görev')
      .replaceAll('G��l�', 'Güçlü')
      .replaceAll('g��l�', 'güçlü')
      .replaceAll('�ok', 'çok')
      .replaceAll('�ok', 'Çok')
      .replaceAll('�o?ul', 'çoğul')
      .replaceAll('�o�ul', 'çoğul')
      .replaceAll('�ey', 'şey')
      .replaceAll('?ey', 'şey')
      .replaceAll('?eyi', 'şeyi')
      .replaceAll('?ngilizce', 'İngilizce')
      .replaceAll('?ki ', 'İki ')
      .replaceAll('?u an', 'şu an')
      .replaceAll('?u ', 'şu ')
      .replaceAll('i?aret', 'işaret')
      .replaceAll('dedi?in', 'dediğin')
      .replaceAll('ba?lamak', 'bağlamak')
      .replaceAll('sonu�', 'sonuç')
      .replaceAll('di?er', 'diğer')
      .replaceAll('0nsan ', 'İnsan ')
      .replaceAll('Yak1nda ba_layaca?1z', 'Yakında başlayacağız')
      .replaceAll('yak?nda ya?mur ya?acak', 'yakında yağmur yağacak')
      .replaceAll('Yak1nda varacaklar m1?', 'Yakında varacaklar mı?')
      .replaceAll('Yak1nda', 'Yakında')
      .replaceAll('yak?nda', 'yakında')
      .replaceAll('Yar1n', 'Yarın')
      .replaceAll('Yar1na', 'Yarına')
      .replaceAll('yar1n', 'yarın')
      .replaceAll('yak?n', 'yakın')
      .replaceAll('ba_layaca?1z', 'başlayacağız')
      .replaceAll('ba_layacak m1y1z', 'başlayacak mıyız')
      .replaceAll('ba_layacak', 'başlayacak')
      .replaceAll('ya?mur ya?acak', 'yağmur yağacak')
      .replaceAll('Ya?mur ya?acak', 'Yağmur yağacak')
      .replaceAll('varacaklar m1?', 'varacaklar mı?')
      .replaceAll('kalacaklar m1?', 'kalacaklar mı?')
      .replaceAll('kalacak m1s1n?', 'kalacak mısın?')
      .replaceAll('arayacak m1s1n?', 'arayacak mısın?')
      .replaceAll('alacak m1s1n?', 'alacak mısın?')
      .replaceAll('aramal1 m1y1m?', 'aramalı mıyım?')
      .replaceAll('m1y1z?', 'mıyız?')
      .replaceAll('m1y1m?', 'mıyım?')
      .replaceAll('yapacaks1n?', 'yapacaksın?')
      .replaceAll('yapmay1', 'yapmayı')
      .replaceAll('planlad1?1n1', 'planladığını')
      .replaceAll('g�rd�?�n', 'gördüğün')
      .replaceAll('gelece?e', 'geleceğe')
      .replaceAll('i?aret eder', 'işaret eder')
      .replaceAll('i?aret', 'işaret')
      .replaceAll('G�r�nen i?aret', 'Görünen işaret')
      .replaceAll('G�r�nen kan1ta', 'Görünen kanıta')
      .replaceAll('g�r�n�yor', 'görünüyor')
      .replaceAll('?lk g�n', 'İlk gün')
      .replaceAll('?lk tan1_mada', 'İlk tanışmada')
      .replaceAll('S?navdan �nce', 'Sınavdan önce')
      .replaceAll('S?nav1 ge�mek', 'Sınavı geçmek')
      .replaceAll('? g�revi', 'İş görevi')
      .replaceAll('?, okul', 'İş, okul')
      .replaceAll('�antan1 kontrol etmek', 'Çantanı kontrol etmek')
      .replaceAll('�antan1n', 'çantanın')
      .replaceAll('�antanda', 'çantanda')
      .replaceAll('i�inde', 'içinde')
      .replaceAll('e_yalardan', 'eşyalardan')
      .replaceAll('e_yan1n', 'eşyanın')
      .replaceAll('e_yay1', 'eşyayı')
      .replaceAll('Al1_veri_', 'Alışveriş')
      .replaceAll('s?n?f', 'sınıf')
      .replaceAll('?eyle', 'şeyle')
      .replaceAll('?eyleri', 'şeyleri')
      .replaceAll('Do?um g�n�m', 'Doğum günüm')
      .replaceAll('g�n�m', 'günüm')
      .replaceAll('g�nleri', 'günleri')
      .replaceAll('g�n�', 'günü')
      .replaceAll('g�n', 'gün')
      .replaceAll('D�n ak?am', 'Dün akşam')
      .replaceAll('D�n gece', 'Dün gece')
      .replaceAll('D�n ne yapt1?1n1', 'Dün ne yaptığını')
      .replaceAll('yapt1?1n1', 'yaptığını')
      .replaceAll('yapt1n?', 'yaptın?')
      .replaceAll('arad1n m1?', 'aradın mı?')
      .replaceAll('ald1n m1?', 'aldın mı?')
      .replaceAll('kald1n m1?', 'kaldın mı?')
      .replaceAll('izledin mi?', 'izledin mi?')
      .replaceAll('odam1', 'odamı')
      .replaceAll('odas1n1', 'odasını')
      .replaceAll('amcam1', 'amcamı')
      .replaceAll('B�t�n gece', 'Bütün gece')
      .replaceAll('b�t�n gece', 'bütün gece')
      .replaceAll('Kahvalt1y1', 'Kahvaltıyı')
      .replaceAll('atlamamal1s1n', 'atlamamalısın')
      .replaceAll('uyumal1s1n', 'uyumalısın')
      .replaceAll('takmal1s1n', 'takmalısın')
      .replaceAll('sormal1s1n', 'sormalısın')
      .replaceAll('yapmal1s1n', 'yapmalısın')
      .replaceAll('�al1_mas1', 'çalışması')
      .replaceAll('�al1_malar1', 'çalışmaları')
      .replaceAll('�al1_man', 'çalışman')
      .replaceAll('�al1_mal1', 'çalışmalı')
      .replaceAll('�al1_mal1s1n', 'çalışmalısın')
      .replaceAll('�al1_mamal1s1n', 'çalışmamalısın')
      .replaceAll('�al1_t1 m1?', 'çalıştı mı?')
      .replaceAll('�al1_t1', 'çalıştı')
      .replaceAll('�al1_maz', 'çalışmaz')
      .replaceAll('�deme', 'ödeme')
      .replaceAll('de?iliz', 'değiliz')
      .replaceAll('_imdi', 'şimdi')
      .replaceAll('Dosyay1', 'Dosyayı')
      .replaceAll('g�nderece?im', 'göndereceğim')
      .replaceAll('^emsiye', 'Şemsiye')
      .replaceAll('^ehirler', 'Şehirler')
      .replaceAll('^u an', 'Şu an')
      .replaceAll('^u ', 'Şu ')
      .replaceAll('�niforma', 'Üniforma')
      .replaceAll('K�t�phanede', 'Kütüphanede')
      .replaceAll('k�t�phanede', 'kütüphanede')
      .replaceAll('alan1n', 'alanın')
      .replaceAll('geni_', 'geniş')
      .replaceAll('ay/y1l', 'ay/yıl')
      .replaceAll('kitab1n1', 'kitabını')
      .replaceAll('otob�s', 'otobüs')
      .replaceAll('s?k g�r�l�r', 'sık görülür')
      .replaceAll('g�r�l�r', 'görülür')
      .replaceAll('Ba?lam', 'Bağlam')
      .replaceAll('ba?lam', 'bağlam')
      .replaceAll('ya?acak', 'yaşayacak')
      .replaceAll('m1s1n?', 'mısın?')
      .replaceAll('m1?', 'mı?')
      .replaceAll(' Çok ', ' çok ');

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

List<String> repairGrammarStringList(List<String> values) {
  return values.map(_repairMojibake).toList(growable: false);
}

Map<String, List<String>> repairGrammarStringListMap(
    Map<String, List<String>> values) {
  return values.map(
    (key, value) => MapEntry(key, repairGrammarStringList(value)),
  );
}

String repairVisibleGrammarText(String value) => _repairMojibake(value);

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
