class Constants {
  // ============================================================
  // SUPABASE - Reemplaza estos valores con los de tu proyecto
  // ============================================================
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  // ============================================================
  // APP
  // ============================================================
  static const String appName = 'Nexora';
  static const String appVersion = '1.0.0';
  static const String discordInvite = 'https://discord.gg/TU_INVITE'; // Cambiar

  // Límites
  static const int maxVideoDurationMinutes = 24;
  static const int maxBioLength = 160;
  static const int maxUsernameLength = 30;

  // Storage buckets
  static const String avatarsBucket = 'avatars';
  static const String postsBucket = 'posts';
  static const String videosBucket = 'videos';
}
