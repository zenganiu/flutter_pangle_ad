import BUAdSDK
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        BUAdSDKManager.setAppID("5112108")
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

//public class SwiftFlutterPangleAdPlugin: NSObject, FlutterPlugin {
//    // 开屏广告
//    var splashAdView: BUSplashAdView?
//
//    public static func register(with registrar: FlutterPluginRegistrar) {
//        let channel = FlutterMethodChannel(name: "flutter_pangle_ad", binaryMessenger: registrar.messenger())
//        let instance = SwiftFlutterPangleAdPlugin()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//    }
//
//    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        result("iOS " + UIDevice.current.systemVersion)
//
//        switch call.method {
//        case "splashAd":
//
//            BUAdSDKManager.setAppID("5112108")
//
//            splashAdView = BUSplashAdView(slotID: "887394289", frame: UIScreen.main.bounds)
//            splashAdView?.tolerateTimeout = 10
//            splashAdView?.needSplashZoomOutAd = true
//
//            let keyWindow = UIApplication.shared.keyWindow
//            splashAdView?.loadAdData()
//            if let adview = splashAdView, let keyWindow = keyWindow {
//                keyWindow.addSubview(adview)
//                adview.rootViewController = keyWindow.rootViewController
//            }
//        default:
//            break
//        }
//    }
//}
