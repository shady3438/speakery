import 'package:flutter/material.dart';

import 'package:speakery/data/grammar/grammar_models.dart';

const List<GrammarTopic> grammarA1Topics = [
  GrammarTopic(
    id: 'a1_be_verb',
    level: 'A1',
    title: 'Be: am / is / are',
    subtitle: 'kimlik, duygu, yer, yaş',
    icon: Icons.auto_awesome_rounded,
    rule: 'I am, he/she/it is, you/we/they are.',
    example: 'I am ready. She is at home. They are students.',
    trap: 'I is, she are, they is yanlıştır.',
  ),
  GrammarTopic(
    id: 'a1_subject_pronouns',
    level: 'A1',
    title: 'Subject & Object Pronouns',
    subtitle: 'I/me, he/him, she/her, we/us, they/them',
    icon: Icons.person_rounded,
    rule:
        'Subject pronoun işi yapan kişiyi; object pronoun fiilden sonra gelen kişiyi gösterir.',
    example: 'She helps me. I like them.',
    trap: 'Help I değil; help me. Mary she is happy gibi tekrar da yapma.',
  ),
  GrammarTopic(
    id: 'a1_possessive_adjectives',
    level: 'A1',
    title: 'Possessives',
    subtitle: 'my, your, his, her, Ali’s, whose',
    icon: Icons.badge_rounded,
    rule:
        'my/your/his/her isimden önce gelir; Ali’s bir ismin sahibini gösterir.',
    example: 'My bag is here. This is Ali’s phone. Whose pen is this?',
    trap: 'He bag / she phone değil; his bag / her phone.',
  ),
  GrammarTopic(
    id: 'a1_there_is_are',
    level: 'A1',
    title: 'There is / There are',
    subtitle: 'var / yok demek',
    icon: Icons.location_on_rounded,
    rule: 'There is tekil, there are çoğul isimlerle kullanılır.',
    example: 'There is a table. There are two chairs.',
    trap: 'There is two chairs yanlıştır.',
  ),
  GrammarTopic(
    id: 'a1_articles',
    level: 'A1',
    title: 'Articles: a / an / the',
    subtitle: 'genel ve belirli isimler',
    icon: Icons.article_rounded,
    rule: 'a/an genel bir tane; the belirli veya bilinen şeydir.',
    example: 'I saw a dog. The dog was black.',
    trap: 'Tekil sayılabilen isim genelde articlesiz kalmaz.',
  ),
  GrammarTopic(
    id: 'a1_singular_plural',
    level: 'A1',
    title: 'Plural & Quantity Basics',
    subtitle: 'books, some/any, much/many',
    icon: Icons.format_list_numbered_rounded,
    rule:
        'Sayılabilen isimler çoğul olur; some/any, much/many ve a lot of miktar anlatır.',
    example: 'two books, some milk, many apples, a lot of water.',
    trap: 'Two book değil; two books. Much books değil; many books.',
  ),
  GrammarTopic(
    id: 'a1_present_simple',
    level: 'A1',
    title: 'Present Simple',
    subtitle: 'rutinler, sıklık, wh-soruları, sevme/sevmeme',
    icon: Icons.repeat_rounded,
    rule:
        'Rutinlerde V1 kullan; he/she/it -s/-es alır. Sıklık zarfları fiilden önce gelir.',
    example: 'I usually work. She likes music. Where do you live?',
    trap: 'Does/doesn\'t geldiyse ana fiile -s ekleme.',
  ),
  GrammarTopic(
    id: 'a1_present_continuous',
    level: 'A1',
    title: 'Present Continuous',
    subtitle: 'Şu an olan eylemler',
    icon: Icons.timelapse_rounded,
    rule: 'am/is/are + verb-ing ile Şu an olan eylemi anlat.',
    example: 'I am studying now. She is reading.',
    trap: 'She reading yanlıştır; She is reading.',
  ),
  GrammarTopic(
    id: 'a1_can_cant',
    level: 'A1',
    title: "Can / Can't",
    subtitle: 'yetenek, izin, rica',
    icon: Icons.bolt_rounded,
    rule: 'Can/can\'t sonrasında fiil yalın halde gelir.',
    example: 'I can swim. She can\'t drive.',
    trap: 'can swims veya can to swim yanlıştır.',
  ),
  GrammarTopic(
    id: 'a1_have_has_got',
    level: 'A1',
    title: 'Have got / Has got',
    subtitle: 'sahiplik ve aile',
    icon: Icons.inventory_2_rounded,
    rule: 'I/you/we/they have got; he/she/it has got.',
    example: 'I have got a bike. She has got a brother.',
    trap: 'She have got değil; she has got.',
  ),
  GrammarTopic(
    id: 'a1_basic_prepositions',
    level: 'A1',
    title: 'Basic Prepositions: in / on / at',
    subtitle: 'yer ve zamanın en temel halleri',
    icon: Icons.place_rounded,
    rule: 'in alan/ay/yıl, on yüzey/gün, at nokta/saat için kullanılır.',
    example: 'in the bag, on the table, at seven.',
    trap: 'on Monday doğru; in Monday yanlıştır.',
  ),
  GrammarTopic(
    id: 'a1_imperatives',
    level: 'A1',
    title: 'Imperatives',
    subtitle: 'komut, yönerge, rica',
    icon: Icons.campaign_rounded,
    rule: 'Imperative cümle genelde yalın fiille başlar.',
    example: 'Open the door. Please sit down. Don\'t run.',
    trap: 'You open the door bir emir gibi doğal değildir.',
  ),
  GrammarTopic(
    id: 'a1_demonstratives',
    level: 'A1',
    title: 'This / That / These / Those',
    subtitle: 'yakın, uzak, tekil, çoğul',
    icon: Icons.touch_app_rounded,
    rule:
        'This/these yakın; that/those uzak. This/that tekil; these/those çoğul.',
    example: 'This is my phone. Those are my shoes.',
    trap: 'These is veya this are yanlıştır.',
  ),
];

GrammarLesson? a1LessonForTopic(GrammarTopic topic) {
  final lesson = _a1Lessons[topic.id];
  if (lesson == null) return null;
  return _withA1QuizFloor(topic.id, _polishedA1Lesson(topic.id, lesson));
}

GrammarLesson _withA1QuizFloor(String topicId, GrammarLesson lesson) {
  final curated = _a1GoldQuiz[topicId] ??
      _a1QualityQuiz[topicId] ??
      _a1Step4Quiz[topicId] ??
      _a1CuratedQuiz[topicId];
  if (curated != null && curated.length >= 10) {
    return GrammarLesson(
      bigTitle: lesson.bigTitle,
      oneLineGoal: lesson.oneLineGoal,
      timeLabel: lesson.timeLabel,
      teacherIntro: lesson.teacherIntro,
      formulaRows: lesson.formulaRows,
      usageBullets: lesson.usageBullets,
      examples: lesson.examples,
      wrong: lesson.wrong,
      right: lesson.right,
      reason: lesson.reason,
      task: lesson.task,
      modelAnswer: lesson.modelAnswer,
      quiz: curated.take(10).toList(growable: false),
    );
  }

  final quiz = <GrammarQuizQuestion>[
    ...?curated,
    ...lesson.quiz.where((q) =>
        q.type == GrammarQuizType.fillBlank &&
        (q.sentence ?? q.prompt).contains('_____') &&
        q.options.length == 4),
    ...?_a1ExtraQuiz[topicId],
  ].take(10).toList(growable: false);

  if (quiz.length >= 10) {
    return GrammarLesson(
      bigTitle: lesson.bigTitle,
      oneLineGoal: lesson.oneLineGoal,
      timeLabel: lesson.timeLabel,
      teacherIntro: lesson.teacherIntro,
      formulaRows: lesson.formulaRows,
      usageBullets: lesson.usageBullets,
      examples: lesson.examples,
      wrong: lesson.wrong,
      right: lesson.right,
      reason: lesson.reason,
      task: lesson.task,
      modelAnswer: lesson.modelAnswer,
      quiz: quiz,
    );
  }

  return lesson;
}

GrammarQuizQuestion _q(String id, String sentence, List<String> options,
        String answer, String explanation) =>
    GrammarQuizQuestion(
      id: id,
      type: GrammarQuizType.fillBlank,
      prompt: 'Boşluğu doldur.',
      sentence: sentence,
      options: options,
      answer: answer,
      explanation: _cleanA1Turkish(explanation),
    );

String _cleanA1Turkish(String value) {
  return value
      .replaceAll('Ã‡', 'Ç')
      .replaceAll('Ã§', 'ç')
      .replaceAll('ÄŸ', 'ğ')
      .replaceAll('Ä', 'Ğ')
      .replaceAll('Ä±', 'ı')
      .replaceAll('Ä°', 'İ')
      .replaceAll('Ã¶', 'ö')
      .replaceAll('Ã–', 'Ö')
      .replaceAll('ÅŸ', 'ş')
      .replaceAll('Å', 'Ş')
      .replaceAll('Ã¼', 'ü')
      .replaceAll('Ãœ', 'Ü')
      .replaceAll('â€™', "'")
      .replaceAll('â†’', '->')
      .replaceAll('â€”', '-');
}

List<GrammarQuizQuestion> _qs(String prefix, List<List<Object>> rows) {
  return List.generate(rows.length, (index) {
    final row = rows[index];
    return _q(
      '${prefix}_c${index + 1}',
      row[0] as String,
      (row[1] as List).cast<String>(),
      row[2] as String,
      row[3] as String,
    );
  });
}

final Map<String, List<GrammarQuizQuestion>> _a1GoldQuiz = {
  'a1_be_verb': _qs('a1_be_gold', [
    [
      'I _____ ready.',
      ['is', 'am', 'are', 'be'],
      'am',
      'I öznesi ile be fiili am olur: I am ready.'
    ],
    [
      'She _____ at school.',
      ['am', 'are', 'is', 'be'],
      'is',
      'She tekildir. He/she/it ile is kullanılır.'
    ],
    [
      'They _____ my friends.',
      ['are', 'is', 'am', 'be'],
      'are',
      'They çoğul öznedir. You/we/they ile are kullanılır.'
    ],
    [
      'We _____ not late.',
      ['is', 'am', 'be', 'are'],
      'are',
      'We ile are kullanılır. Olumsuzda not, are kelimesinden sonra gelir.'
    ],
    [
      '_____ you tired?',
      ['Is', 'Are', 'Am', 'Do'],
      'Are',
      'Be fiiliyle soru yaparken am/is/are başa gelir: Are you tired?'
    ],
    [
      'He _____ twelve years old.',
      ['are', 'is', 'am', 'do'],
      'is',
      'He tekil öznedir. Yaş söylerken he is kullanılır.'
    ],
    [
      'My bag _____ blue.',
      ['am', 'are', 'is', 'be'],
      'is',
      'My bag tekil bir isimdir. Tekil isimle is kullanılır.'
    ],
    [
      'You _____ very kind.',
      ['is', 'am', 'are', 'be'],
      'are',
      'You ile be fiili are olur: You are kind.'
    ],
    [
      'It _____ a small room.',
      ['are', 'is', 'am', 'do'],
      'is',
      'It tekil bir şey için kullanılır. Bu yüzden is doğru formdur.'
    ],
    [
      '_____ I in the right class?',
      ['Is', 'Are', 'Am', 'Do'],
      'Am',
      'I ile soru yaparken am başa gelir: Am I...?'
    ],
  ]),
  'a1_subject_pronouns': _qs('a1_pronouns_gold', [
    [
      '_____ am a student.',
      ['He', 'I', 'Me', 'Her'],
      'I',
      'Cümlede işi yapan kişi özne olur. I özne zamiridir.'
    ],
    [
      'Can you help _____?',
      ['I', 'he', 'me', 'she'],
      'me',
      'Help fiilinden sonra nesne gerekir. I değil, me kullanılır.'
    ],
    [
      'Mia is my friend. _____ is kind.',
      ['Her', 'She', 'Him', 'Me'],
      'She',
      'Mia özne yerinde she ile anlatılır.'
    ],
    [
      'I like Ali. I like _____.',
      ['he', 'him', 'his', 'she'],
      'him',
      'Like fiilinden sonra nesne zamiri gerekir. He değil, him kullanılır.'
    ],
    [
      'These are my books. _____ are new.',
      ['It', 'They', 'Them', 'He'],
      'They',
      'Books çoğuldur ve özne yerinde they kullanılır.'
    ],
    [
      'Please call _____.',
      ['we', 'us', 'our', 'they'],
      'us',
      'Call fiilinden sonra nesne zamiri gelir. We değil, us kullanılır.'
    ],
    [
      'My sister is here. I can see _____.',
      ['she', 'her', 'hers', 'he'],
      'her',
      'See fiilinden sonra nesne zamiri gerekir. She değil, her kullanılır.'
    ],
    [
      'Tom and I are ready. _____ are ready.',
      ['Us', 'We', 'Them', 'Me'],
      'We',
      'Tom and I özne görevindedir. Bu yüzden we kullanılır.'
    ],
    [
      'This is my phone. _____ is black.',
      ['They', 'He', 'It', 'Them'],
      'It',
      'Tekil bir şeyden söz ederken özne olarak it kullanılır.'
    ],
    [
      'I know Ece and Ali. I know _____.',
      ['they', 'them', 'we', 'us'],
      'them',
      'Know fiilinden sonra nesne zamiri gelir. They değil, them kullanılır.'
    ],
  ]),
  'a1_possessive_adjectives': _qs('a1_possessives_gold', [
    [
      'This is _____ bag.',
      ['I', 'my', 'me', 'mine'],
      'my',
      'İsimden önce sahiplik sıfatı gelir: my bag.'
    ],
    [
      'She is with _____ mother.',
      ['she', 'her', 'hers', 'him'],
      'her',
      'Mother isimdir. She değil, her mother denir.'
    ],
    [
      'He has got _____ phone.',
      ['he', 'him', 'his', 'her'],
      'his',
      'Erkek sahibi için isimden önce his kullanılır.'
    ],
    [
      'We are in _____ classroom.',
      ['we', 'us', 'our', 'their'],
      'our',
      'We öznesinin sahiplik sıfatı our olur: our classroom.'
    ],
    [
      'They love _____ school.',
      ['they', 'them', 'their', 'there'],
      'their',
      'They için sahiplik sıfatı their olur.'
    ],
    [
      '_____ name is Deniz.',
      ['I', 'My', 'Me', 'Mine'],
      'My',
      'Name isimdir. İsimden önce my kullanılır.'
    ],
    [
      'Is this _____ pencil?',
      ['you', 'your', 'yours', 'me'],
      'your',
      'Pencil isimdir. You değil, your pencil denir.'
    ],
    [
      '_____ bag is this?',
      ['Who', 'Whose', 'What', 'Where'],
      'Whose',
      'Bir şeyin sahibini sormak için whose kullanılır.'
    ],
    [
      'This is Ali_____ book.',
      ['s', "'s", 'is', 'his'],
      "'s",
      'Bir isme sahiplik eklemek için apostrof + s kullanılır: Ali\'s book.'
    ],
    [
      'The cat is in _____ box.',
      ['it', 'its', "it's", 'they'],
      'its',
      'Bir hayvan/şey için sahiplik sıfatı its olur.'
    ],
  ]),
  'a1_there_is_are': _qs('a1_there_gold', [
    [
      'There _____ a chair in my room.',
      ['are', 'is', 'am', 'be'],
      'is',
      'A chair tekildir. Tekil isimle there is kullanılır.'
    ],
    [
      'There _____ two chairs in my room.',
      ['is', 'are', 'am', 'be'],
      'are',
      'Two chairs çoğuldur. Çoğul isimle there are kullanılır.'
    ],
    [
      '_____ there a bank near here?',
      ['Are', 'Is', 'Do', 'Am'],
      'Is',
      'Tekil isimle soru Is there...? şeklindedir.'
    ],
    [
      '_____ there any shops near here?',
      ['Is', 'Are', 'Do', 'Does'],
      'Are',
      'Shops çoğuldur. Soru Are there...? olur.'
    ],
    [
      'There _____ not a TV in my room.',
      ['are', 'is', 'am', 'do'],
      'is',
      'A TV tekildir. Olumsuzda there is not kullanılır.'
    ],
    [
      'There _____ not any books here.',
      ['is', 'are', 'am', 'be'],
      'are',
      'Books çoğuldur. Olumsuzda there are not kullanılır.'
    ],
    [
      'There is _____ apple on the table.',
      ['two', 'an', 'any', 'many'],
      'an',
      'Apple tekil sayılabilen isimdir ve sesli sesle başlar; an apple kullanılır.'
    ],
    [
      'There are _____ students in class.',
      ['a', 'one', 'many', 'much'],
      'many',
      'Students çoğul sayılabilen isimdir. Many students doğru olur.'
    ],
    [
      'There _____ a park near my house.',
      ['are', 'is', 'do', 'be'],
      'is',
      'A park tekildir. Bir şeyin varlığını there is ile söyleriz.'
    ],
    [
      'There _____ three pencils in my bag.',
      ['is', 'are', 'am', 'has'],
      'are',
      'Three pencils çoğuldur. Bu yüzden there are kullanılır.'
    ],
  ]),
  'a1_articles': _qs('a1_articles_gold', [
    [
      'I have _____ pen.',
      ['an', 'a', 'the', 'no article'],
      'a',
      'Pen tekil sayılabilen isimdir ve sessiz sesle başlar; a pen kullanılır.'
    ],
    [
      'She has _____ apple.',
      ['a', 'an', 'the', 'no article'],
      'an',
      'Apple sesli sesle başlar. Bu yüzden an apple denir.'
    ],
    [
      'Open _____ door, please.',
      ['a', 'an', 'the', 'no article'],
      'the',
      'Hangi kapı olduğu bellidir. Belirli şeyler için the kullanılır.'
    ],
    [
      'I like _____ music.',
      ['a', 'an', 'the', 'no article'],
      'no article',
      'Music genel ve sayılamayan bir isimdir. Genel anlamda article gerekmez.'
    ],
    [
      'There is _____ cat in the garden.',
      ['an', 'a', 'the', 'no article'],
      'a',
      'Cat ilk kez söylenen tekil sayılabilen bir isimdir. A cat kullanılır.'
    ],
    [
      '_____ cat is black. (We know the cat.)',
      ['A', 'An', 'The', 'No article'],
      'The',
      'Kedi artık biliniyor. Bilinen şey için the kullanılır.'
    ],
    [
      'She is _____ teacher.',
      ['an', 'a', 'the', 'no article'],
      'a',
      'Teacher tekil bir meslek ismidir ve sessiz sesle başlar; a teacher denir.'
    ],
    [
      'He has _____ old bike.',
      ['a', 'an', 'the', 'no article'],
      'an',
      'Old sesli sesle başlar. Bu yüzden an old bike kullanılır.'
    ],
    [
      'I have two _____.',
      ['a book', 'book', 'books', 'the book'],
      'books',
      'Two birden fazla demektir. Çoğul isim books olur; a/an kullanılmaz.'
    ],
    [
      'We are at _____ now.',
      ['a school', 'an school', 'school', 'the schools'],
      'school',
      'At school günlük A1 ifadesidir. Burada genel yer/kurum anlamı vardır.'
    ],
  ]),
  'a1_singular_plural': _qs('a1_plural_gold', [
    [
      'I have two _____.',
      ['book', 'books', 'booking', 'bookes'],
      'books',
      'Two birden fazla demektir. Countable noun çoğul olur: books.'
    ],
    [
      'There are three _____ on the table.',
      ['box', 'boxs', 'boxes', 'boxies'],
      'boxes',
      'Box kelimesi çoğul olurken -es alır: boxes.'
    ],
    [
      'I need some _____.',
      ['waters', 'water', 'wateres', 'many water'],
      'water',
      'Water sayılamayan isimdir. Genelde -s almaz.'
    ],
    [
      'Do you have _____ eggs?',
      ['some', 'any', 'much', 'a'],
      'any',
      'Soru cümlelerinde any sık kullanılır: any eggs.'
    ],
    [
      'There is not _____ milk.',
      ['many', 'much', 'a', 'an'],
      'much',
      'Milk sayılamayan isimdir. Miktar için much kullanılır.'
    ],
    [
      'There are _____ apples.',
      ['much', 'many', 'a', 'an'],
      'many',
      'Apples çoğul sayılabilen isimdir. Many apples doğru olur.'
    ],
    [
      'One _____ is on the desk.',
      ['books', 'book', 'bookes', 'boxes'],
      'book',
      'One tekil demektir. Tekil isim book kullanılır.'
    ],
    [
      'Five _____ are in my bag.',
      ['pencil', 'pencils', 'penciles', 'penciling'],
      'pencils',
      'Five birden fazla demektir. Pencil çoğul olur: pencils.'
    ],
    [
      'We have _____ bread.',
      ['some', 'many', 'a', 'an'],
      'some',
      'Bread sayılamayan isimdir. Olumlu cümlede some bread doğal olur.'
    ],
    [
      'There are not _____ chairs.',
      ['some', 'much', 'any', 'a'],
      'any',
      'Olumsuz çoğul cümlede any kullanılır: not any chairs.'
    ],
  ]),
  'a1_present_simple': _qs('a1_present_simple_gold', [
    [
      'I _____ up at seven.',
      ['wakes', 'wake', 'waking', 'woke'],
      'wake',
      'I/you/we/they ile Present Simple olumlu cümlede fiil yalın kalır.'
    ],
    [
      'She _____ music.',
      ['like', 'likes', 'liking', 'liked'],
      'likes',
      'She ile olumlu Present Simple cümlede fiile -s gelir.'
    ],
    [
      'They _____ football after school.',
      ['plays', 'play', 'playing', 'played'],
      'play',
      'They ile fiil yalın kullanılır: they play.'
    ],
    [
      'He _____ not drink coffee.',
      ['do', 'does', 'is', 'are'],
      'does',
      'He ile olumsuz Present Simple does not + V1 olur.'
    ],
    [
      '_____ you live near here?',
      ['Does', 'Do', 'Are', 'Is'],
      'Do',
      'You ile soru Do you + V1 şeklindedir.'
    ],
    [
      '_____ she work in a bank?',
      ['Do', 'Does', 'Is', 'Are'],
      'Does',
      'She ile Present Simple soru does ile başlar.'
    ],
    [
      'My brother _____ English every day.',
      ['study', 'studies', 'studying', 'studied'],
      'studies',
      'Brother tekil olduğu için fiil -s/-es alır: studies.'
    ],
    [
      'We _____ usually eat lunch at school.',
      ['does not', 'is not', 'do not', 'are not'],
      'do not',
      'We ile olumsuz Present Simple do not + V1 olur.'
    ],
    [
      'She does not _____ tea.',
      ['likes', 'like', 'liking', 'liked'],
      'like',
      'Does not geldikten sonra ana fiil yalın kalır: like.'
    ],
    [
      'Where _____ your father work?',
      ['do', 'does', 'is', 'are'],
      'does',
      'Your father tekil olduğu için soru does ile kurulur.'
    ],
  ]),
  'a1_present_continuous': _qs('a1_present_continuous_gold', [
    [
      'I _____ studying now.',
      ['is', 'am', 'are', 'do'],
      'am',
      'Present Continuous am/is/are + V-ing ister. I ile am kullanılır.'
    ],
    [
      'She _____ reading a book.',
      ['am', 'are', 'is', 'does'],
      'is',
      'She ile is + V-ing kullanılır.'
    ],
    [
      'They _____ waiting for the bus.',
      ['is', 'am', 'are', 'do'],
      'are',
      'They ile are + V-ing kullanılır.'
    ],
    [
      'He is not _____.',
      ['listen', 'listens', 'listening', 'listened'],
      'listening',
      'Present Continuous yapısında ana fiil -ing alır.'
    ],
    [
      '_____ you coming with us?',
      ['Do', 'Are', 'Is', 'Am'],
      'Are',
      'You ile Present Continuous sorusu Are you + V-ing? olur.'
    ],
    [
      'My mother _____ cooking now.',
      ['are', 'is', 'am', 'does'],
      'is',
      'My mother tekil öznedir; is cooking kullanılır.'
    ],
    [
      'We _____ not sleeping.',
      ['is', 'am', 'are', 'do'],
      'are',
      'We ile are kullanılır. Olumsuzda not, are sonrasına gelir.'
    ],
    [
      'Look! The baby _____ smiling.',
      ['am', 'are', 'is', 'does'],
      'is',
      'The baby tekil olduğu için is smiling doğru olur.'
    ],
    [
      'What _____ you doing?',
      ['is', 'am', 'are', 'do'],
      'are',
      'You ile soru What are you doing? şeklindedir.'
    ],
    [
      'It _____ raining now.',
      ['are', 'is', 'am', 'does'],
      'is',
      'It tekil öznedir. Present Continuous için is raining kullanılır.'
    ],
  ]),
  'a1_can_cant': _qs('a1_can_gold', [
    [
      'I _____ swim.',
      ['am', 'can', 'do', 'have'],
      'can',
      'Yetenek anlatmak için can kullanılır: I can swim.'
    ],
    [
      'She can _____ English.',
      ['speaks', 'speak', 'speaking', 'to speak'],
      'speak',
      'Can sonrasında fiil yalın gelir. -s veya to kullanılmaz.'
    ],
    [
      'He _____ drive. He is twelve.',
      ['can', "can't", 'does', 'is'],
      "can't",
      'Olumsuz yetenek için can\'t kullanılır.'
    ],
    [
      '_____ you help me?',
      ['Do', 'Are', 'Can', 'Is'],
      'Can',
      'Rica cümlesi Can you + V1? şeklinde kurulabilir.'
    ],
    [
      'Can I _____ here?',
      ['sit', 'sits', 'sitting', 'to sit'],
      'sit',
      'Can I sonrasında fiil yalın olur: sit.'
    ],
    [
      'My brother _____ ride a bike.',
      ['cans', 'can', 'is', 'does'],
      'can',
      'Can bütün öznelerle aynı kalır. Cans denmez.'
    ],
    [
      'We cannot _____ today.',
      ['come', 'comes', 'coming', 'to come'],
      'come',
      'Cannot sonrasında fiil yalın kullanılır.'
    ],
    [
      'Can she sing? Yes, she _____.',
      ['is', 'does', 'can', 'sings'],
      'can',
      'Can ile soruya kısa cevapta can kullanılır.'
    ],
    [
      'Can they play tennis? No, they _____.',
      ['are not', "can't", "don't", "isn't"],
      "can't",
      'Can ile soruya olumsuz kısa cevap can\'t olur.'
    ],
    [
      'You _____ use my pen.',
      ['can', 'are', 'do', 'have'],
      'can',
      'İzin verirken can kullanılır: You can use my pen.'
    ],
  ]),
  'a1_have_has_got': _qs('a1_have_got_gold', [
    [
      'I _____ got a bike.',
      ['has', 'have', 'am', 'is'],
      'have',
      'I ile have got kullanılır.'
    ],
    [
      'She _____ got a brother.',
      ['have', 'has', 'is', 'are'],
      'has',
      'She ile has got kullanılır.'
    ],
    [
      'They _____ got two cats.',
      ['has', 'have', 'are', 'is'],
      'have',
      'They ile have got kullanılır.'
    ],
    [
      'He _____ not got a car.',
      ['have', 'has', 'is', 'does'],
      'has',
      'He ile olumsuz yapı has not got olur.'
    ],
    [
      '_____ you got a pen?',
      ['Has', 'Have', 'Do', 'Are'],
      'Have',
      'You ile soru Have you got...? şeklindedir.'
    ],
    [
      '_____ she got a sister?',
      ['Have', 'Has', 'Is', 'Does'],
      'Has',
      'She ile soru Has she got...? şeklinde kurulur.'
    ],
    [
      'We have got _____ small dog.',
      ['a', 'an', 'the', 'many'],
      'a',
      'Dog tekil sayılabilen isimdir; a small dog kullanılır.'
    ],
    [
      'My friend has got two _____.',
      ['bag', 'bags', 'bagging', 'bages'],
      'bags',
      'Two çoğul ister. Bag kelimesi çoğul olunca bags olur.'
    ],
    [
      'Have they got a garden? Yes, they _____.',
      ['has', 'have', 'are', 'do'],
      'have',
      'Have got sorusuna kısa cevap Yes, they have olur.'
    ],
    [
      'Has he got a phone? No, he _____.',
      ["haven't", "hasn't", "isn't", "doesn't"],
      "hasn't",
      'Has ile soruya olumsuz kısa cevap hasn\'t olur.'
    ],
  ]),
  'a1_basic_prepositions': _qs('a1_prepositions_gold', [
    [
      'The keys are _____ my bag.',
      ['on', 'at', 'in', 'to'],
      'in',
      'Bir şey çantanın içindeyse in kullanılır.'
    ],
    [
      'The book is _____ the table.',
      ['in', 'on', 'at', 'to'],
      'on',
      'Yüzey üzerinde olan şeyler için on kullanılır.'
    ],
    [
      'I am _____ school now.',
      ['in', 'on', 'at', 'to'],
      'at',
      'Okul gibi net bir yer/nokta için at school kullanılır.'
    ],
    [
      'We meet _____ Monday.',
      ['in', 'on', 'at', 'to'],
      'on',
      'Günlerle on kullanılır: on Monday.'
    ],
    [
      'The lesson starts _____ seven.',
      ['in', 'on', 'at', 'to'],
      'at',
      'Saatlerle at kullanılır: at seven.'
    ],
    [
      'My birthday is _____ June.',
      ['on', 'at', 'in', 'to'],
      'in',
      'Aylarla in kullanılır: in June.'
    ],
    [
      'The picture is _____ the wall.',
      ['in', 'on', 'at', 'to'],
      'on',
      'Duvarın yüzeyinde olan şey için on the wall kullanılır.'
    ],
    [
      'She lives _____ Ankara.',
      ['on', 'at', 'in', 'to'],
      'in',
      'Şehirlerle in kullanılır: in Ankara.'
    ],
    [
      'I am _____ home.',
      ['in', 'on', 'at', 'to'],
      'at',
      'Evde olmak için doğal ifade at home şeklindedir.'
    ],
    [
      'The cat is _____ the box.',
      ['on', 'in', 'at', 'to'],
      'in',
      'Kedi kutunun içindeyse in the box kullanılır.'
    ],
  ]),
  'a1_imperatives': _qs('a1_imperatives_gold', [
    [
      '_____ the door, please.',
      ['Opens', 'Open', 'Opening', 'To open'],
      'Open',
      'Imperative cümle fiilin yalın haliyle başlar.'
    ],
    [
      "_____ run in class.",
      ['No', "Don't", "Doesn't", "Isn't"],
      "Don't",
      'Olumsuz emir Don\'t + V1 şeklindedir.'
    ],
    [
      'Please _____ down.',
      ['sit', 'sits', 'sitting', 'to sit'],
      'sit',
      'Please sonrasında fiilin yalın hali kullanılır.'
    ],
    [
      '_____ carefully.',
      ['Listens', 'Listen', 'Listening', 'To listen'],
      'Listen',
      'Yönergelerde fiilin yalın hali kullanılır: Listen carefully.'
    ],
    [
      '_____ your name here.',
      ['Write', 'Writes', 'Writing', 'To write'],
      'Write',
      'Imperative cümlede özne yazılmaz; fiil yalın başlar.'
    ],
    [
      "Don't _____ your phone.",
      ['uses', 'use', 'using', 'to use'],
      'use',
      'Don\'t sonrasında fiil yalın kalır: Don\'t use.'
    ],
    [
      'Please _____ quiet.',
      ['be', 'is', 'are', 'being'],
      'be',
      'Imperative olarak be quiet denir.'
    ],
    [
      '_____ at the board.',
      ['Look', 'Looks', 'Looking', 'To look'],
      'Look',
      'Kısa yönergede yalın fiil kullanılır: Look.'
    ],
    [
      '_____ your book.',
      ['Opening', 'Open', 'Opens', 'To open'],
      'Open',
      'Emir cümlesi Open your book şeklinde başlar.'
    ],
    [
      "Don't _____ late.",
      ['be', 'is', 'are', 'being'],
      'be',
      'Olumsuz imperative Don\'t be late şeklindedir.'
    ],
  ]),
  'a1_demonstratives': _qs('a1_demonstratives_gold', [
    [
      '_____ is my phone. (near)',
      ['These', 'Those', 'This', 'They'],
      'This',
      'Yakındaki tekil şey için this kullanılır.'
    ],
    [
      '_____ is your bag. (far)',
      ['This', 'These', 'That', 'They'],
      'That',
      'Uzaktaki tekil şey için that kullanılır.'
    ],
    [
      '_____ are my keys. (near)',
      ['This', 'That', 'These', 'It'],
      'These',
      'Yakındaki çoğul şeyler için these kullanılır.'
    ],
    [
      '_____ are my shoes. (far)',
      ['This', 'That', 'Those', 'It'],
      'Those',
      'Uzaktaki çoğul şeyler için those kullanılır.'
    ],
    [
      'This _____ my pen.',
      ['are', 'is', 'am', 'be'],
      'is',
      'This tekildir. Tekil gösterme kelimesiyle is kullanılır.'
    ],
    [
      'These _____ my books.',
      ['is', 'are', 'am', 'be'],
      'are',
      'These çoğuldur. Çoğul gösterme kelimesiyle are kullanılır.'
    ],
    [
      'Is _____ your bag?',
      ['these', 'those', 'this', 'they'],
      'this',
      'Bag tekildir. Tekil soru Is this...? şeklindedir.'
    ],
    [
      'Are _____ your pencils?',
      ['this', 'that', 'these', 'it'],
      'these',
      'Pencils çoğuldur. Çoğul soru Are these...? şeklindedir.'
    ],
    [
      '_____ are old cars. (far)',
      ['This', 'That', 'Those', 'It'],
      'Those',
      'Cars çoğuldur ve uzakta oldukları belirtilmiş. Those doğru olur.'
    ],
    [
      '_____ is a big house. (far)',
      ['These', 'Those', 'That', 'They'],
      'That',
      'House tekildir ve uzakta. That is a big house doğru olur.'
    ],
  ]),
};

GrammarLesson _polishedA1Lesson(String topicId, GrammarLesson fallback) {
  switch (topicId) {
    case 'a1_be_verb':
      return GrammarLesson(
        bigTitle: 'Be: am / is / are',
        oneLineGoal:
            'Use am, is, and are to say who someone is, where they are, or how they feel.',
        timeLabel: '8 min',
        teacherIntro:
            'Be is a small but important verb. Say I am, he/she/it is, and you/we/they are. Do not drop be: say "I am tired", not "I tired".',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'I', pattern: 'I + am', sample: 'I am tired.'),
          GrammarFormulaRow(
              label: 'He / She / It',
              pattern: 'he/she/it + is',
              sample: 'She is at school.'),
          GrammarFormulaRow(
              label: 'You / We / They',
              pattern: 'you/we/they + are',
              sample: 'They are ready.'),
          GrammarFormulaRow(
              label: 'Questions',
              pattern: 'Am/Is/Are + subject?',
              sample: 'Are you okay?'),
        ],
        usageBullets: const [
          'Use be for names, jobs, feelings, ages, and places.',
          'Put not after be: She is not here.',
          'Move be to the front for questions: Are you ready?',
        ],
        examples: const [
          'I am a student.',
          'You are happy.',
          'He is my brother.',
          'We are at school.',
          'They are friends.',
          'Are you ready?',
        ],
        wrong: 'I are very tired.',
        right: 'I am very tired.',
        reason: 'A be sentence needs am, is, or are. With I, use am.',
        task:
            'Write five short be sentences about you, a friend, and your classroom.',
        modelAnswer:
            'I am a student. I am tired. My friend is kind. We are in class. Are you ready?',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_subject_pronouns':
      return GrammarLesson(
        bigTitle: 'Subject and Object Pronouns',
        oneLineGoal:
            'Use I/he/she/we/they before the verb and me/him/her/us/them after the verb.',
        timeLabel: '8 min',
        teacherIntro:
            'A subject pronoun does the action: She helps. An object pronoun receives the action: She helps me. Do not say the name and the pronoun together.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'Subject',
              pattern: 'I / you / he / she / it / we / they + verb',
              sample: 'She helps me.'),
          GrammarFormulaRow(
              label: 'Object',
              pattern: 'verb + me/you/him/her/it/us/them',
              sample: 'I like them.'),
          GrammarFormulaRow(
              label: 'No repeat',
              pattern: 'name OR pronoun',
              sample: 'Mia is very happy. / She is very happy.'),
        ],
        usageBullets: const [
          'Use he for a boy or man, she for a girl or woman.',
          'Use it for one thing and they for plural things or people.',
          'After a verb, use me, him, her, us, or them.',
        ],
        examples: const [
          'I am a teacher.',
          'You are my friend.',
          'He is ten years old.',
          'She is at home.',
          'They are students.',
        ],
        wrong: 'Mia she is happy.',
        right: 'Mia is very happy.',
        reason: 'Use the name or the pronoun as the subject, not both.',
        task: 'Write six sentences with subject and object pronouns.',
        modelAnswer:
            'She is my friend. I help her. He is in class. Can you call him? They are ready. I like them.',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_possessive_adjectives':
      return GrammarLesson(
        bigTitle: 'Possessive Adjectives',
        oneLineGoal: 'Use my, your, his, her, our, and their before a noun.',
        timeLabel: '7 min',
        teacherIntro:
            'Possessive adjectives show who owns something. They come before a noun: my bag, her phone, their house.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'My / your',
              pattern: 'my/your + noun',
              sample: 'My notebook is here.'),
          GrammarFormulaRow(
              label: 'His / her',
              pattern: 'his/her + noun',
              sample: 'Her phone is new.'),
          GrammarFormulaRow(
              label: 'Our / their',
              pattern: 'our/their + noun',
              sample: 'Their room is clean.'),
          GrammarFormulaRow(
              label: 'Whose',
              pattern: 'Whose + noun + is this?',
              sample: 'Whose pen is this?'),
        ],
        usageBullets: const [
          'Use his for a boy or man, her for a girl or woman.',
          'Do not use he or she before a noun.',
          'Use whose to ask about the owner.',
        ],
        examples: const [
          'This is my book.',
          'Your bag is blue.',
          'His name is Ali.',
          'Her phone is new.',
          'Our classroom is big.',
          'Their house is big.',
        ],
        wrong: 'She phone is new.',
        right: 'Her phone is new.',
        reason:
            'Phone is a noun, so it needs the possessive adjective her, not the subject pronoun she.',
        task:
            'Write six short sentences with my, your, his, her, our, and their.',
        modelAnswer:
            'My bag is blue. Your pen is here. His bike is old. Her phone is new. Our class is quiet. Their house is near school.',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_there_is_are':
      return GrammarLesson(
        bigTitle: 'There is / There are',
        oneLineGoal: 'Say what exists in a place.',
        timeLabel: '8 min',
        teacherIntro:
            'Use there is for one thing and there are for two or more things. This is the basic way to say that something exists.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'One thing',
              pattern: 'There is + singular noun',
              sample: 'There is a cafe near my school.'),
          GrammarFormulaRow(
              label: 'Two or more',
              pattern: 'There are + plural noun',
              sample: 'There are two cafes near my school.'),
          GrammarFormulaRow(
              label: 'Questions',
              pattern: 'Is there...? / Are there...?',
              sample: 'Are there any chairs?'),
          GrammarFormulaRow(
              label: 'Negative',
              pattern: "There isn't / There aren't",
              sample: "There isn't a TV."),
        ],
        usageBullets: const [
          'Use there is with one thing.',
          'Use there are with plural nouns.',
          'Use any often in questions and negatives.',
        ],
        examples: const [
          'There is a book on the table.',
          'There is a cat in the room.',
          'There are two chairs.',
          'There are five students.',
          'There is not a computer here.',
        ],
        wrong: 'There is two cafes.',
        right: 'There are two cafes.',
        reason: 'Two cafes is plural, so use there are.',
        task:
            'Write six sentences about things in your room or near your school.',
        modelAnswer:
            'There is a desk in my room. There are two books on the desk. There is a cafe near my school. There are three shops. There is not a TV. Are there any chairs?',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_articles':
      return GrammarLesson(
        bigTitle: 'Articles: a / an / the',
        oneLineGoal: 'Use a/an for one new thing and the for a specific thing.',
        timeLabel: '8 min',
        teacherIntro:
            'Use a before a consonant sound and an before a vowel sound. Use the when the listener knows which thing you mean.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'A', pattern: 'a + consonant sound', sample: 'a bag'),
          GrammarFormulaRow(
              label: 'An', pattern: 'an + vowel sound', sample: 'an apple'),
          GrammarFormulaRow(
              label: 'The',
              pattern: 'the + known/specific noun',
              sample: 'Open the door.'),
          GrammarFormulaRow(
              label: 'No a/an',
              pattern: 'plural or general uncountable noun',
              sample: 'I like music.'),
        ],
        usageBullets: const [
          'Use a/an with one countable thing.',
          'Use the when the thing is clear or already known.',
          'Do not use a/an with plural nouns.',
        ],
        examples: const [
          'This is a pen.',
          'It is an apple.',
          'The book is on the desk.',
          'I have a bag.',
          'She has an umbrella.',
        ],
        wrong: 'She has apple.',
        right: 'She has an apple.',
        reason:
            'Apple is one countable noun and starts with a vowel sound, so use an.',
        task: 'Write five short sentences with a, an, the, and no article.',
        modelAnswer:
            'I have a pen. She has an umbrella. The door is open. I like tea. There are books on the desk.',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_singular_plural':
      return GrammarLesson(
        bigTitle: 'Plural and Quantity Basics',
        oneLineGoal:
            'Use plural nouns and simple quantity words: some, any, much, and many.',
        timeLabel: '9 min',
        teacherIntro:
            'Countable nouns can be one book or two books. Uncountable nouns, like water or milk, usually do not take -s.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'Regular plural',
              pattern: 'number + noun-s',
              sample: 'two books'),
          GrammarFormulaRow(
              label: '-es plural',
              pattern: 'box -> boxes / bus -> buses',
              sample: 'three boxes'),
          GrammarFormulaRow(
              label: 'Some / any',
              pattern: 'some in positives / any in questions and negatives',
              sample: 'I have some water.'),
          GrammarFormulaRow(
              label: 'Many / much',
              pattern: 'many + plural / much + uncountable',
              sample: 'many apples / much water'),
        ],
        usageBullets: const [
          'Use -s or -es for most plural countable nouns.',
          'Use many with plural countable nouns.',
          'Use much with uncountable nouns.',
          'Use some in positive sentences and any in questions or negatives.',
        ],
        examples: const [
          'This is one apple.',
          'These are two apples.',
          'I have one book.',
          'We have three books.',
          'The child is happy.',
          'The children are happy.',
        ],
        wrong: 'I have two book.',
        right: 'I have two books.',
        reason: 'After two, the countable noun must be plural: books.',
        task: 'Write six short sentences with plural nouns and quantity words.',
        modelAnswer:
            'I have two books. There are three boxes. We need some water. Do you have any eggs? There is not much milk. I have many pencils.',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_present_simple':
      return GrammarLesson(
        bigTitle: 'Present Simple',
        oneLineGoal: 'Talk about routines, habits, and facts.',
        timeLabel: '9 min',
        teacherIntro:
            'Use Present Simple for things that happen often or are generally true. With he, she, and it, add -s or -es in positive sentences.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'I / You / We / They',
              pattern: 'subject + V1',
              sample: 'I wake up at seven.'),
          GrammarFormulaRow(
              label: 'He / She / It',
              pattern: 'subject + verb-s/es',
              sample: 'He usually wakes up at seven.'),
          GrammarFormulaRow(
              label: 'Negative',
              pattern: "do not / does not + V1",
              sample: "She doesn't like coffee."),
          GrammarFormulaRow(
              label: 'Question',
              pattern: 'Do/Does + subject + V1?',
              sample: 'Do you live near here?'),
        ],
        usageBullets: const [
          'Use it for daily routines and habits.',
          'Add -s or -es only in positive he/she/it sentences.',
          'After does or does not, keep the main verb in V1.',
        ],
        examples: const [
          'I like tea.',
          'You play football.',
          'He goes to school.',
          'She watches TV every evening.',
          'We study English.',
        ],
        wrong: 'She like music.',
        right: 'She likes music.',
        reason:
            'In a positive Present Simple sentence, she takes a verb with -s: likes.',
        task: 'Write six routine sentences about your day.',
        modelAnswer:
            'I wake up at seven. I go to school by bus. My brother plays football. My mother works in a hospital. We eat dinner at seven. Do you study every day?',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_present_continuous':
      return GrammarLesson(
        bigTitle: 'Present Continuous',
        oneLineGoal: 'Talk about actions happening now.',
        timeLabel: '8 min',
        teacherIntro:
            'Present Continuous needs two parts: am/is/are and a verb with -ing. Say "She is reading", not "She reading".',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'Positive',
              pattern: 'subject + am/is/are + V-ing',
              sample: 'I am studying now.'),
          GrammarFormulaRow(
              label: 'Negative',
              pattern: 'subject + am/is/are + not + V-ing',
              sample: "He isn't listening."),
          GrammarFormulaRow(
              label: 'Question',
              pattern: 'Am/Is/Are + subject + V-ing?',
              sample: 'Are you coming?'),
        ],
        usageBullets: const [
          'Use it for actions happening now.',
          'Always include am, is, or are.',
          'Use -ing on the action verb.',
        ],
        examples: const [
          'I am reading now.',
          'You are listening.',
          'He is playing football.',
          'She is cooking.',
          'They are studying.',
        ],
        wrong: 'She reading now.',
        right: 'She is reading now.',
        reason:
            'Present Continuous needs be + V-ing. With she, use is reading.',
        task: 'Write five sentences about what people are doing now.',
        modelAnswer:
            'I am studying now. My sister is watching TV. My parents are cooking. My friend is walking to school. I am not sleeping.',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_can_cant':
      return GrammarLesson(
        bigTitle: "Can / Can't",
        oneLineGoal: 'Talk about ability, permission, and requests.',
        timeLabel: '8 min',
        teacherIntro:
            'After can or cannot, use the base verb. Do not add to, -s, or -ing: can swim, can speak, can help.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'Ability',
              pattern: 'subject + can + V1',
              sample: 'I can swim.'),
          GrammarFormulaRow(
              label: 'Negative',
              pattern: "subject + can't + V1",
              sample: "She can't drive."),
          GrammarFormulaRow(
              label: 'Request',
              pattern: 'Can you + V1?',
              sample: 'Can you help me?'),
          GrammarFormulaRow(
              label: 'Permission',
              pattern: 'Can I + V1?',
              sample: 'Can I sit here?'),
        ],
        usageBullets: const [
          'Use can for ability: I can swim.',
          'Use Can you...? for requests.',
          'Use Can I...? for permission.',
          'Keep the next verb in base form.',
        ],
        examples: const [
          'I can swim.',
          'She can sing.',
          'He can ride a bike.',
          'We can speak English.',
          'I can\'t fly.',
        ],
        wrong: 'She can speaks English.',
        right: 'She can speak English.',
        reason: 'After can, use the base verb: speak. Do not add -s.',
        task: 'Write six sentences with can and cannot.',
        modelAnswer:
            "I can swim. I can't drive. My sister can sing. Can you help me? Can I sit here? No, you can't.",
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_have_has_got':
      return GrammarLesson(
        bigTitle: 'Have got / Has got',
        oneLineGoal: 'Talk about things, family, and pets you have.',
        timeLabel: '8 min',
        teacherIntro:
            'Use have got with I, you, we, and they. Use has got with he, she, and it. In questions, move have or has to the front.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'I / You / We / They',
              pattern: 'subject + have got + noun',
              sample: 'I have got a bike.'),
          GrammarFormulaRow(
              label: 'He / She / It',
              pattern: 'subject + has got + noun',
              sample: 'She has got a blue bag.'),
          GrammarFormulaRow(
              label: 'Negative',
              pattern: "haven't got / hasn't got",
              sample: "He hasn't got a car."),
          GrammarFormulaRow(
              label: 'Question',
              pattern: 'Have/Has + subject + got?',
              sample: 'Have you got a pen?'),
        ],
        usageBullets: const [
          'Use it for possessions, family, and pets.',
          'Use has got with he, she, and it.',
          'In short answers, do not repeat got: Yes, I have.',
        ],
        examples: const [
          'I have got a car.',
          'You have got a phone.',
          'He has got a brother.',
          'She has got a cat.',
          'They have got a house.',
        ],
        wrong: 'She have got a blue bag.',
        right: 'She has got a blue bag.',
        reason: 'With she, use has got.',
        task: 'Write five sentences about things or people you have got.',
        modelAnswer:
            "I have got a phone. I have got a sister. My friend has got a bike. We have got a small class. I haven't got a dog.",
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_basic_prepositions':
      return GrammarLesson(
        bigTitle: 'Prepositions: in / on / at',
        oneLineGoal: 'Use in, on, and at for simple places and times.',
        timeLabel: '8 min',
        teacherIntro:
            'Use in for inside a place, on for a surface, and at for a point or clock time. For time, say on Monday, in May, and at seven.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'In',
              pattern: 'in + place/month/year',
              sample: 'The keys are in my bag.'),
          GrammarFormulaRow(
              label: 'On',
              pattern: 'on + surface/day',
              sample: 'The book is on the table.'),
          GrammarFormulaRow(
              label: 'At',
              pattern: 'at + point/time',
              sample: 'The lesson starts at seven.'),
        ],
        usageBullets: const [
          'Use in when something is inside.',
          'Use on when something is on a surface or a day.',
          'Use at for a point place or exact time.',
        ],
        examples: const [
          'The book is on the table.',
          'The cat is under the chair.',
          'The bag is in the room.',
          'The school is next to the park.',
          'The pen is near the book.',
          'The keys are in the bag.',
        ],
        wrong: 'We meet in Monday.',
        right: 'We meet on Monday.',
        reason: 'Use on with days: on Monday.',
        task: 'Write six short sentences with in, on, and at.',
        modelAnswer:
            'My phone is in my bag. The book is on the desk. I am at school. We meet on Monday. The class starts at eight. My birthday is in June.',
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_imperatives':
      return GrammarLesson(
        bigTitle: 'Imperatives',
        oneLineGoal: 'Give simple instructions, warnings, and polite requests.',
        timeLabel: '7 min',
        teacherIntro:
            'Imperatives usually start with the base verb. Use please to sound polite. Use Do not or Don\'t before the verb for a negative instruction.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'Instruction',
              pattern: 'base verb + object',
              sample: 'Open the door.'),
          GrammarFormulaRow(
              label: 'Polite request',
              pattern: 'Please + base verb',
              sample: 'Please sit down.'),
          GrammarFormulaRow(
              label: 'Negative',
              pattern: "Don't + base verb",
              sample: "Don't run."),
        ],
        usageBullets: const [
          'Start with the base verb.',
          'Add please for a polite request.',
          'Use Don\'t + base verb for warnings.',
        ],
        examples: const [
          'Open the door.',
          'Close your book.',
          'Listen to me.',
          'Don\'t run.',
          'Please sit down.',
          'Write your name.',
        ],
        wrong: 'You open the door, please.',
        right: 'Open the door, please.',
        reason:
            'A normal imperative starts with the base verb. You is usually not needed.',
        task: 'Write five classroom instructions.',
        modelAnswer:
            "Open your book. Please listen. Write your name here. Don't run. Please sit down.",
        quiz: _a1GoldQuiz[topicId]!,
      );
    case 'a1_demonstratives':
      return GrammarLesson(
        bigTitle: 'This / That / These / Those',
        oneLineGoal: 'Point to near and far things, singular and plural.',
        timeLabel: '8 min',
        teacherIntro:
            'Use this and these for things near you. Use that and those for things farther away. This/that are singular; these/those are plural.',
        formulaRows: const [
          GrammarFormulaRow(
              label: 'Near singular',
              pattern: 'This is + singular noun',
              sample: 'This is my phone.'),
          GrammarFormulaRow(
              label: 'Far singular',
              pattern: 'That is + singular noun',
              sample: 'That is your bag.'),
          GrammarFormulaRow(
              label: 'Near plural',
              pattern: 'These are + plural noun',
              sample: 'These are my keys.'),
          GrammarFormulaRow(
              label: 'Far plural',
              pattern: 'Those are + plural noun',
              sample: 'Those are my shoes.'),
        ],
        usageBullets: const [
          'Use this for one thing near you.',
          'Use that for one thing far from you.',
          'Use these and those with plural nouns.',
        ],
        examples: const [
          'This is my book.',
          'That is your bag.',
          'These are my pens.',
          'Those are her shoes.',
          'This is a small room.',
        ],
        wrong: 'These is my keys.',
        right: 'These are my keys.',
        reason: 'These is plural, so use are.',
        task: 'Write six sentences about near and far objects around you.',
        modelAnswer:
            'This is my pen. That is your bag. These are my books. Those are her shoes. Is this your phone? Are those your keys?',
        quiz: _a1GoldQuiz[topicId]!,
      );
    default:
      return fallback;
  }
}

final Map<String, List<GrammarQuizQuestion>> _a1QualityQuiz = {
  'a1_be_verb': _qs('a1_be_quality', [
    [
      'I _____ tired.',
      ['am', 'is', 'are', 'be'],
      'am',
      'Use am with I.'
    ],
    [
      'She _____ at school.',
      ['is', 'are', 'am', 'be'],
      'is',
      'Use is with she.'
    ],
    [
      'They _____ ready.',
      ['are', 'is', 'am', 'be'],
      'are',
      'Use are with they.'
    ],
    [
      'He _____ not here.',
      ['is', 'are', 'am', 'do'],
      'is',
      'Put not after the correct be verb.'
    ],
    [
      '_____ you okay?',
      ['Are', 'Is', 'Am', 'Do'],
      'Are',
      'In a be question, move are before you.'
    ],
    [
      'My keys _____ on the table.',
      ['are', 'is', 'am', 'be'],
      'are',
      'Keys is plural, so use are.'
    ],
    [
      'This bag _____ blue.',
      ['is', 'are', 'am', 'do'],
      'is',
      'One bag takes is.'
    ],
    [
      'We _____ in class.',
      ['are', 'is', 'am', 'be'],
      'are',
      'Use are with we.'
    ],
    [
      '_____ I late?',
      ['Am', 'Is', 'Are', 'Do'],
      'Am',
      'The question form with I is Am I...?'
    ],
    [
      'No, she _____ not.',
      ['is', 'are', 'am', 'do'],
      'is',
      'A short negative answer uses she is not.'
    ],
  ]),
  'a1_subject_pronouns': _qs('a1_pron_quality', [
    [
      'Mia is my friend. _____ is kind.',
      ['She', 'He', 'It', 'They'],
      'She',
      'Use she for a girl or woman.'
    ],
    [
      'Ali is in class. _____ is ready.',
      ['He', 'She', 'It', 'They'],
      'He',
      'Use he for a boy or man.'
    ],
    [
      'My bag is new. _____ is blue.',
      ['It', 'They', 'He', 'We'],
      'It',
      'Use it for one thing.'
    ],
    [
      'My keys are here. _____ are on the desk.',
      ['They', 'It', 'He', 'She'],
      'They',
      'Use they for plural things.'
    ],
    [
      'Can you help _____?',
      ['me', 'I', 'he', 'she'],
      'me',
      'After help, use the object pronoun me.'
    ],
    [
      'I like _____.',
      ['them', 'they', 'he', 'we'],
      'them',
      'After like, use the object pronoun them.'
    ],
    [
      'Please call _____.',
      ['him', 'he', 'they', 'I'],
      'him',
      'After call, use him, not he.'
    ],
    [
      'My sister and I are ready. _____ are ready.',
      ['We', 'They', 'You', 'It'],
      'We',
      'Use we when the speaker is in the group.'
    ],
    [
      'Tom and Sara are students. _____ are students.',
      ['They', 'We', 'It', 'He'],
      'They',
      'Use they for two people.'
    ],
    [
      'This is Anna. I sit with _____.',
      ['her', 'she', 'he', 'they'],
      'her',
      'After with, use the object pronoun her.'
    ],
  ]),
  'a1_possessive_adjectives': _qs('a1_poss_quality', [
    [
      'I have a blue bag. _____ bag is blue.',
      ['My', 'I', 'Me', 'His'],
      'My',
      'Use my before a noun for something you have.'
    ],
    [
      'You have a pen. Is this _____ pen?',
      ['your', 'you', 'yours', 'he'],
      'your',
      'Use your before the noun pen.'
    ],
    [
      'Ali has a bike. _____ bike is old.',
      ['His', 'He', 'Her', 'Their'],
      'His',
      'Use his before a noun for a boy or man.'
    ],
    [
      'Mia has a phone. _____ phone is new.',
      ['Her', 'She', 'His', 'Our'],
      'Her',
      'Use her before a noun for a girl or woman.'
    ],
    [
      'We have a teacher. _____ teacher is kind.',
      ['Our', 'We', 'Their', 'My'],
      'Our',
      'Use our for something connected to the group we.'
    ],
    [
      'They have a house. _____ house is near school.',
      ['Their', 'They', 'Our', 'Its'],
      'Their',
      'Use their before a noun for they.'
    ],
    [
      'The dog has a bed. _____ bed is small.',
      ['Its', 'It', 'His', 'Their'],
      'Its',
      'Use its for one animal or thing.'
    ],
    [
      '_____ jacket is this?',
      ['Whose', 'Who', 'What', 'Where'],
      'Whose',
      'Use whose to ask about the owner.'
    ],
    [
      'This is Ece_____ notebook.',
      ["'s", 's', 'es', 'is'],
      "'s",
      'Add apostrophe s to a name for possession.'
    ],
    [
      'She is my friend. _____ name is Lara.',
      ['Her', 'She', 'His', 'Their'],
      'Her',
      'Use her before the noun name.'
    ],
  ]),
  'a1_there_is_are': _qs('a1_there_quality', [
    [
      'There _____ a cafe near my school.',
      ['is', 'are', 'am', 'be'],
      'is',
      'A cafe is singular, so use there is.'
    ],
    [
      'There _____ two cafes near my school.',
      ['are', 'is', 'am', 'be'],
      'are',
      'Two cafes is plural, so use there are.'
    ],
    [
      '_____ there a bank near here?',
      ['Is', 'Are', 'Do', 'Does'],
      'Is',
      'A bank is singular, so ask Is there...?'
    ],
    [
      '_____ there any chairs?',
      ['Are', 'Is', 'Do', 'Does'],
      'Are',
      'Chairs is plural, so ask Are there...?'
    ],
    [
      "There _____ a TV in my room.",
      ["isn't", "aren't", "don't", "am not"],
      "isn't",
      'A TV is singular, so use there is not.'
    ],
    [
      "There _____ any books here.",
      ["aren't", "isn't", "doesn't", "am not"],
      "aren't",
      'Books is plural, so use there are not.'
    ],
    [
      'There _____ some water on the table.',
      ['is', 'are', 'am', 'be'],
      'is',
      'Water is uncountable, so use there is.'
    ],
    [
      'There _____ three students outside.',
      ['are', 'is', 'am', 'be'],
      'are',
      'Three students is plural.'
    ],
    [
      'Is there _____ apple in your bag?',
      ['an', 'a', 'any', 'are'],
      'an',
      'Use an before apple.'
    ],
    [
      'Are there _____ questions?',
      ['any', 'a', 'an', 'is'],
      'any',
      'Use any naturally in plural questions.'
    ],
  ]),
  'a1_articles': _qs('a1_art_quality', [
    [
      'I have _____ blue bag.',
      ['a', 'an', 'the', '-'],
      'a',
      'Use a before the consonant sound in blue bag.'
    ],
    [
      'She has _____ old phone.',
      ['an', 'a', 'the', '-'],
      'an',
      'Use an before a vowel sound: old.'
    ],
    [
      'Open _____ door, please.',
      ['the', 'a', 'an', '-'],
      'the',
      'The door is specific in this request.'
    ],
    [
      'I like _____ music.',
      ['-', 'a', 'an', 'the a'],
      '-',
      'Music is general here, so no article is needed.'
    ],
    [
      'There is _____ apple on the desk.',
      ['an', 'a', 'the', '-'],
      'an',
      'Use an before apple.'
    ],
    [
      'This is _____ classroom.',
      ['a', 'an', 'the', '-'],
      'a',
      'Classroom starts with a consonant sound.'
    ],
    [
      '_____ sun is hot today.',
      ['The', 'A', 'An', '-'],
      'The',
      'We normally say the sun.'
    ],
    [
      'She is _____ student.',
      ['a', 'an', 'the', '-'],
      'a',
      'Student is one countable noun, so use a.'
    ],
    [
      'I need _____ umbrella.',
      ['an', 'a', 'the', '-'],
      'an',
      'Umbrella begins with a vowel sound.'
    ],
    [
      'There are _____ books on the table.',
      ['-', 'a', 'an', 'the a'],
      '-',
      'Do not use a or an before plural books.'
    ],
  ]),
  'a1_singular_plural': _qs('a1_plural_quality', [
    [
      'I have two _____.',
      ['books', 'book', 'a book', 'bookes'],
      'books',
      'After two, use the plural noun books.'
    ],
    [
      'There are three _____ in the room.',
      ['boxes', 'box', 'boxs', 'a box'],
      'boxes',
      'Box takes -es in the plural: boxes.'
    ],
    [
      'We need _____ water.',
      ['some', 'any', 'many', 'a'],
      'some',
      'Use some in positive sentences with water.'
    ],
    [
      'Do you have _____ eggs?',
      ['any', 'some', 'much', 'a'],
      'any',
      'Use any in questions with plural nouns.'
    ],
    [
      'There is not _____ milk.',
      ['much', 'many', 'a', 'some'],
      'much',
      'Milk is uncountable, so use much.'
    ],
    [
      'There are _____ apples.',
      ['many', 'much', 'a', 'an'],
      'many',
      'Apples are countable plural, so use many.'
    ],
    [
      'I see five _____.',
      ['buses', 'bus', 'buss', 'a bus'],
      'buses',
      'Bus takes -es in the plural: buses.'
    ],
    [
      'She has one _____.',
      ['cat', 'cats', 'some cat', 'many cat'],
      'cat',
      'After one, use a singular noun.'
    ],
    [
      "There aren't _____ chairs.",
      ['any', 'some', 'much', 'a'],
      'any',
      'Use any in negative plural sentences.'
    ],
    [
      'I have a lot of _____.',
      ['friends', 'friend', 'much friend', 'a friends'],
      'friends',
      'A lot of can go with plural countable nouns.'
    ],
  ]),
  'a1_present_simple': _qs('a1_ps_quality', [
    [
      'I _____ up at seven.',
      ['wake', 'wakes', 'waking', 'am wake'],
      'wake',
      'Use the base verb with I.'
    ],
    [
      'He usually _____ up at seven.',
      ['wakes', 'wake', 'waking', 'is wake'],
      'wakes',
      'Add -s with he in positive sentences.'
    ],
    [
      'She _____ music.',
      ['likes', 'like', 'liking', 'is like'],
      'likes',
      'Add -s with she in positive sentences.'
    ],
    [
      'We _____ lunch at school.',
      ['eat', 'eats', 'eating', 'are eat'],
      'eat',
      'Use the base verb with we.'
    ],
    [
      "She _____ coffee.",
      ["doesn't like", "don't likes", "isn't like", "doesn't likes"],
      "doesn't like",
      'After does not, use the base verb like.'
    ],
    [
      '_____ you live near here?',
      ['Do', 'Does', 'Are', 'Is'],
      'Do',
      'Use Do for questions with you.'
    ],
    [
      '_____ he play football?',
      ['Does', 'Do', 'Is', 'Are'],
      'Does',
      'Use Does for questions with he.'
    ],
    [
      'My brother _____ TV after school.',
      ['watches', 'watch', 'watching', 'is watch'],
      'watches',
      'Watch takes -es with he/she/it.'
    ],
    [
      'They _____ to school by bus.',
      ['go', 'goes', 'going', 'are go'],
      'go',
      'Use the base verb with they.'
    ],
    [
      'Where _____ she live?',
      ['does', 'do', 'is', 'are'],
      'does',
      'Use does in wh-questions with she.'
    ],
  ]),
  'a1_present_continuous': _qs('a1_pc_quality', [
    [
      'I _____ studying now.',
      ['am', 'is', 'are', 'do'],
      'am',
      'Present Continuous with I uses am + V-ing.'
    ],
    [
      'She _____ reading a book.',
      ['is', 'are', 'am', 'does'],
      'is',
      'Use is with she.'
    ],
    [
      'They _____ waiting for the bus.',
      ['are', 'is', 'am', 'do'],
      'are',
      'Use are with they.'
    ],
    [
      'He is _____ lunch.',
      ['eating', 'eat', 'eats', 'to eat'],
      'eating',
      'After is, use the -ing form.'
    ],
    [
      '_____ you listening?',
      ['Are', 'Is', 'Do', 'Does'],
      'Are',
      'Move are before you in a question.'
    ],
    [
      "We _____ not sleeping.",
      ['are', 'is', 'am', 'do'],
      'are',
      'Use are not with we.'
    ],
    [
      'My sister is _____ her homework.',
      ['doing', 'do', 'does', 'to do'],
      'doing',
      'Use is + V-ing for an action now.'
    ],
    [
      'The children _____ playing outside.',
      ['are', 'is', 'am', 'do'],
      'are',
      'Children is plural, so use are.'
    ],
    [
      'I am _____ for my friend.',
      ['waiting', 'wait', 'waits', 'to wait'],
      'waiting',
      'Use am + V-ing.'
    ],
    [
      '_____ he coming now?',
      ['Is', 'Are', 'Do', 'Does'],
      'Is',
      'Use Is he + V-ing?'
    ],
  ]),
  'a1_can_cant': _qs('a1_can_quality', [
    [
      'I can _____.',
      ['swim', 'swims', 'to swim', 'swimming'],
      'swim',
      'After can, use the base verb.'
    ],
    [
      'She can _____ English.',
      ['speak', 'speaks', 'to speak', 'speaking'],
      'speak',
      'Do not add -s after can.'
    ],
    [
      'He _____ play the guitar.',
      ['can', 'cans', 'is', 'does'],
      'can',
      'Can does not change with he.'
    ],
    [
      'Can you _____ me?',
      ['help', 'helps', 'to help', 'helping'],
      'help',
      'Use Can you + base verb for a request.'
    ],
    [
      '_____ I ask a question?',
      ['Can', 'Do', 'Am', 'Does'],
      'Can',
      'Use Can I...? for permission.'
    ],
    [
      "She _____ come today.",
      ["can't", "doesn't", "isn't", "don't"],
      "can't",
      'The negative of can is cannot or can\'t.'
    ],
    [
      'No, I _____.',
      ["can't", "don't", "am not", "haven't"],
      "can't",
      'A short answer to a can question uses can or can\'t.'
    ],
    [
      'Yes, we _____.',
      ['can', 'are', 'do', 'have'],
      'can',
      'A positive short answer repeats can.'
    ],
    [
      'Can they _____ football?',
      ['play', 'plays', 'playing', 'to play'],
      'play',
      'After can, use the base verb play.'
    ],
    [
      'My brother can _____ a bike.',
      ['ride', 'rides', 'to ride', 'riding'],
      'ride',
      'Use can + base verb: can ride.'
    ],
  ]),
  'a1_have_has_got': _qs('a1_have_quality', [
    [
      'I _____ got a phone.',
      ['have', 'has', 'am', 'do'],
      'have',
      'Use have got with I.'
    ],
    [
      'She _____ got a blue bag.',
      ['has', 'have', 'is', 'does'],
      'has',
      'Use has got with she.'
    ],
    [
      'We _____ got two cats.',
      ['have', 'has', 'are', 'do'],
      'have',
      'Use have got with we.'
    ],
    [
      'He _____ got a bike.',
      ["hasn't", "haven't", "isn't", "don't"],
      "hasn't",
      'The negative with he is has not got.'
    ],
    [
      '_____ you got a pen?',
      ['Have', 'Has', 'Do', 'Are'],
      'Have',
      'Questions with you start with Have.'
    ],
    [
      '_____ she got a sister?',
      ['Has', 'Have', 'Is', 'Does'],
      'Has',
      'Questions with she start with Has.'
    ],
    [
      'No, she _____.',
      ["hasn't", "haven't", "isn't", "doesn't"],
      "hasn't",
      'Short answers do not repeat got.'
    ],
    [
      'Yes, I _____.',
      ['have', 'has', 'am', 'do'],
      'have',
      'The short answer is Yes, I have.'
    ],
    [
      'They _____ got a small house.',
      ['have', 'has', 'are', 'do'],
      'have',
      'Use have got with they.'
    ],
    [
      'My dog _____ got a long tail.',
      ['has', 'have', 'is', 'does'],
      'has',
      'Use has got with it or one animal.'
    ],
  ]),
  'a1_basic_prepositions': _qs('a1_prep_quality', [
    [
      'The keys are _____ my bag.',
      ['in', 'on', 'at', 'to'],
      'in',
      'Use in when something is inside.'
    ],
    [
      'The book is _____ the table.',
      ['on', 'in', 'at', 'to'],
      'on',
      'Use on for a surface.'
    ],
    [
      'I am _____ school now.',
      ['at', 'in', 'on', 'to'],
      'at',
      'Use at for a point place like school.'
    ],
    [
      'The lesson starts _____ seven.',
      ['at', 'on', 'in', 'to'],
      'at',
      'Use at with clock times.'
    ],
    [
      'We meet _____ Monday.',
      ['on', 'in', 'at', 'to'],
      'on',
      'Use on with days.'
    ],
    [
      'My birthday is _____ May.',
      ['in', 'on', 'at', 'to'],
      'in',
      'Use in with months.'
    ],
    [
      'The poster is _____ the wall.',
      ['on', 'in', 'at', 'to'],
      'on',
      'A poster is on a surface.'
    ],
    [
      'She lives _____ Ankara.',
      ['in', 'on', 'at', 'to'],
      'in',
      'Use in with cities.'
    ],
    [
      'I am _____ home.',
      ['at', 'in', 'on', 'to'],
      'at',
      'At home is the natural phrase.'
    ],
    [
      'The apples are _____ the box.',
      ['in', 'on', 'at', 'to'],
      'in',
      'The apples are inside the box.'
    ],
  ]),
  'a1_imperatives': _qs('a1_imp_quality', [
    [
      '_____ the door, please.',
      ['Open', 'Opens', 'Opening', 'To open'],
      'Open',
      'Imperatives start with the base verb.'
    ],
    [
      'Please _____ down.',
      ['sit', 'sits', 'sitting', 'to sit'],
      'sit',
      'After please, use the base verb.'
    ],
    [
      "_____ run in class.",
      ["Don't", "Doesn't", "Isn't", "Aren't"],
      "Don't",
      'Use Don\'t + base verb for a negative instruction.'
    ],
    [
      '_____ carefully.',
      ['Listen', 'Listens', 'Listening', 'To listen'],
      'Listen',
      'Use the base verb to give an instruction.'
    ],
    [
      "Don't _____ late.",
      ['be', 'is', 'are', 'to be'],
      'be',
      'After don\'t, use the base form be.'
    ],
    [
      '_____ your name here.',
      ['Write', 'Writes', 'Writing', 'To write'],
      'Write',
      'Use the base verb write.'
    ],
    [
      'Please _____ your book.',
      ['open', 'opens', 'opening', 'to open'],
      'open',
      'Please is followed by the base verb.'
    ],
    [
      "Don't _____ your phone.",
      ['use', 'uses', 'using', 'to use'],
      'use',
      'Don\'t is followed by the base verb.'
    ],
    [
      '_____ after me.',
      ['Repeat', 'Repeats', 'Repeating', 'To repeat'],
      'Repeat',
      'Classroom instructions use the base verb.'
    ],
    [
      'Please _____ quiet.',
      ['be', 'is', 'are', 'to be'],
      'be',
      'Use be after please in this imperative.'
    ],
  ]),
  'a1_demonstratives': _qs('a1_dem_quality', [
    [
      '_____ is my phone here.',
      ['This', 'These', 'Those', 'They'],
      'This',
      'This is for one thing near you.'
    ],
    [
      '_____ are my keys here.',
      ['These', 'This', 'That', 'It'],
      'These',
      'These is for plural things near you.'
    ],
    [
      '_____ is your bag over there.',
      ['That', 'These', 'This', 'They'],
      'That',
      'That is for one thing farther away.'
    ],
    [
      '_____ are my shoes over there.',
      ['Those', 'That', 'This', 'It'],
      'Those',
      'Those is for plural things farther away.'
    ],
    [
      'Are _____ your books?',
      ['these', 'this', 'that', 'it'],
      'these',
      'Books is plural, so use these or those.'
    ],
    [
      'Is _____ your seat?',
      ['this', 'these', 'those', 'they'],
      'this',
      'Seat is singular, so use this or that.'
    ],
    [
      '_____ are her pens.',
      ['These', 'This', 'That', 'It'],
      'These',
      'Pens is plural, so use these.'
    ],
    [
      '_____ is an old house.',
      ['That', 'Those', 'These', 'They'],
      'That',
      'House is singular and far, so use that.'
    ],
    [
      'Are _____ your shoes over there?',
      ['those', 'that', 'this', 'it'],
      'those',
      'Shoes is plural and far, so use those.'
    ],
    [
      '_____ is my blue bag.',
      ['This', 'These', 'Those', 'They'],
      'This',
      'Bag is singular and near, so use this.'
    ],
  ]),
};

final Map<String, List<GrammarQuizQuestion>> _a1CuratedQuiz = {
  'a1_be_verb': [
    _q('a1_be_c1', 'I _____ twelve.', ['am', 'is', 'are', 'be'], 'am',
        'I öznesi be fiilinde her zaman "am" alır.'),
    _q('a1_be_c2', 'She _____ a nurse.', ['are', 'am', 'is', 'be'], 'is',
        'She üçüncü tekildir; kimlik ve meslek için "is" kullanılır.'),
    _q('a1_be_c3', 'They _____ at home.', ['is', 'are', 'am', 'be'], 'are',
        'They çoğuldur; be fiili "are" olur.'),
    _q('a1_be_c4', 'He _____ not tired.', ['are', 'am', 'do', 'is'], 'is',
        'Olumsuz be cümlesinde "not", doğru be fiilinden sonra gelir.'),
    _q('a1_be_c5', '_____ you ready?', ['Is', 'Are', 'Am', 'Do'], 'Are',
        'Be sorusunda am/is/are başa gelir. You ile "are" kullanılır.'),
    _q('a1_be_c6', 'No, she _____ not.', ['are', 'am', 'do', 'is'], 'is',
        'Is she...? sorusuna kısa cevapta "she is / she is not" denir.'),
    _q('a1_be_c7', 'My keys _____ on the table.', ['is', 'am', 'are', 'be'],
        'are', 'Keys çoğuldur; yer bildirirken "are" gerekir.'),
    _q('a1_be_c8', 'My father _____ a teacher.', ['is', 'are', 'am', 'do'],
        'is', 'My father tek kişidir; be fiili "is" olur.'),
    _q('a1_be_c9', 'We _____ happy today.', ['is', 'am', 'be', 'are'], 'are',
        'We öznesi be fiilinde "are" alır.'),
    _q('a1_be_c10', '_____ I late?', ['Is', 'Am', 'Are', 'Do'], 'Am',
        'I ile soru "Am I...?" şeklinde kurulur.'),
  ],
  'a1_present_simple': [
    _q(
        'a1_ps_c1',
        'I _____ breakfast at seven.',
        ['eat', 'eats', 'eating', 'am eat'],
        'eat',
        'I ile Present Simple olumlu cümlede fiil yalın kalır.'),
    _q(
        'a1_ps_c2',
        'She _____ to school every day.',
        ['go', 'going', 'is go', 'goes'],
        'goes',
        'She ile olumlu cümlede fiile -s/-es gelir.'),
    _q(
        'a1_ps_c3',
        'They _____ football on Sundays.',
        ['plays', 'playing', 'play', 'is play'],
        'play',
        'They ile fiil yalın kalır.'),
    _q(
        'a1_ps_c4',
        'I _____ drink coffee.',
        ["doesn't", "don't", "am not", "isn't"],
        "don't",
        'I ile olumsuz Present Simple "don\'t + V1" olur.'),
    _q(
        'a1_ps_c5',
        'He _____ like milk.',
        ["don't", "isn't", "aren't", "doesn't"],
        "doesn't",
        'He ile olumsuzda "doesn\'t + V1" kullanılır.'),
    _q('a1_ps_c6', '_____ you live near here?', ['Does', 'Do', 'Are', 'Is'],
        'Do', 'You ile Present Simple sorusunda "Do" kullanılır.'),
    _q('a1_ps_c7', '_____ she work on Mondays?', ['Does', 'Do', 'Is', 'Are'],
        'Does', 'She ile Present Simple sorusu "Does she + V1?" olur.'),
    _q(
        'a1_ps_c8',
        'He does not _____ tea.',
        ['drinks', 'drinking', 'drink', 'is drink'],
        'drink',
        'Does not geldiyse ana fiil yalın kalır.'),
    _q(
        'a1_ps_c9',
        'We usually _____ at night.',
        ['studies', 'study', 'studying', 'are study'],
        'study',
        'We ile fiil yalındır; usually rutin anlatır.'),
    _q(
        'a1_ps_c10',
        'The bus _____ at eight.',
        ['leave', 'leaving', 'is leave', 'leaves'],
        'leaves',
        'The bus tekildir; program/rutin cümlesinde -s gelir.'),
  ],
  'a1_present_continuous': [
    _q('a1_pc_c1', 'I _____ studying now.', ['is', 'are', 'do', 'am'], 'am',
        'I ile Present Continuous yardımcı fiili "am" olur.'),
    _q('a1_pc_c2', 'She _____ reading a book.', ['are', 'am', 'is', 'does'],
        'is', 'She ile "is + V-ing" kullanılır.'),
    _q('a1_pc_c3', 'They _____ watching TV.', ['are', 'is', 'am', 'do'], 'are',
        'They ile yardımcı fiil "are" olur.'),
    _q(
        'a1_pc_c4',
        'We are _____ for the bus.',
        ['wait', 'waiting', 'waits', 'to wait'],
        'waiting',
        'Present Continuous yapısında ana fiil -ing alır.'),
    _q(
        'a1_pc_c5',
        'He is not _____ now.',
        ['sleep', 'sleeps', 'sleeping', 'to sleep'],
        'sleeping',
        'Be + not sonrası fiil -ing formunda gelir.'),
    _q('a1_pc_c6', '_____ you listening?', ['Are', 'Is', 'Am', 'Do'], 'Are',
        'You ile soru "Are you + V-ing?" olur.'),
    _q('a1_pc_c7', '_____ she coming?', ['Are', 'Is', 'Do', 'Does'], 'Is',
        'She ile soru "Is she + V-ing?" şeklindedir.'),
    _q(
        'a1_pc_c8',
        'My dad _____ working on his laptop.',
        ['are', 'am', 'does', 'is'],
        'is',
        'My dad tek kişidir; "is" kullanılır.'),
    _q(
        'a1_pc_c9',
        'The children _____ playing outside.',
        ['are', 'is', 'am', 'do'],
        'are',
        'Children çoğuldur; yardımcı fiil "are" olur.'),
    _q(
        'a1_pc_c10',
        'I am _____ lunch right now.',
        ['eat', 'eats', 'eating', 'to eat'],
        'eating',
        'Right now Şu anı gösterir; am + V-ing gerekir.'),
  ],
  'a1_can_cant': [
    _q('a1_can_c1', 'I can _____.', ['swims', 'swim', 'to swim', 'swimming'],
        'swim', 'Can’den sonra fiil yalın halde gelir.'),
    _q(
        'a1_can_c2',
        'She can _____ English.',
        ['speaks', 'to speak', 'speak', 'speaking'],
        'speak',
        'Can he/she/it ile bile -s almaz.'),
    _q('a1_can_c3', 'He _____ play the guitar.', ['cans', 'is', 'does', 'can'],
        'can', 'Can özneye göre değişmez; "cans" olmaz.'),
    _q(
        'a1_can_c4',
        'Can you _____ me?',
        ['help', 'helps', 'to help', 'helping'],
        'help',
        'Can sorusunda da ana fiil yalın kalır.'),
    _q('a1_can_c5', '_____ I ask a question?', ['Do', 'Can', 'Am', 'Does'],
        'Can', 'İzin isterken "Can I...?" kullanılır.'),
    _q(
        'a1_can_c6',
        'She can not _____ today.',
        ['comes', 'to come', 'coming', 'come'],
        'come',
        'Can not sonrasında fiil V1 kalır.'),
    _q('a1_can_c7', 'No, I _____.', ["don't", "am not", "can't", "haven't"],
        "can't", 'Can sorusuna kısa olumsuz cevap "can\'t" ile verilir.'),
    _q('a1_can_c8', 'Yes, we _____.', ['can', 'are', 'do', 'have'], 'can',
        'Can sorusuna kısa olumlu cevapta "can" tekrar edilir.'),
    _q(
        'a1_can_c9',
        'Can they _____ this song?',
        ['sings', 'to sing', 'singing', 'sing'],
        'sing',
        'Can + özne + V1 soru düzenidir.'),
    _q(
        'a1_can_c10',
        'My brother can _____ a bike.',
        ['rides', 'ride', 'to ride', 'riding'],
        'ride',
        'Can’den sonra ana fiil yalın olur: can ride.'),
  ],
};

final Map<String, List<GrammarQuizQuestion>> _a1ExtraQuiz = {
  'a1_be_verb': [
    _q('a1_be_q6', 'We _____ ready.', ['are', 'is', 'am', 'be'], 'are',
        'We ile be fiili "are" olur.'),
    _q('a1_be_q7', 'My brother _____ ten.', ['are', 'am', 'is', 'be'], 'is',
        'Tek bir kişi için "is" kullanılır.'),
    _q('a1_be_q8', 'No, I _____ not.', ['is', 'am', 'are', 'do'], 'am',
        'Are you...? sorusuna kısa cevapta "I am / I am not" kullanılır.'),
    _q('a1_be_q9', 'The books _____ on the desk.', ['is', 'am', 'be', 'are'],
        'are', 'Books çoğuldur; bu yüzden "are" gerekir.'),
    _q('a1_be_q10', '_____ he your teacher?', ['Are', 'Is', 'Am', 'Do'], 'Is',
        'He ile soru "Is he...?" şeklinde başlar.'),
  ],
  'a1_subject_pronouns': [
    _q(
        'a1_pron_q6',
        'Mehmet is here. _____ is my friend.',
        ['She', 'He', 'It', 'They'],
        'He',
        'Mehmet erkek ismidir; "he" kullanılır.'),
    _q(
        'a1_pron_q7',
        'My mother is a doctor. _____ is kind.',
        ['He', 'It', 'We', 'She'],
        'She',
        'Mother için özne zamiri "she" olur.'),
    _q(
        'a1_pron_q8',
        'The car is red. _____ is new.',
        ['It', 'They', 'He', 'She'],
        'It',
        'Tek bir eşya için "it" kullanılır.'),
    _q(
        'a1_pron_q9',
        'You and I are students. _____ are students.',
        ['They', 'You', 'We', 'It'],
        'We',
        'Konuşan kişi grubun içindeyse "we" kullanılır.'),
    _q('a1_pron_q10', 'Ali and Ayşe are at school. _____ are at school.',
        ['We', 'It', 'They', 'He'], 'They', 'İki kişi için "they" kullanılır.'),
  ],
  'a1_possessive_adjectives': [
    _q('a1_poss_q6', 'I have a sister. _____ sister is young.',
        ['I', 'Her', 'My', 'Their'], 'My', 'I için sahiplik sıfatı "my" olur.'),
    _q(
        'a1_poss_q7',
        'You have a pen. _____ pen is blue.',
        ['Your', 'You', 'His', 'Our'],
        'Your',
        'You için sahiplik sıfatı "your" olur.'),
    _q(
        'a1_poss_q8',
        'The dog has a ball. _____ ball is small.',
        ['It', 'His', 'Their', 'Its'],
        'Its',
        'Hayvan/eşya sahipliğinde "its" kullanılır.'),
    _q(
        'a1_poss_q9',
        'We have a room. _____ room is clean.',
        ['We', 'Our', 'Their', 'My'],
        'Our',
        'We grubunun sahipliği "our" ile anlatılır.'),
    _q('a1_poss_q10', 'This is _____ bag, Ayşe.', ['your', 'you', 'her', 'she'],
        'your', 'Karşındaki kişiye ait bir isimden önce "your" gelir.'),
  ],
  'a1_there_is_are': [
    _q(
        'a1_there_q6',
        'There _____ three books here.',
        ['is', 'am', 'be', 'are'],
        'are',
        'Three books çoğuldur; "there are" kullanılır.'),
    _q(
        'a1_there_q7',
        'There _____ a phone on the table.',
        ['are', 'is', 'am', 'be'],
        'is',
        'A phone tekildir; "there is" kullanılır.'),
    _q(
        'a1_there_q8',
        'There _____ any chairs.',
        ["isn't", "am not", "aren't", "don't"],
        "aren't",
        'Chairs çoğuldur; olumsuzda "there aren\'t" kullanılır.'),
    _q(
        'a1_there_q9',
        '_____ there a cafe near here?',
        ['Is', 'Are', 'Do', 'Does'],
        'Is',
        'A cafe tekildir; soru "Is there...?" olur.'),
    _q('a1_there_q10', '_____ there any parks?', ['Is', 'Do', 'Does', 'Are'],
        'Are', 'Parks çoğuldur; soru "Are there...?" olur.'),
  ],
  'a1_articles': [
    _q('a1_artq6', 'This is _____ book.', ['an', 'a', 'the', '-'], 'a',
        'Book sessiz sesle başlar; genel tekil isimde "a" kullanılır.'),
    _q('a1_artq7', 'It is _____ old phone.', ['an', 'a', 'the', '-'], 'an',
        'Old sesli sesle başlar; "an old phone" olur.'),
    _q(
        'a1_artq8',
        'I have a bag. _____ bag is black.',
        ['A', 'An', '-', 'The'],
        'The',
        'Bag ikinci kez geçiyor; artık bilinen şey olduğu için "the" kullanılır.'),
    _q('a1_artq9', 'She is _____ student.', ['an', 'the', 'a', '-'], 'a',
        'Student sessiz sesle başlar; meslek/kimlikte "a student" denir.'),
    _q('a1_artq10', 'We like _____ music.', ['-', 'a', 'an', 'the a'], '-',
        'Genel anlamda music için a/an kullanılmaz.'),
  ],
  'a1_singular_plural': [
    _q('a1_plural_q6', 'I see two _____.', ['dog', 'a dog', 'dogs', 'doges'],
        'dogs', 'Two sonrasında çoğul isim gerekir.'),
    _q(
        'a1_plural_q7',
        'One _____ is on the desk.',
        ['pens', 'penes', 'a pens', 'pen'],
        'pen',
        'One tekildir; isim tekil kalır.'),
    _q(
        'a1_plural_q8',
        'These _____ are heavy.',
        ['bag', 'bags', 'a bag', 'bag is'],
        'bags',
        'These çoğul olduğu için "bags" gerekir.'),
    _q(
        'a1_plural_q9',
        'There are two _____ in my bag.',
        ['watches', 'watch', 'watchs', 'a watch'],
        'watches',
        'Watch çoğulda -es alır.'),
    _q(
        'a1_plural_q10',
        'Three _____ are in the room.',
        ['person', 'persons', 'people', 'a person'],
        'people',
        'Person kelimesinin yaygın çoğulu "people"dir.'),
  ],
  'a1_present_simple': [
    _q(
        'a1_ps_q7',
        'My father _____ in a shop.',
        ['works', 'work', 'working', 'is work'],
        'works',
        'My father he/she/it gibidir; olumlu cümlede fiile -s gelir.'),
    _q('a1_ps_q8', '_____ they play tennis?', ['Does', 'Are', 'Is', 'Do'], 'Do',
        'They ile soru "Do they...?" olur.'),
    _q(
        'a1_ps_q9',
        'She _____ TV at night.',
        ['watch', 'watching', 'watches', 'do watch'],
        'watches',
        'She ile olumlu Present Simple fiile -s/-es alır.'),
    _q(
        'a1_ps_q10',
        'He does not _____ coffee.',
        ['drinks', 'drink', 'drinking', 'is drink'],
        'drink',
        'Does not geldiyse ana fiil V1 kalır.'),
    _q(
        'a1_ps_q11',
        'I usually _____ at seven.',
        ['wakes up', 'waking up', 'am wake', 'wake up'],
        'wake up',
        'I ile fiil yalındır; "usually" rutin anlatır.'),
  ],
  'a1_present_continuous': [
    _q('a1_pc_q6', 'We _____ eating lunch now.', ['is', 'am', 'do', 'are'],
        'are', 'We ile Present Continuous yardımcisi "are" olur.'),
    _q('a1_pc_q7', 'He _____ running in the park.', ['are', 'am', 'is', 'does'],
        'is', 'He ile "is + V-ing" kullanılır.'),
    _q(
        'a1_pc_q8',
        'They are _____ music.',
        ['listening to', 'listen to', 'listens to', 'to listen'],
        'listening to',
        'Present Continuous yapısında fiil -ing alır.'),
    _q('a1_pc_q9', '_____ she sleeping?', ['Are', 'Is', 'Do', 'Does'], 'Is',
        'She ile soru "Is she + V-ing?" olur.'),
    _q('a1_pc_q10', 'I _____ not studying now.', ['is', 'are', 'am', 'do'],
        'am', 'I ile "am not + V-ing" kullanılır.'),
  ],
  'a1_can_cant': [
    _q(
        'a1_can_q6',
        'Can she _____ English?',
        ['speaks', 'speak', 'to speak', 'speaking'],
        'speak',
        'Can sonrasında fiil yalın gelir.'),
    _q('a1_can_q7', 'He _____ play football.', ['cans', 'is', 'can', 'does'],
        'can', 'Can he/she/it ile -s almaz.'),
    _q('a1_can_q8', '_____ I sit here?', ['Do', 'Am', 'Does', 'Can'], 'Can',
        'İzin isterken "Can I...?" kullanılır.'),
    _q(
        'a1_can_q9',
        'She can not _____ today.',
        ['come', 'comes', 'to come', 'coming'],
        'come',
        'Can not sonrasında fiil V1 kalır.'),
    _q('a1_can_q10', 'Yes, we _____.', ['are', 'can', 'do', 'have'], 'can',
        'Can sorusuna kısa cevapta "can" kullanılır.'),
  ],
  'a1_have_has_got': [
    _q(
        'a1_hhg_q6',
        'We _____ a big family.',
        ['has got', 'is got', 'have got', 'are got'],
        'have got',
        'We ile "have got" kullanılır.'),
    _q(
        'a1_hhg_q7',
        'He _____ a new phone.',
        ['have got', 'has got', 'am got', 'are got'],
        'has got',
        'He ile "has got" kullanılır.'),
    _q('a1_hhg_q8', '_____ you got a pen?', ['Have', 'Has', 'Are', 'Do'],
        'Have', 'You ile soru "Have you got...?" olur.'),
    _q('a1_hhg_q9', 'She _____ not got a bike.', ['have', 'is', 'are', 'has'],
        'has', 'She ile olumsuzda "has not got" kullanılır.'),
    _q('a1_hhg_q10', 'They _____ got two cats.', ['has', 'is', 'have', 'are'],
        'have', 'They ile "have got" kullanılır.'),
  ],
  'a1_basic_prepositions': [
    _q('a1_prep_q6', 'The keys are _____ the bag.', ['on', 'at', 'to', 'in'],
        'in', 'Bir şeyin içinde olduğunu anlatırken "in" kullanılır.'),
    _q('a1_prep_q7', 'The book is _____ the table.', ['on', 'in', 'at', 'to'],
        'on', 'Yüzey üstünde "on" kullanılır.'),
    _q('a1_prep_q8', 'The lesson starts _____ eight.', ['in', 'at', 'on', 'to'],
        'at', 'Saatlerde "at" kullanılır.'),
    _q('a1_prep_q9', 'We meet _____ Monday.', ['in', 'at', 'on', 'to'], 'on',
        'Günlerde "on" kullanılır.'),
    _q('a1_prep_q10', 'My birthday is _____ July.', ['on', 'at', 'to', 'in'],
        'in', 'Aylarda "in" kullanılır.'),
  ],
  'a1_imperatives': [
    _q(
        'a1_imp_q6',
        '_____ the door, please.',
        ['Open', 'Opens', 'Opening', 'To open'],
        'Open',
        'Imperative cümle yalın fiille başlar.'),
    _q('a1_imp_q7', 'Please _____ down.', ['sits', 'sit', 'sitting', 'to sit'],
        'sit', 'Please olsa da fiil yalın kalır.'),
    _q('a1_imp_q8', '_____ run in class.', ['Not', 'No', 'Does', "Don't"],
        "Don't", 'Olumsuz imperative "Don\'t + V1" ile kurulur.'),
    _q(
        'a1_imp_q9',
        '_____ carefully.',
        ['Listens', 'Listening', 'Listen', 'To listen'],
        'Listen',
        'Ynerge verirken yalın fiil kullanılır.'),
    _q(
        'a1_imp_q10',
        'Do not _____ the window.',
        ['opens', 'open', 'opening', 'to open'],
        'open',
        'Do not sonrasında fiil V1 kalır.'),
  ],
  'a1_demonstratives': [
    _q('a1_dem_q6', '_____ is my bag.', ['These', 'Those', 'This', 'They'],
        'This', 'Yakındaki tekil şey için "this" kullanılır.'),
    _q('a1_dem_q7', '_____ are my shoes.', ['These', 'This', 'That', 'It'],
        'These', 'Yakındaki çoğul şeyler için "these" kullanılır.'),
    _q(
        'a1_dem_q8',
        '_____ is your car over there.',
        ['These', 'That', 'This', 'They'],
        'That',
        'Uzaktaki tekil şey için "that" kullanılır.'),
    _q('a1_dem_q9', '_____ are old houses.', ['That', 'This', 'It', 'Those'],
        'Those', 'Uzaktaki çoğul şeyler için "those" kullanılır.'),
    _q('a1_dem_q10', 'Are _____ your keys?', ['these', 'this', 'that', 'it'],
        'these', 'Keys çoğuldur; soru içinde "these" uygundur.'),
  ],
};

final Map<String, List<GrammarQuizQuestion>> _a1Step4Quiz = {
  'a1_be_verb': _qs('a1_be_s4', [
    [
      'I _____ ten.',
      ['am', 'is', 'are', 'be'],
      'am',
      'I öznesi be fiilinde her zaman "am" alır. "I is" Türkçe düşünceden gelen yaygın bir hatadır.'
    ],
    [
      'She _____ a doctor.',
      ['am', 'are', 'is', 'be'],
      'is',
      'She üçüncü tekil şahıstır. Bu yüzden "is" kullanılır. "am" sadece I ile, "are" ise you/we/they ile kullanılır.'
    ],
    [
      'They _____ students.',
      ['is', 'are', 'am', 'be'],
      'are',
      'They çoğul öznedir. çoğul kişilerle be fiili "are" olur.'
    ],
    [
      'He _____ not tired.',
      ['are', 'am', 'do', 'is'],
      'is',
      'Olumsuz be cümlesinde önce doğru be fiili gelir, sonra "not" gelir: He is not tired.'
    ],
    [
      '_____ you ready?',
      ['Is', 'Are', 'Am', 'Do'],
      'Are',
      'Be fiiliyle soru yaparken am/is/are başa gelir. You ile "are" kullanılır.'
    ],
    [
      'No, I _____ not.',
      ['is', 'are', 'do', 'am'],
      'am',
      'Are you...? sorusuna cevap verirken özne I ise "am" kullanılır: No, I am not.'
    ],
    [
      'My mother _____ at home.',
      ['are', 'am', 'is', 'be'],
      'is',
      'My mother tek kişidir. Yer bildirirken de tekil kişi için "is" gerekir.'
    ],
    [
      'We _____ happy today.',
      ['are', 'is', 'am', 'be'],
      'are',
      'We öznesi her zaman "are" alır. Duygu cümlelerinde de be fiili gerekir.'
    ],
    [
      '_____ he your brother?',
      ['Are', 'Am', 'Do', 'Is'],
      'Is',
      'He üçüncü tekil şahıstır. Be sorusunda doğru yapı "Is he...?" şeklindedir.'
    ],
    [
      'My father _____ a teacher.',
      ['are', 'is', 'am', 'do'],
      'is',
      'Meslek söylerken be fiili kullanılır. My father tek kişi olduğu için "is" doğrudur.'
    ],
  ]),
  'a1_subject_pronouns': _qs('a1_pron_s4', [
    [
      '_____ am a student.',
      ['He', 'I', 'She', 'They'],
      'I',
      'Am sadece I ile kullanılır. Bu yüzden özne "I" olmalıdır.'
    ],
    [
      'Ali is my friend. _____ is funny.',
      ['She', 'It', 'They', 'He'],
      'He',
      'Ali erkek ismidir. Erkek tekil kişi için özne zamiri "he" kullanılır.'
    ],
    [
      'Ayşe is my sister. _____ is kind.',
      ['She', 'He', 'It', 'We'],
      'She',
      'Ayşe kadın/kız ismidir. Kadın tekil kişi için "she" kullanılır.'
    ],
    [
      'This phone is new. _____ is black.',
      ['They', 'He', 'It', 'She'],
      'It',
      'Tek bir eşya için "it" kullanılır. Eşyalar için he/she kullanılmaz.'
    ],
    [
      'My brother and I are ready. _____ are ready.',
      ['They', 'You', 'We', 'It'],
      'We',
      'Konuşan kişi grubun içindeyse "we" kullanılır.'
    ],
    [
      'Ali and Ece are here. _____ are here.',
      ['They', 'We', 'It', 'He'],
      'They',
      'İki kişi çoğuldur. Konuşan kişi bu grupta değilse "they" kullanılır.'
    ],
    [
      '_____ are my teacher.',
      ['I', 'He', 'It', 'You'],
      'You',
      'Karşımızdaki kişiye hitap ederken "you" kullanılır. You ile be fiili "are" olur.'
    ],
    [
      'The books are on the desk. _____ are old.',
      ['It', 'They', 'He', 'She'],
      'They',
      'Books çoğuldur. çoğul nesneler için "they" kullanılır.'
    ],
    [
      'Mert is at school. _____ is in class.',
      ['They', 'It', 'He', 'She'],
      'He',
      'Mert tek erkek kişidir; yerine "he" gelir.'
    ],
    [
      'The cat is small. _____ is white.',
      ['It', 'They', 'He', 'We'],
      'It',
      'A1 düzeyinde hayvanın cinsiyetini özellikle söylemiyorsak tek hayvan için genelde "it" kullanılır.'
    ],
  ]),
  'a1_possessive_adjectives': _qs('a1_poss_s4', [
    [
      'I have a bag. _____ bag is blue.',
      ['I', 'His', 'My', 'Their'],
      'My',
      'Sahiplik sıfatı isimden önce gelir. I için sahiplik sıfatı "my" olur.'
    ],
    [
      'You have a phone. _____ phone is new.',
      ['Your', 'You', 'My', 'Her'],
      'Your',
      'You öznesinin sahiplik şekli "your"dur: your phone.'
    ],
    [
      'Ali has a bike. _____ bike is red.',
      ['He', 'Her', 'Its', 'His'],
      'His',
      'Ali erkek olduğu için sahiplikte "his" kullanılır. "He bike" denmez.'
    ],
    [
      'Ece has a room. _____ room is clean.',
      ['She', 'Her', 'His', 'Our'],
      'Her',
      'Ece için sahiplik sıfatı "her" olur. "She" özne olarak kullanılır, isimden önce gelmez.'
    ],
    [
      'The cat has a toy. _____ toy is small.',
      ['Its', 'It', 'His', 'Their'],
      'Its',
      'Bir hayvan/eşya için sahiplik sıfatı "its" olur. "It toy" yanlıştır.'
    ],
    [
      'We have a class. _____ class is quiet.',
      ['We', 'Their', 'Our', 'My'],
      'Our',
      'We grubunun sahipliği "our" ile anlatılır: our class.'
    ],
    [
      'They have a house. _____ house is big.',
      ['They', 'Their', 'Our', 'Its'],
      'Their',
      'They için sahiplik sıfatı "their" olur.'
    ],
    [
      'Is this _____ book?',
      ['you', 'he', 'she', 'your'],
      'your',
      'Book isimdir; isimden önce sahiplik sıfatı gerekir: your book.'
    ],
    [
      'She is my sister. _____ name is Ece.',
      ['Her', 'She', 'His', 'Its'],
      'Her',
      'Name bir isimdir. Kız kardeşin adını söylerken "her name" kullanılır.'
    ],
    [
      'He is my father. _____ job is teacher.',
      ['He', 'Her', 'His', 'Our'],
      'His',
      'Job isimdir. Erkek kişi için isimden önce "his" gelir.'
    ],
  ]),
  'a1_there_is_are': _qs('a1_there_s4', [
    [
      'There _____ a bed in my room.',
      ['are', 'am', 'be', 'is'],
      'is',
      'A bed tekildir. Tekil isimle "there is" kullanılır.'
    ],
    [
      'There _____ two chairs in the kitchen.',
      ['is', 'are', 'am', 'be'],
      'are',
      'Two chairs çoğuldur. çoğul isimle "there are" gerekir.'
    ],
    [
      'There _____ not a TV in my room.',
      ['are', 'am', 'is', 'do'],
      'is',
      'A TV tekildir. Olumsuzda da tekil için "there is not" kullanılır.'
    ],
    [
      'There _____ not any books on the desk.',
      ['are', 'is', 'am', 'does'],
      'are',
      'Books çoğuldur. "Any books" ile olumsuz çoğulda "there are not" kullanılır.'
    ],
    [
      '_____ there a park near here?',
      ['Are', 'Do', 'Does', 'Is'],
      'Is',
      'A park tekildir. Soru "Is there a park...?" şeklinde kurulur.'
    ],
    [
      '_____ there any buses today?',
      ['Are', 'Is', 'Do', 'Does'],
      'Are',
      'Buses çoğuldur. Any + çoğul isimle soruda "Are there...?" kullanılır.'
    ],
    [
      'There _____ a bank on this street.',
      ['are', 'is', 'am', 'be'],
      'is',
      'A bank tekil bir yerdir. Şehir/yer tarifinde tekil için "there is" kullanılır.'
    ],
    [
      'There _____ many cafes in my city.',
      ['is', 'am', 'are', 'be'],
      'are',
      'Many cafes çoğuldur. Bu yüzden "there are" doğrudur.'
    ],
    [
      'There are _____ books on the shelf.',
      ['a', 'some', 'an', 'is'],
      'some',
      'Books çoğul olduğu için a/an kullanılamaz. Olumlu çoğul cümlede "some" doğaldır.'
    ],
    [
      'There is _____ apple on the table.',
      ['a', 'any', 'are', 'an'],
      'an',
      'Apple tekil ve sesli sesle başlar; "an apple" gerekir.'
    ],
  ]),
  'a1_articles': _qs('a1_arts4', [
    [
      'I need _____ pen.',
      ['an', 'a', 'the', '-'],
      'a',
      'Pen sessiz sesle başlar ve tekil sayılabilen isimdir. İlk/genel söyleyişte "a pen" kullanılır.'
    ],
    [
      'She has _____ umbrella.',
      ['an', 'a', 'the', '-'],
      'an',
      'Umbrella sesli sesle başlar. Bu yüzden "an umbrella" kullanılır.'
    ],
    [
      'I saw a dog. _____ dog was black.',
      ['A', 'An', '-', 'The'],
      'The',
      'Dog ikinci kez geçiyor. Artık hangi köpek olduğu belli olduğu için "the dog" kullanılır.'
    ],
    [
      'He is _____ student.',
      ['an', 'the', 'a', '-'],
      'a',
      'Student sessiz sesle başlar. Meslek/kimlik tekilse "a student" deriz.'
    ],
    [
      'She is _____ engineer.',
      ['an', 'a', 'the', '-'],
      'an',
      'Engineer sesli sesle başlar. Bu yüzden "an engineer" doğrudur.'
    ],
    [
      'I like _____ apples.',
      ['a', 'an', 'the a', '-'],
      '-',
      'Genel olarak çoğul isimlerden bahsederken a/an kullanılmaz: I like apples.'
    ],
    [
      'Open _____ door, please.',
      ['a', 'the', 'an', '-'],
      'the',
      'Kapı belli bir kapıdır. Dinleyen hangi kapı olduğunu bildiği için "the door" kullanılır.'
    ],
    [
      'This is _____ old phone.',
      ['a', 'the', 'an', '-'],
      'an',
      'Old sesli sesle başlar. Sıfat varsa a/an seçimi sıfatın sesine göre yapılır: an old phone.'
    ],
    [
      'There is _____ cafe near here.',
      ['an', 'the', '-', 'a'],
      'a',
      'Cafe ilk kez söylenen tekil sayılabilen isimdir; "a cafe" kullanılır.'
    ],
    [
      '_____ cafe is open now.',
      ['A', 'The', 'An', '-'],
      'The',
      'önce bahsedilen cafe artık biliniyor. İkinci kullanımda "the cafe" doğaldır.'
    ],
  ]),
  'a1_singular_plural': _qs('a1_plural_s4', [
    [
      'I have two _____.',
      ['book', 'a book', 'books', 'bookes'],
      'books',
      'Two birden fazladır. Sayılabilen isim çoğul olur: two books.'
    ],
    [
      'There are three _____ in the room.',
      ['box', 'boxs', 'a box', 'boxes'],
      'boxes',
      'Box -x ile biter; çoğulda -es alır: boxes.'
    ],
    [
      'This is one _____.',
      ['bags', 'bag', 'bagies', 'a bags'],
      'bag',
      'One tekildir. Bu yüzden isim tekil kalır: one bag.'
    ],
    [
      'These are my _____.',
      ['keys', 'key', 'a key', 'keies'],
      'keys',
      'These çoğuldur; arkasından çoğul isim gelir: keys.'
    ],
    [
      'Those _____ are old.',
      ['house', 'a house', 'houses', 'housees'],
      'houses',
      'Those çoğul gösterir. Bu yüzden isim de çoğul olur.'
    ],
    [
      'Two _____ are in the park.',
      ['child', 'children', 'childs', 'a child'],
      'children',
      'Child düzensiz çoğuldur; "childs" değil "children" kullanılır.'
    ],
    [
      'Five _____ are in class.',
      ['person', 'persons', 'a person', 'people'],
      'people',
      'Person kelimesinin yaygın çoğulu "people"dır.'
    ],
    [
      'I have _____ orange.',
      ['an', 'a', 'two', '-'],
      'an',
      'Orange tekil ve sesli sesle başlar; "an orange" gerekir.'
    ],
    [
      'I have _____ oranges.',
      ['an', 'two', 'a', 'one'],
      'two',
      'Oranges çoğuldur. A/an çoğul isimle kullanılmaz.'
    ],
    [
      'There are four _____ on the desk.',
      ['pen', 'a pen', 'pens', 'penes'],
      'pens',
      'Four çoğul sayı olduğu için dzenli isim -s alır: pens.'
    ],
  ]),
  'a1_present_simple': _qs('a1_ps_s4', [
    [
      'I _____ tea every morning.',
      ['drink', 'drinks', 'drinking', 'am drink'],
      'drink',
      'I ile Present Simple olumlu cümlede fiil yalın kalır.'
    ],
    [
      'She _____ English at school.',
      ['study', 'studying', 'is study', 'studies'],
      'studies',
      'She ile olumlu cümlede fiile -s/-es gelir. Study fiili -ies olur.'
    ],
    [
      'He _____ football on Sundays.',
      ['play', 'playing', 'plays', 'is play'],
      'plays',
      'He üçüncü tekildir; olumlu rutinde fiil -s alır.'
    ],
    [
      'We _____ breakfast at home.',
      ['eats', 'eat', 'eating', 'are eat'],
      'eat',
      'We ile ana fiil yalın kalır.'
    ],
    [
      'I _____ like coffee.',
      ["doesn't", "am not", "isn't", "don't"],
      "don't",
      'I ile olumsuz Present Simple "don\'t + V1" olur.'
    ],
    [
      'She _____ drink milk.',
      ["don't", "doesn't", "isn't", "aren't"],
      "doesn't",
      'She ile olumsuzda "doesn\'t + yalın fiil" kullanılır. Drink fiiline -s eklenmez.'
    ],
    [
      '_____ you live here?',
      ['Do', 'Does', 'Are', 'Is'],
      'Do',
      'You ile Present Simple sorusu "Do you + V1?" şeklindedir.'
    ],
    [
      '_____ he work here?',
      ['Do', 'Is', 'Does', 'Are'],
      'Does',
      'He ile soru "Does he + V1?" olur. Ana fiil yalın kalır.'
    ],
    [
      'The sun _____ in the morning.',
      ['rise', 'rises', 'rising', 'is rise'],
      'rises',
      'The sun tekildir. Genel gereklerde Present Simple kullanılır ve fiil -s alır.'
    ],
    [
      'He does not _____ meat.',
      ['eats', 'eating', 'to eat', 'eat'],
      'eat',
      'Does/doesn\'t geldikten sonra ana fiil yalın kalır. "doesn\'t eats" yanlıştır.'
    ],
  ]),
  'a1_present_continuous': _qs('a1_pc_s4', [
    [
      'I _____ studying now.',
      ['is', 'are', 'do', 'am'],
      'am',
      'I ile Present Continuous yapısında "am + V-ing" kullanılır.'
    ],
    [
      'She _____ reading a book.',
      ['are', 'am', 'is', 'does'],
      'is',
      'She tekildir; ödevam eden eylem için "is reading" gerekir.'
    ],
    [
      'They _____ watching TV right now.',
      ['are', 'is', 'am', 'do'],
      'are',
      'They çoğuldur. Present Continuous yapısında "are + V-ing" kullanılır.'
    ],
    [
      'We are _____ for the bus.',
      ['wait', 'waiting', 'waits', 'to wait'],
      'waiting',
      'am/is/are sonrasında fiil -ing formunda gelir.'
    ],
    [
      'He is not _____ now.',
      ['sleep', 'sleeps', 'sleeping', 'to sleep'],
      'sleeping',
      'Olumsuzda not, be fiilinden sonra gelir; ana fiil yine -ing alır.'
    ],
    [
      '_____ you listening?',
      ['Are', 'Is', 'Am', 'Do'],
      'Are',
      'Soru yaparken be fiili başa gelir. You ile "Are" kullanılır.'
    ],
    [
      '_____ she coming today?',
      ['Are', 'Is', 'Do', 'Does'],
      'Is',
      'She ile Present Continuous sorusu "Is she + V-ing?" olur.'
    ],
    [
      'My father _____ working today.',
      ['are', 'am', 'does', 'is'],
      'is',
      'My father tek kişidir. Geçici/bugnk eylem için "is working" kullanılır.'
    ],
    [
      'The children _____ playing outside.',
      ['are', 'is', 'am', 'do'],
      'are',
      'Children çoğuldur. Bu yüzden "are playing" doğrudur.'
    ],
    [
      'I am _____ lunch right now.',
      ['eat', 'eats', 'eating', 'to eat'],
      'eating',
      'Right now Şu anı gösterir. Present Continuous için am + V-ing gerekir.'
    ],
  ]),
  'a1_can_cant': _qs('a1_can_s4', [
    [
      'I can _____.',
      ['swims', 'swim', 'to swim', 'swimming'],
      'swim',
      'Can\'den sonra fiil yalın halde gelir. -s, to veya -ing kullanılmaz.'
    ],
    [
      'She can _____ English.',
      ['speaks', 'to speak', 'speak', 'speaking'],
      'speak',
      'Can he/she/it ile değişmez. Bu yüzden "can speaks" yanlıştır.'
    ],
    [
      'He _____ ride a bike.',
      ['cans', 'is', 'does', 'can'],
      'can',
      'Can özneye göre -s almaz. Doğru yapı "he can ride" olur.'
    ],
    [
      'She _____ drive.',
      ["can't", "doesn't", "isn't", "don't"],
      "can't",
      'Can yapısının olumsuzu "can\'t/cannot" olur. Do/does kullanılmaz.'
    ],
    [
      '_____ you help me?',
      ['Do', 'Can', 'Are', 'Does'],
      'Can',
      'Rica sorusunda "Can you + V1?" çok doğal bir A1 yapısıdır.'
    ],
    [
      '_____ I sit here?',
      ['Do', 'Am', 'Does', 'Can'],
      'Can',
      'İzin isterken "Can I + V1?" kullanılır.'
    ],
    [
      'No, I _____.',
      ["don't", "am not", "can't", "haven't"],
      "can't",
      'Can ile sorulan soruya kısa cevap yine can/can\'t ile verilir.'
    ],
    [
      'Yes, we _____.',
      ['can', 'are', 'do', 'have'],
      'can',
      'Can sorusunun olumlu kısa cevabı "Yes, subject + can" şeklindedir.'
    ],
    [
      'Can they _____ this song?',
      ['sings', 'to sing', 'singing', 'sing'],
      'sing',
      'Soru yapısında da can sonrasında fiil yalın kalır.'
    ],
    [
      'My brother can _____ a bike.',
      ['rides', 'ride', 'to ride', 'riding'],
      'ride',
      'Can\'den sonra ana fiil V1 olur: can ride.'
    ],
  ]),
  'a1_have_has_got': _qs('a1_have_s4', [
    [
      'I _____ got a bike.',
      ['has', 'am', 'have', 'do'],
      'have',
      'I ile sahiplik anlatırken "have got" kullanılır.'
    ],
    [
      'She _____ got a brother.',
      ['have', 'has', 'is', 'does'],
      'has',
      'She üçüncü tekildir. Bu yüzden "has got" gerekir.'
    ],
    [
      'They _____ got a small house.',
      ['have', 'has', 'are', 'do'],
      'have',
      'They ile "have got" kullanılır.'
    ],
    [
      'He _____ got a car.',
      ["haven't", "isn't", "don't", "hasn't"],
      "hasn't",
      'He ile olumsuz sahiplik "hasn\'t got" olur.'
    ],
    [
      'We _____ got a TV.',
      ["hasn't", "aren't", "haven't", "don't"],
      "haven't",
      'We ile olumsuzda "haven\'t got" kullanılır.'
    ],
    [
      '_____ you got a pen?',
      ['Have', 'Has', 'Do', 'Are'],
      'Have',
      'You ile soru "Have you got...?" şeklinde başlar.'
    ],
    [
      '_____ she got a phone?',
      ['Have', 'Does', 'Is', 'Has'],
      'Has',
      'She ile soru "Has she got...?" olur.'
    ],
    [
      'Yes, I _____.',
      ['has', 'have', 'am', 'do'],
      'have',
      'Have you got...? sorusuna kısa olumlu cevap "Yes, I have" olur; got tekrar edilmez.'
    ],
    [
      'No, she _____.',
      ["hasn't", "haven't", "isn't", "doesn't"],
      "hasn't",
      'Has she got...? sorusuna kısa olumsuz cevap "No, she hasn\'t" olur.'
    ],
    [
      'My sister _____ got a cat.',
      ['have', 'is', 'has', 'does'],
      'has',
      'My sister tek kişidir. Aile/nesne sahipliğinde "has got" kullanılır.'
    ],
  ]),
  'a1_basic_prepositions': _qs('a1_prep_s4', [
    [
      'The keys are _____ my bag.',
      ['on', 'at', 'to', 'in'],
      'in',
      'Bir şey çantanın içindeyse "in" kullanılır.'
    ],
    [
      'The book is _____ the table.',
      ['on', 'in', 'at', 'to'],
      'on',
      'Yüzey üstünde olan şeyler için "on" kullanılır: on the table.'
    ],
    [
      'I am _____ school now.',
      ['in', 'at', 'on', 'to'],
      'at',
      'Okul gibi nokta/yer bildiren A1 ifadelerde "at school" kullanılır.'
    ],
    [
      'My birthday is _____ May.',
      ['on', 'at', 'in', 'to'],
      'in',
      'Ay isimleriyle "in" kullanılır: in May.'
    ],
    [
      'We meet _____ Monday.',
      ['in', 'at', 'to', 'on'],
      'on',
      'Gün isimleriyle "on" kullanılır. "in Monday" yaygın bir hatadır.'
    ],
    [
      'The lesson starts _____ seven.',
      ['on', 'at', 'in', 'for'],
      'at',
      'Saatlerde "at" kullanılır: at seven.'
    ],
    [
      'There is milk _____ the fridge.',
      ['in', 'on', 'at', 'to'],
      'in',
      'Fridge bir kap/alan gibi düşünlr; içinde olduğu için "in" gerekir.'
    ],
    [
      'The picture is _____ the wall.',
      ['in', 'at', 'on', 'from'],
      'on',
      'Duvar yüzeyinde duran şeyler için "on the wall" kullanılır.'
    ],
    [
      'She is _____ home today.',
      ['on', 'at', 'in', 'to'],
      'at',
      'Evde olma ifadesi A1 düzeyinde "at home" şeklindedir.'
    ],
    [
      'I was born _____ 2015.',
      ['on', 'at', 'to', 'in'],
      'in',
      'Yıllarla "in" kullanılır: in 2015.'
    ],
  ]),
  'a1_imperatives': _qs('a1_imp_s4', [
    [
      '_____ the door, please.',
      ['Open', 'Opens', 'Opening', 'You open'],
      'Open',
      'Imperative cümle yalın fiille başlar. özne yazmak gerekmez.'
    ],
    [
      'Please _____ down.',
      ['sits', 'sit', 'sitting', 'to sit'],
      'sit',
      'Please sonrasında fiil yalın halde gelir: Please sit down.'
    ],
    [
      '_____ run in the classroom.',
      ["Doesn't", "Isn't", "Aren't", "Don't"],
      "Don't",
      'Olumsuz emir için "Don\'t + yalın fiil" kullanılır.'
    ],
    [
      '_____ carefully.',
      ['Listens', 'Listening', 'Listen', 'To listen'],
      'Listen',
      'Sınıf yönergelerinde fiil yalın halde başa gelir.'
    ],
    [
      "Don't _____ late.",
      ['is', 'be', 'are', 'to be'],
      'be',
      'Don\'t sonrasında be fiili de yalın halde "be" kalır.'
    ],
    [
      '_____ your name here.',
      ['Writes', 'Writing', 'Write', 'To write'],
      'Write',
      'Talimat verirken "write" gibi yalın fiille başlarız.'
    ],
    [
      'Please _____ the window.',
      ['close', 'closes', 'closing', 'to close'],
      'close',
      'Kibar yönergede please + yalın fiil kullanılır.'
    ],
    [
      '_____ at the board.',
      ['Looks', 'Looking', 'To look', 'Look'],
      'Look',
      'Classroom instruction yapısında özne kullanılmaz; fiil yalın gelir.'
    ],
    [
      "Don't _____ your phone in class.",
      ['uses', 'using', 'use', 'to use'],
      'use',
      'Don\'t sonrasında ana fiil yalındır. "Don\'t uses" denmez.'
    ],
    [
      '_____ after me.',
      ['Repeats', 'Repeat', 'Repeating', 'To repeat'],
      'Repeat',
      'Komut/yönerge cümlesinde yalın fiil kullanılır: Repeat after me.'
    ],
  ]),
  'a1_demonstratives': _qs('a1_dem_s4', [
    [
      '_____ is my phone here.',
      ['These', 'Those', 'This', 'They'],
      'This',
      'Phone tekil ve yakında. Yakındaki tekil şey için "this" kullanılır.'
    ],
    [
      '_____ is your bag over there.',
      ['That', 'These', 'This', 'They'],
      'That',
      'Bag tekil ve uzakta. Uzaktaki tekil şey için "that" kullanılır.'
    ],
    [
      '_____ are my keys here.',
      ['This', 'These', 'That', 'It'],
      'These',
      'Keys çoğul ve yakında. Yakındaki çoğul şeyler için "these" kullanılır.'
    ],
    [
      '_____ are my shoes over there.',
      ['That', 'This', 'It', 'Those'],
      'Those',
      'Shoes çoğul ve uzakta. Uzaktaki çoğul şeyler için "those" kullanılır.'
    ],
    [
      'This _____ my seat.',
      ['is', 'are', 'am', 'be'],
      'is',
      'This tekildir. This/that ile be fiili "is" olur.'
    ],
    [
      'That _____ a big house.',
      ['are', 'am', 'is', 'be'],
      'is',
      'That tekil gösterir. Bu yüzden "is" kullanılır.'
    ],
    [
      'These _____ my books.',
      ['is', 'am', 'be', 'are'],
      'are',
      'These çoğuldur. These/those ile "are" kullanılır.'
    ],
    [
      'Those _____ old cars.',
      ['is', 'are', 'am', 'be'],
      'are',
      'Those çoğul ve uzak şeyleri gösterir; be fiili "are" olur.'
    ],
    [
      'Is _____ your bag?',
      ['these', 'those', 'this', 'they'],
      'this',
      'Soru tekil bir çantayı soruyor. Doğru yapı "Is this...?" şeklindedir.'
    ],
    [
      'Are _____ your pencils?',
      ['these', 'this', 'that', 'it'],
      'these',
      'Pencils çoğuldur. çoğul yakındaki şeyler için "these" kullanılır.'
    ],
  ]),
};

const Map<String, GrammarLesson> _a1Lessons = {
  'a1_be_verb': GrammarLesson(
    bigTitle: 'Be: am / is / are',
    oneLineGoal:
        'am/is/are ile kimlik, duygu, yer, yaş ve meslek cümleleri kur.',
    timeLabel: '8 dk',
    teacherIntro:
        'Be fiili Türkçedeki "olmak" gibi düşünülebilir ama İngilizcede cümlede görünmek zorundadır. "I happy" değil, "I am happy" deriz. Özneye göre am, is veya are seçilir.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'I + am / He-She-It + is / You-We-They + are',
          sample: 'She is a student.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'subject + am/is/are + not',
          sample: 'They are not at home.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Am/Is/Are + subject?',
          sample: 'Are you tired?'),
      GrammarFormulaRow(
          label: 'Short answers',
          pattern: 'Yes, subject + be. / No, subject + be + not.',
          sample: 'Yes, I am. / No, she isn\'t.'),
    ],
    usageBullets: [
      'I ile am, he/she/it ile is, you/we/they ile are kullan.',
      'Olumsuzda not, be fiilinden sonra gelir.',
      'Soruda am/is/are başa gelir.',
      'Kısa cevapta ana bilgiyi tekrar etmezsin: Yes, I am.',
    ],
    examples: [
      'I am a student.',
      'You are happy.',
      'He is my brother.',
      'We are at school.',
      'They are friends.',
      'Are you ready?',
    ],
    wrong: 'She are a doctor.',
    right: 'She is a doctor.',
    reason:
        'She üçüncü tekil şahıstır. Bu yüzden be fiili "is" olur. "are" you/we/they ile kullanılır.',
    task: 'Kendin ve iki kişi hakkında 5 be cümlesi kur.',
    modelAnswer:
        'I am a student. My mother is kind. My friends are at school. I am not tired. Are you ready?',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_be_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'She _____ a doctor.',
          options: ['am', 'is', 'are', 'be'],
          answer: 'is',
          explanation:
              'She üçüncü tekil şahıstır. Bu yüzden "is" kullanılır. "am" sadece I ile, "are" ise you/we/they ile kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_be_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I _____ ready.',
          options: ['am', 'is', 'are', 'be'],
          answer: 'am',
          explanation: 'I öznesi be fiilinde sadece "am" alır: I am ready.'),
      GrammarQuizQuestion(
          id: 'a1_be_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'They _____ at school.',
          options: ['are', 'is', 'am', 'be'],
          answer: 'are',
          explanation: 'They çoğul olduğu için "are" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_be_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ you tired?',
          options: ['Are', 'Is', 'Am', 'Do'],
          answer: 'Are',
          explanation:
              'Be fiiliyle soru yaparken fiil başa gelir: Are you tired?'),
      GrammarQuizQuestion(
          id: 'a1_be_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'He _____ not here.',
          options: ['is', 'are', 'am', 'do'],
          answer: 'is',
          explanation:
              'Olumsuz be cümlesinde "not", be fiilinden sonra gelir: He is not here.'),
    ],
  ),
  'a1_subject_pronouns': GrammarLesson(
    bigTitle: 'Subject & Object Pronouns',
    oneLineGoal:
        'İsim yerine özne olarak I/he/she; fiilden sonra me/him/her gibi zamirler kullan.',
    timeLabel: '7 dk',
    teacherIntro:
        'Subject pronoun cümlenin öznesidir. Türkçede özneyi bazen saklayabiliriz ama İngilizcede genelde söylemek gerekir. "Is happy" değil, "She is happy" deriz.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'People',
          pattern: 'I / you / he / she / we / they',
          sample: 'She is my friend.'),
      GrammarFormulaRow(
          label: 'Things and animals',
          pattern: 'it (one thing) / they (plural)',
          sample: 'It is new.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'pronoun + verb',
          sample: 'Are they ready?'),
      GrammarFormulaRow(
          label: 'Object pronouns',
          pattern: 'verb/preposition + me/you/him/her/it/us/them',
          sample: 'Can you help me?'),
      GrammarFormulaRow(
          label: 'Avoid repeat',
          pattern: 'name OR pronoun',
          sample: 'Mary is happy. / She is happy.'),
    ],
    usageBullets: [
      'Kadın/kız için she, erkek için he kullan.',
      'Tek bir eşya/hayvan/fikir için it; çoğul için they kullan.',
      'Fiilden sonra I/he/she/we/they değil me/him/her/us/them kullan.',
      'Aynı özne yerinde hem isim hem zamir kullanma.',
    ],
    examples: [
      'I am a teacher.',
      'You are my friend.',
      'He is ten years old.',
      'She is at home.',
      'They are students.',
      'We are ready.',
    ],
    wrong: 'Mary she is happy.',
    right: 'Mary is happy.',
    reason:
        'Aynı özne yerinde hem isim hem zamir kullanma. "Mary is happy" veya "She is happy" yeterlidir.',
    task:
        'Ailendeki kişiler ve eşyalar için özne ve nesne zamirleriyle 6 cümle yaz.',
    modelAnswer:
        'My father is kind. He is a teacher. My sister is young. She is funny. My bag is black. It is new.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_pron_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Ayşe is my sister. _____ is kind.',
          options: ['She', 'He', 'It', 'They'],
          answer: 'She',
          explanation:
              'Ayşe bir kadın/kız ismidir. özne olarak "she" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_pron_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Ali is my friend. _____ is funny.',
          options: ['He', 'She', 'It', 'They'],
          answer: 'He',
          explanation: 'Ali erkek ismidir. özne olarak "he" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_pron_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'My keys are here. _____ are on the table.',
          options: ['They', 'It', 'He', 'She'],
          answer: 'They',
          explanation: 'Keys çoğuldur. çoğul şeyler için "they" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_pron_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'This phone is new. _____ is expensive.',
          options: ['It', 'They', 'He', 'We'],
          answer: 'It',
          explanation: 'Tek bir eşya için "it" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_pron_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'My friends and I are ready. _____ are ready.',
          options: ['We', 'They', 'You', 'It'],
          answer: 'We',
          explanation: 'Konuşan kişi grubun içindeyse "we" kullanılır.'),
    ],
  ),
  'a1_possessive_adjectives': GrammarLesson(
    bigTitle: 'Possessives',
    oneLineGoal:
        'my/your/his/her ve Ali’s / whose ile kime ait olduğunu anlat.',
    timeLabel: '7 dk',
    teacherIntro:
        'Possessive adjective tek başına durmaz; mutlaka bir isimden önce gelir: my bag, her phone. Türkçede "onun telefonu" derken tek kelime gibi hissedebilirsin ama İngilizcede his/her ayrımına dikkat ederiz.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Basic form',
          pattern: 'possessive adjective + noun',
          sample: 'My bag is black.'),
      GrammarFormulaRow(
          label: 'His / her',
          pattern: 'his + noun / her + noun',
          sample: 'Her phone is new.'),
      GrammarFormulaRow(
          label: 'Our / their',
          pattern: 'our + noun / their + noun',
          sample: 'Their house is big.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Is this + possessive adjective + noun?',
          sample: 'Is this your book?'),
      GrammarFormulaRow(
          label: 'Possessive ’s / whose',
          pattern: 'name + ’s + noun / Whose + noun?',
          sample: 'This is Ece’s bag. Whose pen is this?'),
    ],
    usageBullets: [
      'Possessive adjective isimden önce gelir.',
      'He/she zne, his/her sahipliktir.',
      'Your hem senin hem sizin anlamına gelebilir.',
      'Bir kişinin sahipliğini isimle söylersen Ali’s bag gibi ’s ekle.',
      'Kime ait diye sorarken Whose...? kullan.',
    ],
    examples: [
      'My notebook is here.',
      'Your jacket is nice.',
      'His car is blue.',
      'Her phone is on the desk.',
      'Our teacher is friendly.',
      'Their room is clean.',
      'This is Ece’s bag.',
      'Whose pen is this?',
    ],
    wrong: 'She phone is new.',
    right: 'Her phone is new.',
    reason:
        'Phone bir isimdir. İsimden önce sahiplik gerekiyorsa "her" kullanılır. "She" özne olarak kullanılır.',
    task: 'my, your, his, her, our, their ve ’s ile 6 sahiplik cümlesi yaz.',
    modelAnswer:
        'My bag is black. Your pen is blue. His room is small. Her phone is new. Our class is quiet. Their house is big.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_poss_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Ali has a bag. _____ bag is black.',
          options: ['His', 'He', 'Her', 'Their'],
          answer: 'His',
          explanation:
              'Ali erkek olduğu için sahiplikte "his bag" deriz. "He" özne olur, isimden önce kullanılmaz.'),
      GrammarQuizQuestion(
          id: 'a1_poss_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Ayşe has a phone. _____ phone is new.',
          options: ['Her', 'She', 'His', 'Our'],
          answer: 'Her',
          explanation: 'Ayşe için sahiplik sıfatımız "her" olur: her phone.'),
      GrammarQuizQuestion(
          id: 'a1_poss_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'We are in class. _____ teacher is kind.',
          options: ['Our', 'We', 'Their', 'My'],
          answer: 'Our',
          explanation:
              'We grubunun sahipliği "our" ile anlatılır: our teacher.'),
      GrammarQuizQuestion(
          id: 'a1_poss_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'They have a house. _____ house is big.',
          options: ['Their', 'They', 'Our', 'Its'],
          answer: 'Their',
          explanation: 'They için sahiplik sıfatı "their" olur.'),
      GrammarQuizQuestion(
          id: 'a1_poss_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Is this _____ book?',
          options: ['your', 'you', 'yours', 'he'],
          answer: 'your',
          explanation:
              'Book isim olduğu için önüne possessive adjective gelir: your book.'),
    ],
  ),
  'a1_there_is_are': GrammarLesson(
    bigTitle: 'There is / There are',
    oneLineGoal: 'Bir yerde ne var/ne yok söyle.',
    timeLabel: '8 dk',
    teacherIntro:
        'There is / there are "var" demenin en temel yoludur. Tek bir şey varsa there is, birden fazla şey varsa there are kullanılır. Türkçedeki "var" tek kelime ama İngilizcede tekil-çoğul seçimi gerekir.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Positive singular',
          pattern: 'There is + singular noun',
          sample: 'There is a table.'),
      GrammarFormulaRow(
          label: 'Positive plural',
          pattern: 'There are + plural noun',
          sample: 'There are two chairs.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'There isn\'t / There aren\'t',
          sample: 'There isn\'t a TV.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Is there...? / Are there...?',
          sample: 'Are there any books?'),
    ],
    usageBullets: [
      'Tekil isimle there is kullan.',
      'çoğul isimle there are kullan.',
      'Soruda is/are başa gelir.',
      'Yok demek için there isn\'t / there aren\'t kullan.',
    ],
    examples: [
      'There is a book on the table.',
      'There is a cat in the room.',
      'There are two chairs.',
      'There are five students.',
      'There is not a computer here.',
      'Are there any questions?',
    ],
    wrong: 'There is two chairs.',
    right: 'There are two chairs.',
    reason: 'Two chairs çoğuldur. çoğul isimle "there are" kullanılır.',
    task: 'Odanda olan ve olmayan şeyleri 6 cümleyle anlat.',
    modelAnswer:
        'There is a bed. There is a desk. There are two chairs. There are books on the desk. There isn\'t a TV. There aren\'t any plants.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_there_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'There _____ a cat in the garden.',
          options: ['is', 'are', 'am', 'be'],
          answer: 'is',
          explanation: 'A cat tekildir. Tekil isimle "there is" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_there_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'There _____ two chairs in the room.',
          options: ['are', 'is', 'am', 'be'],
          answer: 'are',
          explanation: 'Two chairs çoğuldur. Bu yüzden "there are" gerekir.'),
      GrammarQuizQuestion(
          id: 'a1_there_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ there a bank near here?',
          options: ['Is', 'Are', 'Do', 'Does'],
          answer: 'Is',
          explanation: 'A bank tekildir. Soruda "Is there...?" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_there_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ there any students in class?',
          options: ['Are', 'Is', 'Do', 'Does'],
          answer: 'Are',
          explanation: 'Students çoğuldur. Soruda "Are there...?" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_there_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'There _____ any milk.',
          options: ["isn't", "aren't", 'am not', "don't"],
          answer: "isn't",
          explanation:
              'Milk sayılamayan/tekil gibi davranan bir isimdir. Bu yüzden "there isn\'t any milk" deriz.'),
    ],
  ),
  'a1_articles': GrammarLesson(
    bigTitle: 'Articles: a / an / the',
    oneLineGoal: 'Genel bir şey ile belirli bir şeyi ayır.',
    timeLabel: '8 dk',
    teacherIntro:
        'A/an "herhangi bir tane" gibi düşünülebilir. The ise konuşan ve dinleyen hangi şeyden bahsettiğini biliyorsa kullanılır. a/an seçimi harfe değil sese bağlıdır: an hour deriz çünkü h okunmaz.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'a', pattern: 'a + consonant sound', sample: 'I have a pen.'),
      GrammarFormulaRow(
          label: 'an',
          pattern: 'an + vowel sound',
          sample: 'She has an umbrella.'),
      GrammarFormulaRow(
          label: 'the',
          pattern: 'the + specific/known noun',
          sample: 'The pen is blue.'),
      GrammarFormulaRow(
          label: 'No a/an with plural',
          pattern: 'plural noun without a/an',
          sample: 'I like apples.'),
    ],
    usageBullets: [
      'İlk kez/genel bir tekil isimde a/an kullan.',
      'Dinleyen hangi şey olduğunu biliyorsa the kullan.',
      'an sesli sesle başlayan kelimelerden önce gelir.',
    ],
    examples: [
      'This is a pen.',
      'It is an apple.',
      'The book is on the desk.',
      'I have a bag.',
      'She has an umbrella.',
      'This is a book.',
    ],
    wrong: 'I have book.',
    right: 'I have a book.',
    reason:
        'Book tekil sayılabilen bir isimdir. Genel anlamda bir tane kitap derken "a book" kullanılır.',
    task: 'a, an ve the ile 6 kısa cümle yaz.',
    modelAnswer:
        'I have a bag. She has an umbrella. The bag is black. He is a student. It is an old phone. The phone is mine.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_artq1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'She has _____ umbrella.',
          options: ['an', 'a', 'the', '-'],
          answer: 'an',
          explanation:
              'Umbrella sesli sesle başlar. Bu yüzden "an umbrella" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_artq2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I need _____ pen.',
          options: ['a', 'an', 'the', '-'],
          answer: 'a',
          explanation:
              'Pen sessiz sesle başlar ve tekil sayılabilen isimdir. Genel anlamda "a pen" deriz.'),
      GrammarQuizQuestion(
          id: 'a1_artq3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I saw a dog. _____ dog was black.',
          options: ['The', 'A', 'An', '-'],
          answer: 'The',
          explanation:
              'Dog ikinci kez geçiyor; artık hangi köpek olduğu biliniyor. Bu yüzden "the dog" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_artq4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'He is _____ engineer.',
          options: ['an', 'a', 'the', '-'],
          answer: 'an',
          explanation:
              'Engineer sesli sesle başlar. Meslek tekil olduğu için "an engineer" deriz.'),
      GrammarQuizQuestion(
          id: 'a1_artq5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I like _____ apples.',
          options: ['-', 'a', 'an', 'the a'],
          answer: '-',
          explanation:
              'Genel olarak çoğul isimden bahsederken a/an kullanılmaz: I like apples.'),
    ],
  ),
  'a1_singular_plural': GrammarLesson(
    bigTitle: 'Plural & Quantity Basics',
    oneLineGoal:
        'Tekil/çoğul isimleri ve some/any, much/many, a lot of miktarlarını doğru kullan.',
    timeLabel: '7 dk',
    teacherIntro:
        'Bir şey tekil, iki veya daha fazlası çoğuldur. İngilizcede sayı söylendiyse isim de çoğul olmalıdır: two books. Türkçedeki "iki kitap" mantığı seni yanıltabilir; İngilizcede bookS gerekir.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Regular plural', pattern: 'noun + -s', sample: 'two books'),
      GrammarFormulaRow(
          label: '-es plural',
          pattern: 'box/watch/bus + -es',
          sample: 'three boxes'),
      GrammarFormulaRow(
          label: 'y changes', pattern: 'city -> cities', sample: 'two cities'),
      GrammarFormulaRow(
          label: 'Irregular',
          pattern: 'child -> children / person -> people',
          sample: 'three children'),
      GrammarFormulaRow(
          label: 'Some / any',
          pattern: 'some in positives / any in negatives and questions',
          sample: 'There is some milk. Are there any eggs?'),
      GrammarFormulaRow(
          label: 'Much / many / a lot of',
          pattern: 'many + countable plural / much + uncountable',
          sample: 'many apples, much water, a lot of books'),
    ],
    usageBullets: [
      'Birden fazla sayılabilen isim çoğul olur.',
      's, x, ch, sh ile biten bazı isimler -es alır.',
      'a/an çoğul isimle kullanılmaz.',
      'Olumlu cümlede some; soru ve olumsuzda çoğunlukla any kullan.',
      'Sayılabilen çoğullarla many, sayılamayan isimlerle much kullan.',
      'A lot of hem sayılabilen hem sayılamayan isimlerle genelde güvenli bir seçenektir.',
    ],
    examples: [
      'This is one apple.',
      'These are two apples.',
      'I have one book.',
      'We have three books.',
      'The child is happy.',
      'The children are happy.',
    ],
    wrong: 'I have two book.',
    right: 'I have two books.',
    reason: 'Two birden fazla demektir. Sayılabilen isim çoğul olur: books.',
    task: 'Tekil/çoğul isimler ve miktar kelimeleriyle 8 kısa örnek yaz.',
    modelAnswer:
        'one book, two books; one box, three boxes; one city, two cities; one child, two children.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_plural_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I have two _____.',
          options: ['books', 'book', 'a book', 'bookes'],
          answer: 'books',
          explanation: 'Two sonrasında sayılabilen isim çoğul olur: books.'),
      GrammarQuizQuestion(
          id: 'a1_plural_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'There are three _____ on the table.',
          options: ['boxes', 'box', 'boxs', 'a box'],
          answer: 'boxes',
          explanation: 'Box kelimesi çoğulda -es alır: boxes.'),
      GrammarQuizQuestion(
          id: 'a1_plural_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I have one _____.',
          options: ['child', 'children', 'childs', 'a children'],
          answer: 'child',
          explanation: 'One tekildir. Bu yüzden "child" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_plural_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'There are five _____ in the class.',
          options: ['children', 'child', 'childs', 'childrens'],
          answer: 'children',
          explanation:
              'Child düzensiz çoğuldur: children. "childs" yanlıştır.'),
      GrammarQuizQuestion(
          id: 'a1_plural_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'These _____ are new.',
          options: ['bags', 'bag', 'a bag', 'bag is'],
          answer: 'bags',
          explanation:
              'These çoğul gösterir. Bu yüzden isim de çoğul olur: bags.'),
    ],
  ),
  'a1_present_simple': GrammarLesson(
    bigTitle: 'Present Simple',
    oneLineGoal:
        'Rutin, alışkanlık ve genel gerekleri olumlu, olumsuz ve soru halinde kullan.',
    timeLabel: '10 dk',
    teacherIntro:
        'Present Simple sadece "olumlu cümle" değildir; tam bir ders olarak olumlu, olumsuz, soru ve kısa cevapları birlikte bilmen gerekir. En kritik nokta: he/she/it olumlu cümlede -s alır ama does/doesn\'t geldiyse ana fiil yalın kalır.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'I/You/We/They + V1 | He/She/It + V-s/es',
          sample: 'She works every day.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'I/You/We/They + don\'t + V1 | He/She/It + doesn\'t + V1',
          sample: 'He doesn\'t like coffee.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Do/Does + subject + V1?',
          sample: 'Does she live here?'),
      GrammarFormulaRow(
          label: 'Short answers',
          pattern: 'Yes, I do. / No, she doesn\'t.',
          sample: 'No, she doesn\'t.'),
      GrammarFormulaRow(
          label: 'Time words',
          pattern: 'always, usually, often, sometimes, every day',
          sample: 'I usually study at night.'),
      GrammarFormulaRow(
          label: 'Wh- questions',
          pattern: 'Where/When/What + do/does + subject + V1?',
          sample: 'Where do you live?'),
      GrammarFormulaRow(
          label: 'Likes',
          pattern: 'like/love/hate + noun or V-ing',
          sample: 'I like music. She loves swimming.'),
    ],
    usageBullets: [
      'Rutin: I get up at seven.',
      'Alışkanlık: She drinks tea.',
      'Genel gerek: Water boils at 100 degörees.',
      'Sıklık zarfları genelde ana fiilden önce gelir: I usually study.',
      'Bilgi sorusunda wh-word + do/does kullan: Where do you live?',
      'Like/love/hate sonrasında isim veya -ing kullanabilirsin.',
      'Does/doesn\'t varsa ana fiile -s ekleme.',
    ],
    examples: [
      'I like tea.',
      'You play football.',
      'He goes to school.',
      'She watches TV every evening.',
      'We study English.',
      'Do you drink tea?',
    ],
    wrong: 'She doesn\'t likes coffee.',
    right: 'She doesn\'t like coffee.',
    reason:
        'Doesn\'t zaten he/she/it bilgisini taşır. Bu yüzden ana fiil yalın kalır: like.',
    task:
        'Kendi rutinin hakkında sıklık zarfı, wh-sorusu ve like/love/hate içeren 8 cümle yaz.',
    modelAnswer:
        'I get up early. I drink tea. I don\'t watch TV in the morning. My sister studies English. She doesn\'t like coffee. Does she work? Yes, she does. Do you study every day?',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_ps_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'She _____ to school every day.',
          options: ['goes', 'go', 'going', 'is go'],
          answer: 'goes',
          explanation:
              'She ile Present Simple olumlu cümlede fiile -s/-es gelir: goes.'),
      GrammarQuizQuestion(
          id: 'a1_ps_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'They _____ football on Sundays.',
          options: ['play', 'plays', 'playing', 'is play'],
          answer: 'play',
          explanation:
              'They ile fiil yalın kalır. -s sadece he/she/it olumlu cümlede gelir.'),
      GrammarQuizQuestion(
          id: 'a1_ps_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'He _____ like milk.',
          options: ["doesn't", "don't", "isn't", "aren't"],
          answer: "doesn't",
          explanation: 'He ile olumsuz Present Simple: doesn\'t + V1.'),
      GrammarQuizQuestion(
          id: 'a1_ps_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ you live near here?',
          options: ['Do', 'Does', 'Are', 'Is'],
          answer: 'Do',
          explanation: 'You ile Present Simple sorusunda "Do" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_ps_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ she work in a bank?',
          options: ['Does', 'Do', 'Is', 'Are'],
          answer: 'Does',
          explanation:
              'She ile Present Simple sorusunda "Does" kullanılır; ana fiil yalın kalır: work.'),
      GrammarQuizQuestion(
          id: 'a1_ps_q6',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'No, she _____.',
          options: ["doesn't", "don't", "isn't", "does"],
          answer: "doesn't",
          explanation:
              'Does ile sorulan Present Simple soruya olumsuz kısa cevap: No, she doesn\'t.'),
    ],
  ),
  'a1_present_continuous': GrammarLesson(
    bigTitle: 'Present Continuous',
    oneLineGoal: 'Şu anda veya şu sıralar olan eylemleri anlat.',
    timeLabel: '9 dk',
    teacherIntro:
        'Present Continuous için iki para gerekir: am/is/are + V-ing. Türkçede "çalışıyorum" tek kelime gibi gelir ama İngilizcede "I am studying" deriz. Be fiilini unutmak en yaygın hatadır.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'subject + am/is/are + V-ing',
          sample: 'She is studying now.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'subject + am/is/are + not + V-ing',
          sample: 'They aren\'t sleeping.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Am/Is/Are + subject + V-ing?',
          sample: 'Are you listening?'),
      GrammarFormulaRow(
          label: 'Now markers',
          pattern: 'now, right now, at the moment, today',
          sample: 'I am working today.'),
    ],
    usageBullets: [
      'Şu anda olan eylem için kullan.',
      'Geçici durumlar için de kullanılabilir: I am staying with my aunt.',
      'V-ing öncesinde am/is/are olmak zorunda.',
      'Like, know, want gibi state verbler A1 seviyesinde genelde continuous kullanmaz.',
    ],
    examples: [
      'I am reading now.',
      'You are listening.',
      'He is playing football.',
      'She is cooking.',
      'They are studying.',
      'Are you coming?',
    ],
    wrong: 'She reading now.',
    right: 'She is reading now.',
    reason:
        'Present Continuous yapısı am/is/are + V-ing ister. She ile "is" kullanılır.',
    task: 'Şu anda olan 6 eylem yaz.',
    modelAnswer:
        'I am studying now. My mother is cooking. My brother is watching TV. We are sitting in the living room. My friends are playing football. I am not sleeping.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_pc_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'She _____ reading now.',
          options: ['is', 'are', 'am', 'does'],
          answer: 'is',
          explanation:
              'She ile Present Continuous yapısında "is + V-ing" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_pc_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'They _____ watching TV.',
          options: ['are', 'is', 'am', 'do'],
          answer: 'are',
          explanation: 'They ile be fiili "are" olur: They are watching TV.'),
      GrammarQuizQuestion(
          id: 'a1_pc_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I _____ studying English.',
          options: ['am', 'is', 'are', 'do'],
          answer: 'am',
          explanation: 'I ile Present Continuous: I am + V-ing.'),
      GrammarQuizQuestion(
          id: 'a1_pc_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'He is _____ for the bus.',
          options: ['waiting', 'wait', 'waits', 'to wait'],
          answer: 'waiting',
          explanation: 'Be fiilinden sonra eylem -ing alır: is waiting.'),
      GrammarQuizQuestion(
          id: 'a1_pc_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ you listening?',
          options: ['Are', 'Is', 'Do', 'Does'],
          answer: 'Are',
          explanation:
              'Present Continuous sorusunda be fiili başa gelir. You ile "Are" kullanılır.'),
    ],
  ),
  'a1_can_cant': GrammarLesson(
    bigTitle: "Can / Can't",
    oneLineGoal: 'Yetenek, izin ve rica cümleleri kur.',
    timeLabel: '8 dk',
    teacherIntro:
        'Can\'den sonra fiil her zaman yalın halde gelir. Türkçede "yüzebilir" derken fiil değişiyor gibi hissedebilirsin ama İngilizcede "can swim" deriz. "can swims" veya "can to swim" yanlıştır.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'subject + can + V1',
          sample: 'I can swim.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'subject + can\'t/cannot + V1',
          sample: 'She can\'t drive.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Can + subject + V1?',
          sample: 'Can you help me?'),
      GrammarFormulaRow(
          label: 'Short answers',
          pattern: 'Yes, I can. / No, I can\'t.',
          sample: 'No, she can\'t.'),
    ],
    usageBullets: [
      'Yetenek: I can swim.',
      'Rica: Can you open the door?',
      'İzin: Can I sit here?',
      'Can sonrasında to, -s, -ing kullanma.',
    ],
    examples: [
      'I can swim.',
      'She can sing.',
      'He can ride a bike.',
      'We can speak English.',
      'I can\'t fly.',
      'Can you help me?',
    ],
    wrong: 'She can swims.',
    right: 'She can swim.',
    reason:
        'Can\'den sonra fiil yalın halde gelir. She olsa bile fiile -s eklemiyoruz.',
    task: 'Yetenek, rica ve izin içeren 6 can/can\'t cümlesi yaz.',
    modelAnswer:
        'I can swim. I can\'t drive. My sister can sing. Can you help me? Can I sit here? No, you can\'t.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_can_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'She can _____ English.',
          options: ['speak', 'speaks', 'to speak', 'speaking'],
          answer: 'speak',
          explanation:
              'Can\'den sonra fiil yalın halde gelir: can speak. "speaks" veya "to speak" kullanılmaz.'),
      GrammarQuizQuestion(
          id: 'a1_can_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'He _____ swim.',
          options: ["can't", "doesn't", "isn't", "don't"],
          answer: "can't",
          explanation:
              'Can yapısının olumsuzu "can\'t/cannot" olur. Do/does kullanılmaz.'),
      GrammarQuizQuestion(
          id: 'a1_can_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ you help me?',
          options: ['Can', 'Do', 'Are', 'Does'],
          answer: 'Can',
          explanation:
              'Rica sorusunda "Can + subject + V1?" kullanılır: Can you help me?'),
      GrammarQuizQuestion(
          id: 'a1_can_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'No, I _____.',
          options: ["can't", "don't", "am not", "doesn't"],
          answer: "can't",
          explanation:
              'Can ile sorulan soruya kısa cevap yine can/can\'t ile verilir.'),
      GrammarQuizQuestion(
          id: 'a1_can_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Can I _____ here?',
          options: ['sit', 'sits', 'to sit', 'sitting'],
          answer: 'sit',
          explanation: 'İzin isterken Can I + V1 kullanılır: Can I sit here?'),
    ],
  ),
  'a1_have_has_got': GrammarLesson(
    bigTitle: 'Have got / Has got',
    oneLineGoal: 'Sahiplik ve aile/iliİkiler için have got kullan.',
    timeLabel: '8 dk',
    teacherIntro:
        'Have got A1 seviyesinde sahiplik için çok doğaldır. I/you/we/they ile have got, he/she/it ile has got kullanılır. Soru yaparken have/has başa gelir: Have you got...?',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'I/You/We/They + have got | He/She/It + has got',
          sample: 'She has got a brother.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'haven\'t got / hasn\'t got',
          sample: 'I haven\'t got a car.'),
      GrammarFormulaRow(
          label: 'Question',
          pattern: 'Have/Has + subject + got?',
          sample: 'Have you got a pen?'),
      GrammarFormulaRow(
          label: 'Short answers',
          pattern: 'Yes, I have. / No, she hasn\'t.',
          sample: 'No, she hasn\'t.'),
    ],
    usageBullets: [
      'Sahiplik: I have got a bike.',
      'Aile: She has got a brother.',
      'He/she/it ile has got kullan.',
      'Kısa cevapta got tekrar edilmez: Yes, I have.',
    ],
    examples: [
      'I have got a car.',
      'You have got a phone.',
      'He has got a brother.',
      'She has got a cat.',
      'They have got a house.',
      'Have you got a pen?',
    ],
    wrong: 'She have got a brother.',
    right: 'She has got a brother.',
    reason:
        'She ile "has got" kullanılır. Have got I/you/we/they ile kullanılır.',
    task: 'Sahip olduğun ve sahip olmadığın şeylerle ilgili 6 cümle yaz.',
    modelAnswer:
        'I have got a phone. I have got a bike. I haven\'t got a car. My sister has got a cat. She hasn\'t got a dog. Have you got a pen?',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_have_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'She _____ got a brother.',
          options: ['has', 'have', 'is', 'does'],
          answer: 'has',
          explanation: 'She ile "has got" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_have_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'I _____ got a bike.',
          options: ['have', 'has', 'am', 'do'],
          answer: 'have',
          explanation: 'I ile "have got" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_have_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'He _____ got a car.',
          options: ["hasn't", "haven't", "isn't", "don't"],
          answer: "hasn't",
          explanation: 'He ile olumsuz "hasn\'t got" olur.'),
      GrammarQuizQuestion(
          id: 'a1_have_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ you got a pen?',
          options: ['Have', 'Has', 'Do', 'Are'],
          answer: 'Have',
          explanation: 'You ile soru "Have you got...?" şeklindedir.'),
      GrammarQuizQuestion(
          id: 'a1_have_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'No, she _____.',
          options: ["hasn't", "haven't", "isn't", "doesn't"],
          answer: "hasn't",
          explanation:
              'Has ile sorulan soruya olumsuz kısa cevap: No, she hasn\'t.'),
    ],
  ),
  'a1_basic_prepositions': GrammarLesson(
    bigTitle: 'Basic Prepositions: in / on / at',
    oneLineGoal: 'in, on, at ile temel yer ve zaman ifadeleri kur.',
    timeLabel: '8 dk',
    teacherIntro:
        'Türkçede in, on, at bazen aynı eklerle çevrilebilir; ama İngilizcede kullanımları farklıdır. In genelde bir alanın içinde olmayı, on bir yüzeyin üstünde olmayı, at ise belirli bir nokta veya saati anlatır.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Place: in',
          pattern: 'in + enclosed place',
          sample: 'The keys are in the bag.'),
      GrammarFormulaRow(
          label: 'Place: on',
          pattern: 'on + surface',
          sample: 'The book is on the table.'),
      GrammarFormulaRow(
          label: 'Place/time: at',
          pattern: 'at + point / clock time',
          sample: 'The lesson starts at seven.'),
      GrammarFormulaRow(
          label: 'Time basics',
          pattern: 'in months/years, on days, at times',
          sample: 'on Monday, in May, at 8 o\'clock'),
    ],
    usageBullets: [
      'in: bir alanın içinde veya ay/yıl gibi geniş zaman.',
      'on: yüzey üstünde veya günlerde.',
      'at: belirli nokta ve saatlerde.',
      'Türkçeden birebir çevirmek yerine durumu hayal et.',
    ],
    examples: [
      'The book is on the table.',
      'The cat is under the chair.',
      'The bag is in the room.',
      'The school is next to the park.',
      'The pen is near the book.',
      'The keys are in the bag.',
    ],
    wrong: 'We meet in Monday.',
    right: 'We meet on Monday.',
    reason:
        'Gün isimleriyle "on" kullanılır: on Monday, on Friday. "in Monday" yanlıştır.',
    task: 'in, on, at ile 9 kısa yer/zaman cümlesi yaz.',
    modelAnswer:
        'The phone is in my bag. The book is on the desk. I am at home. We meet on Monday. The lesson starts at eight. My birthday is in June.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_prep_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'The book is _____ the table.',
          options: ['on', 'in', 'at', 'to'],
          answer: 'on',
          explanation: 'Yüzey üstünde olduğu için "on the table" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_prep_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'The keys are _____ my bag.',
          options: ['in', 'on', 'at', 'to'],
          answer: 'in',
          explanation: 'Bir şeyin içindeyse "in" kullanılır: in my bag.'),
      GrammarQuizQuestion(
          id: 'a1_prep_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'The lesson starts _____ seven.',
          options: ['at', 'on', 'in', 'for'],
          answer: 'at',
          explanation: 'Saatlerde "at" kullanılır: at seven.'),
      GrammarQuizQuestion(
          id: 'a1_prep_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'We meet _____ Monday.',
          options: ['on', 'in', 'at', 'to'],
          answer: 'on',
          explanation: 'Günlerde "on" kullanılır: on Monday.'),
      GrammarQuizQuestion(
          id: 'a1_prep_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'My birthday is _____ May.',
          options: ['in', 'on', 'at', 'to'],
          answer: 'in',
          explanation: 'Ay isimleriyle "in" kullanılır: in May.'),
    ],
  ),
  'a1_imperatives': GrammarLesson(
    bigTitle: 'Imperatives',
    oneLineGoal: 'Komut, yönerge, uyarı ve kibar rica cümleleri kur.',
    timeLabel: '7 dk',
    teacherIntro:
        'Imperative cümlede genelde özne söylenmez; cümle yalın fiille başlar. "Open the door" deriz. Daha kibar yapmak için please ekleyebilirsin. Olumsuz emir için Don\'t + V1 kullanılır.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Positive',
          pattern: 'base verb + object',
          sample: 'Open the door.'),
      GrammarFormulaRow(
          label: 'Polite',
          pattern: 'Please + base verb',
          sample: 'Please sit down.'),
      GrammarFormulaRow(
          label: 'Negative',
          pattern: 'Don\'t + base verb',
          sample: 'Don\'t run.'),
      GrammarFormulaRow(
          label: 'Classroom',
          pattern: 'Listen / Look / Repeat / Write',
          sample: 'Listen carefully.'),
    ],
    usageBullets: [
      'Talimat ve komutlarda yalın fiille başla.',
      'Please cümleyi daha kibar yapar.',
      'Olumsuz emir: Don\'t + V1.',
      'Genelde you yazmaya gerek yoktur.',
    ],
    examples: [
      'Open the door.',
      'Close your book.',
      'Listen to me.',
      'Don\'t run.',
      'Please sit down.',
      'Write your name.',
    ],
    wrong: 'You open the door, please.',
    right: 'Open the door, please.',
    reason:
        'Imperative cümle genelde yalın fiille başlar. Özne "you" çoğu durumda söylenmez.',
    task: 'Sınıfta veya günlük hayatta kullanılacak 6 imperative yaz.',
    modelAnswer:
        'Open the window. Please sit down. Listen carefully. Don\'t run. Don\'t be late. Write your name.',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_imp_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ the door, please.',
          options: ['Open', 'Opens', 'Opening', 'You open'],
          answer: 'Open',
          explanation: 'Imperative cümle yalın fiille başlar: Open the door.'),
      GrammarQuizQuestion(
          id: 'a1_imp_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Please _____ down.',
          options: ['sit', 'sits', 'sitting', 'to sit'],
          answer: 'sit',
          explanation:
              'Please sonrasında yalın fiil kullanılır: Please sit down.'),
      GrammarQuizQuestion(
          id: 'a1_imp_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ run in the classroom.',
          options: ["Don't", "Doesn't", "Isn't", "Aren't"],
          answer: "Don't",
          explanation: 'Olumsuz emir için "Don\'t + V1" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_imp_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ carefully.',
          options: ['Listen', 'Listens', 'Listening', 'To listen'],
          answer: 'Listen',
          explanation:
              'Ynerge verirken fiil yalın halde kullanılır: Listen carefully.'),
      GrammarQuizQuestion(
          id: 'a1_imp_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: "Don't _____ late.",
          options: ['be', 'is', 'are', 'to be'],
          answer: 'be',
          explanation:
              'Don\'t sonrasında fiil yalın olur. Be fiili de yalın halde "be" kalır.'),
    ],
  ),
  'a1_demonstratives': GrammarLesson(
    bigTitle: 'This / That / These / Those',
    oneLineGoal: 'Yakın/uzak ve tekil/çoğul nesneleri göster.',
    timeLabel: '8 dk',
    teacherIntro:
        'This ve these yakındaki şeyler içindir; that ve those uzaktaki şeyler içindir. This/that tekil, these/those çoğuldur. En sık hata: these ile is veya this ile are kullanmaktır.',
    formulaRows: [
      GrammarFormulaRow(
          label: 'Near singular',
          pattern: 'This is + singular noun',
          sample: 'This is my phone.'),
      GrammarFormulaRow(
          label: 'Far singular',
          pattern: 'That is + singular noun',
          sample: 'That is your bag.'),
      GrammarFormulaRow(
          label: 'Near plural',
          pattern: 'These are + plural noun',
          sample: 'These are my keys.'),
      GrammarFormulaRow(
          label: 'Far plural',
          pattern: 'Those are + plural noun',
          sample: 'Those are my shoes.'),
      GrammarFormulaRow(
          label: 'Questions',
          pattern: 'Is this/that...? Are these/those...?',
          sample: 'Are those your shoes?'),
    ],
    usageBullets: [
      'Yakındaki tekil: this.',
      'Uzaktaki tekil: that.',
      'Yakındaki çoğul: these.',
      'Uzaktaki çoğul: those.',
    ],
    examples: [
      'This is my book.',
      'That is your bag.',
      'These are my pens.',
      'Those are her shoes.',
      'This is a small room.',
      'Are those your books?',
    ],
    wrong: 'These is my keys.',
    right: 'These are my keys.',
    reason:
        'These çoğuldur. Bu yüzden be fiili "are" olur ve isim de çoğul kalır.',
    task: 'Etrafındaki yakın/uzak eşyalar için 8 demonstrative cümlesi yaz.',
    modelAnswer:
        'This is my pen. That is your bag. These are my books. Those are her shoes. Is this your phone? Are those your keys?',
    quiz: [
      GrammarQuizQuestion(
          id: 'a1_dem_q1',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ is my phone here.',
          options: ['This', 'These', 'Those', 'They'],
          answer: 'This',
          explanation: 'Phone tekil ve yakında. Bu yüzden "this" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_dem_q2',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ are my keys here.',
          options: ['These', 'This', 'That', 'It'],
          answer: 'These',
          explanation: 'Keys çoğul ve yakında. Bu yüzden "these" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_dem_q3',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ is your bag over there.',
          options: ['That', 'These', 'This', 'They'],
          answer: 'That',
          explanation: 'Bag tekil ve uzakta. Bu yüzden "that" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_dem_q4',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: '_____ are my shoes over there.',
          options: ['Those', 'That', 'This', 'It'],
          answer: 'Those',
          explanation: 'Shoes çoğul ve uzakta. Bu yüzden "those" kullanılır.'),
      GrammarQuizQuestion(
          id: 'a1_dem_q5',
          type: GrammarQuizType.fillBlank,
          prompt: 'Boşluğu doldur.',
          sentence: 'Are _____ your books?',
          options: ['these', 'this', 'that', 'it'],
          answer: 'these',
          explanation:
              'Books çoğul olduğu için "these" veya "those" gerekir. Burada yakın anlam için "these" doğru.'),
    ],
  ),
};
