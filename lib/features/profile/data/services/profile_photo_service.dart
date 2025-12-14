import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Service for uploading and managing profile photos
class ProfilePhotoService {
  final CloudinaryPublic _cloudinary;
  final FirebaseFirestore _firestore;

  ProfilePhotoService({
    CloudinaryPublic? cloudinary,
    FirebaseFirestore? firestore,
  }) : _cloudinary =
           cloudinary ??
           CloudinaryPublic('dcjhugzvs', 'homify_unsigned', cache: false),
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// Upload a profile photo to Cloudinary and update Firestore
  /// Returns the secure URL of the uploaded image
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      // 1. Upload to Cloudinary
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'profile_photos/$userId',
        ),
      );

      final photoUrl = response.secureUrl;
      debugPrint('Profile photo uploaded: $photoUrl');

      // 2. Update Firestore with the new photo URL
      await _firestore.collection('users').doc(userId).update({
        'photo_url': photoUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return photoUrl;
    } catch (e) {
      debugPrint('Profile photo upload failed: $e');
      throw Exception('Failed to upload profile photo: $e');
    }
  }
}
