import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_models.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class AuthService {
  // Use getters to avoid immediate crash if Firebase isn't initialized
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Get current user
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Stream of auth changes
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      return const Stream.empty();
    }
  }

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
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Get User Profile
  Future<BaseUser?> getUserProfile() async {
    try {
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
    } catch (e) {
      debugPrint(
        'Error fetching user profile (firebase might be down/unconfigured): $e',
      );
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during password reset');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update User Profile
  Future<void> updateUserProfile(BaseUser user) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      // Ensure we're updating the correct user
      if (currentUser.uid != user.id) {
        throw Exception('User ID mismatch');
      }

      Map<String, dynamic> userData;
      if (user is NGOUser) {
        userData = user.toMap();
      } else if (user is DonorUser) {
        userData = user.toMap();
      } else if (user is VolunteerUser) {
        userData = user.toMap();
      } else {
        throw Exception('Unknown user type');
      }

      // Update in Firestore
      await _firestore.collection('users').doc(user.id).update(userData);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'An error occurred during profile update');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update specific fields (partial update)
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      if (currentUser.uid != userId) {
        throw Exception('User ID mismatch');
      }

      await _firestore.collection('users').doc(userId).update(fields);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'An error occurred during profile update');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
