import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/constants/image_constants.dart';
import '../../../data/repositories/authentication_repository.dart';
import '../../../state_management/controllers/verify_email_controller.dart';

class VerifyMail extends StatelessWidget {
  const VerifyMail({super.key, required this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => AuthenticationRepository.instance.logOut(),
          icon: const Icon(CupertinoIcons.clear, color: Colors.white,),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              /// Image
              Image.asset(ImageStrings.verifyEmail),
              const SizedBox(height: 15),

              /// Title and Subtitle
              Text(
                'Verify Your Email Address!',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),

              SizedBox(
                height: 10,
              ),
              Text(
                'Your account has been created sucessfully, please do verify your email to proceed ahead',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white60),
              ),
              SizedBox(height: 25),

              Column(
                children: [
                  Text(
                    'Mail has been sent to ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '$email',
                    style:
                        GoogleFonts.poppins(color: Colors.blue, fontSize: 18),
                  )
                ],
              ),

              /// Buttons (you can add your buttons here)

              // CustomButton(color: Colors.redAccent,buttonText: 'Continue', onTap: () => controller.checkEmailVerificationStatus()),

              SizedBox(height: 10),

              TextButton(
                  onPressed: () => controller.sendEmailVerification(),
                  child: Text(
                    'Resend Email',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
