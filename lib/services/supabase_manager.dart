import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseManager {
  static Future<void> initialize() async {
    try {
      // Load .env if present. If the asset or file is missing, ignore.
      await dotenv.load(fileName: ".env");
    } catch (_) {
      // ignore: avoid_print
      print('dotenv: .env not found, skipping Supabase init');
    }

    final String? supabaseUrl = dotenv.env['SUPABASE_URL'];
    final String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null ||
        supabaseAnonKey == null ||
        supabaseUrl.isEmpty ||
        supabaseAnonKey.isEmpty) {
      // ignore: avoid_print
      print('Supabase env not configured, skipping Supabase.initialize');
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
