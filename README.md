# nativeweb

Build your Own Plugin using (PlatformViews) Demo for Flutter Live 2018 Extended Event - Hyderabad 

## Step 1

```dart
flutter create --org io.github.ponnamkarthik --template=plugin nativeweb
```

## Step 2

Inside lib/nativeweb.dart file we create a WebController Class

```dart

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

```

## Step 3

Create a Webview callback function

```dart
typedef void WebViewCreatedCallback(WebController controller);
```

Now in lib/nativeweb.dart we create a stateful widget

```dart

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
    return Container(
      
    );
  }
}

```

## Step 4

Inside build function instead of returning Container we return `AndroidView` or `UiKitView` for **Android** or **iOS**

```dart

if(defaultTargetPlatform == TargetPlatform.android) {
    return AndroidView(

    );
} else if(defaultTargetPlatform == TargetPlatform.iOS) {
    return UiKitView(

    );
}

return new Text('$defaultTargetPlatform is not yet supported by this plugin');

```

## Step 5

AndroidView and UiKitView accepts few parameters

```dart

viewType: 'nativeweb',
onPlatformViewCreated: onPlatformViewCreated,
creationParamsCodec: const StandardMessageCodec(),
```

AndroidView and UiKitView looks like below

```dart
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
```

This is our onPlatFormViewCreated Function

```dart
Future<void> onPlatformViewCreated(id) async {
    if (widget.onWebCreated == null) {
    return;
    }
    widget.onWebCreated(new WebController.init(id));
}
```

## Step 6

Inside `android` folder `NativeWebPlugin.java` file

```java
/** NativewebPlugin */
public class NativewebPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "nativeweb");
    channel.setMethodCallHandler(new NativewebPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }
}
```

replace above code with this one

```java
public class NativewebPlugin {

  public static void registerWith(Registrar registrar) {
    registrar
            .platformViewRegistry()
            .registerViewFactory(
                    "nativeweb", new WebFactory(registrar));
  }
}
```

## Step 7

Create a new file `WebFactory.java`

```java
public class WebFactory extends PlatformViewFactory {

    private final Registrar mPluginRegistrar;

    public WebFactory(Registrar registrar) {
        super(StandardMessageCodec.INSTANCE);
        mPluginRegistrar = registrar;
    }

    @Override
    public PlatformView create(Context context, int i, Object o) {
        return new FlutterWeb(context, mPluginRegistrar, i);
    }

}
```

## Step 8

Create a new file `FlutterWeb.java`

In this file we implement two methods `PlatformView`, `MethodCallHandler`

```java
public class FlutterWeb implements PlatformView, MethodCallHandler {
  
  // ..
  // ..
  
}
```

`FlutterWeb.java` constructor will be as below

```java
FlutterWeb(Context context, Registrar registrar, int id) {
    this.context = context;
    this.registrar = registrar;
    webView = getWebView(registrar);

    channel = new MethodChannel(registrar.messenger(), "nativeweb_" + id);
    
    channel.setMethodCallHandler(this);
}
```

we ovrride some default methods

```java
@Override
public View getView() {
    return webView;
}

@Override
public void dispose() {}

@Override
public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
        case "loadUrl":
            String url = call.arguments.toString();
            webView.loadUrl(url);
            break;
        default:
            result.notImplemented();
    }

}
```

we create a new function which return a webview

```java
private WebView getWebView(Registrar registrar) {
    WebView webView = new WebView(registrar.context());
    webView.setWebViewClient(new WebViewClient());
    webView.getSettings().setJavaScriptEnabled(true);
    return webView;
}
```

## Step 9

Inside iOS folder `NativewebPlugin.m` file replace the existing code with below

```
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterNativeWebFactory* webviewFactory =
      [[FlutterNativeWebFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:webviewFactory withId:@"nativeweb"];
}
```

## Step 10

Create two file `FlutterWeb.h` and `FlutterWeb.m`

Inside `FlutterWeb.h` paste the below code

```objc
#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

@interface FlutterWebController : NSObject <FlutterPlatformView>

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (UIView*)view;
@end

@interface FlutterWebFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
```


Inside `FlutterWeb.m` paste the below code

We implement `FlutterWebFactory` and `FlutterWebController`

```objc
#import "FlutterWeb.h"

@implementation FlutterWebFactory {
  NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
  FlutterWebController* webviewController =
      [[FlutterWebController alloc] initWithWithFrame:frame
                                       viewIdentifier:viewId
                                            arguments:args
                                      binaryMessenger:_messenger];
  return webviewController;
}

@end
```

```objc
@implementation FlutterWebController {
  WKWebView* _webView;
  int64_t _viewId;
  FlutterMethodChannel* _channel;
}

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if ([super init]) {
    _viewId = viewId;
    _webView = [[WKWebView alloc] initWithFrame:frame];
    NSString* channelName = [NSString stringWithFormat:@"ponnamkarthik/flutterwebview_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      [weakSelf onMethodCall:call result:result];
    }];

  }
  return self;
}

- (UIView*)view {
  return _webView;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([[call method] isEqualToString:@"loadUrl"]) {
    [self onLoadUrl:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onLoadUrl:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* url = [call arguments];
  if (![self loadUrl:url]) {
    result([FlutterError errorWithCode:@"loadUrl_failed"
                               message:@"Failed parsing the URL"
                               details:[NSString stringWithFormat:@"URL was: '%@'", url]]);
  } else {
    result(nil);
  }
}

- (bool)loadUrl:(NSString*)url {
  NSURL* nsUrl = [NSURL URLWithString:url];
  if (!nsUrl) {
    return false;
  }
  NSURLRequest* req = [NSURLRequest requestWithURL:nsUrl];
  [_webView loadRequest:req];
  return true;
}

@end
```

## Step 12

Inside `example/lib` folder `main.dart` file

```dart
// create a nativeweb widget
NativeWeb nativeWeb = new NativeWeb(
    onWebCreated: onWebCreated,
);
```

```dart
// call back function on view created
void onWebCreated(webController) {
    this.webController = webController;
    this.webController.loadUrl("https://flutter.io/");
}
```



## Step 11

* Most Important

Inside `example/ios` folder `Info.plist` file

```plist
<key>io.flutter.embedded_views_preview</key>
<string>YES</string>
```

