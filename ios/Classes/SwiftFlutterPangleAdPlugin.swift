import BUAdSDK
import Flutter
import UIKit

internal let screenWidth = UIScreen.main.bounds.width
internal let screenHeight = UIScreen.main.bounds.height
internal var rootkeyWindow: UIWindow? {
    return UIApplication.shared.windows.first
}

internal var rootController: UIViewController? {
    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
        return rootVC
    }
    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
        return rootVC
    }
    return nil
}

public class SwiftFlutterPangleAdPlugin: NSObject, FlutterPlugin {
    /// 通道名称
    static let channelName = "flutter_pangle_ad"

    private let showSplashAdTag: Int = 997
    private let showRewardAdTag: Int = 998
    private let showSplashAdWithLogoTag: Int = 999

    /// 开屏广告
    var splashAd: BUSplashAd?

    /// 带自定义logo开屏广告
    var splashAdWithLogo: BUSplashAd?

    /// 激励视频
    var rewardedAd: BUNativeExpressRewardedVideoAd?

    var logoContainerView: UIView?
    var logoView: UIView?

    var splashAdResult: FlutterResult?
    var splashAdWithLogoResult: FlutterResult?
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

        case "showSplashAdWithLogo":

            showSplashAdWithLogo(call, result: result)

        case "showRewardAd":

            showRewardAd(call, result: result)

        case "loadSplashAd", "loadRewardAd":

            let dict = MyResult.error(message: "方法已弃用")
            result(dict)

        default:
            break
        }
    }

    private func initialSDK(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let appId = call.getString(key: "appId") else {
            let dict = MyResult.error(message: "appId为必传参数，不能为空")
            result(dict)
            return
        }

        let configuration = BUAdSDKConfiguration()
        var level: BUAdSDKLogLevel = .none
        if let logLevel = call.getInt(key: "logLevel") {
            switch logLevel {
            case 0:
                level = .none
            case 1:
                level = .error
            case 2:
                level = .verbose
            default:
                break
            }
        }

        configuration.logLevel = level
        configuration.appID = appId
        configuration.territory = .CN

        // 初始化
        BUAdSDKManager.start(asyncCompletionHandler: { isSuccess, error in

            if isSuccess {
                let dict = MyResult.success(message: "初始化成功")
                result(dict)
            } else {
                var message = "初始化失败"
                if let errorMessage = error?.localizedDescription {
                    message = "初始化失败: \(errorMessage)"
                }
                let dict = MyResult.error(message: message)
                result(dict)
            }
        })
    }

    // MARK: - - 获取平台、系统版本

    private func getPlatformVersion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let system = UIDevice.current.systemName
        let version = UIDevice.current.systemVersion
        let platformVersion = "\(system) \(version)"

        result(platformVersion)
    }

    // MARK: - - 显示开屏广告

    private func showSplashAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let slotID = call.getString(key: "slotID") else {
            let dict = MyResult.error(message: "slotID为必传参数，不能为空")
            result(dict)
            return
        }

        // 是否隐藏跳过按钮
        let hideSkipButton = call.getBool(key: "hideSkipButton") ?? false
        // 超时时间
        let tolerateTimeout = call.getDouble(key: "tolerateTimeout") ?? 3.5

        let ad = BUSplashAd(slotID: slotID, adSize: UIScreen.main.bounds.size)

        ad.tolerateTimeout = tolerateTimeout
        ad.hideSkipButton = hideSkipButton
        ad.delegate = self
        splashAdResult = result
        ad.loadData()

        // 临时变量加载广告将不能完成广告加载
        splashAd = ad
    }

    // MARK: - - 显示带底部Logo的开屏广告

    private func showSplashAdWithLogo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let slotID = call.getString(key: "slotID") else {
            let dict = MyResult.error(message: "slotID为必传参数，不能为空")
            result(dict)
            return
        }

        // 是否隐藏跳过按钮
        let hideSkipButton = call.getBool(key: "hideSkipButton") ?? false
        // 超时时间
        let tolerateTimeout = call.getDouble(key: "tolerateTimeout") ?? 3.5

        let logoImageName = call.getString(key: "logoImageName") ?? ""
        let logoViewHeight = call.getDouble(key: "logoContainerHeight") ?? 0
        let logoWidth = call.getDouble(key: "logoWidth") ?? 0
        let logoHeight = call.getDouble(key: "logoHeight") ?? 0
 
        
        let logoView = UIView(frame: .init(x: 0, y: screenHeight - logoViewHeight, width: screenWidth, height: logoViewHeight))
        logoView.backgroundColor = .white
        let logoImageView = UIImageView(image: UIImage(named: logoImageName))
        logoImageView.frame = .init(x: (screenWidth - logoWidth) / 2, y: (logoViewHeight - logoHeight) / 2, width: logoWidth, height: logoHeight)
        logoView.addSubview(logoImageView)
        self.logoView = logoView
        
        // 开屏广告
        let ad = BUSplashAd(slotID: slotID, adSize: .init(width: screenWidth, height: screenHeight-logoViewHeight))
        ad.hideSkipButton = hideSkipButton
        ad.tolerateTimeout = tolerateTimeout
        ad.delegate = self
        splashAdWithLogoResult = result
        ad.loadData()

        // 临时变量加载广告将不能完成广告加载
        splashAdWithLogo = ad
    }

    // MARK: - - 显示激励视频

    private func showRewardAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let slotID = call.getString(key: "slotID") else {
            let dict = MyResult.error(message: "slotID为必传参数，不能为空")
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

        rewardResult = result
        let ad = BUNativeExpressRewardedVideoAd(slotID: slotID, rewardedVideoModel: model)
        ad.delegate = self
        ad.loadData()
        rewardedAd = ad
    }
}

// MARK: - - 开屏广告Delegate

extension SwiftFlutterPangleAdPlugin: BUSplashAdDelegate {
    public func removeShowSplashAdView() {
        if let splashAd {
            splashAd.removeSplashView()
            self.splashAd = nil
        }

        if let splashAdWithLogo {
            splashAdWithLogo.removeSplashView()
            self.splashAdWithLogo = nil
            self.logoView?.removeFromSuperview()
            self.logoContainerView?.removeFromSuperview()
            self.logoView = nil
            self.logoContainerView = nil
        }
    }

    // MARK: - - 接收广告加载结果

    /// 返回的错误码(error)表示广告加载失败的原因
    public func splashAdLoadFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        printLog("splashAdLoadFail: \(error?.localizedDescription ?? "--")")
    }

    /// 广告加载成功回调
    public func splashAdLoadSuccess(_ splashAd: BUSplashAd) {
        printLog("splashAdLoadSuccess")
        if let ad = self.splashAd, let rootController {
            ad.showSplashView(inRootViewController: rootController)
        } else if let ad = splashAdWithLogo,
                  let adView = ad.splashView,
                  let rootController,
                  let logo = logoView
        {
        
            let logoContainerView = UIView(frame: UIScreen.main.bounds)
            logoContainerView.addSubview(logo)
            adView.frame = .init(x: 0, y: 0, width: screenWidth, height: screenHeight - logo.frame.height)
            logoContainerView.addSubview(adView)
            rootController.view.addSubview(logoContainerView)
            self.logoContainerView = logoContainerView
        }
    }

    // MARK: - - BUSplashAdDelegate回调

    ///  SDK渲染开屏广告渲染成功回调
    public func splashAdRenderSuccess(_ splashAd: BUSplashAd) {
        printLog("splashAdRenderSuccess")
    }

    /// SDK渲染开屏广告渲染失败回调
    public func splashAdRenderFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        removeShowSplashAdView()
        printLog("splashAdRenderFail: \(error?.localizedDescription ?? "")")
    }

    /// SDK渲染开屏广告即将展示
    public func splashAdWillShow(_ splashAd: BUSplashAd) {
        printLog("splashAdWillShow")
    }

    /// SDK渲染开屏广告展示
    public func splashAdDidShow(_ splashAd: BUSplashAd) {
        printLog("splashAdDidShow")
    }

    /// SDK渲染开屏广告点击回调
    public func splashAdDidClick(_ splashAd: BUSplashAd) {
        printLog("splashAdDidClick")
    }

    /// SDK渲染开屏广告关闭回调，当用户点击广告时会直接触发此回调，建议在此回调方法中直接进行广告对象的移除操作
    public func splashAdDidClose(_ splashAd: BUSplashAd, closeType: BUSplashAdCloseType) {
        printLog("splashAdDidClose")
        removeShowSplashAdView()
    }

    /// SDK渲染开屏广告视图控制器关闭
    public func splashAdViewControllerDidClose(_ splashAd: BUSplashAd) {
        printLog("splashAdViewControllerDidClose")
    }

    /// 此回调在广告跳转到其他控制器时，该控制器被关闭时调用。interactionType：此参数可区分是打开的appstore/网页/视频广告详情页面
    public func splashDidCloseOtherController(_ splashAd: BUSplashAd, interactionType: BUInteractionType) {
        printLog("splashDidCloseOtherController")
    }

    /// 视频广告播放完毕回调
    public func splashVideoAdDidPlayFinish(_ splashAd: BUSplashAd, didFailWithError error: Error) {
        printLog("splashVideoAdDidPlayFinish")
    }
}

// MARK: - - 激励视频Delegate

extension SwiftFlutterPangleAdPlugin: BUNativeExpressRewardedVideoAdDelegate {
    // 返回的错误码(error)表示广告加载失败的原因
    public func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        let dict = MyResult.error(message: "激励视频加载失败: \(String(describing: error?.localizedDescription))")
        rewardResult?(dict)
    }

    // 渲染失败，网络原因或者硬件原因导致渲染失败,可以更换手机或者网络环境测试。
    public func nativeExpressRewardedVideoAdViewRenderFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, error: Error?) {
        let dict = MyResult.error(message: "激励视频渲染失败: \(String(describing: error?.localizedDescription))")
        rewardResult?(dict)
    }

    // 广告素材物料加载成功
    public func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        if let rootController{
            rewardedAd?.show(fromRootViewController: rootController)
        }
    }

    // 视频下载完成
    public func nativeExpressRewardedVideoAdDidDownLoadVideo(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
    }

    // 用户关闭广告时会触发此回调，注意：任何广告的关闭操作必须用户主动触发
    public func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        let dict = MyResult.success(message: "用户关闭广告")
        rewardResult?(dict)
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
        let dict = MyResult.success(message: "激励视频奖励发放回调")
        rewardResult?(dict)
    }
}
