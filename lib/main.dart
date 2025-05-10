import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:skillet/app.dart';
import 'package:skillet/data/repositories/user_repository.dart';
import 'package:skillet/state_management/controllers/cart_controller.dart';
import 'package:skillet/state_management/controllers/signup_controlller.dart';

import 'data/repositories/authentication_repository.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init(); // Initialize GetStorage for local storage

  await Hive.initFlutter();
  await Hive.openBox('downloads');
  /// Register AuthenticationRepository
  Get.put(AuthenticationRepository());
  Get.put(UserRepository());
  Get.put(CartController());
  runApp(MyApp());
}
