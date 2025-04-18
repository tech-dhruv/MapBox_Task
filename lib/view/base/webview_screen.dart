import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewWidget extends StatefulWidget {
  final String url;
  const WebViewWidget({
    Key? key,
    required this.url
  }) : super(key: key);

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  late InAppWebViewController _controller;
  bool _isLoading = true;
  double progress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    showEasyLoader(false);
  }

  InAppWebViewGroupOptions inAPPWebOption = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: true,
        useOnDownloadStart: true,
        supportZoom: false,
        javaScriptEnabled: true,
        cacheEnabled: true,
        // userAgent: AppConstants.USER_AGENT,
        verticalScrollBarEnabled: true,
        horizontalScrollBarEnabled: true,
        preferredContentMode: UserPreferredContentMode.MOBILE,
        transparentBackground: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        thirdPartyCookiesEnabled: true,
        allowFileAccess: true,
        geolocationEnabled: true,
        domStorageEnabled: true,
      ),
      ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          allowsPictureInPictureMediaPlayback: true),);

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
          gestureRecognizers: Set()
            ..add(Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer())),
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
          onWebViewCreated: (controller) async {
            _controller = controller;
            setState(() {
              _isLoading = true;
            });
            showEasyLoader(_isLoading);
          },
          initialOptions: inAPPWebOption,
          onLoadStop: (controller, url) async {
            setState(() {
              _isLoading = false;
            });
            showEasyLoader(_isLoading);
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
        );
  }
}

showEasyLoader(
  bool isLoading,
) {
  if (isLoading) {
    EasyLoading.show(status: 'loading...');
  } else {
    if (EasyLoading.isShow) EasyLoading.dismiss();
  }
}
