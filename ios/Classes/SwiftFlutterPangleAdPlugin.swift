import BUAdSDK
import Flutter
import UIKit

public class SwiftFlutterPangleAdPlugin: NSObject, FlutterPlugin {
    var splashAdView: BUSplashAdView?
    var rootViewController: UIViewController?
    var keyWindow: UIWindow? = UIApplication.shared.windows.first
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_pangle_ad", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPangleAdPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "splashAd":
            
            
            let arguments = call.arguments as? [String: Any]
            guard let args = arguments else {
                return
            }
            let slotID = args["slotID"] as? String
            guard let aslotID = slotID else {
                return
            }
            
            
            BUAdSDKManager.setLoglevel(.debug)
            BUAdSDKManager.setIsPaidApp(false)
            splashAdView = BUSplashAdView(slotID: aslotID, frame: UIScreen.main.bounds)
            splashAdView?.tolerateTimeout = 10
            splashAdView?.needSplashZoomOutAd = true
            splashAdView?.delegate = self

            splashAdView?.loadAdData()
            if let adview = splashAdView, let keyWindow = self.keyWindow {
                keyWindow.rootViewController?.view.addSubview(adview)
                adview.rootViewController = keyWindow.rootViewController
            }
        default:
            break
        }
    }

    public func removeSplashAdView() {
        guard let _ = splashAdView else {
            return
        }
        splashAdView?.removeFromSuperview()

    }
}

extension SwiftFlutterPangleAdPlugin: BUSplashAdDelegate {
    // 广告加载成功回调
    public func splashAdDidLoad(_ splashAd: BUSplashAdView) {
        print("广告加载成功回调")
    }

    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
    }

    // SDK渲染开屏广告关闭回调，当用户点击广告时会直接触发此回调
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
        
        self.removeSplashAdView()
    }
}
