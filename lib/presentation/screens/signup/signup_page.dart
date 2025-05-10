import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skillet/common/formatters/formatters.dart';
import 'package:skillet/features/authentication/google_auth/google_auth_service.dart';
import 'package:skillet/presentation/screens/home_screen.dart';
import 'package:skillet/state_management/controllers/signup_controlller.dart';
import '../../../core/utils/constants/loaders.dart';
import '../login/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService _authService = AuthService();
  final controller = Get.put(SignUpController());
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background set to black
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black, // AppBar set to black
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: controller.signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create an account",
                  style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  "Welcome! Please enter your details.",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                /// Name Fields
                _buildLabel("Name"),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller.firstName, "First Name", Iconsax.profile_2user)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(controller.lastName, "Last Name", Iconsax.profile_2user)),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                /// Phone Number Field
                _buildLabel("Phone Number"),
                _buildTextField(controller.phoneNumber, "Phone Number", Icons.phone, isPhone: true),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                /// Email Field
                _buildLabel("Email"),
                _buildTextField(controller.email, "Enter your email", Icons.mail_outline),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                /// Password Field
                _buildLabel("Password"),
                TextFormField(
                  cursorColor: Colors.white,
                  controller: controller.password,
                  obscureText: _obscureText,
                  decoration: _inputDecoration("Enter your password", Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                      icon: Icon(_obscureText ? Iconsax.eye_slash : Iconsax.eye, color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => InputValidators.validatePassword(value),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                /// Sign Up Button
                GestureDetector(
                  onTap: () => controller.signUp(context),
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text("Sign Up", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                /// Login Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
                    TextButton(
                      onPressed: () => Get.to(() => const LoginPage()),
                      child: Text("Log in", style: GoogleFonts.poppins(color: Colors.blue, fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a text field with a consistent style
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      cursorColor: Colors.white,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: _inputDecoration(hint, icon),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value!.isEmpty) return '$hint is required';
        return null;
      },
    );
  }

  /// Builds a styled label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
    );
  }

  /// Common input decoration
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }
}
