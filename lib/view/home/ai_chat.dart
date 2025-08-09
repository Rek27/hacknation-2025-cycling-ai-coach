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
  String? _lastBgHex;

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
    final status = await Permission.microphone.status;
    if (status.isGranted) return;

    final res = await Permission.microphone.request();
    if (res.isPermanentlyDenied) {
      //await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute background color from widget or current theme
    final Color bg = Theme.of(context).colorScheme.surface;
    final String bgHex = _toCssHex(bg);

    if (_lastBgHex != bgHex) {
      _controller.loadHtmlString(_buildHtml(bgHex));
      _lastBgHex = bgHex;
    }

    return WebViewWidget(controller: _controller);
  }

  String _toCssHex(Color c) {
    // Use component accessors to avoid deprecated fields
    final int r = ((c.r * 255.0).round()) & 0xFF;
    final int g = ((c.g * 255.0).round()) & 0xFF;
    final int b = ((c.b * 255.0).round()) & 0xFF;
    return '#'
        '${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  String _buildHtml(String bgHex) {
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
      html, body, #app { margin:0; padding:0; height:100%; width:100%; }
      body { background: transparent !important; }
      #app { position: fixed; inset: 0; }
      elevenlabs-convai.full { display:block; width:100%; height:100%; min-height:100%; }
    </style>
  </head>
  <body>
    <div id="app">
      <elevenlabs-convai class="full" agent-id="$agentId"></elevenlabs-convai>
    </div>
  </body>
</html>
''';
  }
}
