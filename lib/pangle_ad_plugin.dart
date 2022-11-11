import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PangleAdPlugin {
  static const MethodChannel _channel = const MethodChannel('flutter_pangle_ad');

  /// 获取平台系统版本，如 iOS 13.7/Andorid 11.0
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 初始化配置
  ///
  /// [appId] 穿山甲AppId
  /// [logLevel] 0-None,1-Error,2-Debug
  static Future initialSDK({required String appId, int logLevel = 0}) async {
    return await _channel.invokeMethod("initialSDK", {'appId': appId, 'logLevel': logLevel});
  }

  /// 显示开屏广告
  ///
  /// [slotID] 广告位id
  /// [hideSkipButton] 是否自定义跳过按钮 BOOL类型 默认为NO
  /// [tolerateTimeout] 默认超时时间为3.5s
  /// [needSplashZoomOutAd] 是否需要点睛广告 默认为NO,注：3200-3500版本有效， 3600以及以上版本无效
  static Future showSplashAd({
    required String slotID,
    bool hideSkipButton = false,
    double tolerateTimeout = 3.5,
    @deprecated bool needSplashZoomOutAd = false,
  }) async {
    return await _channel.invokeMethod("showSplashAd", {
      'slotID': slotID,
      'hideSkipButton': hideSkipButton,
      'tolerateTimeout': tolerateTimeout,
      'needSplashZoomOutAd': needSplashZoomOutAd
    });
  }

  /// 显示带有底部Logo的开屏广告
  ///
  /// [slotID] 广告位id
  /// [hideSkipButton] 是否自定义跳过按钮 BOOL类型 默认为NO
  /// [tolerateTimeout] 默认超时时间为3.5s
  /// [needSplashZoomOutAd] 是否需要点睛广告 默认为NO,注：3200-3500版本有效， 3600以及以上版本无效
  /// [logoContainerHeight] logo容器高度
  /// [logoImageName] logo图片名称
  /// [logoWidth] logo宽度
  /// [logoHeight] logo高度
  static Future showSplashAdWithLogo({
    required String slotID,
    bool hideSkipButton = false,
    double tolerateTimeout = 3.5,
    @deprecated bool needSplashZoomOutAd = false,
    double logoContainerHeight = 0,
    String logoImageName = '',
    double logoWidth = 0,
    double logoHeight = 0,
  }) async {
    return await _channel.invokeMethod("showSplashAdWithLogo", {
      'slotID': slotID,
      'hideSkipButton': hideSkipButton,
      'tolerateTimeout': tolerateTimeout,
      'needSplashZoomOutAd': needSplashZoomOutAd,
      'logoImageName': logoImageName,
      'logoWidth': logoWidth,
      'logoHeight': logoHeight,
      'logoContainerHeight': logoContainerHeight,
    });
  }

  /// 显示激励视频
  ///
  /// [slotID] 代码位ID
  /// [userId] tag_id
  /// [rewardName] 奖励名称
  /// [rewardAmount] 奖励数量
  /// [extra] 透传参数,应为json序列化后的字符串
  static Future showRewardAd({
    required String slotID,
    String? userId,
    String? rewardName,
    int? rewardAmount,
    String? extra,
  }) async {
    return await _channel.invokeMethod("showRewardAd", {
      'slotID': slotID,
      'userId': userId,
      'rewardName': rewardName,
      'rewardAmount': rewardAmount,
      'extra': extra,
    });
  }

  /// 加载开屏广告
  ///
  /// [slotID] 广告位id
  /// [hideSkipButton] 是否自定义跳过按钮 BOOL类型 默认为NO
  /// [tolerateTimeout] 默认超时时间为3.5s
  /// [needSplashZoomOutAd] 是否需要点睛广告 默认为NO
  @Deprecated('loadSplashAd will remove')
  static Future loadSplashAd({
    required String slotID,
    bool hideSkipButton = false,
    double tolerateTimeout = 3.5,
    bool needSplashZoomOutAd = false,
  }) async {
    return await _channel.invokeMethod("loadSplashAd", {
      'slotID': slotID,
      'hideSkipButton': hideSkipButton,
      'tolerateTimeout': tolerateTimeout,
      'needSplashZoomOutAd': needSplashZoomOutAd
    });
  }

  /// 加载激励视频
  ///
  /// [slotID] 代码位ID
  /// [userId] tag_id
  /// [rewardName] 奖励名称
  /// [rewardAmount] 奖励数量
  /// [extra] 透传参数,应为json序列化后的字符串
  @Deprecated('loadRewardAd will remove')
  static Future loadRewardAd({
    required String slotID,
    String? userId,
    String? rewardName,
    int? rewardAmount,
    String? extra,
  }) async {
    return await _channel.invokeMethod("loadRewardAd", {
      'slotID': slotID,
      'userId': userId,
      'rewardName': rewardName,
      'rewardAmount': rewardAmount,
      'extra': extra,
    });
  }
}
