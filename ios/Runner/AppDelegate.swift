import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var inkwormHandover: InkwormHandover?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PaladinInkworm") {
      inkwormHandover = InkwormHandover(registrar: registrar)
    }
  }
}

// Opens a book straight in Inkworm, skipping the "Open in…" sheet. The book is
// copied into the App Group container both apps share, then Inkworm is opened
// with inkworm://open?file=<name>; Inkworm moves it into its own library. The
// file name is kept so Inkworm's reading progress (keyed by it) carries over.
// Answers false when Inkworm isn't installed or can't be opened, so Dart can
// fall back to the standard sheet.
class InkwormHandover: NSObject {
  private static let appGroup = "group.au.com.sharpblue.books"

  private let channel: FlutterMethodChannel

  init(registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "au.com.sharpblue.paladin/inkworm", binaryMessenger: registrar.messenger())
    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self, call.method == "open", let path = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.open(path, result: result)
    }
  }

  private func open(_ path: String, result: @escaping FlutterResult) {
    let book = URL(fileURLWithPath: path)
    guard let probe = URL(string: "inkworm://"), UIApplication.shared.canOpenURL(probe),
          let handover = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: InkwormHandover.appGroup)?
            .appendingPathComponent("Handover", isDirectory: true) else {
      result(false)
      return
    }

    let fileManager = FileManager.default
    let destination = handover.appendingPathComponent(book.lastPathComponent)
    do {
      try fileManager.createDirectory(at: handover, withIntermediateDirectories: true)
      if fileManager.fileExists(atPath: destination.path) {
        try fileManager.removeItem(at: destination)
      }
      try fileManager.copyItem(at: book, to: destination)
    } catch {
      result(false)
      return
    }

    var components = URLComponents()
    components.scheme = "inkworm"
    components.host = "open"
    components.queryItems = [URLQueryItem(name: "file", value: book.lastPathComponent)]
    guard let url = components.url else {
      try? fileManager.removeItem(at: destination)
      result(false)
      return
    }

    UIApplication.shared.open(url) { opened in
      if !opened {
        try? fileManager.removeItem(at: destination)
      }
      result(opened)
    }
  }
}
