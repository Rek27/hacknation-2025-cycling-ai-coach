import 'package:flutter/material.dart';
import 'package:hackathon/services/supabase_manager.dart';
import 'package:hackathon/themes/app_themes.dart';
import 'package:hackathon/view/home/home_controller.dart';
import 'package:hackathon/view/home/home_view.dart';
import 'package:provider/provider.dart';
import 'package:hackathon/dto/test_dto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseManager.initialize();

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
