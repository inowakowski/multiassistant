import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  // final String localUrl;
  // final String externalUrl;
  final String url;

  // WebViewPage(this.localUrl, this.externalUrl, {super.key});
  const WebViewPage(this.url, {super.key});

  @override
  State<WebViewPage> createState() {
    return _WebViewPageState(url);
    // return _WebViewPageState(this.localUrl, this.externalUrl);
  }
}

class _WebViewPageState extends State<WebViewPage>
    with AutomaticKeepAliveClientMixin {
  // String localUrl;
  // String externalUrl;
  String url;

  _WebViewPageState(this.url);
  // _WebViewPageState(this.localUrl, this.externalUrl);
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
