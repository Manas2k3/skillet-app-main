import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skillet/navigation_menu.dart';
import 'package:skillet/presentation/screens/home_screen.dart';
import '../../core/utils/constants/animation_constants.dart';
import '../../core/utils/constants/loaders.dart';
import '../../core/utils/popups/full_screen.dart';

class LoginController extends GetxController {
  // Controllers for the email and password fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();

  /// Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Function to handle login using Firebase Authentication
  Future<void> loginWithEmail(BuildContext context) async {
    try {
      // Show loading dialog
      FullScreenLoader.openLoadingDialog(
        "Signing you in...",
        AnimationStrings.loadingAnimation,
      );

      // Get user input
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      // Validate the form fields
      if (!loginFormKey.currentState!.validate()) {
        Get.back(); // Close the loading dialog
        return;
      }

      // Authenticate user with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('Users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Retrieve the user data from Firestore
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          // Access user data from Firestore
          String firstName = userData['firstName'] ?? 'No name available';
          String lastName = userData['lastName'] ?? 'No name available';
          String phone = userData['phone'] ?? 'No phone available';
          String gender = userData['gender'] ?? 'No gender available';
          String email = userData['email'] ?? 'No email available';

          // Print or use the fetched user data as required
          print('Name: $firstName');
          print('Name: $lastName');
          print('Phone: $phone');
          print('Gender: $gender');
          print('Email: $email');

          // Proceed to the navigation menu after successful login and data retrieval
          Loaders.successSnackBar(
            title: "Login Successful",
            message: "Login successful and data fetched!",
          );
          Get.offAll(() => NavigationMenu());
        } else {
          // Handle case where user document doesn't exist
          Loaders.errorSnackBar(
            title: 'User does not exist!',
            message: 'Consider creating an account first',
          );
        }
      } else {
        throw Exception("Failed to log in.");
      }
    } on FirebaseAuthException catch (e) {
      // Display an appropriate error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getFirebaseAuthErrorMessage(e)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oops!', message: 'An error occurred');
    } finally {
      Get.back(); // Close the loading dialog
    }
  }


  /// Error message mapper for Firebase Authentication
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'The email address is invalid.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
