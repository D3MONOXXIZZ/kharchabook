/// Configuration constants for Supabase backend.
/// Replace placeholder values with your Supabase Project settings.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Check whether credentials have been configured
  static bool get isConfigured =>
      url != 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co' &&
      anonKey != 'YOUR_SUPABASE_ANON_KEY';
}
