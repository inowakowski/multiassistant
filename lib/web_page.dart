import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class WebViewPage extends StatefulWidget {
  final String localUrl;
  final String externalUrl;

  WebViewPage(this.localUrl, this.externalUrl, {super.key});

  @override
  State<WebViewPage> createState() {
    return _WebViewPageState(this.localUrl, this.externalUrl);
  }
}

class _WebViewPageState extends State<WebViewPage>
    with AutomaticKeepAliveClientMixin {
  String localUrl;
  String externalUrl;

  _WebViewPageState(this.localUrl, this.externalUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: WebView(
          initialUrl: externalUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }

  Future<bool> url() async {
    http.Response response = await http.get(Uri.parse(localUrl));

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
