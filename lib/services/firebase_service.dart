import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth get auth =>
      FirebaseAuth.instance;
  static FirebaseFirestore get firestore =>
      FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Get current user
  static User? get currentUser =>
      auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn =>
      currentUser != null;
}
