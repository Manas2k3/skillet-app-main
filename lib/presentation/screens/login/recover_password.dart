import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/components/custom_button.dart';
import '../../../common/formatters/formatters.dart';
import '../../../state_management/controllers/forgot_password_controller.dart';
import 'login_page.dart';

class RecoverPassword extends StatelessWidget {
  const RecoverPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Get.offAll(() => const LoginPage()),
          icon: const Icon(Icons.arrow_back, color: Colors.white,), // Use back arrow
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Heading
            Text(
              'Recover your password',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600, // Added proper styling
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Don't worry we've got your back, enter your email and we will send you a password reset link",
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(color: Colors.white60),
            ),

            SizedBox(height: 25),

            Form(
              key: controller.forgetPasswordFormKey,
              child: TextFormField(
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                controller: controller.email,
                decoration: InputDecoration(
                    floatingLabelStyle: TextStyle(color: Colors.grey.shade100),
                    hintText: "Enter your mail",
                    hintStyle: GoogleFonts.poppins(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white)
                    ),
                    prefixIcon: Icon(Iconsax.direct_right, color: Colors.white,),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
                validator: InputValidators.validateEmail,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(40.0),
              child: CustomButton(initialColor: Colors.blue, pressedColor: Colors.blueAccent,buttonText: "Submit", onTap: () => ForgetPasswordController.instance.sendPasswordResetMail(context)),
            )
            // You can add further widgets for email input, recovery steps, etc.
          ],
        ),
      ),
    );
  }
}
