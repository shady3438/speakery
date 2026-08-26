import 'learning_models.dart';

final Map<String, LessonContent> readingLessons = {
  "a1_reading_short_personal_text": const LessonContent(
    id: "a1_reading_short_personal_text",
    title: "Reading • Short Personal Text",
    level: "A1",
    explanation:
        "Read a short personal text and understand basic information such as name, age, city, family, school and hobbies.",
    structures: [
      "My name is...",
      "I am ... years old.",
      "I live in...",
      "I have got...",
      "I like...",
      "My favorite ... is...",
    ],
    examples: [
      "My name is Elif. I am 13 years old. I live in Kayseri with my family. I have got one brother and one sister. My favorite subject is English. In my free time, I listen to music and play volleyball.",
      "name = isim",
      "years old = yaşında",
      "live = yaşamak",
      "family = aile",
      "free time = boş zaman",
    ],
    commonMistakes: [
      "She is 13 years -> She is 13 years old",
      "I live at Kayseri -> I live in Kayseri",
      "I have one brother and one sister",
    ],
    quiz: [
      QuizQuestion(
        question: "How old is Elif?",
        options: [
          "11",
          "12",
          "13",
          "14",
        ],
        correctIndex: 2,
        explanation: "The text says: I am 13 years old.",
      ),
      QuizQuestion(
        question: "Where does Elif live?",
        options: [
          "Ankara",
          "Kayseri",
          "Istanbul",
          "Izmir",
        ],
        correctIndex: 1,
        explanation: "The text says she lives in Kayseri.",
      ),
      QuizQuestion(
        question: "What is her favorite subject?",
        options: [
          "Math",
          "Science",
          "English",
          "History",
        ],
        correctIndex: 2,
        explanation: "The text says her favorite subject is English.",
      ),
      QuizQuestion(
        question: "What does she do in her free time?",
        options: [
          "plays football",
          "listens to music and plays volleyball",
          "watches TV only",
          "goes shopping",
        ],
        correctIndex: 1,
        explanation: "She listens to music and plays volleyball.",
      ),
    ],
    speakingPrompts: [
      "Introduce yourself like Elif.",
      "Talk about your city, family and hobbies.",
      "Ask your partner: Where do you live?",
    ],
    writingPrompts: [
      "Write a short personal text about yourself.",
      "Write 6 sentences: name, age, city, family, school and hobby.",
    ],
  ),
  "a1_reading_simple_email": const LessonContent(
    id: "a1_reading_simple_email",
    title: "Reading • Simple Email",
    level: "A1",
    explanation:
        "Read a simple email and understand greetings, personal information, daily activities and closing phrases.",
    structures: [
      "Hi / Hello...",
      "How are you?",
      "My school is...",
      "My favorite lesson is...",
      "See you soon.",
      "Best wishes,",
    ],
    examples: [
      "Hi Tom,\n\nHow are you? I am fine. I am in a new school this year. My school is big and modern. I have got many friends in my class. My favorite lesson is English because my teacher is very kind.\n\nSee you soon,\nMert",
      "new school = yeni okul",
      "modern = modern",
      "kind = nazik",
      "after school = okuldan sonra",
      "See you soon = yakında görüşürüz",
    ],
    commonMistakes: [
      "I am fine",
      "I have got many friends",
      "What about you?",
      "See you soon",
    ],
    quiz: [
      QuizQuestion(
        question: "Who writes the email?",
        options: [
          "Tom",
          "Mert",
          "Teacher",
          "Ali",
        ],
        correctIndex: 1,
        explanation: "The email ends with Mert, so Mert writes it.",
      ),
      QuizQuestion(
        question: "What is Mert’s school like?",
        options: [
          "small and old",
          "big and modern",
          "boring",
          "far away",
        ],
        correctIndex: 1,
        explanation: "He says his school is big and modern.",
      ),
      QuizQuestion(
        question: "What is his favorite lesson?",
        options: [
          "Math",
          "Science",
          "English",
          "Art",
        ],
        correctIndex: 2,
        explanation: "He says his favorite lesson is English.",
      ),
      QuizQuestion(
        question: "Which is a closing phrase?",
        options: [
          "How are you?",
          "See you soon",
          "My school is big",
          "What about you?",
        ],
        correctIndex: 1,
        explanation: "See you soon is used to close an email/message.",
      ),
    ],
    speakingPrompts: [
      "Talk about your school.",
      "Ask your friend: Do you like your school?",
      "Say what you do after school.",
    ],
    writingPrompts: [
      "Write a simple email to a friend about your school.",
      "Write 6 sentences about your favorite lesson.",
    ],
  ),
  "a1_reading_daily_routine": const LessonContent(
    id: "a1_reading_daily_routine",
    title: "Reading • Daily Routine",
    level: "A1",
    explanation:
        "Read a daily routine text and understand time, repeated actions and routine verbs.",
    structures: [
      "I wake up at...",
      "I have breakfast.",
      "I go to school/work.",
      "In the evening...",
      "I go to bed at...",
    ],
    examples: [
      "Hi! My name is Ali. I wake up at 7 o’clock every day. I brush my teeth and have breakfast. Then I go to school at 8 o’clock. I come home at 4 p.m. In the evening, I do my homework and watch TV. I usually go to bed at 11 p.m.",
      "wake up = uyanmak",
      "brush my teeth = dişlerimi fırçalamak",
      "have breakfast = kahvaltı yapmak",
      "do homework = ödev yapmak",
    ],
    commonMistakes: [
      "I go bed -> I go to bed",
      "I make homework -> I do homework",
      "I wake up at 7",
    ],
    quiz: [
      QuizQuestion(
        question: "What time does Ali wake up?",
        options: [
          "6",
          "7",
          "8",
          "11",
        ],
        correctIndex: 1,
        explanation: "The text says he wakes up at 7 o’clock.",
      ),
      QuizQuestion(
        question: "Where does he go at 8?",
        options: [
          "school",
          "work",
          "park",
          "cafe",
        ],
        correctIndex: 0,
        explanation: "He goes to school at 8 o’clock.",
      ),
      QuizQuestion(
        question: "What does he do in the evening?",
        options: [
          "does homework and watches TV",
          "plays football",
          "goes shopping",
          "visits friends",
        ],
        correctIndex: 0,
        explanation: "He does homework and watches TV in the evening.",
      ),
      QuizQuestion(
        question: "What time does he go to bed?",
        options: [
          "8 p.m.",
          "9 p.m.",
          "10 p.m.",
          "11 p.m.",
        ],
        correctIndex: 3,
        explanation: "He usually goes to bed at 11 p.m.",
      ),
    ],
    speakingPrompts: [
      "Describe your daily routine.",
      "What time do you wake up?",
      "What do you do in the evening?",
    ],
    writingPrompts: [
      "Write your daily routine in 8 sentences.",
      "Write about your morning routine.",
    ],
  ),
  "a1_reading_at_the_cafe": const LessonContent(
    id: "a1_reading_at_the_cafe",
    title: "Reading • At the Cafe",
    level: "A1",
    explanation:
        "Read a simple cafe dialogue and understand polite ordering phrases, food and drinks.",
    structures: [
      "What would you like?",
      "I would like...",
      "Can I have...?",
      "Anything else?",
      "How much is it?",
      "Here you are.",
    ],
    examples: [
      "Waiter: Hello! What would you like?\nAli: I would like a coffee, please.\nWaiter: Anything else?\nAli: Yes, a cheese sandwich, please.\nWaiter: Sure. That is 90 lira.\nAli: Here you are.\nWaiter: Thank you. Enjoy!",
      "waiter = garson",
      "I would like = rica ediyorum",
      "Anything else? = Başka bir şey?",
      "How much is it? = Ne kadar?",
    ],
    commonMistakes: [
      "Give me coffee -> Can I have a coffee, please?",
      "How many is it? -> How much is it?",
      "I want coffee is okay, but I would like is more polite.",
    ],
    quiz: [
      QuizQuestion(
        question: "Where are Ali and the waiter?",
        options: [
          "at school",
          "at a cafe",
          "at a hospital",
          "at home",
        ],
        correctIndex: 1,
        explanation: "The dialogue happens at a cafe.",
      ),
      QuizQuestion(
        question: "What drink does Ali order?",
        options: [
          "tea",
          "coffee",
          "water",
          "juice",
        ],
        correctIndex: 1,
        explanation: "Ali says he would like a coffee.",
      ),
      QuizQuestion(
        question: "What food does Ali order?",
        options: [
          "pizza",
          "soup",
          "cheese sandwich",
          "salad",
        ],
        correctIndex: 2,
        explanation: "Ali orders a cheese sandwich.",
      ),
      QuizQuestion(
        question: "Which phrase is polite?",
        options: [
          "Coffee now.",
          "Give me coffee.",
          "Can I have a coffee, please?",
          "I coffee.",
        ],
        correctIndex: 2,
        explanation: "Can I have..., please? is polite.",
      ),
    ],
    speakingPrompts: [
      "Make a cafe dialogue with a partner.",
      "Order a drink and food politely.",
      "Ask: How much is it?",
    ],
    writingPrompts: [
      "Write a short cafe dialogue.",
      "Write 5 polite ordering sentences.",
    ],
  ),
  "a2_reading_travel_plan": const LessonContent(
    id: "a2_reading_travel_plan",
    title: "Reading • Travel Plan",
    level: "A2",
    explanation:
        "Read a travel plan and understand future arrangements, places, transport and activities.",
    structures: [
      "I am going to...",
      "We are planning to...",
      "First, we will...",
      "After that...",
      "We are staying at...",
      "I am excited because...",
    ],
    examples: [
      "Next weekend, Deniz and her family are going to Cappadocia. They are planning to leave early on Saturday morning. First, they will visit the underground city. After that, they are going to take photos near the fairy chimneys. They are staying at a small hotel for one night. Deniz is excited because she loves history and nature.",
      "travel plan = seyahat planı",
      "leave early = erken ayrılmak",
      "underground city = yeraltı şehri",
      "fairy chimneys = peri bacaları",
      "excited = heyecanlı",
    ],
    commonMistakes: [
      "I will to visit -> I will visit",
      "I am go to -> I am going to",
      "at Saturday -> on Saturday",
    ],
    quiz: [
      QuizQuestion(
        question: "Where are they going?",
        options: [
          "Istanbul",
          "Cappadocia",
          "Antalya",
          "Ankara",
        ],
        correctIndex: 1,
        explanation: "They are going to Cappadocia.",
      ),
      QuizQuestion(
        question: "When are they leaving?",
        options: [
          "Friday night",
          "Saturday morning",
          "Sunday evening",
          "Monday",
        ],
        correctIndex: 1,
        explanation: "They are leaving early on Saturday morning.",
      ),
      QuizQuestion(
        question: "Where are they staying?",
        options: [
          "at a small hotel",
          "at a school",
          "in a tent",
          "with friends",
        ],
        correctIndex: 0,
        explanation: "They are staying at a small hotel.",
      ),
      QuizQuestion(
        question: "Why is Deniz excited?",
        options: [
          "She loves shopping.",
          "She loves history and nature.",
          "She hates travelling.",
          "She wants to sleep.",
        ],
        correctIndex: 1,
        explanation: "She loves history and nature.",
      ),
    ],
    speakingPrompts: [
      "Talk about a place you want to visit.",
      "Describe your weekend travel plan.",
      "Ask a friend about their holiday plan.",
    ],
    writingPrompts: [
      "Write a weekend travel plan.",
      "Write 8 sentences about a city you want to visit.",
    ],
  ),
  "a2_reading_health_advice": const LessonContent(
    id: "a2_reading_health_advice",
    title: "Reading • Health Advice",
    level: "A2",
    explanation:
        "Read a short health text and understand symptoms, advice and simple modal verbs.",
    structures: [
      "You should...",
      "You shouldn’t...",
      "You need to...",
      "If you feel...",
      "It is important to...",
      "Drink plenty of water.",
    ],
    examples: [
      "When you have a cold, you should rest and drink plenty of water. You shouldn’t go to bed very late. If you have a fever, you need to see a doctor. It is also important to eat healthy food. You can drink warm tea with lemon, but you shouldn’t take medicine without asking an adult or a doctor.",
      "cold = soğuk algınlığı",
      "fever = ateş",
      "rest = dinlenmek",
      "plenty of water = bol su",
      "medicine = ilaç",
    ],
    commonMistakes: [
      "You should to rest -> You should rest",
      "You must to see -> You must see",
      "drink water plenty -> drink plenty of water",
    ],
    quiz: [
      QuizQuestion(
        question: "What should you do when you have a cold?",
        options: [
          "rest and drink water",
          "run outside",
          "eat only sweets",
          "sleep at school",
        ],
        correctIndex: 0,
        explanation: "The text says you should rest and drink plenty of water.",
      ),
      QuizQuestion(
        question: "What should you do if you have a fever?",
        options: [
          "watch TV",
          "see a doctor",
          "eat ice cream",
          "go shopping",
        ],
        correctIndex: 1,
        explanation: "If you have a fever, you need to see a doctor.",
      ),
      QuizQuestion(
        question: "What drink is mentioned?",
        options: [
          "cold cola",
          "warm tea with lemon",
          "coffee",
          "energy drink",
        ],
        correctIndex: 1,
        explanation: "The text mentions warm tea with lemon.",
      ),
      QuizQuestion(
        question: "What shouldn’t you do?",
        options: [
          "ask a doctor",
          "rest",
          "take medicine without asking",
          "drink water",
        ],
        correctIndex: 2,
        explanation: "You shouldn’t take medicine without asking.",
      ),
    ],
    speakingPrompts: [
      "Give health advice to a friend.",
      "Talk about what you do when you feel ill.",
      "Use should and shouldn’t.",
    ],
    writingPrompts: [
      "Write 6 health tips.",
      "Write a short advice message to a sick friend.",
    ],
  ),
  "a2_reading_shopping_dialogue": const LessonContent(
    id: "a2_reading_shopping_dialogue",
    title: "Reading • Shopping Dialogue",
    level: "A2",
    explanation:
        "Read a shopping dialogue and understand prices, sizes, colors and polite requests.",
    structures: [
      "Can I help you?",
      "I am looking for...",
      "What size are you?",
      "Do you have it in...?",
      "How much is it?",
      "I’ll take it.",
    ],
    examples: [
      "Assistant: Can I help you?\nCustomer: Yes, I am looking for a jacket.\nAssistant: What size are you?\nCustomer: Medium. Do you have it in black?\nAssistant: Yes, here you are.\nCustomer: It looks nice. How much is it?\nAssistant: It is 750 lira.\nCustomer: Great. I’ll take it.",
      "looking for = aramak",
      "size = beden",
      "medium = orta beden",
      "I’ll take it = bunu alacağım",
    ],
    commonMistakes: [
      "I search a jacket -> I am looking for a jacket",
      "How many is it? -> How much is it?",
      "I will take it is okay, but I’ll take it is natural.",
    ],
    quiz: [
      QuizQuestion(
        question: "What is the customer looking for?",
        options: [
          "a shirt",
          "a jacket",
          "shoes",
          "a bag",
        ],
        correctIndex: 1,
        explanation: "The customer is looking for a jacket.",
      ),
      QuizQuestion(
        question: "What size does the customer want?",
        options: [
          "small",
          "medium",
          "large",
          "extra large",
        ],
        correctIndex: 1,
        explanation: "The customer says Medium.",
      ),
      QuizQuestion(
        question: "What color does the customer ask for?",
        options: [
          "blue",
          "white",
          "black",
          "green",
        ],
        correctIndex: 2,
        explanation: "The customer asks for black.",
      ),
      QuizQuestion(
        question: "How much is the jacket?",
        options: [
          "500 lira",
          "650 lira",
          "750 lira",
          "900 lira",
        ],
        correctIndex: 2,
        explanation: "The jacket is 750 lira.",
      ),
    ],
    speakingPrompts: [
      "Make a shopping dialogue.",
      "Ask for a different size or color.",
      "Talk about clothes you like buying.",
    ],
    writingPrompts: [
      "Write a shopping dialogue.",
      "Describe an item you want to buy.",
    ],
  ),
  "a2_reading_city_guide": const LessonContent(
    id: "a2_reading_city_guide",
    title: "Reading • City Guide",
    level: "A2",
    explanation:
        "Read a short city guide and understand places, directions and recommendations.",
    structures: [
      "There is / There are...",
      "You can visit...",
      "It is famous for...",
      "It is next to...",
      "The best time to visit is...",
      "Don’t miss...",
    ],
    examples: [
      "Kayseri is a city in Central Anatolia. There are many historical places and modern shopping centers. You can visit Kayseri Castle in the city center. The city is famous for mantı and pastırma. In winter, many tourists go to Erciyes Mountain for skiing. The best time to visit depends on what you want to do.",
      "city guide = şehir rehberi",
      "historical places = tarihi yerler",
      "famous for = ile meşhur",
      "skiing = kayak yapmak",
    ],
    commonMistakes: [
      "famous with -> famous for",
      "There is many places -> There are many places",
      "in winter season -> in winter",
    ],
    quiz: [
      QuizQuestion(
        question: "Where is Kayseri?",
        options: [
          "Central Anatolia",
          "Black Sea",
          "Aegean",
          "Europe",
        ],
        correctIndex: 0,
        explanation: "The text says Kayseri is in Central Anatolia.",
      ),
      QuizQuestion(
        question: "What can you visit in the city center?",
        options: [
          "a beach",
          "Kayseri Castle",
          "a zoo",
          "a lake",
        ],
        correctIndex: 1,
        explanation: "You can visit Kayseri Castle.",
      ),
      QuizQuestion(
        question: "What food is Kayseri famous for?",
        options: [
          "mantı and pastırma",
          "pizza",
          "fish",
          "cake",
        ],
        correctIndex: 0,
        explanation: "It is famous for mantı and pastırma.",
      ),
      QuizQuestion(
        question: "Where do tourists go for skiing?",
        options: [
          "Erciyes Mountain",
          "the castle",
          "the shopping center",
          "the airport",
        ],
        correctIndex: 0,
        explanation: "Tourists go to Erciyes Mountain for skiing.",
      ),
    ],
    speakingPrompts: [
      "Describe your city.",
      "Recommend three places to visit.",
      "Ask for directions in a city.",
    ],
    writingPrompts: [
      "Write a city guide for your town.",
      "Write 8 sentences about a famous city.",
    ],
  ),
  "b1_reading_technology_habits": const LessonContent(
    id: "b1_reading_technology_habits",
    title: "Reading • Technology Habits",
    level: "B1",
    explanation:
        "Read about technology habits and understand opinions, reasons, advantages and disadvantages.",
    structures: [
      "Many people believe that...",
      "On the one hand...",
      "On the other hand...",
      "This means that...",
      "As a result...",
      "In my opinion...",
    ],
    examples: [
      "Technology has changed the way teenagers study, communicate and spend their free time. Many students use online videos to learn new topics and practise English. On the one hand, this is useful because students can study whenever they want. On the other hand, spending too much time online can reduce concentration. In my opinion, technology is helpful if people use it in a balanced way.",
      "communicate = iletişim kurmak",
      "whenever = ne zaman isterse",
      "reduce concentration = dikkati azaltmak",
      "balanced way = dengeli şekilde",
    ],
    commonMistakes: [
      "technology is useful if we use it balanced -> in a balanced way",
      "many students uses -> many students use",
      "on the other hand should introduce contrast",
    ],
    quiz: [
      QuizQuestion(
        question: "What has technology changed?",
        options: [
          "only schools",
          "the way teenagers study and communicate",
          "only sports",
          "food habits",
        ],
        correctIndex: 1,
        explanation:
            "The text says it changed the way teenagers study, communicate and spend free time.",
      ),
      QuizQuestion(
        question: "Why can online videos be useful?",
        options: [
          "They are always expensive.",
          "Students can study whenever they want.",
          "They stop concentration.",
          "They are only for teachers.",
        ],
        correctIndex: 1,
        explanation: "Students can study whenever they want.",
      ),
      QuizQuestion(
        question: "What is a disadvantage?",
        options: [
          "better learning",
          "more communication",
          "reduced concentration",
          "more free time",
        ],
        correctIndex: 2,
        explanation: "Too much time online can reduce concentration.",
      ),
      QuizQuestion(
        question: "What is the writer’s opinion?",
        options: [
          "Technology is always bad.",
          "Technology is helpful if used in a balanced way.",
          "Students should never go online.",
          "Videos are useless.",
        ],
        correctIndex: 1,
        explanation:
            "The writer says technology is helpful if used in a balanced way.",
      ),
    ],
    speakingPrompts: [
      "Talk about your technology habits.",
      "Discuss advantages and disadvantages of phones.",
      "Give your opinion about online learning.",
    ],
    writingPrompts: [
      "Write a paragraph about technology in education.",
      "Write advantages and disadvantages of social media.",
    ],
  ),
  "b1_reading_environment_project": const LessonContent(
    id: "b1_reading_environment_project",
    title: "Reading • Environment Project",
    level: "B1",
    explanation:
        "Read about an environmental project and understand problem, solution, result and community action.",
    structures: [
      "The main problem is...",
      "In order to...",
      "People decided to...",
      "This project helped...",
      "As a result...",
      "Everyone can contribute by...",
    ],
    examples: [
      "Last year, students at Green Valley School noticed that there was too much plastic waste in the school garden. In order to solve this problem, they started a recycling project. They put recycling boxes in every corridor and prepared posters about waste. At first, only a few students joined the project, but later many classes supported it. As a result, the school reduced its plastic waste and students became more aware of environmental problems.",
      "plastic waste = plastik atık",
      "recycling = geri dönüşüm",
      "aware of = farkında",
      "support = desteklemek",
    ],
    commonMistakes: [
      "aware about -> aware of",
      "too many plastic waste -> too much plastic waste",
      "in order solve -> in order to solve",
    ],
    quiz: [
      QuizQuestion(
        question: "What problem did the students notice?",
        options: [
          "too much homework",
          "plastic waste",
          "no sports area",
          "bad food",
        ],
        correctIndex: 1,
        explanation: "They noticed too much plastic waste.",
      ),
      QuizQuestion(
        question: "What project did they start?",
        options: [
          "a music project",
          "a recycling project",
          "a history project",
          "a travel project",
        ],
        correctIndex: 1,
        explanation: "They started a recycling project.",
      ),
      QuizQuestion(
        question: "Where did they put boxes?",
        options: [
          "in every corridor",
          "only in the garden",
          "in the kitchen",
          "outside school",
        ],
        correctIndex: 0,
        explanation: "They put recycling boxes in every corridor.",
      ),
      QuizQuestion(
        question: "What was the result?",
        options: [
          "The school closed.",
          "Waste increased.",
          "Students became more aware.",
          "No one joined.",
        ],
        correctIndex: 2,
        explanation: "Students became more aware of environmental problems.",
      ),
    ],
    speakingPrompts: [
      "Talk about an environmental problem in your city.",
      "Suggest three solutions for plastic waste.",
      "Explain how students can help nature.",
    ],
    writingPrompts: [
      "Write about a school project.",
      "Write a paragraph about recycling.",
    ],
  ),
  "b1_reading_studying_abroad": const LessonContent(
    id: "b1_reading_studying_abroad",
    title: "Reading • Studying Abroad",
    level: "B1",
    explanation:
        "Read about studying abroad and understand experiences, challenges and personal development.",
    structures: [
      "At first...",
      "I found it difficult to...",
      "After a while...",
      "I got used to...",
      "The best part was...",
      "This experience taught me...",
    ],
    examples: [
      "When Ece moved to Poland for an exchange program, she felt excited but nervous. At first, she found it difficult to understand different accents and live in a new culture. After a while, she got used to daily life and made friends from different countries. The best part of the experience was becoming more independent. She says studying abroad taught her to be brave and open-minded.",
      "exchange program = değişim programı",
      "accent = aksan",
      "get used to = alışmak",
      "independent = bağımsız",
      "open-minded = açık fikirli",
    ],
    commonMistakes: [
      "used to daily life -> got used to daily life",
      "different country friends -> friends from different countries",
      "teach me be brave -> taught me to be brave",
    ],
    quiz: [
      QuizQuestion(
        question: "Where did Ece move?",
        options: [
          "Spain",
          "Poland",
          "Germany",
          "Italy",
        ],
        correctIndex: 1,
        explanation: "The text says she moved to Poland.",
      ),
      QuizQuestion(
        question: "How did she feel at first?",
        options: [
          "angry and bored",
          "excited but nervous",
          "tired and hungry",
          "calm and sleepy",
        ],
        correctIndex: 1,
        explanation: "She felt excited but nervous.",
      ),
      QuizQuestion(
        question: "What did she find difficult?",
        options: [
          "cooking only",
          "understanding accents and living in a new culture",
          "playing sports",
          "buying clothes",
        ],
        correctIndex: 1,
        explanation: "She found accents and a new culture difficult.",
      ),
      QuizQuestion(
        question: "What did the experience teach her?",
        options: [
          "to be brave and open-minded",
          "to avoid travel",
          "to speak less",
          "to stay alone",
        ],
        correctIndex: 0,
        explanation: "The experience taught her to be brave and open-minded.",
      ),
    ],
    speakingPrompts: [
      "Would you like to study abroad? Why?",
      "Talk about a challenge in a new place.",
      "Describe how travel can change a person.",
    ],
    writingPrompts: [
      "Write about an exchange program.",
      "Write a paragraph about the benefits of studying abroad.",
    ],
  ),
  "b1_reading_work_experience": const LessonContent(
    id: "b1_reading_work_experience",
    title: "Reading • Work Experience",
    level: "B1",
    explanation:
        "Read about a first work experience and understand responsibilities, skills and personal reflection.",
    structures: [
      "My main responsibility was...",
      "I learned how to...",
      "At the beginning...",
      "Later, I became more confident.",
      "This job helped me...",
      "I would recommend...",
    ],
    examples: [
      "Burak’s first part-time job was at a small bookstore. His main responsibility was helping customers find books and organizing shelves. At the beginning, he was shy and worried about making mistakes. Later, he became more confident because his manager supported him. The job helped him improve his communication skills and learn how to solve small problems quickly.",
      "part-time job = yarı zamanlı iş",
      "responsibility = sorumluluk",
      "shelves = raflar",
      "confident = özgüvenli",
      "communication skills = iletişim becerileri",
    ],
    commonMistakes: [
      "I learned how solve -> I learned how to solve",
      "responsible of -> responsible for",
      "make mistake -> make a mistake",
    ],
    quiz: [
      QuizQuestion(
        question: "Where did Burak work?",
        options: [
          "bookstore",
          "hospital",
          "hotel",
          "restaurant",
        ],
        correctIndex: 0,
        explanation: "He worked at a small bookstore.",
      ),
      QuizQuestion(
        question: "What was his responsibility?",
        options: [
          "driving a bus",
          "helping customers and organizing shelves",
          "cooking meals",
          "teaching math",
        ],
        correctIndex: 1,
        explanation: "He helped customers and organized shelves.",
      ),
      QuizQuestion(
        question: "How did he feel at the beginning?",
        options: [
          "shy and worried",
          "angry",
          "very bored",
          "careless",
        ],
        correctIndex: 0,
        explanation: "At the beginning, he was shy and worried.",
      ),
      QuizQuestion(
        question: "What skill did he improve?",
        options: [
          "communication",
          "painting",
          "running",
          "singing",
        ],
        correctIndex: 0,
        explanation: "He improved his communication skills.",
      ),
    ],
    speakingPrompts: [
      "Talk about a job you would like to try.",
      "Describe important skills for work.",
      "Would you prefer part-time or full-time work?",
    ],
    writingPrompts: [
      "Write about your first job or dream job.",
      "Write a paragraph about useful work skills.",
    ],
  ),
  "b2_reading_academic_technology": const LessonContent(
    id: "b2_reading_academic_technology",
    title: "Reading • Technology and Learning",
    level: "B2",
    explanation:
        "Read a semi-academic text and identify main idea, supporting arguments, contrast and implication.",
    structures: [
      "Although...",
      "Whereas...",
      "This suggests that...",
      "A major advantage is...",
      "However, critics argue that...",
      "The evidence indicates...",
    ],
    examples: [
      "Although digital learning platforms have made education more accessible, their effectiveness depends largely on how students use them. A major advantage is flexibility: learners can review lessons, pause videos and practise at their own pace. However, critics argue that online learning may encourage passive study habits if learners only watch content without applying it. This suggests that technology itself is not enough; meaningful learning requires active engagement, feedback and consistency.",
      "accessible = erişilebilir",
      "effectiveness = etkililik",
      "passive study habits = pasif çalışma alışkanlıkları",
      "active engagement = aktif katılım",
      "consistency = istikrar",
    ],
    commonMistakes: [
      "Although digital learning is useful, but... -> Although digital learning is useful, ...",
      "depends from -> depends on",
      "technology is enough itself -> technology itself is not enough",
    ],
    quiz: [
      QuizQuestion(
        question: "What does the text mainly argue?",
        options: [
          "Technology always guarantees learning.",
          "Digital platforms can help, but active learning is necessary.",
          "Online learning is useless.",
          "Students should never use videos.",
        ],
        correctIndex: 1,
        explanation:
            "The text says technology helps, but meaningful learning requires active engagement.",
      ),
      QuizQuestion(
        question: "What is one advantage of digital learning?",
        options: [
          "flexibility",
          "expensive materials",
          "less feedback",
          "no practice",
        ],
        correctIndex: 0,
        explanation: "The text mentions flexibility as a major advantage.",
      ),
      QuizQuestion(
        question: "What problem do critics mention?",
        options: [
          "too much active speaking",
          "passive study habits",
          "too many teachers",
          "paper books",
        ],
        correctIndex: 1,
        explanation:
            "Critics say online learning may encourage passive study habits.",
      ),
      QuizQuestion(
        question: "What does meaningful learning require?",
        options: [
          "only videos",
          "active engagement, feedback and consistency",
          "no practice",
          "only grammar rules",
        ],
        correctIndex: 1,
        explanation:
            "The text directly states active engagement, feedback and consistency.",
      ),
    ],
    speakingPrompts: [
      "Do you think online learning is effective? Why?",
      "Compare classroom learning and app-based learning.",
      "Explain how students can avoid passive learning.",
    ],
    writingPrompts: [
      "Write an opinion paragraph about digital learning.",
      "Write advantages and disadvantages of learning apps.",
    ],
  ),
  "b2_reading_social_media_opinion": const LessonContent(
    id: "b2_reading_social_media_opinion",
    title: "Reading • Social Media Opinion",
    level: "B2",
    explanation:
        "Read an opinion text and analyze argument structure, tone, concession and conclusion.",
    structures: [
      "It is often argued that...",
      "There is no doubt that...",
      "Nevertheless...",
      "One possible drawback is...",
      "A more balanced approach would be...",
      "Ultimately...",
    ],
    examples: [
      "It is often argued that social media damages young people’s attention span and self-confidence. There is no doubt that constant comparison can create pressure, especially when users see unrealistic lifestyles online. Nevertheless, social media can also be a powerful tool for learning, networking and creativity. A more balanced approach would be to teach digital awareness instead of simply telling teenagers to delete every app. Ultimately, the problem is not social media itself, but the way it is used.",
      "attention span = dikkat süresi",
      "self-confidence = özgüven",
      "constant comparison = sürekli kıyaslama",
      "digital awareness = dijital farkındalık",
      "ultimately = nihayetinde",
    ],
    commonMistakes: [
      "There is no doubt social media affects -> There is no doubt that social media affects",
      "instead of tell -> instead of telling",
      "the way how it is used -> the way it is used",
    ],
    quiz: [
      QuizQuestion(
        question: "What is the writer’s balanced view?",
        options: [
          "Delete every app.",
          "Social media is only harmful.",
          "Teach digital awareness and use it wisely.",
          "Teenagers should never go online.",
        ],
        correctIndex: 2,
        explanation:
            "The writer supports digital awareness rather than deleting every app.",
      ),
      QuizQuestion(
        question: "What can constant comparison create?",
        options: [
          "pressure",
          "better sleep",
          "more exercise",
          "no emotion",
        ],
        correctIndex: 0,
        explanation: "The text says constant comparison can create pressure.",
      ),
      QuizQuestion(
        question: "What positive uses are mentioned?",
        options: [
          "learning, networking and creativity",
          "only games",
          "sleeping",
          "shopping only",
        ],
        correctIndex: 0,
        explanation: "The text mentions learning, networking and creativity.",
      ),
      QuizQuestion(
        question: "What is the ultimate problem according to the writer?",
        options: [
          "the app name",
          "the phone brand",
          "the way social media is used",
          "the internet speed",
        ],
        correctIndex: 2,
        explanation: "The writer says the problem is the way it is used.",
      ),
    ],
    speakingPrompts: [
      "Do you think social media is more useful or harmful?",
      "How can teenagers use social media wisely?",
      "Give examples of positive online habits.",
    ],
    writingPrompts: [
      "Write a balanced opinion paragraph about social media.",
      "Write a short essay introduction about digital awareness.",
    ],
  ),
  "b2_reading_work_life_balance": const LessonContent(
    id: "b2_reading_work_life_balance",
    title: "Reading • Work-Life Balance",
    level: "B2",
    explanation:
        "Read a text about work-life balance and identify cause-effect relationships and recommendations.",
    structures: [
      "One reason for this is...",
      "This can lead to...",
      "In contrast...",
      "Employers should...",
      "From an employee’s perspective...",
      "Long-term productivity depends on...",
    ],
    examples: [
      "In many modern workplaces, employees are expected to be available even after office hours. One reason for this is the widespread use of smartphones and instant messaging. This can lead to stress, poor sleep and lower motivation. In contrast, companies that protect personal time often report better long-term productivity. From an employee’s perspective, setting clear boundaries is essential for mental health and sustainable performance.",
      "available = ulaşılabilir",
      "widespread = yaygın",
      "lead to = yol açmak",
      "boundaries = sınırlar",
      "sustainable performance = sürdürülebilir performans",
    ],
    commonMistakes: [
      "lead stress -> lead to stress",
      "depends of -> depends on",
      "protect personal time improves -> protecting personal time improves",
    ],
    quiz: [
      QuizQuestion(
        question: "Why are employees often available after work?",
        options: [
          "because of smartphones and instant messaging",
          "because offices are closed",
          "because they sleep more",
          "because there is no internet",
        ],
        correctIndex: 0,
        explanation: "The text mentions smartphones and instant messaging.",
      ),
      QuizQuestion(
        question: "What can constant availability lead to?",
        options: [
          "stress and poor sleep",
          "better holidays",
          "more hobbies",
          "less work",
        ],
        correctIndex: 0,
        explanation: "It can lead to stress, poor sleep and lower motivation.",
      ),
      QuizQuestion(
        question: "What do successful companies protect?",
        options: [
          "personal time",
          "only meetings",
          "lunch menus",
          "old phones",
        ],
        correctIndex: 0,
        explanation:
            "Companies that protect personal time report better productivity.",
      ),
      QuizQuestion(
        question: "What is essential for mental health?",
        options: [
          "working all night",
          "setting clear boundaries",
          "answering every message",
          "avoiding sleep",
        ],
        correctIndex: 1,
        explanation: "Setting clear boundaries is essential.",
      ),
    ],
    speakingPrompts: [
      "Is work-life balance important? Why?",
      "Should employees answer messages after work?",
      "How can people set boundaries?",
    ],
    writingPrompts: [
      "Write a paragraph about work-life balance.",
      "Write recommendations for healthy work habits.",
    ],
  ),
  "b2_reading_culture_and_identity": const LessonContent(
    id: "b2_reading_culture_and_identity",
    title: "Reading • Culture and Identity",
    level: "B2",
    explanation:
        "Read a reflective text and understand abstract ideas such as identity, belonging and cultural change.",
    structures: [
      "Identity is shaped by...",
      "Belonging does not always mean...",
      "People tend to...",
      "As societies become more connected...",
      "This raises the question of...",
      "Rather than..., we should...",
    ],
    examples: [
      "Identity is shaped by language, family, traditions and personal experiences. As societies become more connected, many people are exposed to different cultures from an early age. This can sometimes create confusion, but it can also make individuals more flexible and open-minded. Belonging does not always mean choosing only one culture. Rather than seeing cultural variety as a problem, we should view it as a source of growth and understanding.",
      "identity = kimlik",
      "belonging = aidiyet",
      "exposed to = maruz kalmak / tanışmak",
      "open-minded = açık fikirli",
      "source of growth = gelişim kaynağı",
    ],
    commonMistakes: [
      "belonging means choose one culture -> belonging means choosing one culture",
      "exposed different cultures -> exposed to different cultures",
      "rather seeing -> rather than seeing",
    ],
    quiz: [
      QuizQuestion(
        question: "What shapes identity according to the text?",
        options: [
          "only money",
          "language, family, traditions and experiences",
          "only school",
          "only technology",
        ],
        correctIndex: 1,
        explanation:
            "The text lists language, family, traditions and personal experiences.",
      ),
      QuizQuestion(
        question: "What can cultural exposure create?",
        options: [
          "only problems",
          "confusion but also flexibility",
          "no change",
          "less understanding",
        ],
        correctIndex: 1,
        explanation:
            "It can create confusion but also make people flexible and open-minded.",
      ),
      QuizQuestion(
        question: "What does belonging not always mean?",
        options: [
          "choosing only one culture",
          "learning a language",
          "having a family",
          "travelling abroad",
        ],
        correctIndex: 0,
        explanation:
            "The text says belonging does not always mean choosing only one culture.",
      ),
      QuizQuestion(
        question: "How should cultural variety be viewed?",
        options: [
          "as a source of growth",
          "as a danger only",
          "as something useless",
          "as a school subject only",
        ],
        correctIndex: 0,
        explanation:
            "The writer says it should be viewed as a source of growth and understanding.",
      ),
    ],
    speakingPrompts: [
      "What shapes a person’s identity?",
      "Can a person belong to more than one culture?",
      "Talk about a tradition that is important to you.",
    ],
    writingPrompts: [
      "Write a reflective paragraph about culture and identity.",
      "Write about how learning a language affects identity.",
    ],
  ),
};
