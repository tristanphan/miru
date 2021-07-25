import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Web {
  static Future<Web> init(String url) async {
    Web web = Web();
    // int startTime = DateTime.now().millisecondsSinceEpoch;
    await web.inAppWeb.init(url);
    // print("WebView Init Time: " + ((DateTime.now().millisecondsSinceEpoch - startTime)/1000).toStringAsFixed(3) + " seconds");
    await web.inAppWeb.finishLoading();
    // print("Page Load Time: " + ((DateTime.now().millisecondsSinceEpoch - startTime)/1000).toStringAsFixed(3) + " seconds");
    return web;
  }

  Future<void> reload() async {
    await inAppWeb.reload();
  }

  Future<void> finishLoading() async {
    await inAppWeb.finishLoading();
  }

  _InAppWeb inAppWeb = _InAppWeb();

  Future<void> load(String url) async {
    // int startTime = DateTime.now().millisecondsSinceEpoch;
    await inAppWeb.load(url);
    // print("Page Load Time: " + ((DateTime.now().millisecondsSinceEpoch - startTime)/1000).toStringAsFixed(3) + " seconds");
  }

  Future<String> getURL() async {
    return (await inAppWeb.controller!.getUrl()).toString();
  }

  Future<dynamic> evaluate(String javascript) async {
    return inAppWeb.evaluate(javascript);
  }

  void destroy() {
    inAppWeb.destroy();
  }
}

class _InAppWeb {
  Future<void> load(String url) async {
    controller!.loadUrl(
        urlRequest: URLRequest(
            url: Uri.parse(Uri.encodeFull(url).replaceAll("//", "/"))));
    while (await controller!.isLoading()) {
      await Future.delayed(Duration(milliseconds: 10));
    }
    return;
  }

  Future<void> finishLoading() async {
    while (await controller!.isLoading()) {
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  Future<void> reload() async {
    await controller!.reload();
  }

  Future<dynamic> evaluate(String javascript) async =>
      controller!.evaluateJavascript(source: javascript);
  InAppWebViewController? controller;
  HeadlessInAppWebView? _view;

  Future<void> init(String url) async {
    _view = new HeadlessInAppWebView(
        onWebViewCreated: (c) {
          controller = c;
        },
        initialUrlRequest: URLRequest(
            url: Uri.parse(Uri.encodeFull(url).replaceAll("//", "/"))),
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                incognito: true,
                cacheEnabled: true,
                javaScriptCanOpenWindowsAutomatically: false)));
    return await _view!.run();
  }

  void destroy() {
    _view!.dispose();
  }

  void doNothing(anything, somethingElse) {}
}
