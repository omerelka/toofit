import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Get user by UID with fallback creation
  static Future<UserModel?> getUserById(
    String uid,
  ) async {
    try {
      print(
        '🔍 Fetching user document for: $uid',
      );

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        print('✅ User document found');
        return UserModel.fromFirestore(doc);
      } else {
        print(
          '⚠️ User document not found, creating fallback user...',
        );

        // Get the current Firebase user info
        User? firebaseUser = FirebaseAuth
            .instance
            .currentUser;
        if (firebaseUser != null) {
          return await _createFallbackUser(
            firebaseUser,
          );
        } else {
          print(
            '❌ No Firebase user found to create fallback',
          );
          return null;
        }
      }
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  // Create a fallback user document when one doesn't exist
  static Future<UserModel?>
  _createFallbackUser(
    User firebaseUser,
  ) async {
    try {
      print(
        '🔧 Creating fallback user document for: ${firebaseUser.uid}',
      );

      // Extract name from email or use defaults
      String email =
          firebaseUser.email ?? '';
      String firstName = 'משתמש';
      String lastName = 'חדש';

      // Try to extract name from email
      if (email.isNotEmpty) {
        String localPart = email.split(
          '@',
        )[0];
        if (localPart.contains('.')) {
          List<String> nameParts = localPart
              .split('.');
          firstName = _capitalize(
            nameParts[0],
          );
          if (nameParts.length > 1) {
            lastName = _capitalize(
              nameParts[1],
            );
          }
        } else {
          firstName = _capitalize(localPart);
        }
      }

      // Create user document with default role 'client'
      Map<String, dynamic> userData = {
        'uid': firebaseUser.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role':
            'client', // Default to client
        'createdAt':
            FieldValue.serverTimestamp(),
        'lastLoginAt':
            FieldValue.serverTimestamp(),
        'isActive': true,
        'fcmToken': '',
      };

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userData);

      // Create client document as well
      await _createDefaultClientData(
        firebaseUser.uid,
      );

      print(
        '✅ Fallback user created successfully',
      );

      // Return the created user
      return UserModel(
        uid: firebaseUser.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: 'client',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
        fcmToken: '',
      );
    } catch (e) {
      print(
        '❌ Error creating fallback user: $e',
      );
      return null;
    }
  }

  // Create default client data
  static Future<void>
  _createDefaultClientData(
    String uid,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(uid)
          .set({
            'uid': uid,
            'trainerId': '',
            'age': 0,
            'height': 0,
            'weight': 0,
            'fitnessLevel': 'beginner',
            'goals': [],
            'medicalConditions': [],
            'assignedWorkouts': [],
            'completedWorkouts': 0,
            'totalWorkoutTime': 0,
            'currentStreak': 0,
            'lastWorkout': null,
            'joinedAt':
                FieldValue.serverTimestamp(),
          });
      print('✅ Default client data created');
    } catch (e) {
      print(
        '❌ Error creating client data: $e',
      );
    }
  }

  // Helper to capitalize first letter
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() +
        text.substring(1).toLowerCase();
  }

  // Get client data
  static Future<Map<String, dynamic>?>
  getClientData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('clients')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data()
            as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting client data: $e');
      return null;
    }
  }

  // Get trainer data
  static Future<Map<String, dynamic>?>
  getTrainerData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('trainers')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data()
            as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print(
        'Error getting trainer data: $e',
      );
      return null;
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update(data);
    } catch (e) {
      print(
        'Error updating user profile: $e',
      );
      rethrow;
    }
  }

  // Update client data
  static Future<void> updateClientData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('clients')
          .doc(uid)
          .update(data);
    } catch (e) {
      print(
        'Error updating client data: $e',
      );
      rethrow;
    }
  }
}
