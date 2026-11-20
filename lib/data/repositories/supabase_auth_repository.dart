import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Production authentication repository communicating with Supabase Auth & PostgreSQL.
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  @override
  Stream<UserProfile?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      return _fetchProfile(user.id, user.email ?? '');
    });
  }

  Future<UserProfile?> _fetchProfile(String uid, String email) async {
    try {
      final res = await _client.from('profiles').select().eq('id', uid).maybeSingle();
      if (res != null) {
        return UserProfile.fromJson(res);
      }
      return UserProfile(
        id: uid,
        name: email.split('@').first,
        email: email,
        updatedAt: DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id, user.email ?? '');
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = res.user;
    if (user == null) {
      throw Exception('Authentication failed');
    }
    final profile = await _fetchProfile(user.id, user.email ?? email);
    return profile ??
        UserProfile(
          id: user.id,
          name: email.split('@').first,
          email: email,
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
      emailRedirectTo: 'io.supabase.kharchabook://login-callback',
    );
    final user = res.user;
    if (user == null) {
      throw Exception('Registration failed');
    }

    // If session is null (due to Supabase email confirmation requirement),
    // attempt immediate login (leveraging database auto-confirm):
    if (res.session == null) {
      try {
        final loginRes = await _client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (loginRes.user != null) {
          final profile = await _fetchProfile(loginRes.user!.id, email);
          return profile ??
              UserProfile(
                id: loginRes.user!.id,
                name: name,
                email: email,
                updatedAt: DateTime.now(),
              );
        }
      } catch (_) {
        // If signInWithPassword still fails because confirmation is enforced:
        throw Exception(
          'Account created! Please check your email to confirm your account, or sign in with your credentials.',
        );
      }
    }

    final profile = await _fetchProfile(user.id, user.email ?? email);
    return profile ??
        UserProfile(
          id: user.id,
          name: name,
          email: email,
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserProfile> updateMonthlyBudget(double newBudget) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final res = await _client
        .from('profiles')
        .update({'monthly_budget': newBudget, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', user.id)
        .select()
        .single();

    return UserProfile.fromJson(res);
  }

  @override
  Future<UserProfile> updateProfile({required String name}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final res = await _client
        .from('profiles')
        .update({'name': name.trim(), 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', user.id)
        .select()
        .single();

    return UserProfile.fromJson(res);
  }
}
