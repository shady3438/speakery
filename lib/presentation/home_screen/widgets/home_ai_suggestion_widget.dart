import '../../../core/app_export.dart';
import '../../../theme/speakery_theme_adapter.dart';
import '../../chat_screen/chat_screen.dart';

class HomeAiSuggestionWidget extends StatelessWidget {
  const HomeAiSuggestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SpeakeryThemeAdapter(
              child: SpeakeryAIChatPage(),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 12),
              const Text(
                "You struggle with conditionals.\nTry a focused 8-min lesson.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _button(
                    label: "Start",
                    icon: Icons.play_arrow_rounded,
                    primary: true,
                  ),
                  const SizedBox(width: 10),
                  _button(
                    label: "Explain",
                    icon: Icons.auto_awesome_rounded,
                    primary: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text(
              "AI",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "Speakery AI",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withAlpha(18)),
          ),
          child: const Text(
            "SMART",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _button({
    required String label,
    required IconData icon,
    required bool primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: primary ? AppTheme.primaryGradient : null,
        color: primary ? null : Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: primary ? null : Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
