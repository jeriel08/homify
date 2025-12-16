import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/properties/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.propertyId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.rating,
    required super.comment,
    required super.createdAt,
    super.likes,
    super.dislikes,
    super.reports,
  });

  factory ReviewModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      propertyId: data['propertyId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatar: data['userAvatar'],
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: List<String>.from(data['likes'] ?? []),
      dislikes: List<String>.from(data['dislikes'] ?? []),
      reports: List<String>.from(data['reports'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'dislikes': dislikes,
      'reports': reports,
    };
  }

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      propertyId: entity.propertyId,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
      likes: entity.likes,
      dislikes: entity.dislikes,
      reports: entity.reports,
    );
  }
}
