import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'login_type.dart';

class UserService {
  final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String dummyJsonBaseUrl =
      'https://dummyjson.com';

  // =========================
  // FIREBASE AUTHENTICATION
  // =========================

  Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _saveFirebaseUserData(
          credential.user!,
        );

        await _saveFirebaseProfileToFirestore(
          credential.user!,
        );
      }

      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  Future<firebase_auth.UserCredential> createAccount({
    required String email,
    required String password,
    String? username,
    String? firstName,
    String? lastName,
    int? age,
    String? contactNo,
  }) async {
    try {
      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null &&
          username != null &&
          username.trim().isNotEmpty) {
        await user.updateDisplayName(
          username.trim(),
        );

        await user.reload();
      }

      final updatedUser =
          _auth.currentUser;

      if (updatedUser != null) {
        await _saveFirebaseUserData(
          updatedUser,
        );

        final prefs =
            await SharedPreferences.getInstance();

        if (firstName != null) {
          await prefs.setString(
            'firstName',
            firstName.trim(),
          );
        }

        if (lastName != null) {
          await prefs.setString(
            'lastName',
            lastName.trim(),
          );
        }

        if (age != null) {
          await prefs.setInt(
            'age',
            age,
          );
        }

        if (contactNo != null) {
          await prefs.setString(
            'contactNo',
            contactNo.trim(),
          );
        }

        await _saveFirebaseProfileToFirestore(
          updatedUser,
        );
      }

      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to save profile data: ${e.message}',
      );
    }
  }

  // =========================
  // FIREBASE PASSWORD RESET
  // =========================

  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  // =========================
  // DUMMYJSON AUTHENTICATION
  // =========================

  Future<User> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$dummyJsonBaseUrl/auth/login',
        ),
        headers: {
          'Content-Type':
              'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 30,
        }),
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          data['message']?.toString() ??
              'Invalid username or password.',
        );
      }

      final user =
          User.fromJson(data);

      await _saveDummyJsonUserData(
        user,
        data,
      );

      return user;
    } on http.ClientException {
      throw Exception(
        'Unable to connect to DummyJSON.',
      );
    } on FormatException {
      throw Exception(
        'Invalid response from DummyJSON.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Unable to sign in with DummyJSON.',
      );
    }
  }

  // =========================
  // SESSION MANAGEMENT
  // =========================

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Continue clearing the local session.
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('isLoggedIn');
    await prefs.remove('loginType');

    await prefs.remove('firebaseUid');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('displayName');

    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('age');
    await prefs.remove('contactNo');
    await prefs.remove('gender');
    await prefs.remove('image');

    await prefs.remove('userId');
    await prefs.remove('dummyJsonAccessToken');
    await prefs.remove('dummyJsonRefreshToken');
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<bool> isLoggedIn() async {
    final loginType =
        await getLoginType();

    if (loginType == LoginType.firebase) {
      return _auth.currentUser != null;
    }

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          'isLoggedIn',
        ) ??
        false;
  }

  // =========================
  // LOGIN TYPE
  // =========================

  Future<LoginType> getLoginType() async {
    final prefs =
        await SharedPreferences.getInstance();

    final value =
        prefs.getString('loginType');

    switch (value) {
      case 'dummyJson':
        return LoginType.dummyJson;

      case 'guest':
        return LoginType.guest;

      case 'firebase':
      default:
        return LoginType.firebase;
    }
  }

  // =========================
  // PROFILE FUNCTIONS
  // =========================

  Future<User?> getUserData() async {
    final loginType =
        await getLoginType();

    final prefs =
        await SharedPreferences.getInstance();

    // =========================
    // FIREBASE PROFILE
    // =========================

    if (loginType == LoginType.firebase) {
      final firebaseUser =
          _auth.currentUser;

      if (firebaseUser != null) {
        return User(
          id: 0,
          username:
              firebaseUser.displayName ??
                  prefs.getString(
                    'username',
                  ) ??
                  '',
          email:
              firebaseUser.email ??
                  prefs.getString(
                    'email',
                  ) ??
                  '',
          firstName:
              prefs.getString(
                    'firstName',
                  ) ??
                  '',
          lastName:
              prefs.getString(
                    'lastName',
                  ) ??
                  '',
          age:
              prefs.getInt('age') ?? 0,
          contactNo:
              prefs.getString(
                    'contactNo',
                  ) ??
                  '',
          gender:
              prefs.getString(
                    'gender',
                  ) ??
                  '',
          image:
              prefs.getString(
                    'image',
                  ) ??
                  '',
        );
      }
    }

    // =========================
    // DUMMYJSON PROFILE
    // =========================

    if (loginType == LoginType.dummyJson) {
      final loggedIn =
          prefs.getBool(
                'isLoggedIn',
              ) ??
              false;

      if (!loggedIn) {
        return null;
      }

      return User(
        id:
            prefs.getInt(
                  'userId',
                ) ??
                0,
        username:
            prefs.getString(
                  'username',
                ) ??
                '',
        email:
            prefs.getString(
                  'email',
                ) ??
                '',
        firstName:
            prefs.getString(
                  'firstName',
                ) ??
                '',
        lastName:
            prefs.getString(
                  'lastName',
                ) ??
                '',
        age:
            prefs.getInt('age') ?? 0,
        contactNo:
            prefs.getString(
                  'contactNo',
                ) ??
                '',
        gender:
            prefs.getString(
                  'gender',
                ) ??
                '',
        image:
            prefs.getString(
                  'image',
                ) ??
                '',
      );
    }

    return null;
  }

  // =========================
  // UPDATE USERNAME
  // =========================

  Future<void> updateUsername(
    String username,
  ) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    final cleanedUsername =
        username.trim();

    if (cleanedUsername.isEmpty) {
      throw Exception(
        'Username cannot be empty.',
      );
    }

    await user.updateDisplayName(
      cleanedUsername,
    );

    await user.reload();

    final updatedUser =
        _auth.currentUser;

    if (updatedUser != null) {
      await _saveFirebaseUserData(
        updatedUser,
      );

      await _saveFirebaseProfileToFirestore(
        updatedUser,
      );
    }
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<void> deleteAccount() async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.clear();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to delete profile data: ${e.message}',
      );
    }
  }

  // =========================
  // CHANGE PASSWORD
  // =========================

  Future<void>
      resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    final email = user.email;

    if (email == null ||
        email.isEmpty) {
      throw Exception(
        'The current account does not have an email address.',
      );
    }

    if (currentPassword.isEmpty) {
      throw Exception(
        'Please enter your current password.',
      );
    }

    if (newPassword.length < 6) {
      throw Exception(
        'The new password must be at least 6 characters.',
      );
    }

    try {
      final credential =
          firebase_auth.EmailAuthProvider
              .credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(
        credential,
      );

      await user.updatePassword(
        newPassword,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(
        _firebaseErrorMessage(e),
      );
    }
  }

  // =========================
  // GET FIREBASE USER
  // =========================

  Future<firebase_auth.User?>
      getFirebaseUserData() async {
    return _auth.currentUser;
  }

  // =========================
  // FIRESTORE PROFILE
  // =========================

  Future<void> _saveFirebaseProfileToFirestore(
    firebase_auth.User user,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'uid': user.uid,
        'username':
            user.displayName ?? '',
        'email':
            user.email ?? '',
        'firstName':
            prefs.getString(
                  'firstName',
                ) ??
                '',
        'lastName':
            prefs.getString(
                  'lastName',
                ) ??
                '',
        'age':
            prefs.getInt('age') ?? 0,
        'contactNo':
            prefs.getString(
                  'contactNo',
                ) ??
                '',
        'gender':
            prefs.getString(
                  'gender',
                ) ??
                '',
        'image':
            prefs.getString(
                  'image',
                ) ??
                '',
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  // =========================
  // SAVE FIREBASE USER DATA
  // =========================

  Future<void> _saveFirebaseUserData(
    firebase_auth.User user,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'isLoggedIn',
      true,
    );

    await prefs.setString(
      'loginType',
      'firebase',
    );

    await prefs.setString(
      'firebaseUid',
      user.uid,
    );

    await prefs.setString(
      'username',
      user.displayName ?? '',
    );

    await prefs.setString(
      'email',
      user.email ?? '',
    );

    await prefs.setString(
      'displayName',
      user.displayName ?? '',
    );
  }

  // =========================
  // SAVE DUMMYJSON USER DATA
  // =========================

  Future<void> _saveDummyJsonUserData(
    User user,
    Map<String, dynamic> data,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'isLoggedIn',
      true,
    );

    await prefs.setString(
      'loginType',
      'dummyJson',
    );

    await prefs.setInt(
      'userId',
      user.id,
    );

    await prefs.setString(
      'username',
      user.username,
    );

    await prefs.setString(
      'email',
      user.email,
    );

    await prefs.setString(
      'firstName',
      user.firstName,
    );

    await prefs.setString(
      'lastName',
      user.lastName,
    );

    await prefs.setInt(
      'age',
      user.age,
    );

    await prefs.setString(
      'contactNo',
      user.contactNo,
    );

    await prefs.setString(
      'gender',
      user.gender,
    );

    await prefs.setString(
      'image',
      user.image,
    );

    final accessToken =
        data['accessToken']?.toString();

    if (accessToken != null &&
        accessToken.isNotEmpty) {
      await prefs.setString(
        'dummyJsonAccessToken',
        accessToken,
      );
    }

    final refreshToken =
        data['refreshToken']?.toString();

    if (refreshToken != null &&
        refreshToken.isNotEmpty) {
      await prefs.setString(
        'dummyJsonRefreshToken',
        refreshToken,
      );
    }
  }

  // =========================
  // FIREBASE ERROR MESSAGES
  // =========================

  String _firebaseErrorMessage(
    firebase_auth.FirebaseAuthException e,
  ) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'requires-recent-login':
        return 'Please sign in again before performing this action.';

      default:
        return e.message ??
            'Unable to complete the request.';
    }
  }
}