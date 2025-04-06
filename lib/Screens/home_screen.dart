import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fusion/CustomWidgets/web_tile.dart';
import 'dart:ui';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer'; // For debugPrint

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
  bool _webViewError = false; // Added state for WebView error

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
                // Handle errors - e.g., fallback to image
                log('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''', name: 'WebView Error');
                if (mounted) {
                  setState(() {
                    _showWebView = false; // Fallback to image on error
                    _isLoadingWebView = false;
                    _webViewError = true; // Mark error
                  });
                }
              },
              // Optional: Add more delegates as needed
            ),
          )
          ..loadRequest(uri); // Load the parsed URI
      } catch (e) {
        // Handle potential URI parsing errors
        log('Error parsing URL: ${widget.webUrl}, Error: $e',
            name: 'WebView Setup Error');
        if (mounted) {
          setState(() {
            _showWebView = false; // Fallback to image if URL is invalid
            _isLoadingWebView = false;
            _webViewError = true;
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
        // Show broken image icon if image fails to load OR if webview had an error (_webViewError flag)
        log('Error loading image: ${widget.imageUrl}, Error: $error',
            name: 'Image Loading Error');
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

List<Widget> customWidgets = [
  const WidgetsGridTile(
    height: 2,
    width: 2,
    imageUrl: "",
  ),
  const WidgetsGridTile(
    height: 1,
    width: 1,
    imageUrl:
        "https://i.pinimg.com/736x/f7/b7/4b/f7b74b54f279a021e17ca9c901f7603b.jpg",
  ),
];

List<Widget> setWidgets = [
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/ETHUSD/",
  ),
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/BTCUSD/",
  ),
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/XRPUSD/",
  ),
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/XRPUSD/",
  ),
].toList(); // Convert to a mutable list

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _addWidgetToHomeScreen(Widget widget) {
    setState(() {
      setWidgets.add(widget);
    });
  }

  void _showAddCustomerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  color:
                      Theme.of(context).colorScheme.surface.withOpacity(0.01),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(children: [
                  AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(
                      "Add New Widget",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 4,
                        children: customWidgets,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomerModal(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 4,
            children: setWidgets,
          ),
        ),
      ),
    );
  }
}
