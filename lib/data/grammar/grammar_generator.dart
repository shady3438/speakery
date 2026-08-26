import 'package:flutter/material.dart';
import 'package:speakery/data/grammar/grammar_models.dart';

/// Speakery Grammar Generator
///
/// This file is the grammar brain. The screen should render these points instead
/// of guessing whether a row is positive, negative, question, mistake, etc.
/// Phase160 starts the split architecture: screen = renderer, this file = logic.
class GrammarLogicPoint {
  final String kind;
  final String titleEn;
  final String titleTr;
  final String model;
  final String avoid;
  final String logicEn;
  final String logicTr;

  const GrammarLogicPoint({
    required this.kind,
    required this.titleEn,
    required this.titleTr,
    required this.model,
    required this.avoid,
    required this.logicEn,
    required this.logicTr,
  });

  String title(bool isEnglish) => isEnglish ? titleEn : titleTr;
  String logic(bool isEnglish) => isEnglish ? logicEn : logicTr;
}

List<GrammarLogicPoint> generateGrammarLogicPoints(GrammarLesson lesson) {
  final key = _lessonKey(lesson);
  final special = _specialBlueprint(key);
  if (special.isNotEmpty) return special;

  final generated = <GrammarLogicPoint>[];
  for (final row in lesson.formulaRows) {
    if (generated.length >= 5) break;
    final model = _singleSentence(row.sample);
    if (!_isGoodModel(model)) continue;

    final kind = _rowKind(row.label, row.pattern, row.sample);
    final avoid = _avoidFor(kind, model, row.label, row.pattern);
    if (!_isGoodAvoid(avoid) || _same(model, avoid)) continue;

    generated.add(
      GrammarLogicPoint(
        kind: kind,
        titleEn: _cleanRowLabel(row.label, true, kind),
        titleTr: _cleanRowLabel(row.label, false, kind),
        model: model,
        avoid: avoid,
        logicEn: _logicFor(kind, true),
        logicTr: _logicFor(kind, false),
      ),
    );
  }

  if (generated.isNotEmpty) return generated;

  final model = _firstGoodSentence([
        lesson.right,
        ...lesson.examples,
        lesson.modelAnswer,
      ]) ??
      'I use this structure correctly.';

  final avoid = _avoidFor('usage', model, '', '');
  return [
    GrammarLogicPoint(
      kind: 'usage',
      titleEn: 'Core use',
      titleTr: 'Temel kullanım',
      model: model,
      avoid: avoid,
      logicEn:
          'The model keeps the natural word order and verb form for this use.',
      logicTr:
          'Model cümle bu kullanım için doğal kelime sırasını ve fiil biçimini korur.',
    ),
  ];
}

/// Returns the internal blueprint key. Useful while adding new level data files.
/// If this returns a long raw title, that lesson is probably falling back.
String debugGrammarBlueprintKey(GrammarLesson lesson) => _lessonKey(lesson);

List<GrammarLogicPoint> _specialBlueprint(String key) {
  final phase189 = _phase189Blueprint(key);
  if (phase189.isNotEmpty) return phase189;

  switch (key) {
    case 'a1_be_verb':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'I + am',
            titleTr: 'I + am',
            model: 'I am ready.',
            avoid: 'I is ready.',
            logicEn: 'With “I”, be verb is always “am”: I am…',
            logicTr: 'I öznesiyle be verb her zaman “am” olur: I am…'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'He / She / It + is',
            titleTr: 'He / She / It + is',
            model: 'She is tired.',
            avoid: 'She are tired.',
            logicEn: 'With he/she/it (and singular nouns), use “is”.',
            logicTr: 'He/she/it (ve tekil isim) ile “is” kullanılır: She is…'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'You / We / They + are',
            titleTr: 'You / We / They + are',
            model: 'They are at home.',
            avoid: 'They is at home.',
            logicEn: 'With you/we/they (and plural nouns), use “are”.',
            logicTr:
                'You/we/they (ve çoğul isim) ile “are” kullanılır: They are…'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative be verb',
            titleTr: 'Olumsuz be verb',
            model: 'He is not late.',
            avoid: 'He not is late.',
            logicEn: 'In negatives, put “not” after am/is/are.',
            logicTr:
                'Olumsuzda “not”, be verb’den sonra gelir: He is not… / He isn’t…'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            model: 'Are you okay?',
            avoid: 'Do you are okay?',
            logicEn:
                'Questions: move am/is/are before the subject (no do/does).',
            logicTr:
                'Soru: be verb başa gelir (Are you…?). “Do/does” kullanılmaz.'),
      ];
    case 'a1_present_simple':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'I / You / We / They + V1',
            titleTr: 'I / You / We / They + V1',
            model: 'I work every day.',
            avoid: 'I works every day.',
            logicEn: 'I/you/we/they use the base verb (no -s).',
            logicTr: 'I/you/we/they ile fiil yalın kalır: I work… (-s yok).'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'He / She / It + -s',
            titleTr: 'He / She / It + -s',
            model: 'She studies English after school.',
            avoid: 'She study English after school.',
            logicEn: 'He/she/it takes -s/-es in affirmative sentences.',
            logicTr:
                'Olumlu cümlede he/she/it ile fiile -s/-es gelir: she works / he goes.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Don’t + V1',
            titleTr: 'Don’t + V1',
            model: 'They don’t watch TV every night.',
            avoid: 'They don’t watches TV every night.',
            logicEn: 'After don’t, keep the main verb in base form.',
            logicTr:
                'Don’t sonrası fiil V1 kalır: don’t watch (watch+s olmaz).'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Doesn’t + V1',
            titleTr: 'Doesn’t + V1',
            model: 'She doesn’t like coffee.',
            avoid: 'She doesn’t likes coffee.',
            logicEn: 'After doesn’t, remove the -s from the main verb.',
            logicTr:
                'Doesn’t zaten he/she/it içindir; ana fiile -s ekleme: doesn’t like.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Do / Does + subject + V1?',
            titleTr: 'Do / Does + özne + V1?',
            model: 'Does your brother play football?',
            avoid: 'Does your brother plays football?',
            logicEn: 'Questions use Do/Does + subject + base verb.',
            logicTr:
                'Soru: Do/Does + özne + V1. Does varsa fiil V1 kalır (play, plays değil).'),
      ];
    case 'a2_past_simple':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Positive finished action',
            titleTr: 'Bitmiş olumlu olay',
            model: 'I watched a movie yesterday.',
            avoid: 'I watch a movie yesterday.',
            logicEn: 'Use V2/-ed when the action is finished in the past.',
            logicTr: 'Olay geçmişte bittiyse olumlu cümlede V2/-ed kullan.'),
        GrammarLogicPoint(
            kind: 'irregular',
            titleEn: 'Irregular past form',
            titleTr: 'Düzensiz geçmiş form',
            model: 'She went to Ankara last week.',
            avoid: 'She go to Ankara last week.',
            logicEn:
                'Irregular verbs have special past forms: go becomes went.',
            logicTr:
                'Düzensiz fiiller özel geçmiş form alır: go fiili went olur.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative with did not',
            titleTr: 'Did not ile olumsuz',
            model: 'I did not go to school.',
            avoid: 'I did not went to school.',
            logicEn: 'After did not, the main verb returns to V1.',
            logicTr: 'Did not geldiğinde ana fiil tekrar V1 olur.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Question with did',
            titleTr: 'Did ile soru',
            model: 'Did you call me yesterday?',
            avoid: 'Did you called me yesterday?',
            logicEn: 'In questions, use Did + subject + V1.',
            logicTr: 'Soruda Did + özne + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Finished time signal',
            titleTr: 'Bitmiş zaman ipucu',
            model: 'We met two days ago.',
            avoid: 'We meet two days ago.',
            logicEn:
                'Ago, yesterday and last week usually point to Past Simple.',
            logicTr: 'Ago, yesterday ve last week genelde Past Simple ister.'),
      ];
    case 'a2_past_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Was + V-ing',
            titleTr: 'Was + V-ing',
            model: 'I was studying at 9 p.m.',
            avoid: 'I studying at 9 p.m.',
            logicEn: 'Use was before V-ing with I/he/she/it.',
            logicTr: 'I/he/she/it ile V-ing öncesinde was kullan.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Were + V-ing',
            titleTr: 'Were + V-ing',
            model: 'They were watching TV at 9.',
            avoid: 'They was watching TV at 9.',
            logicEn: 'Use were before V-ing with you/we/they.',
            logicTr: 'You/we/they ile V-ing öncesinde were kullan.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative past scene',
            titleTr: 'Olumsuz geçmiş sahne',
            model: 'She was not sleeping.',
            avoid: 'She not was sleeping.',
            logicEn: 'Put not after was/were.',
            logicTr: 'Olumsuzda not, was/were sonrasına gelir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            model: 'Were you listening?',
            avoid: 'You were listening?',
            logicEn: 'Move was/were before the subject in questions.',
            logicTr: 'Soruda was/were öznenin önüne gelir.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Interrupted action',
            titleTr: 'Araya giren kısa olay',
            model: 'I was studying when you called.',
            avoid: 'I studying when you called.',
            logicEn:
                'The long action uses Past Continuous; the short action uses Past Simple.',
            logicTr:
                'Uzun olay Past Continuous, araya giren kısa olay Past Simple olur.'),
      ];
    case 'a2_comparatives':
      return const [
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'Short adjective + -er',
            titleTr: 'Kısa sıfat + -er',
            model: 'Kayseri is colder than Antalya.',
            avoid: 'Kayseri is more cold than Antalya.',
            logicEn: 'Short adjectives usually take -er.',
            logicTr: 'Kısa sıfatlarda genelde -er kullanılır.'),
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'More + long adjective',
            titleTr: 'More + uzun sıfat',
            model: 'This lesson is more useful than the last one.',
            avoid: 'This lesson is usefuler than the last one.',
            logicEn: 'Long adjectives usually use more.',
            logicTr: 'Uzun sıfatlarda genelde more kullanılır.'),
        GrammarLogicPoint(
            kind: 'irregular',
            titleEn: 'Irregular comparative',
            titleTr: 'Düzensiz comparative',
            model: 'This answer is better than mine.',
            avoid: 'This answer is more better than mine.',
            logicEn: 'Good becomes better; do not say more better.',
            logicTr: 'Good kelimesi better olur; more better denmez.'),
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'Use than',
            titleTr: 'Than kullan',
            model: 'The train is faster than the bus.',
            avoid: 'The train is faster from the bus.',
            logicEn: 'Than introduces the second side of the comparison.',
            logicTr: 'Karşılaştırılan ikinci taraf than ile gelir.'),
      ];
    case 'a2_must_have_to':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Must + V1',
            titleTr: 'Must + V1',
            model: 'You must wear a seat belt.',
            avoid: 'You must to wear a seat belt.',
            logicEn: 'Must is followed directly by V1.',
            logicTr: 'Must sonrasında doğrudan V1 gelir.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Have to obligation',
            titleTr: 'Have to zorunluluğu',
            model: 'I have to finish my homework.',
            avoid: 'I must to finish my homework.',
            logicEn: 'Have to is natural for duties and outside obligations.',
            logicTr: 'Have to görev ve dış zorunluluklarda doğaldır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Has to with he/she/it',
            titleTr: 'He/she/it ile has to',
            model: 'She has to wake up early.',
            avoid: 'She have to wake up early.',
            logicEn: 'Use has to with he/she/it.',
            logicTr: 'He/she/it ile has to kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'No necessity',
            titleTr: 'Gereklilik yok',
            model: 'You do not have to come early.',
            avoid: 'You must not come early.',
            logicEn:
                'Don’t have to means it is not necessary; mustn’t means it is forbidden.',
            logicTr: 'Don’t have to gerek yok, mustn’t yasak anlamı verir.'),
      ];

    case 'a1_present_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'am/is/are + V-ing',
            titleTr: 'am/is/are + V-ing',
            model: 'I am studying now.',
            avoid: 'I studying now.',
            logicEn:
                'Present Continuous is be + V-ing. The -ing verb cannot stand alone.',
            logicTr:
                'Present Continuous = am/is/are + V-ing. V-ing tek başına yetmez.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'He / She / It + is',
            titleTr: 'He / She / It + is',
            model: 'She is reading a book.',
            avoid: 'She are reading a book.',
            logicEn: 'Use is with he/she/it (singular).',
            logicTr: 'He/she/it ile “is” kullanılır: She is…'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative form',
            titleTr: 'Olumsuz yapı',
            model: 'They are not sleeping.',
            avoid: 'They not are sleeping.',
            logicEn: 'Negatives: be + not + V-ing.',
            logicTr:
                'Olumsuz: be + not + V-ing. “not” be verb’den sonra gelir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            model: 'Are you listening?',
            avoid: 'Do you are listening?',
            logicEn: 'Questions: be comes first (no do/does).',
            logicTr: 'Soru: be başa gelir (Are you…?). “Do/does” kullanılmaz.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Now signal',
            titleTr: 'Şimdi ipucu',
            model: 'We are having lunch right now.',
            avoid: 'We have lunch right now.',
            logicEn:
                'Right now / at the moment strongly point to Present Continuous.',
            logicTr:
                'Right now / at the moment genelde Present Continuous ister.'),
      ];
    case 'a1_can_cant':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Can + V1',
            titleTr: 'Can + V1',
            model: 'I can swim.',
            avoid: 'I can to swim.',
            logicEn: 'After can, use the base verb (no to).',
            logicTr: 'Can’dan sonra fiil yalın gelir: to yok.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'No -s after can',
            titleTr: 'Can sonrası -s yok',
            model: 'She can speak English.',
            avoid: 'She cans speak English.',
            logicEn: 'Can never takes -s (even with he/she/it).',
            logicTr: 'Can, he/she/it ile bile -s almaz.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Cannot / can’t',
            titleTr: 'Cannot / can’t',
            model: 'He cannot drive a car.',
            avoid: 'He cannot to drive a car.',
            logicEn: 'Negative ability: cannot/can’t + base verb.',
            logicTr: 'Olumsuz yetenek: cannot/can’t + V1.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Can question',
            titleTr: 'Can ile soru',
            model: 'Can you help me?',
            avoid: 'Do you can help me?',
            logicEn: 'Questions start with can: Can + subject + V1?',
            logicTr: 'Soru: Can + özne + V1? “Do/does” kullanılmaz.'),
      ];
    case 'a1_there_is_are':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'There is + singular',
            titleTr: 'There is + tekil',
            model: 'There is a desk in my room.',
            avoid: 'There are a desk in my room.',
            logicEn: 'Use there is with singular nouns.',
            logicTr: 'Tekil isimlerle there is kullanılır.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'There are + plural',
            titleTr: 'There are + çoğul',
            model: 'There are two chairs in the kitchen.',
            avoid: 'There is two chairs in the kitchen.',
            logicEn: 'Use there are with plural nouns.',
            logicTr: 'Çoğul isimlerle there are kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative existence',
            titleTr: 'Olumsuz varlık',
            model: 'There are not any books here.',
            avoid: 'There is not any books here.',
            logicEn: 'Plural negative sentences use there are not.',
            logicTr: 'Çoğul olumsuz cümlede there are not kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Is / Are there?',
            titleTr: 'Is / Are there?',
            model: 'Are there any students in the room?',
            avoid: 'Is there any students in the room?',
            logicEn: 'Choose is or are according to the noun after there.',
            logicTr: 'There sonrasındaki isme göre is veya are seçilir.'),
      ];
    case 'a1_articles':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'A + consonant sound',
            titleTr: 'Sessiz sesle a',
            model: 'I saw a dog.',
            avoid: 'I saw dog.',
            logicEn: 'A singular countable noun usually needs an article.',
            logicTr: 'Tekil sayılabilen isim genelde article ister.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'An + vowel sound',
            titleTr: 'Sesli sesle an',
            model: 'She has an umbrella.',
            avoid: 'She has a umbrella.',
            logicEn: 'Use an before a vowel sound.',
            logicTr: 'Sesli sesle başlayan kelimelerden önce an kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'The for known things',
            titleTr: 'Bilinen şeylerde the',
            model: 'The dog was black.',
            avoid: 'A dog was black.',
            logicEn: 'Use the when the listener knows which thing you mean.',
            logicTr:
                'Dinleyici hangi şeyden bahsettiğini biliyorsa the kullanılır.'),
        GrammarLogicPoint(
            kind: 'irregular',
            titleEn: 'Sound, not letter',
            titleTr: 'Harf değil ses',
            model: 'He is an honest man.',
            avoid: 'He is a honest man.',
            logicEn: 'Article choice depends on sound, not only spelling.',
            logicTr: 'Article seçimi harfe değil sese bağlıdır.'),
      ];
    case 'a2_going_to':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'I am going to + V1',
            titleTr: 'I am going to + V1',
            model: 'I am going to study tonight.',
            avoid: 'I going to study tonight.',
            logicEn: 'Going to needs am/is/are before it.',
            logicTr: 'Going to yapısından önce am/is/are gerekir.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'He / She / It is going to',
            titleTr: 'He / She / It is going to',
            model: 'She is going to call you.',
            avoid: 'She are going to call you.',
            logicEn: 'Use is going to with he/she/it.',
            logicTr: 'He/she/it ile is going to kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative plan',
            titleTr: 'Olumsuz plan',
            model: 'We are not going to wait.',
            avoid: 'We do not going to wait.',
            logicEn: 'Negative form uses am/is/are + not going to.',
            logicTr: 'Olumsuz yapı am/is/are + not going to şeklindedir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Going to question',
            titleTr: 'Going to sorusu',
            model: 'Are you going to join us?',
            avoid: 'Do you going to join us?',
            logicEn: 'Questions begin with am/is/are.',
            logicTr: 'Sorular am/is/are ile başlar.'),
      ];
    case 'a2_should':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Should + V1',
            titleTr: 'Should + V1',
            model: 'You should drink more water.',
            avoid: 'You should to drink more water.',
            logicEn: 'Should is followed directly by V1.',
            logicTr: 'Should sonrasında doğrudan V1 gelir.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'No -s after should',
            titleTr: 'Should sonrası -s yok',
            model: 'She should study more.',
            avoid: 'She should studies more.',
            logicEn: 'Should does not take -s with he/she/it.',
            logicTr: 'Should, he/she/it ile -s almaz.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Shouldn’t + V1',
            titleTr: 'Shouldn’t + V1',
            model: 'You should not sleep late.',
            avoid: 'You should not to sleep late.',
            logicEn: 'Negative advice uses should not + V1.',
            logicTr: 'Olumsuz tavsiye should not + V1 ile kurulur.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Should question',
            titleTr: 'Should sorusu',
            model: 'Should I call her?',
            avoid: 'Do I should call her?',
            logicEn: 'Should goes before the subject in questions.',
            logicTr: 'Should soruda öznenin önüne gelir.'),
      ];
    case 'a2_too_enough':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Too + adjective',
            titleTr: 'Too + sıfat',
            model: 'This bag is too heavy.',
            avoid: 'This bag is heavy too.',
            logicEn:
                'Too comes before the adjective and often shows a problem.',
            logicTr: 'Too sıfattan önce gelir ve çoğu zaman problem gösterir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Adjective + enough',
            titleTr: 'Sıfat + enough',
            model: 'He is old enough to drive.',
            avoid: 'He is enough old to drive.',
            logicEn: 'Enough comes after adjectives.',
            logicTr: 'Enough sıfatlardan sonra gelir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Enough + noun',
            titleTr: 'Enough + isim',
            model: 'We have enough time.',
            avoid: 'We have time enough.',
            logicEn: 'Enough comes before nouns.',
            logicTr: 'Enough isimlerden önce gelir.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Not enough',
            titleTr: 'Yeterli değil',
            model: 'This room is not big enough.',
            avoid: 'This room is not enough big.',
            logicEn: 'Use not + adjective + enough.',
            logicTr: 'Not + sıfat + enough kullanılır.'),
      ];
    case 'a2_present_perfect_intro':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Have / has + V3',
            titleTr: 'Have / has + V3',
            model: 'I have visited Istanbul.',
            avoid: 'I have visit Istanbul.',
            logicEn: 'Present Perfect needs have/has + V3.',
            logicTr: 'Present Perfect have/has + V3 ister.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'He / She / It has',
            titleTr: 'He / She / It has',
            model: 'She has finished her homework.',
            avoid: 'She have finished her homework.',
            logicEn: 'Use has with he/she/it.',
            logicTr: 'He/she/it ile has kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Experience question',
            titleTr: 'Deneyim sorusu',
            model: 'Have you ever tried sushi?',
            avoid: 'Did you ever tried sushi?',
            logicEn:
                'Use have/has before the subject in Present Perfect questions.',
            logicTr: 'Present Perfect sorusunda have/has öznenin önüne gelir.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Finished time warning',
            titleTr: 'Bitmiş zaman uyarısı',
            model: 'I visited Istanbul yesterday.',
            avoid: 'I have visited Istanbul yesterday.',
            logicEn: 'Use Past Simple with finished time words like yesterday.',
            logicTr:
                'Yesterday gibi bitmiş zamanlarla Past Simple kullanılır.'),
      ];
    case 'a2_first_conditional':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'If + present simple',
            titleTr: 'If + present simple',
            model: 'If it rains, I will stay at home.',
            avoid: 'If it will rain, I will stay at home.',
            logicEn: 'Do not use will in the if-clause of First Conditional.',
            logicTr: 'First Conditional’da if tarafında will kullanılmaz.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Will + V1 result',
            titleTr: 'Sonuçta will + V1',
            model: 'If I study, I will pass the exam.',
            avoid: 'If I study, I will passes the exam.',
            logicEn: 'The result side uses will + V1.',
            logicTr: 'Sonuç tarafında will + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Possible future',
            titleTr: 'Olası gelecek',
            model: 'If you call me, I will answer.',
            avoid: 'If you call me, I answer yesterday.',
            logicEn: 'First Conditional talks about a real future possibility.',
            logicTr: 'First Conditional gerçekçi gelecek ihtimalini anlatır.'),
      ];

    case 'a1_subject_pronouns':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'I for the speaker',
            titleTr: 'Konuşan kişi için I',
            model: 'I am from Turkey.',
            avoid: 'Me am from Turkey.',
            logicEn: 'Use subject pronouns before the verb.',
            logicTr: 'Subject pronoun fiilden önce özne olarak kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'He / She for people',
            titleTr: 'Kişiler için he / she',
            model: 'She is my teacher.',
            avoid: 'Her is my teacher.',
            logicEn: 'Use she or he as the subject, not object forms.',
            logicTr:
                'Özne yerinde she/he kullanılır, object form kullanılmaz.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'It for one thing',
            titleTr: 'Tek nesne için it',
            model: 'It is a beautiful city.',
            avoid: 'They is a beautiful city.',
            logicEn: 'Use it for one thing, animal, city or idea.',
            logicTr: 'Tek nesne, hayvan, şehir veya fikir için it kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'They for plural',
            titleTr: 'Çoğul için they',
            model: 'They are my classmates.',
            avoid: 'It are my classmates.',
            logicEn: 'Use they for plural people or things.',
            logicTr: 'Çoğul kişi veya şeyler için they kullanılır.'),
      ];
    case 'a1_possessive_adjectives':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'My + noun',
            titleTr: 'My + isim',
            model: 'This is my notebook.',
            avoid: 'This is I notebook.',
            logicEn: 'A possessive adjective comes before a noun.',
            logicTr: 'Possessive adjective isimden önce gelir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'His + noun',
            titleTr: 'His + isim',
            model: 'His car is black.',
            avoid: 'He car is black.',
            logicEn: 'Use his before a noun for a male owner.',
            logicTr: 'Erkek sahiplikte isimden önce his kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Her + noun',
            titleTr: 'Her + isim',
            model: 'Her phone is new.',
            avoid: 'She phone is new.',
            logicEn: 'Use her before a noun for a female owner.',
            logicTr: 'Kadın sahiplikte isimden önce her kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Their + noun',
            titleTr: 'Their + isim',
            model: 'Their teacher is friendly.',
            avoid: 'They teacher is friendly.',
            logicEn: 'Use their before a noun for plural owners.',
            logicTr: 'Çoğul sahiplikte isimden önce their kullanılır.'),
      ];
    case 'a1_singular_plural':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'One thing',
            titleTr: 'Tek şey',
            model: 'I have a book.',
            avoid: 'I have book.',
            logicEn: 'A singular countable noun often needs a/an.',
            logicTr: 'Tekil sayılabilen isim çoğunlukla a/an ister.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Two or more',
            titleTr: 'İki veya daha fazla',
            model: 'I have two books.',
            avoid: 'I have two book.',
            logicEn: 'Use plural nouns after numbers greater than one.',
            logicTr: 'Birden büyük sayılardan sonra çoğul isim kullanılır.'),
        GrammarLogicPoint(
            kind: 'spelling',
            titleEn: 'Add -es',
            titleTr: '-es ekle',
            model: 'There are three boxes.',
            avoid: 'There are three boxs.',
            logicEn: 'Words ending in x, s, sh or ch often take -es.',
            logicTr: 'x, s, sh, ch ile biten kelimeler çoğunlukla -es alır.'),
        GrammarLogicPoint(
            kind: 'irregular',
            titleEn: 'Irregular plural',
            titleTr: 'Düzensiz çoğul',
            model: 'Children are in the garden.',
            avoid: 'Childs are in the garden.',
            logicEn: 'Some plural nouns change irregularly.',
            logicTr: 'Bazı çoğul isimler düzensiz değişir.'),
      ];
    case 'a1_demonstratives':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'This + singular near',
            titleTr: 'Yakın tekil için this',
            model: 'This is my phone.',
            avoid: 'These is my phone.',
            logicEn: 'Use this for one thing near you.',
            logicTr: 'Yakındaki tekil şey için this kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'That + singular far',
            titleTr: 'Uzak tekil için that',
            model: 'That is your bag.',
            avoid: 'Those is your bag.',
            logicEn: 'Use that for one thing far from you.',
            logicTr: 'Uzaktaki tekil şey için that kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'These + plural near',
            titleTr: 'Yakın çoğul için these',
            model: 'These are my keys.',
            avoid: 'This are my keys.',
            logicEn: 'Use these for plural things near you.',
            logicTr: 'Yakındaki çoğullar için these kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Those + plural far',
            titleTr: 'Uzak çoğul için those',
            model: 'Those houses are big.',
            avoid: 'That houses are big.',
            logicEn: 'Use those for plural things far from you.',
            logicTr: 'Uzaktaki çoğullar için those kullanılır.'),
      ];
    case 'a1_have_has_got':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Have got',
            titleTr: 'Have got',
            model: 'I have got a new bag.',
            avoid: 'I has got a new bag.',
            logicEn: 'Use have got with I, you, we and they.',
            logicTr: 'I, you, we, they ile have got kullanılır.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Has got',
            titleTr: 'Has got',
            model: 'She has got a brother.',
            avoid: 'She have got a brother.',
            logicEn: 'Use has got with he, she and it.',
            logicTr: 'He, she, it ile has got kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative possession',
            titleTr: 'Olumsuz sahiplik',
            model: 'He has not got a bike.',
            avoid: 'He have not got a bike.',
            logicEn: 'Negative form keeps the correct have/has form.',
            logicTr: 'Olumsuzda doğru have/has formu korunur.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Have / Has question',
            titleTr: 'Have / Has sorusu',
            model: 'Have you got a computer?',
            avoid: 'Do you have got a computer?',
            logicEn: 'Questions begin with have or has.',
            logicTr: 'Sorular have veya has ile başlar.'),
      ];
    case 'a1_adverbs_frequency':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Before main verb',
            titleTr: 'Ana fiilden önce',
            model: 'I usually watch TV.',
            avoid: 'I watch usually TV.',
            logicEn: 'Frequency adverbs usually come before the main verb.',
            logicTr: 'Frequency adverb genellikle ana fiilden önce gelir.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'After be verb',
            titleTr: 'Be verb sonrası',
            model: 'He is never late.',
            avoid: 'He never is late.',
            logicEn: 'Frequency adverbs usually come after am/is/are.',
            logicTr: 'Frequency adverb genellikle am/is/are sonrasında gelir.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Never is already negative',
            titleTr: 'Never zaten olumsuzdur',
            model: 'She never eats fish.',
            avoid: 'She does not never eat fish.',
            logicEn: 'Do not use double negative with never.',
            logicTr: 'Never ile çift olumsuz yapma.'),
      ];
    case 'a1_present_simple_vs_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Routine',
            titleTr: 'Rutin',
            model: 'I study English every day.',
            avoid: 'I am studying English every day.',
            logicEn: 'Use Present Simple for routines.',
            logicTr: 'Rutinler için Present Simple kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Now',
            titleTr: 'Şu an',
            model: 'I am studying English now.',
            avoid: 'I study English now.',
            logicEn: 'Use Present Continuous for actions happening now.',
            logicTr:
                'Şu anda olan eylemler için Present Continuous kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Ask about now',
            titleTr: 'Şu anı sor',
            model: 'Are you studying now?',
            avoid: 'Do you studying now?',
            logicEn: 'Current actions use be + V-ing in questions.',
            logicTr: 'Şu an olan eylem sorularında be + V-ing kullanılır.'),
      ];
    case 'a1_imperatives':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Base verb command',
            titleTr: 'Yalın fiil ile komut',
            model: 'Open the door.',
            avoid: 'You open the door.',
            logicEn: 'Imperatives usually start with the base verb.',
            logicTr: 'Imperative cümleler genelde yalın fiille başlar.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Do not + V1',
            titleTr: 'Do not + V1',
            model: 'Do not run.',
            avoid: 'Not run.',
            logicEn: 'Negative imperatives use do not before the verb.',
            logicTr: 'Olumsuz imperative için fiilden önce do not kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Polite instruction',
            titleTr: 'Kibar yönerge',
            model: 'Please listen carefully.',
            avoid: 'Please listens carefully.',
            logicEn: 'The verb stays in base form.',
            logicTr: 'Fiil yalın formda kalır.'),
      ];
    case 'a1_object_pronouns':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'After a verb',
            titleTr: 'Fiilden sonra',
            model: 'Call me.',
            avoid: 'Call I.',
            logicEn: 'Use object pronouns after verbs.',
            logicTr: 'Fiillerden sonra object pronoun kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Him / her',
            titleTr: 'Him / her',
            model: 'I like her.',
            avoid: 'I like she.',
            logicEn: 'Use object forms after verbs.',
            logicTr: 'Fiilden sonra object form kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'After prepositions',
            titleTr: 'Edatlardan sonra',
            model: 'Look at them.',
            avoid: 'Look at they.',
            logicEn: 'Use object pronouns after prepositions.',
            logicTr: 'Edatlardan sonra object pronoun kullanılır.'),
      ];
    case 'a1_prepositions_place':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'On a surface',
            titleTr: 'Yüzeyde on',
            model: 'The book is on the table.',
            avoid: 'The book is in the table.',
            logicEn: 'Use on for a surface.',
            logicTr: 'Yüzey üstünde on kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Inside a place',
            titleTr: 'İçinde in',
            model: 'The keys are in the bag.',
            avoid: 'The keys are on the bag.',
            logicEn: 'Use in for inside a space.',
            logicTr: 'Bir alanın içinde in kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Near position',
            titleTr: 'Yakın konum',
            model: 'The chair is next to the desk.',
            avoid: 'The chair is in the desk.',
            logicEn: 'Next to shows a side-by-side position.',
            logicTr: 'Next to yan yana konum gösterir.'),
      ];
    case 'a1_prepositions_time':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'At + time',
            titleTr: 'Saatlerde at',
            model: 'The lesson starts at seven.',
            avoid: 'The lesson starts in seven.',
            logicEn: 'Use at for clock times.',
            logicTr: 'Saatler için at kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'On + day',
            titleTr: 'Günlerde on',
            model: 'We meet on Monday.',
            avoid: 'We meet in Monday.',
            logicEn: 'Use on for days and dates.',
            logicTr: 'Günler ve tarihler için on kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'In + month/year',
            titleTr: 'Ay/yıl için in',
            model: 'My birthday is in June.',
            avoid: 'My birthday is at June.',
            logicEn: 'Use in for months, years and long periods.',
            logicTr: 'Ay, yıl ve uzun dönemlerde in kullanılır.'),
      ];
    case 'a1_some_any':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Some in positive',
            titleTr: 'Olumlu cümlede some',
            model: 'I have some money.',
            avoid: 'I have any money.',
            logicEn: 'Use some in many positive sentences.',
            logicTr: 'Olumlu cümlelerde çoğunlukla some kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Any in questions',
            titleTr: 'Soruda any',
            model: 'Do you have any water?',
            avoid: 'Do you have some water?',
            logicEn: 'Use any in many questions.',
            logicTr: 'Sorularda çoğunlukla any kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Any in negatives',
            titleTr: 'Olumsuzda any',
            model: 'There is not any milk.',
            avoid: 'There is not some milk.',
            logicEn: 'Use any in many negative sentences.',
            logicTr: 'Olumsuz cümlelerde çoğunlukla any kullanılır.'),
      ];
    case 'a1_countable_uncountable':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Countable noun',
            titleTr: 'Sayılabilir isim',
            model: 'I have two apples.',
            avoid: 'I have two apple.',
            logicEn: 'Countable nouns can take plural forms.',
            logicTr: 'Sayılabilir isimler çoğul form alabilir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Uncountable noun',
            titleTr: 'Sayılamaz isim',
            model: 'I need some water.',
            avoid: 'I need a water.',
            logicEn: 'Uncountable nouns usually do not take a/an.',
            logicTr: 'Sayılamaz isimler genelde a/an almaz.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Much with uncountable',
            titleTr: 'Sayılamaz ile much',
            model: 'There is much water.',
            avoid: 'There are many water.',
            logicEn: 'Use much with uncountable nouns.',
            logicTr: 'Sayılamaz isimlerle much kullanılır.'),
      ];
    case 'a1_how_much_many':
      return const [
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'How many + plural',
            titleTr: 'How many + çoğul',
            model: 'How many books do you have?',
            avoid: 'How much books do you have?',
            logicEn: 'Use how many with plural countable nouns.',
            logicTr: 'Çoğul sayılabilir isimlerle how many kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'How much + uncountable',
            titleTr: 'How much + sayılamaz',
            model: 'How much water do you drink?',
            avoid: 'How many water do you drink?',
            logicEn: 'Use how much with uncountable nouns.',
            logicTr: 'Sayılamaz isimlerle how much kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Price question',
            titleTr: 'Fiyat sorusu',
            model: 'How much is this bag?',
            avoid: 'How many is this bag?',
            logicEn: 'Use how much to ask price.',
            logicTr: 'Fiyat sormak için how much kullanılır.'),
      ];
    case 'a1_question_words':
      return const [
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'What for things',
            titleTr: 'Şeyler için what',
            model: 'What is your name?',
            avoid: 'Where is your name?',
            logicEn: 'Use what to ask about things, names or information.',
            logicTr: 'Şeyler, isimler ve bilgi için what kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Where for places',
            titleTr: 'Yerler için where',
            model: 'Where do you live?',
            avoid: 'When do you live?',
            logicEn: 'Use where to ask about places.',
            logicTr: 'Yer sormak için where kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Why for reasons',
            titleTr: 'Sebep için why',
            model: 'Why are you late?',
            avoid: 'Who are you late?',
            logicEn: 'Use why to ask for a reason.',
            logicTr: 'Sebep sormak için why kullanılır.'),
      ];
    case 'a1_possessive_s':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Person + apostrophe s',
            titleTr: 'Kişi + apostrophe s',
            model: 'Ali’s book is on the table.',
            avoid: 'Ali book is on the table.',
            logicEn: 'Use apostrophe s to show possession.',
            logicTr: 'Sahiplik göstermek için apostrophe s kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Family possession',
            titleTr: 'Aile sahipliği',
            model: 'My mother’s phone is new.',
            avoid: 'My mother phone is new.',
            logicEn: 'Use apostrophe s after a singular person or noun.',
            logicTr: 'Tekil kişi veya isimden sonra apostrophe s kullanılır.'),
      ];
    case 'a1_basic_conjunctions':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'And adds information',
            titleTr: 'And bilgi ekler',
            model: 'I like tea and coffee.',
            avoid: 'I like tea but coffee.',
            logicEn: 'Use and to add similar ideas.',
            logicTr: 'Benzer fikirleri eklemek için and kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'But shows contrast',
            titleTr: 'But zıtlık gösterir',
            model: 'I like tea, but I do not like coffee.',
            avoid: 'I like tea because I do not like coffee.',
            logicEn: 'Use but to show contrast.',
            logicTr: 'Zıtlık göstermek için but kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Because gives reason',
            titleTr: 'Because sebep verir',
            model: 'I am tired because I work a lot.',
            avoid: 'I am tired but I work a lot.',
            logicEn: 'Use because to give a reason.',
            logicTr: 'Sebep vermek için because kullanılır.'),
      ];
    case 'a2_superlatives':
      return const [
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'The + -est',
            titleTr: 'The + -est',
            model: 'She is the tallest student in the class.',
            avoid: 'She is tallest student in the class.',
            logicEn: 'Most superlatives need the.',
            logicTr: 'Superlative yapılarda genellikle the gerekir.'),
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'The most + adjective',
            titleTr: 'The most + sıfat',
            model: 'This is the most useful app.',
            avoid: 'This is most useful app.',
            logicEn: 'Use the most with long adjectives.',
            logicTr: 'Uzun sıfatlarda the most kullanılır.'),
        GrammarLogicPoint(
            kind: 'irregular',
            titleEn: 'Irregular superlative',
            titleTr: 'Düzensiz superlative',
            model: 'He is the best player on the team.',
            avoid: 'He is the goodest player on the team.',
            logicEn: 'Good becomes the best.',
            logicTr: 'Good kelimesi the best olur.'),
      ];
    case 'a2_will':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Will + V1',
            titleTr: 'Will + V1',
            model: 'I will help you.',
            avoid: 'I will to help you.',
            logicEn: 'Will is followed directly by V1.',
            logicTr: 'Will sonrasında doğrudan V1 gelir.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Will not / won’t',
            titleTr: 'Will not / won’t',
            model: 'They will not come to the party.',
            avoid: 'They do not will come to the party.',
            logicEn: 'Negative future uses will not or won’t.',
            logicTr: 'Olumsuz future için will not veya won’t kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Will question',
            titleTr: 'Will sorusu',
            model: 'Will you join the lesson?',
            avoid: 'Do you will join the lesson?',
            logicEn: 'Will goes before the subject in questions.',
            logicTr: 'Will soruda öznenin önüne gelir.'),
      ];
    case 'a2_used_to':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Past habit',
            titleTr: 'Geçmiş alışkanlık',
            model: 'I used to play football after school.',
            avoid: 'I use to play football after school.',
            logicEn: 'Used to shows a past habit that is not true now.',
            logicTr:
                'Used to artık geçerli olmayan geçmiş alışkanlığı anlatır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Did not use to',
            titleTr: 'Did not use to',
            model: 'She did not use to live in Ankara.',
            avoid: 'She did not used to live in Ankara.',
            logicEn: 'After did not, use use to, not used to.',
            logicTr: 'Did not sonrası used to değil use to kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Did you use to?',
            titleTr: 'Did you use to?',
            model: 'Did you use to walk to school?',
            avoid: 'Did you used to walk to school?',
            logicEn: 'Questions use did + subject + use to.',
            logicTr: 'Soruda did + özne + use to kullanılır.'),
      ];
    case 'a2_would_like':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Would like + noun',
            titleTr: 'Would like + isim',
            model: 'I would like some tea.',
            avoid: 'I want some tea now please.',
            logicEn: 'Would like sounds polite for requests.',
            logicTr: 'Would like isteklerde daha kibar duyulur.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Would like to + V1',
            titleTr: 'Would like to + V1',
            model: 'I would like to join the class.',
            avoid: 'I would like join the class.',
            logicEn: 'Use to before a verb after would like.',
            logicTr: 'Would like sonrası fiil gelirse to kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Would you like?',
            titleTr: 'Would you like?',
            model: 'Would you like to come with us?',
            avoid: 'Do you would like to come with us?',
            logicEn: 'Questions begin with would.',
            logicTr: 'Sorular would ile başlar.'),
      ];
    case 'a2_gerund_infinitive':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Enjoy + V-ing',
            titleTr: 'Enjoy + V-ing',
            model: 'I enjoy reading books.',
            avoid: 'I enjoy to read books.',
            logicEn: 'Enjoy is followed by V-ing.',
            logicTr: 'Enjoy sonrası V-ing gelir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Want + to V1',
            titleTr: 'Want + to V1',
            model: 'I want to learn English.',
            avoid: 'I want learning English.',
            logicEn: 'Want is followed by to + V1.',
            logicTr: 'Want sonrası to + V1 gelir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Need + to V1',
            titleTr: 'Need + to V1',
            model: 'She needs to study tonight.',
            avoid: 'She needs studying tonight.',
            logicEn: 'Need is commonly followed by to + V1.',
            logicTr: 'Need çoğunlukla to + V1 ile kullanılır.'),
      ];
    case 'a2_relative_clauses_intro':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Who for people',
            titleTr: 'İnsanlar için who',
            model: 'A teacher is a person who helps students.',
            avoid: 'A teacher is a person which helps students.',
            logicEn: 'Use who for people.',
            logicTr: 'İnsanlar için who kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Which for things',
            titleTr: 'Şeyler için which',
            model: 'This is a phone which takes great photos.',
            avoid: 'This is a phone who takes great photos.',
            logicEn: 'Use which for things and ideas.',
            logicTr: 'Şeyler ve fikirler için which kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'That is flexible',
            titleTr: 'That esnektir',
            model: 'This is the book that I bought yesterday.',
            avoid: 'This is the book what I bought yesterday.',
            logicEn:
                'That can refer to people or things in many basic relative clauses.',
            logicTr:
                'That birçok temel relative clause içinde kişi veya şeye gidebilir.'),
      ];
    case 'a2_past_simple_vs_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Background action',
            titleTr: 'Arka plan eylemi',
            model: 'I was studying when the phone rang.',
            avoid: 'I studied when the phone was ringing.',
            logicEn:
                'The longer background action usually uses Past Continuous.',
            logicTr: 'Uzun arka plan eylemi genelde Past Continuous kullanır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Short interrupting action',
            titleTr: 'Kısa araya giren olay',
            model: 'The phone rang while I was studying.',
            avoid: 'The phone was ringing while I studied.',
            logicEn: 'The short interrupting action usually uses Past Simple.',
            logicTr: 'Kısa araya giren olay genelde Past Simple kullanır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'While + continuous',
            titleTr: 'While + continuous',
            model: 'While I was cooking, she was studying.',
            avoid: 'While I cooked, she studied now.',
            logicEn: 'While often introduces actions in progress.',
            logicTr: 'While çoğunlukla devam eden eylemleri tanıtır.'),
      ];
    case 'a2_present_perfect_vs_past_simple':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Experience without exact time',
            titleTr: 'Net zaman yoksa deneyim',
            model: 'I have visited Ankara.',
            avoid: 'I visited Ankara before in life.',
            logicEn:
                'Use Present Perfect when the exact finished time is not important.',
            logicTr:
                'Net bitmiş zaman önemli değilse Present Perfect kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Finished time',
            titleTr: 'Bitmiş zaman',
            model: 'I visited Ankara last year.',
            avoid: 'I have visited Ankara last year.',
            logicEn: 'Use Past Simple with finished time expressions.',
            logicTr: 'Bitmiş zaman ifadeleriyle Past Simple kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Ever question',
            titleTr: 'Ever sorusu',
            model: 'Have you ever been to Ankara?',
            avoid: 'Did you ever been to Ankara?',
            logicEn: 'Experience questions often use have/has + ever + V3.',
            logicTr:
                'Deneyim soruları çoğunlukla have/has + ever + V3 ile kurulur.'),
      ];
    case 'a2_quantifiers':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Many + plural countable',
            titleTr: 'Many + çoğul sayılabilir',
            model: 'There are many students in the room.',
            avoid: 'There is many students in the room.',
            logicEn: 'Many goes with plural countable nouns.',
            logicTr: 'Many çoğul sayılabilir isimlerle kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Much + uncountable',
            titleTr: 'Much + sayılamaz',
            model: 'There is much water in the bottle.',
            avoid: 'There are much water in the bottle.',
            logicEn: 'Much goes with uncountable nouns.',
            logicTr: 'Much sayılamaz isimlerle kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'A few / a little',
            titleTr: 'A few / a little',
            model: 'I have a few friends here.',
            avoid: 'I have a little friends here.',
            logicEn: 'Use a few with plural countable nouns.',
            logicTr: 'A few çoğul sayılabilir isimlerle kullanılır.'),
      ];
    case 'a2_so_such':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'So + adjective',
            titleTr: 'So + sıfat',
            model: 'It is so cold today.',
            avoid: 'It is such cold today.',
            logicEn: 'Use so directly before an adjective or adverb.',
            logicTr: 'So doğrudan sıfat veya zarf öncesinde kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Such + noun phrase',
            titleTr: 'Such + isim grubu',
            model: 'It is such a cold day.',
            avoid: 'It is so a cold day.',
            logicEn: 'Use such before a noun phrase.',
            logicTr: 'Such isim grubundan önce kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Such + adjective + noun',
            titleTr: 'Such + sıfat + isim',
            model: 'She is such a kind teacher.',
            avoid: 'She is so kind teacher.',
            logicEn: 'Use such a/an before adjective + singular noun.',
            logicTr: 'Sıfat + tekil isimden önce such a/an kullanılır.'),
      ];
    case 'a2_zero_conditional':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'If + present, present',
            titleTr: 'If + present, present',
            model: 'If you heat water, it boils.',
            avoid: 'If you heat water, it will boil.',
            logicEn:
                'Zero Conditional uses present simple on both sides for general truths.',
            logicTr:
                'Zero Conditional genel gerçeklerde iki tarafta da Present Simple kullanır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Rules and facts',
            titleTr: 'Kurallar ve gerçekler',
            model: 'If people eat too much, they gain weight.',
            avoid: 'If people will eat too much, they gain weight.',
            logicEn: 'Use it for facts that are generally true.',
            logicTr: 'Genel doğru olan gerçekler için kullanılır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'When also works',
            titleTr: 'When de kullanılabilir',
            model: 'When ice melts, it becomes water.',
            avoid: 'When ice will melt, it becomes water.',
            logicEn: 'When can replace if for regular results.',
            logicTr: 'Düzenli sonuçlarda when, if yerine kullanılabilir.'),
      ];
    case 'a2_may_might':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'May / might + V1',
            titleTr: 'May / might + V1',
            model: 'It might rain later.',
            avoid: 'It might rains later.',
            logicEn: 'After may or might, the main verb stays V1.',
            logicTr: 'May veya might sonrasında ana fiil V1 kalır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Uncertain possibility',
            titleTr: 'Belirsiz olasılık',
            model: 'She may join us.',
            avoid: 'She may joins us.',
            logicEn: 'May and might show possibility, not certainty.',
            logicTr: 'May ve might kesinlik değil olasılık gösterir.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'May not / might not',
            titleTr: 'May not / might not',
            model: 'He might not come.',
            avoid: 'He might does not come.',
            logicEn: 'Negative form is may not or might not + V1.',
            logicTr: 'Olumsuz yapı may not veya might not + V1 şeklindedir.'),
      ];
    case 'a2_present_continuous_future':
      return const [
        GrammarLogicPoint(
            kind: 'future',
            titleEn: 'Fixed future arrangement',
            titleTr: 'Planlanmış gelecek düzenleme',
            model: 'I am meeting my friend tomorrow.',
            avoid: 'I meet my friend tomorrow now.',
            logicEn:
                'Present Continuous can show a fixed personal arrangement.',
            logicTr:
                'Present Continuous planlanmış kişisel gelecek düzenlemeyi anlatabilir.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'am/is/are + V-ing',
            titleTr: 'am/is/are + V-ing',
            model: 'She is flying to Ankara on Friday.',
            avoid: 'She flying to Ankara on Friday.',
            logicEn: 'Future arrangements still need am/is/are + V-ing.',
            logicTr: 'Gelecek düzenlemelerde de am/is/are + V-ing gerekir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Arrangement question',
            titleTr: 'Düzenleme sorusu',
            model: 'Are you working tomorrow?',
            avoid: 'Do you working tomorrow?',
            logicEn: 'Use am/is/are before the subject in questions.',
            logicTr: 'Soruda am/is/are öznenin önüne gelir.'),
      ];
    case 'b1_present_perfect_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'duration',
            titleEn: 'have/has been + V-ing',
            titleTr: 'have/has been + V-ing',
            model: 'I have been studying for two hours.',
            avoid: 'I have studying for two hours.',
            logicEn: 'Use have/has been + V-ing for ongoing duration.',
            logicTr: 'Devam eden süre için have/has been + V-ing kullanılır.')
      ];
    case 'b1_past_perfect_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'duration',
            titleEn: 'had been + V-ing',
            titleTr: 'had been + V-ing',
            model: 'She had been working for hours before she rested.',
            avoid: 'She had working for hours before she rested.',
            logicEn: 'Use had been + V-ing for duration before a past point.',
            logicTr:
                'Geçmişteki bir noktadan önceki süre için had been + V-ing kullanılır.')
      ];
    case 'b1_future_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'future',
            titleEn: 'will be + V-ing',
            titleTr: 'will be + V-ing',
            model: 'I will be studying at 8 tonight.',
            avoid: 'I will studying at 8 tonight.',
            logicEn: 'Future Continuous uses will be + V-ing.',
            logicTr: 'Future Continuous will be + V-ing ile kurulur.')
      ];
    case 'b1_future_perfect_intro':
      return const [
        GrammarLogicPoint(
            kind: 'future',
            titleEn: 'will have + V3',
            titleTr: 'will have + V3',
            model: 'I will have finished by 8.',
            avoid: 'I will finish by 8 already.',
            logicEn: 'Future Perfect shows completion before a future time.',
            logicTr:
                'Future Perfect gelecekteki bir zamandan önce tamamlanmayı gösterir.')
      ];
    case 'b2_modal_perfects':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'modal + have + V3',
            titleTr: 'modal + have + V3',
            model: 'You should have called me.',
            avoid: 'You should called me.',
            logicEn: 'Modal perfect uses modal + have + V3.',
            logicTr: 'Modal perfect modal + have + V3 ile kurulur.')
      ];
    case 'b2_advanced_quantifiers':
      return const [
        GrammarLogicPoint(
            kind: 'quantity',
            titleEn: 'Precise quantity expression',
            titleTr: 'Net miktar ifadesi',
            model: 'Hardly any students missed the exam.',
            avoid: 'Hardly students missed the exam.',
            logicEn: 'Advanced quantifiers make quantity precise.',
            logicTr: 'İleri quantifierlar miktarı daha net yapar.')
      ];
    case 'b2_formal_comparisons':
      return const [
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'The more..., the more...',
            titleTr: 'The more..., the more...',
            model: 'The more you practise, the better you become.',
            avoid: 'More you practise, better you become.',
            logicEn: 'Formal parallel comparison uses the + comparative twice.',
            logicTr:
                'Resmi paralel karşılaştırmada iki tarafta da the + comparative kullanılır.')
      ];

    case 'b1_present_perfect':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Experience without exact time',
            titleTr: 'Net zaman yoksa deneyim',
            model: 'I have visited Poland.',
            avoid: 'I visited Poland before in my life.',
            logicEn:
                'Use Present Perfect for life experience when the exact finished time is not the focus.',
            logicTr:
                'Net bitmiş zaman önemli değilse hayat deneyimi için Present Perfect kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Never + V3',
            titleTr: 'Never + V3',
            model: 'She has never tried sushi.',
            avoid: 'She never tried sushi in her life.',
            logicEn:
                'Never is common with Present Perfect for life experience.',
            logicTr:
                'Hayat deneyiminde never, Present Perfect ile çok kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Have you ever...?',
            titleTr: 'Have you ever...?',
            model: 'Have you ever been abroad?',
            avoid: 'Did you ever been abroad?',
            logicEn:
                'Use Have/Has + subject + ever + V3 for experience questions.',
            logicTr:
                'Deneyim sorularında Have/Has + özne + ever + V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Unfinished time',
            titleTr: 'Bitmemiş zaman',
            model: 'I have studied a lot this week.',
            avoid: 'I studied a lot this week.',
            logicEn:
                'This week can be unfinished, so Present Perfect can connect the action to now.',
            logicTr:
                'This week hâlâ bitmemiş olabilir; Present Perfect olayı şimdiye bağlar.'),
      ];
    case 'b1_present_perfect_vs_past':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'No exact time',
            titleTr: 'Net zaman yok',
            model: 'I have seen that film before.',
            avoid: 'I saw that film before without context.',
            logicEn:
                'Use Present Perfect when the experience matters more than the exact time.',
            logicTr:
                'Net zaman değil deneyim önemliyse Present Perfect kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Finished time',
            titleTr: 'Bitmiş zaman',
            model: 'I saw that film yesterday.',
            avoid: 'I have seen that film yesterday.',
            logicEn:
                'Use Past Simple with finished time expressions like yesterday or last year.',
            logicTr:
                'Yesterday, last year gibi bitmiş zamanlarda Past Simple kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Experience question',
            titleTr: 'Deneyim sorusu',
            model: 'Have you ever visited Ankara?',
            avoid: 'Did you ever visited Ankara?',
            logicEn:
                'Ever questions about experience usually use Present Perfect.',
            logicTr:
                'Ever ile deneyim soruları çoğunlukla Present Perfect kullanır.'),
      ];
    case 'b1_first_conditional':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Real future condition',
            titleTr: 'Gerçekçi gelecek şartı',
            model: 'If it rains, I will stay at home.',
            avoid: 'If it will rain, I will stay at home.',
            logicEn:
                'Use Present Simple in the if-clause and will in the result clause.',
            logicTr:
                'If tarafında Present Simple, sonuç tarafında will kullanılır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Result first',
            titleTr: 'Sonuç başta',
            model: 'I will call you if I arrive early.',
            avoid: 'I will call you if I will arrive early.',
            logicEn:
                'The order can change, but the if-clause still uses Present Simple.',
            logicTr:
                'Sıra değişebilir ama if tarafı yine Present Simple kalır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative condition',
            titleTr: 'Olumsuz şart',
            model: 'If you do not study, you will fail.',
            avoid: 'If you will not study, you will fail.',
            logicEn: 'Negative if-clauses also use Present Simple.',
            logicTr: 'Olumsuz if cümlelerinde de Present Simple kullanılır.'),
      ];
    case 'b1_passive_voice':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Present passive',
            titleTr: 'Present passive',
            model: 'The room is cleaned every day.',
            avoid: 'The room cleaned every day.',
            logicEn:
                'Use be + V3 when the action is more important than the doer.',
            logicTr: 'Eylemi yapan değil eylem önemliyse be + V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Past passive',
            titleTr: 'Past passive',
            model: 'The room was cleaned yesterday.',
            avoid: 'The room is cleaned yesterday.',
            logicEn:
                'Change the be verb according to the tense: is cleaned, was cleaned.',
            logicTr: 'Zamana göre be değişir: is cleaned, was cleaned.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Passive negative',
            titleTr: 'Passive olumsuz',
            model: 'The door is not locked at night.',
            avoid: 'The door does not locked at night.',
            logicEn: 'Put not after the be verb in passive negatives.',
            logicTr: 'Passive olumsuzda not, be fiilinden sonra gelir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Passive question',
            titleTr: 'Passive soru',
            model: 'Is the office cleaned every day?',
            avoid: 'Does the office cleaned every day?',
            logicEn: 'Passive questions move the be verb before the subject.',
            logicTr: 'Passive soruda be fiili öznenin önüne gelir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'By phrase',
            titleTr: 'By kullanımı',
            model: 'The song was written by a young artist.',
            avoid: 'The song wrote by a young artist.',
            logicEn: 'Use by when the doer is important enough to mention.',
            logicTr: 'Yapan kişiyi belirtmek gerekiyorsa by kullanılır.'),
      ];
    case 'b1_modal_verbs':
    case 'b1_modals':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Advice',
            titleTr: 'Tavsiye',
            model: 'You should rest after the lesson.',
            avoid: 'You should to rest after the lesson.',
            logicEn: 'Modal verbs are followed by the base verb.',
            logicTr: 'Modal fiillerden sonra fiil yalın halde gelir.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Obligation',
            titleTr: 'Zorunluluk',
            model: 'You must be careful in traffic.',
            avoid: 'You must to be careful in traffic.',
            logicEn: 'Must does not take to before the verb.',
            logicTr: 'Must sonrasında to kullanılmaz.'),
        GrammarLogicPoint(
            kind: 'possibility',
            titleEn: 'Possibility',
            titleTr: 'Olasılık',
            model: 'It might rain after school.',
            avoid: 'It might rains after school.',
            logicEn:
                'Might shows possibility and the following verb stays in base form.',
            logicTr: 'Might olasılık verir ve sonrasındaki fiil yalın kalır.'),
        GrammarLogicPoint(
            kind: 'necessity',
            titleEn: 'Have to',
            titleTr: 'Have to',
            model: 'She has to submit the report today.',
            avoid: 'She has submit the report today.',
            logicEn: 'Have to / has to shows external necessity.',
            logicTr: 'Have to / has to dıştan gelen gerekliliği anlatır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'No -s after modal',
            titleTr: 'Modal sonrası -s yok',
            model: 'She must finish the report.',
            avoid: 'She must finishes the report.',
            logicEn:
                'The verb after a modal does not take -s even with he/she/it.',
            logicTr: 'Modal sonrası fiil he/she/it ile bile -s almaz.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Modal question',
            titleTr: 'Modal soru',
            model: 'Should I call the manager?',
            avoid: 'Do I should call the manager?',
            logicEn: 'Modal questions start with the modal verb.',
            logicTr: 'Modal soruları modal fiil ile başlar.'),
      ];
    case 'b1_past_perfect':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Earlier past action',
            titleTr: 'Daha önceki geçmiş olay',
            model: 'She had left before I arrived.',
            avoid: 'She left before I had arrived.',
            logicEn:
                'Past Perfect shows the action that happened earlier than another past action.',
            logicTr:
                'Past Perfect, başka bir geçmiş olaydan daha önce olan eylemi gösterir.'),
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Had + V3',
            titleTr: 'Had + V3',
            model: 'I had finished my homework by eight.',
            avoid: 'I had finish my homework by eight.',
            logicEn: 'Past Perfect uses had + V3 for all subjects.',
            logicTr: 'Past Perfect tüm öznelerde had + V3 kullanır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Had not + V3',
            titleTr: 'Had not + V3',
            model: 'They had not eaten before the meeting.',
            avoid: 'They did not had eaten before the meeting.',
            logicEn: 'Negative Past Perfect uses had not + V3.',
            logicTr: 'Past Perfect olumsuzda had not + V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Had + subject + V3?',
            titleTr: 'Had + özne + V3?',
            model: 'Had you seen the message before class?',
            avoid: 'Did you had seen the message before class?',
            logicEn: 'Past Perfect questions begin with had.',
            logicTr: 'Past Perfect soruları had ile başlar.'),
      ];
    case 'b1_second_conditional':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Unreal present/future',
            titleTr: 'Gerçek dışı şimdi/gelecek',
            model: 'If I had more time, I would travel more.',
            avoid: 'If I have more time, I would travel more.',
            logicEn:
                'Use If + Past Simple, would + V1 for unreal or unlikely situations.',
            logicTr:
                'Gerçek dışı/olası olmayan durumlarda If + Past Simple, would + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Would + V1',
            titleTr: 'Would + V1',
            model: 'I would buy a car if I had enough money.',
            avoid: 'I would bought a car if I had enough money.',
            logicEn: 'Would is followed by the base verb.',
            logicTr: 'Would sonrasında fiil yalın halde gelir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'What would you do?',
            titleTr: 'What would you do?',
            model: 'What would you do if you won the lottery?',
            avoid: 'What do you do if you would win the lottery?',
            logicEn:
                'Second Conditional questions keep would in the result question.',
            logicTr:
                'Second Conditional sorularında sonuç tarafında would kullanılır.'),
      ];
    case 'b1_reported_speech_intro':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Present to past',
            titleTr: 'Present geçmişe kayar',
            model: 'She said that she was tired.',
            avoid: 'She said that she is tired.',
            logicEn:
                'When the reporting verb is past, the reported tense often shifts back.',
            logicTr:
                'Reporting verb geçmişse aktarılan zaman çoğu zaman geriye kayar.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Will to would',
            titleTr: 'Will, would olur',
            model: 'He said that he would call me.',
            avoid: 'He said that he will call me.',
            logicEn: 'Will often changes to would in reported speech.',
            logicTr: 'Reported speech içinde will çoğunlukla would olur.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Reported question order',
            titleTr: 'Aktarılan soruda düz sıra',
            model: 'She asked where I lived.',
            avoid: 'She asked where did I live.',
            logicEn: 'Reported questions use statement word order.',
            logicTr: 'Aktarılan sorularda düz cümle sırası kullanılır.'),
      ];
    case 'b1_relative_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Who for people',
            titleTr: 'İnsanlar için who',
            model: 'A teacher is a person who helps students.',
            avoid: 'A teacher is a person which helps students.',
            logicEn: 'Use who for people in relative clauses.',
            logicTr: 'Relative clause içinde insanlar için who kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Which for things',
            titleTr: 'Şeyler için which',
            model: 'This is the app which helps me study.',
            avoid: 'This is the app who helps me study.',
            logicEn: 'Use which for things or ideas.',
            logicTr: 'Şeyler ve fikirler için which kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'That is flexible',
            titleTr: 'That esnek kullanılır',
            model: 'This is the book that I bought yesterday.',
            avoid: 'This is the book what I bought yesterday.',
            logicEn:
                'That can refer to people or things in many defining clauses.',
            logicTr:
                'That birçok defining relative clause içinde insan/şey için kullanılabilir.'),
      ];
    case 'b1_used_to_would':
      return const [
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Used to for past habit',
            titleTr: 'Geçmiş alışkanlık için used to',
            model: 'I used to play football after school.',
            avoid: 'I use to play football after school.',
            logicEn:
                'Used to shows a past habit or state that is not true now.',
            logicTr:
                'Used to, artık doğru olmayan geçmiş alışkanlık/durum anlatır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Would for repeated past actions',
            titleTr: 'Tekrarlanan geçmiş eylem için would',
            model:
                'When I was a child, I would visit my grandparents every summer.',
            avoid: 'When I was a child, I would be shy.',
            logicEn:
                'Would works for repeated past actions, not usually for past states.',
            logicTr:
                'Would tekrarlanan geçmiş eylemlerde olur; durumlarda genelde kullanılmaz.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Did + use to',
            titleTr: 'Did + use to',
            model: 'Did you use to live in Ankara?',
            avoid: 'Did you used to live in Ankara?',
            logicEn: 'After did, use the base form: use to.',
            logicTr: 'Did sonrasında base form gelir: use to.'),
      ];

    case 'b2_third_conditional':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Unreal past condition',
            titleTr: 'Gerçekleşmemiş geçmiş şart',
            model: 'If I had studied harder, I would have passed the exam.',
            avoid: 'If I studied harder, I would have passed the exam.',
            logicEn:
                'Use If + Past Perfect, would have + V3 for unreal past results.',
            logicTr:
                'Geçmişte gerçekleşmemiş durumlar için If + Past Perfect, would have + V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Would have + V3',
            titleTr: 'Would have + V3',
            model: 'She would have called you if she had had time.',
            avoid: 'She would called you if she had had time.',
            logicEn: 'The result side needs would have + V3.',
            logicTr: 'Sonuç tarafında would have + V3 gerekir.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative result',
            titleTr: 'Olumsuz sonuç',
            model:
                'They would not have missed the train if they had left earlier.',
            avoid: 'They would not missed the train if they had left earlier.',
            logicEn: 'Negative third conditional keeps have before V3.',
            logicTr:
                'Olumsuz third conditional yapısında V3 öncesinde have kalır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Third conditional question',
            titleTr: 'Third conditional sorusu',
            model: 'What would you have done if you had seen the accident?',
            avoid: 'What would you did if you had seen the accident?',
            logicEn: 'Questions still use would have + V3 for the result idea.',
            logicTr:
                'Soru yapısında da sonuç fikri would have + V3 ile kurulur.'),
      ];
    case 'b2_mixed_conditionals':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Past cause, present result',
            titleTr: 'Geçmiş sebep, şimdiki sonuç',
            model: 'If I had slept earlier, I would feel better now.',
            avoid: 'If I slept earlier, I would feel better now.',
            logicEn:
                'Use Past Perfect in the if-clause when a past action affects the present.',
            logicTr:
                'Geçmişteki eylem bugünü etkiliyorsa if tarafında Past Perfect kullanılır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Present condition, past result',
            titleTr: 'Şimdiki durum, geçmiş sonuç',
            model:
                'If she were more careful, she would not have made that mistake.',
            avoid:
                'If she is more careful, she would not have made that mistake.',
            logicEn: 'A present character/situation can explain a past result.',
            logicTr: 'Şimdiki özellik veya durum geçmiş sonucu açıklayabilir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Time contrast',
            titleTr: 'Zaman karşıtlığı',
            model: 'If I knew French, I would have applied for that job.',
            avoid:
                'If I had known French now, I would have applied for that job.',
            logicEn: 'Mixed conditionals combine different time meanings.',
            logicTr: 'Mixed conditional farklı zaman anlamlarını birleştirir.'),
      ];
    case 'b2_modal_deduction':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Must for strong deduction',
            titleTr: 'Güçlü çıkarım için must',
            model: 'She must be at home; the lights are on.',
            avoid: 'She must to be at home; the lights are on.',
            logicEn: 'Use must + V1 for a strong present deduction.',
            logicTr: 'Güçlü şimdiki çıkarım için must + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Can’t for impossible idea',
            titleTr: 'İmkânsız fikir için can’t',
            model: 'He can’t be the manager; he is too young.',
            avoid: 'He doesn’t can be the manager; he is too young.',
            logicEn: 'Use can’t + V1 when you believe something is impossible.',
            logicTr:
                'Bir şeyin imkânsız olduğunu düşünüyorsan can’t + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Might / could for possibility',
            titleTr: 'Olasılık için might / could',
            model: 'They might be stuck in traffic.',
            avoid: 'They might stuck in traffic.',
            logicEn: 'Might and could show weaker possibility.',
            logicTr: 'Might ve could daha zayıf olasılık bildirir.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Past deduction',
            titleTr: 'Geçmiş çıkarım',
            model: 'She must have forgotten the meeting.',
            avoid: 'She must forgot the meeting.',
            logicEn: 'For past deduction, use modal + have + V3.',
            logicTr: 'Geçmiş çıkarım için modal + have + V3 kullanılır.'),
      ];
    case 'b2_advanced_passive':
      return const [
        GrammarLogicPoint(
            kind: 'positive',
            titleEn: 'Modal passive',
            titleTr: 'Modal passive',
            model: 'The report must be finished today.',
            avoid: 'The report must finish today.',
            logicEn: 'Modal passive uses modal + be + V3.',
            logicTr: 'Modal passive yapısı modal + be + V3 şeklindedir.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Perfect passive',
            titleTr: 'Perfect passive',
            model: 'The documents have been sent.',
            avoid: 'The documents have sent.',
            logicEn: 'Perfect passive uses have/has been + V3.',
            logicTr: 'Perfect passive have/has been + V3 ile kurulur.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Agent unknown',
            titleTr: 'Yapan kişi bilinmiyor',
            model: 'My bike was stolen last night.',
            avoid: 'My bike stole last night.',
            logicEn: 'Use passive when the doer is unknown or unimportant.',
            logicTr:
                'Yapan kişi bilinmiyor veya önemsizse passive kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Passive question',
            titleTr: 'Passive soru',
            model: 'Has the email been sent?',
            avoid: 'Has the email sent?',
            logicEn: 'Keep been in perfect passive questions.',
            logicTr: 'Perfect passive sorularda been korunur.'),
      ];
    case 'b2_reported_speech_advanced':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Tense backshift',
            titleTr: 'Zaman geriye kayması',
            model: 'He said that he had finished the project.',
            avoid: 'He said that he finished the project already.',
            logicEn:
                'Past reporting verbs often push the reported tense one step back.',
            logicTr:
                'Reporting verb geçmişse aktarılan zaman çoğunlukla bir adım geriye kayar.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Reported question',
            titleTr: 'Aktarılan soru',
            model: 'She asked me where I had been.',
            avoid: 'She asked me where had I been.',
            logicEn: 'Reported questions use statement word order.',
            logicTr: 'Aktarılan sorularda düz cümle sırası kullanılır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Modal backshift',
            titleTr: 'Modal geriye kayması',
            model: 'He said he could help me.',
            avoid: 'He said he can help me yesterday.',
            logicEn: 'Can often changes to could in reported speech.',
            logicTr: 'Reported speech içinde can çoğunlukla could olur.'),
      ];
    case 'b2_non_defining_relative_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Extra information with commas',
            titleTr: 'Virgülle ekstra bilgi',
            model: 'My brother, who lives in Ankara, is a doctor.',
            avoid: 'My brother which lives in Ankara is a doctor.',
            logicEn:
                'Non-defining relative clauses add extra information and use commas.',
            logicTr:
                'Non-defining relative clause ekstra bilgi verir ve virgül kullanır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Which for whole idea',
            titleTr: 'Bütün fikir için which',
            model: 'He arrived late, which annoyed everyone.',
            avoid: 'He arrived late, what annoyed everyone.',
            logicEn: 'Use which to refer to a whole previous idea.',
            logicTr:
                'Önceki bütün fikre gönderme yapmak için which kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'No that in non-defining',
            titleTr: 'Non-defining içinde that yok',
            model: 'My car, which is very old, still works.',
            avoid: 'My car, that is very old, still works.',
            logicEn: 'Do not use that in non-defining relative clauses.',
            logicTr: 'Non-defining relative clause içinde that kullanılmaz.'),
      ];
    case 'b2_causative_have_get':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Have something done',
            titleTr: 'Have something done',
            model: 'I had my car repaired yesterday.',
            avoid: 'I repaired my car yesterday by a mechanic.',
            logicEn:
                'Use have + object + V3 when someone does a service for you.',
            logicTr:
                'Bir hizmeti başkasına yaptırdığında have + object + V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Get something done',
            titleTr: 'Get something done',
            model: 'She got her hair cut.',
            avoid: 'She got her hair cutted.',
            logicEn: 'Get + object + V3 is common in informal speech.',
            logicTr: 'Get + object + V3 günlük konuşmada yaygındır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Causative question',
            titleTr: 'Causative soru',
            model: 'Where did you have your phone repaired?',
            avoid: 'Where did you have repaired your phone?',
            logicEn: 'Keep the object before V3 in causative questions.',
            logicTr: 'Causative soruda object, V3 öncesinde kalır.'),
      ];
    case 'b2_wish_if_only':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Wish + Past Simple',
            titleTr: 'Wish + Past Simple',
            model: 'I wish I had more free time.',
            avoid: 'I wish I have more free time.',
            logicEn:
                'Use Past Simple after wish for an unreal present situation.',
            logicTr:
                'Şimdiki gerçek dışı durum için wish sonrası Past Simple kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Wish + Past Perfect',
            titleTr: 'Wish + Past Perfect',
            model: 'I wish I had studied harder.',
            avoid: 'I wish I studied harder yesterday.',
            logicEn: 'Use Past Perfect after wish for regret about the past.',
            logicTr:
                'Geçmiş pişmanlık için wish sonrası Past Perfect kullanılır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Wish + would',
            titleTr: 'Wish + would',
            model: 'I wish he would stop shouting.',
            avoid: 'I wish he stops shouting.',
            logicEn:
                'Use wish + would for annoying repeated behavior or desired change.',
            logicTr:
                'Rahatsız eden tekrarlar veya değişim isteği için wish + would kullanılır.'),
      ];
    case 'b2_participle_clauses_intro':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Reduced active clause',
            titleTr: 'Kısaltılmış active clause',
            model: 'Walking down the street, I saw an old friend.',
            avoid: 'Walked down the street, I saw an old friend.',
            logicEn: 'Use V-ing when the reduced clause has an active meaning.',
            logicTr: 'Kısaltılmış clause active anlamdaysa V-ing kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Reduced passive clause',
            titleTr: 'Kısaltılmış passive clause',
            model: 'Built in 1900, the house is still beautiful.',
            avoid: 'Building in 1900, the house is still beautiful.',
            logicEn: 'Use V3 when the reduced clause has a passive meaning.',
            logicTr: 'Kısaltılmış clause passive anlamdaysa V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Perfect participle',
            titleTr: 'Perfect participle',
            model: 'Having finished the work, she went home.',
            avoid: 'Having finish the work, she went home.',
            logicEn:
                'Having + V3 shows the first action was completed earlier.',
            logicTr:
                'Having + V3 ilk eylemin daha önce tamamlandığını gösterir.'),
      ];

    case 'c1_cleft_sentences':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'It-cleft for focus',
            titleTr: 'Odak için it-cleft',
            model: 'It was my brother who called you.',
            avoid: 'It was my brother which called you.',
            logicEn:
                'Use it was + focused person + who to emphasize the person.',
            logicTr: 'Kişiyi vurgulamak için it was + kişi + who kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'What-cleft',
            titleTr: 'What-cleft',
            model: 'What I need is more time.',
            avoid: 'What I need are more time.',
            logicEn:
                'What-clefts focus attention on the important idea after be.',
            logicTr:
                'What-cleft yapıları dikkati be sonrasındaki önemli fikre çeker.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'The thing is',
            titleTr: 'The thing is',
            model: 'The thing I like most is the design.',
            avoid: 'The thing what I like most is the design.',
            logicEn:
                'The thing + clause can be used to introduce a focused idea.',
            logicTr:
                'The thing + clause odaklanmış fikri tanıtmak için kullanılabilir.'),
      ];
    case 'c1_emphasis_do':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Emphatic do',
            titleTr: 'Vurgulu do',
            model: 'I do understand your point.',
            avoid: 'I am understand your point.',
            logicEn:
                'Use do/does/did before V1 to add emphasis in positive sentences.',
            logicTr: 'Olumlu cümlede vurgu için do/does/did + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Does for third person',
            titleTr: 'Üçüncü tekil için does',
            model: 'She does care about the result.',
            avoid: 'She do care about the result.',
            logicEn: 'Use does for he, she, it in emphatic present sentences.',
            logicTr:
                'Vurgulu present cümlede he, she, it ile does kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Did for past emphasis',
            titleTr: 'Geçmiş vurgu için did',
            model: 'He did tell me the truth.',
            avoid: 'He did told me the truth.',
            logicEn: 'After emphatic did, the main verb stays V1.',
            logicTr: 'Vurgulu did sonrasında ana fiil V1 kalır.'),
      ];
    case 'c1_advanced_modality':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Should have + V3',
            titleTr: 'Should have + V3',
            model: 'You should have told me earlier.',
            avoid: 'You should told me earlier.',
            logicEn: 'Use should have + V3 for past criticism or regret.',
            logicTr:
                'Geçmiş eleştiri veya pişmanlık için should have + V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Need not have + V3',
            titleTr: 'Need not have + V3',
            model: 'You need not have bought so much food.',
            avoid: 'You need not bought so much food.',
            logicEn:
                'Need not have + V3 means the action was unnecessary, but it happened.',
            logicTr:
                'Need not have + V3, eylemin gereksiz olduğunu ama yapıldığını anlatır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Could have + V3',
            titleTr: 'Could have + V3',
            model: 'We could have taken a taxi.',
            avoid: 'We could took a taxi.',
            logicEn:
                'Could have + V3 shows a past possibility that did not happen.',
            logicTr:
                'Could have + V3 geçmişte gerçekleşmemiş olasılığı gösterir.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'Might well',
            titleTr: 'Might well',
            model: 'This decision might well change the result.',
            avoid: 'This decision might to change the result.',
            logicEn: 'Might well expresses a fairly strong possibility.',
            logicTr: 'Might well oldukça güçlü bir olasılık anlatır.'),
      ];
    case 'c1_advanced_linkers':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Despite + noun / V-ing',
            titleTr: 'Despite + isim / V-ing',
            model: 'Despite feeling tired, she finished the report.',
            avoid: 'Despite she felt tired, she finished the report.',
            logicEn:
                'Despite is followed by a noun phrase or V-ing, not a full clause.',
            logicTr:
                'Despite sonrasında tam cümle değil isim grubu veya V-ing gelir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Although + clause',
            titleTr: 'Although + cümle',
            model: 'Although she felt tired, she finished the report.',
            avoid: 'Although feeling tired, she finished the report.',
            logicEn: 'Although is followed by a subject and verb clause.',
            logicTr: 'Although sonrasında özne + fiil içeren cümle gelir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Nevertheless as contrast',
            titleTr: 'Zıtlık için nevertheless',
            model:
                'The task was difficult. Nevertheless, we completed it on time.',
            avoid:
                'The task was difficult. Therefore, it was easy for us to complete on time.',
            logicEn:
                'Nevertheless usually links two ideas with clear punctuation.',
            logicTr:
                'Nevertheless iki fikri genellikle net noktalama ile bağlar.'),
      ];
    case 'c1_noun_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'That-clause as subject',
            titleTr: 'Özne olarak that-clause',
            model: 'That he lied is obvious.',
            avoid: 'That he lied are obvious.',
            logicEn: 'A that-clause can act as a singular subject.',
            logicTr: 'That-clause tekil özne gibi davranabilir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Whether clause',
            titleTr: 'Whether clause',
            model: 'Whether we succeed depends on our preparation.',
            avoid: 'If we succeed depends on our preparation.',
            logicEn: 'Use whether, not if, when the clause is the subject.',
            logicTr: 'Clause özne görevindeyse if yerine whether kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'The fact that',
            titleTr: 'The fact that',
            model: 'The fact that he apologized changed everything.',
            avoid: 'The fact he apologized changed everything.',
            logicEn: 'The fact that introduces a whole idea as a noun phrase.',
            logicTr: 'The fact that bütün fikri isim grubu gibi tanıtır.'),
      ];
    case 'c1_reduced_relative_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Active reduction with V-ing',
            titleTr: 'V-ing ile active kısaltma',
            model: 'The woman speaking to Tom is my manager.',
            avoid: 'The woman spoken to Tom is my manager.',
            logicEn: 'Use V-ing when the reduced relative clause is active.',
            logicTr:
                'Kısaltılmış relative clause active anlamdaysa V-ing kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Passive reduction with V3',
            titleTr: 'V3 ile passive kısaltma',
            model: 'The emails sent yesterday were important.',
            avoid: 'The emails sending yesterday were important.',
            logicEn: 'Use V3 when the reduced relative clause is passive.',
            logicTr:
                'Kısaltılmış relative clause passive anlamdaysa V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'To-infinitive reduction',
            titleTr: 'To-infinitive kısaltma',
            model: 'She was the first person to arrive.',
            avoid: 'She was the first person arriving.',
            logicEn: 'After first, next and last, to + V1 is often used.',
            logicTr:
                'First, next ve last sonrasında çoğunlukla to + V1 kullanılır.'),
      ];

    case 'b2_future_perfect':
      return const [
        GrammarLogicPoint(
            kind: 'form',
            titleEn: 'will have + V3',
            titleTr: 'will have + V3',
            model: 'By Friday, I will have finished the report.',
            avoid: 'By Friday, I will have finish the report.',
            logicEn:
                'Future Perfect shows that an action will be completed before a future point.',
            logicTr:
                'Future Perfect, bir eylemin gelecekteki bir noktadan önce tamamlanmış olacağını gösterir.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'by + future time',
            titleTr: 'by + gelecek zaman',
            model: 'By 2028, I will have graduated from university.',
            avoid: 'By 2028, I will graduate from university already.',
            logicEn:
                'By marks the future deadline before which the action is complete.',
            logicTr:
                'By, eylemin tamamlanmış olacağı gelecek sınırı gösterir.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Negative form',
            titleTr: 'Olumsuz yapı',
            model: 'She will not have completed the task by noon.',
            avoid: 'She will not have complete the task by noon.',
            logicEn: 'In negative form, keep have + V3 after will not.',
            logicTr: 'Olumsuz yapıda will not sonrasında have + V3 korunur.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            model: 'Will you have finished by 8?',
            avoid: 'Will you finished by 8?',
            logicEn: 'Questions use Will + subject + have + V3.',
            logicTr: 'Soru yapısı Will + özne + have + V3 şeklindedir.'),
      ];
    case 'b2_future_perfect_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'form',
            titleEn: 'will have been + V-ing',
            titleTr: 'will have been + V-ing',
            model: 'By June, I will have been working here for two years.',
            avoid: 'By June, I will have working here for two years.',
            logicEn:
                'Future Perfect Continuous emphasizes duration up to a future point.',
            logicTr:
                'Future Perfect Continuous, gelecekteki bir noktaya kadar sürecek süreyi vurgular.'),
        GrammarLogicPoint(
            kind: 'duration',
            titleEn: 'for / since',
            titleTr: 'for / since',
            model: 'By then, she will have been studying for three hours.',
            avoid:
                'By then, she will have studied for three hours and still be studying.',
            logicEn:
                'For and since help show the duration continuing up to the future point.',
            logicTr:
                'For ve since, sürenin gelecek noktaya kadar devam ettiğini gösterir.'),
        GrammarLogicPoint(
            kind: 'future point',
            titleEn: 'By + future time',
            titleTr: 'By + gelecek zaman',
            model: 'By Friday, they will have been training for a month.',
            avoid: 'By Friday, they will train for a month.',
            logicEn:
                'By introduces the future point used to measure the duration.',
            logicTr: 'By, sürenin ölçüldüğü gelecek noktayı gösterir.'),
        GrammarLogicPoint(
            kind: 'ongoing emphasis',
            titleEn: 'Still continuing',
            titleTr: 'Hâlâ devam eden süreç',
            model: 'Next week, we will have been living here for a year.',
            avoid: 'Next week, we will live here for a year.',
            logicEn:
                'The continuous form suggests the activity continues up to that future time.',
            logicTr:
                'Continuous yapı eylemin o gelecek zamana kadar sürdüğünü vurgular.'),
      ];
    case 'b2_inversion_intro':
    case 'c1_full_inversion':
    case 'c1_inversion':
      return const [
        GrammarLogicPoint(
            kind: 'form',
            titleEn: 'Negative adverbial inversion',
            titleTr: 'Olumsuz zarfla inversion',
            model: 'Never have I seen a clearer explanation.',
            avoid: 'Never I have seen a clearer explanation.',
            logicEn:
                'After negative adverbials, use auxiliary + subject + verb.',
            logicTr:
                'Olumsuz zarf başa gelince yardımcı fiil + özne + fiil sırası kullanılır.'),
        GrammarLogicPoint(
            kind: 'form',
            titleEn: 'Only then / Only later',
            titleTr: 'Only then / Only later',
            model: 'Only then did I understand the problem.',
            avoid: 'Only then I understood the problem.',
            logicEn:
                'Only + time expression often triggers inversion in formal English.',
            logicTr:
                'Only + zaman ifadesi resmi İngilizcede çoğunlukla inversion ister.'),
        GrammarLogicPoint(
            kind: 'form',
            titleEn: 'Not only',
            titleTr: 'Not only',
            model: 'Not only did she apologize, but she also offered to help.',
            avoid: 'Not only she apologized, but she also offered to help.',
            logicEn: 'Not only at the beginning needs auxiliary inversion.',
            logicTr:
                'Not only cümle başındaysa yardımcı fiil inversion kullanılır.'),
      ];
    case 'c2_nominalisation':
    case 'academic_nominalisation':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Development as a noun phrase',
            titleTr: 'İsim grubu olarak development',
            model: 'The rapid development of the service surprised investors.',
            avoid: 'The service developed rapid surprised investors.',
            logicEn:
                'Nominalisation turns actions into compact noun phrases for academic style.',
            logicTr:
                'Nominalisation, eylemleri akademik tarzda yoğun isim gruplarına çevirir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Implementation as academic focus',
            titleTr: 'Akademik odak olarak implementation',
            model: 'The implementation of the policy reduced costs.',
            avoid: 'The policy implemented reduced costs.',
            logicEn:
                'Use a noun phrase when the action itself is the focus of the sentence.',
            logicTr: 'Eylemin kendisi odaktaysa isim grubu kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Failure / analysis as noun forms',
            titleTr: 'İsim formu olarak failure / analysis',
            model: 'The failure of the system required further analysis.',
            avoid: 'The system failed required further analyze.',
            logicEn:
                'Academic writing often uses noun forms such as failure and analysis to compress ideas.',
            logicTr:
                'Akademik yazıda failure ve analysis gibi isim formları fikirleri yoğunlaştırır.'),
      ];
    case 'c2_hedging_academic_caution':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'It appears that',
            titleTr: 'It appears that',
            model: 'It appears that the policy has reduced costs.',
            avoid: 'The policy definitely reduced costs.',
            logicEn:
                'Academic hedging avoids overclaiming when evidence is limited.',
            logicTr:
                'Akademik hedging, kanıt sınırlıyken aşırı kesin iddiadan kaçınır.'),
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'May well',
            titleTr: 'May well',
            model: 'This trend may well continue next year.',
            avoid: 'This trend may to continue next year.',
            logicEn:
                'May well expresses a fairly strong but cautious possibility.',
            logicTr: 'May well güçlü ama temkinli olasılık anlatır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Tends to',
            titleTr: 'Tends to',
            model: 'Online feedback tends to improve learner motivation.',
            avoid: 'Online feedback tends improve learner motivation.',
            logicEn:
                'Tend to + V1 generalizes carefully without sounding absolute.',
            logicTr: 'Tend to + V1 kesin konuşmadan genelleme yapar.'),
      ];
    case 'c2_ellipsis_substitution':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'So as substitution',
            titleTr: 'So ile substitution',
            model: 'I think so.',
            avoid: 'I think it.',
            logicEn:
                'So can replace a whole previous idea after verbs like think, hope and believe.',
            logicTr:
                'So; think, hope, believe gibi fiillerden sonra önceki fikrin yerini alabilir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Do so',
            titleTr: 'Do so',
            model: 'The company reduced prices and will continue to do so.',
            avoid: 'The company reduced prices and will continue to do it.',
            logicEn: 'Do so replaces a repeated action in formal style.',
            logicTr:
                'Do so resmi dilde tekrar eden eylemin yerine kullanılır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Auxiliary ellipsis',
            titleTr: 'Yardımcı fiil eksiltme',
            model: 'Some students passed the exam, but others did not.',
            avoid: 'Some students passed the exam, but others did not passed.',
            logicEn:
                'After an auxiliary substitute, do not repeat the main verb form incorrectly.',
            logicTr:
                'Yardımcı fiilden sonra ana fiili yanlış biçimde tekrar etme.'),
      ];
    case 'c2_fronting_information_flow':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Place fronting',
            titleTr: 'Yer ifadesini başa alma',
            model: 'At the end of the corridor stood a small wooden door.',
            avoid: 'At the end of the corridor a small wooden door stood.',
            logicEn:
                'Fronting can make descriptions more literary and control information flow.',
            logicTr:
                'Fronting betimlemeyi daha edebi yapar ve bilgi akışını kontrol eder.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Object fronting',
            titleTr: 'Nesneyi başa alma',
            model: 'This problem we cannot ignore.',
            avoid: 'This problem cannot ignore we.',
            logicEn:
                'Fronted objects are possible for emphasis, but the clause grammar must stay correct.',
            logicTr:
                'Vurgu için nesne başa alınabilir ama cümle grameri doğru kalmalı.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'What matters is',
            titleTr: 'What matters is',
            model: 'What matters most is how clearly we explain the result.',
            avoid: 'What matters most are how clearly we explain the result.',
            logicEn:
                'Use a focused noun-clause opening to organize complex ideas.',
            logicTr:
                'Karmaşık fikirleri düzenlemek için odaklı noun-clause başlangıcı kullan.'),
      ];
    case 'c2_advanced_conditionals':
    case 'c2_advanced_conditional_alternatives':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Were it not for',
            titleTr: 'Were it not for',
            model: 'Were it not for your help, we would have failed.',
            avoid: 'Were it not for your help, we will have failed.',
            logicEn:
                'Were it not for is a formal alternative to if it were not for.',
            logicTr:
                'Were it not for, if it were not for yapısının resmi alternatifidir.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Had it not been for',
            titleTr: 'Had it not been for',
            model:
                'Had it not been for the delay, we would have arrived on time.',
            avoid: 'Had it not been for the delay, we would arrive on time.',
            logicEn:
                'Use had it not been for + would have + V3 for unreal past conditions.',
            logicTr:
                'Geçmiş gerçek dışı koşul için had it not been for + would have + V3 kullan.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Should you need',
            titleTr: 'Should you need',
            model: 'Should you need further details, please contact me.',
            avoid: 'Should you needed further details, please contact me.',
            logicEn: 'Should + subject + V1 is a formal conditional opening.',
            logicTr: 'Should + özne + V1 resmi conditional başlangıcıdır.'),
      ];
    case 'c2_discourse_markers':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'That said',
            titleTr: 'That said',
            model:
                'The plan is risky. That said, it could bring major benefits.',
            avoid: 'The plan is risky. Moreover, it is also dangerous.',
            logicEn:
                'That said introduces contrast and needs clear punctuation.',
            logicTr: 'That said zıtlık getirir ve net noktalama ister.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Be that as it may',
            titleTr: 'Be that as it may',
            model: 'Be that as it may, we still need a practical solution.',
            avoid: 'Be that it may, we still need a practical solution.',
            logicEn: 'Be that as it may is a fixed formal concession phrase.',
            logicTr:
                'Be that as it may kalıplaşmış resmi concession ifadesidir.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'For that matter',
            titleTr: 'For that matter',
            model: 'No one checked the data, or the sources for that matter.',
            avoid: 'No one checked the data, or the sources for that matters.',
            logicEn:
                'For that matter adds a related point to strengthen the argument.',
            logicTr:
                'For that matter argümanı güçlendiren bağlantılı bir nokta ekler.'),
      ];
    case 'c2_register_and_style':
      return const [
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Formal alternative',
            titleTr: 'Resmi alternatif',
            model: 'I would be grateful if you could send the documents.',
            avoid: 'Send me the documents.',
            logicEn: 'Formal register often uses indirect, polite structures.',
            logicTr:
                'Resmi register çoğu zaman dolaylı ve kibar yapılar kullanır.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Concise academic style',
            titleTr: 'Yoğun akademik tarz',
            model: 'The findings highlight the need for further research.',
            avoid: 'The findings show that we need to research more and more.',
            logicEn:
                'Academic style prefers precise nouns and compact wording.',
            logicTr:
                'Akademik tarz net isimleri ve yoğun ifadeyi tercih eder.'),
        GrammarLogicPoint(
            kind: 'usage',
            titleEn: 'Avoid over-personal style',
            titleTr: 'Aşırı kişisel tarzdan kaçın',
            model: 'This essay argues that technology shapes learning.',
            avoid:
                'I will talk about how technology is really cool for learning.',
            logicEn:
                'Formal writing focuses on the argument, not casual personal framing.',
            logicTr:
                'Resmi yazı gündelik kişisel çerçeveye değil argümana odaklanır.'),
      ];
  }
  return const [];
}

List<GrammarLogicPoint> _phase189Blueprint(String key) {
  switch (key) {
    case 'b1_present_perfect_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'duration',
            titleEn: 'have / has been + V-ing',
            titleTr: 'have / has been + V-ing',
            model: 'I have been studying for two hours.',
            avoid: 'I have studying for two hours.',
            logicEn:
                'Use have or has been + V-ing to show an action that started in the past and is still continuing.',
            logicTr:
                'Geçmişte başlayıp hâlâ süren eylem için have/has been + V-ing kullanılır.'),
        GrammarLogicPoint(
            kind: 'duration',
            titleEn: 'For + duration',
            titleTr: 'For + süre',
            model: 'She has been working here for three years.',
            avoid:
                'She has worked here for three years and she is working now.',
            logicEn: 'For shows the length of the continuing action.',
            logicTr: 'For, devam eden eylemin süresini gösterir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'How long question',
            titleTr: 'How long sorusu',
            model: 'How long have you been learning English?',
            avoid: 'How long do you learning English?',
            logicEn:
                'How long questions often use Present Perfect Continuous for ongoing actions.',
            logicTr:
                'How long soruları devam eden eylemlerde çoğunlukla Present Perfect Continuous kullanır.'),
      ];
    case 'b1_past_perfect_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'duration',
            titleEn: 'had been + V-ing',
            titleTr: 'had been + V-ing',
            model: 'She had been working for hours before she rested.',
            avoid: 'She had working for hours before she rested.',
            logicEn:
                'Use had been + V-ing for duration before another past event.',
            logicTr:
                'Başka bir geçmiş olaydan önce süren eylem için had been + V-ing kullanılır.'),
        GrammarLogicPoint(
            kind: 'cause',
            titleEn: 'Past result',
            titleTr: 'Geçmiş sonuç',
            model: 'He was tired because he had been running.',
            avoid: 'He was tired because he had running.',
            logicEn:
                'Past Perfect Continuous can explain the reason for a past result.',
            logicTr:
                'Past Perfect Continuous geçmişteki bir sonucun sebebini açıklayabilir.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'Before a past point',
            titleTr: 'Geçmiş noktadan önce',
            model: 'They had been waiting for an hour when the bus arrived.',
            avoid: 'They had waited for an hour when the bus was arriving.',
            logicEn: 'The duration happened before a later past event.',
            logicTr: 'Süre, daha sonraki bir geçmiş olaydan önce gerçekleşir.'),
      ];
    case 'b1_future_continuous':
      return const [
        GrammarLogicPoint(
            kind: 'future',
            titleEn: 'will be + V-ing',
            titleTr: 'will be + V-ing',
            model: 'I will be studying at 8 tonight.',
            avoid: 'I will studying at 8 tonight.',
            logicEn:
                'Future Continuous uses will be + V-ing for an action in progress at a future time.',
            logicTr:
                'Gelecekte belli bir anda devam eden eylem için will be + V-ing kullanılır.'),
        GrammarLogicPoint(
            kind: 'time',
            titleEn: 'At a future moment',
            titleTr: 'Gelecekte bir anda',
            model: 'This time tomorrow, we will be flying to London.',
            avoid: 'This time tomorrow, we will fly to London already.',
            logicEn: 'Use it to place the listener inside a future moment.',
            logicTr:
                'Dinleyiciyi gelecekteki bir anın içine yerleştirmek için kullanılır.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Question form',
            titleTr: 'Soru yapısı',
            model: 'Will you be working tomorrow morning?',
            avoid: 'Will you working tomorrow morning?',
            logicEn: 'Questions use Will + subject + be + V-ing.',
            logicTr: 'Soruda Will + özne + be + V-ing kullanılır.'),
      ];
    case 'b1_future_perfect_intro':
      return const [
        GrammarLogicPoint(
            kind: 'future',
            titleEn: 'will have + V3',
            titleTr: 'will have + V3',
            model: 'I will have finished by 8.',
            avoid: 'I will finish by 8 already.',
            logicEn: 'Future Perfect shows completion before a future time.',
            logicTr:
                'Future Perfect gelecekteki bir zamandan önce tamamlanmayı gösterir.'),
        GrammarLogicPoint(
            kind: 'deadline',
            titleEn: 'By + future time',
            titleTr: 'By + gelecek zaman',
            model: 'By next month, she will have moved to Ankara.',
            avoid: 'By next month, she will move to Ankara already.',
            logicEn: 'By marks the future deadline before completion.',
            logicTr: 'By, tamamlanmadan önceki gelecek son noktayı gösterir.'),
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Will + subject + have + V3',
            titleTr: 'Will + özne + have + V3',
            model: 'Will they have arrived by noon?',
            avoid: 'Will they arrived by noon?',
            logicEn:
                'Future Perfect questions keep have + V3 after the subject.',
            logicTr:
                'Future Perfect sorularında özne sonrasında have + V3 korunur.'),
      ];
    case 'b1_passive_voice_by_tense':
      return const [
        GrammarLogicPoint(
            kind: 'present',
            titleEn: 'Present passive',
            titleTr: 'Present passive',
            model: 'The rooms are cleaned every morning.',
            avoid: 'The rooms clean every morning.',
            logicEn: 'Present passive uses am/is/are + V3.',
            logicTr: 'Present passive am/is/are + V3 ile kurulur.'),
        GrammarLogicPoint(
            kind: 'past',
            titleEn: 'Past passive',
            titleTr: 'Past passive',
            model: 'The letter was sent yesterday.',
            avoid: 'The letter sent yesterday.',
            logicEn: 'Past passive uses was/were + V3.',
            logicTr: 'Past passive was/were + V3 ile kurulur.'),
        GrammarLogicPoint(
            kind: 'future',
            titleEn: 'Future passive',
            titleTr: 'Future passive',
            model: 'The results will be announced tomorrow.',
            avoid: 'The results will announce tomorrow.',
            logicEn: 'Future passive uses will be + V3.',
            logicTr: 'Future passive will be + V3 ile kurulur.'),
      ];
    case 'b1_reported_questions':
      return const [
        GrammarLogicPoint(
            kind: 'question',
            titleEn: 'Statement word order',
            titleTr: 'Düz cümle sırası',
            model: 'She asked where I lived.',
            avoid: 'She asked where did I live.',
            logicEn: 'Reported questions use statement word order.',
            logicTr: 'Aktarılan sorularda düz cümle sırası kullanılır.'),
        GrammarLogicPoint(
            kind: 'yes-no',
            titleEn: 'If / whether',
            titleTr: 'If / whether',
            model: 'He asked if I was ready.',
            avoid: 'He asked was I ready.',
            logicEn: 'Use if or whether for yes/no reported questions.',
            logicTr:
                'Yes/no reported question için if veya whether kullanılır.'),
        GrammarLogicPoint(
            kind: 'tense',
            titleEn: 'Backshift',
            titleTr: 'Zaman kayması',
            model: 'They asked what I had done.',
            avoid: 'They asked what had I done.',
            logicEn: 'The question form becomes an embedded statement.',
            logicTr: 'Soru yapısı iç içe düz cümleye dönüşür.'),
      ];
    case 'b1_reported_commands':
      return const [
        GrammarLogicPoint(
            kind: 'command',
            titleEn: 'Told + object + to',
            titleTr: 'Told + nesne + to',
            model: 'The teacher told us to be quiet.',
            avoid: 'The teacher told us be quiet.',
            logicEn: 'Reported commands use told + object + to + V1.',
            logicTr: 'Aktarılan emirlerde told + nesne + to + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'negative',
            titleEn: 'Told + object + not to',
            titleTr: 'Told + nesne + not to',
            model: 'She told me not to wait.',
            avoid: 'She told me to not waited.',
            logicEn: 'Negative reported commands use not to + V1.',
            logicTr: 'Olumsuz aktarılan emirlerde not to + V1 kullanılır.'),
        GrammarLogicPoint(
            kind: 'request',
            titleEn: 'Asked + object + to',
            titleTr: 'Asked + nesne + to',
            model: 'He asked me to call him later.',
            avoid: 'He asked me call him later.',
            logicEn: 'Reported requests often use asked + object + to + V1.',
            logicTr:
                'Aktarılan ricalarda asked + nesne + to + V1 sık kullanılır.'),
      ];
    case 'b1_defining_relative_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'people',
            titleEn: 'Who for people',
            titleTr: 'İnsanlar için who',
            model: 'A doctor is a person who helps sick people.',
            avoid: 'A doctor is a person which helps sick people.',
            logicEn: 'Use who for people in defining relative clauses.',
            logicTr:
                'Defining relative clause içinde insanlar için who kullanılır.'),
        GrammarLogicPoint(
            kind: 'things',
            titleEn: 'Which / that for things',
            titleTr: 'Şeyler için which / that',
            model: 'This is the book that I bought yesterday.',
            avoid: 'This is the book what I bought yesterday.',
            logicEn: 'Use which or that for things.',
            logicTr: 'Şeyler için which veya that kullanılır.'),
        GrammarLogicPoint(
            kind: 'essential',
            titleEn: 'Essential information',
            titleTr: 'Gerekli bilgi',
            model: 'The student who studies regularly usually improves.',
            avoid: 'The student studies regularly who usually improves.',
            logicEn:
                'The relative clause identifies which person or thing we mean.',
            logicTr:
                'Relative clause hangi kişi veya şeyi kastettiğimizi belirler.'),
      ];
    case 'b1_non_defining_relative_intro':
      return const [
        GrammarLogicPoint(
            kind: 'extra',
            titleEn: 'Extra information with commas',
            titleTr: 'Virgülle ekstra bilgi',
            model: 'My brother, who lives in Izmir, is a doctor.',
            avoid: 'My brother which lives in Izmir is a doctor.',
            logicEn:
                'Non-defining clauses add extra information and need commas.',
            logicTr: 'Non-defining clause ekstra bilgi ekler ve virgül ister.'),
        GrammarLogicPoint(
            kind: 'thing',
            titleEn: 'Which for a thing',
            titleTr: 'Şeyler için which',
            model: 'My phone, which I bought last year, still works well.',
            avoid: 'My phone, that I bought last year, still works well.',
            logicEn: 'Use which, not that, in many non-defining clauses.',
            logicTr:
                'Non-defining clause içinde çoğu zaman that yerine which kullanılır.'),
        GrammarLogicPoint(
            kind: 'extra',
            titleEn: 'Not essential',
            titleTr: 'Zorunlu değil',
            model:
                'Ankara, which is the capital of Turkey, is an important city.',
            avoid:
                'Ankara, that is the capital of Turkey, is an important city.',
            logicEn:
                'The extra information can be removed without losing the main idea.',
            logicTr: 'Ekstra bilgi çıkarılsa da ana fikir kalır.'),
      ];
    case 'b1_gerund_vs_infinitive':
      return const [
        GrammarLogicPoint(
            kind: 'gerund',
            titleEn: 'Enjoy + V-ing',
            titleTr: 'Enjoy + V-ing',
            model: 'I enjoy reading novels.',
            avoid: 'I enjoy to read novels.',
            logicEn: 'Some verbs are followed by a gerund.',
            logicTr: 'Bazı fiillerden sonra gerund gelir.'),
        GrammarLogicPoint(
            kind: 'infinitive',
            titleEn: 'Want + to V1',
            titleTr: 'Want + to V1',
            model: 'She wants to study abroad.',
            avoid: 'She wants studying abroad.',
            logicEn: 'Some verbs are followed by to + V1.',
            logicTr: 'Bazı fiillerden sonra to + V1 gelir.'),
        GrammarLogicPoint(
            kind: 'meaning',
            titleEn: 'Different pattern',
            titleTr: 'Farklı kalıp',
            model: 'We decided to leave early.',
            avoid: 'We decided leaving early.',
            logicEn:
                'The verb before the pattern decides whether gerund or infinitive is needed.',
            logicTr:
                'Gerund veya infinitive gerekip gerekmediğini önceki fiil belirler.'),
      ];
    case 'b1_used_to_be_used_to_get_used_to':
      return const [
        GrammarLogicPoint(
            kind: 'past',
            titleEn: 'Used to + V1',
            titleTr: 'Used to + V1',
            model: 'I used to live in a small town.',
            avoid: 'I used to living in a small town.',
            logicEn: 'Used to + V1 describes a past habit or state.',
            logicTr: 'Used to + V1 geçmiş alışkanlık veya durum anlatır.'),
        GrammarLogicPoint(
            kind: 'familiarity',
            titleEn: 'Be used to + V-ing',
            titleTr: 'Be used to + V-ing',
            model: 'I am used to waking up early.',
            avoid: 'I am used to wake up early.',
            logicEn:
                'Be used to means be familiar with something and takes V-ing or a noun.',
            logicTr:
                'Be used to alışık olmak demektir ve V-ing veya isim alır.'),
        GrammarLogicPoint(
            kind: 'change',
            titleEn: 'Get used to + V-ing',
            titleTr: 'Get used to + V-ing',
            model: 'She is getting used to living alone.',
            avoid: 'She is getting used to live alone.',
            logicEn: 'Get used to shows the process of becoming familiar.',
            logicTr: 'Get used to alışma sürecini gösterir.'),
      ];
    case 'b1_question_tags_indirect_questions':
      return const [
        GrammarLogicPoint(
            kind: 'tag',
            titleEn: 'Positive sentence, negative tag',
            titleTr: 'Olumlu cümle, olumsuz tag',
            model: 'You are coming, are you not?',
            avoid: 'You are coming, are you?',
            logicEn: 'A positive statement usually takes a negative tag.',
            logicTr: 'Olumlu cümle genelde olumsuz tag alır.'),
        GrammarLogicPoint(
            kind: 'tag',
            titleEn: 'Negative sentence, positive tag',
            titleTr: 'Olumsuz cümle, olumlu tag',
            model: 'She does not like coffee, does she?',
            avoid: 'She does not like coffee, does not she?',
            logicEn: 'A negative statement usually takes a positive tag.',
            logicTr: 'Olumsuz cümle genelde olumlu tag alır.'),
        GrammarLogicPoint(
            kind: 'indirect',
            titleEn: 'Indirect question order',
            titleTr: 'Dolaylı soru sırası',
            model: 'Could you tell me where the station is?',
            avoid: 'Could you tell me where is the station?',
            logicEn: 'Indirect questions use statement word order.',
            logicTr: 'Dolaylı sorularda düz cümle sırası kullanılır.'),
      ];

    case 'b2_advanced_gerund_infinitive':
      return const [
        GrammarLogicPoint(
            kind: 'gerund',
            titleEn: 'Risk + V-ing',
            titleTr: 'Risk + V-ing',
            model: 'They risked losing the contract.',
            avoid: 'They risked to lose the contract.',
            logicEn: 'Some advanced verbs are followed by a gerund.',
            logicTr: 'Bazı ileri seviye fiillerden sonra gerund gelir.'),
        GrammarLogicPoint(
            kind: 'infinitive',
            titleEn: 'Manage + to V1',
            titleTr: 'Manage + to V1',
            model: 'She managed to finish the report.',
            avoid: 'She managed finishing the report.',
            logicEn: 'Manage is followed by to + V1.',
            logicTr: 'Manage fiilinden sonra to + V1 gelir.'),
        GrammarLogicPoint(
            kind: 'meaning',
            titleEn: 'Remember doing / to do',
            titleTr: 'Remember doing / to do',
            model: 'I remember meeting him last year.',
            avoid: 'I remember to meet him last year.',
            logicEn:
                'Some verbs change meaning depending on gerund or infinitive.',
            logicTr:
                'Bazı fiiller gerund veya infinitive ile anlam değiştirir.'),
      ];
    case 'b2_passive_reporting':
      return const [
        GrammarLogicPoint(
            kind: 'reporting',
            titleEn: 'It is said that',
            titleTr: 'It is said that',
            model: 'It is said that the company is growing.',
            avoid: 'It says that the company is growing.',
            logicEn: 'Passive reporting makes the source impersonal.',
            logicTr:
                'Passive reporting kaynağı daha nesnel ve resmi gösterir.'),
        GrammarLogicPoint(
            kind: 'reporting',
            titleEn: 'Subject + is believed to',
            titleTr: 'Özne + is believed to',
            model: 'The suspect is believed to be abroad.',
            avoid: 'The suspect believes to be abroad.',
            logicEn: 'Use subject + passive reporting verb + to-infinitive.',
            logicTr:
                'Özne + passive reporting verb + to-infinitive kullanılır.'),
        GrammarLogicPoint(
            kind: 'perfect',
            titleEn: 'Perfect infinitive',
            titleTr: 'Perfect infinitive',
            model: 'He is thought to have left the country.',
            avoid: 'He is thought to left the country.',
            logicEn: 'Use to have + V3 when the reported action is earlier.',
            logicTr: 'Aktarılan eylem daha önceyse to have + V3 kullanılır.'),
      ];
    case 'b2_complex_relative_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'relative',
            titleEn: 'Preposition + which',
            titleTr: 'Preposition + which',
            model: 'This is the issue about which we spoke yesterday.',
            avoid: 'This is the issue about that we spoke yesterday.',
            logicEn:
                'Formal relative clauses can place the preposition before which.',
            logicTr:
                'Resmi relative clause içinde preposition which önüne gelebilir.'),
        GrammarLogicPoint(
            kind: 'possessive',
            titleEn: 'Whose',
            titleTr: 'Whose',
            model: 'The writer whose book won the prize gave a speech.',
            avoid: 'The writer who book won the prize gave a speech.',
            logicEn: 'Whose shows possession inside a relative clause.',
            logicTr: 'Whose relative clause içinde sahiplik gösterir.'),
        GrammarLogicPoint(
            kind: 'clause',
            titleEn: 'Whole-clause which',
            titleTr: 'Tüm cümleye gönderme',
            model: 'He ignored the warning, which surprised everyone.',
            avoid: 'He ignored the warning, what surprised everyone.',
            logicEn: 'Which can refer to a whole previous clause.',
            logicTr: 'Which önceki tüm cümleye gönderme yapabilir.'),
      ];
    case 'b2_emphasis_structures':
      return const [
        GrammarLogicPoint(
            kind: 'emphasis',
            titleEn: 'What-clause emphasis',
            titleTr: 'What-clause vurgusu',
            model: 'What I need is more time.',
            avoid: 'What I need are more time.',
            logicEn:
                'What-clauses can focus the important part of the sentence.',
            logicTr: 'What-clause cümlenin önemli kısmını öne çıkarır.'),
        GrammarLogicPoint(
            kind: 'cleft',
            titleEn: 'It was... that',
            titleTr: 'It was... that',
            model: 'It was the delay that caused the problem.',
            avoid: 'It was the delay caused the problem.',
            logicEn: 'Cleft structures split the sentence to create emphasis.',
            logicTr: 'Cleft yapı cümleyi bölerek vurgu oluşturur.'),
        GrammarLogicPoint(
            kind: 'do',
            titleEn: 'Do for emphasis',
            titleTr: 'Vurgu için do',
            model: 'I do understand your concern.',
            avoid: 'I am understand your concern.',
            logicEn: 'Do can emphasize a positive statement.',
            logicTr: 'Do olumlu cümleyi vurgulamak için kullanılabilir.'),
      ];
    case 'b2_advanced_linking_devices':
      return const [
        GrammarLogicPoint(
            kind: 'contrast',
            titleEn: 'Nevertheless',
            titleTr: 'Nevertheless',
            model: 'The task was difficult. Nevertheless, we completed it.',
            avoid: 'The task was difficult. Therefore, it was easy for us.',
            logicEn: 'Advanced linkers need clear punctuation and logic.',
            logicTr: 'İleri linkerlar net noktalama ve mantık ilişkisi ister.'),
        GrammarLogicPoint(
            kind: 'addition',
            titleEn: 'Moreover',
            titleTr: 'Moreover',
            model: 'The course is practical. Moreover, it is affordable.',
            avoid:
                'The course is practical. Nevertheless, it is also practical.',
            logicEn: 'Moreover adds a second supporting point.',
            logicTr: 'Moreover ikinci destekleyici fikri ekler.'),
        GrammarLogicPoint(
            kind: 'result',
            titleEn: 'Therefore',
            titleTr: 'Therefore',
            model: 'The evidence was weak. Therefore, the claim was rejected.',
            avoid: 'The evidence was weak. Moreover, the claim was rejected.',
            logicEn: 'Therefore introduces a result or conclusion.',
            logicTr: 'Therefore sonuç veya çıkarım verir.'),
      ];
    case 'b2_concession_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'concession',
            titleEn: 'Although + clause',
            titleTr: 'Although + cümle',
            model: 'Although it was expensive, we bought it.',
            avoid: 'Although it was expensive, but we bought it.',
            logicEn: 'Do not use although and but for the same contrast.',
            logicTr: 'Aynı zıtlık için although ve but birlikte kullanılmaz.'),
        GrammarLogicPoint(
            kind: 'concession',
            titleEn: 'Despite + noun / V-ing',
            titleTr: 'Despite + isim / V-ing',
            model: 'Despite feeling tired, she kept working.',
            avoid: 'Despite she felt tired, she kept working.',
            logicEn:
                'Despite is followed by a noun phrase or V-ing, not a full clause.',
            logicTr:
                'Despite sonrasında tam cümle değil isim grubu veya V-ing gelir.'),
        GrammarLogicPoint(
            kind: 'concession',
            titleEn: 'Even though + clause',
            titleTr: 'Even though + cümle',
            model: 'Even though he was nervous, he spoke clearly.',
            avoid: 'Even though nervous, he spoke clearly.',
            logicEn: 'Even though is followed by a subject and verb.',
            logicTr: 'Even though sonrasında özne ve fiil gelir.'),
      ];
    case 'b2_purpose_result_reason_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'purpose',
            titleEn: 'So that + clause',
            titleTr: 'So that + cümle',
            model: 'I left early so that I could catch the bus.',
            avoid: 'I left early so that to catch the bus.',
            logicEn: 'So that is followed by a clause with subject and verb.',
            logicTr: 'So that sonrasında özne ve fiilli cümle gelir.'),
        GrammarLogicPoint(
            kind: 'purpose',
            titleEn: 'In order to + V1',
            titleTr: 'In order to + V1',
            model: 'She studied hard in order to pass the exam.',
            avoid: 'She studied hard in order passing the exam.',
            logicEn: 'In order to is followed by the base verb.',
            logicTr: 'In order to sonrasında fiil yalın gelir.'),
        GrammarLogicPoint(
            kind: 'reason',
            titleEn: 'Because of + noun',
            titleTr: 'Because of + isim',
            model: 'The match was cancelled because of the rain.',
            avoid: 'The match was cancelled because of it rained.',
            logicEn: 'Because of takes a noun phrase, not a full clause.',
            logicTr: 'Because of tam cümle değil isim grubu alır.'),
      ];
    case 'b2_modal_perfects':
      return const [
        GrammarLogicPoint(
            kind: 'modal',
            titleEn: 'should have + V3',
            titleTr: 'should have + V3',
            model: 'You should have called me.',
            avoid: 'You should called me.',
            logicEn: 'Use should have + V3 for past criticism or regret.',
            logicTr:
                'Geçmiş eleştiri veya pişmanlık için should have + V3 kullanılır.'),
        GrammarLogicPoint(
            kind: 'deduction',
            titleEn: 'must have + V3',
            titleTr: 'must have + V3',
            model: 'She must have forgotten the meeting.',
            avoid: 'She must forgot the meeting.',
            logicEn: 'Must have + V3 shows strong deduction about the past.',
            logicTr: 'Must have + V3 geçmiş hakkında güçlü çıkarım gösterir.'),
        GrammarLogicPoint(
            kind: 'possibility',
            titleEn: 'might have + V3',
            titleTr: 'might have + V3',
            model: 'He might have missed the train.',
            avoid: 'He might missed the train.',
            logicEn: 'Might have + V3 shows past possibility.',
            logicTr: 'Might have + V3 geçmiş olasılık anlatır.'),
      ];
    case 'b2_advanced_quantifiers':
      return const [
        GrammarLogicPoint(
            kind: 'quantity',
            titleEn: 'Hardly any',
            titleTr: 'Hardly any',
            model: 'Hardly any students missed the exam.',
            avoid: 'Hardly students missed the exam.',
            logicEn: 'Hardly any means almost no.',
            logicTr: 'Hardly any neredeyse hiç anlamı verir.'),
        GrammarLogicPoint(
            kind: 'quantity',
            titleEn: 'A great deal of',
            titleTr: 'A great deal of',
            model: 'The project requires a great deal of patience.',
            avoid: 'The project requires many patience.',
            logicEn: 'A great deal of is common with uncountable nouns.',
            logicTr: 'A great deal of sayılamayan isimlerle sık kullanılır.'),
        GrammarLogicPoint(
            kind: 'quantity',
            titleEn: 'A number of',
            titleTr: 'A number of',
            model: 'A number of students have complained.',
            avoid: 'A number of student has complained.',
            logicEn: 'A number of is followed by plural nouns.',
            logicTr: 'A number of sonrasında çoğul isim gelir.'),
      ];
    case 'b2_formal_comparisons':
      return const [
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'The more..., the more...',
            titleTr: 'The more..., the more...',
            model: 'The more you practise, the better you become.',
            avoid: 'More you practise, better you become.',
            logicEn: 'Formal parallel comparison uses the + comparative twice.',
            logicTr:
                'Resmi paralel karşılaştırmada iki tarafta da the + comparative kullanılır.'),
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'No less than',
            titleTr: 'No less than',
            model: 'The result was no less important than the method.',
            avoid: 'The result was not less important than method.',
            logicEn: 'No less than creates formal comparison and emphasis.',
            logicTr: 'No less than resmi karşılaştırma ve vurgu kurar.'),
        GrammarLogicPoint(
            kind: 'comparison',
            titleEn: 'As much as',
            titleTr: 'As much as',
            model: 'Accuracy matters as much as speed.',
            avoid: 'Accuracy matters so much as speed.',
            logicEn: 'As much as compares equal importance.',
            logicTr: 'As much as eşit önem karşılaştırması yapar.'),
      ];

    case 'c1_nominalisation_intro':
      return const [
        GrammarLogicPoint(
            kind: 'style',
            titleEn: 'Verb to noun',
            titleTr: 'Fiilden isme',
            model: 'The arrival of new data changed the conclusion.',
            avoid: 'New data arrived changed the conclusion.',
            logicEn: 'Nominalisation turns actions into noun phrases.',
            logicTr: 'Nominalisation eylemleri isim gruplarına dönüştürür.'),
        GrammarLogicPoint(
            kind: 'style',
            titleEn: 'Academic density',
            titleTr: 'Akademik yoğunluk',
            model: 'The implementation of the policy took months.',
            avoid: 'The policy implemented took months.',
            logicEn: 'Academic writing often compresses actions into nouns.',
            logicTr:
                'Akademik yazı eylemleri sık sık isimleştirerek yoğunlaştırır.'),
        GrammarLogicPoint(
            kind: 'style',
            titleEn: 'Of-phrase',
            titleTr: 'Of yapısı',
            model: 'The analysis of the results was useful.',
            avoid: 'The analyze of the results was useful.',
            logicEn: 'Use the correct noun form in nominalised phrases.',
            logicTr: 'İsimleştirilmiş yapılarda doğru isim formu kullanılır.'),
      ];
    case 'c1_advanced_passive':
      return const [
        GrammarLogicPoint(
            kind: 'passive',
            titleEn: 'Impersonal passive',
            titleTr: 'Impersonal passive',
            model: 'It is widely believed that stress affects learning.',
            avoid: 'It widely believes that stress affects learning.',
            logicEn: 'Advanced passive creates a formal, impersonal tone.',
            logicTr: 'İleri passive resmi ve kişisiz bir ton kurar.'),
        GrammarLogicPoint(
            kind: 'passive',
            titleEn: 'Modal passive',
            titleTr: 'Modal passive',
            model: 'The issue must be addressed immediately.',
            avoid: 'The issue must address immediately.',
            logicEn: 'Modal passive uses modal + be + V3.',
            logicTr: 'Modal passive modal + be + V3 ile kurulur.'),
        GrammarLogicPoint(
            kind: 'passive',
            titleEn: 'Perfect passive',
            titleTr: 'Perfect passive',
            model: 'The decision has been criticised by experts.',
            avoid: 'The decision has criticised by experts.',
            logicEn: 'Perfect passive uses have/has been + V3.',
            logicTr: 'Perfect passive have/has been + V3 ile kurulur.'),
      ];
    case 'c1_hedging':
      return const [
        GrammarLogicPoint(
            kind: 'hedging',
            titleEn: 'It seems that',
            titleTr: 'It seems that',
            model: 'It seems that the results are reliable.',
            avoid: 'The results are definitely reliable.',
            logicEn: 'Hedging makes claims more careful.',
            logicTr: 'Hedging iddiaları daha temkinli yapar.'),
        GrammarLogicPoint(
            kind: 'hedging',
            titleEn: 'May suggest',
            titleTr: 'May suggest',
            model: 'The data may suggest a change in behaviour.',
            avoid: 'The data suggest certainly a change in behaviour.',
            logicEn: 'May helps avoid overclaiming.',
            logicTr: 'May aşırı kesin iddiadan kaçınmaya yardım eder.'),
        GrammarLogicPoint(
            kind: 'hedging',
            titleEn: 'Tends to',
            titleTr: 'Tends to',
            model: 'Online practice tends to improve confidence.',
            avoid: 'Online practice tends improve confidence.',
            logicEn: 'Tend to states a careful general pattern.',
            logicTr: 'Tend to dikkatli bir genel eğilim ifade eder.'),
      ];
    case 'c1_advanced_conditionals':
      return const [
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Were it not for',
            titleTr: 'Were it not for',
            model: 'Were it not for your support, we would fail.',
            avoid: 'Were it not for your support, we will fail.',
            logicEn: 'Were it not for is a formal unreal conditional.',
            logicTr: 'Were it not for resmi gerçek dışı koşul yapısıdır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Had I known',
            titleTr: 'Had I known',
            model: 'Had I known the truth, I would have acted differently.',
            avoid: 'Had I knew the truth, I would have acted differently.',
            logicEn:
                'Inverted third conditionals omit if and use Had + subject + V3.',
            logicTr:
                'Inverted third conditional if olmadan Had + özne + V3 kullanır.'),
        GrammarLogicPoint(
            kind: 'condition',
            titleEn: 'Should you need',
            titleTr: 'Should you need',
            model: 'Should you need help, please contact us.',
            avoid: 'Should you needed help, please contact us.',
            logicEn: 'Should + subject + V1 is a formal future conditional.',
            logicTr: 'Should + özne + V1 resmi gelecek koşuludur.'),
      ];
    case 'c1_reduced_clauses':
      return const [
        GrammarLogicPoint(
            kind: 'reduction',
            titleEn: 'After + V-ing',
            titleTr: 'After + V-ing',
            model: 'After finishing the task, she left the office.',
            avoid: 'After she finishing the task, she left the office.',
            logicEn:
                'Reduced time clauses can use V-ing when the subject is shared.',
            logicTr: 'Özne ortaksa reduced time clause V-ing kullanabilir.'),
        GrammarLogicPoint(
            kind: 'reduction',
            titleEn: 'When + V-ing',
            titleTr: 'When + V-ing',
            model: 'When entering the room, please be quiet.',
            avoid: 'When you entering the room, please be quiet.',
            logicEn: 'Reduced clauses remove repeated subject and auxiliary.',
            logicTr: 'Reduced clause tekrar eden özne ve yardımcıyı azaltır.'),
        GrammarLogicPoint(
            kind: 'reduction',
            titleEn: 'Past participle reduction',
            titleTr: 'V3 ile reduction',
            model: 'Written in simple language, the guide is easy to follow.',
            avoid: 'Writing in simple language, the guide is easy to follow.',
            logicEn: 'Use V3 when the reduced meaning is passive.',
            logicTr: 'Anlam passive ise reduction içinde V3 kullanılır.'),
      ];
    case 'c1_register_control':
      return const [
        GrammarLogicPoint(
            kind: 'register',
            titleEn: 'Formal request',
            titleTr: 'Resmi rica',
            model: 'I would appreciate it if you could reply soon.',
            avoid: 'Reply soon.',
            logicEn:
                'Register control means choosing the structure that fits the situation.',
            logicTr: 'Register control duruma uygun yapıyı seçmek demektir.'),
        GrammarLogicPoint(
            kind: 'register',
            titleEn: 'Academic tone',
            titleTr: 'Akademik ton',
            model: 'This essay examines the impact of technology on learning.',
            avoid: 'I will talk about technology and learning.',
            logicEn:
                'Academic tone prefers precise verbs and less casual framing.',
            logicTr:
                'Akademik ton net fiilleri ve daha az gündelik çerçeveyi tercih eder.'),
        GrammarLogicPoint(
            kind: 'register',
            titleEn: 'Polite distance',
            titleTr: 'Kibar mesafe',
            model: 'Would it be possible to change the meeting time?',
            avoid: 'Change the meeting time.',
            logicEn: 'Indirect questions often sound more polite.',
            logicTr: 'Dolaylı sorular çoğunlukla daha kibar duyulur.'),
      ];
    case 'c1_subjunctive_formulaic':
      return const [
        GrammarLogicPoint(
            kind: 'subjunctive',
            titleEn: 'It is essential that + subject + V1',
            titleTr: 'It is essential that + özne + V1',
            model: 'It is essential that he be informed immediately.',
            avoid: 'It is essential that he is informed immediately.',
            logicEn: 'Formal subjunctive can use the base verb after that.',
            logicTr:
                'Resmi subjunctive that sonrasında yalın fiil kullanabilir.'),
        GrammarLogicPoint(
            kind: 'formulaic',
            titleEn: 'So be it',
            titleTr: 'So be it',
            model: 'If that is the final decision, so be it.',
            avoid: 'If that is the final decision, so is it.',
            logicEn: 'Some formulaic structures are fixed expressions.',
            logicTr: 'Bazı formulaic yapılar kalıplaşmış ifadelerdir.'),
        GrammarLogicPoint(
            kind: 'wish',
            titleEn: 'If need be',
            titleTr: 'If need be',
            model: 'We can postpone the meeting if need be.',
            avoid: 'We can postpone the meeting if needs be.',
            logicEn: 'If need be is a fixed formal phrase.',
            logicTr: 'If need be kalıplaşmış resmi bir ifadedir.'),
      ];
    case 'c1_ellipsis_substitution_intro':
      return const [
        GrammarLogicPoint(
            kind: 'ellipsis',
            titleEn: 'Short answer with auxiliary',
            titleTr: 'Yardımcı fiille kısa cevap',
            model: 'I have finished the task, but she has not.',
            avoid: 'I have finished the task, but she has not finished it not.',
            logicEn: 'Ellipsis avoids repeating words that are already clear.',
            logicTr:
                'Ellipsis zaten net olan kelimeleri tekrar etmemeyi sağlar.'),
        GrammarLogicPoint(
            kind: 'substitution',
            titleEn: 'Do so',
            titleTr: 'Do so',
            model: 'The team reduced costs and will continue to do so.',
            avoid: 'The team reduced costs and will continue to do it.',
            logicEn: 'Do so can replace a repeated action in formal style.',
            logicTr: 'Do so resmi tarzda tekrar eden eylemin yerine geçer.'),
        GrammarLogicPoint(
            kind: 'substitution',
            titleEn: 'So / not',
            titleTr: 'So / not',
            model: 'I hope so.',
            avoid: 'I hope it.',
            logicEn:
                'So can replace a previous idea after verbs like hope and think.',
            logicTr:
                'So, hope ve think gibi fiillerden sonra önceki fikrin yerine geçebilir.'),
      ];

    case 'c2_dense_noun_phrases':
      return const [
        GrammarLogicPoint(
            kind: 'density',
            titleEn: 'Pre-modified noun phrase',
            titleTr: 'Önceden nitelenmiş isim grubu',
            model: 'The long-term economic impact remains unclear.',
            avoid: 'The impact economic long-term remains unclear.',
            logicEn:
                'Dense noun phrases place modifiers before the head noun in a controlled order.',
            logicTr:
                'Yoğun isim gruplarında niteleyiciler ana isimden önce kontrollü sırayla gelir.'),
        GrammarLogicPoint(
            kind: 'of-phrase',
            titleEn: 'Of-phrase expansion',
            titleTr: 'Of-phrase genişletmesi',
            model:
                'The implementation of the new assessment policy caused debate.',
            avoid: 'The implement of the new assessment policy caused debate.',
            logicEn: 'Use correct noun forms inside dense noun phrases.',
            logicTr: 'Yoğun isim gruplarında doğru isim formları kullanılır.'),
        GrammarLogicPoint(
            kind: 'style',
            titleEn: 'Academic precision',
            titleTr: 'Akademik netlik',
            model: 'A gradual decline in learner motivation was observed.',
            avoid: 'Learner motivation declined gradual was observed.',
            logicEn:
                'Academic style often packages actions as precise noun phrases.',
            logicTr:
                'Akademik tarz eylemleri net isim grupları halinde paketler.'),
      ];
    case 'c2_complex_subordination':
      return const [
        GrammarLogicPoint(
            kind: 'subordination',
            titleEn: 'Although + clause',
            titleTr: 'Although + cümle',
            model: 'Although the sample was small, the findings were useful.',
            avoid:
                'Although the sample was small, but the findings were useful.',
            logicEn:
                'Complex subordination connects ideas without double connectors.',
            logicTr:
                'Karmaşık subordination fikirleri çift bağlaç kullanmadan bağlar.'),
        GrammarLogicPoint(
            kind: 'subordination',
            titleEn: 'Whereas + clause',
            titleTr: 'Whereas + cümle',
            model:
                'Whereas some learners need structure, others prefer freedom.',
            avoid:
                'Whereas some learners need structure, but others prefer freedom.',
            logicEn: 'Whereas contrasts two complete ideas.',
            logicTr: 'Whereas iki tam fikri karşılaştırır.'),
        GrammarLogicPoint(
            kind: 'subordination',
            titleEn: 'In that + clause',
            titleTr: 'In that + cümle',
            model: 'The method is useful in that it encourages reflection.',
            avoid: 'The method is useful in that encourages reflection.',
            logicEn: 'In that explains the specific way something is true.',
            logicTr: 'In that bir şeyin hangi açıdan doğru olduğunu açıklar.'),
      ];
    case 'c2_advanced_concession':
      return const [
        GrammarLogicPoint(
            kind: 'concession',
            titleEn: 'Be that as it may',
            titleTr: 'Be that as it may',
            model: 'Be that as it may, the decision must be reviewed.',
            avoid: 'Be that it may, the decision must be reviewed.',
            logicEn: 'This fixed phrase introduces formal concession.',
            logicTr: 'Bu kalıp resmi concession başlatır.'),
        GrammarLogicPoint(
            kind: 'concession',
            titleEn: 'Admittedly',
            titleTr: 'Admittedly',
            model: 'Admittedly, the plan is risky, but it is worth testing.',
            avoid:
                'Admittedly the plan is risky but it is worth testing without commas.',
            logicEn: 'Admittedly concedes a point before the main argument.',
            logicTr: 'Admittedly ana argümandan önce bir noktayı kabul eder.'),
        GrammarLogicPoint(
            kind: 'concession',
            titleEn: 'For all its flaws',
            titleTr: 'For all its flaws',
            model: 'For all its flaws, the system remains effective.',
            avoid: 'For all it flaws, the system remains effective.',
            logicEn: 'For all its flaws means despite its problems.',
            logicTr: 'For all its flaws sorunlarına rağmen anlamı verir.'),
      ];
    case 'c2_advanced_emphasis':
      return const [
        GrammarLogicPoint(
            kind: 'emphasis',
            titleEn: 'What matters is',
            titleTr: 'What matters is',
            model: 'What matters is whether the solution is sustainable.',
            avoid: 'What matters are whether the solution is sustainable.',
            logicEn:
                'Advanced emphasis controls what the reader notices first.',
            logicTr:
                'İleri vurgu okuyucunun önce neyi fark ettiğini kontrol eder.'),
        GrammarLogicPoint(
            kind: 'emphasis',
            titleEn: 'It is not X but Y',
            titleTr: 'It is not X but Y',
            model: 'It is not speed but accuracy that matters most.',
            avoid: 'It is not speed but accuracy matters most.',
            logicEn: 'Cleft-like contrast sharpens the focus.',
            logicTr: 'Cleft benzeri zıtlık odağı keskinleştirir.'),
        GrammarLogicPoint(
            kind: 'emphasis',
            titleEn: 'The very reason',
            titleTr: 'The very reason',
            model: 'That is the very reason why the policy failed.',
            avoid: 'That is very reason why the policy failed.',
            logicEn: 'Very can intensify a noun phrase in formal emphasis.',
            logicTr: 'Very resmi vurguda isim grubunu güçlendirebilir.'),
      ];
    case 'c2_stylistic_inversion':
      return const [
        GrammarLogicPoint(
            kind: 'inversion',
            titleEn: 'Rarely have I...',
            titleTr: 'Rarely have I...',
            model: 'Rarely have I seen such careful analysis.',
            avoid: 'Rarely I have seen such careful analysis.',
            logicEn: 'Stylistic inversion creates a formal or literary tone.',
            logicTr: 'Stylistic inversion resmi veya edebi ton oluşturur.'),
        GrammarLogicPoint(
            kind: 'inversion',
            titleEn: 'Only after',
            titleTr: 'Only after',
            model: 'Only after reviewing the data did we change our view.',
            avoid: 'Only after reviewing the data we changed our view.',
            logicEn:
                'Only + fronted phrase often triggers auxiliary inversion.',
            logicTr:
                'Only + başa alınmış ifade çoğunlukla yardımcı fiil inversion ister.'),
        GrammarLogicPoint(
            kind: 'inversion',
            titleEn: 'Little did...',
            titleTr: 'Little did...',
            model: 'Little did they realise how serious the issue was.',
            avoid: 'Little they realised how serious the issue was.',
            logicEn: 'Little at the beginning needs inversion in this style.',
            logicTr:
                'Little başta kullanıldığında bu tarzda inversion gerekir.'),
      ];
    case 'c2_precision_modality':
      return const [
        GrammarLogicPoint(
            kind: 'modality',
            titleEn: 'May well',
            titleTr: 'May well',
            model: 'This approach may well reduce long-term costs.',
            avoid: 'This approach may to reduce long-term costs.',
            logicEn: 'May well expresses a strong but cautious possibility.',
            logicTr: 'May well güçlü ama temkinli olasılık anlatır.'),
        GrammarLogicPoint(
            kind: 'modality',
            titleEn: 'Is likely to',
            titleTr: 'Is likely to',
            model: 'The change is likely to affect smaller schools.',
            avoid: 'The change is likely affect smaller schools.',
            logicEn:
                'Likely to gives precise probability without sounding absolute.',
            logicTr: 'Likely to kesin konuşmadan net olasılık verir.'),
        GrammarLogicPoint(
            kind: 'modality',
            titleEn: 'Cannot be ruled out',
            titleTr: 'Cannot be ruled out',
            model: 'A further increase cannot be ruled out.',
            avoid: 'A further increase cannot rule out.',
            logicEn:
                'This passive modal phrase is common in cautious analysis.',
            logicTr: 'Bu passive modal ifade temkinli analizde yaygındır.'),
      ];
    case 'c2_discourse_flow':
      return const [
        GrammarLogicPoint(
            kind: 'flow',
            titleEn: 'That said',
            titleTr: 'That said',
            model: 'The evidence is limited. That said, the trend is clear.',
            avoid: 'The evidence is limited. Therefore, the trend is limited.',
            logicEn: 'That said manages contrast between two ideas.',
            logicTr: 'That said iki fikir arasında zıtlık akışı kurar.'),
        GrammarLogicPoint(
            kind: 'flow',
            titleEn: 'In turn',
            titleTr: 'In turn',
            model:
                'Better feedback improves confidence, which in turn increases participation.',
            avoid:
                'Better feedback improves confidence, which in turns increases participation.',
            logicEn: 'In turn shows a chain of effects.',
            logicTr: 'In turn etki zinciri gösterir.'),
        GrammarLogicPoint(
            kind: 'flow',
            titleEn: 'Taken together',
            titleTr: 'Taken together',
            model: 'Taken together, these findings support the main argument.',
            avoid: 'Taking together, these findings support the main argument.',
            logicEn:
                'Taken together summarizes multiple points as one conclusion.',
            logicTr: 'Taken together birden fazla noktayı tek sonuçta toplar.'),
      ];
  }
  return const [];
}

String _lessonKey(GrammarLesson lesson) {
  final raw = _normalizedKey(
    '${lesson.bigTitle} ${lesson.oneLineGoal} ${lesson.teacherIntro} '
    '${lesson.formulaRows.map((e) => '${e.label} ${e.pattern} ${e.sample}').join(' ')} '
    '${lesson.examples.join(' ')} ${lesson.right} ${lesson.wrong} ${lesson.modelAnswer}',
  );
  // Phase187 audit lock: direct title aliases for curriculum topics.
  // These must come before broad generic rules like "will", "passive", "inversion", "hedging".
  if (raw.contains('present continuous for future arrangements') ||
      raw.contains('fixed future plans')) {
    return 'a2_present_continuous_future';
  }
  if (raw.contains('may / might') ||
      raw.contains('may and might') ||
      raw.contains('possibility after may') ||
      raw.contains('might rain')) {
    return 'a2_may_might';
  }
  if (raw.contains('present perfect vs past simple intro') ||
      raw.contains('experience or finished time')) {
    return 'a2_present_perfect_vs_past_simple';
  }

  if (raw.contains('present perfect continuous')) {
    return 'b1_present_perfect_continuous';
  }
  if (raw.contains('past perfect continuous')) {
    return 'b1_past_perfect_continuous';
  }
  if (raw.contains('future continuous')) return 'b1_future_continuous';
  if (raw.contains('future perfect intro')) return 'b1_future_perfect_intro';
  if (raw.contains('passive voice by tense') ||
      raw.contains('passive across common tenses')) {
    return 'b1_passive_voice_by_tense';
  }
  if (raw.contains('reported questions')) return 'b1_reported_questions';
  if (raw.contains('reported commands')) return 'b1_reported_commands';
  if (raw.contains('modals of advice') ||
      raw.contains('advice, obligation and possibility')) {
    return 'b1_modals';
  }
  if (raw.contains('defining relative clauses') &&
      !raw.contains('non-defining')) {
    return 'b1_defining_relative_clauses';
  }
  if (raw.contains('non-defining relative clauses intro')) {
    return 'b1_non_defining_relative_intro';
  }
  if (raw.contains('gerund vs infinitive')) return 'b1_gerund_vs_infinitive';
  if (raw.contains('used to / be used to / get used to')) {
    return 'b1_used_to_be_used_to_get_used_to';
  }
  if (raw.contains('question tags') || raw.contains('indirect questions')) {
    return 'b1_question_tags_indirect_questions';
  }

  if (raw.contains('advanced gerund / infinitive')) {
    return 'b2_advanced_gerund_infinitive';
  }
  if (raw.contains('passive reporting structures') ||
      raw.contains('it is said') ||
      raw.contains('he is believed to')) {
    return 'b2_passive_reporting';
  }
  if (raw.contains('complex relative clauses')) {
    return 'b2_complex_relative_clauses';
  }
  if (raw.contains('conditionals review and mixed conditionals')) {
    return 'b2_mixed_conditionals';
  }
  if (raw.contains('modal perfects') ||
      raw.contains('past deduction and criticism')) {
    return 'b2_modal_perfects';
  }
  if (raw.contains('emphasis structures')) return 'b2_emphasis_structures';
  if (raw.contains('advanced linking devices')) {
    return 'b2_advanced_linking_devices';
  }
  if (raw.contains('concession clauses')) return 'b2_concession_clauses';
  if (raw.contains('purpose result and reason clauses') ||
      raw.contains('so that / in order to')) {
    return 'b2_purpose_result_reason_clauses';
  }
  if (raw.contains('advanced quantifiers')) return 'b2_advanced_quantifiers';
  if (raw.contains('formal comparisons')) return 'b2_formal_comparisons';

  if (raw.contains('nominalisation intro')) return 'c1_nominalisation_intro';
  if (raw.contains('careful academic claims') || raw == 'hedging') {
    return 'c1_hedging';
  }
  if (raw.contains('advanced passive') &&
      raw.contains('formal and impersonal')) {
    return 'c1_advanced_passive';
  }
  if (raw.contains('advanced conditionals') &&
      raw.contains('formal alternatives to if')) {
    return 'c1_advanced_conditionals';
  }
  if (raw.contains('reduced clauses') && raw.contains('compact time')) {
    return 'c1_reduced_clauses';
  }
  if (raw.contains('register control')) return 'c1_register_control';
  if (raw.contains('subjunctive') || raw.contains('formulaic structures')) {
    return 'c1_subjunctive_formulaic';
  }
  if (raw.contains('ellipsis / substitution intro')) {
    return 'c1_ellipsis_substitution_intro';
  }

  if (raw.contains('dense noun phrases')) return 'c2_dense_noun_phrases';
  if (raw.contains('complex subordination')) return 'c2_complex_subordination';
  if (raw.contains('advanced concession')) return 'c2_advanced_concession';
  if (raw.contains('advanced emphasis')) return 'c2_advanced_emphasis';
  if (raw.contains('stylistic inversion')) return 'c2_stylistic_inversion';
  if (raw.contains('advanced conditional alternatives')) {
    return 'c2_advanced_conditional_alternatives';
  }
  if (raw.contains('precision with modality')) return 'c2_precision_modality';
  if (raw.contains('discourse flow')) return 'c2_discourse_flow';

  // Phase171 audit: broader aliases so level data can use natural titles without falling back.
  if (raw.contains('future perfect continuous') ||
      raw.contains('will have been')) {
    return 'b2_future_perfect_continuous';
  }
  if (raw.contains('future perfect') ||
      raw.contains('will have + v3') ||
      raw.contains('will have v3')) {
    return 'b2_future_perfect';
  }
  if (raw.contains('inversion intro')) return 'b2_inversion_intro';
  if (raw.contains('full inversion') ||
      raw.contains('never have i') ||
      raw.contains('only then did') ||
      raw.contains('negative adverbial inversion')) {
    return 'c1_full_inversion';
  }
  if (raw.contains('verb to be') ||
      raw.contains('to be verb') ||
      raw.contains('am is are') ||
      raw.contains('am/is/are')) {
    return 'a1_be_verb';
  }

  // A1 Present Simple is split into three topics in Speakery.
  if (raw.contains('present simple (olumlu)') ||
      raw.contains('present simple positive')) {
    return 'a1_present_simple_positive';
  }
  if (raw.contains('present simple (olumsuz)') ||
      raw.contains('present simple negative') ||
      (raw.contains('present simple') &&
          (raw.contains("don't") ||
              raw.contains("doesn't") ||
              raw.contains('don’t') ||
              raw.contains('doesn’t')))) {
    return 'a1_present_simple_negative';
  }
  if (raw.contains('present simple (soru)') ||
      raw.contains('present simple questions') ||
      (raw.contains('present simple') &&
          (raw.contains('do / does') ||
              raw.contains('do/does') ||
              raw.contains('yes, i do') ||
              raw.contains('does she')))) {
    return 'a1_present_simple_questions';
  }

  if ((raw.contains('present simple') || raw.contains('simple present')) &&
      !raw.contains('continuous') &&
      !raw.contains('progressive')) {
    return 'a1_present_simple';
  }
  if (raw.contains('present progressive') ||
      raw.contains('continuous present')) {
    return 'a1_present_continuous';
  }
  if (raw.contains('ability') &&
      (raw.contains('can') || raw.contains("can't"))) {
    return 'a1_can_cant';
  }
  if (raw.contains('demonstrative adjectives') ||
      raw.contains('this that these those')) {
    return 'a1_demonstratives';
  }
  if (raw.contains('possessive pronouns') && raw.contains('my')) {
    return 'a1_possessive_adjectives';
  }
  if (raw.contains('place prepositions') ||
      raw.contains('in on under next to')) {
    return 'a1_prepositions_place';
  }
  if (raw.contains('time prepositions') || raw.contains('in on at time')) {
    return 'a1_prepositions_time';
  }
  if (raw.contains('count nouns') || raw.contains('uncount nouns')) {
    return 'a1_countable_uncountable';
  }
  if (raw.contains('wh questions') || raw.contains('wh- questions')) {
    return 'a1_question_words';
  }
  if (raw.contains('conjunctions') &&
      (raw.contains('and') || raw.contains('but') || raw.contains('because'))) {
    return 'a1_basic_conjunctions';
  }

  if (raw.contains('nominalisation') ||
      raw.contains('nominalization') ||
      raw.contains('noun phrase style')) {
    return 'c2_nominalisation';
  }
  if (raw.contains('hedging') ||
      raw.contains('academic caution') ||
      raw.contains('it appears that') ||
      raw.contains('tends to')) {
    return 'c2_hedging_academic_caution';
  }
  if (raw.contains('ellipsis') ||
      raw.contains('substitution') ||
      raw.contains('do so') ||
      raw.contains('think so')) {
    return 'c2_ellipsis_substitution';
  }
  if (raw.contains('fronting') ||
      raw.contains('information flow') ||
      raw.contains('marked word order')) {
    return 'c2_fronting_information_flow';
  }
  if (raw.contains('advanced conditional') ||
      raw.contains('were it not for') ||
      raw.contains('had it not been for') ||
      raw.contains('should you need')) {
    return 'c2_advanced_conditionals';
  }
  if (raw.contains('discourse marker') ||
      raw.contains('that said') ||
      raw.contains('be that as it may') ||
      raw.contains('for that matter')) {
    return 'c2_discourse_markers';
  }
  if (raw.contains('register') ||
      raw.contains('formal style') ||
      raw.contains('academic style') ||
      raw.contains('polite request')) {
    return 'c2_register_and_style';
  }
  if (raw.contains('inversion') ||
      raw.contains('negative adverbial') ||
      raw.contains('not only') ||
      raw.contains('only then')) {
    return 'c1_inversion';
  }
  if (raw.contains('cleft') ||
      raw.contains('it-cleft') ||
      raw.contains('what-cleft') ||
      raw.contains('emphasis structure')) {
    return 'c1_cleft_sentences';
  }
  if (raw.contains('emphatic do') ||
      raw.contains('emphasis with do') ||
      raw.contains('do / does / did for emphasis')) {
    return 'c1_emphasis_do';
  }
  if (raw.contains('advanced modality') ||
      raw.contains('should have') ||
      raw.contains('need not have') ||
      raw.contains('could have')) {
    return 'c1_advanced_modality';
  }
  if (raw.contains('advanced linkers') ||
      raw.contains('despite') ||
      raw.contains('nevertheless') ||
      raw.contains('although')) {
    return 'c1_advanced_linkers';
  }
  if (raw.contains('noun clause') ||
      raw.contains('that-clause') ||
      raw.contains('whether clause') ||
      raw.contains('the fact that')) {
    return 'c1_noun_clauses';
  }
  if (raw.contains('reduced relative') ||
      raw.contains('relative clause reduction') ||
      raw.contains('reduced adjective clause')) {
    return 'c1_reduced_relative_clauses';
  }
  if (raw.contains('third conditional')) return 'b2_third_conditional';
  if (raw.contains('mixed conditional')) return 'b2_mixed_conditionals';
  if (raw.contains('modal') &&
      (raw.contains('deduction') ||
          raw.contains('must have') ||
          raw.contains('might have'))) {
    return 'b2_modal_deduction';
  }
  if ((raw.contains('advanced passive') ||
          raw.contains('modal passive') ||
          raw.contains('perfect passive')) ||
      (raw.contains('passive') && raw.contains('been'))) {
    return 'b2_advanced_passive';
  }
  if (raw.contains('reported speech') &&
      (raw.contains('advanced') ||
          raw.contains('reported question') ||
          raw.contains('backshift'))) {
    return 'b2_reported_speech_advanced';
  }
  if (raw.contains('non-defining') ||
      raw.contains('non defining') ||
      raw.contains('extra information with commas')) {
    return 'b2_non_defining_relative_clauses';
  }
  if (raw.contains('causative') ||
      raw.contains('have something done') ||
      raw.contains('get something done')) {
    return 'b2_causative_have_get';
  }
  if (raw.contains('wish') || raw.contains('if only')) return 'b2_wish_if_only';
  if (raw.contains('participle clause') || raw.contains('reduced clause')) {
    return 'b2_participle_clauses_intro';
  }
  if (raw.contains('past perfect')) return 'b1_past_perfect';
  if (raw.contains('second conditional')) return 'b1_second_conditional';
  if (raw.contains('reported speech')) return 'b1_reported_speech_intro';
  if (raw.contains('passive voice') ||
      raw.contains('object focus') ||
      raw.contains('be + v3')) {
    return 'b1_passive_voice';
  }
  if (raw.contains('present perfect vs past') ||
      raw.contains('present perfect vs past simple') ||
      raw.contains('time difference')) {
    return 'b1_present_perfect_vs_past';
  }
  if ((raw.contains('present perfect') &&
          (raw.contains('life experience') ||
              raw.contains('unfinished time'))) &&
      !raw.contains('intro')) {
    return 'b1_present_perfect';
  }
  if (raw.contains('conditionals 1') || raw.contains('real future')) {
    return 'b1_first_conditional';
  }
  if (raw.contains('modal verbs') ||
      (raw.contains('must') &&
          raw.contains('should') &&
          raw.contains('have to'))) {
    return 'b1_modal_verbs';
  }
  if (raw.contains('relative clauses') && !raw.contains('intro')) {
    return 'b1_relative_clauses';
  }
  if (raw.contains('used to / would') ||
      (raw.contains('used to') && raw.contains('would'))) {
    return 'b1_used_to_would';
  }
  if (raw.contains('am / is / are') || raw.contains('be verb')) {
    return 'a1_be_verb';
  }
  if (raw.contains('present simple') && !raw.contains('continuous')) {
    return 'a1_present_simple';
  }
  if (raw.contains('present continuous')) return 'a1_present_continuous';
  if (raw.contains('can / can') ||
      raw.contains('can / can’t') ||
      raw.contains('can / cannot') ||
      raw.contains("can and can't") ||
      raw.contains('can cannot')) {
    return 'a1_can_cant';
  }
  if (raw.contains('there is') || raw.contains('there are')) {
    return 'a1_there_is_are';
  }
  if (raw.contains('articles') ||
      raw.contains('a, an, the') ||
      raw.contains('a an the') ||
      raw.contains('indefinite article') ||
      raw.contains('definite article')) {
    return 'a1_articles';
  }
  if (raw.contains('going to') ||
      raw.contains('planned future') ||
      raw.contains('future plan')) {
    return 'a2_going_to';
  }
  if (raw.contains('should')) return 'a2_should';
  if (raw.contains('too / enough') ||
      raw.contains('too enough') ||
      raw.contains('too adjective') ||
      raw.contains('adjective enough')) {
    return 'a2_too_enough';
  }
  if (raw.contains('present perfect intro') ||
      (raw.contains('present perfect') && !raw.contains('past simple'))) {
    return 'a2_present_perfect_intro';
  }
  if (raw.contains('first conditional') ||
      raw.contains('conditional type 1') ||
      raw.contains('if clause type 1')) {
    return 'a2_first_conditional';
  }
  if (raw.contains('past simple vs past continuous')) {
    return 'a2_past_simple_vs_continuous';
  }
  if (raw.contains('past simple') &&
      !raw.contains('continuous') &&
      !raw.contains('perfect')) {
    return 'a2_past_simple';
  }
  if (raw.contains('past continuous')) return 'a2_past_continuous';
  if (raw.contains('comparative') ||
      raw.contains('comparatives') ||
      raw.contains('comparison adjective')) {
    return 'a2_comparatives';
  }
  if ((raw.contains('must') && raw.contains('have to')) ||
      raw.contains('obligation') ||
      raw.contains('necessity') ||
      raw.contains('mustn')) {
    return 'a2_must_have_to';
  }
  if (raw.contains('subject pronouns')) return 'a1_subject_pronouns';
  if (raw.contains('possessive adjectives')) return 'a1_possessive_adjectives';
  if (raw.contains('singular') && raw.contains('plural')) {
    return 'a1_singular_plural';
  }
  if (raw.contains('demonstratives') || raw.contains('this, that')) {
    return 'a1_demonstratives';
  }
  if (raw.contains('have / has got') || raw.contains('has got')) {
    return 'a1_have_has_got';
  }
  if (raw.contains('adverbs of frequency') || raw.contains('frequency')) {
    return 'a1_adverbs_frequency';
  }
  if (raw.contains('present simple vs continuous')) {
    return 'a1_present_simple_vs_continuous';
  }
  if (raw.contains('imperatives')) return 'a1_imperatives';
  if (raw.contains('object pronouns')) return 'a1_object_pronouns';
  if (raw.contains('prepositions of place')) return 'a1_prepositions_place';
  if (raw.contains('prepositions of time')) return 'a1_prepositions_time';
  if (raw.contains('some / any')) return 'a1_some_any';
  if (raw.contains('countable') && raw.contains('uncountable')) {
    return 'a1_countable_uncountable';
  }
  if (raw.contains('how much') || raw.contains('how many')) {
    return 'a1_how_much_many';
  }
  if (raw.contains('question words')) return 'a1_question_words';
  if (raw.contains('possessive') && raw.contains("'s")) {
    return 'a1_possessive_s';
  }
  if (raw.contains('basic conjunctions') || raw.contains('and, but')) {
    return 'a1_basic_conjunctions';
  }
  if (raw.contains('superlative')) return 'a2_superlatives';
  if (raw.contains('future: will') ||
      raw.contains('will =') ||
      raw.contains('will +') ||
      raw.contains('future simple') ||
      raw.contains('simple future')) {
    return 'a2_will';
  }
  if (raw.contains('used to')) return 'a2_used_to';
  if (raw.contains('would like')) return 'a2_would_like';
  if (raw.contains('gerund') ||
      raw.contains('infinitive') ||
      raw.contains('verb patterns')) {
    return 'a2_gerund_infinitive';
  }
  if (raw.contains('relative clauses intro') ||
      raw.contains('who / which') ||
      raw.contains('who which that') ||
      raw.contains('relative pronouns')) {
    return 'a2_relative_clauses_intro';
  }
  if (raw.contains('present perfect vs past simple')) {
    return 'a2_present_perfect_vs_past_simple';
  }
  if (raw.contains('quantifiers')) return 'a2_quantifiers';
  if (raw.contains('so / such')) return 'a2_so_such';
  if (raw.contains('zero conditional') ||
      raw.contains('conditional type 0') ||
      raw.contains('general truths with if')) {
    return 'a2_zero_conditional';
  }
  return raw.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

String _rowKind(String label, String pattern, String sample) {
  final s = '$label $pattern $sample'.toLowerCase();
  if (s.contains('negative') ||
      s.contains('olumsuz') ||
      s.contains('not') ||
      s.contains("n't")) {
    return 'negative';
  }
  if (s.contains('question') || s.contains('soru') || s.contains('?')) {
    return 'question';
  }
  if (s.contains('irregular') || s.contains('düzensiz')) return 'irregular';
  if (s.contains('spelling') || s.contains('y →') || s.contains('ies')) {
    return 'spelling';
  }
  if (s.contains('time') ||
      s.contains('zaman') ||
      s.contains('yesterday') ||
      s.contains('ago')) {
    return 'time';
  }
  if (s.contains('than') || s.contains('compar') || s.contains('more +')) {
    return 'comparison';
  }
  if (s.contains('must') ||
      s.contains('should') ||
      s.contains('have to') ||
      s.contains('modal')) {
    return 'modal';
  }
  if (s.contains('if ') || s.contains('when ') || s.contains('while ')) {
    return 'condition';
  }
  if (s.contains('positive') ||
      s.contains('affirmative') ||
      s.contains('olumlu')) {
    return 'positive';
  }
  return 'usage';
}

String _cleanRowLabel(String label, bool isEnglish, String kind) {
  final clean = label.trim();
  final lower = clean.toLowerCase();
  if (clean.isEmpty ||
      lower.startsWith('step') ||
      lower == 'meaning' ||
      lower == 'use') {
    switch (kind) {
      case 'positive':
        return isEnglish ? 'Positive form' : 'Olumlu yapı';
      case 'negative':
        return isEnglish ? 'Negative form' : 'Olumsuz yapı';
      case 'question':
        return isEnglish ? 'Question form' : 'Soru yapısı';
      case 'time':
        return isEnglish ? 'Time signal' : 'Zaman ipucu';
      case 'comparison':
        return isEnglish ? 'Comparison pattern' : 'Karşılaştırma kalıbı';
      case 'modal':
        return isEnglish ? 'Modal pattern' : 'Modal kalıbı';
      default:
        return isEnglish ? 'Core pattern' : 'Temel kalıp';
    }
  }
  return clean;
}

String _logicFor(String kind, bool isEnglish) {
  switch (kind) {
    case 'positive':
      return isEnglish
          ? 'Use this form to make a clear positive sentence.'
          : 'Bu form olumlu cümle kurmak için kullanılır.';
    case 'negative':
      return isEnglish
          ? 'The negative marker must stay in the correct position.'
          : 'Olumsuzluk işareti doğru yerde durmalı.';
    case 'question':
      return isEnglish
          ? 'Questions usually move the helper verb before the subject.'
          : 'Sorularda yardımcı fiil genelde öznenin önüne gelir.';
    case 'irregular':
      return isEnglish
          ? 'This form changes specially; do not build it with the regular rule.'
          : 'Bu form özel değişir; normal kuralla kurma.';
    case 'spelling':
      return isEnglish
          ? 'Notice the spelling change before you use the form.'
          : 'Formu kullanmadan önce yazım değişimini fark et.';
    case 'time':
      return isEnglish
          ? 'Time words show when the action happens.'
          : 'Zaman kelimeleri olayın ne zaman olduğunu gösterir.';
    case 'comparison':
      return isEnglish
          ? 'Use the correct comparison pattern for this adjective.'
          : 'Bu sıfat için doğru karşılaştırma kalıbını kullan.';
    case 'modal':
      return isEnglish
          ? 'The verb after the modal stays in base form.'
          : 'Modal sonrası fiil yalın halde kalır.';
    case 'condition':
      return isEnglish
          ? 'Each part of the sentence has a different job.'
          : 'Cümlenin her parçasının farklı görevi vardır.';
    default:
      return isEnglish
          ? 'The model keeps the natural word order and verb form for this use.'
          : 'Model cümle bu kullanım için doğal kelime sırasını ve fiil biçimini korur.';
  }
}

String _avoidFor(String kind, String model, String label, String pattern) {
  final lower = model.toLowerCase();
  String replaceWord(String from, String to) =>
      model.replaceFirst(RegExp('\\b$from\\b', caseSensitive: false), to);

  if (kind == 'negative') {
    if (lower.contains('did not go')) return replaceWord('go', 'went');
    if (lower.contains('did not watch')) return replaceWord('watch', 'watched');
    if (lower.contains('does not like')) return replaceWord('like', 'likes');
    if (lower.contains('do not watch')) return replaceWord('watch', 'watches');
    if (lower.contains('was not')) {
      return model.replaceFirst(
          RegExp(r'\bwas not\b', caseSensitive: false), 'not was');
    }
    if (lower.contains('were not')) {
      return model.replaceFirst(
          RegExp(r'\bwere not\b', caseSensitive: false), 'not were');
    }
    if (lower.contains('do not have to')) {
      return model.replaceFirst(
          RegExp(r'\bdo not have to\b', caseSensitive: false), 'must not');
    }
  }

  if (kind == 'question') {
    if (model.endsWith('?')) {
      return '${model.substring(0, model.length - 1)}.';
    }
    if (lower.startsWith('did ')) {
      return '${model.replaceFirst(RegExp(r'^did\\s+', caseSensitive: false), '')}?';
    }
    if (lower.startsWith('were ')) {
      return '${model.replaceFirst(RegExp(r'^were\\s+', caseSensitive: false), '')}?';
    }
    if (lower.startsWith('are ')) {
      return '${model.replaceFirst(RegExp(r'^are\\s+', caseSensitive: false), '')}?';
    }
  }

  if (kind == 'comparison') {
    if (lower.contains('colder')) return replaceWord('colder', 'more cold');
    if (lower.contains('more useful')) {
      return replaceWord('more useful', 'usefuler');
    }
    if (lower.contains('better')) return replaceWord('better', 'more better');
    if (lower.contains('than')) return replaceWord('than', 'from');
  }

  if (kind == 'modal') {
    if (lower.contains('must wear')) {
      return model.replaceFirst(
          RegExp(r'\bmust wear\b', caseSensitive: false), 'must to wear');
    }
    if (lower.contains('have to finish')) {
      return model.replaceFirst(
          RegExp(r'\bhave to finish\b', caseSensitive: false),
          'must to finish');
    }
    if (lower.contains('has to wake')) {
      return model.replaceFirst(
          RegExp(r'\bhas to wake\b', caseSensitive: false), 'have to wake');
    }
    if (lower.contains('should study')) {
      return model.replaceFirst(
          RegExp(r'\bshould study\b', caseSensitive: false), 'should studies');
    }
  }
  if (lower.contains('is going to')) {
    return model.replaceFirst(
        RegExp(r'\bis going to\b', caseSensitive: false), 'going to');
  }
  if (lower.contains('are going to')) {
    return model.replaceFirst(
        RegExp(r'\bare going to\b', caseSensitive: false), 'do going to');
  }
  if (lower.contains('am going to')) {
    return model.replaceFirst(
        RegExp(r'\bam going to\b', caseSensitive: false), 'going to');
  }
  if (lower.contains('have visited')) {
    return model.replaceFirst(
        RegExp(r'\bhave visited\b', caseSensitive: false), 'have visit');
  }
  if (lower.contains('has finished')) {
    return model.replaceFirst(
        RegExp(r'\bhas finished\b', caseSensitive: false), 'have finished');
  }
  if (lower.contains('old enough')) {
    return model.replaceFirst(
        RegExp(r'\bold enough\b', caseSensitive: false), 'enough old');
  }
  if (lower.contains('enough time')) {
    return model.replaceFirst(
        RegExp(r'\benough time\b', caseSensitive: false), 'time enough');
  }
  if (lower.contains('too heavy')) {
    return model.replaceFirst(
        RegExp(r'\btoo heavy\b', caseSensitive: false), 'heavy too');
  }

  if (lower.contains('i am ')) {
    return model.replaceFirst(RegExp(r'\bam\b', caseSensitive: false), 'is');
  }
  if (lower.contains('she is ')) {
    return model.replaceFirst(RegExp(r'\bis\b', caseSensitive: false), 'are');
  }
  if (lower.contains('they are ')) {
    return model.replaceFirst(RegExp(r'\bare\b', caseSensitive: false), 'is');
  }
  if (lower.contains('i was ')) {
    return model.replaceFirst(RegExp(r'\bwas\b', caseSensitive: false), '');
  }
  if (lower.contains('they were ')) {
    return model.replaceFirst(RegExp(r'\bwere\b', caseSensitive: false), 'was');
  }
  if (lower.contains('watched')) return replaceWord('watched', 'watch');
  if (lower.contains('went')) return replaceWord('went', 'go');
  if (lower.contains('works')) return replaceWord('works', 'work');
  if (lower.contains('studies')) return replaceWord('studies', 'study');

  final words = model
      .replaceAll(RegExp(r'[.!?]+$'), '')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: true);
  if (words.length >= 4) {
    words.insert(1, 'not');
    return '${words.join(' ')}.';
  }
  return 'This sentence not follows the target pattern.';
}

String? _firstGoodSentence(List<String> values) {
  for (final value in values) {
    final sentence = _singleSentence(value);
    if (_isGoodModel(sentence)) return sentence;
  }
  return null;
}

String _singleSentence(String value) {
  final clean = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (clean.isEmpty) return '';
  final match = RegExp(r'^(.+?[.!?])(?:\s+|$)').firstMatch(clean);
  final first = (match?.group(1) ?? clean).trim();
  return first.length > 120 ? first.substring(0, 120).trim() : first;
}

bool _looksLikeGrammarPatternSample(String value) {
  final clean = value.trim();
  final lower = clean.toLowerCase();
  if (clean.isEmpty) return true;
  if (clean.contains('→') || clean.contains('->')) return true;
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

bool _looksLikeFullGrammarSentence(String value) {
  final clean = value.trim();
  if (_looksLikeGrammarPatternSample(clean)) return false;
  final words =
      clean.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).length;
  if (words < 4) return false;
  return RegExp(r'[a-zA-Z]').hasMatch(clean) &&
      (clean.endsWith('.') || clean.endsWith('?') || clean.endsWith('!'));
}

bool _isGoodModel(String value) {
  final clean = value.trim();
  if (clean.length < 5) return false;
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
  return _looksLikeFullGrammarSentence(clean);
}

bool _isGoodAvoid(String value) {
  final clean = value.trim();
  if (clean.length < 4) return false;
  final lower = clean.toLowerCase();
  if (lower.startsWith('use ') ||
      lower.startsWith('avoid ') ||
      lower.startsWith('remember ')) {
    return false;
  }
  return _looksLikeFullGrammarSentence(clean);
}

bool _same(String a, String b) =>
    a.trim().toLowerCase() == b.trim().toLowerCase();

// -----------------------------------------------------------------------------
// Context Generator
// Phase169: Context content also lives in the generator, not in the screen.
// The screen must only render the pack returned by generateGrammarContextPack.
// UI language can be Turkish, but dialogue examples intentionally stay English.
// -----------------------------------------------------------------------------

class GrammarContextPack {
  final IconData heroIcon;
  final List<IconData> backgroundIcons;
  final String title;
  final String subtitle;
  final String scene;
  final List<GrammarContextDialogueLine> dialogueLines;
  final List<GrammarContextScenario> scenarios;
  final String tip;

  const GrammarContextPack({
    required this.heroIcon,
    required this.backgroundIcons,
    required this.title,
    required this.subtitle,
    required this.scene,
    required this.dialogueLines,
    required this.scenarios,
    required this.tip,
  });
}

class GrammarContextDialogueLine {
  final String speaker;
  final String text;
  const GrammarContextDialogueLine(this.speaker, this.text);
}

class GrammarContextScenario {
  final IconData icon;
  final String title;
  final String sentence;
  final String note;
  const GrammarContextScenario(this.icon, this.title, this.sentence, this.note);
}

GrammarContextPack generateGrammarContextPack(
    GrammarLesson lesson, bool isEnglish) {
  final key = _contextKeyFor(lesson);
  final blueprintKey = _lessonKey(lesson);
  final title = lesson.bigTitle.toLowerCase();

  if (title.contains('first conditional')) {
    return _firstConditionalContext(isEnglish);
  }
  if (title.contains('advanced modality')) {
    return _modalPerfectsContext(isEnglish);
  }
  if (title.contains('reduced clauses')) {
    return _reducedClausesContext(isEnglish);
  }

  if (blueprintKey.startsWith('a1_')) {
    return _a1LessonSpecificContext(lesson, blueprintKey, isEnglish);
  }
  if (blueprintKey == 'b2_future_perfect' ||
      blueprintKey == 'b1_future_perfect_intro') {
    return _futurePerfectContext(isEnglish);
  }
  if (blueprintKey == 'b2_future_perfect_continuous') {
    return _futurePerfectContinuousContext(isEnglish);
  }
  if (blueprintKey == 'a2_may_might') {
    return _mayMightContext(isEnglish);
  }
  if (blueprintKey == 'a2_would_like') {
    return _wouldLikeContext(isEnglish);
  }
  if (blueprintKey == 'a2_present_continuous_future') {
    return _presentContinuousFutureContext(isEnglish);
  }

  if (blueprintKey == 'b1_modal_verbs' || blueprintKey == 'b1_modals') {
    return _b1ModalsContext(isEnglish);
  }
  if (blueprintKey == 'b2_modal_perfects') {
    return _modalPerfectsContext(isEnglish);
  }
  if (blueprintKey == 'c1_advanced_modality') {
    return _modalPerfectsContext(isEnglish);
  }
  if (blueprintKey == 'c1_reduced_clauses') {
    return _reducedClausesContext(isEnglish);
  }
  if (blueprintKey == 'b1_first_conditional') {
    return _firstConditionalContext(isEnglish);
  }
  if (blueprintKey == 'b2_modal_deduction') {
    return _modalDeductionContext(isEnglish);
  }
  if (blueprintKey == 'b1_reported_commands') {
    return _reportedCommandsContext(isEnglish);
  }
  if (blueprintKey == 'c2_advanced_concession') {
    return _advancedConcessionContext(isEnglish);
  }

  if (blueprintKey == 'b2_inversion_intro' ||
      blueprintKey == 'c1_full_inversion' ||
      blueprintKey == 'c1_inversion' ||
      blueprintKey == 'c2_stylistic_inversion') {
    return _inversionContext(isEnglish);
  }

  if (_hasAny(key, [
    'past continuous',
    'past progressive',
    'was/were + v-ing',
    'was / were + v-ing',
    'interrupted action'
  ])) {
    return _pastContinuousContext(isEnglish);
  }
  if (_hasAny(key, [
    'past simple',
    'simple past',
    'v2',
    'did / didn',
    'did not',
    'finished past'
  ])) {
    return _pastSimpleContext(isEnglish);
  }
  if (_hasAny(key, ['present perfect vs past simple', 'have/has + v3 vs v2'])) {
    return _presentPerfectVsPastSimpleContext(isEnglish);
  }
  if (_hasAny(key, [
    'present perfect',
    'have/has + v3',
    'ever',
    'never',
    'already',
    'yet'
  ])) {
    return _presentPerfectContext(isEnglish);
  }
  if (_hasAny(key, [
    'present continuous',
    'present progressive',
    'am/is/are + v-ing',
    'am / is / are + v-ing',
    'happening now'
  ])) {
    return _presentContinuousContext(isEnglish);
  }
  if (_hasAny(key, ['present simple vs continuous'])) {
    return _presentSimpleVsContinuousContext(isEnglish);
  }
  if (_hasAny(key, [
    'present simple',
    'simple present',
    'do/does',
    'daily routine',
    'routines',
    'habits'
  ])) {
    return _presentSimpleContext(isEnglish);
  }
  if (_hasAny(key, [
    'comparative',
    'comparatives',
    'comparison',
    'more + adjective',
    '-er than',
    'than'
  ])) {
    return _comparativesContext(isEnglish);
  }
  if (_hasAny(key, ['superlative', 'the most', 'the -est'])) {
    return _superlativesContext(isEnglish);
  }
  if (_hasAny(key, [
    'must',
    'have to',
    'mustn',
    'obligation',
    'necessity',
    'don’t have to',
    "don't have to"
  ])) {
    return _mustHaveToContext(isEnglish);
  }
  if (_hasAny(key, ['should', 'shouldn'])) {
    return _shouldContext(isEnglish);
  }
  if (_hasAny(key, ['first conditional'])) {
    return _firstConditionalContext(isEnglish);
  }
  if (_hasAny(key, ['second conditional'])) {
    return _secondConditionalContext(isEnglish);
  }
  if (_hasAny(key, ['third conditional'])) {
    return _thirdConditionalContext(isEnglish);
  }
  if (_hasAny(key, ['will', 'future simple'])) {
    return _willContext(isEnglish);
  }
  if (_hasAny(key, ['going to', 'be going to'])) {
    return _goingToContext(isEnglish);
  }
  if (_hasAny(key, ['can', 'can’t', "can't", 'ability', 'permission'])) {
    return _canContext(isEnglish);
  }
  if (_hasAny(key, ['there is', 'there are'])) {
    return _thereIsAreContext(isEnglish);
  }
  if (_hasAny(key, [
    'article',
    'articles',
    'a/an',
    'a / an',
    'a an the',
    'indefinite article',
    'definite article'
  ])) {
    return _articlesContext(isEnglish);
  }
  if (_hasAny(key, ['some / any', 'some and any', 'some any'])) {
    return _someAnyContext(isEnglish);
  }
  if (_hasAny(key, ['how much', 'how many'])) {
    return _howMuchManyContext(isEnglish);
  }
  if (_hasAny(key, ['passive'])) {
    return _passiveContext(isEnglish);
  }
  if (_hasAny(key, ['reported speech'])) {
    return _reportedSpeechContext(isEnglish);
  }
  if (_hasAny(key, [
    'relative clause',
    'relative clauses',
    'who which that',
    'relative pronoun'
  ])) {
    return _relativeClausesContext(isEnglish);
  }
  if (_hasAny(key, ['wish', 'if only'])) {
    return _wishContext(isEnglish);
  }
  if (_hasAny(key, ['inversion', 'never have i', 'only then did'])) {
    return _inversionContext(isEnglish);
  }
  if (_hasAny(key, ['cleft'])) {
    return _cleftContext(isEnglish);
  }

  if (_hasAny(key, ['nominalisation', 'nominalization', 'noun phrase style'])) {
    return _nominalisationContext(isEnglish);
  }
  if (_hasAny(
      key, ['hedging', 'academic caution', 'it appears that', 'tends to'])) {
    return _hedgingContext(isEnglish);
  }
  if (_hasAny(key, ['ellipsis', 'substitution', 'do so', 'think so'])) {
    return _ellipsisSubstitutionContext(isEnglish);
  }
  if (_hasAny(key, ['fronting', 'information flow', 'marked word order'])) {
    return _frontingContext(isEnglish);
  }
  if (_hasAny(key, [
    'advanced conditional',
    'were it not for',
    'had it not been for',
    'should you need'
  ])) {
    return _advancedConditionalsContext(isEnglish);
  }
  if (_hasAny(key, [
    'discourse marker',
    'that said',
    'be that as it may',
    'for that matter'
  ])) {
    return _discourseMarkersContext(isEnglish);
  }
  if (_hasAny(key, [
    'register',
    'style control',
    'formal style',
    'academic style',
    'polite request',
    'formal email'
  ])) {
    return _registerStyleContext(isEnglish);
  }

  return _fallbackContext(lesson, isEnglish);
}

String _contextKeyFor(GrammarLesson lesson) {
  return _normalizedKey(
    '${lesson.bigTitle} ${lesson.oneLineGoal} ${lesson.teacherIntro} '
    '${lesson.formulaRows.map((e) => '${e.label} ${e.pattern} ${e.sample}').join(' ')} '
    '${lesson.examples.join(' ')} ${lesson.right} ${lesson.wrong} ${lesson.modelAnswer}',
  );
}

bool _hasAny(String key, List<String> words) {
  final normalizedKey = _normalizedKey(key);
  return words.any((w) => normalizedKey.contains(_normalizedKey(w)));
}

String _normalizedKey(String value) {
  return value
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll('‘', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('cannot', "can't")
      .replaceAll('can not', "can't")
      .replaceAll('can’t', "can't")
      .replaceAll('mustn’t', "mustn't")
      .replaceAll('shouldn’t', "shouldn't")
      .replaceAll('don’t', "don't");
}

String _cx(bool isEnglish, String en, String tr) => isEnglish ? en : tr;
GrammarContextDialogueLine _d(String speaker, String text) =>
    GrammarContextDialogueLine(speaker, text);
GrammarContextScenario _s(
        IconData icon, String title, String sentence, String note) =>
    GrammarContextScenario(icon, title, sentence, note);

GrammarContextPack _a1LessonSpecificContext(
    GrammarLesson lesson, String key, bool e) {
  switch (key) {
    case 'a1_be_verb':
      return GrammarContextPack(
        heroIcon: Icons.person_rounded,
        backgroundIcons: const [
          Icons.school_rounded,
          Icons.mood_rounded,
          Icons.location_on_rounded
        ],
        title: _cx(e, 'Before you start speaking', 'Konuşmaya başlamadan önce'),
        subtitle: _cx(e, 'Quick “am / is / are” sentences',
            'Kısa “am / is / are” cümleleri'),
        scene: _cx(
            e,
            'You are in class and you want to speak in simple sentences.',
            'Sınıftasın ve basit cümlelerle kendini ifade etmek istiyorsun.'),
        dialogueLines: [
          _d('A', 'Are you ready?'),
          _d('B', 'Yes, I am. Let’s start.'),
          _d('A', 'Is your friend tired?'),
          _d('B', 'Yes, she is tired today.'),
        ],
        scenarios: [
          _s(
              Icons.school_rounded,
              _cx(e, 'Before the lesson', 'Ders başlamadan önce'),
              'I am ready for the lesson.',
              _cx(e, 'A natural line when you are about to begin.',
                  'Başlamadan önce kendini hazır hissedince söyleyebilirsin.')),
          _s(
              Icons.people_rounded,
              _cx(e, 'Describing a friend', 'Bir arkadaşını anlatırken'),
              'She is tired today.',
              _cx(e, 'Useful when you talk about someone’s feeling.',
                  'Birinin nasıl hissettiğini anlatırken kullanılır.')),
          _s(
              Icons.location_on_rounded,
              _cx(e, 'Saying where people are', 'Nerede olduklarını söylerken'),
              'They are in the classroom.',
              _cx(e, 'Useful when someone asks “Where are they?”',
                  'Biri “Neredeler?” diye sorunca kullanırsın.')),
        ],
        tip: _cx(e, 'Say it short and clear. You can answer with: “Yes, I am.”',
            'Kısa ve net söyle. Kısa cevap: “Yes, I am.”'),
      );
    case 'a1_subject_pronouns':
      return GrammarContextPack(
        heroIcon: Icons.person_rounded,
        backgroundIcons: const [
          Icons.people_alt_rounded,
          Icons.badge_rounded,
          Icons.chat_rounded
        ],
        title: _cx(e, 'Introduce people simply', 'İnsanları basitçe tanıt'),
        subtitle: _cx(e, 'I, you, he, she, it, we, they',
            'I, you, he, she, it, we, they'),
        scene: _cx(
            e,
            'You are meeting someone and talking about yourself and others.',
            'Birisiyle tanışıyor, kendinden ve başkalarından bahsediyorsun.'),
        dialogueLines: [
          _d('A', 'Hi. I am Deniz.'),
          _d('B', 'Nice to meet you. I am Alex.'),
          _d('A', 'Is she your friend?'),
          _d('B', 'Yes, she is.'),
        ],
        scenarios: [
          _s(
              Icons.badge_rounded,
              _cx(e, 'First meeting', 'İlk tanışma'),
              'I am from Turkey.',
              _cx(e, 'A simple sentence to start a conversation.',
                  'Sohbete başlamak için çok kullanışlı.')),
          _s(
              Icons.person_rounded,
              _cx(e, 'Talking about one person', 'Bir kişiden bahsederken'),
              'He is my teacher.',
              _cx(e, 'Use it when you point to one person.',
                  'Tek bir kişiyi gösterdiğinde kullanırsın.')),
          _s(
              Icons.people_alt_rounded,
              _cx(e, 'Talking about a group', 'Bir gruptan bahsederken'),
              'They are my friends.',
              _cx(e, 'Useful when you talk about more than one person.',
                  'Birden fazla kişi için kullanırsın.')),
        ],
        tip: _cx(
            e,
            'In real talk, keep it simple: I / you / he / she / we / they.',
            'Gerçek konuşmada basit tut: I / you / he / she / we / they.'),
      );
    case 'a1_possessive_adjectives':
      return GrammarContextPack(
        heroIcon: Icons.key_rounded,
        backgroundIcons: const [
          Icons.shopping_bag_rounded,
          Icons.phone_iphone_rounded,
          Icons.key_rounded
        ],
        title: _cx(e, 'Talk about your things', 'Eşya ve sahiplik konuş'),
        subtitle: _cx(e, 'my / your / his / her / our / their',
            'my / your / his / her / our / their'),
        scene: _cx(
            e,
            'You are identifying items in real life: phone, bag, keys...',
            'Gündelik hayatta eşyaları tanıtıyorsun: telefon, çanta, anahtar...'),
        dialogueLines: [
          _d('A', 'Is this your phone?'),
          _d('B', 'Yes, it is my phone.'),
          _d('A', 'Where is her bag?'),
          _d('B', 'Her bag is on the chair.'),
        ],
        scenarios: [
          _s(
              Icons.phone_iphone_rounded,
              _cx(e, 'Finding your phone', 'Telefonunu ararken'),
              'This is my phone.',
              _cx(e, 'Say it when you identify your item.',
                  'Kendi eşyanı gösterirken söyleyebilirsin.')),
          _s(
              Icons.shopping_bag_rounded,
              _cx(e, 'In a cafe', 'Kafede'),
              'Is this your seat?',
              _cx(e, 'A friendly question in public places.',
                  'Kalabalık yerde kibarca sorabilirsin.')),
          _s(
              Icons.home_rounded,
              _cx(e, 'Talking about family', 'Aileden bahsederken'),
              'Their house is near the school.',
              _cx(e, 'Use it when you talk about other people’s things.',
                  'Başkalarının eşyası/evinden bahsederken kullanılır.')),
        ],
        tip: _cx(
            e,
            'In conversation, it’s very common to say: my bag, your seat, his phone.',
            'Konuşmada çok geçen kalıplar: my bag, your seat, his phone.'),
      );
    case 'a1_articles':
      return GrammarContextPack(
        heroIcon: Icons.article_rounded,
        backgroundIcons: const [
          Icons.shopping_cart_rounded,
          Icons.pets_rounded,
          Icons.article_rounded
        ],
        title: _cx(e, 'Tell a simple story', 'Kısa bir hikâye anlat'),
        subtitle: _cx(
            e, 'a / an / the in real talk', 'Gerçek konuşmada a / an / the'),
        scene: _cx(e, 'You saw something and you are telling it to a friend.',
            'Bir şey gördün ve arkadaşına anlatıyorsun.'),
        dialogueLines: [
          _d('A', 'What happened?'),
          _d('B', 'I saw a dog. The dog was very small.'),
          _d('A', 'Really?'),
          _d('B', 'Yes, it was cute.'),
        ],
        scenarios: [
          _s(
              Icons.pets_rounded,
              _cx(e, 'On the street', 'Sokakta'),
              'I saw a dog in the street.',
              _cx(e, 'A natural sentence when you tell what you saw.',
                  'Gördüğün bir şeyi anlatırken kullanırsın.')),
          _s(
              Icons.pets_rounded,
              _cx(e, 'Talking about it again', 'Tekrar bahsederken'),
              'The dog was very small.',
              _cx(e, 'Use it when you continue the same story.',
                  'Aynı hikâyeyi devam ettirirken kullanılır.')),
          _s(
              Icons.shopping_cart_rounded,
              _cx(e, 'In a shop', 'Mağazada'),
              'I need an umbrella, please.',
              _cx(e, 'Useful when you ask for something politely.',
                  'Bir şey isterken kibarca söyleyebilirsin.')),
        ],
        tip: _cx(e, 'Keep the story flowing: one short sentence at a time.',
            'Akışı bozmadan anlat: tek tek, kısa cümlelerle.'),
      );
    case 'a1_singular_plural':
      return GrammarContextPack(
        heroIcon: Icons.format_list_numbered_rounded,
        backgroundIcons: const [
          Icons.shopping_basket_rounded,
          Icons.backpack_rounded,
          Icons.format_list_numbered_rounded
        ],
        title: _cx(e, 'Count what you need', 'İhtiyacını say'),
        subtitle: _cx(e, 'one book / two books', 'one book / two books'),
        scene: _cx(
            e,
            'You are shopping or packing and you need to say quantities.',
            'Alışveriş yapıyor veya çantanı hazırlıyorsun.'),
        dialogueLines: [
          _d('A', 'Do you need anything?'),
          _d('B', 'Yes. I need two bottles of water.'),
          _d('A', 'Anything else?'),
          _d('B', 'One notebook, please.'),
        ],
        scenarios: [
          _s(
              Icons.shopping_basket_rounded,
              _cx(e, 'At the market', 'Markette'),
              'I need two apples.',
              _cx(e, 'Use it when you ask for more than one item.',
                  'Birden fazla ürün isterken kullanılır.')),
          _s(
              Icons.backpack_rounded,
              _cx(e, 'Packing your bag', 'Çantanı hazırlarken'),
              'I have one notebook in my bag.',
              _cx(e, 'Useful to say what you have.',
                  'Çantanda ne var anlatırken kullanırsın.')),
          _s(
              Icons.home_rounded,
              _cx(e, 'At home', 'Evde'),
              'There are three chairs in the kitchen.',
              _cx(e, 'A simple way to describe your home.',
                  'Evi tarif ederken kullanışlı.')),
        ],
        tip: _cx(e, 'In daily life, numbers + nouns appear all the time.',
            'Gündelik hayatta sayılarla isimleri çok kullanırsın.'),
      );
    case 'a1_demonstratives':
      return GrammarContextPack(
        heroIcon: Icons.touch_app_rounded,
        backgroundIcons: const [
          Icons.touch_app_rounded,
          Icons.shopping_bag_rounded,
          Icons.photo_camera_rounded
        ],
        title: _cx(e, 'Point and ask', 'Göster ve sor'),
        subtitle: _cx(
            e, 'this / that / these / those', 'this / that / these / those'),
        scene: _cx(e, 'You are pointing at objects while speaking.',
            'Konuşurken bir şeye işaret ediyorsun.'),
        dialogueLines: [
          _d('A', 'Is this your bag?'),
          _d('B', 'No, that bag is mine.'),
          _d('A', 'What are those?'),
          _d('B', 'Those are my keys.'),
        ],
        scenarios: [
          _s(
              Icons.shopping_bag_rounded,
              _cx(e, 'On the table', 'Masada'),
              'This is my bag.',
              _cx(e, 'Say it when something is close to you.',
                  'Yakınındaki bir şeyi gösterirken kullanırsın.')),
          _s(
              Icons.place_rounded,
              _cx(e, 'Across the room', 'Odanın öbür tarafında'),
              'That is my teacher.',
              _cx(e, 'Useful when you point to someone far.',
                  'Uzak birini gösterirken kullanılır.')),
          _s(
              Icons.vpn_key_rounded,
              _cx(e, 'More than one', 'Birden fazla'),
              'These are my keys.',
              _cx(e, 'Useful when you hold or show several items.',
                  'Birden fazla eşyayı gösterirken kullanılır.')),
        ],
        tip: _cx(e, 'Point with your hand and say one short sentence.',
            'Elinle göster, tek kısa cümle kur.'),
      );
    case 'a1_have_has_got':
      return GrammarContextPack(
        heroIcon: Icons.inventory_2_rounded,
        backgroundIcons: const [
          Icons.family_restroom_rounded,
          Icons.inventory_2_rounded,
          Icons.school_rounded
        ],
        title: _cx(e, 'Talk about what you have', 'Sahip olduklarını söyle'),
        subtitle: _cx(
            e, 'family, things, simple descriptions', 'aile, eşya, kısa tarif'),
        scene: _cx(e, 'You are describing your family and your belongings.',
            'Aileni ve eşyalarını anlatıyorsun.'),
        dialogueLines: [
          _d('A', 'Have you got a pen?'),
          _d('B', 'Yes, I have. Here you are.'),
          _d('A', 'Has your sister got a bike?'),
          _d('B', 'No, she hasn’t.'),
        ],
        scenarios: [
          _s(
              Icons.school_rounded,
              _cx(e, 'In class', 'Sınıfta'),
              'Have you got a pen?',
              _cx(e, 'A very common question in class.',
                  'Sınıfta çok kullanılan bir soru.')),
          _s(
              Icons.family_restroom_rounded,
              _cx(e, 'Talking about family', 'Aileden bahsederken'),
              'She has got two brothers.',
              _cx(e, 'Useful when you introduce your family.',
                  'Aileni tanıtırken kullanırsın.')),
          _s(
              Icons.inventory_2_rounded,
              _cx(e, 'Your belongings', 'Eşyaların'),
              'I have got a small bag.',
              _cx(e, 'Useful when you describe what you carry.',
                  'Yanında ne var anlatırken kullanırsın.')),
        ],
        tip: _cx(e, 'Use it for quick, everyday talk about family and things.',
            'Aile ve eşya için hızlı, günlük konuşmada kullan.'),
      );
    case 'a1_there_is_are':
      return GrammarContextPack(
        heroIcon: Icons.location_on_rounded,
        backgroundIcons: const [
          Icons.home_rounded,
          Icons.location_on_rounded,
          Icons.map_rounded
        ],
        title: _cx(e, 'Describe a place', 'Bir yeri tarif et'),
        subtitle: _cx(e, 'rooms, streets, simple descriptions',
            'oda, sokak, basit tarif'),
        scene: _cx(e, 'You are describing what exists in a room or area.',
            'Bir odada ya da yerde ne var anlatıyorsun.'),
        dialogueLines: [
          _d('A', 'Is there a supermarket near here?'),
          _d('B', 'Yes, there is.'),
          _d('A', 'Are there any cafés on this street?'),
          _d('B', 'Yes, there are two cafés.'),
        ],
        scenarios: [
          _s(
              Icons.home_rounded,
              _cx(e, 'In your room', 'Odanda'),
              'There is a desk in my room.',
              _cx(e, 'A simple way to describe your room.',
                  'Odanı tarif ederken kullanırsın.')),
          _s(
              Icons.restaurant_rounded,
              _cx(e, 'In a café', 'Kafede'),
              'There are two free tables.',
              _cx(e, 'Useful when you talk about places in public.',
                  'Dışarıda yer durumu anlatırken kullanılır.')),
          _s(
              Icons.map_rounded,
              _cx(e, 'In the city', 'Şehirde'),
              'There is a bus stop near my house.',
              _cx(e, 'Useful when you give basic location info.',
                  'Yer tarifi yaparken kullanışlı.')),
        ],
        tip: _cx(e, 'Keep it real: describe what you see around you.',
            'Gerçek hayata bağla: etrafında gördüğünü anlat.'),
      );
    case 'a1_can_cant':
      return GrammarContextPack(
        heroIcon: Icons.bolt_rounded,
        backgroundIcons: const [
          Icons.sports_handball_rounded,
          Icons.school_rounded,
          Icons.bolt_rounded
        ],
        title: _cx(e, 'Talk about ability', 'Yetenek konuş'),
        subtitle:
            _cx(e, 'skills and simple permission', 'yetenek ve basit izin'),
        scene: _cx(
            e,
            'You are talking about what you can do and asking simple permission.',
            'Yapabildiklerini söylüyor ve basit izin istiyorsun.'),
        dialogueLines: [
          _d('A', 'Can you swim?'),
          _d('B', 'Yes, I can.'),
          _d('A', 'Can I sit here?'),
          _d('B', 'Yes, you can.'),
        ],
        scenarios: [
          _s(
              Icons.sports_handball_rounded,
              _cx(e, 'At the gym', 'Sporda'),
              'I can run fast.',
              _cx(e, 'Use it when you talk about your skills.',
                  'Yeteneklerinden bahsederken kullanırsın.')),
          _s(
              Icons.school_rounded,
              _cx(e, 'In class', 'Sınıfta'),
              'Can you help me, please?',
              _cx(e, 'A polite way to ask for help.',
                  'Yardım isterken kibarca söyleyebilirsin.')),
          _s(
              Icons.block_rounded,
              _cx(e, 'Saying you can’t', 'Yapamadığını söylemek'),
              'I can’t drive.',
              _cx(e, 'Useful when you set a limit.',
                  'Bir şeyin mümkün olmadığını söylediğinde kullanılır.')),
        ],
        tip: _cx(
            e,
            'Real beginners can use it everywhere: Can you…? I can / I can’t.',
            'Başlangıç için her yerde kullan: Can you…? I can / I can’t.'),
      );
    case 'a1_imperatives':
      return GrammarContextPack(
        heroIcon: Icons.campaign_rounded,
        backgroundIcons: const [
          Icons.school_rounded,
          Icons.warning_rounded,
          Icons.campaign_rounded
        ],
        title: _cx(e, 'Give simple instructions', 'Basit talimat ver'),
        subtitle: _cx(e, 'classroom, home, signs', 'sınıf, ev, tabelalar'),
        scene: _cx(e, 'You need quick, direct language to guide someone.',
            'Birini yönlendirmek için hızlı ve net bir dile ihtiyacın var.'),
        dialogueLines: [
          _d('A', 'Please sit down.'),
          _d('B', 'Okay.'),
          _d('A', 'Don’t use your phone.'),
          _d('B', 'Sorry.'),
        ],
        scenarios: [
          _s(
              Icons.school_rounded,
              _cx(e, 'In the classroom', 'Sınıfta'),
              'Open your book, please.',
              _cx(e, 'A friendly teacher instruction.',
                  'Sınıfta öğretmen dili gibi düşün.')),
          _s(
              Icons.home_rounded,
              _cx(e, 'At home', 'Evde'),
              'Close the window.',
              _cx(e, 'Useful when you give a simple instruction.',
                  'Basit bir rica/yönerge verirken kullanılır.')),
          _s(
              Icons.warning_rounded,
              _cx(e, 'Safety', 'Güvenlik'),
              'Don’t touch that!',
              _cx(e, 'Useful for a quick warning.', 'Acil uyarıda çok doğal.')),
        ],
        tip: _cx(e, 'Short instructions are powerful: one verb is enough.',
            'Kısa talimat etkilidir: tek bir fiil yeter.'),
      );
    case 'a1_present_simple_positive':
      return GrammarContextPack(
        heroIcon: Icons.repeat_rounded,
        backgroundIcons: const [
          Icons.alarm_rounded,
          Icons.repeat_rounded,
          Icons.coffee_rounded
        ],
        title: _cx(e, 'Talk about your routine', 'Rutinini anlat'),
        subtitle:
            _cx(e, 'daily habits and facts', 'günlük alışkanlık ve gerçek'),
        scene: _cx(e, 'You are telling someone what you do in normal life.',
            'Birine normal hayatta ne yaptığını anlatıyorsun.'),
        dialogueLines: [
          _d('A', 'What time do you get up?'),
          _d('B', 'I get up at seven.'),
          _d('A', 'What does your brother do?'),
          _d('B', 'He works in a shop.'),
        ],
        scenarios: [
          _s(
              Icons.alarm_rounded,
              _cx(e, 'Morning routine', 'Sabah rutini'),
              'I get up at seven.',
              _cx(e, 'A very common daily routine line.',
                  'Günde birçok kez kullanılan rutin cümle.')),
          _s(
              Icons.work_rounded,
              _cx(e, 'Work life', 'İş hayatı'),
              'She works in a cafe.',
              _cx(e, 'Use it when you describe someone’s routine.',
                  'Birinin rutini/işi için kullanılır.')),
          _s(
              Icons.school_rounded,
              _cx(e, 'School life', 'Okul hayatı'),
              'We study English after class.',
              _cx(e, 'Useful when you talk about habits at school.',
                  'Okuldaki alışkanlıklar için güzel.')),
        ],
        tip: _cx(e, 'Add simple time words: every day, on Mondays, at night.',
            'Basit zaman sözleri ekle: every day, on Mondays, at night.'),
      );
    case 'a1_present_simple_negative':
      return GrammarContextPack(
        heroIcon: Icons.block_rounded,
        backgroundIcons: const [
          Icons.block_rounded,
          Icons.fastfood_rounded,
          Icons.schedule_rounded
        ],
        title: _cx(e, 'Say what you don’t do', 'Yapmadığını söyle'),
        subtitle:
            _cx(e, 'simple negatives in daily life', 'günlük hayatta olumsuz'),
        scene: _cx(
            e,
            'You are talking about preferences and habits you don’t have.',
            'Sevmediğin veya yapmadığın alışkanlıkları anlatıyorsun.'),
        dialogueLines: [
          _d('A', 'Do you drink coffee?'),
          _d('B', 'No, I don’t.'),
          _d('A', 'Does he eat meat?'),
          _d('B', 'No, he doesn’t.'),
        ],
        scenarios: [
          _s(
              Icons.fastfood_rounded,
              _cx(e, 'Food preferences', 'Yemek tercihi'),
              'I don’t eat meat.',
              _cx(e, 'Use it when you talk about your diet.',
                  'Beslenme alışkanlığını anlatırken kullanırsın.')),
          _s(
              Icons.nights_stay_rounded,
              _cx(e, 'Sleep habits', 'Uyku alışkanlığı'),
              'She doesn’t go to bed late.',
              _cx(e, 'Useful when you talk about someone’s routine.',
                  'Birinin rutininde ne yapmadığını anlatırsın.')),
          _s(
              Icons.smoke_free_rounded,
              _cx(e, 'Lifestyle', 'Yaşam tarzı'),
              'We don’t smoke at home.',
              _cx(e, 'A clear sentence for daily life.',
                  'Günlük hayatta net bir cümle.')),
        ],
        tip: _cx(
            e,
            'Negatives are common in real life: I don’t… / She doesn’t…',
            'Olumsuz cümleler çok kullanılır: I don’t… / She doesn’t…'),
      );
    case 'a1_present_simple_questions':
      return GrammarContextPack(
        heroIcon: Icons.help_rounded,
        backgroundIcons: const [
          Icons.help_rounded,
          Icons.people_alt_rounded,
          Icons.coffee_rounded
        ],
        title: _cx(e, 'Ask simple questions', 'Basit sorular sor'),
        subtitle: _cx(e, 'daily questions with Do / Does',
            'Do / Does ile günlük sorular'),
        scene: _cx(e, 'You are meeting people and asking about routines.',
            'İnsanlarla tanışıp rutinlerini soruyorsun.'),
        dialogueLines: [
          _d('A', 'Do you work here?'),
          _d('B', 'Yes, I do.'),
          _d('A', 'Does she speak English?'),
          _d('B', 'No, she doesn’t.'),
        ],
        scenarios: [
          _s(
              Icons.work_rounded,
              _cx(e, 'At work', 'İşte'),
              'Do you work on Saturdays?',
              _cx(e, 'A simple routine question.',
                  'Rutin sorularının en temeli.')),
          _s(
              Icons.people_alt_rounded,
              _cx(e, 'About someone', 'Başkası hakkında'),
              'Does your brother play football?',
              _cx(e, 'Useful when you ask about another person.',
                  'Başkasını sorarken çok kullanışlı.')),
          _s(
              Icons.coffee_rounded,
              _cx(e, 'Preferences', 'Tercih'),
              'Do you like tea?',
              _cx(e, 'A friendly small-talk question.',
                  'Sohbet açmak için güzel.')),
        ],
        tip: _cx(e, 'In conversation, keep it short: Do you…? Does she…?',
            'Konuşmada kısa tut: Do you…? Does she…?'),
      );
    case 'a1_adverbs_frequency':
      return GrammarContextPack(
        heroIcon: Icons.schedule_rounded,
        backgroundIcons: const [
          Icons.schedule_rounded,
          Icons.fitness_center_rounded,
          Icons.restaurant_rounded
        ],
        title: _cx(e, 'Describe how often', 'Ne sıklıkla, anlat'),
        subtitle: _cx(e, 'always / usually / sometimes / never',
            'always / usually / sometimes / never'),
        scene: _cx(e, 'You are talking about your routine with more detail.',
            'Rutinini daha detaylı anlatıyorsun.'),
        dialogueLines: [
          _d('A', 'Do you cook at home?'),
          _d('B', 'Yes, I usually cook at home.'),
          _d('A', 'Do you eat fast food?'),
          _d('B', 'No, I never eat fast food.'),
        ],
        scenarios: [
          _s(
              Icons.restaurant_rounded,
              _cx(e, 'Food habits', 'Yemek alışkanlığı'),
              'I usually cook at home.',
              _cx(e, 'Use it when you talk about your normal routine.',
                  'Normal rutini anlatırken çok doğal.')),
          _s(
              Icons.fitness_center_rounded,
              _cx(e, 'Exercise', 'Spor'),
              'She sometimes goes to the gym.',
              _cx(e, 'Useful when it is not every day.',
                  'Her gün değilse kullanışlı.')),
          _s(
              Icons.access_time_rounded,
              _cx(e, 'Being late', 'Geç kalma'),
              'He is never late.',
              _cx(e, 'A strong statement about someone’s habit.',
                  'Bir alışkanlığı güçlü şekilde söylemek için.')),
        ],
        tip: _cx(e, 'These words make your speaking more natural.',
            'Bu kelimeler konuşmanı daha doğal yapar.'),
      );
    case 'a1_present_continuous':
      return GrammarContextPack(
        heroIcon: Icons.timelapse_rounded,
        backgroundIcons: const [
          Icons.phone_rounded,
          Icons.timelapse_rounded,
          Icons.chat_bubble_rounded
        ],
        title: _cx(e, 'Talk about “now”', 'Şu anı anlat'),
        subtitle: _cx(e, 'what is happening right now', 'şu an olan eylem'),
        scene: _cx(e, 'You are on the phone and describing what you are doing.',
            'Telefondasın ve şu an ne yaptığını söylüyorsun.'),
        dialogueLines: [
          _d('A', 'What are you doing?'),
          _d('B', 'I am studying right now.'),
          _d('A', 'Is your brother sleeping?'),
          _d('B', 'No, he is watching a video.'),
        ],
        scenarios: [
          _s(
              Icons.phone_rounded,
              _cx(e, 'On the phone', 'Telefonda'),
              'I am studying right now.',
              _cx(e, 'A common answer when someone calls you.',
                  'Biri arayınca çok doğal bir cevap.')),
          _s(
              Icons.home_rounded,
              _cx(e, 'At home', 'Evde'),
              'She is cooking dinner.',
              _cx(e, 'Useful when you describe what is happening at home.',
                  'Evde şu an olan şeyi anlatırsın.')),
          _s(
              Icons.directions_walk_rounded,
              _cx(e, 'Outside', 'Dışarıda'),
              'They are waiting for the bus.',
              _cx(e, 'A natural sentence when you describe a situation.',
                  'Bir durum anlatırken çok doğal.')),
        ],
        tip: _cx(e, 'Add “now / right now” when you want to be extra clear.',
            'Daha net olmak için “now / right now” ekleyebilirsin.'),
      );
    case 'a1_present_simple_vs_continuous':
      return GrammarContextPack(
        heroIcon: Icons.compare_rounded,
        backgroundIcons: const [
          Icons.compare_rounded,
          Icons.schedule_rounded,
          Icons.timelapse_rounded
        ],
        title: _cx(e, 'Routine vs now', 'Rutin mi, şu an mı?'),
        subtitle: _cx(
            e, 'two useful sentences together', 'iki cümleyi birlikte kullan'),
        scene: _cx(
            e,
            'You are explaining what you do normally and what you are doing today.',
            'Genelde ne yaptığını ve bugün ne yaptığını ayırıyorsun.'),
        dialogueLines: [
          _d('A', 'Do you work every day?'),
          _d('B', 'I work every day, but I am not working today.'),
          _d('A', 'Why?'),
          _d('B', 'I am resting at home.'),
        ],
        scenarios: [
          _s(
              Icons.work_rounded,
              _cx(e, 'Normal routine', 'Normal rutin'),
              'She works in a bank.',
              _cx(e, 'Useful to say a permanent situation.',
                  'Kalıcı bir durumu anlatırsın.')),
          _s(
              Icons.timelapse_rounded,
              _cx(e, 'Right now', 'Şu an'),
              'She is working now.',
              _cx(e, 'Useful when you talk about the moment.',
                  'O anda olanı anlatırsın.')),
          _s(
              Icons.event_busy_rounded,
              _cx(e, 'Not today', 'Bugün değil'),
              'He usually plays football, but he is studying today.',
              _cx(e, 'Useful when today is different from normal.',
                  'Bugün rutin dışıysa çok kullanışlı.')),
        ],
        tip: _cx(e, 'In real life, people often use both in one conversation.',
            'Gerçek konuşmada ikisi aynı sohbette çok geçiyor.'),
      );
    case 'a1_object_pronouns':
      return GrammarContextPack(
        heroIcon: Icons.switch_account_rounded,
        backgroundIcons: const [
          Icons.call_rounded,
          Icons.favorite_rounded,
          Icons.switch_account_rounded
        ],
        title: _cx(
            e, 'Talk about people as objects', 'Kişileri nesne olarak söyle'),
        subtitle: _cx(e, 'me / you / him / her / us / them',
            'me / you / him / her / us / them'),
        scene: _cx(e, 'You are talking about who you call, see, help, or like.',
            'Kimi aradığını, gördüğünü, sevdiğini anlatıyorsun.'),
        dialogueLines: [
          _d('A', 'Can you call me later?'),
          _d('B', 'Yes, I can call you later.'),
          _d('A', 'Do you know him?'),
          _d('B', 'Yes, I know him.'),
        ],
        scenarios: [
          _s(
              Icons.call_rounded,
              _cx(e, 'Phone call', 'Telefon'),
              'Call me tonight.',
              _cx(e, 'A very common daily sentence.',
                  'Günlük hayatta çok kullanılır.')),
          _s(
              Icons.favorite_rounded,
              _cx(e, 'Talking about likes', 'Sevme'),
              'I like her.',
              _cx(e, 'Useful when you talk about another person.',
                  'Bir kişiden bahsederken kullanırsın.')),
          _s(
              Icons.group_rounded,
              _cx(e, 'Talking about a group', 'Grup'),
              'I see them every day.',
              _cx(e, 'Useful when you talk about more than one person.',
                  'Birden fazla kişi için kullanırsın.')),
        ],
        tip: _cx(
            e,
            'These words are very common in real speaking: call me, help us, see them.',
            'Gerçek konuşmada çok geçiyor: call me, help us, see them.'),
      );
    case 'a1_possessive_s':
      return GrammarContextPack(
        heroIcon: Icons.key_rounded,
        backgroundIcons: const [
          Icons.vpn_key_rounded,
          Icons.school_rounded,
          Icons.key_rounded
        ],
        title: _cx(e, 'Say whose it is', 'Kimin olduğunu söyle'),
        subtitle: _cx(e, "Ali’s / my mother’s / the teacher’s",
            "Ali’s / my mother’s / the teacher’s"),
        scene: _cx(
            e,
            'You are identifying the owner of an item in a real situation.',
            'Gerçek bir durumda eşyanın sahibini söylüyorsun.'),
        dialogueLines: [
          _d('A', 'Whose bag is this?'),
          _d('B', 'It is Ali’s bag.'),
          _d('A', 'Is it your bag?'),
          _d('B', 'No, it is my sister’s bag.'),
        ],
        scenarios: [
          _s(
              Icons.school_rounded,
              _cx(e, 'In the classroom', 'Sınıfta'),
              'This is the teacher’s book.',
              _cx(e, 'Useful when you return an item to someone.',
                  'Bir eşyayı sahibine verirken kullanırsın.')),
          _s(
              Icons.vpn_key_rounded,
              _cx(e, 'Lost and found', 'Kayıp eşya'),
              'Is this Ayşe’s phone?',
              _cx(e, 'Useful when you ask about ownership.',
                  'Kime ait diye sorarken kullanışlı.')),
          _s(
              Icons.family_restroom_rounded,
              _cx(e, 'Family', 'Aile'),
              'My mother’s phone is new.',
              _cx(e, 'Useful when you talk about family belongings.',
                  'Aile eşyaları için kullanılır.')),
        ],
        tip: _cx(e, 'In real life, this is very useful for lost items.',
            'Kayıp eşya durumlarında çok kullanışlı.'),
      );
    case 'a1_prepositions_place':
      return GrammarContextPack(
        heroIcon: Icons.place_rounded,
        backgroundIcons: const [
          Icons.place_rounded,
          Icons.home_rounded,
          Icons.map_rounded
        ],
        title: _cx(e, 'Describe where things are', 'Eşyalar nerede?'),
        subtitle:
            _cx(e, 'in / on / under / next to', 'in / on / under / next to'),
        scene: _cx(
            e,
            'You are giving simple location information at home or in class.',
            'Evde veya sınıfta basit yer bilgisi veriyorsun.'),
        dialogueLines: [
          _d('A', 'Where is my phone?'),
          _d('B', 'It is on the table.'),
          _d('A', 'Where are the keys?'),
          _d('B', 'They are in your bag.'),
        ],
        scenarios: [
          _s(
              Icons.table_restaurant_rounded,
              _cx(e, 'On the table', 'Masanın üstünde'),
              'The book is on the table.',
              _cx(e, 'Use it when you describe objects in a room.',
                  'Odada eşyayı tarif ederken kullanırsın.')),
          _s(
              Icons.backpack_rounded,
              _cx(e, 'In your bag', 'Çantada'),
              'My keys are in my bag.',
              _cx(e, 'Very common daily sentence.',
                  'Günlük hayatta çok geçiyor.')),
          _s(
              Icons.bed_rounded,
              _cx(e, 'Under the bed', 'Yatağın altında'),
              'The cat is under the bed.',
              _cx(e, 'Useful when you search for something.',
                  'Bir şey ararken çok kullanışlı.')),
        ],
        tip: _cx(e, 'Look around you and describe one thing you see.',
            'Etrafına bak ve gördüğün bir şeyi tarif et.'),
      );
    case 'a1_prepositions_time':
      return GrammarContextPack(
        heroIcon: Icons.access_time_rounded,
        backgroundIcons: const [
          Icons.access_time_rounded,
          Icons.calendar_today_rounded,
          Icons.event_rounded
        ],
        title: _cx(e, 'Talk about schedules', 'Program ve zaman konuş'),
        subtitle: _cx(e, 'in / on / at for time', 'zaman için in / on / at'),
        scene: _cx(e, 'You are making plans and talking about days and times.',
            'Plan yapıyor, gün ve saat söylüyorsun.'),
        dialogueLines: [
          _d('A', 'When is your lesson?'),
          _d('B', 'It is on Monday at 7.'),
          _d('A', 'Great. See you then.'),
          _d('B', 'See you.'),
        ],
        scenarios: [
          _s(
              Icons.access_time_rounded,
              _cx(e, 'Clock time', 'Saat'),
              'The class starts at 7.',
              _cx(e, 'A common sentence for schedules.',
                  'Program anlatırken çok doğal.')),
          _s(
              Icons.calendar_today_rounded,
              _cx(e, 'Day', 'Gün'),
              'I work on Monday.',
              _cx(e, 'Useful when you talk about your weekly plan.',
                  'Haftalık plan için kullanışlı.')),
          _s(
              Icons.event_rounded,
              _cx(e, 'Month', 'Ay'),
              'My birthday is in June.',
              _cx(e, 'Useful when you talk about months.',
                  'Aylarla ilgili konuşurken kullanırsın.')),
        ],
        tip: _cx(e, 'Use it in plans: on Monday, at 7, in June.',
            'Plan yaparken çok geçiyor: on Monday, at 7, in June.'),
      );
    case 'a1_some_any':
      return GrammarContextPack(
        heroIcon: Icons.shopping_cart_rounded,
        backgroundIcons: const [
          Icons.shopping_cart_rounded,
          Icons.local_cafe_rounded,
          Icons.kitchen_rounded
        ],
        title: _cx(e, 'Ask for food and small things', 'Yiyecek ve miktar sor'),
        subtitle:
            _cx(e, 'shopping and polite requests', 'alışveriş ve kibar istek'),
        scene: _cx(
            e,
            'You are at home or in a cafe and you want to ask politely.',
            'Evde ya da kafede kibarca bir şey istiyorsun.'),
        dialogueLines: [
          _d('A', 'Do we have any milk?'),
          _d('B', 'No, we don’t.'),
          _d('A', 'Can I have some water, please?'),
          _d('B', 'Sure.'),
        ],
        scenarios: [
          _s(
              Icons.kitchen_rounded,
              _cx(e, 'At home', 'Evde'),
              'We don’t have any milk.',
              _cx(e, 'Useful when you check the fridge.',
                  'Dolabı kontrol ederken çok doğal.')),
          _s(
              Icons.shopping_cart_rounded,
              _cx(e, 'Shopping list', 'Alışveriş listesi'),
              'I need some eggs.',
              _cx(e, 'Useful when you tell what you need.',
                  'İhtiyacın olan şeyi söylersin.')),
          _s(
              Icons.local_cafe_rounded,
              _cx(e, 'In a cafe', 'Kafede'),
              'Can I have some tea, please?',
              _cx(e, 'A polite request at a cafe.',
                  'Kafede kibarca istemek için.')),
        ],
        tip: _cx(
            e,
            'These sentences are common in daily life: some water, any milk.',
            'Günlük hayatta çok kullanılır: some water, any milk.'),
      );
    case 'a1_countable_uncountable':
      return GrammarContextPack(
        heroIcon: Icons.water_drop_rounded,
        backgroundIcons: const [
          Icons.shopping_basket_rounded,
          Icons.water_drop_rounded,
          Icons.kitchen_rounded
        ],
        title: _cx(e, 'Shopping and cooking talk', 'Alışveriş ve mutfak konuş'),
        subtitle: _cx(e, 'items vs materials', 'sayılan şeyler ve maddeler'),
        scene: _cx(
            e,
            'You are buying food and you need to talk about quantity.',
            'Yiyecek alıyor ve miktar söylemek istiyorsun.'),
        dialogueLines: [
          _d('A', 'Do we need anything?'),
          _d('B', 'Yes. We need some rice and two apples.'),
          _d('A', 'Okay. Let’s go.'),
          _d('B', 'Great.'),
        ],
        scenarios: [
          _s(
              Icons.shopping_basket_rounded,
              _cx(e, 'At the market', 'Markette'),
              'I need two apples.',
              _cx(e, 'A simple shopping sentence.',
                  'Alışverişte çok kullanışlı.')),
          _s(
              Icons.kitchen_rounded,
              _cx(e, 'Cooking', 'Yemek yaparken'),
              'We need some water.',
              _cx(e, 'Useful when you talk about ingredients.',
                  'Malzeme konuşurken kullanırsın.')),
          _s(
              Icons.local_grocery_store_rounded,
              _cx(e, 'At the store', 'Mağazada'),
              'Can I have some bread, please?',
              _cx(e, 'A polite request in a shop.',
                  'Mağazada kibarca istek için.')),
        ],
        tip: _cx(
            e,
            'In real life, you often mix both: two apples + some water.',
            'Gerçek hayatta ikisi birlikte gelir: two apples + some water.'),
      );
    case 'a1_how_much_many':
      return GrammarContextPack(
        heroIcon: Icons.calculate_rounded,
        backgroundIcons: const [
          Icons.shopping_cart_rounded,
          Icons.calculate_rounded,
          Icons.kitchen_rounded
        ],
        title: _cx(e, 'Ask about quantity', 'Miktar sor'),
        subtitle: _cx(e, 'shopping and planning', 'alışveriş ve plan'),
        scene: _cx(e, 'You are shopping or cooking and you need numbers.',
            'Alışveriş yapıyor veya yemek yapıyorsun; sayı lazım.'),
        dialogueLines: [
          _d('A', 'How many apples do we need?'),
          _d('B', 'We need four apples.'),
          _d('A', 'How much milk do we need?'),
          _d('B', 'One liter.'),
        ],
        scenarios: [
          _s(
              Icons.shopping_cart_rounded,
              _cx(e, 'In a shop', 'Mağazada'),
              'How many bananas do you want?',
              _cx(e, 'A common question at a market.',
                  'Manavda çok duyarsın.')),
          _s(
              Icons.kitchen_rounded,
              _cx(e, 'Cooking', 'Yemek yaparken'),
              'How much sugar do we need?',
              _cx(e, 'Useful in recipes.', 'Tariflerde çok kullanılır.')),
          _s(
              Icons.attach_money_rounded,
              _cx(e, 'Price', 'Fiyat'),
              'How much is this?',
              _cx(e, 'A quick way to ask the price.',
                  'Fiyat sormanın en kısa yolu.')),
        ],
        tip: _cx(e, 'Keep it practical: ask in shops and in the kitchen.',
            'Pratik tut: mağazada ve mutfakta sor.'),
      );
    case 'a1_question_words':
      return GrammarContextPack(
        heroIcon: Icons.help_outline_rounded,
        backgroundIcons: const [
          Icons.help_outline_rounded,
          Icons.person_rounded,
          Icons.map_rounded
        ],
        title: _cx(e, 'Ask basic questions', 'Temel sorular sor'),
        subtitle: _cx(e, 'what / where / when / who / why / how',
            'what / where / when / who / why / how'),
        scene: _cx(
            e,
            'You are meeting someone and asking simple information questions.',
            'Biriyle tanışıp basit bilgi soruyorsun.'),
        dialogueLines: [
          _d('A', 'Where do you live?'),
          _d('B', 'I live in Istanbul.'),
          _d('A', 'What do you do?'),
          _d('B', 'I am a student.'),
        ],
        scenarios: [
          _s(
              Icons.person_rounded,
              _cx(e, 'First meeting', 'İlk tanışma'),
              'What is your name?',
              _cx(e, 'The most common first question.', 'En yaygın ilk soru.')),
          _s(
              Icons.map_rounded,
              _cx(e, 'Asking for a place', 'Yer sorarken'),
              'Where is the bus stop?',
              _cx(e, 'Useful in the street.', 'Sokakta çok kullanışlı.')),
          _s(
              Icons.schedule_rounded,
              _cx(e, 'Asking about time', 'Zaman sorarken'),
              'When is the lesson?',
              _cx(e, 'Useful for schedules.', 'Program sorarken kullanılır.')),
        ],
        tip: _cx(e, 'Use these to keep a conversation going.',
            'Sohbeti devam ettirmek için bu sorular çok iyi.'),
      );
    case 'a1_basic_conjunctions':
      return GrammarContextPack(
        heroIcon: Icons.link_rounded,
        backgroundIcons: const [
          Icons.link_rounded,
          Icons.chat_bubble_rounded,
          Icons.lightbulb_rounded
        ],
        title: _cx(e, 'Connect ideas naturally', 'Fikirleri doğal bağla'),
        subtitle:
            _cx(e, 'and / but / because / so', 'and / but / because / so'),
        scene: _cx(
            e,
            'You want to say more in one sentence, like real conversation.',
            'Gerçek konuşma gibi tek cümlede biraz daha fazla şey söylemek istiyorsun.'),
        dialogueLines: [
          _d('A', 'Do you want tea or coffee?'),
          _d('B', 'Tea, please. I am tired, so I need coffee later.'),
          _d('A', 'Why are you tired?'),
          _d('B', 'Because I work a lot.'),
        ],
        scenarios: [
          _s(
              Icons.add_circle_outline_rounded,
              _cx(e, 'Adding', 'Ekleme'),
              'I like tea and coffee.',
              _cx(e, 'Useful when you list two things.',
                  'İki şeyi birlikte söylemek için.')),
          _s(
              Icons.compare_arrows_rounded,
              _cx(e, 'Contrast', 'Zıtlık'),
              'I like tea, but I don’t like coffee.',
              _cx(e, 'Useful when your two ideas are different.',
                  'İki fikir zıt olunca kullanırsın.')),
          _s(
              Icons.psychology_rounded,
              _cx(e, 'Reason', 'Sebep'),
              'I am tired because I work a lot.',
              _cx(e, 'Useful when you explain “why”.',
                  'Neden sorusuna cevap verirken kullanılır.')),
        ],
        tip: _cx(e, 'Start with small links: and / but / because / so.',
            'Küçük bağlaçlarla başla: and / but / because / so.'),
      );
    default:
      final examples = _contextUsableSentences(lesson);
      final first = examples.isNotEmpty ? examples[0] : lesson.right;
      final second = examples.length > 1 ? examples[1] : first;
      final third = examples.length > 2 ? examples[2] : second;
      return GrammarContextPack(
        heroIcon: Icons.chat_bubble_rounded,
        backgroundIcons: const [
          Icons.chat_bubble_rounded,
          Icons.location_on_rounded,
          Icons.school_rounded
        ],
        title: _cx(e, 'Try it in a real moment', 'Gerçek bir anda dene'),
        subtitle: _cx(e, 'Short daily sentences', 'Kısa günlük cümleler'),
        scene: _cx(e, 'Pick a situation and say the sentence out loud.',
            'Bir durum seç ve cümleyi sesli söyle.'),
        dialogueLines: [
          _d('A', first),
          _d('B', second),
          _d('A', third),
        ],
        scenarios: [
          _s(
              Icons.school_rounded,
              _cx(e, 'In class', 'Sınıfta'),
              first,
              _cx(e, 'A simple useful line.',
                  'Basit ve kullanışlı bir cümle.')),
          _s(Icons.shopping_bag_rounded, _cx(e, 'Outside', 'Dışarıda'), second,
              _cx(e, 'Use it in daily life.', 'Günlük hayatta kullan.')),
          _s(
              Icons.people_alt_rounded,
              _cx(e, 'With a friend', 'Arkadaşla'),
              third,
              _cx(e, 'Say it in a short dialogue.', 'Kısa diyalogda söyle.')),
        ],
        tip: _cx(e, 'Say it once. Then change one word.',
            'Bir kez söyle. Sonra bir kelimeyi değiştir.'),
      );
  }
}

List<String> _contextUsableSentences(GrammarLesson lesson) {
  final raw = <String>[
    ...lesson.examples,
    lesson.right,
    ...lesson.modelAnswer.split(RegExp(r'[\n/]')),
    ...lesson.formulaRows.map((row) => row.sample),
  ];
  final result = <String>[];
  for (final item in raw) {
    final clean = _cleanContextSentence(item);
    if (clean.isEmpty) continue;
    if (_looksLikeContextMeta(clean)) continue;
    if (_looksLikeContextPatternOrList(clean)) continue;
    if (!_looksLikeContextSentence(clean)) continue;
    if (!result.contains(clean)) result.add(clean);
    if (result.length >= 5) break;
  }
  while (result.length < 3) {
    result.add('I use English every day.');
  }
  return result;
}

String _cleanContextSentence(String value) {
  return value.replaceAll('→', ' ').replaceAll('  ', ' ').trim();
}

bool _looksLikeContextSentence(String value) {
  final clean = value.trim();
  if (clean.length < 8) return false;
  if (!(clean.endsWith('.') || clean.endsWith('?') || clean.endsWith('!'))) {
    return false;
  }
  final words =
      clean.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).length;
  return words >= 3;
}

bool _looksLikeContextPatternOrList(String value) {
  final v = value.trim().toLowerCase();
  if (v.contains(' + ') ||
      v.contains(' / ') ||
      v.contains('→') ||
      v.contains('->')) {
    return true;
  }
  if (v.contains(',') &&
      !v.contains(' and ') &&
      !v.contains(' but ') &&
      !v.contains(' because ')) {
    return true;
  }
  if (RegExp(r'^[a-z]+(,\s*[a-z]+)+\.?$').hasMatch(v)) return true;
  if (RegExp(r'^(a|an|the|my|your|his|her|its|our|their)\s+[a-z]+,')
      .hasMatch(v)) {
    return true;
  }
  return false;
}

bool _looksLikeContextMeta(String value) {
  final v = value.toLowerCase();
  return v.contains('look at this sentence') ||
      v.contains('notice the form') ||
      v.contains('what should i notice') ||
      v.contains('so i should avoid') ||
      v.contains('exactly. say') ||
      v.contains('common mistake') ||
      v.contains('correct version') ||
      v.contains('extra model') ||
      v.contains('use the same logic');
}

GrammarContextPack _futurePerfectContext(bool e) => GrammarContextPack(
      heroIcon: Icons.flag_circle_rounded,
      backgroundIcons: const [
        Icons.schedule_rounded,
        Icons.task_alt_rounded,
        Icons.flag_circle_rounded
      ],
      title: _cx(e, 'Show completion before a future time',
          'Gelecekteki bir zamandan önce tamamlanmayı anlat'),
      subtitle: _cx(e, 'will have + V3', 'will have + V3'),
      scene: _cx(
          e,
          'You are looking forward and saying something will be finished before a deadline.',
          'İleriye bakıp bir şeyin son tarihten önce bitmiş olacağını söylüyorsun.'),
      dialogueLines: [
        _d('A', 'Will you finish before 8?'),
        _d('B', 'Yes, I will have finished by 8.'),
        _d('A', 'So it is completed before that time?'),
        _d('B', 'Exactly. By 8, it will be done.')
      ],
      scenarios: [
        _s(
            Icons.schedule_rounded,
            _cx(e, 'Deadline', 'Son tarih'),
            'I will have finished by 8.',
            _cx(e, 'By shows the future deadline.',
                'By gelecekteki son zamanı gösterir.')),
        _s(
            Icons.school_rounded,
            _cx(e, 'Exam prep', 'Sınav hazırlığı'),
            'She will have revised all units by Friday.',
            _cx(e, 'The revision is complete before Friday.',
                'Tekrar Friday’den önce tamamlanır.')),
        _s(
            Icons.work_rounded,
            _cx(e, 'Project', 'Proje'),
            'They will have sent the report by noon.',
            _cx(e, 'Focus on completion before noon.',
                'Odak noon öncesi tamamlanmadır.'))
      ],
      tip: _cx(
          e,
          'Future Perfect is not just will + V1. It must be will have + V3.',
          'Future Perfect sadece will + V1 değildir. Mutlaka will have + V3 olur.'),
    );

GrammarContextPack _futurePerfectContinuousContext(bool e) =>
    GrammarContextPack(
      heroIcon: Icons.timelapse_rounded,
      backgroundIcons: const [
        Icons.timelapse_rounded,
        Icons.schedule_rounded,
        Icons.hourglass_top_rounded
      ],
      title: _cx(e, 'Show duration before a future point',
          'Gelecekteki bir noktadan önceki süreyi anlat'),
      subtitle: _cx(e, 'will have been + V-ing', 'will have been + V-ing'),
      scene: _cx(
          e,
          'You are saying how long an action will have been continuing by a future time.',
          'Bir eylemin gelecekteki bir zamana kadar ne kadar süredir devam ediyor olacağını söylüyorsun.'),
      dialogueLines: [
        _d('A', 'How long will you have been working by June?'),
        _d('B', 'I will have been working here for two years.'),
        _d('A', 'So the duration matters?'),
        _d('B', 'Yes, the focus is the length of time.')
      ],
      scenarios: [
        _s(
            Icons.work_rounded,
            _cx(e, 'Work duration', 'İş süresi'),
            'I will have been working here for two years by June.',
            _cx(e, 'For two years shows duration.',
                'For two years süreyi gösterir.')),
        _s(
            Icons.fitness_center_rounded,
            _cx(e, 'Training', 'Antrenman'),
            'She will have been training for six months by May.',
            _cx(e, 'The action continues up to a future point.',
                'Eylem gelecekteki noktaya kadar sürer.')),
        _s(
            Icons.school_rounded,
            _cx(e, 'Course duration', 'Kurs süresi'),
            'By July, they will have been studying English for a year.',
            _cx(e, 'The duration continues until July.',
                'Süre July ayına kadar devam eder.'))
      ],
      tip: _cx(e, 'Use will have been + V-ing when duration is the main idea.',
          'Ana fikir süre ise will have been + V-ing kullan.'),
    );

GrammarContextPack _mayMightContext(bool e) => GrammarContextPack(
      heroIcon: Icons.help_outline_rounded,
      backgroundIcons: const [
        Icons.cloud_rounded,
        Icons.help_outline_rounded,
        Icons.event_available_rounded
      ],
      title: _cx(
          e, 'Talk about uncertain possibility', 'Belirsiz olasılıktan bahset'),
      subtitle: _cx(e, 'may / might + V1', 'may / might + V1'),
      scene: _cx(e, 'You are not sure, but something is possible.',
          'Emin değilsin ama bir şey mümkün.'),
      dialogueLines: [
        _d('A', 'Will it rain later?'),
        _d('B', 'It might rain later.'),
        _d('A', 'Is she coming?'),
        _d('B', 'She may come to the party.')
      ],
      scenarios: [
        _s(
            Icons.cloud_rounded,
            _cx(e, 'Weather', 'Hava'),
            'It might rain later.',
            _cx(e, 'Might shows uncertainty.', 'Might belirsizlik gösterir.')),
        _s(
            Icons.group_rounded,
            _cx(e, 'Plans', 'Planlar'),
            'She may join us.',
            _cx(e, 'May shows possible participation.',
                'May olası katılımı gösterir.')),
        _s(
            Icons.schedule_rounded,
            _cx(e, 'Later today', 'Bugün daha sonra'),
            'We may need more time.',
            _cx(e, 'May shows a possible need.', 'May olası ihtiyaç anlatır.'))
      ],
      tip: _cx(e, 'After may or might, use V1: might rain, not might rains.',
          'May veya might sonrasında V1 kullan: might rain, might rains değil.'),
    );

GrammarContextPack _presentSimpleContext(bool e) => GrammarContextPack(
      heroIcon: Icons.repeat_rounded,
      backgroundIcons: const [
        Icons.alarm_rounded,
        Icons.calendar_today_rounded,
        Icons.coffee_rounded
      ],
      title: _cx(
          e, 'Use it for routines and facts', 'Rutin ve gerçekler için kullan'),
      subtitle: _cx(e, 'Habits, schedules, general truths',
          'Alışkanlıklar, programlar, genel doğrular'),
      scene: _cx(e, 'You are describing what usually happens in daily life.',
          'Günlük hayatta genelde olan şeyleri anlatıyorsun.'),
      dialogueLines: [
        _d('A', 'What time do you wake up?'),
        _d('B', 'I wake up at seven every day.'),
        _d('A', 'Does your sister study English?'),
        _d('B', 'Yes, she studies after school.')
      ],
      scenarios: [
        _s(
            Icons.alarm_rounded,
            _cx(e, 'Routine', 'Rutin'),
            'I drink coffee every morning.',
            _cx(e, 'Repeated action = Present Simple.',
                'Tekrar eden eylem = Present Simple.')),
        _s(
            Icons.school_rounded,
            _cx(e, 'Third person', 'Üçüncü tekil'),
            'She studies English after school.',
            _cx(e, 'He / She / It takes -s or -es.',
                'He / She / It ile fiil -s veya -es alır.')),
        _s(
            Icons.public_rounded,
            _cx(e, 'Fact', 'Gerçek'),
            'The sun rises in the east.',
            _cx(e, 'General truths use Present Simple.',
                'Genel doğrular Present Simple alır.'))
      ],
      tip: _cx(
          e,
          'For he / she / it, remember the final -s: she works, he plays.',
          'He / she / it için -s takısını unutma: she works, he plays.'),
    );

GrammarContextPack _presentContinuousContext(bool e) => GrammarContextPack(
      heroIcon: Icons.motion_photos_on_rounded,
      backgroundIcons: const [
        Icons.bolt_rounded,
        Icons.visibility_rounded,
        Icons.schedule_rounded
      ],
      title: _cx(e, 'Use it for actions happening now',
          'Şu anda olan eylemler için kullan'),
      subtitle: _cx(e, 'am / is / are + V-ing', 'am / is / are + V-ing'),
      scene: _cx(
          e,
          'You are describing what is happening right now or around now.',
          'Şu anda ya da bu dönem devam eden şeyi anlatıyorsun.'),
      dialogueLines: [
        _d('A', 'What are you doing now?'),
        _d('B', 'I am studying English.'),
        _d('A', 'Is your brother sleeping?'),
        _d('B', 'No, he is watching a video.')
      ],
      scenarios: [
        _s(
            Icons.visibility_rounded,
            _cx(e, 'Right now', 'Şu an'),
            'She is reading a book now.',
            _cx(e, 'The action is happening at this moment.',
                'Eylem şu anda gerçekleşiyor.')),
        _s(
            Icons.work_rounded,
            _cx(e, 'Around now', 'Bu dönem'),
            'I am working on a new project.',
            _cx(e, 'It can mean this period, not only this second.',
                'Sadece bu saniye değil, bu dönem anlamı da olabilir.')),
        _s(
            Icons.check_circle_rounded,
            _cx(e, 'Now', 'Şimdi'),
            'He is playing football.',
            _cx(e, 'Use is with he / she / it.',
                'He / she / it ile is kullan.'))
      ],
      tip: _cx(e, 'Do not forget am / is / are before V-ing.',
          'V-ing’den önce am / is / are kullanmayı unutma.'),
    );

GrammarContextPack _pastSimpleContext(bool e) => GrammarContextPack(
      heroIcon: Icons.history_rounded,
      backgroundIcons: const [
        Icons.calendar_month_rounded,
        Icons.photo_rounded,
        Icons.route_rounded
      ],
      title: _cx(e, 'Use it for finished past events',
          'Bitmiş geçmiş olaylar için kullan'),
      subtitle:
          _cx(e, 'yesterday / last week / ago', 'yesterday / last week / ago'),
      scene: _cx(
          e,
          'You are telling someone about yesterday or a finished memory.',
          'Birine dününü ya da bitmiş bir anıyı anlatıyorsun.'),
      dialogueLines: [
        _d('A', 'What did you do yesterday?'),
        _d('B', 'I watched a movie at home.'),
        _d('A', 'Did you go out later?'),
        _d('B', 'No, I stayed at home.')
      ],
      scenarios: [
        _s(
            Icons.calendar_month_rounded,
            _cx(e, 'Finished time', 'Bitmiş zaman'),
            'I finished my homework yesterday.',
            _cx(e, 'A finished time points to Past Simple.',
                'Bitmiş zaman Past Simple’a götürür.')),
        _s(
            Icons.flight_takeoff_rounded,
            _cx(e, 'Travel memory', 'Gezi anısı'),
            'She went to Ankara last week.',
            _cx(e, 'Use V2 in positive sentences.',
                'Olumlu cümlede V2 kullan.')),
        _s(
            Icons.question_answer_rounded,
            _cx(e, 'Question', 'Soru'),
            'Did you call me yesterday?',
            _cx(e, 'After did, the verb returns to V1.',
                'Did sonrası fiil V1 olur.'))
      ],
      tip: _cx(e, 'After did / did not, use V1: did not go, not did not went.',
          'Did / did not sonrasında V1 kullan: did not go; did not went değil.'),
    );

GrammarContextPack _pastContinuousContext(bool e) => GrammarContextPack(
      heroIcon: Icons.blur_on_rounded,
      backgroundIcons: const [
        Icons.access_time_rounded,
        Icons.call_rounded,
        Icons.cloud_rounded
      ],
      title: _cx(e, 'Use it for a past action in progress',
          'Geçmişte devam eden eylem için kullan'),
      subtitle: _cx(e, 'was / were + V-ing', 'was / were + V-ing'),
      scene: _cx(
          e,
          'You are describing what was happening at a specific past moment.',
          'Geçmişte belli bir anda ne olmakta olduğunu anlatıyorsun.'),
      dialogueLines: [
        _d('A', 'What were you doing when I called?'),
        _d('B', 'I was studying in my room.'),
        _d('A', 'Were you busy?'),
        _d('B', 'Yes. I was preparing for the quiz.')
      ],
      scenarios: [
        _s(
            Icons.access_time_rounded,
            _cx(e, 'Past moment', 'Geçmiş an'),
            'They were watching TV at 9.',
            _cx(e, 'The action was in progress at that time.',
                'O anda eylem devam ediyordu.')),
        _s(
            Icons.call_rounded,
            _cx(e, 'Interrupted action', 'Kesilen eylem'),
            'I was sleeping when you called.',
            _cx(e, 'Long action + short interruption.',
                'Uzun eylem + kısa kesinti.')),
        _s(
            Icons.cloud_rounded,
            _cx(e, 'Background', 'Arka plan'),
            'It was raining, and people were running home.',
            _cx(e, 'Use it to paint the scene.',
                'Sahneyi canlandırmak için kullan.'))
      ],
      tip: _cx(e, 'Use was/were before V-ing: I was studying.',
          'V-ing’den önce was/were kullan: I was studying.'),
    );

GrammarContextPack _comparativesContext(bool e) => GrammarContextPack(
      heroIcon: Icons.compare_arrows_rounded,
      backgroundIcons: const [
        Icons.balance_rounded,
        Icons.bar_chart_rounded,
        Icons.swap_horiz_rounded
      ],
      title: _cx(e, 'Use it to compare two things',
          'İki şeyi karşılaştırmak için kullan'),
      subtitle: _cx(e, '-er / more + than', '-er / more + than'),
      scene: _cx(
          e,
          'You are choosing between two cities, people, lessons, or products.',
          'İki şehir, kişi, ders ya da ürün arasında kıyas yapıyorsun.'),
      dialogueLines: [
        _d('A', 'Which city is colder?'),
        _d('B', 'Kayseri is colder than Antalya.'),
        _d('A', 'Is this lesson easier?'),
        _d('B', 'Yes, it is easier than the last one.')
      ],
      scenarios: [
        _s(
            Icons.thermostat_rounded,
            _cx(e, 'Weather', 'Hava'),
            'Today is hotter than yesterday.',
            _cx(e, 'Than introduces the second side.',
                'Than ikinci tarafı gösterir.')),
        _s(
            Icons.shopping_bag_rounded,
            _cx(e, 'Shopping', 'Alışveriş'),
            'This phone is more expensive than my old phone.',
            _cx(e, 'Long adjectives usually use more.',
                'Uzun sıfatlar genelde more alır.')),
        _s(
            Icons.star_rounded,
            _cx(e, 'Irregular', 'Düzensiz'),
            'This answer is better than mine.',
            _cx(e, 'Good becomes better.', 'Good, better olur.'))
      ],
      tip: _cx(e, 'Do not say more better. Use better.',
          'More better deme. Better kullan.'),
    );

GrammarContextPack _superlativesContext(bool e) => GrammarContextPack(
      heroIcon: Icons.emoji_events_rounded,
      backgroundIcons: const [
        Icons.workspace_premium_rounded,
        Icons.star_rounded,
        Icons.leaderboard_rounded
      ],
      title: _cx(e, 'Use it for the top item in a group',
          'Bir gruptaki en üst şeyi anlat'),
      subtitle: _cx(e, 'the -est / the most', 'the -est / the most'),
      scene: _cx(
          e,
          'You are choosing the best, biggest, or most useful option in a group.',
          'Bir grup içinde en iyi, en büyük veya en faydalı seçeneği söylüyorsun.'),
      dialogueLines: [
        _d('A', 'Who is the tallest student?'),
        _d('B', 'Mert is the tallest student in the class.'),
        _d('A', 'What is the most useful app?'),
        _d('B', 'This is the most useful app for me.')
      ],
      scenarios: [
        _s(
            Icons.school_rounded,
            _cx(e, 'Class', 'Sınıf'),
            'She is the tallest student in the class.',
            _cx(e, 'Use in for the group/place.',
                'Grup veya yer için in kullan.')),
        _s(
            Icons.apps_rounded,
            _cx(e, 'Choice', 'Seçim'),
            'This is the most useful app.',
            _cx(e, 'Long adjectives use the most.',
                'Uzun sıfatlarda the most kullanılır.')),
        _s(
            Icons.sports_soccer_rounded,
            _cx(e, 'Team', 'Takım'),
            'He is the best player on the team.',
            _cx(e, 'Good becomes the best.', 'Good, the best olur.'))
      ],
      tip: _cx(e, 'Most superlatives need the: the biggest, the best.',
          'Superlative yapılarda çoğunlukla the gerekir: the biggest, the best.'),
    );

GrammarContextPack _b1ModalsContext(bool e) => GrammarContextPack(
      heroIcon: Icons.tune_rounded,
      backgroundIcons: const [
        Icons.health_and_safety_rounded,
        Icons.traffic_rounded,
        Icons.help_outline_rounded
      ],
      title: _cx(e, 'Advice, necessity, and possibility',
          'Tavsiye, gereklilik ve olasılık'),
      subtitle: _cx(e, 'should / must / have to / might',
          'should / must / have to / might'),
      scene: _cx(
          e,
          'You choose a modal according to how strong the message is.',
          'Mesajın gücüne göre doğru modal fiili seçiyorsun.'),
      dialogueLines: [
        _d('A', 'I feel sick today.'),
        _d('B', 'You should rest.'),
        _d('A', 'Can I skip the form?'),
        _d('B', 'No. You have to complete it before the meeting.')
      ],
      scenarios: [
        _s(
            Icons.favorite_rounded,
            _cx(e, 'Advice', 'Tavsiye'),
            'You should talk to your teacher.',
            _cx(e, 'Should sounds helpful, not forceful.',
                'Should yardımcı bir tavsiye verir.')),
        _s(
            Icons.assignment_rounded,
            _cx(e, 'Necessity', 'Gereklilik'),
            'She has to submit the report today.',
            _cx(e, 'Have to shows a necessary action.',
                'Have to gerekli bir eylem gösterir.')),
        _s(
            Icons.cloud_queue_rounded,
            _cx(e, 'Possibility', 'Olasılık'),
            'It might rain after school.',
            _cx(e, 'Might shows uncertainty.',
                'Might kesin olmayan olasılık gösterir.'))
      ],
      tip: _cx(e, 'After a modal, keep the main verb in base form.',
          'Modal fiilden sonra ana fiil yalın halde kalır.'),
    );

GrammarContextPack _modalPerfectsContext(bool e) => GrammarContextPack(
      heroIcon: Icons.history_toggle_off_rounded,
      backgroundIcons: const [
        Icons.warning_amber_rounded,
        Icons.psychology_rounded,
        Icons.undo_rounded
      ],
      title: _cx(
          e, 'Looking back at past choices', 'Geçmiş seçimlere dönüp bakma'),
      subtitle: _cx(e, 'should have / must have / might have + V3',
          'should have / must have / might have + V3'),
      scene: _cx(
          e,
          'You are judging, guessing, or regretting something after it happened.',
          'Bir olay olduktan sonra yorum, tahmin veya pişmanlık ifade ediyorsun.'),
      dialogueLines: [
        _d('A', 'I failed the quiz.'),
        _d('B', 'You should have studied earlier.'),
        _d('A', 'Where is Emre?'),
        _d('B', 'He might have missed the bus.')
      ],
      scenarios: [
        _s(
            Icons.report_problem_rounded,
            _cx(e, 'Regret', 'Pişmanlık'),
            'You should have called me.',
            _cx(e, 'A better past action did not happen.',
                'Geçmişte daha iyi bir eylem yapılmadı.')),
        _s(
            Icons.search_rounded,
            _cx(e, 'Deduction', 'Çıkarım'),
            'She must have forgotten the meeting.',
            _cx(e, 'You feel almost sure about the past.',
                'Geçmişle ilgili güçlü çıkarım yaparsın.')),
        _s(
            Icons.help_rounded,
            _cx(e, 'Uncertain past', 'Belirsiz geçmiş'),
            'They might have taken another road.',
            _cx(e, 'Might have keeps the idea uncertain.',
                'Might have belirsizliği korur.'))
      ],
      tip: _cx(e, 'The structure is modal + have + V3, not modal + V2.',
          'Yapı modal + have + V3 şeklindedir; modal + V2 değil.'),
    );

GrammarContextPack _modalDeductionContext(bool e) => GrammarContextPack(
      heroIcon: Icons.manage_search_rounded,
      backgroundIcons: const [
        Icons.lightbulb_rounded,
        Icons.visibility_rounded,
        Icons.help_outline_rounded
      ],
      title: _cx(e, 'Guessing from evidence', 'Kanıttan çıkarım yapma'),
      subtitle: _cx(
          e, 'must be / can’t be / might be', 'must be / can’t be / might be'),
      scene: _cx(e, 'You look at clues and decide how likely something is.',
          'İpuçlarına bakıp bir şeyin ne kadar olası olduğunu söylüyorsun.'),
      dialogueLines: [
        _d('A', 'The lights are on.'),
        _d('B', 'She must be at home.'),
        _d('A', 'Is that Ali’s car?'),
        _d('B', 'It can’t be his car. His car is red.')
      ],
      scenarios: [
        _s(
            Icons.check_circle_rounded,
            _cx(e, 'Strong guess', 'Güçlü tahmin'),
            'She must be tired after the trip.',
            _cx(e, 'Must shows a strong deduction.',
                'Must güçlü çıkarım gösterir.')),
        _s(
            Icons.cancel_rounded,
            _cx(e, 'Impossible idea', 'İmkânsız fikir'),
            'He can’t be the manager.',
            _cx(e, 'Can’t rejects the idea.', 'Can’t fikri reddeder.')),
        _s(
            Icons.help_rounded,
            _cx(e, 'Possible idea', 'Olası fikir'),
            'They might be in the library.',
            _cx(e, 'Might keeps the guess open.',
                'Might tahmini açık bırakır.'))
      ],
      tip: _cx(
          e,
          'Use must when evidence is strong; use might when you are less sure.',
          'Kanıt güçlüyse must, daha az eminsen might kullan.'),
    );

GrammarContextPack _reportedCommandsContext(bool e) => GrammarContextPack(
      heroIcon: Icons.assignment_ind_rounded,
      backgroundIcons: const [
        Icons.record_voice_over_rounded,
        Icons.school_rounded,
        Icons.do_not_disturb_on_rounded
      ],
      title: _cx(e, 'Reporting instructions', 'Talimatları aktarma'),
      subtitle: _cx(
          e, 'told / asked + object + to V1', 'told / asked + nesne + to V1'),
      scene: _cx(e, 'You tell someone what another person wanted people to do.',
          'Birinin başkasından ne yapmasını istediğini aktarıyorsun.'),
      dialogueLines: [
        _d('A', 'What did the teacher say?'),
        _d('B', 'She told us to be quiet.'),
        _d('A', 'Did she mention homework?'),
        _d('B', 'Yes. She asked us to finish it tonight.')
      ],
      scenarios: [
        _s(
            Icons.school_rounded,
            _cx(e, 'Instruction', 'Talimat'),
            'The teacher told us to open our books.',
            _cx(e, 'Use told + object + to.', 'Told + nesne + to kullanılır.')),
        _s(
            Icons.person_add_alt_rounded,
            _cx(e, 'Request', 'Rica'),
            'He asked me to help him.',
            _cx(e, 'Asked sounds softer than told.',
                'Asked, told’dan daha yumuşaktır.')),
        _s(
            Icons.do_not_disturb_rounded,
            _cx(e, 'Negative instruction', 'Olumsuz talimat'),
            'She told me not to wait outside.',
            _cx(e, 'Negative form is not to + V1.',
                'Olumsuz yapı not to + V1 şeklindedir.'))
      ],
      tip: _cx(e, 'Do not drop the object: told me to, asked us to.',
          'Nesneyi düşürme: told me to, asked us to.'),
    );

GrammarContextPack _advancedConcessionContext(bool e) => GrammarContextPack(
      heroIcon: Icons.sync_alt_rounded,
      backgroundIcons: const [
        Icons.balance_rounded,
        Icons.gavel_rounded,
        Icons.auto_stories_rounded
      ],
      title: _cx(
          e, 'Balancing a strong counterpoint', 'Güçlü karşı fikri dengeleme'),
      subtitle: _cx(e, 'Be that as it may / Admittedly / For all its flaws',
          'Be that as it may / Admittedly / For all its flaws'),
      scene: _cx(
          e,
          'You accept one point, then continue with your main argument.',
          'Bir noktayı kabul edip ana argümanına devam ediyorsun.'),
      dialogueLines: [
        _d('A', 'The proposal has several problems.'),
        _d('B', 'Admittedly, it is imperfect, but it solves the main issue.'),
        _d('A', 'So we do not ignore the weakness?'),
        _d('B', 'Exactly. We acknowledge it and move forward.')
      ],
      scenarios: [
        _s(
            Icons.balance_rounded,
            _cx(e, 'Admittedly', 'Admittedly'),
            'Admittedly, the plan is risky, but it is worth testing.',
            _cx(e, 'You concede before defending the idea.',
                'Fikri savunmadan önce bir noktayı kabul edersin.')),
        _s(
            Icons.gavel_rounded,
            _cx(e, 'Be that as it may', 'Be that as it may'),
            'Be that as it may, the decision needs a practical solution.',
            _cx(e, 'Formal transition after a counterpoint.',
                'Karşı fikirden sonra resmi geçiş yapar.')),
        _s(
            Icons.settings_suggest_rounded,
            _cx(e, 'For all its flaws', 'For all its flaws'),
            'For all its flaws, the system remains useful.',
            _cx(e, 'Problems are admitted, but the main point remains.',
                'Sorunlar kabul edilir ama ana fikir kalır.'))
      ],
      tip: _cx(
          e,
          'Advanced concession should sound balanced, not dramatic for no reason.',
          'İleri concession dengeli duyulmalı; gereksiz dramatik olmamalı.'),
    );

GrammarContextPack _reducedClausesContext(bool e) => GrammarContextPack(
      heroIcon: Icons.compress_rounded,
      backgroundIcons: const [
        Icons.article_rounded,
        Icons.timeline_rounded,
        Icons.edit_note_rounded,
      ],
      title: _cx(
        e,
        'Compress background information',
        'Arka plan bilgisini sıkıştır',
      ),
      subtitle: _cx(
        e,
        'Having + V3 / V-ing / V3 phrase',
        'Having + V3 / V-ing / V3 öbeği',
      ),
      scene: _cx(
        e,
        'You connect related actions without repeating the same subject.',
        'Aynı özneyi tekrarlamadan bağlantılı eylemleri birleştiriyorsun.',
      ),
      dialogueLines: [
        _d('A', 'Why did Selin send the report immediately?'),
        _d('B',
            'Having finished the final checks, she sent it to the manager.'),
        _d('A', 'What happened to the documents next?'),
        _d('B', 'Approved by the board, they were released that afternoon.'),
      ],
      scenarios: [
        _s(
          Icons.done_all_rounded,
          _cx(e, 'Earlier action', 'Önce tamamlanan eylem'),
          'Having completed the interview, she wrote her notes.',
          _cx(
            e,
            'The first action is complete before the main event.',
            'İlk eylem, ana olaydan önce tamamlanır.',
          ),
        ),
        _s(
          Icons.directions_walk_rounded,
          _cx(e, 'Parallel action', 'Eş zamanlı eylem'),
          'Walking through the station, he checked the departure board.',
          _cx(
            e,
            'Both actions share the same subject.',
            'İki eylemin öznesi aynıdır.',
          ),
        ),
        _s(
          Icons.verified_rounded,
          _cx(e, 'Passive background', 'Edilgen arka plan'),
          'Designed for small teams, the app remains easy to manage.',
          _cx(
            e,
            'A past participle phrase adds passive background information.',
            'Past participle öbeği edilgen arka plan bilgisi ekler.',
          ),
        ),
      ],
      tip: _cx(
        e,
        'Keep the implied subject of the reduced phrase and main clause the same.',
        'Kısaltılmış öbeğin örtük öznesi ile ana cümlenin öznesini aynı tut.',
      ),
    );

GrammarContextPack _mustHaveToContext(bool e) => GrammarContextPack(
      heroIcon: Icons.rule_rounded,
      backgroundIcons: const [
        Icons.assignment_turned_in_rounded,
        Icons.local_police_rounded,
        Icons.school_rounded
      ],
      title: _cx(e, 'Use it for rules and obligation',
          'Kural ve zorunluluk için kullan'),
      subtitle: _cx(e, 'must / have to / mustn’t / don’t have to',
          'must / have to / mustn’t / don’t have to'),
      scene: _cx(
          e,
          'You are talking about rules, duties, prohibition, or no necessity.',
          'Kural, görev, yasak veya gereklilik olmama durumunu anlatıyorsun.'),
      dialogueLines: [
        _d('A', 'Can I park here?'),
        _d('B', 'No, you mustn’t park here.'),
        _d('A', 'Do I have to wear a uniform?'),
        _d('B', 'Yes, you have to wear it at school.')
      ],
      scenarios: [
        _s(
            Icons.traffic_rounded,
            _cx(e, 'Rule', 'Kural'),
            'You must wear a seat belt.',
            _cx(e, 'Must sounds strong and direct.',
                'Must güçlü ve doğrudandır.')),
        _s(
            Icons.business_center_rounded,
            _cx(e, 'External duty', 'Dış zorunluluk'),
            'She has to wake up early for work.',
            _cx(e, 'Has to with he/she/it.', 'He/she/it ile has to kullan.')),
        _s(
            Icons.do_not_disturb_alt_rounded,
            _cx(e, 'No necessity', 'Gerek yok'),
            'You don’t have to come early.',
            _cx(e, 'No necessity, not prohibition.', 'Gerek yok; yasak değil.'))
      ],
      tip: _cx(
          e,
          'Mustn’t means prohibition. Don’t have to means no necessity.',
          'Mustn’t yasak demektir. Don’t have to gerekli değil demektir.'),
    );

GrammarContextPack _shouldContext(bool e) => GrammarContextPack(
      heroIcon: Icons.lightbulb_rounded,
      backgroundIcons: const [
        Icons.health_and_safety_rounded,
        Icons.favorite_rounded,
        Icons.school_rounded
      ],
      title: _cx(e, 'Use it to give advice', 'Tavsiye vermek için kullan'),
      subtitle: _cx(e, 'should / shouldn’t + V1', 'should / shouldn’t + V1'),
      scene: _cx(
          e,
          'Someone has a problem, and you are suggesting a good idea.',
          'Birinin problemi var ve ona iyi bir fikir öneriyorsun.'),
      dialogueLines: [
        _d('A', 'I feel tired.'),
        _d('B', 'You should rest and drink water.'),
        _d('A', 'Should I study tonight?'),
        _d('B', 'Yes, but you shouldn’t sleep too late.')
      ],
      scenarios: [
        _s(
            Icons.local_hospital_rounded,
            _cx(e, 'Health', 'Sağlık'),
            'You should drink more water.',
            _cx(e, 'Helpful advice.', 'Yardımcı tavsiye.')),
        _s(
            Icons.menu_book_rounded,
            _cx(e, 'Study', 'Ders'),
            'You should review the lesson.',
            _cx(e, 'Verb stays V1 after should.',
                'Should sonrası fiil V1 kalır.')),
        _s(
            Icons.nightlight_rounded,
            _cx(e, 'Warning', 'Uyarı'),
            'You shouldn’t sleep late.',
            _cx(e, 'Negative advice.', 'Olumsuz tavsiye.'))
      ],
      tip: _cx(e, 'After should, never add to or -s: she should study.',
          'Should sonrasında to veya -s ekleme: she should study.'),
    );

GrammarContextPack _willContext(bool e) => GrammarContextPack(
      heroIcon: Icons.rocket_launch_rounded,
      backgroundIcons: const [
        Icons.flash_on_rounded,
        Icons.cloud_rounded,
        Icons.favorite_rounded
      ],
      title: _cx(e, 'Use it for quick decisions and predictions',
          'Ani karar ve tahmin için kullan'),
      subtitle: _cx(e, 'will + V1', 'will + V1'),
      scene: _cx(
          e,
          'You decide something while speaking, make a prediction, or promise something.',
          'Konuşurken karar veriyor, tahmin yapıyor veya söz veriyorsun.'),
      dialogueLines: [
        _d('A', 'I’m tired.'),
        _d('B', 'I will help you.'),
        _d('A', 'Do you think it will rain?'),
        _d('B', 'Yes, I think it will.')
      ],
      scenarios: [
        _s(
            Icons.flash_on_rounded,
            _cx(e, 'Quick decision', 'Ani karar'),
            'I will open the window.',
            _cx(e, 'Decision happens while speaking.',
                'Karar konuşma anında verilir.')),
        _s(
            Icons.cloud_rounded,
            _cx(e, 'Prediction', 'Tahmin'),
            'It will be sunny tomorrow.',
            _cx(e, 'Future guess.', 'Gelecek tahmini.')),
        _s(
            Icons.favorite_rounded,
            _cx(e, 'Promise', 'Söz'),
            'I will call you tonight.',
            _cx(e, 'Will is common in promises.',
                'Söz verirken will sık kullanılır.'))
      ],
      tip: _cx(e, 'After will, always use V1.',
          'Will sonrasında her zaman V1 gelir.'),
    );

GrammarContextPack _goingToContext(bool e) => GrammarContextPack(
      heroIcon: Icons.flag_rounded,
      backgroundIcons: const [
        Icons.event_rounded,
        Icons.check_circle_rounded,
        Icons.route_rounded
      ],
      title: _cx(e, 'Use it for plans and visible evidence',
          'Plan ve görünen kanıt için kullan'),
      subtitle:
          _cx(e, 'am / is / are going to + V1', 'am / is / are going to + V1'),
      scene: _cx(
          e,
          'You already have a plan, or you can see evidence for a future event.',
          'Zaten bir planın var ya da gelecekle ilgili kanıt görüyorsun.'),
      dialogueLines: [
        _d('A', 'What are you going to do tonight?'),
        _d('B', 'I am going to study English.'),
        _d('A', 'Look at those clouds.'),
        _d('B', 'It is going to rain.')
      ],
      scenarios: [
        _s(
            Icons.event_rounded,
            _cx(e, 'Plan', 'Plan'),
            'We are going to visit our grandparents.',
            _cx(e, 'A planned future action.', 'Planlanmış gelecek eylemi.')),
        _s(
            Icons.cloud_rounded,
            _cx(e, 'Evidence', 'Kanıt'),
            'It is going to rain.',
            _cx(e, 'You can see evidence now.', 'Şu anda kanıt görüyorsun.')),
        _s(
            Icons.warning_rounded,
            _cx(e, 'Form', 'Yapı'),
            'She is going to call you.',
            _cx(e, 'Use be before going to.', 'Going to’dan önce be kullan.'))
      ],
      tip: _cx(e, 'Do not forget am/is/are before going to.',
          'Going to’dan önce am/is/are kullanmayı unutma.'),
    );

GrammarContextPack _canContext(bool e) => GrammarContextPack(
      heroIcon: Icons.psychology_alt_rounded,
      backgroundIcons: const [
        Icons.sports_soccer_rounded,
        Icons.translate_rounded,
        Icons.lock_open_rounded
      ],
      title: _cx(e, 'Use it for ability and permission',
          'Yetenek ve izin için kullan'),
      subtitle: _cx(e, 'can / can’t + V1', 'can / can’t + V1'),
      scene: _cx(e, 'You are saying what someone is able or allowed to do.',
          'Birinin ne yapabildiğini veya neye izinli olduğunu söylüyorsun.'),
      dialogueLines: [
        _d('A', 'Can you swim?'),
        _d('B', 'Yes, I can swim well.'),
        _d('A', 'Can I use your pen?'),
        _d('B', 'Sure, you can use it.')
      ],
      scenarios: [
        _s(
            Icons.sports_soccer_rounded,
            _cx(e, 'Ability', 'Yetenek'),
            'He can play football.',
            _cx(e, 'Can shows ability.', 'Can yetenek gösterir.')),
        _s(
            Icons.lock_open_rounded,
            _cx(e, 'Permission', 'İzin'),
            'You can sit here.',
            _cx(e, 'Can also gives permission.', 'Can izin de verir.')),
        _s(
            Icons.close_rounded,
            _cx(e, 'Negative', 'Olumsuz'),
            'I can’t drive a car.',
            _cx(e, 'Can’t means no ability or no permission.',
                'Can’t yapamama ya da izin olmama anlamı verir.'))
      ],
      tip: _cx(e, 'After can, use V1: can swim, not can swims.',
          'Can sonrasında V1 kullan: can swim; can swims değil.'),
    );

GrammarContextPack _thereIsAreContext(bool e) => GrammarContextPack(
      heroIcon: Icons.location_on_rounded,
      backgroundIcons: const [
        Icons.chair_rounded,
        Icons.home_rounded,
        Icons.map_rounded
      ],
      title: _cx(e, 'Use it to say something exists somewhere',
          'Bir yerde bir şey olduğunu söyle'),
      subtitle: _cx(e, 'there is / there are', 'there is / there are'),
      scene: _cx(e, 'You are describing a room, city, classroom, or picture.',
          'Bir oda, şehir, sınıf veya resmi tarif ediyorsun.'),
      dialogueLines: [
        _d('A', 'Is there a bank near here?'),
        _d('B', 'Yes, there is one on the corner.'),
        _d('A', 'Are there any students in the class?'),
        _d('B', 'Yes, there are three students.')
      ],
      scenarios: [
        _s(
            Icons.home_rounded,
            _cx(e, 'Room', 'Oda'),
            'There is a desk in my room.',
            _cx(e, 'Singular = there is.', 'Tekil = there is.')),
        _s(
            Icons.groups_rounded,
            _cx(e, 'Plural', 'Çoğul'),
            'There are two books on the table.',
            _cx(e, 'Plural = there are.', 'Çoğul = there are.')),
        _s(
            Icons.search_rounded,
            _cx(e, 'Question', 'Soru'),
            'Is there a café near here?',
            _cx(e, 'Move is/are to the front.', 'Is/are başa gelir.'))
      ],
      tip: _cx(e, 'Use there is for singular and there are for plural.',
          'Tekil için there is, çoğul için there are kullan.'),
    );

GrammarContextPack _articlesContext(bool e) => GrammarContextPack(
      heroIcon: Icons.label_rounded,
      backgroundIcons: const [
        Icons.looks_one_rounded,
        Icons.edit_rounded,
        Icons.book_rounded
      ],
      title: _cx(e, 'Use articles to introduce or identify nouns',
          'İsimleri tanıtmak veya belirlemek için kullan'),
      subtitle: _cx(e, 'a / an / the', 'a / an / the'),
      scene: _cx(
          e,
          'You mention a thing for the first time, then refer to the same thing again.',
          'Bir şeyi ilk kez söylüyor, sonra aynı şeye tekrar dönüyorsun.'),
      dialogueLines: [
        _d('A', 'I saw a dog in the street.'),
        _d('B', 'Was the dog friendly?'),
        _d('A', 'Yes, the dog was very cute.'),
        _d('B', 'I want a dog too.')
      ],
      scenarios: [
        _s(
            Icons.looks_one_rounded,
            _cx(e, 'First mention', 'İlk kullanım'),
            'I bought a book.',
            _cx(e, 'First time = a/an.', 'İlk kullanım = a/an.')),
        _s(
            Icons.repeat_rounded,
            _cx(e, 'Known noun', 'Bilinen isim'),
            'The book is very interesting.',
            _cx(e, 'Known/specific = the.', 'Bilinen/belirli = the.')),
        _s(
            Icons.record_voice_over_rounded,
            _cx(e, 'Sound', 'Ses'),
            'She is an engineer.',
            _cx(e, 'An before vowel sound.', 'Sesli harf sesi öncesi an.'))
      ],
      tip: _cx(
          e,
          'Use a/an for one non-specific thing; use the for a specific thing.',
          'Belirsiz tek şey için a/an, belirli şey için the kullan.'),
    );

GrammarContextPack _someAnyContext(bool e) => GrammarContextPack(
      heroIcon: Icons.scatter_plot_rounded,
      backgroundIcons: const [
        Icons.shopping_cart_rounded,
        Icons.kitchen_rounded,
        Icons.help_rounded
      ],
      title: _cx(
          e, 'Use it for unknown amounts', 'Belirsiz miktarlar için kullan'),
      subtitle: _cx(e, 'some in positive, any in negatives/questions',
          'Olumlu cümlede some, olumsuz/soruda any'),
      scene: _cx(
          e,
          'You are talking about food, shopping, or things without exact numbers.',
          'Yiyecek, alışveriş veya tam sayısı bilinmeyen şeylerden bahsediyorsun.'),
      dialogueLines: [
        _d('A', 'Do we have any milk?'),
        _d('B', 'Yes, we have some milk.'),
        _d('A', 'Are there any apples?'),
        _d('B', 'No, there aren’t any apples.')
      ],
      scenarios: [
        _s(
            Icons.check_circle_rounded,
            _cx(e, 'Positive', 'Olumlu'),
            'We have some bread.',
            _cx(e, 'Some is common in positive sentences.',
                'Olumlu cümlede some yaygındır.')),
        _s(
            Icons.help_rounded,
            _cx(e, 'Question', 'Soru'),
            'Do you have any money?',
            _cx(e, 'Any is common in questions.', 'Soruda any yaygındır.')),
        _s(
            Icons.close_rounded,
            _cx(e, 'Negative', 'Olumsuz'),
            'There isn’t any sugar.',
            _cx(e, 'Any is common in negatives.',
                'Olumsuz cümlede any yaygındır.'))
      ],
      tip: _cx(e, 'Simple rule: positive some; question/negative any.',
          'Basit kural: olumlu some; soru/olumsuz any.'),
    );

GrammarContextPack _howMuchManyContext(bool e) => GrammarContextPack(
      heroIcon: Icons.calculate_rounded,
      backgroundIcons: const [
        Icons.water_drop_rounded,
        Icons.format_list_numbered_rounded,
        Icons.shopping_cart_rounded
      ],
      title:
          _cx(e, 'Use it to ask about quantity', 'Miktar sormak için kullan'),
      subtitle: _cx(e, 'how much / how many', 'how much / how many'),
      scene: _cx(
          e,
          'You are asking the amount of something countable or uncountable.',
          'Sayılabilen ya da sayılamayan bir şeyin miktarını soruyorsun.'),
      dialogueLines: [
        _d('A', 'How many students are there?'),
        _d('B', 'There are twelve students.'),
        _d('A', 'How much water do we need?'),
        _d('B', 'We need two bottles.')
      ],
      scenarios: [
        _s(
            Icons.groups_rounded,
            _cx(e, 'Countable', 'Sayılabilir'),
            'How many chairs are there?',
            _cx(e, 'Use many with countable plural nouns.',
                'Sayılabilir çoğul isimlerle many kullan.')),
        _s(
            Icons.water_drop_rounded,
            _cx(e, 'Uncountable', 'Sayılamaz'),
            'How much water do you drink?',
            _cx(e, 'Use much with uncountable nouns.',
                'Sayılamaz isimlerle much kullan.')),
        _s(
            Icons.shopping_cart_rounded,
            _cx(e, 'Shopping', 'Alışveriş'),
            'How much cheese do you want?',
            _cx(e, 'Cheese is treated as uncountable here.',
                'Cheese burada sayılamaz kabul edilir.'))
      ],
      tip: _cx(e, 'Many = countable plural. Much = uncountable.',
          'Many = sayılabilir çoğul. Much = sayılamaz.'),
    );

GrammarContextPack _presentSimpleVsContinuousContext(bool e) =>
    GrammarContextPack(
      heroIcon: Icons.compare_rounded,
      backgroundIcons: const [
        Icons.repeat_rounded,
        Icons.motion_photos_on_rounded,
        Icons.timeline_rounded
      ],
      title: _cx(e, 'Separate routine from now', 'Rutini şu andan ayır'),
      subtitle: _cx(e, 'usually vs now', 'usually ve now farkı'),
      scene: _cx(
          e,
          'You decide whether the action is a habit or happening now.',
          'Eylemin alışkanlık mı şu an mı olduğunu ayırıyorsun.'),
      dialogueLines: [
        _d('A', 'What do you usually do after school?'),
        _d('B', 'I usually play football.'),
        _d('A', 'What are you doing now?'),
        _d('B', 'I am doing my homework now.')
      ],
      scenarios: [
        _s(
            Icons.repeat_rounded,
            _cx(e, 'Routine', 'Rutin'),
            'I walk to school every day.',
            _cx(e, 'Every day = Present Simple.',
                'Every day = Present Simple.')),
        _s(
            Icons.motion_photos_on_rounded,
            _cx(e, 'Now', 'Şu an'),
            'I am walking to school now.',
            _cx(e, 'Now = Present Continuous.', 'Now = Present Continuous.')),
        _s(
            Icons.warning_rounded,
            _cx(e, 'Contrast', 'Karşıtlık'),
            'She works in a bank, but she is studying tonight.',
            _cx(e, 'Permanent job vs temporary action.',
                'Kalıcı iş ve geçici eylem farkı.'))
      ],
      tip: _cx(e, 'Ask yourself: is it usually true, or is it happening now?',
          'Kendine sor: genelde mi doğru, yoksa şu an mı oluyor?'),
    );

GrammarContextPack _presentPerfectContext(bool e) => GrammarContextPack(
      heroIcon: Icons.done_all_rounded,
      backgroundIcons: const [
        Icons.travel_explore_rounded,
        Icons.history_toggle_off_rounded,
        Icons.task_alt_rounded
      ],
      title: _cx(e, 'Connect the past to now', 'Geçmişi şimdiye bağla'),
      subtitle: _cx(e, 'have / has + V3', 'have / has + V3'),
      scene: _cx(
          e,
          'You are talking about experience, recent results, or unfinished time.',
          'Deneyim, yeni sonuç veya bitmemiş zaman anlatıyorsun.'),
      dialogueLines: [
        _d('A', 'Have you ever been to Istanbul?'),
        _d('B', 'Yes, I have been there twice.'),
        _d('A', 'Have you finished your homework yet?'),
        _d('B', 'Yes, I have already finished it.')
      ],
      scenarios: [
        _s(
            Icons.travel_explore_rounded,
            _cx(e, 'Experience', 'Deneyim'),
            'I have visited London.',
            _cx(e, 'Life experience without exact past time.',
                'Net geçmiş zaman olmadan yaşam deneyimi.')),
        _s(
            Icons.task_alt_rounded,
            _cx(e, 'Result', 'Sonuç'),
            'She has finished her project.',
            _cx(e, 'The result matters now.', 'Sonuç şimdi önemlidir.')),
        _s(
            Icons.schedule_rounded,
            _cx(e, 'Unfinished time', 'Bitmemiş zaman'),
            'We have had two lessons this week.',
            _cx(e, 'This week is not finished.', 'Bu hafta henüz bitmedi.'))
      ],
      tip: _cx(
          e,
          'Do not use yesterday with Present Perfect. Use Past Simple for exact finished time.',
          'Yesterday ile Present Perfect kullanma. Net bitmiş zaman için Past Simple kullan.'),
    );

GrammarContextPack _presentPerfectVsPastSimpleContext(bool e) =>
    GrammarContextPack(
      heroIcon: Icons.alt_route_rounded,
      backgroundIcons: const [
        Icons.done_all_rounded,
        Icons.history_rounded,
        Icons.access_time_rounded
      ],
      title: _cx(e, 'Choose experience or exact past time',
          'Deneyim mi net geçmiş zaman mı seç'),
      subtitle: _cx(e, 'have done vs did', 'have done ve did farkı'),
      scene: _cx(e, 'You decide if the exact past time is important or not.',
          'Net geçmiş zamanın önemli olup olmadığını seçiyorsun.'),
      dialogueLines: [
        _d('A', 'Have you seen this movie?'),
        _d('B', 'Yes, I have seen it.'),
        _d('A', 'When did you see it?'),
        _d('B', 'I saw it last night.')
      ],
      scenarios: [
        _s(Icons.done_all_rounded, _cx(e, 'Experience', 'Deneyim'),
            'I have tried sushi.', _cx(e, 'No exact time.', 'Net zaman yok.')),
        _s(
            Icons.history_rounded,
            _cx(e, 'Exact past', 'Net geçmiş'),
            'I tried sushi yesterday.',
            _cx(e, 'Exact finished time.', 'Net bitmiş zaman.')),
        _s(
            Icons.question_mark_rounded,
            _cx(e, 'Follow-up', 'Devam sorusu'),
            'When did you try it?',
            _cx(e, 'When usually needs Past Simple.',
                'When genelde Past Simple ister.'))
      ],
      tip: _cx(
          e,
          'Have you ever...? asks experience. When did you...? asks exact past time.',
          'Have you ever...? deneyim sorar. When did you...? net geçmiş zaman sorar.'),
    );

GrammarContextPack _firstConditionalContext(bool e) => GrammarContextPack(
      heroIcon: Icons.device_thermostat_rounded,
      backgroundIcons: const [
        Icons.call_split_rounded,
        Icons.event_available_rounded,
        Icons.warning_rounded
      ],
      title: _cx(e, 'Use it for real future possibilities',
          'Gerçek gelecek ihtimalleri için kullan'),
      subtitle: _cx(e, 'if + present, will + V1', 'if + present, will + V1'),
      scene: _cx(
          e,
          'You are talking about a possible condition and its future result.',
          'Olası bir şart ve gelecekteki sonucunu anlatıyorsun.'),
      dialogueLines: [
        _d('A', 'What will you do if it rains?'),
        _d('B', 'If it rains, I will stay at home.'),
        _d('A', 'Will you call me if you finish early?'),
        _d('B', 'Yes, I will call you.')
      ],
      scenarios: [
        _s(
            Icons.cloud_rounded,
            _cx(e, 'Weather', 'Hava'),
            'If it rains, we will cancel the picnic.',
            _cx(e, 'Real possible future.', 'Gerçekçi gelecek ihtimali.')),
        _s(
            Icons.school_rounded,
            _cx(e, 'Study', 'Ders'),
            'If I study, I will pass the exam.',
            _cx(e, 'Condition + future result.', 'Şart + gelecek sonuç.')),
        _s(
            Icons.warning_rounded,
            _cx(e, 'Avoid', 'Kaçın'),
            'If he comes, I will tell him.',
            _cx(e, 'No will in the if-part.', 'If kısmında will kullanma.'))
      ],
      tip: _cx(
          e,
          'In first conditional, the if-part uses Present Simple, not will.',
          'First conditional’da if kısmı Present Simple alır; will almaz.'),
    );

GrammarContextPack _secondConditionalContext(bool e) => GrammarContextPack(
      heroIcon: Icons.auto_awesome_rounded,
      backgroundIcons: const [
        Icons.psychology_rounded,
        Icons.cloud_queue_rounded,
        Icons.question_answer_rounded
      ],
      title: _cx(e, 'Use it for imaginary present or future',
          'Hayali şimdi/gelecek için kullan'),
      subtitle: _cx(e, 'if + past, would + V1', 'if + past, would + V1'),
      scene: _cx(e, 'You imagine a different situation and its result.',
          'Farklı bir durumu ve sonucunu hayal ediyorsun.'),
      dialogueLines: [
        _d('A', 'What would you do if you had more time?'),
        _d('B', 'I would learn another language.'),
        _d('A', 'If you were rich, where would you live?'),
        _d('B', 'I would live by the sea.')
      ],
      scenarios: [
        _s(
            Icons.schedule_rounded,
            _cx(e, 'Imaginary time', 'Hayali zaman'),
            'If I had more time, I would travel.',
            _cx(e, 'Not real now.', 'Şu an gerçek değil.')),
        _s(
            Icons.account_balance_wallet_rounded,
            _cx(e, 'Dream', 'Hayal'),
            'If she had money, she would buy a car.',
            _cx(e, 'Imaginary condition.', 'Hayali şart.')),
        _s(
            Icons.person_rounded,
            _cx(e, 'Advice style', 'Tavsiye gibi'),
            'If I were you, I would apologize.',
            _cx(e, 'Common advice formula.', 'Yaygın tavsiye kalıbı.'))
      ],
      tip: _cx(
          e,
          'Use past form after if, but the meaning is imaginary present/future.',
          'If’ten sonra past form gelir ama anlam hayali şimdi/gelecektir.'),
    );

GrammarContextPack _thirdConditionalContext(bool e) => GrammarContextPack(
      heroIcon: Icons.replay_rounded,
      backgroundIcons: const [
        Icons.history_toggle_off_rounded,
        Icons.undo_rounded,
        Icons.error_outline_rounded
      ],
      title: _cx(e, 'Use it for unreal past results',
          'Gerçekleşmemiş geçmiş sonuçlar için kullan'),
      subtitle:
          _cx(e, 'if + had V3, would have V3', 'if + had V3, would have V3'),
      scene: _cx(e, 'You imagine how the past could have been different.',
          'Geçmişin nasıl farklı olabileceğini hayal ediyorsun.'),
      dialogueLines: [
        _d('A', 'What would have happened if you had studied?'),
        _d('B', 'I would have passed the exam.'),
        _d('A', 'Did you miss the bus?'),
        _d('B', 'Yes. If I had left earlier, I would have caught it.')
      ],
      scenarios: [
        _s(
            Icons.school_rounded,
            _cx(e, 'Regret', 'Pişmanlık'),
            'If I had studied, I would have passed.',
            _cx(e, 'Imaginary past.', 'Hayali geçmiş.')),
        _s(
            Icons.directions_bus_rounded,
            _cx(e, 'Missed chance', 'Kaçan fırsat'),
            'If she had left earlier, she would have caught the bus.',
            _cx(e, 'Past condition did not happen.',
                'Geçmiş şart gerçekleşmedi.')),
        _s(
            Icons.warning_rounded,
            _cx(e, 'Form', 'Yapı'),
            'I would have helped you.',
            _cx(e, 'would have + V3.', 'would have + V3.'))
      ],
      tip: _cx(e, 'Third conditional talks about the past, but it is not real.',
          'Third conditional geçmişten bahseder ama gerçek değildir.'),
    );

GrammarContextPack _passiveContext(bool e) => GrammarContextPack(
      heroIcon: Icons.swap_horiz_rounded,
      backgroundIcons: const [
        Icons.factory_rounded,
        Icons.newspaper_rounded,
        Icons.visibility_off_rounded
      ],
      title: _cx(e, 'Focus on the action, not the doer',
          'Yapan kişiye değil eyleme odaklan'),
      subtitle: _cx(e, 'be + V3', 'be + V3'),
      scene: _cx(e, 'The action or result is more important than who did it.',
          'Eylem veya sonuç, yapan kişiden daha önemli.'),
      dialogueLines: [
        _d('A', 'Who made this cake?'),
        _d('B', 'It was made by my mother.'),
        _d('A', 'When was the bridge built?'),
        _d('B', 'It was built in 2010.')
      ],
      scenarios: [
        _s(
            Icons.newspaper_rounded,
            _cx(e, 'News', 'Haber'),
            'The bank was robbed last night.',
            _cx(e, 'The action is the focus.', 'Odak eylemdir.')),
        _s(
            Icons.factory_rounded,
            _cx(e, 'Production', 'Üretim'),
            'These cars are made in Germany.',
            _cx(e, 'Common for products.', 'Ürünlerde sık kullanılır.')),
        _s(
            Icons.visibility_off_rounded,
            _cx(e, 'Unknown doer', 'Bilinmeyen yapan'),
            'My phone was stolen.',
            _cx(e, 'The doer is unknown or unimportant.',
                'Yapan bilinmiyor veya önemsiz.'))
      ],
      tip: _cx(e, 'Passive needs be + V3. Change be for the tense.',
          'Passive be + V3 ister. Zamana göre be değişir.'),
    );

GrammarContextPack _reportedSpeechContext(bool e) => GrammarContextPack(
      heroIcon: Icons.record_voice_over_rounded,
      backgroundIcons: const [
        Icons.chat_rounded,
        Icons.forum_rounded,
        Icons.arrow_back_rounded
      ],
      title: _cx(e, 'Report what someone said', 'Birinin söylediğini aktar'),
      subtitle: _cx(e, 'said that / told me that', 'said that / told me that'),
      scene: _cx(e, 'You tell another person what someone said earlier.',
          'Birinin daha önce söylediğini başka birine aktarıyorsun.'),
      dialogueLines: [
        _d('A', 'What did Ali say?'),
        _d('B', 'He said that he was tired.'),
        _d('A', 'Did he call you?'),
        _d('B', 'Yes. He told me that he would come later.')
      ],
      scenarios: [
        _s(
            Icons.chat_rounded,
            _cx(e, 'Statement', 'Cümle'),
            'She said that she was busy.',
            _cx(e, 'Backshift is common.', 'Zaman geri kayması yaygındır.')),
        _s(
            Icons.person_rounded,
            _cx(e, 'Tell someone', 'Birine söylemek'),
            'He told me that he needed help.',
            _cx(e, 'Tell needs an object.', 'Tell nesne ister.')),
        _s(
            Icons.arrow_back_rounded,
            _cx(e, 'Earlier words', 'Önceki sözler'),
            'He said that he was tired after the lesson.',
            _cx(e, 'am often becomes was in reported speech.',
                'am çoğunlukla was olur.'))
      ],
      tip: _cx(
          e,
          'Say does not need an object; tell usually needs one: told me.',
          'Say nesne istemez; tell genelde ister: told me.'),
    );

GrammarContextPack _relativeClausesContext(bool e) => GrammarContextPack(
      heroIcon: Icons.link_rounded,
      backgroundIcons: const [
        Icons.person_search_rounded,
        Icons.place_rounded,
        Icons.merge_type_rounded
      ],
      title: _cx(
          e, 'Add information about a noun', 'Bir isim hakkında bilgi ekle'),
      subtitle:
          _cx(e, 'who / which / that / where', 'who / which / that / where'),
      scene: _cx(
          e,
          'You identify a person, thing, or place by adding extra information.',
          'Kişi, şey veya yeri ek bilgiyle tanımlıyorsun.'),
      dialogueLines: [
        _d('A', 'Who is Tom?'),
        _d('B', 'He is the student who sits next to me.'),
        _d('A', 'Which phone is yours?'),
        _d('B', 'The phone that has a black case is mine.')
      ],
      scenarios: [
        _s(
            Icons.person_rounded,
            _cx(e, 'Person', 'Kişi'),
            'The woman who lives next door is a doctor.',
            _cx(e, 'Use who for people.', 'İnsanlar için who.')),
        _s(
            Icons.phone_android_rounded,
            _cx(e, 'Thing', 'Şey'),
            'The phone that I bought is expensive.',
            _cx(e, 'Use which/that for things.', 'Şeyler için which/that.')),
        _s(
            Icons.place_rounded,
            _cx(e, 'Place', 'Yer'),
            'This is the café where we met.',
            _cx(e, 'Use where for places.', 'Yerler için where.'))
      ],
      tip: _cx(
          e,
          'Relative clauses help you avoid short, disconnected sentences.',
          'Relative clause kısa ve kopuk cümleleri birleştirir.'),
    );

GrammarContextPack _wishContext(bool e) => GrammarContextPack(
      heroIcon: Icons.nights_stay_rounded,
      backgroundIcons: const [
        Icons.sentiment_dissatisfied_rounded,
        Icons.auto_awesome_rounded,
        Icons.replay_rounded
      ],
      title: _cx(
          e, 'Use it for wishes and regrets', 'Dilek ve pişmanlık için kullan'),
      subtitle: _cx(e, 'wish / if only', 'wish / if only'),
      scene: _cx(e, 'You want reality to be different now or in the past.',
          'Gerçeğin şimdi ya da geçmişte farklı olmasını istiyorsun.'),
      dialogueLines: [
        _d('A', 'Do you like living here?'),
        _d('B', 'It is okay, but I wish I lived near the sea.'),
        _d('A', 'Did you study enough?'),
        _d('B', 'No. I wish I had studied more.')
      ],
      scenarios: [
        _s(
            Icons.home_rounded,
            _cx(e, 'Present wish', 'Şimdiki dilek'),
            'I wish I lived in London.',
            _cx(e, 'Unreal present.', 'Gerçek olmayan şimdi.')),
        _s(
            Icons.replay_rounded,
            _cx(e, 'Past regret', 'Geçmiş pişmanlık'),
            'I wish I had listened to you.',
            _cx(e, 'Regret about the past.', 'Geçmişle ilgili pişmanlık.')),
        _s(
            Icons.volume_off_rounded,
            _cx(e, 'Complaint', 'Şikâyet'),
            'I wish you would stop shouting.',
            _cx(e, 'Annoying repeated action.', 'Rahatsız eden tekrar.'))
      ],
      tip: _cx(e, 'Wish often moves one step back from reality.',
          'Wish yapısı genelde gerçek zamandan bir adım geriye gider.'),
    );

GrammarContextPack _inversionContext(bool e) => GrammarContextPack(
      heroIcon: Icons.flip_to_front_rounded,
      backgroundIcons: const [
        Icons.workspace_premium_rounded,
        Icons.swap_vert_rounded,
        Icons.school_rounded
      ],
      title: _cx(e, 'Use it for formal emphasis', 'Resmî vurgu için kullan'),
      subtitle: _cx(e, 'negative phrase + auxiliary + subject',
          'olumsuz ifade + yardımcı + özne'),
      scene: _cx(
          e,
          'You want a formal, dramatic, or academic sentence opening.',
          'Resmî, etkileyici veya akademik bir cümle başlangıcı istiyorsun.'),
      dialogueLines: [
        _d('A', 'Was the lecture impressive?'),
        _d('B', 'Never have I heard such a clear explanation.'),
        _d('A', 'When did you understand the problem?'),
        _d('B', 'Only then did I understand the real issue.')
      ],
      scenarios: [
        _s(
            Icons.block_rounded,
            _cx(e, 'Negative opening', 'Olumsuz başlangıç'),
            'Never have I seen such a view.',
            _cx(e, 'Use auxiliary before subject.',
                'Yardımcı fiil öznenin önüne gelir.')),
        _s(
            Icons.timelapse_rounded,
            _cx(e, 'Only then', 'Ancak o zaman'),
            'Only then did I realize my mistake.',
            _cx(e, 'Did appears before the subject.',
                'Did öznenin önüne gelir.')),
        _s(
            Icons.school_rounded,
            _cx(e, 'Formal style', 'Resmî tarz'),
            'Rarely do students notice this detail.',
            _cx(e, 'Useful in advanced writing.',
                'İleri seviye yazıda kullanışlıdır.'))
      ],
      tip: _cx(
          e,
          'Inversion is advanced style; use it for emphasis, not every sentence.',
          'Inversion ileri seviye bir stildir; her cümlede değil vurgu için kullan.'),
    );

GrammarContextPack _cleftContext(bool e) => GrammarContextPack(
      heroIcon: Icons.center_focus_strong_rounded,
      backgroundIcons: const [
        Icons.filter_center_focus_rounded,
        Icons.adjust_rounded,
        Icons.highlight_rounded
      ],
      title: _cx(e, 'Use it to focus one part strongly',
          'Bir bölümü güçlü biçimde vurgula'),
      subtitle: _cx(e, 'It was... who / What I need is...',
          'It was... who / What I need is...'),
      scene: _cx(
          e,
          'You want to highlight exactly who, what, where, or why matters.',
          'Tam olarak kimin, neyin, nerede veya neden önemli olduğunu vurguluyorsun.'),
      dialogueLines: [
        _d('A', 'Who helped you?'),
        _d('B', 'It was my brother who helped me.'),
        _d('A', 'What do you need now?'),
        _d('B', 'What I need is a short break.')
      ],
      scenarios: [
        _s(
            Icons.person_rounded,
            _cx(e, 'Person focus', 'Kişi vurgusu'),
            'It was my teacher who encouraged me.',
            _cx(e, 'Focus on the person.', 'Kişiye vurgu.')),
        _s(
            Icons.coffee_rounded,
            _cx(e, 'Need focus', 'İhtiyaç vurgusu'),
            'What I need is a coffee.',
            _cx(e, 'Focus on the thing needed.',
                'İhtiyaç duyulan şeye vurgu.')),
        _s(
            Icons.place_rounded,
            _cx(e, 'Place focus', 'Yer vurgusu'),
            'It was in Kayseri that I met him.',
            _cx(e, 'Focus on the place.', 'Yere vurgu.'))
      ],
      tip: _cx(e, 'Cleft sentences sound polished when you need strong focus.',
          'Cleft sentences güçlü vurgu gerektiğinde daha polished duyulur.'),
    );

GrammarContextPack _nominalisationContext(bool e) => GrammarContextPack(
      heroIcon: Icons.account_tree_rounded,
      backgroundIcons: const [
        Icons.subject_rounded,
        Icons.article_rounded,
        Icons.school_rounded
      ],
      title: _cx(e, 'Turn actions into academic noun phrases',
          'Eylemleri akademik isim gruplarına çevir'),
      subtitle: _cx(e, 'expansion / completion / the fact that',
          'expansion / completion / the fact that'),
      scene: _cx(
          e,
          'You are making a sentence more compact, formal, and academic.',
          'Cümleyi daha yoğun, resmi ve akademik hale getiriyorsun.'),
      dialogueLines: [
        _d('A', 'How can I make this sound more academic?'),
        _d('B', 'Use a noun phrase: the rapid expansion of the service.'),
        _d('A', 'So I should not write it like a spoken sentence?'),
        _d('B', 'Exactly. Make the action a focused noun idea.')
      ],
      scenarios: [
        _s(
            Icons.trending_up_rounded,
            _cx(e, 'Process as noun', 'Süreç isim gibi'),
            'The rapid expansion of the service surprised investors.',
            _cx(e, 'Expansion carries the action as a noun.',
                'Expansion eylemi isim gibi taşır.')),
        _s(
            Icons.fact_check_rounded,
            _cx(e, 'Whole idea', 'Bütün fikir'),
            'The fact that demand increased changed our strategy.',
            _cx(e, 'A full idea can act as a noun phrase.',
                'Tam fikir isim grubu gibi davranabilir.')),
        _s(
            Icons.done_all_rounded,
            _cx(e, 'After preposition', 'Preposition sonrası'),
            'After the completion of the project, the team celebrated.',
            _cx(e, 'After can take a noun phrase.',
                'After isim grubu alabilir.'))
      ],
      tip: _cx(
          e,
          'Nominalisation is powerful in essays, but too much of it can sound heavy.',
          'Nominalisation essaylerde güçlüdür ama fazlası cümleyi ağırlaştırır.'),
    );

GrammarContextPack _hedgingContext(bool e) => GrammarContextPack(
      heroIcon: Icons.balance_rounded,
      backgroundIcons: const [
        Icons.psychology_rounded,
        Icons.insights_rounded,
        Icons.science_rounded
      ],
      title: _cx(e, 'Sound precise without overclaiming',
          'Aşırı iddia etmeden net konuş'),
      subtitle: _cx(e, 'may well / tends to / appears to',
          'may well / tends to / appears to'),
      scene: _cx(
          e,
          'You are writing academically and you want your claim to sound careful.',
          'Akademik yazıda iddianın temkinli ve güvenilir duyulmasını istiyorsun.'),
      dialogueLines: [
        _d('A', 'Can I say this always works?'),
        _d('B', 'Better: It appears that this approach works in many cases.'),
        _d('A', 'So I should be less absolute?'),
        _d('B', 'Yes. Academic language often sounds careful.')
      ],
      scenarios: [
        _s(
            Icons.visibility_rounded,
            _cx(e, 'Appears that', 'Appears that'),
            'It appears that the policy has reduced costs.',
            _cx(e, 'Careful claim based on evidence.',
                'Kanıta dayalı temkinli iddia.')),
        _s(
            Icons.trending_flat_rounded,
            _cx(e, 'Tends to', 'Tends to'),
            'Online feedback tends to improve motivation.',
            _cx(e, 'Generalization without absolute certainty.',
                'Kesinlik olmadan genelleme.')),
        _s(
            Icons.auto_awesome_rounded,
            _cx(e, 'May well', 'May well'),
            'This trend may well continue next year.',
            _cx(e, 'Strong but cautious possibility.',
                'Güçlü ama temkinli olasılık.'))
      ],
      tip: _cx(
          e,
          'Hedging makes advanced writing sound more credible, not weaker.',
          'Hedging ileri seviye yazıyı zayıf değil, daha güvenilir gösterir.'),
    );

GrammarContextPack _ellipsisSubstitutionContext(bool e) => GrammarContextPack(
      heroIcon: Icons.compress_rounded,
      backgroundIcons: const [
        Icons.short_text_rounded,
        Icons.repeat_rounded,
        Icons.swap_horiz_rounded
      ],
      title: _cx(e, 'Avoid repeating the same idea',
          'Aynı fikri tekrar etmekten kaçın'),
      subtitle: _cx(e, 'so / do so / did not', 'so / do so / did not'),
      scene: _cx(e, 'You keep the sentence smooth by replacing repeated words.',
          'Tekrar eden kelimeleri değiştirerek cümleyi akıcı tutuyorsun.'),
      dialogueLines: [
        _d('A', 'Do you think the plan will work?'),
        _d('B', 'I think so.'),
        _d('A', 'Will the company reduce prices again?'),
        _d('B', 'It may continue to do so.')
      ],
      scenarios: [
        _s(
            Icons.chat_rounded,
            _cx(e, 'So', 'So'),
            'I think so.',
            _cx(e, 'So replaces the previous idea.',
                'So önceki fikrin yerine geçer.')),
        _s(
            Icons.business_rounded,
            _cx(e, 'Do so', 'Do so'),
            'The company reduced prices and will continue to do so.',
            _cx(e, 'Do so replaces the action.',
                'Do so eylemin yerine geçer.')),
        _s(
            Icons.remove_done_rounded,
            _cx(e, 'Auxiliary only', 'Sadece yardımcı'),
            'Some students passed, but others did not.',
            _cx(e, 'Do not repeat the main verb unnecessarily.',
                'Ana fiili gereksiz tekrar etme.'))
      ],
      tip: _cx(
          e,
          'Substitution makes advanced writing cleaner and less repetitive.',
          'Substitution ileri seviye yazıyı daha temiz ve daha az tekrarlı yapar.'),
    );

GrammarContextPack _frontingContext(bool e) => GrammarContextPack(
      heroIcon: Icons.vertical_align_top_rounded,
      backgroundIcons: const [
        Icons.swap_vert_rounded,
        Icons.view_stream_rounded,
        Icons.auto_stories_rounded
      ],
      title:
          _cx(e, 'Move information for emphasis', 'Vurgu için bilgiyi öne al'),
      subtitle:
          _cx(e, 'fronting and information flow', 'fronting ve bilgi akışı'),
      scene: _cx(e, 'You control what the reader notices first.',
          'Okuyucunun ilk neyi fark edeceğini kontrol ediyorsun.'),
      dialogueLines: [
        _d('A', 'Can I make this sentence more dramatic?'),
        _d('B', 'Yes: At the end of the corridor stood a small wooden door.'),
        _d('A', 'So the place comes first?'),
        _d('B', 'Exactly. The opening controls the atmosphere.')
      ],
      scenarios: [
        _s(
            Icons.place_rounded,
            _cx(e, 'Place first', 'Yer başta'),
            'At the end of the corridor stood a small wooden door.',
            _cx(e, 'Creates a descriptive opening.',
                'Betimleyici başlangıç kurar.')),
        _s(
            Icons.warning_rounded,
            _cx(e, 'Object focus', 'Nesne odağı'),
            'This problem we cannot ignore.',
            _cx(e, 'The object is highlighted.', 'Nesne vurgulanır.')),
        _s(
            Icons.center_focus_strong_rounded,
            _cx(e, 'Idea focus', 'Fikir odağı'),
            'What matters most is clarity.',
            _cx(e, 'The important idea comes into focus.',
                'Önemli fikir odağa gelir.'))
      ],
      tip: _cx(e, 'Fronting is stylish; use it when the emphasis is worth it.',
          'Fronting stilistiktir; vurgu gerçekten gerekliyse kullan.'),
    );

GrammarContextPack _advancedConditionalsContext(bool e) => GrammarContextPack(
      heroIcon: Icons.alt_route_rounded,
      backgroundIcons: const [
        Icons.call_split_rounded,
        Icons.history_edu_rounded,
        Icons.mail_outline_rounded
      ],
      title: _cx(e, 'Use formal conditional openings',
          'Resmi conditional başlangıçları kullan'),
      subtitle: _cx(
          e,
          'Were it not for / Had it not been for / Should you need',
          'Were it not for / Had it not been for / Should you need'),
      scene: _cx(
          e,
          'You are writing formally and want a polished conditional structure.',
          'Resmi yazıda daha polished bir conditional yapı istiyorsun.'),
      dialogueLines: [
        _d('A', 'Can I start without if?'),
        _d('B',
            'Yes: Had it not been for the delay, we would have arrived on time.'),
        _d('A', 'Is that formal?'),
        _d('B', 'Very. It is common in advanced writing.')
      ],
      scenarios: [
        _s(
            Icons.handshake_rounded,
            _cx(e, 'Were it not for', 'Were it not for'),
            'Were it not for your help, we would have failed.',
            _cx(e, 'Formal unreal present/past support.',
                'Resmi gerçek dışı destek ifadesi.')),
        _s(
            Icons.history_rounded,
            _cx(e, 'Had it not been for', 'Had it not been for'),
            'Had it not been for the delay, we would have arrived on time.',
            _cx(e, 'Unreal past condition.', 'Geçmiş gerçek dışı koşul.')),
        _s(
            Icons.email_rounded,
            _cx(e, 'Should you need', 'Should you need'),
            'Should you need further details, please contact me.',
            _cx(e, 'Formal future possibility.', 'Resmi gelecek olasılığı.'))
      ],
      tip: _cx(
          e,
          'These forms are advanced and formal; perfect for essays and professional emails.',
          'Bu yapılar ileri ve resmidir; essay ve profesyonel e-postalarda çok iyi durur.'),
    );

GrammarContextPack _discourseMarkersContext(bool e) => GrammarContextPack(
      heroIcon: Icons.hub_rounded,
      backgroundIcons: const [
        Icons.compare_arrows_rounded,
        Icons.format_quote_rounded,
        Icons.route_rounded
      ],
      title: _cx(e, 'Guide the reader through complex ideas',
          'Okuyucuyu karmaşık fikirler içinde yönlendir'),
      subtitle: _cx(e, 'That said / Be that as it may / For that matter',
          'That said / Be that as it may / For that matter'),
      scene: _cx(
          e,
          'You connect ideas with advanced transitions instead of simple but/because.',
          'Basit but/because yerine ileri seviye geçişlerle fikirleri bağlıyorsun.'),
      dialogueLines: [
        _d('A', 'Is the plan risky?'),
        _d('B', 'Yes. That said, it could bring major benefits.'),
        _d('A', 'So we can still support it?'),
        _d('B', 'Be that as it may, we need a safer version.')
      ],
      scenarios: [
        _s(
            Icons.sync_alt_rounded,
            _cx(e, 'That said', 'That said'),
            'The plan is risky. That said, it could bring benefits.',
            _cx(e, 'Contrast with balance.', 'Dengeli zıtlık kurar.')),
        _s(
            Icons.gavel_rounded,
            _cx(e, 'Be that as it may', 'Be that as it may'),
            'Be that as it may, we still need a solution.',
            _cx(e, 'Formal concession.', 'Resmi concession.')),
        _s(
            Icons.add_circle_outline_rounded,
            _cx(e, 'For that matter', 'For that matter'),
            'No one checked the data, or the sources for that matter.',
            _cx(e, 'Adds a related point.', 'Bağlantılı nokta ekler.'))
      ],
      tip: _cx(
          e,
          'Advanced markers are useful only when the logical relationship is clear.',
          'İleri markerlar sadece mantık ilişkisi netse işe yarar.'),
    );

GrammarContextPack _registerStyleContext(bool e) => GrammarContextPack(
      heroIcon: Icons.workspace_premium_rounded,
      backgroundIcons: const [
        Icons.mail_rounded,
        Icons.description_rounded,
        Icons.school_rounded
      ],
      title: _cx(e, 'Choose the right style for the situation',
          'Duruma uygun tarzı seç'),
      subtitle:
          _cx(e, 'formal / academic / polite', 'formal / academic / polite'),
      scene: _cx(
          e,
          'You change the same message depending on audience and purpose.',
          'Aynı mesajı hedef kitleye ve amaca göre değiştiriyorsun.'),
      dialogueLines: [
        _d('A', 'Is “send me the file” okay?'),
        _d('B',
            'With friends, maybe. In a formal email: I would be grateful if you could send the file.'),
        _d('A', 'So grammar changes the tone?'),
        _d('B', 'Exactly. Structure creates register.')
      ],
      scenarios: [
        _s(
            Icons.mail_outline_rounded,
            _cx(e, 'Polite email', 'Kibar e-posta'),
            'I would be grateful if you could send the documents.',
            _cx(e, 'Indirect request sounds formal.',
                'Dolaylı rica resmi duyulur.')),
        _s(
            Icons.school_rounded,
            _cx(e, 'Academic claim', 'Akademik iddia'),
            'The findings highlight the need for further research.',
            _cx(e, 'Precise nouns create academic tone.',
                'Net isimler akademik ton kurar.')),
        _s(
            Icons.person_off_rounded,
            _cx(e, 'Less personal', 'Daha az kişisel'),
            'This essay argues that technology shapes learning.',
            _cx(e, 'Focus on argument, not casual self-reference.',
                'Gündelik ben dilinden çok argümana odaklan.'))
      ],
      tip: _cx(e, 'C2 grammar is often about control: same idea, better tone.',
          'C2 gramer çoğu zaman kontroldür: aynı fikir, daha iyi ton.'),
    );

GrammarContextPack _wouldLikeContext(bool e) => GrammarContextPack(
      heroIcon: Icons.local_cafe_rounded,
      backgroundIcons: const [
        Icons.restaurant_rounded,
        Icons.handshake_rounded,
        Icons.question_answer_rounded
      ],
      title: _cx(
          e, 'Use polite requests naturally', 'Kibar istekleri doğal kullan'),
      subtitle: _cx(e, 'would like + noun / would like to + V1',
          'would like + isim / would like to + V1'),
      scene: _cx(e, 'You are ordering, offering, or asking politely.',
          'Sipariş veriyor, teklif ediyor veya kibarca soruyorsun.'),
      dialogueLines: [
        _d('A', 'Would you like some tea?'),
        _d('B', 'Yes, I would like some tea, please.'),
        _d('A', 'Would you like to join us?'),
        _d('B', 'I would like to join you.')
      ],
      scenarios: [
        _s(
            Icons.local_cafe_rounded,
            _cx(e, 'At a café', 'Kafede'),
            'I would like some coffee, please.',
            _cx(e, 'Polite ordering.', 'Kibar sipariş.')),
        _s(
            Icons.group_add_rounded,
            _cx(e, 'Invitation', 'Davet'),
            'Would you like to come with us?',
            _cx(e, 'Polite invitation.', 'Kibar davet.')),
        _s(
            Icons.event_available_rounded,
            _cx(e, 'Plan', 'Plan'),
            'I would like to visit Ankara this summer.',
            _cx(e, 'Polite way to talk about wants.',
                'İstekleri kibar anlatır.'))
      ],
      tip: _cx(e, 'Use to before a verb: would like to go.',
          'Fiilden önce to kullan: would like to go.'),
    );

GrammarContextPack _presentContinuousFutureContext(bool e) =>
    GrammarContextPack(
      heroIcon: Icons.event_available_rounded,
      backgroundIcons: const [
        Icons.flight_takeoff_rounded,
        Icons.calendar_month_rounded,
        Icons.group_rounded
      ],
      title: _cx(e, 'Use it for fixed future arrangements',
          'Kesinleşmiş gelecek planları için kullan'),
      subtitle: _cx(e, 'am / is / are + V-ing + future time',
          'am / is / are + V-ing + gelecek zaman'),
      scene: _cx(e, 'You are talking about a plan that is already arranged.',
          'Önceden ayarlanmış bir plandan bahsediyorsun.'),
      dialogueLines: [
        _d('A', 'What are you doing on Friday?'),
        _d('B', 'I am flying to Ankara on Friday.'),
        _d('A', 'Are you meeting Deniz tonight?'),
        _d('B', 'Yes, we are meeting at seven.')
      ],
      scenarios: [
        _s(
            Icons.flight_takeoff_rounded,
            _cx(e, 'Travel', 'Seyahat'),
            'She is flying to Ankara on Friday.',
            _cx(e, 'The future time makes the plan clear.',
                'Gelecek zaman planı netleştirir.')),
        _s(
            Icons.restaurant_rounded,
            _cx(e, 'Dinner', 'Akşam yemeği'),
            'We are having dinner with friends tonight.',
            _cx(e, 'Arranged social plan.', 'Ayarlanmış sosyal plan.')),
        _s(
            Icons.video_call_rounded,
            _cx(e, 'Meeting', 'Toplantı'),
            'I am meeting my teacher tomorrow.',
            _cx(e, 'Fixed future arrangement.', 'Kesinleşmiş gelecek planı.'))
      ],
      tip: _cx(e, 'Do not forget am / is / are before V-ing.',
          'V-ing’den önce am / is / are kullanmayı unutma.'),
    );

GrammarContextPack _fallbackContext(GrammarLesson lesson, bool e) {
  final title = e ? 'Use it in real life' : 'Gerçek hayatta kullan';
  final subtitle = e ? lesson.bigTitle : lesson.bigTitle;
  final model = _fallbackContextModel(lesson);
  return GrammarContextPack(
    heroIcon: Icons.auto_awesome_rounded,
    backgroundIcons: const [
      Icons.chat_rounded,
      Icons.menu_book_rounded,
      Icons.edit_note_rounded
    ],
    title: title,
    subtitle: subtitle,
    scene: _cx(e, 'See this grammar point inside a short, natural situation.',
        'Bu grammar konusunu kısa ve doğal bir durum içinde gör.'),
    dialogueLines: [
      _d('A', 'Can you give me an example?'),
      _d('B', model),
      _d('A', 'Can I make a similar sentence?'),
      _d('B', 'Yes. Change the person, place, or time.')
    ],
    scenarios: [
      _s(
          Icons.school_rounded,
          _cx(e, 'Class answer', 'Sınıf cevabı'),
          model,
          _cx(e, 'Use it as a clear classroom sentence.',
              'Bunu net bir sınıf cümlesi gibi kullan.')),
      _s(Icons.chat_rounded, _cx(e, 'Conversation', 'Konuşma'), model,
          _cx(e, 'Keep it short and natural.', 'Kısa ve doğal tut.')),
      _s(
          Icons.edit_rounded,
          _cx(e, 'Your version', 'Kendi versiyonun'),
          model,
          _cx(e, 'Change one detail and produce your own sentence.',
              'Bir ayrıntıyı değiştirip kendi cümleni üret.'))
    ],
    tip: _cx(e, 'Context is for real usage, not rule memorization.',
        'Context gerçek kullanım içindir, kural ezberi için değil.'),
  );
}

String _fallbackContextModel(GrammarLesson lesson) {
  final candidates = <String>[
    if (lesson.right.trim().isNotEmpty) lesson.right,
    ...lesson.examples,
    if (lesson.modelAnswer.trim().isNotEmpty) lesson.modelAnswer,
    ...lesson.formulaRows.map((e) => e.sample),
  ];
  for (final item in candidates) {
    final s = item.trim();
    if (s.length > 8 &&
        s.endsWith('.') &&
        !s.contains(' + ') &&
        !s.contains('→')) {
      return s;
    }
  }
  return 'This structure appears in natural speech.';
}

// -----------------------------------------------------------------------------
// Phase172 — Full Curriculum Coverage Map
// -----------------------------------------------------------------------------
// This map is intentionally data-only. It helps us fill grammar_a1.dart,
// grammar_a2.dart, grammar_b1.dart, grammar_b2.dart, grammar_c1.dart and
// grammar_c2.dart without forgetting core topics. The generator can also use
// these titles/aliases as a stable reference while we expand level files.

class GrammarCurriculumItem {
  final String level;
  final String title;
  final String generatorKey;
  final String stage;
  final List<String> aliases;

  const GrammarCurriculumItem({
    required this.level,
    required this.title,
    required this.generatorKey,
    required this.stage,
    this.aliases = const [],
  });
}

const List<GrammarCurriculumItem> grammarFullCurriculumMap = [
  // A1 — Foundations
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'am / is / are',
      generatorKey: 'be_present',
      aliases: ['verb to be', 'to be', 'am is are', 'be forms']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'Subject Pronouns',
      generatorKey: 'subject_pronouns',
      aliases: ['I you he she it we they']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'Possessive Adjectives',
      generatorKey: 'possessive_adjectives',
      aliases: ['my your his her its our their']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'a / an / the',
      generatorKey: 'articles',
      aliases: ['articles', 'indefinite article', 'definite article']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'Singular / Plural Nouns',
      generatorKey: 'singular_plural',
      aliases: ['plural nouns', 'regular plurals', 'irregular plurals']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'this / that / these / those',
      generatorKey: 'demonstratives',
      aliases: ['demonstrative pronouns', 'demonstrative adjectives']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'have got / has got',
      generatorKey: 'have_got',
      aliases: ['has got', 'possession']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'foundation',
      title: 'there is / there are',
      generatorKey: 'there_is_are',
      aliases: ['existence', 'there is', 'there are']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'ability',
      title: 'can / can’t',
      generatorKey: 'can_ability',
      aliases: ['can cannot', 'ability', 'permission can']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'classroom',
      title: 'Imperatives',
      generatorKey: 'imperatives',
      aliases: ['commands', 'instructions', 'classroom instructions']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'present',
      title: 'Present Simple Positive',
      generatorKey: 'present_simple_positive',
      aliases: ['simple present positive', 'habits positive']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'present',
      title: 'Present Simple Negative',
      generatorKey: 'present_simple_negative',
      aliases: ['do not does not', 'don’t doesn’t']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'present',
      title: 'Present Simple Questions',
      generatorKey: 'present_simple_questions',
      aliases: ['do does questions', 'simple present questions']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'present',
      title: 'Adverbs of Frequency',
      generatorKey: 'frequency_adverbs',
      aliases: ['always usually often sometimes never']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'present',
      title: 'Present Continuous',
      generatorKey: 'present_continuous',
      aliases: ['present progressive', 'am is are ving']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'present',
      title: 'Present Simple vs Present Continuous',
      generatorKey: 'present_simple_vs_continuous',
      aliases: ['routine vs now', 'stative contrast intro']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'pronouns',
      title: 'Object Pronouns',
      generatorKey: 'object_pronouns',
      aliases: ['me you him her it us them']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'possession',
      title: 'Possessive ’s',
      generatorKey: 'possessive_s',
      aliases: ['apostrophe s', 'genitive s']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'prepositions',
      title: 'Prepositions of Place',
      generatorKey: 'prepositions_place',
      aliases: ['in on under next to between behind']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'prepositions',
      title: 'Prepositions of Time',
      generatorKey: 'prepositions_time',
      aliases: ['in on at time', 'time prepositions']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'determiners',
      title: 'some / any',
      generatorKey: 'some_any',
      aliases: ['some and any', 'affirmative negative questions']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'nouns',
      title: 'Countable / Uncountable Nouns',
      generatorKey: 'countable_uncountable',
      aliases: ['count nouns', 'uncount nouns']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'questions',
      title: 'How much / How many',
      generatorKey: 'how_much_many',
      aliases: ['quantity questions']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'questions',
      title: 'Question Words',
      generatorKey: 'question_words',
      aliases: ['what where when why who how which']),
  GrammarCurriculumItem(
      level: 'A1',
      stage: 'linking',
      title: 'Basic Conjunctions',
      generatorKey: 'basic_conjunctions',
      aliases: ['and but because so']),

  // A2 — Core expansion
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'past',
      title: 'Past Simple: Regular Verbs',
      generatorKey: 'past_simple_regular',
      aliases: ['regular past', 'ed endings']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'past',
      title: 'Past Simple: Irregular Verbs',
      generatorKey: 'past_simple_irregular',
      aliases: ['irregular past', 'v2']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'past',
      title: 'Past Simple Negative and Questions',
      generatorKey: 'past_simple_did',
      aliases: ['did questions', 'did not', 'didn’t']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'past',
      title: 'Past Continuous',
      generatorKey: 'past_continuous',
      aliases: ['was were ving', 'past progressive']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'past',
      title: 'Past Simple vs Past Continuous',
      generatorKey: 'past_simple_vs_continuous',
      aliases: ['when while', 'interrupted action']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'future',
      title: 'will',
      generatorKey: 'will_future',
      aliases: ['future simple', 'prediction', 'promise']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'future',
      title: 'be going to',
      generatorKey: 'going_to',
      aliases: ['planned future', 'intention']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'future',
      title: 'Present Continuous for Future Arrangements',
      generatorKey: 'present_continuous_future',
      aliases: ['future arrangements']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'modals',
      title: 'must / have to',
      generatorKey: 'must_have_to',
      aliases: ['obligation', 'necessity']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'modals',
      title: 'should / shouldn’t',
      generatorKey: 'should_advice',
      aliases: ['advice', 'recommendation']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'modals',
      title: 'may / might',
      generatorKey: 'may_might_possibility',
      aliases: ['possibility', 'maybe']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'comparison',
      title: 'Comparatives',
      generatorKey: 'comparatives',
      aliases: ['more than', 'er than']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'comparison',
      title: 'Superlatives',
      generatorKey: 'superlatives',
      aliases: ['the most', 'the est']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'determiners',
      title: 'Quantifiers',
      generatorKey: 'a2_quantifiers',
      aliases: ['a lot of', 'much', 'many', 'a few', 'a little']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'adjectives',
      title: 'too / enough',
      generatorKey: 'too_enough',
      aliases: ['too adjective', 'adjective enough']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'perfect',
      title: 'Present Perfect Intro',
      generatorKey: 'present_perfect_intro',
      aliases: ['have has v3', 'experience']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'perfect',
      title: 'Present Perfect vs Past Simple Intro',
      generatorKey: 'present_perfect_vs_past_simple_intro',
      aliases: ['finished time vs experience']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'conditionals',
      title: 'Zero Conditional',
      generatorKey: 'zero_conditional',
      aliases: ['facts conditional', 'if present present']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'conditionals',
      title: 'First Conditional',
      generatorKey: 'first_conditional',
      aliases: ['real future conditional', 'if present will']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'verbs',
      title: 'would like',
      generatorKey: 'would_like',
      aliases: ['polite wants']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'verbs',
      title: 'used to',
      generatorKey: 'used_to',
      aliases: ['past habits']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'verbs',
      title: 'Gerund / Infinitive Intro',
      generatorKey: 'gerund_infinitive_intro',
      aliases: ['like doing', 'want to do']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'clauses',
      title: 'Relative Clauses Intro',
      generatorKey: 'relative_clauses_intro',
      aliases: ['who which that']),
  GrammarCurriculumItem(
      level: 'A2',
      stage: 'intensifiers',
      title: 'so / such',
      generatorKey: 'so_such',
      aliases: ['so adjective', 'such noun phrase']),

  // B1 — Intermediate control
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'perfect',
      title: 'Present Perfect',
      generatorKey: 'present_perfect',
      aliases: ['have has v3', 'experience result']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'perfect',
      title: 'Present Perfect Continuous',
      generatorKey: 'present_perfect_continuous',
      aliases: ['have been ving', 'duration until now']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'perfect',
      title: 'Present Perfect vs Past Simple',
      generatorKey: 'present_perfect_vs_past_simple',
      aliases: ['life experience vs finished time']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'past',
      title: 'Past Perfect',
      generatorKey: 'past_perfect',
      aliases: ['had v3', 'earlier past']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'past',
      title: 'Past Perfect Continuous',
      generatorKey: 'past_perfect_continuous',
      aliases: ['had been ving']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'future',
      title: 'Future Continuous',
      generatorKey: 'future_continuous',
      aliases: ['will be ving']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'future',
      title: 'Future Perfect Intro',
      generatorKey: 'future_perfect_intro',
      aliases: ['will have v3']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'modals',
      title: 'Modals of Advice / Obligation / Possibility',
      generatorKey: 'b1_modals',
      aliases: ['should must might have to could']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'passive',
      title: 'Passive Voice',
      generatorKey: 'passive_voice',
      aliases: ['be v3', 'passive by tense']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'reported',
      title: 'Reported Speech Intro',
      generatorKey: 'reported_speech_intro',
      aliases: ['said that', 'told me that']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'reported',
      title: 'Reported Questions',
      generatorKey: 'reported_questions',
      aliases: ['asked me if', 'asked me where']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'reported',
      title: 'Reported Commands',
      generatorKey: 'reported_commands',
      aliases: ['told me to', 'asked me to']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'clauses',
      title: 'Defining Relative Clauses',
      generatorKey: 'defining_relative_clauses',
      aliases: ['who which that defining']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'clauses',
      title: 'Non-defining Relative Clauses Intro',
      generatorKey: 'non_defining_relative_intro',
      aliases: ['commas relative clause']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'conditionals',
      title: 'Second Conditional',
      generatorKey: 'second_conditional',
      aliases: ['unreal present', 'if past would']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'verbs',
      title: 'Gerund vs Infinitive',
      generatorKey: 'gerund_vs_infinitive',
      aliases: ['stop doing', 'want to do', 'enjoy doing']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'verbs',
      title: 'used to / be used to / get used to',
      generatorKey: 'used_to_be_get_used_to',
      aliases: ['past habits accustomed']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'pronouns',
      title: 'Reflexive Pronouns',
      generatorKey: 'reflexive_pronouns',
      aliases: ['myself yourself himself']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'pronouns',
      title: 'Reciprocal Pronouns',
      generatorKey: 'reciprocal_pronouns',
      aliases: ['each other', 'one another']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'responses',
      title: 'so / neither / either',
      generatorKey: 'so_neither_either',
      aliases: ['short agreement']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'questions',
      title: 'Question Tags',
      generatorKey: 'question_tags',
      aliases: ['isn’t it', 'don’t you']),
  GrammarCurriculumItem(
      level: 'B1',
      stage: 'questions',
      title: 'Indirect Questions',
      generatorKey: 'indirect_questions',
      aliases: ['could you tell me', 'do you know where']),

  // B2 — Upper-intermediate precision
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'perfect',
      title: 'Future Perfect',
      generatorKey: 'future_perfect',
      aliases: ['will have v3 by']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'perfect',
      title: 'Future Perfect Continuous',
      generatorKey: 'future_perfect_continuous',
      aliases: ['will have been ving']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'conditionals',
      title: 'Third Conditional',
      generatorKey: 'third_conditional',
      aliases: ['if had v3 would have v3']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'conditionals',
      title: 'Mixed Conditionals',
      generatorKey: 'mixed_conditionals',
      aliases: ['past condition present result']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'modals',
      title: 'Modal Deduction',
      generatorKey: 'modal_deduction',
      aliases: ['must be might be can’t be']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'modals',
      title: 'Modal Perfects',
      generatorKey: 'modal_perfects',
      aliases: ['should have', 'must have', 'might have']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'passive',
      title: 'Advanced Passive',
      generatorKey: 'advanced_passive',
      aliases: ['passive by tense', 'complex passive']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'passive',
      title: 'Passive Reporting Structures',
      generatorKey: 'passive_reporting',
      aliases: ['it is said that', 'he is believed to']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'causative',
      title: 'Causative have / get',
      generatorKey: 'causative_have_get',
      aliases: ['have something done', 'get something done']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'reported',
      title: 'Reported Speech Advanced',
      generatorKey: 'reported_speech_advanced',
      aliases: ['reporting verbs', 'backshift advanced']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'clauses',
      title: 'Non-defining Relative Clauses',
      generatorKey: 'non_defining_relative_clauses',
      aliases: ['comma relative clauses']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'clauses',
      title: 'Complex Relative Clauses',
      generatorKey: 'complex_relative_clauses',
      aliases: ['whose where which clause']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'clauses',
      title: 'Participle Clauses',
      generatorKey: 'participle_clauses',
      aliases: ['ing clauses', 'reduced adverbial clauses']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'verbs',
      title: 'Advanced Gerund / Infinitive',
      generatorKey: 'advanced_gerund_infinitive',
      aliases: ['regret doing', 'remember to do']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'wishes',
      title: 'Wish / If only',
      generatorKey: 'wish_if_only',
      aliases: ['wish past', 'wish would', 'if only']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'inversion',
      title: 'Inversion Intro',
      generatorKey: 'inversion_intro',
      aliases: ['not only did', 'rarely do']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'emphasis',
      title: 'Emphasis Structures',
      generatorKey: 'emphasis_structures',
      aliases: ['cleft intro', 'emphatic do']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'linking',
      title: 'Advanced Linking Devices',
      generatorKey: 'advanced_linking_devices',
      aliases: ['however nevertheless whereas despite']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'clauses',
      title: 'Concession Clauses',
      generatorKey: 'concession_clauses',
      aliases: ['although even though despite in spite of']),
  GrammarCurriculumItem(
      level: 'B2',
      stage: 'clauses',
      title: 'Purpose / Result / Reason Clauses',
      generatorKey: 'purpose_result_reason_clauses',
      aliases: ['so that in order to therefore because of']),

  // C1 — Advanced grammar control
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'inversion',
      title: 'Full Inversion',
      generatorKey: 'full_inversion',
      aliases: ['negative adverbial inversion', 'only then did']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'cleft',
      title: 'Cleft Sentences',
      generatorKey: 'cleft_sentences',
      aliases: ['it was who', 'what I need is']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'emphasis',
      title: 'Emphatic Do',
      generatorKey: 'emphatic_do',
      aliases: ['I do understand', 'he did help']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'modality',
      title: 'Advanced Modality',
      generatorKey: 'advanced_modality',
      aliases: ['should have', 'needn’t have', 'ought to have']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'linking',
      title: 'Advanced Linkers',
      generatorKey: 'advanced_linkers',
      aliases: ['whereas notwithstanding nevertheless']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'clauses',
      title: 'Noun Clauses',
      generatorKey: 'noun_clauses',
      aliases: ['whether', 'that clause', 'what clause']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'clauses',
      title: 'Reduced Relative Clauses',
      generatorKey: 'reduced_relative_clauses',
      aliases: ['the man standing', 'the book written']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'nominalisation',
      title: 'Nominalisation Intro',
      generatorKey: 'nominalisation_intro',
      aliases: ['verbs to nouns', 'academic noun phrases']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'passive',
      title: 'Advanced Passive',
      generatorKey: 'c1_advanced_passive',
      aliases: ['passive style', 'impersonal passive']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'hedging',
      title: 'Hedging',
      generatorKey: 'hedging',
      aliases: ['appears to', 'tends to', 'may suggest']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'conditionals',
      title: 'Advanced Conditionals',
      generatorKey: 'advanced_conditionals',
      aliases: ['should you need', 'were it not for']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'clauses',
      title: 'Reduced Clauses',
      generatorKey: 'reduced_clauses',
      aliases: ['while walking', 'having finished']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'style',
      title: 'Register Control',
      generatorKey: 'register_control',
      aliases: ['formal informal academic tone']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'subjunctive',
      title: 'Subjunctive / Formulaic Structures',
      generatorKey: 'subjunctive_formulaic',
      aliases: ['it is essential that he be', 'so be it']),
  GrammarCurriculumItem(
      level: 'C1',
      stage: 'ellipsis',
      title: 'Ellipsis / Substitution Intro',
      generatorKey: 'ellipsis_substitution_intro',
      aliases: ['so do I', 'if necessary', 'one ones']),

  // C2 — Mastery and style
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'academic',
      title: 'Academic Nominalisation',
      generatorKey: 'academic_nominalisation',
      aliases: ['dense nouns', 'nominal groups']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'information',
      title: 'Fronting / Information Structure',
      generatorKey: 'fronting_information_structure',
      aliases: ['fronting', 'what matters most', 'information flow']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'ellipsis',
      title: 'Ellipsis & Substitution',
      generatorKey: 'ellipsis_substitution',
      aliases: ['do so', 'if so', 'where necessary']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'hedging',
      title: 'Advanced Hedging',
      generatorKey: 'advanced_hedging',
      aliases: ['would appear to', 'arguably', 'to some extent']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'style',
      title: 'Register Shifts',
      generatorKey: 'register_shifts',
      aliases: ['formal to neutral', 'tone control']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'phrases',
      title: 'Dense Noun Phrases',
      generatorKey: 'dense_noun_phrases',
      aliases: ['complex noun phrases', 'pre-modification']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'subordination',
      title: 'Complex Subordination',
      generatorKey: 'complex_subordination',
      aliases: ['whereas although in that whether']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'concession',
      title: 'Advanced Concession',
      generatorKey: 'advanced_concession',
      aliases: ['be that as it may', 'however much']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'emphasis',
      title: 'Advanced Emphasis',
      generatorKey: 'advanced_emphasis',
      aliases: ['not merely but', 'what is striking is']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'inversion',
      title: 'Stylistic Inversion',
      generatorKey: 'stylistic_inversion',
      aliases: ['on no account', 'little did', 'under no circumstances']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'modality',
      title: 'Precision with Modality',
      generatorKey: 'precision_modality',
      aliases: ['may well', 'is likely to', 'cannot have failed to']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'discourse',
      title: 'Discourse Flow',
      generatorKey: 'discourse_flow',
      aliases: ['that said', 'for that matter', 'in turn']),
  GrammarCurriculumItem(
      level: 'C2',
      stage: 'conditionals',
      title: 'Advanced Conditional Alternatives',
      generatorKey: 'advanced_conditional_alternatives',
      aliases: ['but for', 'otherwise', 'provided that']),
];

List<GrammarCurriculumItem> grammarCurriculumForLevel(String level) {
  final normalized = level.trim().toUpperCase();
  return grammarFullCurriculumMap
      .where((item) => item.level.toUpperCase() == normalized)
      .toList(growable: false);
}

List<String> grammarCurriculumTitlesForLevel(String level) {
  return grammarCurriculumForLevel(level)
      .map((item) => item.title)
      .toList(growable: false);
}

List<String> grammarCurriculumGeneratorKeysForLevel(String level) {
  return grammarCurriculumForLevel(level)
      .map((item) => item.generatorKey)
      .toList(growable: false);
}

Map<String, int> grammarCurriculumCountByLevel() {
  final result = <String, int>{};
  for (final item in grammarFullCurriculumMap) {
    result[item.level] = (result[item.level] ?? 0) + 1;
  }
  return result;
}

String debugGrammarCurriculumSummary() {
  final counts = grammarCurriculumCountByLevel();
  return ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
      .map((level) => '$level: ${counts[level] ?? 0}')
      .join(' | ');
}
