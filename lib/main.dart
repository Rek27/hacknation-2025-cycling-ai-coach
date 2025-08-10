import 'package:flutter/material.dart';
import 'package:hackathon/dto/schedule_interval_dto.dart';
import 'package:hackathon/model/mock_schedule_interval.dart';
import 'package:hackathon/services/supabase_manager.dart';
import 'package:hackathon/themes/app_themes.dart';
import 'package:hackathon/view/home/home_controller.dart';
import 'package:hackathon/view/home/home_view.dart';
import 'package:provider/provider.dart';
import 'package:hackathon/dto/test_dto.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'model/schedule_interval.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseManager.initialize();

  print('mocking data...');
  for (var interval in mockIntervals) {
    await ScheduleIntervalDto.insertInterval(
      interval,
    );
  }
  print('mocking data done');

  // Ensure a platform implementation for webview_flutter on iOS
  if (WebViewPlatform.instance == null ||
      WebViewPlatform.instance is! WebKitWebViewPlatform) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
        // Add future controllers here
      ],
      child: MaterialApp(
        title: 'Hackathon',
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        highContrastTheme: AppThemes.lightHighContrast,
        highContrastDarkTheme: AppThemes.darkHighContrast,
        home: const HomeView(),
      ),
    );
  }
}
