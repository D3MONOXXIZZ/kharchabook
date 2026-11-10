/// Configuration constants for Supabase backend.
/// Replace placeholder values with your Supabase Project settings.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://lhfbbuxtuytxtykmkfbw.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoZmJidXh0dXl0eHR5a21rZmJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyOTQwOTIsImV4cCI6MjEwOTg3MDA5Mn0.t24PER3oW2443Q8YtlpMHi-fUTn5kO0eLAWXZO-U0LA';

  /// Check whether credentials have been configured
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      !url.contains('YOUR_SUPABASE_PROJECT_ID') &&
      !anonKey.contains('YOUR_SUPABASE_ANON_KEY');
}
