import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';

class VerifyProperty {
  final FirebaseFirestore firestore;

  VerifyProperty(this.firestore);

  Future<Either<Failure, Unit>> call(
    String propertyId,
    bool isApproved, {
    String? rejectionReason,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'is_verified': isApproved,
        'status': isApproved ? 'approved' : 'rejected',
      };

      if (!isApproved && rejectionReason != null) {
        updateData['rejection_reason'] = rejectionReason;
      } else if (isApproved) {
        // Clear rejection reason when approving
        updateData['rejection_reason'] = FieldValue.delete();
      }

      await firestore
          .collection('properties')
          .doc(propertyId)
          .update(updateData);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to update property'));
    }
  }
}
