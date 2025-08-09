import 'package:flutter/material.dart';
import 'package:hackathon/src/service/supabase_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hackathon/src/dto/test_dto.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseManager.initialize();

  print(await TestDto.testFunction(testId: 1));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Show something simple for now
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Template Project',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: Text('Template Project')),
        body: Center(child: Text('Welcome to the Template Project!')),
      ),
    );
  }
}
