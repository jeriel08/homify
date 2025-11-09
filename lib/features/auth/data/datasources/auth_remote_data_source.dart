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

  Future<UserModel> loginUser(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
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

  @override
  Future<UserModel> loginUser(String email, String password) async {
    // 1. Sign in the user
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user == null) {
      throw Exception('Login failed.');
    }

    // 2. Get their data from Firestore
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .get();
      if (!userDoc.exists) {
        throw Exception('User data not found in Firestore.');
      }
      // 3. Convert to UserModel using our newly renamed method
      return UserModel.fromSnapshot(userDoc);
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // 1. Get the current auth user
    final authUser = _auth.currentUser;

    // 2. If no one is logged in, return null
    if (authUser == null) {
      return null;
    }

    // 3. If they are logged in, get their details from Firestore
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(authUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found in Firestore.');
      }

      // 4. Convert Firestore data to a UserModel and return it
      return UserModel.fromSnapshot(userDoc);
    } catch (e) {
      // Handle error (e.g., user exists in Auth but not in Firestore)
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
