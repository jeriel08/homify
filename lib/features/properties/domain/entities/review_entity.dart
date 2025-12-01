import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> likes;
  final List<String> dislikes;
  final List<String> reports;

  const ReviewEntity({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.likes = const [],
    this.dislikes = const [],
    this.reports = const [],
  });

  ReviewEntity copyWith({
    String? id,
    String? propertyId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? likes,
    List<String>? dislikes,
    List<String>? reports,
  }) {
    return ReviewEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      reports: reports ?? this.reports,
    );
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    userId,
    userName,
    userAvatar,
    rating,
    comment,
    createdAt,
    likes,
    dislikes,
    reports,
  ];
}
