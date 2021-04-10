import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PangleAdBannerView extends StatefulWidget {
  String slotID;

  PangleAdBannerView({String slotID}) {
    this.slotID = slotID;
  }

  @override
  _PangleAdBannerViewState createState() => _PangleAdBannerViewState();
}

class _PangleAdBannerViewState extends State<PangleAdBannerView> {
  Widget _getBannerView() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      Map<String, dynamic> params = {
        'slotID': widget.slotID ?? "945912085",
      };

      return UiKitView(
        viewType: 'PangleAdBannerView',
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return ErrorWidget('unsupport android');
    } else {
      return ErrorWidget('unsupport Platform');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _getBannerView();
  }
}
