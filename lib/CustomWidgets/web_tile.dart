import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebOnlyGridTile extends StatefulWidget {
  final int height;
  final int width;
  final String webUrl;

  const WebOnlyGridTile({
    super.key,
    required this.height,
    required this.width,
    required this.webUrl,
  });

  @override
  State<WebOnlyGridTile> createState() => _WebOnlyGridTileState();
}

class _WebOnlyGridTileState extends State<WebOnlyGridTile> {
  WebViewController? _webViewController;
  bool _isLoadingWebView = true;
  bool _webViewError = false;

  @override
  void initState() {
    super.initState();

    try {
      Uri uri = Uri.parse(widget.webUrl);

      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  _isLoadingWebView = true;
                  _webViewError = false;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoadingWebView = true;
                  _webViewError = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoadingWebView = false;
                  _webViewError = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              log(
                '''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''' as num,
              );
              if (mounted) {
                setState(() {
                  _isLoadingWebView = false;
                  _webViewError = true;
                });
              }
            },
          ),
        )
        ..loadRequest(uri);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWebView = false;
          _webViewError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaggeredGridTile.count(
      crossAxisCellCount: widget.width,
      mainAxisCellCount: widget.height,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _buildWebContent(),
        ),
      ),
    );
  }

  Widget _buildWebContent() {
    if (_webViewError) {
      return Center(
        child: Icon(
          Icons.error_outline,
          size: 40,
          color: Theme.of(context).colorScheme.error.withOpacity(0.7),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_webViewController != null)
          WebViewWidget(controller: _webViewController!),
        if (_isLoadingWebView) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
