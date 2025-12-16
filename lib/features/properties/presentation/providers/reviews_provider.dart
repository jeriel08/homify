import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/data/repositories/reviews_repository_impl.dart';
import 'package:homify/features/properties/domain/entities/review_entity.dart';
import 'package:homify/features/properties/domain/repositories/reviews_repository.dart';
import 'package:uuid/uuid.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepositoryImpl(FirebaseFirestore.instance);
});

final reviewsProvider = StreamProvider.family<List<ReviewEntity>, String>((
  ref,
  propertyId,
) {
  final repository = ref.watch(reviewsRepositoryProvider);
  return repository.getReviews(propertyId);
});

class ReviewsController extends AsyncNotifier<void> {
  late final ReviewsRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(reviewsRepositoryProvider);
  }

  Future<void> addReview(
    String propertyId,
    double rating,
    String comment,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final review = ReviewEntity(
        id: const Uuid().v4(),
        propertyId: propertyId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        userAvatar: user.photoURL,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await _repository.addReview(review);
    });
  }

  Future<void> editReview(
    String reviewId,
    double rating,
    String comment,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final review = ReviewEntity(
        id: reviewId,
        propertyId: '', // Not needed for update
        userId: user.uid,
        userName: '',
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await _repository.updateReview(review);
    });
  }

  Future<void> deleteReview(String reviewId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteReview(reviewId);
    });
  }

  Future<void> toggleLike(String reviewId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Optimistic update or just fire and forget?
    // Since we stream reviews, the UI will update when Firestore updates.
    // We don't necessarily need to set state to loading for likes/dislikes to avoid flickering.
    await _repository.toggleLike(reviewId, user.uid);
  }

  Future<void> toggleDislike(String reviewId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _repository.toggleDislike(reviewId, user.uid);
  }

  Future<void> reportReview(String reviewId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _repository.reportReview(reviewId, user.uid);
  }
}

final reviewsControllerProvider =
    AsyncNotifierProvider<ReviewsController, void>(() {
      return ReviewsController();
    });
