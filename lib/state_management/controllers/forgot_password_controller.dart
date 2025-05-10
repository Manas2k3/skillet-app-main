import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../core/utils/constants/animation_constants.dart';
import '../../core/utils/constants/loaders.dart';
import '../../core/utils/popups/full_screen.dart';
import '../../data/repositories/authentication_repository.dart';
import '../../presentation/screens/login/reset_password.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// Variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Check Internet Connection
  Future<bool> _isInternetConnected() async {
    final checker = InternetConnectionChecker.createInstance();
    return await checker.hasConnection;
  }

  /// Send Reset Password Email
  Future<void> sendPasswordResetMail(BuildContext context) async {
    try {
      FullScreenLoader.openLoadingDialog(
        "We are processing your information",
        AnimationStrings.loadingAnimation,
      );

      /// Internet connection check
      if (!(await _isInternetConnected())) {
        FullScreenLoader.stopLoading();
        _showNoInternetDialog(context);
        return;
      }

      /// Form Validation
      if (!forgetPasswordFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      /// Send Email to Reset the Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

      /// Removal of the loader
      FullScreenLoader.stopLoading();

      /// Show success screen
      Loaders.successSnackBar(
        title: 'Email Sent!',
        message: 'Email link has been sent to reset your password!',
      );

      /// Pass the email entered to the ResetPassword page
      Get.to(() => ResetPassword(email: email.text.trim()));

    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(
        title: 'Oh Snap!',
        message: e.toString(),
      );
    }
  }

  /// Resend Password Reset Email
  Future<void> resendPasswordResetMail(String email, BuildContext context) async {
    try {
      FullScreenLoader.openLoadingDialog(
        "We are processing your information",
        AnimationStrings.loadingAnimation,
      );

      /// Internet connection check
      if (!(await _isInternetConnected())) {
        FullScreenLoader.stopLoading();
        _showNoInternetDialog(context);
        return;
      }

      /// Send Email to Reset the Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      /// Removal of the loader
      FullScreenLoader.stopLoading();

      /// Show success screen
      Loaders.successSnackBar(
        title: 'Email Sent!',
        message: 'Email link has been sent to reset your password!',
      );

    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(
        title: 'Oh Snap!',
        message: e.toString(),
      );
    }
  }

  /// Show No Internet Dialog
  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Internet"),
          content: const Text("Please check your internet connection."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
