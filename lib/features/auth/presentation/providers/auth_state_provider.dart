import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/data/models/user_model.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final getCurrentUser = ref.watch(getCurrentUserUseCaseProvider);

  return FirebaseAuth.instance.authStateChanges().asyncMap((
    firebaseUser,
  ) async {
    if (firebaseUser == null) return null;

    try {
      final userEntity = await getCurrentUser();
      return userEntity != null ? UserModel.fromEntity(userEntity) : null;
    } catch (e) {
      // If Firestore data is missing, still return null
      return null;
    }
  });
});
