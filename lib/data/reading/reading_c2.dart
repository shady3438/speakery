import 'package:flutter/material.dart';

import 'reading_models.dart';

/// C2 Reading data.
/// Content rules:
/// - 800–1200 words target, but initial seed lessons may stay slightly shorter
///   during prototype phase.
/// - native-density essays with nuance, compression, irony, register shifts,
///   implicit stance, and culturally aware argument.
/// - English-only by default; Turkish support is minimal and strategic.

const List<ReadingCluster> readingC2Clusters = [
  ReadingCluster(
    id: 'c2_language_power_and_culture',
    level: ReadingLevel.c2,
    title: 'Language, Power & Culture',
    subtitle:
        'Dense essays on modern life, public language, and hidden assumptions.',
    icon: Icons.auto_awesome_rounded,
    lessons: [
      ReadingLesson(
        id: 'c2_the_pleasure_of_being_wrong',
        level: ReadingLevel.c2,
        clusterId: 'c2_language_power_and_culture',
        title: 'The Pleasure of Being Wrong',
        subtitle:
            'A literary essay on certainty, humility, and intellectual freedom',
        icon: Icons.psychology_rounded,
        estimatedMinutes: 20,
        textType: 'literary essay',
        orientationEnglish:
            'In this text, you will read a dense essay about why being wrong can be intellectually and emotionally valuable.',
        orientationTurkish:
            'Bu metinde yanılmanın entelektüel ve duygusal değeri üzerine yoğun bir deneme okuyacaksın.',
        readingTipTurkish:
            'C2 metinlerde yazarın açıkça söylediği kadar ima ettiği şeyleri de takip et. Irony, concession ve metaphor kritik olabilir.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'There is a peculiar relief in discovering that one has been wrong. The moment is rarely pleasant at first: it may arrive dressed as embarrassment, disappointment, or the sudden collapse of a confidently held opinion. Yet beneath the bruise to pride there is often a quieter sensation, almost luxurious in its clarity. The world has not become smaller because a belief has failed; it has become less obedient, which is to say, more real.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Modern public life has made certainty strangely theatrical. Opinions are not merely held; they are displayed, defended, packaged, and performed. To change one’s mind, especially in front of others, can feel like an admission not simply of error but of weakness. As a result, people often continue defending ideas long after those ideas have stopped convincing even themselves. The performance outlives the belief.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'This is unfortunate, because being wrong is one of the few experiences that can genuinely expand the self. Agreement may comfort us, and success may reward us, but error interrupts us. It introduces a crack through which other possibilities enter. A person who has never been forced to revise a judgement may possess confidence, but it is the confidence of a locked room: secure, undisturbed, and poorly ventilated.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'Of course, not every mistake is noble. Some errors are careless, some are harmful, and some are merely repetitive. There is no virtue in refusing evidence and later celebrating the correction as growth. The pleasure of being wrong depends on a particular posture: the willingness to let reality answer back. It requires enough seriousness to care about truth and enough lightness not to confuse one’s identity with every opinion one happens to hold.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'Children often understand this better than adults. They can be corrected and then, after a brief protest, return to the activity itself. Adults, by contrast, frequently build small monuments to their conclusions. We decorate them with reasons, defend them with anecdotes, and invite others to admire their stability. Eventually, dismantling the monument feels like destroying a part of ourselves, even when the original structure was badly built.',
          ),
          ReadingParagraph(
            number: 6,
            text:
                'The most interesting minds are not those that avoid error but those that metabolise it. They do not treat correction as humiliation but as contact with the world. To be wrong, then, is not simply to lose an argument; it is to be reminded that thought is alive. A mind incapable of embarrassment may look strong from a distance, but it is often only rigid. The freer mind is the one that can blush, laugh, alter course, and continue.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'peculiar',
            meaningEnglish: 'strange or distinctive in a noticeable way',
            meaningTurkish: 'kendine özgü / tuhaf',
            example:
                'There is a peculiar relief in discovering that one has been wrong.',
          ),
          ReadingGloss(
            word: 'theatrical',
            meaningEnglish: 'performed dramatically, often for public effect',
            meaningTurkish: 'sahneye konmuş gibi / gösterişli',
            example:
                'Modern public life has made certainty strangely theatrical.',
          ),
          ReadingGloss(
            word: 'metabolise',
            meaningEnglish:
                'process and transform something into energy, insight, or growth',
            meaningTurkish: 'özümsemek / dönüştürmek',
            example:
                'The most interesting minds are not those that avoid error but those that metabolise it.',
          ),
          ReadingGloss(
            word: 'rigid',
            meaningEnglish: 'stiff, fixed, and unwilling to change',
            meaningTurkish: 'katı / esnek olmayan',
            example:
                'A mind incapable of embarrassment may look strong, but it is often only rigid.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c2_wrong_q1',
            type: ReadingQuestionType.mainIdea,
            question:
                'Which statement best captures the essay’s central claim?',
            options: [
              'Being wrong can be valuable when it leads to intellectual openness and contact with reality',
              'People should deliberately make careless mistakes in order to appear humble',
              'Public disagreement is always more useful than private reflection',
              'Certainty is impossible, so every opinion should be abandoned immediately',
            ],
            answer:
                'Being wrong can be valuable when it leads to intellectual openness and contact with reality',
            explanationEnglish:
                'The essay argues that error can expand the self when it is met with seriousness, humility, and willingness to revise.',
            explanationTurkish:
                'Metin, yanılmanın ciddiyet ve esneklikle karşılandığında kişiyi genişletebileceğini savunuyor.',
          ),
          ReadingQuestion(
            id: 'c2_wrong_q2',
            type: ReadingQuestionType.inference,
            question:
                'What does the phrase “The performance outlives the belief” imply?',
            options: [
              'People may continue defending views they no longer truly find convincing',
              'Public speakers always believe everything they say',
              'Theatre is a better guide to truth than argument',
              'Beliefs become stronger when performed publicly',
            ],
            answer:
                'People may continue defending views they no longer truly find convincing',
            explanationEnglish:
                'The previous sentence explains that people defend ideas even after those ideas have stopped convincing them.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_wrong_q3',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In paragraph 3, the metaphor of “a locked room” suggests confidence that is ____.',
            options: [
              'secure but intellectually closed',
              'dangerous but socially generous',
              'publicly admired and flexible',
              'temporary but emotionally healthy',
            ],
            answer: 'secure but intellectually closed',
            explanationEnglish:
                'The room is secure and undisturbed, but poorly ventilated, suggesting closed confidence without fresh ideas.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c2_wrong_q4',
            type: ReadingQuestionType.inference,
            question:
                'Why does the writer include the concession “not every mistake is noble”?',
            options: [
              'To avoid romanticising error and clarify the conditions under which being wrong is valuable',
              'To argue that most mistakes should be ignored',
              'To suggest that careless mistakes are the highest form of learning',
              'To weaken the entire argument beyond recovery',
            ],
            answer:
                'To avoid romanticising error and clarify the conditions under which being wrong is valuable',
            explanationEnglish:
                'The writer distinguishes valuable correction from careless or harmful error, strengthening the argument through nuance.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c2_wrong_q5',
            type: ReadingQuestionType.detail,
            question:
                'According to paragraph 4, what attitude is necessary for the pleasure of being wrong?',
            options: [
              'A willingness to let reality answer back',
              'A refusal to care about truth',
              'A desire to win arguments publicly',
              'A habit of changing opinions randomly',
            ],
            answer: 'A willingness to let reality answer back',
            explanationEnglish:
                'The paragraph states this directly as the necessary posture.',
            evidenceParagraph: 4,
            evidenceText:
                'The pleasure of being wrong depends on a particular posture: the willingness to let reality answer back.',
          ),
          ReadingQuestion(
            id: 'c2_wrong_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'The monuments adults build around their conclusions',
              'Why children never resist correction',
              'The scientific method in childhood education',
              'The disappearance of public disagreement',
            ],
            answer: 'The monuments adults build around their conclusions',
            explanationEnglish:
                'The paragraph uses the metaphor of adults building monuments to their conclusions and struggling to dismantle them.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'c2_wrong_q7',
            type: ReadingQuestionType.inference,
            question:
                'What quality does the writer most admire in “the freer mind”?',
            options: [
              'The capacity to revise itself without treating correction as destruction',
              'The ability to avoid embarrassment entirely',
              'The refusal to take truth seriously',
              'The skill of winning arguments through confidence',
            ],
            answer:
                'The capacity to revise itself without treating correction as destruction',
            explanationEnglish:
                'The final paragraph praises minds that can blush, laugh, alter course, and continue.',
            evidenceParagraph: 6,
          ),
          ReadingQuestion(
            id: 'c2_wrong_q8',
            type: ReadingQuestionType.inference,
            question: 'What is the overall tone of the essay?',
            options: [
              'Reflective, ironic, and gently corrective',
              'Purely technical and impersonal',
              'Angry and accusatory throughout',
              'Playful but intellectually empty',
            ],
            answer: 'Reflective, ironic, and gently corrective',
            explanationEnglish:
                'The essay uses metaphor, irony, and reflection to challenge public certainty without becoming hostile.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'humiliation',
            originalSentence:
                'They do not treat correction as humiliation but as contact with the world.',
            newExampleSentence:
                'A good learning environment separates correction from humiliation.',
            meaningEnglish: 'a feeling of shame or loss of dignity',
            meaningTurkish: 'aşağılanma / küçük düşme',
          ),
        ],
        reflectionPrompt:
            'When was the last time changing your mind improved your understanding of something?',
        reflectionPromptTurkish:
            'Fikrini değiştirmen en son ne zaman bir şeyi daha iyi anlamanı sağladı?',
      ),
      ReadingLesson(
        id: 'c2_against_nostalgia',
        level: ReadingLevel.c2,
        clusterId: 'c2_language_power_and_culture',
        title: 'Against Nostalgia',
        subtitle: 'A critical essay on memory, politics, and the imagined past',
        icon: Icons.history_edu_rounded,
        estimatedMinutes: 21,
        textType: 'critical essay',
        orientationEnglish:
            'In this text, you will read a critical essay about nostalgia and its influence on public imagination.',
        orientationTurkish:
            'Bu metinde nostaljinin toplumsal hayal gücü ve kamusal söylem üzerindeki etkisine dair eleştirel bir deneme okuyacaksın.',
        readingTipTurkish:
            'C2 eleştirel metinlerde yazarın hedef aldığı “görünüşte masum” kavramı bul: burada nostalgia sadece duygu değil, politik bir araç gibi inceleniyor.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Nostalgia is often defended as a harmless tenderness toward the past: an old song, a childhood street, the smell of bread from a shop that no longer exists. In this private form, it may be gentle and even necessary. Human beings need continuity; without some affection for what has been lost, memory becomes merely administrative. Yet nostalgia becomes more dangerous when it moves from the private heart into public argument.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Public nostalgia rarely remembers the past in its full disorder. It edits. It brightens certain rooms and locks others. It preserves the music but forgets who was not allowed to dance. This selectiveness is not accidental; it is the mechanism by which nostalgia converts memory into desire. The past is not recovered but redesigned, made simpler so that the present can be accused of betrayal.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'The phrase “things were better then” often conceals more than it reveals. Better for whom? Better in what sense? Material comfort, social belonging, moral certainty, national pride, family structure: each can be invoked as if it belonged to everyone equally. But many golden ages shine only because certain people have been kept outside the frame. What appears as warmth to one group may have been suffocation to another.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'This does not mean that criticism of the present is illegitimate. A society that cannot admit decline in any form is as dishonest as one that invents perfection behind it. There are losses worth naming: loneliness in crowded cities, the commercialisation of attention, the disappearance of local memory, the speed with which work enters every corner of life. The problem begins when these real losses are used to manufacture an imaginary cure.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'Nostalgia offers emotional efficiency. It gathers scattered dissatisfaction and gives it a direction: backward. Unlike serious historical thinking, it does not ask what conditions produced a particular way of life or what injustices sustained it. It promises restoration without complexity. This is why nostalgic politics is so seductive. It allows people to feel critical, wounded, and hopeful without requiring them to imagine anything genuinely new.',
          ),
          ReadingParagraph(
            number: 6,
            text:
                'A better relationship with the past would be neither worship nor dismissal. We can inherit without obeying. We can grieve what has disappeared without pretending it was pure. We can learn from earlier forms of community while refusing the exclusions that accompanied them. The past should be a resource, not a residence. To live politically inside nostalgia is to mistake a museum for a map.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'administrative',
            meaningEnglish:
                'concerned only with records, organisation, or management rather than feeling',
            meaningTurkish: 'idari / duygudan arınmış kayıt gibi',
            example:
                'Without affection for what has been lost, memory becomes merely administrative.',
          ),
          ReadingGloss(
            word: 'suffocation',
            meaningEnglish:
                'a feeling of being unable to breathe or live freely',
            meaningTurkish: 'boğulma / sıkışmışlık',
            example:
                'What appears as warmth to one group may have been suffocation to another.',
          ),
          ReadingGloss(
            word: 'seductive',
            meaningEnglish: 'strongly attractive, often in a misleading way',
            meaningTurkish: 'baştan çıkarıcı / yanıltıcı biçimde çekici',
            example: 'This is why nostalgic politics is so seductive.',
          ),
          ReadingGloss(
            word: 'dismissal',
            meaningEnglish: 'rejection or refusal to take something seriously',
            meaningTurkish: 'yok sayma / ciddiye almama',
            example:
                'A better relationship with the past would be neither worship nor dismissal.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c2_nostalgia_q1',
            type: ReadingQuestionType.mainIdea,
            question:
                'What is the writer’s main criticism of public nostalgia?',
            options: [
              'It simplifies the past and uses selective memory as a public argument',
              'It makes people remember childhood too accurately',
              'It prevents all emotional connection to history',
              'It proves that the present is always better than the past',
            ],
            answer:
                'It simplifies the past and uses selective memory as a public argument',
            explanationEnglish:
                'The essay argues that public nostalgia edits the past, turns memory into desire, and offers restoration without complexity.',
          ),
          ReadingQuestion(
            id: 'c2_nostalgia_q2',
            type: ReadingQuestionType.inference,
            question:
                'What does “It preserves the music but forgets who was not allowed to dance” imply?',
            options: [
              'Nostalgia remembers attractive details while ignoring exclusion',
              'Music is the only reliable historical evidence',
              'Dancing was more common in the past than today',
              'The writer believes cultural memory is impossible',
            ],
            answer:
                'Nostalgia remembers attractive details while ignoring exclusion',
            explanationEnglish:
                'The metaphor criticises selective memory that celebrates pleasant aspects while ignoring who was excluded.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_nostalgia_q3',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In paragraph 2, “mechanism” is closest in meaning to ____.',
            options: [
              'the process by which something works',
              'a machine used in old buildings',
              'a personal childhood memory',
              'a form of musical performance',
            ],
            answer: 'the process by which something works',
            explanationEnglish:
                'The sentence explains how selectiveness converts memory into desire, so mechanism means process or working method.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_nostalgia_q4',
            type: ReadingQuestionType.inference,
            question:
                'Why does the writer ask “Better for whom?” in paragraph 3?',
            options: [
              'To expose the unequal assumptions behind claims of a golden age',
              'To request statistical data about economic growth',
              'To argue that nobody has ever experienced improvement',
              'To change the topic from memory to family structure',
            ],
            answer:
                'To expose the unequal assumptions behind claims of a golden age',
            explanationEnglish:
                'The paragraph challenges general claims about the past by asking whose experience is being centred.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c2_nostalgia_q5',
            type: ReadingQuestionType.detail,
            question:
                'Which present-day loss does the writer explicitly recognise as real?',
            options: [
              'The commercialisation of attention',
              'The complete disappearance of all families',
              'The impossibility of local memory',
              'The end of every form of community',
            ],
            answer: 'The commercialisation of attention',
            explanationEnglish:
                'Paragraph 4 lists the commercialisation of attention among real losses worth naming.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c2_nostalgia_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'The emotional efficiency of looking backward',
              'The scientific accuracy of nostalgic politics',
              'The disappearance of dissatisfaction',
              'The economic history of restoration',
            ],
            answer: 'The emotional efficiency of looking backward',
            explanationEnglish:
                'Paragraph 5 explains how nostalgia gathers dissatisfaction and directs it backward.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'c2_nostalgia_q7',
            type: ReadingQuestionType.inference,
            question:
                'What does the writer mean by “The past should be a resource, not a residence”?',
            options: [
              'We should learn from the past without trying to live inside it',
              'Historical buildings should be turned into public homes',
              'Private memory is more important than public history',
              'The past has nothing useful to offer modern societies',
            ],
            answer:
                'We should learn from the past without trying to live inside it',
            explanationEnglish:
                'The writer argues for inheritance without obedience and learning without nostalgic worship.',
            evidenceParagraph: 6,
          ),
          ReadingQuestion(
            id: 'c2_nostalgia_q8',
            type: ReadingQuestionType.inference,
            question:
                'What is the function of the final metaphor, “to mistake a museum for a map”?',
            options: [
              'It criticises treating preserved memory as a guide for future action',
              'It suggests that museums are more useful than political ideas',
              'It argues that maps are historically unreliable objects',
              'It praises nostalgia as the only way to organise society',
            ],
            answer:
                'It criticises treating preserved memory as a guide for future action',
            explanationEnglish:
                'A museum preserves the past, while a map guides movement; the metaphor warns against using nostalgia as political direction.',
            evidenceParagraph: 6,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'restoration',
            originalSentence: 'It promises restoration without complexity.',
            newExampleSentence:
                'Political slogans often promise restoration while ignoring why change happened.',
            meaningEnglish:
                'the act of bringing something back to an earlier condition',
            meaningTurkish: 'eski hâline döndürme / restorasyon',
          ),
        ],
        reflectionPrompt:
            'Can nostalgia be useful without becoming politically dangerous? Explain your position.',
        reflectionPromptTurkish:
            'Nostalji politik olarak tehlikeli olmadan faydalı olabilir mi? Görüşünü açıkla.',
      ),
      ReadingLesson(
        id: 'c2_efficiency_problem',
        level: ReadingLevel.c2,
        clusterId: 'c2_language_power_and_culture',
        title: 'When Efficiency Becomes a Problem',
        subtitle: 'A dense essay on speed, friction, and human judgement',
        icon: Icons.precision_manufacturing_rounded,
        estimatedMinutes: 18,
        textType: 'critical essay',
        orientationEnglish:
            'In this text, you will read a dense essay about efficiency and the value of certain forms of slowness.',
        orientationTurkish:
            'Bu metinde verimlilik ve bazı yavaşlık biçimlerinin değeri üzerine yoğun bir deneme okuyacaksın.',
        readingTipTurkish:
            'C2 metinlerde kavramın ters yüz edilmesine dikkat et: efficiency burada sadece olumlu bir değer değil, potansiyel bir problem olarak tartışılıyor.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Efficiency has the clean moral appeal of a word that seems to waste nothing. It promises fewer delays, fewer errors, fewer unnecessary gestures. In hospitals, transport systems, schools, and offices, efficiency can be genuinely humane: it can reduce waiting, save money, and prevent exhaustion. The danger begins when efficiency stops being a servant of human purposes and becomes the purpose itself.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Not every delay is a defect. Some forms of friction protect judgement. A pause before sending a message may prevent cruelty; a slow conversation may reveal what a survey cannot; a complicated application process may, in certain contexts, force institutions to look closely at a person rather than process them as a unit. Speed can clarify a system, but it can also erase the very details that make the system worth having.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'The cult of efficiency tends to dislike ambiguity because ambiguity is expensive. It requires attention, interpretation, and sometimes mercy. A perfectly efficient school might measure learning constantly and produce elegant charts, while neglecting curiosity. A perfectly efficient workplace might remove every idle conversation, only to discover that trust had been hiding inside those apparently unproductive minutes.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'This is not an argument for chaos or incompetence. Waste can be cruel too, especially when it steals time from people with little power. But a humane institution must distinguish between waste and meaningful slowness. The question is not simply “How can this be faster?” but “What might be lost if this becomes faster?” Efficiency is valuable when it clears space for human life; it is dangerous when it quietly redesigns life to fit the machine.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'This distinction becomes especially important when efficiency is treated as politically neutral. A faster system always benefits someone, but it may also shift costs onto those who are least able to refuse them: patients who cannot explain their symptoms inside a short appointment, students whose progress is too irregular for a dashboard, or workers whose informal care for colleagues disappears from official measurement. Meaningful slowness is not nostalgia for inconvenience. It is a recognition that certain human goods, such as trust, interpretation, forgiveness, and learning, are damaged when they are forced to justify themselves in the language of speed. The real test of efficiency is therefore not whether a process becomes leaner, but whether the people inside it become more capable of being seen, heard, and answered with care. Without that test, speed can become a polite name for neglect.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'friction',
            meaningEnglish:
                'difficulty or resistance that slows a process down',
            meaningTurkish: 'sürtünme / yavaşlatıcı direnç',
            example: 'Some forms of friction protect judgement.',
          ),
          ReadingGloss(
            word: 'ambiguity',
            meaningEnglish:
                'the state of having more than one possible meaning',
            meaningTurkish: 'belirsizlik / çok anlamlılık',
            example: 'Efficiency tends to dislike ambiguity.',
          ),
          ReadingGloss(
            word: 'humane',
            meaningEnglish:
                'showing care for human needs, dignity, and suffering',
            meaningTurkish: 'insancıl',
            example:
                'A humane institution must distinguish between waste and meaningful slowness.',
          ),
          ReadingGloss(
            word: 'incompetence',
            meaningEnglish: 'lack of ability to do something properly',
            meaningTurkish: 'yetersizlik / beceriksizlik',
            example: 'This is not an argument for chaos or incompetence.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c2_efficiency_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the essay’s central claim?',
            options: [
              'Efficiency is useful, but it becomes dangerous when it overrides human judgement',
              'Efficiency should be rejected in all institutions',
              'Slow systems are always more ethical than fast systems',
              'Human judgement is unnecessary when systems are well designed',
            ],
            answer:
                'Efficiency is useful, but it becomes dangerous when it overrides human judgement',
            explanationEnglish:
                'The writer repeatedly balances the real benefits of efficiency with the risk of losing judgement, ambiguity, and human detail.',
          ),
          ReadingQuestion(
            id: 'c2_efficiency_q2',
            type: ReadingQuestionType.inference,
            question:
                'What does the writer mean by saying efficiency has “clean moral appeal”?',
            options: [
              'It seems obviously good because it appears to remove waste',
              'It is morally pure in every possible situation',
              'It is mainly a religious concept',
              'It always makes institutions more compassionate',
            ],
            answer:
                'It seems obviously good because it appears to remove waste',
            explanationEnglish:
                'The phrase introduces the attractive simplicity of efficiency before the essay complicates it.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c2_efficiency_q3',
            type: ReadingQuestionType.detail,
            question: 'Which example of protective friction is mentioned?',
            options: [
              'A pause before sending a message',
              'A machine that never stops',
              'A chart that measures every second',
              'A workplace without conversation',
            ],
            answer: 'A pause before sending a message',
            explanationEnglish:
                'Paragraph 2 says such a pause may prevent cruelty.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_efficiency_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In paragraph 3, “ambiguity” is closest in meaning to ____.',
            options: [
              'uncertainty that requires interpretation',
              'a simple instruction',
              'a proven result',
              'a repeated routine',
            ],
            answer: 'uncertainty that requires interpretation',
            explanationEnglish:
                'The paragraph says ambiguity requires attention and interpretation.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c2_efficiency_q5',
            type: ReadingQuestionType.inference,
            question: 'Why does the writer mention idle conversations at work?',
            options: [
              'To show that trust may develop in moments that look unproductive',
              'To argue that workplaces should ban serious meetings',
              'To suggest that conversation always reduces trust',
              'To prove that efficiency has no workplace value',
            ],
            answer:
                'To show that trust may develop in moments that look unproductive',
            explanationEnglish:
                'The writer suggests trust may be hidden inside apparently unproductive minutes.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c2_efficiency_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 4?',
            options: [
              'Distinguishing waste from meaningful slowness',
              'Why all slow institutions are better',
              'The economic history of transport',
              'How to remove every human delay',
            ],
            answer: 'Distinguishing waste from meaningful slowness',
            explanationEnglish:
                'Paragraph 4 explicitly argues that institutions must distinguish these two ideas.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c2_efficiency_q7',
            type: ReadingQuestionType.inference,
            question: 'What does the final sentence warn against?',
            options: [
              'Designing human life around machine-like speed',
              'Using efficiency to save time for people',
              'Asking whether a process can improve',
              'Recognising that waste can be harmful',
            ],
            answer: 'Designing human life around machine-like speed',
            explanationEnglish:
                'The sentence contrasts clearing space for human life with redesigning life to fit the machine.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c2_efficiency_q8',
            type: ReadingQuestionType.inference,
            question: 'What is the tone of the essay?',
            options: [
              'Nuanced and cautionary',
              'Purely celebratory',
              'Angrily dismissive',
              'Casual and comic',
            ],
            answer: 'Nuanced and cautionary',
            explanationEnglish:
                'The writer recognises both the benefits and the dangers of efficiency.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'friction',
            originalSentence: 'Some forms of friction protect judgement.',
            newExampleSentence:
                'A little friction in a decision process can prevent careless choices.',
            meaningEnglish: 'difficulty or resistance that slows a process',
            meaningTurkish: 'sürtünme / yavaşlatıcı direnç',
          ),
        ],
        reflectionPrompt:
            'Can making life more efficient sometimes make it less human? Explain.',
        reflectionPromptTurkish:
            'Hayatı daha verimli hâle getirmek bazen onu daha az insancıl yapabilir mi? Açıkla.',
      ),
      ReadingLesson(
        id: 'c2_why_nuance_matters',
        level: ReadingLevel.c2,
        clusterId: 'c2_language_power_and_culture',
        title: 'Why Nuance Matters',
        subtitle: 'A critical essay on simplification and public debate',
        icon: Icons.tune_rounded,
        estimatedMinutes: 18,
        textType: 'critical essay',
        orientationEnglish:
            'In this text, you will read about nuance, public debate, and the cost of oversimplified arguments.',
        orientationTurkish:
            'Bu metinde nüans, kamusal tartışma ve aşırı basitleştirilmiş argümanların bedeli hakkında okuyacaksın.',
        readingTipTurkish:
            'C2 seviyesinde yazarın karşı çıktığı şey genellikle “basitçe yanlış” değildir; eksik, dar veya fazla kesin olabilir.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Nuance is often accused of weakness. In public debate, the person who says “it depends” may sound less courageous than the person who declares an answer with theatrical certainty. Complexity is slow; certainty travels well. A sharp slogan can cross a crowd in seconds, while a careful distinction arrives late and slightly out of breath.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Yet nuance is not the enemy of conviction. It is the discipline that prevents conviction from becoming crude. To recognise complexity is not to refuse judgement; it is to judge with the relevant conditions in view. A doctor, a teacher, a judge, and a historian all know that details are not decorative. They are often the difference between accuracy and harm.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'The hunger for simplicity is understandable. People are tired, information is excessive, and moral confusion is uncomfortable. Simple stories reduce anxiety by assigning clear roles: victim, villain, hero, solution. But the world rarely cooperates for long. The villain may have a grievance, the victim may have power, the hero may be vain, and the solution may create new damage.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'This is why nuance is ethically demanding. It asks people to remain attentive after the emotional satisfaction of certainty has arrived. It may require holding two truths together: that a policy helps one group while harming another, that a person can be responsible and wounded, that a tradition can carry wisdom and exclusion at the same time.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'A culture without nuance does not become more decisive; it becomes more theatrical. Arguments are performed as identity signals, and disagreement becomes proof of moral corruption rather than a possible invitation to think. Nuance matters because reality does not become simpler when language does. It merely becomes easier to misdescribe.',
          ),
          ReadingParagraph(
            number: 6,
            text:
                'The defence of nuance therefore has to resist two misunderstandings at once. It must resist the impatient demand that every judgement be reduced to a slogan, but it must also resist the comfortable habit of using complexity to avoid judgement altogether. Some situations do require clear moral language; the point is that clarity should be earned rather than performed. A nuanced argument does not weaken responsibility. It asks responsibility to become more precise: to name causes without inventing purity, to criticise harm without erasing context, and to decide while still admitting what remains uncertain. That precision is slower than outrage, but it leaves public language less brutal and more faithful to experience, especially when conflict tempts people to simplify each other.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'nuance',
            meaningEnglish:
                'a subtle difference or complexity in meaning, judgement, or situation',
            meaningTurkish: 'nüans / ince ayrım',
            example: 'Nuance is often accused of weakness.',
          ),
          ReadingGloss(
            word: 'conviction',
            meaningEnglish: 'a strong belief or certainty',
            meaningTurkish: 'güçlü kanaat / inanç',
            example: 'Nuance is not the enemy of conviction.',
          ),
          ReadingGloss(
            word: 'crude',
            meaningEnglish: 'too simple, rough, or lacking careful thought',
            meaningTurkish: 'kaba / incelikten yoksun',
            example: 'It prevents conviction from becoming crude.',
          ),
          ReadingGloss(
            word: 'misdescribe',
            meaningEnglish: 'describe something inaccurately',
            meaningTurkish: 'yanlış betimlemek',
            example: 'It becomes easier to misdescribe reality.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c2_nuance_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main claim of the essay?',
            options: [
              'Nuance is necessary for accurate and ethical judgement',
              'Nuance prevents people from ever making decisions',
              'Simple slogans are always more truthful than complex arguments',
              'Public debate should avoid moral questions completely',
            ],
            answer: 'Nuance is necessary for accurate and ethical judgement',
            explanationEnglish:
                'The writer argues that nuance protects judgement from oversimplification and harm.',
          ),
          ReadingQuestion(
            id: 'c2_nuance_q2',
            type: ReadingQuestionType.inference,
            question: 'Why does the writer say “certainty travels well”?',
            options: [
              'Because simple confident claims spread more easily than careful distinctions',
              'Because certainty is always based on evidence',
              'Because travel makes people more confident',
              'Because crowds dislike slogans',
            ],
            answer:
                'Because simple confident claims spread more easily than careful distinctions',
            explanationEnglish:
                'The contrast with a careful distinction arriving late shows that certainty is easier to circulate.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c2_nuance_q3',
            type: ReadingQuestionType.detail,
            question: 'According to paragraph 2, what does nuance prevent?',
            options: [
              'Conviction from becoming crude',
              'Doctors from making decisions',
              'Teachers from noticing details',
              'Historians from studying conditions',
            ],
            answer: 'Conviction from becoming crude',
            explanationEnglish:
                'Paragraph 2 directly states that nuance prevents conviction from becoming crude.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_nuance_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In paragraph 3, “cooperates” means the world ____.',
            options: [
              'fits the simple story people want',
              'refuses every form of change',
              'becomes completely predictable',
              'stops producing moral confusion',
            ],
            answer: 'fits the simple story people want',
            explanationEnglish:
                'The writer says the world rarely cooperates with simple roles such as villain, victim, and hero.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c2_nuance_q5',
            type: ReadingQuestionType.inference,
            question: 'What does paragraph 4 suggest about ethical thinking?',
            options: [
              'It may require holding conflicting truths together',
              'It becomes easier when all details are removed',
              'It should avoid responsibility and harm',
              'It depends only on emotional certainty',
            ],
            answer: 'It may require holding conflicting truths together',
            explanationEnglish:
                'The paragraph gives examples of two truths existing at the same time.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c2_nuance_q6',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'The writer says details are merely decorative in professional judgement.',
            options: ['True', 'False', 'Not Given'],
            answer: 'False',
            explanationEnglish:
                'Paragraph 2 says details are not decorative and can be the difference between accuracy and harm.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_nuance_q7',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'When simplified language distorts reality',
              'Why disagreement should disappear',
              'The benefits of theatrical certainty',
              'How slogans make culture more accurate',
            ],
            answer: 'When simplified language distorts reality',
            explanationEnglish:
                'The final paragraph argues that simpler language makes reality easier to misdescribe.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'c2_nuance_q8',
            type: ReadingQuestionType.inference,
            question:
                'What does the writer likely think of the phrase “it depends”?',
            options: [
              'It can be intellectually responsible rather than weak',
              'It is always a way to avoid judgement',
              'It should be removed from public debate',
              'It proves that someone has no convictions',
            ],
            answer: 'It can be intellectually responsible rather than weak',
            explanationEnglish:
                'The essay begins by noting that “it depends” is treated as weak, then defends nuance as disciplined judgement.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'conviction',
            originalSentence: 'Nuance is not the enemy of conviction.',
            newExampleSentence:
                'Strong conviction without evidence can become arrogance.',
            meaningEnglish: 'a strong belief or certainty',
            meaningTurkish: 'güçlü kanaat / inanç',
          ),
        ],
        reflectionPrompt:
            'Why do you think simple arguments are often more popular than nuanced ones?',
        reflectionPromptTurkish:
            'Sence basit argümanlar neden nüanslı argümanlardan daha popüler oluyor?',
      ),
      ReadingLesson(
        id: 'c2_ethics_of_convenience',
        level: ReadingLevel.c2,
        clusterId: 'c2_language_power_and_culture',
        title: 'The Ethics of Convenience',
        subtitle: 'An essay on comfort, invisibility, and responsibility',
        icon: Icons.shopping_bag_rounded,
        estimatedMinutes: 18,
        textType: 'philosophical essay',
        orientationEnglish:
            'In this text, you will read about convenience and the hidden labour behind frictionless modern life.',
        orientationTurkish:
            'Bu metinde konfor, görünmez emek ve sorumluluk hakkında felsefi bir deneme okuyacaksın.',
        readingTipTurkish:
            'C2 metinlerde soyut kavramların arkasındaki görünmeyen aktörleri takip et: convenience kimin için, hangi bedelle?',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Convenience is one of the quiet triumphs of modern life. Food arrives at the door, directions appear before confusion has time to form, and products can be summoned with a gesture so small it barely feels like a decision. The world seems to have become smoother, less resistant, more obedient to desire.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'But convenience often works by moving difficulty out of sight rather than removing it. The meal that arrives quickly may depend on rushed workers, complex logistics, and streets crowded with delivery traffic. The cheap product may carry the invisible history of underpaid labour, distant factories, and environmental cost. To the user, the experience is frictionless; to others, the friction has merely been redistributed.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'This invisibility matters because moral imagination depends on contact. When effort, delay, and human labour disappear from the surface of an experience, it becomes easier to forget that anyone is involved. Convenience can therefore produce a kind of innocence: not the innocence of doing no harm, but the innocence of not having to notice the harm one is connected to.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'The answer is not to reject convenience entirely. Few people truly want a life in which every task is slow, difficult, and local. Convenience can support disabled people, save exhausted parents time, and make daily life more manageable. The ethical question is not whether comfort is allowed, but whether comfort requires ignorance.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'A more responsible form of convenience would make its conditions visible. It would ask users to accept that speed has a cost, that low prices are not neutral facts, and that ease for one person may mean pressure for another. Convenience becomes ethically dangerous when it allows comfort to feel disconnected from consequence.',
          ),
          ReadingParagraph(
            number: 6,
            text:
                'Visibility alone, however, is not enough if it becomes another form of decoration. A label about labour conditions, an option to tip, or a message about carbon cost can easily become a ritual that leaves the structure untouched. The deeper ethical question is whether convenient systems allow people and institutions to change the conditions they reveal. If responsibility is reduced to a brief moment of consumer awareness, convenience remains largely intact. If visibility leads to fairer pay, slower promises, repairable products, or regulation that protects hidden workers, then comfort can begin to answer to the world that makes it possible. Ethical convenience would not abolish ease; it would refuse to let ease depend on disciplined ignorance or permanent distance from those who carry its costs.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'frictionless',
            meaningEnglish: 'smooth and easy, with no visible difficulty',
            meaningTurkish: 'sürtünmesiz / zahmetsiz görünen',
            example: 'To the user, the experience is frictionless.',
          ),
          ReadingGloss(
            word: 'redistributed',
            meaningEnglish: 'moved or shared in a different way',
            meaningTurkish: 'yeniden dağıtılmış',
            example: 'The friction has merely been redistributed.',
          ),
          ReadingGloss(
            word: 'moral imagination',
            meaningEnglish:
                'the ability to consider other people’s experiences and ethical consequences',
            meaningTurkish: 'ahlaki tahayyül / etik hayal gücü',
            example: 'Moral imagination depends on contact.',
          ),
          ReadingGloss(
            word: 'consequence',
            meaningEnglish: 'a result or effect of an action',
            meaningTurkish: 'sonuç / bedel',
            example: 'Comfort can feel disconnected from consequence.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c2_convenience_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main argument of the essay?',
            options: [
              'Convenience is useful but can hide labour, cost, and responsibility',
              'Convenience should be completely removed from modern life',
              'Comfort is always morally wrong',
              'Technology has solved the problem of labour',
            ],
            answer:
                'Convenience is useful but can hide labour, cost, and responsibility',
            explanationEnglish:
                'The writer does not reject convenience entirely but argues that its hidden conditions must be made visible.',
          ),
          ReadingQuestion(
            id: 'c2_convenience_q2',
            type: ReadingQuestionType.inference,
            question:
                'What does the writer imply by saying the world seems “more obedient to desire”?',
            options: [
              'Modern services make wants appear instantly satisfied',
              'People have stopped wanting convenient services',
              'Desire has become morally pure',
              'The world no longer resists anyone in any way',
            ],
            answer: 'Modern services make wants appear instantly satisfied',
            explanationEnglish:
                'The phrase follows examples of instant delivery, directions, and purchasing.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c2_convenience_q3',
            type: ReadingQuestionType.detail,
            question:
                'According to paragraph 2, what may quick food delivery depend on?',
            options: [
              'Rushed workers and complex logistics',
              'A complete absence of labour',
              'Customers cooking slowly',
              'Factories becoming local',
            ],
            answer: 'Rushed workers and complex logistics',
            explanationEnglish:
                'Paragraph 2 explicitly mentions rushed workers and complex logistics.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_convenience_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In paragraph 2, “redistributed” means the difficulty has been ____.',
            options: [
              'moved onto others',
              'fully removed',
              'made imaginary',
              'shared only by customers',
            ],
            answer: 'moved onto others',
            explanationEnglish:
                'The sentence contrasts the user’s smooth experience with difficulty carried by others.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c2_convenience_q5',
            type: ReadingQuestionType.inference,
            question:
                'What does the writer mean by “the innocence of not having to notice”?',
            options: [
              'People may feel innocent because hidden harm is kept out of view',
              'People are never responsible for distant consequences',
              'Convenience removes all ethical questions',
              'Ignorance is always morally better than knowledge',
            ],
            answer:
                'People may feel innocent because hidden harm is kept out of view',
            explanationEnglish:
                'Paragraph 3 argues that invisibility makes it easier to forget the labour and harm one is connected to.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c2_convenience_q6',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'The writer believes convenience can support disabled people.',
            options: ['True', 'False', 'Not Given'],
            answer: 'True',
            explanationEnglish:
                'Paragraph 4 explicitly says convenience can support disabled people.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c2_convenience_q7',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'Making the conditions of comfort visible',
              'Rejecting all forms of modern comfort',
              'Why low prices are always neutral',
              'How to make services faster at any cost',
            ],
            answer: 'Making the conditions of comfort visible',
            explanationEnglish:
                'The final paragraph argues for a responsible convenience that reveals its costs and conditions.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'c2_convenience_q8',
            type: ReadingQuestionType.inference,
            question:
                'What attitude does the writer take toward convenience overall?',
            options: [
              'Critical but not absolutist',
              'Completely hostile',
              'Unquestioningly celebratory',
              'Indifferent and descriptive only',
            ],
            answer: 'Critical but not absolutist',
            explanationEnglish:
                'The writer criticises hidden costs while recognising that convenience can make life manageable.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'visible',
            originalSentence:
                'A more responsible form of convenience would make its conditions visible.',
            newExampleSentence:
                'Ethical design can make hidden labour more visible to users.',
            meaningEnglish: 'able to be seen or noticed',
            meaningTurkish: 'görünür',
          ),
        ],
        reflectionPrompt:
            'Should convenient services show users more information about labour and environmental cost?',
        reflectionPromptTurkish:
            'Kullanışlı hizmetler kullanıcılara emek ve çevresel maliyet hakkında daha fazla bilgi göstermeli mi?',
      ),
    ],
  ),
];
