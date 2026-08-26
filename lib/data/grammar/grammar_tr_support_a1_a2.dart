// Turkish lesson-content support prepared for a future controlled re-enable.
//
// This file is intentionally not connected to the UI yet. It keeps clean,
// reviewed Turkish support content separate from generated or repaired strings
// so A1/A2 Turkish lesson-content can be restored later in a safer way.

class GrammarTrSupport {
  final String lessonKey;
  final String? teacherNote;
  final List<String> quickLookBullets;
  final List<String> structureNotes;
  final List<String> usageNotes;
  final Map<String, String> exampleTranslations;
  final Map<String, String> quizExplanations;

  const GrammarTrSupport({
    required this.lessonKey,
    this.teacherNote,
    this.quickLookBullets = const <String>[],
    this.structureNotes = const <String>[],
    this.usageNotes = const <String>[],
    this.exampleTranslations = const <String, String>{},
    this.quizExplanations = const <String, String>{},
  });
}

const Map<String, GrammarTrSupport> grammarTrSupportA1A2 =
    <String, GrammarTrSupport>{
  'a1_be': GrammarTrSupport(
    lessonKey: 'a1_be',
    teacherNote:
        'Be fiili özneye göre değişir: I am, he/she/it is, you/we/they are.',
    quickLookBullets: <String>[
      'Kimlik, duygu, yer ve durum anlatır.',
      'Olumsuzda not, be fiilinden sonra gelir.',
      'Soruda be fiili öznenin önüne gelir.',
    ],
    structureNotes: <String>[
      'Olumlu: özne + am/is/are.',
      'Olumsuz: özne + am/is/are + not.',
      'Soru: am/is/are + özne.',
    ],
    usageNotes: <String>[
      'Kendini tanıtırken kullanılır.',
      'Birinin nerede veya nasıl olduğunu söylerken kullanılır.',
    ],
    exampleTranslations: <String, String>{
      'I am ready.': 'Hazırım.',
      'She is at home.': 'O evde.',
      'Are you tired?': 'Yorgun musun?',
    },
    quizExplanations: <String, String>{
      'be_subject_match': 'Doğru be fiili özneye göre seçilir.',
      'be_question_order': 'Soruda be fiili öznenin önüne gelir.',
    },
  ),
  'a1_subject_object_pronouns': GrammarTrSupport(
    lessonKey: 'a1_subject_object_pronouns',
    teacherNote:
        'Özne zamiri işi yapan kişiyi, nesne zamiri fiilden etkilenen kişiyi gösterir.',
    quickLookBullets: <String>[
      'I, you, he, she, it, we, they özne zamirleridir.',
      'Me, him, her, us, them nesne zamirleridir.',
      'Nesne zamiri genellikle fiilden sonra gelir.',
    ],
    structureNotes: <String>[
      'Özne: He is my friend.',
      'Nesne: I know him.',
    ],
    usageNotes: <String>[
      'Aynı ismi tekrar etmemek için zamir kullanılır.',
      'Kişilerden ve nesnelerden kısa biçimde söz edilir.',
    ],
    exampleTranslations: <String, String>{
      'He is my friend.': 'O benim arkadaşım.',
      'I know him.': 'Onu tanıyorum.',
      'Can you help me?': 'Bana yardım edebilir misin?',
    },
    quizExplanations: <String, String>{
      'subject_pronoun': 'Fiilden önce özne zamiri kullanılır.',
      'object_pronoun': 'Fiilden sonra nesne zamiri kullanılır.',
    },
  ),
  'a1_possessives': GrammarTrSupport(
    lessonKey: 'a1_possessives',
    teacherNote:
        'Sahiplik yapıları bir şeyin kime ait olduğunu açıkça gösterir.',
    quickLookBullets: <String>[
      'My, your, his, her, our, their isimden önce gelir.',
      'Possessive s bir isme sahiplik anlamı katar.',
      'Whose ile sahibini sorarsın.',
    ],
    structureNotes: <String>[
      'Sıfat: my bag, her phone.',
      'İsimle sahiplik: Ece’s bag.',
      'Soru: Whose bag is this?',
    ],
    usageNotes: <String>[
      'Aile, eşya ve kişisel bilgilerde kullanılır.',
      'Bir nesnenin sahibini belirtir.',
    ],
    exampleTranslations: <String, String>{
      'My bag is blue.': 'Çantam mavi.',
      'This is Ece’s bag.': 'Bu Ece’nin çantası.',
      'Whose pen is this?': 'Bu kimin kalemi?',
    },
    quizExplanations: <String, String>{
      'possessive_adjective': 'Sahiplik sıfatından sonra isim gelir.',
      'whose_question': 'Whose, sahipliği sormak için kullanılır.',
    },
  ),
  'a1_basic_prepositions': GrammarTrSupport(
    lessonKey: 'a1_basic_prepositions',
    teacherNote:
        'In, on ve at yer veya zaman bilgisini kısa ve net biçimde verir.',
    quickLookBullets: <String>[
      'In genellikle alan veya kapalı yer anlatır.',
      'On yüzey ve günlerle kullanılır.',
      'At nokta yer veya saat anlatır.',
    ],
    structureNotes: <String>[
      'In + room/city/month.',
      'On + table/day.',
      'At + school/time.',
    ],
    usageNotes: <String>[
      'Bir şeyin nerede olduğunu söylerken kullanılır.',
      'Saat, gün ve yer bilgisini bağlar.',
    ],
    exampleTranslations: <String, String>{
      'The book is on the table.': 'Kitap masanın üstünde.',
      'She is at school.': 'O okulda.',
      'I live in Ankara.': 'Ankara’da yaşıyorum.',
    },
    quizExplanations: <String, String>{
      'place_preposition': 'Yer anlamına göre doğru edat seçilir.',
      'time_preposition': 'Zaman ifadesi edat seçimini etkiler.',
    },
  ),
  'a2_past_simple': GrammarTrSupport(
    lessonKey: 'a2_past_simple',
    teacherNote:
        'Past Simple geçmişte bitmiş olayları anlatır; zamanda netlik önemlidir.',
    quickLookBullets: <String>[
      'Olumlu cümlede fiilin geçmiş hali kullanılır.',
      'Olumsuzda did not + V1 kullanılır.',
      'Soruda did + özne + V1 kullanılır.',
    ],
    structureNotes: <String>[
      'Olumlu: subject + V2.',
      'Olumsuz: subject + did not + V1.',
      'Soru: did + subject + V1?',
    ],
    usageNotes: <String>[
      'Dün, geçen hafta, iki gün önce gibi zamanlarla kullanılır.',
      'Geçmişte tamamlanan eylemleri anlatır.',
    ],
    exampleTranslations: <String, String>{
      'I visited my aunt yesterday.': 'Dün teyzemi ziyaret ettim.',
      'She went to Ankara last week.': 'Geçen hafta Ankara’ya gitti.',
      'Did you finish your homework?': 'Ödevini bitirdin mi?',
    },
    quizExplanations: <String, String>{
      'past_positive': 'Olumlu geçmiş cümlede fiilin ikinci hali kullanılır.',
      'past_negative': 'Did not sonrası fiil yalın halde kalır.',
      'past_question': 'Soruda did başa gelir ve fiil yalın halde kalır.',
    },
  ),
  'a2_must_have_to': GrammarTrSupport(
    lessonKey: 'a2_must_have_to',
    teacherNote:
        'Must ve have to zorunluluk anlatır; mustn’t yasak anlamı verir.',
    quickLookBullets: <String>[
      'Must güçlü kural veya zorunluluk anlatır.',
      'Have to günlük zorunluluklarda yaygındır.',
      'Mustn’t bir şeyi yapmaman gerektiğini söyler.',
    ],
    structureNotes: <String>[
      'Must + V1.',
      'Have/has to + V1.',
      'Must not + V1.',
    ],
    usageNotes: <String>[
      'Okul, iş ve güvenlik kurallarında kullanılır.',
      'Kişisel zorunlulukları anlatırken kullanılır.',
    ],
    exampleTranslations: <String, String>{
      'You must wear a helmet.': 'Kask takmalısın.',
      'I have to study tonight.': 'Bu gece ders çalışmam gerekiyor.',
      'You must not touch that.': 'Ona dokunmamalısın.',
    },
    quizExplanations: <String, String>{
      'must_obligation': 'Must güçlü zorunluluk anlatır.',
      'have_to_obligation': 'Have to günlük zorunluluk anlatır.',
      'must_not_prohibition': 'Must not yasak anlamı verir.',
    },
  ),
  'a2_some_any': GrammarTrSupport(
    lessonKey: 'a2_some_any',
    teacherNote:
        'Some ve any miktarı belirsiz olan şeyleri anlatır; cümle türü seçimi etkiler.',
    quickLookBullets: <String>[
      'Some genellikle olumlu cümlelerde kullanılır.',
      'Any genellikle olumsuz ve soru cümlelerinde kullanılır.',
      'Sayılabilen çoğul ve sayılamayan isimlerle kullanılabilir.',
    ],
    structureNotes: <String>[
      'Olumlu: some + noun.',
      'Olumsuz: not any + noun.',
      'Soru: any + noun?',
    ],
    usageNotes: <String>[
      'Yiyecek, içecek ve günlük ihtiyaçlarda sık kullanılır.',
      'Miktar tam bilinmediğinde kullanılır.',
    ],
    exampleTranslations: <String, String>{
      'I need some water.': 'Biraz suya ihtiyacım var.',
      'There are not any apples.': 'Hiç elma yok.',
      'Do you have any milk?': 'Sütün var mı?',
    },
    quizExplanations: <String, String>{
      'some_positive': 'Some çoğunlukla olumlu cümlede kullanılır.',
      'any_negative': 'Any olumsuz cümlede yaygındır.',
      'any_question': 'Soru cümlelerinde any sık kullanılır.',
    },
  ),
};
