import '../../../core/app_export.dart';

class HomeDailyContentWidget extends StatefulWidget {
  const HomeDailyContentWidget({super.key});

  @override
  State<HomeDailyContentWidget> createState() => _HomeDailyContentWidgetState();
}

class _HomeDailyContentWidgetState extends State<HomeDailyContentWidget> {
  bool revealed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Content",
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _wordCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniCard(
                  color: const Color(0xFF38BDF8),
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Grammar Tip',
                  body:
                      'Use "since" for a starting point and "for" for duration.',
                  footer: 'since 2021 · for 3 years',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniCard(
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.mic_rounded,
                  title: 'Speaking',
                  body: 'Describe your morning routine in 30 seconds.',
                  footer: '+50 XP challenge',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wordCard() {
    return GestureDetector(
      onTap: () => setState(() => revealed = !revealed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2D2550),
              Color(0xFF1E293B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha(22)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withAlpha(34),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _iconBox(
              icon: Icons.auto_stories_rounded,
              colors: const [
                Color(0xFF8B5CF6),
                Color(0xFF38BDF8),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: revealed
                    ? const Column(
                        key: ValueKey('revealed'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perseverance',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '/ˌpɜːrsəˈvɪrəns/',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppTheme.textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Azim, kararlılık',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        key: ValueKey('hidden'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Word of the Day',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Perseverance',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Tap to reveal meaning',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Icon(
              revealed ? Icons.visibility_off_rounded : Icons.touch_app_rounded,
              color: Colors.white54,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCard({
    required Color color,
    required IconData icon,
    required String title,
    required String body,
    required String footer,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(36),
            const Color(0xFF1E293B),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withAlpha(70)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(28),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _smallIcon(icon, color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox({
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: Colors.white, size: 23),
    );
  }

  Widget _smallIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withAlpha(55),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }
}
