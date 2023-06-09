import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  private let sharedKey = "ShareKey"
  private let sharedFileType = "file"
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    openZipFile(url: url)
    return true
  }
  
  private func openZipFile(url: URL) {
    guard
      let window = window,
      let controller = window.rootViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "org.cardanotokens.app/import_zip",
      binaryMessenger: controller.binaryMessenger)
    
    let args = [ "url": url.absoluteString ]
    channel.invokeMethod("onZipImport", arguments: args)
  }
}
