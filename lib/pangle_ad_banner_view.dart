import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PangleAdBannerView extends StatefulWidget {
  String slotID;
  double viewWidth;
  double viewHeight;

  /// 初始化
  ///
  /// [slotID] 代码位
  /// [viewWidth] banner宽度
  /// [viewHeight] banner宽度高度
  PangleAdBannerView({String slotID, double viewWidth, double viewHeight}) {
    this.slotID = slotID;
    this.viewWidth = viewWidth;
    this.viewHeight = viewHeight;
  }

  @override
  _PangleAdBannerViewState createState() => _PangleAdBannerViewState();
}

class _PangleAdBannerViewState extends State<PangleAdBannerView> {
  @override
  Widget build(BuildContext context) {
    return _getBannerView();
  }

  Widget _getBannerView() {
    Map<String, dynamic> params = {
      'slotID': widget.slotID ?? "945912085",
      'viewWidth': widget.viewWidth,
      'viewHeight': widget.viewHeight,
    };
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'PangleAdBannerView',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'PangleAdBannerView',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return ErrorWidget('unsupport Platform');
    }
  }
}
