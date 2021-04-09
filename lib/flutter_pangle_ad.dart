import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class FlutterPangleAd {
  static const MethodChannel _channel =
      const MethodChannel('flutter_pangle_ad');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 显示开屏广告
  ///
  /// [slotID] 广告位id
  /// [hideSkipButton] 是否自定义跳过按钮 BOOL类型 默认为NO
  /// [tolerateTimeout] 默认超时时间为3.5s
  /// [needSplashZoomOutAd] 是否需要点睛广告 默认为NO
  static Future<bool> showSplashAd(
      {@required String slotID,
      bool hideSkipButton = false,
      double tolerateTimeout = 3.5,
      bool needSplashZoomOutAd = false}) async {
    return await _channel.invokeMethod("splashAd", {
      'slotID': slotID,
      'hideSkipButton': hideSkipButton,
      'tolerateTimeout': tolerateTimeout,
      'needSplashZoomOutAd': needSplashZoomOutAd
    });
  }
}
