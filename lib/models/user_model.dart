import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.fcmToken = '',
  });

  String get fullName =>
      '$firstName $lastName';

  factory UserModel.fromFirestore(
    DocumentSnapshot doc,
  ) {
    Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      role: data['role'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      lastLoginAt: data['lastLoginAt']
          ?.toDate(),
      isActive: data['isActive'] ?? true,
      fcmToken: data['fcmToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'isActive': isActive,
      'fcmToken': fcmToken,
    };
  }
}
