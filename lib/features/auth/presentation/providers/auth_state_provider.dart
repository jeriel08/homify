import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/data/models/user_model.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);

  return FirebaseAuth.instance.authStateChanges().asyncMap((
    firebaseUser,
  ) async {
    if (firebaseUser == null) {
      debugPrint('AUTH STATE: No Firebase user → returning null');
      return null;
    }

    debugPrint('AUTH STATE: Firebase user changed: ${firebaseUser.uid}');

    // CRITICAL: Only return UserModel if Firestore data exists
    try {
      final userEntity = await getCurrentUser();

      debugPrint('AUTH STATE: Firestore user loaded: ${userEntity?.uid}');
      debugPrint('AUTH STATE: Account Type: ${userEntity?.accountType}');
      if (userEntity == null) return null;

      return UserModel.fromEntity(userEntity);
    } catch (e) {
      debugPrint('AUTH STATE: Firestore failed: $e');
      return null;
    }
  });
});
