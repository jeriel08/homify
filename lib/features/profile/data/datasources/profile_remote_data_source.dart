import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/profile/data/models/user_profile_model.dart';

/// Remote data source for profile operations
abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Stream<UserProfileModel> getUserProfileStream(String userId);
  Future<void> updateProfile(String userId, Map<String, dynamic> updates);
  Future<void> banUser(String userId, String bannedBy, String reason);
  Future<void> unbanUser(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl({required this.firestore});

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return UserProfileModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Stream<UserProfileModel> getUserProfileStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw Exception('User not found');
          }
          return UserProfileModel.fromFirestore(doc);
        })
        .handleError((e) {
          throw Exception('Failed to stream user profile: $e');
        });
  }

  @override
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updated timestamp
      final updatesWithTimestamp = {
        ...updates,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('users')
          .doc(userId)
          .update(updatesWithTimestamp);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> banUser(String userId, String bannedBy, String reason) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'is_banned': true,
        'banned_at': FieldValue.serverTimestamp(),
        'banned_by': bannedBy,
        'ban_reason': reason,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to ban user: $e');
    }
  }

  @override
  Future<void> unbanUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'is_banned': false,
        'banned_at': null,
        'banned_by': null,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unban user: $e');
    }
  }
}
