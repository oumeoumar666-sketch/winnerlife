import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  AuthService() {
    _supabase.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Supabase sign in error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Supabase sign up error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      return await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.winnerlife://login-callback/',
      );
    } catch (e) {
      debugPrint('Supabase Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
