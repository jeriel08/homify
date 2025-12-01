import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/properties/data/models/review_model.dart';
import 'package:homify/features/properties/domain/entities/review_entity.dart';
import 'package:homify/features/properties/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final FirebaseFirestore _firestore;

  ReviewsRepositoryImpl(this._firestore);

  @override
  Stream<List<ReviewEntity>> getReviews(String propertyId) {
    return _firestore
        .collection('reviews')
        .where('propertyId', isEqualTo: propertyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          // ignore: avoid_print
          print('Firestore Query Error: $error');
          throw error;
        })
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Future<void> addReview(ReviewEntity review) async {
    final model = ReviewModel.fromEntity(review);
    // Let Firestore generate ID if not provided or use provided ID
    if (review.id.isEmpty) {
      await _firestore.collection('reviews').add(model.toJson());
    } else {
      await _firestore.collection('reviews').doc(review.id).set(model.toJson());
    }
  }

  @override
  Future<void> updateReview(ReviewEntity review) async {
    final model = ReviewModel.fromEntity(review);
    await _firestore.collection('reviews').doc(review.id).update({
      'rating': model.rating,
      'comment': model.comment,
    });
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  @override
  Future<void> toggleLike(String reviewId, String userId) async {
    final docRef = _firestore.collection('reviews').doc(reviewId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      final dislikes = List<String>.from(data['dislikes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
        dislikes.remove(userId);
      }

      transaction.update(docRef, {'likes': likes, 'dislikes': dislikes});
    });
  }

  @override
  Future<void> toggleDislike(String reviewId, String userId) async {
    final docRef = _firestore.collection('reviews').doc(reviewId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      final dislikes = List<String>.from(data['dislikes'] ?? []);

      if (dislikes.contains(userId)) {
        dislikes.remove(userId);
      } else {
        dislikes.add(userId);
        likes.remove(userId);
      }

      transaction.update(docRef, {'likes': likes, 'dislikes': dislikes});
    });
  }

  @override
  Future<void> reportReview(String reviewId, String userId) async {
    final docRef = _firestore.collection('reviews').doc(reviewId);
    await docRef.update({
      'reports': FieldValue.arrayUnion([userId]),
    });
  }
}
