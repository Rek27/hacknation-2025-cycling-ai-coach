import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class AIChat extends StatefulWidget {
  const AIChat({super.key});

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  late final WebViewController _controller;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    // Ensure iOS presents the app-level microphone permission first,
    // so it appears in Settings and WebView can capture audio.
    _ensureMicPermission();

    final params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent);

    // Initial HTML will be loaded in build with the themed background color.
    _controller = controller;
  }

  Future<void> _ensureMicPermission() async {
    // Request on app side so the toggle appears in iOS Settings
    final PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) return;

    final PermissionStatus res = await Permission.microphone.request();
    print('res: $res');
    if (res.isPermanentlyDenied || res.isRestricted) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      _controller.loadHtmlString(_buildHtml());
      _loaded = true;
    }

    return WebViewWidget(controller: _controller);
  }

  String _buildHtml() {
    const String agentId = 'agent_6001k2812qqde7k95sppksdhw516';
    const String scriptUrl =
        'https://unpkg.com/@elevenlabs/convai-widget-embed';
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <script src="$scriptUrl" async type="text/javascript"></script>
    <style>
      html, body { margin:0; padding:0; background: transparent !important; }
      #app { display: inline-block; }
      elevenlabs-convai.full { display: inline-block; width: auto; height: auto; }
    </style>
  </head>
  <body>
    <div id="app">
      <elevenlabs-convai class="full" agent-id="$agentId"></elevenlabs-convai>
    </div>
    <!-- Simplified: no scripting; element fills container provided by Flutter -->
  </body>
</html>
''';
  }
}
