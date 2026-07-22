import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:beautyontapp/store_webview.dart' show kBrowserUserAgent;

// LEGACY: this screen belongs to the old native shop flow (beautyontapp.net
// backend) and is not reachable from the shipped WebView-wrapper app. If it
// is ever reactivated, checkout MUST keep the shared browser user agent so
// analytics cookies set on the storefront carry into checkout — otherwise
// purchases complete with no ad attribution.
class CheckoutWebView extends StatelessWidget {
  final String url;

  const CheckoutWebView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text('Checkout'),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setUserAgent(kBrowserUserAgent)
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}
