import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pangle_ad/flutter_pangle_ad.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _platformVersion = 'Unknown';
  String get appId => Platform.isIOS ? "5112108" : "5112114";
  String get splashAdSoltId => Platform.isIOS ? "887394289" : "887391515";
  String get rewardAdSoltId => Platform.isIOS ? "945562374" : "945546650";
  String get bannerAdSoltId => Platform.isIOS ? "945912085" : "945758301";

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    PangleAdPlugin.initialSDK(appId: appId, logLevel: 2);
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion = '';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PangleAdPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    } catch (e) {
      print('initPlatformState: ${e.toString()}');
    }

    if (mounted) {
      setState(() {
        _platformVersion = platformVersion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plangle Ad example'),
        ),
        body: SafeArea(
          child: Container(
            constraints: BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Text('Running on: $_platformVersion\n'),
                  ),
                  _buildSplashAdButton(),
                  _buildSplashAdWithLogoButton(),
                  _buildRewardAdButton(),
                  _buildBannerAdView()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplashAdButton() {
    return OutlinedButton(
      onPressed: () async {
        var result = await PangleAdPlugin.showSplashAd(
          slotID: splashAdSoltId,
        );
        print('开屏广告: $result');
      },
      child: Text('开屏广告'),
    );
  }

  Widget _buildSplashAdWithLogoButton() {
    return OutlinedButton(
      onPressed: () async {
        var result = await PangleAdPlugin.showSplashAdWithLogo(
          slotID: splashAdSoltId,
          logoContainerHeight: 110,
          logoWidth: 135.5,
          logoHeight: 30,
          logoImageName: 'splashAd_logo',
        );
        print('带底部logo的开屏广告: $result');
      },
      child: Text('带底部logo的开屏广告'),
    );
  }

  Widget _buildRewardAdButton() {
    return OutlinedButton(
      onPressed: () async {
        var result = await PangleAdPlugin.showRewardAd(slotID: rewardAdSoltId);
        print('激励视频: $result');
      },
      child: Text('激励视频'),
    );
  }

  Widget _buildBannerAdView() {
    return Container(
      color: Colors.grey,
      width: 300,
      height: 130,
      margin: EdgeInsets.all(10),
      child: PangleAdBannerView(
        slotID: bannerAdSoltId,
        viewHeight: 130,
        viewWidth: 300,
      ),
    );
  }
}
