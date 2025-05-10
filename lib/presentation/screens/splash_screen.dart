import 'package:flutter/material.dart';
import 'package:skillet/core/utils/constants/image_constants.dart';
import 'package:skillet/data/repositories/authentication_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      AuthenticationRepository.instance.screenRedirect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     Color(0xFFBFC3C8), // Light grayish tone at the top
            //     Color(0xFF7F8C97), // Slightly darker gradient effect
            //   ],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
        ),
        child: Center(
          child: Image.asset(
            ImageStrings.splashScreen, // Ensure the image is in your assets folder
            width: 350, // Adjust as per need
          ),
        ),
      ),
    );
  }
}
