import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../common/components/custom_button.dart';
import '../login/login_page.dart';

class SucesssEmail extends StatelessWidget {
  const SucesssEmail({super.key, required this.image, required this.title, required this.subTitle, required this.onPressed});

  final String image, title, subTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Get.offAll(() => const LoginPage()),
          icon: const Icon(CupertinoIcons.clear, color: Colors.white,),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
            children: [
              /// Image
              Lottie.asset('assets/animations/successfully_registered.json'),
              // Image.asset(ImageStrings.successEmail),
              // const SizedBox(height: 15),

              /// Title and Subtitle
              Text(
                'Your email has been verified successfully!',
                style: GoogleFonts.poppins(
                    fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              /// Button
              CustomButton(initialColor: Colors.blue, pressedColor: Colors.blue.shade100,buttonText: 'Continue', onTap: () => Get.to(LoginPage())),
            ],
          ),
        ),
      ),
    );
  }
}
