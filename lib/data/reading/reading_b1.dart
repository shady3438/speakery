import 'package:flutter/material.dart';

import 'reading_models.dart';

/// B1 Reading data.
/// Content rules:
/// - 200–350 words target
/// - everyday articles, blogs, reviews, personal opinion texts
/// - main idea, detail, inference, vocabulary-in-context, true/false/not given
/// - Turkish support is strategic, not full translation

const List<ReadingCluster> readingB1Clusters = [
  ReadingCluster(
    id: 'b1_modern_life',
    level: ReadingLevel.b1,
    title: 'Modern Life',
    subtitle: 'Everyday articles about habits, technology, work, and choices.',
    icon: Icons.public_rounded,
    lessons: [
      ReadingLesson(
        id: 'b1_month_without_phone',
        level: ReadingLevel.b1,
        clusterId: 'b1_modern_life',
        title: 'A Month Without a Smartphone',
        subtitle: 'A personal experiment article',
        icon: Icons.phone_android_rounded,
        estimatedMinutes: 9,
        textType: 'personal article',
        orientationEnglish:
            'In this text, a university student writes about living without a smartphone for one month.',
        orientationTurkish:
            'Bu metinde bir üniversite öğrencisinin bir ay telefonsuz yaşama deneyimini okuyacaksın.',
        readingTipTurkish:
            'B1 metinlerde sadece detay arama. Yazarın deneyimden çıkardığı sonucu da yakalamaya çalış.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'At the beginning of last year, I realised that I was checking my smartphone more than a hundred times a day. I used it on the bus, during lunch, and even while I was watching films. I did not think this was a serious problem until I noticed that I could not read a book for more than ten minutes without touching my phone.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'For this reason, I decided to live without my smartphone for one month. I did not stop using technology completely. I still used my laptop for university work and emails, but I left my phone in a drawer at home. The first week was difficult. I often felt that I was missing something important, although nothing urgent was actually happening.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'After the second week, things changed. I started to notice the city more when I travelled by bus. I talked to my classmates more often, and I finished two books. I also slept better because I was not scrolling before bed. However, there were some problems. It was harder to find places, arrange meetings, and take quick photos.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'At the end of the month, I took my phone back, but I changed the way I used it. I deleted several apps, turned off most notifications, and stopped taking it to bed. I do not think smartphones are bad, but I now believe they should be tools, not habits.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'realised',
            meaningEnglish: 'understood clearly',
            meaningTurkish: 'farkına vardı',
            example: 'I realised that I was checking my smartphone too often.',
          ),
          ReadingGloss(
            word: 'urgent',
            meaningEnglish: 'needing immediate attention',
            meaningTurkish: 'acil',
            example: 'Nothing urgent was actually happening.',
          ),
          ReadingGloss(
            word: 'notifications',
            meaningEnglish: 'alerts from apps or devices',
            meaningTurkish: 'bildirimler',
            example: 'I turned off most notifications.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b1_phone_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main idea of the text?',
            options: [
              'A student learns to use a smartphone more consciously',
              'A student decides that all technology is dangerous',
              'A student buys a new phone for university',
              'A student starts a business without social media',
            ],
            answer: 'A student learns to use a smartphone more consciously',
            explanationEnglish:
                'The writer does not reject smartphones completely; they change their habits and use the phone more carefully.',
            explanationTurkish:
                'Yazar telefonu tamamen reddetmiyor; alışkanlıklarını değiştirip telefonu daha bilinçli kullanıyor.',
          ),
          ReadingQuestion(
            id: 'b1_phone_q2',
            type: ReadingQuestionType.detail,
            question: 'What made the writer notice the problem?',
            options: [
              'They could not read for long without touching the phone',
              'Their phone stopped working on the bus',
              'Their classmates complained about their phone',
              'They forgot to answer an urgent email',
            ],
            answer: 'They could not read for long without touching the phone',
            explanationEnglish:
                'Paragraph 1 says the writer noticed the problem when they could not read for more than ten minutes without touching the phone.',
            evidenceParagraph: 1,
            evidenceText:
                'I could not read a book for more than ten minutes without touching my phone.',
          ),
          ReadingQuestion(
            id: 'b1_phone_q3',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'The writer stopped using all technology during the experiment.',
            options: ['True', 'False', 'Not Given'],
            answer: 'False',
            explanationEnglish:
                'The writer still used a laptop for university work and emails.',
            explanationTurkish:
                'Yazar teknoloji kullanımını tamamen bırakmadı; üniversite işleri ve e-postalar için laptop kullandı.',
            evidenceParagraph: 2,
            evidenceText:
                'I still used my laptop for university work and emails.',
          ),
          ReadingQuestion(
            id: 'b1_phone_q4',
            type: ReadingQuestionType.inference,
            question: 'How did the writer probably feel during the first week?',
            options: [
              'Nervous and uncomfortable',
              'Completely relaxed',
              'Angry with classmates',
              'Excited about buying a new phone',
            ],
            answer: 'Nervous and uncomfortable',
            explanationEnglish:
                'The writer says the first week was difficult and they felt they were missing something important.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b1_phone_q5',
            type: ReadingQuestionType.detail,
            question: 'Which positive change is mentioned in the text?',
            options: [
              'The writer slept better',
              'The writer became famous online',
              'The writer bought more books',
              'The writer stopped using emails',
            ],
            answer: 'The writer slept better',
            explanationEnglish:
                'Paragraph 3 says the writer slept better because they were not scrolling before bed.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b1_phone_q6',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In the text, “notifications” means ____.',
            options: [
              'alerts from apps or devices',
              'long messages from teachers',
              'photos saved on a phone',
              'rules about using technology',
            ],
            answer: 'alerts from apps or devices',
            explanationEnglish:
                'The writer talks about turning off notifications, so the word refers to alerts from apps or the phone.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'habit',
            originalSentence: 'I now believe they should be tools, not habits.',
            newExampleSentence:
                'Checking my phone before sleep became a bad habit.',
            meaningEnglish:
                'something you do regularly, often without thinking',
            meaningTurkish: 'alışkanlık',
          ),
        ],
        reflectionPrompt:
            'Do you think you could live without your smartphone for one week? Why or why not?',
        reflectionPromptTurkish:
            'Sence bir hafta akıllı telefonsuz yaşayabilir misin? Neden?',
      ),
      ReadingLesson(
        id: 'b1_working_from_home',
        level: ReadingLevel.b1,
        clusterId: 'b1_modern_life',
        title: 'Working from Home',
        subtitle: 'A balanced opinion text',
        icon: Icons.home_work_rounded,
        estimatedMinutes: 8,
        textType: 'opinion article',
        orientationEnglish:
            'In this text, you will read a balanced opinion about working from home.',
        orientationTurkish:
            'Bu metinde evden çalışma hakkında dengeli bir görüş yazısı okuyacaksın.',
        readingTipTurkish:
            'B1 opinion metinlerinde avantaj ve dezavantajları ayır. however, on the other hand gibi ifadeler önemlidir.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Working from home has become normal for many people. A few years ago, most office workers travelled to work every day. Now, some companies allow their employees to work from home for part of the week. This change has created new opportunities, but it has also brought new problems.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'One clear advantage is time. People do not need to spend an hour in traffic before work. They can start the day more calmly, and they may have more time for their families. Working from home can also help people concentrate, especially when the office is noisy.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'However, home is not always the perfect workplace. Some people live in small flats or share rooms with family members. Others find it difficult to stop working because their computer is always near them. As a result, the line between work and free time can become unclear.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'In my opinion, the best solution is not to choose only one system. A flexible model can work better. Employees can go to the office for meetings and teamwork, but they can stay at home when they need quiet time. This way, people can enjoy the benefits of both places.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'employees',
            meaningEnglish: 'people who work for a company',
            meaningTurkish: 'çalışanlar',
            example: 'Some companies allow their employees to work from home.',
          ),
          ReadingGloss(
            word: 'concentrate',
            meaningEnglish: 'focus your attention on something',
            meaningTurkish: 'odaklanmak',
            example: 'Working from home can help people concentrate.',
          ),
          ReadingGloss(
            word: 'flexible',
            meaningEnglish: 'able to change when needed',
            meaningTurkish: 'esnek',
            example: 'A flexible model can work better.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b1_home_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the writer’s main opinion?',
            options: [
              'A flexible work model is better than only one system',
              'Everyone should work from home every day',
              'Office work is always better than home work',
              'Companies should stop online meetings',
            ],
            answer: 'A flexible work model is better than only one system',
            explanationEnglish:
                'The final paragraph says the best solution is not only one system, but a flexible model.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b1_home_q2',
            type: ReadingQuestionType.detail,
            question: 'Which advantage is mentioned in paragraph 2?',
            options: [
              'People save time by avoiding traffic',
              'People can buy cheaper computers',
              'People never feel tired at home',
              'People do not need internet',
            ],
            answer: 'People save time by avoiding traffic',
            explanationEnglish:
                'The text says people do not need to spend an hour in traffic before work.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b1_home_q3',
            type: ReadingQuestionType.inference,
            question:
                'Why can the line between work and free time become unclear?',
            options: [
              'Because the computer is always near',
              'Because offices are too far away',
              'Because people dislike teamwork',
              'Because families always work together',
            ],
            answer: 'Because the computer is always near',
            explanationEnglish:
                'The writer explains that some people find it difficult to stop working because their computer is always near them.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b1_home_q4',
            type: ReadingQuestionType.trueFalseNotGiven,
            question: 'The writer believes meetings are better in the office.',
            options: ['True', 'False', 'Not Given'],
            answer: 'True',
            explanationEnglish:
                'The writer says employees can go to the office for meetings and teamwork.',
            evidenceParagraph: 4,
          ),
          ReadingQuestion(
            id: 'b1_home_q5',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In the text, “flexible” means ____.',
            options: [
              'able to change when needed',
              'very expensive',
              'strict and fixed',
              'difficult to understand',
            ],
            answer: 'able to change when needed',
            explanationEnglish:
                'The writer uses flexible to describe a work model that combines home and office work.',
          ),
          ReadingQuestion(
            id: 'b1_home_q6',
            type: ReadingQuestionType.detail,
            question: 'Which problem is mentioned about working from home?',
            options: [
              'Some people do not have a suitable space',
              'All workers become less productive',
              'Companies cannot send emails',
              'Traffic becomes worse',
            ],
            answer: 'Some people do not have a suitable space',
            explanationEnglish:
                'Paragraph 3 says some people live in small flats or share rooms with family members.',
            evidenceParagraph: 3,
          ),
        ],
        reflectionPrompt:
            'Would you prefer to work from home, in an office, or both? Explain your answer.',
        reflectionPromptTurkish:
            'Evden mi, ofisten mi, yoksa ikisinden de çalışmayı mı tercih edersin? Cevabını açıkla.',
      ),
      ReadingLesson(
        id: 'b1_new_student_in_class',
        level: ReadingLevel.b1,
        clusterId: 'b1_modern_life',
        title: 'A New Student in Class',
        subtitle: 'A school story about confidence and friendship',
        icon: Icons.groups_rounded,
        estimatedMinutes: 8,
        textType: 'school story',
        orientationEnglish:
            'In this text, a student describes the first week of a new classmate.',
        orientationTurkish:
            'Bu metinde yeni bir sınıf arkadaşının ilk haftasını okuyacaksın.',
        readingTipTurkish:
            'B1 hikâyelerde karakterin duygularını ve değişimini takip et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'When Daniel joined our class in October, he did not speak much. During the first lesson, he sat at the back and looked at his notebook. Some students thought he was unfriendly, but I noticed that he simply looked nervous. Our teacher asked him a few easy questions, and Daniel answered very quietly.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'At lunch, I invited him to sit with my friends. At first, the conversation was slow because Daniel was afraid of making mistakes in English. Then we discovered that he liked basketball and science fiction films. After that, he started to smile and ask questions.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'By Friday, Daniel seemed more comfortable. He helped our group prepare a short presentation and explained one idea very clearly. I realised that new students may need time before people understand them. A quiet person is not always bored or rude; sometimes they are just waiting to feel safe.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'The next week, more students started speaking to Daniel before lessons. He still did not talk loudly, but he joined games at lunch and shared his ideas in group work. Small friendly actions made the classroom feel less strange for him.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'nervous',
            meaningEnglish: 'worried or not relaxed',
            meaningTurkish: 'gergin',
            example: 'He simply looked nervous.',
          ),
          ReadingGloss(
            word: 'unfriendly',
            meaningEnglish: 'not kind or welcoming',
            meaningTurkish: 'soğuk, arkadaşça olmayan',
            example: 'Some students thought he was unfriendly.',
          ),
          ReadingGloss(
            word: 'comfortable',
            meaningEnglish: 'relaxed and confident',
            meaningTurkish: 'rahat',
            example: 'Daniel seemed more comfortable.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b1_new_student_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main message of the text?',
            options: [
              'People may need time before they feel comfortable',
              'New students should never speak in class',
              'Basketball is more important than school',
              'Teachers should not ask questions',
            ],
            answer: 'People may need time before they feel comfortable',
            explanationEnglish:
                'The writer learns that quiet people may simply need time to feel safe.',
            explanationTurkish:
                'Yazar, sessiz kişilerin kendini güvende hissetmek için zamana ihtiyaç duyabileceğini anlıyor.',
          ),
          ReadingQuestion(
            id: 'b1_new_student_q2',
            type: ReadingQuestionType.detail,
            question: 'Where did Daniel sit during the first lesson?',
            options: [
              'At the back',
              'Near the door',
              'Next to the teacher',
              'In the front row'
            ],
            answer: 'At the back',
            explanationEnglish:
                'The first paragraph says Daniel sat at the back.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'b1_new_student_q3',
            type: ReadingQuestionType.inference,
            question: 'Why was Daniel quiet at first?',
            options: [
              'He was nervous',
              'He disliked everyone',
              'He was angry with the teacher',
              'He wanted to leave the school',
            ],
            answer: 'He was nervous',
            explanationEnglish:
                'The writer says Daniel looked nervous and was afraid of making mistakes.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'b1_new_student_q4',
            type: ReadingQuestionType.detail,
            question: 'What helped the conversation become easier?',
            options: [
              'They found shared interests',
              'The teacher gave homework',
              'Daniel left the table',
              'They watched a film in class',
            ],
            answer: 'They found shared interests',
            explanationEnglish:
                'They discovered Daniel liked basketball and science fiction films.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b1_new_student_q5',
            type: ReadingQuestionType.trueFalseNotGiven,
            question: 'Daniel helped with a group presentation.',
            options: ['True', 'False', 'Not Given'],
            answer: 'True',
            explanationEnglish:
                'Paragraph 3 says Daniel helped the group prepare a short presentation.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b1_new_student_q6',
            type: ReadingQuestionType.vocabularyInContext,
            question:
                'In the text, “comfortable” is closest in meaning to ____.',
            options: [
              'relaxed and confident',
              'very tired',
              'angry and loud',
              'confused'
            ],
            answer: 'relaxed and confident',
            explanationEnglish:
                'Daniel becomes more relaxed and joins the group work.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'nervous',
            originalSentence: 'He simply looked nervous.',
            newExampleSentence: 'I felt nervous before my speaking exam.',
            meaningEnglish: 'worried or not relaxed',
            meaningTurkish: 'gergin',
          ),
        ],
        reflectionPrompt:
            'What can students do to help a new classmate feel comfortable?',
        reflectionPromptTurkish:
            'Öğrenciler yeni bir sınıf arkadaşının rahat hissetmesi için ne yapabilir?',
      ),
      ReadingLesson(
        id: 'b1_why_people_like_short_videos',
        level: ReadingLevel.b1,
        clusterId: 'b1_modern_life',
        title: 'Why People Like Short Videos',
        subtitle: 'A short article about online habits',
        icon: Icons.smart_display_rounded,
        estimatedMinutes: 8,
        textType: 'everyday article',
        orientationEnglish:
            'In this text, you will read about why short videos are popular.',
        orientationTurkish:
            'Bu metinde kısa videoların neden popüler olduğunu okuyacaksın.',
        readingTipTurkish:
            'Neden-sonuç ilişkilerini takip et: because, so, as a result.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Short videos have become a normal part of daily life. Many people watch them while waiting for a bus, resting after school, or taking a short break from work. One reason is simple: they are easy to start. A video may last only fifteen seconds, so it does not feel like a serious decision.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Another reason is variety. In a few minutes, a person can see a cooking tip, a joke, a sports moment, and a language lesson. This variety makes people feel that they are always finding something new. However, it can also make longer activities, such as reading or studying, feel slower than before.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Short videos are not always a problem. They can teach useful ideas quickly and help creative people reach an audience. The real question is control. If people choose videos for a short rest, they may enjoy them. If they keep scrolling without noticing the time, the habit can become tiring.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'For this reason, some people set simple limits. They watch a few videos, then put the phone away and return to another activity. This does not make short videos bad; it helps them stay a small break instead of becoming the whole evening.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'variety',
            meaningEnglish: 'many different types of something',
            meaningTurkish: 'çeşitlilik',
            example: 'Another reason is variety.',
          ),
          ReadingGloss(
            word: 'audience',
            meaningEnglish: 'the people who watch or listen',
            meaningTurkish: 'izleyici kitlesi',
            example: 'Creative people can reach an audience.',
          ),
          ReadingGloss(
            word: 'scrolling',
            meaningEnglish: 'moving through content on a screen',
            meaningTurkish: 'ekranda kaydırma',
            example: 'They keep scrolling without noticing the time.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b1_short_videos_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the text mainly about?',
            options: [
              'Why short videos are popular and how they can affect habits',
              'Why all short videos should be banned',
              'How to become famous by making videos',
              'Why long films are no longer useful',
            ],
            answer:
                'Why short videos are popular and how they can affect habits',
            explanationEnglish:
                'The text explains reasons for popularity and discusses possible effects.',
          ),
          ReadingQuestion(
            id: 'b1_short_videos_q2',
            type: ReadingQuestionType.detail,
            question: 'Why are short videos easy to start?',
            options: [
              'They do not take much time',
              'They are always educational',
              'They are only for students',
              'They need no internet',
            ],
            answer: 'They do not take much time',
            explanationEnglish:
                'The first paragraph says a video may last only fifteen seconds.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'b1_short_videos_q3',
            type: ReadingQuestionType.detail,
            question: 'What can a person see in a few minutes?',
            options: [
              'Different types of content',
              'Only cooking videos',
              'Only school lessons',
              'A full documentary',
            ],
            answer: 'Different types of content',
            explanationEnglish:
                'Paragraph 2 gives examples such as a cooking tip, a joke, sports, and language learning.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b1_short_videos_q4',
            type: ReadingQuestionType.inference,
            question: 'What does the writer suggest about short videos?',
            options: [
              'They are useful if people control their time',
              'They are always harmful',
              'They are only good for children',
              'They should replace reading',
            ],
            answer: 'They are useful if people control their time',
            explanationEnglish:
                'The writer says the real question is control, not whether short videos are always bad.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b1_short_videos_q5',
            type: ReadingQuestionType.trueFalseNotGiven,
            question:
                'Short videos can help people learn useful ideas quickly.',
            options: ['True', 'False', 'Not Given'],
            answer: 'True',
            explanationEnglish:
                'Paragraph 3 says they can teach useful ideas quickly.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b1_short_videos_q6',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In the text, “variety” means ____.',
            options: [
              'many different types',
              'one repeated thing',
              'a difficult rule',
              'a long break',
            ],
            answer: 'many different types',
            explanationEnglish:
                'The paragraph lists several different types of videos.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'audience',
            originalSentence:
                'They can help creative people reach an audience.',
            newExampleSentence: 'The singer smiled when the audience clapped.',
            meaningEnglish: 'people who watch or listen',
            meaningTurkish: 'izleyici kitlesi',
          ),
        ],
        reflectionPrompt:
            'Do short videos help you learn, or do they distract you? Explain.',
        reflectionPromptTurkish:
            'Kısa videolar öğrenmene yardımcı mı oluyor, yoksa dikkatini mi dağıtıyor? Açıkla.',
      ),
      ReadingLesson(
        id: 'b1_my_first_part_time_job',
        level: ReadingLevel.b1,
        clusterId: 'b1_modern_life',
        title: 'My First Part-Time Job',
        subtitle: 'A personal experience about work and responsibility',
        icon: Icons.work_outline_rounded,
        estimatedMinutes: 8,
        textType: 'personal experience',
        orientationEnglish:
            'In this text, a young person describes their first part-time job.',
        orientationTurkish:
            'Bu metinde bir gencin ilk yarı zamanlı iş deneyimini okuyacaksın.',
        readingTipTurkish:
            'Deneyim metinlerinde önce problemi, sonra öğrenilen dersi bul.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Last year, I started working at a small bakery on weekends. At first, I thought the job would be easy because I liked cakes and bread. I soon learned that enjoying a place as a customer is very different from working there.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'My first task was to clean tables and put fresh bread on the shelves. Later, I helped customers choose cakes and packed their orders. The busiest time was Saturday morning. People were friendly, but they wanted fast service, so I had to stay calm and organised.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'After a few weeks, I became more confident. I learned how to speak politely to customers, manage my time, and ask for help when I was unsure. The job was tiring, but it taught me responsibility. Now I understand work better, and I respect people in service jobs more.',
          ),
          ReadingParagraph(
            number: 4,
            text:
                'The money was useful, but the experience was more important. I noticed how many small jobs must be done before a shop looks ready for customers. Now, when I buy something, I try to be patient and kind.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'customer',
            meaningEnglish: 'a person who buys something from a shop',
            meaningTurkish: 'müşteri',
            example:
                'Enjoying a place as a customer is different from working there.',
          ),
          ReadingGloss(
            word: 'organised',
            meaningEnglish: 'able to plan and keep things in order',
            meaningTurkish: 'düzenli',
            example: 'I had to stay calm and organised.',
          ),
          ReadingGloss(
            word: 'responsibility',
            meaningEnglish: 'the duty to take care of something',
            meaningTurkish: 'sorumluluk',
            example: 'It taught me responsibility.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'b1_job_q1',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main idea of the text?',
            options: [
              'A first job teaches the writer responsibility',
              'Bakeries should only sell bread',
              'Weekend jobs are always easy',
              'Customers do not like fast service',
            ],
            answer: 'A first job teaches the writer responsibility',
            explanationEnglish:
                'The writer explains what they learned from their first part-time job.',
          ),
          ReadingQuestion(
            id: 'b1_job_q2',
            type: ReadingQuestionType.detail,
            question: 'Where did the writer work?',
            options: [
              'At a bakery',
              'At a library',
              'At a sports centre',
              'At a cinema'
            ],
            answer: 'At a bakery',
            explanationEnglish:
                'The first paragraph says the writer worked at a small bakery.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'b1_job_q3',
            type: ReadingQuestionType.detail,
            question: 'What was one of the writer’s first tasks?',
            options: [
              'Cleaning tables',
              'Driving a car',
              'Teaching children',
              'Writing advertisements',
            ],
            answer: 'Cleaning tables',
            explanationEnglish:
                'Paragraph 2 says the first task was to clean tables.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b1_job_q4',
            type: ReadingQuestionType.inference,
            question: 'Why did the writer need to stay calm and organised?',
            options: [
              'Because customers wanted fast service',
              'Because the bakery was always empty',
              'Because the manager was never there',
              'Because the writer disliked bread',
            ],
            answer: 'Because customers wanted fast service',
            explanationEnglish:
                'The text says Saturday morning was busy and people wanted fast service.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'b1_job_q5',
            type: ReadingQuestionType.trueFalseNotGiven,
            question: 'The job made the writer respect service workers more.',
            options: ['True', 'False', 'Not Given'],
            answer: 'True',
            explanationEnglish:
                'The final sentence says the writer respects people in service jobs more.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'b1_job_q6',
            type: ReadingQuestionType.vocabularyInContext,
            question: 'In the text, “responsibility” means ____.',
            options: [
              'the duty to take care of something',
              'a sweet food',
              'a relaxed holiday',
              'a quick conversation',
            ],
            answer: 'the duty to take care of something',
            explanationEnglish:
                'The job taught the writer how to manage tasks and behave carefully.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'organised',
            originalSentence: 'I had to stay calm and organised.',
            newExampleSentence:
                'An organised student keeps notes and deadlines in order.',
            meaningEnglish: 'able to plan and keep things in order',
            meaningTurkish: 'düzenli',
          ),
        ],
        reflectionPrompt:
            'What kind of part-time job would you like to try? Why?',
        reflectionPromptTurkish:
            'Nasıl bir yarı zamanlı iş denemek isterdin? Neden?',
      ),
    ],
  ),
];
