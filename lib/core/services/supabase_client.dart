import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  SupabaseClientService._();

  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    final normalizedSupabaseUrl = supabaseUrl.trim();
    final normalizedSupabaseAnonKey = supabaseAnonKey.trim();

    if (normalizedSupabaseUrl.isEmpty || normalizedSupabaseAnonKey.isEmpty) {
      throw Exception(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file.',
      );
    }

    await Supabase.initialize(
      url: normalizedSupabaseUrl,
      anonKey: normalizedSupabaseAnonKey,
    );
  }

  static SupabaseClient get instance => Supabase.instance.client;
}
