import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/data/models/property_model.dart';

final pendingPropertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('properties')
      .where('is_verified', isEqualTo: false)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => PropertyModel.fromFirestore(doc))
            .toList(),
      );
});
