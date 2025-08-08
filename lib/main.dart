import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
