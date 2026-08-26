import 'package:speakery/presentation/grammar_skill_screen/grammar_ui_text.dart';

void main() {
  const damaged = <String, String>{
    'H?zl? Bak1_': 'Hızlı bakış',
    'Ge�mi_te ba_lay1p bitmi? olaylar1 anlat1r.':
        'Geçmişte başlayıp bitmiş olayları anlatır.',
    'Bir eylemin neden yap?ld1?1n1 a�1klamak i�in to + V1 kullan?l?r.':
        'Bir eylemin neden yapıldığını açıklamak için to + V1 kullanılır.',
    'Mustn?t yasak; don?t have to zorunluluk olmad1?1n1 anlat1r.':
        "Mustn't yasak; don't have to zorunluluk olmadığını anlatır.",
    'When k1sa olay1, while devam eden sahneyi ba?lamak i�in �ok kullan?l?r.':
        'When kısa olayı, while devam eden sahneyi bağlamak için çok kullanılır.',
    'Bulut, kan1t veya g�r�nen durum varsa tahmin i�in kullan?l?r.':
        'Bulut, kanıt veya görünen durum varsa tahmin için kullanılır.',
    'Sonuç ?u anki durumdan anla_1l1yorsa kullan?l?r.':
        'Sonuç şu anki durumdan anlaşılıyorsa kullanılır.',
    'G��l� kurallar i�in must, g�rev i�in have to kullan?l?r.':
        'Güçlü kurallar için must, görev için have to kullanılır.',
    '0nsan i�in who, ?ey veya fikir i�in which kullan?l?r.':
        'İnsan için who, şey veya fikir için which kullanılır.',
  };

  for (final entry in damaged.entries) {
    final repaired = repairGrammarMojibake(entry.key);
    if (repaired != entry.value) {
      throw StateError(
        'Repair mismatch:\ninput: ${entry.key}\nactual: $repaired\nexpected: ${entry.value}',
      );
    }
    if (repairGrammarMojibake(repaired) != repaired) {
      throw StateError('Repair is not idempotent: $repaired');
    }
  }

  const clean = 'İki şeyi karşılaştırırken doğru sıfatı kullan.';
  if (repairGrammarMojibake(clean) != clean) {
    throw StateError('Clean Turkish text was modified.');
  }

  print('Grammar text sanitizer: ${damaged.length + 1} checks passed.');
}
