import 'package:flutter/material.dart';

import 'reading_models.dart';

/// B2 Reading data.
/// Content rules:
/// - 350–550 words target
/// - semi-academic / opinion / report-style texts
/// - focus on stance, evidence, inference, paragraph purpose, vocabulary in context
/// - Turkish support is strategic only, not translation

const List<ReadingCluster> readingB2Clusters = [
  ReadingCluster(
    id: 'b2_society_and_technology',
    level: ReadingLevel.b2,
    title: 'Society & Technology',
    subtitle: 'Longer texts about technology, education, work, and culture.',
    icon: Icons.hub_rounded,
    lessons: [
      ReadingLesson(
        id: 'b2_social_media_algorithms',
        level: ReadingLevel.b2,
        clusterId: 'b2_society_and_technology',
        title: 'Social Media Algorithms',
        subtitle: 'A semi-academic article about attention and choice',
        icon: Icons.dynamic_feed_rounded,
        estimatedMinutes: 12,
        textType: 'semi-academic article',
        orientationEnglish:
            'In this text, you will read about how social media algorithms shape what people see online.',
        orientationTurkish:
            'Bu metinde sosyal medya algoritmalarının çevrim içi gördüklerimizi nasıl etkilediğini okuyacaksın.',
        readingTipTurkish:
            'B2 metinlerde yazarın tamamen karşı mı yoksa dengeli mi yaklaştığını takip et. however, although, as a result gibi bağlaçlar çok önemlidir.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Most people open social media because they want to relax, contact friends, or follow topics they enjoy. Yet the order of posts on a screen is rarely random. Behind the page, algorithms decide which photos, videos, and comments are more likely to keep a user watching. These systems do not simply show what is new; they often show what is predicted to hold attention.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Supporters of algorithmic feeds argue that they make online life more convenient. Without them, users might have to search through hundreds of posts to find what interests them. A person who enjoys language learning, for example, may quickly see vocabulary videos, study tips, and teacher accounts. In this sense, algorithms can reduce information overload and personalise the experience.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'However, convenience has a cost. If a platform mainly rewards content that creates strong reactions, users may see more extreme opinions, shocking headlines, or emotionally charged videos. Over time, this can make the online world feel more dramatic than it really is. Some researchers also warn that personalised feeds can create bubbles, where people repeatedly see ideas similar to their own.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'Another concern is that many users do not understand why a particular post appears. When people believe they are freely choosing everything they watch, they may underestimate how much the platform has guided them. This does not mean algorithms are secretly controlling everyone, but it does mean that online choice is partly designed by invisible systems.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'The solution is not necessarily to remove algorithms completely. Instead, platforms could give users clearer controls and explain why certain posts are recommended. Schools could also teach digital reading skills, helping students ask not only “Is this information true?” but also “Why am I seeing this now?” In a digital society, understanding the system behind the screen is becoming part of basic literacy.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'predicted',
            meaningEnglish: 'expected to happen based on data or reasoning',
            meaningTurkish: 'tahmin edilen',
            example: 'They show what is predicted to hold attention.',
          ),
          ReadingGloss(
            word: 'information overload',
            meaningEnglish:
                'a situation where there is too much information to process',
            meaningTurkish: 'bilgi yüklenmesi',
            example: 'Algorithms can reduce information overload.',
          ),
          ReadingGloss(
            word: 'underestimate',
            meaningEnglish:
                'think something is smaller or less important than it really is',
            meaningTurkish: 'olduğundan az görmek',
            example:
                'Users may underestimate how much the platform has guided them.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b2_algorithms_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main idea of the text?',
            options: [
              'Algorithms can be useful, but users should understand their influence',
              'Algorithms should be completely removed from all social media platforms',
              'Social media users are never responsible for what they watch',
              'Language learning videos are the main reason algorithms exist',
            ],
            answer:
                'Algorithms can be useful, but users should understand their influence',
            explanationEnglish:
                'The writer presents both benefits and risks, then argues for clearer controls and digital reading skills.',
            explanationTurkish:
                'Yazar hem faydaları hem riskleri veriyor ve daha açık kontroller ile dijital okuma becerilerinin önemini vurguluyor.',
          ),
          ReadingQuestion(
            id: 'b2_algorithms_q2',
            type: ReadingQuestionType.detail,
            question:
                'According to paragraph 2, how can algorithms help users?',
            options: [
              'They can reduce information overload',
              'They can remove all false information',
              'They can stop people from wasting time',
              'They can make every user see the same posts',
            ],
            answer: 'They can reduce information overload',
            explanationEnglish:
                'Paragraph 2 says algorithms can reduce information overload and personalise the experience.',
            evidenceParagraph: 2,
            evidenceText:
                'Algorithms can reduce information overload and personalise the experience.',
          ),
          ReadingQuestion(
            id: 'b2_algorithms_q3',
            type: ReadingQuestionType.inference,
            question:
                'What can be inferred from paragraph 3 about emotionally charged content?',
            options: [
              'It may receive more attention on platforms',
              'It is always more accurate than neutral content',
              'It is usually produced by schools',
              'It prevents users from forming opinions',
            ],
            answer: 'It may receive more attention on platforms',
            explanationEnglish:
                'The paragraph says platforms may reward content that creates strong reactions, which suggests emotional content can be promoted.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_algorithms_q4',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'The writer believes algorithms secretly control everyone.',
            options: ['True', 'False', 'Not Given'],
            answer: 'False',
            explanationEnglish:
                'Paragraph 4 directly says this does not mean algorithms are secretly controlling everyone.',
            evidenceParagraph: 4,
            evidenceText:
                'This does not mean algorithms are secretly controlling everyone.',
          ),
          ReadingQuestion(
            id: 'b2_algorithms_q5',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In paragraph 4, “underestimate” means ____.',
            options: [
              'think something is less important than it is',
              'explain something in great detail',
              'disagree with something strongly',
              'control something completely',
            ],
            answer: 'think something is less important than it is',
            explanationEnglish:
                'The sentence says users may not realise how much the platform guides them, so underestimate means seeing something as less important or smaller.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b2_algorithms_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'Teaching users to understand recommendation systems',
              'Why schools should ban social media',
              'The history of online advertising',
              'How to create vocabulary videos',
            ],
            answer: 'Teaching users to understand recommendation systems',
            explanationEnglish:
                'Paragraph 5 focuses on clearer controls and digital reading skills, especially asking why a post is shown.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'b2_algorithms_q7',
            type: ReadingQuestionType.inference,
            question:
                'What is the writer’s attitude towards algorithms overall?',
            options: [
              'Balanced and cautious',
              'Completely negative',
              'Uninterested and neutral',
              'Excited without any concerns',
            ],
            answer: 'Balanced and cautious',
            explanationEnglish:
                'The writer recognises benefits but also warns about risks and asks for better user understanding.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'literacy',
            originalSentence:
                'Understanding the system behind the screen is becoming part of basic literacy.',
            newExampleSentence:
                'Media literacy helps students judge online information more carefully.',
            meaningEnglish:
                'the ability to understand and use information in a particular area',
            meaningTurkish: 'okuryazarlık / belirli bir alanda anlama becerisi',
          ),
        ],
        reflectionPrompt:
            'Do you think social media platforms should explain why they recommend posts? Give reasons.',
        reflectionPromptTurkish:
            'Sence sosyal medya platformları gönderileri neden önerdiğini açıklamalı mı? Nedenleriyle yaz.',
      ),
      ReadingLesson(
        id: 'b2_remote_work_culture',
        level: ReadingLevel.b2,
        clusterId: 'b2_society_and_technology',
        title: 'Remote Work Culture',
        subtitle: 'A report-style text about flexibility and connection',
        icon: Icons.laptop_mac_rounded,
        estimatedMinutes: 12,
        textType: 'report-style article',
        orientationEnglish:
            'In this text, you will read about how remote work changes company culture.',
        orientationTurkish:
            'Bu metinde uzaktan çalışmanın şirket kültürünü nasıl değiştirdiğini okuyacaksın.',
        readingTipTurkish:
            'B2 report-style metinlerde problem, evidence ve solution bölümlerini ayırmaya çalış.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Remote work was once seen as an unusual benefit offered by a small number of companies. After global changes in working habits, it has become a normal part of professional life for many employees. Some workers now expect flexibility, and many organisations have discovered that offices are not the only places where serious work can happen.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'The most obvious advantage is access. Companies can hire people who live in different cities or even different countries. This allows them to find skilled workers without asking everyone to move. Employees, meanwhile, may save money and time because they do not travel to the office every day.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Nevertheless, remote work can weaken informal communication. In an office, people often learn from short conversations before meetings or while making coffee. Online, these small moments are less likely to happen. As a result, new employees may find it harder to understand the culture of a company or ask quick questions.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'Managers also face a new challenge. If they focus only on whether people are online, they may create pressure without improving results. A better approach is to judge work by clear goals and outcomes. This requires trust, but it can also make expectations more transparent.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'For this reason, many companies are experimenting with hybrid models. Teams may work from home most days but meet in person for planning, training, or creative discussions. The future of work will probably not be fully remote or fully office-based. It will depend on how well organisations design communication, trust, and shared purpose.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'flexibility',
            meaningEnglish: 'the ability to change or adapt easily',
            meaningTurkish: 'esneklik',
            example: 'Some workers now expect flexibility.',
          ),
          ReadingGloss(
            word: 'informal communication',
            meaningEnglish:
                'casual communication that is not part of official meetings',
            meaningTurkish: 'resmî olmayan iletişim',
            example: 'Remote work can weaken informal communication.',
          ),
          ReadingGloss(
            word: 'outcomes',
            meaningEnglish: 'results',
            meaningTurkish: 'sonuçlar',
            example:
                'A better approach is to judge work by clear goals and outcomes.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b2_remote_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the text mainly about?',
            options: [
              'How remote work changes company culture and management',
              'Why all companies should close their offices',
              'How employees can avoid online meetings',
              'Why global hiring is impossible for modern companies',
            ],
            answer: 'How remote work changes company culture and management',
            explanationEnglish:
                'The text discusses advantages, communication problems, management challenges, and hybrid solutions.',
          ),
          ReadingQuestion(
            id: 'b2_remote_q2',
            type: ReadingQuestionType.detail,
            question: 'What advantage is mentioned in paragraph 2?',
            options: [
              'Companies can hire skilled workers from different places',
              'Employees must move to bigger cities',
              'All meetings become unnecessary',
              'New workers learn company culture faster',
            ],
            answer: 'Companies can hire skilled workers from different places',
            explanationEnglish:
                'Paragraph 2 says companies can hire people from different cities or countries.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b2_remote_q3',
            type: ReadingQuestionType.inference,
            question:
                'Why may new employees struggle more in remote companies?',
            options: [
              'They miss informal chances to ask questions and observe culture',
              'They are not allowed to attend online meetings',
              'They cannot use computers at home',
              'They usually dislike flexible schedules',
            ],
            answer:
                'They miss informal chances to ask questions and observe culture',
            explanationEnglish:
                'Paragraph 3 says informal moments are less likely online, so new employees may find it harder to understand culture or ask quick questions.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_remote_q4',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'The writer thinks managers should judge employees only by whether they are online.',
            options: ['True', 'False', 'Not Given'],
            answer: 'False',
            explanationEnglish:
                'Paragraph 4 says a better approach is to judge work by goals and outcomes.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b2_remote_q5',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In paragraph 4, “transparent” is closest in meaning to ____.',
            options: [
              'clear and easy to understand',
              'secret and private',
              'expensive to organise',
              'impossible to measure',
            ],
            answer: 'clear and easy to understand',
            explanationEnglish:
                'The writer connects transparent expectations with clear goals and outcomes.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b2_remote_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 5?',
            options: [
              'Hybrid work as a possible future',
              'The end of professional teamwork',
              'Why offices are always unnecessary',
              'The cost of international hiring',
            ],
            answer: 'Hybrid work as a possible future',
            explanationEnglish:
                'Paragraph 5 discusses hybrid models and argues the future will depend on design rather than one fixed system.',
            evidenceParagraph: 5,
          ),
          ReadingQuestion(
            id: 'b2_remote_q7',
            type: ReadingQuestionType.inference,
            question: 'What does the writer suggest about the future of work?',
            options: [
              'It will depend on thoughtful design and balance',
              'It will become fully remote for every job',
              'It will return completely to offices',
              'It will remove the need for managers',
            ],
            answer: 'It will depend on thoughtful design and balance',
            explanationEnglish:
                'The final paragraph says the future will depend on communication, trust, and shared purpose.',
            evidenceParagraph: 5,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'hybrid',
            originalSentence:
                'Many companies are experimenting with hybrid models.',
            newExampleSentence:
                'A hybrid course combines online lessons with face-to-face meetings.',
            meaningEnglish: 'combining two different systems or styles',
            meaningTurkish: 'iki farklı sistemi birleştiren',
          ),
        ],
        reflectionPrompt:
            'What is the best work model: office, remote, or hybrid? Explain with examples.',
        reflectionPromptTurkish:
            'En iyi çalışma modeli hangisi: ofis, uzaktan veya hibrit? Örneklerle açıkla.',
      ),
      ReadingLesson(
        id: 'b2_learning_with_ai',
        level: ReadingLevel.b2,
        clusterId: 'b2_society_and_technology',
        title: 'Learning with AI',
        subtitle: 'An article about support, independence, and effort',
        icon: Icons.psychology_alt_rounded,
        estimatedMinutes: 11,
        textType: 'balanced opinion article',
        orientationEnglish:
            'In this text, you will read about how AI tools can affect learning habits.',
        orientationTurkish:
            'Bu metinde yapay zekâ araçlarının öğrenme alışkanlıklarını nasıl etkileyebileceğini okuyacaksın.',
        readingTipTurkish:
            'B2 metinlerde yazarın dengeli görüşünü yakala: avantaj, risk ve çözüm bölümlerini ayır.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Artificial intelligence tools are becoming common in education. Students can now ask for explanations, examples, summaries, and practice questions within seconds. For learners who do not have regular access to a teacher, this can be extremely helpful. A difficult grammar point or reading passage no longer has to remain confusing until the next class.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'However, easy help can change the way students think. If a tool gives a complete answer too quickly, the learner may skip the mental effort that makes learning last. For example, copying a model paragraph may produce a clean text, but it does not necessarily improve the student’s ability to organise ideas independently.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'A better approach is to treat AI as a coach rather than a replacement for thinking. Students can ask for hints, compare their own answers with feedback, or request extra practice after making mistakes. In this way, the tool supports effort instead of removing it.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'Teachers also have a role. Instead of simply banning AI, they can design tasks that require reflection, personal examples, and explanation of choices. The future of learning will not depend only on whether students use AI, but on how honestly and actively they use it.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'This balance is especially important for language learners. A student might ask AI to correct a sentence, but then they should look at the correction and explain the rule in their own words. If the tool only gives answers, progress may look faster than it really is. If it helps learners notice patterns, repeat useful language, and revise weak points, it can become part of a serious study routine.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'mental effort',
            meaningEnglish: 'the work your mind does when trying to learn',
            meaningTurkish: 'zihinsel çaba',
            example:
                'The learner may skip the mental effort that makes learning last.',
          ),
          ReadingGloss(
            word: 'independently',
            meaningEnglish: 'without needing someone else to do it',
            meaningTurkish: 'bağımsız şekilde',
            example: 'Organise ideas independently.',
          ),
          ReadingGloss(
            word: 'reflection',
            meaningEnglish: 'careful thinking about an experience or choice',
            meaningTurkish: 'derin düşünme, yansıtma',
            example: 'Tasks can require reflection.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b2_ai_learning_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main idea of the text?',
            options: [
              'AI can support learning if students still think actively',
              'AI should replace teachers in most classrooms',
              'Students should avoid all digital tools',
              'Grammar is the only subject AI can teach',
            ],
            answer: 'AI can support learning if students still think actively',
            explanationEnglish:
                'The writer presents AI as useful but warns against using it to avoid effort.',
          ),
          ReadingQuestion(
            id: 'b2_ai_learning_q2',
            type: ReadingQuestionType.detail,
            question:
                'Why can AI be helpful for learners without regular teacher access?',
            options: [
              'It can give explanations and practice quickly',
              'It removes the need to study',
              'It always grades exams officially',
              'It prevents all mistakes',
            ],
            answer: 'It can give explanations and practice quickly',
            explanationEnglish:
                'Paragraph 1 says students can ask for explanations, examples, summaries, and practice questions within seconds.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'b2_ai_learning_q3',
            type: ReadingQuestionType.inference,
            question: 'Why might copying a model paragraph be unhelpful?',
            options: [
              'It may not develop independent organisation of ideas',
              'It always contains grammar mistakes',
              'It takes more time than writing alone',
              'It is impossible to understand',
            ],
            answer: 'It may not develop independent organisation of ideas',
            explanationEnglish:
                'Paragraph 2 says a clean model does not necessarily improve the student’s ability to organise ideas independently.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b2_ai_learning_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In the text, “coach” is closest in meaning to ____.',
            options: [
              'a guide that supports practice',
              'a person who gives final answers only',
              'a device for recording sound',
              'a strict exam rule',
            ],
            answer: 'a guide that supports practice',
            explanationEnglish:
                'The writer contrasts a coach with a replacement for thinking.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_ai_learning_q5',
            type: ReadingQuestionType.trueFalseNotGiven,
            question: 'The writer says teachers should simply ban AI.',
            options: ['True', 'False', 'Not Given'],
            answer: 'False',
            explanationEnglish:
                'Paragraph 4 says teachers can design better tasks instead of simply banning AI.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b2_ai_learning_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 3?',
            options: [
              'Using AI as guided support',
              'The history of AI tools',
              'Why feedback should disappear',
              'How to avoid all practice',
            ],
            answer: 'Using AI as guided support',
            explanationEnglish:
                'Paragraph 3 explains using AI for hints, feedback, and extra practice.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_ai_learning_q7',
            type: ReadingQuestionType.inference,
            question: 'What does the writer value most in learning?',
            options: [
              'Active effort and honest use of support',
              'Fast answers with no explanation',
              'Avoiding mistakes completely',
              'Using only printed books',
            ],
            answer: 'Active effort and honest use of support',
            explanationEnglish:
                'The final paragraph focuses on honest and active use, while earlier paragraphs stress effort.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'independently',
            originalSentence:
                'It does not necessarily improve the student’s ability to organise ideas independently.',
            newExampleSentence:
                'Good learners can check examples but still write independently.',
            meaningEnglish: 'without needing someone else to do it',
            meaningTurkish: 'bağımsız şekilde',
          ),
        ],
        reflectionPrompt:
            'How can students use AI without losing their own thinking skills?',
        reflectionPromptTurkish:
            'Öğrenciler kendi düşünme becerilerini kaybetmeden yapay zekâyı nasıl kullanabilir?',
      ),
      ReadingLesson(
        id: 'b2_fast_content_problem',
        level: ReadingLevel.b2,
        clusterId: 'b2_society_and_technology',
        title: 'The Problem with Fast Content',
        subtitle: 'A text about attention, speed, and depth',
        icon: Icons.speed_rounded,
        estimatedMinutes: 11,
        textType: 'opinion article',
        orientationEnglish:
            'In this text, you will read about the effects of fast online content on attention.',
        orientationTurkish:
            'Bu metinde hızlı çevrim içi içeriklerin dikkat üzerindeki etkisini okuyacaksın.',
        readingTipTurkish:
            'Ana iddiayı bul ve örneklerin bu iddiayı nasıl desteklediğine bak.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Online content is increasingly designed for speed. Headlines are shorter, videos begin with dramatic moments, and posts compete for attention within seconds. This can be entertaining, and it helps people discover information quickly. Yet the same speed can make deeper attention feel unusually difficult.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'The problem is not that fast content exists. Short explanations, news updates, and visual examples can be useful. The problem begins when speed becomes the main standard for all information. A topic such as climate change, history, or personal finance cannot be fully understood through a few exciting clips.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Fast content may also create the feeling of learning without enough understanding. A person can watch ten educational videos and feel productive, but if they never stop to take notes, ask questions, or connect ideas, much of the information disappears quickly. Depth requires pauses.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'This does not mean people should avoid short content completely. Instead, they can use it as a starting point. A short video can introduce a question, but a longer article, discussion, or project can build real understanding. In other words, fast content is useful when it opens the door, not when it becomes the whole room.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'One practical solution is to separate discovery from study. A person might save an interesting video, then choose one topic to explore more slowly later. They can write a short summary, check another source, or discuss the idea with someone else. These small habits turn quick attention into deeper attention. Without them, fast content may leave behind many impressions but few ideas that can actually be used.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'compete',
            meaningEnglish: 'try to be more successful than others',
            meaningTurkish: 'rekabet etmek',
            example: 'Posts compete for attention within seconds.',
          ),
          ReadingGloss(
            word: 'standard',
            meaningEnglish: 'a level or rule used to judge something',
            meaningTurkish: 'ölçüt, standart',
            example: 'Speed becomes the main standard for all information.',
          ),
          ReadingGloss(
            word: 'depth',
            meaningEnglish: 'serious and detailed understanding',
            meaningTurkish: 'derinlik',
            example: 'Depth requires pauses.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b2_fast_content_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the writer’s main argument?',
            options: [
              'Fast content is useful only if it leads to deeper learning',
              'All short videos should be removed from the internet',
              'People cannot learn anything from visual examples',
              'Long articles are always entertaining',
            ],
            answer:
                'Fast content is useful only if it leads to deeper learning',
            explanationEnglish:
                'The writer says fast content can be a starting point but should not replace deeper understanding.',
          ),
          ReadingQuestion(
            id: 'b2_fast_content_q2',
            type: ReadingQuestionType.detail,
            question: 'What does paragraph 1 say about online content?',
            options: [
              'It is increasingly designed for speed',
              'It is becoming longer and slower',
              'It no longer uses headlines',
              'It avoids dramatic moments',
            ],
            answer: 'It is increasingly designed for speed',
            explanationEnglish:
                'The first sentence directly states that online content is increasingly designed for speed.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'b2_fast_content_q3',
            type: ReadingQuestionType.inference,
            question: 'Why does the writer mention climate change and history?',
            options: [
              'To show that complex topics need more than short clips',
              'To argue that these subjects are not important',
              'To explain why videos are always wrong',
              'To list topics that students dislike',
            ],
            answer: 'To show that complex topics need more than short clips',
            explanationEnglish:
                'The examples support the idea that some topics require deeper attention.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b2_fast_content_q4',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In paragraph 3, “productive” means ____.',
            options: [
              'doing something that feels useful',
              'feeling bored and confused',
              'watching entertainment only',
              'avoiding learning completely',
            ],
            answer: 'doing something that feels useful',
            explanationEnglish:
                'The person feels productive after watching educational videos, but the writer questions whether real learning happened.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_fast_content_q5',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'The writer believes short content can introduce a useful question.',
            options: ['True', 'False', 'Not Given'],
            answer: 'True',
            explanationEnglish:
                'Paragraph 4 says a short video can introduce a question.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b2_fast_content_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 3?',
            options: [
              'The difference between feeling informed and understanding',
              'Why all educational videos are too long',
              'The financial cost of online platforms',
              'How to make dramatic headlines',
            ],
            answer: 'The difference between feeling informed and understanding',
            explanationEnglish:
                'Paragraph 3 explains that watching many videos may feel like learning without deep understanding.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_fast_content_q7',
            type: ReadingQuestionType.inference,
            question: 'What does “opens the door, not the whole room” suggest?',
            options: [
              'Fast content should begin learning, not complete it',
              'Fast content should only be watched indoors',
              'Short videos are always private',
              'Learning should happen without questions',
            ],
            answer: 'Fast content should begin learning, not complete it',
            explanationEnglish:
                'The metaphor means fast content can introduce an idea, but deeper work must follow.',
            evidenceParagraph: 4,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'depth',
            originalSentence: 'Depth requires pauses.',
            newExampleSentence:
                'A good discussion can add depth to a simple idea.',
            meaningEnglish: 'serious and detailed understanding',
            meaningTurkish: 'derinlik',
          ),
        ],
        reflectionPrompt:
            'Do you think fast content makes learning easier or shallower? Explain your view.',
        reflectionPromptTurkish:
            'Sence hızlı içerikler öğrenmeyi kolaylaştırıyor mu, yoksa yüzeyselleştiriyor mu? Görüşünü açıkla.',
      ),
      ReadingLesson(
        id: 'b2_quiet_spaces_in_cities',
        level: ReadingLevel.b2,
        clusterId: 'b2_society_and_technology',
        title: 'Why Cities Need Quiet Spaces',
        subtitle: 'An urban life text about noise and wellbeing',
        icon: Icons.park_rounded,
        estimatedMinutes: 11,
        textType: 'semi-academic article',
        orientationEnglish:
            'In this text, you will read about the importance of quiet spaces in busy cities.',
        orientationTurkish:
            'Bu metinde kalabalık şehirlerde sessiz alanların neden önemli olduğunu okuyacaksın.',
        readingTipTurkish:
            'B2 metinlerde problem-solution yapısını takip et. Gürültü problemi nasıl çözülüyor?',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Cities are often described through movement: traffic, crowds, construction, and constant activity. This energy can make urban life exciting, but it also creates a problem that is easy to ignore: noise. For many residents, silence has become something they experience only late at night or far away from the city centre.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Noise is not only annoying; it can affect wellbeing. People who live near busy roads or loud commercial areas may find it harder to rest, concentrate, or feel calm. Even when they become used to the sound, their bodies may continue to react to it as stress.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Quiet spaces do not have to be large forests or expensive parks. A small garden between buildings, a library courtyard, or a street with fewer cars can make a difference. What matters is that people have places where they can slow down without needing to buy anything.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'City planners can support this by protecting green areas, reducing traffic in selected streets, and designing public spaces for reading, resting, and conversation. A successful city should not only move people quickly. It should also give them places to breathe.',
          ),
          ReadingParagraph(
            number: 5,
            text:
                'Quiet spaces can also make city life feel more equal. Not everyone has a private balcony, a large home, or money to spend in calm cafés. Public quiet areas give students, older residents, workers, and parents a place to recover without paying for peace. When silence is treated as a shared resource, it becomes part of public health rather than a luxury for people who can escape the noise.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'urban',
            meaningEnglish: 'connected with a city',
            meaningTurkish: 'kentsel, şehirle ilgili',
            example: 'Urban life can be exciting.',
          ),
          ReadingGloss(
            word: 'residents',
            meaningEnglish: 'people who live in a place',
            meaningTurkish: 'sakinler',
            example: 'For many residents, silence is rare.',
          ),
          ReadingGloss(
            word: 'wellbeing',
            meaningEnglish: 'general physical and mental health',
            meaningTurkish: 'iyi oluş, sağlıklı ruh hâli',
            example: 'Noise can affect wellbeing.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b2_quiet_city_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main idea of the text?',
            options: [
              'Cities need quiet public spaces for wellbeing',
              'Cities should stop all construction permanently',
              'People should leave cities to find silence',
              'Noise is only a problem at night',
            ],
            answer: 'Cities need quiet public spaces for wellbeing',
            explanationEnglish:
                'The text explains the problem of noise and argues for quiet spaces in cities.',
          ),
          ReadingQuestion(
            id: 'b2_quiet_city_q2',
            type: ReadingQuestionType.detail,
            question: 'What problem does paragraph 1 introduce?',
            options: [
              'Noise in active cities',
              'A lack of shopping centres',
              'Too many forests',
              'Slow public transport',
            ],
            answer: 'Noise in active cities',
            explanationEnglish:
                'Paragraph 1 says city energy creates a problem: noise.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'b2_quiet_city_q3',
            type: ReadingQuestionType.inference,
            question:
                'What does paragraph 2 suggest about getting used to noise?',
            options: [
              'The body may still experience stress',
              'Noise becomes completely harmless',
              'People sleep better near busy roads',
              'Commercial areas are always calm',
            ],
            answer: 'The body may still experience stress',
            explanationEnglish:
                'The paragraph says bodies may continue to react to sound as stress.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b2_quiet_city_q4',
            type: ReadingQuestionType.detail,
            question: 'Which example of a quiet space is mentioned?',
            options: [
              'A library courtyard',
              'A shopping mall',
              'A car park',
              'A stadium',
            ],
            answer: 'A library courtyard',
            explanationEnglish:
                'Paragraph 3 gives a library courtyard as an example.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_quiet_city_q5',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'The writer says quiet spaces must always be large and expensive.',
            options: ['True', 'False', 'Not Given'],
            answer: 'False',
            explanationEnglish:
                'Paragraph 3 says quiet spaces do not have to be large forests or expensive parks.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b2_quiet_city_q6',
            type: ReadingQuestionType.matchingHeadings,
            question: 'Which heading best fits paragraph 4?',
            options: [
              'How planners can create calmer cities',
              'Why cities should remove all roads',
              'The history of public libraries',
              'How to make shopping streets louder',
            ],
            answer: 'How planners can create calmer cities',
            explanationEnglish:
                'Paragraph 4 lists actions city planners can take to support quiet spaces.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b2_quiet_city_q7',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In the text, “residents” means ____.',
            options: [
              'people who live in a place',
              'people who visit for one day',
              'city planners only',
              'drivers on a road',
            ],
            answer: 'people who live in a place',
            explanationEnglish:
                'The sentence refers to people who experience city noise where they live.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'wellbeing',
            originalSentence:
                'Noise is not only annoying; it can affect wellbeing.',
            newExampleSentence:
                'Regular sleep is important for physical and mental wellbeing.',
            meaningEnglish: 'general physical and mental health',
            meaningTurkish: 'iyi oluş, sağlıklı ruh hâli',
          ),
        ],
        reflectionPrompt:
            'What kind of quiet space would improve life in a busy city?',
        reflectionPromptTurkish:
            'Kalabalık bir şehirde yaşamı iyileştirecek nasıl bir sessiz alan tasarlardın?',
      ),
    ],
  ),
];
