# flutter_pangle_ad

穿山甲广告Flutter插件

## 安装

```yaml
  flutter_pangle_ad:
    git: https://github.com/zenganiu/flutter_pangle_ad.git
```

## 使用

```dart
import 'package:flutter_pangle_ad/flutter_pangle_ad.dart';

/// 初始化SDK
PangleAdPlugin.initialSDK(appId: "xxx", logLevel: 2);

/// 开屏广告
var result = await PangleAdPlugin.showSplashAd(slotID: "xxx");

/// 激励视频
var result = await PangleAdPlugin.showRewardAd(slotID: 'xxx');

/// flutter bannar widget
PangleAdBannerView(slotID: 'xxx',viewHeight: 130,viewWidth: 300)

```



