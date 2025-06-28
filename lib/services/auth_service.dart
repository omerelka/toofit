import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth =
      FirebaseAuth.instance;
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Sign in with email and password
  static Future<UserCredential?>
  signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // Update last login time
      if (result.user != null) {
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .update({
              'lastLoginAt':
                  FieldValue.serverTimestamp(),
            });
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  static Future<UserCredential?>
  createUserWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String role, // 'client' or 'trainer'
  ) async {
    try {
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      if (result.user != null) {
        // Create user document in Firestore
        await _createUserDocument(
          result.user!.uid,
          email.trim(),
          firstName,
          lastName,
          role,
        );
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument(
    String uid,
    String email,
    String firstName,
    String lastName,
    String role,
  ) async {
    // Create user document
    await _firestore
        .collection('users')
        .doc(uid)
        .set({
          'uid': uid,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'createdAt':
              FieldValue.serverTimestamp(),
          'lastLoginAt':
              FieldValue.serverTimestamp(),
          'isActive': true,
          'fcmToken': '',
        });

    // Create role-specific document
    if (role == 'client') {
      await _firestore
          .collection('clients')
          .doc(uid)
          .set({
            'uid': uid,
            'trainerId':
                '', // To be assigned later
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
    } else if (role == 'trainer') {
      await _firestore
          .collection('trainers')
          .doc(uid)
          .set({
            'uid': uid,
            'businessName': '',
            'specializations': [],
            'experience': 0,
            'certifications': [],
            'bio': '',
            'clients': [],
            'workouts': [],
            'rating': 5.0,
            'totalClients': 0,
            'createdAt':
                FieldValue.serverTimestamp(),
          });
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  static Future<void> resetPassword(
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(
    FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'user-not-found':
        return 'לא נמצא משתמש עם כתובת האימייל הזו';
      case 'wrong-password':
        return 'סיסמה שגויה';
      case 'email-already-in-use':
        return 'כתובת האימייל כבר בשימוש';
      case 'weak-password':
        return 'הסיסמה חלשה מדי';
      case 'invalid-email':
        return 'כתובת אימייל לא תקינה';
      case 'too-many-requests':
        return 'יותר מדי ניסיונות התחברות. נסי שוב מאוחר יותר';
      default:
        return 'שגיאה: ${e.message}';
    }
  }
}
