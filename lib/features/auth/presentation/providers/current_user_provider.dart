import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/data/models/user_model.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';

// This provider listens to the FIRESTORE document of the currently logged-in user
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) {
    return Stream.value(null);
  }

  // Listen to the 'users' collection for the specific UID
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return null;
        return UserModel.fromSnapshot(snapshot);
      });
});
