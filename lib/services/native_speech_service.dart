import 'package:flutter/services.dart';

class NativeSpeechService {
  NativeSpeechService._() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static final NativeSpeechService instance = NativeSpeechService._();
  static const MethodChannel _channel = MethodChannel('speakery/native_speech');

  void Function()? onComplete;

  Future<void> speak(
    String text, {
    double rate = 1,
  }) async {
    try {
      await _channel.invokeMethod<void>('speak', {
        'text': text,
        'rate': rate,
        'language': 'en-US',
      });
    } on MissingPluginException {
      onComplete?.call();
    } on PlatformException {
      onComplete?.call();
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method == 'speechComplete') {
      onComplete?.call();
    }
  }
}
