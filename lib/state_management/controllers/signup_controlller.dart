import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../Cards/card_contents.dart';
import '../../core/utils/constants/animation_constants.dart';
import '../../core/utils/constants/loaders.dart';
import '../../core/utils/popups/full_screen.dart';
import '../../core/utils/storage/user_model.dart';
import '../../data/repositories/authentication_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../presentation/screens/signup/verify_mail.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  Future<void> signUp(BuildContext context) async {
    try {
      _showLoader();
      if (!await _isInternetConnected()) {
        _hideLoader();
        _showNoInternetDialog(context);
        return;
      }
      if (!_validateForm()) {
        _hideLoader();
        return;
      }
      final userCredential = await AuthenticationRepository.instance
          .registerWithEmailAndPassword(email.text.trim(), password.text.trim());

      if (userCredential.user == null) throw Exception("User  creation failed.");

      await _saveUserData(userCredential.user!.uid);
      await _createPurchaseRecord(userCredential.user!.uid); // Create purchase record
      await _fetchUserData(userCredential.user!.uid);
      _hideLoader();

      Loaders.successSnackBar(title: 'Success!', message: "Verify your email to proceed.");
      Get.to(() => VerifyMail(email: email.text.trim()));
    } catch (e, stackTrace) {
      _handleSignUpError(e, stackTrace);
    }
  }

  void _showLoader() => FullScreenLoader.openLoadingDialog("Processing", AnimationStrings.loadingAnimation);
  void _hideLoader() => FullScreenLoader.stopLoading();

  Future<bool> _isInternetConnected() async {
    final checker = InternetConnectionChecker.createInstance();
    return await checker.hasConnection;
  }

  bool _validateForm() => signUpFormKey.currentState?.validate() ?? false;

  Future<void> _saveUserData(String userId) async {
    final userEmail = email.text.trim();

    // Determine role based on email domain
    String role = userEmail.endsWith('@sallet.in') ? 'Teacher' : 'Student';

    final newUser = UserModel(
      id: userId,
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      email: userEmail,
      phone: phoneNumber.text.trim(),
      createdAt: DateTime.now(),
      role: role, // <--- Added role here
    );

    await Get.find<UserRepository>().savedUserRecord(newUser);
  }


  Future<void> _createPurchaseRecord(String userId) async {
    // Create a new document in the purchases collection for the user
    await FirebaseFirestore.instance.collection('Purchases').doc(userId).set({
      'userId': userId,
      'purchasedCourses': [], // Initialize with an empty list
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _fetchUserData(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      debugPrint('User  data fetched: ${userDoc.data()}');
    } else {
      debugPrint('User  does not exist.');
    }
  }

  void _handleSignUpError(Object e, StackTrace stackTrace) {
    _hideLoader();
    debugPrint("Sign-up error: $e");
    debugPrint("Stack trace: $stackTrace");
    Future.delayed(const Duration(milliseconds: 100), () => Loaders.errorSnackBar(title: "Error", message: e.toString()));
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Internet"),
        content: const Text("Please check your internet connection."),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK"))],
      ),
    );
  }
}