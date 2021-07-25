import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EmergencyView extends StatefulWidget {
  final String url;

  const EmergencyView(this.url, {Key? key}) : super(key: key);

  @override
  _EmergencyViewState createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  InAppWebViewController? controller;

  @override
  void initState() {
    print("Fallback Mode: " + widget.url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text("Fallback Mode")),
        backgroundColor: Colors.black,
        body: Center(
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                    onWebViewCreated: (c) {
                      controller = c;
                    },
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            incognito: true,
                            useShouldOverrideUrlLoading: true,
                            javaScriptEnabled: true,
                            javaScriptCanOpenWindowsAutomatically: false,
                            transparentBackground: true)),
                    shouldOverrideUrlLoading:
                        (InAppWebViewController controller,
                            NavigationAction action) async {
                      if (action.request.url.toString() == widget.url)
                        return NavigationActionPolicy.ALLOW;
                      return NavigationActionPolicy.CANCEL;
                    }))));
  }
}
