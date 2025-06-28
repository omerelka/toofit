import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Get user by UID
  static Future<UserModel?> getUserById(
    String uid,
  ) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
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
