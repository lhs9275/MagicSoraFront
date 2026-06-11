import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "magicsorafront/kakao_config",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "getNativeAppKey":
          result(Self.kakaoNativeAppKey())
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private static func kakaoNativeAppKey() -> String {
    guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes")
      as? [[String: Any]]
    else {
      return ""
    }

    for urlType in urlTypes {
      guard let schemes = urlType["CFBundleURLSchemes"] as? [String] else {
        continue
      }

      for scheme in schemes where scheme.hasPrefix("kakao") {
        let appKey = String(scheme.dropFirst("kakao".count))
        if !appKey.isEmpty && appKey != "YOUR_NATIVE_APP_KEY" {
          return appKey
        }
      }
    }

    return ""
  }
}
