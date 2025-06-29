import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _isAuthenticated;
  String? get errorMessage => _errorMessage;
  User? get currentFirebaseUser =>
      FirebaseService.currentUser;

  AuthProvider() {
    print(
      '🔧 AuthProvider constructor called',
    );
    _checkAuthState();
  }

  // Check initial authentication state
  void _checkAuthState() {
    print('🔍 Checking auth state...');

    try {
      FirebaseService.auth.authStateChanges().listen(
        (User? user) {
          print(
            '🔥 Auth state changed: user = ${user?.uid ?? 'null'}',
          );

          _isAuthenticated = user != null;
          _isLoading = false;

          print(
            '✅ Auth state updated: isAuthenticated=$_isAuthenticated, isLoading=$_isLoading',
          );
          notifyListeners();
        },
        onError: (error) {
          print(
            '❌ Auth state error: $error',
          );
          _isLoading = false;
          _errorMessage = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      print(
        '❌ Error setting up auth listener: $e',
      );
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print(
        '🔑 Attempting sign in for: $email',
      );

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserCredential? result =
          await AuthService.signInWithEmailAndPassword(
            email,
            password,
          );

      if (result != null) {
        print(
          '✅ Sign in successful for: ${result.user?.email}',
        );
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      print('❌ Sign in failed: no result');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Sign in error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up with email and password
  Future<bool>
  createUserWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String role,
  ) async {
    try {
      print(
        '📝 Attempting sign up for: $email, role: $role',
      );

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserCredential? result =
          await AuthService.createUserWithEmailAndPassword(
            email,
            password,
            firstName,
            lastName,
            role,
          );

      if (result != null) {
        print(
          '✅ Sign up successful for: ${result.user?.email}',
        );
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      print('❌ Sign up failed: no result');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Sign up error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🚪 Signing out...');
      await AuthService.signOut();
      _isAuthenticated = false;
      print('✅ Sign out successful');
      notifyListeners();
    } catch (e) {
      print('❌ Sign out error: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(
    String email,
  ) async {
    try {
      print(
        '🔄 Resetting password for: $email',
      );
      _errorMessage = null;
      await AuthService.resetPassword(email);
      print('✅ Password reset email sent');
      return true;
    } catch (e) {
      print('❌ Password reset error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    print('🧹 Clearing error message');
    _errorMessage = null;
    notifyListeners();
  }
}
