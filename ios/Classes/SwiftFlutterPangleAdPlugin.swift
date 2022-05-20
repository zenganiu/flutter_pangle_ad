import BUAdSDK
import Flutter
import UIKit

internal let codeKey = "code"
internal let messageKey = "message"
internal let dataKey = "payload"
internal let code_success = "00000"
internal let screenWidth = UIScreen.main.bounds.width
internal let screenHeight = UIScreen.main.bounds.height
internal var rootkeyWindow: UIWindow? {
    return UIApplication.shared.windows.first
}

public class SwiftFlutterPangleAdPlugin: NSObject, FlutterPlugin {
    /// 通道名称
    static let channelName = "flutter_pangle_ad"

    private let showSplashAdTag: Int = 999
    private let loadSplashAdTag: Int = 998
    private let showRewardAdTag: Int = 997
    private let loadRewardAdTag: Int = 996
    private let showSplashAdWithLogoTag: Int = 1000

    /// 开屏广告
    var showSplashAdView: BUSplashAdView?
    /// 激励视频
    var rewardedAd: BUNativeExpressRewardedVideoAd?

    /// 根视图
    var rootViewController: UIViewController?
    var logoContainerView: UIView?


    var showSplashAdResult: FlutterResult?
    var showSplashAdWithLogoResult: FlutterResult?
    var showRewardResult: FlutterResult?



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

        case "showSplashAdWithLogo":
            
            showSplashAdWithLogo(call, result: result)

        case "showRewardAd":

            showRewardAd(call, result: result)

        case "loadSplashAd", "loadRewardAd":

            let dict: Dictionary<String, Any> = [codeKey: "-1", messageKey: "方法已弃用"]
            result(dict)

        default:
            break
        }
    }

    private func initialSDK(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appId = call.getString(key: "appId") else {
            let dict: Dictionary<String, Any> = [codeKey: "-1", messageKey: "appId为必传参数，不能为空"]
            debugPrint(dict)
            result(dict)
            return
        }
        var level: BUAdSDKLogLevel = .none
        if let logLevel = call.getInt(key: "logLevel") {
            switch logLevel {
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
        guard let slotID = call.getString(key: "slotID") else {
            let dict: Dictionary<String, Any> = [codeKey: "-1", messageKey: "slotID为必传参数，不能为空"]
            debugPrint(dict)
            result(dict)
            return
        }
        
        let userId = call.getString(key: "userId") ?? ""
        let rewardName = call.getString(key: "rewardName") ?? ""
        let rewardAmount = call.getInt(key: "rewardAmount") ?? 0
        let extra = call.getString(key: "extra") ?? ""

        let model = BURewardedVideoModel()
        model.userId = userId
        model.rewardName = rewardName
        model.rewardAmount = rewardAmount
        model.extra = extra

        showRewardResult = result
        let ad = BUNativeExpressRewardedVideoAd(slotID: slotID, rewardedVideoModel: model)
        ad.delegate = self
        ad.loadData()
        rewardedAd = ad
    }

    // MARK: - - 显示开屏广告

    private func showSplashAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let slotID = call.getString(key: "slotID") else {
            let dict: Dictionary<String, Any> = [codeKey: "-1", messageKey: "slotID为必传参数，不能为空"]
            debugPrint(dict)
            result(dict)
            return
        }

        let ad = BUSplashAdView(slotID: slotID, frame: UIScreen.main.bounds)
        ad.tolerateTimeout = 10
        ad.delegate = self
        ad.tag = showSplashAdTag
        showSplashAdResult = result

        ad.loadAdData()
        if let keyWindow = rootkeyWindow {
            keyWindow.rootViewController?.view.addSubview(ad)
            ad.rootViewController = keyWindow.rootViewController
            showSplashAdView = ad
        }
    }

    // MARK: - - 显示带底部Logo的开屏广告

    private func showSplashAdWithLogo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let slotID = call.getString(key: "slotID") else {
            let dict: Dictionary<String, Any> = [codeKey: "-1", messageKey: "slotID为必传参数，不能为空"]
            debugPrint(dict)
            result(dict)
            return
        }

        // 是否隐藏跳过按钮
        let hideSkipButton = call.getBool(key: "hideSkipButton") ?? false
        // 超时时间
        let tolerateTimeout = call.getDouble(key: "tolerateTimeout") ?? 3.5

        let logoImageName = call.getString(key: "logoImageName") ?? ""
        let logoContainerHeight = call.getDouble(key: "logoContainerHeight") ?? 0
        let logoWidth = call.getDouble(key: "logoWidth") ?? 0
        let logoHeight = call.getDouble(key: "logoHeight") ?? 0

        // 开屏广告
        let ad = BUSplashAdView(slotID: slotID,
                                frame: .init(x: 0,
                                             y: 0,
                                             width: screenWidth,
                                             height: screenHeight - logoContainerHeight))
        ad.hideSkipButton = hideSkipButton
        ad.tolerateTimeout = tolerateTimeout
        ad.tag = showSplashAdWithLogoTag
        ad.delegate = self
        showSplashAdWithLogoResult = result

        // logo
        let logoContainerView = UIView(frame: .init(x: 0,
                                           y: screenHeight - logoContainerHeight,
                                           width: screenWidth,
                                           height: logoContainerHeight))
        logoContainerView.backgroundColor = .white
        let logoImageView = UIImageView(image: UIImage(named: logoImageName))
        logoImageView.frame = .init(x: (screenWidth - logoWidth) / 2,
                                y: (logoContainerHeight - logoHeight) / 2,
                                width: logoWidth,
                                height: logoHeight)
        logoContainerView.addSubview(logoImageView)
        self.logoContainerView = logoContainerView

        ad.loadAdData()
        if let keyWindow = rootkeyWindow {
            keyWindow.rootViewController?.view.addSubview(ad)
            if logoContainerHeight > 0 && logoHeight > 0 && logoContainerHeight > logoHeight {
                keyWindow.rootViewController?.view.addSubview(logoContainerView)
            }

            ad.rootViewController = keyWindow.rootViewController
            showSplashAdView = ad
        }
    }
}

// MARK: - - 开屏广告Delegate

extension SwiftFlutterPangleAdPlugin: BUSplashAdDelegate {
    public func removeShowSplashAdView() {
        guard let _ = showSplashAdView else { return }
        showSplashAdView?.removeFromSuperview()
        showSplashAdView = nil
        logoContainerView?.removeFromSuperview()
        logoContainerView = nil
    }

    /// 广告加载成功回调
    public func splashAdDidLoad(_ splashAd: BUSplashAdView) {}

    /// SDK渲染开屏广告即将展示
    public func splashAdWillVisible(_ splashAd: BUSplashAdView) {}

    /// SDK渲染开屏广告点击回调
    public func splashAdDidClick(_ splashAd: BUSplashAdView) {}

    /// SDK渲染开屏广告即将关闭回调
    public func splashAdWillClose(_ splashAd: BUSplashAdView) {}

    /// 返回的错误码(error)表示广告加载失败的原因，所有错误码详情请见链接
    ///  https://www.csjplatform.com/supportcenter/5421
    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        
        if splashAd.tag == showSplashAdTag {
            let dict: Dictionary<String, Any> = [
                codeKey: "-1",
                messageKey: "开屏广告加载失败: \(String(describing: error?.localizedDescription))",
            ]
            debugPrint(dict)
            showSplashAdResult?(dict)
        } else if splashAd.tag == showSplashAdWithLogoTag {
            let dict: Dictionary<String, Any> = [
                codeKey: "-1",
                messageKey: "开屏广告加载失败: \(String(describing: error?.localizedDescription))",
            ]
            debugPrint(dict)
            showSplashAdWithLogoResult?(dict)
        }
        removeShowSplashAdView()
    }

    /// 用户点击跳过按钮时会触发此回调，可在此回调方法中处理用户点击跳转后的相关逻辑
    public func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {
    }

    /// SDK渲染开屏广告关闭回调，当用户点击广告时会直接触发此回调，建议在此回调方法中直接进行广告对象的移除操作
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
        if splashAd.tag == showSplashAdTag {
            let dict: Dictionary<String, Any> = [
                codeKey: code_success,
                messageKey: "开屏广告关闭回调",
            ]
            debugPrint(dict)
            showSplashAdResult?(dict)
        } else if splashAd.tag == showSplashAdWithLogoTag {
            let dict: Dictionary<String, Any> = [
                codeKey: code_success,
                messageKey: "开屏广告关闭回调",
            ]
            debugPrint(dict)
            showSplashAdWithLogoResult?(dict)
        }
        removeShowSplashAdView()
    }

    /// 倒计时为0时会触发此回调，如果客户端使用了此回调方法，建议在此回调方法中进行广告的移除操作
    public func splashAdCountdown(toZero splashAd: BUSplashAdView) {
        if splashAd.tag == showSplashAdTag {
            let dict: Dictionary<String, Any> = [
                codeKey: code_success,
                messageKey: "开屏广告倒计时为0关闭回调",
            ]
            debugPrint(dict)
            showSplashAdResult?(dict)
        } else if splashAd.tag == showSplashAdWithLogoTag {
            let dict: Dictionary<String, Any> = [
                codeKey: code_success,
                messageKey: "开屏广告倒计时为0关闭回调",
            ]
            debugPrint(dict)
            showSplashAdWithLogoResult?(dict)
        }
        removeShowSplashAdView()
    }

    /// 此回调在广告跳转到其他控制器时，该控制器被关闭时调用。interactionType：此参数可区分是打开的appstore/网页/视频广告详情页面
    public func splashAdDidCloseOtherController(_ splashAd: BUSplashAdView, interactionType: BUInteractionType) {
    }
}

// MARK: - - 激励视频Delegate

extension SwiftFlutterPangleAdPlugin: BUNativeExpressRewardedVideoAdDelegate {
    // 返回的错误码(error)表示广告加载失败的原因
    public func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
    }

    // 渲染失败，网络原因或者硬件原因导致渲染失败,可以更换手机或者网络环境测试。
    public func nativeExpressRewardedVideoAdViewRenderFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, error: Error?) {
        let dict: Dictionary<String, Any> = [
            codeKey: -1,
            messageKey: "激励视频渲染失败: \(String(describing: error?.localizedDescription))",
        ]
        debugPrint(dict)
        showRewardResult?(dict)
    }

    // 广告素材物料加载成功
    public func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        guard let window = rootkeyWindow, let rootVC = window.rootViewController else { return }
        rewardedAd?.show(fromRootViewController: rootVC)
    }

    // 视频下载完成
    public func nativeExpressRewardedVideoAdDidDownLoadVideo(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }

    // 用户关闭广告时会触发此回调，注意：任何广告的关闭操作必须用户主动触发
    public func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        let dict: Dictionary<String, Any> = [
            codeKey: code_success,
            messageKey: "用户关闭广告",
        ]
        debugPrint(dict)
        showRewardResult?(dict)
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
        let dict: Dictionary<String, Any> = [
            codeKey: code_success,
            messageKey: "激励视频奖励发放回调",
        ]
        debugPrint(dict)
        showRewardResult?(dict)
    }
}
