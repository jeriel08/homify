import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/data/models/user_model.dart';

final userProvider = FutureProvider.family<UserModel, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  if (!doc.exists) {
    throw Exception('User not found');
  }
  return UserModel.fromSnapshot(doc);
});
