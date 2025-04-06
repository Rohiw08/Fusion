import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WidgetsGridTile extends StatefulWidget {
  final int height;
  final int width;
  final String imageUrl;
  final String? webUrl; // Changed to nullable String?

  const WidgetsGridTile({
    super.key,
    required this.height,
    required this.width,
    required this.imageUrl,
    this.webUrl, // Removed 'required', now optional (defaults to null if not provided)
  });

  @override
  State<WidgetsGridTile> createState() => _WidgetsGridTileState();
}

class _WidgetsGridTileState extends State<WidgetsGridTile> {
  WebViewController? _webViewController;
  bool _showWebView = false;
  bool _isLoadingWebView = true; // Added state for WebView loading
// Added state for WebView error

  @override
  void initState() {
    super.initState();

    // Check if webUrl is non-null AND not empty
    _showWebView = widget.webUrl?.isNotEmpty ?? false; // Use null-aware check

    if (_showWebView) {
      // Since _showWebView is true, widget.webUrl cannot be null here.
      // We can safely use the bang operator (!)
      try {
        Uri uri = Uri.parse(widget.webUrl!); // Parse the URL

        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Still loading
                if (mounted) {
                  setState(() {
                    _isLoadingWebView = true;
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoadingWebView = true;
                  });
                }
              },
              onPageFinished: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoadingWebView = false;
                  });
                }
              },
              onWebResourceError: (WebResourceError error) {
                // Handle errors - e.g., fallback to image
                if (mounted) {
                  setState(() {
                    _showWebView = false; // Fallback to image on error
                    _isLoadingWebView = false;
// Mark error
                  });
                }
              },
              // Optional: Add more delegates as needed
            ),
          )
          ..loadRequest(uri); // Load the parsed URI
      } catch (e) {
        // Handle potential URI parsing errors
        if (mounted) {
          setState(() {
            _showWebView = false; // Fallback to image if URL is invalid
            _isLoadingWebView = false;
          });
        }
      }
    } else {
      // If not showing webview, ensure loading is false
      _isLoadingWebView = false;
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
          child: _buildChildContent(), // Use helper to build content
        ),
      ),
    );
  }

  // Helper to decide which widget to show inside ClipRRect
  Widget _buildChildContent() {
    if (_showWebView && _webViewController != null) {
      // Show WebView, potentially with a loading indicator overlay
      return Stack(
        alignment: Alignment.center,
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isLoadingWebView) // Show indicator only while loading WebView
            const Center(child: CircularProgressIndicator()),
        ],
      );
    } else {
      // Show Image (handles its own loading/error internally)
      return _buildImageView();
    }
  }

  // Helper widget to build the Image view (no changes needed here)
  Widget _buildImageView() {
    return Image.network(
      widget.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child; // Image loaded
        // Show progress indicator for image loading
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        ;
        return Center(
          child: Icon(
            Icons.broken_image,
            size: 40,
            color: Theme.of(context)
                .colorScheme
                .error
                .withOpacity(0.7), // Use error color
          ),
        );
      },
    );
  }
}
