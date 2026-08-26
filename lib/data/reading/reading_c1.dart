import 'package:flutter/material.dart';

import 'reading_models.dart';

/// C1 Reading data.
/// Content rules:
/// - 550–800 words target
/// - advanced editorials / analytical essays / academic-style introductions
/// - focus on tone, implication, argument structure, rhetorical purpose
/// - mostly English-only support; Turkish support is strategic and minimal

const List<ReadingCluster> readingC1Clusters = [
  ReadingCluster(
    id: 'c1_ideas_and_identity',
    level: ReadingLevel.c1,
    title: 'Ideas & Identity',
    subtitle: 'Advanced texts about thought, choice, memory, and society.',
    icon: Icons.psychology_alt_rounded,
    lessons: [
      ReadingLesson(
        id: 'c1_paradox_of_choice',
        level: ReadingLevel.c1,
        clusterId: 'c1_ideas_and_identity',
        title: 'The Paradox of Choice',
        subtitle: 'An analytical essay on freedom and decision fatigue',
        icon: Icons.account_tree_rounded,
        estimatedMinutes: 16,
        textType: 'analytical essay',
        orientationEnglish:
            'In this text, you will read an analytical discussion of choice, freedom, and the psychological cost of endless options.',
        orientationTurkish:
            'Bu metinde seçim özgürlüğü, karar yorgunluğu ve çok fazla seçeneğin psikolojik etkisi üzerine analitik bir metin okuyacaksın.',
        readingTipTurkish:
            'C1 metinlerde sadece ana fikri değil, yazarın argümanı nasıl inşa ettiğini takip et. Contrast, concession ve rhetorical shift noktalarını yakala.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Modern life often presents choice as an unquestionable good. We are encouraged to customise our education, careers, diets, identities, entertainment, and even our methods of relaxation. At first glance, this seems liberating. After all, the ability to choose appears to protect individuality and resist the pressure of a single social script. Yet the abundance of options can also become a source of anxiety, not because choice is harmful in itself, but because limitless choice quietly changes the burden placed on the individual.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'In earlier periods, many decisions were shaped by family, geography, class, or tradition. This could be restrictive, and it would be naïve to romanticise a world in which fewer people had the power to design their own lives. However, the modern alternative has produced a different kind of pressure. When every path appears open, each decision begins to feel like a personal statement. Choosing a university course, a job, or even a lifestyle is no longer simply practical; it is treated as evidence of who one really is.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'This creates a peculiar form of responsibility. If a person selects one option from hundreds and later feels dissatisfied, it becomes difficult to blame circumstance. The mind easily returns to the alternatives: the career not pursued, the city not moved to, the relationship not chosen, the skill not developed. In this way, choice can extend regret into imaginary futures. The problem is not merely that people make wrong decisions, but that they are forced to live with an awareness of all the decisions they might have made.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'The digital marketplace intensifies this condition. Streaming platforms promise perfect entertainment, yet many viewers spend more time browsing than watching. Online courses offer unlimited self-improvement, yet the very number of possibilities may prevent commitment. Even productivity tools can multiply the feeling that life should be optimised rather than lived. What appears to be empowerment can gradually become a subtle demand: if the best version of your life is available somewhere, why have you not selected it yet?',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'A mature response to this paradox is not to reject choice, but to limit its authority. Meaningful freedom requires the ability to decide, but it also requires the ability to stop comparing. A life cannot be experienced fully while it is constantly measured against every unrealised version of itself. Perhaps the most valuable skill in an age of abundance is not choosing perfectly, but choosing sufficiently, and then giving one’s attention to the path that has been chosen.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'unquestionable',
            meaningEnglish: 'accepted as completely true or good without doubt',
            meaningTurkish: 'sorgulanamaz',
            example:
                'Modern life often presents choice as an unquestionable good.',
          ),
          ReadingGloss(
            word: 'restrictive',
            meaningEnglish: 'limiting freedom or possibility',
            meaningTurkish: 'kısıtlayıcı',
            example:
                'This could be restrictive, and it would be naïve to romanticise it.',
          ),
          ReadingGloss(
            word: 'peculiar',
            meaningEnglish: 'strange or unusual in a noticeable way',
            meaningTurkish: 'tuhaf / kendine özgü',
            example: 'This creates a peculiar form of responsibility.',
          ),
          ReadingGloss(
            word: 'unrealised',
            meaningEnglish: 'not achieved, experienced, or made real',
            meaningTurkish: 'gerçekleşmemiş',
            example:
                'A life cannot be measured against every unrealised version of itself.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c1_choice_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'Which statement best summarises the writer’s argument?',
            options: [
              'Choice is valuable, but excessive choice can create anxiety and regret',
              'Modern people should return to traditional social roles',
              'Individuality is impossible in a digital marketplace',
              'The only solution to dissatisfaction is unlimited freedom',
            ],
            answer:
                'Choice is valuable, but excessive choice can create anxiety and regret',
            explanationEnglish:
                'The writer repeatedly balances the value of choice with its psychological costs, especially anxiety, regret, and comparison.',
            explanationTurkish:
                'Yazar seçim özgürlüğünün değerini kabul ederken, aşırı seçeneğin kaygı, pişmanlık ve karşılaştırma doğurduğunu savunuyor.',
          ),
          ReadingQuestion(
            id: 'c1_choice_q2',
            type: ReadingQuestionType.inference,
            question:
                'What does the writer imply about earlier periods with fewer choices?',
            options: [
              'They were not ideal, even if they reduced some decision pressure',
              'They were clearly better than modern life in every way',
              'They gave everyone equal control over their future',
              'They eliminated regret completely',
            ],
            answer:
                'They were not ideal, even if they reduced some decision pressure',
            explanationEnglish:
                'The writer says it would be naïve to romanticise the past because fewer choices were often restrictive.',
            evidenceParagraph: 2,
            evidenceText:
                'This could be restrictive, and it would be naïve to romanticise a world...',
          ),
          ReadingQuestion(
            id: 'c1_choice_q3',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In paragraph 3, “imaginary futures” refers to ____.',
            options: [
              'possible lives that were never actually chosen',
              'plans that are certain to happen later',
              'childhood dreams that disappear with age',
              'fictional stories created for entertainment',
            ],
            answer: 'possible lives that were never actually chosen',
            explanationEnglish:
                'The writer lists alternatives such as the career not pursued or city not moved to, so the phrase refers to unrealised possibilities.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c1_choice_q4',
            type: ReadingQuestionType.detail,
            question:
                'According to paragraph 4, what do streaming platforms illustrate?',
            options: [
              'The difficulty of committing when options seem endless',
              'The disappearance of all meaningful entertainment',
              'The superiority of traditional television',
              'The fact that viewers never know what they like',
            ],
            answer: 'The difficulty of committing when options seem endless',
            explanationEnglish:
                'The example shows that people may spend more time browsing than watching when too many choices are available.',
            evidenceParagraph: 4,
            evidenceText:
                'Many viewers spend more time browsing than watching.',
          ),
          ReadingQuestion(
            id: 'c1_choice_q5',
            type: ReadingQuestionType.inference,
            question:
                'What attitude does the writer take toward self-optimisation culture?',
            options: [
              'Sceptical, because it can turn life into a permanent project',
              'Enthusiastic, because it guarantees happiness',
              'Neutral, because it has no effect on identity',
              'Dismissive, because it only affects young people',
            ],
            answer:
                'Sceptical, because it can turn life into a permanent project',
            explanationEnglish:
                'The writer warns that productivity tools can make life feel like something to optimise rather than live.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c1_choice_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'Learning to stop comparing',
              'Rejecting freedom completely',
              'Choosing the most profitable option',
              'Returning to traditional authority',
            ],
            answer: 'Learning to stop comparing',
            explanationEnglish:
                'The paragraph argues that meaningful freedom includes the ability to stop comparing unrealised alternatives.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'c1_choice_q7',
            type: ReadingQuestionType.inference,
            question:
                'What is meant by “choosing sufficiently” in the final sentence?',
            options: [
              'Making a good-enough decision and then committing attention to it',
              'Refusing to make decisions until a perfect option appears',
              'Letting other people decide every important question',
              'Choosing as many options as possible at the same time',
            ],
            answer:
                'Making a good-enough decision and then committing attention to it',
            explanationEnglish:
                'The writer contrasts perfect choice with committing to the path chosen, so “sufficiently” means good enough to live with attentively.',
            evidenceParagraph: 5,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'abundance',
            originalSentence:
                'Perhaps the most valuable skill in an age of abundance is not choosing perfectly...',
            newExampleSentence:
                'An abundance of information can make research both easier and more confusing.',
            meaningEnglish: 'a very large amount of something',
            meaningTurkish: 'bolluk / çokluk',
          ),
        ],
        reflectionPrompt:
            'Do you agree that too much choice can reduce happiness? Explain with examples from modern life.',
        reflectionPromptTurkish:
            'Çok fazla seçeneğin mutluluğu azaltabileceğine katılıyor musun? Modern hayattan örneklerle açıkla.',
      ),
      ReadingLesson(
        id: 'c1_memory_and_identity',
        level: ReadingLevel.c1,
        clusterId: 'c1_ideas_and_identity',
        title: 'Memory and Identity',
        subtitle: 'A reflective essay on the stories we tell about ourselves',
        icon: Icons.auto_awesome_motion_rounded,
        estimatedMinutes: 15,
        textType: 'reflective essay',
        orientationEnglish:
            'In this text, you will read about the relationship between memory, identity, and personal storytelling.',
        orientationTurkish:
            'Bu metinde hafıza, kimlik ve kişinin kendi hayatını hikâyeleştirmesi arasındaki ilişkiyi okuyacaksın.',
        readingTipTurkish:
            'C1 reflective essaylerde somut iddiadan çok kavramsal bağlantılara dikkat et: memory, narrative, identity gibi tekrar eden anahtar kavramlar argümanı taşır.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'People often imagine memory as an archive: a quiet room in the mind where past events are stored and later recovered. This image is comforting, but it is misleading. Memories are not simply retrieved; they are reconstructed. Each time a person tells a story about childhood, friendship, success, or loss, the memory is shaped again by the needs, language, and emotions of the present.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'This does not mean that memory is useless or false. Rather, it means that memory is active. A person does not merely possess a past; they interpret it. Two siblings may remember the same family holiday differently, not because one is lying, but because each has placed the event inside a different personal narrative. One may remember freedom, the other loneliness; one may recall sunlight, the other silence.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Identity depends heavily on this narrative process. We become coherent to ourselves by linking separate moments into a story. A failed exam becomes the beginning of discipline, a painful move becomes the start of independence, and a difficult friendship becomes a lesson in boundaries. The event itself matters, but the meaning attached to it may matter even more.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'There is, however, a danger in treating identity as a fixed story. Once a person becomes too loyal to one version of the past, they may stop noticing new possibilities. Someone who has always described themselves as shy may overlook evidence of courage. Someone who remembers failure as proof of inadequacy may avoid situations where growth is possible. In this sense, memory can become not only a mirror but also a cage.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'A healthier relationship with memory might involve holding one’s stories lightly. The past cannot be rewritten in a simple sense, but it can be reinterpreted with greater complexity. A person can recognise pain without allowing it to define every future action. They can honour old versions of themselves without being trapped by them. Identity, then, is not a finished autobiography but an ongoing act of revision.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'archive',
            meaningEnglish:
                'a collection of historical records or stored information',
            meaningTurkish: 'arşiv',
            example: 'People often imagine memory as an archive.',
          ),
          ReadingGloss(
            word: 'reconstructed',
            meaningEnglish: 'built again or formed again',
            meaningTurkish: 'yeniden inşa edilmiş',
            example:
                'Memories are not simply retrieved; they are reconstructed.',
          ),
          ReadingGloss(
            word: 'coherent',
            meaningEnglish: 'clear, connected, and understandable',
            meaningTurkish: 'tutarlı / bütünlüklü',
            example:
                'We become coherent to ourselves by linking separate moments into a story.',
          ),
          ReadingGloss(
            word: 'inadequacy',
            meaningEnglish: 'the feeling of not being good enough',
            meaningTurkish: 'yetersizlik',
            example:
                'Someone who remembers failure as proof of inadequacy may avoid growth.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c1_memory_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the central argument of the text?',
            options: [
              'Memory is active and shapes identity through personal storytelling',
              'Memory is completely unreliable and should be ignored',
              'Identity is determined only by childhood experiences',
              'People should avoid thinking about the past',
            ],
            answer:
                'Memory is active and shapes identity through personal storytelling',
            explanationEnglish:
                'The text argues that memory is reconstructed and interpreted, and that these interpretations shape identity.',
          ),
          ReadingQuestion(
            id: 'c1_memory_q2',
            type: ReadingQuestionType.detail,
            question:
                'Why does the writer reject the image of memory as an archive?',
            options: [
              'Because memories are reconstructed rather than simply stored and recovered',
              'Because people cannot remember childhood at all',
              'Because archives are always inaccurate',
              'Because emotions have no effect on memory',
            ],
            answer:
                'Because memories are reconstructed rather than simply stored and recovered',
            explanationEnglish:
                'Paragraph 1 says the archive image is misleading because memories are shaped again by present needs, language, and emotions.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c1_memory_q3',
            type: ReadingQuestionType.inference,
            question:
                'What does the example of two siblings suggest about memory?',
            options: [
              'Different interpretations can exist without deliberate dishonesty',
              'One person’s memory must always be false',
              'Family holidays are usually unpleasant',
              'Children remember events more accurately than adults',
            ],
            answer:
                'Different interpretations can exist without deliberate dishonesty',
            explanationEnglish:
                'The writer says the siblings may remember differently not because one is lying, but because each uses a different personal narrative.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c1_memory_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In paragraph 3, “coherent” is closest in meaning to ____.',
            options: [
              'connected and understandable',
              'emotionally distant',
              'unchanging and fixed',
              'brief and incomplete',
            ],
            answer: 'connected and understandable',
            explanationEnglish:
                'The paragraph explains that separate moments are linked into a story, making the self feel connected and understandable.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c1_memory_q5',
            type: ReadingQuestionType.inference,
            question: 'What risk does the writer identify in paragraph 4?',
            options: [
              'A fixed self-story may prevent people from recognising growth',
              'People may remember too many details from childhood',
              'Identity becomes stronger when it changes often',
              'Courage is impossible for shy people',
            ],
            answer:
                'A fixed self-story may prevent people from recognising growth',
            explanationEnglish:
                'The writer gives examples of people trapped by old descriptions of themselves, such as being shy or inadequate.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c1_memory_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'Revising the stories we live by',
              'Forgetting the past completely',
              'Why memory should be scientific',
              'The impossibility of personal change',
            ],
            answer: 'Revising the stories we live by',
            explanationEnglish:
                'The final paragraph argues that identity is an ongoing act of revision rather than a fixed autobiography.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'c1_memory_q7',
            type: ReadingQuestionType.inference,
            question:
                'What does the writer mean by “memory can become not only a mirror but also a cage”?',
            options: [
              'Memory can reflect the past but also limit future possibilities',
              'Memory always shows the past exactly as it happened',
              'Memory is useful only when it is painful',
              'Memory prevents people from forming any identity',
            ],
            answer:
                'Memory can reflect the past but also limit future possibilities',
            explanationEnglish:
                'The metaphor suggests that memory can help people understand themselves but can also trap them in limiting stories.',
            evidenceParagraph: 4,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'revision',
            originalSentence:
                'Identity, then, is not a finished autobiography but an ongoing act of revision.',
            newExampleSentence:
                'Personal growth often requires the revision of old beliefs about yourself.',
            meaningEnglish: 'the process of changing or rethinking something',
            meaningTurkish: 'gözden geçirme / yeniden düzenleme',
          ),
        ],
        reflectionPrompt:
            'Can changing the way we interpret a memory change the way we see ourselves? Explain.',
        reflectionPromptTurkish:
            'Bir anıyı yorumlama biçimimizi değiştirmek kendimizi görme şeklimizi değiştirebilir mi? Açıkla.',
      ),
      ReadingLesson(
        id: 'c1_constant_productivity',
        level: ReadingLevel.c1,
        clusterId: 'c1_ideas_and_identity',
        title: 'The Cost of Constant Productivity',
        subtitle: 'An analytical essay on work, worth, and rest',
        icon: Icons.trending_up_rounded,
        estimatedMinutes: 14,
        textType: 'analytical essay',
        orientationEnglish:
            'In this text, you will read about how productivity culture can change the way people understand rest and self-worth.',
        orientationTurkish:
            'Bu metinde üretkenlik kültürünün dinlenme ve öz-değer algısını nasıl etkilediğini okuyacaksın.',
        readingTipTurkish:
            'C1 metinlerde kavramlar arasındaki ilişkiyi takip et: productivity, worth, rest ve guilt metnin argümanını taşır.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Productivity was once a practical idea: the ability to complete necessary work with reasonable efficiency. In contemporary culture, however, it has expanded into a moral language. People no longer simply ask whether a task has been completed; they ask whether the day has been used well enough. Even leisure is often judged by its output: a book finished, a skill improved, a body made healthier, a personal brand strengthened.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'This shift is subtle because it often appears positive. Planning one’s time can reduce stress, and discipline can make difficult goals possible. Yet productivity becomes oppressive when it turns every hour into evidence of personal value. Rest then stops being recovery and becomes a suspicious gap in the schedule, something that must be justified rather than experienced.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'The result is a strange form of guilt. A person may finish their work and still feel behind, not because a real deadline has been missed, but because some imagined version of the self could have done more. The comparison is no longer with other people alone; it is with a more efficient, more focused, more optimised self that never seems to need a pause.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'A healthier understanding of productivity would treat rest not as the opposite of achievement but as one of its conditions. Attention, creativity, and emotional patience all weaken when life is treated as a permanent project. To rest without guilt is not laziness. It is a refusal to measure the entire self by visible output.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'The challenge is that this refusal is difficult to practise alone. Workplaces, schools, and social media platforms often reward visible busyness more quickly than quiet recovery. A person who chooses a slower rhythm may therefore feel as if they are falling behind a race they never agreed to enter. Changing the culture of productivity requires more than better personal habits; it requires spaces where limits are respected, unfinished time is not treated as failure, and worth is not constantly translated into performance.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'moral language',
            meaningEnglish:
                'a way of speaking that treats something as right or wrong',
            meaningTurkish: 'ahlaki dil / doğru-yanlış dili',
            example: 'It has expanded into a moral language.',
          ),
          ReadingGloss(
            word: 'oppressive',
            meaningEnglish: 'causing pressure or making people feel trapped',
            meaningTurkish: 'baskıcı',
            example: 'Productivity becomes oppressive.',
          ),
          ReadingGloss(
            word: 'output',
            meaningEnglish: 'the visible result of work or effort',
            meaningTurkish: 'çıktı / üretim sonucu',
            example: 'The self is measured by visible output.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c1_productivity_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the writer’s main argument?',
            options: [
              'Productivity becomes harmful when it defines personal worth',
              'Productivity should be completely rejected in modern life',
              'Rest is useful only when it produces visible results',
              'People are naturally lazy without strict schedules',
            ],
            answer:
                'Productivity becomes harmful when it defines personal worth',
            explanationEnglish:
                'The text criticises productivity when it becomes a moral measure of the self.',
          ),
          ReadingQuestion(
            id: 'c1_productivity_q2',
            type: ReadingQuestionType.detail,
            question: 'How does the writer say leisure is often judged?',
            options: [
              'By its output',
              'By its silence',
              'By its cost',
              'By its popularity',
            ],
            answer: 'By its output',
            explanationEnglish:
                'Paragraph 1 says even leisure is often judged by what it produces.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c1_productivity_q3',
            type: ReadingQuestionType.inference,
            question: 'Why does rest become “suspicious” in this culture?',
            options: [
              'Because it seems unproductive and must be justified',
              'Because it always prevents achievement',
              'Because people dislike sleeping',
              'Because schedules are no longer used',
            ],
            answer: 'Because it seems unproductive and must be justified',
            explanationEnglish:
                'Paragraph 2 contrasts rest as recovery with rest as a gap that needs justification.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c1_productivity_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In paragraph 2, “oppressive” is closest in meaning to ____.',
            options: [
              'pressuring and restrictive',
              'helpful and relaxing',
              'brief and unimportant',
              'random and playful',
            ],
            answer: 'pressuring and restrictive',
            explanationEnglish:
                'The word describes productivity when it makes every hour feel like a test of personal value.',
          ),
          ReadingQuestion(
            id: 'c1_productivity_q5',
            type: ReadingQuestionType.inference,
            question:
                'What is the “imagined version of the self” used to show?',
            options: [
              'An unrealistic standard people compare themselves with',
              'A person’s childhood memory',
              'A real manager at work',
              'A friend who works less',
            ],
            answer: 'An unrealistic standard people compare themselves with',
            explanationEnglish:
                'The writer describes a more efficient self that always could have done more.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c1_productivity_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 4?',
            options: [
              'Rest as a condition of achievement',
              'Why laziness is always dangerous',
              'The end of all discipline',
              'How to produce more every day',
            ],
            answer: 'Rest as a condition of achievement',
            explanationEnglish:
                'The paragraph argues that rest supports attention, creativity, and patience.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c1_productivity_q7',
            type: ReadingQuestionType.inference,
            question: 'What tone does the writer take toward discipline?',
            options: [
              'Balanced: useful, but dangerous when tied to self-worth',
              'Completely hostile to any discipline',
              'Unquestioningly enthusiastic',
              'Indifferent and technical',
            ],
            answer: 'Balanced: useful, but dangerous when tied to self-worth',
            explanationEnglish:
                'The writer recognises that discipline can help goals but warns against moralising productivity.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'justify',
            originalSentence:
                'Rest becomes something that must be justified rather than experienced.',
            newExampleSentence:
                'You do not need to justify every quiet hour of your day.',
            meaningEnglish: 'give a reason to show something is acceptable',
            meaningTurkish: 'gerekçelendirmek',
          ),
        ],
        reflectionPrompt:
            'Do you think people today connect productivity too strongly with self-worth? Explain.',
        reflectionPromptTurkish:
            'Sence insanlar bugün üretkenliği öz-değerle fazla mı ilişkilendiriyor? Açıkla.',
      ),
      ReadingLesson(
        id: 'c1_value_of_boredom',
        level: ReadingLevel.c1,
        clusterId: 'c1_ideas_and_identity',
        title: 'The Value of Boredom',
        subtitle: 'A reflective essay on attention and inner life',
        icon: Icons.hourglass_empty_rounded,
        estimatedMinutes: 14,
        textType: 'reflective essay',
        orientationEnglish:
            'In this text, you will read about boredom, attention, and why empty moments may be valuable.',
        orientationTurkish:
            'Bu metinde can sıkıntısı, dikkat ve boş anların değeri hakkında okuyacaksın.',
        readingTipTurkish:
            'C1 reflective metinlerde yazarın bir kavramı tersine çevirmesine dikkat et: boredom burada problem değil, potansiyel olarak ele alınıyor.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Boredom has a poor reputation. It is treated as a small failure of entertainment, a sign that something should immediately be opened, watched, played, or refreshed. The modern person is rarely required to remain bored for long. A screen can fill almost any empty moment before the mind has time to notice its own restlessness.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Yet boredom may be one of the few experiences that forces attention to turn inward. When nothing arrives from outside, the mind begins to search, combine, remember, and imagine. This is not always pleasant. The first stage of boredom is often irritation. But if the feeling is not interrupted too quickly, it can become a space in which unplanned thought begins.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Many forms of creativity depend on such space. A solution may appear while walking without music, an old memory may connect with a current problem, or a vague feeling may finally find words. These moments cannot be scheduled in the same way as meetings. They require a kind of mental weather that constant stimulation rarely allows.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'This does not mean boredom is always noble. Some boredom comes from unfair conditions, repetitive work, or a lack of opportunity. The point is not to romanticise emptiness, but to defend the ordinary pauses in which thought is not being directed by a device. A life with no boredom may also be a life with very little room to hear itself think.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'For this reason, boredom can be understood as a threshold rather than a destination. It is not valuable because it feels empty, but because it may lead beyond the immediate demand to be entertained. If every uncomfortable pause is filled at once, the mind learns to expect rescue before it has examined its own questions. To protect occasional boredom is to protect the slow arrival of attention, including the awkward early minutes when nothing interesting seems to be happening. Those minutes matter because thought often begins without confidence, before it has a purpose or audience.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'restlessness',
            meaningEnglish:
                'the uncomfortable feeling of wanting to move or do something',
            meaningTurkish: 'huzursuzluk',
            example: 'The mind notices its own restlessness.',
          ),
          ReadingGloss(
            word: 'stimulation',
            meaningEnglish: 'activity or input that keeps the mind interested',
            meaningTurkish: 'uyarıcı etki / uyarılma',
            example: 'Constant stimulation rarely allows it.',
          ),
          ReadingGloss(
            word: 'romanticise',
            meaningEnglish:
                'make something seem better or more attractive than it is',
            meaningTurkish: 'romantize etmek / olduğundan güzel göstermek',
            example: 'The point is not to romanticise emptiness.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c1_boredom_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the central idea of the text?',
            options: [
              'Boredom can create space for thought and creativity',
              'Boredom should always be avoided immediately',
              'Entertainment has no value in modern life',
              'Creativity happens only during scheduled work',
            ],
            answer: 'Boredom can create space for thought and creativity',
            explanationEnglish:
                'The writer argues that empty moments can allow inward attention and unplanned thought.',
          ),
          ReadingQuestion(
            id: 'c1_boredom_q2',
            type: ReadingQuestionType.detail,
            question: 'How is boredom usually treated today?',
            options: [
              'As a small failure of entertainment',
              'As a serious academic subject',
              'As a form of physical exercise',
              'As a social achievement',
            ],
            answer: 'As a small failure of entertainment',
            explanationEnglish:
                'The first paragraph directly describes boredom in this way.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c1_boredom_q3',
            type: ReadingQuestionType.inference,
            question: 'Why does the writer mention screens in paragraph 1?',
            options: [
              'To show how quickly empty moments are filled',
              'To argue that all technology is useless',
              'To explain how screens improve memory',
              'To praise constant entertainment',
            ],
            answer: 'To show how quickly empty moments are filled',
            explanationEnglish:
                'The screen is presented as something that interrupts boredom before it develops.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c1_boredom_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In paragraph 2, “inward” means ____.',
            options: [
              'toward one’s own thoughts',
              'toward other people',
              'toward a public event',
              'toward physical movement',
            ],
            answer: 'toward one’s own thoughts',
            explanationEnglish:
                'The paragraph contrasts outside input with the mind’s own searching and imagining.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c1_boredom_q5',
            type: ReadingQuestionType.detail,
            question: 'Which example of creative thinking is mentioned?',
            options: [
              'A solution appearing while walking without music',
              'A solution appearing during a noisy meeting',
              'A memory disappearing completely',
              'A device directing every thought',
            ],
            answer: 'A solution appearing while walking without music',
            explanationEnglish:
                'Paragraph 3 gives this as one example of thought emerging in empty space.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c1_boredom_q6',
            type: ReadingQuestionType.inference,
            question: 'Why does the writer say boredom is not always noble?',
            options: [
              'To avoid oversimplifying painful or unfair forms of boredom',
              'To reject the entire argument',
              'To claim boredom has no mental value',
              'To argue that repetitive work is creative',
            ],
            answer:
                'To avoid oversimplifying painful or unfair forms of boredom',
            explanationEnglish:
                'The final paragraph recognises boredom caused by unfair conditions or limited opportunity.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c1_boredom_q7',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 3?',
            options: [
              'Creativity in unscheduled space',
              'The danger of all walking',
              'Why music prevents every idea',
              'The rules of productive meetings',
            ],
            answer: 'Creativity in unscheduled space',
            explanationEnglish:
                'Paragraph 3 explains how unscheduled mental space can support creative connections.',
            evidenceParagraph: 3,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'interrupt',
            originalSentence:
                'If the feeling is not interrupted too quickly, it can become a space for thought.',
            newExampleSentence:
                'A message can interrupt your focus during a difficult task.',
            meaningEnglish: 'stop something from continuing',
            meaningTurkish: 'bölmek / kesintiye uğratmak',
          ),
        ],
        reflectionPrompt:
            'Do you think boredom can be useful for creativity? Explain with examples.',
        reflectionPromptTurkish:
            'Sence can sıkıntısı yaratıcılık için faydalı olabilir mi? Örneklerle açıkla.',
      ),
      ReadingLesson(
        id: 'c1_public_silence',
        level: ReadingLevel.c1,
        clusterId: 'c1_ideas_and_identity',
        title: 'Public Silence and Private Thought',
        subtitle: 'An essay on speaking, listening, and social pressure',
        icon: Icons.record_voice_over_rounded,
        estimatedMinutes: 14,
        textType: 'argumentative essay',
        orientationEnglish:
            'In this text, you will read about silence, public expression, and the pressure to have an opinion.',
        orientationTurkish:
            'Bu metinde sessizlik, kamusal ifade ve fikir belirtme baskısı hakkında okuyacaksın.',
        readingTipTurkish:
            'Yazarın silence kavramına verdiği farklı işlevleri takip et: avoidance, reflection, listening, pressure.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'In a culture that rewards immediate response, silence is easily misunderstood. When a public issue appears, people are often expected to react quickly, clearly, and visibly. To remain silent can be interpreted as ignorance, fear, indifference, or even agreement with the strongest voice in the room.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Sometimes this suspicion is justified. Silence can protect comfort. It can allow injustice to continue without challenge. There are moments when not speaking is not neutral at all. Yet it would be a mistake to treat every silence as moral failure. Some silences are forms of attention. They give people time to listen, check facts, or understand experiences beyond their own.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'The difficulty is that digital spaces rarely distinguish between thoughtful silence and empty avoidance. Platforms value visible participation: a comment, a statement, a reaction, a position. Reflection, by contrast, leaves little trace. A person who is still thinking may appear identical to a person who does not care.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'A more mature public culture would not ask people to choose between instant performance and permanent silence. It would make room for delayed speech: the kind that arrives after listening, reading, and uncertainty. Speaking matters, but so does the process that makes speech responsible. Not every silence deserves respect, but not every immediate statement deserves trust.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'The value of delayed speech depends on what happens during the delay. Silence that simply waits for danger to pass is different from silence that gathers evidence, hears people directly affected, and tests its own assumptions. Public life needs ways to recognise that difference, even if digital platforms are poorly designed for it. Otherwise, speed becomes a substitute for courage, and performance becomes a substitute for responsibility. The goal is not quieter citizens, but more accountable voices. In that sense, responsible speech is not merely the act of having a position; it is the discipline of letting a position be changed by attention. That slower discipline can make public disagreement less reactive and more honest.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'indifference',
            meaningEnglish: 'lack of interest, care, or concern',
            meaningTurkish: 'ilgisizlik / kayıtsızlık',
            example: 'Silence can be interpreted as indifference.',
          ),
          ReadingGloss(
            word: 'neutral',
            meaningEnglish: 'not supporting any side',
            meaningTurkish: 'tarafsız',
            example: 'Not speaking is not neutral at all.',
          ),
          ReadingGloss(
            word: 'trace',
            meaningEnglish: 'a sign that something has happened or existed',
            meaningTurkish: 'iz',
            example: 'Reflection leaves little trace.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'c1_silence_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the writer’s main argument?',
            options: [
              'Silence can be harmful or thoughtful depending on context',
              'Silence is always a sign of moral failure',
              'Immediate public reaction is always reliable',
              'People should never speak about public issues',
            ],
            answer: 'Silence can be harmful or thoughtful depending on context',
            explanationEnglish:
                'The text distinguishes between silence that protects comfort and silence that allows listening and reflection.',
          ),
          ReadingQuestion(
            id: 'c1_silence_q2',
            type: ReadingQuestionType.detail,
            question: 'How may silence be interpreted in public situations?',
            options: [
              'As ignorance, fear, indifference, or agreement',
              'Only as deep wisdom',
              'Only as anger',
              'As proof of expertise',
            ],
            answer: 'As ignorance, fear, indifference, or agreement',
            explanationEnglish:
                'Paragraph 1 lists these possible interpretations.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'c1_silence_q3',
            type: ReadingQuestionType.inference,
            question:
                'Why does the writer say suspicion of silence can be justified?',
            options: [
              'Because silence can sometimes protect comfort and allow injustice',
              'Because all quiet people are careless',
              'Because listening is impossible in public',
              'Because facts are never important',
            ],
            answer:
                'Because silence can sometimes protect comfort and allow injustice',
            explanationEnglish:
                'Paragraph 2 acknowledges that not speaking can allow injustice to continue.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'c1_silence_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In paragraph 3, “visible participation” means ____.',
            options: [
              'public signs of taking part',
              'private reading without response',
              'silent disagreement',
              'careful fact-checking',
            ],
            answer: 'public signs of taking part',
            explanationEnglish:
                'The paragraph gives examples such as comments, statements, reactions, and positions.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c1_silence_q5',
            type: ReadingQuestionType.inference,
            question: 'What problem do digital spaces create?',
            options: [
              'They make thoughtful silence look like not caring',
              'They make everyone listen carefully',
              'They remove the need for public speech',
              'They always reward uncertainty',
            ],
            answer: 'They make thoughtful silence look like not caring',
            explanationEnglish:
                'The writer says a thinking person may appear identical to one who does not care.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'c1_silence_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 4?',
            options: [
              'Making room for delayed speech',
              'Rejecting all public conversation',
              'Why silence is always superior',
              'The end of uncertainty',
            ],
            answer: 'Making room for delayed speech',
            explanationEnglish:
                'The final paragraph argues for speech that comes after listening, reading, and uncertainty.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'c1_silence_q7',
            type: ReadingQuestionType.inference,
            question: 'What does the writer imply about immediate statements?',
            options: [
              'They can be visible without being responsible',
              'They are always more ethical than silence',
              'They prove that a person understands the issue',
              'They should be trusted automatically',
            ],
            answer: 'They can be visible without being responsible',
            explanationEnglish:
                'The writer says not every immediate statement deserves trust.',
            evidenceParagraph: 4,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'responsible',
            originalSentence:
                'Speaking matters, but so does the process that makes speech responsible.',
            newExampleSentence:
                'A responsible opinion is based on listening and evidence.',
            meaningEnglish: 'careful, fair, and aware of consequences',
            meaningTurkish: 'sorumlu / dikkatli',
          ),
        ],
        reflectionPrompt:
            'Is it better to speak quickly about public issues or wait until you understand more? Explain.',
        reflectionPromptTurkish:
            'Kamusal konularda hızlı konuşmak mı, yoksa daha iyi anlayana kadar beklemek mi daha doğru? Açıkla.',
      ),
    ],
  ),
];
