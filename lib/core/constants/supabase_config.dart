/// Supabase connection configuration.
///
/// Fill these in with your project's values (Project Settings -> API).
/// They are read at startup by [SupabaseService.initialize].
///
/// IMPORTANT: The anon key is safe to ship in client apps because Row Level
/// Security on the database protects the data. Never put the service_role key here.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://onzzsijynoprwqemadjv.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uenpzaWp5bm9wcndxZW1hZGp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM1ODIyODQsImV4cCI6MjA5OTE1ODI4NH0.sYgq5KAH4GOy5gMENa_vIvXuhRfu998TCJadxPXDT4E',
  );

  /// Optional explicit REST endpoint (defaults to `<url>/rest/v1`).
  static const String restUrl = String.fromEnvironment(
    'SUPABASE_REST_URL',
    defaultValue: 'https://onzzsijynoprwqemadjv.supabase.co/rest/v1/',
  );

  /// Convenience for manual setup without build-time env vars.
  static const bool isConfigured =
      url != 'https://YOUR-PROJECT-REF.supabase.co' &&
      anonKey != 'YOUR-SUPABASE-ANON-KEY';
}
