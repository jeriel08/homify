import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/admin/domain/usecases/verify_property.dart';

final verifyPropertyProvider = Provider<VerifyProperty>((ref) {
  return VerifyProperty(FirebaseFirestore.instance);
});
