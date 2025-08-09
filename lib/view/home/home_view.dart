import 'package:flutter/material.dart';
import 'package:hackathon/themes/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:hackathon/view/home/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _chatController = TextEditingController();
  late final stt.SpeechToText _speech;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final bool available = await _speech.initialize();
    if (!available) return;
    setState(() => _listening = true);
    await _speech.listen(onResult: (res) {
      setState(() {
        _chatController.text = res.recognizedWords;
        _chatController.selection = TextSelection.fromPosition(
          TextPosition(offset: _chatController.text.length),
        );
      });
    });
  }

  Future<void> _pickFiles() async {
    await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'mp4', 'mov']);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycling Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync last 90 days',
            onPressed: () => controller.syncFromHealth(),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportCyclingCsvAndShare(),
          ),
          IconButton(
            icon: const Icon(Icons.bolt),
            tooltip: 'Load mock data',
            onPressed: () => controller.loadMockCyclingData(count: 24),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Spacings.m),
              children: const [
                // Placeholder for chat messages
                SizedBox.shrink(),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickFiles,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        // TODO: send message
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacings.s),
                  IconButton(
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                    onPressed: _toggleListening,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
