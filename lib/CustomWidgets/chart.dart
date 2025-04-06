import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BankNiftyWebView extends StatefulWidget {
  @override
  _BankNiftyWebViewState createState() => _BankNiftyWebViewState();
}

class _BankNiftyWebViewState extends State<BankNiftyWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.tradingview.com/symbols/NSE-BANKNIFTY/'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DEX')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
