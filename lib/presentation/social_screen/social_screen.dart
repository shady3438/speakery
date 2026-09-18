import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_progress.dart';
import '../../data/community_feed_store.dart';
import '../../data/social_profile_store.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../theme/speakery_theme_tokens.dart';
import '../../widgets/ios_liquid_glass.dart';
import '../../widgets/premium_feedback.dart';
import '../../widgets/theme_toggle_button.dart';
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
  static const String _savedPostsKey = 'speakery_social_saved_posts';

  final CommunityFeedStore _feed = CommunityFeedStore.instance;

  String _filter = 'Feed';

  /// Bookmarks stay on the device — they are a private shortlist, not
  /// something other learners are meant to see.
  final Set<String> _saved = <String>{};

  /// Posts whose replies are currently expanded.
  final Set<String> _openReplies = <String>{};

  List<CommunityPost> _applyFilter(List<CommunityPost> posts) {
    if (_filter == 'Challenges') return posts.take(2).toList();
    if (_filter == 'Friends') {
      return posts.where((post) => post.type != 'Question').toList();
    }
    return posts;
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
    if (!mounted) return;
    setState(() {
      _saved
        ..clear()
        ..addAll(prefs.getStringList(_savedPostsKey) ?? const <String>[]);
    });
  }

  Future<void> _saveSocialState() async {
    final prefs = await SharedPreferences.getInstance();
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

    try {
      await _feed.createPost(
        text: content,
        type: result.type,
        name: name,
        level: level,
        help: _localCoachHint(content, result.type),
      );
    } catch (error) {
      if (!mounted) return;
      _feedback(
        error is StateError
            ? error.message
            : 'Could not share the post. Check your connection.',
        tone: PremiumFeedbackTone.error,
      );
      return;
    }

    if (!mounted) return;
    _feedback('Shared with the community.',
        tone: PremiumFeedbackTone.success);
  }

  Future<void> _toggleLike(CommunityPost post) async {
    try {
      await _feed.toggleLike(post);
    } catch (error) {
      if (!mounted) return;
      _feedback(
        error is StateError ? error.message : 'Could not update the like.',
        tone: PremiumFeedbackTone.error,
      );
    }
  }

  Future<void> _showReplyComposer(CommunityPost post) async {
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

    final profile = SocialProfileStore.instance;
    final progress = AppProgress.instance;

    try {
      await _feed.addComment(
        postId: post.id,
        text: cleanReply,
        name: profile.displayName.trim().isEmpty
            ? 'You'
            : profile.displayName.trim(),
        level: progress.englishLevel.trim().isEmpty
            ? 'A1'
            : progress.englishLevel.trim(),
      );
    } catch (error) {
      if (!mounted) return;
      _feedback(
        error is StateError ? error.message : 'Could not post the reply.',
        tone: PremiumFeedbackTone.error,
      );
      return;
    }

    if (!mounted) return;
    // Open the thread so the new reply is visible straight away.
    setState(() => _openReplies.add(post.id));
    _feedback('Reply posted.', tone: PremiumFeedbackTone.success);
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

  /// The live feed. Every signed-in account listens to the same query, so a
  /// post written on one device lands on the others without a refresh.
  Widget _buildFeed(SpeakeryThemeTokens tokens) {
    return StreamBuilder<List<CommunityPost>>(
      stream: _feed.watchFeed(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _FeedNotice(
            tokens: tokens,
            icon: Icons.cloud_off_rounded,
            title: 'Feed unavailable',
            message: _feed.isSignedIn
                ? 'Could not reach the community feed right now.'
                : 'Sign in to see what the community is posting.',
          );
        }

        if (!snapshot.hasData) {
          return _FeedNotice(
            tokens: tokens,
            icon: Icons.hourglass_top_rounded,
            title: 'Loading feed',
            message: 'Fetching the latest posts.',
          );
        }

        final posts = _applyFilter(snapshot.data!);
        if (posts.isEmpty) {
          return _FeedNotice(
            tokens: tokens,
            icon: Icons.forum_outlined,
            title: 'No posts yet',
            message: 'Be the first to share something with the community.',
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          child: Column(
            key: ValueKey('$_filter-${posts.length}'),
            children: [
              for (final post in posts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PostCard(
                    tokens: tokens,
                    post: post,
                    liked: post.likedByMe(_feed.currentUid),
                    saved: _saved.contains(post.id),
                    replyCount: post.comments,
                    repliesOpen: _openReplies.contains(post.id),
                    replies: _openReplies.contains(post.id)
                        ? _RepliesPanel(
                            tokens: tokens,
                            postId: post.id,
                            onWriteReply: () => _showReplyComposer(post),
                          )
                        : null,
                    onLike: () => _toggleLike(post),
                    onReply: () => setState(() {
                      if (!_openReplies.add(post.id)) {
                        _openReplies.remove(post.id);
                      }
                    }),
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
                          message: 'Post saved on this device.',
                          tone: PremiumFeedbackTone.success,
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
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
            padding: const EdgeInsets.fromLTRB(
                16, kThemeToggleReserve, 16, 124),
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
              _buildFeed(tokens),
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
  final CommunityPost post;
  final bool liked;
  final bool saved;
  final int replyCount;
  final bool repliesOpen;

  /// The live thread, built only while it is open so a closed post costs no
  /// Firestore listener.
  final Widget? replies;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback onSave;

  const _PostCard({
    required this.tokens,
    required this.post,
    required this.liked,
    required this.saved,
    required this.replyCount,
    required this.repliesOpen,
    required this.replies,
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
                            '${post.type} - ${post.age}',
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
            post.text,
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
                label: post.likes == 0
                    ? (liked ? 'Liked' : 'Like')
                    : '${post.likes}',
                active: liked,
                color: _pink,
                onTap: onLike,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                tokens: tokens,
                icon: repliesOpen
                    ? Icons.chat_bubble_rounded
                    : Icons.chat_bubble_outline_rounded,
                label: replyCount == 0 ? 'Replies' : 'Replies $replyCount',
                active: repliesOpen,
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
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: replies ?? const SizedBox(width: double.infinity),
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

/// The live reply thread under one post.
class _RepliesPanel extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String postId;
  final VoidCallback onWriteReply;

  const _RepliesPanel({
    required this.tokens,
    required this.postId,
    required this.onWriteReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1, color: tokens.border),
          const SizedBox(height: 10),
          StreamBuilder<List<CommunityComment>>(
            stream: CommunityFeedStore.instance.watchComments(postId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ReplyNote(
                  tokens: tokens,
                  text: 'Could not load the replies.',
                );
              }
              if (!snapshot.hasData) {
                return _ReplyNote(tokens: tokens, text: 'Loading replies...');
              }

              final replies = snapshot.data!;
              if (replies.isEmpty) {
                return _ReplyNote(
                  tokens: tokens,
                  text: 'No replies yet. Be the first to answer.',
                );
              }

              return Column(
                children: [
                  for (final reply in replies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _ReplyRow(tokens: tokens, reply: reply),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 2),
          _MiniButton(
            tokens: tokens,
            label: 'Write a reply',
            onTap: onWriteReply,
          ),
        ],
      ),
    );
  }
}

class _ReplyRow extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final CommunityComment reply;

  const _ReplyRow({required this.tokens, required this.reply});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: tokens.inputSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: tokens.brandGradient,
            ),
            child: Text(
              reply.initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reply.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      reply.level,
                      style: TextStyle(
                        color: tokens.readableAccent(_blue),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  reply.text,
                  style: TextStyle(
                    color: tokens.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyNote extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final String text;

  const _ReplyNote({required this.tokens, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: tokens.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Stands in for the post list while the feed is loading, empty, or refusing
/// to load — a blank column would read as "there is nothing here".
class _FeedNotice extends StatelessWidget {
  final SpeakeryThemeTokens tokens;
  final IconData icon;
  final String title;
  final String message;

  const _FeedNotice({
    required this.tokens,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      tokens: tokens,
      child: Column(
        children: [
          Icon(icon, size: 28, color: tokens.readableAccent(_blue)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 12.5,
              height: 1.38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplySheet extends StatefulWidget {
  final CommunityPost post;

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
            widget.post.text,
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

