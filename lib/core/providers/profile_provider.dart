import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

/// Perfil del usuario actual (incluye rol).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    required this.role,
    this.bio = '',
    this.avatarUrl,
    this.isBanned = false,
  });

  final String id;
  final String email;
  final String username;
  final String displayName;
  final String role; // 'user' | 'admin'
  final String bio;
  final String? avatarUrl;
  final bool isBanned;

  bool get isAdmin => role == 'admin' && !isBanned;
}

class AuthState {
  const AuthState({
    this.session,
    this.profile,
    this.loading = true,
    this.error,
  });

  final Session? session;
  final UserProfile? profile;
  final bool loading;
  final String? error;

  bool get isAuthenticated => session != null;
  bool get isAdmin => profile?.isAdmin == true;
  bool get isDemo => !Constants.hasSupabaseCredentials || session == null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  SupabaseClient? get _client {
    if (!Constants.hasSupabaseCredentials) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> _init() async {
    final client = _client;
    if (client == null) {
      state = const AuthState(loading: false);
      return;
    }

    client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session == null) {
        state = const AuthState(loading: false);
        return;
      }
      await _loadProfile(session);
    });

    final current = client.auth.currentSession;
    if (current != null) {
      await _loadProfile(current);
    } else {
      state = const AuthState(loading: false);
    }
  }

  Future<void> _loadProfile(Session session) async {
    state = AuthState(session: session, loading: true);
    final client = _client;
    if (client == null) {
      state = AuthState(session: session, loading: false);
      return;
    }

    try {
      final row = await client
          .from('profiles')
          .select('id, username, display_name, bio, avatar_url, role, is_banned')
          .eq('id', session.user.id)
          .maybeSingle();

      if (row == null) {
        state = AuthState(
          session: session,
          profile: UserProfile(
            id: session.user.id,
            email: session.user.email ?? '',
            username: 'user',
            displayName: session.user.userMetadata?['display_name'] as String? ??
                session.user.email?.split('@').first ??
                'Usuario',
            role: 'user',
          ),
          loading: false,
        );
        return;
      }

      final profile = UserProfile(
        id: row['id'] as String,
        email: session.user.email ?? '',
        username: row['username'] as String? ?? 'user',
        displayName: row['display_name'] as String? ?? 'Usuario',
        role: (row['role'] as String?) ?? 'user',
        bio: row['bio'] as String? ?? '',
        avatarUrl: row['avatar_url'] as String?,
        isBanned: row['is_banned'] as bool? ?? false,
      );

      state = AuthState(session: session, profile: profile, loading: false);
    } catch (e) {
      state = AuthState(
        session: session,
        loading: false,
        error: e.toString(),
        profile: UserProfile(
          id: session.user.id,
          email: session.user.email ?? '',
          username: 'user',
          displayName: session.user.email?.split('@').first ?? 'Usuario',
          role: 'user',
        ),
      );
    }
  }

  Future<void> refreshProfile() async {
    final session = state.session;
    if (session != null) await _loadProfile(session);
  }

  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
    state = const AuthState(loading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Solo true si el usuario tiene rol admin real en la base de datos.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});
