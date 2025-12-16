import 'package:homify/features/properties/domain/entities/review_entity.dart';

abstract class ReviewsRepository {
  Stream<List<ReviewEntity>> getReviews(String propertyId);
  Future<void> addReview(ReviewEntity review);
  Future<void> updateReview(ReviewEntity review);
  Future<void> deleteReview(String reviewId);
  Future<void> toggleLike(String reviewId, String userId);
  Future<void> toggleDislike(String reviewId, String userId);
  Future<void> reportReview(String reviewId, String userId);
}
