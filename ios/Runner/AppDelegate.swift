import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let siriShortcutsChannel = FlutterMethodChannel(name: "elainedb.dev.registry-helper-for-wu/siri_shortcuts",
                                              binaryMessenger: controller)
    siriShortcutsChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
        // Note: this method is invoked on the UI thread.
        guard call.method == "getShortcut" else {
            result(FlutterMethodNotImplemented)
            return
        }
        self?.receiveSiriShortcut(result: result)
    })

    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func receiveSiriShortcut(result: FlutterResult) {
        result("my_registry")
    }
}
