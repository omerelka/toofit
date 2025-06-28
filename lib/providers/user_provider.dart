import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/firebase_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  Map<String, dynamic>? _clientData;
  Map<String, dynamic>? _trainerData;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  Map<String, dynamic>? get clientData =>
      _clientData;
  Map<String, dynamic>? get trainerData =>
      _trainerData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProvider() {
    _initializeUser();
  }

  // Initialize user data when provider is created
  void _initializeUser() {
    FirebaseService.auth
        .authStateChanges()
        .listen((User? firebaseUser) async {
          if (firebaseUser != null) {
            await loadUserData(
              firebaseUser.uid,
            );
          } else {
            _clearUserData();
          }
        });
  }

  // Load user data from Firestore
  Future<void> loadUserData(
    String uid,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get basic user data
      UserModel? user =
          await UserService.getUserById(uid);
      if (user != null) {
        _currentUser = user;

        // Get role-specific data
        if (user.role == 'client') {
          _clientData =
              await UserService.getClientData(
                uid,
              );
        } else if (user.role == 'trainer') {
          _trainerData =
              await UserService.getTrainerData(
                uid,
              );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    if (_currentUser == null) return false;

    try {
      await UserService.updateUserProfile(
        _currentUser!.uid,
        data,
      );

      // Reload user data
      await loadUserData(_currentUser!.uid);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update client-specific data
  Future<bool> updateClientData(
    Map<String, dynamic> data,
  ) async {
    if (_currentUser == null ||
        _currentUser!.role != 'client') {
      return false;
    }

    try {
      await UserService.updateClientData(
        _currentUser!.uid,
        data,
      );

      // Reload client data
      _clientData =
          await UserService.getClientData(
            _currentUser!.uid,
          );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear user data on logout
  void _clearUserData() {
    _currentUser = null;
    _clientData = null;
    _trainerData = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get client's trainer data
  Future<Map<String, dynamic>?>
  getMyTrainer() async {
    if (_clientData == null ||
        _clientData!['trainerId'] == null) {
      return null;
    }

    try {
      String trainerId =
          _clientData!['trainerId'];
      if (trainerId.isEmpty) return null;

      return await UserService.getTrainerData(
        trainerId,
      );
    } catch (e) {
      print(
        'Error getting trainer data: $e',
      );
      return null;
    }
  }

  // Check if client has a trainer assigned
  bool get hasTrainer {
    return _clientData != null &&
        _clientData!['trainerId'] != null &&
        _clientData!['trainerId']
            .toString()
            .isNotEmpty;
  }

  // Get client's fitness goals
  List<String> get fitnessGoals {
    if (_clientData == null ||
        _clientData!['goals'] == null) {
      return [];
    }
    return List<String>.from(
      _clientData!['goals'],
    );
  }

  // Get client's current streak
  int get currentStreak {
    if (_clientData == null) return 0;
    return _clientData!['currentStreak'] ??
        0;
  }

  // Get completed workouts count
  int get completedWorkouts {
    if (_clientData == null) return 0;
    return _clientData!['completedWorkouts'] ??
        0;
  }

  // Get total workout time
  int get totalWorkoutTime {
    if (_clientData == null) return 0;
    return _clientData!['totalWorkoutTime'] ??
        0;
  }
}
