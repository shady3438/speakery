import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, AVSpeechSynthesizerDelegate {
  private let speechSynthesizer = AVSpeechSynthesizer()
  private var speechChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    speechSynthesizer.delegate = self

    if let controller = window?.rootViewController as? FlutterViewController {
      speechChannel = FlutterMethodChannel(
        name: "speakery/native_speech",
        binaryMessenger: controller.binaryMessenger
      )
      speechChannel?.setMethodCallHandler { [weak self] call, result in
        guard let self else { return }
        switch call.method {
        case "speak":
          guard
            let args = call.arguments as? [String: Any],
            let text = args["text"] as? String
          else {
            result(
              FlutterError(
                code: "INVALID_ARGUMENT",
                message: "Speech text is required.",
                details: nil
              )
            )
            return
          }
          let speed = (args["rate"] as? Double) ?? 1.0
          self.speechSynthesizer.stopSpeaking(at: .immediate)
          let utterance = AVSpeechUtterance(string: text)
          utterance.voice = self.bestEnglishVoice()
          utterance.rate =
            AVSpeechUtteranceDefaultSpeechRate * Float(max(0.78, min(speed, 1.18)))
          utterance.pitchMultiplier = 1.02
          utterance.preUtteranceDelay = 0.08
          utterance.postUtteranceDelay = 0.12
          self.speechSynthesizer.speak(utterance)
          result(nil)
        case "stop":
          self.speechSynthesizer.stopSpeaking(at: .immediate)
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func bestEnglishVoice() -> AVSpeechSynthesisVoice? {
    let voices = AVSpeechSynthesisVoice.speechVoices().filter {
      $0.language.hasPrefix("en-")
    }
    if #available(iOS 16.0, *) {
      if let premium = voices.first(where: { $0.quality == .premium }) {
        return premium
      }
    }
    return voices.first(where: { $0.quality == .enhanced })
      ?? voices.first(where: { $0.language == "en-US" })
      ?? voices.first
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didFinish utterance: AVSpeechUtterance
  ) {
    speechChannel?.invokeMethod("speechComplete", arguments: nil)
  }

  func speechSynthesizer(
    _ synthesizer: AVSpeechSynthesizer,
    didCancel utterance: AVSpeechUtterance
  ) {
    speechChannel?.invokeMethod("speechComplete", arguments: nil)
  }
}
