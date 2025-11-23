import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homify/features/auth/data/models/user_model.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<UserModel> signInWithGoogle();
  Future<UserModel> loginUser(String email, String password);
  Future<UserModel?> getCurrentUser();
  Future<UserModel> getUser(String uid);
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

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

    if (cred.user == null) throw Exception('User creation failed');

    await cred.user!.sendEmailVerification();

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
      createdAt: DateTime.now(),
      onboardingComplete: false,
      emailVerified: false,
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
  Future<UserModel> getUser(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      throw Exception('User not found');
    }
    return UserModel.fromSnapshot(userDoc);
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
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        clientId:
            "915621689789-g8j7kpre8ldjdbs4c4a2mmqevdncci1c.apps.googleusercontent.com",
      );

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;

      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);

      final accessToken = authorization?.accessToken;

      // 3. Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // 4. Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw Exception('Sign-in failed, but no exception was thrown.');
      }

      final user = userCredential.user!;
      final additionalInfo = userCredential.additionalUserInfo;

      // 5. Check if this is a new user
      if (additionalInfo?.isNewUser == true) {
        // --- This is a NEW user ---
        // Create the UserModel
        final userModel = UserModel(
          uid: user.uid,
          // Extract data from Google profile
          firstName: user.displayName?.split(' ').first ?? '',
          lastName: user.displayName?.split(' ').last ?? '',
          email: user.email!,
          // Set sensible defaults for new Google users
          accountType: AccountType.tenant, // Default to tenant
          birthday: '', // User must fill this in later
          gender: '', // User must fill this in later
          mobile: user.phoneNumber ?? '', // May be null
          createdAt: DateTime.now(),
          onboardingComplete: false,
          emailVerified: user.emailVerified,
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(userModel.uid)
            .set(userModel.toFirestore());

        return userModel;
      } else {
        // --- This is a RETURNING user ---
        // Get their existing data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          // This is a rare edge case: they exist in Auth but not Firestore
          throw Exception('User data not found in Firestore.');
        }
        return UserModel.fromSnapshot(userDoc);
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific auth errors (like 'account-exists-with-different-credential')
      throw Exception('Auth Error: ${e.message}');
    } on GoogleSignInException catch (e) {
      if (e.code.toString() == "GoogleSignInExceptionCode.canceled") {
        throw Exception('Google sign-in was cancelled.');
      } else {
        throw Exception('Google Sign-In Error: $e');
      }
    } catch (e) {
      // Handle other errors (like cancelling the sign-in)
      throw Exception(e.toString());
    }
  }
}
