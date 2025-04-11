import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserModel?> getUserDetails() async {
  await Future.delayed(const Duration(milliseconds: 500));
  final currentUser = FirebaseAuth.instance.currentUser;
  print("Auth user: $currentUser");

  if (currentUser != null) {
    final doc = await FirebaseFirestore.instance
        .collection('employees')
        .doc(currentUser.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
  }
  return null;
}

class UserModel {
  final String name;
  final String degree;

  UserModel({
    required this.name,
    required this.degree,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final qualification = map['qualification'] as Map<String, dynamic>? ?? {};
    final ug = qualification['ug'] as Map<String, dynamic>? ?? {};
    final pg = qualification['pg'] as Map<String, dynamic>?;

    final ugDegree = ug['degree'] ?? '';
    final pgDegree = pg != null ? (pg['degree'] ?? '') : null;

    final firstName = map['firstName'] ?? '';
    final lastName = map['lastName'] ?? '';

    return UserModel(
      name: '$firstName $lastName'.trim(),
      degree: pgDegree?.isNotEmpty == true ? pgDegree! : ugDegree,
    );
  }
}

class UserSession {
  static UserModel? currentUser;

  static Future<void> initUser() async {
    currentUser ??= await getUserDetails();
  }

  static void clearUser() {
    currentUser = null;
  }
}
