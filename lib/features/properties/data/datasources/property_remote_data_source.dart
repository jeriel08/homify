import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:homify/features/properties/data/models/property_model.dart';

abstract class PropertyRemoteDataSource {
  Future<PropertyModel> addProperty(
    PropertyModel propertyData,
    List<File> images,
  );
  Future<List<PropertyModel>> getVerifiedProperties();
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final FirebaseFirestore _firestore;
  // ADD CLOUDINARY
  final CloudinaryPublic _cloudinary;

  PropertyRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    CloudinaryPublic? cloudinary,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       // INITIALIZE CLOUDINARY
       _cloudinary =
           cloudinary ??
           CloudinaryPublic('dcjhugzvs', 'homify_unsigned', cache: false);

  @override
  Future<PropertyModel> addProperty(
    PropertyModel propertyData,
    List<File> images,
  ) async {
    try {
      final newDocRef = _firestore.collection('properties').doc();

      final tempProperty = propertyData.copyWith(
        id: newDocRef.id,
        imageUrls: [], // Start with empty images
      );

      await newDocRef.set(tempProperty.toFirestore());

      final imageUrls = await _uploadImages(images, propertyData.ownerUid);

      await newDocRef.update({
        'image_urls': imageUrls,
        'updated_at': FieldValue.serverTimestamp(), // Good to update this
      });

      return tempProperty.copyWith(imageUrls: imageUrls);
    } catch (e) {
      throw Exception('Failed to add property: ${e.toString()}');
    }
  }

  /// Helper function to upload images to Cloudinary
  Future<List<String>> _uploadImages(List<File> images, String ownerUid) async {
    try {
      // We create a list of futures to upload all images in parallel
      final uploadTasks = images.map((image) {
        return _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            image.path,
            resourceType: CloudinaryResourceType.Image,
            // Use a folder to keep it organized
            folder: 'properties/$ownerUid',
          ),
        );
      }).toList();

      // Wait for all uploads to complete
      final List<CloudinaryResponse> responses = await Future.wait(uploadTasks);

      // Collect the secure URLs
      return responses.map((res) => res.secureUrl).toList();
    } catch (e) {
      debugPrint('Cloudinary upload failed: $e');
      throw Exception('Image upload failed');
    }
  }

  @override
  Future<List<PropertyModel>> getVerifiedProperties() async {
    try {
      final snapshot = await _firestore
          .collection('properties')
          .where('is_verified', isEqualTo: true) // Filter handled by backend
          .get();

      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Server Failed');
    }
  }
}
