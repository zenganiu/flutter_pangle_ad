import BUAdSDK
import Flutter
import UIKit

public class SwiftFlutterPangleAdPlugin: NSObject, FlutterPlugin {
    /// 开屏广告
    var splashAdView: BUSplashAdView?

    /// 激励视频
    var rewardedAd: BUNativeExpressRewardedVideoAd?

    /// 根视图
    var rootViewController: UIViewController?

    /// keywinow
    var keyWindow: UIWindow?{
       return UIApplication.shared.windows.first
    }
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_pangle_ad", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPangleAdPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let factory = PlatformBannerViewFactory()
        registrar.register(factory, withId: "PangleAdBannerView")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "splashAd":

            showSplashAd(call, result: result)
        case "rewardAd":
            showRewardAd(call, result: result)
            
        default:
            break
        }
    }
    
    // MARK: - - 显示激励视频

    private func showRewardAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        guard let args = arguments else {
            return
        }
        let slotID = args["slotID"] as? String
        guard let aslotID = slotID else {
            return
        }

        let userId = args["userId"] as? String ?? ""
        let rewardName = args["rewardName"] as? String ?? ""
        let rewardAmount = args["rewardAmount"] as? Int ?? 0
        let extra = args["extra"] as? String ?? ""

        let model = BURewardedVideoModel()
        model.userId = userId
        model.rewardName = rewardName
        model.rewardAmount = rewardAmount
        model.extra = extra

        let ad = BUNativeExpressRewardedVideoAd(slotID: aslotID, rewardedVideoModel: model)
        ad.delegate = self
        ad.loadData()
        self.rewardedAd = ad
    }

    // MARK: - - 显示开屏广告

    private func showSplashAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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

        let ad = BUSplashAdView(slotID: aslotID, frame: UIScreen.main.bounds)
        ad.tolerateTimeout = 10
        ad.needSplashZoomOutAd = true
        ad.delegate = self
        ad.loadAdData()
        if let keyWindow = self.keyWindow {
            keyWindow.rootViewController?.view.addSubview(ad)
            ad.rootViewController = keyWindow.rootViewController
            splashAdView = ad
        }
    }
}

// MARK: - - BUSplashAdDelegate

extension SwiftFlutterPangleAdPlugin: BUSplashAdDelegate {
    public func removeSplashAdView() {
        guard let _ = splashAdView else { return }
        splashAdView?.removeFromSuperview()
    }

    // 广告加载成功回调
    public func splashAdDidLoad(_ splashAd: BUSplashAdView) {
        print("广告加载成功回调")
    }

    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        removeSplashAdView()
    }

    // SDK渲染开屏广告关闭回调，当用户点击广告时会直接触发此回调
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
        removeSplashAdView()
    }
}

// MARK: - - BUNativeExpressRewardedVideoAdDelegate

extension SwiftFlutterPangleAdPlugin: BUNativeExpressRewardedVideoAdDelegate {
    // 返回的错误码(error)表示广告加载失败的原因
    public func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
    }

    // 渲染失败，网络原因或者硬件原因导致渲染失败,可以更换手机或者网络环境测试。
    public func nativeExpressRewardedVideoAdViewRenderFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, error: Error?) {
    }

    // 广告素材物料加载成功
    public func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        guard let window = self.keyWindow,let rootVC = window.rootViewController else{return}
        self.rewardedAd?.show(fromRootViewController: rootVC)
    }

    // 视频下载完成
    public func nativeExpressRewardedVideoAdDidDownLoadVideo(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }

    // 用户关闭广告时会触发此回调，注意：任何广告的关闭操作必须用户主动触发
    public func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }

    // 点击回调方法
    public func nativeExpressRewardedVideoAdDidClick(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }

    // 跳过回调方法
    public func nativeExpressRewardedVideoAdDidClickSkip(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }

    // 视频正常播放完成时可触发此回调方法，当广告播放发生异常时，不会进入此回调
    public func nativeExpressRewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
    }

    // 异步请求的服务器验证成功回调，开发者需要在此回调中进行奖励发放
    public func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
    }
}
