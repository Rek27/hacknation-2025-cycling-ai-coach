import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';

/// The AIChat is a widget that displays a chatbot for the user to ask questions about their cycling activities.
///
/// It uses the ElevenLabs Convai widget to display the chatbot.
/// It handles the permission for the microphone, and the local server and
/// the HTML for the chatbot
class AIChat extends StatefulWidget {
  const AIChat({super.key});

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  late final WebViewController _controller;
  HttpServer? _server;

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

    _controller = controller;

    // Start local server and load the hosted HTML over a secure (localhost) origin
    () async {
      final uri = await _startLocalServer();
      if (!mounted) return;
      await _controller.loadRequest(uri);
      if (mounted) setState(() {});
    }();
  }

  Future<void> _ensureMicPermission() async {
    // Request on app side so the toggle appears in iOS Settings
    final PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) return;

    final PermissionStatus res = await Permission.microphone.request();
    if (res.isPermanentlyDenied || res.isRestricted) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }

  /// Starts a local server to host the HTML for the chatbot.
  ///
  /// The server is started on the loopback address and the port is returned.
  Future<Uri> _startLocalServer() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final int port = _server!.port;

    () async {
      await for (final HttpRequest request in _server!) {
        request.response.headers.contentType = ContentType.html;
        request.response.write(_buildHtml());
        await request.response.close();
      }
    }();

    return Uri.parse('http://127.0.0.1:$port/');
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  /// Builds the HTML for the chatbot.
  ///
  /// The HTML is returned as a [String] object.
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
