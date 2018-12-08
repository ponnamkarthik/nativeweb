import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

typedef void WebViewCreatedCallback(WebController controller);

class NativeWeb extends StatefulWidget {

  final WebViewCreatedCallback onWebCreated;

  NativeWeb({
    Key key,
     @required this.onWebCreated,
  });

  @override
  _NativeWebState createState() => _NativeWebState();
}

class _NativeWebState extends State<NativeWeb> {
  @override
  Widget build(BuildContext context) {
    if(defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'nativeweb',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'nativeweb',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return new Text('$defaultTargetPlatform is not yet supported by this plugin');
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onWebCreated == null) {
      return;
    }
    widget.onWebCreated(new WebController.init(id));
  }

}


class WebController {

  MethodChannel _channel;
  
  WebController.init(int id) {
    _channel =  new MethodChannel('nativeweb_$id');
  }

  Future<void> loadUrl(String url) async {
    assert(url != null);
    return _channel.invokeMethod('loadUrl', url);
  }
}
