import 'package:flutter/material.dart';

import 'reading_models.dart';

/// A2 Reading data.
/// Content rules:
/// - 100–200 words
/// - short stories, emails, notices, travel, advice
/// - simple main idea, sequence, detail, true/false, gap fill
/// - Turkish orientation/tip allowed, but no full translation

const List<ReadingCluster> readingA2Clusters = [
  ReadingCluster(
    id: 'a2_everyday_stories',
    level: ReadingLevel.a2,
    title: 'Everyday Stories',
    subtitle: 'Short stories, plans, holidays, and simple advice.',
    icon: Icons.travel_explore_rounded,
    lessons: [
      ReadingLesson(
        id: 'a2_antalya_holiday',
        level: ReadingLevel.a2,
        clusterId: 'a2_everyday_stories',
        title: 'A Holiday in Antalya',
        subtitle: 'A short past event story',
        icon: Icons.beach_access_rounded,
        estimatedMinutes: 7,
        textType: 'short personal story',
        orientationEnglish:
            'In this text, a student describes a short holiday in Antalya.',
        orientationTurkish:
            'Bu metinde bir öğrencinin Antalya tatilini okuyacaksın.',
        readingTipTurkish:
            'A2 metinlerde olay sırasını gösteren first, then, after that gibi kelimelere dikkat et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Last summer, I went to Antalya with my family. We stayed in a small hotel near the beach. The weather was hot and sunny every day, so we spent a lot of time outside.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'On the first day, we swam in the sea and ate fish at a restaurant. On the second day, we visited an old town and took many photos. I bought a small gift for my best friend.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'I really enjoyed the holiday because I relaxed and tried new food. Next year, I want to visit another city by the sea.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'relaxed',
            meaningEnglish: 'rested and felt calm',
            example: 'I relaxed and tried new food.',
          ),
          ReadingGloss(
            word: 'gift',
            meaningEnglish: 'something you give to another person',
            example: 'I bought a small gift for my best friend.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a2_antalya_q1',
            type: ReadingQuestionType.detail,
            question: 'Where did the writer stay?',
            options: [
              'In a small hotel near the beach',
              'In a big house in the city',
              'In a tent near a mountain',
              'In a school building',
            ],
            answer: 'In a small hotel near the beach',
            explanationEnglish:
                'Paragraph 1 says they stayed in a small hotel near the beach.',
            evidenceParagraph: 1,
            evidenceText: 'We stayed in a small hotel near the beach.',
          ),
          ReadingQuestion(
            id: 'a2_antalya_q2',
            type: ReadingQuestionType.sequence,
            question: 'Which event happened first?',
            options: [
              'They swam in the sea',
              'They visited an old town',
              'The writer bought a gift',
              'The writer planned next year’s trip',
            ],
            answer: 'They swam in the sea',
            explanationEnglish:
                'The text says they swam in the sea on the first day.',
            evidenceParagraph: 2,
            evidenceText: 'On the first day, we swam in the sea...',
          ),
          ReadingQuestion(
            id: 'a2_antalya_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'The weather was rainy every day.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish:
                'The text says the weather was hot and sunny every day.',
            evidenceParagraph: 1,
            evidenceText: 'The weather was hot and sunny every day.',
          ),
          ReadingQuestion(
            id: 'a2_antalya_q4',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the text mainly about?',
            options: [
              'A family holiday',
              'A school project',
              'A new restaurant',
              'A city problem',
            ],
            answer: 'A family holiday',
            explanationEnglish:
                'The writer describes a holiday with family in Antalya.',
          ),
          ReadingQuestion(
            id: 'a2_antalya_q5',
            type: ReadingQuestionType.gapFill,
            question: 'The writer bought a small ____ for a friend.',
            options: ['gift', 'ticket', 'hotel', 'beach'],
            answer: 'gift',
            explanationEnglish:
                'The text says, “I bought a small gift for my best friend.”',
            evidenceParagraph: 2,
            evidenceText: 'I bought a small gift for my best friend.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'relaxed',
            originalSentence:
                'I really enjoyed the holiday because I relaxed and tried new food.',
            newExampleSentence: 'After the exam, I relaxed at home.',
            meaningEnglish: 'rested and felt calm',
          ),
        ],
      ),
      ReadingLesson(
        id: 'a2_busy_saturday',
        level: ReadingLevel.a2,
        clusterId: 'a2_everyday_stories',
        title: 'A Busy Saturday',
        subtitle: 'A simple weekend story',
        icon: Icons.calendar_month_rounded,
        estimatedMinutes: 6,
        textType: 'short story',
        orientationEnglish:
            'In this text, a teenager talks about a busy Saturday.',
        orientationTurkish:
            'Bu metinde yoğun geçen bir cumartesi gününü okuyacaksın.',
        readingTipTurkish:
            'Olayları sıraya koyarken zaman ifadelerine dikkat et: in the morning, after lunch, in the evening.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'On Saturday morning, Deniz helped his father in the garden. They cleaned the small table and watered the flowers. Deniz did not like waking up early, but he enjoyed working outside.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'After lunch, he met his friends at the shopping centre. They looked at new shoes, drank lemonade, and talked about school. Deniz wanted to buy a T-shirt, but it was too expensive.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'In the evening, Deniz stayed at home. He watched a film with his sister and finished his English homework before bed.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'watered',
            meaningEnglish: 'put water on plants',
            example: 'They watered the flowers.',
          ),
          ReadingGloss(
            word: 'expensive',
            meaningEnglish: 'costing a lot of money',
            example: 'The T-shirt was too expensive.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a2_saturday_q1',
            type: ReadingQuestionType.detail,
            question: 'What did Deniz do in the morning?',
            options: [
              'He helped his father in the garden',
              'He watched a film',
              'He bought new shoes',
              'He went to school',
            ],
            answer: 'He helped his father in the garden',
            explanationEnglish:
                'Paragraph 1 says Deniz helped his father in the garden.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_saturday_q2',
            type: ReadingQuestionType.detail,
            question: 'Why didn’t Deniz buy the T-shirt?',
            options: [
              'It was too expensive',
              'It was too small',
              'He did not like the colour',
              'The shop was closed',
            ],
            answer: 'It was too expensive',
            explanationEnglish: 'The text says the T-shirt was too expensive.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_saturday_q3',
            type: ReadingQuestionType.sequence,
            question: 'What did Deniz do after lunch?',
            options: [
              'He met his friends',
              'He watered flowers',
              'He finished homework',
              'He watched a film',
            ],
            answer: 'He met his friends',
            explanationEnglish:
                'Paragraph 2 begins with “After lunch, he met his friends...”',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_saturday_q4',
            type: ReadingQuestionType.trueFalse,
            question: 'Deniz finished his English homework before bed.',
            options: ['True', 'False'],
            answer: 'True',
            explanationEnglish:
                'The final paragraph says he finished his English homework before bed.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'a2_saturday_q5',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the best title for the text?',
            options: [
              'A Busy Saturday',
              'A New School',
              'A Bad Holiday',
              'A Football Match',
            ],
            answer: 'A Busy Saturday',
            explanationEnglish:
                'The text describes different activities during one busy Saturday.',
          ),
        ],
      ),
      ReadingLesson(
        id: 'a2_new_shopping_centre',
        level: ReadingLevel.a2,
        clusterId: 'a2_everyday_stories',
        title: 'The New Shopping Centre',
        subtitle: 'A short notice-style text',
        icon: Icons.storefront_rounded,
        estimatedMinutes: 6,
        textType: 'simple description',
        orientationEnglish:
            'In this text, you will read about a new shopping centre in a town.',
        orientationTurkish:
            'Bu metinde şehirdeki yeni bir alışveriş merkezini okuyacaksın.',
        readingTipTurkish:
            'A2 açıklama metinlerinde yer, saat ve özellik bildiren cümleleri ayırmaya çalış.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'A new shopping centre opened in our town last week. It is next to the bus station, so it is easy to get there. There are many shops, a small cinema, and a children’s play area.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'On the first day, many people visited the centre. Some people bought clothes, and others had lunch in the food court. The café near the entrance was very popular.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'The shopping centre is open from ten in the morning to ten at night. My friends and I are going to visit it again next Saturday.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'entrance',
            meaningEnglish: 'the place where you go into a building',
            example: 'The café near the entrance was very popular.',
          ),
          ReadingGloss(
            word: 'popular',
            meaningEnglish: 'liked by many people',
            example: 'The café was very popular.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a2_shopping_q1',
            type: ReadingQuestionType.detail,
            question: 'Where is the shopping centre?',
            options: [
              'Next to the bus station',
              'Behind the school',
              'Near the old town',
              'Opposite the hospital',
            ],
            answer: 'Next to the bus station',
            explanationEnglish:
                'Paragraph 1 says it is next to the bus station.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_shopping_q2',
            type: ReadingQuestionType.detail,
            question: 'What can children use there?',
            options: [
              'A play area',
              'A swimming pool',
              'A library',
              'A sports field',
            ],
            answer: 'A play area',
            explanationEnglish: 'The text mentions a children’s play area.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_shopping_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'The shopping centre closes at six in the evening.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish: 'The text says it is open until ten at night.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'a2_shopping_q4',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the text mainly about?',
            options: [
              'A new place in town',
              'A bus problem',
              'A school project',
              'A film review',
            ],
            answer: 'A new place in town',
            explanationEnglish:
                'The whole text introduces the new shopping centre.',
          ),
          ReadingQuestion(
            id: 'a2_shopping_q5',
            type: ReadingQuestionType.gapFill,
            question: 'The café near the ____ was very popular.',
            options: ['entrance', 'station', 'cinema', 'school'],
            answer: 'entrance',
            explanationEnglish:
                'The text says, “The café near the entrance was very popular.”',
            evidenceParagraph: 2,
          ),
        ],
      ),
      ReadingLesson(
        id: 'a2_weekend_plan',
        level: ReadingLevel.a2,
        clusterId: 'a2_everyday_stories',
        title: 'A Weekend Plan',
        subtitle: 'A short future plan',
        icon: Icons.event_available_rounded,
        estimatedMinutes: 6,
        textType: 'simple plan',
        orientationEnglish:
            'In this text, two friends make a plan for the weekend.',
        orientationTurkish:
            'Bu metinde iki arkadaşın hafta sonu planını okuyacaksın.',
        readingTipTurkish:
            'Plan metinlerinde going to, want to ve zaman ifadelerini takip et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Emma and Leo are going to meet on Saturday afternoon. First, they want to visit a small bookshop in the city centre. Emma needs a new notebook, and Leo wants to buy a comic book.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'After the bookshop, they are going to walk to the park. They will take some sandwiches and fruit with them. If the weather is good, they will sit under the trees and read their new books.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'In the evening, Emma has to go home early because her cousins are coming for dinner. Leo is going to call his brother and watch a film at home.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'bookshop',
            meaningEnglish: 'a shop that sells books',
            meaningTurkish: 'kitapçı',
            example: 'They want to visit a small bookshop.',
          ),
          ReadingGloss(
            word: 'cousins',
            meaningEnglish: 'children of your aunt or uncle',
            meaningTurkish: 'kuzenler',
            example: 'Her cousins are coming for dinner.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a2_weekend_plan_q1',
            type: ReadingQuestionType.detail,
            question: 'When are Emma and Leo going to meet?',
            options: [
              'On Saturday afternoon',
              'On Sunday morning',
              'On Friday evening',
              'On Monday afternoon',
            ],
            answer: 'On Saturday afternoon',
            explanationEnglish:
                'The first sentence says they are going to meet on Saturday afternoon.',
            explanationTurkish:
                'İlk cümlede cumartesi öğleden sonra buluşacakları söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_weekend_plan_q2',
            type: ReadingQuestionType.detail,
            question: 'What does Emma need?',
            options: [
              'A new notebook',
              'A comic book',
              'A new phone',
              'A sandwich',
            ],
            answer: 'A new notebook',
            explanationEnglish: 'Emma needs a new notebook.',
            explanationTurkish:
                'Metinde Emma’nın yeni bir deftere ihtiyacı olduğu söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_weekend_plan_q3',
            type: ReadingQuestionType.sequence,
            question: 'What will they do after the bookshop?',
            options: [
              'Walk to the park',
              'Go home early',
              'Watch a film',
              'Cook dinner',
            ],
            answer: 'Walk to the park',
            explanationEnglish:
                'Paragraph 2 says they are going to walk to the park after the bookshop.',
            explanationTurkish:
                'İkinci paragrafta kitapçıdan sonra parka yürüyecekleri söyleniyor.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_weekend_plan_q4',
            type: ReadingQuestionType.trueFalse,
            question: 'Emma has to go home early in the evening.',
            options: ['True', 'False'],
            answer: 'True',
            explanationEnglish:
                'The text says Emma has to go home early because her cousins are coming.',
            explanationTurkish:
                'Emma kuzenleri geleceği için eve erken gitmek zorunda.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'a2_weekend_plan_q5',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the text mainly about?',
            options: [
              'A weekend plan',
              'A school exam',
              'A family problem',
              'A new restaurant',
            ],
            answer: 'A weekend plan',
            explanationEnglish:
                'The text describes Emma and Leo’s plan for Saturday.',
            explanationTurkish:
                'Metin Emma ve Leo’nun cumartesi planını anlatıyor.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'bookshop',
            originalSentence:
                'First, they want to visit a small bookshop in the city centre.',
            newExampleSentence: 'There is a quiet bookshop near the station.',
            meaningEnglish: 'a shop that sells books',
            meaningTurkish: 'kitapçı',
          ),
        ],
        reflectionPrompt:
            'Write your own simple weekend plan in three sentences.',
        reflectionPromptTurkish: 'Kendi hafta sonu planını üç cümleyle yaz.',
      ),
      ReadingLesson(
        id: 'a2_shopping_for_a_gift',
        level: ReadingLevel.a2,
        clusterId: 'a2_everyday_stories',
        title: 'Shopping for a Gift',
        subtitle: 'A simple shopping story',
        icon: Icons.card_giftcard_rounded,
        estimatedMinutes: 6,
        textType: 'short story',
        orientationEnglish:
            'In this text, a teenager looks for a birthday gift.',
        orientationTurkish:
            'Bu metinde bir gencin doğum günü hediyesi aramasını okuyacaksın.',
        readingTipTurkish:
            'Alışveriş metinlerinde fiyat, kişi ve tercih bilgilerine dikkat et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Nora wants to buy a birthday gift for her brother. He likes music, football, and funny T-shirts. Nora goes to a small shopping street after school.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'First, she looks at a music shop, but the headphones are too expensive. Then she finds a blue football T-shirt in another shop. It is not cheap, but it is in her brother’s favourite colour.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Nora buys the T-shirt and a small birthday card. At home, she writes a short message on the card. She hopes her brother will like the gift.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'headphones',
            meaningEnglish: 'a device you wear to listen to sound',
            meaningTurkish: 'kulaklık',
            example: 'The headphones are too expensive.',
          ),
          ReadingGloss(
            word: 'favourite',
            meaningEnglish: 'liked the most',
            meaningTurkish: 'favori, en sevilen',
            example: 'It is in her brother’s favourite colour.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a2_gift_q1',
            type: ReadingQuestionType.detail,
            question: 'Who is the gift for?',
            options: [
              'Nora’s brother',
              'Nora’s father',
              'Nora’s friend',
              'Nora’s teacher',
            ],
            answer: 'Nora’s brother',
            explanationEnglish:
                'The text says Nora wants to buy a birthday gift for her brother.',
            explanationTurkish:
                'Metinde Nora’nın kardeşi için hediye almak istediği söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_gift_q2',
            type: ReadingQuestionType.detail,
            question: 'Why doesn’t Nora buy the headphones?',
            options: [
              'They are too expensive',
              'They are broken',
              'They are red',
              'They are too small',
            ],
            answer: 'They are too expensive',
            explanationEnglish:
                'Paragraph 2 says the headphones are too expensive.',
            explanationTurkish:
                'İkinci paragrafta kulaklığın çok pahalı olduğu söyleniyor.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_gift_q3',
            type: ReadingQuestionType.detail,
            question: 'What does Nora buy?',
            options: [
              'A blue football T-shirt and a card',
              'Headphones and a bag',
              'A music book',
              'A football ticket',
            ],
            answer: 'A blue football T-shirt and a card',
            explanationEnglish:
                'Nora buys the T-shirt and a small birthday card.',
            explanationTurkish:
                'Nora tişörtü ve küçük bir doğum günü kartını alıyor.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'a2_gift_q4',
            type: ReadingQuestionType.trueFalse,
            question: 'The T-shirt is in her brother’s favourite colour.',
            options: ['True', 'False'],
            answer: 'True',
            explanationEnglish:
                'The text says the T-shirt is in his favourite colour.',
            explanationTurkish:
                'Metinde tişörtün kardeşinin en sevdiği renkte olduğu söyleniyor.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_gift_q5',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the best title for this story?',
            options: [
              'Shopping for a Gift',
              'A Football Match',
              'A Music Lesson',
              'A New School Bag',
            ],
            answer: 'Shopping for a Gift',
            explanationEnglish:
                'The whole story is about Nora buying a birthday gift.',
            explanationTurkish:
                'Metin Nora’nın doğum günü hediyesi almasını anlatıyor.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'expensive',
            originalSentence: 'The headphones are too expensive.',
            newExampleSentence: 'This jacket is nice, but it is expensive.',
            meaningEnglish: 'costing a lot of money',
            meaningTurkish: 'pahalı',
          ),
        ],
        reflectionPrompt: 'Write about a gift you want to buy for someone.',
        reflectionPromptTurkish:
            'Birine almak istediğin bir hediye hakkında yaz.',
      ),
      ReadingLesson(
        id: 'a2_a_rainy_day',
        level: ReadingLevel.a2,
        clusterId: 'a2_everyday_stories',
        title: 'A Rainy Day',
        subtitle: 'A simple weather story',
        icon: Icons.umbrella_rounded,
        estimatedMinutes: 6,
        textType: 'short story',
        orientationEnglish:
            'In this text, a rainy day changes two friends’ plans.',
        orientationTurkish:
            'Bu metinde yağmurlu bir günün iki arkadaşın planını nasıl değiştirdiğini okuyacaksın.',
        readingTipTurkish:
            'Plan değişikliklerini anlamak için but, so ve because kelimelerine dikkat et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Maya and Ben wanted to ride their bikes on Sunday morning. They checked the weather on Ben’s phone. It was cloudy, but the app said it would not rain before lunch.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'After twenty minutes, dark clouds came, and it started to rain. Maya had a small umbrella, but Ben did not. They ran to a library near the park and waited there.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'At first, they were unhappy, but then they found an interesting comic book. They read it together and laughed. The rainy day became a good day in the end.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'cloudy',
            meaningEnglish: 'with many clouds in the sky',
            meaningTurkish: 'bulutlu',
            example: 'It was cloudy in the morning.',
          ),
          ReadingGloss(
            word: 'umbrella',
            meaningEnglish: 'an object that protects you from rain',
            meaningTurkish: 'şemsiye',
            example: 'Maya had a small umbrella.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a2_rainy_day_q1',
            type: ReadingQuestionType.detail,
            question: 'What did Maya and Ben want to do?',
            options: [
              'Ride their bikes',
              'Go shopping',
              'Cook lunch',
              'Watch a film',
            ],
            answer: 'Ride their bikes',
            explanationEnglish:
                'The first paragraph says they wanted to ride their bikes.',
            explanationTurkish:
                'İlk paragrafta bisiklet sürmek istedikleri söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_rainy_day_q2',
            type: ReadingQuestionType.detail,
            question: 'Where did they go when it started to rain?',
            options: [
              'To a library',
              'To a cafe',
              'To Maya’s house',
              'To a bus station',
            ],
            answer: 'To a library',
            explanationEnglish: 'They ran to a library near the park.',
            explanationTurkish: 'Parkın yakınındaki bir kütüphaneye koştular.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_rainy_day_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'Ben had a small umbrella.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish: 'Maya had an umbrella, but Ben did not.',
            explanationTurkish: 'Şemsiye Maya’da vardı, Ben’de yoktu.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_rainy_day_q4',
            type: ReadingQuestionType.sequence,
            question: 'What happened after they went to the library?',
            options: [
              'They found a comic book',
              'They rode bikes again',
              'They bought umbrellas',
              'They called a taxi',
            ],
            answer: 'They found a comic book',
            explanationEnglish:
                'In the library, they found an interesting comic book.',
            explanationTurkish: 'Kütüphanede ilginç bir çizgi roman buldular.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'a2_rainy_day_q5',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the main idea of the text?',
            options: [
              'A bad plan can become a good day',
              'Libraries are always noisy',
              'Rain is never useful',
              'Phones are difficult to use',
            ],
            answer: 'A bad plan can become a good day',
            explanationEnglish:
                'Their biking plan changed, but they enjoyed the library.',
            explanationTurkish:
                'Bisiklet planı değişti ama kütüphanede güzel zaman geçirdiler.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'cloudy',
            originalSentence:
                'It was cloudy, but the app said it would not rain.',
            newExampleSentence: 'It is cloudy today, so take a jacket.',
            meaningEnglish: 'with many clouds',
            meaningTurkish: 'bulutlu',
          ),
        ],
        reflectionPrompt: 'Write about something you can do on a rainy day.',
        reflectionPromptTurkish:
            'Yağmurlu bir günde yapabileceğin bir şey hakkında yaz.',
      ),
      ReadingLesson(
        id: 'a2_simple_travel_plan',
        level: ReadingLevel.a2,
        clusterId: 'a2_everyday_stories',
        title: 'A Simple Travel Plan',
        subtitle: 'A short email about travel',
        icon: Icons.flight_takeoff_rounded,
        estimatedMinutes: 6,
        textType: 'simple email',
        orientationEnglish:
            'In this text, you will read a short email about a travel plan.',
        orientationTurkish:
            'Bu metinde basit bir seyahat planı anlatan kısa bir e-posta okuyacaksın.',
        readingTipTurkish:
            'E-postalarda tarih, ulaşım ve yapılacak aktiviteleri ayrı ayrı takip et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Hi Alex, I am writing about our trip next month. We are going to leave on Friday morning by train. The journey takes about three hours, so we will arrive before lunch.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'I booked a small hotel near the main square. It is not expensive, and breakfast is included. On the first day, we can walk around the old streets and take photos.',
          ),
          ReadingParagraph(
            number: 3,
            text:
                'Please bring comfortable shoes and a light jacket. The evenings may be cool. I am very excited because this will be our first trip together.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'journey',
            meaningEnglish: 'travel from one place to another',
            meaningTurkish: 'yolculuk',
            example: 'The journey takes about three hours.',
          ),
          ReadingGloss(
            word: 'included',
            meaningEnglish: 'part of the price or plan',
            meaningTurkish: 'dahil',
            example: 'Breakfast is included.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a2_travel_plan_q1',
            type: ReadingQuestionType.detail,
            question: 'How are they going to travel?',
            options: ['By train', 'By plane', 'By bus', 'By car'],
            answer: 'By train',
            explanationEnglish:
                'The email says they are going to leave by train.',
            explanationTurkish: 'E-postada trenle yola çıkacakları söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a2_travel_plan_q2',
            type: ReadingQuestionType.detail,
            question: 'Where is the hotel?',
            options: [
              'Near the main square',
              'Near the airport',
              'Outside the city',
              'Next to a school',
            ],
            answer: 'Near the main square',
            explanationEnglish:
                'The writer booked a small hotel near the main square.',
            explanationTurkish:
                'Yazar ana meydanın yakınında küçük bir otel ayırtmış.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_travel_plan_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'Breakfast is included at the hotel.',
            options: ['True', 'False'],
            answer: 'True',
            explanationEnglish: 'The text says breakfast is included.',
            explanationTurkish: 'Metinde kahvaltının dahil olduğu söyleniyor.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a2_travel_plan_q4',
            type: ReadingQuestionType.detail,
            question: 'What should Alex bring?',
            options: [
              'Comfortable shoes and a light jacket',
              'A heavy coat and gloves',
              'A swimsuit and towel',
              'A notebook and pencil',
            ],
            answer: 'Comfortable shoes and a light jacket',
            explanationEnglish:
                'The writer asks Alex to bring comfortable shoes and a light jacket.',
            explanationTurkish:
                'Yazar Alex’ten rahat ayakkabı ve hafif bir ceket getirmesini istiyor.',
            evidenceParagraph: 3,
          ),
          ReadingQuestion(
            id: 'a2_travel_plan_q5',
            type: ReadingQuestionType.mainIdea,
            question: 'What is the email mainly about?',
            options: [
              'A travel plan',
              'A hotel complaint',
              'A school timetable',
              'A restaurant menu',
            ],
            answer: 'A travel plan',
            explanationEnglish:
                'The email gives information about a future trip.',
            explanationTurkish:
                'E-posta gelecek bir seyahat hakkında bilgi veriyor.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'journey',
            originalSentence: 'The journey takes about three hours.',
            newExampleSentence:
                'The journey from my town to the city is short.',
            meaningEnglish: 'travel from one place to another',
            meaningTurkish: 'yolculuk',
          ),
        ],
        reflectionPrompt:
            'Write three sentences about a trip you want to take.',
        reflectionPromptTurkish:
            'Gitmek istediğin bir seyahat hakkında üç cümle yaz.',
      ),
    ],
  ),
];
