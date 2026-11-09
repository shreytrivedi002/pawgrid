import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let feedbackAudio = FeedbackAudio()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PawgridFeedbackAudio") {
      feedbackAudio.connect(messenger: registrar.messenger(), registry: registrar)
    }
  }
}


private final class FeedbackAudio: NSObject {
  private var players: [String: AVAudioPlayer] = [:]
  private var channel: FlutterMethodChannel?
  override init() {
    super.init()
    NotificationCenter.default.addObserver(self, selector: #selector(stopForBackground), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(stopForBackground), name: AVAudioSession.interruptionNotification, object: nil)
  }
  func connect(messenger: FlutterBinaryMessenger, registry: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "pawgrid/feedback", binaryMessenger: messenger)
    try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
    for cue in ["mark", "erase", "place", "swipe", "undo", "warning", "hint", "win"] {
      let key = registry.lookupKey(forAsset: "assets/audio/\(cue).wav")
      if let path = Bundle.main.path(forResource: key, ofType: nil),
         let player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path)) {
        player.prepareToPlay()
        players[cue] = player
      }
    }
    channel?.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(false); return }
      switch call.method {
      case "prepare": result(["loaded": Array(self.players.keys), "active": UIApplication.shared.applicationState == .active, "voices": self.players.values.filter { $0.isPlaying }.count])
      case "stop": self.stop(); result(nil)
      case "play":
        guard UIApplication.shared.applicationState == .active,
              let args = call.arguments as? [String: Any],
              let cue = args["cue"] as? String,
              let player = self.players[cue] else { result(false); return }
        do {
          let session = AVAudioSession.sharedInstance()
          try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
          try session.setActive(true)
          player.currentTime = 0
          player.volume = min(1, max(0, (args["volume"] as? NSNumber)?.floatValue ?? 0.7)) * 0.65
          result(player.volume > 0 ? player.play() : false)
        } catch { result(false) }
      default: result(FlutterMethodNotImplemented)
      }
    }
  }
  @objc private func stopForBackground(_ notification: Notification) { stop() }
  func stop() { for player in players.values { player.stop(); player.currentTime = 0 } }
  deinit { NotificationCenter.default.removeObserver(self) }
}
