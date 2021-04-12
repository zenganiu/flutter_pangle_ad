
import BUAdSDK
import Flutter

class PlatformBannerView: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    let args: Any?

    init(_ frame: CGRect, viewID: Int64, args: Any?) {
        self.frame = frame
        viewId = viewID
        self.args = args
    }

    func view() -> UIView {
        guard let args = self.args as? Dictionary<String, Any>,
              let slotID = args["slotID"] as? String,
              let keyWindow = UIApplication.shared.windows.first,
              let rootVC = keyWindow.rootViewController
        else {
            let label = UILabel()
            label.text = "数据加载失败"
            label.textColor = UIColor.red
            label.frame = frame
            label.textAlignment = .center
            return label
        }

        var viewWidth: Double = 300
        var viewHeight: Double = 300
        if let w = args["viewWidth"] as? NSNumber {
            viewWidth = w.doubleValue
        }
        if let h = args["viewHeight"] as? NSNumber {
            viewHeight = h.doubleValue
        }

        let banner = BUNativeExpressBannerView(slotID: slotID, rootViewController: rootVC, adSize: CGSize(width: viewWidth, height: viewHeight))
        banner.loadAdData()
        return banner
    }
}
