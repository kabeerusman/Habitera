import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'habitera://login-callback',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> resendLink(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }

  // The client SDK can't delete its own auth user directly — that needs
  // elevated privileges. This assumes a `delete_user` Postgres function
  // (SECURITY DEFINER, deletes auth.users for the calling uid()) is set up
  // on the Supabase project, which is the standard pattern for self-serve
  // account deletion.
  Future<void> deleteAccount() async {
    await _supabase.rpc('delete_user');
    await _supabase.auth.signOut();
  }
}
