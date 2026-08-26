import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_progress.dart';
import '../../data/social_profile_store.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';
import '../speaking_screen/speaking_screen.dart';

const Color _blue = Color(0xFF3B82F6);
const Color _purple = Color(0xFF8B5CF6);
const Color _pink = Color(0xFFEC4899);
const Color _green = Color(0xFF10B981);

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  static const String _localPostsKey = 'speakery_social_local_posts';
  static const String _likedPostsKey = 'speakery_social_liked_posts';
  static const String _savedPostsKey = 'speakery_social_saved_posts';

  String _filter = 'Feed';
  final Set<String> _liked = <String>{};
  final Set<String> _saved = <String>{};

  List<_SocialPost> _posts = _seedPosts();

  static List<_SocialPost> _seedPosts() => const [
        _SocialPost(
          id: 'seed_elif_progress',
          name: 'Elif',
          level: 'A2',
          time: '8m',
          type: 'Progress',
          content:
              'I described my morning in English without translating first.',
          help: 'Nice natural sentence. Try adding one detail next time.',
          replies: 6,
        ),
        _SocialPost(
          id: 'seed_mert_question',
          name: 'Mert',
          level: 'B1',
          time: '16m',
          type: 'Question',
          content: 'Can someone check this: I go to school yesterday?',
          help: 'Try: I went to school yesterday.',
          replies: 11,
        ),
        _SocialPost(
          id: 'seed_aylin_friends',
          name: 'Aylin',
          level: 'A1',
          time: '1h',
          type: 'Friends',
          content: 'Small win: I ordered coffee in English today.',
          replies: 4,
        ),
      ];

  List<_SocialPost> get _visiblePosts {
    if (_filter == 'Challenges') return _posts.take(2).toList();
    if (_filter == 'Friends') {
      return _posts.where((post) => post.type != 'Question').toList();
    }
    return _posts;
  }

  void _feedback(
    String message, {
    PremiumFeedbackTone tone = PremiumFeedbackTone.info,
  }) {
    PremiumFeedback.show(context, message: message, tone: tone);
  }

  @override
  void initState() {
    super.initState();
    SocialProfileStore.instance.load();
    _loadSocialState();
  }

  Future<void> _loadSocialState() async {
    final prefs = await SharedPreferences.getInstance();
    final localPosts = (prefs.getStringList(_localPostsKey) ?? const <String>[])
        .map(_SocialPost.fromJsonString)
        .whereType<_SocialPost>()
        .where((post) => post.id.isNotEmpty && post.content.trim().isNotEmpty)
        .toList();
    final mergedPosts = _seedPosts();

    for (final localPost in localPosts.reversed) {
      final seedIndex =
          mergedPosts.indexWhere((post) => post.id == localPost.id);
      if (seedIndex == -1) {
        mergedPosts.insert(0, localPost);
      } else {
        mergedPosts[seedIndex] = localPost;
      }
    }

    if (!mounted) return;
    setState(() {
      _posts = mergedPosts;
      _liked
        ..clear()
        ..addAll(prefs.getStringList(_likedPostsKey) ?? const <String>[]);
      _saved
        ..clear()
        ..addAll(prefs.getStringList(_savedPostsKey) ?? const <String>[]);
    });
  }

  Future<void> _saveSocialState() async {
    final prefs = await SharedPreferences.getInstance();
    final localPosts = _posts
        .where((post) => post.local)
        .map((post) => jsonEncode(post.toJson()))
        .toList(growable: false);

    await prefs.setStringList(_localPostsKey, localPosts);
    await prefs.setStringList(_likedPostsKey, _liked.toList()..sort());
    await prefs.setStringList(_savedPostsKey, _saved.toList()..sort());
  }

  Future<void> _showComposer({
    String initialText = '',
    String type = 'Progress',
  }) async {
    final result = await showModalBottomSheet<_ComposeResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SpeakeryThemeTokens.of(context).background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ComposerSheet(initialText: initialText, type: type),
    );

    if (result == null) return;
    final content = result.content.trim();
    if (content.length < 3) {
      _feedback('Write a little more before posting.');
      return;
    }

    final profile = SocialProfileStore.instance;
    final name =
        profile.displayName.trim().isEmpty ? 'You' : profile.displayName.trim();
    final progress = AppProgress.instance;
    final level = progress.englishLevel.trim().isEmpty
        ? 'A1'
        : progress.englishLevel.trim();

    final post = _SocialPost(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      level: level,
      time: 'now',
      type: result.type,
      content: content,
      help: _localCoachHint(content, result.type),
      replies: 0,
      local: true,
    );

    setState(() => _posts.insert(0, post));
    await _saveSocialState();
    if (!mounted) return;
    _feedback('Post shared on your local feed.',
        tone: PremiumFeedbackTone.success);
  }

  Future<void> _showReplyComposer(_SocialPost post) async {
    final reply = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SpeakeryThemeTokens.of(context).background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ReplySheet(post: post),
    );

    final cleanReply = reply?.trim() ?? '';
    if (cleanReply.length < 2) return;

    setState(() {
      final index = _posts.indexWhere((item) => item.id == post.id);
      if (index == -1) return;
      _posts[index] = _posts[index].withReply(cleanReply);
    });
    await _saveSocialState();
    if (!mounted) return;
    _feedback('Reply added.', tone: PremiumFeedbackTone.success);
  }

  String? _localCoachHint(String content, String type) {
    final lower = content.toLowerCase();
    if (type == 'Question') {
      return 'Community question saved. Try adding your own correction attempt too.';
    }
    if (lower.contains('yesterday') || lower.contains('last ')) {
      return 'Nice past-time context. Check whether the main verb is in past form.';
    }
    if (content.split(RegExp(r'\s+')).length < 8) {
      return 'Good start. Add one detail to make the sentence easier to discuss.';
    }
    return null;
  }

  void _openSpeakingChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpeakeryThemeAdapter(child: SpeakingScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: IosDynamicGlassBackdrop(
        primary: tokens.secondaryAccent,
        secondary: tokens.isLight ? _pink : tokens.foxAccent,
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 124),
            children: [
              _Header(tokens: tokens),
              const SizedBox(height: 14),
              _FeaturedPrompt(
                tokens: tokens,
                onTap: () => _showComposer(
                  initialText: 'Today I learned that ',
                  type: 'Progress',
                ),
              ),
              const SizedBox(height: 12),
              _Composer(
                tokens: tokens,
                onTap: _showComposer,
              ),
              const SizedBox(height: 14),
              _FilterRow(
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: Column(
                  key: ValueKey(_filter),
                  children: [
                    for (final post in _visiblePosts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PostCard(
                          tokens: tokens,
                          post: post,
                          liked: _liked.contains(post.id),
                          saved: _saved.contains(post.id),
                          onLike: () {
                            setState(() {
                              if (!_liked.add(post.id)) _liked.remove(post.id);
                            });
                            _saveSocialState();
                          },
                          onReply: () => _showReplyComposer(post),
                          onSave: () {
                            var savedNow = false;
                            setState(() {
                              if (!_saved.add(post.id)) {
                                _saved.remove(post.id);
                              } else {
                                savedNow = true;
                              }
                            });
                            _saveSocialState();
                            if (savedNow) {
                              PremiumFeedback.show(
                                context,
                                message: 'Post saved locally.',
                                tone: PremiumFeedbackTone.success,
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              _ChallengeCard(tokens: tokens, onTap: _openSpeakingChallenge),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SpeakeryThemeTokens tokens;

  const _Header({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Social',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Learn with the community.',
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _Pill(
          tokens: tokens,
          icon: Icons.auto_awesome_rounded,
          label: 'Voxa circle',
          color: tokens.foxAccent,
        ),
      ],
    );
  }
}

class _FeaturedPrompt extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final VoidCallback onTap;

  const _FeaturedPrompt({required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      tokens: tokens,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _IconTile(tokens: tokens, icon: Icons.forum_rounded, color: _purple),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Community Prompt',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Share one sentence about your day.',
                  style: TextStyle(
                    color: tokens.textSecondary,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _MiniButton(tokens: tokens, label: 'Join', onTap: onTap),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final VoidCallback onTap;

  const _Composer({required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: tokens.inputSurface,
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_note_rounded,
                color: tokens.iconSecondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Share a sentence or question...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _CircleButton(tokens: tokens, icon: Icons.arrow_upward_rounded),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterRow({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const items = ['Feed', 'Challenges', 'Friends'];
    final index = items.indexOf(selected).clamp(0, items.length - 1);
    return IosLiquidPillSelector(
      selectedIndex: index,
      onChanged: (value) => onSelected(items[value]),
      startColor: _purple,
      endColor: _pink,
      itemColors: const [_purple, _green, _blue],
      items: const [
        IosPillItem('Feed', icon: Icons.dynamic_feed_rounded),
        IosPillItem('Challenges', icon: Icons.bolt_rounded),
        IosPillItem('Friends', icon: Icons.group_rounded),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final _SocialPost post;
  final bool liked;
  final bool saved;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onSave;

  const _PostCard({
    required this.tokens,
    required this.post,
    required this.liked,
    required this.saved,
    required this.onLike,
    required this.onReply,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(tokens: tokens, label: post.initial),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.name,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Pill(
                          tokens: tokens,
                          icon: Icons.school_rounded,
                          label: post.level,
                          color: _blue,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            '${post.type} - ${post.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            post.content,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (post.help != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: _blue.withAlpha(tokens.isLight ? 16 : 24),
                border: Border.all(
                    color: _blue.withAlpha(tokens.isLight ? 46 : 58)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_rounded,
                    color: _blue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post.help!,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _ActionButton(
                tokens: tokens,
                icon: liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: liked ? 'Liked' : 'Like',
                active: liked,
                color: _pink,
                onTap: onLike,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                tokens: tokens,
                icon: Icons.chat_bubble_outline_rounded,
                label: post.replyLabel,
                color: _purple,
                onTap: onReply,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                tokens: tokens,
                icon: saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: saved ? 'Saved' : 'Save',
                active: saved,
                color: _green,
                onTap: onSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final VoidCallback onTap;

  const _ChallengeCard({required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      tokens: tokens,
      padding: const EdgeInsets.fromLTRB(15, 14, 14, 14),
      child: Row(
        children: [
          _IconTile(tokens: tokens, icon: Icons.mic_rounded, color: _green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Speaking Prompt',
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Describe your favorite place in 30 seconds.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _MiniButton(tokens: tokens, label: 'Try', onTap: onTap),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.tokens,
    required this.child,
    this.padding = const EdgeInsets.all(15),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: tokens.glassSurface,
            border: Border.all(color: tokens.border),
            boxShadow: [
              BoxShadow(
                color: tokens.shadow.withAlpha(tokens.isLight ? 24 : 70),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;

  const _Avatar({required this.tokens, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: tokens.brandGradient,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final Color color;

  const _IconTile({
    required this.tokens,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withAlpha(tokens.isLight ? 22 : 34),
        border: Border.all(color: color.withAlpha(tokens.isLight ? 56 : 70)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _Pill extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(tokens.isLight ? 18 : 28),
        border: Border.all(color: color.withAlpha(tokens.isLight ? 48 : 62)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final visibleColor = active ? color : tokens.iconSecondary;
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active
              ? color.withAlpha(tokens.isLight ? 18 : 26)
              : tokens.chipSurface,
          border:
              Border.all(color: active ? color.withAlpha(58) : tokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: visibleColor, size: 17),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? color : tokens.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String label;
  final VoidCallback onTap;

  const _MiniButton({
    required this.tokens,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: tokens.brandGradient,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;

  const _CircleButton({required this.tokens, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: tokens.brandGradient,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapScale({required this.child, required this.onTap});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? .975 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _ComposeResult {
  final String content;
  final String type;

  const _ComposeResult({
    required this.content,
    required this.type,
  });
}

class _ComposerSheet extends StatefulWidget {
  final String initialText;
  final String type;

  const _ComposerSheet({
    required this.initialText,
    required this.type,
  });

  @override
  State<_ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends State<_ComposerSheet> {
  late final TextEditingController _controller;
  late String _type;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _type = widget.type;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        16,
        18,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _SheetHandle(tokens: tokens)),
          const SizedBox(height: 16),
          Text(
            'Share with the community',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _SheetChip(
                label: 'Progress',
                selected: _type == 'Progress',
                onTap: () => setState(() => _type = 'Progress'),
              ),
              _SheetChip(
                label: 'Question',
                selected: _type == 'Question',
                onTap: () => setState(() => _type = 'Question'),
              ),
              _SheetChip(
                label: 'Friends',
                selected: _type == 'Friends',
                onTap: () => setState(() => _type = 'Friends'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 4,
            minLines: 3,
            style: TextStyle(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
            decoration: InputDecoration(
              hintText: 'Write a sentence, question, or small win...',
              hintStyle: TextStyle(color: tokens.textMuted),
              filled: true,
              fillColor: tokens.inputSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: tokens.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: _purple),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SheetButton(
            label: 'Post',
            icon: Icons.arrow_upward_rounded,
            onTap: () => Navigator.pop(
              context,
              _ComposeResult(content: _controller.text, type: _type),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplySheet extends StatefulWidget {
  final _SocialPost post;

  const _ReplySheet({required this.post});

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        16,
        18,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _SheetHandle(tokens: tokens)),
          const SizedBox(height: 16),
          Text(
            'Reply to ${widget.post.name}',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            minLines: 2,
            style: TextStyle(color: tokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Write a helpful reply...',
              hintStyle: TextStyle(color: tokens.textMuted),
              filled: true,
              fillColor: tokens.inputSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: tokens.border),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SheetButton(
            label: 'Reply',
            icon: Icons.chat_bubble_rounded,
            onTap: () => Navigator.pop(context, _controller.text),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final SpeakeryThemeTokens tokens;

  const _SheetHandle({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.border,
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SheetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? _purple.withAlpha(26) : tokens.chipSurface,
          border: Border.all(
            color: selected ? _purple.withAlpha(70) : tokens.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _purple : tokens.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [_purple, _pink]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialPost {
  final String id;
  final String name;
  final String level;
  final String time;
  final String type;
  final String content;
  final String? help;
  final int replies;
  final bool local;
  final List<String> localReplies;

  const _SocialPost({
    required this.id,
    required this.name,
    required this.level,
    required this.time,
    required this.type,
    required this.content,
    this.help,
    required this.replies,
    this.local = false,
    this.localReplies = const <String>[],
  });

  String get initial => name.isEmpty ? 'S' : name.substring(0, 1).toUpperCase();
  int get totalReplies => replies + localReplies.length;
  String get replyLabel => totalReplies == 0 ? 'Reply' : 'Reply $totalReplies';

  _SocialPost withReply(String reply) {
    return _SocialPost(
      id: id,
      name: name,
      level: level,
      time: time,
      type: type,
      content: content,
      help: help,
      replies: replies,
      local: true,
      localReplies: [...localReplies, reply],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'time': time,
      'type': type,
      'content': content,
      'help': help,
      'replies': replies,
      'local': local,
      'localReplies': localReplies,
    };
  }

  static _SocialPost? fromJsonString(String value) {
    try {
      final data = jsonDecode(value) as Map<String, dynamic>;
      return _SocialPost(
        id: data['id'] as String? ?? '',
        name: data['name'] as String? ?? 'You',
        level: data['level'] as String? ?? 'A1',
        time: data['time'] as String? ?? 'now',
        type: data['type'] as String? ?? 'Progress',
        content: data['content'] as String? ?? '',
        help: data['help'] as String?,
        replies: data['replies'] as int? ?? 0,
        local: data['local'] as bool? ?? true,
        localReplies: (data['localReplies'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
      );
    } catch (_) {
      return null;
    }
  }
}
