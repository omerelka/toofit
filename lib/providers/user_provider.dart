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
    print(
      '🔧 UserProvider constructor called',
    );
    _initializeUser();
  }

  // Initialize user data when provider is created
  void _initializeUser() {
    print('🔍 Initializing user...');

    try {
      FirebaseService.auth.authStateChanges().listen(
        (User? firebaseUser) async {
          print(
            '🔥 User auth state changed: ${firebaseUser?.uid ?? 'null'}',
          );

          if (firebaseUser != null) {
            print(
              '👤 Loading user data for: ${firebaseUser.uid}',
            );
            await loadUserData(
              firebaseUser.uid,
            );
          } else {
            print('🧹 Clearing user data');
            _clearUserData();
          }
        },
        onError: (error) {
          print(
            '❌ User auth state error: $error',
          );
          _errorMessage = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print(
        '❌ Error setting up user listener: $e',
      );
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user data from Firestore
  Future<void> loadUserData(
    String uid,
  ) async {
    try {
      print(
        '📊 Loading user data for: $uid',
      );

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get basic user data
      print('🔍 Fetching user document...');
      UserModel? user =
          await UserService.getUserById(uid);

      if (user != null) {
        print(
          '✅ User data loaded: ${user.firstName} ${user.lastName}, role: ${user.role}',
        );
        _currentUser = user;

        // Get role-specific data
        if (user.role == 'client') {
          print(
            '🏃‍♀️ Loading client data...',
          );
          _clientData =
              await UserService.getClientData(
                uid,
              );
          print(
            '✅ Client data loaded: ${_clientData != null ? 'success' : 'null'}',
          );
        } else if (user.role == 'trainer') {
          print(
            '💪 Loading trainer data...',
          );
          _trainerData =
              await UserService.getTrainerData(
                uid,
              );
          print(
            '✅ Trainer data loaded: ${_trainerData != null ? 'success' : 'null'}',
          );
        }
      } else {
        print(
          '❌ User document not found for: $uid',
        );
        _errorMessage =
            'User data not found';
      }

      _isLoading = false;
      print('🏁 User data loading complete');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user data: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    if (_currentUser == null) {
      print(
        '❌ Cannot update profile: no current user',
      );
      return false;
    }

    try {
      print(
        '📝 Updating user profile for: ${_currentUser!.uid}',
      );

      await UserService.updateUserProfile(
        _currentUser!.uid,
        data,
      );

      // Reload user data
      await loadUserData(_currentUser!.uid);
      print('✅ Profile update successful');
      return true;
    } catch (e) {
      print('❌ Profile update error: $e');
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
      print(
        '❌ Cannot update client data: invalid user or role',
      );
      return false;
    }

    try {
      print(
        '📝 Updating client data for: ${_currentUser!.uid}',
      );

      await UserService.updateClientData(
        _currentUser!.uid,
        data,
      );

      // Reload client data
      _clientData =
          await UserService.getClientData(
            _currentUser!.uid,
          );
      print(
        '✅ Client data update successful',
      );
      notifyListeners();
      return true;
    } catch (e) {
      print(
        '❌ Client data update error: $e',
      );
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear user data on logout
  void _clearUserData() {
    print('🧹 Clearing all user data');
    _currentUser = null;
    _clientData = null;
    _trainerData = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    print('🧹 Clearing error message');
    _errorMessage = null;
    notifyListeners();
  }

  // Get client's trainer data
  Future<Map<String, dynamic>?>
  getMyTrainer() async {
    if (_clientData == null ||
        _clientData!['trainerId'] == null) {
      print(
        '🔍 No trainer assigned to this client',
      );
      return null;
    }

    try {
      String trainerId =
          _clientData!['trainerId'];
      if (trainerId.isEmpty) {
        print('🔍 Trainer ID is empty');
        return null;
      }

      print(
        '🔍 Getting trainer data for: $trainerId',
      );
      return await UserService.getTrainerData(
        trainerId,
      );
    } catch (e) {
      print(
        '❌ Error getting trainer data: $e',
      );
      return null;
    }
  }

  // Check if client has a trainer assigned
  bool get hasTrainer {
    final result =
        _clientData != null &&
        _clientData!['trainerId'] != null &&
        _clientData!['trainerId']
            .toString()
            .isNotEmpty;
    print('🔍 Has trainer: $result');
    return result;
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
