package com.example.speakery

import android.os.Bundle
import android.media.AudioAttributes
import android.media.AudioManager
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.speech.tts.Voice
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterFragmentActivity(), TextToSpeech.OnInitListener {
    private val channelName = "speakery/native_speech"
    private var speech: TextToSpeech? = null
    private var channel: MethodChannel? = null
    private var speechReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        )
        speech = TextToSpeech(this, this)

        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "speak" -> {
                    val text = call.argument<String>("text").orEmpty()
                    val rate = call.argument<Double>("rate")?.toFloat() ?: 1.0f
                    if (!speechReady || text.isBlank()) {
                        result.error("TTS_UNAVAILABLE", "Speech engine is not ready.", null)
                        return@setMethodCallHandler
                    }
                    speech?.setLanguage(Locale.US)
                    selectBestEnglishVoice()
                    speech?.setSpeechRate(rate.coerceIn(0.6f, 1.4f))
                    speech?.setPitch(1.02f)
                    speech?.speak(
                        text,
                        TextToSpeech.QUEUE_FLUSH,
                        Bundle(),
                        "speakery-listening",
                    )
                    result.success(null)
                }
                "stop" -> {
                    speech?.stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onInit(status: Int) {
        speechReady = status == TextToSpeech.SUCCESS
        if (speechReady) {
            speech?.language = Locale.US
            speech?.setAudioAttributes(
                AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .setUsage(AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY)
                    .setLegacyStreamType(AudioManager.STREAM_MUSIC)
                    .build(),
            )
            selectBestEnglishVoice()
        }
        speech?.setOnUtteranceProgressListener(
            object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) = Unit

                override fun onDone(utteranceId: String?) {
                    runOnUiThread {
                        channel?.invokeMethod("speechComplete", null)
                    }
                }

                @Deprecated("Deprecated in Java")
                override fun onError(utteranceId: String?) {
                    runOnUiThread {
                        channel?.invokeMethod("speechComplete", null)
                    }
                }
            },
        )
    }

    private fun selectBestEnglishVoice() {
        val engine = speech ?: return
        val candidates = engine.voices
            ?.filter { voice ->
                voice.locale.language == Locale.ENGLISH.language
            }
            ?.sortedWith(
                compareByDescending<Voice> { it.quality }
                    .thenBy { it.isNetworkConnectionRequired }
                    .thenBy { it.latency }
                    .thenByDescending { voice ->
                        voice.locale.country == Locale.US.country ||
                            voice.locale.country == Locale.UK.country
                    },
            )
            .orEmpty()

        candidates.firstOrNull()?.let { engine.voice = it }
    }

    override fun onDestroy() {
        speech?.stop()
        speech?.shutdown()
        speech = null
        super.onDestroy()
    }
}
