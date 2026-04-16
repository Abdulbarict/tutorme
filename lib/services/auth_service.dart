import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

/// Wraps [FirebaseAuth] with clean, typed methods.
///
/// The provider is exposed as [authServiceProvider].
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  // ── Stream ────────────────────────────────────────────────────────────────

  /// Emits the current [User] on every auth state change.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Getters ───────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  // ── Email / Password ──────────────────────────────────────────────────────

  /// Sign in with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  /// Create a new account with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

  /// Send password-reset email.
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Update the display name of the currently signed-in user.
  Future<void> updateDisplayName(String name) =>
      _auth.currentUser!.updateDisplayName(name);

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() => _auth.signOut();

  // ── Re-authenticate ───────────────────────────────────────────────────────

  /// Re-authenticate before sensitive operations (e.g., password change).
  Future<UserCredential> reAuthenticate({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    return _auth.currentUser!.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(String newPassword) =>
      _auth.currentUser!.updatePassword(newPassword);

  // ── Error helpers ─────────────────────────────────────────────────────────

  /// Converts a [FirebaseAuthException] code into a user-friendly message.
  static String errorMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'email-already-in-use' => 'An account with this email already exists.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Password must be at least 6 characters.',
      'too-many-requests' =>
        'Too many attempts. Please wait and try again later.',
      'user-disabled' => 'This account has been disabled.',
      'network-request-failed' => 'Check your internet connection.',
      _ => e.message ?? 'An unexpected error occurred.',
    };
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
AuthService authService(Ref ref) =>
    AuthService(ref.watch(firebaseAuthProvider));

@riverpod
Stream<User?> authStateChanges(Ref ref) =>
    ref.watch(authServiceProvider).authStateChanges;
