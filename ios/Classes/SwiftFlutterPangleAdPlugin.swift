import BUAdSDK
import Flutter
import UIKit

public class SwiftFlutterPangleAdPlugin: NSObject, FlutterPlugin {
    /// 通道名称
    static let channelName = "flutter_pangle_ad"

    /// 开屏广告
    var splashAdView: BUSplashAdView?

    /// 激励视频
    var rewardedAd: BUNativeExpressRewardedVideoAd?

    /// 根视图
    var rootViewController: UIViewController?

    /// 主窗口
    var keyWindow: UIWindow? {
        return UIApplication.shared.windows.first
    }

    var rewardResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPangleAdPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let factory = PlatformBannerViewFactory()
        /// 注册视图，与UiKitView中viewType对应
        registrar.register(factory, withId: "PangleAdBannerView")

        // registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialSDK":
            initialSDK(call, result: result)
        case "getPlatformVersion":
            getPlatformVersion(call, result: result)

        case "showSplashAd":
            showSplashAd(call, result: result)
        case "loadSplashAd":
            
            break
            
            
        case "showRewardAd":

            showRewardAd(call, result: result)
        case "loadRewardAd":
            break
        default:
            break
        }
    }

    private func initialSDK(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        guard let args = arguments, let appId = args["appId"] as? String else {
            return
        }

        var level: BUAdSDKLogLevel = .none
        if let logLevel = args["logLevel"] as? NSNumber {
            let num = logLevel.intValue

            switch num {
            case 0:
                level = .none
            case 1:
                level = .error
            case 2:
                level = .debug
            default:
                break
            }
        }

        BUAdSDKManager.setAppID(appId)
        BUAdSDKManager.setLoglevel(level)
    }

    // MARK: - - 获取平台、系统版本

    private func getPlatformVersion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let system = UIDevice.current.systemName
        let version = UIDevice.current.systemVersion
        let platformVersion = "\(system) \(version)"

        result(platformVersion)
    }

    // MARK: - - 显示激励视频

    private func showRewardAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        guard let args = arguments, let slotID = args["slotID"] as? String else {
            return
        }

        let userId = args["userId"] as? String ?? ""
        let rewardName = args["rewardName"] as? String ?? ""
        let rewardAmount = (args["rewardAmount"] as? NSNumber ?? NSNumber(value: 0)).intValue
        let extra = args["extra"] as? String ?? ""

        let model = BURewardedVideoModel()
        model.userId = userId
        model.rewardName = rewardName
        model.rewardAmount = rewardAmount
        model.extra = extra

        rewardResult = result
        let ad = BUNativeExpressRewardedVideoAd(slotID: slotID, rewardedVideoModel: model)
        ad.delegate = self
        ad.loadData()
        rewardedAd = ad
    }
    // MARK: - - 加载激励视频
    private func loadRewardAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        guard let args = arguments, let slotID = args["slotID"] as? String else {
            return
        }

        let userId = args["userId"] as? String ?? ""
        let rewardName = args["rewardName"] as? String ?? ""
        let rewardAmount = (args["rewardAmount"] as? NSNumber ?? NSNumber(value: 0)).intValue
        let extra = args["extra"] as? String ?? ""

        let model = BURewardedVideoModel()
        model.userId = userId
        model.rewardName = rewardName
        model.rewardAmount = rewardAmount
        model.extra = extra

        rewardResult = result
        let ad = BUNativeExpressRewardedVideoAd(slotID: slotID, rewardedVideoModel: model)
        //ad.delegate = self
        ad.loadData()
        rewardedAd = ad
    }
    // MARK: - - 显示开屏广告

    private func showSplashAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        guard let args = arguments, let slotID = args["slotID"] as? String else {
            return
        }

        BUAdSDKManager.setIsPaidApp(false)

        let ad = BUSplashAdView(slotID: slotID, frame: UIScreen.main.bounds)
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
    
    // MARK: - - 加载开屏广告
    private func loadSplashAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let arguments = call.arguments as? [String: Any]
        guard let args = arguments, let slotID = args["slotID"] as? String else {
            return
        }

        BUAdSDKManager.setIsPaidApp(false)
        let ad = BUSplashAdView(slotID: slotID, frame: UIScreen.main.bounds)
        ad.tolerateTimeout = 10
        ad.needSplashZoomOutAd = true
        //ad.delegate = self
        ad.loadAdData()
        
        
    }
    
}

// MARK: - - 开屏广告Delegate

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

// MARK: - - 激励视频Delegate

extension SwiftFlutterPangleAdPlugin: BUNativeExpressRewardedVideoAdDelegate {
    // 返回的错误码(error)表示广告加载失败的原因
    public func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
    }

    // 渲染失败，网络原因或者硬件原因导致渲染失败,可以更换手机或者网络环境测试。
    public func nativeExpressRewardedVideoAdViewRenderFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, error: Error?) {
    }

    // 广告素材物料加载成功
    public func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        guard let window = keyWindow, let rootVC = window.rootViewController else { return }
        rewardedAd?.show(fromRootViewController: rootVC)
    }

    // 视频下载完成
    public func nativeExpressRewardedVideoAdDidDownLoadVideo(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }

    // 用户关闭广告时会触发此回调，注意：任何广告的关闭操作必须用户主动触发
    public func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        rewardResult?("AdDidClose")
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
