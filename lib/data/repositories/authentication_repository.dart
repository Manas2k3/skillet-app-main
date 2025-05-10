import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../navigation_menu.dart';
import '../../pages/onboarding/onboarding.dart';
import '../../presentation/screens/login/login_page.dart';
import '../../presentation/screens/signup/signup_page.dart';
import '../../presentation/screens/signup/verify_mail.dart';
import '../../presentation/screens/splash_screen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  @override
  void onReady() {
    super.onReady();
    _requestStoragePermission();
    // screenRedirect(); // Ensure redirection happens when the controller initializes
  }

  /// 🔥 Request Storage Permission on First Launch
  Future<void> _requestStoragePermission() async {
    bool isFirstLaunch = deviceStorage.read('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      var status = await Permission.storage.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        Get.snackbar(
          "Permission Denied",
          "Storage permission is needed for downloads.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      deviceStorage.write('isFirstLaunch', false); // Mark as not first launch
    }
  }

  /// Function to determine the screen redirection based on user status
  Future<void> screenRedirect() async {

    User? user = _auth.currentUser;

    /// Check if it's the first time launching the app
    if (user != null) {
      // If the user is logged in
      if (user.emailVerified) {
        // Redirect to main navigation screen initially
        Get.offAll(() => NavigationMenu());
      } else {
        // If the user's email is not verified, navigate to the Verify Email screen
        Get.offAll(() => VerifyMail(
          email: _auth.currentUser?.email,
        ));
      }
    } else {
      // First-time user or logged-out user redirection
      deviceStorage.writeIfNull('isFirstTime', true);
      deviceStorage.read('isFirstTime') != true
          ? Get.offAll(() => const LoginPage())
          : Get.offAll(() => const OnboardingPage());
    }
  }

  /// Function to register credentials with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // More detailed logging
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          throw 'Email is already registered. Please use a different email.';
        case 'invalid-email':
          throw 'Invalid email format. Please check your email.';
        case 'operation-not-allowed':
          throw 'Email/password accounts are not enabled.';
        case 'weak-password':
          throw 'Password is too weak. Please choose a stronger password.';
        default:
          throw 'Authentication failed. Please try again.';
      }
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function that sends email verification to the registered email id
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(message: e.message, code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(message: e.message, code: e.code, plugin: '');
    } on FormatException {
      throw const FormatException('Invalid format.');
    } on  PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function to log in using email and password
  Future<UserCredential> loginWithEmailandPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(message: e.message, code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(message: e.message, code: e.code, plugin: '');
    } on FormatException {
      throw const FormatException('Invalid format.');
    } on PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function for the forget password functionality
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(message: e.message, code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(message: e.message, code: e.code, plugin: '');
    } on FormatException {
      throw const FormatException('Invalid format.');
    } on PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  /// Function to log out from the signed-in account
  Future<void> logOut() async {
    try {
      await _auth.signOut();
      Get.offAll(() => const LoginPage());
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(message: e.message, code: e.code);
    } on FirebaseException catch (e) {
      throw FirebaseException(message: e.message, code: e.code, plugin: '');
    } on FormatException {
      throw const FormatException('Invalid format.');
    } on PlatformException catch (e) {
      throw PlatformException(message: e.message, code: e.code);
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

}
