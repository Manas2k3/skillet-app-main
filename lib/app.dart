import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skillet/presentation/screens/downloads/download_screen.dart';
import 'package:skillet/presentation/screens/profile_screen/profile_screen.dart';
import 'package:skillet/presentation/screens/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      getPages: [
        GetPage(name: "/splash", page: () => SplashScreen()),
        GetPage(name: "/profile", page: () => ProfileScreen()),
        GetPage(name: "/downloads", page: () => DownloadsScreen()), // Added route
      ],
    );
  }
}
