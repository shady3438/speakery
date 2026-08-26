import '../../../core/app_export.dart';
import '../../../widgets/premium_feedback.dart';

class LearnFeaturedCarouselWidget extends StatefulWidget {
  const LearnFeaturedCarouselWidget({super.key});

  @override
  State<LearnFeaturedCarouselWidget> createState() =>
      _LearnFeaturedCarouselWidgetState();
}

class _LearnFeaturedCarouselWidgetState
    extends State<LearnFeaturedCarouselWidget> {
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.88);

  static const List<Map<String, dynamic>> _featuredItems = [
    {
      'title': 'IELTS Writing Task 2\nMasterclass',
      'subtitle': 'Band 7+ strategies with AI feedback',
      'tag': 'IELTS Prep',
      'tagColor': Color(0xFFEC4899),
      'xpReward': 200,
      'duration': '45 min',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_18950ab5b-1772632146648.png',
      'imageSemantic':
          'Student writing in notebook at desk with open textbooks, study session',
      'gradient': [Color(0xFFEC4899), Color(0xFF7C3AED)],
    },
    {
      'title': '30 Essential Phrasal\nVerbs for B2',
      'subtitle': 'Master the most common phrasal verbs in context',
      'tag': 'Vocabulary',
      'tagColor': Color(0xFF10B981),
      'xpReward': 120,
      'duration': '30 min',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1eb468843-1765962682372.png',
      'imageSemantic':
          'Open English vocabulary book with highlighted words on wooden desk',
      'gradient': [Color(0xFF10B981), Color(0xFF3B82F6)],
    },
    {
      'title': 'Conditional Sentences:\nAll 4 Types Explained',
      'subtitle': 'Zero, first, second and third conditionals with examples',
      'tag': 'Grammar',
      'tagColor': Color(0xFF6366F1),
      'xpReward': 150,
      'duration': '22 min',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_126d46918-1765269383666.png',
      'imageSemantic':
          'Grammar lesson on whiteboard with English sentence structures and arrows',
      'gradient': [Color(0xFF6366F1), Color(0xFF3B82F6)],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Featured Content',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _featuredItems.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final item = _featuredItems[index];
                final gradientColors = (item['gradient'] as List).cast<Color>();
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 20 : 8,
                    right: index == _featuredItems.length - 1 ? 20 : 8,
                  ),
                  child: _FeaturedCard(
                    item: item,
                    gradientColors: gradientColors,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _featuredItems.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? AppTheme.primary
                      : AppTheme.textMuted.withAlpha(102),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final List<Color> gradientColors;

  const _FeaturedCard({required this.item, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PremiumFeedback.show(
        context,
        message: 'Start a matching practice from the Learn overview.',
        icon: Icons.play_circle_rounded,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CustomImageWidget(
              imageUrl: item['imageUrl'] as String,
              width: double.infinity,
              height: 190,
              fit: BoxFit.cover,
              semanticLabel: item['imageSemantic'] as String,
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors.first.withAlpha(217),
                    gradientColors.last.withAlpha(166),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withAlpha(77),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item['tag'] as String,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(64),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '+${item['xpReward']} XP',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Bottom content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: Colors.white.withAlpha(204),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  size: 14,
                                  color: gradientColors.first,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Start',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: gradientColors.first,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['duration'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
