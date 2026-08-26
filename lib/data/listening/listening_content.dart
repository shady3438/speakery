import 'package:flutter/material.dart';

class ListeningMission {
  final String id;
  final String level;
  final String titleEn;
  final String titleTr;
  final String subtitleEn;
  final String subtitleTr;
  final String duration;
  final String scene;
  final IconData icon;
  final String transcript;
  final String translationTr;
  final String focusQuestionEn;
  final String focusQuestionTr;
  final List<String> focusOptions;
  final int focusAnswer;
  final String dictationTarget;
  final String shadowChunk;
  final String dialoguePromptEn;
  final String dialoguePromptTr;
  final List<String> dialogueOptions;
  final int dialogueAnswer;

  const ListeningMission({
    required this.id,
    required this.level,
    required this.titleEn,
    required this.titleTr,
    required this.subtitleEn,
    required this.subtitleTr,
    required this.duration,
    required this.scene,
    required this.icon,
    required this.transcript,
    required this.translationTr,
    required this.focusQuestionEn,
    required this.focusQuestionTr,
    required this.focusOptions,
    required this.focusAnswer,
    required this.dictationTarget,
    required this.shadowChunk,
    required this.dialoguePromptEn,
    required this.dialoguePromptTr,
    required this.dialogueOptions,
    required this.dialogueAnswer,
  });
}

const listeningMissions = <ListeningMission>[
  ListeningMission(
    id: 'a1_coffee_order',
    level: 'A1',
    titleEn: 'Morning coffee order',
    titleTr: 'Sabah kahve siparişi',
    subtitleEn: 'Catch a drink, a size and a price.',
    subtitleTr: 'İçecek, boy ve fiyat bilgisini yakala.',
    duration: '0:28',
    scene: 'Cafe',
    icon: Icons.local_cafe_rounded,
    transcript:
        'Good morning. Can I have a small coffee and a cheese sandwich, please? That is five pounds twenty. Thank you.',
    translationTr:
        'Günaydın. Küçük bir kahve ve peynirli sandviç alabilir miyim? Toplam beş sterlin yirmi. Teşekkürler.',
    focusQuestionEn: 'How much is the order?',
    focusQuestionTr: 'Sipariş ne kadar?',
    focusOptions: ['£4.20', '£5.20', '£5.50'],
    focusAnswer: 1,
    dictationTarget: 'Can I have a small coffee, please?',
    shadowChunk: 'Can I have a small coffee and a cheese sandwich, please?',
    dialoguePromptEn: 'The server asks: "Anything else?"',
    dialoguePromptTr: 'Görevli soruyor: "Başka bir şey?"',
    dialogueOptions: [
      'No, thank you. That is all.',
      'I am five pounds.',
      'The cafe is morning.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'a1_new_classmate',
    level: 'A1',
    titleEn: 'Meet a new classmate',
    titleTr: 'Yeni sınıf arkadaşıyla tanış',
    subtitleEn: 'Listen for names, countries and hobbies.',
    subtitleTr: 'İsim, ülke ve hobi bilgilerini dinle.',
    duration: '0:31',
    scene: 'School',
    icon: Icons.school_rounded,
    transcript:
        'Hi, I am Maya. I am from Spain, but I live in London now. I like music and tennis. What is your name?',
    translationTr:
        'Merhaba, ben Maya. İspanyalıyım ama şimdi Londra\'da yaşıyorum. Müzik ve tenisi severim. Senin adın ne?',
    focusQuestionEn: 'Where is Maya from?',
    focusQuestionTr: 'Maya nereli?',
    focusOptions: ['Spain', 'London', 'Italy'],
    focusAnswer: 0,
    dictationTarget: 'I live in London now.',
    shadowChunk: 'I am from Spain, but I live in London now.',
    dialoguePromptEn: 'Maya asks for your name. What is a natural reply?',
    dialoguePromptTr: 'Maya adını soruyor. Doğal cevap hangisi?',
    dialogueOptions: [
      'My name is Alex. Nice to meet you.',
      'I name London.',
      'Tennis is from Spain.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'a1_find_library',
    level: 'A1',
    titleEn: 'Find the library',
    titleTr: 'Kütüphaneyi bul',
    subtitleEn: 'Follow simple directions around town.',
    subtitleTr: 'Şehirde basit yön tariflerini takip et.',
    duration: '0:34',
    scene: 'Town',
    icon: Icons.map_rounded,
    transcript:
        'Go straight for two minutes. Turn left at the bank. The library is next to the pharmacy, opposite the park.',
    translationTr:
        'İki dakika düz git. Bankadan sola dön. Kütüphane eczanenin yanında, parkın karşısında.',
    focusQuestionEn: 'What is next to the library?',
    focusQuestionTr: 'Kütüphanenin yanında ne var?',
    focusOptions: ['The bank', 'The pharmacy', 'The station'],
    focusAnswer: 1,
    dictationTarget: 'Turn left at the bank.',
    shadowChunk: 'The library is next to the pharmacy, opposite the park.',
    dialoguePromptEn: 'You did not understand. What should you say?',
    dialoguePromptTr: 'Anlamadın. Ne demelisin?',
    dialogueOptions: [
      'Could you say that again, please?',
      'The park says left.',
      'I do not library.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'a2_platform_change',
    level: 'A2',
    titleEn: 'Platform change',
    titleTr: 'Peron değişikliği',
    subtitleEn: 'Catch times, platforms and destinations.',
    subtitleTr: 'Saat, peron ve varış bilgilerini yakala.',
    duration: '0:38',
    scene: 'Travel',
    icon: Icons.train_rounded,
    transcript:
        'Attention please. The ten forty train to Oxford will now leave from platform six, not platform four. It is delayed by fifteen minutes.',
    translationTr:
        'Dikkat lütfen. Oxford\'a giden 10.40 treni dördüncü peron yerine altıncı perondan kalkacak. Tren on beş dakika gecikmeli.',
    focusQuestionEn: 'Which platform should passengers use?',
    focusQuestionTr: 'Yolcular hangi peronu kullanmalı?',
    focusOptions: ['Platform 4', 'Platform 6', 'Platform 15'],
    focusAnswer: 1,
    dictationTarget: 'The train is delayed by fifteen minutes.',
    shadowChunk: 'The ten forty train will now leave from platform six.',
    dialoguePromptEn: 'Ask a staff member to confirm the platform.',
    dialoguePromptTr: 'Görevliden peronu teyit et.',
    dialogueOptions: [
      'Excuse me, does the Oxford train leave from platform six?',
      'Oxford is fifteen platform.',
      'Where train delayed?',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'a2_doctor_visit',
    level: 'A2',
    titleEn: 'Doctor appointment',
    titleTr: 'Doktor randevusu',
    subtitleEn: 'Understand symptoms and simple advice.',
    subtitleTr: 'Belirtileri ve basit önerileri anla.',
    duration: '0:42',
    scene: 'Health',
    icon: Icons.health_and_safety_rounded,
    transcript:
        'I have had a sore throat since Monday and I feel tired. You should rest, drink plenty of water and take these tablets twice a day.',
    translationTr:
        'Pazartesiden beri boğazım ağrıyor ve yorgun hissediyorum. Dinlenmeli, bol su içmeli ve bu tabletleri günde iki kez almalısın.',
    focusQuestionEn: 'How often should the patient take the tablets?',
    focusQuestionTr: 'Hasta tabletleri ne sıklıkla almalı?',
    focusOptions: ['Once a day', 'Twice a day', 'Every Monday'],
    focusAnswer: 1,
    dictationTarget: 'You should drink plenty of water.',
    shadowChunk: 'I have had a sore throat since Monday.',
    dialoguePromptEn: 'The doctor asks how long you have felt ill.',
    dialoguePromptTr: 'Doktor ne kadar süredir hasta olduğunu soruyor.',
    dialogueOptions: [
      'Since Monday morning.',
      'Twice a tablet.',
      'I am plenty of water.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'a2_weekend_plan',
    level: 'A2',
    titleEn: 'Weekend plans',
    titleTr: 'Hafta sonu planları',
    subtitleEn: 'Follow invitations and schedule changes.',
    subtitleTr: 'Davetleri ve program değişikliklerini takip et.',
    duration: '0:40',
    scene: 'Friends',
    icon: Icons.weekend_rounded,
    transcript:
        'We planned to meet on Saturday, but I have to work. Are you free on Sunday afternoon? We could see the new film at three.',
    translationTr:
        'Cumartesi buluşmayı planlamıştık ama çalışmam gerekiyor. Pazar öğleden sonra müsait misin? Yeni filmi saat üçte izleyebiliriz.',
    focusQuestionEn: 'When is the new plan?',
    focusQuestionTr: 'Yeni plan ne zaman?',
    focusOptions: ['Saturday morning', 'Sunday afternoon', 'Sunday evening'],
    focusAnswer: 1,
    dictationTarget: 'Are you free on Sunday afternoon?',
    shadowChunk: 'We could see the new film at three.',
    dialoguePromptEn: 'Accept the invitation naturally.',
    dialoguePromptTr: 'Daveti doğal bir şekilde kabul et.',
    dialogueOptions: [
      'Sunday works for me. See you at three.',
      'I worked the film.',
      'Saturday is a new afternoon.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'b1_project_update',
    level: 'B1',
    titleEn: 'Project update',
    titleTr: 'Proje güncellemesi',
    subtitleEn: 'Follow progress, problems and next steps.',
    subtitleTr: 'İlerleme, sorun ve sonraki adımları takip et.',
    duration: '0:52',
    scene: 'Work',
    icon: Icons.business_center_rounded,
    transcript:
        'We have completed the first stage, but the client requested two changes to the design. If we receive the new images today, we can still finish by Friday.',
    translationTr:
        'İlk aşamayı tamamladık ancak müşteri tasarımda iki değişiklik istedi. Yeni görselleri bugün alırsak cuma gününe kadar yine bitirebiliriz.',
    focusQuestionEn: 'What does the team need today?',
    focusQuestionTr: 'Ekibin bugün neye ihtiyacı var?',
    focusOptions: ['A new client', 'The new images', 'A Friday meeting'],
    focusAnswer: 1,
    dictationTarget: 'The client requested two changes to the design.',
    shadowChunk: 'If we receive the new images today, we can finish by Friday.',
    dialoguePromptEn: 'A colleague asks if Friday is still possible.',
    dialoguePromptTr:
        'Bir çalışma arkadaşın cumanın hâlâ mümkün olup olmadığını soruyor.',
    dialogueOptions: [
      'Yes, provided that the images arrive today.',
      'Friday requested the client.',
      'The design is two today.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'b1_flat_viewing',
    level: 'B1',
    titleEn: 'Apartment viewing',
    titleTr: 'Daire gezisi',
    subtitleEn: 'Compare features, costs and conditions.',
    subtitleTr: 'Özellikleri, masrafları ve koşulları karşılaştır.',
    duration: '0:55',
    scene: 'Housing',
    icon: Icons.apartment_rounded,
    transcript:
        'The rent includes water, but electricity and internet are separate. The flat is available from next month, and the owner asks for a six-week deposit.',
    translationTr:
        'Kiraya su dahil ancak elektrik ve internet ayrı. Daire gelecek aydan itibaren müsait ve ev sahibi altı haftalık depozito istiyor.',
    focusQuestionEn: 'Which cost is included in the rent?',
    focusQuestionTr: 'Hangi masraf kiraya dahil?',
    focusOptions: ['Internet', 'Electricity', 'Water'],
    focusAnswer: 2,
    dictationTarget: 'The flat is available from next month.',
    shadowChunk: 'Electricity and internet are separate.',
    dialoguePromptEn: 'Ask whether pets are allowed.',
    dialoguePromptTr: 'Evcil hayvanlara izin verilip verilmediğini sor.',
    dialogueOptions: [
      'Could you tell me whether pets are allowed?',
      'Are pets include the rent?',
      'The owner is a pet?',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'b1_habit_podcast',
    level: 'B1',
    titleEn: 'Building a new habit',
    titleTr: 'Yeni alışkanlık edinmek',
    subtitleEn: 'Identify examples, reasons and advice.',
    subtitleTr: 'Örnekleri, nedenleri ve tavsiyeleri belirle.',
    duration: '1:02',
    scene: 'Podcast',
    icon: Icons.podcasts_rounded,
    transcript:
        'People often fail because they choose a goal that is too ambitious. Start with an action that takes less than two minutes, then connect it to something you already do every day.',
    translationTr:
        'İnsanlar genellikle fazla iddialı bir hedef seçtikleri için başarısız olur. İki dakikadan kısa süren bir eylemle başla, sonra onu her gün yaptığın bir şeye bağla.',
    focusQuestionEn: 'Why do people often fail?',
    focusQuestionTr: 'İnsanlar neden sık sık başarısız oluyor?',
    focusOptions: [
      'Their goal is too ambitious.',
      'They have only two minutes.',
      'They repeat the same action.',
    ],
    focusAnswer: 0,
    dictationTarget: 'Start with an action that takes less than two minutes.',
    shadowChunk: 'Connect it to something you already do every day.',
    dialoguePromptEn: 'Suggest a small reading habit.',
    dialoguePromptTr: 'Küçük bir okuma alışkanlığı öner.',
    dialogueOptions: [
      'Read one page after breakfast each day.',
      'Finish every book before breakfast.',
      'Reading has less ambitious.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'b2_job_interview',
    level: 'B2',
    titleEn: 'Job interview insight',
    titleTr: 'İş görüşmesi ipucu',
    subtitleEn: 'Notice evidence, attitude and implied meaning.',
    subtitleTr: 'Kanıt, tutum ve ima edilen anlamı fark et.',
    duration: '1:08',
    scene: 'Career',
    icon: Icons.badge_rounded,
    transcript:
        'Although I had not managed a team formally, I coordinated five volunteers during the campaign. That experience taught me to delegate clearly and deal with disagreements early.',
    translationTr:
        'Resmî olarak bir ekip yönetmemiş olsam da kampanya sırasında beş gönüllüyü koordine ettim. Bu deneyim bana açık görev dağıtmayı ve anlaşmazlıkları erken ele almayı öğretti.',
    focusQuestionEn: 'What weakness does the speaker address?',
    focusQuestionTr: 'Konuşmacı hangi eksikliğini ele alıyor?',
    focusOptions: [
      'Limited formal management experience',
      'Poor campaign results',
      'Difficulty working with volunteers',
    ],
    focusAnswer: 0,
    dictationTarget: 'That experience taught me to delegate clearly.',
    shadowChunk:
        'Although I had not managed a team formally, I coordinated five volunteers.',
    dialoguePromptEn: 'Ask for a concrete example of leadership.',
    dialoguePromptTr: 'Somut bir liderlik örneği iste.',
    dialogueOptions: [
      'Could you describe a situation in which you led others?',
      'Why leadership is five?',
      'Did the campaign formally disagree?',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'b2_green_city',
    level: 'B2',
    titleEn: 'A greener city',
    titleTr: 'Daha yeşil bir şehir',
    subtitleEn: 'Track contrasting views and supporting evidence.',
    subtitleTr: 'Karşıt görüşleri ve destekleyici kanıtları takip et.',
    duration: '1:12',
    scene: 'News',
    icon: Icons.eco_rounded,
    transcript:
        'The council argues that restricting cars will improve air quality. Local shop owners support cleaner streets, yet some worry that fewer parking spaces could reduce passing trade.',
    translationTr:
        'Belediye araçları sınırlamanın hava kalitesini artıracağını savunuyor. Yerel dükkân sahipleri daha temiz sokakları destekliyor ancak bazıları daha az park yerinin müşteri trafiğini azaltmasından endişeli.',
    focusQuestionEn: 'What concerns some shop owners?',
    focusQuestionTr: 'Bazı dükkân sahiplerini ne endişelendiriyor?',
    focusOptions: [
      'Higher air pollution',
      'Reduced passing trade',
      'Too many parking spaces',
    ],
    focusAnswer: 1,
    dictationTarget: 'Restricting cars will improve air quality.',
    shadowChunk:
        'Some worry that fewer parking spaces could reduce passing trade.',
    dialoguePromptEn: 'Give a balanced response to the proposal.',
    dialoguePromptTr: 'Öneriye dengeli bir yanıt ver.',
    dialogueOptions: [
      'Cleaner air matters, but businesses may need better delivery access.',
      'Cars and shops are exactly the same.',
      'Parking should improve pollution.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'b2_customer_solution',
    level: 'B2',
    titleEn: 'Resolve a complaint',
    titleTr: 'Şikâyeti çözümle',
    subtitleEn: 'Recognise tone, responsibility and solutions.',
    subtitleTr: 'Ton, sorumluluk ve çözümleri fark et.',
    duration: '1:05',
    scene: 'Service',
    icon: Icons.support_agent_rounded,
    transcript:
        'I understand why the delay has been frustrating. We cannot replace the item today, but I can arrange express delivery at no extra cost and refund the original shipping fee.',
    translationTr:
        'Gecikmenin neden sinir bozucu olduğunu anlıyorum. Ürünü bugün değiştiremeyiz ancak ek ücret olmadan hızlı teslimat ayarlayabilir ve ilk kargo ücretini iade edebilirim.',
    focusQuestionEn: 'What two solutions are offered?',
    focusQuestionTr: 'Hangi iki çözüm sunuluyor?',
    focusOptions: [
      'A discount and collection',
      'Express delivery and a shipping refund',
      'A replacement today and free installation',
    ],
    focusAnswer: 1,
    dictationTarget: 'I can arrange express delivery at no extra cost.',
    shadowChunk: 'I understand why the delay has been frustrating.',
    dialoguePromptEn: 'Accept the solution but confirm the date.',
    dialoguePromptTr: 'Çözümü kabul et ama tarihi teyit et.',
    dialogueOptions: [
      'That sounds fair. Could you confirm when it will arrive?',
      'The refund arrives a frustration.',
      'I accept no item today yesterday.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'c1_attention_lecture',
    level: 'C1',
    titleEn: 'The attention economy',
    titleTr: 'Dikkat ekonomisi',
    subtitleEn: 'Follow an abstract argument and its qualification.',
    subtitleTr: 'Soyut bir argümanı ve sınırlandırmasını takip et.',
    duration: '1:24',
    scene: 'Lecture',
    icon: Icons.psychology_rounded,
    transcript:
        'Digital platforms do not merely compete for our time; they shape what feels worthy of attention. This does not mean users lack agency, but that individual discipline operates within systems designed to interrupt it.',
    translationTr:
        'Dijital platformlar yalnızca zamanımız için rekabet etmez; neyin dikkate değer hissettirdiğini de şekillendirir. Bu, kullanıcıların iradesi olmadığı anlamına gelmez ancak bireysel disiplin onu kesintiye uğratmak için tasarlanmış sistemler içinde işler.',
    focusQuestionEn: 'What qualification does the speaker make?',
    focusQuestionTr: 'Konuşmacı hangi sınırlandırmayı yapıyor?',
    focusOptions: [
      'Users still have some agency.',
      'Platforms never influence attention.',
      'Individual discipline is unnecessary.',
    ],
    focusAnswer: 0,
    dictationTarget: 'They shape what feels worthy of attention.',
    shadowChunk:
        'Individual discipline operates within systems designed to interrupt it.',
    dialoguePromptEn: 'Challenge the argument thoughtfully.',
    dialoguePromptTr: 'Argümana düşünceli bir itiraz getir.',
    dialogueOptions: [
      'Could the argument underestimate how differently individuals use the same platform?',
      'Attention is digital because time competes.',
      'All users have exactly no agency.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'c1_contract_negotiation',
    level: 'C1',
    titleEn: 'Contract negotiation',
    titleTr: 'Sözleşme müzakeresi',
    subtitleEn: 'Interpret diplomatic language and conditions.',
    subtitleTr: 'Diplomatik dili ve koşulları yorumla.',
    duration: '1:18',
    scene: 'Business',
    icon: Icons.handshake_rounded,
    transcript:
        'We are broadly aligned on price. The remaining issue is the cancellation clause, which, as it stands, places a disproportionate risk on our side. We could proceed if that period were reduced to thirty days.',
    translationTr:
        'Fiyat konusunda genel olarak aynı noktadayız. Kalan konu, mevcut hâliyle bizim tarafa orantısız risk yükleyen iptal maddesi. Bu süre otuz güne indirilirse ilerleyebiliriz.',
    focusQuestionEn: 'What condition would allow the deal to proceed?',
    focusQuestionTr: 'Anlaşmanın ilerlemesini hangi koşul sağlar?',
    focusOptions: [
      'A higher price',
      'A thirty-day cancellation period',
      'Removing every contract clause',
    ],
    focusAnswer: 1,
    dictationTarget: 'The remaining issue is the cancellation clause.',
    shadowChunk: 'As it stands, it places a disproportionate risk on our side.',
    dialoguePromptEn: 'Respond with a cautious compromise.',
    dialoguePromptTr: 'Temkinli bir uzlaşmayla yanıt ver.',
    dialogueOptions: [
      'We can consider thirty days, provided the notice is given in writing.',
      'The risk is broadly a price.',
      'We cancel the alignment immediately.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'c1_memory_documentary',
    level: 'C1',
    titleEn: 'How memory changes',
    titleTr: 'Hafıza nasıl değişir',
    subtitleEn: 'Distinguish claims, examples and limitations.',
    subtitleTr: 'İddia, örnek ve sınırlamaları ayırt et.',
    duration: '1:28',
    scene: 'Documentary',
    icon: Icons.movie_filter_rounded,
    transcript:
        'Memory is less like a recording and more like a reconstruction. Each act of recall can subtly alter the event, particularly when later information is emotionally vivid or repeatedly suggested.',
    translationTr:
        'Hafıza bir kayıttan çok yeniden kurmaya benzer. Her hatırlama eylemi, özellikle sonraki bilgi duygusal olarak canlıysa veya tekrar tekrar telkin ediliyorsa olayı hafifçe değiştirebilir.',
    focusQuestionEn: 'Which metaphor does the speaker reject?',
    focusQuestionTr: 'Konuşmacı hangi benzetmeyi reddediyor?',
    focusOptions: [
      'Memory as a recording',
      'Memory as reconstruction',
      'Emotion as information'
    ],
    focusAnswer: 0,
    dictationTarget: 'Memory is more like a reconstruction.',
    shadowChunk: 'Each act of recall can subtly alter the event.',
    dialoguePromptEn: 'Summarise the main implication.',
    dialoguePromptTr: 'Ana sonucu özetle.',
    dialogueOptions: [
      'Remembering an event can also reshape it.',
      'Every recording is emotionally vivid.',
      'Later information cannot affect memory.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'c2_public_policy',
    level: 'C2',
    titleEn: 'Policy under uncertainty',
    titleTr: 'Belirsizlik altında politika',
    subtitleEn: 'Unpack stance, concession and rhetorical emphasis.',
    subtitleTr: 'Tutum, taviz ve retorik vurguyu çözümle.',
    duration: '1:36',
    scene: 'Debate',
    icon: Icons.account_balance_rounded,
    transcript:
        'Demanding certainty before acting may sound prudent, yet in practice it privileges the status quo. The relevant question is not whether evidence is complete, but whether the cost of delay exceeds the risk of a reversible intervention.',
    translationTr:
        'Harekete geçmeden önce kesinlik istemek ihtiyatlı gelebilir ancak uygulamada mevcut düzeni kayırır. İlgili soru kanıtın eksiksiz olup olmadığı değil, gecikmenin maliyetinin geri alınabilir bir müdahalenin riskini aşıp aşmadığıdır.',
    focusQuestionEn: 'What does the speaker imply about waiting for certainty?',
    focusQuestionTr: 'Konuşmacı kesinliği beklemek hakkında ne ima ediyor?',
    focusOptions: [
      'It can favour the status quo.',
      'It always reduces risk.',
      'It makes intervention irreversible.',
    ],
    focusAnswer: 0,
    dictationTarget: 'In practice it privileges the status quo.',
    shadowChunk:
        'The cost of delay may exceed the risk of a reversible intervention.',
    dialoguePromptEn: 'Offer a precise counterargument.',
    dialoguePromptTr: 'Kesin bir karşı argüman sun.',
    dialogueOptions: [
      'Even reversible policies can create path dependency and unequal short-term costs.',
      'Certainty is always the same as delay.',
      'Evidence should never affect policy.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'c2_literary_review',
    level: 'C2',
    titleEn: 'A layered literary review',
    titleTr: 'Katmanlı edebiyat eleştirisi',
    subtitleEn: 'Track irony, evaluation and implicit criticism.',
    subtitleTr: 'İroni, değerlendirme ve örtük eleştiriyi takip et.',
    duration: '1:32',
    scene: 'Culture',
    icon: Icons.auto_stories_rounded,
    transcript:
        'The novel presents itself as a satire of ambition, though its fascination with the very wealth it mocks occasionally weakens the critique. Its contradictions are revealing, if not always intentional.',
    translationTr:
        'Roman kendini hırsın bir hicvi olarak sunuyor ancak alay ettiği zenginliğe duyduğu hayranlık zaman zaman eleştiriyi zayıflatıyor. Çelişkileri her zaman kasıtlı olmasa da açıklayıcı.',
    focusQuestionEn: 'What reservation does the reviewer express?',
    focusQuestionTr: 'Eleştirmen hangi çekinceyi ifade ediyor?',
    focusOptions: [
      'The satire is weakened by its fascination with wealth.',
      'The novel contains no contradictions.',
      'The author avoids ambition entirely.',
    ],
    focusAnswer: 0,
    dictationTarget: 'Its fascination with wealth weakens the critique.',
    shadowChunk: 'Its contradictions are revealing, if not always intentional.',
    dialoguePromptEn: 'Paraphrase the reviewer\'s mixed assessment.',
    dialoguePromptTr: 'Eleştirmenin karma değerlendirmesini yeniden ifade et.',
    dialogueOptions: [
      'The novel is insightful partly because it embodies the conflict it tries to criticise.',
      'The novel is only about intentional wealth.',
      'The reviewer finds no value in contradiction.',
    ],
    dialogueAnswer: 0,
  ),
  ListeningMission(
    id: 'c2_ai_ethics',
    level: 'C2',
    titleEn: 'Accountability in AI',
    titleTr: 'Yapay zekâda hesap verebilirlik',
    subtitleEn: 'Follow a dense argument across competing principles.',
    subtitleTr: 'Yoğun bir argümanı rakip ilkeler boyunca takip et.',
    duration: '1:40',
    scene: 'Forum',
    icon: Icons.hub_rounded,
    transcript:
        'Transparency is often treated as a cure-all, but explanation alone does not establish accountability. A system may be perfectly interpretable while the institution deploying it remains insulated from meaningful challenge or remedy.',
    translationTr:
        'Şeffaflık sık sık her derde deva gibi görülür ancak açıklama tek başına hesap verebilirlik sağlamaz. Bir sistem tamamen yorumlanabilirken onu kullanan kurum anlamlı itiraz veya telafiden yalıtılmış kalabilir.',
    focusQuestionEn: 'Why is transparency insufficient?',
    focusQuestionTr: 'Şeffaflık neden yetersiz?',
    focusOptions: [
      'Institutions may still avoid challenge and remedy.',
      'Interpretable systems cannot be explained.',
      'Accountability requires secrecy.',
    ],
    focusAnswer: 0,
    dictationTarget: 'Explanation alone does not establish accountability.',
    shadowChunk:
        'The institution may remain insulated from meaningful challenge or remedy.',
    dialoguePromptEn: 'Extend the argument with a practical requirement.',
    dialoguePromptTr: 'Argümanı pratik bir gereklilikle genişlet.',
    dialogueOptions: [
      'Users also need a clear route to appeal decisions and obtain correction.',
      'Institutions should explain without changing anything.',
      'Remedy makes systems less interpretable.',
    ],
    dialogueAnswer: 0,
  ),
];

List<ListeningMission> listeningMissionsForLevel(String level) {
  return listeningMissions
      .where((mission) => mission.level == level)
      .toList(growable: false);
}
