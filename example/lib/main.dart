import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pangle_ad/flutter_pangle_ad.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _platformVersion = 'Unknown';

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState(){
    super.initState();
    PangleAdPlugin.initialSDK(appId: "5112108",logLevel: 2);
    initPlatformState();

  }



  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await PangleAdPlugin.platformVersion;
      String res1 =  await PangleAdPlugin.loadRewardAd(slotID: '945562374');
      String res2 = await PangleAdPlugin.loadSplashAd(slotID: '887394289');
      print('123123 $res1,$res2');

    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }catch(e){
      print('123123 $e');
    }


    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Text('Running on: $_platformVersion\n')
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
                  OutlinedButton(
                    onPressed: () async{
                      var result = await PangleAdPlugin.showSplashAd(slotID: "887394289");
                      print('123123 $result');
                    },
                    child: Text('开屏广告'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      var result = await PangleAdPlugin.showRewardAd(
                          slotID: '945562374');
                      print('123123 $result');
                    },
                    child: Text('激励视频'),
                  ),
                  Container(
                    color: Colors.grey,
                    width: 300,
                    height: 130,
                    margin: EdgeInsets.all(10),
                    child: PangleAdBannerView(
                      slotID: '945912085',
                      viewHeight: 130,
                      viewWidth: 300,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
