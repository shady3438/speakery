import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

enum AIFeedbackTask {
  general('general'),
  chat('chat'),
  writing('writing'),
  speaking('speaking'),
  listening('listening');

  const AIFeedbackTask(this.id);

  final String id;
}

class AIService {
  // Keep provider API keys on a server. Pass a HTTPS endpoint with:
  // --dart-define=AI_FEEDBACK_ENDPOINT=https://your-domain.example/ai-feedback
  // Or split prompts server-side to reduce repeated prompt tokens:
  // --dart-define=AI_WRITING_FEEDBACK_ENDPOINT=https://.../ai/writing
  // --dart-define=AI_SPEAKING_FEEDBACK_ENDPOINT=https://.../ai/speaking
  // --dart-define=AI_LISTENING_FEEDBACK_ENDPOINT=https://.../ai/listening
  // --dart-define=AI_CHAT_FEEDBACK_ENDPOINT=https://.../ai/chat
  static const String _feedbackEndpoint =
      String.fromEnvironment('AI_FEEDBACK_ENDPOINT');
  static const String _writingEndpoint =
      String.fromEnvironment('AI_WRITING_FEEDBACK_ENDPOINT');
  static const String _speakingEndpoint =
      String.fromEnvironment('AI_SPEAKING_FEEDBACK_ENDPOINT');
  static const String _listeningEndpoint =
      String.fromEnvironment('AI_LISTENING_FEEDBACK_ENDPOINT');
  static const String _chatEndpoint =
      String.fromEnvironment('AI_CHAT_FEEDBACK_ENDPOINT');

  static bool get _hasProxy =>
      _feedbackEndpoint.trim().isNotEmpty ||
      _writingEndpoint.trim().isNotEmpty ||
      _speakingEndpoint.trim().isNotEmpty ||
      _listeningEndpoint.trim().isNotEmpty ||
      _chatEndpoint.trim().isNotEmpty;
  static bool get isConfigured => _hasProxy;

  static Future<Map<String, String>> correctSentence(String input) async {
    return feedback(task: AIFeedbackTask.general, text: input);
  }

  static Future<Map<String, String>> feedback({
    required AIFeedbackTask task,
    required String text,
    Map<String, Object?> context = const <String, Object?>{},
  }) async {
    if (!isConfigured) {
      throw StateError('AI service is not configured.');
    }

    final canUseProxy = _hasProxyFor(task);
    if (!canUseProxy) {
      throw StateError('AI service is not configured for ${task.id}.');
    }

    final safeText = _trimText(text, 1200);
    final safeContext = _compactContext(context);
    final result = await _requestProxy(task, safeText, safeContext);

    return {
      'result': result,
    };
  }

  static Future<String> _requestProxy(
    AIFeedbackTask task,
    String safeText,
    Map<String, Object?> context,
  ) async {
    final url = Uri.parse(_endpointFor(task));

    final response = await http
        .post(
          url,
          headers: await _proxyHeaders(),
          body: jsonEncode({
            'v': 1,
            't': task.id,
            'x': safeText,
            if (context.isNotEmpty) 'c': context,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('AI error');
    }

    final data = jsonDecode(response.body);
    return _extractText(data);
  }

  static String _endpointFor(AIFeedbackTask task) {
    final taskEndpoint = switch (task) {
      AIFeedbackTask.writing => _writingEndpoint,
      AIFeedbackTask.speaking => _speakingEndpoint,
      AIFeedbackTask.listening => _listeningEndpoint,
      AIFeedbackTask.chat => _chatEndpoint,
      AIFeedbackTask.general => '',
    };

    if (taskEndpoint.trim().isNotEmpty) return taskEndpoint;
    if (_feedbackEndpoint.trim().isNotEmpty) return _feedbackEndpoint;

    throw StateError('No endpoint configured for ${task.id}.');
  }

  static Future<Map<String, String>> _proxyHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static bool _hasProxyFor(AIFeedbackTask task) {
    if (_feedbackEndpoint.trim().isNotEmpty) return true;
    return switch (task) {
      AIFeedbackTask.writing => _writingEndpoint.trim().isNotEmpty,
      AIFeedbackTask.speaking => _speakingEndpoint.trim().isNotEmpty,
      AIFeedbackTask.listening => _listeningEndpoint.trim().isNotEmpty,
      AIFeedbackTask.chat => _chatEndpoint.trim().isNotEmpty,
      AIFeedbackTask.general => false,
    };
  }

  static Map<String, Object?> _compactContext(Map<String, Object?> context) {
    if (context.isEmpty) return const <String, Object?>{};

    final compact = <String, Object?>{};
    for (final entry in context.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;

      final value = _compactValue(entry.value);
      if (value == null) continue;
      compact[key] = value;
    }
    return compact;
  }

  static Object? _compactValue(Object? value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = _trimText(value, 220);
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num || value is bool) return value;
    if (value is Map) {
      final compact = <String, Object?>{};
      for (final entry in value.entries.take(8)) {
        final key = entry.key.toString().trim();
        if (key.isEmpty) continue;
        final nestedValue = _compactValue(entry.value);
        if (nestedValue != null) compact[key] = nestedValue;
      }
      return compact.isEmpty ? null : compact;
    }
    if (value is Iterable) {
      final compact = value
          .take(8)
          .map(_compactValue)
          .whereType<Object>()
          .toList(growable: false);
      return compact.isEmpty ? null : compact;
    }

    final fallback = _trimText(value.toString(), 220);
    return fallback.isEmpty ? null : fallback;
  }

  static String _trimText(String value, int maxLength) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength).trimRight();
  }

  static String _extractText(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in const ['result', 'feedback', 'message', 'output']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }

      final outputText = data['output_text'];
      if (outputText is String && outputText.trim().isNotEmpty) {
        return outputText;
      }

      final output = data['output'];
      if (output is List) {
        final buffer = StringBuffer();
        for (final item in output) {
          if (item is! Map<String, dynamic>) continue;
          final content = item['content'];
          if (content is! List) continue;
          for (final part in content) {
            if (part is! Map<String, dynamic>) continue;
            final text = part['text'];
            if (text is String && text.trim().isNotEmpty) {
              if (buffer.isNotEmpty) buffer.write('\n');
              buffer.write(text.trim());
            }
          }
        }
        if (buffer.isNotEmpty) return buffer.toString();
      }
    }

    throw const FormatException('AI response did not include feedback text.');
  }
}
