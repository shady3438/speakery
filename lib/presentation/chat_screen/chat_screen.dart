import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../theme/speakery_theme_tokens.dart';
import '../../theme/speakery_theme_adapter.dart';
import '../../services/ai_service.dart';
import '../../widgets/ios_liquid_glass.dart';

const Color _bg = Color(0xFF050712);
const Color _blue = Color(0xFF00C2FF);
const Color _purple = Color(0xFF8B5CF6);
const Color _pink = Color(0xFFFF4FD8);
const Color _green = Color(0xFF22C55E);
const Color _amber = Color(0xFFF59E0B);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = const ['All', 'Unread', 'Practice', 'Groups'];

  final List<_ConversationItem> _conversations = const <_ConversationItem>[
    _ConversationItem(
      id: 'voxa',
      name: 'Voxa Coach',
      level: 'AI',
      preview: 'Send a sentence or voice note for instant practice.',
      time: 'Now',
      unreadCount: 1,
      colorA: Color(0xFFFF7A12),
      colorB: Color(0xFFEC4899),
      isOnline: true,
      avatarLetter: 'V',
      isCoach: true,
      hasVoiceNote: true,
    ),
    _ConversationItem(
      id: 'ece',
      name: 'Ece',
      level: 'A2',
      preview: 'Can we practise daily routines later?',
      time: '9m',
      unreadCount: 2,
      colorA: Color(0xFF38BDF8),
      colorB: Color(0xFF8B5CF6),
      isOnline: true,
      avatarLetter: 'E',
    ),
    _ConversationItem(
      id: 'mert',
      name: 'Mert',
      level: 'B1',
      preview: 'Voice note - 0:18',
      time: '24m',
      unreadCount: 0,
      colorA: Color(0xFF22C55E),
      colorB: Color(0xFF00C2FF),
      isOnline: false,
      avatarLetter: 'M',
      hasVoiceNote: true,
    ),
    _ConversationItem(
      id: 'aylin',
      name: 'Aylin',
      level: 'B2',
      preview: 'Your sentence sounds more natural now.',
      time: '1h',
      unreadCount: 0,
      colorA: Color(0xFFFF4FD8),
      colorB: Color(0xFF8B5CF6),
      isOnline: true,
      avatarLetter: 'A',
    ),
  ];

  List<_ConversationItem> get _filteredConversations {
    var base = List<_ConversationItem>.from(_conversations);

    if (_selectedTabIndex == 1) {
      base = base.where((e) => e.unreadCount > 0).toList();
    } else if (_selectedTabIndex == 2) {
      base = base
          .where((e) => e.isCoach || e.hasVoiceNote || e.level == 'B1')
          .toList();
    } else if (_selectedTabIndex == 3) {
      base = const <_ConversationItem>[];
    }

    return base;
  }

  void _openConversation(_ConversationItem item) {
    if (item.isCoach) {
      _openVoxaCoach();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SpeakeryThemeAdapter(
          child: _ConversationDetailScreen(conversation: item),
        ),
      ),
    );
  }

  void _openVoxaCoach() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SpeakeryThemeAdapter(child: VoxaCoachScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _filteredConversations;
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      body: IosDynamicGlassBackdrop(
        primary: tokens.primaryAccent,
        secondary: tokens.secondaryAccent,
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: _MessagesHeader(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _VoxaHeroCard(onTap: _openVoxaCoach),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    return _FilterPill(
                      label: _tabs[index],
                      selected: index == _selectedTabIndex,
                      onTap: () => setState(() => _selectedTabIndex = index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: conversations.isEmpty
                    ? _EmptyState(onStartVoxa: _openVoxaCoach)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: conversations.length + 1,
                        itemBuilder: (context, index) {
                          if (index == conversations.length) {
                            return const _BottomHint();
                          }
                          final item = conversations[index];
                          return _FadeInUp(
                            delay: Duration(milliseconds: 40 * index),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ConversationCard(
                                item: item,
                                onTap: () => _openConversation(item),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AppShell compatibility. AppShell can keep calling SpeakeryAIChatPage().
class SpeakeryAIChatPage extends StatelessWidget {
  const SpeakeryAIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VoxaCoachScreen();
  }
}

class _ConversationDetailScreen extends StatefulWidget {
  final _ConversationItem conversation;

  const _ConversationDetailScreen({required this.conversation});

  @override
  State<_ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<_ConversationDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _voiceRecorder = AudioRecorder();
  DateTime? _recordingStartedAt;
  Timer? _timeTicker;

  late final List<_ChatMessage> _messages = <_ChatMessage>[];

  bool _showTyping = false;
  bool _isRecording = false;
  _ChatMessage? _replyingTo;

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      _ChatMessage(
        id: 'peer-${widget.conversation.id}-1',
        text: widget.conversation.preview.trim().isEmpty
            ? 'Hey, ready to practise a little English?'
            : widget.conversation.preview,
        isMe: false,
        time: widget.conversation.time,
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ]);
    _timeTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timeTicker?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    unawaited(_voiceRecorder.dispose());
    super.dispose();
  }

  void _sendMessage() {
    final value = _messageController.text.trim();
    if (value.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: value,
          isMe: true,
          time: _currentTime(),
          createdAt: DateTime.now(),
          replyTo: _replyingTo?.text,
        ),
      );
      _messageController.clear();
      _replyingTo = null;
      _showTyping = false;
    });

    _scrollBottom();
  }

  Future<void> _sendVoiceNote() async {
    if (_isRecording) {
      final path = await _voiceRecorder.stop();
      final started = _recordingStartedAt;
      final duration =
          started == null ? Duration.zero : DateTime.now().difference(started);
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordingStartedAt = null;
        if (path != null &&
            path.isNotEmpty &&
            File(path).existsSync() &&
            File(path).lengthSync() > 0) {
          _messages.add(
            _ChatMessage(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              text: 'Voice note • ${_formatDuration(duration)}',
              isMe: true,
              time: _currentTime(),
              createdAt: DateTime.now(),
              isVoice: true,
              voicePath: path,
              durationLabel: _formatDuration(duration),
              replyTo: _replyingTo?.text,
            ),
          );
          _replyingTo = null;
        }
      });
      _scrollBottom();

      // Important:
      // Stopping a recording should only add the user's voice-note bubble.
      // Do not auto-generate a bot/AI reply here; that made a mic tap feel
      // like a normal text message submission.
      return;
    }

    final hasPermission = await _voiceRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Microphone permission is required to send a voice note.')),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/speakery_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _voiceRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
        echoCancel: false,
        noiseSuppress: false,
        autoGain: false,
      ),
      path: filePath,
    );

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordingStartedAt = DateTime.now();
    });
  }

  String _formatDuration(Duration duration) {
    final rawSeconds = (duration.inMilliseconds / 1000).ceil();
    final seconds = rawSeconds.clamp(0, 599);
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }

  void _scrollBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 160,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _currentTime() {
    final now = TimeOfDay.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.conversation;
    final tokens = SpeakeryThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _PremiumBackground(detailMode: true),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: _ConversationHeader(item: item),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                    itemCount: _messages.length + (_showTyping ? 2 : 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Center(child: _DatePill(label: 'Today')),
                        );
                      }
                      final messageIndex = index - 1;
                      if (_showTyping && messageIndex == _messages.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 10),
                          child: _TypingIndicator(
                            colorA: item.colorA,
                            colorB: item.colorB,
                            avatarLetter: item.avatarLetter,
                            useImageAvatar: item.isCoach,
                            label: '${item.name} is typing',
                          ),
                        );
                      }
                      final message = _messages[messageIndex];
                      final previous =
                          messageIndex > 0 ? _messages[messageIndex - 1] : null;
                      final compactTop =
                          previous != null && previous.isMe == message.isMe;
                      return Padding(
                        padding: EdgeInsets.only(bottom: compactTop ? 6 : 11),
                        child: _MessageBubble(
                          message: message,
                          colorA: item.colorA,
                          colorB: item.colorB,
                          avatarLetter: item.avatarLetter,
                          showAvatar: !message.isMe && !compactTop,
                          useImageAvatar: item.isCoach && !message.isMe,
                          onReply: () => setState(() => _replyingTo = message),
                        ),
                      );
                    },
                  ),
                ),
                if (_replyingTo != null)
                  _ReplyPreview(
                    message: _replyingTo!,
                    onClose: () => setState(() => _replyingTo = null),
                  ),
                if (_isRecording) const _RecordingPreview(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: _PremiumInputBar(
                    controller: _messageController,
                    hintText: 'Message ${item.name}...',
                    onChanged: (_) => setState(() {}),
                    onSend: _sendMessage,
                    onVoice: _sendVoiceNote,
                    isRecording: _isRecording,
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

class VoxaCoachScreen extends StatefulWidget {
  const VoxaCoachScreen({super.key});

  @override
  State<VoxaCoachScreen> createState() => _VoxaCoachScreenState();
}

class _VoxaCoachScreenState extends State<VoxaCoachScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecorder _voiceRecorder = AudioRecorder();
  DateTime? _recordingStartedAt;
  Timer? _timeTicker;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      id: 'v1',
      text:
          "Hi, I'm Voxa. Send a sentence, thought, or voice note, and I'll help you sound clearer and more natural in English.",
      isMe: false,
      time: 'Now',
      createdAt: DateTime.now(),
    ),
  ];

  String _selectedMode = 'correct';
  bool _isLoading = false;
  bool _isRecording = false;
  _ChatMessage? _replyingTo;

  @override
  void initState() {
    super.initState();
    _timeTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timeTicker?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    unawaited(_voiceRecorder.dispose());
    super.dispose();
  }

  Future<void> _send({String? overrideText}) async {
    final text = (overrideText ?? _inputController.text).trim();
    if (text.isEmpty || _isLoading) return;
    final reply = _replyingTo;

    setState(() {
      _messages.add(
        _ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          isMe: true,
          time: 'Now',
          createdAt: DateTime.now(),
          replyTo: reply?.text,
        ),
      );
      _inputController.clear();
      _replyingTo = null;
      _isLoading = true;
    });
    _scrollBottom();

    final answer = await _voxaReply(text, reply?.text);
    if (!mounted) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: answer,
          isMe: false,
          time: 'Now',
          createdAt: DateTime.now(),
        ),
      );
      _isLoading = false;
    });
    _scrollBottom();
  }

  Future<String> _voxaReply(String input, String? replyTo) async {
    if (!AIService.isConfigured) return _localVoxaReply(input);

    try {
      final replyContext = replyTo == null || replyTo.trim().isEmpty
          ? null
          : (replyTo.length > 220 ? replyTo.substring(0, 220) : replyTo);
      final result = await AIService.feedback(
        task: AIFeedbackTask.chat,
        text: input,
        context: {
          'mode': _selectedMode,
          if (replyContext != null) 'reply': replyContext,
        },
      );
      final answer = result['result']?.trim();
      if (answer != null && answer.isNotEmpty) return answer;
    } catch (_) {
      // Keep Voxa usable offline or when the configured endpoint is down.
    }

    return _localVoxaReply(input);
  }

  String _localVoxaReply(String input) {
    switch (_selectedMode) {
      case 'grammar':
        return 'Grammar note\n\nYour idea is clear. The key point is word order and tense consistency.\n\nTry this: "I usually practise English after work."';
      case 'speaking':
        return 'Speaking practice\n\nGood start. Answer with one clear reason and one example.\n\nQuestion: What kind of places do you enjoy visiting on holiday?';
      case 'examples':
        return 'Five natural examples\n\n1. I practise English every day.\n2. She sounds more confident now.\n3. This phrase is common in daily English.\n4. Try to speak more slowly.\n5. That answer sounds natural.';
      default:
        return 'Corrected version\n\n"I usually try to improve my English by speaking every day."\n\nQuick note: Your meaning is clear. This version sounds smoother and more natural.';
    }
  }

  Future<void> _sendVoice() async {
    if (_isLoading) return;

    if (_isRecording) {
      final path = await _voiceRecorder.stop();
      final started = _recordingStartedAt;
      final duration =
          started == null ? Duration.zero : DateTime.now().difference(started);
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordingStartedAt = null;
        if (path != null &&
            path.isNotEmpty &&
            File(path).existsSync() &&
            File(path).lengthSync() > 0) {
          _messages.add(
            _ChatMessage(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              text: 'Voice note • ${_formatDuration(duration)}',
              isMe: true,
              time: 'Now',
              createdAt: DateTime.now(),
              isVoice: true,
              voicePath: path,
              durationLabel: _formatDuration(duration),
              replyTo: _replyingTo?.text,
            ),
          );
          _replyingTo = null;
        }
      });
      _scrollBottom();
      return;
    }

    final hasPermission = await _voiceRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Microphone permission is required to send a voice note.')),
      );
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/speakery_voxa_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _voiceRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 44100,
        numChannels: 1,
        echoCancel: false,
        noiseSuppress: false,
        autoGain: false,
      ),
      path: filePath,
    );

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordingStartedAt = DateTime.now();
    });
  }

  String _formatDuration(Duration duration) {
    final rawSeconds = (duration.inMilliseconds / 1000).ceil();
    final seconds = rawSeconds.clamp(0, 599);
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }

  void _scrollBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 170,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const _PremiumBackground(detailMode: true),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: _VoxaHeader(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: _ModeSelector(
                    selected: _selectedMode,
                    onChanged: (value) => setState(() => _selectedMode = value),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                    itemCount: _messages.length + (_isLoading ? 2 : 1),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Center(child: _DatePill(label: 'Today')),
                        );
                      }
                      final messageIndex = index - 1;
                      if (_isLoading && messageIndex == _messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 2, bottom: 10),
                          child: _TypingIndicator(
                            colorA: _purple,
                            colorB: _blue,
                            avatarLetter: 'V',
                            useImageAvatar: true,
                            label: 'Voxa is thinking',
                          ),
                        );
                      }
                      final message = _messages[messageIndex];
                      final previous =
                          messageIndex > 0 ? _messages[messageIndex - 1] : null;
                      final compactTop =
                          previous != null && previous.isMe == message.isMe;
                      return Padding(
                        padding: EdgeInsets.only(bottom: compactTop ? 6 : 11),
                        child: _MessageBubble(
                          message: message,
                          colorA: _purple,
                          colorB: _blue,
                          avatarLetter: 'V',
                          showAvatar: !message.isMe && !compactTop,
                          useImageAvatar: !message.isMe,
                          onReply: () => setState(() => _replyingTo = message),
                        ),
                      );
                    },
                  ),
                ),
                if (_replyingTo != null)
                  _ReplyPreview(
                    message: _replyingTo!,
                    onClose: () => setState(() => _replyingTo = null),
                  ),
                if (_isRecording) const _RecordingPreview(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: _PremiumInputBar(
                    controller: _inputController,
                    hintText: 'Ask Voxa anything...',
                    onChanged: (_) => setState(() {}),
                    onSend: () => unawaited(_send()),
                    onVoice: _sendVoice,
                    isRecording: _isRecording,
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

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader();

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Messages',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Practice English in natural chats.',
                style: TextStyle(
                  color: tokens.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 0),
      ],
    );
  }
}

class _VoxaHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _VoxaHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: _GlassPanel(
        radius: 26,
        padding: const EdgeInsets.fromLTRB(15, 15, 13, 15),
        child: Row(
          children: [
            const _VoxaAvatar(size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Voxa',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 16.2,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'AI speaking coach · ready',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textSecondary,
                      fontSize: 11.6,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Practice naturally. Get instant corrections.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 12.4,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: tokens.chipSurface,
                    border: Border.all(color: tokens.border),
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      color: tokens.iconSecondary, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  final _ConversationItem item;

  const _ConversationHeader({required this.item});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(7, 7, 9, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: tokens.glassSurface,
            border: Border.all(color: tokens.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
                compact: true,
              ),
              const SizedBox(width: 8),
              _AvatarBadge(item: item, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusDot(online: item.isOnline),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.isOnline ? 'Active now' : 'Last seen recently',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 11.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _MiniStatusPill(label: item.level, color: item.colorA),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CircleButton(
                icon: Icons.call_rounded,
                onTap: () => _showPracticeCallSheet(context, item),
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPracticeCallSheet(BuildContext context, _ConversationItem item) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PracticeCallSheet(item: item),
  );
}

class _PracticeCallSheet extends StatefulWidget {
  final _ConversationItem item;

  const _PracticeCallSheet({required this.item});

  @override
  State<_PracticeCallSheet> createState() => _PracticeCallSheetState();
}

class _PracticeCallSheetState extends State<_PracticeCallSheet> {
  static const List<String> _prompts = [
    'Describe your day in three clear sentences.',
    'Ask one follow-up question, then answer it yourself.',
    'Give one opinion and one reason.',
    'Repeat your best answer more slowly and naturally.',
  ];

  Timer? _timer;
  int _seconds = 0;
  bool _active = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_active) {
      _timer?.cancel();
      setState(() => _active = false);
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds += 1);
    });
    setState(() => _active = true);
  }

  String get _duration {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get _prompt => _prompts[(_seconds ~/ 25) % _prompts.length];

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            decoration: BoxDecoration(
              color: tokens.glassSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: tokens.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(72),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.textMuted.withAlpha(90),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _AvatarBadge(item: item, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Practice call with ${item.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _active
                                ? 'Speak out loud. Use the prompt below.'
                                : 'Warm up first, then start the timer.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tokens.inputSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _active
                                ? Icons.graphic_eq_rounded
                                : Icons.phone_in_talk_rounded,
                            color: item.colorA,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _duration,
                            style: TextStyle(
                              color: tokens.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          const Spacer(),
                          _MiniStatusPill(
                            label: _active ? 'LIVE' : 'READY',
                            color: _active ? _green : item.colorA,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _prompt,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _PracticeCallButton(
                        label: _active ? 'Pause' : 'Start',
                        icon: _active
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: item.colorA,
                        primary: true,
                        onTap: _toggle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PracticeCallButton(
                        label: 'Finish',
                        icon: Icons.check_rounded,
                        color: _green,
                        primary: false,
                        onTap: () => Navigator.of(context).pop(),
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
}

class _PracticeCallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool primary;
  final VoidCallback onTap;

  const _PracticeCallButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: primary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, _purple],
                )
              : null,
          color: primary ? null : tokens.chipSurface,
          border: Border.all(
            color: primary ? Colors.white.withAlpha(34) : tokens.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary ? Colors.white : color, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primary ? Colors.white : tokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoxaHeader extends StatelessWidget {
  const _VoxaHeader();

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(7, 7, 11, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: tokens.glassSurface,
            border: Border.all(color: tokens.border),
            boxShadow: [
              BoxShadow(
                color: _purple.withAlpha(18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).maybePop(),
                compact: true,
              ),
              const SizedBox(width: 9),
              const _VoxaAvatar(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voxa',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 16.8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.26,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const _StatusDot(online: true),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'AI coach · ready',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.textSecondary,
                              fontSize: 11.2,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _ModeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    const modes = [
      _ModeSpec('correct', 'Correct', Icons.auto_fix_high_rounded),
      _ModeSpec('grammar', 'Grammar', Icons.school_rounded),
      _ModeSpec('examples', 'Examples', Icons.auto_stories_rounded),
      _ModeSpec('speaking', 'Speak', Icons.mic_rounded),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: tokens.inputSurface,
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: modes.map((mode) {
              final isSelected = selected == mode.id;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _TapScale(
                    onTap: () => onChanged(mode.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: isSelected
                            ? (tokens.isVoxaTheme
                                ? tokens.brandGradient
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _blue.withAlpha(56),
                                      _purple.withAlpha(72),
                                      _pink.withAlpha(54),
                                    ],
                                  ))
                            : null,
                        color: isSelected ? null : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withAlpha(18)
                              : Colors.transparent,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _purple.withAlpha(14),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(mode.icon,
                              size: 12.5,
                              color: isSelected
                                  ? Colors.white
                                  : tokens.iconSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              mode.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : tokens.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.05,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PremiumInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final bool isRecording;

  const _PremiumInputBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onSend,
    required this.onVoice,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    final tokens = SpeakeryThemeTokens.of(context);

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 230),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(8, 9, 8, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(31),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tokens.glassStrong,
                  tokens.inputSurface,
                  _purple.withAlpha(hasText ? 18 : 9),
                ],
              ),
              border: Border.all(
                color: hasText
                    ? tokens.primaryAccent.withAlpha(72)
                    : tokens.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(68),
                  blurRadius: 28,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.white.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, -1),
                ),
                if (hasText)
                  BoxShadow(
                    color: _blue.withAlpha(9),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _InputIconButton(
                  icon: isRecording
                      ? Icons.graphic_eq_rounded
                      : Icons.mic_none_rounded,
                  color: isRecording ? _pink : _blue,
                  onTap: onVoice,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: 44, maxHeight: 118),
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontSize: 14.8,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                      cursorColor: _blue,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: tokens.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                _SendButton(onTap: onSend, enabled: hasText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final Color colorA;
  final Color colorB;
  final String avatarLetter;
  final bool showAvatar;
  final bool useImageAvatar;
  final VoidCallback onReply;

  const _MessageBubble({
    required this.message,
    required this.colorA,
    required this.colorB,
    required this.avatarLetter,
    required this.showAvatar,
    required this.useImageAvatar,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth =
        screenWidth < 380 ? screenWidth * 0.78 : screenWidth * 0.74;
    final isMe = message.isMe;
    final isVoxa = useImageAvatar && !isMe;
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(25),
      topRight: const Radius.circular(25),
      bottomLeft: Radius.circular(isMe ? 25 : 10),
      bottomRight: Radius.circular(isMe ? 10 : 25),
    );

    final bubble = _TapScale(
      onLongPress: onReply,
      child: ClipRRect(
        borderRadius: bubbleRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: isVoxa ? 18 : 10, sigmaY: isVoxa ? 18 : 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: EdgeInsets.fromLTRB(16, message.isVoice ? 12 : 14, 16, 10),
            decoration: BoxDecoration(
              borderRadius: bubbleRadius,
              gradient: isMe
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _blue.withAlpha(92),
                        _purple.withAlpha(100),
                        _pink.withAlpha(76),
                      ],
                    )
                  : isVoxa
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withAlpha(15),
                            const Color(0xFF101827).withAlpha(232),
                            _purple.withAlpha(22),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withAlpha(11),
                            const Color(0xFF0E1624).withAlpha(238),
                            Colors.white.withAlpha(4),
                          ],
                        ),
              border: Border.all(
                color: isMe
                    ? Colors.white.withAlpha(25)
                    : isVoxa
                        ? Colors.white.withAlpha(18)
                        : Colors.white.withAlpha(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: isVoxa
                      ? Colors.black.withAlpha(28)
                      : Colors.black.withAlpha(isMe ? 22 : 25),
                  blurRadius: isVoxa ? 20 : 12,
                  offset: const Offset(0, 8),
                ),
                if (isVoxa)
                  BoxShadow(
                    color: _purple.withAlpha(8),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.replyTo != null && message.replyTo!.isNotEmpty) ...[
                  _InlineReplyPreview(
                    text: message.replyTo!,
                    accent: isMe ? Colors.white : colorB,
                  ),
                  const SizedBox(height: 8),
                ],
                if (message.isVoice)
                  _VoiceMessage(
                      color: isMe ? Colors.white : colorB,
                      isMe: isMe,
                      durationLabel: message.durationLabel ?? '0:01',
                      voicePath: message.voicePath)
                else
                  Text(
                    message.text,
                    style: TextStyle(
                      color: Colors.white.withAlpha(246),
                      fontSize: 15,
                      height: 1.42,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _relativeTimeLabel(message.createdAt, message.time),
                      style: TextStyle(
                        color: Colors.white.withAlpha(isMe ? 174 : 116),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 5),
                      Icon(Icons.done_all_rounded,
                          size: 14, color: Colors.white.withAlpha(198)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final avatar = useImageAvatar
        ? const _VoxaAvatar(size: 34)
        : _LetterAvatar(
            letter: avatarLetter, colorA: colorA, colorB: colorB, size: 30);

    return TweenAnimationBuilder<double>(
      key: ValueKey(message.id),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
                isMe ? (1 - value) * 14 : -(1 - value) * 14, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            Padding(padding: const EdgeInsets.only(bottom: 16), child: avatar),
            const SizedBox(width: 7),
          ],
          if (!isMe && !showAvatar) const SizedBox(width: 41),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _InlineReplyPreview extends StatelessWidget {
  final String text;
  final Color accent;

  const _InlineReplyPreview({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black.withAlpha(26),
        border:
            Border(left: BorderSide(color: accent.withAlpha(210), width: 3)),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withAlpha(182),
          fontSize: 10.8,
          height: 1.25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final _ConversationItem item;
  final VoidCallback onTap;

  const _ConversationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: _GlassPanel(
        radius: 28,
        padding: const EdgeInsets.fromLTRB(13, 13, 12, 13),
        child: Row(
          children: [
            _AvatarBadge(item: item, size: 58),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontSize: 16.4,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      _LevelBadge(level: item.level),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (item.hasVoiceNote) ...[
                        Icon(Icons.mic_rounded, color: item.colorA, size: 15),
                        const SizedBox(width: 5),
                      ],
                      Expanded(
                        child: Text(
                          item.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tokens.textSecondary,
                            fontSize: 12.2,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                      color: tokens.textMuted,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: item.unreadCount > 0
                        ? LinearGradient(colors: [
                            item.colorA.withAlpha(145),
                            item.colorB.withAlpha(120)
                          ])
                        : null,
                    color: item.unreadCount > 0 ? null : tokens.chipSurface,
                    border: Border.all(
                      color: item.unreadCount > 0
                          ? Colors.white.withAlpha(22)
                          : tokens.border,
                    ),
                  ),
                  child: item.unreadCount > 0
                      ? Text('${item.unreadCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900))
                      : Icon(Icons.chevron_right_rounded,
                          color: tokens.iconSecondary, size: 19),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected
              ? (tokens.isVoxaTheme
                  ? tokens.brandGradient
                  : LinearGradient(colors: [
                      _blue.withAlpha(80),
                      _purple.withAlpha(95),
                      _pink.withAlpha(70),
                    ]))
              : null,
          color: selected ? null : tokens.chipSurface,
          border: Border.all(
              color: selected ? Colors.white.withAlpha(35) : tokens.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : tokens.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _PrimaryCoachButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimaryCoachButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 14, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: tokens.isVoxaTheme
              ? tokens.brandGradient
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _blue.withAlpha(115),
                    _purple.withAlpha(135),
                    _pink.withAlpha(105),
                  ],
                ),
          border: Border.all(
            color: tokens.isVoxaTheme
                ? tokens.secondaryAccent.withAlpha(48)
                : tokens.isLight
                    ? _purple.withAlpha(34)
                    : Colors.white.withAlpha(26),
          ),
          boxShadow: [
            BoxShadow(
              color: (tokens.isVoxaTheme ? tokens.primaryAccent : _purple)
                  .withAlpha(24),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
            SizedBox(width: 8),
            Text(
              'Start with Voxa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TinyGlassChip extends StatelessWidget {
  final String label;

  const _TinyGlassChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tokens.textSecondary,
          fontSize: 10.6,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final _ChatMessage message;
  final VoidCallback onClose;

  const _ReplyPreview({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 9, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: const Color(0xFF09101C).withAlpha(210),
              border: Border.all(color: Colors.white.withAlpha(13)),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                        colors: [message.isMe ? _purple : _blue, _pink]),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.isMe ? 'Replying to you' : 'Replying',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(172),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withAlpha(126),
                          fontSize: 11.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _TapScale(
                  onTap: onClose,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(10),
                      border: Border.all(color: Colors.white.withAlpha(10)),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordingPreview extends StatelessWidget {
  const _RecordingPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: _pink.withAlpha(14),
          border: Border.all(color: _pink.withAlpha(16)),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration:
                  const BoxDecoration(shape: BoxShape.circle, color: _pink),
            ),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'Recording voice note...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const Icon(Icons.graphic_eq_rounded, color: _pink, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final Color colorA;
  final Color colorB;
  final String avatarLetter;
  final bool useImageAvatar;
  final String label;

  const _TypingIndicator({
    required this.colorA,
    required this.colorB,
    required this.avatarLetter,
    required this.useImageAvatar,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = useImageAvatar
        ? const _VoxaAvatar(size: 32)
        : _LetterAvatar(
            letter: avatarLetter, colorA: colorA, colorB: colorB, size: 32);
    return Row(
      children: [
        avatar,
        const SizedBox(width: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                color: Colors.white.withAlpha(10),
                border: Border.all(color: Colors.white.withAlpha(13)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TypingDots(color: colorB),
                  const SizedBox(width: 9),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withAlpha(142),
                      fontSize: 11.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypingDots extends StatefulWidget {
  final Color color;

  const _TypingDots({required this.color});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final value = ((_controller.value + (index * 0.22)) % 1.0);
            final opacity =
                value < 0.5 ? 0.35 + value : 1.0 - ((value - 0.5) * 0.8);
            return Container(
              width: 5,
              height: 5,
              margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color
                      .withAlpha((opacity.clamp(0.25, 1.0) * 255).round())),
            );
          }),
        );
      },
    );
  }
}

class _VoiceMessage extends StatefulWidget {
  final Color color;
  final bool isMe;
  final String durationLabel;
  final String? voicePath;

  const _VoiceMessage({
    required this.color,
    required this.isMe,
    required this.durationLabel,
    required this.voicePath,
  });

  @override
  State<_VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<_VoiceMessage> {
  late final AudioPlayer _player;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
    _positionSub = _player.onPositionChanged.listen((value) {
      if (!mounted) return;
      setState(() => _position = value);
    });
    _durationSub = _player.onDurationChanged.listen((value) {
      if (!mounted) return;
      setState(() => _duration = value);
    });
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final path = widget.voicePath;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This voice note is not ready to play.'),
        ),
      );
      return;
    }

    final file = File(path);
    if (!file.existsSync() || file.lengthSync() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Voice file could not be found on this device.')),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _player.pause();
        if (!mounted) return;
        setState(() => _isPlaying = false);
        return;
      }

      if (_position > Duration.zero &&
          _duration > Duration.zero &&
          _position < _duration) {
        await _player.resume();
      } else {
        _position = Duration.zero;
        await _player.stop();
        await _player.play(DeviceFileSource(path));
        Future.delayed(const Duration(milliseconds: 220), () async {
          final value = await _player.getDuration();
          if (!mounted || value == null) return;
          setState(() => _duration = value);
        });
      }

      if (!mounted) return;
      setState(() => _isPlaying = true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isPlaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not play this voice note. Please try again.'),
        ),
      );
    }
  }

  String get _label {
    final value = _position > Duration.zero ? _position : _duration;
    if (value > Duration.zero) {
      final seconds = value.inSeconds;
      final mm = (seconds ~/ 60).toString();
      final ss = (seconds % 60).toString().padLeft(2, '0');
      return '$mm:$ss';
    }
    return widget.durationLabel;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(widget.isMe ? 42 : 16),
              border: Border.all(
                  color: Colors.white.withAlpha(_isPlaying ? 45 : 18)),
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 112,
          height: 22,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(14, (index) {
              final h = 5.0 + ((index % 5) * 2.7);
              final active = index / 13 <= progress;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutCubic,
                width: 3,
                height: h,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color:
                      widget.color.withAlpha(active || _isPlaying ? 210 : 95),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          _label,
          style: TextStyle(
            color: Colors.white.withAlpha(190),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InputIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _InputIconButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tokens.chipSurface,
          border: Border.all(
              color: tokens.isLight ? tokens.border : color.withAlpha(28)),
          boxShadow: [
            if (color == _pink)
              BoxShadow(
                color: _pink.withAlpha(14),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(icon, color: color.withAlpha(230), size: 19),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;

  const _SendButton({required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: enabled
              ? (tokens.isVoxaTheme
                  ? tokens.brandGradient
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_blue, _purple, _pink],
                    ))
              : null,
          color: enabled ? null : tokens.chipSurface,
          border: Border.all(
              color: enabled
                  ? (tokens.isLight
                      ? _purple.withAlpha(36)
                      : Colors.white.withAlpha(34))
                  : tokens.border),
          boxShadow: enabled
              ? [
                  BoxShadow(
                      color: _purple.withAlpha(24),
                      blurRadius: 12,
                      offset: const Offset(0, 5))
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            enabled ? Icons.arrow_upward_rounded : Icons.arrow_upward_rounded,
            key: ValueKey(enabled),
            color: enabled ? Colors.white : tokens.iconSecondary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _CircleButton(
      {required this.icon, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 44.0;
    final tokens = SpeakeryThemeTokens.of(context);
    return _TapScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tokens.chipSurface,
          border: Border.all(color: tokens.border),
        ),
        child: Icon(icon, color: tokens.iconPrimary, size: compact ? 16 : 18),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final _ConversationItem item;
  final double size;

  const _AvatarBadge({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    if (item.isCoach) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _VoxaAvatar(size: size),
          const Positioned(
              right: 1,
              bottom: 1,
              child: _StatusDot(online: true, outlined: true)),
        ],
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _LetterAvatar(
            letter: item.avatarLetter,
            colorA: item.colorA,
            colorB: item.colorB,
            size: size),
        Positioned(
            right: 1,
            bottom: 1,
            child: _StatusDot(online: item.isOnline, outlined: true)),
      ],
    );
  }
}

class _LetterAvatar extends StatelessWidget {
  final String letter;
  final Color colorA;
  final Color colorB;
  final double size;

  const _LetterAvatar(
      {required this.letter,
      required this.colorA,
      required this.colorB,
      required this.size});

  @override
  Widget build(BuildContext context) {
    final safeLetter = letter.trim().isEmpty
        ? 'S'
        : letter.trim().substring(0, 1).toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: [colorA, colorB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: colorA.withAlpha(45),
              blurRadius: 14,
              offset: const Offset(0, 6))
        ],
      ),
      alignment: Alignment.center,
      child: Text(safeLetter,
          style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w900)),
    );
  }
}

class _VoxaAvatar extends StatelessWidget {
  final double size;

  const _VoxaAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .045),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFFCF8),
        border: Border.all(
          color: const Color(0xFFFF7A12).withAlpha(82),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A4A20).withAlpha(24),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/voxa_mascot_v2.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF9A3D), Color(0xFFFF7A12)],
              ),
            ),
            child: Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: size * .4,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool online;
  final bool outlined;

  const _StatusDot({required this.online, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: outlined ? 11 : 7,
      height: outlined ? 11 : 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? _green : Colors.white.withAlpha(80),
        border: outlined ? Border.all(color: _bg, width: 2) : null,
      ),
    );
  }
}

class _MiniStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(13),
        border: Border.all(color: color.withAlpha(34)),
      ),
      child: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: tokens.isLight ? color : Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w900)),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    final color = switch (level) {
      'A1' => _blue,
      'A2' => _green,
      'B1' => _amber,
      'B2' => _pink,
      'C1' => _purple,
      _ => const Color(0xFFFF6B6B),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withAlpha(13),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Text(level,
          style: TextStyle(
              color: tokens.isLight ? color : Colors.white.withAlpha(190),
              fontSize: 9,
              fontWeight: FontWeight.w900)),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const _GlassPanel(
      {required this.child, required this.padding, required this.radius});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: tokens.glassSurface,
            border: Border.all(color: tokens.border),
            boxShadow: [
              BoxShadow(
                  color: tokens.shadow.withAlpha(tokens.isLight ? 28 : 70),
                  blurRadius: 18,
                  offset: const Offset(0, 10))
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  final bool detailMode;

  const _PremiumBackground({this.detailMode = false});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: tokens.pageGradient,
          ),
          child: const SizedBox.expand(),
        ),
        Positioned(
            top: detailMode ? -105 : -80,
            right: -120,
            child: _Glow(
                color: tokens.isLight ? tokens.primaryAccent : _pink,
                size: detailMode ? 300 : 260)),
        Positioned(
            top: detailMode ? 210 : 230,
            left: -140,
            child: _Glow(
                color: tokens.isLight ? tokens.secondaryAccent : _blue,
                size: detailMode ? 250 : 215)),
        if (!tokens.isLight)
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(0),
                    Colors.black.withAlpha(detailMode ? 28 : 18)
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(42), blurRadius: 110, spreadRadius: 34)
          ],
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String label;

  const _DatePill({required this.label});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: tokens.chipSurface,
        border: Border.all(color: tokens.border),
      ),
      child: Text(label,
          style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 10.4,
              fontWeight: FontWeight.w800)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onStartVoxa;

  const _EmptyState({required this.onStartVoxa});

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
        child: _GlassPanel(
          radius: 26,
          padding: const EdgeInsets.fromLTRB(21, 24, 21, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _VoxaAvatar(size: 44),
              const SizedBox(height: 15),
              Text(
                'No conversations yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              _PrimaryCoachButton(onTap: onStartVoxa),
              const SizedBox(height: 13),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TinyGlassChip(label: 'Correct my sentence'),
                  _TinyGlassChip(label: 'Practice speaking'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomHint extends StatelessWidget {
  const _BottomHint();

  @override
  Widget build(BuildContext context) {
    final tokens = SpeakeryThemeTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        'Practice messages stay here while Voxa helps you improve.',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: tokens.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FadeInUp extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _FadeInUp({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
              offset: Offset(0, 10 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }
}

class _TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _TapScale({required this.child, this.onTap, this.onLongPress});

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _ModeSpec {
  final String id;
  final String label;
  final IconData icon;

  const _ModeSpec(this.id, this.label, this.icon);
}

String _relativeTimeLabel(DateTime? createdAt, String fallback) {
  if (createdAt == null) {
    return fallback == 'Now' ? 'just now' : fallback;
  }

  final diff = DateTime.now().difference(createdAt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';

  final hour = createdAt.hour.toString().padLeft(2, '0');
  final minute = createdAt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _ConversationItem {
  final String id;
  final String name;
  final String level;
  final String preview;
  final String time;
  final int unreadCount;
  final Color colorA;
  final Color colorB;
  final bool isOnline;
  final String avatarLetter;
  final bool hasVoiceNote;
  final bool isCoach;

  const _ConversationItem({
    required this.id,
    required this.name,
    required this.level,
    required this.preview,
    required this.time,
    required this.unreadCount,
    required this.colorA,
    required this.colorB,
    required this.isOnline,
    required this.avatarLetter,
    // ignore: unused_element_parameter
    this.hasVoiceNote = false,
    // ignore: unused_element_parameter
    this.isCoach = false,
  });
}

class _ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time;
  final DateTime? createdAt;
  final bool isVoice;
  final String? voicePath;
  final String? durationLabel;
  final String? replyTo;

  _ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.createdAt,
    this.isVoice = false,
    this.voicePath,
    this.durationLabel,
    this.replyTo,
  });
}
