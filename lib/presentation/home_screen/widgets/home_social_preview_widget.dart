import 'dart:ui';

import '../../../core/app_export.dart';

class HomeSocialPreviewWidget extends StatelessWidget {
  const HomeSocialPreviewWidget({super.key});

  static final List<Map<String, dynamic>> _previewPosts = [
    {
      'userName': 'Mehmet',
      'userLevel': 'B2',
      'timeAgo': '2m ago',
      'content': 'Just finished IELTS Writing practice 🚀',
      'likes': 24,
      'comments': 7,
      'initial': 'M',
    },
    {
      'userName': 'Zeynep',
      'userLevel': 'A2',
      'timeAgo': '18m ago',
      'content': '21 day streak today 🔥',
      'likes': 41,
      'comments': 12,
      'initial': 'Z',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Community Activity',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryLight.withAlpha(210),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._previewPosts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SocialPreviewCard(post: post),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialPreviewCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const _SocialPreviewCard({required this.post});

  @override
  State<_SocialPreviewCard> createState() => _SocialPreviewCardState();
}

class _SocialPreviewCardState extends State<_SocialPreviewCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final likes = (widget.post['likes'] as int) + (_liked ? 1 : 0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withAlpha(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF38BDF8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    widget.post['initial'] as String,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.post['userName'] as String,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        _LevelPill(level: widget.post['userLevel'] as String),
                        const SizedBox(width: 7),
                        Text(
                          widget.post['timeAgo'] as String,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.post['content'] as String,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _liked = !_liked),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _liked
                                  ? const Color(0xFF8B5CF6).withAlpha(28)
                                  : Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _liked
                                    ? const Color(0xFF8B5CF6).withAlpha(70)
                                    : Colors.white.withAlpha(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _liked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 17,
                                  color: _liked
                                      ? const Color(0xFFC4B5FD)
                                      : Colors.white54,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$likes',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _liked
                                        ? const Color(0xFFC4B5FD)
                                        : Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _MiniAction(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: '${widget.post['comments']}',
                        ),
                        const Spacer(),
                        Icon(
                          Icons.ios_share_rounded,
                          color: Colors.white.withAlpha(90),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  final String level;

  const _LevelPill({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.cefrLevelColor(level).withAlpha(28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppTheme.cefrLevelColor(level).withAlpha(55),
        ),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppTheme.cefrLevelColor(level),
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniAction({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
