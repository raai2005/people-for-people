import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required BaseUser userDetails,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) throw Exception('User creation failed');

      // Create a map from user details, but overwrite/ensure ID matches Auth ID
      Map<String, dynamic> userData;
      if (userDetails is NGOUser) {
        userData = userDetails.toMap();
      } else if (userDetails is DonorUser) {
        userData = userDetails.toMap();
      } else if (userDetails is VolunteerUser) {
        userData = userDetails.toMap();
      } else {
        throw Exception('Unknown user role');
      }

      // Ensure the ID in Firestore matches the Auth UID
      userData['id'] = user.uid;

      // Save user details to Firestore
      await _firestore.collection('users').doc(user.uid).set(userData);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during sign up');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign In
  Future<BaseUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) throw Exception('Sign in failed');

      // Fetch user details from Firestore
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String role = data['role'] ?? '';

      switch (role) {
        case 'ngo':
          return NGOUser.fromMap(data);
        case 'donor':
          return DonorUser.fromMap(data);
        case 'volunteer':
          return VolunteerUser.fromMap(data);
        default:
          throw Exception('Unknown user role found in profile');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during sign in');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Profile
  Future<BaseUser?> getUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String role = data['role'] ?? '';

        switch (role) {
          case 'ngo':
            return NGOUser.fromMap(data);
          case 'donor':
            return DonorUser.fromMap(data);
          case 'volunteer':
            return VolunteerUser.fromMap(data);
        }
      }
    }
    return null;
  }
}
