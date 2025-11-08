import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homify/features/auth/data/models/user_model.dart';
import 'package:homify/core/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  /// Creates a new user with email/password and saves their data.
  ///
  /// Throws a [FirebaseAuthException] if auth fails.
  /// Throws a [FirebaseException] if Firestore save fails.
  Future<UserModel> registerUser(
    String email,
    String password,
    Map<String, dynamic> userData,
  );

  // You would also add:
  // Future<UserModel> loginUser(String email, String password);
  // Future<User?> getCurrentUser();
  // Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> registerUser(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    // 1. Create the user in Firebase Auth
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user == null) {
      throw Exception('User creation failed, but no exception was thrown.');
    }

    // 2. Build the UserModel
    // We use the new UID from auth and the data from the form
    final userModel = UserModel(
      uid: cred.user!.uid, // Use the auth UID
      accountType: AccountType.values.firstWhere(
        (e) => e.name == userData['account_type'],
        orElse: () => AccountType.tenant,
      ),
      firstName: userData['first_name'] as String,
      lastName: userData['last_name'] as String,
      birthday: userData['birthday'] as String,
      gender: userData['gender'] as String,
      mobile: userData['mobile'] as String,
      email: email,
      createdAt: DateTime.now(), // This will be replaced by server timestamp
    );

    // 3. Save the UserModel to Firestore
    await _firestore
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toFirestore()); // Use our new Model's method!

    // 4. Return the full user model
    return userModel;
  }
}
