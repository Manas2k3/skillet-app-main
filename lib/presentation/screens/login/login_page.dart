import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillet/common/formatters/formatters.dart';
import 'package:skillet/presentation/screens/login/recover_password.dart';
import 'package:skillet/presentation/screens/signup/signup_page.dart';
import '../../../features/authentication/google_auth/google_auth_service.dart';
import '../../../state_management/controllers/login_controller.dart';
import '../home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = Get.put(LoginController());
  final AuthService _authService = AuthService();
  bool _obscureText = true;

  Future<void> _saveUserData(User user) async {
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'id': user.uid,
        'firstName': user.displayName?.split(' ').first ?? '',
        'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
        'email': user.email,
        'phone': user.phoneNumber ?? '',
        'paymentStatus': false,
        'createdAt': DateTime.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Log in",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                Text(
                  "Welcome back! Please enter your details.",
                  style: GoogleFonts.poppins(color: Colors.white60),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                /// Email Field
                Text("Email",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                TextFormField(
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline, color: Colors.white),
                    hintText: "Enter your email",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue)),
                  ),
                  validator: (value) => InputValidators.validateEmail(value),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                /// Password Field
                Text("Password",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                TextFormField(
                  cursorColor: Colors.white,
                  controller: controller.passwordController,
                  obscureText: _obscureText,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Iconsax.eye_slash : Iconsax.eye,
                        color: Colors.white,
                      ),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                    hintText: "Enter your password",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue)),
                  ),
                  validator: (value) => InputValidators.validatePassword(value),
                ),

                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => Get.to(() => RecoverPassword()),
                        child: Text(
                          "Forgot your password?",
                          style: GoogleFonts.poppins(color: Colors.blue),
                        ))),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                ///Sign Up Button
                GestureDetector(
                  onTap: () => controller.loginWithEmail(context),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15)),
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Text("Log in",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 16)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                ///Divider
                // Row(
                //   children: [
                //     Expanded(
                //       child: Divider(color: Colors.grey.shade700, thickness: 1),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //       child: Text("Or log in with", style: GoogleFonts.poppins(color: Colors.grey.shade700),),
                //     ),
                //     Expanded(
                //       child: Divider(color: Colors.grey.shade700, thickness: 1),
                //     ),
                //   ],
                // ),
                // GestureDetector(
                //   onTap: () async {
                //     final user = await _authService.signInWithGoogle();
                //     if (user != null) {
                //       await _saveUserData(user);
                //       Get.offAll(() => HomeScreen());
                //     } else {
                //       Get.snackbar("Login Failed", "Something went wrong, please try again.",
                //           snackPosition: SnackPosition.BOTTOM);
                //     }
                //   },
                //   child: Padding(
                //     padding: EdgeInsets.symmetric(horizontal:150),
                //     child: Container(
                //       alignment: Alignment.center,
                //       height: MediaQuery.of(context).size.height*0.08,
                //       width: MediaQuery.of(context).size.width*0.2,
                //       decoration: BoxDecoration(
                //         border: Border.all(color: Colors.grey.shade400, width: 1.0),
                //         borderRadius: BorderRadius.circular(12),
                //         color: Colors.white,
                //       ),
                //       child: Image.network("https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png"),
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: Row(
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: Colors.white),
                      ),
                      TextButton(
                          onPressed: () => Get.to(SignupPage()),
                          child: Text(
                            "Sign up",
                            style: GoogleFonts.poppins(
                                color: Colors.blue, fontSize: 15),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
