import 'package:flutter/material.dart';
import 'package:nativeweb/nativeweb.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  WebController webController;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    NativeWeb nativeWeb = new NativeWeb(
      onWebCreated: onWebCreated,
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: nativeWeb,
          height: 300.0,
        )
      ),
    );
  }

  void onWebCreated(webController) {
    this.webController = webController;
    this.webController.loadUrl("https://flutter.io/");
  }
}
