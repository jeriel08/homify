import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:homify/features/properties/data/models/property_model.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';

abstract class PropertyRemoteDataSource {
  Future<PropertyModel> addProperty(
    PropertyModel propertyData,
    List<File> images,
  );
  Future<List<PropertyModel>> getVerifiedProperties();
  Future<List<PropertyModel>> getPropertiesByOwner(String ownerUid);
  Future<PropertyModel> getPropertyById(String id);
  Future<PropertyModel> updateProperty(
    String propertyId,
    Map<String, dynamic> updates,
  );

  /// Upload images to Cloudinary
  Future<List<String>> uploadImages(List<File> images, String ownerUid);

  /// Delete property and archive it
  Future<void> deleteProperty(String propertyId, String reason);

  /// Search properties
  Future<List<PropertyModel>> searchProperties({
    String? query,
    PropertyType? type,
  });
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
        favoritesCount: 0,
      );

      await newDocRef.set(tempProperty.toFirestore());

      final imageUrls = await uploadImages(images, propertyData.ownerUid);

      await newDocRef.update({
        'image_urls': imageUrls,
        'updated_at': FieldValue.serverTimestamp(), // Good to update this
      });

      return tempProperty.copyWith(imageUrls: imageUrls);
    } catch (e) {
      throw Exception('Failed to add property: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> uploadImages(List<File> images, String ownerUid) async {
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

  @override
  Future<List<PropertyModel>> getPropertiesByOwner(String ownerUid) async {
    try {
      final snapshot = await _firestore
          .collection('properties')
          .where('owner_uid', isEqualTo: ownerUid)
          .orderBy('created_at', descending: true) // Show newest first
          .get();

      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch owner properties: $e');
    }
  }

  @override
  Future<PropertyModel> getPropertyById(String id) async {
    try {
      final doc = await _firestore.collection('properties').doc(id).get();

      if (!doc.exists) {
        throw Exception('Property not found');
      }

      return PropertyModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch property: $e');
    }
  }

  @override
  Future<PropertyModel> updateProperty(
    String propertyId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Update the document in Firestore
      await _firestore.collection('properties').doc(propertyId).update({
        ...updates,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Fetch and return the updated property
      final doc = await _firestore
          .collection('properties')
          .doc(propertyId)
          .get();

      if (!doc.exists) {
        throw Exception('Property not found after update');
      }

      return PropertyModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  @override
  Future<void> deleteProperty(String propertyId, String reason) async {
    try {
      final docRef = _firestore.collection('properties').doc(propertyId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Property not found');
      }

      final data = docSnapshot.data()!;

      // Create a batch for atomicity
      final batch = _firestore.batch();

      // 1. Add to deleted_properties collection
      final deletedRef = _firestore
          .collection('deleted_properties')
          .doc(propertyId);
      batch.set(deletedRef, {
        ...data,
        'deletion_reason': reason,
        'deleted_at': FieldValue.serverTimestamp(),
      });

      // 2. Delete from properties collection
      batch.delete(docRef);

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  @override
  Future<List<PropertyModel>> searchProperties({
    String? query,
    PropertyType? type,
  }) async {
    try {
      // 1. Base query: Get all verified properties
      // Note: For a larger app, we'd use Algolia/Elasticsearch or more complex Firestore queries
      // But for now, client-side filtering of verified properties is acceptable
      Query queryRef = _firestore
          .collection('properties')
          .where('is_verified', isEqualTo: true);

      // 2. If filtering by type ONLY (no text query), we can do it on the server
      // However, if we have a text query, we'll fetch all and filter in Dart
      // to avoid composite index issues for every combination
      if (type != null && (query == null || query.isEmpty)) {
        queryRef = queryRef.where('type', isEqualTo: type.name);
      }

      final snapshot = await queryRef.get();
      var properties = snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();

      // 3. Client-side filtering
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        properties = properties.where((p) {
          final matchesName = p.name.toLowerCase().contains(lowerQuery);
          final matchesDesc = p.description.toLowerCase().contains(lowerQuery);
          final matchesType = type != null ? p.type == type : true;
          return (matchesName || matchesDesc) && matchesType;
        }).toList();
      } else if (type != null) {
        // If we didn't filter by type on server (e.g. if we decided to fetch all), do it here
        // But the server query above handles the type-only case.
        // This block is just a fallback or for consistency if logic changes.
        // Currently, if query is empty, we already filtered by type on server.
      }

      return properties;
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
}
