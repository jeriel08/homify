import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';

class VerifyProperty {
  final FirebaseFirestore firestore;

  VerifyProperty(this.firestore);

  Future<Either<Failure, Unit>> call(String propertyId, bool isApproved) async {
    try {
      await firestore.collection('properties').doc(propertyId).update({
        'is_verified': isApproved,
      });
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to update property'));
    }
  }
}
