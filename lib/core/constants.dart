class Constants {
  // Reemplaza estos valores por los de tu proyecto de Supabase.
  // Nunca publiques una service_role key dentro de la aplicación móvil.
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  static bool get hasSupabaseCredentials =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('YOUR_PROJECT') &&
      supabaseAnonKey.length > 30 &&
      !supabaseAnonKey.contains('YOUR_ANON_KEY');

  static const String appName = 'Nexora';
  static const String appVersion = '1.3.0';
  static const String discordInvite = 'https://discord.gg/TU_INVITE';

  static const int maxVideoDurationMinutes = 24;
  static const int maxBioLength = 160;
  static const int maxUsernameLength = 30;

  static const String avatarsBucket = 'avatars';
  static const String postsBucket = 'posts';
  static const String videosBucket = 'videos';
}
