import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/app_progress.dart';
import '../../data/learning_models.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/premium_feedback.dart';

class QuizScreen extends StatefulWidget {
  final LessonContent lesson;

  const QuizScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int currentIndex = 0;
  int score = 0;
  int streak = 0;
  int bestStreak = 0;
  int xp = 0;

  bool answered = false;
  int? selectedIndex;

  late final AnimationController _resultController;
  late final AnimationController _pulseController;
  late final Animation<double> _resultScale;
  late final Animation<double> _resultFade;
  late final Animation<double> _pulse;

  final Color color1 = const Color(0xFF8B5CF6);
  final Color color2 = const Color(0xFF38BDF8);
  final Color color3 = const Color(0xFF6366F1);

  bool get _isEnglish => AppProgress.instance.isEnglish;
  String _copy(String english, String turkish) =>
      _isEnglish ? english : turkish;

  @override
  void initState() {
    super.initState();

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _resultScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _resultController,
        curve: Curves.easeOutBack,
      ),
    );

    _resultFade = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOut,
    );

    _pulse = Tween<double>(begin: 0.98, end: 1.025).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _resultController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _answer(int index) {
    if (answered) return;

    final question = widget.lesson.quiz[currentIndex];
    final correct = index == question.correctIndex;

    setState(() {
      selectedIndex = index;
      answered = true;

      if (correct) {
        score++;
        streak++;
        bestStreak = streak > bestStreak ? streak : bestStreak;
        xp += 10 + (streak >= 3 ? 5 : 0);
      } else {
        streak = 0;
      }
    });

    PremiumFeedback.show(
      context,
      message: correct
          ? _copy(
              'Correct. Keep the streak going!',
              'Doğru. Seriyi devam ettir!',
            )
          : _copy(
              'Almost. Check the clue and try the next one.',
              'Çok yaklaştın. İpucunu kontrol et ve sıradakini dene.',
            ),
      tone: correct ? PremiumFeedbackTone.success : PremiumFeedbackTone.error,
    );
  }

  void _nextQuestion() {
    if (currentIndex < widget.lesson.quiz.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedIndex = null;
      });
    } else {
      _showResult();
    }
  }

  void _restartQuiz() {
    setState(() {
      currentIndex = 0;
      score = 0;
      streak = 0;
      bestStreak = 0;
      xp = 0;
      answered = false;
      selectedIndex = null;
    });
  }

  void _showResult() {
    _resultController.forward(from: 0);

    final total = widget.lesson.quiz.length;
    final percent = total == 0 ? 0 : ((score / total) * 100).round();
    final title = percent >= 80
        ? _copy('Excellent Work', 'Harika İş')
        : percent >= 50
            ? _copy('Good Progress', 'İyi İlerleme')
            : _copy('Keep Practicing', 'Pratiğe Devam');

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Result',
      barrierColor: Colors.black.withAlpha(190),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) {
        final resultCard = Center(
          child: AnimatedBuilder(
            animation: _resultController,
            builder: (context, child) {
              return Opacity(
                opacity: _resultFade.value,
                child: Transform.scale(
                  scale: _resultScale.value,
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.88,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withAlpha(28),
                          Colors.white.withAlpha(10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: Colors.white.withAlpha(38)),
                      boxShadow: [
                        BoxShadow(
                          color: color1.withAlpha(95),
                          blurRadius: 38,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulse.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color1, color2],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color1.withAlpha(90),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _copy(
                            '$score / $total correct',
                            '$score / $total doğru',
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : score / total,
                            minHeight: 10,
                            backgroundColor: Colors.white.withAlpha(18),
                            valueColor: AlwaysStoppedAnimation<Color>(color2),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _resultStat(
                                Icons.bolt_rounded,
                                '$percent%',
                                _copy('Success', 'Başarı'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resultStat(
                                Icons.local_fire_department_rounded,
                                '$bestStreak',
                                _copy('Best Streak', 'En İyi Seri'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _resultStat(
                                Icons.stars_rounded,
                                '$xp',
                                'XP',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _restartQuiz();
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(_copy('Retry', 'Tekrar Dene')),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withAlpha(120),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.check_rounded),
                                label: Text(_copy('Finish', 'Bitir')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: color1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        return resultCard;
      },
    );
  }

  Widget _resultStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(22)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.lesson.quiz;
    final tokens = SpeakeryThemeTokens.of(context);

    if (quiz.isEmpty) {
      return Scaffold(
        backgroundColor:
            tokens.isVoxaTheme ? Colors.transparent : const Color(0xFF070B16),
        appBar: AppBar(
          title: Text(
            widget.lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text(
            _isEnglish
                ? 'No quiz found for this lesson.'
                : 'Bu ders için quiz bulunamadı.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final question = quiz[currentIndex];
    final progress = (currentIndex + 1) / quiz.length;

    return Scaffold(
      backgroundColor:
          tokens.isVoxaTheme ? Colors.transparent : const Color(0xFF070B16),
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _glow(color1, 230),
          ),
          Positioned(
            bottom: 80,
            left: -120,
            child: _glow(color2, 220),
          ),
          Positioned(
            top: 260,
            right: -140,
            child: _glow(const Color(0xFFEC4899), 170),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _quizHeader(progress, quiz.length),
                  const SizedBox(height: 16),
                  _questionCard(question.question),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        return _optionCard(index, question);
                      },
                    ),
                  ),
                  if (answered) _explanationCard(question.explanation),
                  const SizedBox(height: 12),
                  _bottomButton(quiz.length),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(80),
              blurRadius: 95,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quizHeader(double progress, int total) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withAlpha(22),
                Colors.white.withAlpha(7),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withAlpha(26)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _miniStat(
                    Icons.quiz_rounded,
                    'Q ${currentIndex + 1}/$total',
                    'Question',
                  ),
                  const SizedBox(width: 8),
                  _miniStat(
                    Icons.local_fire_department_rounded,
                    '$streak',
                    'Streak',
                  ),
                  const SizedBox(width: 8),
                  _miniStat(
                    Icons.stars_rounded,
                    '$xp',
                    'XP',
                  ),
                ],
              ),
              const SizedBox(height: 13),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: Colors.white.withAlpha(16),
                  valueColor: AlwaysStoppedAnimation<Color>(color1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withAlpha(18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(String text) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Transform.scale(
          scale: answered ? 1 : _pulse.value,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color1.withAlpha(80),
                  color3.withAlpha(45),
                  Colors.white.withAlpha(12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withAlpha(34)),
              boxShadow: [
                BoxShadow(
                  color: color1.withAlpha(55),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  top: -22,
                  child: Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white.withAlpha(28),
                    size: 96,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withAlpha(24)),
                      ),
                      child: Text(
                        _copy('Choose the best answer', 'En iyi cevabı seç'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.22,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionCard(int index, QuizQuestion question) {
    final isSelected = selectedIndex == index;
    final isCorrect = question.correctIndex == index;

    Color borderColor = Colors.white.withAlpha(22);
    List<Color> gradientColors = [
      Colors.white.withAlpha(18),
      Colors.white.withAlpha(7),
    ];
    IconData icon = Icons.radio_button_unchecked_rounded;
    Color iconColor = Colors.white54;

    if (answered && isSelected && isCorrect) {
      borderColor = const Color(0xFF86EFAC);
      gradientColors = [
        const Color(0xFF22C55E).withAlpha(85),
        Colors.white.withAlpha(12),
      ];
      icon = Icons.check_circle_rounded;
      iconColor = const Color(0xFF86EFAC);
    } else if (answered && isSelected && !isCorrect) {
      borderColor = const Color(0xFFFCA5A5);
      gradientColors = [
        const Color(0xFFEF4444).withAlpha(80),
        Colors.white.withAlpha(10),
      ];
      icon = Icons.cancel_rounded;
      iconColor = const Color(0xFFFCA5A5);
    } else if (answered && isCorrect) {
      borderColor = const Color(0xFF86EFAC).withAlpha(180);
      gradientColors = [
        const Color(0xFF22C55E).withAlpha(58),
        Colors.white.withAlpha(8),
      ];
      icon = Icons.check_circle_rounded;
      iconColor = const Color(0xFF86EFAC);
    }

    return GestureDetector(
      onTap: () => _answer(index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isSelected ? 0.985 : 1,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isCorrect
                          ? const Color(0xFF22C55E).withAlpha(45)
                          : const Color(0xFFEF4444).withAlpha(45),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.white.withAlpha(14)),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.options[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _explanationCard(String explanation) {
    final correct = selectedIndex != null &&
        selectedIndex == widget.lesson.quiz[currentIndex].correctIndex;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: ClipRRect(
        key: ValueKey<String>(explanation),
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: correct
                    ? [
                        const Color(0xFF22C55E).withAlpha(60),
                        Colors.white.withAlpha(10),
                      ]
                    : [
                        const Color(0xFFEF4444).withAlpha(55),
                        Colors.white.withAlpha(10),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withAlpha(24)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  correct
                      ? Icons.auto_awesome_rounded
                      : Icons.tips_and_updates_rounded,
                  color: Colors.white,
                  size: 23,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    explanation,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomButton(int total) {
    final last = currentIndex == total - 1;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: answered
            ? LinearGradient(colors: [color1, color2])
            : LinearGradient(
                colors: [
                  Colors.white.withAlpha(18),
                  Colors.white.withAlpha(8),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: answered
            ? [
                BoxShadow(
                  color: color1.withAlpha(75),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: answered ? _nextQuestion : null,
        icon: Icon(last ? Icons.flag_rounded : Icons.arrow_forward_rounded),
        label: Text(
          last
              ? _copy('Finish Quiz', 'Quizi Bitir')
              : _copy('Next Question', 'Sonraki Soru'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
