import 'package:flutter/material.dart';

import 'reading_models.dart';

/// A1 Reading data.
/// Content rules:
/// - 50–100 words
/// - simple, warm, real-world texts
/// - direct comprehension questions
/// - Turkish orientation/tips allowed
/// - no full Turkish translation of the reading text

const List<ReadingCluster> readingA1Clusters = [
  ReadingCluster(
    id: 'a1_daily_world',
    level: ReadingLevel.a1,
    title: 'Daily World',
    subtitle: 'People, rooms, school, and simple routines.',
    icon: Icons.wb_sunny_rounded,
    lessons: [
      ReadingLesson(
        id: 'a1_my_classroom',
        level: ReadingLevel.a1,
        clusterId: 'a1_daily_world',
        title: 'My Classroom',
        subtitle: 'A short room description',
        icon: Icons.school_rounded,
        estimatedMinutes: 4,
        textType: 'short description',
        orientationEnglish:
            'In this text, a student describes a simple classroom.',
        orientationTurkish: 'Bu metinde bir öğrencinin sınıfını tanıyacaksın.',
        readingTipTurkish:
            'A1 metinlerde önce kişiyi ve yeri bul. Sonra eşyaları ve sayıları takip et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'This is my classroom. It is small, but it is nice. There are twelve students in my class. There is a big whiteboard on the wall. There are two windows and one door.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'My teacher is Mr Green. He is friendly. My desk is near the window. My bag is under the desk. I like my classroom because it is quiet.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'whiteboard',
            meaningEnglish: 'a board teachers write on',
            meaningTurkish: 'yazı tahtası',
            example: 'There is a big whiteboard on the wall.',
          ),
          ReadingGloss(
            word: 'quiet',
            meaningEnglish: 'not noisy',
            meaningTurkish: 'sessiz',
            example: 'I like my classroom because it is quiet.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a1_my_classroom_q1',
            type: ReadingQuestionType.detail,
            question: 'How many students are there in the class?',
            options: ['Ten', 'Twelve', 'Twenty'],
            answer: 'Twelve',
            explanationEnglish:
                'The text says, “There are twelve students in my class.”',
            explanationTurkish:
                'Metinde “There are twelve students in my class” deniyor.',
            evidenceParagraph: 1,
            evidenceText: 'There are twelve students in my class.',
          ),
          ReadingQuestion(
            id: 'a1_my_classroom_q2',
            type: ReadingQuestionType.trueFalse,
            question: 'The classroom is big.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish:
                'The text says the classroom is small, but nice.',
            explanationTurkish:
                'Metinde sınıfın küçük ama güzel olduğu söyleniyor.',
            evidenceParagraph: 1,
            evidenceText: 'It is small, but it is nice.',
          ),
          ReadingQuestion(
            id: 'a1_my_classroom_q3',
            type: ReadingQuestionType.detail,
            question: 'Where is the student’s bag?',
            options: ['On the desk', 'Under the desk', 'Near the door'],
            answer: 'Under the desk',
            explanationEnglish: 'The student says, “My bag is under the desk.”',
            explanationTurkish: 'Öğrenci “My bag is under the desk” diyor.',
            evidenceParagraph: 2,
            evidenceText: 'My bag is under the desk.',
          ),
          ReadingQuestion(
            id: 'a1_my_classroom_q4',
            type: ReadingQuestionType.detail,
            question: 'Why does the student like the classroom?',
            options: ['It is quiet', 'It is very big', 'It has many doors'],
            answer: 'It is quiet',
            explanationEnglish:
                'The final sentence says the classroom is quiet.',
            explanationTurkish: 'Son cümlede sınıfın sessiz olduğu söyleniyor.',
            evidenceParagraph: 2,
            evidenceText: 'I like my classroom because it is quiet.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'quiet',
            originalSentence: 'I like my classroom because it is quiet.',
            newExampleSentence: 'The library is quiet in the morning.',
            meaningEnglish: 'not noisy',
            meaningTurkish: 'sessiz',
          ),
        ],
      ),
      ReadingLesson(
        id: 'a1_saras_morning',
        level: ReadingLevel.a1,
        clusterId: 'a1_daily_world',
        title: 'Sara’s Morning',
        subtitle: 'A simple daily routine',
        icon: Icons.alarm_rounded,
        estimatedMinutes: 5,
        textType: 'short routine',
        orientationEnglish:
            'In this text, Sara talks about her morning routine.',
        orientationTurkish: 'Bu metinde Sara’nın sabah rutinini okuyacaksın.',
        readingTipTurkish:
            'Rutin metinlerinde saatleri ve her gün yapılan işleri takip et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Sara is a student. She gets up at seven o’clock. She washes her face and has breakfast. She usually eats bread, cheese, and an egg.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Sara leaves home at eight. Her school is near her house, so she walks to school. Her first lesson starts at half past eight.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'usually',
            meaningEnglish: 'most of the time',
            meaningTurkish: 'genellikle',
            example: 'She usually eats bread, cheese, and an egg.',
          ),
          ReadingGloss(
            word: 'near',
            meaningEnglish: 'not far',
            meaningTurkish: 'yakın',
            example: 'Her school is near her house.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a1_saras_morning_q1',
            type: ReadingQuestionType.detail,
            question: 'What time does Sara get up?',
            options: ['At seven', 'At eight', 'At half past eight'],
            answer: 'At seven',
            explanationEnglish: 'The text says Sara gets up at seven o’clock.',
            explanationTurkish:
                'Metinde Sara’nın saat yedide kalktığı söyleniyor.',
            evidenceParagraph: 1,
            evidenceText: 'She gets up at seven o’clock.',
          ),
          ReadingQuestion(
            id: 'a1_saras_morning_q2',
            type: ReadingQuestionType.detail,
            question: 'What does Sara usually eat for breakfast?',
            options: [
              'Bread, cheese, and an egg',
              'Rice and chicken',
              'Soup and salad',
            ],
            answer: 'Bread, cheese, and an egg',
            explanationEnglish: 'Paragraph 1 lists bread, cheese, and an egg.',
            explanationTurkish:
                'Birinci paragrafta ekmek, peynir ve yumurta geçiyor.',
            evidenceParagraph: 1,
            evidenceText: 'She usually eats bread, cheese, and an egg.',
          ),
          ReadingQuestion(
            id: 'a1_saras_morning_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'Sara’s school is far from her house.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish: 'The text says her school is near her house.',
            explanationTurkish:
                'Metinde okulunun evine yakın olduğu söyleniyor.',
            evidenceParagraph: 2,
            evidenceText: 'Her school is near her house.',
          ),
          ReadingQuestion(
            id: 'a1_saras_morning_q4',
            type: ReadingQuestionType.detail,
            question: 'How does Sara go to school?',
            options: ['She walks', 'She takes a bus', 'She rides a bike'],
            answer: 'She walks',
            explanationEnglish: 'The text says she walks to school.',
            explanationTurkish: 'Metinde okula yürüyerek gittiği söyleniyor.',
            evidenceParagraph: 2,
            evidenceText: 'She walks to school.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'usually',
            originalSentence: 'She usually eats bread, cheese, and an egg.',
            newExampleSentence: 'I usually drink tea in the morning.',
            meaningEnglish: 'most of the time',
            meaningTurkish: 'genellikle',
          ),
        ],
      ),
      ReadingLesson(
        id: 'a1_my_bedroom',
        level: ReadingLevel.a1,
        clusterId: 'a1_daily_world',
        title: 'My Bedroom',
        subtitle: 'A simple place description',
        icon: Icons.bed_rounded,
        estimatedMinutes: 4,
        textType: 'room description',
        orientationEnglish: 'In this text, a boy describes his bedroom.',
        orientationTurkish: 'Bu metinde bir çocuğun odasını okuyacaksın.',
        readingTipTurkish:
            'Oda anlatımlarında there is / there are ifadelerine dikkat et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'My bedroom is small and clean. There is a bed near the window. There is a blue desk next to the bed. My books are on the desk.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'There are two posters on the wall. My football is under the chair. I like my room because it is comfortable.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'comfortable',
            meaningEnglish: 'nice to use or sit in',
            meaningTurkish: 'rahat',
            example: 'I like my room because it is comfortable.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a1_bedroom_q1',
            type: ReadingQuestionType.detail,
            question: 'Where is the bed?',
            options: ['Near the window', 'Under the chair', 'On the desk'],
            answer: 'Near the window',
            explanationEnglish:
                'The text says, “There is a bed near the window.”',
            explanationTurkish:
                'Metinde yatağın pencerenin yanında olduğu söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_bedroom_q2',
            type: ReadingQuestionType.detail,
            question: 'What colour is the desk?',
            options: ['Blue', 'Green', 'White'],
            answer: 'Blue',
            explanationEnglish: 'The text says there is a blue desk.',
            explanationTurkish: 'Metinde mavi bir masa olduğu söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_bedroom_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'There are two posters on the wall.',
            options: ['True', 'False'],
            answer: 'True',
            explanationEnglish:
                'The second paragraph says there are two posters on the wall.',
            explanationTurkish:
                'İkinci paragrafta duvarda iki poster olduğu söyleniyor.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a1_bedroom_q4',
            type: ReadingQuestionType.detail,
            question: 'Where is the football?',
            options: ['Under the chair', 'On the bed', 'Near the window'],
            answer: 'Under the chair',
            explanationEnglish:
                'The text says, “My football is under the chair.”',
            explanationTurkish:
                'Metinde futbol topunun sandalyenin altında olduğu söyleniyor.',
            evidenceParagraph: 2,
          ),
        ],
      ),
      ReadingLesson(
        id: 'a1_my_school_bag',
        level: ReadingLevel.a1,
        clusterId: 'a1_daily_world',
        title: 'My School Bag',
        subtitle: 'A short object description',
        icon: Icons.backpack_rounded,
        estimatedMinutes: 4,
        textType: 'short description',
        orientationEnglish:
            'In this text, a student talks about the things in a school bag.',
        orientationTurkish:
            'Bu metinde bir öğrencinin okul çantasındaki eşyaları okuyacaksın.',
        readingTipTurkish:
            'A1 metinlerde renkleri, sayıları ve yer ifadelerini takip et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'This is my school bag. It is black and blue. I have three books, two notebooks, and a pencil case in my bag. My English book is big.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'There is a small bottle of water near my books. My lunch box is not in my bag. It is on the kitchen table.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'pencil case',
            meaningEnglish: 'a small bag for pencils and pens',
            meaningTurkish: 'kalemlik',
            example: 'I have a pencil case in my bag.',
          ),
          ReadingGloss(
            word: 'bottle',
            meaningEnglish: 'a container for water',
            meaningTurkish: 'şişe',
            example: 'There is a small bottle of water.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a1_school_bag_q1',
            type: ReadingQuestionType.detail,
            question: 'What colour is the school bag?',
            options: ['Black and blue', 'Red and white', 'Green and yellow'],
            answer: 'Black and blue',
            explanationEnglish: 'The text says the bag is black and blue.',
            explanationTurkish:
                'Metinde çantanın siyah ve mavi olduğu söyleniyor.',
            evidenceParagraph: 1,
            evidenceText: 'It is black and blue.',
          ),
          ReadingQuestion(
            id: 'a1_school_bag_q2',
            type: ReadingQuestionType.detail,
            question: 'How many books are in the bag?',
            options: ['Two', 'Three', 'Four'],
            answer: 'Three',
            explanationEnglish: 'The student has three books in the bag.',
            explanationTurkish: 'Öğrencinin çantasında üç kitap var.',
            evidenceParagraph: 1,
            evidenceText: 'I have three books...',
          ),
          ReadingQuestion(
            id: 'a1_school_bag_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'The English book is small.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish: 'The text says the English book is big.',
            explanationTurkish:
                'Metinde İngilizce kitabının büyük olduğu söyleniyor.',
            evidenceParagraph: 1,
            evidenceText: 'My English book is big.',
          ),
          ReadingQuestion(
            id: 'a1_school_bag_q4',
            type: ReadingQuestionType.detail,
            question: 'Where is the lunch box?',
            options: ['On the kitchen table', 'In the bag', 'Under the books'],
            answer: 'On the kitchen table',
            explanationEnglish:
                'The lunch box is not in the bag. It is on the kitchen table.',
            explanationTurkish:
                'Yemek kutusu çantada değil, mutfak masasının üzerinde.',
            evidenceParagraph: 2,
            evidenceText: 'It is on the kitchen table.',
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'bottle',
            originalSentence: 'There is a small bottle of water near my books.',
            newExampleSentence: 'I have a water bottle on my desk.',
            meaningEnglish: 'a container for water',
            meaningTurkish: 'şişe',
          ),
        ],
        reflectionPrompt: 'Write two sentences about the things in your bag.',
        reflectionPromptTurkish: 'Çantandaki eşyalar hakkında iki cümle yaz.',
      ),
      ReadingLesson(
        id: 'a1_at_the_cafe',
        level: ReadingLevel.a1,
        clusterId: 'a1_daily_world',
        title: 'At the Cafe',
        subtitle: 'A simple food and drink text',
        icon: Icons.local_cafe_rounded,
        estimatedMinutes: 4,
        textType: 'short dialogue-style description',
        orientationEnglish: 'In this text, two friends are at a small cafe.',
        orientationTurkish:
            'Bu metinde iki arkadaşın küçük bir kafede ne yaptığını okuyacaksın.',
        readingTipTurkish:
            'Yiyecek ve içecek kelimelerini bul. Kim ne istiyor, buna dikkat et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'Lena and Tom are at a small cafe. Lena wants tea and a cake. Tom wants orange juice and a sandwich. They sit near the window.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'The cafe is not noisy. The waiter is friendly. Lena and Tom talk about school. They are happy because the food is good.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'waiter',
            meaningEnglish: 'a person who brings food in a cafe',
            meaningTurkish: 'garson',
            example: 'The waiter is friendly.',
          ),
          ReadingGloss(
            word: 'sandwich',
            meaningEnglish: 'food with bread and filling',
            meaningTurkish: 'sandviç',
            example: 'Tom wants orange juice and a sandwich.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a1_cafe_q1',
            type: ReadingQuestionType.detail,
            question: 'What does Lena want?',
            options: ['Tea and a cake', 'Coffee and soup', 'Juice and pizza'],
            answer: 'Tea and a cake',
            explanationEnglish: 'The text says Lena wants tea and a cake.',
            explanationTurkish:
                'Metinde Lena’nın çay ve kek istediği söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_cafe_q2',
            type: ReadingQuestionType.detail,
            question: 'Where do they sit?',
            options: ['Near the window', 'Near the door', 'In the garden'],
            answer: 'Near the window',
            explanationEnglish: 'They sit near the window.',
            explanationTurkish: 'Pencerenin yanında oturuyorlar.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_cafe_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'The cafe is noisy.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish: 'The text says the cafe is not noisy.',
            explanationTurkish:
                'Metinde kafenin gürültülü olmadığı söyleniyor.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a1_cafe_q4',
            type: ReadingQuestionType.detail,
            question: 'Why are Lena and Tom happy?',
            options: [
              'The food is good',
              'The cafe is big',
              'The school is near'
            ],
            answer: 'The food is good',
            explanationEnglish: 'They are happy because the food is good.',
            explanationTurkish: 'Yemek iyi olduğu için mutlular.',
            evidenceParagraph: 2,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'friendly',
            originalSentence: 'The waiter is friendly.',
            newExampleSentence: 'My new teacher is friendly.',
            meaningEnglish: 'kind and nice',
            meaningTurkish: 'samimi, iyi',
          ),
        ],
        reflectionPrompt: 'Write three things you can order at a cafe.',
        reflectionPromptTurkish: 'Bir kafede sipariş edebileceğin üç şeyi yaz.',
      ),
      ReadingLesson(
        id: 'a1_my_family',
        level: ReadingLevel.a1,
        clusterId: 'a1_daily_world',
        title: 'My Family',
        subtitle: 'A simple family description',
        icon: Icons.family_restroom_rounded,
        estimatedMinutes: 4,
        textType: 'short description',
        orientationEnglish: 'In this text, a girl describes her family.',
        orientationTurkish:
            'Bu metinde bir kızın ailesini nasıl anlattığını okuyacaksın.',
        readingTipTurkish: 'Aile üyelerini ve kişi özelliklerini takip et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'My name is Mia. I live with my mother, my father, and my little brother. My mother is a nurse. My father is a bus driver.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'My brother is five years old. He likes toy cars. We have a cat, too. Its name is Cookie. My family is small, but we are happy.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'nurse',
            meaningEnglish: 'a person who helps sick people',
            meaningTurkish: 'hemşire',
            example: 'My mother is a nurse.',
          ),
          ReadingGloss(
            word: 'driver',
            meaningEnglish: 'a person who drives a vehicle',
            meaningTurkish: 'sürücü',
            example: 'My father is a bus driver.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a1_family_q1',
            type: ReadingQuestionType.detail,
            question: 'Who does Mia live with?',
            options: [
              'Her mother, father, and brother',
              'Her grandparents',
              'Her friends',
            ],
            answer: 'Her mother, father, and brother',
            explanationEnglish:
                'Mia lives with her mother, father, and little brother.',
            explanationTurkish:
                'Mia annesi, babası ve küçük kardeşiyle yaşıyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_family_q2',
            type: ReadingQuestionType.detail,
            question: 'What is Mia’s mother?',
            options: ['A nurse', 'A teacher', 'A driver'],
            answer: 'A nurse',
            explanationEnglish: 'The text says her mother is a nurse.',
            explanationTurkish: 'Metinde annesinin hemşire olduğu söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_family_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'Mia has a dog.',
            options: ['True', 'False'],
            answer: 'False',
            explanationEnglish: 'Mia has a cat, not a dog.',
            explanationTurkish: 'Mia’nın köpeği değil, kedisi var.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a1_family_q4',
            type: ReadingQuestionType.detail,
            question: 'What is the cat’s name?',
            options: ['Cookie', 'Mia', 'Tom'],
            answer: 'Cookie',
            explanationEnglish: 'The cat’s name is Cookie.',
            explanationTurkish: 'Kedinin adı Cookie.',
            evidenceParagraph: 2,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'little',
            originalSentence: 'I live with my little brother.',
            newExampleSentence: 'My little sister is six.',
            meaningEnglish: 'young or small',
            meaningTurkish: 'küçük',
          ),
        ],
        reflectionPrompt: 'Write two sentences about your family or a friend.',
        reflectionPromptTurkish:
            'Ailen veya bir arkadaşın hakkında iki cümle yaz.',
      ),
      ReadingLesson(
        id: 'a1_a_small_park',
        level: ReadingLevel.a1,
        clusterId: 'a1_daily_world',
        title: 'A Small Park',
        subtitle: 'A simple place description',
        icon: Icons.park_rounded,
        estimatedMinutes: 4,
        textType: 'place description',
        orientationEnglish: 'In this text, you will read about a small park.',
        orientationTurkish: 'Bu metinde küçük bir park hakkında okuyacaksın.',
        readingTipTurkish:
            'Yer anlatımlarında there is / there are ve sıfatlara dikkat et.',
        paragraphs: [
          ReadingParagraph(
            number: 1,
            text:
                'There is a small park near my house. It has green trees and many flowers. There are two benches under a big tree.',
          ),
          ReadingParagraph(
            number: 2,
            text:
                'Children play football in the park after school. Old people sit on the benches. I go there with my sister on Sundays.',
          ),
        ],
        glosses: [
          ReadingGloss(
            word: 'bench',
            meaningEnglish: 'a long seat for people',
            meaningTurkish: 'bank',
            example: 'There are two benches under a big tree.',
          ),
          ReadingGloss(
            word: 'flowers',
            meaningEnglish: 'colourful parts of plants',
            meaningTurkish: 'çiçekler',
            example: 'It has green trees and many flowers.',
          ),
        ],
        questions: [
          ReadingQuestion(
            id: 'a1_park_q1',
            type: ReadingQuestionType.detail,
            question: 'Where is the park?',
            options: ['Near the house', 'Near the school', 'Near the cafe'],
            answer: 'Near the house',
            explanationEnglish: 'The text says the park is near the house.',
            explanationTurkish:
                'Metinde parkın evin yakınında olduğu söyleniyor.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_park_q2',
            type: ReadingQuestionType.detail,
            question: 'How many benches are there?',
            options: ['One', 'Two', 'Three'],
            answer: 'Two',
            explanationEnglish: 'There are two benches under a big tree.',
            explanationTurkish: 'Büyük bir ağacın altında iki bank var.',
            evidenceParagraph: 1,
          ),
          ReadingQuestion(
            id: 'a1_park_q3',
            type: ReadingQuestionType.trueFalse,
            question: 'Children play football in the park.',
            options: ['True', 'False'],
            answer: 'True',
            explanationEnglish: 'The text says children play football there.',
            explanationTurkish:
                'Metinde çocukların parkta futbol oynadığı söyleniyor.',
            evidenceParagraph: 2,
          ),
          ReadingQuestion(
            id: 'a1_park_q4',
            type: ReadingQuestionType.detail,
            question: 'When does the writer go to the park?',
            options: ['On Sundays', 'On Mondays', 'Every morning'],
            answer: 'On Sundays',
            explanationEnglish: 'The writer goes there on Sundays.',
            explanationTurkish: 'Yazar oraya pazar günleri gidiyor.',
            evidenceParagraph: 2,
          ),
        ],
        vocabularyReview: [
          ReadingVocabularyReviewItem(
            word: 'near',
            originalSentence: 'There is a small park near my house.',
            newExampleSentence: 'There is a market near my school.',
            meaningEnglish: 'not far',
            meaningTurkish: 'yakın',
          ),
        ],
        reflectionPrompt:
            'Write two sentences about a park or a place near your home.',
        reflectionPromptTurkish:
            'Evinin yakınındaki bir yer hakkında iki cümle yaz.',
      ),
    ],
  ),
];
