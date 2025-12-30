// lib/features/auth/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await _googleSignIn.initialize();

      // Listen for sign-in events
      _googleSignIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: (error) {
          debugPrint('Auth error: $error');
          _error = error.toString();
          notifyListeners();
        },
      );

      // Attempt lightweight authentication
      await _googleSignIn.attemptLightweightAuthentication();

      // Load saved user data
      await _loadSavedUser();
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    }
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        _setUser(user);
        break;
      case GoogleSignInAuthenticationEventSignOut():
        _clearUser();
        break;
    }
  }

  Future<void> _setUser(GoogleSignInAccount account) async {
    _user = UserModel(
      id: account.id,
      email: account.email,
      name: account.displayName,
      photoUrl: account.photoUrl,
    );

    await _saveUser(_user!);
    _error = null;
    notifyListeners();
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    if (user.name != null) {
      await prefs.setString('user_name', user.name!);
    }
    if (user.photoUrl != null) {
      await prefs.setString('user_photo_url', user.photoUrl!);
    }
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final userEmail = prefs.getString('user_email');

    if (userId != null && userEmail != null) {
      _user = UserModel(
        id: userId,
        email: userEmail,
        name: prefs.getString('user_name'),
        photoUrl: prefs.getString('user_photo_url'),
      );
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _googleSignIn.authenticate();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Sign in failed: $e';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _clearUser();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<void> _clearUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}